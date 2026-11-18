# Brainrot Bay

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/geishakampret/brainrot-bay/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/geishakampret/brainrot-bay/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

A 3D Roblox brainrot game: absurd meme characters ride a conveyor across a
sunny island, you click one to buy it, it walks to your base and earns money
every second. Steal from other players' bases (unless they locked them),
outrun the tsunami that sweeps the map every few minutes, rebirth for a
permanent income multiplier, and climb the ladder from Sir Toaster Crumb to
The Last Brain Cell — 21 original characters across 7 rarities, with Golden,
Diamond and Rainbow mutations.

## Run it

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

Open `game.rbxl` in Roblox Studio to play it. `main.ts` (Node 22, standard
library only) hands the game in: it copies `game.rbxl`, `src/`,
`screenshots/` and `PLAY.json` to `/output` and writes `/output/dossier.json`
with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.

- `src/shared/` — `Catalog.luau` (the 21 characters, rarities, mutations)
  and `Config.luau` (every tuning number in one place).
- `src/server/` — `State.luau` (the single state store), `Plots.luau`,
  `Conveyor.luau`, `Economy.luau` (buy/sell/rebirth/upgrades), `Steal.luau`
  (carry, yank-back, base lock), `Events.luau` (the tsunami),
  `BrainrotFactory.luau` (builds each character from plain parts) and
  `WorldBuilder.luau` (palms, coins, clouds, signs).
- `src/client/` — `Game.client.luau` and `Hud.luau` (cash/income/rebirth bar,
  Lock/Rebirth/Upgrades buttons, help panel, event banner).
- `screenshots/` — captures of the game running in Roblox Studio; the first
  by name is the game's thumbnail on Roblox.

---

<sub>Entered on [make.fun](https://make.fun/?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>
