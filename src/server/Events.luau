-- Brainrot Bay — the tsunami event.
-- Every three minutes the sea answers: ten seconds of warning on the
-- banner, then a wall of water sweeps the island west to east. A player
-- caught in the open is splashed back to the spawn plaza and stunned for
-- two seconds. Bases and the spawn plaza are safe ground, so a player
-- holding a catch has somewhere to run to.
--
-- trigger(kind) is the public handle the TOUR.json calls: reviewers can
-- bring the wave on demand with the "tsunami" argument.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)

local Events = {}

local wave: Part? = nil

-- Builds the wave wall once: a tall translucent slab waiting offstage.
local function buildWave()
	local part = Instance.new("Part")
	part.Name = "TsunamiWave"
	part.Size = Vector3.new(8, 26, 240)
	part.Color = Color3.fromRGB(40, 140, 255)
	part.Material = Enum.Material.Glass
	part.Transparency = 0.35
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(-160, 12, 0)
	part.Parent = workspace
	return part
end

-- Safe ground: your own plot's pad, or the spawn plaza.
local function isSafe(player: Player): boolean
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if rootPart == nil then
		return true
	end
	local position = (rootPart :: BasePart).Position
	if (Vector3.new(position.X, 0, position.Z) - Config.SPAWN_CENTER).Magnitude < Config.SPAWN_SAFE_RADIUS then
		return true
	end
	local plot = Plots.plotOf(player)
	if plot ~= nil and Plots.isOnPlot(plot, position) then
		return true
	end
	return false
end

-- Splashes a caught player back to the spawn plaza and stuns them.
local function splash(player: Player)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if rootPart == nil or humanoid == nil then
		return
	end
	local root = rootPart :: BasePart
	root.CFrame = CFrame.new(Config.SPAWN_CENTER.X, 5, Config.SPAWN_CENTER.Z)
	humanoid.WalkSpeed = 0
	task.delay(Config.TSUNAMI_STUN, function()
		local state = State.get(player)
		if state ~= nil and character.Parent ~= nil then
			local fresh = character:FindFirstChildOfClass("Humanoid")
			if fresh ~= nil then
				fresh.WalkSpeed = State.walkSpeed(state)
			end
		end
	end)
end

-- One wave: warn, sweep, splash whoever the water catches, park offstage.
local function runTsunami()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	if wave == nil then
		wave = buildWave()
	end
	remotes.EventBanner:FireAllClients("🌊 TSUNAMI INCOMING! Run to your base!", Config.TSUNAMI_WARNING)
	task.wait(Config.TSUNAMI_WARNING)
	remotes.EventBanner:FireAllClients("🌊 TSUNAMI!", 6)

	local splashed = {}
	local startX = -160
	local endX = 160
	local steps = 80
	local wavePart = wave :: Part
	for step = 1, steps do
		local alpha = step / steps
		local x = startX + (endX - startX) * alpha
		wavePart.CFrame = CFrame.new(x, 12, 0)
		for _, player in ipairs(Players:GetPlayers()) do
			if splashed[player] == nil and not isSafe(player) then
				local character = player.Character
				local rootPart = character and character:FindFirstChild("HumanoidRootPart")
				if rootPart ~= nil and math.abs((rootPart :: BasePart).Position.X - x) < 6 then
					splashed[player] = true
					splash(player)
				end
			end
		end
		task.wait(0.1)
	end
	wavePart.CFrame = CFrame.new(-160, 12, 0)
end

-- The public handle: "tsunami" brings a wave now (TOUR.json uses it).
function Events.trigger(kind: string)
	if kind == "tsunami" then
		task.spawn(runTsunami)
	end
end

-- The event loop: a wave every three minutes, forever.
function Events.start()
	task.spawn(function()
		while true do
			task.wait(Config.TSUNAMI_INTERVAL)
			runTsunami()
		end
	end)
end

return Events
