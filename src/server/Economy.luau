-- Brainrot Bay — the economy.
-- The buy: only walking brainrots, only with enough cash and a free slot.
-- Cash ticks up every second from every brainrot on your base. Selling
-- returns half the buy price. Rebirth wipes cash and brainrots for a
-- permanent +25% income each level. Two upgrade tracks, three levels each.
-- The server validates every request; the client only ever asks.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Catalog"))
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)

local Economy = {}

local remotes = ReplicatedStorage:WaitForChild("Remotes")

-- The whole HUD snapshot the client renders: cash, income, rebirths, both
-- upgrade levels and their next costs, and the base lock's countdown.
local function hudSnapshot(state: State.PlayerState)
	local speedDef = Config.UPGRADES.Speed
	local incomeDef = Config.UPGRADES.Income
	return {
		cash = math.floor(state.cash),
		income = math.floor(State.getIncomePerSecond(state)),
		rebirths = state.rebirths,
		speedLevel = state.speedLevel,
		incomeLevel = state.incomeLevel,
		speedCost = if state.speedLevel < speedDef.maxLevel then speedDef.costs[state.speedLevel + 1] else nil,
		incomeCost = if state.incomeLevel < incomeDef.maxLevel then incomeDef.costs[state.incomeLevel + 1] else nil,
		lockLeft = math.max(0, math.floor(state.lockUntil - os.clock())),
		lockCooldownLeft = math.max(0, math.floor(state.lockCooldownUntil - os.clock())),
	}
end

function Economy.pushHud(player: Player)
	local state = State.get(player)
	if state == nil then
		return
	end
	remotes.HudUpdate:FireClient(player, hudSnapshot(state))
end

function Economy.notify(player: Player, message: string)
	remotes.Notify:FireClient(player, message)
end

-- Creates the leaderstats the Roblox leaderboard reads: Cash, Income, Rebirths.
function Economy.setupPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.START_CASH
	cash.Parent = leaderstats

	local income = Instance.new("IntValue")
	income.Name = "Income"
	income.Value = 0
	income.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats
end

local function syncLeaderstats(state: State.PlayerState)
	local leaderstats = state.player:FindFirstChild("leaderstats")
	if leaderstats == nil then
		return
	end
	local cash = leaderstats:FindFirstChild("Cash")
	local income = leaderstats:FindFirstChild("Income")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if cash ~= nil then
		(cash :: IntValue).Value = math.floor(state.cash)
	end
	if income ~= nil then
		(income :: IntValue).Value = math.floor(State.getIncomePerSecond(state))
	end
	if rebirths ~= nil then
		(rebirths :: IntValue).Value = state.rebirths
	end
end

-- Buys a walking brainrot: takes the money, books the slot, hands the
-- plot and slot back so the belt can walk it home. Returns nil, nil when
-- the buy is refused, with a toast saying why.
function Economy.tryBuy(player: Player, record: State.BrainrotRecord): (Plots.Plot?, number?)
	local state = State.get(player)
	if state == nil or record.state ~= "walking" then
		return nil, nil
	end
	local cost = Catalog.getPrice(record.character, record.mutation)
	if state.cash < cost then
		Economy.notify(player, "Not enough cash! Need $" .. tostring(cost) .. ".")
		return nil, nil
	end
	local plot = Plots.plotOf(player)
	if plot == nil then
		Economy.notify(player, "You have no base yet!")
		return nil, nil
	end
	local slotIndex = Plots.freeSlot(plot)
	if slotIndex == nil then
		Economy.notify(player, "Your base is full! Sell a brainrot first.")
		return nil, nil
	end
	state.cash -= cost
	state.owned[record.id] = true
	record.owner = player
	Economy.pushHud(player)
	syncLeaderstats(state)
	Economy.notify(player, "Bought " .. record.character.name .. " for $" .. tostring(cost) .. "!")
	return plot, slotIndex
end

