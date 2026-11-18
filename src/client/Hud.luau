-- Hud.luau
-- The player HUD for Brainrot Bay (build4, written from scratch).
-- Top bar sits at y-offset 44 (below Roblox's own menu/chat buttons) and
-- the event banner at 106, so nothing is ever covered by the Roblox UI.

local Hud = {}

local TOP_BAR_Y = 44
local BANNER_Y = 106

local function makeButton(parent, text, color, yOffset)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 170, 0, 44)
	button.Position = UDim2.new(1, -185, 0, yOffset)
	button.BackgroundColor3 = color
	button.Text = text
	button.TextSize = 18
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

local function makePanel(parent, title)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 340, 0, 260)
	frame.Position = UDim2.new(0.5, -170, 0.5, -130)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.Visible = false
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local heading = Instance.new("TextLabel")
	heading.Size = UDim2.new(1, 0, 0, 36)
	heading.BackgroundTransparency = 1
	heading.Text = title
	heading.TextSize = 20
	heading.TextColor3 = Color3.fromRGB(255, 255, 255)
	heading.Font = Enum.Font.GothamBold
	heading.Parent = frame
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 32, 0, 32)
	close.Position = UDim2.new(1, -38, 0, 4)
	close.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	close.Text = "X"
	close.TextSize = 16
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.Parent = frame
	close.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)
	return frame
end

