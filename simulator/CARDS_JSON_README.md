# Card data is now in `cards.json`

`simulator/cards.json` is the **single source of truth** for every card. The simulator loads
it at startup (locally via fetch; the standalone/project build inlines it as
`window.CARDS_DATA`). Godot will read the same file later. The Tracks `.xlsx` is now just a
**generated snapshot** — regenerated from this JSON on request, never hand-edited.

## Structure
```jsonc
{
  "auspices":     [ ... 4 auspice objects ... ],
  "starter":      [ ... 5 starter cards ... ],
  "recruits":     [ ... recruits (all guilds + Fallah) ... ],
  "buildings":    [ ... buildings ... ],
  "conjurations": [ ... creatures, spells, AND possessions ... ],
  "monsters":     [ ... monsters + The Portal ... ]
}
```

## To ADD a card
1. Find the closest existing card in the right array, **copy its object**.
2. Change its `"id"` to something **new and unique** (e.g. `w10`, `bg17`, `mn_wraith`).
   The id is also the art filename — save art as `art/<id>.png`.
3. Edit the fields (see reference below), then **save cards.json**.
4. Reload `http://localhost:8791/` — the card is in the pool.

## To CHANGE a card
Edit its object's fields in `cards.json`, save, reload. That's the whole loop.

## ⚠️ Important: data vs. behavior
`cards.json` controls a card's **data** — cost, stats, text, flags, and which market it
gates into. If your new card only combines things the engine already does (produce
Influence/Food/ATK, unlock buildings/conjurations, walls, repair, attach, etc.), it works
from JSON alone.

**A genuinely new *ability* still needs engine code** (in `playCard` / the effect handlers),
keyed to the card's `id` or a flag. `effect1`/`effect2` are just the **displayed text** — they
don't *do* anything by themselves. So: new stat-line cards = JSON only; new mechanics = JSON +
a code hook (tell me the ability and I'll wire it).

## Field reference (recruit example)
| Field | Meaning |
|---|---|
| `id` | unique code + art filename (`<id>.png`) |
| `name` | display name |
| `guild` | Warrior / Augury Mage / Builder / Conjurer / Farmer / Starter / Possession / Farm / Factionless |
| `type` | Recruit / Building / Conjuration |
| `subtype` | e.g. Warrior, Farm, Siege, Library, Creature, Spell, Possession |
| `cost_inf`, `cost_food` | purchase cost |
| `vp` | victory points |
| `inf`, `food` | resources produced when played |
| `atk_creature`, `atk_siege`, `atk_generic` | 🟡 / 🔴 / ⚪ attack |
| `def` | defense (permanents) |
| `permanent` | stays in the Kingdom |
| `isWall`, `fly`, `isCreatureType` | structural flags |
| `isWarrior`, `isBuilder`, `isConjurer`, `isSiegeman` | guild-role flags (drive market unlocks & synergies) |
| `requiresBuilder`, `requiresWarrior` | acquisition gates (farms & walls are false = always open) |
| `canLegend`, `drawOnPlay`, `repairCount` | misc behaviors |
| `auspiceTag` | for possessions/monsters: the auspice that buffs them |
| `effect1`, `effect2` | **display text only** |
| `qty` | copies in the market deck |

Monsters use `monsterHp`, `monsterAtk`, `isTrophyMonster`, `auspiceTag`, `auspiceBuffHP`
instead of the recruit economy fields. Auspices use `id`, `name`, `icon`, `cls`, `effect`.

## After editing, to update the project build
Ask for a **re-embed** — the embedder inlines the latest `cards.json` (and art) into the
standalone HTML. To refresh the Tracks spreadsheet, ask for a **Tracks regen**.
