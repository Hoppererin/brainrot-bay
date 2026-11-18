-- BrainrotFactory.luau
-- Builds the 3D model of one brainrot from plain parts (build4, from scratch).
-- Body + head + one accessory piece, plus a floating billboard with the
-- name, the rarity and the $/s (with its price). No meshes, no assets.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Catalog)

local Factory = {}

local BILLBOARD_WIDTH = 110
local BILLBOARD_HEIGHT = 44
local NAME_TEXT_SIZE = 12
local RARITY_TEXT_SIZE = 10
local RATE_TEXT_SIZE = 11

local function makeLabel(parent, yOffset, height, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = "Label" .. tostring(yOffset)
	label.Size = UDim2.new(1, 0, 0, height)
	label.Position = UDim2.new(0, 0, 0, yOffset)
	label.BackgroundTransparency = 1
	label.Text = ""
	label.TextSize = textSize
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextScaled = false
	label.Parent = parent
	return label
end

local function makeAccessory(kind, head, bodyColor)
	local piece = Instance.new("Part")
	piece.Name = "Accessory"
	piece.Anchored = true
	piece.CanCollide = false
	piece.Material = Enum.Material.SmoothPlastic
	if kind == "Crown" or kind == "Tiara" then
		piece.Size = Vector3.new(1.6, 0.5, 1.6)
		piece.Color = Color3.fromRGB(255, 215, 0)
		piece.Position = head.Position + Vector3.new(0, 1.1, 0)
	elseif kind == "WizardHat" then
		piece.Size = Vector3.new(1.4, 1.4, 1.4)
		piece.Color = Color3.fromRGB(120, 60, 200)
		piece.Position = head.Position + Vector3.new(0, 1.3, 0)
	elseif kind == "Helmet" then
		piece.Size = Vector3.new(1.9, 0.9, 1.9)
		piece.Color = Color3.fromRGB(90, 90, 110)
		piece.Position = head.Position + Vector3.new(0, 0.9, 0)
	elseif kind == "Halo" then
		piece.Size = Vector3.new(1.8, 0.3, 1.8)
		piece.Color = Color3.fromRGB(255, 240, 150)
		piece.Material = Enum.Material.Neon
		piece.Position = head.Position + Vector3.new(0, 1.5, 0)
	elseif kind == "Sombrero" then
		piece.Size = Vector3.new(2.6, 0.3, 2.6)
		piece.Color = Color3.fromRGB(200, 160, 60)
		piece.Position = head.Position + Vector3.new(0, 0.9, 0)
	elseif kind == "Turban" then
		piece.Size = Vector3.new(1.8, 0.8, 1.8)
		piece.Color = Color3.fromRGB(240, 240, 240)
		piece.Position = head.Position + Vector3.new(0, 0.9, 0)
	elseif kind == "Wings" then
		piece.Size = Vector3.new(2.6, 0.2, 1.0)
		piece.Color = Color3.fromRGB(255, 255, 255)
		piece.Position = head.Position + Vector3.new(0, 0.2, 0)
	elseif kind == "Cape" then
		piece.Size = Vector3.new(1.8, 1.6, 0.2)
		piece.Color = Color3.fromRGB(200, 30, 30)
		piece.Position = head.Position + Vector3.new(0, -0.4, -0.9)
	elseif kind == "Glasses" then
		piece.Size = Vector3.new(1.7, 0.4, 0.4)
		piece.Color = Color3.fromRGB(30, 30, 30)
		piece.Position = head.Position + Vector3.new(0, 0.2, 0.9)
	elseif kind == "Monocle" then
		piece.Size = Vector3.new(0.6, 0.6, 0.2)
		piece.Color = Color3.fromRGB(255, 215, 0)
		piece.Material = Enum.Material.Neon
		piece.Position = head.Position + Vector3.new(0.5, 0.2, 0.9)
	elseif kind == "Bow" then
		piece.Size = Vector3.new(1.2, 0.5, 0.3)
		piece.Color = Color3.fromRGB(255, 80, 140)
		piece.Position = head.Position + Vector3.new(0, 1.0, 0)
	elseif kind == "Fan" then
		piece.Size = Vector3.new(0.3, 1.2, 1.4)
		piece.Color = Color3.fromRGB(180, 120, 200)
		piece.Position = head.Position + Vector3.new(1.0, 0, 0)
	elseif kind == "Beret" then
		piece.Size = Vector3.new(1.6, 0.4, 1.6)
		piece.Color = Color3.fromRGB(60, 60, 120)
		piece.Position = head.Position + Vector3.new(0, 1.0, 0)
	elseif kind == "Bowl" then
		piece.Size = Vector3.new(1.8, 0.5, 1.8)
		piece.Color = Color3.fromRGB(255, 255, 255)
		piece.Position = head.Position + Vector3.new(0, 1.0, 0)
	elseif kind == "Sprinkles" then
		piece.Size = Vector3.new(1.7, 0.3, 1.7)
		piece.Color = Color3.fromRGB(255, 120, 200)
		piece.Position = head.Position + Vector3.new(0, 1.0, 0)
	else -- "Hat" and anything else: a plain cap
		piece.Size = Vector3.new(1.7, 0.5, 1.7)
		piece.Color = bodyColor
		piece.Position = head.Position + Vector3.new(0, 1.0, 0)
	end
	return piece
end

-- Build a model for a record. `onClick` is called as onClick(player, record)
-- when a player clicks the brainrot. Returns the model.
function Factory.create(record, onClick)
	local character = nil
	for _, entry in ipairs(Catalog.CHARACTERS) do
		if entry.name == record.charName then
			character = entry
			break
		end
	end
	if character == nil then
		return nil
	end

	local scale = character.size
	local model = Instance.new("Model")
	model.Name = record.charName
	model:SetAttribute("Scale", scale)

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2 * scale, 2 * scale, 2 * scale)
	body.Color = character.body
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Position = Vector3.new(0, 1 * scale, 0)
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.6 * scale, 1.6 * scale, 1.6 * scale)
	head.Color = character.accent
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.Position = Vector3.new(0, 2.6 * scale, 0)
	head.Parent = model

	local accessory = makeAccessory(character.accessory, head, character.body)
	accessory.Parent = model

	if record.mutation ~= nil then
		local tintColor = Color3.fromRGB(255, 215, 0)
		for _, mutation in ipairs(Catalog.MUTATIONS) do
			if mutation.name == record.mutation then
				tintColor = mutation.color
			end
		end
		local tint = Instance.new("Part")
		tint.Name = "MutationTint"
		tint.Size = Vector3.new(2.2 * scale, 0.4 * scale, 2.2 * scale)
		tint.Color = tintColor
		tint.Material = Enum.Material.Neon
		tint.Anchored = true
		tint.CanCollide = false
		tint.Position = Vector3.new(0, 0.3 * scale, 0)
		tint.Parent = model
	end

	model.PrimaryPart = body

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(BILLBOARD_WIDTH, BILLBOARD_HEIGHT)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 4.2 * scale, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = model

	local nameLabel = makeLabel(billboard, 0, 12, NAME_TEXT_SIZE, Color3.fromRGB(255, 255, 255))
	nameLabel.Name = "NameLabel"
	nameLabel.Text = record.charName
	local rarityLabel = makeLabel(billboard, 12, 10, RARITY_TEXT_SIZE, Catalog.rarityColor(record.rarity))
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Text = record.rarity
	if record.mutation ~= nil then
		rarityLabel.Text = record.mutation .. " " .. record.rarity
	end
	local rateLabel = makeLabel(billboard, 22, 11, RATE_TEXT_SIZE, Color3.fromRGB(120, 255, 120))
	rateLabel.Name = "RateLabel"
	rateLabel.Text = "$" .. tostring(record.rate * record.mult) .. "/s"
	local priceLabel = makeLabel(billboard, 33, 11, RATE_TEXT_SIZE, Color3.fromRGB(255, 220, 100))
	priceLabel.Name = "PriceLabel"
	priceLabel.Text = "$" .. tostring(Catalog.getPrice(record))

	local click = Instance.new("ClickDetector")
	click.Name = "BuyClick"
	click.MaxActivationDistance = 32
	click.MouseClick:Connect(function(player)
		if onClick ~= nil then
			onClick(player, record)
		end
	end)
	click.Parent = model

	return model
end

-- Refresh the billboard of a model after the record changed.
function Factory.refreshLabel(model, record)
	local billboard = model:FindFirstChild("Label")
	if billboard == nil then
		return
	end
	for _, child in ipairs(billboard:GetChildren()) do
		if child:IsA("TextLabel") and child.Name == "RateLabel" then
			child.Text = "$" .. tostring(record.rate * record.mult) .. "/s"
		elseif child:IsA("TextLabel") and child.Name == "PriceLabel" then
			child.Text = "$" .. tostring(Catalog.getPrice(record))
		end
	end
end

return Factory
