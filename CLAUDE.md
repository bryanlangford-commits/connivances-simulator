# Connivances Visual Studios

## Project

A deck-building game with TCG-like mechanics, built in Godot with 3D
presentation. This repo is brand new — no scenes, scripts, or assets exist
yet. Structure below is a starting skeleton, not a fixed convention; adjust
as the project grows.

- **Engine**: Godot 4.x
- **Scripting**: GDScript for gameplay glue, C# for performance-sensitive or
  systems-heavy code. No fixed split yet — decide per-feature.
- **Version control**: not yet a git repository.

## Layout

- `docs/design/` — game design docs owned by the Design Lead agent (GDD,
  mechanic specs, level briefs).
- `docs/qa/` — test plans and bug tracking owned by the QA Lead agent.
- `.claude/agents/` — custom subagents for this project (`design-lead`,
  `qa-lead`). Invoke via the Agent tool with `subagent_type`.

## Agents

- **design-lead** — game mechanics, systems design, feature specs, balancing.
  Writes/maintains docs in `docs/design/`. Defers to `tcg-designer` for
  card-system specifics.
- **qa-lead** — test plans, edge cases, regression review, test code. Writes/
  maintains docs in `docs/qa/` and test scripts alongside game code.
- **tcg-designer** — specialist for the card layer: mana/resource systems,
  keyword/mechanic design, set skeleton, rarity/as-fan, archetype balance,
  combo prevention. Writes/maintains docs in `docs/design/cards/`.
- **pve-pressure-designer** — specialist for the threat layer: doom clocks,
  escalation curves, monster victory conditions, loss states, the Seeping
  Portal pressure model. Owns V11 "creeping doom" design. Distinct from
  `tcg-designer` (card layer).

## Key design docs

- `deliverables/godot_handoff_pack/` — **START HERE.** The current authoritative
  handoff package (source of truth for the Godot port): `README.md` (precedence +
  canonical build), `00_CURRENT_STATE_OVERVIEW.md`, `CHANGES_SINCE_v2_3.md`
  (current vs parked), `GAME_MODES.md` (all 7 modes), `cards.json`, data guide,
  faction identities, visual refs. Supersedes older MDs and the old
  `claude_project_pack` where they disagree. (Snapshot 2026-10-02.)
- `docs/design/CONNIVANCES_Project_Master_Instructions_v2_2.md` — canonical
  rulebook (⚠️ mixes live rules with legacy scaffolding — confirm intent).
- `docs/design/FACTION_IDENTITIES.md` — designer-authored spirit of each
  faction. Check card proposals against the faction's fantasy here.
- `docs/design/V11_MONSTER_PRESSURE_BASELINE.md` — measured baseline of what
  the threat system actually does today.
- `docs/design/MD_UPDATE_QUEUE_v2_3.md` — rule changes queued for the next MD.
- `docs/qa/TEST_PLAN.md` — findings, fixes, and verification status.

## Simulator

`simulator/connivances_simulator_v11.html` is the playable prototype (single
HTML file, embedded JS engine). Run it via `simulator/serve.ps1` (PowerShell
static server on :8791) — `file://` is blocked in the browser tool. Fastest QA
method: drive the engine directly via the browser console (`S`, `calcVP`,
`monsterPickTarget`, `resetGame` are globals) rather than clicking through turns.

Update this file as real folders (e.g. `project.godot`, `scenes/`, `scripts/`)
get added, so agents stay oriented.
