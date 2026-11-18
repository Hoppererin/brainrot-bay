-- Brainrot Bay — the tsunami event.
-- Every TSUNAMI_INTERVAL seconds a wave sweeps the island. A warning banner
-- goes out first; then the wave crosses the map from north to south, and
-- any player caught outside a safe zone (spawn plaza or their own plot) is
-- splashed back to spawn and stunned for TSUNAMI_STUN seconds.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)

local Events = {}

--- Is a player standing somewhere safe from the wave?
local function isSafe(player)
	local character = player.Character
	if character == nil then
		return true
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart == nil then
		return true
	end
	local pos = rootPart.Position
	if (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(Config.SPAWN_CENTER.X, 0, Config.SPAWN_CENTER.Z)).Magnitude <= Config.SPAWN_SAFE_RADIUS then
		return true
	end
	local state = State.get(player)
	if state ~= nil and state.plotId ~= 0 then
		local plotInfo = Plots.get(state.plotId)
		if plotInfo ~= nil and (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(plotInfo.center.X, 0, plotInfo.center.Z)).Magnitude <= 18 then
			return true
		end
	end
	return false
end

--- Splash one player: back to spawn, stunned briefly.
local function splash(player)
	local state = State.get(player)
	local character = player.Character
	if character == nil then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart ~= nil then
		rootPart.CFrame = CFrame.new(Config.SPAWN_POSITION)
	end
	if state ~= nil then
		State.applyWalkSpeed(state, false)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid ~= nil then
			humanoid.WalkSpeed = 0
			task.delay(Config.TSUNAMI_STUN, function()
				if state.player.Parent ~= nil then
					State.applyWalkSpeed(state, false)
				end
			end)
		end
	end
end

--- Run one tsunami: warn, then sweep the wave across the island.
local function runTsunami(remotes, wave)
	local banner = remotes:FindFirstChild("HudBanner")
	if banner ~= nil then
		banner:FireAllClients(string.format("TSUNAMI IN %d SECONDS! Get to spawn or your base!", Config.TSUNAMI_WARNING))
	end
	task.wait(Config.TSUNAMI_WARNING)
	if banner ~= nil then
		banner:FireAllClients("TSUNAMI! Hold on!")
	end
	wave.Parent = workspace
	local startZ = -110
	local endZ = 110
	local duration = 8
	local steps = 40
	for step = 1, steps do
		local z = startZ + (endZ - startZ) * (step / steps)
		wave.CFrame = CFrame.new(0, 4, z)
		for player, _ in pairs(State.players) do
			local character = player.Character
			if character ~= nil then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				if rootPart ~= nil and math.abs(rootPart.Position.Z - z) < 12 and not isSafe(player) then
					splash(player)
				end
			end
		end
		task.wait(duration / steps)
	end
	wave.Parent = nil
	if banner ~= nil then
		banner:FireAllClients("")
	end
end

--- Start the tsunami timer.
function Events.start(remotes)
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(240, 12, 20)
	wave.Color = Color3.fromRGB(40, 120, 220)
	wave.Material = Enum.Material.Neon
	wave.Anchored = true
	wave.CanCollide = false
	wave.Transparency = 0.25

	task.spawn(function()
		while true do
			task.wait(Config.TSUNAMI_INTERVAL)
			runTsunami(remotes, wave)
		end
	end)
end

return Events
