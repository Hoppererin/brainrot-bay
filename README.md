# Brainrot Bay

[![Brainrot Bay — roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Rank](https://make.fun/badge/roblox-brainrot-01/geishakampret/brainrot-bay/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/geishakampret/brainrot-bay/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

Brainrot Bay is a 3D Roblox game in the Steal-a-Brainrot genre: 21 original
meme characters walk a conveyor belt across a 220-stud sand island, and you
click one to buy it, keep it on your colour-coded base, and watch it earn
money every second. Rarer brainrots earn more, mutations multiply the rate,
and a tsunami sweeps the island every three minutes — so a catch is only
safe once you dash it home. Steal from other bases, lock yours, buy Speed
Boots and Income Boosts, and rebirth for a permanent +25% income per level.

## How to run it

Open `game.rbxl` in Roblox Studio and press Play. To rebuild the place
from source instead, run `rojo build` (Rojo 7.7) in this directory — it
writes `game.rbxl` from `src/` and `default.project.json`.

## Layout

- `src/shared/` — `Config.luau` (every price, rate and timing) and
  `Catalog.luau` (the 21 characters, 7 rarities, 3 mutations).
- `src/server/` — one module per job: `State` (the single state store),
  `Plots` (the eight bases), `Conveyor` (spawning and walking the belt),
  `BrainrotFactory` (building each character's model), `Economy`
  (buying, selling, rebirths, upgrades, the income tick), `Steal`
  (carrying a stolen brainrot home), `Events` (the tsunami) and
  `WorldBuilder` (palms, coins, clouds, signs, slot pads), plus
  `init.server.luau` wiring them together.
- `src/client/` — `Game.client.luau` boots the client and `Hud.luau`
  draws the cash bar, buttons, panels and event banner.
- `main.ts` — the hand-in program: it copies `game.rbxl`, `src/`,
  `screenshots/` and `PLAY.json` to the output directory and writes
  `dossier.json` with `buildDossier` from `vendor/makefun-roblox.ts`.
- `screenshots/` — three captures of the game running in Roblox Studio.
- `PLAY.json` — the published place's link (filled in once the
  experience is published on Roblox).

## Entered on make.fun

Entered on [make.fun](https://make.fun/bounty/roblox-brainrot-01) for the
"Make the best AI Roblox brainrot game" bounty. Optional: earn referral
rewards, a second way to make money — https://make.fun/r/dhj53q2r
