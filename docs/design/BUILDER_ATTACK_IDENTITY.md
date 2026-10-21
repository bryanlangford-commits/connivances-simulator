# Builder Attack Identity (design pass)

Owner: Design Lead. Status: recommendation for review. Numbers deferred to `tcg-designer`.

> **UPDATE (Path A adopted):** Bryan chose "revive the Warrior swarm"; see the
> companion `WARRIOR_SWARM_AND_BUILDER_MORALE.md`. Two changes land back here:
> (1) Siegeman loses its Siege market-unlock, so **Builders become the sole Siege
> market key** — Route A (basic siege) is reinforced, not weakened. (2) The
> building-side "Morale" keyword is the durable counterpart to the Route B
> "war-works" recruit; `tcg-designer` decides whether they are one design or two.
> Everything below still holds; read the two docs together.

Answers Bryan's three questions: (1) add new Builder recruits? (2) what is the
Builder's self-sufficient attack that is not "worse Siegeman"? (3) how to
consolidate the redundant repair builders.

Anchored to `FACTION_IDENTITIES.md` (Builders: permanents-first, passive boosts
+ **direct attack abilities per turn**, low/slow/steady, engines shareable, they
repair) and to `WARRIOR_GUILD_REVIEW.md` (Siegeman / Siege-gate discussion).

---

## 1. Identity call (one line)

**Builders win by OUT-BUILDING: a wide board of cheap, durable engines that each
add a little recurring ATK, summed over many turns and kept standing by repair.
Warriors win by OUT-WIELDING: amplifying a few engines into one spike.**

Same siege buildings, opposite verb. The Warrior (Siegeman) reads "+1 🔴 per
active Siege permanent" and wants *few engines, big multiplier, one exposure
window*. The Builder wants *many engines, no multiplier needed, every turn*.
Builders are the war **economy**; Warriors are the war **blow**.

This is not "Builders do worse siege." It is a different axis: **breadth and
uptime, not amplitude.** A Builder never out-damages a Siegeman turn per engine;
a Builder out-accumulates by fielding more engines and repairing them so the
recurring total actually banks turn after turn, which is the exact thing that
collapses for every other faction once monsters start disabling the board
(see `WARRIOR_GUILD_REVIEW.md` B1.x: rival curves "collapse if any Siege piece
is disabled"). Builders are the one faction that keeps firing.

---

## 2. Two Builder attack routes

The faction owns two channels. Keep them distinct so the mode never plays as
"siege-mandatory" (the Storming the Castle problem, see §5).

### Route A. Self-sufficient BASIC siege (the durability route)

- Builders already unlock Siege natively (any Builder recruit; MD §7 market gates).
  No Siegeman required. **This route needs zero new cards to exist.**
- The Builder edge over other siege users is **uptime, not damage**: repair keeps
  Catapult (+1 🔴) and Trebuchet (+2 🔴) standing, and Wall Sets (+2 DEF to
  Creatures & Siege) keep them above the disable threshold. A Builder fields 3-4
  siege engines and keeps them all alive; a Warrior fields fewer and spikes them.
- Design intent: a pure-Builder deck reaches a **basic** siege win (stack recurring
  🔴 across several kept-alive engines) without any amplifier. Slow, steady, safe.

### Route B. The "war works": non-siege recurring ⚪ (the direct-attack route)

This is the missing piece and the answer to Bryan's Q2. The faction doc promises
"**direct attack abilities per turn**," and today **no Builder recruit produces
any ATK** and the only ⚪ engine (War Room) is impractical (§5). Two additions
fix it, both on-theme and both low technical risk:

- **B1. A "war-works" recruit that converts board breadth into per-turn ⚪ ATK.**
  Pattern already exists in-engine: Handler (c-guild) gives "+1 🟡 per active
  creature permanent." The Builder mirror is "+X ⚪ per active **building** (or per
  active engine-subtype building)." This is literally the faction's "direct attack
  abilities per turn" clause, delivered. It rewards breadth (many cheap Farms /
  Walls / engines) rather than a multiplier, so it is the Builder verb, not the
  Warrior one.
  - ⚠️ **Combo-prevention flag to `tcg-designer`:** "+1 ⚪ per active building"
    over a wide cheap board is an uncapped ATK printer and can early-spike. Gate
    it: count only a **subset** of subtypes (e.g. Siege + Armory, not Farm/Wall),
    and/or hard-cap the grant, and/or make it scale with Builder count so it ramps
    slow. Must be provably incapable of an early 4-5 ATK spike, same constraint the
    designer set for Warriors.

