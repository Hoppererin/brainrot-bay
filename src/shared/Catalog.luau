-- Brainrot Bay — the cast.
-- 21 original characters on a ladder of 7 rarities, $5/s to $5,000/s.
-- A brainrot's price comes from its rate: it pays for itself in about
-- 25 seconds, so the ladder is the economy. A mutation multiplies both
-- the rate and the price, and tints the body its own colour.

local Catalog = {}

-- Rarity colours and spawn weights (out of 100). Common walks the belt
-- most often; a Secret is a rare sight.
Catalog.RARITIES = {
	Common = { color = Color3.fromRGB(205, 205, 205), weight = 40 },
	Rare = { color = Color3.fromRGB(80, 180, 255), weight = 25 },
	Epic = { color = Color3.fromRGB(180, 90, 255), weight = 15 },
	Legendary = { color = Color3.fromRGB(255, 180, 40), weight = 10 },
	Mythic = { color = Color3.fromRGB(255, 80, 180), weight = 6 },
	Divine = { color = Color3.fromRGB(255, 230, 90), weight = 3 },
	Secret = { color = Color3.fromRGB(120, 255, 220), weight = 1 },
}

-- name, rarity, $/s, body colour, belly colour, head accessory, size.
Catalog.CHARACTERS = {
	-- Common: cheap, everywhere, the first rung.
	{ name = "Sir Toaster Crumb", rarity = "Common", rate = 5, body = Color3.fromRGB(210, 180, 120), belly = Color3.fromRGB(245, 220, 160), accessory = "toaster", scale = 1.0 },
	{ name = "Baron Von Waffle", rarity = "Common", rate = 8, body = Color3.fromRGB(190, 140, 70), belly = Color3.fromRGB(230, 190, 110), accessory = "crown", scale = 1.0 },
	{ name = "Captain Noodlebeard", rarity = "Common", rate = 12, body = Color3.fromRGB(240, 220, 150), belly = Color3.fromRGB(255, 245, 200), accessory = "hat", scale = 1.05 },
	-- Rare: a first taste of real money.
	{ name = "Madame Croissant", rarity = "Rare", rate = 20, body = Color3.fromRGB(220, 170, 90), belly = Color3.fromRGB(250, 215, 140), accessory = "beret", scale = 1.05 },
	{ name = "El Gato Volador", rarity = "Rare", rate = 28, body = Color3.fromRGB(255, 150, 60), belly = Color3.fromRGB(255, 210, 140), accessory = "wings", scale = 1.1 },
	{ name = "Professor Bubbleduck", rarity = "Rare", rate = 35, body = Color3.fromRGB(255, 230, 80), belly = Color3.fromRGB(255, 245, 170), accessory = "glasses", scale = 1.1 },
	-- Epic: the belt starts to feel generous.
	{ name = "Count Spaghettino", rarity = "Epic", rate = 55, body = Color3.fromRGB(200, 60, 60), belly = Color3.fromRGB(245, 200, 170), accessory = "cape", scale = 1.15 },
	{ name = "Lady Llama Latte", rarity = "Epic", rate = 70, body = Color3.fromRGB(200, 160, 200), belly = Color3.fromRGB(240, 220, 240), accessory = "flower", scale = 1.15 },
	{ name = "General Pickle", rarity = "Epic", rate = 90, body = Color3.fromRGB(90, 180, 80), belly = Color3.fromRGB(160, 230, 130), accessory = "helmet", scale = 1.2 },
	-- Legendary: the ones players cross the map for.
	{ name = "Dr. Disco Banana", rarity = "Legendary", rate = 140, body = Color3.fromRGB(255, 220, 40), belly = Color3.fromRGB(255, 240, 130), accessory = "disco", scale = 1.25 },
	{ name = "Queen Of The Couch", rarity = "Legendary", rate = 180, body = Color3.fromRGB(160, 90, 200), belly = Color3.fromRGB(210, 160, 240), accessory = "crown", scale = 1.25 },
	{ name = "Sir Reginald Wobblebottom", rarity = "Legendary", rate = 220, body = Color3.fromRGB(120, 170, 255), belly = Color3.fromRGB(190, 220, 255), accessory = "tophat", scale = 1.3 },
	-- Mythic: a whole base's income in one body.
	{ name = "The Almighty Burrito", rarity = "Mythic", rate = 320, body = Color3.fromRGB(190, 130, 60), belly = Color3.fromRGB(240, 200, 120), accessory = "cape", scale = 1.35 },
	{ name = "Lord Slippery Soap", rarity = "Mythic", rate = 420, body = Color3.fromRGB(140, 220, 255), belly = Color3.fromRGB(210, 245, 255), accessory = "bubble", scale = 1.35 },
	{ name = "Empress Of WiFi", rarity = "Mythic", rate = 520, body = Color3.fromRGB(255, 120, 200), belly = Color3.fromRGB(255, 190, 230), accessory = "antenna", scale = 1.4 },
	-- Divine: endgame money printers.
	{ name = "Zeus The Goldfish", rarity = "Divine", rate = 800, body = Color3.fromRGB(255, 170, 40), belly = Color3.fromRGB(255, 220, 130), accessory = "lightning", scale = 1.45 },
	{ name = "Chrono Cat Supreme", rarity = "Divine", rate = 1000, body = Color3.fromRGB(90, 90, 160), belly = Color3.fromRGB(160, 160, 230), accessory = "clock", scale = 1.45 },
	{ name = "The Infinite Sandwich", rarity = "Divine", rate = 1250, body = Color3.fromRGB(230, 200, 140), belly = Color3.fromRGB(255, 240, 200), accessory = "toaster", scale = 1.5 },
	-- Secret: the belt almost never shows these.
	{ name = "Brr Brr The Forbidden One", rarity = "Secret", rate = 2500, body = Color3.fromRGB(60, 60, 90), belly = Color3.fromRGB(120, 120, 180), accessory = "crown", scale = 1.6 },
	{ name = "Grandma's Secret Recipe", rarity = "Secret", rate = 3500, body = Color3.fromRGB(255, 140, 140), belly = Color3.fromRGB(255, 200, 200), accessory = "chefhat", scale = 1.6 },
	{ name = "The Last Brain Cell", rarity = "Secret", rate = 5000, body = Color3.fromRGB(200, 255, 220), belly = Color3.fromRGB(240, 255, 245), accessory = "halo", scale = 1.7 },
}

