# Connivances — Godot Handoff Pack

**Snapshot date:** 2026-10-02
**Purpose:** the **source of truth** for the Godot implementation of Connivances. This supersedes the earlier `deliverables/claude_project_pack` (v2.3 / v11.6.4), which is now outdated — development continued afterward (3 new modes, the Duel's disable-combat rework, 5-card hands, card-text fixes). See `CHANGES_SINCE_v2_3.md` for exactly what changed.

## Canonical build this pack describes

**`simulator/connivances_simulator_v11_6_4.html`** (the version number is unchanged since the last pack, but the content evolved). The deployed standalone is `simulator/index.html` (the embed, on connivances.com). `simulator/cards.json` is the live card data this pack's copy mirrors.

## Files

| File | What it is | Priority |
|---|---|---|
| **00_CURRENT_STATE_OVERVIEW.md** | Orientation: what the game is, build/run/deploy, **engine architecture**, card data, systems, the 7 modes, and the **Godot port path**. Read first. | **Required** |
| **CHANGES_SINCE_v2_3.md** | The authoritative **delta** since the last pack, split into **CURRENT (authoritative)** vs **PARKED/PROPOSED** vs **SUPERSEDED**. Top precedence for recent rules. | **Required** |
| **GAME_MODES.md** | The **seven** current modes: pool, setup, antagonist, win/loss, state key, and what was redesigned. | **Required** |
| **cards.json** | Single source of truth for every card. | **Required** |
| **CARD_DATA_GUIDE.md** | How `cards.json` works: schema, field reference, add/change workflow, the data-vs-behavior rule. | Recommended |
| **FACTION_IDENTITIES.md** | Designer-authored "spirit of each guild." Check card ideas against this. | Recommended |
| **MASTER_RULES_v2_3.md** | The full detailed rulebook. **Legacy depth** — correct in general, but partially superseded; defer to `CHANGES_SINCE_v2_3.md` + `cards.json` where they disagree (the file's own v2.2→v2.3 change-log at the top is authoritative for that era). | Reference |
| **visual_references/** | `card_frame_kit.html` (the card frame system), `art_style_bible.html`, `art_prompt_sheet.html` — for building the Godot `Card` scene and matching the art direction. | Reference |

## Source precedence (when two sources disagree)

1. **`cards.json`** — for any card's data (cost, stats, text, flags, gating).
2. **`CHANGES_SINCE_v2_3.md` (section A, CURRENT)** — for recent rules/behaviour.
3. **`00_CURRENT_STATE_OVERVIEW.md` + `GAME_MODES.md`** — for systems and anything mode-specific.
4. **`MASTER_RULES_v2_3.md`** — deep detail/history; a passage it contradicts in items 1–3 is **superseded**.
5. The ultimate tiebreaker is the **live engine** (`connivances_simulator_v11_6_4.html`): if a rule's behaviour is ambiguous, the code is the truth.

## CURRENT vs PARKED (the important distinction)

Everything in `GAME_MODES.md` and `CHANGES_SINCE_v2_3.md` **section A** is **current and authoritative** — implement it. Everything in `CHANGES_SINCE_v2_3.md` **section B** (Occupy keyword, Seer second skill, networked PvP, difficulty tiers, expansion ideas) is **parked/proposed — do NOT implement as rules.** Section C lists superseded ideas to ignore if you see them in older MDs.

## One-line orientation

> Connivances is a deck-builder with TCG mechanics (target engine: **Godot 4**, 3D presentation), prototyped in a single-file HTML simulator. Card data lives in `cards.json`; the **same cards behave identically across all 7 modes** — only pool, starting-deck substitutions, setup, antagonist, and win/loss differ. VP comes from owning cards; **Legend** banks VP while thinning the deck; the game ends when the Portal closes or the monsters raze all market spaces.

## Keeping this pack current

Re-export whenever card data or rules change: update `cards.json`, add to `CHANGES_SINCE_v2_3.md` section A, and (for mode work) `GAME_MODES.md`. The full in-repo design docs live in `docs/design/` (and `docs/qa/`); this pack is the distilled, current, Godot-facing subset.
