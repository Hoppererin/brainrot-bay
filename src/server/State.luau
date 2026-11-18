-- Brainrot Bay: the single state store.
-- Every number that matters about a player lives in one table per player,
-- so no two services can disagree about cash, income, rebirths or upgrades.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local State = {}
State.Players = {} -- [Player] = state table

function State.new(player: Player)
	local state = {
		player = player,
		cash = Config.START_CASH,
		rebirths = 0,
		upgrades = { Speed = 0, Income = 0 },
		plotId = nil,
		owned = {}, -- [brainrotId] = brainrot record
		carrying = nil, -- brainrotId the player is carrying, if any
		lockUntil = 0,
		lockCooldownUntil = 0,
		yankCooldownUntil = 0,
		stunnedUntil = 0, -- os.clock() time until the tsunami stun wears off
		baseWalkSpeed = 16,
	}
	State.Players[player] = state
	return state
end

function State.get(player: Player)
	return State.Players[player]
end

function State.remove(player: Player)
	State.Players[player] = nil
end

-- Income multiplier from rebirths and the Income upgrade, combined.
function State.getIncomeMultiplier(state): number
	local mult = 1 + state.rebirths * Config.REBIRTH_MULT_PER_LEVEL
	mult += state.upgrades.Income * Config.UPGRADES.Income.bonusPerLevel
	return mult
end

-- WalkSpeed with the Speed upgrade applied (carrying slows you down).
function State.getWalkSpeed(state): number
	local speed = state.baseWalkSpeed + state.upgrades.Speed * Config.UPGRADES.Speed.bonusPerLevel
	if state.carrying ~= nil then
		speed = Config.CARRY_SPEED_PENALTY
	end
	return speed
end

-- Money per second across everything the player owns, after multipliers.
function State.getIncomePerSecond(state): number
	local total = 0
	for _, brainrot in pairs(state.owned) do
		total += brainrot.rate
	end
	return math.floor(total * State.getIncomeMultiplier(state))
end

function State.getRebirthCost(state): number
	return Config.REBIRTH_BASE_COST * (state.rebirths + 1)
end

return State
