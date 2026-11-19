# Brainrot Bay

[![Brainrot Bay on make.fun](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Rank](https://make.fun/badge/roblox-brainrot-01/Hoppererin/brainrot-bay/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/Hoppererin/brainrot-bay/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A 3D Roblox brainrot game — a Steal-a-Brainrot-style island where brainrots
walk the conveyor, you click to buy them, they earn cash at your base, and
thieves, tsunamis and rebirths keep the tension up.

## The game

- **40 original brainrots** in 7 rarities (Common → Secret, $5/s to $5,000/s),
  plus Golden (×2), Diamond (×4) and Rainbow (×8) mutations.
- **Buy–steal–rebirth loop**: click a brainrot on the conveyor to buy it
  (price = $/s × 25); it walks to your base and earns every second. Click
  your own brainrot to sell it for a 50% refund. Click someone else's to
  steal it — carry it home in 20 seconds while the owner tries to yank it
  back. Lock your base for 60 seconds to stop thieves.
- **Tsunami every 3 minutes**: a wave sweeps the island; get to spawn or
  your base, or get splashed back and stunned.
- **Progression**: rebirths (+25% income per level) and Speed / Income
  upgrades, 3 levels each.
- **World**: a 220-stud sand island in the sea, neon-railed conveyor with
  portal and exit arches, 8 colour-coded base plots (6 slots each), spawn
  plaza, volcano, lamps, palms, clouds and spinning gold coins.
- **Server-authoritative**: the client only asks; the server validates every
  buy, sell, steal, rebirth and upgrade.

## Layout

- `src/shared/` — `Config.luau` (all tuning in one place) and `Catalog.luau`
  (the 40-character roster, rarities, mutations).
- `src/server/` — `State`, `Plots`, `Conveyor`, `BrainrotFactory`,
  `Economy`, `Steal`, `Events`, `WorldBuilder`, `init.server`.
- `src/client/` — `Game.client` (bootstrap) and `Hud` (cash bar, banner,
  buttons, upgrades and help panels).
- `main.ts` — writes `dossier.json` from `game.rbxl`, `src/` and
  `screenshots/` (Node 22, standard library only).
- `game.rbxl` — built with Rojo 7.7 from `default.project.json`.

## Play

Publish the place from Roblox Studio as a new experience named
**Brainrot Bay Island**, set it Public, and put the play code
`makefun-quince-dragon-mole` in the experience description.

Entered on [make.fun](https://make.fun/r/dhj53q2r)
