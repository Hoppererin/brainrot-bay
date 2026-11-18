// Brainrot Bay — a 3D Roblox brainrot game for make.fun's roblox-brainrot-01.
//
// The game is a Rojo project: `rojo build default.project.json --output game.rbxl`
// turns src/ and default.project.json into the place file, and this program
// (Node 22, standard library only) hands the entry in. It copies game.rbxl,
// PLAY.json, src/ and screenshots/ from beside this file to /output and
// writes /output/dossier.json, the summary the judge reads, with the vendored
// make.fun library (vendor/makefun-roblox.ts, the kit's copy, unchanged).
//
// The loop the player gets: brainrots ride the conveyor across the island,
// you click one to buy it, it walks to your base and earns money every
// second. Steal from other bases (unless they are locked), outrun the
// tsunami, rebirth for a permanent income multiplier, and climb the ladder
// from Sir Toaster Crumb to The Last Brain Cell.
//
// Every name under /output starts with a letter, a digit or _ and holds only
// letters, digits, . _ and -: the grader fails an entry whose output holds
// any other, so src/ and screenshots/ are copied without any name that
// starts with a dot (.gitkeep, .DS_Store, .git).
//
// Run it as the grader does, writing out/ in place of /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** Leave out every file and directory whose name starts with a dot. */
function keepVisible(path: string): boolean {
	return !basename(path).startsWith('.');
}

function handIn(): void {
	if (!existsSync(join(here, 'game.rbxl'))) {
		throw new Error('game.rbxl is missing: run `rojo build default.project.json --output game.rbxl` first.');
	}
	mkdirSync(out, { recursive: true });
	copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
	copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
	cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: keepVisible });
	mkdirSync(join(out, 'screenshots'), { recursive: true });
	if (existsSync(join(here, 'screenshots'))) {
		cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: keepVisible });
	}
	// The scorer's own caps (reference/gate.json): only text_max_bytes shapes
	// the bytes; the others refuse an entry the scorer would refuse (more
	// than 4 screenshots or one over 256 KiB; a place of more than 500000
	// instances, whose scripts' sources come to over 8 MiB or whose scripts'
	// paths come to over 1048576 characters, in all). These numbers mirror
	// the gate exactly, so a local hand-in that passes here passes there.
	writeFileSync(
		join(out, 'dossier.json'),
		buildDossier(out, {
			text_max_bytes: 65536,
			screenshots: { max: 4, max_bytes: 262144 },
			max_instances: 500000,
			scripts_max_source_bytes: 8388608,
			scripts_max_path_chars: 1048576,
		}),
	);
}

handIn();
