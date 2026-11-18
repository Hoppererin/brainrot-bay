-- Brainrot Bay — runtime dressing.
-- The static island comes from the project file; this module dresses it
-- while the game runs: palm trees, spinning gold coins, drifting clouds,
-- the welcome sign, a coloured sign per plot, and the slot pads a
-- brainrot stands on. All of it is built from plain parts, so the place
-- needs no meshes or assets.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Plots = require(script.Parent.Plots)

local WorldBuilder = {}

local function makePart(name: string, size: Vector3, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function addTextBillboard(parent: Instance, text: string, color: Color3, width: number, height: number, textSize: number)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, width, 0, height)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.2
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

-- A palm: a leaning trunk and a crown of green balls.
local function addPalm(position: Vector3)
	local trunk = makePart("PalmTrunk", Vector3.new(1.2, 9, 1.2), Color3.fromRGB(140, 100, 60), Enum.Material.Wood)
	trunk.CFrame = CFrame.new(position.X, 4.5, position.Z) * CFrame.Angles(0, 0, math.rad(8))
	trunk.Parent = workspace
	for i = 0, 4 do
		local angle = (i / 5) * math.pi * 2
		local leaf = makePart("PalmLeaf", Vector3.new(3.5, 1, 3.5), Color3.fromRGB(40, 160, 70), Enum.Material.Grass)
		leaf.Shape = Enum.PartType.Ball
		leaf.CFrame = CFrame.new(position.X + math.cos(angle) * 2.5, 9.5, position.Z + math.sin(angle) * 2.5)
		leaf.Parent = workspace
	end
	local crown = makePart("PalmCrown", Vector3.new(2.5, 2, 2.5), Color3.fromRGB(60, 190, 80), Enum.Material.Grass)
	crown.Shape = Enum.PartType.Ball
	crown.CFrame = CFrame.new(position.X, 10, position.Z)
	crown.Parent = workspace
end

-- A gold coin that spins above the sand, marking the island's paths.
local function addCoin(position: Vector3)
	local coin = makePart("GoldCoin", Vector3.new(0.4, 2.2, 2.2), Color3.fromRGB(255, 215, 0), Enum.Material.Neon)
	coin.Shape = Enum.PartType.Cylinder
	coin.CFrame = CFrame.new(position.X, 2.5, position.Z)
	coin.Parent = workspace
	task.spawn(function()
		local angle = 0
		while coin.Parent do
			angle += 0.05
			coin.CFrame = CFrame.new(position.X, 2.5 + math.sin(angle * 2) * 0.3, position.Z) * CFrame.Angles(angle, 0, 0)
			task.wait(0.05)
		end
	end)
end

-- A cloud: three white balls drifting slowly across the sky.
local function addCloud(position: Vector3)
	local group = Instance.new("Model")
	group.Name = "Cloud"
	group.Parent = workspace
	for i, offset in ipairs({ Vector3.new(-3, 0, 0), Vector3.new(0, 1, 0), Vector3.new(3, 0, 0) }) do
		local puff = makePart("CloudPuff", Vector3.new(7, 3, 5), Color3.fromRGB(255, 255, 255))
		puff.Shape = Enum.PartType.Ball
		puff.Transparency = 0.15
		puff.CFrame = CFrame.new(position + offset)
		puff.Parent = group
	end
	task.spawn(function()
		local x = position.X
		while group.Parent do
			x += 0.05
			if x > 130 then
				x = -130
			end
			group:PivotTo(CFrame.new(x, position.Y, position.Z))
			task.wait(0.1)
		end
	end)
end

-- The welcome sign at the spawn plaza: what the first screenshot reads.
local function addWelcomeSign()
	local post = makePart("WelcomePost", Vector3.new(1, 6, 1), Color3.fromRGB(120, 80, 40), Enum.Material.Wood)
	post.CFrame = CFrame.new(-12, 3, 52)
	post.Parent = workspace
	local board = makePart("WelcomeBoard", Vector3.new(16, 5, 0.8), Color3.fromRGB(255, 240, 200), Enum.Material.Wood)
	board.CFrame = CFrame.new(-12, 7, 52)
	board.Parent = workspace
	addTextBillboard(board, "Welcome to Brainrot Bay!", Color3.fromRGB(60, 40, 10), 220, 40, 22)
end

-- One coloured sign per plot, so a player can find their own base.
local function addPlotSigns()
	for _, plot in ipairs(Config.PLOTS) do
		local sign = makePart("PlotSign", Vector3.new(1, 5, 1), Color3.fromRGB(90, 60, 30), Enum.Material.Wood)
		sign.CFrame = CFrame.new(plot.center.X - 11, 2.5, plot.center.Z - 9)
		sign.Parent = workspace
		local board = makePart("PlotBoard", Vector3.new(6, 2.5, 0.6), plot.color)
		board.CFrame = CFrame.new(plot.center.X - 11, 5.5, plot.center.Z - 9)
		board.Parent = workspace
		addTextBillboard(board, "Plot " .. tostring(plot.id), Color3.fromRGB(255, 255, 255), 90, 30, 16)
	end
end

-- The six slot pads on every plot: flat tinted tiles a brainrot lands on.
local function addSlotPads()
	for _, plotDef in ipairs(Config.PLOTS) do
		local plot = Plots.get(plotDef.id)
		if plot ~= nil then
			for slotIndex = 1, #Config.SLOT_OFFSETS do
				local at = Plots.slotPosition(plot, slotIndex)
				local pad = makePart("SlotPad", Vector3.new(5, 0.3, 5), plot.color, Enum.Material.Neon)
				pad.Transparency = 0.6
				pad.CFrame = CFrame.new(at.X, 1.05, at.Z)
				pad.Parent = workspace
			end
		end
	end
end

function WorldBuilder.build()
	addWelcomeSign()
	addPlotSigns()
	addSlotPads()
	for _, spot in ipairs({
		Vector3.new(-100, 0, 50),
		Vector3.new(100, 0, -50),
		Vector3.new(-100, 0, -90),
		Vector3.new(95, 0, 70),
		Vector3.new(60, 0, -95),
		Vector3.new(-60, 0, 95),
	}) do
		addPalm(spot)
	end
	for _, spot in ipairs({
		Vector3.new(-20, 0, 40),
		Vector3.new(20, 0, 40),
		Vector3.new(-40, 0, -10),
		Vector3.new(40, 0, -10),
		Vector3.new(0, 0, -45),
	}) do
		addCoin(spot)
	end
	for _, spot in ipairs({
		Vector3.new(-80, 45, -40),
		Vector3.new(0, 50, 30),
		Vector3.new(80, 42, -60),
	}) do
		addCloud(spot)
	end
end

return WorldBuilder
