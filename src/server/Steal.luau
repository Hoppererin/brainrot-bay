-- Brainrot Bay: stealing.
-- Click a brainrot on someone else's base to grab it and carry it home:
-- you walk slower while carrying, the owner can yank it back with a click
-- while you are close, and a locked base cannot be stolen from at all.
-- The lock is the defence; the carry is the risk.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Plots = require(script.Parent.Plots)
local State = require(script.Parent.State)

local Steal = {}
local Conveyor = nil
local Economy = nil

function Steal.init(remotes, economy, conveyor)
	Economy = economy
	Conveyor = conveyor
end

local function distanceTo(player: Player, position: Vector3): number
	local character = player.Character
	if not character then
		return math.huge
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return math.huge
	end
	return (root.Position - position).Magnitude
end

-- Lock the player's own base: no stealing from it while the lock holds.
function Steal.tryLock(player: Player)
	local state = State.get(player)
	if not state then
		return
	end
	local now = os.clock()
	if now < state.lockCooldownUntil then
		local wait = math.floor(state.lockCooldownUntil - now)
		Economy.notify(player, "Lock recharging: " .. tostring(wait) .. "s left.")
		return
	end
	state.lockUntil = now + Config.LOCK_DURATION
	state.lockCooldownUntil = now + Config.LOCK_COOLDOWN
	Economy.notify(player, "Base LOCKED for " .. tostring(Config.LOCK_DURATION) .. "s!")
end

function Steal.trySteal(player: Player, record)
	local state = State.get(player)
	if not state or record.state ~= "owned" then
		return
	end
	local owner = record.owner
	if owner == player then
		-- Clicking your own brainrot offers to sell it instead.
		Economy.trySell(player, record.id)
		return
	end
	if state.carrying ~= nil then
		Economy.notify(player, "You are already carrying one! Bring it home first.")
		return
	end
	local ownerState = owner and State.get(owner)
	if ownerState and os.clock() < ownerState.lockUntil then
		Economy.notify(player, "That base is LOCKED. Wait for the lock to end!")
		return
	end
	local plot = Plots.getFor(player)
	if not plot then
		return
	end
	if Plots.getFreeSlot(plot) == nil then
		Economy.notify(player, "Your base is full! No room for a stolen brainrot.")
		return
	end
	-- Grab it: it leaves its slot and follows the thief.
	record.state = "carried"
	record.carriedBy = player
	record.carryDeadline = os.clock() + Config.CARRY_TIME_LIMIT
	if record.plotId then
		local ownerPlot = Plots.List[record.plotId]
		if ownerPlot and record.slotIndex then
			ownerPlot.taken[record.slotIndex] = nil
		end
		record.plotId = nil
		record.slotIndex = nil
	end
	state.carrying = record.id
	Economy.applyWalkSpeed(player)
	Economy.notify(player, "STOLEN! Run home in " .. tostring(Config.CARRY_TIME_LIMIT) .. "s — you are slow and the owner can yank it back!")
	if owner then
		Economy.notify(owner, player.DisplayName .. " stole your " .. record.spawn.character.name .. "! Click it to yank it back!")
	end
	-- The carry: the brainrot hovers above the thief until home, or the
	-- timer runs out and it walks back to its owner's plot. Checked every
	-- 0.1 s so a fast thief crossing the plot edge is caught at once.
	task.spawn(function()
		while record.state == "carried" and record.model.Parent do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then
				break
			end
			record.model:PivotTo(CFrame.new(root.Position + Vector3.new(0, 5, 0)))
			local ownPlot = Plots.getFor(player)
			if ownPlot and Plots.isInside(ownPlot, root.Position) then
				Steal.completeSteal(player, record)
				return
			end
			if os.clock() > record.carryDeadline then
				Steal.dropCarried(player, record, "Too slow! The brainrot ran home.")
				return
			end
			task.wait(0.1)
		end
	end)
end

-- The thief made it home: the brainrot is theirs now.
function Steal.completeSteal(player: Player, record)
	local state = State.get(player)
	if not state then
		return
	end
	local plot = Plots.getFor(player)
	local slotIndex = plot and Plots.getFreeSlot(plot)
	if not slotIndex then
		Steal.dropCarried(player, record, "No free slot at home!")
		return
	end
	local previousOwner = record.owner
	state.carrying = nil
	record.owner = player
	record.carriedBy = nil
	state.owned[record.id] = record
	Economy.applyWalkSpeed(player)
	Conveyor.sendToPlot(record, plot, slotIndex)
	Economy.notify(player, "You kept the stolen " .. record.spawn.character.name .. "!")
	if previousOwner and previousOwner ~= player then
		Economy.notify(previousOwner, "Your " .. record.spawn.character.name .. " was stolen for good!")
	end
	Economy.refreshLeaderstats(player)
end

-- The carry failed: the brainrot walks back to its owner's plot.
function Steal.dropCarried(player: Player, record, reason: string)
	local state = State.get(player)
	if state and state.carrying == record.id then
		state.carrying = nil
		Economy.applyWalkSpeed(player)
	end
	local owner = record.owner
	local ownerPlot = owner and Plots.getFor(owner)
	local slotIndex = ownerPlot and Plots.getFreeSlot(ownerPlot)
	if owner and ownerPlot and slotIndex then
		Conveyor.sendToPlot(record, ownerPlot, slotIndex)
		if State.get(owner) ~= nil then
			Economy.notify(owner, "Your " .. record.spawn.character.name .. " came back!")
		end
	else
		Conveyor.remove(record)
	end
	Economy.notify(player, reason)
end

-- The owner clicks a carried brainrot within range to yank it straight back.
function Steal.tryYankBack(player: Player, record)
	if record.state ~= "carried" then
		return
	end
	if record.owner ~= player then
		Economy.notify(player, "Only its owner can yank it back!")
		return
	end
	local state = State.get(player)
	if not state then
		return
	end
	if os.clock() < state.yankCooldownUntil then
		return
	end
	local carrier = record.carriedBy
	if not carrier then
		return
	end
	if distanceTo(player, record.model:GetPivot().Position) > Config.YANK_BACK_RANGE then
		Economy.notify(player, "Too far away to yank it back!")
		return
	end
	state.yankCooldownUntil = os.clock() + Config.YANK_BACK_COOLDOWN
	local carrierState = State.get(carrier)
	if carrierState and carrierState.carrying == record.id then
		carrierState.carrying = nil
		Economy.applyWalkSpeed(carrier)
	end
	Economy.notify(carrier, "YANKED BACK! " .. player.DisplayName .. " took their brainrot back.")
	local ownerPlot = Plots.getFor(player)
	local slotIndex = ownerPlot and Plots.getFreeSlot(ownerPlot)
	if ownerPlot and slotIndex then
		Conveyor.sendToPlot(record, ownerPlot, slotIndex)
	else
		Conveyor.remove(record)
	end
end

return Steal
