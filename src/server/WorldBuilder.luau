-- Brainrot Bay: runtime world dressing.
-- The island's static shell (sand, sea, conveyor, plots) lives in
-- default.project.json; this module adds the living bits at boot: slot pads
-- on every plot, owner name boards, spinning gold coins, palm trees, clouds
-- and the big welcome sign.

local Workspace = game:GetService("Workspace")

local WorldBuilder = {}

local function newPart(name: string, className: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?)
	local part = Instance.new(className or "Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.Parent = Workspace
	return part
end

-- One palm tree: a leaning trunk of stacked blocks and a crown of balls.
local function buildPalm(x: number, z: number)
	local trunkHeight = 12
	local trunk = newPart("PalmTrunk", "Part", Vector3.new(1.5, trunkHeight, 1.5), Vector3.new(x, trunkHeight / 2, z), Color3.fromRGB(140, 95, 50), Enum.Material.Wood)
	trunk.CanCollide = true
	for i, offset in ipairs({ Vector3.new(0, 0, 0), Vector3.new(2.5, 1, 0), Vector3.new(-2.5, 1, 0), Vector3.new(0, 1, 2.5), Vector3.new(0, 1, -2.5) }) do
		newPart("PalmLeaf", "Part", Vector3.new(5, 2.5, 5), Vector3.new(x, trunkHeight + 1, z) + offset, Color3.fromRGB(40, 160, 70), Enum.Material.SmoothPlastic).Shape = Enum.PartType.Ball
	end
end

-- A gold coin that spins above the plaza, purely decorative.
local function buildCoin(x: number, y: number, z: number)
	local coin = newPart("GoldCoin", "Part", Vector3.new(2, 2, 0.4), Vector3.new(x, y, z), Color3.fromRGB(255, 210, 40), Enum.Material.Neon)
	coin.Shape = Enum.PartType.Cylinder
	task.spawn(function()
		while coin.Parent do
			coin.CFrame *= CFrame.Angles(0, math.rad(3), 0)
			task.wait(0.05)
		end
	end)
end

function WorldBuilder.build(plots)
	-- Welcome sign at the spawn plaza.
	local board = newPart("WelcomeBoard", "Part", Vector3.new(24, 10, 1), Vector3.new(0, 6, 62), Color3.fromRGB(60, 60, 90), Enum.Material.Wood)
	board.CanCollide = true
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.6)
	title.BackgroundTransparency = 1
	title.Text = "BRAINROT BAY"
	title.TextColor3 = Color3.fromRGB(255, 220, 60)
	title.TextScaled = true
	title.Font = Enum.Font.FredokaOne
	title.Parent = gui
	local sub = Instance.new("TextLabel")
	sub.Position = UDim2.fromScale(0, 0.6)
	sub.Size = UDim2.fromScale(1, 0.4)
	sub.BackgroundTransparency = 1
	sub.Text = "Catch them! Base them! Get rich!"
	sub.TextColor3 = Color3.fromRGB(255, 255, 255)
	sub.TextScaled = true
	sub.Font = Enum.Font.SourceSansBold
	sub.Parent = gui

	-- Palm trees around the island's rim.
	for _, spot in ipairs({ { -100, -80 }, { 100, -80 }, { -100, 80 }, { 100, 80 }, { -60, 85 }, { 60, 85 }, { -105, 0 }, { 105, 0 } }) do
		buildPalm(spot[1], spot[2])
	end

	-- Coins floating over the plaza.
	for i = 1, 5 do
		buildCoin(-12 + (i - 1) * 6, 8, 55)
	end

	-- Clouds drifting high above the island.
	for _, spot in ipairs({ { -60, 70, -60 }, { 50, 80, -70 }, { 0, 75, 70 }, { -40, 85, 20 }, { 70, 70, 40 } }) do
		local cloud = newPart("Cloud", "Part", Vector3.new(16, 5, 9), Vector3.new(spot[1], spot[2], spot[3]), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
		cloud.Shape = Enum.PartType.Ball
		cloud.Transparency = 0.15
	end

	-- Slot pads and owner boards on every plot.
	-- Pads glow so a player can see at a glance which slots are free.
	for _, plot in ipairs(plots) do
		for slotIndex, slotPos in ipairs(plot.slots) do
			local pad = newPart("SlotPad" .. slotIndex, "Part", Vector3.new(4, 0.2, 4), Vector3.new(slotPos.X, 0.6, slotPos.Z), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
			pad.Transparency = 0.6
		end
		local sign = newPart("PlotSign", "Part", Vector3.new(10, 4, 0.5), plot.signPosition, Color3.fromRGB(40, 40, 60), Enum.Material.SmoothPlastic)
		local signGui = Instance.new("SurfaceGui")
		signGui.Face = Enum.NormalId.Front
		signGui.Parent = sign
		local label = Instance.new("TextLabel")
		label.Name = "OwnerLabel"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = "EMPTY PLOT"
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = signGui
		plot.signLabel = label
	end
end

return WorldBuilder
