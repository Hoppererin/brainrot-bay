# Brainrot Bay

[![Brainrot Bay on make.fun](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Rank](https://make.fun/badge/roblox-brainrot-01/geishakampret/brainrot-bay/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/geishakampret/brainrot-bay/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A 3D Roblox game in the Steal-a-Brainrot genre, built for the
[roblox-brainrot-01 bounty](https://make.fun/bounty/roblox-brainrot-01) on make.fun.

## How to play

Brainrots walk in from the purple portal and along the neon conveyor.
**Click one to buy it** — it walks to your base and earns money every second.
Click another player's brainrot to **steal** it, but you only have 20 seconds
to run it home, and the owner can yank it back within 40 studs.
**Lock your base** to stop thieves. A **tsunami** sweeps the island every
3 minutes: hide in your base or at spawn, or get splashed back.
Spend your cash on **rebirths** (+25% income per level) and **upgrades**
(Speed Boots, Income Boost, 3 levels each).

## The cast

21 original characters in 7 rarities — Common, Rare, Epic, Legendary,
Mythic, Godly, Secret — earning $5/s up to $5,000/s, plus Golden (x2),
Diamond (x4) and Rainbow (x8) mutations. The cheapest brainrot costs $125,
and you start with $150, so your first buy is always within reach.

## Structure

- `src/shared/` — `Config.luau` (tuning, plots, upgrades) and `Catalog.luau`
  (the 21 characters, rarities, mutations)
- `src/server/` — `State` (the one server store), `Plots`, `Conveyor`,
  `BrainrotFactory`, `Economy`, `Steal`, `Events` (tsunami), `WorldBuilder`
  (palms, coins, clouds, signs) and `init.server.luau`
- `src/client/` — `Game.client.luau` and `Hud.luau`
- `default.project.json` — the static island, built with Rojo (`rojo build`)
- `main.ts` — the hand-in program: copies the game to `/output` and writes
  `dossier.json` with the kit's `vendor/makefun-roblox.ts`
- `game.rbxl` — the built place file, `PLAY.json` — the play link,
  `TOUR.json` — a guided tour of the game

Everything is server-authoritative: the client draws the HUD and asks,
the server validates every buy, sell, steal, rebirth and upgrade.

## Build

```sh
rojo build -o game.rbxl
MAKEFUN_OUTPUT_DIR=out node main.ts
```

Entered on make.fun — play it at https://make.fun/bounty/roblox-brainrot-01 —
my referral link: https://make.fun/r/dhj53q2r
