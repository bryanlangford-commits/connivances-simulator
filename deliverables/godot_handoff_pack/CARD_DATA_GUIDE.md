# Connivances — Card Data Guide (`cards.json`)

`cards.json` is the **single source of truth** for every card. The simulator loads it at startup (fetch locally; inlined as `window.CARDS_DATA` in the standalone build); **Godot will read the same file** (`FileAccess` + `JSON.parse_string`). Updated 2026-10-02.

## Structure

```jsonc
{
  "_meta":        { ...version/notes... },
  "auspices":     [ 6 auspices: mystic, hunter, harvest, famine, winter, usurp ],
  "starter":      [ 5 starter defs, each with a qty for the 10-card deck ],
  "recruits":     [ 46 recruits: Warrior, Augury Mage, Builder, Conjurer, Farmer, + Fallah ],
  "buildings":    [ 19: farms, walls, siege, dojo, libraries, armories, granary, caravans, encampments ],
  "conjurations": [ 17: creatures, spells, AND possessions ],
  "monsters":     [ 10: guardian monsters + The Portal ],
  "horsemen":     [ 4: the Long Winter riders ]
}
```

The **Winter** auspice and the **horsemen** carry `"modes":["long_winter"]`; they appear only in that mode. Everything else is shared across all modes.

**Counts (verified 2026-10-02):** starter 5 (10-card deck), recruits 46, buildings 19 (58 copies), conjurations 17 (7 creatures j1/j2/j3/j6/j7/j9/j10, 3 spells j4/j5/j8, 7 possessions p1–p7), monsters 10, horsemen 4, auspices 6. Global recruit copies: Warrior 30, Augury 27, Conjurer 24, Builder 22, Farmer 19, Fallah 2.

## To ADD a card

1. Copy the closest existing card object in the right array.
2. Give it a **new unique `id`** (e.g. `w12`, `bg20`, `mn_wraith`). **The id is also the art filename** — save art as `art/<id>.png`.
3. Edit the fields (reference below), **save `cards.json`**, reload the simulator.
4. Regenerate `cards.js` (the `file://` fallback) and, for the standalone build, re-embed.

## To CHANGE a card

Edit its fields, save, reload. Regenerate `cards.js` after.

## ⚠️ Data vs. behavior — the one rule that trips people up

`cards.json` controls a card's **data**: cost, stats, text, flags, and which market it gates into. If a new card only **recombines things the engine already does** (produce Influence/Food/ATK, unlock buildings/conjurations, walls, repair, attach, draw, heal…), it works **from JSON alone**.

A genuinely **new ability** still needs **engine code** (in `playCard` / the effect handlers), keyed to the card's `id` or a flag. **`effect1`/`effect2` are displayed text only** — they don't *do* anything by themselves. (Example: the Cleric *always healed* in engine code; fixing its `effect2` text to say "Heal a creature" changed nothing mechanically.)

- New stat-line card = **JSON only**.
- New mechanic = **JSON + a code hook**.

## Field reference (recruit example)

| Field | Meaning |
|---|---|
| `id` | unique code + art filename (`<id>.png`) |
| `name` | display name |
| `guild` | Warrior / Augury Mage / Builder / Conjurer / Farmer / Starter / Possession / Farm / Factionless |
| `type` | Recruit / Building / Conjuration |
| `subtype` | Warrior, Farm, Siege, School (Dojo), Wall, Library, Armory, Granary, Caravan, Creature, Spell, Possession, … |
| `cost_inf`, `cost_food` | purchase cost |
| `vp` | victory points |
| `inf`, `food` | resources produced when played |
| `atk_creature`, `atk_siege`, `atk_generic` | 🟡 / 🔴 / ⚪ attack |
| `def` | defense (permanents); in the Duel it is the **disable threshold** |
| `permanent` | stays in the Kingdom |
| `isWall`, `fly`, `isCreatureType` | structural flags |
| `isWarrior`, `isBuilder`, `isConjurer`, `isSiegeman`, `isOracle` | guild-role flags (drive market unlocks & synergies) |
| `requiresBuilder`, `requiresWarrior` | acquisition gates. Farms = both false (always open). Walls/Portcullis/Fortress = `requiresBuilder:true`. **Siege = requiresBuilder, but opens via Siegeman/Warlord** (not any Warrior — the old "Option C" was reverted). Dojo = `requiresWarrior:true`. Libraries/Armories open via an **Oracle**. |
| `canLegend`, `drawOnPlay`, `repairCount` | misc (`repairCount` = repair uses granted on play; House Hand 1, Contractor 2) |
| `revealsSeal` | Seer: reveals a hidden monster unseal condition |
| `auspiceTag` | for possessions/monsters/trophies: the auspice that buffs them |
| `effect1`, `effect2` | **display text only** |
| `qty` | copies in the supply. **`qty:0` = retired** (e.g. `b2` Repair Master, folded into House Hand/Contractor). Note the `expandQty` quirk: `qty||1`, so a `qty:0` card still yields 1 phantom copy in some paths — tune pools via **per-mode overrides**, not by relying on this. |

**Monsters** use `monsterHp`, `monsterAtk`, `isTrophyMonster`, `auspiceTag`, `auspiceBuffHP` and hidden-unseal data instead of the recruit economy fields.

**Auspices** use `id`, `name`, `icon`, `cls`, `effect` (+ optional `modes`).

**Horsemen** (Long Winter) use `id`, `name`, `order` (1–4), `hp`, `woundedBy` (`any` / `siege` / `generic` / `creature`), `icon`, `counter`, `threat`, `effect1`, optional `fly`, and `"modes":["long_winter"]`. Current: Conquest(1, 8, any), War(2, 10, creature), Famine(3, 9, siege), Death(4, 15, any, fly).

## Keeping the fallback in sync

`cards.js` is a generated wrapper (`window.CARDS_DATA = <cards.json>;`) used as the `file://` fallback and the base for the standalone embed. **Regenerate it after every `cards.json` edit:**

```powershell
$json = Get-Content -Raw -Encoding UTF8 cards.json; "window.CARDS_DATA=$json;" | Set-Content -Encoding UTF8 cards.js
```