function Hud.init(player, remotes)
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotHud"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Top bar: cash, income, rebirths.
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(0, 470, 0, 36)
	topBar.Position = UDim2.new(0.5, -235, 0, TOP_BAR_Y)
	topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	topBar.Parent = gui
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 8)
	topCorner.Parent = topBar

	local cashLabel = Instance.new("TextLabel")
	cashLabel.Name = "CashLabel"
	cashLabel.Size = UDim2.new(0, 150, 1, 0)
	cashLabel.Position = UDim2.new(0, 8, 0, 0)
	cashLabel.BackgroundTransparency = 1
	cashLabel.Text = "Cash: $150"
	cashLabel.TextSize = 18
	cashLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	cashLabel.Font = Enum.Font.GothamBold
	cashLabel.Parent = topBar

	local incomeLabel = Instance.new("TextLabel")
	incomeLabel.Name = "IncomeLabel"
	incomeLabel.Size = UDim2.new(0, 130, 1, 0)
	incomeLabel.Position = UDim2.new(0, 160, 0, 0)
	incomeLabel.BackgroundTransparency = 1
	incomeLabel.Text = "$0/s"
	incomeLabel.TextSize = 18
	incomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	incomeLabel.Font = Enum.Font.GothamBold
	incomeLabel.Parent = topBar

	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Name = "RebirthLabel"
	rebirthLabel.Size = UDim2.new(0, 160, 1, 0)
	rebirthLabel.Position = UDim2.new(0, 300, 0, 0)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.Text = "Rebirths: 0"
	rebirthLabel.TextSize = 18
	rebirthLabel.TextColor3 = Color3.fromRGB(255, 210, 80)
	rebirthLabel.Font = Enum.Font.GothamBold
	rebirthLabel.Parent = topBar

	-- Event banner, hidden until an event fires.
	local banner = Instance.new("TextLabel")
	banner.Name = "EventBanner"
	banner.Size = UDim2.new(0, 520, 0, 36)
	banner.Position = UDim2.new(0.5, -260, 0, BANNER_Y)
	banner.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	banner.Text = ""
	banner.TextSize = 20
	banner.TextColor3 = Color3.fromRGB(255, 255, 255)
	banner.Font = Enum.Font.GothamBold
	banner.Visible = false
	banner.Parent = gui
	local bannerCorner = Instance.new("UICorner")
	bannerCorner.CornerRadius = UDim.new(0, 8)
	bannerCorner.Parent = banner

	-- Notify line under the banner.
	local notifyLabel = Instance.new("TextLabel")
	notifyLabel.Name = "NotifyLabel"
	notifyLabel.Size = UDim2.new(0, 520, 0, 28)
	notifyLabel.Position = UDim2.new(0.5, -260, 0, BANNER_Y + 44)
	notifyLabel.BackgroundTransparency = 1
	notifyLabel.Text = ""
	notifyLabel.TextSize = 16
	notifyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifyLabel.Font = Enum.Font.GothamBold
	notifyLabel.TextStrokeTransparency = 0.5
	notifyLabel.Parent = gui

	-- Right-side buttons.
	local lockButton = makeButton(gui, "LOCK BASE", Color3.fromRGB(70, 110, 255), 170)
	local rebirthButton = makeButton(gui, "REBIRTH", Color3.fromRGB(160, 80, 220), 224)
	local upgradesButton = makeButton(gui, "UPGRADES", Color3.fromRGB(70, 180, 90), 278)
	local helpButton = makeButton(gui, "?", Color3.fromRGB(120, 120, 130), 332)
	helpButton.Size = UDim2.new(0, 44, 0, 44)
	helpButton.Position = UDim2.new(1, -59, 0, 332)

	-- Upgrades panel.
	local upgradesPanel = makePanel(gui, "UPGRADES")
	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(1, -16, 0, 30)
	speedLabel.Position = UDim2.new(0, 8, 0, 48)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "Speed Boots: +4 walk speed per level"
	speedLabel.TextSize = 15
	speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedLabel.Font = Enum.Font.Gotham
	speedLabel.Parent = upgradesPanel
	local speedButton = Instance.new("TextButton")
	speedButton.Size = UDim2.new(1, -16, 0, 36)
	speedButton.Position = UDim2.new(0, 8, 0, 80)
	speedButton.BackgroundColor3 = Color3.fromRGB(70, 110, 255)
	speedButton.Text = "Buy Speed level 1 ($500)"
	speedButton.TextSize = 16
	speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedButton.Font = Enum.Font.GothamBold
	speedButton.Parent = upgradesPanel
	local incomeUpgradeLabel = Instance.new("TextLabel")
	incomeUpgradeLabel.Size = UDim2.new(1, -16, 0, 30)
	incomeUpgradeLabel.Position = UDim2.new(0, 8, 0, 130)
	incomeUpgradeLabel.BackgroundTransparency = 1
	incomeUpgradeLabel.Text = "Income Boost: +15% income per level"
	incomeUpgradeLabel.TextSize = 15
	incomeUpgradeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	incomeUpgradeLabel.Font = Enum.Font.Gotham
	incomeUpgradeLabel.Parent = upgradesPanel
	local incomeButton = Instance.new("TextButton")
	incomeButton.Size = UDim2.new(1, -16, 0, 36)
	incomeButton.Position = UDim2.new(0, 8, 0, 162)
	incomeButton.BackgroundColor3 = Color3.fromRGB(70, 180, 90)
	incomeButton.Text = "Buy Income level 1 ($1000)"
	incomeButton.TextSize = 16
	incomeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	incomeButton.Font = Enum.Font.GothamBold
	incomeButton.Parent = upgradesPanel
	local speedLevel = 0
	local incomeLevel = 0
	local speedCosts = { 500, 5000, 50000 }
	local incomeCosts = { 1000, 10000, 100000 }
	speedButton.MouseButton1Click:Connect(function()
		remotes.BuyUpgrade:FireServer("Speed")
		if speedLevel < 3 then
			speedLevel += 1
			if speedLevel < 3 then
				speedButton.Text = "Buy Speed level " .. tostring(speedLevel + 1) .. " ($" .. tostring(speedCosts[speedLevel + 1]) .. ")"
			else
				speedButton.Text = "Speed MAXED"
			end
		end
	end)
	incomeButton.MouseButton1Click:Connect(function()
		remotes.BuyUpgrade:FireServer("Income")
		if incomeLevel < 3 then
			incomeLevel += 1
			if incomeLevel < 3 then
				incomeButton.Text = "Buy Income level " .. tostring(incomeLevel + 1) .. " ($" .. tostring(incomeCosts[incomeLevel + 1]) .. ")"
			else
				incomeButton.Text = "Income MAXED"
			end
		end
	end)

	-- Help panel.
	local helpPanel = makePanel(gui, "HOW TO PLAY")
	local helpText = Instance.new("TextLabel")
	helpText.Size = UDim2.new(1, -16, 1, -48)
	helpText.Position = UDim2.new(0, 8, 0, 44)
	helpText.BackgroundTransparency = 1
	helpText.Text = "Brainrots walk in from the purple portal and along the belt. Click one to buy it -- it walks to your base and earns $/s. Click another player's brainrot to steal it, but run home in 20 seconds! Lock your base to stop thieves. A tsunami sweeps the island every 3 minutes: hide in your base or at spawn."
	helpText.TextSize = 15
	helpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	helpText.Font = Enum.Font.Gotham
	helpText.TextWrapped = true
	helpText.TextYAlignment = Enum.TextYAlignment.Top
	helpText.Parent = helpPanel

	lockButton.MouseButton1Click:Connect(function()
		remotes.LockBase:FireServer()
	end)
	rebirthButton.MouseButton1Click:Connect(function()
		remotes.Rebirth:FireServer()
	end)
	upgradesButton.MouseButton1Click:Connect(function()
		upgradesPanel.Visible = not upgradesPanel.Visible
	end)
	helpButton.MouseButton1Click:Connect(function()
		helpPanel.Visible = not helpPanel.Visible
	end)

	remotes.HudUpdate.OnClientEvent:Connect(function(cash, income, rebirths)
		cashLabel.Text = "Cash: $" .. tostring(cash)
		incomeLabel.Text = "$" .. tostring(income) .. "/s"
		rebirthLabel.Text = "Rebirths: " .. tostring(rebirths)
	end)

	remotes.EventBanner.OnClientEvent:Connect(function(text, seconds)
		banner.Text = text
		banner.Visible = true
		task.delay(seconds, function()
			banner.Visible = false
		end)
	end)

	remotes.Notify.OnClientEvent:Connect(function(text)
		notifyLabel.Text = text
		task.delay(4, function()
			if notifyLabel.Text == text then
				notifyLabel.Text = ""
			end
		end)
	end)
end

return Hud
