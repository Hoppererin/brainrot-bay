-- Steal.luau
-- Stealing for Brainrot Bay (build4, written from scratch).
-- Click another player's brainrot to carry it home: 20 seconds at reduced
-- speed. The owner can yank it back by clicking it within 40 studs.
-- A locked base cannot be stolen from. The thief must reach their own plot.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)

local Steal = {}

local carries = {} -- [recordId] = { record, carrier, deadline }
local remotes = nil

local function getRemotes()
	if remotes == nil then
		remotes = ReplicatedStorage:WaitForChild("Remotes")
	end
	return remotes
end

local function notify(player, text)
	getRemotes().Notify:FireClient(player, text)
end

local function setCarrySpeed(player, carrying)
	local character = player.Character
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	if carrying then
		humanoid.WalkSpeed = State.walkSpeed(player) * Config.STEAL_SLOW_MULT
	else
		humanoid.WalkSpeed = State.walkSpeed(player)
	end
end

-- Put a brainrot back on its slot in its owner's plot.
local function returnHome(record)
	local plot = Plots.get(record.plotId)
	if plot == nil or record.model == nil then
		return
	end
	local target = Plots.slotPosition(plot, record.slot)
	local scale = record.model:GetAttribute("Scale")
	if scale == nil then
		scale = 1
	end
	record.model:PivotTo(CFrame.new(target + Vector3.new(0, 1 + scale, 0)))
	record.carried = false
end

local function endCarry(recordId, stolen)
	local carry = carries[recordId]
	if carry == nil then
		return
	end
	carries[recordId] = nil
	local record = carry.record
	local thief = carry.carrier
	local thiefState = State.get(thief)
	if thiefState ~= nil then
		thiefState.carrying = nil
	end
	setCarrySpeed(thief, false)
	if stolen then
		return
	end
	returnHome(record)
end

local function completeSteal(carry)
	local record = carry.record
	local thief = carry.carrier
	local thiefState = State.get(thief)
	local oldOwner = record.owner
	if thiefState == nil or oldOwner == nil then
		endCarry(record.id, false)
		return
	end
	local slot = Plots.freeSlot(thief, thiefState.owned)
	if slot == 0 then
		notify(thief, "Your base is full! The brainrot escaped back.")
		endCarry(record.id, false)
		return
	end
	local oldState = State.get(oldOwner)
	if oldState ~= nil then
		oldState.owned[record.id] = nil
		State.recalcIncome(oldOwner)
	end
	record.owner = thief
	record.plotId = Plots.plotOf(thief)
	record.slot = slot
	record.carried = false
	thiefState.owned[record.id] = record
	State.recalcIncome(thief)
	carries[record.id] = nil
	thiefState.carrying = nil
	setCarrySpeed(thief, false)
	local plot = Plots.get(record.plotId)
	if plot ~= nil and record.model ~= nil then
		local target = Plots.slotPosition(plot, slot)
		local scale = record.model:GetAttribute("Scale")
		if scale == nil then
			scale = 1
		end
		record.model:PivotTo(CFrame.new(target + Vector3.new(0, 1 + scale, 0)))
	end
	notify(thief, "Stole " .. record.charName .. "!")
	if oldOwner ~= nil then
		notify(oldOwner, thief.Name .. " stole your " .. record.charName .. "!")
	end
end

local function carrierInOwnPlot(player)
	local character = player.Character
	if character == nil then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false
	end
	local plotId = Plots.plotOf(player)
	if plotId == 0 then
		return false
	end
	local plot = Plots.get(plotId)
	if plot == nil then
		return false
	end
	local pos = root.Position
	return math.abs(pos.X - plot.center.X) <= 13 and math.abs(pos.Z - plot.center.Z) <= 11
end

local function stepCarries()
	local now = os.time()
	for recordId, carry in pairs(carries) do
		local record = carry.record
		local thief = carry.carrier
		local character = thief.Character
		local root = nil
		if character ~= nil then
			root = character:FindFirstChild("HumanoidRootPart")
		end
		if root == nil or record.model == nil then
			endCarry(recordId, false)
		elseif now >= carry.deadline then
			notify(thief, "Too slow! " .. record.charName .. " ran back home.")
			endCarry(recordId, false)
		elseif carrierInOwnPlot(thief) then
			completeSteal(carry)
		else
			record.model:PivotTo(CFrame.new(root.Position + Vector3.new(0, 3, 0)))
		end
	end
end

-- Start a steal: click someone else's brainrot while it sits in their base.
function Steal.trySteal(player, record)
	local thiefState = State.get(player)
	if thiefState == nil then
		return
	end
	if record.owner == nil or record.owner == player then
		return
	end
	if record.carried then
		return
	end
	if thiefState.carrying ~= nil then
		notify(player, "You are already carrying a brainrot!")
		return
	end
	local ownerState = State.get(record.owner)
	if ownerState ~= nil and ownerState.lockUntil > os.time() then
		notify(player, "That base is locked!")
		return
	end
	if Plots.freeSlot(player, thiefState.owned) == 0 then
		notify(player, "Your base is full! Make room first.")
		return
	end
	record.carried = true
	thiefState.carrying = record.id
	carries[record.id] = {
		record = record,
		carrier = player,
		deadline = os.time() + Config.STEAL_TIME,
	}
	setCarrySpeed(player, true)
	notify(player, "Run home! You have " .. tostring(Config.STEAL_TIME) .. " seconds.")
end

-- The owner clicks their own carried brainrot within 40 studs: yank it back.
function Steal.yank(player, record)
	local carry = carries[record.id]
	if carry == nil then
		return
	end
	local ownerRoot = nil
	local ownerChar = player.Character
	if ownerChar ~= nil then
		ownerRoot = ownerChar:FindFirstChild("HumanoidRootPart")
	end
	if ownerRoot == nil or record.model == nil then
		return
	end
	local distance = (ownerRoot.Position - record.model:GetPivot().Position).Magnitude
	if distance > Config.STEAL_YANK_RADIUS then
		notify(player, "Too far away to yank it back!")
		return
	end
	local thief = carry.carrier
	notify(thief, "The owner yanked " .. record.charName .. " back!")
	notify(player, "You yanked " .. record.charName .. " back!")
	endCarry(record.id, false)
end

-- Drop whatever the player is carrying (death, leave, rebirth).
function Steal.dropCarry(player)
	local state = State.get(player)
	if state == nil or state.carrying == nil then
		return
	end
	endCarry(state.carrying, false)
end

function Steal.start()
	RunService.Heartbeat:Connect(stepCarries)
end

return Steal
