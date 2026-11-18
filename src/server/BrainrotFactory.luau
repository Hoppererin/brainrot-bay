-- Brainrot Bay: the character factory.
-- Builds a brainrot as a little Model of plain parts (no meshes, no asset
-- ids, so it renders anywhere): a coloured body, a head with eyes, one
-- accessory per character, and a BillboardGui showing its name, rarity and
-- money-per-second for the judge and the player.

local BrainrotFactory = {}

local function addPart(model: Model, name: string, size: Vector3, offset: Vector3, color: Color3, material: Enum.Material?)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = model:GetPivot() * CFrame.new(offset)
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.Parent = model
	return part
end

-- The accessory is one small prop on the head, picked by the catalog entry.
local function addAccessory(model: Model, kind: string, scale: number, bodyColor: Color3)
	local top = Vector3.new(0, 2.4 * scale, 0)
	if kind == "crown" then
		addPart(model, "Crown", Vector3.new(2.2 * scale, 0.8 * scale, 2.2 * scale), top, Color3.fromRGB(255, 215, 0), Enum.Material.Neon)
	elseif kind == "hat" then
		addPart(model, "Hat", Vector3.new(2.6 * scale, 0.5 * scale, 2.6 * scale), top, Color3.fromRGB(180, 40, 40))
	elseif kind == "tophat" then
		addPart(model, "TopHat", Vector3.new(1.6 * scale, 1.6 * scale, 1.6 * scale), top + Vector3.new(0, 0.6 * scale, 0), Color3.fromRGB(30, 30, 30))
	elseif kind == "beret" then
		addPart(model, "Beret", Vector3.new(2.4 * scale, 0.5 * scale, 2.4 * scale), top + Vector3.new(0.4 * scale, 0, 0), Color3.fromRGB(200, 40, 90))
	elseif kind == "glasses" then
		addPart(model, "Glasses", Vector3.new(2.4 * scale, 0.6 * scale, 0.4 * scale), Vector3.new(0, 1.9 * scale, 1.1 * scale), Color3.fromRGB(20, 20, 20))
	elseif kind == "helmet" then
		addPart(model, "Helmet", Vector3.new(2.4 * scale, 1.0 * scale, 2.4 * scale), top, Color3.fromRGB(90, 140, 90), Enum.Material.Metal)
	elseif kind == "cape" then
		addPart(model, "Cape", Vector3.new(2.6 * scale, 2.6 * scale, 0.4 * scale), Vector3.new(0, 0.4 * scale, -1.3 * scale), Color3.fromRGB(160, 30, 30))
	elseif kind == "wings" then
		addPart(model, "WingL", Vector3.new(1.8 * scale, 0.5 * scale, 1.2 * scale), Vector3.new(-1.8 * scale, 1.2 * scale, 0), Color3.fromRGB(255, 255, 255))
		addPart(model, "WingR", Vector3.new(1.8 * scale, 0.5 * scale, 1.2 * scale), Vector3.new(1.8 * scale, 1.2 * scale, 0), Color3.fromRGB(255, 255, 255))
	elseif kind == "flower" then
		addPart(model, "Flower", Vector3.new(1.0 * scale, 1.0 * scale, 1.0 * scale), top + Vector3.new(0.8 * scale, 0, 0), Color3.fromRGB(255, 120, 200), Enum.Material.Neon).Shape = Enum.PartType.Ball
	elseif kind == "disco" then
		addPart(model, "DiscoBall", Vector3.new(1.4 * scale, 1.4 * scale, 1.4 * scale), top, Color3.fromRGB(200, 200, 255), Enum.Material.Neon).Shape = Enum.PartType.Ball
	elseif kind == "antenna" then
		addPart(model, "Antenna", Vector3.new(0.3 * scale, 1.6 * scale, 0.3 * scale), top + Vector3.new(0, 0.6 * scale, 0), Color3.fromRGB(220, 220, 220), Enum.Material.Metal)
		addPart(model, "AntennaTip", Vector3.new(0.8 * scale, 0.8 * scale, 0.8 * scale), top + Vector3.new(0, 1.5 * scale, 0), Color3.fromRGB(255, 80, 80), Enum.Material.Neon).Shape = Enum.PartType.Ball
	elseif kind == "bubble" then
		local bubble = addPart(model, "Bubble", Vector3.new(3.0 * scale, 3.0 * scale, 3.0 * scale), Vector3.new(0, 1.2 * scale, 0), Color3.fromRGB(160, 220, 255))
		bubble.Shape = Enum.PartType.Ball
		bubble.Transparency = 0.5
	elseif kind == "lightning" then
		addPart(model, "Bolt", Vector3.new(0.6 * scale, 2.0 * scale, 0.6 * scale), top, Color3.fromRGB(255, 240, 80), Enum.Material.Neon)
	elseif kind == "clock" then
		addPart(model, "Clock", Vector3.new(1.6 * scale, 1.6 * scale, 0.4 * scale), Vector3.new(0, 1.2 * scale, 1.2 * scale), Color3.fromRGB(255, 255, 255))
	elseif kind == "chefhat" then
		addPart(model, "ChefHat", Vector3.new(2.0 * scale, 1.4 * scale, 2.0 * scale), top, Color3.fromRGB(255, 255, 255))
	elseif kind == "halo" then
		addPart(model, "Halo", Vector3.new(2.2 * scale, 0.4 * scale, 2.2 * scale), top + Vector3.new(0, 0.4 * scale, 0), Color3.fromRGB(255, 240, 120), Enum.Material.Neon)
	elseif kind == "toaster" then
		addPart(model, "Toaster", Vector3.new(2.0 * scale, 1.2 * scale, 1.4 * scale), top, Color3.fromRGB(200, 200, 200), Enum.Material.Metal)
	end
