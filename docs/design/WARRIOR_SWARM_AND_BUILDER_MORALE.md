# Path A: Warrior Swarm + Builder Morale (design pass)

Owner: Design Lead. Status: recommendation for review. Companion to
`BUILDER_ATTACK_IDENTITY.md`. Specs-only; all numbers, keyword mechanics, and
card templates deferred to `tcg-designer` (briefed in parallel).

Bryan picked **Path A: revive the Warrior swarm.** This doc gives the identity
structure; the Builder spec still holds for the Builder attack line, with the
reconciliation note added to its header.

---

## 0. The reframe (why the overlap existed)

The Warrior/Builder siege overlap was never the intended design. It came from a
**tutorial-conciseness decision**: Siegeman was given the power to *unlock/purchase
the Siege market* so the Warrior tutorial would not confuse new players, who were
lost on why Warriors "couldn't attack" and whose market cards did not deliver the
intended "army running across the field together" fantasy.

That patch over-powered Siegeman and **colonized the Builders' siege turf.** Path
A undoes the patch and restores the original split:

- **Warriors = an ephemeral SWARM.** Rally many foot soldiers; burst ATK **this
  turn** from numbers fighting together; the cards then **fleet off to the
  discard**. Light board, **no heavy permanents.**
- **Builders = the permanents/engines** behind the line (siege, encampments,
  walls). The war economy. See `BUILDER_ATTACK_IDENTITY.md`.
- **Siegeman = the crossover** who *operates* Builder-made siege. He amplifies and
  repairs engines he did not open.
- **Dojo = the one sanctioned building** a Warrior touches: where they train,
  converting Influence to ⚪ ATK.

Net: Warriors get ATK from **swarm cards + Dojo**, not from siege. Builders own
siege and the engine board.

---

## 1. Warrior swarm identity (one line)

**Warriors win by RALLYING: many cheap bodies played in one turn that fight
together for a burst of ⚪ THIS TURN, then fleet to the discard. Mass, not
permanence; the blow, not the board.**

Design properties:
- **Ephemeral.** Swarm output is turn-scoped ATK. Nothing persists on the board
  (Dojo is the lone exception, a building, not a swarm unit).
