# Onboarding: Warrior Combat Tutorial (attack primer)

Owner: Design Lead. Status: spec for build. Companion sub-spec (captain pressure
numbers) owned by `pve-pressure-designer`, referenced in s7. Swarm/Dojo card
numbers owned by `tcg-designer` (`WARRIOR_SWARM_AND_BUILDER_MORALE.md`). The Godot
client is the oracle; this replaces the opening combat beats of `warrior_stone`.

---

## AS BUILT (ruled by Bryan, 2026-11-06) - authoritative

This section records what shipped and Bryan's rulings. Where anything below it
conflicts (the two-beat 1 HP ramp, action-gated steps, retiring the Stone), this
section wins. The rest of the doc is kept for its rationale and future direction.

**No new mode, no separate primer.** The Sundering Stone (`warrior_stone`) stays THE
first Warrior tutorial. Its encounter was rebuilt in place (`ward_stone.gd`); there is
no `warrior_captain` mode and no handoff to a separate "fuller" tutorial. The old single
20 HP chip-target is retired.

**The encounter (first-pass, tunable):**
- Four Minotaur Raiders: DEF 3, ATK 1 each.
- One Minotaur Captain: DEF 6, ATK 2. Musters every 3 turns (first on turn 3), reviving
  fallen raiders back to a full line of four.
- The Sundering Stone is KEPT as the doom clock: integrity 30, eroded each enemy turn by
  the summed ATK of every living foe (full board = 6/turn). Reaches 0, you lose. You win
  by felling the Captain, even with raiders still afield.

**Combat model (final shape, intent unchanged):** all-or-nothing per target plus
use-it-or-lose-it. A foe is felled only by landing its full DEF in ONE strike (3 for a
raider, 6 for the Captain). Less is rejected and spends nothing; the remainder of the
pool strikes other targets this turn; anything unspent evaporates at end of turn. Built
on the engine's `_spend_atk`, and `end_turn` rebuilds the pool each turn.

**Why DEF 3 raiders, not 1 HP:** meeting a 3 requirement in one strike teaches
"meet the requirement or nothing happens" by construction (a 2 does nothing), and a pool
of 7 fells two raiders and wastes the last 1, teaching allocation and leftover-waste in a
single turn. Cleaner than the 1 HP target the draft below proposed. Raiders also deal 1
to the Stone, so they are not harmless chaff; ignoring them crumbles the clock faster.

**Why DEF 6 Captain, not 4:** Bryan confirmed the Warrior market reaches 12+ attack in a
turn, so 6 is comfortably one-shottable; the real challenge is timing warrior buildup
against the Stone's crumble, which is the lesson. The pve sub-spec's DEF 4 ceiling
argument is superseded (tcg-designer may still confirm the ramp reaches 6 by ~turn 3).

**Coach marks (as built):** a six-step combat primer appended to the learn-to-play tour,
shown only in the Sundering Stone. All six are READ steps with animated drag gestures
(drag-to-play, drag-to-strike), tap to advance, so nothing soft-locks on turn one. The
`game_tour.gd` overlay also gained the action-advance and click-through-cutout powers
this doc designed (below); wiring specific beats to action-advance is a post-playtest
upgrade, not in v1.

**Not yet built / open for playtest:** crumbling the Stone is a HARD defeat in v1, not the
soft-retry the companion spec proposes; add soft-retry + mercy if the no-fail feel is
wanted. Captain art supplied (`art/mn_captain.webp`).

**Open questions below, answered:** (1) replaced in place, no separate mode, 20 HP chip
retired. (2) a distinct minor Captain; art supplied. (3) no separate Beat 1; the single
encounter teaches leftover-waste via the 3-DEF raiders and the "use it or lose it" step.

---

## What changed and why (read first)

The live Warrior tutorial (`scripts/antagonists/ward_stone.gd`) opens the player's
first-ever attack against a **single 20 HP Minotaur** that they chip down over many
turns (`mino_hp -= pool`). That teaches the **wrong mental model**: that damage
accumulates and carries over on a target. Connivances combat is **use-it-or-lose-it**:
attack is built fresh each turn and any point not spent this turn is gone, and to
defeat a target you meet its requirement in one shot (no chipping). A single fat-HP
wall teaches carryover by construction.

This spec replaces that opening with a **two-beat ramp** of weak (1 HP) targets so
the correct rule is taught by construction, not by a tooltip fighting the mechanic.
The deeper Warrior systems (Muster bursts, Dojo conversion, the telegraphed boss)
still live downstream in the fuller tutorial; this is the first-contact attack primer
that runs **right after the learn-to-play tour** (`scripts/game_tour.gd`, which has
already taught Food and Influence).

