# CONNIVANCES. Card Data Guide (`cards.json`)

`cards.json` is the **single source of truth** for every card. The simulator loads
it at startup (fetch locally; inlined as `window.CARDS_DATA` in the standalone
build); Godot will read the same file. The Tracks `.xlsx` is now a **generated
snapshot**; regenerated from this JSON on request, never hand-edited.

## Structure

```jsonc
{
  "_meta":        { ...version/notes... },
  "auspices":     [ 5 auspices; mystic, hunter, harvest, famine, winter ],
  "starter":      [ 5 starter card defs (each with a qty for the 10-card deck) ],
  "recruits":     [ all recruits; every guild + Fallah ],
  "buildings":    [ farms, walls, siege, dojo, libraries, armories, granary, caravans ],
  "conjurations": [ creatures, spells, AND possessions ],
  "monsters":     [ guardian monsters + The Portal ],
  "horsemen":     [ the 4 Long Winter riders ]
}
```

The **Winter** auspice and the **horsemen** carry `"modes":["long_winter"]`; they
appear only in that mode. Everything else is shared across all modes.

## To ADD a card

1. Find the closest existing card in the right array and **copy its object**.
2. Change its `"id"` to something **new and unique** (e.g. `w10`, `bg17`,
   `mn_wraith`). **The id is also the art filename**; save art as `art/<id>.png`.
3. Edit the fields (reference below), then **save `cards.json`**.
4. Reload the simulator; the card is in the pool.
5. For the standalone build, ask for a **re-embed** (inlines the latest
   `cards.json` + art). For the `.xlsx`, ask for a **Tracks regen**.

## To CHANGE a card

Edit its object's fields, save, reload. That's the whole loop.

## ⚠️ Data vs. behavior; the one rule that trips people up

`cards.json` controls a card's **data**: cost, stats, text, flags, and which market
it gates into. If a new card only **recombines things the engine already does**
(produce Influence/Food/ATK, unlock buildings/conjurations, walls, repair, attach,
draw…), it works **from JSON alone**.

A genuinely **new ability** still needs **engine code** (in `playCard` / the effect
handlers), keyed to the card's `id` or a flag. `effect1`/`effect2` are **displayed
text only**; they don't *do* anything by themselves.

- New stat-line card = **JSON only**.
- New mechanic = **JSON + a code hook** (say the ability; it gets wired).

Example from this cycle: **Warlord's** aura flip (Influence → ⚪ ATK) was a real
behavior change, so it needed both the `effect2` text in `cards.json` **and** three
engine hooks. A pure "+2 Food" card would have needed neither.

## Field reference (recruit example)

| Field | Meaning |
|---|---|
| `id` | unique code + art filename (`<id>.png`) |
| `name` | display name |
| `guild` | Warrior / Augury Mage / Builder / Conjurer / Farmer / Starter / Possession / Farm / Factionless |
| `type` | Recruit / Building / Conjuration |
| `subtype` | e.g. Warrior, Farm, Siege, School (Dojo), Wall, Library, Armory, Granary, Caravan, Creature, Spell, Possession |
| `cost_inf`, `cost_food` | purchase cost |
| `vp` | victory points |
| `inf`, `food` | resources produced when played |
| `atk_creature`, `atk_siege`, `atk_generic` | 🟡 / 🔴 / ⚪ attack |
| `def` | defense (permanents) |
| `permanent` | stays in the Kingdom |
| `isWall`, `fly`, `isCreatureType` | structural flags |
| `isWarrior`, `isBuilder`, `isConjurer`, `isSiegeman` | guild-role flags (drive market unlocks & synergies) |
| `requiresBuilder`, `requiresWarrior` | acquisition gates. Farms = both false (always open). Walls/Portcullis/Fortress/Siege = `requiresBuilder:true`. Dojo = `requiresWarrior:true`. (Engine also opens Siege for **any** Warrior. Option C.) |
| `canLegend`, `drawOnPlay`, `repairCount` | misc behaviors (`repairCount` = repair uses granted on play; e.g. House Hand 1) |
| `auspiceTag` | for possessions/monsters/trophies: the auspice that buffs them |
| `effect1`, `effect2` | **display text only** |
| `qty` | copies in the market deck (or in the starter deck for `starter` cards) |

**Monsters** use `monsterHp`, `monsterAtk`, `isTrophyMonster`, `auspiceTag`,
`auspiceBuffHP` instead of the recruit economy fields.

**Auspices** use `id`, `name`, `icon`, `cls`, `effect` (+ optional `modes`).

**Horsemen** (Long Winter) use `id`, `name`, `order`, `hp`, `woundedBy`
(siege/generic/creature/any), `icon`, `counter`, `threat`, `effect1`, optional
`fly`, and `"modes":["long_winter"]`.

## Regenerating the fallback + snapshot

- `cards.js` is a generated wrapper (`window.CARDS_DATA = <cards.json>;`) used as the
  `file://` fallback. **Regenerate it after any `cards.json` edit** (ask for it, or
  it's a one-line copy of the JSON into the `window.CARDS_DATA=…;` assignment).
- The Tracks `.xlsx` is a generated snapshot; ask for a **Tracks regen** when you
  want the spreadsheet refreshed.
