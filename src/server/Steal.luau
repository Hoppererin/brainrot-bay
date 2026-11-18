-- Brainrot Bay — stealing.
-- Click another player's brainrot to carry it home: you walk slower, you
-- have STEAL_TIME seconds to reach your own plot, and the owner can yank
-- it back by coming within STEAL_YANK_RANGE studs. A locked base cannot
-- be stolen from at all.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)
local Economy = require(script.Parent.Economy)

local Steal = {}
Steal.active = {}

--- Start carrying a brainrot home. `record` is the victim's owned record.
function Steal.startSteal(remotes, thief, record)
	local victim = record.owner
	local victimState = State.get(victim)
	local thiefState = State.get(thief)
	if victimState == nil or thiefState == nil then
		return
	end
	if Steal.active[record.id] ~= nil then
		return
	end
	if os.clock() < victimState.lockUntil then
		Economy.notify(remotes, thief, "That base is locked!")
		return
	end
	if thiefState.plotId == 0 then
		Economy.notify(remotes, thief, "You have no base to steal to!")
		return
	end
	local taken = {}
	for _, owned in pairs(thiefState.owned) do
		if owned.plotId == thiefState.plotId then
			taken[owned.slotIndex] = true
		end
	end
	if Plots.freeSlot(taken) == 0 then
		Economy.notify(remotes, thief, "Your base is full — no room for a stolen brainrot!")
		return
	end

	victimState.owned[record.id] = nil
	Steal.active[record.id] = {
		record = record,
		thief = thief,
		victim = victim,
		deadline = os.clock() + Config.STEAL_TIME,
	}
	State.applyWalkSpeed(thiefState, true)
	Economy.notify(remotes, thief, string.format("Stealing %s! Get it to your base!", record.charName))
	Economy.notify(remotes, victim, string.format("%s is stealing your %s! Get close to yank it back!", thief.Name, record.charName))
end

--- The carried brainrot goes back to its owner's plot.
local function returnToOwner(remotes, steal)
	local record = steal.record
	local victimState = State.get(steal.victim)
	if victimState ~= nil then
		local taken = {}
		for _, owned in pairs(victimState.owned) do
			if owned.plotId == record.plotId then
				taken[owned.slotIndex] = true
			end
		end
		local slotIndex = Plots.freeSlot(taken)
		if slotIndex ~= 0 then
			record.slotIndex = slotIndex
			victimState.owned[record.id] = record
			local ground = Plots.slotPosition(record.plotId, record.slotIndex)
			local size = record.model:GetAttribute("Size")
			record.model:PivotTo(CFrame.new(ground.X, ground.Y + size / 2, ground.Z))
		else
			record.model:Destroy()
		end
	end
	local thiefState = State.get(steal.thief)
	if thiefState ~= nil then
		State.applyWalkSpeed(thiefState, false)
	end
	Steal.active[record.id] = nil
end

--- One step of the steal loop: carry the model, check the yank, the
-- deadline and the arrival home.
function Steal.step(remotes)
	for id, steal in pairs(Steal.active) do
		local record = steal.record
		local thiefState = State.get(steal.thief)
		local thiefCharacter = steal.thief.Character
		local rootPart = nil
		if thiefCharacter ~= nil then
			rootPart = thiefCharacter:FindFirstChild("HumanoidRootPart")
		end
		if thiefState == nil or rootPart == nil then
			returnToOwner(remotes, steal)
		else
			-- Carry it just in front of the thief.
			record.model:PivotTo(rootPart.CFrame * CFrame.new(0, 0, -3))
			local victimCharacter = steal.victim.Character
			local victimRoot = nil
			if victimCharacter ~= nil then
				victimRoot = victimCharacter:FindFirstChild("HumanoidRootPart")
			end
			if victimRoot ~= nil and (victimRoot.Position - rootPart.Position).Magnitude <= Config.STEAL_YANK_RANGE then
				Economy.notify(remotes, steal.thief, "Yanked back! The owner caught you.")
				Economy.notify(remotes, steal.victim, string.format("You yanked %s back!", record.charName))
				returnToOwner(remotes, steal)
			elseif os.clock() >= steal.deadline then
				Economy.notify(remotes, steal.thief, "Too slow! The brainrot ran home.")
				returnToOwner(remotes, steal)
			else
				local plotInfo = Plots.get(thiefState.plotId)
				if plotInfo ~= nil and (rootPart.Position - plotInfo.center).Magnitude <= 18 then
					-- Home! It is yours now.
					local taken = {}
					for _, owned in pairs(thiefState.owned) do
						if owned.plotId == thiefState.plotId then
							taken[owned.slotIndex] = true
						end
					end
					local slotIndex = Plots.freeSlot(taken)
					if slotIndex == 0 then
						returnToOwner(remotes, steal)
					else
						Steal.active[id] = nil
						record.owner = steal.thief
						record.plotId = thiefState.plotId
						record.slotIndex = slotIndex
						thiefState.owned[record.id] = record
						local ground = Plots.slotPosition(record.plotId, record.slotIndex)
						local size = record.model:GetAttribute("Size")
						record.model:PivotTo(CFrame.new(ground.X, ground.Y + size / 2, ground.Z))
						State.applyWalkSpeed(thiefState, false)
						Economy.notify(remotes, steal.thief, string.format("Stole %s! Nice one!", record.charName))
						Economy.notify(remotes, steal.victim, string.format("%s stole your %s!", steal.thief.Name, record.charName))
						Economy.pushState(remotes, steal.thief)
						Economy.pushState(remotes, steal.victim)
					end
				end
			end
		end
	end
end

--- Start the steal loop.
function Steal.start(remotes)
	game:GetService("RunService").Heartbeat:Connect(function()
		Steal.step(remotes)
	end)
end

return Steal