-- Sells one of your owned brainrots for half its buy price.
function Economy.sell(player: Player, recordId: number)
	local state = State.get(player)
	local record = State.getRecord(recordId)
	if state == nil or record == nil or record.owner ~= player or record.state ~= "owned" then
		return
	end
	local refund = math.floor(Catalog.getPrice(record.character, record.mutation) * Config.SELL_REFUND)
	state.cash += refund
	state.owned[recordId] = nil
	local plot = Plots.get(record.plotId or 0)
	if plot ~= nil and record.slotIndex ~= nil then
		plot.taken[record.slotIndex] = nil
	end
	record.state = "gone"
	State.removeRecord(recordId)
	record.model:Destroy()
	Economy.pushHud(player)
	syncLeaderstats(state)
	Economy.notify(player, "Sold " .. record.character.name .. " for $" .. tostring(refund) .. ".")
end

-- Rebirth: wipe cash and brainrots for a permanent +25% income each level.
-- Costs 250k times the level being bought; the first rebirth costs 250k.
function Economy.tryRebirth(player: Player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local cost = Config.REBIRTH_BASE_COST * (state.rebirths + 1)
	if state.cash < cost then
		Economy.notify(player, "Rebirth costs $" .. tostring(cost) .. ". Keep earning!")
		return
	end
	for id in pairs(state.owned) do
		local record = State.getRecord(id)
		if record ~= nil then
			local plot = Plots.get(record.plotId or 0)
			if plot ~= nil and record.slotIndex ~= nil then
				plot.taken[record.slotIndex] = nil
			end
			record.state = "gone"
			State.removeRecord(id)
			record.model:Destroy()
		end
	end
	table.clear(state.owned)
	state.cash = Config.START_CASH
	state.rebirths += 1
	Economy.pushHud(player)
	syncLeaderstats(state)
	Economy.notify(player, "Rebirth! Income +" .. tostring(Config.REBIRTH_BONUS * 100) .. "% forever.")
end

-- Buys one level of an upgrade track: Speed Boots or Income Boost.
function Economy.buyUpgrade(player: Player, kind: string)
	local state = State.get(player)
	if state == nil then
		return
	end
	local def = Config.UPGRADES[kind]
	if def == nil then
		return
	end
	local level = if kind == "Speed" then state.speedLevel else state.incomeLevel
	if level >= def.maxLevel then
		Economy.notify(player, def.name .. " is already maxed!")
		return
	end
	local cost = def.costs[level + 1]
	if state.cash < cost then
		Economy.notify(player, def.name .. " level " .. tostring(level + 1) .. " costs $" .. tostring(cost) .. ".")
		return
	end
	state.cash -= cost
	if kind == "Speed" then
		state.speedLevel += 1
	else
		state.incomeLevel += 1
	end
	local character = state.player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		humanoid.WalkSpeed = State.walkSpeed(state)
	end
	Economy.pushHud(player)
	syncLeaderstats(state)
	Economy.notify(player, def.name .. " level " .. tostring(level + 1) .. " bought!")
end

-- Locks your base against steals for 60 seconds, then a 120-second cooldown.
function Economy.lockBase(player: Player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local now = os.clock()
	if now < state.lockUntil then
		Economy.notify(player, "Your base is already locked!")
		return
	end
	if now < state.lockCooldownUntil then
		Economy.notify(player, "Lock is cooling down: " .. tostring(math.floor(state.lockCooldownUntil - now)) .. "s left.")
		return
	end
	state.lockUntil = now + Config.LOCK_DURATION
	state.lockCooldownUntil = now + Config.LOCK_DURATION + Config.LOCK_COOLDOWN
	Economy.pushHud(player)
	Economy.notify(player, "Base locked for " .. tostring(Config.LOCK_DURATION) .. " seconds!")
end

-- Every second, every player's cash ticks up by their income, and the
-- leaderboard and HUD follow it.
function Economy.startIncomeLoop()
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				local state = State.get(player)
				if state ~= nil then
					state.cash += State.getIncomePerSecond(state)
					syncLeaderstats(state)
					Economy.pushHud(player)
				end
			end
		end
	end)
end

return Economy
