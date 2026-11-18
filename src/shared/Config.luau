-- Brainrot Bay: shared tuning numbers.
-- Every price, rate and timing the game runs on lives in this one table,
-- so the server and the client can never disagree about them.

local Config = {}

-- Economy ---------------------------------------------------------------
Config.START_CASH = 100
Config.INCOME_TICK_SECONDS = 1
Config.SELL_REFUND = 0.5 -- selling a brainrot returns half its buy price

-- Conveyor ---------------------------------------------------------------
Config.SPAWN_INTERVAL = 2.5 -- seconds between spawns while the belt has room
Config.MAX_WALKING = 10 -- brainrots walking the belt at once
Config.WALK_SPEED = 4 -- studs per second along the belt
Config.BELT_START_X = -78
Config.BELT_END_X = 78
Config.BELT_Z = 0
Config.BELT_Y = 2 -- the height brainrots walk at

-- Plots ------------------------------------------------------------------
Config.PLOT_COUNT = 8
Config.SLOTS_PER_PLOT = 6
Config.PLOT_SIZE_X = 22
Config.PLOT_SIZE_Z = 14

-- Stealing ---------------------------------------------------------------
Config.CARRY_TIME_LIMIT = 20 -- seconds to reach your base with a stolen brainrot
Config.CARRY_SPEED_PENALTY = 6 -- WalkSpeed while carrying (down from 16)
Config.YANK_BACK_RANGE = 40 -- studs: owner can yank a carried brainrot back
Config.YANK_BACK_COOLDOWN = 15
Config.LOCK_DURATION = 60
Config.LOCK_COOLDOWN = 120

-- Tsunami event ----------------------------------------------------------
Config.TSUNAMI_INTERVAL = 180 -- seconds between waves
Config.TSUNAMI_WARNING = 10 -- seconds of warning before the wave
Config.TSUNAMI_SWEEP_SECONDS = 8 -- how long the wave takes to cross the map
Config.TSUNAMI_STUN = 2 -- seconds a splashed player cannot move

-- Rebirth ----------------------------------------------------------------
-- Cost grows with level: level N costs 250k x N (see State.getRebirthCost).
Config.REBIRTH_BASE_COST = 250000
Config.REBIRTH_MULT_PER_LEVEL = 0.25 -- +25% income per rebirth

-- Upgrades ---------------------------------------------------------------
-- Each entry is the cash cost of that level. Speed adds WalkSpeed,
-- Income adds a flat multiplier on top of everything else.
Config.UPGRADES = {
	Speed = {
		costs = { 5000, 25000, 100000 },
		bonusPerLevel = 4, -- WalkSpeed
	},
	Income = {
		costs = { 10000, 50000, 250000 },
		bonusPerLevel = 0.15, -- +15% income per level
	},
}

return Config
