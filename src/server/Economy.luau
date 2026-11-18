-- Brainrot Bay — money: buying, selling, income ticks, rebirths, upgrades.
-- The server is authoritative: the client only asks, every rule is checked here.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)
local Conveyor = require(script.Parent.Conveyor)

local Economy = {}

--- Send a short message to one player's HUD.
function Economy.notify(remotes, player, message)
	local event = remotes:FindFirstChild("HudNotify")
	if event ~= nil then
		event:FireClient(player, message)
	end
end

--- Push a player's cash/income/rebirths to their HUD and leaderstats.
function Economy.pushState(remotes, player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local income = State.recalcIncome(state)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats ~= nil then
		local cashValue = leaderstats:FindFirstChild("Cash")
		local incomeValue = leaderstats:FindFirstChild("Income")
		local rebirthValue = leaderstats:FindFirstChild("Rebirths")
		if cashValue ~= nil then
			cashValue.Value = state.cash
		end
		if incomeValue ~= nil then
			incomeValue.Value = income
		end
		if rebirthValue ~= nil then
			rebirthValue.Value = state.rebirths
		end
	end
	local event = remotes:FindFirstChild("HudUpdate")
	if event ~= nil then
		event:FireClient(player, state.cash, income, state.rebirths, state.speedLevel, state.incomeLevel)
	end
end

--- Where an owned brainrot stands on its plot.
local function placeOnPlot(record)
	local ground = Plots.slotPosition(record.plotId, record.slotIndex)
	local size = record.model:GetAttribute("Size")
	record.model:PivotTo(CFrame.new(ground.X, ground.Y + size / 2, ground.Z))
end

--- Handle a click on a brainrot: buy it off the belt, sell your own, or
-- start a steal on somebody else's.
function Economy.handleClick(remotes, player, brainrotId)
	local state = State.get(player)
	if state == nil then
		return
	end
	local record = Conveyor.belt[brainrotId]
	if record ~= nil then
		-- On the belt: buy it.
		if state.cash < record.price then
			Economy.notify(remotes, player, string.format("Need $%d for %s!", record.price, record.charName))
			return
		end
		if state.plotId == 0 then
			Economy.notify(remotes, player, "No free plot yet, wait a moment!")
			return
		end
		local taken = {}
		for _, owned in pairs(state.owned) do
			if owned.plotId == state.plotId then
				taken[owned.slotIndex] = true
			end
		end
		local slotIndex = Plots.freeSlot(taken)
		if slotIndex == 0 then
			Economy.notify(remotes, player, "Your base is full! Sell or rebirth first.")
			return
		end
		state.cash = state.cash - record.price
		Conveyor.belt[brainrotId] = nil
		record.owner = player
		record.plotId = state.plotId
		record.slotIndex = slotIndex
		state.owned[record.id] = record
		placeOnPlot(record)
		Economy.notify(remotes, player, string.format("Bought %s for $%d!", record.charName, record.price))
		Economy.pushState(remotes, player)
		return
	end
	-- Not on the belt: find whose base it lives on.
	for _, otherState in pairs(State.players) do
		local owned = otherState.owned[brainrotId]
		if owned ~= nil then
			if owned.owner == player then
				-- Your own brainrot: sell it for a 50% refund.
				local refund = math.floor(owned.price * Config.SELL_REFUND)
				state.cash = state.cash + refund
				owned.model:Destroy()
				state.owned[brainrotId] = nil
				Economy.notify(remotes, player, string.format("Sold %s for $%d.", owned.charName, refund))
				Economy.pushState(remotes, player)
			else
				-- Somebody else's: steal it.
				local Steal = require(script.Parent.Steal)
				Steal.startSteal(remotes, player, owned)
			end
			return
		end
	end
end

--- One income tick for every player, every INCOME_TICK seconds.
function Economy.tickLoop(remotes)
	task.spawn(function()
		while true do
			task.wait(Config.INCOME_TICK)
			for player, state in pairs(State.players) do
				local income = State.recalcIncome(state)
				if income > 0 then
					state.cash = state.cash + income
				end
				Economy.pushState(remotes, player)
			end
		end
	end)
end

--- Rebirth: pay the cost, reset cash + brainrots, keep +25% income per level.
function Economy.rebirth(remotes, player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local cost = Config.REBIRTH_BASE_COST * (state.rebirths + 1)
	if state.cash < cost then
		Economy.notify(remotes, player, string.format("Rebirth costs $%d!", cost))
		return
	end
	for _, record in pairs(state.owned) do
		record.model:Destroy()
	end
	state.owned = {}
	state.cash = Config.START_CASH
	state.rebirths = state.rebirths + 1
	Economy.notify(remotes, player, string.format("Rebirth %d! Income +%d%%.", state.rebirths, math.floor(Config.REBIRTH_BONUS * state.rebirths * 100)))
	Economy.pushState(remotes, player)
end

--- Buy one level of an upgrade ("Speed" or "Income").
function Economy.buyUpgrade(remotes, player, kind)
	local state = State.get(player)
	if state == nil then
		return
	end
	local upgradeDef = Config.UPGRADES[kind]
	if upgradeDef == nil then
		return
	end
	local level = 0
	if kind == "Speed" then
		level = state.speedLevel
	else
		level = state.incomeLevel
	end
	if level >= upgradeDef.maxLevel then
		Economy.notify(remotes, player, upgradeDef.name .. " is maxed out!")
		return
	end
	local cost = upgradeDef.costs[level + 1]
	if state.cash < cost then
		Economy.notify(remotes, player, string.format("%s level %d costs $%d!", upgradeDef.name, level + 1, cost))
		return
	end
	state.cash = state.cash - cost
	if kind == "Speed" then
		state.speedLevel = state.speedLevel + 1
		State.applyWalkSpeed(state, false)
	else
		state.incomeLevel = state.incomeLevel + 1
	end
	Economy.notify(remotes, player, string.format("%s level %d bought!", upgradeDef.name, level + 1))
	Economy.pushState(remotes, player)
end

--- Lock a base for LOCK_DURATION seconds (then LOCK_COOLDOWN cooldown).
function Economy.lockBase(remotes, player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local now = os.clock()
	if now < state.lockCooldownUntil then
		Economy.notify(remotes, player, "Lock is cooling down!")
		return
	end
	state.lockUntil = now + Config.LOCK_DURATION
	state.lockCooldownUntil = now + Config.LOCK_DURATION + Config.LOCK_COOLDOWN
	Economy.notify(remotes, player, "Base locked for 60 seconds!")
end

return Economy
