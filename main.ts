// Brainrot Bay — the hand-in program (Node 22, standard library only).
// Copies the entry's files into the output directory and writes
// dossier.json with buildDossier from vendor/makefun-roblox.ts. The
// program runs twice while grading and both runs must write the same
// bytes, so every step here is a plain deterministic copy: no timestamps,
// no randomness, no network.

import { cpSync, existsSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

// The repository root is the directory this file sits in, whatever the
// working directory is when Node runs it.
const repoRoot = dirname(fileURLToPath(import.meta.url));
const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// Start from an empty output directory so a stale file from an earlier
// run can never leak into the entry.
if (existsSync(outDir)) {
	rmSync(outDir, { recursive: true, force: true });
}
mkdirSync(outDir, { recursive: true });

// The entry's files, copied whole. Nothing starting with a dot is ever
// copied: a dotfile under /output fails the entry before the gate runs.
cpSync(join(repoRoot, 'game.rbxl'), join(outDir, 'game.rbxl'));
cpSync(join(repoRoot, 'PLAY.json'), join(outDir, 'PLAY.json'));
cpSync(join(repoRoot, 'src'), join(outDir, 'src'), { recursive: true });
cpSync(join(repoRoot, 'screenshots'), join(outDir, 'screenshots'), { recursive: true });

// The dossier, byte for byte what the gate rebuilds from these same files.
const dossier = buildDossier(outDir, { text_max_bytes: 65536 });
writeFileSync(join(outDir, 'dossier.json'), dossier);
