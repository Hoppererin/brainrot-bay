-- Brainrot Bay — the HUD.
-- Cash/income/rebirths bar (kept below Roblox's own menu buttons), event
-- banner, Lock / Rebirth / Upgrades / Help buttons, an upgrades panel and
-- a help panel. The server is authoritative: this only shows numbers the
-- server sends and asks the server to act.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local Hud = {}
Hud.speedLevel = 0
Hud.incomeLevel = 0

local function makeLabel(parent, name, text, position, size, textSize, textColor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize
	label.TextColor3 = textColor
	label.TextStrokeTransparency = 0.4
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function makeButton(parent, name, text, position, size)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = Color3.fromRGB(50, 90, 160)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 15
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = parent
	return button
end

--- The caption of an upgrade button: name, level and next cost (or MAX).
local function upgradeCaption(kind, level)
	local upgradeDef = Config.UPGRADES[kind]
	if level >= upgradeDef.maxLevel then
		return string.format("%s Lv %d — MAX", upgradeDef.name, level)
	end
	return string.format("%s Lv %d — $%d", upgradeDef.name, level, upgradeDef.costs[level + 1])
end

--- Format a money amount: $1.23M, $4.5K, or $123.
-- (The 999950 threshold keeps 999999 from rounding to "$1000.0K".)
local function formatMoney(amount)
	if amount >= 999950 then
		return string.format("$%.2fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.1fK", amount / 1000)
	else
		return string.format("$%d", amount)
	end
end

function Hud.start(remotes, player)
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotHud"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Top bar: cash, income, rebirths.
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Position = UDim2.new(0, 10, 0, Config.TOP_BAR_Y)
	topBar.Size = UDim2.new(0, 360, 0, 36)
	topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	topBar.BackgroundTransparency = 0.2
	topBar.Parent = gui
	local cashLabel = makeLabel(topBar, "CashLabel", "Cash: " .. formatMoney(150), UDim2.new(0, 10, 0, 0), UDim2.new(0, 130, 1, 0), 16, Color3.fromRGB(255, 255, 120))
	local incomeLabel = makeLabel(topBar, "IncomeLabel", formatMoney(0) .. "/s", UDim2.new(0, 145, 0, 0), UDim2.new(0, 110, 1, 0), 16, Color3.fromRGB(140, 255, 140))
	local rebirthLabel = makeLabel(topBar, "RebirthLabel", "Rebirths: 0", UDim2.new(0, 260, 0, 0), UDim2.new(0, 95, 1, 0), 16, Color3.fromRGB(200, 160, 255))

	-- Event banner, under the top bar.
	local banner = Instance.new("TextLabel")
	banner.Name = "Banner"
	banner.Position = UDim2.new(0.5, -250, 0, Config.BANNER_Y)
	banner.Size = UDim2.new(0, 500, 0, 30)
	banner.BackgroundTransparency = 1
	banner.Font = Enum.Font.GothamBold
	banner.TextSize = 20
	banner.TextColor3 = Color3.fromRGB(255, 120, 60)
	banner.TextStrokeTransparency = 0.3
	banner.Text = ""
	banner.Visible = false
	banner.Parent = gui

	-- Right-side buttons.
	local lockButton = makeButton(gui, "LockButton", "LOCK BASE", UDim2.new(1, -170, 0, 44), UDim2.new(0, 160, 0, 36))
	local rebirthButton = makeButton(gui, "RebirthButton", "REBIRTH", UDim2.new(1, -170, 0, 88), UDim2.new(0, 160, 0, 36))
	local upgradesButton = makeButton(gui, "UpgradesButton", "UPGRADES", UDim2.new(1, -170, 0, 132), UDim2.new(0, 160, 0, 36))
	local helpButton = makeButton(gui, "HelpButton", "?", UDim2.new(1, -170, 0, 176), UDim2.new(0, 160, 0, 36))

	-- Upgrades panel (hidden until opened).
	local upgradesPanel = Instance.new("Frame")
	upgradesPanel.Name = "UpgradesPanel"
	upgradesPanel.Position = UDim2.new(0.5, -150, 0.5, -100)
	upgradesPanel.Size = UDim2.new(0, 300, 0, 200)
	upgradesPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	upgradesPanel.Visible = false
	upgradesPanel.Parent = gui
	makeLabel(upgradesPanel, "Title", "UPGRADES", UDim2.new(0, 10, 0, 10), UDim2.new(0, 280, 0, 30), 18, Color3.fromRGB(255, 255, 255))
	local speedButton = makeButton(upgradesPanel, "SpeedButton", upgradeCaption("Speed", 0), UDim2.new(0, 10, 0, 50), UDim2.new(0, 280, 0, 40))
	local incomeButton = makeButton(upgradesPanel, "IncomeButton", upgradeCaption("Income", 0), UDim2.new(0, 10, 0, 100), UDim2.new(0, 280, 0, 40))
	local closeUpgrades = makeButton(upgradesPanel, "CloseButton", "CLOSE", UDim2.new(0, 10, 0, 150), UDim2.new(0, 280, 0, 36))

	-- Help panel (hidden until opened).
	local helpPanel = Instance.new("Frame")
	helpPanel.Name = "HelpPanel"
	helpPanel.Position = UDim2.new(0.5, -200, 0.5, -130)
	helpPanel.Size = UDim2.new(0, 400, 0, 260)
	helpPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	helpPanel.Visible = false
	helpPanel.Parent = gui
	local helpText = Instance.new("TextLabel")
	helpText.Name = "HelpText"
	helpText.Position = UDim2.new(0, 10, 0, 10)
	helpText.Size = UDim2.new(0, 380, 0, 200)
	helpText.BackgroundTransparency = 1
	helpText.Font = Enum.Font.Gotham
	helpText.TextSize = 14
	helpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	helpText.TextXAlignment = Enum.TextXAlignment.Left
	helpText.TextYAlignment = Enum.TextYAlignment.Top
	helpText.TextWrapped = true
	helpText.Text = "HOW TO PLAY\n\nClick a brainrot on the conveyor to buy it (price = $/s x 25). It walks to your base and earns cash every second.\n\nClick your own brainrot to sell it for 50% back. Click someone else's to steal it — carry it home in 20 seconds!\n\nLOCK BASE stops thieves for 60s. REBIRTH resets cash + brainrots for +25% income per level. A tsunami sweeps the island every 3 minutes — get to spawn or your base!"
	helpText.Parent = helpPanel
	local closeHelp = makeButton(helpPanel, "CloseButton", "CLOSE", UDim2.new(0, 10, 0, 215), UDim2.new(0, 380, 0, 36))

	-- One-line notifications at the bottom.
	local notifyLabel = Instance.new("TextLabel")
	notifyLabel.Name = "NotifyLabel"
	notifyLabel.Position = UDim2.new(0.5, -250, 1, -60)
	notifyLabel.Size = UDim2.new(0, 500, 0, 30)
	notifyLabel.BackgroundTransparency = 1
	notifyLabel.Font = Enum.Font.GothamBold
	notifyLabel.TextSize = 16
	notifyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifyLabel.TextStrokeTransparency = 0.3
	notifyLabel.Text = ""
	notifyLabel.Visible = false
	notifyLabel.Parent = gui

	local function refreshUpgrades()
		speedButton.Text = upgradeCaption("Speed", Hud.speedLevel)
		incomeButton.Text = upgradeCaption("Income", Hud.incomeLevel)
	end

	remotes.HudUpdate.OnClientEvent:Connect(function(cash, income, rebirths, speedLevel, incomeLevel)
		cashLabel.Text = "Cash: " .. formatMoney(cash)
		incomeLabel.Text = formatMoney(income) .. "/s"
		rebirthLabel.Text = string.format("Rebirths: %d", rebirths)
		Hud.speedLevel = speedLevel or 0
		Hud.incomeLevel = incomeLevel or 0
		refreshUpgrades()
	end)

	remotes.HudNotify.OnClientEvent:Connect(function(message)
		notifyLabel.Text = message
		notifyLabel.Visible = true
		task.delay(3, function()
			notifyLabel.Visible = false
		end)
	end)

	remotes.HudBanner.OnClientEvent:Connect(function(text)
		banner.Text = text
		banner.Visible = text ~= ""
	end)

	lockButton.MouseButton1Click:Connect(function()
		remotes.LockRequest:FireServer()
	end)
	rebirthButton.MouseButton1Click:Connect(function()
		remotes.RebirthRequest:FireServer()
	end)
	upgradesButton.MouseButton1Click:Connect(function()
		upgradesPanel.Visible = not upgradesPanel.Visible
	end)
	helpButton.MouseButton1Click:Connect(function()
		helpPanel.Visible = not helpPanel.Visible
	end)
	speedButton.MouseButton1Click:Connect(function()
		remotes.UpgradeRequest:FireServer("Speed")
	end)
	incomeButton.MouseButton1Click:Connect(function()
		remotes.UpgradeRequest:FireServer("Income")
	end)
	closeUpgrades.MouseButton1Click:Connect(function()
		upgradesPanel.Visible = false
	end)
	closeHelp.MouseButton1Click:Connect(function()
		helpPanel.Visible = false
	end)
end

return Hud
