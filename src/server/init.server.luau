-- Brainrot Bay: server boot.
-- Wires every service together, hands out plots and leaderstats as players
-- join, and starts the conveyor, the income tick and the tsunami.
-- One script, one job: start the game.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Conveyor = require(script.Conveyor)
local Economy = require(script.Economy)
local Events = require(script.Events)
local Plots = require(script.Plots)
local State = require(script.State)
local Steal = require(script.Steal)
local WorldBuilder = require(script.WorldBuilder)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Services hand each other the remotes and each other at boot, so no module
-- has to require a sibling that is still loading.
Economy.init(Remotes, Conveyor)
Steal.init(Remotes, Economy, Conveyor)
Conveyor.init(Remotes, Economy)
Events.init(Remotes, Economy)

Plots.build()
WorldBuilder.build(Plots.List)

-- Best-effort saving: in Studio without API access this just stays in memory.
local store = nil
pcall(function()
	store = DataStoreService:GetDataStore("BrainrotBayV1")
end)

local function loadPlayer(player: Player)
	local state = State.new(player)
	if store then
		pcall(function()
			local saved = store:GetAsync("player_" .. tostring(player.UserId))
			if saved and type(saved) == "table" then
				state.cash = saved.cash or state.cash
				state.rebirths = saved.rebirths or 0
				if saved.upgrades then
					state.upgrades.Speed = saved.upgrades.Speed or 0
					state.upgrades.Income = saved.upgrades.Income or 0
				end
			end
		end)
	end
	local plot = Plots.claimFor(player)
	state.plotId = plot and plot.id or nil

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = math.floor(state.cash)
	cash.Parent = leaderstats
	local income = Instance.new("IntValue")
	income.Name = "Income"
	income.Value = 0
	income.Parent = leaderstats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = state.rebirths
	rebirths.Parent = leaderstats

	Economy.applyWalkSpeed(player)
	Remotes.Notify:FireClient(player, "Welcome to Brainrot Bay! Buy brainrots off the belt, base them, get rich!")
end

local function savePlayer(player: Player)
	local state = State.get(player)
	if not state or not store then
		return
	end
	pcall(function()
		store:SetAsync("player_" .. tostring(player.UserId), {
			cash = math.floor(state.cash),
			rebirths = state.rebirths,
			upgrades = state.upgrades,
		})
	end)
end

local function onPlayerAdded(player: Player)
	loadPlayer(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		Economy.applyWalkSpeed(player)
	end)
end

local function onPlayerRemoving(player: Player)
	local state = State.get(player)
	if state then
		-- Owned brainrots leave with their owner.
		for id in pairs(state.owned) do
			Conveyor.remove(state.owned[id])
		end
		if state.carrying then
			local record = Conveyor.Walking[state.carrying]
			if record then
				Steal.dropCarried(player, record, "The carrier left!")
			end
		end
	end
	savePlayer(player)
	Plots.release(player)
	State.remove(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Client requests: every one is validated again on the server.
-- The client only ever asks; a forged RemoteEvent call buys nothing.
Remotes.LockBase.OnServerEvent:Connect(function(player: Player)
	Steal.tryLock(player)
end)
Remotes.Rebirth.OnServerEvent:Connect(function(player: Player)
	Economy.tryRebirth(player)
end)
Remotes.BuyUpgrade.OnServerEvent:Connect(function(player: Player, kind: string)
	Economy.tryUpgrade(player, kind)
end)

Conveyor.start()
Economy.start()
Events.start()

print("Brainrot Bay is live: plots, conveyor, economy and tsunami running.")
