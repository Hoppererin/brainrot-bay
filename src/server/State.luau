-- Brainrot Bay — the single state store.
-- Every player's money, levels and brainrots live here, and every brainrot
-- record is registered here too, so any module can find it by id without
-- requiring the module that spawned it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Catalog"))

local State = {}

local playerStates = {} -- [Player] = state
local records = {} -- [recordId] = brainrot record
local nextRecordId = 0

export type PlayerState = {
	player: Player,
	cash: number,
	rebirths: number,
	speedLevel: number,
	incomeLevel: number,
	owned: { [number]: boolean }, -- record ids on this player's base
	plotId: number?,
	lockUntil: number,
	lockCooldownUntil: number,
	carrying: number?, -- record id being carried after a steal
}

export type BrainrotRecord = {
	id: number,
	character: typeof(Catalog.CHARACTERS[1]),
	mutation: any,
	model: Model,
	state: string, -- "walking" | "owned" | "carried" | "gone"
	owner: Player?,
	plotId: number?,
	slotIndex: number?,
	carrier: Player?,
	progress: number,
}

-- A fresh player: starting cash, no rebirths, no upgrades, empty base.
function State.new(player: Player): PlayerState
	local state: PlayerState = {
		player = player,
		cash = Config.START_CASH,
		rebirths = 0,
		speedLevel = 0,
		incomeLevel = 0,
		owned = {},
		plotId = nil,
		lockUntil = 0,
		lockCooldownUntil = 0,
		carrying = nil,
	}
	playerStates[player] = state
	return state
end

function State.get(player: Player): PlayerState?
	return playerStates[player]
end

function State.remove(player: Player)
	playerStates[player] = nil
end

-- Registers a brainrot record and hands it its id.
function State.addRecord(record: BrainrotRecord): number
	nextRecordId += 1
	record.id = nextRecordId
	records[record.id] = record
	return record.id
end

function State.getRecord(id: number): BrainrotRecord?
	return records[id]
end

function State.removeRecord(id: number)
	records[id] = nil
end

-- The $/s a player earns right now: every owned brainrot's rate, with its
-- mutation, then the rebirth bonus and the income-upgrade bonus.
function State.getIncomePerSecond(state: PlayerState): number
	local total = 0
	for id in pairs(state.owned) do
		local record = records[id]
		if record ~= nil then
			total += Catalog.getEffectiveRate(record.character, record.mutation)
		end
	end
	total *= 1 + Config.REBIRTH_BONUS * state.rebirths
	total *= 1 + Config.UPGRADES.Income.bonusPerLevel * state.incomeLevel
	return total
end

-- A player's walk speed: base, plus Speed Boots, slowed while carrying.
function State.walkSpeed(state: PlayerState): number
	local speed = Config.BASE_WALKSPEED + Config.UPGRADES.Speed.bonusPerLevel * state.speedLevel
	if state.carrying ~= nil then
		speed *= Config.STEAL_SLOW
	end
	return speed
end

-- Whether a player's base lock is up right now.
function State.isLocked(state: PlayerState): boolean
	return os.clock() < state.lockUntil
end

return State
