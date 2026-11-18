-- Catalog.luau
-- The brainrot cast for Brainrot Bay (build4, written from scratch):
-- 21 original characters in 7 rarities, plus 3 mutations.
-- A character entry has ONLY the fields: name, rarity, rate, body, accent,
-- size, accessory. A rarity entry has ONLY: color, weight.
-- A mutation entry has ONLY: name, mult, chance, color.

local Config = require(script.Parent.Config)

local Catalog = {}

-- Rarities, common first. `weight` is the spawn weight of the whole rarity.
Catalog.RARITIES = {
	Common = { color = Color3.fromRGB(200, 200, 200), weight = 45 },
	Rare = { color = Color3.fromRGB(80, 140, 255), weight = 25 },
	Epic = { color = Color3.fromRGB(170, 80, 255), weight = 14 },
	Legendary = { color = Color3.fromRGB(255, 200, 40), weight = 8 },
	Mythic = { color = Color3.fromRGB(255, 70, 120), weight = 4.5 },
	Godly = { color = Color3.fromRGB(60, 230, 230), weight = 2.5 },
	Secret = { color = Color3.fromRGB(30, 30, 30), weight = 1 },
}

Catalog.RARITY_ORDER = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret" }

-- 21 characters, 3 per rarity. `rate` is $/s, `body`/`accent` are part colours,
-- `size` scales the model, `accessory` picks the head piece the factory builds.
Catalog.CHARACTERS = {
	{ name = "Baron Baguette", rarity = "Common", rate = 5, body = Color3.fromRGB(222, 184, 120), accent = Color3.fromRGB(120, 60, 20), size = 1.0, accessory = "Beret" },
	{ name = "Sir Soggy Cereal", rarity = "Common", rate = 8, body = Color3.fromRGB(190, 170, 200), accent = Color3.fromRGB(90, 60, 120), size = 1.05, accessory = "Bowl" },
	{ name = "Duke of Donuts", rarity = "Common", rate = 12, body = Color3.fromRGB(240, 150, 180), accent = Color3.fromRGB(255, 255, 255), size = 1.1, accessory = "Sprinkles" },
	{ name = "Madame Pickle", rarity = "Rare", rate = 20, body = Color3.fromRGB(90, 180, 80), accent = Color3.fromRGB(40, 100, 40), size = 1.1, accessory = "Hat" },
	{ name = "Count Cappuccino", rarity = "Rare", rate = 30, body = Color3.fromRGB(150, 110, 70), accent = Color3.fromRGB(240, 230, 210), size = 1.15, accessory = "Monocle" },
	{ name = "Lady Lollipop", rarity = "Rare", rate = 45, body = Color3.fromRGB(230, 80, 120), accent = Color3.fromRGB(255, 255, 255), size = 1.15, accessory = "Bow" },
	{ name = "General Gummy Bear", rarity = "Epic", rate = 60, body = Color3.fromRGB(230, 60, 60), accent = Color3.fromRGB(255, 200, 0), size = 1.25, accessory = "Helmet" },
	{ name = "Professor Popcorn", rarity = "Epic", rate = 85, body = Color3.fromRGB(250, 240, 200), accent = Color3.fromRGB(230, 40, 40), size = 1.2, accessory = "Glasses" },
	{ name = "Queen Queso", rarity = "Epic", rate = 120, body = Color3.fromRGB(250, 210, 60), accent = Color3.fromRGB(255, 255, 255), size = 1.3, accessory = "Crown" },
	{ name = "King Ketchup", rarity = "Legendary", rate = 180, body = Color3.fromRGB(220, 30, 30), accent = Color3.fromRGB(255, 255, 255), size = 1.35, accessory = "Crown" },
	{ name = "Empress Espresso", rarity = "Legendary", rate = 250, body = Color3.fromRGB(80, 50, 30), accent = Color3.fromRGB(210, 170, 120), size = 1.35, accessory = "Tiara" },
	{ name = "Lord Lasagna", rarity = "Legendary", rate = 350, body = Color3.fromRGB(240, 140, 40), accent = Color3.fromRGB(200, 60, 20), size = 1.4, accessory = "Cape" },
	{ name = "Wizard Waffle", rarity = "Mythic", rate = 500, body = Color3.fromRGB(230, 180, 60), accent = Color3.fromRGB(120, 60, 200), size = 1.45, accessory = "WizardHat" },
	{ name = "Sultan Spaghetti", rarity = "Mythic", rate = 700, body = Color3.fromRGB(240, 200, 120), accent = Color3.fromRGB(200, 30, 30), size = 1.5, accessory = "Turban" },
	{ name = "Duchess Dumpling", rarity = "Mythic", rate = 950, body = Color3.fromRGB(240, 240, 235), accent = Color3.fromRGB(180, 120, 200), size = 1.5, accessory = "Fan" },
	{ name = "Emperor Eggroll", rarity = "Godly", rate = 1300, body = Color3.fromRGB(210, 150, 80), accent = Color3.fromRGB(255, 210, 0), size = 1.6, accessory = "Crown" },
	{ name = "Saint Sushi", rarity = "Godly", rate = 1800, body = Color3.fromRGB(250, 180, 160), accent = Color3.fromRGB(40, 120, 80), size = 1.6, accessory = "Halo" },
	{ name = "Pope Pizza", rarity = "Godly", rate = 2400, body = Color3.fromRGB(240, 170, 60), accent = Color3.fromRGB(200, 40, 40), size = 1.7, accessory = "Halo" },
	{ name = "God of Ramen", rarity = "Secret", rate = 3200, body = Color3.fromRGB(200, 60, 40), accent = Color3.fromRGB(255, 200, 0), size = 1.8, accessory = "Crown" },
	{ name = "The Flying Burrito", rarity = "Secret", rate = 4200, body = Color3.fromRGB(180, 140, 90), accent = Color3.fromRGB(60, 180, 60), size = 1.8, accessory = "Wings" },
	{ name = "El Gran Taco Supreme", rarity = "Secret", rate = 5000, body = Color3.fromRGB(250, 200, 50), accent = Color3.fromRGB(220, 60, 40), size = 1.9, accessory = "Sombrero" },
}

