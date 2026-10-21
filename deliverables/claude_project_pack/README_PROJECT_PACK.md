# CONNIVANCES. Claude Project Upload Pack

Everything the Claude.ai project needs to reason about the game at its **current**
state (v2.3 / build v11.6.4). Drop these into the project's knowledge.

## What to upload

| File | What it is | Priority |
|---|---|---|
| **CONNIVANCES_Master_Rules_v2_3.md** | The complete, current rulebook. The **v2.2 → v2.3 change log at the top is authoritative**; the legacy body is retained with ⚠️ v2.3 banners where superseded. | **Required** |
| **GAME_MODES_v11_6.md** | The four shipped modes (Creeping Doom, Long Winter, Augury tutorial, Sundering Stone); pools, setup, antagonist behaviour, win/loss, and the "iron rule." | **Required** |
| **cards.json** | Single source of truth for every card (auspices, starter, recruits, buildings, conjurations, monsters, horsemen). | **Required** |
| **CARD_DATA_GUIDE.md** | How `cards.json` works; field reference, add/change workflow, and the data-vs-behavior rule. | Recommended |
| **FACTION_IDENTITIES.md** | Designer-intent "spirit of each guild." Check card ideas against this. | Recommended |
| **connivances_sim_v11_6_4_EMBEDDED.html** | The playable standalone (you already have this from `deliverables/`). Not "knowledge," but keep it alongside so the project and the build stay in lockstep. | Have it |

## Precedence (when two sources disagree)

1. **`cards.json`**; for any card's data (cost, stats, text, flags, gating).
2. **Master rules v2.3 change log (top)**; for rules/behaviour.
3. **`GAME_MODES_v11_6.md`**; for anything mode-specific.
4. The legacy body of the master rules; history only; a ⚠️ v2.3 banner means that
   passage is superseded by items 1–3.

## One-line orientation for the project

> Connivances is a 3D deck-builder with TCG mechanics (target engine: Godot),
> prototyped in a single-file HTML simulator. Card data is externalized to
> `cards.json`; the same cards run across four game modes and must behave
> **identically** in each; only pool, setup, antagonist, and win/loss differ.

## Keeping this pack current

- Re-export this pack whenever card data or rules change: update `cards.json`, add a
  bullet to the master's **v2.2 → v2.3 change log**, and (for mode work)
  `GAME_MODES_v11_6.md`.
- The deep engineering-reconciliation detail lives in
  `docs/design/MD_UPDATE_QUEUE_v2_3.md` (not needed by the project, but it's the
  source these summaries were folded from).

_Generated from the local repo on 2026-09-06. Build: `connivances_simulator_v11_6_4.html`._
