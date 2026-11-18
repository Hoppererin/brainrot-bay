-- Config.luau
-- Shared tuning and world layout for Brainrot Bay (build4, written from scratch).
-- IMPORTANT: an entry of Config.PLOTS has ONLY the fields `id` and `center`.
-- Plot colours live in Config.PLOT_COLORS, keyed by plot id. Never read `.color`
-- (or any other field) off a PLOTS entry: it does not exist and a nil read
-- would kill the server before the conveyor starts (the build3 bug).

local Config = {}

-- Economy -----------------------------------------------------------------
Config.START_CASH = 150
Config.PRICE_MULT = 25 -- a brainrot costs rate * 25 (cheapest: 5 * 25 = $125)
Config.SELL_REFUND = 0.5 -- selling refunds half the price

-- Conveyor ----------------------------------------------------------------
Config.BELT_START_X = -70 -- west end, under the purple portal arch
Config.BELT_END_X = 70 -- east end, under the green exit arch
Config.BELT_Z = -70 -- the belt's line across the island's north edge
Config.BELT_Y = 2.6 -- pivot height of a brainrot walking the belt
Config.BELT_SPEED = 6 -- studs per second along the belt
Config.SPAWN_INTERVAL = 2.5 -- seconds between spawns while the belt has room
Config.BELT_MAX_WALKING = 12 -- the belt stops spawning past this many walkers

-- Spawn -------------------------------------------------------------------
Config.SPAWN_CENTER = Vector3.new(0, 0, 60)
Config.SPAWN_SAFE_RADIUS = 18 -- tsunami-safe circle around the spawn pad

-- Plots -------------------------------------------------------------------
-- 8 plots in two rows of four. Each entry: { id, center } ONLY.
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

-- Plot colours, keyed by plot id. This is the ONLY place a plot's colour lives.
Config.PLOT_COLORS = {
	[1] = Color3.fromRGB(255, 90, 90),
	[2] = Color3.fromRGB(90, 140, 255),
	[3] = Color3.fromRGB(90, 220, 120),
	[4] = Color3.fromRGB(255, 200, 60),
	[5] = Color3.fromRGB(200, 120, 255),
	[6] = Color3.fromRGB(255, 140, 200),
	[7] = Color3.fromRGB(90, 220, 220),
	[8] = Color3.fromRGB(255, 150, 60),
}


-- Six slots per plot, two rows of three, relative to the plot centre.
Config.SLOT_OFFSETS = {
	Vector3.new(-8, 0, -5),
	Vector3.new(0, 0, -5),
	Vector3.new(8, 0, -5),
	Vector3.new(-8, 0, 5),
	Vector3.new(0, 0, 5),
	Vector3.new(8, 0, 5),
}

-- Rebirth -----------------------------------------------------------------
Config.REBIRTH_BASE_COST = 250000 -- rebirth n costs base * n
Config.REBIRTH_BONUS = 0.25 -- +25% income per rebirth level

-- Lock and steal ----------------------------------------------------------
Config.LOCK_DURATION = 60 -- seconds a locked base cannot be stolen from
Config.LOCK_COOLDOWN = 120 -- seconds before the lock can be used again
Config.STEAL_TIME = 20 -- seconds a thief has to carry a brainrot home
Config.STEAL_YANK_RADIUS = 40 -- owner can yank a carried brainrot back within this many studs
Config.STEAL_SLOW_MULT = 0.55 -- walk-speed multiplier while carrying a stolen brainrot

-- Tsunami -----------------------------------------------------------------
Config.TSUNAMI_INTERVAL = 180 -- seconds between tsunami events
Config.TSUNAMI_WARNING = 10 -- seconds of warning banner before the wave
Config.TSUNAMI_STUN = 2 -- seconds a splashed player is stunned

-- Upgrades ----------------------------------------------------------------
-- Each upgrade has 3 levels. `costs` and `bonus` are parallel arrays.
Config.UPGRADES = {
	Speed = {
		name = "Speed Boots",
		costs = { 500, 5000, 50000 },
		bonus = { 4, 4, 4 }, -- +WalkSpeed per level
	},
	Income = {
		name = "Income Boost",
		costs = { 1000, 10000, 100000 },
		bonus = { 0.15, 0.15, 0.15 }, -- +income multiplier per level
	},
}

return Config
