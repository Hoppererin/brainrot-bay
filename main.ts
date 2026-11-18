// main.ts
// The hand-in program for Brainrot Bay (build4, written from scratch).
// Copies the game (place file, sources, screenshots, play link) into the
// output directory and writes its dossier with the kit's vendor library.
//
//   MAKEFUN_OUTPUT_DIR=out node main.ts
//
// Node 22+ runs this TypeScript as-is, no build step, no install.

import { cpSync, mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { buildDossier } from './vendor/makefun-roblox.ts';

const root = process.cwd();
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

mkdirSync(out, { recursive: true });
cpSync(join(root, 'game.rbxl'), join(out, 'game.rbxl'));
cpSync(join(root, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(root, 'src'), join(out, 'src'), { recursive: true });
cpSync(join(root, 'screenshots'), join(out, 'screenshots'), { recursive: true });

const dossier = buildDossier(out, { text_max_bytes: 65536 });
writeFileSync(join(out, 'dossier.json'), dossier);
console.log(`wrote ${join(out, 'dossier.json')} (${dossier.length} bytes)`);
