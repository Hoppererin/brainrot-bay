-- Brainrot Bay — the conveyor belt.
-- Brainrots spawn at the portal, walk the belt west to east, and despawn
-- at the exit arch. Clicking one buys it when it is walking, tries a
-- steal when it belongs to another base, and yanks it back when it is
-- being carried away from yours.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Catalog"))
local State = require(script.Parent.State)
local Economy = require(script.Parent.Economy)
local Steal = require(script.Parent.Steal)
local Plots = require(script.Parent.Plots)
local BrainrotFactory = require(script.Parent.BrainrotFactory)

local Conveyor = {}

local walking: { State.BrainrotRecord } = {}

local function removeFromWalking(record: State.BrainrotRecord)
	for i, other in ipairs(walking) do
		if other == record then
			table.remove(walking, i)
			return
		end
	end
end

-- Spawns one brainrot at the portal: a weighted character, a rolled
-- mutation, a model from the factory, and a ClickDetector on its root.
local function spawnOne()
	local character = Catalog.randomCharacter()
	local mutation = Catalog.rollMutation()
	local model = BrainrotFactory.create(character, mutation)
	model.Parent = workspace
	model:PivotTo(CFrame.new(Config.BELT_START_X, Config.BELT_Y, Config.BELT_Z))

	local record: State.BrainrotRecord = {
		id = 0,
		character = character,
		mutation = mutation,
		model = model,
		state = "walking",
		owner = nil,
		plotId = nil,
		slotIndex = nil,
		carrier = nil,
		progress = 0,
	}
	State.addRecord(record)
	table.insert(walking, record)

	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 32
	detector.MouseClick:Connect(function(player: Player)
		Conveyor.onClicked(player, record)
	end)
	detector.Parent = model.PrimaryPart

	-- A gentle bob while it walks, so the belt reads as alive. The loop
	-- stops itself the moment the brainrot is bought or despawns.
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

-- Walks one brainrot along the belt until it is bought or reaches the exit.
local function walkLoop(record: State.BrainrotRecord)
	task.spawn(function()
		while record.state == "walking" and record.model.Parent do
			local dt = task.wait(0.05)
			local pivot = record.model:GetPivot()
			local nextX = pivot.X + Config.BELT_SPEED * dt
			if nextX >= Config.BELT_END_X then
				Conveyor.despawn(record)
				return
			end
			record.model:PivotTo(CFrame.new(nextX, pivot.Y, pivot.Z))
			record.progress = nextX - Config.BELT_START_X
		end
	end)
end

-- Removes a walker that reached the exit: model gone, record forgotten.
function Conveyor.despawn(record: State.BrainrotRecord)
	if record.state ~= "walking" then
		return
	end
	record.state = "gone"
	removeFromWalking(record)
	State.removeRecord(record.id)
	record.model:Destroy()
end

-- Clicking a brainrot does the thing its state asks for: buy it while it
-- walks, steal it while it sits on another base, yank it back while it
-- is being carried away from yours.
function Conveyor.onClicked(player: Player, record: State.BrainrotRecord)
	if record.state == "walking" then
		-- tryBuy takes the money and books the slot; the belt then walks
		-- the brainrot home. It returns nothing when the buy is refused.
		local plot, slotIndex = Economy.tryBuy(player, record)
		if plot ~= nil and slotIndex ~= nil then
			Conveyor.sendToPlot(record, plot, slotIndex)
		end
	elseif record.state == "owned" then
		Steal.trySteal(player, record)
	elseif record.state == "carried" then
		Steal.tryYankBack(player, record)
	end
end

-- Sends a bought brainrot to its slot on its owner's plot, walking the
-- last leg so the buy reads on screen, then plants it there.
function Conveyor.sendToPlot(record: State.BrainrotRecord, plot: Plots.Plot, slotIndex: number)
	record.state = "owned"
	record.plotId = plot.id
	record.slotIndex = slotIndex
	plot.taken[slotIndex] = record.id
	removeFromWalking(record)

	local target = Plots.slotPosition(plot, slotIndex)
	local model = record.model
	task.spawn(function()
		local from = model:GetPivot().Position
		local height = 2.4 * record.character.scale
		local goal = Vector3.new(target.X, target.Y + height / 2, target.Z)
		for step = 1, 20 do
			if record.state ~= "owned" or not model.Parent then
				return
			end
			local alpha = step / 20
			local pos = from:Lerp(goal, alpha)
			model:PivotTo(CFrame.new(pos.X, pos.Y + math.sin(alpha * math.pi) * 1.5, pos.Z))
			task.wait(0.05)
		end
		if record.state == "owned" and model.Parent then
			model:PivotTo(CFrame.new(goal))
		end
	end)
end

-- The spawn loop: a new brainrot every few seconds while the belt has room.
function Conveyor.start()
	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_INTERVAL)
			if #walking < Config.BELT_MAX_WALKING then
				spawnOne()
				local record = walking[#walking]
				if record ~= nil then
					walkLoop(record)
				end
			end
		end
	end)
end

return Conveyor
