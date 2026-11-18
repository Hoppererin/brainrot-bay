-- Brainrot Bay — the HUD.
-- A cash / income / rebirths bar across the top, Lock / Rebirth /
-- Upgrades buttons down the right side, an upgrades panel, a help panel,
-- an event banner and a toast line for the server's messages.
--
-- Placement fix: the top bar sits at y-offset 44, not 8, so the Cash
-- label is no longer hidden under Roblox's own menu and chat buttons in
-- the top-left corner, and the event banner sits at 106, below the bar.
-- The side buttons keep their place on the right.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Hud = {}

local player = Players.LocalPlayer

-- Fixed offsets for the top of the screen (see the note above).
local TOP_BAR_Y = 44
local BANNER_Y = 106

local cashLabel: TextLabel
local incomeLabel: TextLabel
local rebirthLabel: TextLabel
local lockButton: TextButton
local bannerLabel: TextLabel
local toastLabel: TextLabel
local upgradesPanel: Frame
local speedRow: TextLabel
local incomeRow: TextLabel
local speedButton: TextButton
local incomeButton: TextButton

local function makeLabel(parent: Instance, text: string, size: UDim2, textSize: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = size
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.2
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.Parent = parent
	return label
end

local function makeButton(parent: Instance, text: string, size: UDim2, position: UDim2, color: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 20
	button.Font = Enum.Font.GothamBold
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	button.Parent = parent
	return button
end

local function showToast(message: string)
	toastLabel.Text = message
	toastLabel.Visible = true
	task.delay(3, function()
		toastLabel.Text = ""
		toastLabel.Visible = false
	end)
end

local function showBanner(message: string, seconds: number)
	bannerLabel.Text = message
	bannerLabel.Visible = true
	task.delay(seconds, function()
		bannerLabel.Visible = false
	end)
end

-- Renders one HUD snapshot from the server: money, income, rebirths,
-- upgrade levels and costs, and the base lock's countdown.
local function render(snapshot)
	cashLabel.Text = "Cash: $" .. tostring(snapshot.cash)
	incomeLabel.Text = "$" .. tostring(snapshot.income) .. "/s"
	rebirthLabel.Text = "Rebirths: " .. tostring(snapshot.rebirths)
	if snapshot.lockLeft > 0 then
		lockButton.Text = "LOCKED " .. tostring(snapshot.lockLeft) .. "s"
	elseif snapshot.lockCooldownLeft > 0 then
		lockButton.Text = "LOCK (" .. tostring(snapshot.lockCooldownLeft) .. "s)"
	else
		lockButton.Text = "LOCK BASE"
	end
	speedRow.Text = "Speed Boots  Lv " .. tostring(snapshot.speedLevel) .. "/3"
	incomeRow.Text = "Income Boost  Lv " .. tostring(snapshot.incomeLevel) .. "/3"
	if snapshot.speedCost ~= nil then
		speedButton.Text = "Buy $" .. tostring(snapshot.speedCost)
		speedButton.Visible = true
	else
		speedButton.Text = "MAX"
		speedButton.Visible = false
	end
	if snapshot.incomeCost ~= nil then
		incomeButton.Text = "Buy $" .. tostring(snapshot.incomeCost)
		incomeButton.Visible = true
	else
		incomeButton.Text = "MAX"
		incomeButton.Visible = false
	end
end

function Hud.init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local playerGui = player:WaitForChild("PlayerGui")

	local screen = Instance.new("ScreenGui")
	screen.Name = "BrainrotBayHud"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.Parent = playerGui

	-- Top bar: three dark tiles, centred, below Roblox's own buttons.
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(0, 460, 0, 44)
	topBar.Position = UDim2.new(0.5, -230, 0, TOP_BAR_Y)
	topBar.BackgroundTransparency = 1
	topBar.Parent = screen

	cashLabel = makeLabel(topBar, "Cash: $150", UDim2.new(0, 170, 1, 0), 22, Color3.fromRGB(120, 255, 120))
	cashLabel.Position = UDim2.new(0, 0, 0, 0)
	cashLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
	cashLabel.BackgroundTransparency = 0.25
	cashLabel.Parent = topBar

	incomeLabel = makeLabel(topBar, "$0/s", UDim2.new(0, 110, 1, 0), 22, Color3.fromRGB(255, 255, 255))
	incomeLabel.Position = UDim2.new(0, 175, 0, 0)
	incomeLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
	incomeLabel.BackgroundTransparency = 0.25
	incomeLabel.Parent = topBar

	rebirthLabel = makeLabel(topBar, "Rebirths: 0", UDim2.new(0, 170, 1, 0), 22, Color3.fromRGB(255, 220, 90))
	rebirthLabel.Position = UDim2.new(0, 290, 0, 0)
	rebirthLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
	rebirthLabel.BackgroundTransparency = 0.25
	rebirthLabel.Parent = topBar

	-- Event banner: centred under the top bar, hidden until a wave warns.
	bannerLabel = makeLabel(screen, "", UDim2.new(0, 520, 0, 40), 24, Color3.fromRGB(255, 255, 255))
	bannerLabel.Position = UDim2.new(0.5, -260, 0, BANNER_Y)
	bannerLabel.BackgroundColor3 = Color3.fromRGB(20, 90, 180)
	bannerLabel.BackgroundTransparency = 0.2
	bannerLabel.Visible = false
	bannerLabel.Parent = screen

	-- Right-side buttons: lock, rebirth, upgrades, help.
	lockButton = makeButton(screen, "LOCK BASE", UDim2.new(0, 170, 0, 48), UDim2.new(1, -190, 0, 130), Color3.fromRGB(40, 120, 255))
	local rebirthButton = makeButton(screen, "REBIRTH", UDim2.new(0, 170, 0, 48), UDim2.new(1, -190, 0, 188), Color3.fromRGB(150, 60, 220))
	local upgradesButton = makeButton(screen, "UPGRADES", UDim2.new(0, 170, 0, 48), UDim2.new(1, -190, 0, 246), Color3.fromRGB(60, 180, 90))
	local helpButton = makeButton(screen, "?", UDim2.new(0, 48, 0, 48), UDim2.new(1, -190, 0, 304), Color3.fromRGB(90, 90, 90))

	-- Toast line for the server's messages, bottom centre.
	toastLabel = makeLabel(screen, "", UDim2.new(0, 520, 0, 32), 18, Color3.fromRGB(255, 255, 255))
	toastLabel.Position = UDim2.new(0.5, -260, 1, -60)
	toastLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	toastLabel.BackgroundTransparency = 0.3
	toastLabel.Visible = false
	toastLabel.Parent = screen

	-- Upgrades panel: two rows, each a level label and a buy button.
	upgradesPanel = Instance.new("Frame")
	upgradesPanel.Size = UDim2.new(0, 340, 0, 180)
	upgradesPanel.Position = UDim2.new(0.5, -170, 0.5, -90)
	upgradesPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	upgradesPanel.BorderSizePixel = 0
	upgradesPanel.Visible = false
	upgradesPanel.Parent = screen
	local upgradesCorner = Instance.new("UICorner")
	upgradesCorner.CornerRadius = UDim.new(0, 10)
	upgradesCorner.Parent = upgradesPanel

	local upgradesTitle = makeLabel(upgradesPanel, "UPGRADES", UDim2.new(1, 0, 0, 40), 22, Color3.fromRGB(255, 255, 255))
	upgradesTitle.Position = UDim2.new(0, 0, 0, 8)
	upgradesTitle.Parent = upgradesPanel

	speedRow = makeLabel(upgradesPanel, "Speed Boots  Lv 0/3", UDim2.new(0, 200, 0, 36), 17, Color3.fromRGB(255, 255, 255))
	speedRow.Position = UDim2.new(0, 16, 0, 56)
	speedRow.TextXAlignment = Enum.TextXAlignment.Left
	speedRow.Parent = upgradesPanel
	speedButton = makeButton(upgradesPanel, "Buy $500", UDim2.new(0, 100, 0, 36), UDim2.new(1, -116, 0, 56), Color3.fromRGB(60, 180, 90))
	speedButton.TextSize = 16

	incomeRow = makeLabel(upgradesPanel, "Income Boost  Lv 0/3", UDim2.new(0, 200, 0, 36), 17, Color3.fromRGB(255, 255, 255))
	incomeRow.Position = UDim2.new(0, 16, 0, 104)
	incomeRow.TextXAlignment = Enum.TextXAlignment.Left
	incomeRow.Parent = upgradesPanel
	incomeButton = makeButton(upgradesPanel, "Buy $750", UDim2.new(0, 100, 0, 36), UDim2.new(1, -116, 0, 104), Color3.fromRGB(60, 180, 90))
	incomeButton.TextSize = 16

	local upgradesClose = makeButton(upgradesPanel, "Close", UDim2.new(0, 100, 0, 32), UDim2.new(0.5, -50, 0, 148), Color3.fromRGB(90, 90, 90))
	upgradesClose.TextSize = 16

	-- Help panel: how the game is played, in four lines.
	local helpPanel = Instance.new("Frame")
	helpPanel.Size = UDim2.new(0, 420, 0, 220)
	helpPanel.Position = UDim2.new(0.5, -210, 0.5, -110)
	helpPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	helpPanel.BorderSizePixel = 0
	helpPanel.Visible = false
	helpPanel.Parent = screen
	local helpCorner = Instance.new("UICorner")
	helpCorner.CornerRadius = UDim.new(0, 10)
	helpCorner.Parent = helpPanel

	local helpTitle = makeLabel(helpPanel, "HOW TO PLAY", UDim2.new(1, 0, 0, 40), 22, Color3.fromRGB(255, 255, 255))
	helpTitle.Position = UDim2.new(0, 0, 0, 8)
	helpTitle.Parent = helpPanel
	local helpText = makeLabel(
		helpPanel,
		"Click a brainrot on the belt to buy it.\nIt walks to your base and earns $ every second.\nClick a brainrot on another base to steal it.\nA tsunami sweeps the island every 3 minutes!",
		UDim2.new(1, -32, 0, 120),
		16,
		Color3.fromRGB(230, 230, 230)
	)
	helpText.Position = UDim2.new(0, 16, 0, 52)
	helpText.TextXAlignment = Enum.TextXAlignment.Left
	helpText.TextYAlignment = Enum.TextYAlignment.Top
	helpText.Parent = helpPanel
	local helpClose = makeButton(helpPanel, "Close", UDim2.new(0, 100, 0, 32), UDim2.new(0.5, -50, 0, 180), Color3.fromRGB(90, 90, 90))
	helpClose.TextSize = 16

	-- Buttons ask; the server decides.
	lockButton.MouseButton1Click:Connect(function()
		remotes.LockBase:FireServer()
	end)
	rebirthButton.MouseButton1Click:Connect(function()
		remotes.Rebirth:FireServer()
	end)
	upgradesButton.MouseButton1Click:Connect(function()
		upgradesPanel.Visible = not upgradesPanel.Visible
	end)
	upgradesClose.MouseButton1Click:Connect(function()
		upgradesPanel.Visible = false
	end)
	speedButton.MouseButton1Click:Connect(function()
		remotes.BuyUpgrade:FireServer("Speed")
	end)
	incomeButton.MouseButton1Click:Connect(function()
		remotes.BuyUpgrade:FireServer("Income")
	end)
	helpButton.MouseButton1Click:Connect(function()
		helpPanel.Visible = not helpPanel.Visible
	end)
	helpClose.MouseButton1Click:Connect(function()
		helpPanel.Visible = false
	end)

	-- The server's answers: HUD snapshots, toasts and the tsunami banner.
	remotes.HudUpdate.OnClientEvent:Connect(render)
	remotes.Notify.OnClientEvent:Connect(showToast)
	remotes.EventBanner.OnClientEvent:Connect(showBanner)
end

return Hud
