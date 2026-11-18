-- Brainrot Bay: client boot.
-- Builds the HUD and keeps the camera on the island; everything else
-- (buying, stealing, locking) is a click on the 3D world, handled by the
-- server's ClickDetectors. No game logic lives here on purpose.
local Hud = require(script.Parent.Hud)

Hud.build()

print("Brainrot Bay client ready.")
