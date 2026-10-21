# V11. Creeping Doom: PvE Pressure Review

**Reviewer:** pressure-systems pass · **Date:** 2026-07-20
**Reviewing:** `docs/design/V11_CREEPING_DOOM_BRIEF.md` (designer-authored)
**Against:** `V11_MONSTER_PRESSURE_BASELINE.md` (empirical), MD v2.2 §8E / §12A / §13 / §13A / §13B / §10

**Constraint respected throughout:** no proposal below changes a card's printed stats or
text. Everything is a **monster-side rule** or a **mode-level rule**. PvP-safety is called
out per item in §E8.

---

## TL;DR

The brief is directionally right and fixes the hardest of the three measured problems
(**loss is now reachable**). But three things need designer decisions before this is
buildable, and one of them is a reachability regression the brief has not spotted.

| Verdict | Item |
|---|---|
| ✅ Fixed | Loss reachability; 12 destroyed market positions is a real terminal state |
| ⚠️ Partly fixed | Cork B; brief implies all-four evaluation but does not explicitly retire §13A's "only ONE monster may leave the portal per monster turn" |
| ⚠️ Partly fixed | Cork A. Ghoul's food trigger is non-elective, but monsters 2–4 keep the old table, several of which are still player-elective off-switches |
| ❌ Not fixed | **The incentive is still inverted; it has merely flipped sign.** Under R2 ordering, owning permanents *brakes* the doom clock. Chump-blocking with a 1-Food Farm per turn absorbs a monster action worth a market slot |
| ❌ New hole | **Possessions plug market slots and are never destroyable (R2).** A player who farms Possessions into the 3 Conjuration slots makes 12/12 unreachable; loss becomes unreachable again |
| 🚫 Blocked | Portal exposure paradox (brief Q1); needs a ruling; recommendation in §B |

**The single number nobody has set:** target game length. Baseline games ran 25–40 turns.
The brief's pacing implies ~10. Every number in §C and §D is downstream of this. It needs
a designer ruling, not my guess.

---

## A. Does this design fix the measured problems?

### A1. Loss reachability; ✅ fixed, with one condition

"All 12 market positions destroyed" is a genuine, monotonic, reachable terminal state.
It resolves **Item 23** *without* requiring permanent destruction, which is a real win -
the disable-only permanent model (§13A, locked) stays intact, and no card changes.

**But loss reachability is downstream of unseal reachability.** The chain is:

```
unseal condition met → monster in field → monster has no permanent target
                     → monster attacks a market slot → 12 slots → loss
```

Every link must be non-elective. The brief fixes link 1 for Ghoul only, and link 3 is
*conditional on the player not having targets*; see A3. Today the chain still has two
player-operated switches in it.

**Also unspotted:** three market-slot states are now needed but only two are named
(brief Q4). See §E4; natural **deck exhaustion** must not count toward the monster win,
or a long game auto-loses.

### A2. The corks; ⚠️ partly fixed

**Cork A (Ghoul gated on player-elective Famine):** the 10-Food unseal is a real fix for
Ghoul. But §8E fills positions 2–4 randomly from the non-Ghoul pool, and the §13 unseal
table still contains:

| Monster | Trigger | Elective? |
|---|---|---|
| Fiend | Start of Turn 3 | No; good |
| Silent Stalker | First card to Legend | Semi; avoidable but hard to avoid |
| Minotaur | 4+ permanents | **Yes; never build 4** |
| Nightmare | Any monster defeated | **Yes; never kill anything** |
| Gargantuan | Any Wall enters Kingdom | **Yes; never play a Wall** |
| Dank Beast | First portal monster defeated | **Yes; duplicate of Nightmare (item 20)** |
| Dragon | Legend ≥ 3 | **Yes** |
| Noxious Beast | 2 Conjuration purchases | **Yes; never buy a Conjuration** |

Six of eight are opt-out-able. Because positions 2–4 are random, a given game may draw
three fully elective monsters and have **exactly one** live threat all game. Fixing
Ghoul alone does not fix the cork; it fixes 1/4 of it. Recommendation in §C2.

**Cork B (only position 1 evaluated):** brief §6.1a; *"In order of monster position 1–4,
check whether the monster is sealed"*; reads as evaluating all four. Good. **But the
brief never explicitly retires §13A Step 2's rule "Only ONE monster may leave the portal
per monster turn."** That throttle is the actual mechanism of Cork B. An engineer
implementing the brief literally, against a doc that still contains that line, will
rebuild the cork.

> **Action required (spec text, not a decision):** the V11 spec must say explicitly:
> *"§13A Step 2's one-monster-per-turn throttle is REMOVED. Every living monster is
> evaluated every monster turn, in queue order 1→4."*

Also: brief §6.1a says *"Once unsealed, a monster is never sealed again."* This restates
existing behaviour (`monstersUnsealed` never re-evaluates, §13A); it is not a change.
But the wording conflates two independent axes and will cause bugs:

- **Seal axis:** `sealed | unsealed`; permanent, one-way, tracked by `monstersUnsealed`
- **Location axis:** `guarding | field | siege | dead`; currently reversible

The brief's sentence is true of the *seal* axis and says nothing about the *location*
axis, which is what Q1 and item 56 are actually about. Keep them separate in the spec.

### A3. Inverted incentive; ❌ not fixed, sign flipped

This is my most serious mechanical objection.

R2 ordering is: *player permanents remain highest priority; if none attackable, attack a
market slot.* Combined with §13A's "disabled permanents cannot be attacked again until
repaired," this produces:

- **Having an attackable permanent = the doom clock does not tick this turn.**
- A permanent costs **1 Food**. A market slot is **1/12 of the game**. The exchange rate
  is absurd.
- Optimal play is therefore: **play one cheap disposable permanent per turn** (a Farm, a
  Caravan. Caravans are *highest* priority per §13A, making them the ideal decoy) to
  soak each monster's action. Doom never advances.
- Worse, **repair becomes an obligation to feed the monsters.** A fully-disabled board
  has no valid targets, so market attacks begin. The player repairs *in order to give the
  monsters something to chew on*. That is thematically backwards and will read as a bug
  to playtesters.
- **Trophy interaction:** Trophies are untargetable (§13A, locked). Killing monsters
  generates Trophies. So the reward for fighting monsters is an untargetable board, which
  *accelerates* market attacks. A player who fights well is punished on the market clock.

**Recommendation; invert the priority (designer ruling required, flips R2's ordering):**

> **Markets are the primary target. Permanents are obstacles.**
> A field monster attacks a market slot each turn. It attacks a player permanent **only**
> when a permanent physically interposes; i.e. a taunt Wall (bg3) it must break through,
> or a Caravan it opportunistically snaps up.

Why this is the right shape:

- **Doom is independent of player passivity.** Building nothing no longer switches the
  threat off, and it no longer switches it on either; it just leaves you undefended.
- **Building is rewarded, not punished.** Walls become genuine interposition, which is
  what a wall is for. This resolves the flavour inversion the baseline flagged.
- **It matches the brief's own theme.** "Monsters are establishing a foothold in the
  human world"; they should be going for the land and the townsfolk (the markets), and
  fighting your army only when it stands in the way. R2's current ordering has them
  ignore the objective to punch a Farm.
- It kills the chump-block, the repair-to-feed perversity, and the Trophy feedback loop
  in one move.

**Cost to the designer:** this contradicts R2's *"player permanents remain highest."*
That is a locked ruling in principle, so this is a request for a re-ruling, not something
I can decide. Flagging it plainly.

**If the designer keeps R2's ordering**, the chump-block must be closed some other way.
The cheapest patch: a monster that attacks a permanent **also** advances a separate
foothold counter (so permanents divert damage but not the clock). That is more moving
parts and I like it less, but it is a valid fallback.

---

## B. The portal-exposure paradox (brief Q1)

### The problem, restated sharply

`isPortalExposed()` is true when zero monsters are `guarding`. Under the new design
monsters are *supposed* to leave portal defense to attack markets. So:

- **Monster aggression is self-defeating.** Every monster that presses the market clock
  hands the player a free shot at the Portal.
- The **unseal-rush fast win (item 59)** gets strictly easier; the player doesn't need
  to kill anything, just wait for four unseals and swing.
- A compounding factor nobody has connected: **the Portal cannot be chipped.** Item 47
  made portal attacks binary; you spend exactly its effective HP or you spend nothing.
  So the player's entire game is *building toward one alpha-strike turn*. Portal
  exposure isn't a slow siege; it is a single boolean that, once true, ends the game the
  moment the player's ATK pool clears the bar.

That makes "no monster guarding" a catastrophically brittle win condition. It is not a
threshold; it is a trapdoor.

### Options and trade-offs

**Option 1. Exposure requires all monsters `dead`.**
*Pro:* simplest, kills item 59 outright, monster aggression is free.
*Con:* deletes the mode's core flavour ("the portal becomes more accessible as monsters
leave", §13 core concept). Also makes the game strictly a 4-kill grind (4+5+5+6ish HP,
then 7 for the Portal) with no strategic choice; you must kill everything, always.
It replaces a trapdoor with a checklist. **Not recommended.**

