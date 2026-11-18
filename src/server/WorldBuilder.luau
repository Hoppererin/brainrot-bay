-- Brainrot Bay — builds the island at runtime.
-- Sea, sand island, conveyor with neon rails and portal/exit arches, eight
-- colour-coded plots with slot pads and signs, spawn plaza, volcano, lamps,
-- path tiles, palms, clouds, spinning gold coins and a welcome sign.
-- Plot colours ALWAYS come from Config.PLOT_COLORS keyed by plot id.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local WorldBuilder = {}
WorldBuilder.coins = {}

local function makePart(name, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	return part
end

local function addLabel(parent, text, textSize, textColor, height)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(120, 30)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, height, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = parent
	billboard.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = textColor
	label.TextStrokeTransparency = 0.4
	label.Parent = billboard
	return billboard
end

--- The sea and the sand island.
function WorldBuilder.addIsland(parent)
	local sea = makePart("Sea", Vector3.new(600, 1, 600), Color3.fromRGB(30, 120, 200), Enum.Material.SmoothPlastic)
	sea.Position = Vector3.new(0, -1.5, 0)
	sea.Parent = parent
	local island = makePart("Island", Vector3.new(Config.ISLAND_SIZE, 2, Config.ISLAND_SIZE), Color3.fromRGB(240, 220, 160), Enum.Material.Sand)
	island.Position = Vector3.new(0, -1, 0)
	island.CanCollide = true
	island.Parent = parent
end

--- The conveyor belt, neon rails and the portal/exit arches.
function WorldBuilder.addConveyor(parent)
	local belt = makePart("Belt", Vector3.new(Config.CONVEYOR_LENGTH, 1, 10), Color3.fromRGB(50, 50, 60), Enum.Material.SmoothPlastic)
	belt.Position = Vector3.new(0, 0.5, Config.CONVEYOR_Z)
	belt.CanCollide = true
	belt.Parent = parent

	local railNorth = makePart("RailNorth", Vector3.new(Config.CONVEYOR_LENGTH, 0.5, 0.8), Color3.fromRGB(0, 220, 255), Enum.Material.Neon)
	railNorth.Position = Vector3.new(0, 1.2, -75.4)
	railNorth.Parent = parent
	local railSouth = makePart("RailSouth", Vector3.new(Config.CONVEYOR_LENGTH, 0.5, 0.8), Color3.fromRGB(255, 110, 200), Enum.Material.Neon)
	railSouth.Position = Vector3.new(0, 1.2, -64.6)
	railSouth.Parent = parent

	-- Portal arch (west end): two posts and a top beam, purple.
	local portalPostA = makePart("PortalPost", Vector3.new(1, 8, 1), Color3.fromRGB(150, 90, 255), Enum.Material.Neon)
	portalPostA.Position = Vector3.new(-78, 4, -75)
	portalPostA.Parent = parent
	local portalPostB = makePart("PortalPost", Vector3.new(1, 8, 1), Color3.fromRGB(150, 90, 255), Enum.Material.Neon)
	portalPostB.Position = Vector3.new(-78, 4, -65)
	portalPostB.Parent = parent
	local portalTop = makePart("PortalTop", Vector3.new(1, 1, 11), Color3.fromRGB(150, 90, 255), Enum.Material.Neon)
	portalTop.Position = Vector3.new(-78, 8, -70)
	portalTop.Parent = parent
	addLabel(portalTop, "SPAWN", 18, Color3.fromRGB(200, 160, 255), 2)

	-- Exit arch (east end): green.
	local exitPostA = makePart("ExitPost", Vector3.new(1, 8, 1), Color3.fromRGB(80, 220, 90), Enum.Material.Neon)
	exitPostA.Position = Vector3.new(78, 4, -75)
	exitPostA.Parent = parent
	local exitPostB = makePart("ExitPost", Vector3.new(1, 8, 1), Color3.fromRGB(80, 220, 90), Enum.Material.Neon)
	exitPostB.Position = Vector3.new(78, 4, -65)
	exitPostB.Parent = parent
	local exitTop = makePart("ExitTop", Vector3.new(1, 1, 11), Color3.fromRGB(80, 220, 90), Enum.Material.Neon)
	exitTop.Position = Vector3.new(78, 8, -70)
	exitTop.Parent = parent
	addLabel(exitTop, "EXIT", 18, Color3.fromRGB(140, 255, 150), 2)
end

--- The eight base plots: coloured pads and slot pads.
function WorldBuilder.addPlots(parent)
	for _, plotEntry in ipairs(Config.PLOTS) do
		local plotColor = Config.PLOT_COLORS[plotEntry.id]
		local pad = makePart("PlotPad", Config.PLOT_PAD_SIZE, plotColor, Enum.Material.SmoothPlastic)
		pad.Position = plotEntry.center + Vector3.new(0, 0.25, 0)
		pad.CanCollide = true
		pad.Parent = parent
	end
end

--- Slot pads: six small pads on every plot, coloured like the plot.
function WorldBuilder.addSlotPads(parent)
	for _, plotEntry in ipairs(Config.PLOTS) do
		local plotColor = Config.PLOT_COLORS[plotEntry.id]
		for slotIndex, offset in ipairs(Config.SLOT_OFFSETS) do
			local slotPad = makePart("SlotPad", Vector3.new(4, 0.3, 4), plotColor, Enum.Material.Neon)
			slotPad.Position = plotEntry.center + offset + Vector3.new(0, 0.6, 0)
			slotPad.Transparency = 0.5
			slotPad.Parent = parent
		end
	end
end

--- Plot signs: one board per plot, coloured with the plot's colour.
-- The colour comes from Config.PLOT_COLORS[plot.id]. A PLOTS entry has
-- only id and center — reading .color off it would be nil and would kill
-- the whole build, so this never does that.
function WorldBuilder.addPlotSigns(parent)
	for _, plotEntry in ipairs(Config.PLOTS) do
		local boardColor = Config.PLOT_COLORS[plotEntry.id]
		local post = makePart("PlotSignPost", Vector3.new(0.6, 4, 0.6), Color3.fromRGB(120, 80, 40), Enum.Material.Wood)
		post.Position = plotEntry.center + Vector3.new(-14, 2, -9)
		post.Parent = parent
		local board = makePart("PlotBoard", Vector3.new(7, 3, 0.4), boardColor, Enum.Material.SmoothPlastic)
		board.Position = plotEntry.center + Vector3.new(-14, 4.5, -9)
		board.Parent = parent
		addLabel(board, "BASE " .. tostring(plotEntry.id), 20, Color3.fromRGB(255, 255, 255), 2.5)
	end
end

--- Spawn plaza, path tiles, volcano, lamps, palms, clouds, coins, sign.
function WorldBuilder.addDressing(parent)
	local plaza = makePart("SpawnPlaza", Vector3.new(20, 0.5, 20), Color3.fromRGB(200, 200, 210), Enum.Material.SmoothPlastic)
	plaza.Position = Vector3.new(Config.SPAWN_CENTER.X, 0.25, Config.SPAWN_CENTER.Z)
	plaza.CanCollide = true
	plaza.Parent = parent

	for i = 1, 5 do
		local tile = makePart("PathTile", Vector3.new(4, 0.3, 4), Color3.fromRGB(220, 200, 150), Enum.Material.SmoothPlastic)
		tile.Position = Vector3.new(0, 0.15, 60 - i * 8)
		tile.Parent = parent
	end

	-- Volcano in the north-east corner.
	local volcanoBase = makePart("VolcanoBase", Vector3.new(24, 10, 24), Color3.fromRGB(120, 90, 70), Enum.Material.Rock)
	volcanoBase.Position = Vector3.new(90, 5, -90)
	volcanoBase.Parent = parent
	local volcanoTop = makePart("VolcanoTop", Vector3.new(12, 6, 12), Color3.fromRGB(90, 60, 50), Enum.Material.Rock)
	volcanoTop.Position = Vector3.new(90, 12, -90)
	volcanoTop.Parent = parent
	local lava = makePart("Lava", Vector3.new(8, 1, 8), Color3.fromRGB(255, 100, 0), Enum.Material.Neon)
	lava.Position = Vector3.new(90, 15, -90)
	lava.Parent = parent

	-- Lamps along the path.
	for _, lampPos in ipairs({ Vector3.new(-8, 0, 40), Vector3.new(8, 0, 40), Vector3.new(-8, 0, 0), Vector3.new(8, 0, 0) }) do
		local pole = makePart("LampPole", Vector3.new(0.6, 6, 0.6), Color3.fromRGB(80, 80, 80), Enum.Material.Metal)
		pole.Position = lampPos + Vector3.new(0, 3, 0)
		pole.Parent = parent
		local lamp = makePart("Lamp", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(255, 240, 150), Enum.Material.Neon)
		lamp.Position = lampPos + Vector3.new(0, 6.5, 0)
		lamp.Parent = parent
	end

	-- Palm trees.
	for _, palmPos in ipairs({ Vector3.new(-95, 0, 60), Vector3.new(95, 0, 60), Vector3.new(-95, 0, -10), Vector3.new(95, 0, 30), Vector3.new(-60, 0, 85) }) do
		local trunk = makePart("PalmTrunk", Vector3.new(1.2, 8, 1.2), Color3.fromRGB(140, 100, 60), Enum.Material.Wood)
		trunk.Position = palmPos + Vector3.new(0, 4, 0)
		trunk.Parent = parent
		for leafAngle = 0, 3 do
			local leaf = makePart("PalmLeaf", Vector3.new(5, 0.4, 1.5), Color3.fromRGB(60, 180, 80), Enum.Material.SmoothPlastic)
			local angle = math.rad(leafAngle * 90)
			leaf.CFrame = CFrame.new(palmPos + Vector3.new(0, 8.5, 0)) * CFrame.Angles(0, angle, 0) * CFrame.new(2.5, 0, 0)
			leaf.Parent = parent
		end
	end

	-- Clouds drifting high above.
	for _, cloudPos in ipairs({ Vector3.new(-60, 40, -40), Vector3.new(40, 45, 20), Vector3.new(0, 42, -90), Vector3.new(80, 40, 70) }) do
		local cloud = makePart("Cloud", Vector3.new(14, 3, 8), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
		cloud.Position = cloudPos
		cloud.Transparency = 0.2
		cloud.Parent = parent
	end

	-- Spinning gold coins near the spawn.
	for _, coinPos in ipairs({ Vector3.new(-12, 2, 55), Vector3.new(12, 2, 55), Vector3.new(0, 2, 48) }) do
		local coin = makePart("Coin", Vector3.new(0.5, 2, 2), Color3.fromRGB(255, 215, 0), Enum.Material.Neon)
		coin.Position = coinPos
		coin.Parent = parent
		table.insert(WorldBuilder.coins, coin)
	end

	-- Welcome sign at the spawn.
	local signPost = makePart("WelcomePost", Vector3.new(1, 6, 1), Color3.fromRGB(120, 80, 40), Enum.Material.Wood)
	signPost.Position = Vector3.new(-10, 3, 68)
	signPost.Parent = parent
	local signBoard = makePart("WelcomeBoard", Vector3.new(14, 4, 0.5), Color3.fromRGB(60, 140, 255), Enum.Material.SmoothPlastic)
	signBoard.Position = Vector3.new(-10, 6, 68)
	signBoard.Parent = parent
	addLabel(signBoard, "BRAINROT BAY", 22, Color3.fromRGB(255, 255, 255), 3)
end

--- Spin the gold coins forever.
function WorldBuilder.spinCoins()
	task.spawn(function()
		while true do
			task.wait(0.05)
			for _, coin in ipairs(WorldBuilder.coins) do
				coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(4), 0)
			end
		end
	end)
end

--- Build the whole world.
function WorldBuilder.build()
	local world = Instance.new("Folder")
	world.Name = "World"
	world.Parent = workspace
	WorldBuilder.addIsland(world)
	WorldBuilder.addConveyor(world)
	WorldBuilder.addPlots(world)
	WorldBuilder.addSlotPads(world)
	WorldBuilder.addPlotSigns(world)
	WorldBuilder.addDressing(world)
	WorldBuilder.spinCoins()
	return world
end

return WorldBuilder