## The one-line lesson

**Your attack is spent fresh each turn, one point per target, and anything you do not
spend is wasted.** Overkill one enemy and the rest live; bank nothing for next turn.

## Continuity with the learn-to-play tour

The learn-to-play tour runs first and has already taught: cards in hand, playing a
card costs Food, buying from a market costs Influence, and the ATK **arsenal** exists
(see `game_tour.gd` step "Attack Pool": "Drag it onto a monster... to strike"). This
primer assumes all of that and teaches only the **attack gesture and its rules**. Do
not re-teach Food or Influence. Open line hands off from the tour, warm and plain:
"You can play cards and spend Influence. Now learn to fight."

Faction fit (`FACTION_IDENTITIES.md`): Warriors are **mass, not individual power**,
"the fantasy is many overwhelming." The two-beat ramp dramatizes exactly that: one
soldier ends one minotaur, and a warband spread across many ends many. Beat 2 is the
first taste of the swarm.

---

## Combat behavior this mode requires (the lesson, mechanized)

This is the crux; the mode's attack resolver must behave this way or the primer
teaches the old carryover model again. It matches the live Conjurer Duel model
("meet its requirement in one shot, no chip, no carryover, unused attack is lost").

- Each minotaur has **requirement 1** (1 HP, dies to 1 point).
- Striking a target spends **exactly its requirement** from the arsenal (1), not the
  whole pool. The **remainder stays in the arsenal** to strike other targets this turn.
- You cannot chip: if the arsenal is below a target's requirement you cannot strike it.
- Any arsenal **not spent by end of turn evaporates**. It never banks.
- Pouring more than a target needs into it (the old whole-pool dump) is **overkill**
  and the excess is lost; this is why you spread across targets.

> Engineering note: the current `ward_stone.attack()` dumps the entire pool onto one
> target and zeroes all three ATK pools. This mode needs a **per-target spend** resolver
> instead (spend the requirement, keep the remainder, evaporate on end-turn). The Duel
> already does per-target disable, so the pattern exists; confirm parity with engineering.

---

## Beat structure and pacing

Two beats, in order, no branching. Both are **soft** (see s6, failure handling).

### Beat 1 - One minotaur (teach the gesture + the core rule)

- **Board:** a single Minotaur, 1 HP. No captain, no clock, no ward-stone.
- **Arsenal:** seed the player so the arsenal starts at **3** on the first turn (a few
  ⚪; exact card seed to `tcg-designer`). Three, not one, so the leftover-is-wasted
  beat has something to waste while the single target keeps allocation unambiguous.
- **What it teaches:**
  1. The gesture: drag the arsenal onto the target to strike.
  2. One point kills one HP (the strike spends 1 of the 3).
  3. Leftover attack is wasted: the 2 remaining evaporate at end of turn, called out.
- **How we know they learned it (success criteria):**
  - Player performed the drag-strike unaided (step advanced on the action, not Next).
  - The minotaur died from a single point.
  - Player saw the end-of-turn evaporation callout at least once.

### Beat 2 - Four minotaurs + a Captain (teach allocation, priority, telegraph)