-- Mutations: rolled at spawn, rarest first. A mutated brainrot earns its
-- multiplier and is worth the same multiplier on its price.
Catalog.MUTATIONS = {
	{ name = "Rainbow", mult = 8, chance = 0.015, color = Color3.fromRGB(255, 120, 220) },
	{ name = "Diamond", mult = 4, chance = 0.04, color = Color3.fromRGB(180, 240, 255) },
	{ name = "Golden", mult = 2, chance = 0.10, color = Color3.fromRGB(255, 215, 0) },
}

-- A brainrot's buy price: its rate times 25, so it pays for itself in
-- about 25 seconds. A mutation multiplies the price with the rate.
function Catalog.getPrice(character, mutation)
	local mult = 1
	if mutation ~= nil then
		mult = mutation.mult
	end
	return math.floor(character.rate * 25 * mult)
end

-- The $/s a brainrot earns, with its mutation applied.
function Catalog.getEffectiveRate(character, mutation)
	local mult = 1
	if mutation ~= nil then
		mult = mutation.mult
	end
	return character.rate * mult
end

-- Rolls one mutation by chance, rarest first, or nil for a plain brainrot.
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

-- Picks a character weighted by its rarity, so Commons crowd the belt
-- and Secrets stay rare.
function Catalog.randomCharacter()
	local total = 0
	for _, rarity in pairs(Catalog.RARITIES) do
		total += rarity.weight
	end
	local roll = math.random() * total
	local running = 0
	for _, character in ipairs(Catalog.CHARACTERS) do
		running += Catalog.RARITIES[character.rarity].weight
		if roll < running then
			return character
		end
	end
	return Catalog.CHARACTERS[1]
end

return Catalog
