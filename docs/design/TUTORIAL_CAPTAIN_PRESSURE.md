# Attack Tutorial, Part 2. The Captain (threat-layer sub-spec)

**Owner:** pve-pressure-designer · **Date:** 2026-11-06 · **Scope:** Warrior attack
onboarding, single-player, Godot client (the oracle).
**Companion:** design-lead owns the master onboarding spec
(`ONBOARDING_COMBAT_TUTORIAL.md`): beat order, flow, and all coach-mark copy. This doc
owns only the Captain as a miniature, telegraphed doom-clock. Card-layer values (Muster
steps, Dojo conversion, any new captain card) hand off to tcg-designer; flagged inline.

**All numbers are first-pass and tunable.** They are chosen to be legible and buildable,
not balanced by playtest. Tune against the arc in §4, not in isolation.

---

## AS BUILT (ruled by Bryan, 2026-11-06) - authoritative

Records what shipped and Bryan's rulings. Where the sections below conflict (Captain
DEF 4, the separate 0-12 War Drum, a `warrior_captain` mode, harmless minotaurs, the
soft-retry), this section wins. The reasoning below is kept as background.

- **This IS the Sundering Stone**, not a separate beat. The encounter was rebuilt in
  place in `warrior_stone` / `ward_stone.gd`. The naming-collision concern in §0 dissolves:
  there is one Warrior tutorial, and we replaced its contents. No `warrior_captain` id.
- **Captain: DEF 6, ATK 2** (was DEF 4). Bryan confirmed the Warrior market reaches 12+
  attack per turn, so 6 is comfortably one-shottable; the challenge is timing the buildup
  against the clock. Felled in one strike of 6 = win. The §4 DEF-4 ceiling is superseded.
- **The doom clock is the Sundering Stone itself** (integrity 30), not a separate 0-12 War
  Drum. It erodes each enemy turn by the summed ATK of every living foe: four raiders at 1
  plus the Captain at 2 = 6/turn at full board, slowing as raiders fall. Same spirit as
  the drum (more alive, faster clock), fewer moving parts. The telegraph is the objective
  line (stone integrity, raider count, "Captain Musters next turn").
- **Raiders: DEF 3, ATK 1** (was DEF 1, harmless). They do erode the Stone, so clearing
  them is a legitimate stall that buys clock, exactly the §4 arc, but they are not harmless.
- **Muster: every 3 turns, first on turn 3, revive fallen raiders to a full four.** Matches
  §2 as built.
- **Win = fell the Captain**, even with raiders afield; the fight ends there. Matches §4.
- **Not built in v1:** the no-terminal-loss soft-retry and the 2nd-retry mercy lever (§5).
  Crumbling the Stone is currently a hard defeat. Add soft-retry later if the no-fail
  onboarding feel is wanted. Captain art supplied (`art/mn_captain.webp`); no placeholder
  needed.

**Open questions (§ bottom), answered:** (1) not a standalone mode; it is `warrior_stone`,
rebuilt in place. (2) mercy lever deferred with the soft-retry, not in v1. (3) the Captain
threatens the Stone (ATK 2 erosion), not the player's board; no Gore/disable in this
tutorial. (4) DEF 6 is reachable per Bryan; tcg-designer may still confirm the ramp hits 6
by ~turn 3.

---

## 0. Where this sits

