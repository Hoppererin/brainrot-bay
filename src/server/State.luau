-- State.luau
-- The single server-side store for Brainrot Bay (build4, written from scratch).
-- One table per player; every other server module reads and writes through here.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local State = {}

local players = {} -- [Player] = player state
local records = {} -- [recordId] = brainrot record, every brainrot in the game

-- A brainrot record:
--   id, charName, rarity, rate, mutation (string or nil), mult,
--   plotId (0 while walking the belt), slot (0 while walking),
--   owner (Player or nil), model (Model or nil), carried (bool)

function State.newPlayer(player)
	players[player] = {
		cash = Config.START_CASH,
		income = 0,
		rebirths = 0,
		speedLevel = 0,
		incomeLevel = 0,
		lockUntil = 0,
		lockCooldownUntil = 0,
		plotId = 0,
		owned = {}, -- [recordId] = record
		carrying = nil, -- recordId of a stolen brainrot being carried, or nil
	}
	return players[player]
end

function State.get(player)
	return players[player]
end

function State.remove(player)
	players[player] = nil
end

function State.allPlayers()
	return players
end

function State.addRecord(record)
	records[record.id] = record
end

function State.getRecord(recordId)
	return records[recordId]
end

function State.removeRecord(recordId)
	records[recordId] = nil
end

function State.addCash(player, amount)
	local state = players[player]
	if state == nil then
		return
	end
	state.cash += amount
end

-- Recompute a player's $/s from what they own: base rates, mutation
-- multipliers, rebirth bonus and the income upgrade.
function State.recalcIncome(player)
	local state = players[player]
	if state == nil then
		return 0
	end
	local total = 0
	for _, record in pairs(state.owned) do
		total += record.rate * record.mult
	end
	local rebirthMult = 1 + Config.REBIRTH_BONUS * state.rebirths
	local upgradeMult = 1 + 0.15 * state.incomeLevel
	state.income = math.floor(total * rebirthMult * upgradeMult + 0.5)
	return state.income
end

-- Walk speed from the speed upgrade: base 16, +4 per level.
function State.walkSpeed(player)
	local state = players[player]
	if state == nil then
		return 16
	end
	return 16 + 4 * state.speedLevel
end

return State
