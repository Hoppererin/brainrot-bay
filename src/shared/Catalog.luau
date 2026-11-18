-- Brainrot Bay: the cast.
-- Every character the conveyor can spawn, on a ladder of seven rarities.
-- All names are original and absurd; each has its own colours, size,
-- head accessory and money-per-second. A brainrot's price comes from its
-- rate: it pays for itself in about 25 seconds, so the ladder is the
-- whole progression.

local Catalog = {}

-- payMultiplier is reserved for a future rarity payout tweak; today every
-- rarity pays its catalog rate as-is, and the ladder comes from rate alone.
Catalog.RARITIES = {
	{ name = "Common", weight = 40, color = Color3.fromRGB(170, 170, 170), payMultiplier = 1 },
	{ name = "Rare", weight = 25, color = Color3.fromRGB(80, 180, 255), payMultiplier = 1 },
	{ name = "Epic", weight = 15, color = Color3.fromRGB(180, 90, 255), payMultiplier = 1 },
	{ name = "Legendary", weight = 10, color = Color3.fromRGB(255, 190, 40), payMultiplier = 1 },
	{ name = "Mythic", weight = 6, color = Color3.fromRGB(255, 90, 160), payMultiplier = 1 },
	{ name = "Divine", weight = 3, color = Color3.fromRGB(255, 240, 120), payMultiplier = 1 },
	{ name = "Secret", weight = 1, color = Color3.fromRGB(40, 230, 200), payMultiplier = 1 },
}

-- accessory: the little prop the factory bolts onto the character's head.
-- body / belly paint the model; scale grows with rarity.
Catalog.CHARACTERS = {
	-- Common
	{ name = "Sir Toaster Crumb", rarity = "Common", rate = 5, body = Color3.fromRGB(210, 180, 120), belly = Color3.fromRGB(245, 220, 160), accessory = "toaster", scale = 1.0 },
	{ name = "Baron Von Waffle", rarity = "Common", rate = 8, body = Color3.fromRGB(190, 140, 70), belly = Color3.fromRGB(230, 190, 110), accessory = "crown", scale = 1.0 },
	{ name = "Captain Noodlebeard", rarity = "Common", rate = 12, body = Color3.fromRGB(240, 220, 150), belly = Color3.fromRGB(255, 245, 200), accessory = "hat", scale = 1.05 },
	-- Rare
	{ name = "Madame Croissant", rarity = "Rare", rate = 20, body = Color3.fromRGB(220, 170, 90), belly = Color3.fromRGB(250, 215, 140), accessory = "beret", scale = 1.05 },
	{ name = "El Gato Volador", rarity = "Rare", rate = 28, body = Color3.fromRGB(255, 150, 60), belly = Color3.fromRGB(255, 210, 140), accessory = "wings", scale = 1.1 },
	{ name = "Professor Bubbleduck", rarity = "Rare", rate = 35, body = Color3.fromRGB(255, 230, 80), belly = Color3.fromRGB(255, 245, 170), accessory = "glasses", scale = 1.1 },
	-- Epic
	{ name = "Count Spaghettino", rarity = "Epic", rate = 55, body = Color3.fromRGB(200, 60, 60), belly = Color3.fromRGB(245, 200, 170), accessory = "cape", scale = 1.15 },
	{ name = "Lady Llama Latte", rarity = "Epic", rate = 70, body = Color3.fromRGB(200, 160, 200), belly = Color3.fromRGB(240, 220, 240), accessory = "flower", scale = 1.15 },
	{ name = "General Pickle", rarity = "Epic", rate = 90, body = Color3.fromRGB(90, 180, 80), belly = Color3.fromRGB(160, 230, 130), accessory = "helmet", scale = 1.2 },
	-- Legendary
	{ name = "Dr. Disco Banana", rarity = "Legendary", rate = 140, body = Color3.fromRGB(255, 220, 40), belly = Color3.fromRGB(255, 240, 130), accessory = "disco", scale = 1.25 },
	{ name = "Queen Of The Couch", rarity = "Legendary", rate = 180, body = Color3.fromRGB(160, 90, 200), belly = Color3.fromRGB(210, 160, 240), accessory = "crown", scale = 1.25 },
	{ name = "Sir Reginald Wobblebottom", rarity = "Legendary", rate = 220, body = Color3.fromRGB(120, 170, 255), belly = Color3.fromRGB(190, 220, 255), accessory = "tophat", scale = 1.3 },
	-- Mythic
	{ name = "The Almighty Burrito", rarity = "Mythic", rate = 320, body = Color3.fromRGB(190, 130, 60), belly = Color3.fromRGB(240, 200, 120), accessory = "cape", scale = 1.35 },
	{ name = "Lord Slippery Soap", rarity = "Mythic", rate = 420, body = Color3.fromRGB(140, 220, 255), belly = Color3.fromRGB(210, 245, 255), accessory = "bubble", scale = 1.35 },
	{ name = "Empress Of WiFi", rarity = "Mythic", rate = 520, body = Color3.fromRGB(255, 120, 200), belly = Color3.fromRGB(255, 190, 230), accessory = "antenna", scale = 1.4 },
	-- Divine
	{ name = "Zeus The Goldfish", rarity = "Divine", rate = 800, body = Color3.fromRGB(255, 170, 40), belly = Color3.fromRGB(255, 220, 130), accessory = "lightning", scale = 1.45 },
	{ name = "Chrono Cat Supreme", rarity = "Divine", rate = 1000, body = Color3.fromRGB(90, 90, 160), belly = Color3.fromRGB(160, 160, 230), accessory = "clock", scale = 1.45 },
	{ name = "The Infinite Sandwich", rarity = "Divine", rate = 1250, body = Color3.fromRGB(230, 200, 140), belly = Color3.fromRGB(255, 240, 200), accessory = "toaster", scale = 1.5 },
	-- Secret
	{ name = "Brr Brr The Forbidden One", rarity = "Secret", rate = 2500, body = Color3.fromRGB(60, 60, 90), belly = Color3.fromRGB(120, 120, 180), accessory = "crown", scale = 1.6 },
	{ name = "Grandma's Secret Recipe", rarity = "Secret", rate = 3500, body = Color3.fromRGB(255, 140, 140), belly = Color3.fromRGB(255, 200, 200), accessory = "chefhat", scale = 1.6 },
	{ name = "The Last Brain Cell", rarity = "Secret", rate = 5000, body = Color3.fromRGB(200, 255, 220), belly = Color3.fromRGB(240, 255, 245), accessory = "halo", scale = 1.7 },
}