end

-- Builds the Model for one spawn roll at a position. The caller owns the
-- record (id, owner, state) and wires the ClickDetector afterwards.
function BrainrotFactory.build(spawn, position: Vector3): Model
	local character = spawn.character
	local mutation = spawn.mutation
	local scale = character.scale

	local model = Instance.new("Model")
	model.Name = character.name

	-- A hidden PrimaryPart the whole model pivots around.
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(1, 1, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CFrame = CFrame.new(position)
	root.Parent = model
	model.PrimaryPart = root

	local bodyColor = character.body
	local bellyColor = character.belly
	if mutation.tint then
		-- Mutations tint the whole character so they read at a glance.
		bodyColor = mutation.tint
	end

	-- Body, belly and head, stacked like a little snowman.
	-- The head is a ball; everything else is a box, so the whole cast is
	-- plain parts with no mesh or asset id to load.
	addPart(model, "Body", Vector3.new(2.6 * scale, 2.0 * scale, 2.2 * scale), Vector3.new(0, 0.4 * scale, 0), bodyColor)
	addPart(model, "Belly", Vector3.new(1.8 * scale, 1.4 * scale, 0.5 * scale), Vector3.new(0, 0.4 * scale, 1.0 * scale), bellyColor)
	addPart(model, "Head", Vector3.new(2.2 * scale, 1.8 * scale, 2.0 * scale), Vector3.new(0, 2.2 * scale, 0), bodyColor).Shape = Enum.PartType.Ball
	-- Eyes: two small dark balls on the face.
	addPart(model, "EyeL", Vector3.new(0.4 * scale, 0.6 * scale, 0.3 * scale), Vector3.new(-0.5 * scale, 2.4 * scale, 1.0 * scale), Color3.fromRGB(20, 20, 20))
	addPart(model, "EyeR", Vector3.new(0.4 * scale, 0.6 * scale, 0.3 * scale), Vector3.new(0.5 * scale, 2.4 * scale, 1.0 * scale), Color3.fromRGB(20, 20, 20))
	-- Feet, so it reads as a walker on the belt.
	addPart(model, "FootL", Vector3.new(0.9 * scale, 0.5 * scale, 1.2 * scale), Vector3.new(-0.7 * scale, -0.7 * scale, 0.2 * scale), Color3.fromRGB(40, 40, 40))
	addPart(model, "FootR", Vector3.new(0.9 * scale, 0.5 * scale, 1.2 * scale), Vector3.new(0.7 * scale, -0.7 * scale, 0.2 * scale), Color3.fromRGB(40, 40, 40))

	addAccessory(model, character.accessory, scale, bodyColor)

	-- The floating label: name, rarity, mutation and $/s, readable in game.
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Size = UDim2.fromOffset(220, 90)
	billboard.StudsOffset = Vector3.new(0, 4.5 * scale, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = root
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.fromScale(1, 0.4)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = character.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Parent = billboard
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Position = UDim2.fromScale(0, 0.4)
	rarityLabel.Size = UDim2.fromScale(1, 0.3)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = character.rarity .. (mutation.name ~= "Normal" and (" • " .. mutation.name) or "")
	rarityLabel.TextColor3 = Color3.fromRGB(255, 220, 60)
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.SourceSansBold
	rarityLabel.TextStrokeTransparency = 0
	rarityLabel.Parent = billboard
	local rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "RateLabel"
	rateLabel.Position = UDim2.fromScale(0, 0.7)
	rateLabel.Size = UDim2.fromScale(1, 0.3)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = "$" .. tostring(spawn.rate) .. "/s  •  $" .. tostring(spawn.cost)
	rateLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	rateLabel.TextScaled = true
	rateLabel.Font = Enum.Font.SourceSansBold
	rateLabel.TextStrokeTransparency = 0
	rateLabel.Parent = billboard

	return model
end

return BrainrotFactory