-- Mutations. `chance` is the single-roll probability; the roll checks them
-- rarest first (Rainbow, then Diamond, then Golden).
Catalog.MUTATIONS = {
	{ name = "Rainbow", mult = 8, chance = 0.01, color = Color3.fromRGB(255, 100, 200) },
	{ name = "Diamond", mult = 4, chance = 0.04, color = Color3.fromRGB(120, 230, 255) },
	{ name = "Golden", mult = 2, chance = 0.12, color = Color3.fromRGB(255, 215, 0) },
}

-- Price of one brainrot: its effective rate (base rate times mutation) * 25.
function Catalog.getPrice(record)
	return record.rate * record.mult * Config.PRICE_MULT
end

-- The colour of a rarity's label.
function Catalog.rarityColor(rarity)
	local entry = Catalog.RARITIES[rarity]
	if entry == nil then
		return Color3.fromRGB(255, 255, 255)
	end
	return entry.color
end

-- Roll one mutation for a fresh spawn. Returns the mutation entry, or nil.
function Catalog.rollMutation()
	local roll = math.random()
	local running = 0
	for _, mutation in ipairs(Catalog.MUTATIONS) do
		running += mutation.chance
		if roll < running then
			return mutation
		end
	end
	return nil
end

-- Roll one character, weighted by rarity, then uniform inside the rarity.
function Catalog.rollCharacter()
	local total = 0
	for _, rarity in ipairs(Catalog.RARITY_ORDER) do
		total += Catalog.RARITIES[rarity].weight
	end
	local pick = math.random() * total
	local chosen = "Common"
	for _, rarity in ipairs(Catalog.RARITY_ORDER) do
		pick -= Catalog.RARITIES[rarity].weight
		if pick <= 0 then
			chosen = rarity
			break
		end
	end
	local pool = {}
	for _, character in ipairs(Catalog.CHARACTERS) do
		if character.rarity == chosen then
			table.insert(pool, character)
		end
	end
	return pool[math.random(1, #pool)]
end

return Catalog
