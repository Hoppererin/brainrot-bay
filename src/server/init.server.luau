-- Brainrot Bay — server entrypoint.
-- Wires the modules together: a joining player gets state, a plot and
-- leaderstats; a leaving player frees their plot and drops whatever they
-- were carrying; the client talks to the server only through the three
-- request remotes, and the server validates every one of them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)
local Economy = require(script.Parent.Economy)
local Conveyor = require(script.Parent.Conveyor)
local Events = require(script.Parent.Events)
local WorldBuilder = require(script.Parent.WorldBuilder)

local remotes = ReplicatedStorage:WaitForChild("Remotes")

-- A joining player: fresh state, the first free plot, leaderstats, spawn
-- speed set, and a first HUD push so the bar is never empty.
local function onPlayerAdded(player: Player)
	local state = State.new(player)
	Plots.assign(player)
	Economy.setupPlayer(player)
	player.CharacterAdded:Connect(function(character: Model)
		local humanoid = character:WaitForChild("Humanoid")
		;(humanoid :: Humanoid).WalkSpeed = State.walkSpeed(state)
	end)
	-- The spawn point sits on the spawn plaza (see the SpawnLocation).
	task.spawn(function()
		task.wait(1)
		Economy.pushHud(player)
	end)
end

-- A leaving player: their plot frees up, their state goes, and a
-- brainrot they were carrying walks back to its owner's base.
local function onPlayerRemoving(player: Player)
	local state = State.get(player)
	if state ~= nil and state.carrying ~= nil then
		local record = State.getRecord(state.carrying)
		if record ~= nil and record.state == "carried" then
			local owner = record.owner
			if owner ~= nil then
				local ownerPlot = Plots.plotOf(owner)
				local ownerState = State.get(owner)
				if ownerPlot ~= nil and ownerState ~= nil then
					local slotIndex = Plots.freeSlot(ownerPlot)
					if slotIndex ~= nil then
						record.state = "owned"
						record.owner = owner
						record.plotId = ownerPlot.id
						record.slotIndex = slotIndex
						record.carrier = nil
						ownerPlot.taken[slotIndex] = record.id
						ownerState.owned[record.id] = true
						local target = Plots.slotPosition(ownerPlot, slotIndex)
						record.model:PivotTo(CFrame.new(target.X, target.Y + 1.2, target.Z))
					end
				end
			end
		end
	end
	Plots.free(player)
	State.remove(player)
end

-- The client's three requests. Each one names a player the server checks
-- and a validated action; the client never touches money or state itself.
remotes.LockBase.OnServerEvent:Connect(function(player: Player)
	Economy.lockBase(player)
end)

remotes.Rebirth.OnServerEvent:Connect(function(player: Player)
	Economy.tryRebirth(player)
end)

remotes.BuyUpgrade.OnServerEvent:Connect(function(player: Player, kind: string)
	Economy.buyUpgrade(player, kind)
end)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Plots first: a player joining in the same frame as the server starts
-- still needs a plot to be assigned to.
Plots.init()
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

WorldBuilder.build()
Conveyor.start()
Economy.startIncomeLoop()
Events.start()
