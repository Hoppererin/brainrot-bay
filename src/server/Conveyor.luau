-- Brainrot Bay — the conveyor belt.
-- Brainrots spawn at the purple portal, walk east along the belt and leave
-- through the green exit if nobody buys them. Clicking a belt brainrot
-- calls the `onClick` callback with the player and the brainrot's id.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Catalog)
local BrainrotFactory = require(script.Parent.BrainrotFactory)

local Conveyor = {}
Conveyor.belt = {}
Conveyor.nextId = 1
Conveyor.running = false

--- Spawn one brainrot at the portal end of the belt.
function Conveyor.spawnOne(parent)
	local charDef = Catalog.pickCharacter()
	local mutationName = Catalog.rollMutation()
	local mult = Catalog.mutationMultiplier(mutationName)
	local spawnPos = Vector3.new(Config.BELT_MIN_X, Config.BELT_TOP_Y, Config.CONVEYOR_Z)
	local model = BrainrotFactory.create(charDef, mutationName, spawnPos)
	model.Parent = parent

	local id = Conveyor.nextId
	Conveyor.nextId = Conveyor.nextId + 1
	local record = {
		id = id,
		charName = charDef.name,
		rarity = charDef.rarity,
		rate = charDef.rate,
		mult = mult,
		mutation = mutationName,
		price = Catalog.getPrice(charDef),
		model = model,
		owner = nil,
		plotId = 0,
		slotIndex = 0,
		x = Config.BELT_MIN_X,
	}
	Conveyor.belt[id] = record

	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 32
	detector.Parent = model.PrimaryPart
	detector.MouseClick:Connect(function(player)
		if Conveyor.onClick ~= nil then
			Conveyor.onClick(player, id)
		end
	end)
	return record
end

--- Move every belt brainrot one step and despawn the ones past the exit.
function Conveyor.step(dt, parent)
	for id, record in pairs(Conveyor.belt) do
		record.x = record.x + Config.CONVEYOR_SPEED * dt
		if record.x >= Config.BELT_MAX_X then
			record.model:Destroy()
			Conveyor.belt[id] = nil
		else
			local size = record.model:GetAttribute("Size")
			record.model:PivotTo(CFrame.new(record.x, Config.BELT_TOP_Y + size / 2, Config.CONVEYOR_Z))
		end
	end
end

--- Start the belt: spawn on a timer and move on Heartbeat.
function Conveyor.start(onClick, parent)
	if Conveyor.running then
		return
	end
	Conveyor.running = true
	Conveyor.onClick = onClick

	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_INTERVAL)
			local count = 0
			for _ in pairs(Conveyor.belt) do
				count = count + 1
			end
			if count < Config.MAX_BELT then
				Conveyor.spawnOne(parent)
			end
		end
	end)

	game:GetService("RunService").Heartbeat:Connect(function(dt)
		Conveyor.step(dt, parent)
	end)
end

return Conveyor
