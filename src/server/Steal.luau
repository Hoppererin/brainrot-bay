-- Brainrot Bay — stealing.
-- Click a brainrot on another player's base to carry it home: you have 20
-- seconds at reduced speed, and its owner can yank it back by clicking it
-- while you are within 40 studs. A locked base cannot be stolen from at
-- all. Carrying is a follow loop, not a weld: the model rides above your
-- head until you reach your own plot or the timer runs out.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)

local Steal = {}

-- Plants a brainrot on a slot at once (used when a steal lands or is
-- yanked back): state, owner, slot bookkeeping and model position.
local function placeOnSlot(record: State.BrainrotRecord, player: Player, plot: Plots.Plot, slotIndex: number)
	record.state = "owned"
	record.owner = player
	record.plotId = plot.id
	record.slotIndex = slotIndex
	record.carrier = nil
	plot.taken[slotIndex] = record.id
	local target = Plots.slotPosition(plot, slotIndex)
	local height = 2.4 * record.character.scale
	record.model:PivotTo(CFrame.new(target.X, target.Y + height / 2, target.Z))
end

local function restoreWalkSpeed(player: Player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		humanoid.WalkSpeed = State.walkSpeed(state)
	end
end

local function freeCarrier(player: Player)
	local state = State.get(player)
	if state ~= nil then
		state.carrying = nil
	end
	restoreWalkSpeed(player)
end

-- Starts a steal: lifts the brainrot off its owner's base and rides it
-- above the thief's head. The run ends when the thief reaches their own
-- plot (kept), the 20 seconds run out (sent back), or the owner yanks it.
function Steal.trySteal(player: Player, record: State.BrainrotRecord)
	local state = State.get(player)
	if state == nil or record.owner == player or record.state ~= "owned" then
		return
	end
	if state.carrying ~= nil then
		return
	end
	local ownerState = nil
	if record.owner ~= nil then
		ownerState = State.get(record.owner)
	end
	if ownerState ~= nil and State.isLocked(ownerState) then
		return
	end
	local homePlot = Plots.plotOf(player)
	if homePlot == nil then
		return
	end
	local oldPlot = Plots.get(record.plotId or 0)
	if oldPlot ~= nil and record.slotIndex ~= nil then
		oldPlot.taken[record.slotIndex] = nil
	end
	if ownerState ~= nil then
		ownerState.owned[record.id] = nil
	end

	record.state = "carried"
	record.carrier = player
	record.plotId = nil
	record.slotIndex = nil
	state.carrying = record.id
	restoreWalkSpeed(player)

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		humanoid.WalkSpeed = State.walkSpeed(state)
	end

	task.spawn(function()
		local deadline = os.clock() + Config.STEAL_TIME
		while record.state == "carried" and record.model.Parent do
			local carrierCharacter = player.Character
			local rootPart = carrierCharacter and carrierCharacter:FindFirstChild("HumanoidRootPart")
			if rootPart == nil then
				break
			end
			record.model:PivotTo((rootPart :: BasePart).CFrame * CFrame.new(0, 3.5, 0))
			local distance = (rootPart.Position - homePlot.center).Magnitude
			if distance < Config.STEAL_HOME_RANGE then
				local slotIndex = Plots.freeSlot(homePlot)
				if slotIndex ~= nil then
					placeOnSlot(record, player, homePlot, slotIndex)
					state.owned[record.id] = true
					freeCarrier(player)
					return
				end
			end
			if os.clock() >= deadline then
				break
			end
			task.wait(0.05)
		end
		-- The run failed or the carrier left: send it back to its owner.
		if record.state == "carried" then
			freeCarrier(player)
			local owner = record.owner
			if owner ~= nil then
				local ownerPlot = Plots.plotOf(owner)
				local ownerStateNow = State.get(owner)
				if ownerPlot ~= nil and ownerStateNow ~= nil then
					local slotIndex = Plots.freeSlot(ownerPlot)
					if slotIndex ~= nil then
						placeOnSlot(record, owner, ownerPlot, slotIndex)
						ownerStateNow.owned[record.id] = true
						return
					end
				end
			end
			record.state = "gone"
			State.removeRecord(record.id)
			record.model:Destroy()
		end
	end)
end

-- The owner clicks their own carried brainrot while the thief is close:
-- it snaps back to the owner's base and the thief walks away empty-handed.
function Steal.tryYankBack(player: Player, record: State.BrainrotRecord)
	if record.state ~= "carried" or record.owner ~= player then
		return
	end
	local carrier = record.carrier
	if carrier == nil then
		return
	end
	local ownerCharacter = player.Character
	local ownerRoot = ownerCharacter and ownerCharacter:FindFirstChild("HumanoidRootPart")
	local carrierCharacter = carrier.Character
	local carrierRoot = carrierCharacter and carrierCharacter:FindFirstChild("HumanoidRootPart")
	if ownerRoot == nil or carrierRoot == nil then
		return
	end
	if (ownerRoot.Position - carrierRoot.Position).Magnitude > Config.YANK_RANGE then
		return
	end
	freeCarrier(carrier)
	local ownerPlot = Plots.plotOf(player)
	local ownerState = State.get(player)
	if ownerPlot == nil or ownerState == nil then
		return
	end
	local slotIndex = Plots.freeSlot(ownerPlot)
	if slotIndex == nil then
		return
	end
	placeOnSlot(record, player, ownerPlot, slotIndex)
	ownerState.owned[record.id] = true
end

return Steal