The attack beat has two parts. Part 1 (design-lead) teaches the raw verb:
**use-it-or-lose-it attack** (attack is allocated fresh each turn; unspent points are
gone, nothing carries over) plus **all-or-nothing** targeting (an allocation must meet a
target's DEF in one shot; overkill and leftovers are wasted). This is the real combat
model already formalized for the Duel (`CHANGES_SINCE_v2_3.md §22`); the tutorial teaches
the real rule, not a toy version.

Part 2 (this doc) keeps that verb and adds the first **source-of-escalation** lesson. It
is the new player's first taste of the Seeping Portal's creeping-doom model: a clock that
advances on its own, that you can slow by managing symptoms, but that you only **win** by
removing the source. In training wheels: you cannot lose terminally here (§5), but you can
feel the squeeze and you can fail-soft.

> **Naming collision flag (design-lead):** `warrior_stone` / "The Sundering Stone" is a
> separate, later Warrior tutorial (20-HP Minotaur on a ward-stone seal clock). This beat
> is an earlier attack-fundamentals lesson and must not reuse that mode id, that Minotaur,
> or that clock. Pick a distinct id (suggest `warrior_captain` or fold it into the
> onboarding flow state). Calling both "the Minotaur tutorial" will confuse everyone.

---

## 1. The board

A single legible rank in the field zone:

- **Four Minotaurs, DEF 1 each (1 HP).** The chaff. One point of attack fells one
  Minotaur (meets DEF 1). Dumping 4 attack onto one Minotaur wastes 3 (all-or-nothing, no
  carryover). They are the Part-1 allocation lesson restated: *spread one point each*.
- **One Captain, DEF 4.** The source. Targetable from turn 1 (no taunt, no blocking;
  see §4 for why that is deliberate). Deals **no direct damage** to the player's board in
  this beat (reasoning in §6). Its only outputs are the Muster pulse (§2) and driving the
  War Drum (§3).

Minotaurs are harmless. That is the point: they are the tempting-but-wrong target. The
only target that *wins* is the Captain.

---

## 2. The Muster pulse (the escalation)

**What it does: the Captain rallies his fallen.** On a pulse, every downed Minotaur rises
back to the line at 1 HP, up to the original **4**. It never summons a fifth. The rank is
self-capping; the board cannot spiral.

**Why "revive the fallen line" over the alternatives:**

| Option | Verdict |
|---|---|
| **Revive downed Minotaurs to the line (chosen)** | Teaches "you keep killing them and they keep coming back" in one glance. Self-capping at 4, so it can never spiral. Pure Warrior fantasy: the Captain *Musters* the mob back up, mass over individual power (FACTION_IDENTITIES). |
| Summon a brand-new Minotaur | Same flavor but unbounded; risks a runaway board, the thing the pressure model forbids. Rejected. |
| Buff Minotaur ATK | Requires the Minotaurs to attack the player, which imports a whole damage-race this beat does not need, and punishes a first-timer. Rejected. |
| Raise Minotaur HP/DEF | Fatal under all-or-nothing: if a Minotaur becomes DEF 2 and the player can only field 1-point allocations, it becomes unkillable and soft-locks. Rejected. |

The revive is the cleanest "deal with the faucet, not the puddle" teacher that is also
incapable of producing an unfair state.

**Cadence:** every **3 turns**. First pulse on **turn 3**, telegraphed on turn 2 (§3).
Two clean turns of lull first, so the player feels competent before the squeeze.

**No-op guard:** a pulse with the rank already full (nothing downed) does nothing. It does
not punish, does not over-fill, does not tick the drum by itself. Gentle on purpose.

---

## 3. The War Drum (the doom clock) and its telegraph

A single visible meter, **0 to 12**, rendered beside the Captain. This is the miniature
creeping-doom clock. It advances in the enemy phase:

| Drum input | Amount | Rationale |
|---|---|---|
| Base tick, every enemy phase | **+1** | The clock always moves. Doing nothing still loses eventually. |
| Minotaur rank is **full (4 standing)** at end of enemy phase | **+1 extra** | The horde at full strength surges. Thinning the rank halves the clock, so clearing adds is a *legitimate stall*, never a win. |

Max speed **+2/turn**, min speed **+1/turn**. **Overrun at 12 → soft retry (§5).** The
Captain's death freezes the drum and wins the beat outright (§4), so the drum only ever
matters to a player who refuses to engage the Captain.

**The pulse feeds the drum indirectly, which is the elegant part:** a pulse refills the
rank → rank is now full → the full-rank surge re-engages → the drum speeds back up. So
letting the Captain live both re-floods the board *and* re-accelerates the clock, with no
extra special-case rule.

**Telegraph (a doom-clock the player cannot see coming teaches nothing):**

1. **Persistent clock readout.** The drum meter is always on screen as `War Drum X / 12`
   with its current speed spelled out, e.g. *"+2/turn: the horde is at full strength"* vs
   *"+1/turn: ranks thinned."* This is the live end-turn preview pattern used by the Blight
   and the Conjurer manor; the player always sees next turn's cost before ending the turn.
2. **One-turn pulse warning.** On the turn *before* a Muster, the Captain raises his
   standard (banner badge **"MUSTER NEXT TURN"**) and the downed-Minotaur silhouettes glow
   as if about to rise. The player gets exactly one turn of warning: enough to choose
   "fell the Captain now" instead of being ambushed.
3. **Captain one-shot tag.** The Captain shows `DEF 4` and a **"FELL IN ONE CHARGE"**
   label, so the all-or-nothing requirement (you cannot chip him across turns) is visible,
   not a surprise the player discovers by wasting a turn.

---

## 4. Captain HP and the lesson arc

**Captain DEF = 4. Killable in one focused turn, never by chipping.** This is forced by
the combat model and is also the better lesson:

- Under all-or-nothing + use-it-or-lose-it, there is no "take him down over two turns."
  Partial allocations do nothing and do not persist. So the Captain *must* be fellable in a
  single turn's allocation, and that single-turn burst requirement **is** the capstone of
  the use-it-or-lose-it lesson: assemble force and spend it all at once.
- **Why 4 and not 2 or 3:** 1 would make him indistinguishable from the chaff; a casual
  single-card poke should *not* fell him, or the escalation lesson never triggers. DEF 4
  sits at the top of what a **seeded Muster burst** (several Warriors played in one turn)
  or a **Dojo conversion** can produce in this tutorial, so felling him requires the player
  to deliberately *concentrate* force, which is exactly the Warrior "mass overwhelming"
  fantasy and exactly the skill this beat exists to teach.

> **Balance-constraint flag (tcg-designer / design-lead):** FACTION_IDENTITIES sets a hard
> rule that Warriors must not reach 4-5 ATK *in the early game*. DEF 4 here is intended to
> be reachable **only** via a Muster of several seeded bodies or Dojo conversion in one
> focused turn, i.e. the sanctioned mass burst, not a single printed card and not a
> repeatable early spike. The captain's DEF must be tuned to the ceiling of the tutorial's
> seeded Muster, not above it. Please confirm the seeded rally (currently w10/w10/w9) plus
> Muster steps can reach exactly 4 in one turn and not trivially more.

**The intended arc (what the player should feel):**

1. **Lull, turns 1-2.** Spread one point per Minotaur, clear the rank, feel competent.
   Carries Part 1 forward. Drum ticks quietly (+1/turn once the rank is thinned).
2. **Squeeze, turn 3.** The Muster (telegraphed on turn 2) fires; the fallen rise. *"Wait,
   they came back."* If the player had cleared them, the refilled full rank also re-speeds
   the drum. Coach-mark lands (copy owned by design-lead): the Captain rallies his fallen.
3. **Realization.** The player sees the Captain is the faucet, turns attention to him, and
   learns he needs a *concentrated* burst in one turn. You cannot chip him; the half-hearted
   2-point poke accomplishes nothing. This is the use-it-or-lose-it lesson at full strength.
4. **Resolution.** The player pours a Muster burst onto the Captain. He falls; the leaderless
   Minotaurs **rout** (all remaining Minotaurs are removed); the drum is discarded; the beat
   is won. "Cut the head and the body falls" is literally the win button.
5. **Transfer.** A closing coach-mark maps it to the real mode (copy owned by design-lead,
   intent here): *the guardian monsters and the Portal work the same way; clearing the field
   buys time, but you only win by closing the source.*

**Why the Captain is targetable from turn 1 (no taunt):** a player who already understands
the lesson should be *allowed* to beeline the Captain and win fast; that is the reward for
getting it. A confused first-timer will instinctively clear the easy 1-HP Minotaurs first
(Part 1 trained "spread"), hit the turn-3 Muster, and learn the lesson the intended way. No
hard gate is needed, and a gate would only add a soft-lock risk.

**Cut-the-head is strictly better, provably:** killing the Captain = instant win. Grinding
Minotaurs can *never* win (the rank refills every pulse); it only ever stalls the drum. So
there is no line in which ignoring the Captain is as good as killing him, yet ignoring him is
never an instant loss either (§5). That is the exact band the pressure model aims for:
survivable-but-costly, never ignorable, never arbitrary.

---

## 5. Guardrails (onboarding: comfortably winnable, worst case bounded)

- **No terminal loss.** Overrun (drum reaches 12) triggers a **soft retry**, not a
  game-over: a short dramatic beat ("the horde breaks through, but you dig in and the line
  reforms"), the board resets to its opening state, the drum resets to 0, and a stronger
  coaching line points at the Captain. Matches the Giving Tree no-fail and the Conjurer
  tutorial's soft-retry surge; a terminal variant is out of scope for this beat.
- **Escalating mercy on repeat failure.** On the **second** soft retry in one session, pull
  the struggling player over the line: either gift a one-time **"+2 attack this turn"** rally
  token, or drop the Captain to **DEF 3**. (Pick one with design-lead; mirrors the Conjurer
  tutorial's escalating-help pattern.)
- **Board cannot spiral.** Muster revives only up to the original 4 and never summons a
  fifth. Drum speed is capped at +2/turn. So the worst case is fully bounded: a totally
  passive player (never clears, never engages) overruns in **6 turns** (+2/turn); a player
  who clears adds but ignores the Captain gets **12 turns** (+1/turn); either way it is a
  soft retry with coaching, not a loss.
- **No hidden state to misread.** Attack and damage never carry between turns, so every turn
  is a clean read; a confused player is never punished by invisible accumulated state.
- **Transfer framing is explicit.** The drum is deliberately the same shape as the real
  12-market-razing loss clock of the Seeping Portal (a visible counter that advances on its
  own and ends the game at its cap); clearing the field here maps to disabling field
  monsters there, and felling the Captain maps to closing the Portal. The tutorial is a
  scale model of the real doom, so the lesson transfers.

---

## 6. Edge cases (for the engineer)

- **Captain felled while Minotaurs still stand:** immediate win; remaining Minotaurs rout
  (removed); drum discarded. Do not require a clean rank to win; the Captain is the win.
- **Rank fully cleared, Captain alive:** fine. Drum ticks at +1/turn only (no full-rank
  surge); the Captain stays targetable; the next pulse refills the rank. No soft-lock.
- **Muster fires with the rank already full:** no-op (§2). No over-fill, no drum tick.
- **Player ends a turn with 0 attack available:** allowed. Drum ticks per §3; the player
  acts next turn; repeated inaction is caught by overrun → soft retry → mercy.
- **Player dumps >1 attack on a single Minotaur:** the excess is wasted (all-or-nothing, no
  carryover). This is intended Part-1 reinforcement, not a bug.
- **Player allocates <4 to the Captain:** nothing happens to the Captain (must meet DEF 4 in
  one shot). The "FELL IN ONE CHARGE" tag telegraphs this so it is not a surprise waste.
- **Overrun and a lethal Captain allocation in the same turn:** resolve the player's attack
  first. If the Captain dies, the player wins; the overrun does not fire. A come-from-behind
  win should be allowed, never pre-empted by the clock.
- **Pulse telegraph with nothing downed:** suppress the "MUSTER NEXT TURN" banner if the rank
  is already full, so the warning never cries wolf.

---

## 7. Values table (engineer-facing)

| Thing | Value | Note |
|---|---|---|
| Minotaurs | 4 | DEF 1 each; harmless; killed by 1 attack each |
| Captain DEF | 4 | one-shot only; tune to seeded Muster ceiling (§4 flag) |
| Captain direct damage | 0 | no board damage this beat (§6) |
| Muster cadence | every 3 turns | first pulse turn 3 |
| Muster effect | revive downed Minotaurs to rank | cap 4; never a 5th |
| Muster no-op | rank already full | no effect, no drum tick |
| Pulse telegraph lead | 1 turn | banner + glowing fallen |
| War Drum cap | 12 | overrun → soft retry (§5) |
| Drum base tick | +1 / enemy phase | always advances |
| Drum full-rank surge | +1 / enemy phase | only if 4 Minotaurs standing |
| Drum max / min speed | +2 / +1 per turn | capped; bounds worst case |
| Passive overrun | ~6 turns | never clears, never engages |
| Stalling overrun | ~12 turns | clears adds, ignores Captain |
| Terminal loss | none | soft retry only |
| Mercy trigger | 2nd soft retry | +2 ATK token or Captain DEF 3 |
| Win | Captain felled | Minotaurs rout; drum discarded |

Combat model is the shared all-or-nothing, use-it-or-lose-it rule
(`CHANGES_SINCE_v2_3.md §22`); do not re-stat any shared card. The Captain and Minotaurs are
mode actors living in the beat's own state (per GAME_MODES "Adding a new mode"), never in
`cards.json`.

---

## Open questions for Bryan

1. **Mode id / placement.** Is this beat a standalone mode (suggest `warrior_captain`) or a
   phase inside the onboarding flow? It must not collide with `warrior_stone` (§0).
2. **Mercy lever.** On the 2nd soft retry, prefer the one-time +2 attack rally token, or
   dropping the Captain to DEF 3? (I lean token; it keeps the Captain's identity intact and
   is more legible as "here is extra force, now concentrate it.")
3. **Should the Captain ever threaten the board?** I deliberately gave him 0 direct damage to
   keep this a pure source-lesson. If you want him to also disable a permanent (teaching
   repair, like the Sundering Stone's Gore), I recommend that stays in `warrior_stone`, not
   here, to avoid overloading a first lesson. Confirm.
4. **Captain DEF vs the early-ATK constraint.** Please confirm the seeded Muster (w10/w10/w9
   + Muster steps + Dojo) can reach exactly 4 in one focused turn and not trivially more, so
   DEF 4 sits at the ceiling of the sanctioned burst rather than above or below it (§4 flag).
