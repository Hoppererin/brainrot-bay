-- Brainrot Bay — the brainrot catalogue.
-- 40 original characters in 7 rarities. Every name here is invented for
-- this build. Price = rate * Config.PRICE_MULTIPLIER, so the cheapest
-- brainrot costs $125 and the most expensive $125,000.
-- Spawn weights add up to exactly 100.0.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local Catalog = {}

Catalog.RARITIES = {
	Common = { color = Color3.fromRGB(170, 170, 170), weight = 30 },
	Uncommon = { color = Color3.fromRGB(80, 200, 90), weight = 25 },
	Rare = { color = Color3.fromRGB(60, 140, 255), weight = 18 },
	Epic = { color = Color3.fromRGB(150, 90, 255), weight = 12 },
	Legendary = { color = Color3.fromRGB(255, 165, 0), weight = 8 },
	Mythic = { color = Color3.fromRGB(255, 60, 120), weight = 5 },
	Secret = { color = Color3.fromRGB(255, 220, 60), weight = 2 },
}

Catalog.MUTATIONS = {
	Golden = { multiplier = 2, chance = 0.12, color = Color3.fromRGB(255, 215, 0) },
	Diamond = { multiplier = 4, chance = 0.04, color = Color3.fromRGB(120, 220, 255) },
	Rainbow = { multiplier = 8, chance = 0.01, color = Color3.fromRGB(255, 110, 200) },
}

-- name, rarity, $/s, body colour, size, head accessory.
Catalog.CHARACTERS = {
	-- Common (10) — the everyday weirdos of the bay.
	{ name = "Sir Wobbly Waffle", rarity = "Common", rate = 5, color = Color3.fromRGB(210, 160, 90), size = 1.6, accessory = "hat" },
	{ name = "Captain Crumbly Cracker", rarity = "Common", rate = 7, color = Color3.fromRGB(220, 190, 130), size = 1.6, accessory = "cap" },
	{ name = "Madame Mop Bucket", rarity = "Common", rate = 9, color = Color3.fromRGB(120, 120, 130), size = 1.7, accessory = "none" },
	{ name = "Professor Pickle Jar", rarity = "Common", rate = 11, color = Color3.fromRGB(90, 180, 80), size = 1.7, accessory = "glasses" },
	{ name = "Duke of Damp Socks", rarity = "Common", rate = 13, color = Color3.fromRGB(150, 150, 200), size = 1.8, accessory = "none" },
	{ name = "Lady Lumpy Pillow", rarity = "Common", rate = 15, color = Color3.fromRGB(240, 240, 245), size = 1.8, accessory = "bow" },
	{ name = "Baron Blurry Banana", rarity = "Common", rate = 17, color = Color3.fromRGB(250, 225, 60), size = 1.8, accessory = "none" },
	{ name = "Count Custard Puddle", rarity = "Common", rate = 19, color = Color3.fromRGB(250, 230, 150), size = 1.9, accessory = "hat" },
	{ name = "Miss Wiggly Noodle", rarity = "Common", rate = 22, color = Color3.fromRGB(250, 210, 120), size = 1.9, accessory = "bow" },
	{ name = "King Ketchup Splatter", rarity = "Common", rate = 25, color = Color3.fromRGB(220, 50, 40), size = 2.0, accessory = "crown" },
	-- Uncommon (8) — slightly less ordinary.
	{ name = "Turbo Toilet Plunger", rarity = "Uncommon", rate = 30, color = Color3.fromRGB(200, 60, 50), size = 2.0, accessory = "none" },
	{ name = "Disco Dust Bunny", rarity = "Uncommon", rate = 35, color = Color3.fromRGB(200, 200, 210), size = 1.9, accessory = "glasses" },
	{ name = "Grandma's Flying Slipper", rarity = "Uncommon", rate = 40, color = Color3.fromRGB(200, 130, 200), size = 1.8, accessory = "bow" },
	{ name = "Sir Soggy Sandwich", rarity = "Uncommon", rate = 46, color = Color3.fromRGB(190, 140, 80), size = 2.0, accessory = "cap" },
	{ name = "The Left Sock Goblin", rarity = "Uncommon", rate = 52, color = Color3.fromRGB(90, 160, 90), size = 1.9, accessory = "antenna" },
	{ name = "Madame Microwave Burrito", rarity = "Uncommon", rate = 58, color = Color3.fromRGB(230, 220, 210), size = 2.1, accessory = "none" },
	{ name = "Captain Crunchy Cereal", rarity = "Uncommon", rate = 66, color = Color3.fromRGB(180, 120, 60), size = 2.1, accessory = "cap" },
	{ name = "Lord Leaky Faucet", rarity = "Uncommon", rate = 80, color = Color3.fromRGB(100, 170, 220), size = 2.1, accessory = "hat" },
	-- Rare (7) — the bay's local celebrities.
	{ name = "Quantum Quiche Wizard", rarity = "Rare", rate = 100, color = Color3.fromRGB(140, 90, 220), size = 2.2, accessory = "hat" },
	{ name = "DJ Disco Potato", rarity = "Rare", rate = 120, color = Color3.fromRGB(220, 180, 90), size = 2.2, accessory = "glasses" },
	{ name = "Sir Reginald Rubber Duck", rarity = "Rare", rate = 140, color = Color3.fromRGB(250, 225, 60), size = 2.2, accessory = "crown" },
	{ name = "The Spicy Noodle Dragon", rarity = "Rare", rate = 165, color = Color3.fromRGB(230, 80, 50), size = 2.4, accessory = "antenna" },
	{ name = "Professor Bubble Gum", rarity = "Rare", rate = 185, color = Color3.fromRGB(255, 130, 200), size = 2.3, accessory = "glasses" },
	{ name = "Count Von Spaghetti", rarity = "Rare", rate = 200, color = Color3.fromRGB(240, 200, 130), size = 2.4, accessory = "hat" },
	{ name = "Madame Moonlight Muffin", rarity = "Rare", rate = 220, color = Color3.fromRGB(180, 160, 230), size = 2.4, accessory = "bow" },
	-- Epic (6) — legends whispered about at the docks.
	{ name = "Galactic Gummy Bear", rarity = "Epic", rate = 280, color = Color3.fromRGB(255, 100, 160), size = 2.5, accessory = "bow" },
	{ name = "Sir Crocodile Croissant", rarity = "Epic", rate = 340, color = Color3.fromRGB(90, 170, 80), size = 2.6, accessory = "crown" },
	{ name = "The Invisible Ice Cream", rarity = "Epic", rate = 410, color = Color3.fromRGB(240, 245, 255), size = 2.5, accessory = "none" },
	{ name = "Duke Donut Dimension", rarity = "Epic", rate = 480, color = Color3.fromRGB(230, 150, 200), size = 2.7, accessory = "hat" },
	{ name = "Lady Lava Lamp", rarity = "Epic", rate = 540, color = Color3.fromRGB(255, 120, 40), size = 2.7, accessory = "glasses" },
	{ name = "King Kong Kangaroo Kebab", rarity = "Epic", rate = 600, color = Color3.fromRGB(180, 110, 60), size = 2.8, accessory = "cap" },
	-- Legendary (5) — almost too powerful to exist.
	{ name = "Sir Tacosaurus Rex", rarity = "Legendary", rate = 750, color = Color3.fromRGB(90, 190, 90), size = 2.9, accessory = "crown" },
	{ name = "The Cosmic Coffee Bean", rarity = "Legendary", rate = 900, color = Color3.fromRGB(110, 70, 40), size = 2.8, accessory = "glasses" },
	{ name = "Madame Marshmallow Meteor", rarity = "Legendary", rate = 1100, color = Color3.fromRGB(255, 240, 245), size = 3.0, accessory = "bow" },
	{ name = "Captain Cactus Smoothie", rarity = "Legendary", rate = 1300, color = Color3.fromRGB(70, 180, 90), size = 3.0, accessory = "antenna" },
	{ name = "Lord Laser Lasagna", rarity = "Legendary", rate = 1500, color = Color3.fromRGB(255, 200, 60), size = 3.1, accessory = "crown" },
	-- Mythic (3) — seen once, never forgotten.
	{ name = "The Golden Giraffe DJ", rarity = "Mythic", rate = 1800, color = Color3.fromRGB(255, 215, 0), size = 3.2, accessory = "glasses" },
	{ name = "Sir Unicorn Umbrella", rarity = "Mythic", rate = 2400, color = Color3.fromRGB(255, 180, 230), size = 3.2, accessory = "crown" },
	{ name = "The Intergalactic Iceberg", rarity = "Mythic", rate = 3200, color = Color3.fromRGB(180, 230, 255), size = 3.4, accessory = "antenna" },
	-- Secret (1) — the one every thief dreams of.
	{ name = "El Senor Burrito Galactico", rarity = "Secret", rate = 5000, color = Color3.fromRGB(255, 215, 0), size = 3.6, accessory = "crown" },
}

