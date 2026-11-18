-- Brainrot Bay — base plots.
-- Eight colour-coded pads in two rows. A player owns one plot; each plot
-- holds six brainrots on its six slots. The layout (centres and slot
-- offsets) comes from Config, so the world, the plots and the slot pads
-- can never disagree about where a brainrot stands.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent.State)

local Plots = {}

export type Plot = {
	id: number,
	center: Vector3,
	color: Color3,
	owner: Player?,
	taken: { [number]: number }, -- [slotIndex] = record id
}

local plots: { Plot } = {}

function Plots.init()
	for _, def in ipairs(Config.PLOTS) do
		plots[def.id] = {
			id = def.id,
			center = def.center,
			color = Config.PLOT_COLORS[def.id],
			owner = nil,
			taken = {},
		}
	end
end

-- Hands a joining player the first free plot, or nil when all eight are taken.
function Plots.assign(player: Player): Plot?
	for _, plot in ipairs(plots) do
		if plot.owner == nil then
			plot.owner = player
			local state = State.get(player)
			if state ~= nil then
				state.plotId = plot.id
			end
			return plot
		end
	end
	return nil
end

-- Frees a leaving player's plot and forgets who owned it.
function Plots.free(player: Player)
	local state = State.get(player)
	if state == nil or state.plotId == nil then
		return
	end
	local plot = plots[state.plotId]
	if plot ~= nil then
		plot.owner = nil
	end
end

function Plots.plotOf(player: Player): Plot?
	local state = State.get(player)
	if state == nil or state.plotId == nil then
		return nil
	end
	return plots[state.plotId]
end

function Plots.get(plotId: number): Plot?
	return plots[plotId]
end

-- The first empty slot on a plot, or nil when the base is full.
function Plots.freeSlot(plot: Plot): number?
	for i = 1, #Config.SLOT_OFFSETS do
		if plot.taken[i] == nil then
			return i
		end
	end
	return nil
end

-- Where a brainrot stands on its slot: the pad's top, plus its offset.
-- Y sits just above the slot pad so the model's feet rest on the tile.
function Plots.slotPosition(plot: Plot, slotIndex: number): Vector3
	local offset = Config.SLOT_OFFSETS[slotIndex]
	return Vector3.new(plot.center.X + offset.X, 1.6, plot.center.Z + offset.Z)
end

-- Whether a point is on a plot's pad (used to tell a base from open sand).
function Plots.isOnPlot(plot: Plot, position: Vector3): boolean
	return math.abs(position.X - plot.center.X) <= 13 and math.abs(position.Z - plot.center.Z) <= 11
end

return Plots
