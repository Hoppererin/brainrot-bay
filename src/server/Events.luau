-- Brainrot Bay: the tsunami.
-- Every few minutes a giant wave sweeps the map from west to east. Anyone
-- caught outside their base or the spawn plaza gets splashed back to spawn
-- and stunned: the dash home with your catch is the game's heartbeat.
-- The wave is a plain part, so it needs no assets.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Plots = require(script.Parent.Plots)
local State = require(script.Parent.State)

local Events = {}
local Remotes = nil
local Economy = nil

function Events.init(remotes, economy)
	Remotes = remotes
	Economy = economy
end

-- The wave itself: a tall translucent wall that crosses the island.
local function buildWave(): Part
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(6, 26, 240)
	wave.Position = Vector3.new(-130, 8, 0)
	wave.Color = Color3.fromRGB(40, 140, 255)
	wave.Material = Enum.Material.Neon
	wave.Transparency = 0.35
	wave.Anchored = true
	wave.CanCollide = false
	wave.Parent = Workspace
	return wave
end

local function splash(player: Player)
	local state = State.get(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not state or not root then
		return
	end
	-- Back to the spawn plaza, briefly unable to move.
	root.CFrame = CFrame.new(0, 4, 72)
	state.stunnedUntil = os.clock() + Config.TSUNAMI_STUN
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 0
		task.delay(Config.TSUNAMI_STUN, function()
			if humanoid.Parent then
				humanoid.WalkSpeed = State.getWalkSpeed(state)
			end
		end)
	end
	Economy.notify(player, "SPLASHED by the tsunami! Run home next time!")
end

-- One full wave: warn, sweep, splash whoever is out in the open.
-- The wave moves 260 studs in 40 steps; each step checks every player once,
-- and a splashed player is never splashed twice by the same wave.
function Events.triggerWave()
	Remotes.Notify:FireAllClients("TSUNAMI INCOMING! Get to your base!")
	local wave = buildWave()
	task.wait(Config.TSUNAMI_WARNING)
	local splashed = {}
	local steps = 40
	for i = 1, steps do
		local x = -130 + (260 * i) / steps
		wave.Position = Vector3.new(x, 8, 0)
		for _, player in ipairs(Players:GetPlayers()) do
			if not splashed[player] then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and math.abs(root.Position.X - x) < 6 and not Plots.isSafe(root.Position) then
					splashed[player] = true
					splash(player)
				end
			end
		end
		task.wait(Config.TSUNAMI_SWEEP_SECONDS / steps)
	end
	wave:Destroy()
	Remotes.Notify:FireAllClients("The wave passed. Back to the grind!")
end

function Events.start()
	task.spawn(function()
		while true do
			task.wait(Config.TSUNAMI_INTERVAL)
			Events.triggerWave()
		end
	end)
end

return Events