- **B2. An affordable, pairable recurring-⚪ engine building.** War Room delivers
  the right effect (+1 ⚪/turn on set) but is mispriced for its own payoff: 11 Inf
  each, needs a pair = **22 Inf** before it does anything (§5). Give the Builder a
  **cheaper Armory-subtype sibling designed to actually pair**, so "build two, get
  recurring ⚪" is a real turn-6-8 play, not a turn-14 fantasy. This is a data
  clone of the existing `bg13` COMPLETION_BONUSES entry (`+1 ⚪ Generic ATK/turn`,
  recurring), so engineering lift is near zero.
  - Alternatively (simpler, fewer cards): **reprice War Room down** and let the
    single card carry a small always-on ⚪ so it is not dead before it pairs.
    `tcg-designer` picks between "new cheap sibling" vs "reprice War Room." I lean
    reprice: fewer SKUs, and it fixes the tutorial directly.

Route B is the "distinct Builder attack route that isn't just siege" Bryan asked
for. Together, A + B give the faction a siege win **and** a non-siege ⚪ win, both
self-sufficient, both breadth-based.

---

## 3. Should we add recruits? Yes; the order has room.

Builders have 7 recruits vs Warriors 9 / Augury 10 / Conjurers 9. Grow to ~8-9
**types**, but per Bryan's steer, **fewer types with more copies**, not sprawl.

| Add | Archetype | Role | Rough copies |
|---|---|---|---|
| **War-Works Operator** (keystone, §B1) | per-turn ⚪ from active buildings | delivers "direct attack per turn"; the non-siege win | 2-3 |
| *(optional)* **Quartermaster / Re-armer** | on play: restore a disabled Siege engine to active + it fires this turn | doubles down on uptime (Route A) without copying Siegeman's multiplier | 1-2 |

Notes:
- The **War-Works Operator is the only must-add.** Without it the faction's own
  identity text ("direct attack abilities per turn") is unfulfilled.
- The Quartermaster is optional and overlaps Bryan's revised Siegeman ("repairs
  Siege"). If Siegeman already re-arms siege, **skip it**; Builder repair (§4)
  plus Wall Sets already cover siege durability. Flagging so we don't build the
  same effect twice across two factions.
- Do **not** print flat ATK on a recruit. Builder ATK should always come **through
  a permanent** (per-building conversion, or an engine building), never as a number
  on the recruit itself. Keeps the "engines, wielded" fantasy intact and keeps the
  early-spike guarantee.

---

## 4. Repair consolidation (Bryan's Q3)

Today three of seven recruits are near-redundant repair cards:

| id | Card | Effect | Problem |
|---|---|---|---|
| b1 | House Hand (x7) | +2 Inf, unlock, Repair 1 | fine as baseline |
| b2 | Repair Master (x4) | +3 Inf, unlock, Repair 1 | near-dupe of b1 (only +1 Inf differs) |
| b3 | Contractor (x3) | +2 Inf, unlock, Repair 2 | the "heavy" repair |

**Recommendation: collapse three repair types to two (light / heavy).**

