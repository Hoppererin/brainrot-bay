-- Brainrot Bay — the brainrot factory.
-- Builds a brainrot's model from plain parts only: a blocky body, a belly,
-- two eyes, feet, one head accessory, and a floating label with its name,
-- rarity and $/s. A mutation tints the body its own colour and names
-- itself on the label's rarity line.
--
-- The label is kept narrow on purpose (110 x 44, small text): on the belt
-- the brainrots walk in a row, and a wide label from one swallows its
-- neighbour's, so from the conveyor the whole row reads as one smeared
-- band. Narrow labels stay readable from up close and stop colliding.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Catalog"))

local BrainrotFactory = {}

-- Label size (fix: ~30% narrower than a full-width label, text one step down).
local LABEL_WIDTH = 110
local LABEL_HEIGHT = 44
local NAME_TEXT_SIZE = 12
local RARITY_TEXT_SIZE = 10
local RATE_TEXT_SIZE = 11

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

-- One head accessory per name: a single distinctive part (or a pair for
-- wings and glasses) that sits on the body and reads at a glance.
local function addAccessory(model: Model, accessory: string, scale: number, root: Part)
	local s = scale
	local top = root.Size.Y / 2
	if accessory == "toaster" then
		local slot = makePart("Toaster", Vector3.new(1.4 * s, 0.7 * s, 1.0 * s), Color3.fromRGB(180, 180, 190), Enum.Material.Metal)
		slot.CFrame = root.CFrame * CFrame.new(0, top + 0.35 * s, 0)
		slot.Parent = model
	elseif accessory == "crown" then
		local band = makePart("Crown", Vector3.new(1.6 * s, 0.4 * s, 1.6 * s), Color3.fromRGB(255, 215, 0), Enum.Material.Neon)
		band.CFrame = root.CFrame * CFrame.new(0, top + 0.2 * s, 0)
		band.Parent = model
		for i = -1, 1 do
			local spike = makePart("Spike", Vector3.new(0.3 * s, 0.6 * s, 0.3 * s), Color3.fromRGB(255, 215, 0), Enum.Material.Neon)
			spike.CFrame = root.CFrame * CFrame.new(i * 0.55 * s, top + 0.6 * s, 0)
			spike.Parent = model
		end
	elseif accessory == "hat" then
		local brim = makePart("HatBrim", Vector3.new(2.2 * s, 0.25 * s, 2.2 * s), Color3.fromRGB(90, 60, 30))
		brim.CFrame = root.CFrame * CFrame.new(0, top + 0.1 * s, 0)
		brim.Parent = model
		local dome = makePart("HatTop", Vector3.new(1.2 * s, 0.9 * s, 1.2 * s), Color3.fromRGB(90, 60, 30))
		dome.CFrame = root.CFrame * CFrame.new(0, top + 0.6 * s, 0)
		dome.Parent = model
	elseif accessory == "beret" then
		local beret = makePart("Beret", Vector3.new(1.8 * s, 0.5 * s, 1.8 * s), Color3.fromRGB(200, 60, 90))
		beret.CFrame = root.CFrame * CFrame.new(0.2 * s, top + 0.25 * s, 0)
		beret.Parent = model
	elseif accessory == "wings" then
		for _, side in ipairs({ -1, 1 }) do
			local wing = makePart("Wing", Vector3.new(0.3 * s, 1.2 * s, 1.6 * s), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
			wing.CFrame = root.CFrame * CFrame.new(side * (root.Size.X / 2 + 0.15 * s), 0.3 * s, -0.3 * s)
			wing.Parent = model
		end
	elseif accessory == "glasses" then
		for _, side in ipairs({ -1, 1 }) do
			local lens = makePart("Lens", Vector3.new(0.6 * s, 0.6 * s, 0.2 * s), Color3.fromRGB(20, 20, 30), Enum.Material.Glass)
			lens.CFrame = root.CFrame * CFrame.new(side * 0.5 * s, 0.35 * s, root.Size.Z / 2 + 0.1 * s)
			lens.Parent = model
		end
	elseif accessory == "cape" then
		local cape = makePart("Cape", Vector3.new(1.8 * s, 1.6 * s, 0.25 * s), Color3.fromRGB(160, 30, 30))
		cape.CFrame = root.CFrame * CFrame.new(0, 0.1 * s, -(root.Size.Z / 2 + 0.15 * s))
		cape.Parent = model
	elseif accessory == "flower" then
		local bloom = makePart("Flower", Vector3.new(0.8 * s, 0.4 * s, 0.8 * s), Color3.fromRGB(255, 120, 200), Enum.Material.Neon)
		bloom.CFrame = root.CFrame * CFrame.new(root.Size.X / 2 - 0.2 * s, top + 0.2 * s, 0.2 * s)
		bloom.Parent = model
	elseif accessory == "helmet" then
		local helm = makePart("Helmet", Vector3.new(2.0 * s, 0.9 * s, 2.0 * s), Color3.fromRGB(60, 120, 60), Enum.Material.Metal)
		helm.CFrame = root.CFrame * CFrame.new(0, top + 0.2 * s, 0)
		helm.Parent = model
	elseif accessory == "disco" then
		local ball = makePart("DiscoBall", Vector3.new(0.9 * s, 0.9 * s, 0.9 * s), Color3.fromRGB(220, 220, 240), Enum.Material.Metal)
		ball.Shape = Enum.PartType.Ball
		ball.CFrame = root.CFrame * CFrame.new(0, top + 0.6 * s, 0)
		ball.Parent = model
	elseif accessory == "bubble" then
		local bubble = makePart("Bubble", Vector3.new(1.1 * s, 1.1 * s, 1.1 * s), Color3.fromRGB(180, 230, 255), Enum.Material.Glass)
		bubble.Shape = Enum.PartType.Ball
		bubble.CFrame = root.CFrame * CFrame.new(0, top + 0.7 * s, 0)
		bubble.Parent = model
	elseif accessory == "antenna" then
		local rod = makePart("Antenna", Vector3.new(0.2 * s, 1.0 * s, 0.2 * s), Color3.fromRGB(60, 60, 60), Enum.Material.Metal)
		rod.CFrame = root.CFrame * CFrame.new(0, top + 0.5 * s, 0)
		rod.Parent = model
		local tip = makePart("AntennaTip", Vector3.new(0.5 * s, 0.5 * s, 0.5 * s), Color3.fromRGB(255, 80, 80), Enum.Material.Neon)
		tip.Shape = Enum.PartType.Ball
		tip.CFrame = root.CFrame * CFrame.new(0, top + 1.15 * s, 0)
		tip.Parent = model
	elseif accessory == "lightning" then
		local bolt = makePart("Bolt", Vector3.new(0.5 * s, 1.2 * s, 0.3 * s), Color3.fromRGB(255, 230, 0), Enum.Material.Neon)
		bolt.CFrame = root.CFrame * CFrame.new(0, top + 0.6 * s, 0)
		bolt.Parent = model
	elseif accessory == "clock" then
		local face = makePart("Clock", Vector3.new(1.0 * s, 1.0 * s, 0.3 * s), Color3.fromRGB(240, 240, 240))
		face.CFrame = root.CFrame * CFrame.new(0, top + 0.5 * s, 0)
		face.Parent = model
	elseif accessory == "chefhat" then
		local chef = makePart("ChefHat", Vector3.new(1.5 * s, 0.9 * s, 1.5 * s), Color3.fromRGB(255, 255, 255))
		chef.CFrame = root.CFrame * CFrame.new(0, top + 0.45 * s, 0)
		chef.Parent = model
	elseif accessory == "halo" then
		local halo = makePart("Halo", Vector3.new(1.6 * s, 0.3 * s, 1.6 * s), Color3.fromRGB(255, 240, 150), Enum.Material.Neon)
		halo.CFrame = root.CFrame * CFrame.new(0, top + 0.7 * s, 0)
		halo.Parent = model
	elseif accessory == "tophat" then
		local brim = makePart("TopBrim", Vector3.new(2.0 * s, 0.25 * s, 2.0 * s), Color3.fromRGB(30, 30, 40))
		brim.CFrame = root.CFrame * CFrame.new(0, top + 0.1 * s, 0)
		brim.Parent = model
		local topPiece = makePart("TopHat", Vector3.new(1.1 * s, 1.2 * s, 1.1 * s), Color3.fromRGB(30, 30, 40))
		topPiece.CFrame = root.CFrame * CFrame.new(0, top + 0.7 * s, 0)
		topPiece.Parent = model
	end
end

-- The floating label: name on top, rarity in the middle, $/s and price at
-- the bottom. Narrow, small text, always on top so it reads from the belt.
local function addLabel(model: Model, character, mutation: any, root: Part)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.new(0, LABEL_WIDTH, 0, LABEL_HEIGHT)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 3.4 * character.scale, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Parent = root

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = character.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.TextScaled = false
	nameLabel.TextSize = NAME_TEXT_SIZE
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = gui

	local rarityInfo = Catalog.RARITIES[character.rarity]
	local rarityText = character.rarity
	if mutation ~= nil then
		rarityText = character.rarity .. " • " .. mutation.name
	end
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, 0, 0, 13)
	rarityLabel.Position = UDim2.new(0, 0, 0, 15)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = rarityText
	rarityLabel.TextColor3 = rarityInfo.color
	rarityLabel.TextStrokeTransparency = 0.2
	rarityLabel.TextSize = RARITY_TEXT_SIZE
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Parent = gui

	local rate = Catalog.getEffectiveRate(character, mutation)
	local price = Catalog.getPrice(character, mutation)
	local rateLabel = Instance.new("TextLabel")
	rateLabel.Size = UDim2.new(1, 0, 0, 15)
	rateLabel.Position = UDim2.new(0, 0, 0, 28)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = string.format("$%d/s • $%d", rate, price)
	rateLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	rateLabel.TextStrokeTransparency = 0.2
	rateLabel.TextSize = RATE_TEXT_SIZE
	rateLabel.Font = Enum.Font.GothamBold
	rateLabel.Parent = gui