- **Board:** four Minotaurs, 1 HP each, plus one **Captain** that rallies them on a
  telegraphed pulse every few turns (captain HP, pulse effect, and cadence are
  `pve-pressure-designer`'s; see s7). The Captain is a deliberate miniature preview of
  the real creeping-doom clock.
- **Arsenal:** the player now needs several points per turn. This is the first **swarm**
  moment: play several Warriors in a turn to build a bigger arsenal (Muster; numbers to
  `tcg-designer`). Target feel: a normal turn yields enough to clear ~2-4 adds, not all
  four plus the Captain in one turn, so allocation actually matters.
- **What it teaches:**
  1. Attack is spent **per target**: spread one point across many enemies.
  2. **Overkill is waste**: dump your whole arsenal on one minotaur and the other three
     live and the Captain rallies them back.
  3. **Target priority**: clear the adds versus "cut the head" (kill the Captain to stop
     the rallies).
  4. **Read a telegraph**: the Captain flares before it pulses; act on the warning.
- **How we know they learned it (success criteria):**
  - Player struck at least two different targets in one turn (allocation observed).
  - Player killed the Captain at some point (priority observed), or explicitly chose the
    clear-the-adds line to victory.
  - Player did not lose on the first Captain pulse (telegraph gave them a turn to react;
    if they stalled, the mercy nudge fired; see s6).

**Why this order:** Beat 1 removes every decision except the gesture so the rule lands
clean on the first swing. Beat 2 reintroduces decisions one at a time (many targets,
then a threat to prioritize, then a telegraph to read) once the core rule is reflex.

---

## Failure and retry handling (a primer should be hard to lose)

No terminal game-over anywhere in this primer. Match the family's soft-retry promise
(Giving Tree soft-resets; Sundering Stone lets you rebuild).

- **Beat 1:** unfailable. There is no clock. If the player ends the turn without
  striking, the minotaur simply waits and the coach step re-shows next turn. If the
  arsenal somehow drains to 0 before the kill, re-seed 1 point via the gift cadence so
  the gesture is always performable.
- **Beat 2:** the Captain's pulse is a soft threat, never lethal. Worst case the Captain
  fully re-rallies the minotaurs; the primer does not end, it nudges. If the player
  stalls (ends two turns in a row with the board uncleared and the Captain alive):
  - Mercy hint names the lever in-fiction ("The Captain keeps bringing them back. Cut the
    head.").
  - Gift the player enough arsenal next turn to break the stall (gift cadence), easing one
    notch, same role as the tree's Vitality <= 25 hint.
- The player **cannot be softlocked**: every turn they must be able to act on at least one
  target. `pve-pressure-designer` owns the exact mercy thresholds and the pulse cadence so
  the near-miss is real but always recoverable.

---

## The reusable tutorial-overlay component

Extend the existing `game_tour.gd` Spotlight (dimming scrim + gold-ring cutout over a
live-resolved anchor + bubble card with Back/Skip/Next). Two additions are needed:

1. **Animated drag-gesture ghost.** An optional looping ghost (a translucent hand or
   card token) that animates from a `drag_from` anchor to a `drag_to` anchor, showing the
   drag the player should perform. Loops until the step advances.
2. **Action-advance steps.** Today every step advances only on Next. Add steps that
   advance when the player **performs the action**, detected via a `GameState` signal
   (e.g. an attack-resolved or card-played signal) with an optional predicate. On an
   action step:
   - The Next button is hidden or shown disabled as "...".
   - Input must **pass through the cutout to the spotlighted control** so the player can
     actually interact, while the rest of the screen stays input-blocked. (The current
     Spotlight is `MOUSE_FILTER_STOP` over the whole screen; action steps need a hole in
     that block aligned to the anchor.)

### Step schema (per step)

| Field | Meaning |
|---|---|
| `anchor` | Callable returning the Control to spotlight (live-resolved, as today). |
| `bubble` | The bubble text (short, warm, plain, second person). |
| `drag_ghost` | `false`, or `{from: Callable, to: Callable}` to animate the drag. |
| `advance` | `"next"` (tap Next) or `"action"`. |
| `action` | For action steps: the `GameState` signal + predicate that completes the step. |
| `interact` | For action steps: let input reach the anchor through the cutout. |

---

## Coach-mark step list

Copy is final. Keep it short, warm, plain, second person. No em dashes.

### Beat 1 steps

| # | Anchor | Bubble text | Drag ghost | Advance |
|---|---|---|---|---|
| B1.1 | The minotaur tile | "A minotaur. One hit ends it." | no | Next |
| B1.2 | The arsenal | "This is your attack for this turn. You have three." | no | Next |
| B1.3 | Arsenal to the minotaur | "Drag your attack onto the minotaur to strike." | yes (arsenal to minotaur) | action: minotaur struck |
| B1.4 | The arsenal | "One point was all it needed. The other two are still here." | no | Next |
| B1.5 | The end-turn button | "End your turn. Attack you did not spend is gone. It never banks." | no | action: turn ended |
| B1.6 | The arsenal (now empty) | "See? Spend it or lose it. Next, a whole warband of them." | no | Next (into Beat 2) |

### Beat 2 steps

| # | Anchor | Bubble text | Drag ghost | Advance |
|---|---|---|---|---|
| B2.1 | The four minotaur tiles | "Now four of them, and a Captain spurring them on." | no | Next |
| B2.2 | The Captain tile | "Watch the Captain. When it flares, it rallies the minotaurs. Read the warning." | no | Next |
| B2.3 | Your hand (Warrior cards) | "Rally your warband. Play a few Warriors to build more attack." | yes (hand card to play) | action: arsenal reaches the clear threshold |
| B2.4 | Arsenal to a minotaur | "One point per minotaur. Spread your attack. Strike each one." | yes (arsenal to a minotaur) | action: a second distinct minotaur struck this turn |
| B2.5 | The remaining minotaurs | "Pour it all into one and the rest live. Clear as many as you can." | no | action: turn ended or board cleared |
| B2.6 | The Captain tile | "Cut the head. Kill the Captain and the rallies stop." | yes (arsenal to Captain) | action: Captain killed, or Next |
| B2.7 | The objective banner | "That is the whole of it. Build it, spend it, aim it. Onward." | no | Next (ends primer) |

Notes for the step author:
- B2.3 advances on reaching enough arsenal to matter, not on a fixed card count, so the
  exact Muster numbers can move without breaking the script (`tcg-designer` owns them).
- B2.4's predicate is "a second distinct target struck this turn," which is the concrete
  proof the player grasped allocation rather than whole-pool dumping.
- B2.6 is Next-skippable: a player who wins by clearing adds instead of beheading the
  Captain should not be blocked; the step still names the priority lesson for next time.

---

## What I own vs what is deferred

**I own (this doc):** beat order and pacing, what each beat teaches and its success
criteria, soft-retry/no-lose handling, the overlay component contract and step schema,
and the exact coach-mark copy and step list. Also the combat behavior requirement in s3
(per-target spend, no carryover, end-turn evaporation) and the per-target minotaur
requirement of 1 HP (given in the brief).

**Deferred to `pve-pressure-designer`** (companion sub-spec, proposed filename
`docs/design/ONBOARDING_COMBAT_CAPTAIN_PRESSURE.md`): the Captain's HP, exactly what its
inspire/morale pulse does to the minotaurs, the every-N-turns cadence, the telegraph
window, and the Beat 2 mercy thresholds so the pulse is a real but recoverable near-miss.
Do not read any captain combat number out of this doc; there are none here by design.

**Deferred to `tcg-designer`** (`WARRIOR_SWARM_AND_BUILDER_MORALE.md`): the opening-hand
seed and Muster/Rally card values that let the Beat 1 arsenal start at ~3 and the Beat 2
arsenal reach the "clear ~2-4 adds per turn" band, with no early 4-5 ATK spike.

---

## Assets

- `art/mn_minotaur.png` - exists; used for the single minotaur (Beat 1) and all four
  adds (Beat 2).
- `art/boulder.png` - exists; **not a mechanic in this primer** (the carryover-flavored
  ward-stone is retired from the opening beats). Optional set dressing only.
- **Captain art** - none exists. Placeholder: a scaled-up or color-tinted `mn_minotaur`
  so the Captain reads as distinct. Flag for a real Captain asset before ship.

---

## QA-testable checklist (for `qa-lead` to expand)

- [ ] Primer launches only after the learn-to-play tour is marked seen; does not re-teach
      Food or Influence.
- [ ] Beat 1 board is a single 1 HP minotaur; arsenal starts at 3; no clock present.
- [ ] A strike spends exactly 1 from the arsenal and leaves the remainder (per-target
      spend), not a whole-pool dump; a sub-requirement arsenal cannot strike.
- [ ] Unspent arsenal is zero at the start of the next turn (end-turn evaporation), and
      the B1.4/B1.5 callouts fire.
- [ ] B1.3 and B1.5 advance on the player's action, not on Next; input reaches the
      spotlighted control through the cutout while the rest stays blocked.
- [ ] The drag-ghost animates on B1.3, B2.3, B2.4, B2.6 and loops until the step advances.
- [ ] Beat 2 board is four 1 HP minotaurs plus one Captain; the Captain telegraphs before
      it pulses.
- [ ] B2.4 advances only after two distinct minotaurs are struck in one turn.
- [ ] No terminal game-over anywhere; stalling in Beat 2 triggers the mercy hint and a
      gift, never a loss screen.
- [ ] Player can always act on at least one target each turn (no softlock).

---

## Open questions for Bryan

1. **Seam with the fuller Warrior tutorial.** This primer replaces the *opening* combat of
   `warrior_stone`. Does it hand off into the existing Sundering Stone systems (Muster,
   Dojo, Siege, the telegraphed 20 HP boss and ward-stone clock) as "the rest of the
   lesson," or does the primer stand fully alone as its own short mode? Recommendation:
   primer first, then hand into the fuller challenge, with the single 20 HP chip-target
   retired so carryover is never taught.
2. **Is the Captain the same character as the Sundering Stone Minotaur boss, or a new
   minor figure?** Affects art and lore. Recommendation: a minor Captain here, distinct
   from the later boss, to keep the primer light.
3. **Should Beat 1 force the end-turn-with-leftover beat (seed 3 arsenal), or let a
   player who only built 1 point skip it?** Recommendation: force it once; the
   leftover-is-wasted rule is the whole point and is easiest to feel with something to
   lose.
</content>
</invoke>
