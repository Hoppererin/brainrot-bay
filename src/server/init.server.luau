-- Brainrot Bay — server entrypoint.
-- Builds the world, creates the RemoteEvents, wires players and starts every
-- system: conveyor, income ticks, stealing and the tsunami.
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

-- RemoteEvents, one folder in ReplicatedStorage.
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
for _, eventName in ipairs({ "HudUpdate", "HudNotify", "HudBanner", "LockRequest", "RebirthRequest", "UpgradeRequest" }) do
	local event = Instance.new("RemoteEvent")
	event.Name = eventName
	event.Parent = remotes
end

WorldBuilder.build()
local brainrotFolder = Instance.new("Folder")
brainrotFolder.Name = "Brainrots"
brainrotFolder.Parent = workspace

local function placeCharacter(state, character)
	task.spawn(function()
		local rootPart = character:WaitForChild("HumanoidRootPart", 10)
		if rootPart ~= nil then
			rootPart.CFrame = CFrame.new(Config.SPAWN_POSITION)
		end
		State.applyWalkSpeed(state, false)
	end)
end

local function onPlayerAdded(player)
	local state = State.newPlayer(player)
	state.plotId = Plots.claim(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Value = state.cash
	cashValue.Parent = leaderstats
	local incomeValue = Instance.new("IntValue")
	incomeValue.Name = "Income"
	incomeValue.Value = 0
	incomeValue.Parent = leaderstats
	local rebirthValue = Instance.new("IntValue")
	rebirthValue.Name = "Rebirths"
	rebirthValue.Value = 0
	rebirthValue.Parent = leaderstats

	player.CharacterAdded:Connect(function(character)
		placeCharacter(state, character)
	end)
	if player.Character ~= nil then
		placeCharacter(state, player.Character)
	end
	Economy.pushState(remotes, player)
end

local function onPlayerRemoving(player)
	local state = State.get(player)
	if state ~= nil then
		for _, record in pairs(state.owned) do
			record.model:Destroy()
		end
	end
	Plots.release(player)
	State.removePlayer(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

remotes.LockRequest.OnServerEvent:Connect(function(player)
	Economy.lockBase(remotes, player)
end)
remotes.RebirthRequest.OnServerEvent:Connect(function(player)
	Economy.rebirth(remotes, player)
end)
remotes.UpgradeRequest.OnServerEvent:Connect(function(player, kind)
	Economy.buyUpgrade(remotes, player, kind)
end)

Conveyor.start(function(player, brainrotId)
	Economy.handleClick(remotes, player, brainrotId)
end, brainrotFolder)
Steal.start(remotes)
Events.start(remotes)
Economy.tickLoop(remotes)
