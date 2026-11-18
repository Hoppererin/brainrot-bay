-- Brainrot Bay: the economy.
-- Buying, selling, rebirthing and upgrading, all validated on the server
-- (the client only ever asks). Cash ticks up every second from every
-- brainrot on the player's base.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Plots = require(script.Parent.Plots)
local State = require(script.Parent.State)

local Economy = {}
local Conveyor = nil
local Remotes = nil

function Economy.init(remotes, conveyor)
	Remotes = remotes
	Conveyor = conveyor
end

function Economy.notify(player: Player, text: string)
	Remotes.Notify:FireClient(player, text)
end

function Economy.applyWalkSpeed(player: Player)
	local state = State.get(player)
	local character = player.Character
	if not state or not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = State.getWalkSpeed(state)
	end
end

-- The buy: only walking brainrots, only with enough cash and a free slot.
function Economy.tryBuy(player: Player, record)
	local state = State.get(player)
	if not state or record.state ~= "walking" then
		return
	end
	local plot = Plots.getFor(player)
	if not plot then
		Economy.notify(player, "You have no base yet!")
		return
	end
	local slotIndex = Plots.getFreeSlot(plot)
	if not slotIndex then
		Economy.notify(player, "Your base is full! Sell or rebirth first.")
		return
	end
	local cost = record.spawn.cost
	if state.cash < cost then
		Economy.notify(player, "Not enough cash! Need $" .. tostring(cost) .. ".")
		return
	end
	state.cash -= cost
	record.owner = player
	state.owned[record.id] = record
	Conveyor.sendToPlot(record, plot, slotIndex)
	Economy.notify(player, "Bought " .. record.spawn.character.name .. " for $" .. tostring(cost) .. "!")
	Economy.refreshLeaderstats(player)
end

-- Selling returns half the buy price and frees the slot.
function Economy.trySell(player: Player, brainrotId: number)
	local state = State.get(player)
	local record = state and state.owned[brainrotId]
	if not record then
		return
	end
	local refund = math.floor(record.spawn.cost * Config.SELL_REFUND)
	state.cash += refund
	state.owned[brainrotId] = nil
	Conveyor.remove(record)
	Economy.notify(player, "Sold " .. record.spawn.character.name .. " for $" .. tostring(refund) .. ".")
	Economy.refreshLeaderstats(player)
end

-- Rebirth: wipe cash and brainrots for a permanent +25% income each level.
function Economy.tryRebirth(player: Player)
	local state = State.get(player)
	if not state then
		return
	end
	local cost = State.getRebirthCost(state)
	if state.cash < cost then
		Economy.notify(player, "Rebirth costs $" .. tostring(cost) .. ". Keep earning!")
		return
	end
	for id in pairs(state.owned) do
		local record = state.owned[id]
		Conveyor.remove(record)
	end
	state.owned = {}
	state.cash = Config.START_CASH
	state.rebirths += 1
	Economy.notify(player, "REBIRTH! Income x" .. string.format("%.2f", State.getIncomeMultiplier(state)) .. " forever.")
	Economy.refreshLeaderstats(player)
end

-- Upgrades: Speed boots and an Income boost, three levels each.
function Economy.tryUpgrade(player: Player, kind: string)
	local state = State.get(player)
	if not state then
		return
	end
	local def = Config.UPGRADES[kind]
	if not def then
		return
	end
	local level = state.upgrades[kind]
	if level >= #def.costs then
		Economy.notify(player, kind .. " is already maxed out!")
		return
	end
	local cost = def.costs[level + 1]
	if state.cash < cost then
		Economy.notify(player, "Need $" .. tostring(cost) .. " for " .. kind .. " level " .. tostring(level + 1) .. ".")
		return
	end
	state.cash -= cost
	state.upgrades[kind] = level + 1
	Economy.notify(player, kind .. " upgraded to level " .. tostring(level + 1) .. "!")
	Economy.applyWalkSpeed(player)
	Economy.refreshLeaderstats(player)
end

function Economy.refreshLeaderstats(player: Player)
	local state = State.get(player)
	if not state then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local cash = leaderstats:FindFirstChild("Cash")
	local income = leaderstats:FindFirstChild("Income")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if cash then
		cash.Value = math.floor(state.cash)
	end
	if income then
		income.Value = State.getIncomePerSecond(state)
	end
	if rebirths then
		rebirths.Value = state.rebirths
	end
end

-- The income tick: every second, every player earns from their base.
-- HudUpdate rides the same tick, so the client never shows stale numbers.
function Economy.start()
	task.spawn(function()
		while true do
			task.wait(Config.INCOME_TICK_SECONDS)
			for _, player in ipairs(Players:GetPlayers()) do
				local state = State.get(player)
				if state then
					state.cash += State.getIncomePerSecond(state)
					Economy.refreshLeaderstats(player)
					Remotes.HudUpdate:FireClient(player, {
						cash = math.floor(state.cash),
						income = State.getIncomePerSecond(state),
						rebirths = state.rebirths,
						speedLevel = state.upgrades.Speed,
						incomeLevel = state.upgrades.Income,
						lockSeconds = math.max(0, math.floor(state.lockUntil - os.clock())),
					})
				end
			end
		end
	end)
end

return Economy