**Option 2. Recall: a threatened Portal pulls monsters home.**
*Pro:* dynamic, thematic.
*Con:* **there is no trigger available.** Because portal damage is binary (item 47), the
Portal is never "wounded"; it is at full HP until it is dead. The AI would have to read
the player's ATK pool, which is hidden-information gymnastics and produces a feel-bad
("the monsters knew"). **Not recommended.**

**Option 3. Portal Ward (recommended).**
Replace the exposure boolean with a scalar the player can grind down.

> **Portal Ward.** The Portal's effective HP = its printed HP (7) **+ its Ward**.
> Ward = **2 per living `guarding` monster + 1 per living `field`/`siege` monster + 0 per `dead`**.
> The Portal is **always attackable**; there is no exposure flag. Attack remains binary
> (item 47): the player must clear `7 + Ward` in one turn.

What this buys:

- **The paradox dissolves.** A monster leaving to attack markets *does* lower the
  Portal's protection (2 → 1), so monster aggression carries a real price; exactly the
  "every valve costs something" principle, applied to the monster side. But it does not
  drop protection to zero, so aggression is not suicide.
- **Item 59 dies.** An unseal-rush drops Ward from 8 to 4, so the bar is 11, not 7. Real
  but not free.
- **One clean difficulty dial.** Ward is the single number that sets how hard the game
  is; market destruction is the deadline. They are orthogonal and tunable independently.
- **Both strategies stay live.** Spend ATK on field monsters (lower the bar *and* brake
  the market clock) or hoard for the alpha strike. That is the strategic tension this
  mode currently lacks.
- **Retreat (item 56) becomes meaningful again** rather than a rules wart: a monster
  returning to `guarding` raises Ward by 1. Whether the AI should ever do that is a
  separate question; the rule supports it either way.

Worked numbers at Ward 2/1/0 with 4 monsters:

| Board state | Ward | Bar to kill Portal |
|---|---|---|
| All 4 guarding (turn 1) | 8 | 15 |
| 2 guarding, 2 field | 6 | 13 |
| All 4 field | 4 | 11 |
| 2 field, 2 dead | 2 | 9 |
| All 4 dead | 0 | **7** |

⚠️ **These numbers are illustrative, not tuned.** Do not tune them until reachability is
demonstrated by re-running the baseline probes against the new spec. I do not have a
measured distribution of player ATK-pool-by-turn; that needs to be measured before the
2/1/0 weights or the base 7 are set.

**Option 4; keep the boolean, but only `dead` and `field` clear it, and add a "rear
guard" rule** (at least one monster must remain guarding unless all are unsealed).
*Pro:* minimal code change.
*Con:* the rear guard is an arbitrary-feeling AI rule, and it re-corks the queue (one
monster can never leave), which is Cork B in a new costume. **Not recommended.**

**Recommendation: Option 3 (Portal Ward).** It is the only option that makes monster
aggression *costly but rational*, preserves the mode's flavour, kills item 59, and gives
the designer a single tuning dial.

---

## C. The escalation curve

### C1. What the curve should look like

Three phases, with the phase boundaries as the design targets (turn numbers are
placeholders pending the game-length ruling; see §D):

| Phase | Turns | Monsters live | Slots lost/turn | Player experience |
|---|---|---|---|---|
| **Slack** | 1–3 | 0–1 | 0 | Build freely. Learn the board. See the first unseal coming. |
| **Squeeze** | 4–9 | 2–3 | ~1 | Every turn is a real choice: intercept, kill a monster, or push the Portal. Something is always being lost. |
| **Inevitability** | 10+ | 4 | 2–4 | You cannot hold the line. You are now racing, not defending. Win this turn or the next two, or lose. |

The shape that matters: **early slack must be genuine** (a doom that starts on turn 1
gives no room to make the decision that later kills you), and **late inevitability must
be real** (if the player can stabilise at turn 12, the mode has no ending).

### C2. Can the existing unseal conditions deliver it? No.

Two structural failures:

**Failure 1; six of eight triggers are opt-out-able** (table in §A2). A player can
decline the threat system.

**Failure 2; queue randomness scrambles the curve.** Positions 2–4 are drawn randomly
(§8E). Unseal conditions are attached to *monsters*, not *positions*. So one game draws
Fiend (turn 3) + Silent Stalker (first Legend) + Gargantuan (first Wall) and is under
heavy pressure by turn 4; another draws Dragon (Legend ≥3) + Noxious Beast (2
Conjuration buys) + Minotaur (4 permanents) and may see nothing all game. **The
escalation curve is currently a lottery.** I do not think this has been considered, and
it will make every playtest report contradict every other one.

### C3. Recommended trigger model; behaviour accelerates, position guarantees

> **Every monster unseals at the EARLIER of:**
> **(a) its thematic behaviour trigger**, or
> **(b) a positional turn backstop determined by its slot in the queue, not by its identity.**

Illustrative backstops: **position 1 → turn 3, position 2 → turn 6, position 3 → turn 9,
position 4 → turn 12.**

Why this is the right structure:

- **Reachability is guaranteed** without deleting the flavour triggers.
- **Player-elective triggers stop being off-switches and become risk/reward.** Buying two
  Conjurations doesn't *create* the Noxious Beast; it *pulls it forward*. Declining
  Conjurations doesn't switch it off; it just doesn't accelerate it. That is exactly the
  right relationship; the player influences the clock but cannot stop it.
- **The curve is normalised across queue draws.** Every game has the same skeleton;
  randomness changes *which* monster and *how much earlier*, not *whether*.
- It is legible: the tooltip reads *"Unseals turn 6; or sooner if you buy 2
  Conjurations."* That is a decision the player can actually make.

**Ghoul's 10-Food trigger fits this model directly:** it is the *accelerator* for position
1 (fires ~turn 3 for an active player), with the turn-3 backstop catching a passive one.
Both paths converge on turn 3, which is why it feels right.

**Telegraphing requirement:** the queue UI must show, per monster, both the behaviour
trigger and the backstop turn, and a live countdown ("unseals in 2 turns"). Without the
countdown the backstop is an ambush, not a clock.

### C4. Unseal is not enough for late-game inevitability

Unseal caps at 4. After turn ~12 the pressure is flat, and flat pressure means a
sufficiently good player stabilises forever; the same failure as today, arriving later.
You need a **second escalation axis**. Two candidates:

- **Rampage (recommended for V11).** Once all four monsters are unsealed, each field
  monster destroys **2** market slots per turn instead of 1. Zero new systems, one flag,
  produces a sharp and legible late-game cliff. Counterplay unchanged (kill monsters,
  intercept), so the price is the same currency; it just costs more of it.
