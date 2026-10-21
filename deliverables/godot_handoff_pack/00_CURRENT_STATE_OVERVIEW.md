# Connivances — Current State Overview

**Snapshot date:** 2026-10-02
**Purpose:** Orientation to Connivances **as it exists today**, the source of truth for the Godot implementation. Older MDs have drifted; **the live truth is the code** (`simulator/connivances_simulator_v11_6_4.html` + `simulator/cards.json`). Where this and an older MD disagree, trust this and the code. See `README.md` for file precedence and `CHANGES_SINCE_v2_3.md` for exactly what became current after the previous pack.

---

## 1. What Connivances is

A deck-building / TCG-hybrid. You lead one of the kingdom's **orders** (factions), spend **Food** to play cards and **Influence** to buy them, and earn **Victory Points** by owning and serving. The shared threat is **the Seeping Portal**, a tear in the veil loosing monsters.

**Central lore twist (canon):** the King and a secret society *secretly opened the Portal themselves* as a false-flag common enemy to unite a fractured people; magic had only just been rediscovered, so it got out of hand. **Possessions** (wild-magic backlash) exist because conjuring is young and imperfectly leashed. Tone: Japanese-key high fantasy, grounded, betrayal as the throughline. Full canon in the project's `WORLD_AND_LORE_REFERENCE.md`; faction spirit in `FACTION_IDENTITIES.md` (included). Canonical spellings: **Fallah** (with H), **Laere** (A before E); Theipeann is a **village**, the kingdom is unnamed.

**Strategy context:** finished in the browser simulator → crowdfund → port to **Godot 4** (3D presentation). The simulator is the authoritative prototype of all rules and content.

---

## 2. Canonical build, run, and deploy

- **Canonical dev build:** `simulator/connivances_simulator_v11_6_4.html`. Reads `cards.json` + the loose `art/` folder at load via `fetch`, so edits show on reload. **This file is the authority this pack corresponds to.**
- **Run locally:** `simulator/serve.ps1` → http://localhost:8791 (a PowerShell `HttpListener`; `file://` can't fetch cards.json).
- **Card data:** `cards.json` is the **single source of truth**. `cards.js` is a `file://` fallback (`window.CARDS_DATA = <cards.json>;`), regenerate after edits.
- **Standalone / deploy build ("the embed"):** a build script downscales art to 512px JPEG, base64-inlines it as `window.ART_EMBED`, inlines `cards.json` as `window.CARDS_DATA` → one ~5.4 MB self-contained HTML, copied to `index.html`.
- **Live site:** **connivances.com** = that `index.html` on **AWS S3 behind CloudFront**. Deploy = upload to S3, then **invalidate CloudFront `/index.html`** (CloudFront ignores query strings and otherwise serves the stale cached copy).
- **Print-and-play:** open with `?print=1` for a proof sheet at true **2.5×3.5in** (poker/sleeve), 9 per Letter page, with ×N copies badges.

---

## 3. Engine architecture (the part that matters for Godot)

A single `<script>` with a clean, port-friendly separation:

- **State:** one global `S` — resource pools, `hand`/`deck`/`discard`/`permanents`/`legend`, ~40 per-turn flags, market arrays, monster/Portal state, and per-mode sub-state (`S.duel`, `S.castle`, `S.tree`, treant/house, Minotaur, etc.). Rebuilt by `resetGame()`.
- **Rules:** mostly-pure logic (`calcVP`, `permAtkBonus`, combat/attack resolvers, monster AI, Auspice math, per-mode turn handlers). Almost no DOM dependency — **the layer that ports to Godot nearly 1:1.**
- **Render:** DOM functions rebuilding UI via `innerHTML` (`render`, `buildPermCard`, `cardFrameHTML`, zone renderers). Thrown away and rebuilt as Godot scenes.
- **Mode framework:** `GAME_MODE` / `MODES` (dropdown list) / `S.mode`, dispatched in `resetGame` (setup), `endTurnCore` (enemy/turn phase), and `render` (objective zone). To add a mode: a `MODES` entry + a `setupX`/`xTurn`/`renderXZone` trio + three dispatch lines + per-mode pool filters.
- **Three ATK pools:** `atk_siege` (🔴, ×2 vs walls), `atk_generic` (⚪), `atk_creature` (🟡). Ongoing board offense recomputed each turn by `permAtkBonus()`.
- **Opening hand:** random **5 of a 10-card starter**. Modes with unique starters call **`seedStarterReplaceDA(ids)`** — each forced card *replaces a Devoted Aid* (deck stays 10, hand stays 5); never push onto `S.hand`.

---

## 4. Card data model (`cards.json`)

Arrays: `starter`, `recruits`, `buildings`, `conjurations`, `monsters`, `horsemen`, `auspices`. Full schema + workflow in `CARD_DATA_GUIDE.md`.

**Current counts (verified 2026-10-02):**

| Category | Unique | Notes |
|---|---|---|
| starter | 5 | kn×2, da×5, rf×1, fh×1, ai×1 = **10-card deck** |
| recruits | 46 | five guilds + Augury Initiate + Fallah |
| buildings | 19 | `bg1`–`bg19`; 58 total copies |
| conjurations | 17 | 7 creatures (j1,j2,j3,j6,j7,j9,j10), 3 spells (j4,j5,j8), 7 possessions (p1–p7) |
| monsters | 10 | mn_fiend, mn_nightmare, mn_ghoul, mn_minotaur, mn_stalker, mn_gargantuan, mn_dank, mn_dragon, mn_noxious, mn_portal |
| horsemen | 4 | Conquest(any,8), War(🟡,10), Famine(🔴,9), Death(any+fly,15) |
| auspices | 6 | mystic, hunter, harvest, famine, winter, usurp |

