-- Conveyor.luau
-- The belt: brainrots spawn at the purple portal, walk east, and leave
-- through the green exit unless a player buys one (build4, from scratch).
-- The click handler is injected by init (Economy.handleClick) so this
-- module never requires Economy: no circular requires.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)
local Factory = require(script.Parent.BrainrotFactory)

local Conveyor = {}

local walking = {} -- [recordId] = { record, model, x }
local nextId = 1
local clickHandler = nil

local function spawnOne()
	local character = Catalog.rollCharacter()
	local mutation = Catalog.rollMutation()
	local record = {
		id = nextId,
		charName = character.name,
		rarity = character.rarity,
		rate = character.rate,
		mutation = nil,
		mult = 1,
		plotId = 0,
		slot = 0,
		owner = nil,
		model = nil,
		carried = false,
	}
	if mutation ~= nil then
		record.mutation = mutation.name
		record.mult = mutation.mult
	end
	nextId += 1
	State.addRecord(record)

	local model = Factory.create(record, function(player, clicked)
		if clickHandler ~= nil then
			clickHandler(player, clicked)
		end
	end)
	if model == nil then
		State.removeRecord(record.id)
		return
	end
	record.model = model
	model:PivotTo(CFrame.new(Config.BELT_START_X, Config.BELT_Y, Config.BELT_Z))
	model.Parent = workspace
	walking[record.id] = { record = record, model = model, x = Config.BELT_START_X }
end

local function despawn(recordId)
	local walker = walking[recordId]
	if walker == nil then
		return
	end
	walking[recordId] = nil
	if walker.model ~= nil then
		walker.model:Destroy()
	end
	State.removeRecord(recordId)
end

local function moveStep(dt)
	for recordId, walker in pairs(walking) do
		local nextX = walker.x + Config.BELT_SPEED * dt
		if nextX >= Config.BELT_END_X then
			despawn(recordId)
		else
			walker.x = nextX
			walker.model:PivotTo(CFrame.new(nextX, Config.BELT_Y, Config.BELT_Z))
		end
	end
end

-- Take a walking brainrot off the belt (a purchase is in progress).
-- Returns the model, or nil when the brainrot is already gone.
function Conveyor.take(record)
	local walker = walking[record.id]
	if walker == nil then
		return nil
	end
	walking[record.id] = nil
	return walker.model
end

-- Walk a bought brainrot from the belt to its slot in its owner's plot.
function Conveyor.deliver(record)
	local model = record.model
	if model == nil then
		return
	end
	local plot = Plots.get(record.plotId)
	if plot == nil then
		return
	end
	local target = Plots.slotPosition(plot, record.slot)
	local scale = model:GetAttribute("Scale")
	if scale == nil then
		scale = 1
	end
	local from = model:GetPivot().Position
	local to = target + Vector3.new(0, 1 + scale, 0)
	task.spawn(function()
		local steps = 24
		for step = 1, steps do
			local alpha = step / steps
			local pos = from:Lerp(to, alpha)
			model:PivotTo(CFrame.new(pos))
			task.wait(0.05)
		end
		model:PivotTo(CFrame.new(to))
	end)
end

function Conveyor.start(onClick)
	clickHandler = onClick
	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_INTERVAL)
			local count = 0
			for _, _ in pairs(walking) do
				count += 1
			end
			if count < Config.BELT_MAX_WALKING then
				spawnOne()
			end
		end
	end)
	RunService.Heartbeat:Connect(moveStep)
end

return Conveyor
