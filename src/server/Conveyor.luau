-- Brainrot Bay: the conveyor.
-- Brainrots roll out of the portal, walk the belt from west to east, and
-- despawn at the far gate if nobody buys them. Buying is a click on the
-- brainrot: the server checks the cash, takes the money, and hands the
-- brainrot to the buyer's plot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BrainrotFactory = require(script.Parent.BrainrotFactory)
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local Config = require(ReplicatedStorage.Shared.Config)
local Plots = require(script.Parent.Plots)
local State = require(script.Parent.State)

local Conveyor = {}
Conveyor.Walking = {} -- [brainrotId] = brainrot record
Conveyor.NextId = 1

local Economy = nil

function Conveyor.init(remotes, economy)
	Economy = economy
end

local function nextId(): number
	local id = Conveyor.NextId
	Conveyor.NextId += 1
	return id
end

-- Spawns one brainrot at the west portal and starts it walking east.
local function spawnOne()
	local count = 0
	for _ in pairs(Conveyor.Walking) do
		count += 1
	end
	if count >= Config.MAX_WALKING then
		return
	end
	local spawn = Catalog.rollSpawn()
	local id = nextId()
	local start = Vector3.new(Config.BELT_START_X, Config.BELT_Y, Config.BELT_Z)
	local model = BrainrotFactory.build(spawn, start)
	model.Parent = Workspace

	local record = {
		id = id,
		spawn = spawn,
		model = model,
		state = "walking", -- walking | owned | carried | gone
		owner = nil,
		plotId = nil,
		slotIndex = nil,
		progress = 0, -- studs travelled along the belt
	}
	Conveyor.Walking[id] = record

	-- Clicking a walking brainrot buys it; clicking an owned one tries a steal.
	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 32
	detector.MouseClick:Connect(function(player: Player)
		Conveyor.onClicked(player, record)
	end)
	detector.Parent = model.Root

	-- A gentle bob while it walks, so the belt reads as alive.
	-- The loop stops itself the moment the brainrot is bought or despawns.
	task.spawn(function()
		local t = 0
		while record.state == "walking" and model.Parent do
			t += 0.1
			local bob = math.sin(t * 3) * 0.3
			local base = model:GetPivot().Position
			model:PivotTo(CFrame.new(base.X, Config.BELT_Y + bob, base.Z))
			task.wait(0.1)
		end
	end)
end

function Conveyor.onClicked(player: Player, record)
	local state = State.get(player)
	if not state then
		return
	end
	if record.state == "walking" then
		Economy.tryBuy(player, record)
	elseif record.state == "owned" then
		local Steal = require(script.Parent.Steal)
		Steal.trySteal(player, record)
	elseif record.state == "carried" then
		local Steal = require(script.Parent.Steal)
		Steal.tryYankBack(player, record)
	end
end

-- Sends a brainrot to its slot on its owner's plot, walking the last leg.
function Conveyor.sendToPlot(record, plot, slotIndex: number)
	record.state = "owned"
	record.plotId = plot.id
	record.slotIndex = slotIndex
	plot.taken[slotIndex] = record.id
	local target = plot.slots[slotIndex]
	local model = record.model
	task.spawn(function()
		local from = model:GetPivot().Position
		local steps = 30
		for i = 1, steps do
			if model.Parent == nil then
				return
			end
			local alpha = i / steps
			local pos = from:Lerp(target, alpha)
			model:PivotTo(CFrame.new(pos.X, Config.BELT_Y + math.sin(alpha * math.pi) * 2, pos.Z))
			task.wait(0.03)
		end
		model:PivotTo(CFrame.new(target))
	end)
end

function Conveyor.remove(record)
	record.state = "gone"
	Conveyor.Walking[record.id] = nil
	if record.plotId then
		local plot = Plots.List[record.plotId]
		if plot and record.slotIndex then
			plot.taken[record.slotIndex] = nil
		end
	end
	if record.model and record.model.Parent then
		record.model:Destroy()
	end
end

function Conveyor.start()
	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_INTERVAL)
			spawnOne()
		end
	end)
	-- The belt walk itself: every walking brainrot advances east each tick.
	task.spawn(function()
		while true do
			task.wait(0.1)
			for _, record in pairs(Conveyor.Walking) do
				if record.state == "walking" then
					record.progress += Config.WALK_SPEED * 0.1
					local x = Config.BELT_START_X + record.progress
					if x >= Config.BELT_END_X then
						Conveyor.remove(record)
					else
						local pos = record.model:GetPivot().Position
						record.model:PivotTo(CFrame.new(x, pos.Y, Config.BELT_Z))
					end
				end
			end
		end
	end)
end

return Conveyor
