-- Brainrot Bay — client entrypoint.
-- The client holds no game logic on purpose: it builds the HUD and lets
-- the server's ClickDetectors do the buying, stealing and yanking. All
-- money, locks and rebirths are validated server-side; this script only
-- asks, through the remotes, and shows what the server answers.

local Hud = require(script.Parent.Hud)

Hud.init()
