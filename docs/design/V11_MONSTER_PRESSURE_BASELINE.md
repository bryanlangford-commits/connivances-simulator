# V11. Monster Pressure Baseline (empirical)

**Purpose:** establish the factual starting point for designing V11 monster victory
conditions / "creeping doom." Everything below was measured by driving
`connivances_simulator_v11.html` headlessly, not inferred from reading code.

**Date:** 2026-07-20 · **Build:** `connivances_simulator_v11.html` (post V11-3.x fixes)

---

## TL;DR; three structural facts

1. **Loss is unreachable.** Confirmed empirically, not just asserted (MD Item 23).
2. **The monster queue is corked twice**, and one of the corks is fully player-controlled.
3. **Monster pressure requires the player to own permanents**; so building is punished
   and turtling is rewarded. That is backwards for a doom clock.

---

## 1. Loss is unreachable; confirmed

**Passive-player probe** (plays nothing, buys nothing, attacks nothing; 5 games × 40 turns):

| Metric | Result |
|---|---|
| Games reaching game-over | **0 / 5** |
| `checkLossCondition()` ever true | **0 / 5** |
| Monsters unsealed | **0** |
| Portal ever exposed | **never** |
| Cards still in system | **10 / 10 every game** |

**Why, mechanically:** `checkLossCondition()` requires `noPerms && noCards`.
- `noCards`; cards cycle hand → discard → reshuffle → deck forever. Nothing leaves
  the system except Legend sends (voluntary). So this is essentially never true.
- `noPerms`; `monsterAttackPermanent` only sets `disabled = true`; it never destroys.
  Permanents are removed only when a Caravan expires. So once you own a permanent this
  is never true either.

Both halves are independently unreachable. This is not a tuning problem; there is no
code path to defeat.

**Active-player run** (heuristic bot: plays cards, buys, repairs, attacks; 8 games × 30 turns)
reached the same place: **0/8 wins, 0/8 losses, 0.00 monsters unsealed, 0 permanents ever
disabled**, VP drifting to 65–75 unopposed.

---

## 2. The queue is corked twice

### Cork A. Ghoul Shaman gates the entire queue, on a player-controlled trigger
- `buildMonsterQueue` pins Ghoul Shaman to **position 1 in 30/30 games**.
- Ghoul's unseal condition is `famineEverActive`.
- **Famine is 100% player-elective.** A player who never selects the Famine Auspice
  never unseals Ghoul; and therefore never unseals *anything* (see Cork B).

Measured: passive player, no Famine, 25 turns → **0 monsters unsealed**. Same player with
`famineEverActive` set once → Ghoul unseals on turn 2.

### Cork B; only the position-1 guard is ever evaluated
`runMonsterTurn` Step 2 scans for the first monster that is not `dead|field|siege`,
acts on it, and then **`break`s**. Consequences:

- Monsters at positions 2–4 are **never evaluated for their own unseal conditions**
  while position 1 is still `guarding`.
- A field monster with **no valid target retreats to `guarding`** (Step 1). With no
  player permanents, `monsterPickTarget` returns `null` every turn → the monster
  bounces straight back to `guarding` → position 1 is re-corked, permanently.

Measured: with Famine set, Ghoul unsealed to `field` on turn 2 and was back to
`guarding` on turn 3; then sat there for the remaining 23 turns. Final state across all
four monsters: `guarding, guarding, guarding, guarding`. Only **1 of 4** ever unsealed,
and the Portal was never exposed → **no win path either.**

---

## 3. The incentive is inverted

Monster pressure is *conditional on the player owning targets*:

- No permanents → `monsterPickTarget` → `null` → monster retreats → queue corks.
- Permanents → monsters can act → queue can advance.

So **the safest strategy is to build nothing.** A player who never plays a permanent
faces literally zero monster activity forever, while still accruing VP by buying cards.
For a "creeping doom" this is exactly inverted: doom should be **independent of, or
accelerated by, player passivity**, not switched off by it.

---

## 4. What this means for designing V11 victory conditions

The design cannot rest on the current chassis without addressing:

- **A doom source that does not depend on player permanents.** Today, no targets = no
  pressure. A creeping doom needs a clock that advances regardless (turn count, portal
  corruption, deck decay, market strangulation).
- **Queue advancement independent of position-1.** Cork B means only one monster can
  ever be "live." Either evaluate all guards each turn, or make unseal conditions
  global rather than positional.
- **Unseal triggers that aren't player-elective.** Ghoul's Famine gate lets the player
  simply decline to start the game's threat system. Time- or state-based triggers the
  player cannot opt out of would fix this.
- **An actual defeat state.** Something must be able to *leave* the player's system
  permanently; cards destroyed/exiled, permanents destroyed (not just disabled), or
  market slots shut down. R2 (blocked monsters strangle Recruit market slots
  permanently) is already the ruled answer and directly supplies this; it is blocked
  on items 53–57.

**Relevant existing rulings/items:** R2 (market strangulation → loss pressure),
Item 23 / 21-B (no reachable loss), Items 53–57 (Monster Ability system, cut-off tier,
recruit-slot destruction, retreat reconciliation, field turn order).

---

## 5. Caveats on method

- The active-player bot is **heuristic and weak**; it built only ~1.3 permanents per
  game on average. Treat its *balance* numbers (VP totals, buy patterns) as unreliable.
- The **reachability** findings do not depend on bot quality: the passive probe is a
  worst-case bound, and Cork A/B were verified directly against the state machine.
- No conclusions here are about whether the game is *fun*; only about what states are
  mechanically reachable.
