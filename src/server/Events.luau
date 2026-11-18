-- Events.luau
-- Timed events for Brainrot Bay (build4, written from scratch).
-- A tsunami sweeps the island every 3 minutes: 10 seconds of warning,
-- then a wave rolls south. Players caught outside a safe zone (their own
-- plot, or the spawn plaza) are splashed back to spawn and stunned 2s.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)

local Events = {}

local remotes = nil
local waveRunning = false

local function getRemotes()
	if remotes == nil then
		remotes = ReplicatedStorage:WaitForChild("Remotes")
	end
	return remotes
end

local function broadcastBanner(text, seconds)
	getRemotes().EventBanner:FireAllClients(text, seconds)
end

-- True when the player stands somewhere the wave cannot reach.
local function isSafe(player)
	local character = player.Character
	if character == nil then
		return true
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return true
	end
	local pos = root.Position
	if (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(Config.SPAWN_CENTER.X, 0, Config.SPAWN_CENTER.Z)).Magnitude <= Config.SPAWN_SAFE_RADIUS then
		return true
	end
	local plotId = Plots.plotOf(player)
	if plotId ~= 0 then
		local plot = Plots.get(plotId)
		if plot ~= nil and math.abs(pos.X - plot.center.X) <= 13 and math.abs(pos.Z - plot.center.Z) <= 11 then
			return true
		end
	end
	return false
end

local function splash(player)
	local character = player.Character
	if character == nil then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if root == nil or humanoid == nil then
		return
	end
	root.CFrame = CFrame.new(Config.SPAWN_CENTER + Vector3.new(0, 3, 0))
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	getRemotes().Notify:FireClient(player, "The tsunami splashed you back to spawn!")
	task.delay(Config.TSUNAMI_STUN, function()
		local still = player.Character
		if still == nil then
			return
		end
		local stillHumanoid = still:FindFirstChildOfClass("Humanoid")
		if stillHumanoid ~= nil then
			stillHumanoid.WalkSpeed = State.walkSpeed(player)
			stillHumanoid.JumpPower = 50
		end
	end)
end

function Events.runTsunami()
	if waveRunning then
		return
	end
	waveRunning = true
	broadcastBanner("TSUNAMI INCOMING! Get to your base or spawn!", Config.TSUNAMI_WARNING)
	task.wait(Config.TSUNAMI_WARNING)
	broadcastBanner("TSUNAMI!", 6)

	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(230, 18, 12)
	wave.Color = Color3.fromRGB(40, 120, 220)
	wave.Material = Enum.Material.SmoothPlastic
	wave.Transparency = 0.3
	wave.Anchored = true
	wave.CanCollide = false
	wave.Parent = workspace

	local splashed = {}
	local z = -115
	while z <= 115 do
		wave.Position = Vector3.new(0, 6, z)
		for player, _ in pairs(State.allPlayers()) do
			if splashed[player] == nil and not isSafe(player) then
				local character = player.Character
				local root = nil
				if character ~= nil then
					root = character:FindFirstChild("HumanoidRootPart")
				end
				if root ~= nil and math.abs(root.Position.Z - z) < 8 then
					splashed[player] = true
					splash(player)
				end
			end
		end
		z += 6
		task.wait(0.06)
	end
	wave:Destroy()
	waveRunning = false
end

-- The tour (TOUR.json) calls this to show the tsunami on demand.
function Events.trigger(kind)
	if kind == "tsunami" then
		task.spawn(Events.runTsunami)
	end
end

function Events.start()
	task.spawn(function()
		while true do
			task.wait(Config.TSUNAMI_INTERVAL)
			Events.runTsunami()
		end
	end)
end

return Events
