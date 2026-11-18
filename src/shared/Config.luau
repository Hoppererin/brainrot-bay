-- Brainrot Bay — shared tuning and world constants.
-- Every value other modules read lives here, in one place, so a typo in a
-- field name is caught by the static cross-check (check-config.py) instead
-- of killing the server at runtime.
local Config = {}

-- Economy
Config.START_CASH = 150
Config.PRICE_MULTIPLIER = 25 -- a brainrot costs rate * 25 (cheapest $125 < $150)
Config.SELL_REFUND = 0.5 -- selling refunds half of the buy price
Config.INCOME_TICK = 1 -- seconds between income ticks
Config.REBIRTH_BASE_COST = 250000 -- rebirth n costs base * n
Config.REBIRTH_BONUS = 0.25 -- +25% income per rebirth level
Config.BASE_WALK_SPEED = 16

-- HUD layout (kept clear of Roblox's own menu/chat buttons)
Config.TOP_BAR_Y = 44
Config.BANNER_Y = 106

-- Brainrot billboards (narrow enough that neighbours do not overlap)
Config.BILLBOARD_WIDTH = 110
Config.BILLBOARD_HEIGHT = 44
Config.BILLBOARD_NAME_SIZE = 12
Config.BILLBOARD_RARITY_SIZE = 10
Config.BILLBOARD_RATE_SIZE = 11

-- Conveyor
Config.CONVEYOR_LENGTH = 150
Config.CONVEYOR_SPEED = 4 -- studs per second
Config.CONVEYOR_Z = -70
Config.BELT_TOP_Y = 1
Config.BELT_MIN_X = -78 -- portal end
Config.BELT_MAX_X = 78 -- exit end
Config.SPAWN_INTERVAL = 2.5 -- seconds between spawns
Config.MAX_BELT = 12 -- brainrots on the belt at once

-- Spawn plaza
Config.SPAWN_POSITION = Vector3.new(0, 3, 60)
Config.SPAWN_CENTER = Vector3.new(0, 0, 60)
Config.SPAWN_SAFE_RADIUS = 15

-- Island
Config.ISLAND_SIZE = 220

-- Plots: 8 bases, 4 on the north row (z = -35) and 4 on the south row (z = 15).
-- An entry has ONLY id and center. There is deliberately NO color field here:
-- a plot's colour lives in PLOT_COLORS, keyed by the same id.
Config.PLOTS = {
	{ id = 1, center = Vector3.new(-75, 0, -35) },
	{ id = 2, center = Vector3.new(-25, 0, -35) },
	{ id = 3, center = Vector3.new(25, 0, -35) },
	{ id = 4, center = Vector3.new(75, 0, -35) },
	{ id = 5, center = Vector3.new(-75, 0, 15) },
	{ id = 6, center = Vector3.new(-25, 0, 15) },
	{ id = 7, center = Vector3.new(25, 0, 15) },
	{ id = 8, center = Vector3.new(75, 0, 15) },
}

-- Plot colours, keyed by plot id. This is the ONLY place a plot colour comes from.
Config.PLOT_COLORS = {
	[1] = Color3.fromRGB(255, 80, 80),
	[2] = Color3.fromRGB(255, 165, 0),
	[3] = Color3.fromRGB(255, 220, 60),
	[4] = Color3.fromRGB(80, 200, 90),
	[5] = Color3.fromRGB(60, 140, 255),
	[6] = Color3.fromRGB(150, 90, 255),
	[7] = Color3.fromRGB(255, 110, 200),
	[8] = Color3.fromRGB(60, 220, 220),
}

Config.PLOT_PAD_SIZE = Vector3.new(30, 0.5, 20)

-- Six slots per plot, a 3 x 2 grid around the plot centre.
Config.SLOT_OFFSETS = {
	Vector3.new(-9, 0, -5),
	Vector3.new(0, 0, -5),
	Vector3.new(9, 0, -5),
	Vector3.new(-9, 0, 5),
	Vector3.new(0, 0, 5),
	Vector3.new(9, 0, 5),
}

-- Upgrades: three levels each. Speed adds walk speed, Income adds income.
Config.UPGRADES = {
	Speed = { name = "Speed Boots", costs = { 500, 1500, 4000 }, maxLevel = 3, bonusPerLevel = 2 },
	Income = { name = "Income Boost", costs = { 1000, 3000, 8000 }, maxLevel = 3, bonusPerLevel = 0.10 },
}

-- Steal
Config.STEAL_TIME = 20 -- seconds to carry a stolen brainrot home
Config.STEAL_YANK_RANGE = 40 -- owner within this range yanks it back
Config.STEAL_SLOW_SPEED = 10 -- walk speed while carrying

-- Base lock
Config.LOCK_DURATION = 60
Config.LOCK_COOLDOWN = 120

-- Tsunami event
Config.TSUNAMI_INTERVAL = 180 -- seconds between waves
Config.TSUNAMI_WARNING = 10 -- warning seconds before the wave
Config.TSUNAMI_STUN = 2 -- seconds stunned after being splashed

-- Play code (goes in the experience description when published)
Config.PLAY_CODE = "makefun-quince-dragon-mole"

return Config
