-- Brainrot Bay — builds a brainrot's 3D model from plain parts.
-- One body block in the character's colour, a head, a head accessory and a
-- floating billboard with name, rarity, $/s and price. No meshes, no assets.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Catalog)

local BrainrotFactory = {}

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

--- The head accessory parts for a character's `accessory` word.
-- Returns a list of {part, offset} pairs; offsets are relative to the
-- accessory's anchor point above the head.
local function makeAccessory(accessory, size, bodyColor)
	local parts = {}
	if accessory == "none" then
		return parts
	end
	local anchorY = size + size * 0.75
	if accessory == "crown" then
		table.insert(parts, {
			part = makePart("Crown", Vector3.new(size * 0.7, size * 0.3, size * 0.7), Color3.fromRGB(255, 215, 0), Enum.Material.Neon),
			offset = Vector3.new(0, anchorY, 0),
		})
	elseif accessory == "cap" then
		table.insert(parts, {
			part = makePart("Cap", Vector3.new(size * 0.8, size * 0.25, size * 0.8), Color3.fromRGB(220, 50, 50), Enum.Material.SmoothPlastic),
			offset = Vector3.new(0, anchorY, 0),
		})
	elseif accessory == "glasses" then
		table.insert(parts, {
			part = makePart("Glasses", Vector3.new(size * 0.9, size * 0.18, size * 0.2), Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic),
			offset = Vector3.new(0, anchorY, size * 0.35),
		})
	elseif accessory == "bow" then
		table.insert(parts, {
			part = makePart("Bow", Vector3.new(size * 0.6, size * 0.2, size * 0.3), Color3.fromRGB(255, 110, 200), Enum.Material.SmoothPlastic),
			offset = Vector3.new(0, anchorY, size * 0.4),
		})
	elseif accessory == "antenna" then
		table.insert(parts, {
			part = makePart("Antenna", Vector3.new(size * 0.15, size * 0.7, size * 0.15), Color3.fromRGB(200, 200, 200), Enum.Material.Metal),
			offset = Vector3.new(0, anchorY + size * 0.2, 0),
		})
		table.insert(parts, {
			part = makePart("AntennaTip", Vector3.new(size * 0.3, size * 0.3, size * 0.3), Color3.fromRGB(255, 60, 60), Enum.Material.Neon),
			offset = Vector3.new(0, anchorY + size * 0.55, 0),
		})
	else -- "hat" and anything else: a wide brim hat
		table.insert(parts, {
			part = makePart("Hat", Vector3.new(size * 1.1, size * 0.2, size * 1.1), Color3.fromRGB(60, 60, 80), Enum.Material.SmoothPlastic),
			offset = Vector3.new(0, anchorY, 0),
		})
	end
	return parts
end

--- Two eyes + a mouth on the front (+Z) face of the head, so every
-- brainrot has a face. Returns a list of {part, offset} pairs; offsets
-- are relative to the ground `position`, like makeAccessory.
local function makeFace(size)
	local parts = {}
	local faceColor = Color3.fromRGB(20, 20, 20)
	local frontZ = size * 0.35 + size * 0.03
	table.insert(parts, {
		part = makePart("EyeLeft", Vector3.new(size * 0.12, size * 0.16, size * 0.05), faceColor),
		offset = Vector3.new(-size * 0.16, size * 1.43, frontZ),
	})
	table.insert(parts, {
		part = makePart("EyeRight", Vector3.new(size * 0.12, size * 0.16, size * 0.05), faceColor),
		offset = Vector3.new(size * 0.16, size * 1.43, frontZ),
	})
	table.insert(parts, {
		part = makePart("Mouth", Vector3.new(size * 0.28, size * 0.08, size * 0.05), faceColor),
		offset = Vector3.new(0, size * 1.20, frontZ),
	})
	return parts
end

--- Build a brainrot model for a character + mutation, standing at `position`
-- (the ground position under its feet). Returns the model.
function BrainrotFactory.create(charDef, mutationName, position, stagger)
	local size = charDef.size
	local bodyColor = charDef.color
	if mutationName ~= "" then
		local mutationDef = Catalog.MUTATIONS[mutationName]
		bodyColor = mutationDef.color
	end

	local model = Instance.new("Model")
	model.Name = charDef.name

	local body = makePart("Body", Vector3.new(size, size, size), bodyColor)
	body.Position = position + Vector3.new(0, size / 2, 0)
	body.Parent = model
	model.PrimaryPart = body

	local head = makePart("Head", Vector3.new(size * 0.7, size * 0.7, size * 0.7), bodyColor)
	head.Position = position + Vector3.new(0, size + size * 0.35, 0)
	head.Parent = model

	local accessoryParts = makeAccessory(charDef.accessory, size, bodyColor)
	for _, entry in ipairs(accessoryParts) do
		entry.part.Position = position + entry.offset
		entry.part.Parent = model
	end

	local faceParts = makeFace(size)
	for _, entry in ipairs(faceParts) do
		entry.part.Position = position + entry.offset
		entry.part.Parent = model
	end

	local rarityDef = Catalog.RARITIES[charDef.rarity]
	local price = Catalog.getPrice(charDef)
	local mult = Catalog.mutationMultiplier(mutationName)
	local displayName = charDef.name
	if mutationName ~= "" then
		displayName = mutationName .. " " .. charDef.name
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(Config.BILLBOARD_WIDTH, Config.BILLBOARD_HEIGHT)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, size + 1.2 + (stagger or 0) * Config.BILLBOARD_STAGGER, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = body
	billboard.Parent = body

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, 0, 0.34, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = displayName
	nameLabel.TextSize = Config.BILLBOARD_NAME_SIZE
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Parent = billboard

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Size = UDim2.new(1, 0, 0.28, 0)
	rarityLabel.Position = UDim2.new(0, 0, 0.34, 0)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = charDef.rarity
	rarityLabel.TextSize = Config.BILLBOARD_RARITY_SIZE
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.TextColor3 = rarityDef.color
	rarityLabel.TextStrokeTransparency = 0.4
	rarityLabel.Parent = billboard

	local rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "Rate"
	rateLabel.Size = UDim2.new(1, 0, 0.38, 0)
	rateLabel.Position = UDim2.new(0, 0, 0.62, 0)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = string.format("$%d/s  |  $%d", charDef.rate * mult, price)
	rateLabel.TextSize = Config.BILLBOARD_RATE_SIZE
	rateLabel.Font = Enum.Font.GothamBold
	rateLabel.TextColor3 = Color3.fromRGB(255, 255, 120)
	rateLabel.TextStrokeTransparency = 0.4
	rateLabel.Parent = billboard

	model:SetAttribute("Size", size)
	return model
end

return BrainrotFactory
