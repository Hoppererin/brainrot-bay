-- Plots.luau
-- Base plots for Brainrot Bay (build4, written from scratch).
-- A plot's colour is read ONLY from Config.PLOT_COLORS, keyed by plot id.
-- Plots.get() builds a small table { id, center, color } for callers; the
-- colour there comes from PLOT_COLORS, never from a Config.PLOTS entry.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local Plots = {}

local claimed = {} -- [plotId] = Player who owns the plot

-- First free plot id, or 0 when the island is full.
function Plots.claim(player)
	for _, plot in ipairs(Config.PLOTS) do
		if claimed[plot.id] == nil then
			claimed[plot.id] = player
			return plot.id
		end
	end
	return 0
end

function Plots.release(player)
	for plotId, owner in pairs(claimed) do
		if owner == player then
			claimed[plotId] = nil
		end
	end
end

function Plots.ownerOf(plotId)
	return claimed[plotId]
end

function Plots.plotOf(player)
	for plotId, owner in pairs(claimed) do
		if owner == player then
			return plotId
		end
	end
	return 0
end

-- The plot's description: id, centre and colour (colour from PLOT_COLORS).
function Plots.get(plotId)
	local entry = Config.PLOTS[plotId]
	if entry == nil then
		return nil
	end
	return {
		id = entry.id,
		center = entry.center,
		color = Config.PLOT_COLORS[entry.id],
	}
end

-- World position of one of a plot's six slots (slotIndex 1..6).
function Plots.slotPosition(plot, slotIndex)
	local offset = Config.SLOT_OFFSETS[slotIndex]
	if offset == nil then
		return plot.center
	end
	return plot.center + offset
end

-- First empty slot index in a player's plot, or 0 when the plot is full.
-- `owned` is the player's owned-record table ([recordId] = record).
function Plots.freeSlot(player, owned)
	local plotId = Plots.plotOf(player)
	if plotId == 0 then
		return 0
	end
	local taken = {}
	for _, record in pairs(owned) do
		if record.plotId == plotId then
			taken[record.slot] = true
		end
	end
	for slot = 1, #Config.SLOT_OFFSETS do
		if taken[slot] == nil then
			return slot
		end
	end
	return 0
end

return Plots