- **Second Wave (brief §6.4, recommended for later).** The Portal spawns additional
  monsters from the remaining pool every N turns after all four unseal. Richer, but needs
  queue-position, Ward-weighting and UI work. Defer.

---

## D. Pacing math for the monster win

### D1. The naive number is misleading

12 slots ÷ 4 actions/turn = 3 turns. That is the *floor*, not the clock, and it only
applies in a state (all four unsealed, no diversions, no interception) that occurs late.

### D2. Modelled curve, with §C3 backstops and 1 slot/action

| Turns | Monsters in field | Slots/turn | Cumulative destroyed |
|---|---|---|---|
| 1–2 | 0 | 0 | 0 |
| 3–5 | 1 | 1 | 3 |
| 6–8 | 2 | 2 | 9 |
| 9–10 | 3 | 3 | **12 → loss ~turn 10** |

**That is a ~10-turn game against a passive player.** The baseline measured the current
game running 25–40 turns with VP still climbing at turn 30. A 10-turn doom is a drastic
re-scoping of the mode.

**This is the decision that gates everything else, and it is the designer's, not mine:
what is the intended length of a Creeping Doom game?** Until that is set, every number in
§C3 and §D is unfounded.

My recommendation, offered as a starting point only: **15–20 turns for a competent
player; loss around turn 12–14 for a passive one.** To hit that you need average
destruction of **~0.7 slots/turn**, which means monsters must be *diverted or stopped
roughly half the time*. That is the design brief for the counterplay in §E7; the
interception valve is not a nicety, it is load-bearing for the pacing.

### D3. The felt clock is not the real clock; and it is convex

Slot 1 of 6 Recruits costs the player almost nothing. Slot 6 removes the Recruit market
entirely. **Pain accelerates as the ratchet turns**, which is good pressure design; but
it stacks with a **death spiral**: fewer slots → fewer purchases → weaker board → less
ability to kill monsters or intercept → faster destruction. The curve compounds against
the player exactly when they are least able to respond.

Guardrails I recommend:

1. **Destruction order must be deterministic, not random.** R2 currently says *"a RANDOM
   Recruit market slot."* Random destruction is untelegraphable, and an untelegraphed
   loss is arbitrary rather than earned. It also makes the §E7 interception decision a
   coinflip instead of a decision. Recommend **cheapest-first** (matching Time Crisis's
   shadow track, §13 Mode 2; and item 55 requires a shared representation anyway), with
   the **next target visibly highlighted** during the player's turn.
2. **Reconsider R2's all-Recruits-first order.** Six consecutive Recruit destructions
   wipes the entire Recruit market before Buildings are touched; one enormous cliff
   rather than a curve. Consider **round-robin across categories** or
   **cheapest-first-across-all-markets**, so the player's options narrow smoothly and
   every category stays partially alive longer. This is a tuning question, not a
   correctness one; flagging, not insisting.
3. **The ratchet must never remove the player's ability to act, only to improve.** Verify
   explicitly: with all 12 slots gone, the player still has their starter deck, existing
   permanents, Trophies and ATK generation, so a win remains *possible*. State this in
   the spec as an invariant. It is what keeps the ratchet from feeling hopeless.

---

## E. The eight open questions

### E1. Portal exposure → see §B. **Recommend Portal Ward (Option 3).**

### E2. Do Walls protect the market? **No; with a designed valve instead.**

If Walls protected markets, one unbeaten taunt Wall recreates the measured
"zero pressure forever" exploit exactly. That is disqualifying.

But the naive "no" creates a feel-bad under R2 ordering: your Wall blocks the monster,
the monster is therefore "blocked," and per R2 it goes and eats a market slot. **Your
wall made things worse.** Under my §A3 inversion (markets primary) this evaporates -
the Wall is where you *choose* to interpose, not a redirect.

Either way, the player needs an active answer. Recommended mode-level rule, using only
printed stats; no card changes, PvE-only:

> **Intercept.** Once per monster turn, the player may prevent **one** market-slot
> destruction by either:
> **(a)** spending ATK from their pool equal to the attacking monster's ATK value, or
> **(b)** declaring an active taunt Wall with `currentDef` ≥ the monster's ATK as the
> interceptor; the Wall becomes **Disabled**.
>
> **Price:** (a) costs the alpha-strike pool, i.e. directly delays the win. (b) costs a
> Wall and a repair action. Both are real, both are the right currency.
> **Edge cases:** with no ATK and no standing Wall, Intercept is unavailable; the slot
> falls. Intercept cannot be used twice in a turn regardless of resources. Intercept
> prevents the destruction; it does not damage the monster or move it.

This is the counterplay that makes §D2's ~0.7 slots/turn achievable, and it is the reason
destruction order must be telegraphed (§D3.1); you must know *what* you are saving.

### E3. Permanent or occupancy-based destruction? **Permanent.**

Occupancy would mean killing the squatting monster reopens the slot. That turns the
market into a yo-yo, deletes the ratchet, and re-opens the door to "no reachable loss"
(a player who can always clear can always restore). **Permanence is the ratchet the game
needs.**

Recommended reading of "standing on top of": the monster **destroys** the slot and then
**remains in the field**, attackable. Killing it does **not** restore the slot; killing
it stops *future* destruction. Counterplay is **prevention, not restoration.** That is
the honest, legible contract: what is lost stays lost; what you can control is how much
more you lose.

### E4. Destroyed vs purchased slots; **three states, not two**

| State | Refills? | Counts toward monster win? | Render |
|---|---|---|---|
| `occupied` | n/a | No | The card |
| `empty-refillable` (just purchased) | Yes, from market deck | No | Transient |
| `empty-exhausted` (market deck is out) | No; no cards left | **No** | "Empty slot" (existing) |
| `destroyed` | **Never** | **Yes** | Rubble / distinct visual |

**Edge case the brief has not considered:** the market deck running dry. If
`empty-exhausted` counted toward the monster win, a long game would auto-lose with no
monster involvement. It must not count. The win condition is *"12 slots destroyed"*, not
*"12 slots not showing a card."*

Also needs a ruling: does destroying a slot remove the cards *behind* it from the market
deck, or just the display position (same deck depth, fewer visible slots)? This is
item 55 and it is still open. **Recommendation: display position only**; the deck
survives, you just have fewer windows onto it. Simpler, and it keeps card availability
degrading smoothly rather than in chunks.

### E5. What does "Food consumed" mean? **Food spent from the pool, for any purpose.**

Recommended definition:

- **Counts:** 1 Food per card played from hand; Exchange costs (e.g. Poison Room 3 Food →
  ATK); Supplier's Food → Draw converts. Any Food that leaves the pool by player action.
- **Does not count:** unspent Food lost at end of turn (that is waste, not consumption);
  Food *stored* into a Granary (deferred, not consumed); but Food *released* from a
  Granary and then spent does count, at the point of spending.

**Timing check:** base 3 Food/turn plus Farm output, at 3–5 spends/turn → 10 Food around
**turn 3** for an active player. Correct for a position-1 monster.

The alternative (counting unspent Food) would make it a pure turn-3 timer regardless of
play, which makes the flavour meaningless. Better to keep consumption honest and let the
**positional turn-3 backstop** (§C3) handle the passive player; which is exactly what
the backstop is for.

### E6. Ghoul's Famine cadence; **every turn, but the player can undo it at a price**

"Every turn, unstoppable" is oppressive and self-compounding: Famine zeroes Farm output
(§12A.2), which starves the economy, which weakens the board, which accelerates every
other clock. That is a death spiral with no brake.

"Once, ever" is scenery.

Recommended shape:

> At the end of each monster turn, if the Auspice is not Famine, the Ghoul sets it to
> Famine. The player may change it back on their turn through the normal Auspice use
> queue.

