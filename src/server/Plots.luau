-- Brainrot Bay: plots.
-- Eight bases around the island, one per player, each with six slots where
-- owned brainrots stand and earn. Plots are claimed in join order; a plot
-- knows its owner, its slots and whether it is locked.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local Plots = {}
Plots.List = {} -- [plotId] = plot table
Plots.ByPlayer = {} -- [Player] = plot table

-- Plot centres: four on the north side of the belt, four on the south.
-- Centres sit 50 studs from the belt (z = +/-45) so the belt stays clear.
local CENTERS = {
	{ -75, -45 }, { -25, -45 }, { 25, -45 }, { 75, -45 },
	{ -75, 45 }, { -25, 45 }, { 25, 45 }, { 75, 45 },
}

function Plots.build()
	for plotId, center in ipairs(CENTERS) do
		local cx, cz = center[1], center[2]
		-- Six slots in two rows of three, on the plot floor.
		local slots = {}
		for row = 1, 2 do
			for col = 1, 3 do
				local x = cx - 7 + (col - 1) * 7
				local z = cz - 3 + (row - 1) * 6
				table.insert(slots, Vector3.new(x, 1.5, z))
			end
		end
		-- The sign stands on the side facing the belt.
		local signZ = cz + (cz < 0 and 8 or -8)
		local plot = {
			id = plotId,
			center = Vector3.new(cx, 0, cz),
			slots = slots,
			taken = {}, -- [slotIndex] = brainrotId
			owner = nil,
			signPosition = Vector3.new(cx, 4, signZ),
			signLabel = nil, -- filled in by WorldBuilder
			floor = Workspace:FindFirstChild("PlotFloor" .. plotId),
		}
		Plots.List[plotId] = plot
	end
end

function Plots.claimFor(player: Player)
	for _, plot in ipairs(Plots.List) do
		if plot.owner == nil then
			plot.owner = player
			Plots.ByPlayer[player] = plot
			if plot.signLabel then
				plot.signLabel.Text = string.upper(player.DisplayName or player.Name) .. "'S BASE"
			end
			return plot
		end
	end
	return nil
end

function Plots.release(player: Player)
	local plot = Plots.ByPlayer[player]
	if plot then
		plot.owner = nil
		Plots.ByPlayer[player] = nil
		if plot.signLabel then
			plot.signLabel.Text = "EMPTY PLOT"
		end
	end
end

function Plots.getFor(player: Player)
	return Plots.ByPlayer[player]
end

function Plots.getFreeSlot(plot): number?
	for i = 1, Config.SLOTS_PER_PLOT do
		if plot.taken[i] == nil then
			return i
		end
	end
	return nil
end

-- Is a world position inside this plot's rectangle (the safe zone)?
function Plots.isInside(plot, position: Vector3): boolean
	local dx = math.abs(position.X - plot.center.X)
	local dz = math.abs(position.Z - plot.center.Z)
	return dx <= Config.PLOT_SIZE_X / 2 and dz <= Config.PLOT_SIZE_Z / 2
end

-- Is a world position inside any plot, or on the spawn plaza?
function Plots.isSafe(position: Vector3): boolean
	for _, plot in ipairs(Plots.List) do
		if Plots.isInside(plot, position) then
			return true
		end
	end
	local dx = math.abs(position.X)
	local dz = math.abs(position.Z - 72)
	return dx <= 14 and dz <= 14
end

return Plots