**Global recruit copies by guild:** Warrior 30, Augury Mage 27, Conjurer 24, Builder 22, Farmer 19, Fallah 2. (Four Horsemen mode uses a copy override; see `GAME_MODES.md`.)

---

## 5. Core systems

- **Resources:** **Food** (1 per card played), **Influence** (buy from markets), **3 ATK pools**.
- **Markets:** recruit (6), building (3), conjuration (3); buying refills from that deck; bought cards go to **discard** (deckbuilder cycle), not into play.
- **Unlock gates (per turn):** a **Builder** unlocks buildings; a **Conjurer** unlocks conjurations; a **Siegeman/Warlord** unlocks Siege buildings; an **Oracle** unlocks Libraries/Armories; a **Warrior** unlocks the Dojo.
- **VP / Legend loop (heart of the game, and of PvP):** VP comes from **owning** cards, so greedy buying bloats your deck and dilutes draws. **Legend** is the release valve — a card sent to Legend still scores its VP but **leaves the deck**, banking points while thinning your engine. Game **ends** when the **Portal is closed** OR the **monsters raze all 12 market spaces**; most VP wins. Closing the Portal is only an END trigger, not an auto-win.
- **Auspice:** a 6-omen wheel modifying the game (Harvest boosts Farms, Famine starves them, etc.); changed by Augury cards (Augury Initiate reaches only mystic/harvest; a Channeler reaches any).
- **Walls & siege:** walls are permanents (`isWall`); **Siege (🔴) ×2 vs walls**; two of the same building can form a **Set bonus**.
- **Disable / heal / repair (combat model):** a defeated permanent is **disabled** (`p.disabled`, inert), not destroyed. **Heal** a disabled creature (Cleric/Exorcist/Enforcer) or **repair** a disabled building/wall (House Hand/Contractor grant repair uses → `useRepair`) to re-enable it; `grantMidTurnIncome` re-adds its ATK the same turn.
- **Possessions:** acquiring conjurations can surface a possession (p1–p7) that seizes a market slot until **banished** (spend ATK; kills the covered card) or **dispelled** (Exorcist spares it).
- **Monsters / Portal:** monsters have HP and hidden **unseal conditions** (a Seer reveals one); they advance and disable your permanents; razing all market spaces is the loss.

---

## 6. The seven modes (one-line each; detail in `GAME_MODES.md`)

1. **Creeping Doom** (`creeping_doom`) — the base game vs the Seeping Portal; full pool; the engine PvP is built on.
2. **The Long Winter** (`long_winter`) — the Four Horsemen one at a time, each needing a specific ATK type; pool = all except Granary/Caravans + a copy override.
3. **Tutorial: Augury — The Giving Tree** (`tutorial_augury`) — scripted auspice lesson: nurse a seedling through the seasons (hands you the tool each stage).
4. **Tutorial: Warriors — The Sundering Stone** (`warrior_stone`) — cut down a 20-HP Minotaur before its ward-stone seal breaks; rally Warriors for Muster bursts.
5. **Tutorial: Builders — Storming the Castle** (`builder_castle`) — siege an enemy keep (Wall → Golem → Keep), teaching Siege-vs-walls and Set bonuses.
6. **Conjurer Training — The Summoner's Plight** (`conjurer_house`) — fell a live Treant boss; acquiring conjurations risks possessions that seize markets.
7. **Conjurer Duel — The Rival Summoner** (`conjurer_duel`) — **the PvP trainer**: 1v1 vs a heuristic AI, two castles, all-or-nothing disable combat, heal/repair tug-of-war.

---

## 7. Factions (summary; full intent in `FACTION_IDENTITIES.md`)

- **Builder** — permanents-first, low/slow/steady; walls, siege (the game's shared recurring-ATK engines), morale economy, repair.
- **Augury Mage** — Auspice control, deck-thinning, draw, Harvest food; one burst window (Necromancer + mass mages); no permanents; light on attack otherwise.
- **Conjurer** — summon creatures; wild-magic **possession** risk is the built-in cost.
- **Warrior** — mass not individual power; Muster swarm, Dojo converts Influence→ATK; hard constraint: no early 4–5 ATK spike.
- **Farmer** — Food for everyone; Farmers+Warriors = the pitchfork mob (via Trainer).

---

## 8. Porting to Godot 4 — recommended path

- **Data:** load `cards.json` directly (`FileAccess` + `JSON.parse_string`). No translation.
- **Rules/engine:** translate the pure-logic functions into a **GDScript autoload singleton** (headless, testable); `S` becomes its state; functions port near 1:1. Keep engine-agnostic so it can later back real multiplayer.
- **Render:** rebuild as Godot **scenes** — a `Card` scene (TextureRect art + Labels, themed frame), `Hand`/`Market`/`Board`/castle zones as containers; the engine emits a "state changed" **signal** and the UI updates nodes.
- **Art:** PNGs import as textures; the frame becomes the `Card` scene (see `visual_references/`).
- **Start GDScript-only** (fast, Cursor-friendly); add C# only where profiling demands. First milestone: load cards.json + instance a few `Card` scenes in an `HBoxContainer` to validate the art+data pipeline, then port one mode's turn loop.
- **PvP** (the big least-reversible lift) is intended for Godot's first-class multiplayer post-funding; don't build throwaway HTML netcode.

---

*Keep this current as the mode list / card counts / pipeline change — it is the first doc a new contributor (or a Cursor/Godot session) should read.*
