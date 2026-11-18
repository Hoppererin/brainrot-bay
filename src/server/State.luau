-- Brainrot Bay — the single player-state store.
-- Every player has exactly one state record; every module reads and writes
-- through here, never through its own copy.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local State = {}
State.players = {}

--- A fresh state record for a player who just joined.
function State.newPlayer(player)
	local state = {
		player = player,
		cash = Config.START_CASH,
		rebirths = 0,
		speedLevel = 0,
		incomeLevel = 0,
		plotId = 0,
		lockUntil = 0,
		lockCooldownUntil = 0,
		owned = {},
	}
	State.players[player] = state
	return state
end

function State.get(player)
	return State.players[player]
end

function State.removePlayer(player)
	State.players[player] = nil
end

--- A player's income per second: every owned brainrot's rate times its
-- mutation multiplier, boosted by rebirths and the Income upgrade.
function State.recalcIncome(state)
	local base = 0
	for _, record in pairs(state.owned) do
		base = base + record.rate * record.mult
	end
	local upgradeDef = Config.UPGRADES.Income
	local incomeBoost = 1 + upgradeDef.bonusPerLevel * state.incomeLevel
	local rebirthBoost = 1 + Config.REBIRTH_BONUS * state.rebirths
	return math.floor(base * incomeBoost * rebirthBoost)
end

--- The walk speed a player should have right now.
function State.walkSpeed(state, carrying)
	if carrying then
		return Config.STEAL_SLOW_SPEED
	end
	local upgradeDef = Config.UPGRADES.Speed
	return Config.BASE_WALK_SPEED + upgradeDef.bonusPerLevel * state.speedLevel
end

--- Apply the state's walk speed to the player's humanoid, if it exists.
function State.applyWalkSpeed(state, carrying)
	local character = state.player.Character
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		humanoid.WalkSpeed = State.walkSpeed(state, carrying)
	end
end

return State
