-- Brainrot Bay: the HUD.
-- Builds the whole ScreenGui in code (no asset ids): a top bar with cash,
-- income and rebirths, buttons for Lock / Rebirth / Upgrades, an upgrades
-- panel, a help panel and the event banner. The client never trusts its own
-- numbers: the server pushes HudUpdate every second.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Hud = {}

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local cashLabel: TextLabel
local incomeLabel: TextLabel
local rebirthLabel: TextLabel
local banner: TextLabel
local upgradesPanel: Frame

local function makeButton(parent: Instance, name: string, text: string, position: UDim2, size: UDim2, color: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.SourceSansBold
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

local function makeLabel(parent: Instance, name: string, text: string, position: UDim2, size: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Position = position
	label.Size = size
	label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	label.BackgroundTransparency = 0.4
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = parent
	return label
end

function Hud.build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotBayGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Top bar, kept clear of Roblox's own menu buttons in the top-left.
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.AnchorPoint = Vector2.new(0.5, 0)
	topBar.Position = UDim2.new(0.5, 0, 0, 8)
	topBar.Size = UDim2.new(0, 640, 0, 52)
	topBar.BackgroundTransparency = 1
	topBar.Parent = gui
	cashLabel = makeLabel(topBar, "CashLabel", "Cash: $100", UDim2.new(0, 0, 0, 0), UDim2.new(0, 200, 1, 0))
	cashLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	incomeLabel = makeLabel(topBar, "IncomeLabel", "$0/s", UDim2.new(0, 210, 0, 0), UDim2.new(0, 200, 1, 0))
	rebirthLabel = makeLabel(topBar, "RebirthLabel", "Rebirths: 0", UDim2.new(0, 420, 0, 0), UDim2.new(0, 200, 1, 0))
	rebirthLabel.TextColor3 = Color3.fromRGB(255, 220, 60)

	-- Event banner across the middle of the screen.
	banner = Instance.new("TextLabel")
	banner.Name = "Banner"
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, 70)
	banner.Size = UDim2.new(0, 640, 0, 44)
	banner.BackgroundTransparency = 1
	banner.Text = ""
	banner.TextColor3 = Color3.fromRGB(255, 220, 60)
	banner.TextScaled = true
	banner.Font = Enum.Font.SourceSansBold
	banner.TextStrokeTransparency = 0
	banner.Parent = gui

	-- Buttons down the right side.
	local lockButton = makeButton(gui, "LockButton", "LOCK BASE", UDim2.new(1, -180, 0, 90), UDim2.new(0, 160, 0, 48), Color3.fromRGB(60, 120, 220))
	lockButton.MouseButton1Click:Connect(function()
		Remotes.LockBase:FireServer()
	end)
	local rebirthButton = makeButton(gui, "RebirthButton", "REBIRTH", UDim2.new(1, -180, 0, 146), UDim2.new(0, 160, 0, 48), Color3.fromRGB(160, 60, 200))
	rebirthButton.MouseButton1Click:Connect(function()
		Remotes.Rebirth:FireServer()
	end)
	local upgradesButton = makeButton(gui, "UpgradesButton", "UPGRADES", UDim2.new(1, -180, 0, 202), UDim2.new(0, 160, 0, 48), Color3.fromRGB(60, 180, 90))
	upgradesButton.MouseButton1Click:Connect(function()
		upgradesPanel.Visible = not upgradesPanel.Visible
	end)
	local helpButton = makeButton(gui, "HelpButton", "?", UDim2.new(1, -180, 0, 258), UDim2.new(0, 48, 0, 48), Color3.fromRGB(90, 90, 90))
	helpButton.MouseButton1Click:Connect(function()
		local help = gui:FindFirstChild("HelpPanel")
		if help then
			help.Visible = not help.Visible
		end
	end)

	-- Upgrades panel: Speed boots and the Income boost, three levels each.
	upgradesPanel = Instance.new("Frame")
	upgradesPanel.Name = "UpgradesPanel"
	upgradesPanel.AnchorPoint = Vector2.new(1, 0)
	upgradesPanel.Position = UDim2.new(1, -180, 0, 316)
	upgradesPanel.Size = UDim2.new(0, 300, 0, 190)
	upgradesPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	upgradesPanel.Visible = false
	upgradesPanel.Parent = gui
	local panelTitle = makeLabel(upgradesPanel, "Title", "UPGRADES", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 36))
	panelTitle.BackgroundTransparency = 1
	local speedButton = makeButton(upgradesPanel, "SpeedButton", "Speed boots", UDim2.new(0, 10, 0, 46), UDim2.new(1, -20, 0, 56), Color3.fromRGB(60, 120, 220))
	speedButton.MouseButton1Click:Connect(function()
		Remotes.BuyUpgrade:FireServer("Speed")
	end)
	local incomeButton = makeButton(upgradesPanel, "IncomeButton", "Income boost", UDim2.new(0, 10, 0, 112), UDim2.new(1, -20, 0, 56), Color3.fromRGB(60, 180, 90))
	incomeButton.MouseButton1Click:Connect(function()
		Remotes.BuyUpgrade:FireServer("Income")
	end)

	-- Help panel: the whole game in six lines.
	local helpPanel = Instance.new("Frame")
	helpPanel.Name = "HelpPanel"
	helpPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	helpPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	helpPanel.Size = UDim2.new(0, 520, 0, 320)
	helpPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	helpPanel.Visible = false
	helpPanel.Parent = gui
	local helpText = Instance.new("TextLabel")
	helpText.Size = UDim2.fromScale(1, 1)
	helpText.BackgroundTransparency = 1
	helpText.Text = "HOW TO PLAY\n\n1. Brainrots walk the belt. Click one to buy it.\n2. It moves to your base and earns $ every second.\n3. Click a brainrot on another base to STEAL it —\n   run home before the owner yanks it back!\n4. LOCK your base to stop thieves (60s, then cooldown).\n5. When the TSUNAMI comes, get to your base or spawn!\n6. REBIRTH to reset for a permanent +25% income."
	helpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	helpText.TextScaled = true
	helpText.Font = Enum.Font.SourceSans
	helpText.Parent = helpPanel

	-- Server pushes: numbers every second, banners whenever things happen.
	-- The banner clears itself after 4 s unless a newer message replaced it.
	Remotes.HudUpdate.OnClientEvent:Connect(function(data)
		cashLabel.Text = "Cash: $" .. tostring(data.cash)
		incomeLabel.Text = "$" .. tostring(data.income) .. "/s"
		rebirthLabel.Text = "Rebirths: " .. tostring(data.rebirths)
		local speedCost = Config.UPGRADES.Speed.costs[data.speedLevel + 1]
		local incomeCost = Config.UPGRADES.Income.costs[data.incomeLevel + 1]
		speedButton.Text = speedCost and ("Speed boots Lv" .. tostring(data.speedLevel + 1) .. " — $" .. tostring(speedCost)) or "Speed boots MAX"
		incomeButton.Text = incomeCost and ("Income boost Lv" .. tostring(data.incomeLevel + 1) .. " — $" .. tostring(incomeCost)) or "Income boost MAX"
	end)
	Remotes.Notify.OnClientEvent:Connect(function(text: string)
		banner.Text = text
		task.delay(4, function()
			if banner.Text == text then
				banner.Text = ""
			end
		end)
	end)
end

return Hud