- **Keep House Hand (b1)** as the cheap baseline: +2 Inf, unlock, Repair 1. High
  copies (it is also the tutorial's starter card).
- **Merge Repair Master (b2) into Contractor (b3).** Keep one heavy-repair card
  (Repair 2, unlock, ~+2-3 Inf); raise its copy count to absorb the freed slot.
  Repair Master's only distinction was +1 Inf, which is not worth a card type.
- Net: **2 repair types, more copies each** (e.g. ~7 House Hand + ~4 Contractor),
  exactly Bryan's "4 House Hands, 4 Contractors/Repair Masters" steer. Frees a
  design slot for the War-Works Operator without growing the type count.
- Repair remains 100% Builder-exclusive; it is the durability pillar that makes
  Route A work. Do not dilute total repair volume, just the number of distinct
  cards. `tcg-designer` sets final Inf values and copy counts.

---

## 5. The Storming the Castle trigger (why this pass exists)

The Builder tutorial exposed the gap. Its recruit pool is `b1, b5, b6, f3, f4`
and its building pool is `Farm, Wall, Siege, Library, Armory` subtypes. Result:
**the Builder generates no native ATK except by buying Siege**, so the mode plays
as siege-mandatory. The coaching text names the **War Room** ⚪ set bonus as the
alternative, but War Room is 11 Inf and needs a pair (22 Inf) to fire, so it is
never a real turn-6-8 play in a tutorial. The named alternative is a trap.

Fixing Route B fixes the tutorial directly:
- With a **pairable/affordable recurring-⚪ engine (§B2)**, "build two war works →
  +⚪/turn" becomes the reachable non-siege line the coaching already promises.
- With the **War-Works Operator (§B1)**, the Builder pool finally produces ⚪ from
  its own recruits, so "raise a war-economy and batter it down" is literally true
  and not siege-only.
- Recommend `tcg-designer`/mode owner add the War-Works Operator (or the repriced
  War Room) to the `builder_castle` allow-list once numbers land, so the tutorial
  teaches breadth-ATK, not just siege.

---

## 6. How Builder siege must differ from Siegeman siege (summary table)

| | Warrior / Siegeman | Builder |
|---|---|---|
| Verb | Out-wield: amplify | Out-build: accumulate |
| Engines | few, boosted | many, plain |
| ATK shape | spike in one window | steady every turn |
| Multiplier | yes (+1 🔴 per Siege permanent) | **no** (basic siege, unamplified) |
| Uptime | fragile (collapses if disabled) | durable (repair + Wall Sets) |
| Non-siege ATK | none | ⚪ war works (Route B) |
| Fantasy | the decisive blow | the war economy |

Both use the same Siege buildings; sharing is by-design (faction doc: "engines of
war can be wielded easily by other factions"). Siegeman staying strong at siege is
**correct**, not a problem, once Builders own breadth + uptime + a non-siege ⚪
route instead of competing on amplitude.

---

## 7. Handoffs

**To `tcg-designer` (numbers + combo safety):**
- War-Works Operator: exact ⚪-per-building rate, which subtypes count, the hard
  cap, copy count. **Must be provably incapable of an early 4-5 ATK spike** (same
  bar as Warriors). This is the highest-risk item; treat the cap as load-bearing.
- Route B building: choose **reprice War Room** vs **new cheap Armory-subtype
  sibling**; set Inf cost so a *pair* is affordable by ~turn 6-8. Design lead leans
  reprice (fewer SKUs).
- Repair consolidation: final Inf values and copy counts for House Hand + merged
  Contractor; keep total repair volume roughly constant.
- Confirm whether revised Siegeman already re-arms Siege; if so, cut the optional
  Quartermaster to avoid duplicate effects across factions.

**To engineering (feasibility, not mine to rule):**
- Low risk expected: War-Works Operator mirrors existing Handler ("+X per active
  permanent"); the Route B engine is a data clone of the live `bg13` recurring-⚪
  COMPLETION_BONUSES entry. Please confirm no hidden coupling before we spec final.

**To mode owner:** add the chosen Route B card to the `builder_castle` allow-list
so the tutorial stops being siege-mandatory (§5).
