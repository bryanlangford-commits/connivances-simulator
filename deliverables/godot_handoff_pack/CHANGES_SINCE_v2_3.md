# Connivances — Changes since v2.3 / v11.6.4 (authoritative delta)

**As of 2026-10-02.** The previous pack was v2.3 / build v11.6.4 (mid-Sep 2026). Development continued on the **same build number** (`connivances_simulator_v11_6_4.html`) but the content evolved substantially. This file is the **top-precedence rules delta**: where it and the legacy `MASTER_RULES_v2_3.md` body disagree, **this wins**. (For card data, `cards.json` always wins.)

---

## A. CURRENT — now authoritative

### Modes (was 4, now 7)
- **Three modes added / rebuilt:**
  - **Storming the Castle** (`builder_castle`) — Builder tutorial: breach Wall → Golem → Keep; teaches Siege-vs-walls + Set bonuses.
  - **The Summoner's Plight** (`conjurer_house`) — Conjurer tutorial, rebuilt as a **live Treant boss + acquire-triggered possessions** (buying conjurations can loose a possession that seizes a market slot).
  - **The Rival Summoner** (`conjurer_duel`) — the **no-netcode PvP trainer**, 1v1 vs a heuristic AI.
- **Augury tutorial redesigned → "The Giving Tree"** (`tutorial_augury`): a scripted, no-fail lesson nursing a seedling through the six seasons. **Supersedes** the old "reduce a Famine boss to 0."
- **Warrior tutorial redesigned → cut down the Minotaur** (`warrior_stone`): kill a 20-HP Minotaur before its ward-stone seal clock breaks; rally for Muster. **Supersedes** the old "100-HP Boulder damage-race."

### Long Winter (Four Horsemen) — reworked
- Reframed as the land's own buried suffering "uncorked," not Portal invaders.
- **Typed immunity corrected** (from `cards.json`): **Conquest** (HP 8, any), **War** (HP 10, 🟡 Creature), **Famine** (HP 9, 🔴 Siege), **Death** (HP 15, any, flies). **Supersedes** the old Conquest=Siege / War=generic / Death=Creature typing.
- **Pool = all cards except Granary and Caravans**, with a mode-specific copy override (Builder 24 / Warrior 23 / Augury 21 / Conjurer 19 / Farmer 19) so Siege reliably surfaces.

### Combat model — disable, not destroy (formalized in the Duel)
- A defeated permanent is **disabled** (inert), not destroyed; **heal** (creature) or **repair** (building/wall) **re-enables** it, and its ATK re-joins the **same turn** (via `grantMidTurnIncome`). This mirrors the base Creeping-Doom disable/repair and is now the explicit Duel model.
- In the Duel specifically: **all-or-nothing** (attack must meet DEF in one shot — no chip, no carryover, unused attack lost); **walls/keep are real permanents** (so attach/repair/set-bonuses apply); **Siege ×2 vs walls**, **fliers bypass walls**; **breaching a wall does not also take the keep that turn** (defender gets a repair/re-wall turn); the AI **deploys purchases a turn later** (deckbuilder lag) and recruits a Conjurer before it can summon.

### Starting hands — 5 across all modes
- Every mode opens at a **5-card hand / 10-card starter**. Modes with forced starters no longer push onto the hand; each forced card **replaces a Devoted Aid** in the deck via `seedStarterReplaceDA(ids)`. (The Giving Tree keeps its gifted Irrigator in hand and trims an excess Devoted Aid.)

### Card-text corrections (in `cards.json`)
- **Cleric (c7):** "Heal a creature. +2 ⚪ ATK vs Possessions." (It always healed in-engine; the text now matches.)
- **Siegeman (w5) / Warlord (w8):** "You may buy Siege this turn." **Supersedes** "Unlocks the Siege market" (which read like a new market appeared).
- **Master Mason (b10):** "**Remodel**: upgrade one of your buildings (+2 DEF permanently), twice." **Supersedes** the "RAISE" naming ("raise" means burning something down in this world).
- **Repair Master (b2): retired** (`qty:0`); its repair folded into **House Hand** (repair 1) and **Contractor** (repair 2).

### Data / ops
- **Usurp** is now the **6th auspice** present in `cards.json` (was 5).
- **Print-and-play:** open any build with `?print=1` for a 2.5×3.5in proof sheet (9 per Letter page).
- **Siege gating is Siegeman/Warlord only** (the earlier "any Warrior opens Siege — Option C" was reverted). Builder opens the general building market.
- **Deploy:** the live site (connivances.com) is the embed `index.html` on S3 behind CloudFront; a deploy requires a **CloudFront invalidation** of `/index.html`.

---

## B. PARKED / PROPOSED / NOT authoritative (do NOT implement as rules)

These exist as specs or idea banks but are **not** current rules. Do not promote them into the Godot build unless explicitly moved to section A.

- **Occupy keyword** (Conjurer Duel king-of-mountain capture countdown) — spec'd, **not built**.
- **Seer second skill** — a menu of options in `SEER_SECOND_SKILL_OPTIONS.md`; **undecided, not built**. The Seer's current, live skill is only "reveal a hidden monster seal."
- **Networked multiplayer PvP** — design brief only (`PVP_MODE_BRIEF.md`); **not built**; intended for Godot's native multiplayer post-funding.
- **Duel difficulty tiers** beyond "Rival," and an **expanded flier roster** beyond the Gryphon — proposed, not built.
- **Future mode/expansion ideas** — **Hero/Commander mode** (4–6 selectable lore Heroes with native-system powers) and **Portal Hoppers** (PvP where players acquire Portals and command monsters at each other), plus Bankers + gold, Storytellers, Angels & Demons. Captured in `docs/design/MODE_AND_EXPANSION_IDEAS.md` and `EVIL_IDEAS_BANK.md`. **Speculative — earmarked, not built.**

---

## C. SUPERSEDED (historical — ignore if seen in older docs)

- Old Horsemen typing (Conquest=Siege / War=generic / Death=Creature). → See §A.
- Old Augury tutorial (Famine-boss-to-zero). → now The Giving Tree.
- Old Warrior tutorial (100-HP Boulder race vs Minotaur). → now cut-down-the-Minotaur.
- "Any Warrior opens Siege (Option C)." → reverted; Siegeman/Warlord only.
- Master Mason "RAISE." → now "Remodel."
- The templated/legacy fixed opening hand in Master Instructions §12A.1. → opening hand is a random 5 of 10 (with per-mode `seedStarterReplaceDA` substitutions).