-- Mutations: a spawned brainrot sometimes comes mutated, worth much more.
Catalog.MUTATIONS = {
	{ name = "Normal", weight = 85, multiplier = 1, tint = nil },
	{ name = "Golden", weight = 10, multiplier = 2, tint = Color3.fromRGB(255, 215, 0) },
	{ name = "Diamond", weight = 4, multiplier = 4, tint = Color3.fromRGB(120, 230, 255) },
	{ name = "Rainbow", weight = 1, multiplier = 8, tint = Color3.fromRGB(255, 100, 200) },
}

function Catalog.getRarity(name: string)
	for _, rarity in ipairs(Catalog.RARITIES) do
		if rarity.name == name then
			return rarity
		end
	end
	return Catalog.RARITIES[1]
end

function Catalog.getCost(character): number
	-- A brainrot pays for itself in about 25 seconds of earning.
	return math.floor(character.rate * 25)
end

function Catalog.getEffectiveRate(character, mutation): number
	return math.floor(character.rate * mutation.multiplier)
end

local function pickWeighted(entries)
	local total = 0
	for _, entry in ipairs(entries) do
		total += entry.weight
	end
	local roll = math.random() * total
	for _, entry in ipairs(entries) do
		roll -= entry.weight
		if roll <= 0 then
			return entry
		end
	end
	return entries[1]
end

-- Rolls one full spawn: a character (weighted by rarity, then evenly inside
-- the rarity), a mutation, and the final money-per-second and price.
function Catalog.rollSpawn()
	local rarity = pickWeighted(Catalog.RARITIES)
	local pool = {}
	for _, character in ipairs(Catalog.CHARACTERS) do
		if character.rarity == rarity.name then
			table.insert(pool, character)
		end
	end
	local character = pool[math.random(1, #pool)]
	local mutation = pickWeighted(Catalog.MUTATIONS)
	return {
		character = character,
		mutation = mutation,
		rate = Catalog.getEffectiveRate(character, mutation),
		cost = Catalog.getCost(character) * mutation.multiplier,
	}
end

return Catalog
