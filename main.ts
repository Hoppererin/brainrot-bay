// Brainrot Bay — hand-in program (Node 22, standard library only).
// Writes dossier.json from game.rbxl, src/ and screenshots/, exactly as the
// scorer computes it, via the kit's own vendor library.
import { buildDossier } from "./vendor/makefun-roblox.ts";
import { writeFileSync } from "node:fs";
import { join } from "node:path";

const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? ".";
const dossier = buildDossier(".", { text_max_bytes: 65536 });
writeFileSync(join(outDir, "dossier.json"), dossier);
console.log(`dossier.json written (${dossier.length} bytes)`);
