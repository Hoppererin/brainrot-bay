-- init.server.luau
-- Server entrypoint for Brainrot Bay (build4, written from scratch).
-- Builds the world, starts the conveyor, the tsunami clock and the income
-- tick, claims a plot for every player who joins, and wires the remotes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)
local Conveyor = require(script.Parent.Conveyor)
local Economy = require(script.Parent.Economy)
local Steal = require(script.Parent.Steal)
local Events = require(script.Parent.Events)
local WorldBuilder = require(script.Parent.WorldBuilder)

local remotes = ReplicatedStorage:WaitForChild("Remotes")

-- World first: if this errors, nothing below runs, so it must be clean.
WorldBuilder.build()
Conveyor.start(Economy.handleClick)
Steal.start()
Events.start()
task.spawn(Economy.tickLoop)

local function setupPlayer(player)
	local state = State.newPlayer(player)
	local plotId = Plots.claim(player)
	state.plotId = plotId

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = state.cash
	cash.Parent = leaderstats
	local income = Instance.new("IntValue")
	income.Name = "Income"
	income.Value = state.income
	income.Parent = leaderstats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = state.rebirths
	rebirths.Parent = leaderstats

	local function syncStats()
		cash.Value = state.cash
		income.Value = state.income
		rebirths.Value = state.rebirths
	end
	task.spawn(function()
		while player.Parent ~= nil do
			task.wait(1)
			syncStats()
		end
	end)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = State.walkSpeed(player)
		humanoid.Died:Connect(function()
			Steal.dropCarry(player)
		end)
	end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
	Steal.dropCarry(player)
	local state = State.get(player)
	if state ~= nil then
		for recordId, record in pairs(state.owned) do
			if record.model ~= nil then
				record.model:Destroy()
			end
			State.removeRecord(recordId)
		end
	end
	Plots.release(player)
	State.remove(player)
end)

remotes.LockBase.OnServerEvent:Connect(function(player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local now = os.time()
	if now < state.lockCooldownUntil then
		Economy.notify(player, "Lock is cooling down for " .. tostring(state.lockCooldownUntil - now) .. "s.")
		return
	end
	state.lockUntil = now + Config.LOCK_DURATION
	state.lockCooldownUntil = now + Config.LOCK_COOLDOWN
	Economy.notify(player, "Base locked for " .. tostring(Config.LOCK_DURATION) .. " seconds!")
end)

remotes.Rebirth.OnServerEvent:Connect(function(player)
	Economy.rebirth(player)
end)

remotes.BuyUpgrade.OnServerEvent:Connect(function(player, kind)
	if kind == "Speed" or kind == "Income" then
		Economy.buyUpgrade(player, kind)
	end
end)