**Price:** the player's Auspice use is spent every turn on defence, so they permanently
lose Mystic draw / Hunter Legend / Harvest food as strategic levers while the Ghoul
lives. That is a heavy, legible, *chosen* cost; and it makes killing the Ghoul feel like
a real liberation rather than a checkbox.

⚠️ **I need a fact I don't have:** how many Auspice changes the player gets per turn under
the §12A.3 use queue. If it is exactly one, the above is clean. If it can be zero on some
turns, the player is locked into Famine involuntarily and this becomes oppressive.
**Please measure or rule on the Auspice use budget before this is built.**

### E7. Player counterplay to market loss; **three layers, no restoration**

1. **Prevent**. Intercept (§E2). Costs ATK or a Wall.
2. **Remove the source**; kill field monsters. Costs ATK, competes directly with the
   Portal race, and under the Ward model also lowers the bar. This is the good decision.
3. **Outrace it**; win before the ratchet finishes. Always available.

**No restoration path.** Restoration would undo the only ratchet the mode has. The
anti-hopelessness guardrail is not restoration, it is the §D3.3 invariant: *destruction
removes the ability to improve, never the ability to act.* Combined with clear
telegraphing (you always see the next slot to fall, and how many turns remain), a loss
under this system reads as earned.

### E8. PvP compatibility; **clean, with one future risk**

| Element | PvE | PvP | Safe? |
|---|---|---|---|
| Market-slot destruction | Monster-only ability | Does not exist (no field monsters) | ✅ |
| Portal Ward | Mode rule | No Portal in PvP | ✅ |
| Positional unseal backstops | Mode rule | n/a | ✅ |
| Ghoul Famine passive | Monster-side rule | n/a | ✅ |
| Intercept | Mode rule, uses printed stats only | n/a | ✅ |
| VP inert | Mode rule; VP untouched on cards | VP fully live | ✅ |

**No card text or stats change anywhere.** The constraint holds.

**Future risk to log now:** §8E's multiplayer plan is *1 monster per player + Portal*. If
monsters ever appear in PvP, market destruction hits a **shared** market; that is a
kingmaking and griefing lever of an entirely different character (destroying the slot the
leader needs). Recommend recording now that **market destruction is explicitly PvE-scoped
and must be re-designed, not inherited, if monsters enter PvP.**

---

## F. What the designer hasn't considered

### F1. 🔴 Possessions plug the market and re-break reachability

R2 states monsters **never** attack Possessions. Possessions sit in **Conjuration market
slots** (§8, §10 item 6; they trigger on draw into the market row and cannot be bought).

Therefore: **a player who keeps Possessions alive in the Conjuration slots makes those
slots permanently undestroyable.** Three Possessions parked in the three Conjuration
slots caps the monsters at 9/12. **Loss becomes unreachable again**; the exact bug the
baseline measured, reintroduced through a side door. And the strategy is not obscure:
"don't kill the Possessions" is a one-line realisation that any competent player will
find within two games.

**This is the most important finding in this review.**

Recommended ruling (needs designer sign-off):

> A monster whose next target is a Possession-occupied slot **skips to the next
> destroyable slot**. If **only** Possession-occupied slots remain, the monster destroys
> the slot **together with the Possession**; the Possession is removed from the game,
> grants **no VP to anyone**, and the slot becomes `destroyed`.

This preserves R2's spirit (monsters don't waste turns killing their own kin) while
closing the reachability hole. The player still gets a genuine tactical choice; leaving
a Possession up buys time but does not buy safety.

### F2. Simultaneous-victory resolution

If the 12th slot falls on the same turn the player could kill the Portal, who wins? The
monster turn fires at `endTurn`, before `startTurn` (§13A). So:

> **Recommend: the player's win is checked immediately on the killing blow, during their
> turn, and ends the game before the monster turn fires.** Player wins ties by
> construction. Cleanest and most satisfying; the last-second clutch kill should count.

### F3. Caravans are a premium decoy

Caravans are **highest** targeting priority (§13A) and cost 1 Food to play. Under R2
ordering they are the perfect chump-block (see §A3); a self-removing decoy that costs
almost nothing and eats a monster's whole turn. Under the §A3 inversion this is much less
severe (a Caravan only diverts an *opportunistic* attack), but the interaction should be
explicitly ruled either way.

### F4. Telegraphing gaps; the biggest UX risk

Three things the player must be able to see, and currently cannot:

1. **The doom counter.** A persistent, prominent **"Incursion: N/12"** track. This is the
   game's central clock; it cannot live in a tooltip.
2. **The next slot to fall**, highlighted during the player's turn. Without this,
   Intercept (§E2) is a coinflip and destruction feels arbitrary. This is *why* I
   recommend deterministic destruction order over R2's "random."
3. **Per-monster unseal countdowns**; both the behaviour trigger and the positional
   backstop turn, with a live "unseals in N turns." Currently unseal conditions are in
   queue tooltips only (V10-14).

A doom clock the player cannot read is not pressure; it is noise.

### F5. Do not tune before you re-measure

The baseline's method is the right one and should be re-run against the new spec **before
any number in this document is treated as real**:

- **Passive probe**; plays nothing, buys nothing. Must now reach **loss** (target: ~turn
  12–14). If it does not, reachability is still broken.
- **Turtle probe**; plays one cheap permanent per turn and nothing else. Under R2
  ordering this should expose the chump-block; under the §A3 inversion it should lose.
- **Possession-plug probe**; deliberately preserves market Possessions. Must reach loss
  once F1 is ruled.
- **Unseal-rush probe**; races to expose the Portal without killing anything. Under the
  Ward model this should no longer be a free win.

The reachability findings are what matter; bot-quality caveats (baseline §5) apply only
to balance numbers.

### F6. Retire or rescope the old loss condition

`checkLossCondition`'s `noPerms && noCards` is measurably dead code (baseline §1). Once
market strangulation is the loss condition, either delete it or explicitly demote it to
a secondary trigger, and update §13A "Win / Loss" and §13 "Single Player Win & Loss
Conditions"; which currently both state a *different* loss condition again ("destroys
your last active permanent"). **Three documents currently state three different loss
conditions.** Surfacing this rather than picking one: §13, §13A and the new brief all
need to be reconciled in the same edit.

---

## Summary of decisions needed from the designer

| # | Decision | Blocking |
|---|---|---|
| 1 | **Target game length** for Creeping Doom | All of §C, §D |
| 2 | **Re-rule R2's target priority**; markets primary, permanents obstacles? (§A3) | The core incentive inversion |
| 3 | **Portal exposure model**. Ward recommended (§B) | Item 59, item 56, the whole win path |
| 4 | **Possession-plugged slots** (§F1) | Loss reachability; reintroduces the measured bug |
| 5 | **Positional unseal backstops** replacing per-monster elective triggers (§C3) | Curve reachability + variance |
| 6 | **Deterministic destruction order**, replacing R2's "random" (§D3.1) | Telegraphing, Intercept viability, item 55 |
| 7 | **Auspice use budget per turn**; measurement needed (§E6) | Whether the Ghoul passive is oppressive |
| 8 | Confirm **explicit removal** of §13A's one-monster-per-turn throttle (§A2) | Cork B |

Items 2, 3 and 4 are the ones I would not build without.

---

# ADDENDUM. Delta after Rulings 1 / 1a / 2 (2026-07-20)

**Ruling 1 (R2 targeting unchanged; permanents primary); accepted.** Rebuttals (a) and
(c) hold. **Rebuttal (b) is correct and my §A3 "repair feeds the monsters" claim was
wrong**; `grantMidTurnIncome` restores same-turn function, so repair is genuine
recovery, not decoy maintenance. §A3's repair paragraph is **withdrawn**.

