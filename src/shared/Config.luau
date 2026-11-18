-- Brainrot Bay — shared tuning table.
-- Every price, rate and timing the game runs on lives in this one table,
-- so the server and the client can never disagree about them.

local Config = {}

-- Economy ------------------------------------------------------------------
Config.START_CASH = 150 -- enough to buy the cheapest brainrot ($125) and keep $25
Config.SELL_REFUND = 0.5 -- selling a brainrot returns half its buy price
Config.PRICE_PER_RATE = 25 -- a brainrot's price is its $/s rate times this

-- Conveyor -----------------------------------------------------------------
Config.SPAWN_INTERVAL = 2.5 -- seconds between spawns while the belt has room
Config.BELT_MAX_WALKING = 12 -- the belt stops spawning past this many walkers
Config.BELT_START_X = -70 -- west end, under the portal arch
Config.BELT_END_X = 70 -- east end, under the exit arch
Config.BELT_Z = -70 -- the belt's line across the island's north edge
Config.BELT_Y = 2.6 -- pivot height of a brainrot walking the belt (feet on the belt's top)
Config.BELT_SPEED = 6 -- studs per second along the belt

-- Rebirth ------------------------------------------------------------------
Config.REBIRTH_BASE_COST = 250000 -- times the level being bought (1st costs 250k)
Config.REBIRTH_BONUS = 0.25 -- +25% income per rebirth level, forever

-- Base lock ----------------------------------------------------------------
Config.LOCK_DURATION = 60 -- seconds a base stays locked
Config.LOCK_COOLDOWN = 120 -- seconds before the same base can lock again

-- Stealing -----------------------------------------------------------------
Config.STEAL_TIME = 20 -- seconds to carry a stolen brainrot home
Config.STEAL_SLOW = 0.6 -- walk-speed multiplier while carrying a steal
Config.YANK_RANGE = 40 -- studs: the owner can yank a carried brainrot back
Config.STEAL_HOME_RANGE = 18 -- studs from your own plot centre to complete a steal

-- Tsunami ------------------------------------------------------------------
Config.TSUNAMI_INTERVAL = 180 -- seconds between waves (3 minutes)
Config.TSUNAMI_WARNING = 10 -- seconds of warning before the wave sweeps
Config.TSUNAMI_STUN = 2 -- seconds a splashed player cannot move

-- Movement -----------------------------------------------------------------
Config.BASE_WALKSPEED = 16 -- a fresh player's walk speed

-- Plots --------------------------------------------------------------------
-- Eight colour-coded base plots in two rows. A plot is a 26 x 22 pad; its six
-- slots sit on the offsets below, so a brainrot always lands on its own pad.
Config.PLOT_COLORS = {
	Color3.fromRGB(255, 90, 90),
	Color3.fromRGB(90, 160, 255),
	Color3.fromRGB(90, 220, 120),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(200, 120, 255),
	Color3.fromRGB(255, 140, 200),
	Color3.fromRGB(90, 220, 220),
	Color3.fromRGB(255, 150, 60),
}

Config.PLOTS = {
	{ id = 1, center = Vector3.new(-84, 0, -35) },
	{ id = 2, center = Vector3.new(-28, 0, -35) },
	{ id = 3, center = Vector3.new(28, 0, -35) },
	{ id = 4, center = Vector3.new(84, 0, -35) },
	{ id = 5, center = Vector3.new(-84, 0, 15) },
	{ id = 6, center = Vector3.new(-28, 0, 15) },
	{ id = 7, center = Vector3.new(28, 0, 15) },
	{ id = 8, center = Vector3.new(84, 0, 15) },
}

-- Six slots per plot, two rows of three, inside the 26 x 22 pad.
Config.SLOT_OFFSETS = {
	Vector3.new(-8, 0, -5),
	Vector3.new(0, 0, -5),
	Vector3.new(8, 0, -5),
	Vector3.new(-8, 0, 5),
	Vector3.new(0, 0, 5),
	Vector3.new(8, 0, 5),
}

-- The spawn plaza, where players arrive and where the wave cannot reach.
Config.SPAWN_CENTER = Vector3.new(0, 0, 60)
Config.SPAWN_SAFE_RADIUS = 18

-- Upgrades -----------------------------------------------------------------
-- Two tracks, three levels each. Speed adds walk speed; Income multiplies
-- every brainrot's rate. Costs are paid in cash, one level at a time.
Config.UPGRADES = {
	Speed = {
		name = "Speed Boots",
		maxLevel = 3,
		costs = { 500, 2000, 8000 },
		bonusPerLevel = 2,
	},
	Income = {
		name = "Income Boost",
		maxLevel = 3,
		costs = { 750, 3000, 12000 },
		bonusPerLevel = 0.15,
	},
}

return Config
