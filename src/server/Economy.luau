-- Economy.luau
-- Money, buying, selling, rebirth and upgrades for Brainrot Bay (build4).
-- The server validates every move: the client only ever asks.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local State = require(script.Parent.State)
local Plots = require(script.Parent.Plots)
local Conveyor = require(script.Parent.Conveyor)
local Steal = require(script.Parent.Steal)

local Economy = {}

local remotes = nil
local function getRemotes()
	if remotes == nil then
		remotes = ReplicatedStorage:WaitForChild("Remotes")
	end
	return remotes
end

function Economy.push(player)
	local state = State.get(player)
	if state == nil then
		return
	end
	getRemotes().HudUpdate:FireClient(player, state.cash, state.income, state.rebirths)
end

function Economy.notify(player, text)
	getRemotes().Notify:FireClient(player, text)
end

-- Central click routing for every brainrot in the game.
function Economy.handleClick(player, record)
	if record == nil then
		return
	end
	if record.plotId == 0 then
		Economy.buy(player, record)
		return
	end
	local state = State.get(player)
	if state == nil then
		return
	end
	if record.owner == player then
		if record.carried then
			Steal.yank(player, record)
		else
			Economy.notify(player, record.charName .. " is already yours.")
		end
		return
	end
	Steal.trySteal(player, record)
end

-- Buy a brainrot that is walking the belt.
function Economy.buy(player, record)
	local state = State.get(player)
	if state == nil then
		return
	end
	if record.plotId ~= 0 then
		return
	end
	local plotId = Plots.plotOf(player)
	if plotId == 0 then
		Economy.notify(player, "You have no base yet.")
		return
	end
	local slot = Plots.freeSlot(player, state.owned)
	if slot == 0 then
		Economy.notify(player, "Your base is full! Sell or rebirth first.")
		return
	end
	local price = Catalog.getPrice(record)
	if state.cash < price then
		Economy.notify(player, "Not enough cash! Need $" .. tostring(price) .. ".")
		return
	end
	if Conveyor.take(player, record) == false then
		return
	end
	State.addCash(player, -price)
	record.owner = player
	record.plotId = plotId
	record.slot = slot
	state.owned[record.id] = record
	State.recalcIncome(player)
	Economy.push(player)
	Economy.notify(player, "Bought " .. record.charName .. " for $" .. tostring(price) .. "!")
end

-- Sell one of your own brainrots for a 50% refund.
function Economy.sell(player, recordId)
	local state = State.get(player)
	if state == nil then
		return
	end
	local record = state.owned[recordId]
	if record == nil then
		return
	end
	local refund = math.floor(Catalog.getPrice(record) * Config.SELL_REFUND + 0.5)
	if record.model ~= nil then
		record.model:Destroy()
	end
	State.removeRecord(recordId)
	state.owned[recordId] = nil
	State.addCash(player, refund)
	State.recalcIncome(player)
	Economy.push(player)
	Economy.notify(player, "Sold " .. record.charName .. " for $" .. tostring(refund) .. ".")
end

-- Rebirth: costs 250k times the next level, resets cash and brainrots,
-- and adds +25% income per level forever.
function Economy.rebirth(player)
	local state = State.get(player)
	if state == nil then
		return
	end
	local nextLevel = state.rebirths + 1
	local cost = Config.REBIRTH_BASE_COST * nextLevel
	if state.cash < cost then
		Economy.notify(player, "Rebirth costs $" .. tostring(cost) .. ".")
		return
	end
	for recordId, record in pairs(state.owned) do
		if record.model ~= nil then
			record.model:Destroy()
		end
		State.removeRecord(recordId)
	end
	state.owned = {}
	state.cash = Config.START_CASH
	state.rebirths = nextLevel
	State.recalcIncome(player)
	Economy.push(player)
	Economy.notify(player, "Rebirth " .. tostring(nextLevel) .. "! Income +" .. tostring(25 * nextLevel) .. "%.")
end

-- Buy one level of an upgrade ("Speed" or "Income"), at most 3 levels.
function Economy.buyUpgrade(player, kind)
	local state = State.get(player)
	if state == nil then
		return
	end
	local upgrade = Config.UPGRADES[kind]
	if upgrade == nil then
		return
	end
	local level = 0
	if kind == "Speed" then
		level = state.speedLevel
	elseif kind == "Income" then
		level = state.incomeLevel
	end
	if level >= #upgrade.costs then
		Economy.notify(player, upgrade.name .. " is maxed out!")
		return
	end
	local cost = upgrade.costs[level + 1]
	if state.cash < cost then
		Economy.notify(player, upgrade.name .. " level " .. tostring(level + 1) .. " costs $" .. tostring(cost) .. ".")
		return
	end
	State.addCash(player, -cost)
	if kind == "Speed" then
		state.speedLevel = level + 1
		local character = player.Character
		if character ~= nil then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid ~= nil then
				humanoid.WalkSpeed = State.walkSpeed(player)
			end
		end
	elseif kind == "Income" then
		state.incomeLevel = level + 1
		State.recalcIncome(player)
	end
	Economy.push(player)
	Economy.notify(player, upgrade.name .. " level " .. tostring(level + 1) .. " bought!")
end

-- Income tick, run once a second from init: every player earns their $/s.
function Economy.tickLoop()
	while true do
		task.wait(1)
		for player, _ in pairs(State.allPlayers()) do
			local state = State.get(player)
			if state ~= nil and state.income > 0 then
				State.addCash(player, state.income)
				Economy.push(player)
			end
		end
	end
end

return Economy