--- The buy price of a character: rate * 25.
function Catalog.getPrice(charDef)
	return charDef.rate * Config.PRICE_MULTIPLIER
end

--- Pick a random character, weighted by its rarity's spawn weight.
function Catalog.pickCharacter()
	local roll = math.random() * 100
	local acc = 0
	local rarityName = "Common"
	for name, rarityDef in pairs(Catalog.RARITIES) do
		acc = acc + rarityDef.weight
		if roll <= acc then
			rarityName = name
			break
		end
	end
	local pool = {}
	for _, charDef in ipairs(Catalog.CHARACTERS) do
		if charDef.rarity == rarityName then
			table.insert(pool, charDef)
		end
	end
	return pool[math.random(1, #pool)]
end

--- Roll a mutation: Rainbow 1%, Diamond 4%, Golden 12%, else none.
function Catalog.rollMutation()
	local roll = math.random()
	if roll < Catalog.MUTATIONS.Rainbow.chance then
		return "Rainbow"
	elseif roll < Catalog.MUTATIONS.Rainbow.chance + Catalog.MUTATIONS.Diamond.chance then
		return "Diamond"
	elseif roll < Catalog.MUTATIONS.Rainbow.chance + Catalog.MUTATIONS.Diamond.chance + Catalog.MUTATIONS.Golden.chance then
		return "Golden"
	end
	return ""
end

--- The income multiplier a mutation gives (1 when there is none).
function Catalog.mutationMultiplier(mutationName)
	if mutationName == "" then
		return 1
	end
	local mutationDef = Catalog.MUTATIONS[mutationName]
	return mutationDef.multiplier
end

return Catalog