**Ruling 2 (Walls don't protect markets); accepted, matches §E2.** The Intercept valve
(§E2) becomes more load-bearing, since Walls now provide no market cover at all.

## G1. The DEF-threshold problem; §A3's objection survives in mutated form

Targeting validity is *"enabled AND defense lower than the monster's attack value."*
Field-monster ATK values (§8E): **4, 5, 5, 6, 6, 7, 7, 8, 9.**

A permanent whose DEF **meets or exceeds** the attacker's ATK is **not a valid target** -
so the monster falls through to the market. Therefore:

> **Making your board tougher pushes monsters onto the markets. Defence is anti-defence.**

The stall strategy is not "build nothing" (fixed) and not "build well"; it is **build
disable-able chaff**: keep exactly N low-DEF permanents enabled, where N = field monsters.
Optimal DEF is *just under* the weakest attacker's ATK. A player who over-invests in DEF
is punished on the market clock. This is the residual of my §A3 objection and it is not
addressed by Ruling 1.

**Cheap monster-side fixes (no card changes); pick one, needs a ruling:**
- **(i)** A monster that finds permanents in play but none it can beat **spends its action
  attacking the toughest one anyway and fails** (no market attack). Toughness then buys a
  wasted monster turn; legitimate, purchasable, and capped by repair throughput.
- **(ii)** Extend the Wall Siege combine: blocked monsters gang up on the toughest
  permanent; only if the *combined* total still fails does anyone hit a market. Reuses
  existing machinery, more code.
- **(iii)** Accept it, and make market attacks *not* fall-through-only (i.e. one monster
  always hits the market regardless). Simplest guaranteed clock.

I'd take **(i)**.

## G2. Ruling 1a; answers to your four questions

**Q1; pacing/curve.** Two effects, and they point opposite ways.
- Trophies with DEF ≥ attacker ATK (**Gargantuan 6, Dank Beast 6, Dragon 8, Noxious 9**)
  are *invisible* to most attackers and therefore **do not soak**; 1a delivers less
  extra soak than expected. Only **Ghoul (4), Minotaur (5), Silent Stalker (5)** reliably
  soak.
- Net on the doom clock: **market loss is back-loaded.** Early on (1–2 field monsters) a
  1–2 permanent stall is trivial, so slots barely fall; late (4 monsters + Rampage) the
  stall collapses. §D2's "1 slot/turn from turn 3" is **too aggressive; withdraw it**.
  The real shape risks becoming *nothing, nothing, nothing, dead*; a cliff, not a curve.
  Recommend re-running the probes before setting any pacing numbers.
- **Death-spiral tightens:** destroyed Recruit slots remove the repair engines
  (House Hand / Repair Master / Contractor) that sustain the stall. Losing slots costs
  repair throughput, which costs enabled targets, which costs more slots. Guardrail:
  §D3.1 telegraphing + §E2 Intercept are now mandatory, not optional.

**Q2; new degenerate strategies. Yes, two, both perverse.**
1. **Auspice de-protection.** The Auspice +1 can push a Trophy *over* an attacker's ATK
   threshold, removing it from the target pool and **diverting that monster to the
   market**. So the optimal play is often to switch *away* from a Trophy's Auspice to keep
   it targetable as a soak; "un-protect your stuff so it eats the hit." Feel-bad and
   backwards. Fixed by G1(i).
2. **Threshold chaffing** (G1); cultivate permanents at DEF just below the weakest
   attacker. Strictly better than a strong board under current rules.

**Q3. Trophy passive cascade (not asked, worth flagging).** Disabling **Gargantuan**
strips +2 DEF from *all* creatures at once, dropping a whole row below attacker ATK
thresholds and converting them to valid targets in a single beat. A good designed
cascade, but a swingy cliff that must be telegraphed. Also **Dank Beast** counts only
Active Trophies, so one disable cuts ATK immediately.

**Q4; rules collision, engineering will hit this.** 1a says Trophies are *"repairable via
the normal repair path"*, but §13A.9.2 / §13B lock **"repair is buildings-only; `useRepair`
rejects creatures"**, and most Trophy monsters are Creature-type. 1a must state explicitly
whether it overrides that guard for Trophies specifically, or whether Trophies use the
heal path (Cleric/Exorcist/Enforcer). **Needs a one-line ruling.**

## G3. Possession-plug (§F1); severity UNCHANGED, arguably raised

Nothing in Rulings 1 / 1a / 2 touches it. Monsters still never attack Possessions;
Possessions still occupy Conjuration market slots; monsters still cap at **9/12** and
**loss remains unreachable**.

Slightly *worse* under confirmed permanents-primary: the chaff-and-repair stall already
back-loads market loss (G2/Q1), so the game leans harder on the final slots; and if three
of them are structurally unreachable, the ratchet cannot finish at all. §F1's recommended
ruling stands unamended. **Still the #1 reachability blocker.**

## G4. Portal Ward (§B); unchanged, and now *more* necessary

Ward is orthogonal to targeting, so the proposal is unaffected. But permanents-primary
makes the paradox **worse**, not better: monsters now leave portal defence in the
*ordinary* case (attacking a permanent), not only when blocked. Under the existing
boolean, the Portal will be exposed early and routinely. Recommendation stands, with
higher priority.

> **SUPERSEDED (2026-07-20):** Portal Ward was **rejected** by the designer. Binary
> exposure is intended; the skill test is mustering burst ATK inside the window. §G4 is
> withdrawn; see §H3 for the pacing analysis under binary exposure.

---

# ADDENDUM 2. Delta after Possession / Ward / Reinforcement rulings

**Correction accepted:** all seven Trophy monsters are `isCreatureType:false`; only Fiend
and Nightmare (non-Trophy) are Creature-type. `useRepair` accepts Trophies. My §G2/Q4
"repair rejects Trophies" flag was **false** and is withdrawn.

## H1. Wall-Siege generalisation. I agree, my fix was worse

The coordinator is right and I withdraw §G1(i). "Monster attacks the toughest permanent
and fails" means **one** high-DEF permanent absorbs **every** monster **every** turn at
**zero** upkeep; a free total stall, strictly worse than the problem it solves.

**Generalising Wall Siege is the better shape**, for a reason beyond tidiness: it makes
the toughness bar **scale with the number of unsealed monsters**. A DEF-8 permanent is
impassable to 1 monster, cracks to 2, is trivial to 4. Board investment buys time
proportional to how early you made it; which is exactly a creeping-doom curve, and it
comes free from a mechanic that already exists.

**Residual edge to check, not fix:** a permanent with DEF greater than the *combined* ATK
of all field monsters still filters out and still pushes them to markets. Combined ATK of
4 field monsters is roughly **20–28**. Worth a reachability check on max attainable DEF
(base + attachments + Wall Sets + Gargantuan/Fortress passives); if a player can exceed
~24 DEF on a single permanent, "defence is anti-defence" survives at the extreme.

## H2. Possession-plug ruling; closes the exploit, opens a different one

**Rules 1 and 2 are clean.** Skipping possessed slots is correct (nothing to gain), and
"destroyed slots can never return or be possessed" is the right ratchet. Good ruling.

**Rule 3 is where I disagree with your read.** You called it a *mutual* stalemate. I don't
think it is. I think it is **player-favourable, and a total pressure vacuum.**

Per §13A Player Targeting, the player may attack **any `guarding` monster directly**. So
when monsters return to portal defence:

| Side | Available action during the stall |
|---|---|
| Monsters | **None.** Guarding monsters do not attack. No markets left to take. |
| Player | **Kill guarding monsters, one at a time, with unlimited turns and zero incoming pressure.** |

When the last one dies, all four are `dead` → zero guarding → portal exposed → win. The
player never has to clear the Possession at all. The "long-shot win" is not a long shot;
it is a safe, untimed grind.

**The degenerate line:** the doom clock's off-switch is *reaching 9/12*. A player who has
banked a board and wants the pressure to stop should **let the markets burn**. That
inverts the entire mode; losing 9 of 12 market positions becomes a winning move.

**What gates it:** monsters only return to portal defence when they have no valid
*permanent* targets either (permanents are primary). So the line requires a board with no
beatable permanents; which is **exactly the high-DEF board that the "defence is
anti-defence" filter produces**. The two open decisions are coupled: the DEF-threshold
ruling largely determines whether this stall is reachable. If Wall-Siege generalisation
lands, monsters combine against the tough board instead of parking, and the vacuum mostly
closes on its own.

**Mitigation already in the rules:** live Possessions attack the player's permanents
passively (§8), so plugging is not free. That is real counter-pressure; but it is
subject to the same DEF filter, so against a high-DEF board it may also do nothing.

**Recommend the designer decide:** whether guarding monsters at the stall state should
remain fully passive. If the answer is "the doom clock should never fully stop," this
needs a ruling. I am not proposing the mechanism here.

## H3. Pacing with binary exposure retained

Ward is off the table; not re-advocating. Here is the honest analysis of what remains.

**Exposure cannot occur before the 4th unseal.** Zero-guarding requires every monster to
be unsealed *and* fielded. So the **unseal schedule is the win-path gate**, and the
position-4 backstop effectively *is* the minimum game length. That is a cleaner dial than
I gave the design credit for.

**The resulting shape is a genuine race, and a good one:** the player's win window opens
at the 4th unseal; which is also the moment market destruction peaks (4 monsters
fielded). Endgame = "all four are out, slots are falling fastest, you have a few turns to
land the burst." Legible and tense.

**And it rehabilitates item 59.** Under binary exposure the unseal-rush is not a bug; it
is the mode's central gamble. Pulling unseals forward (buy 2 Conjurations, play a Wall,
send a card to Legend) opens your window early *and* starts the doom early. Risk priced
against reward. That is the right structure.