- **Scales with count, not power.** Value comes from *how many* Warriors hit the
  table together (Vanguard's "Muster: 3+ Warriors → +2 ⚪" is the seed). No single
  Warrior is strong; five together are overwhelming. This is the faction's stated
  "MASS, not individual power" identity (`FACTION_IDENTITIES.md`).
- **Two burst valves, both throttled:**
  - **Swarm cards** (below) that read off the turn's Warrior count.
  - **Dojo**, converting the Influence the swarm generates (Negotiator/Warlord)
    into ⚪ ATK at a fixed ratio.
- **Presents almost no board** to Creeping Doom monsters (no permanents to disable),
  which is a deliberate profile per the cross-faction notes.

### 1a. Swarm card templates (direction, numbers to tcg-designer)

The existing Warrior kit is already 80% a swarm engine; it just lacks the terminal
ATK payoff. Templates to fill in, keyed off "Warriors played this turn":

| Template | Reads | Shape | Notes |
|---|---|---|---|
| **Muster payoff** (Vanguard w9 seed) | count of Warriors this turn | +⚪ ATK at a threshold (3+, 5+) | the core "fight together" burst; add 1-2 more Muster cards so the payoff is reliable, not a single-copy hope |
| **Rally / battle-cry** | per additional Warrior this turn | small +⚪ each, ephemeral | linear-with-count burst; the swarm's bread and butter |
| **Charge finisher** | requires N Warriors already played | one larger +⚪ spike, discard after | the decisive-turn cap; gated behind the swarm being assembled |

Constraints for `tcg-designer`:
- ⚠️ **HARD: no early 4-5 ATK spike** (`FACTION_IDENTITIES.md` Warrior constraint).
  Muster/Charge thresholds must be unreachable until the deck can reliably field
  3-5 Warriors in a turn, i.e. mid-game. Provably incapable of an early spike.
- Output is **⚪ Generic** (can target anything), turn-scoped, discarded after use.
- Do **not** print flat ATK on a body with no condition; always gate on count so
  the burst is a swarm reward, never a single-card power spike.
- Farmers feed the swarm via **Trainer** ("Farmers count as Warriors this turn"),
  the sanctioned pitchfork-army crossover. Keep it; it is how the swarm reaches
  its counts cheaply.

---

## 2. Siegeman rework scope

**Keep the card. Strip only the market-unlock.**

| Clause | Today | Path A |
|---|---|---|
| Open/purchase Siege market | **yes** ("buying Siege needs no Builder") | **REMOVED.** Siege market returns to Builders (any Builder recruit opens it). |
| +🔴 to Siege this turn | yes (+1 flat, or Bryan's revised "+1 🔴 per active Siege permanent") | **keep.** Siegeman stays the siege **amplifier/operator.** |
| Repair Siege | (revised) yes | **keep.** He operates and maintains engines Builders built. |
| Self-top-deck | (revised) yes | **keep.** Reliability so the operator shows up for the siege turn. |

Result: Siegeman becomes a **payoff you want to draw** (a multiplier for a Builder-
made siege board), not a **key you must draw** (a market gate). This is the better
card and the on-theme crossover: "engines of war can be wielded easily by other
factions." A Warrior who has invested in a Builder-siege board gets a Warrior-only
amplifier; a Warrior who has not touched siege ignores Siegeman entirely and plays
the swarm.

⚠️ **Consequence to hand to `tcg-designer` / mode owner:** stripping the gate means
**a pure-Warrior deck with no Builder cannot open the Siege market at all.** That
is intended (Warriors are not a siege faction), but it changes the `warrior_stone`
tutorial pool, which today grants Siege access through Siegeman. See §4.

This also resolves the `WARRIOR_GUILD_REVIEW.md` "Option C" open question (W4/W9)
in the opposite direction from that doc's lean: Path A does **not** broaden the
Warrior siege gate; it **removes Warriors from siege** and gives them the swarm
instead. Flagging so the two docs are not read as contradictory: Option C is
superseded by this decision.

---

## 3. Dojo's crossover role

The Dojo is the **one sanctioned building** a Warrior deck buys: "where they train
for the fight and convert their Influence into attack" (`FACTION_IDENTITIES.md`).

- It is the Warriors' **only recurring-conversion** to ATK and their **only
  permanent.** Everything else the swarm does is ephemeral.
- It is the **second burst valve**: the swarm generates Influence (Negotiator +
  Warlord scale superlinearly with Warrior count; the review measured 18 Influence
  on a 5-Warrior turn), and Dojo turns that Influence into ⚪ at a fixed exchange
  (3:1 today). An 18-Influence turn is ~6 ⚪ through Dojo, **on top of** the swarm's
  own Muster/Rally burst.
- Keep the Dojo gated to a Warrior recruit (not a Builder). This is the correct,
  narrow crossover, and settles that a Warrior-gated Influence→ATK pipe is on-theme.
- ⚠️ Open number (from the review, W1/W6): the Dojo exchange ratio and any per-turn
  cap. Hand to `tcg-designer`; the swarm changes the context (Dojo is now the
  Warriors' primary siege-replacement channel, so its ceiling matters more).

---

## 4. HARD CONSTRAINT: the Sundering Stone must still beat the Minotaur

The Warrior tutorial is a **damage race** to break a shared 100-HP Boulder; the
player wins if their cumulative damage >= the Minotaur's when the Boulder hits 0
(ties go to the player). Alt win: kill the Minotaur (28 HP) and finish the rock
uncontested. The Minotaur smashes for ~3 scaling up, with telegraphed War Cry
(wind-up), Gore (disables a weapon), Guard (halves your strike), and heals +5.

Today the tutorial pool leans on Siege (Siegeman/Warlord open it). Path A removes
the Warriors' siege access, so **the tutorial must be re-based onto swarm + Dojo.**

### 4a. Why swarm + Dojo clears it (feasibility sketch)

The race is long (100 HP) and slow, which suits a mid-game swarm curve; there is no
early-spike requirement to clear it. Illustrative Warrior turn once the deck is
online (exact numbers to `tcg-designer`):

- Field 4-5 Warriors in a turn (Pikeman/Swordsman/Trainer draw-and-chain make this
  reliable; Trainer converts Farmers into bodies).
- **Swarm burst:** Muster + Rally payoffs off a 4-5 count → ~4-6 ⚪ this turn.
- **Dojo:** the same turn's Influence (Negotiator/Warlord, ~12-18) → ~4-6 ⚪.
- **Combined ~8-12 ⚪ on a peak turn**, striking the Boulder, vs the Minotaur's
  ~3-5/turn. The player out-paces the race across repeated swarm turns.

Because the swarm output is **⚪ Generic**, Gore (which disables a *weapon
permanent*) has little to bite on: the swarm has no permanents to gore, only the
Dojo. That is a **structural advantage** of the swarm in this specific tutorial and
should be surfaced in the coaching ("the Minotaur gores engines; you have none to
gore, only rally more soldiers").

### 4b. Retune requirements (to tcg-designer + mode owner)

1. **Re-base the `warrior_stone` pool** off Siege: allow buildings `Farm, School`
   (Dojo) only; **drop Siege**. Add the swarm payoff recruits (Vanguard w9 + the
   new Muster/Rally cards) and keep Pikeman/Swordsman/Trainer/Negotiator/Warlord so
   the count-and-Influence engine assembles.
2. **Guarantee the swarm can assemble by ~turn 4-6** (opening-hand seeding, as the
   Builder tutorial already seeds a House Hand). A tutorial must not be luck-gated.
3. **Prove the clear:** the swarm+Dojo curve must reliably beat the Minotaur's
   scaled damage across the race. `tcg-designer` sets swarm/Dojo numbers; QA
   (`qa-lead`) should verify win-rate on the re-based pool before it ships. **This
   is the gate on the whole Siegeman change** — do not strip Siegeman's market
   unlock in the tutorial build until the swarm clear is measured.
4. **Coaching rewrite:** replace "Siegeman opens Siege" framing with "rally the
   warband, fight together, train at the Dojo." The tutorial should teach the swarm,
   which is the fantasy the original patch failed to deliver.

---

## 5. Builder "Morale": buildings that grant ATK (identity-level eval)

Bryan's proposal: a tag like **"Morale: +1 ATK to all XXX"** on Builder buildings
that otherwise would not hold weapons; a **permanent with a recurring per-turn
effect.** This is the building-side expression of the Builder's "out-build" attack
(complements the recruit-side "war works" in `BUILDER_ATTACK_IDENTITY.md` §B).

### 5a. Identity read: it fits, with a guardrail

- On-theme: it makes **buildings** the source of Builder ATK (not siege, not
  recruits), which is exactly "permanents that add passive boosts and direct attack"
  and keeps Builders as breadth-over-time, not spike.
- It is the Builder analogue of the Warrior's Muster: Muster reads Warriors *this
  turn* and vanishes; Morale reads the *standing board* and recurs. Same "strength
  in numbers" fantasy on the two opposite time-scales (ephemeral vs durable). That
  symmetry is good design and worth preserving as the explicit contrast.

### 5b. Balance risks (flag to tcg-designer; do not resolve here)

- ⚠️ **Recurring ATK over a wide, durable, repaired board is the game's strongest
  ATK shape.** "Morale: +1 ⚪ to all buildings" across 5-6 permanents that Builder
  repair keeps standing is a large, disable-resistant, every-turn total. This is the
  same uncapped-printer risk flagged for the "war-works" recruit. Gate it: cap the
  count that benefits, restrict *which* subtypes carry or receive Morale, and/or
  make Morale a **set-completion** payoff (via the existing `COMPLETION_BONUSES`
  system) so it costs a pair rather than firing off one cheap building.
- ⚠️ **Slow-ramp guarantee.** Like every ATK source in this game, Morale must not
  enable an early spike; its breadth should take real turns to assemble.
- ⚠️ **Interaction with Siege and War-Works.** Morale + basic Siege + the War-Works
  recruit could triple-dip on the same board. `tcg-designer` must budget the three
  Builder ATK channels together so their sum is "steady and eventually lethal," not
  "faster than the swarm's peak."

### 5c. Neither faction may end up deficient

The two identities must stay in their lanes and neither should dominate:

| | Warrior swarm | Builder Morale/out-build |
|---|---|---|
| Time-scale | one-turn burst | recurring per turn |
| Board | ~none (ephemeral) | wide, durable |
| Peak | **higher** single-turn spike | lower per turn |
| Sustain | **lower** (must re-rally each turn) | **higher** (banks every turn) |
| Disable-resilience | high (nothing to disable) | high (repair) but board-dependent |

Design rule to hand down: **the swarm should own the higher single-turn peak; the
Builder should own the higher cumulative-over-time total.** If Morale's recurring
board out-peaks a swarm turn, the swarm is deficient and the identity collapses
(Warriors become "worse Builders"). If the swarm's burst also sustains turn over
turn, the Builder is deficient. `tcg-designer` tunes so the two curves cross:
Builders ahead on a long game, Warriors ahead on a decisive turn.

---

## 6. Handoffs to tcg-designer

- **Swarm cards:** exact Muster/Rally/Charge thresholds, ⚪ values, copy counts.
  Provably no early 4-5 ATK spike. Output is turn-scoped ⚪, discard after.
- **Siegeman new block:** rewrite removing the market-unlock clause; keep
  amplifier (+🔴 per active Siege permanent), repair, self-top-deck. Confirm Builders
  become the sole Siege market key.
- **Dojo:** exchange ratio and per-turn cap in the new swarm-primary context (W1/W6).
- **Sundering Stone retune:** swarm+Dojo numbers that provably clear the Minotaur on
  the re-based (no-Siege) pool; hand the win-rate check to `qa-lead`.
- **Morale keyword:** the mechanic itself (subtype scope, cap, set-completion vs
  always-on), its numbers, and the three-channel Builder ATK budget (Siege +
  War-Works + Morale) so the total is steady-not-spiky and stays behind the swarm's
  peak but ahead on sustain.

## 7. Doc reconciliation

- `BUILDER_ATTACK_IDENTITY.md` still governs the Builder attack line. Its Route A
  (basic siege) is **reinforced** by Path A: Builders regain sole ownership of the
  Siege market gate. Its Route B ("war works" recurring ⚪) now sits alongside the
  Morale keyword as the two building/recruit expressions of the same out-build idea;
  `tcg-designer` should decide whether War-Works and Morale are one design or two.
- `WARRIOR_GUILD_REVIEW.md` "Option C" (broaden the Warrior siege gate) is
  **superseded** by this decision. Path A removes Warriors from siege rather than
  widening their access. That doc's other findings (Dojo repricing, pitchfork math)
  still stand.
