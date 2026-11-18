-- WorldBuilder.luau
-- Runtime dressing for Brainrot Bay (build4, written from scratch):
-- palm trees, spinning gold coins, drifting clouds, the welcome sign,
-- one sign per plot and one pad per slot.
--
-- THE BUILD4 FIX: a plot sign's colour is read from
-- Config.PLOT_COLORS[plot.id]. A Config.PLOTS entry has ONLY `id` and
-- `center` -- reading `.color` off it is nil and used to kill the server
-- before the conveyor ever started. Slot pads take their colour from
-- Plots.get(plotId).color, which is built from PLOT_COLORS.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Plots = require(script.Parent.Plots)

local WorldBuilder = {}

local function makePart(name, size, pos, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = pos
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace
	return part
end

local function makeSignBoard(name, pos, size, text, textColor)
	local board = makePart(name, size, pos, Color3.fromRGB(60, 45, 30), Enum.Material.Wood)
	board.CanCollide = true
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = 28
	label.TextColor3 = textColor
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
	return board
end

local function addPalms()
	local spots = {
		Vector3.new(-60, 0, 80),
		Vector3.new(60, 0, 80),
		Vector3.new(-100, 0, 40),
		Vector3.new(100, 0, -50),
		Vector3.new(-40, 0, -95),
		Vector3.new(40, 0, 95),
	}
	for i, spot in ipairs(spots) do
		local trunk = makePart("PalmTrunk" .. tostring(i), Vector3.new(1, 8, 1), spot + Vector3.new(0, 4, 0), Color3.fromRGB(140, 100, 50), Enum.Material.Wood)
		trunk.Shape = Enum.PartType.Cylinder
		trunk.Rotation = Vector3.new(0, 0, 10)
		for leaf = 1, 3 do
			local ball = makePart("PalmLeaf" .. tostring(i) .. "_" .. tostring(leaf), Vector3.new(4, 1.5, 4), spot + Vector3.new((leaf - 2) * 2.5, 8.5, 0), Color3.fromRGB(40, 160, 60), Enum.Material.Grass)
			ball.Shape = Enum.PartType.Ball
		end
	end
end

local function addCoins()
	local coins = {}
	local spots = {
		Vector3.new(-50, 3, 60),
		Vector3.new(50, 3, 60),
		Vector3.new(-56, 3, -10),
		Vector3.new(56, 3, -10),
		Vector3.new(-20, 3, 40),
		Vector3.new(20, 3, 40),
		Vector3.new(-90, 3, 45),
		Vector3.new(90, 3, 45),
	}
	for i, spot in ipairs(spots) do
		local coin = makePart("GoldCoin" .. tostring(i), Vector3.new(2, 2, 0.4), spot, Color3.fromRGB(255, 215, 0), Enum.Material.Neon)
		coin.Shape = Enum.PartType.Cylinder
		table.insert(coins, coin)
	end
	task.spawn(function()
		while true do
			for _, coin in ipairs(coins) do
				coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(6), 0)
			end
			task.wait(0.1)
		end
	end)
end

local function addClouds()
	local clouds = {}
	for i = 1, 5 do
		local base = Vector3.new(-80 + i * 40, 36 + (i % 2) * 6, -60 + (i % 3) * 50)
		local group = {}
		for puff = 1, 3 do
			local ball = makePart("Cloud" .. tostring(i) .. "_" .. tostring(puff), Vector3.new(10, 5, 8), base + Vector3.new((puff - 2) * 7, 0, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
			ball.Shape = Enum.PartType.Ball
			ball.Transparency = 0.25
			table.insert(group, ball)
		end
		table.insert(clouds, group)
	end
	task.spawn(function()
		while true do
			for _, group in ipairs(clouds) do
				for _, ball in ipairs(group) do
					ball.Position += Vector3.new(0.15, 0, 0)
					if ball.Position.X > 120 then
						ball.Position = Vector3.new(-120, ball.Position.Y, ball.Position.Z)
					end
				end
			end
			task.wait(0.2)
		end
	end)
end

local function addWelcomeSign()
	makeSignBoard("WelcomeSign", Vector3.new(0, 5, 78), Vector3.new(16, 4, 0.5), "WELCOME TO BRAINROT BAY", Color3.fromRGB(255, 220, 100))
end

local function addPlotSigns()
	for _, plot in ipairs(Config.PLOTS) do
		-- Colour from PLOT_COLORS, keyed by plot id. NEVER plot.color:
		-- a PLOTS entry has no `color` field, and nil would error here.
		local signColor = Config.PLOT_COLORS[plot.id]
		local signPos = plot.center + Vector3.new(0, 6, -11)
		makeSignBoard("PlotSign" .. tostring(plot.id), signPos, Vector3.new(10, 3, 0.5), "PLOT " .. tostring(plot.id), signColor)
	end
end

local function addSlotPads()
	for _, plot in ipairs(Config.PLOTS) do
		local full = Plots.get(plot.id)
		if full ~= nil then
			for slot = 1, #Config.SLOT_OFFSETS do
				local pos = Plots.slotPosition(full, slot)
				makePart("SlotPad" .. tostring(plot.id) .. "_" .. tostring(slot), Vector3.new(4, 0.2, 4), pos + Vector3.new(0, 1.1, 0), full.color, Enum.Material.SmoothPlastic)
			end
		end
	end
end

function WorldBuilder.build()
	addPalms()
	addCoins()
	addClouds()
	addWelcomeSign()
	addPlotSigns()
	addSlotPads()
end

return WorldBuilder