end

-- Builds the whole model at the origin; the caller moves it where it walks.
function BrainrotFactory.create(character, mutation: any): Model
	local s = character.scale
	local bodyColor = character.body
	if mutation ~= nil then
		bodyColor = mutation.color
	end

	local model = Instance.new("Model")
	model.Name = character.name

	local root = makePart("Root", Vector3.new(2.4 * s, 2.4 * s, 2.4 * s), bodyColor)
	root.CFrame = CFrame.new(0, 1.2 * s, 0)
	root.Parent = model
	model.PrimaryPart = root

	local belly = makePart("Belly", Vector3.new(1.6 * s, 1.4 * s, 0.4 * s), character.belly)
	belly.CFrame = root.CFrame * CFrame.new(0, -0.3 * s, 1.15 * s)
	belly.Parent = model

	for _, side in ipairs({ -1, 1 }) do
		local eye = makePart("Eye", Vector3.new(0.35 * s, 0.5 * s, 0.2 * s), Color3.fromRGB(20, 20, 20))
		eye.CFrame = root.CFrame * CFrame.new(side * 0.5 * s, 0.4 * s, 1.25 * s)
		eye.Parent = model
		local foot = makePart("Foot", Vector3.new(0.7 * s, 0.4 * s, 1.0 * s), Color3.fromRGB(40, 40, 40))
		foot.CFrame = root.CFrame * CFrame.new(side * 0.55 * s, -1.35 * s, 0.2 * s)
		foot.Parent = model
	end

	addAccessory(model, character.accessory, s, root)
	addLabel(model, character, mutation, root)

	return model
end

return BrainrotFactory
