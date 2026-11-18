-- Brainrot Bay — base plots.
-- Eight plots, six slots each. A plot is claimed when a player joins and
-- released when they leave. The colour of a plot always comes from
-- Config.PLOT_COLORS, keyed by plot id — never from a PLOTS entry, which
-- has no colour field.
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local Plots = {}
Plots.ownerByPlot = {}
Plots.plotByPlayer = {}

--- Claim the first free plot for a player. Returns the plot id, or 0 if none.
function Plots.claim(player)
	for _, plotEntry in ipairs(Config.PLOTS) do
		if Plots.ownerByPlot[plotEntry.id] == nil then
			Plots.ownerByPlot[plotEntry.id] = player
			Plots.plotByPlayer[player] = plotEntry.id
			return plotEntry.id
		end
	end
	return 0
end

--- Release a player's plot (on leave).
function Plots.release(player)
	local plotId = Plots.plotByPlayer[player]
	if plotId ~= nil then
		Plots.ownerByPlot[plotId] = nil
		Plots.plotByPlayer[player] = nil
	end
end

--- The plot a player owns, or 0.
function Plots.plotOf(player)
	return Plots.plotByPlayer[player] or 0
end

--- Plot info: id, centre and colour. The colour is looked up in
-- Config.PLOT_COLORS by id — this is the only correct source for it.
function Plots.get(plotId)
	local plotEntry = Config.PLOTS[plotId]
	if plotEntry == nil then
		return nil
	end
	local plotInfo = {
		id = plotEntry.id,
		center = plotEntry.center,
		color = Config.PLOT_COLORS[plotEntry.id],
	}
	return plotInfo
end

--- The world position of a slot on a plot (ground level, on the pad).
function Plots.slotPosition(plotId, slotIndex)
	local plotInfo = Plots.get(plotId)
	local offset = Config.SLOT_OFFSETS[slotIndex]
	if plotInfo == nil or offset == nil then
		return Vector3.new(0, 1, 0)
	end
	return plotInfo.center + offset + Vector3.new(0, 0.5, 0)
end

--- The first free slot index on a plot, or 0 when the plot is full.
-- `taken` is the set of slot indices already occupied on that plot.
function Plots.freeSlot(taken)
	for slotIndex = 1, #Config.SLOT_OFFSETS do
		if taken[slotIndex] == nil then
			return slotIndex
		end
	end
	return 0
end

return Plots