**It all hinges on one unmeasured number.** The Portal is 7 HP with no Auspice tag, and
attack is binary (item 47). So: **how early can a competent player muster 7 ATK in a
single turn?**

- If that is ~turn 6–8, the mode collapses: rush four cheap unseals, alpha-strike,
  skip the doom system entirely. The designer's assumption ("a lot of food to drop a lot
  of gear") would not hold.
- If it is ~turn 12–14, binary exposure works exactly as intended and needs nothing.

**This is the measurement I'd ask for before any further pacing decisions:** distribution
of *earliest turn a bot reaches 7+ single-turn ATK*, and *earliest turn all four unseals
can be forced*. The gap between those two curves is the mode. I can't judge it without
them, and I'd rather say so than guess.

**Target game length (recommendation, contingent on the above):** set the **position-4
unseal backstop to the intended minimum game length**; around **turn 10–12**, yielding a
12–16 turn game, with elective triggers letting a skilled player pull the window to ~8 at
the cost of an early doom clock.

## H4. Reinforcement Wave; reading (b) is clearly better

**Reading (a); "open" = dead.** Reinforcements arrive only after kills.
- **Breaks the player's win path.** Exposure needs zero guarding; every kill summons a
  replacement guard, so killing monsters stops producing exposure. The window never opens
  until the 4-card reserve is exhausted.
- Converts the mode from "seize a window" into "grind through 8 bodies"; the opposite of
  the designer's stated intent for binary exposure.
- Mild monster-favourable spiral (more monsters → more market pressure → weaker player),
  but self-terminating at 8. **Not recommended.**

**Reading (b); "open" = nobody in portal defence.** A reinforcement plugs the gap.
- **This is the right mechanic, and it solves three problems at once:**
  1. It is the natural **governor on the unseal-rush**; empty the portal and it refills.
  2. It converts exposure from a permanent flip into a **pulsing, repeatable window**:
     open → seized or plugged → reopens. Far better felt experience than one binary flip,
     and it matches the designer's "take advantage of that moment" framing exactly.
  3. It supplies the **second escalation axis** I flagged as missing in §C4; late-game
     inevitability; better than my Rampage suggestion, because it is one mechanic doing
     two jobs.
- **Timing is the whole design.** If the reinforcement arrives on the *monster* turn, the
  player sees zero-guarding at the start of their turn and gets a clean, telegraphed
  one-turn window. If it arrives instantly on the last monster leaving, the window never
  materialises and the win path is dead. **This needs an explicit ruling.**
- **Runaway risk: real but bounded and fair.** Each missed window permanently adds a
  monster, accelerating market loss and making the next window harder; a death spiral,
  but a *telegraphed, self-inflicted* one (the player chose to open the window). The
  4-card reserve is the natural cap; I would not raise it.
- **Terminating property worth keeping:** once the reserve empties, the window stays open
  permanently. Both sides get inevitability; the player is guaranteed an eventual
  standing window (no infinite lockout), and by then the monsters have had four extra
  bodies of pressure. Non-arbitrary end to the loop.

**Should reinforcements arrive pre-unsealed? Yes; strongly.**
- If they arrive **sealed**, they sit in `guarding` and block exposure until their trigger
  fires. If the trigger is elective and the player declines it, the window is locked
  **permanently**. That is a hard lockout and a game-ender.
- If they arrive **pre-unsealed** into `guarding`, they plug the window this turn and
  field normally next monster turn; producing the plug/reopen pulse that makes (b) work.
- Bonus: it **sidesteps the 8-triggers problem** entirely. Reinforcements need no unseal
  conditions, so the trigger review stays scoped to the original four.

**Interaction to note:** Possession-ruling rule 3 (monsters return to portal defence) and
reinforcements both plug exposure. They are consistent, but combined they mean the player
can face a re-plugged portal from two independent causes; worth confirming that is
intended rather than accidental.

> **Superseded by ruling 5 (2026-07-20):** reinforcements arrive **sealed**. My lockout
> objection is **withdrawn**; a sealed reinforcement sits in `guarding` and guards are
> directly attackable (§13A), so the win path cannot be permanently locked; it costs
> kills, not access. Consequence to note: this is reading **(a)**, the attrition loop.
> The pulsing-window behaviour of (b) is gone; the mode is now "kill 7 bodies, then the
> window stands open." Against a ~16-turn target that is plausible, but it means the
> **kill count, not the window, is the player's clock.**

---

# ADDENDUM 3. The retreat-on-impotence ruling

## J1. The ruling may have deleted the market-attack branch entirely

Under R2, a market is razed when a monster has **no attackable permanent**. The designer's
ruling replaces that outcome with **retreat to portal defence**. But "no attackable
permanent" covers three very different board states, and the ruling collapses all three:

| # | Board state | Should the monster… |
|---|---|---|
| 1 | Player has **no permanents at all** | ?; **unaddressed** |
| 2 | Player has permanents but **all are Disabled** | ?; **unaddressed** |
| 3 | Player has **active permanents, all DEF > monster ATK** | Retreat (the designer's example) |

The designer's example is **case 3** only. If the ruling is read to cover cases 1 and 2 as
well, **markets are never razed under any circumstances** and the monster win condition is
unreachable again; which directly defeats ruling 9 (*"has never seen the monster win
condition fire and wants to"*).

**This needs an explicit ruling on cases 1 and 2 before anything else is decided.**

## J2. The ruling restores the chump-block; and invalidates the designer's own rebuttal

The designer's rebuttal to my original §A3 chump-block objection was: *"there are up to
FOUR monsters. One permanent absorbs one monster's action; the other three still hit
markets."* **That is no longer true under this ruling.** Chain:

1. Player plays one Farm (1 Food, DEF ~2–3).
2. Monster 1 attacks and **disables** it. A disabled permanent is not `active`, so it
   leaves the target pool.
3. Monsters 2, 3, 4 now find **no attackable permanent** → under the new ruling they
   **retreat to portal defence** instead of razing markets.
4. Net: **1 Food per turn stalls all four monsters, permanently.** No DEF investment, no
   repair-throughput race, no fortress required.

This is **cheaper and more reliable than the fortress line** the coordinator identified,
and it requires no discovery; a player will stumble into it by accident. It is the
dominant strategy under this ruling.

## J3. Does the synthesis hold? Partially; necessary, not sufficient

The coordinator's siege-first synthesis is **correct and I endorse it**, with two caveats:

**It fixes the fortress line.** Combined ATK (~20–28 across four monsters) cracks any
realistically attainable board, and the ≥2-participant requirement (§13B) means a lone
early monster still retreats from a modest board; so board investment buys time
*proportional to how early you made it*. That is the escalation curve, free.

**It does NOT fix the chump-block (J2).** Siege needs an *active* permanent to combine
against. In the J2 line the only permanent is **disabled**, so there is nothing to siege;
the siege attempt fails and the monsters retreat exactly as before. The synthesis leaves
the cheaper exploit untouched.

**It requires extending a LOCKED mechanic.** §13B states *"Only taunt Walls (bg3) are
siege targets. Portcullis and Fortress are never siege targets."* Generalising siege to
any permanent is an explicit override of a must-not-regress entry and needs the designer's
direct authorisation; it is not a free extension.

## J4. Cleaner third option: distinguish *defended* from *undefended*

Split cases 1/2 from case 3; which is what the designer's own thematic reasoning
actually implies:

> A monster retreats to portal defence only when the realm is **defended**; i.e. at least
> one **active** player permanent exists that it cannot beat.
> If there are **no active permanents at all** (empty board, or every permanent Disabled),
> the realm is **undefended**; the monster razes a market slot.

Paired with siege-first for case 3, this gives:

| Board state | Monster behaviour | Degenerate line closed? |
|---|---|---|
| Active permanents, beatable | Attack them (unchanged, permanents-primary) |; |
| Active permanents, too tough | **Siege first**; retreat only if combined ATK also fails | Fortress line ✅ |
| No active permanents (empty or all disabled) | **Raze a market slot** | Chump-block ✅ |

Why this is the right cut:

- **It answers the designer on their own terms.** "Would you rather attack a free space or
  defend the portal?"; the answer depends on whether anyone is holding the line. A realm
  whose defences are all smashed is not defended; that is precisely when the town burns.
  The Ghoul in their example faces a *standing* DEF-5 permanent and goes home. A Ghoul
  facing a razed, wide-open realm has no reason to go home.
- **It makes repair genuinely load-bearing**; the repair-throughput race the designer
  already endorsed as a legitimate strategic axis becomes the actual thing standing
  between the player and market collapse.
- **It makes the monster win reachable**, satisfying ruling 9, without any "extra
  aggression" the designer was reluctant to grant. Monsters only raze when the player has
  genuinely lost the field.

## J5. Other failure modes of retreat-on-impotence

- **Retreat closes the player's own win window.** Binary exposure needs zero guards. A
  tough board sends monsters home, re-plugging the portal. So the player must choose:
  **tough board** (safe, no market loss, but no exposure; must grind every monster down)
  or **weak board** (monsters out, portal exposed, fast win, markets burning). That is a
  genuinely elegant dial and worth keeping deliberately. **The problem is only that the
  safe branch has no clock on it**. J4 supplies one.
- **One pressure source survives the stall:** ruling 7 (Ghoul's Famine passive fires every
  turn while alive) keeps farms at 0 even with every monster parked. That is the only
  thing pressuring a stalling player, and it bites only farm-dependent boards. Worth
  noting as a partial, uneven mitigation; not a substitute for J4.
- **Death-spiral check on J4:** all permanents disabled → markets raze → weaker board →
  more disabling. This spiral is *intended* (it is the ratchet), it is telegraphed, and
  the player breaks it by repairing. Acceptable.
- **Ruling 13 noted:** Possessions are a separate class and do not act on the monster
  turn. My "live Possessions apply counter-pressure to the plug" mitigation is
  **withdrawn**. HAUNTED slots are now pure defensive value to a stalling player, which
  slightly raises the priority of the ruling-1 edge case, though J4 reduces its reach.

---

# ADDENDUM 4. Walls under generalised siege

## K1. Reading 1; taunt and siege are orthogonal, but only if ordered correctly

I agree with the coordinator's position: the Wall's unique property is **targeting
priority** (a gate), and siege is merely **the method** for cracking something too tough.
Generalising the method does not erode the gate.

**But there is a real trap.** Being "blocked by a taunt Wall" and being "blocked by a
too-tough permanent" are the same condition in code; no beatable target. If siege target
selection is written independently of the taunt gate, a monster stopped by a standing Wall
will now legally combine-siege a **back-row** permanent instead. That is **silent taunt
bypass**, and it would delete the Wall's entire function.

**Required precedence (ask 1), concretely:**

1. **Flying attackers** (Silent Stalker, Nightmare) ignore all of this; unchanged.
2. **A standing taunt Wall (bg3) exists** → for non-flying monsters, the *only* legal
   target, **solo or siege**, is a taunt Wall. Siege combines against the **lowest-DEF
   standing taunt Wall** (consistent with the existing §13 focus-fire rule). Back-row
   permanents are not siege-eligible while any taunt Wall stands.
3. **No standing taunt Wall** (none played, or all Disabled) → the general pool opens.
   Siege may combine against any permanent no single monster can beat.
4. **Within the siege pool, target the LOWEST-DEF permanent the combined pool can beat** -
   not the toughest. If siege picked the toughest, DEF investment would paint a target,
   which is a soft re-run of "defence is anti-defence." Lowest-first means a maxed DEF-18
   permanent is the *last* thing to fall, so the investment is genuinely rewarded.

With this ordering, generalised siege does not change which permanent monsters *prefer*;
it only changes what they can *reach*. The Wall's identity is intact.

## K2. Reading 2; the value is not front-loaded, it is investment-gated

Working the actual numbers against monster ATK (4, 5, 5, 6, 6, 7, 7, 8, 9), where
`beatable = atk >= currentDef`:

| Wall configuration | DEF | Monsters that can solo it |
|---|---|---|
| Bare Wall | 6 | 6 of 9 (all but Ghoul 4, Minotaur 5, Stalker 5) |
| Wall + 1 Meurtrière | 8 | 2 of 9 (Dragon 8, Noxious 9) |
| Wall + 2 Meurtrières | 10 | **0 of 9** |
| Wall + 3 Meurtrières | 12 | 0 of 9 |

So the defect is not "early-game only." It is that a **bare** Wall is weak and the card's
real power lives in the **attachment layer**; which now stacks additively. One Meurtrière
takes a Wall from stopping 3 monsters to stopping 7. That is a legitimate investment
curve, and it matches the designer's own stated rationale ("plays to the player's
success").

**More importantly, generalised siege *gives* Walls a late-game role rather than taking
one away**; which inverts the designer's worry:

- Without generalised siege, a DEF-10 Wall is unbeatable by any single monster **forever**
 ; an infinite lock, and one of the exploits already identified.
- With it, four monsters (combined 20–31) always crack it eventually; but they must
  **spend their turn doing so**, which is a turn not spent razing markets or hitting the
  back row.

So the Wall's late-game function is **converting monster actions into wasted turns**. That
is a real, scaling role, and it only exists because siege was generalised. Siege and Walls
are complementary, not in tension.

**Also worth telling the designer:** under the case-1/2/3 ruling, a standing Wall is an
"active permanent blocking them," so a *lone* early monster that cannot beat it (siege
needs ≥2 participants) **retreats to portal defence rather than razing**. Walls therefore
already protect markets *indirectly*, without needing the "Walls protect markets" rule
that was correctly rejected. The designer's original concern; that Walls would be
pointless in PvE; is answered twice over.

**Verdict on ask 2:** not a defect. Acceptable and, I would argue, good design.

## K3. Ask 3; mode-level levers (no card changes)

1. **Siege consumes the action of every participant.** This is the single biggest lever
   and needs an explicit ruling. If a successful siege cracks the Wall and participants
   *then* attack, Walls are weak. If the siege *is* their turn, one Wall absorbs an entire
   monster turn per repair cycle; a scaling, late-relevant role. **Recommend: consumes.**
2. **Taunt gate applied before siege target selection** (K1); without it, generalised
   siege silently deletes taunt.
3. **Lowest-DEF-first siege targeting** (K1.4); keeps DEF investment protective rather
   than target-painting.
4. **Do not** make disabled Walls retain taunt. It would blunt the ratchet and reads badly.

**Residual, flagging not fixing:** Silent Stalker and Nightmare fly and ignore Walls
entirely. A wall-centric player who draws both gets very little from the strategy; the
queue-randomness variance problem from §C2 showing up again in a specific matchup. Worth
knowing before playtest reports blame the Wall card.

---

# ADDENDUM 5. Ghoul-as-gate (flags only)

1. **Doom under-performs; confirmed, and worse than it looks.** Position 1 now razes
   nothing and unseals later (20 Food, ~turn 5). Doom rests entirely on the 3 random
   monsters, whose triggers are mostly elective. **Fiend (turn 3) is the only reliable
   razer in the pool**; if it isn't drawn, a passive early game can be near-silent. The
   tabled unseal-trigger-reliability question (§C2) is now **load-bearing**, not
   deferrable: with Ghoul neutered, an all-elective 3-monster draw can produce *zero*
   market pressure through the mid-game. **Compounding trap:** silence-from-start means
   Noxious Beast's "2 Conjuration purchases" trigger **cannot fire while Ghoul lives** -
   so if Noxious is one of the three, it is gated behind killing Ghoul *first*, dropping
   the early live-razer count from 3 toward 2. Watch the passive-probe raze rate.

2. **Haunted-conjuration soft-lock; agree it's rarer, but the tail is deeper.** Killing
   Ghoul early is incentivised, so most games leave that state. But razing hits
   Conjuration slots **last** (Recruit/Building first), so the 11/12 endgame *converges*
   on Haunted conjuration slots; and if Ghoul is still alive there, clearing the
   Possession is doubly useless (silenced *and* the win is already near). The common case
   improves; the worst case (Ghoul alive at endgame) gets worse.

3. **Degenerate line to watch; "keep Ghoul alive on a non-conjuration build."** A
   Siege/Warrior player loses nothing to silence, and **not killing Ghoul (and nothing
   else) avoids waking Nightmare and Dank Beast** (both unseal on a monster defeat). So
   unseal-rush + siege build + zero kills = silence is free and two doom triggers stay
   dormant. Conversely the design's *intended* early Ghoul kill **wakes** Nightmare/Dank
   Beast if present; killing your gate accelerates your doom. That tension is probably
   good, but confirm it's intended, not a surprise spike.
   **On-ramp: sufficient, with one trap.** Generic (Recruit/Warrior) and Siege
   (Catapult/Trebuchet) ATK both damage Ghoul, and Dojo/Armory/Poison Room exchanges are
   Building-market (open). 4 ATK by turn 4–6 is plausible. The trap is the **pure-
   conjuration player**: their only ATK source is silenced, and they can't kill Ghoul to
   un-silence it; a hard chicken-and-egg. It's self-inflicted (two other markets are
   open), but a new player who commits to creatures will feel it as an unexplained wall.
   Telegraph the silence clearly.

4. **Start-from-game-start vs unseal-gated:** start-from-game-start is correct for the
   two-tier intent, but note it lengthens silence to the whole pre-kill game and creates
   the Noxious gating in flag 1. Unseal-gating would remove that compounding but weaken
   the "his presence suppresses magic" fantasy. No change to my read; just log that
   flag-1's doom-quiet risk is a *consequence* of the from-start choice, so they move
   together.

---

# ADDENDUM 6. Readiness verdict

**Verdict: CONDITIONAL GO for first playtest. NOT yet sealable as "done."**
Two cheap guardrails must land first; everything else is legitimately a tuning item.
The Ghoul silence→+1-Inf-tax change is a real improvement; it deletes the pure-
conjuration chicken-and-egg trap and the Haunted-slot double-lock from my prior flags, so
those are **withdrawn**. What remains is two structural gaps, one of which threatens the
playtest's ability to answer the question it exists to answer.

## MUST-FIX before playtest (both cheap)

**M1. A non-elective doom backstop. This is the real blocker.**
No turn-based backstop was implemented; 7 of 8 non-Ghoul triggers are elective and Ghoul
razes nothing. So a competent player who simply declines the elective triggers (stays
under 4 permanents, buys no Conjurations, plays no Wall, sends nothing to Legend, kills
nothing) unseals **at most Fiend**; and Fiend is only *sometimes* in the 3-random draw.
**In those games the doom clock never starts, and loss is unreachable; the exact baseline
bug, reintroduced by queue RNG plus player choice.** Reinforcements do not save it: they
arrive *sealed* with their own elective triggers, so they can sit dormant too.

Why this is a seal-blocker and not a tuning item: the stated purpose of this playtest
(ruling 9) is to *see the monster win fire*. A version where the clock can silently fail
to start produces "the monsters never did anything" reports; indistinguishable from the
original defect; and the team cannot tell a tuning problem from a dead clock. **An
unreliable doom clock makes the playtest unable to produce signal.**

Minimal fix: a turn backstop on the 3 random monsters (and reinforcements); unseal by
turn N regardless of triggers. A crude flat "any still-sealed monster unseals at turn 8"
is enough for a first test. This is the §C3 recommendation reduced to its cheapest form.

**M2. A terminal safety net so the game cannot HANG.**
The 11/12 state is not a true lock in the player's favour; but it *can* become a literal
hang: 11 razed, remaining slot(s) Haunted (monsters skip), nothing left to raze so
monsters retreat to guarding, and a player who can neither muster the exposure-burst nor
grind the guards sits in a state where **no win condition can fire and nothing advances.**
Rare, but a frozen game in front of a playtester is the most embarrassing possible
outcome. The full "Last Stand" (Possession matures → razes its own slot → doom countdown)
is the elegant fix and I endorse it later; but for the playtest, the cheap insurance is a
**turn cap or a simple loss/stall-detection** that forces a resolution. Do not ship a
state that can hang forever.

## FINE as known tuning items (ship and learn)

- **Soft-lock elegance.** With M2's safety net in place, the 11/12 stall is a rare tail of
  an already-losing game, and the player retains an active out (kill guards → expose).
  Not a blocker. "Last Stand" is post-playtest polish.
- **Exposure-burst difficulty.** Binary exposure + sealed reinforcement means the player
  must clear the last guard *and* land 7 on the Portal in the **same turn** (a reinforcement
  re-plugs next monster turn). That may be too steep; but it is exactly what your
  earliest-7-burst measurement will tell you. Measure, don't pre-tune.
- **Trophy Auspice de-protection** (§G2/Q2). Auspice +1 can lift a Trophy over an
  attacker's ATK and divert it; minor, surfaces as odd AI, tune later.
- **Wall/flier variance**. Stalker+Nightmare draw guts a wall build; queue-composition
  variance, log it for reports.
- **Deterministic Recruits→Buildings→Conjurations raze order**; fine to start; watch that
  the all-Recruits-first cliff (§D3.2) doesn't feel like a wipe rather than a squeeze.

## Q4; single biggest risk to the playtest

**The doom-quiet queue (M1).** It is the only remaining issue that can make the whole pass
*look* like it failed: a tester draws an all-elective queue, plays naturally, watches the
monsters do nothing, and reports the original baseline symptom. Everything else degrades
gracefully into a tuning note; this one degrades into "the fix didn't work." Land M1 and
the playtest can actually stress the design instead of stumbling on its ignition.

**Bottom line:** coherent and near-complete. Land M1 and M2; both small; and it is ready
for human playtesters and honest tuning from their reports. Without M1 the playtest risks
being uninterpretable; without M2 it risks an on-camera hang.
