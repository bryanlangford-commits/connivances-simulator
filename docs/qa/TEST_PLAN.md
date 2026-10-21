# Test Plan

## Framework
_Not yet set up. Recommended: GUT (GDScript) and/or GoDotTest/GdUnit (C#),
depending on which language ends up carrying the gameplay logic._

## Coverage by System
_One section per system, added as features land. Example shape:_

### Movement
- Status: not implemented
- Automated tests: -
- Manual checklist: -

### Connivances Simulator (`simulator/connivances_simulator_v10_23.html`)
Prototype HTML/JS rules engine, not the Godot codebase; testing here means
reading/exercising the embedded JS directly rather than GUT/GdUnit. Findings
below came from static review of the combat/targeting logic plus a live
playtest session at http://localhost:8791 (served via `simulator/serve.ps1`).
- Status: reviewed; combat/targeting, unseal, VP, food/Auspice, repair/heal,
  and the Warrior-synergy Inf web read; 4 of 6 findings confirmed live by
  driving the running engine via the browser console.
- Automated tests: none (engine is DOM-coupled, not standalone). A headless
  harness would pay off; see "Systemic pattern" below.
- Manual checklist: turn 1 economy ✅. Empty-deck reshuffle (`drawCards`,
  1191-1202) ✅ correct. Negotiator retroactive Inf ✅ traced correct across
  pure-Warrior sequences; ⚠️ **but see the Trainer-Farmer defect below; my
  original "mixed sequences" claim did NOT include Trainer-buffed Farmers and
  was overstated.** Trophy-kill paths
  (field 1610 / guard 1707 / portal 2446) ✅ consistent (all → discard).
  Not yet exercised: Wall Siege (`checkWallSiege`), Caravan journey/destruction,
  Expediter attach/detach DEF math, heal-any-field (Enforcer).
- **Cleared (looked suspicious, not bugs)**: Warlord retroactive burst
  over-counts with 2+ Warlords, but Warlord is `qty:1` and resets each turn,
  so two can never coexist; unreachable, not a defect. Possible balance note
  (not a bug): all guards can be *unsealed* (not killed) to expose the Portal,
  enabling a potential fast-win; flag for tcg-designer, not QA.

**Systemic pattern (root cause behind 3 of the findings):** the engine mixes
two incompatible strategies for ongoing effects. Some are *recomputed live*
every turn / on read (Golem, Gargantuan, Fortress, Library/Armory/Farm set
pairs via `applyRecurringSetBonuses`, `permFoodBonus`). Others are *written
once into state and never reconciled* (Wall Set DEF → `currentDef`; the food
delta on Auspice switch; the VP played-copy). Every "written-once" effect
breaks when the state underneath it changes (repair resets DEF, food hits the
clamp, uids diverge). Collapsing onto the recompute model everywhere would
likely fix the DEF-strip, the food exploit, and the VP double-count together.
A small headless test harness (extract the pure functions; `calcVP`,
`permFoodBonus`, `setAuspice` math, `monsterPickTarget`; from the DOM) would
let these be regression-tested in batch.

## Known Issues
_Open bugs, with repro steps, expected vs. actual, and severity._

> **Status (2026-07-19); now tracking V11.** The user regenerated the sim as
> `connivances_simulator_v11.html` by applying the V10 fix spec in their
> claude.ai Project. Verified: **all 6 original fixes carried into V11 and
> regression-pass**, plus the Project assistant added one correct new fix
> (Wall Siege: guard no longer double-counted as its own siege partner, and a
> freshly-unsealed monster stays in `field` instead of being retracted to
> `guarding`; verified live).
>
> **V11 pass found + fixed a 7th bug** (attachment DEF lost on repair/heal/
> dispel; see below), patched directly in `connivances_simulator_v11.html`
> and verified (`ALL_PASS: true`, all prior fixes still pass).
>
> The V10 artifacts remain: `connivances_simulator_v10_23_PATCHED.html` (6-fix
> reference) and [V10_LOCKDOWN_FIXES.md](V10_LOCKDOWN_FIXES.md) (paste-ready
> spec). Fix 7 is appended to that spec.

### Portcullis's "Immune to 🟡 Creature ATK" is never enforced
- **Where**: `simulator/connivances_simulator_v10_23.html`; card data line 938
  (`bg6` Portcullis), dead branches at lines 1509 & 1516 inside
  `checkWallSiege`, cosmetic-only badge at line 4127.
- **Repro**: Buy/play a Portcullis (no "Walls" taunt card in play), then let a
  creature-type monster (e.g. Nightmare, `isCreatureType:true`, ATK 7) attack
  with no taunt wall blocking. `monsterPickTarget()`'s `beatable` filter
  (line ~1297) compares raw `m.monsterAtk` against the target's DEF with no
  check of attack type at all; it has no concept of "this attack is
  creature-type" vs. siege/generic when picking or resolving a target.
- **Expected**: Portcullis should be un-targetable (or at least
  un-disable-able) by creature-type monster attacks, per its own printed
  text.
- **Actual**: Portcullis can be targeted and disabled by any monster whose
  `monsterAtk` meets its DEF, creature-type or not. The only code that ever
  special-cases `isPortcullis` (`checkWallSiege` lines 1509/1516) is
  unreachable, because that function only considers permanents with
  `isTaunt: true` (line 1482), and Portcullis has no `isTaunt` flag (only
  `bg3` "Walls" does); so `wall.isPortcullis` is always `false` at that
  point.
- **Severity**: Medium; doesn't crash anything, but silently breaks a
  printed card ability. A player who reads the card and plans around
  "immune to creature ATK" will find it does nothing.
- **Verdict**: ✅ **CONFIRMED live** (2026-07-19). Put a Portcullis (DEF 7,
  `isPortcullis:true`, not taunt) alone in the kingdom and called the real
  `monsterPickTarget` with Fiend (`isCreatureType:true`, non-flying, ATK 7).
  It returned the Portcullis; `portcullis_was_targeted: true`; so a
  creature-type attack can disable it despite the printed immunity.

### Mid-turn Auspice switch mis-calculates Farm food (two defects, one cause)
- **Where**: `simulator/connivances_simulator_v10_23.html`; `setAuspice`
  real-time food delta, lines 2502-2509, vs. the authoritative
  `permFoodBonus`, lines 1051-1068.
- **Root cause**: `startTurn` (line 2842) banks food as
  `3 + permFoodBonus()`, and `permFoodBonus` zeroes a Farm's *entire* output
  under Famine (`f=0`, line 1060) and adds `+1` under Harvest. But the
  mid-turn switch recomputes food as a *delta* using `oldBonus`/`newBonus`
  of `+1` for Harvest, `-1` for Famine, `0` otherwise (lines 2505-2506) -
  i.e. it models Famine as "−1 from neutral" instead of "zero the farm."
  The two models only agree for a Farm whose base food is exactly 1
  (e.g. Irrigated Field). They diverge for any base-2 Farm (Rice Field,
  Tiered Field).
- **Defect 1; phantom food on switch to Famine (base-2 Farms).** With a
  Rice Field (food 2) and food already banked, switching Harvest→Famine
  subtracts only 1 per farm, leaving 1 phantom food that Famine should have
  removed. Expected under Famine: farm contributes 0. Actual: farm still
  effectively contributes 1.
- **Defect 2; free food via the 0-clamp (any Farm).** Line 2509 clamps
  `S.food = Math.max(0, S.food + delta)`. Repro: get any Farm in play, gain
  Auspice changes (Channeler/Fallah/Witchdoctor/Ghoul trophy), spend food
  down to 0, then Harvest→Famine (negative delta is swallowed by the clamp,
  food stays 0) → Famine→Harvest (positive delta re-added) leaves
  `2 × (farm count)` food generated from nothing. Bounded per turn by
  available Auspice changes and does not compound across turns
  (`startTurn` recomputes from scratch), but within a turn it injects free
  food each toggle cycle if food is spent back to 0 between cycles.
- **Expected**: food after any Auspice switch should equal what a fresh
  `startTurn` under that Auspice would compute (minus already-spent food).
- **Actual**: it can be higher (both defects above).
- **Severity**: Medium. Correctness bug in the core resource economy; Defect
  2 is a genuine (if scarce-gated) exploit. Suggested fix: on switch,
  recompute the farm contribution from `permFoodBonus`-style logic and
  adjust by the true difference, rather than the ±1 neutral-relative delta -
  or track "food already spent this turn" and rebuild the pool.
- **Verdict**: ✅ **CONFIRMED live** (2026-07-19) for Defect 2 (the exploit).
  Injected one Rice Field (food 2), set Harvest, food = 0, gave 'any' Auspice
  uses, then ran the real `setAuspice` Harvest→Famine→Harvest: food went
  0 → 0 → **2**, i.e. 2 food generated from nothing (= 2 × 1 farm),
  consuming 2 Auspice uses. Defect 1 (phantom food magnitude) follows from
  the same code path; not separately reproduced.

### Repair/Heal strips the Wall Set +2 DEF bonus permanently
- **Where**: `simulator/connivances_simulator_v10_23.html`. Wall bond applies
  the bonus as a one-time direct mutation (`applyWallBond`, line 3710:
  `p.currentDef = (p.currentDef||p.def) + 2`), but Repair (`useRepair`, line
  2294: `p.currentDef = p.def`) and Heal (line 3692: `perm.currentDef =
  perm.def`) reset to *base* `def`.
- **Root cause**: the Wall Set DEF bonus is not a reapplied modifier. Unlike
  Library/Armory/Farm set pairs (which `applyRecurringSetBonuses` re-grants
  every `startTurn`, lines 2787-2804), Wall bonds are tracked separately
  (`bondedTo` + `wallSetsCompleted`) and their DEF is written once into
  `currentDef`. Nothing ever re-adds it.
- **Repro**: Bond two Walls (→ all your Creatures & Siege get +2 currentDef).
  Let a monster disable one of those buffed Siege/Creature permanents. Repair
  it (Builder) or heal it (Cleric/Exorcist/Enforcer). Its `currentDef` is
  restored to base `def`, **not** base +2.
- **Expected**: after repair/heal the permanent returns to full strength,
  including the still-active Wall Set bonus.
- **Actual**: it comes back 2 DEF short, and never regains the bonus (the
  bond is still "permanent" per its log message, but the DEF is gone). Makes
  a disabled+repaired unit permanently weaker than an untouched one under the
  same active bond.
- **Severity**: Medium; silent, permanent stat loss on a defensive line
  exactly when the player is trying to shore it up.
- **Related (lower confidence, not yet confirmed)**: the same one-time-mutation
  design means a Creature/Siege **played after** the Wall Set is bonded never
  receives the +2 `currentDef` (only permanents present at bond time are
  buffed, line 3709), yet `getCreatureBuffs` (lines 1117-1118) renders a
  Wall-Set +2 DEF chip for *all* creatures/siege. So the displayed DEF and
  the combat DEF (`currentDef`, read at line 1332) would disagree for
  post-bond units. Needs a display-path read to confirm the shown number.
- **Suggested fix**: compute Wall Set DEF the same way as other set bonuses -
  as a live modifier folded into `effectivePermDef` (which currently adds
  Golem/Gargantuan but not Wall Set, line 1159-1167); rather than a one-time
  write to `currentDef`. That fixes repair/heal, post-bond units, and the
  display mismatch together.
- **Verdict**: Repair/Heal reset is confirmed by code read, high confidence.
  Post-bond gap flagged as plausible pending a live/display check.

### Permanents are double-counted in VP the turn they're played (incl. final score)
- **Where**: `simulator/connivances_simulator_v10_23.html`; `calcVP` dedup,
  line 1042, vs. how a played permanent is stored (lines 1956 & 1974; also
  the Expediter path, line 2394).
- **Root cause**: `calcVP` builds `all = hand+deck+discard+permanents+legend`,
  then adds each `S.played` entry only `if(!all.find(x=>x.uid===p.uid))`; a
  dedup meant to stop a played permanent from also being counted via
  `S.played`. But a played permanent gets **two different uids**: the
  `S.permanents` copy uses one `genUid()` (line 1956), and the `S.played`
  copy uses a **separate** `genUid()` (line 1974). The uids never match, so
  the dedup fails and the permanent's `vp` is summed twice.
- **Why recruits are fine**: a non-permanent lives only in `S.played` during
  its turn (removed from hand at 1855, not pushed to discard until endTurn
  2669); so it's counted exactly once. The bug is specific to permanents,
  which exist in `S.permanents` **and** `S.played` simultaneously during the
  turn they enter.
- **Repro (display)**: Play any permanent (e.g. Rice Field from the starter
  deck, or a bought Irrigated Field once drawn). The ⭐ Projected VP tile
  (`res-vp`, line 2935 → `calcVP`) jumps by **2× the card's VP**. End the
  turn (line 2670 clears `S.played`) and it drops back to the correct value.
- **Repro (final score, worse)**: On the turn you defeat the Portal, any
  permanent you played that same turn is double-counted in the end-game total
  (`game-end-vp`, line 1036 → `calcVP`); and since permanents are 2-3 VP
  each, a typical winning turn that drops a building or two inflates the
  final score by 4-6+.
- **Expected**: each permanent contributes its VP once.
- **Actual**: counted twice during its entry turn, including in the final
  tally if the game ends that turn.
- **Severity**: High. VP is the win condition and the game's primary
  feedback; the number the player watches to judge whether they're winning is
  wrong on exactly the turns they make progress, and the final score can be
  wrong.
- **Suggested fix**: give the `S.played` permanent-copy the **same uid** as
  its `S.permanents` entry (so the dedup catches it), or have `calcVP` skip
  `isPermanent` entries in `S.played` entirely (permanents are already
  counted via `S.permanents`).
- **Verdict**: ✅ **CONFIRMED live** (2026-07-19). Drove the running engine
  directly: injected a 2-VP permanent the exact way `playCard` does
  (`S.permanents` + a `S.played` copy); `calcVP` went 0 → 4 (delta 4,
  expected 2), `doubleCounted: true`, the two uids differed (`u209` vs
  `u210`). Removing the copies restored VP to 0. This is the strongest of the
  findings and the pattern-defining one.

### 🔴 Portal effectively requires ~11 burst ATK. Ghoul-gate blocks exposure (found 2026-07-25)
- **Measured, clean tests (direct ATK injection, isolating win logic from bot skill):**
  - 7 ATK → kill Ghoul (HP 4) → portal exposes → 3 ATK left → **cannot kill Portal (7).**
  - 11 ATK → kill Ghoul (4) + Portal (7) same turn → **win.**
- **Root cause (emergent from the Ghoul-as-gate change):** Ghoul never razes, so with no
  permanent to attack it **retreats to `guarding`** every monster turn (verified
  `ghoul_field_no_target → guarding`). Portal exposure requires **zero** monsters
  guarding, so Ghoul permanently blocks the Portal unless killed; adding its 4 HP on top
  of the Portal's 7.
- **Passive-timeline evidence:** over 19 turns a passive player unsealed only **Fiend**
  (turn 8, which razed all 12 solo); Ghoul/Nightmare/Dragon stayed sealed+guarding the
  whole game → Portal never exposable. The player must actively unseal/kill guards AND
  herd them all out of `guarding` simultaneously.
- **Alternative (fragile) path:** keep every monster in `field` via decoy permanents
  Ghoul will attack (it prioritises Farms), then 7 ATK kills the Portal; but decoys get
  disabled and all other monsters must also be in field at once.
- **Impact:** an ~11 effective burst-ATK bar, against a board the monsters actively
  disable, on a ~16-19-turn doom clock, with a slow influence economy. Strongly explains
  the designer's report that the game is unwinnable. **This is a win-condition/pressure
  interaction, not (only) card power**; flag for pve-pressure-designer as well.
- **Bot caveat:** the automated player maxed at 2 ATK (too weak to conclude "no human
  can win"), but the 11-ATK bar is mechanical, independent of bot skill.
- **✅ RESOLVED (2026-07-25):** two pressure-layer fixes, designer-ruled + verified live:
  (1) **Ghoul no longer retreats to guarding**; once unsealed it `hold`s in the field, so
  it stops being the sticky last guard that welded its 4 HP onto the Portal. Killable
  mid-game as a trophy. (2) **The Fifth Protector**; the one-time reinforcement now
  arrives *awake and guarding* as a pure final gate (`isFinalGuard`, never acts) the first
  time all four originals leave portal defence, keeping "always one protector." Verified:
  clear the guards → Fifth Protector appears (once) → kill it (its HP) → Portal stays
  exposed → **7 ATK closes it the next turn** (two-turn split, no 11-burst). Bar restored
  to the intended 7 (W15).

### Trainer-buffed Farmers don't count toward Negotiator/Warlord (found by tcg-designer, 2026-07-22)
- **Where**: `playCard` Trainer branch (`if(card.id==='w3')`). The retroactive branch
  sets the warrior *gate* `S.warriorPlayedThisTurn=true` but **never increments the
  count** `S.warriorsPlayedThisTurn` for the Farmers it converts.
- **Effect**: Negotiator's (and Warlord's) "+1 Inf per other Warrior this turn" reads
  `warriorsPlayedThisTurn`, so retroactively-converted Farmers are invisible to it.
  Play Farmer, Farmer, Trainer, Negotiator → Negotiator awards **+1** instead of
  **+3**. Order-dependent (Trainer-first + forthcoming Farmers count correctly; the
  *retroactive* path undercounts), which is why my earlier pure-Warrior trace missed it.
- **⚠️ Correction to a prior QA claim**: I previously logged Negotiator as "traced
  correct across mixed sequences." That was overstated; my trace never included a
  Trainer-Farmer sequence. This is the real mixed case, and it's wrong.
- **Severity**: Medium now, higher if a **count-based Dojo** ships (the Warriors fix) -
  any per-Warrior payoff inherits this undercount. Fix before that lands.
- **Fix direction (not yet applied)**: the retroactive branch should increment
  `warriorsPlayedThisTurn` by `farmerCount` (and trigger Warlord, which it also omits),
  so converted Farmers count fully; the designer-ruled behaviour ("pitchfork Farmers
  count like any Warrior, no discount").
- **Verdict**: ✅ **REPRODUCED live + FIXED + VERIFIED** (2026-07-24). Repro: same three
  cards, two orders gave different counts. Farmer,Farmer,Trainer → 1 warrior vs.
  Trainer,Farmer,Farmer → 3. Fix: the retroactive branch now `warriorsPlayedThisTurn +=
  farmerCount`, and also fires the Negotiator bonus ×Negotiator-count (was flat) and the
  Warlord bonus (was omitted). Post-fix: both orders award Negotiator +5 (2 base + 3),
  counts equal at 4; pure-Warrior control unchanged (+4); no double-count in the
  forthcoming path. This is the count-integrity prerequisite for a count-based Dojo (Option A).

### Three passive DEF abilities are ignored by monster combat (found during V11 measurement)
- **Where**: `effectivePermDef` (which adds Golem Defender +2 and Gargantuan +2 for
  creatures) is called in **exactly one place**; a render/display path. Monster
  targeting (`monsterPickTarget`, `atk >= (p.currentDef||p.def)`) and resolution
  (`monsterAttackPermanent`, `def = perm.currentDef ?? perm.def`) both read **raw
  `currentDef`**, so those bonuses never apply in combat.
- **Fortress (bg7) is worse**: its printed *"Passive: Creatures & Siege always +2 DEF
  while Active"* is not in `effectivePermDef` at all; it exists only in
  `getCreatureBuffs`, which is explicitly display-only (*"reports only; it never
  modifies state"*, §13A). So Fortress's DEF passive is applied **nowhere**.
- **Effect**: the player reads their board as DEF 6; the monster attacks it as DEF 2.
  Three printed abilities are cosmetic:
  - Golem Defender; "All your creatures: +2 DEF while Active"
  - Gargantuan (trophy); "all your creatures +2 DEF while Active"
  - Fortress; "Creatures & Siege always +2 DEF while Active"
- **Measured**: a Brood with an active Golem Defender + Gargantuan showed
  `currentDef: 2` vs `effectivePermDef: 6`; a **4-point gap**, all of it ignored by
  combat. Removing Fortress from play changed `effectivePermDef` by 0, confirming it
  is not in the calculation.
- **Severity**: High for V11; the whole Creeping Doom targeting model keys on
  "can this monster beat this permanent's DEF," so a systematically understated DEF
  makes permanents far easier to disable than they read, and directly distorts the
  DEF-threshold rules just ruled on (Point 4/4a).
- **Fix direction (not yet applied)**: make monster targeting and resolution read one
  canonical effective-DEF helper that includes the live passives (Golem, Gargantuan,
  Fortress), rather than raw `currentDef`. Keep it distinct from `recomputeStoredDef`,
  which is the *stored* value (base + attachments + Wall Set).
- **Verdict**: ✅ **CONFIRMED live** (2026-07-20). Not yet fixed; held pending the
  V11 monster-turn implementation so both land together.

### Swordsman top-deck used a blocked `confirm()`; effect silently dead (found in rulebook pass)
- **Rule violated**: §13B "No browser dialogs anywhere" (LOCKED must-not-regress):
  *no `prompt()`/`confirm()`/`alert()` anywhere; browser dialogs are silently
  blocked in the iframe.*
- **Where**: `buyCard`; the Swordsman top-deck choice was `const topDeck=confirm(...)`.
- **Impact**: in the real (iframe) build the dialog never appears and `confirm`
  resolves falsey, so the card always stayed in discard. **Swordsman's entire
  effect2 ("Warriors bought this turn may go to top of deck") was dead.** It
  didn't surface in my earlier testing because a plain browser tab *allows*
  `confirm()`; only the iframe blocks it.
- **Severity**: High; a card's printed ability does nothing in the shipped context.
- **Fix applied**: routed through the standard `showListPicker` overlay (two
  explicit options, mandatory choice). Because the picker is async (the old
  `confirm` was synchronous), the purchased card is now located **by uid** at
  selection time rather than assuming it's still the last element of `S.discard`.
- **Verdict**: ✅ **CONFIRMED + FIX VERIFIED** live; picker renders both options;
  choosing top-deck puts Pikeman on top of the deck and grows the deck by 1.

### ~~Opening hand randomized instead of fixed~~; ❌ RETRACTED (not a bug; my error)
- **What I claimed**: that `resetGame` shuffling the whole 10-card starter pool
  violated §12A.1's fixed opening hand (KN×2, DA×1, FH×1, AI×1), and I "fixed" it
  to deal that fixed hand.
- **Why it was wrong**: **§12A.1's fixed hand is legacy test scaffolding.** Per the
  designer (2026-07-20), that templated hand existed only to verify Legend and Farm
  behaviour during development. The intended game is a **pure random 5-card draw
  from the 10 starter cards**; no forced hand, any card (including Rice Field) may
  open. The MD is stale here, not the code.
- **Lesson**: the MD contains historical scaffolding as well as live rules. A
  code/doc mismatch is not automatically a code bug; confirm intent before
  "fixing" toward the doc. (Same class of error as my first pass at Fix 7.)
- **Action taken**: reverted to the pure random draw and **removed all
  templated-hand support**, including the misleading startup log that asserted
  "Rice Field starts in deck" (it now states the hand is a random 5 of 10).
- **Verdict**: ✅ Revert verified live over 200 games; 23 distinct opening
  compositions; every card appears at its expected ~50% rate (DA 499/500,
  KN 203/200, FH 101/100, RF 102/100, AI 95/100); pool always the correct 10
  cards; hand 5 / deck 5. §12A.1 must be rewritten; see MD_UPDATE_QUEUE_v2_3.md.

### Disabled permanents don't detach their attached recruit to discard (found in V11 pass)
- **Game rule (from the designer):** when a permanent is disabled, any attached
  *player recruit* is "dead"; it detaches and goes to the discard pile (can be
  redrawn and re-attached later). Consequently a repaired permanent must **not**
  carry that attachment's bonus.
- **Bug:** `monsterAttackPermanent` (and the Wall Siege `wall.disabled`) only set
  `disabled=true`; they never removed the attachment. So the recruit wrongly
  stayed attached to a disabled host, and its DEF bonus lingered.
  > **Note / course-correction:** my first V11 pass misread the intent and
  > "fixed" this the wrong way. I wired `defBonus` so repair would *restore*
  > the attachment's +2 (repair → DEF 7). That's backwards. Per the rule the
  > recruit is gone, so repair → base DEF (5). Corrected below.
- **Fix applied (in `connivances_simulator_v11.html`):** added
  `detachRecruitsOnDisable(perm)`; on disable, each attached player recruit is
  pushed to `S.discard` (with `_attached:false`) and removed from
  `attachedCards`; **Possessions (enemy attachments) are kept**. Called from
  `monsterAttackPermanent` and `executeWallSiege`. With the recruit gone,
  `recomputeStoredDef` on repair naturally yields base DEF + Wall Set only.
  The `defBonus` wiring on `confirmAttach`/Expediter and the `detachCard`
  rebuild are retained; they're still needed for **voluntary** detach and
  live DEF with stacked attachments (verified).
- **Severity**: Medium; an attacked, buffed permanent should shed its recruit
  (and the player should get it back in discard); previously the recruit was
  stranded on a disabled host.
- **Verdict**: ✅ **CONFIRMED live + FIX VERIFIED** (2026-07-19). Via the real
  disable path: Fortifier on an Armory (DEF 7) → monster disables → Fortifier
  lands in discard, `attachedCards` empties → repair returns DEF **5**. A
  Possession stays attached on disable. Voluntary detach still returns base DEF;
  all six prior fixes still regression-pass (`ALL_PASS: true`).

### Silent Stalker is described as Flying but doesn't fly
- **Where**: `simulator/connivances_simulator_v10_23.html`; data at line 982
  (`mn_stalker`, `fly:false`) contradicts the priority tooltip at line 1646
  and the code comment at line 1274 (`// Flying monsters (Nightmare, Silent
  Stalker) bypass Walls entirely`).
- **Repro / behavior**: `getMonsterPriority(mn_stalker)` returns "Flying -
  bypasses Walls…", but `monsterPickTarget` reads `!!m.fly` (line 1275), and
  with `fly:false` a taunt Wall blocks it like any grounded monster.
- **Expected**: match the description. Silent Stalker (a stealth unit,
  called "Flying" in two places, grouped with Nightmare) should bypass the
  Wall Row. The likely-correct fix is data: set `fly:true` on `mn_stalker`.
  (Alternatively, if it is intended to be grounded, fix the tooltip and
  comment instead.)
- **Actual**: it is grounded; a taunt Wall stops it, so the player who reads
  "bypasses Walls" and does NOT wall up against it is misled.
- **Severity**: Medium; wrong information drives wrong defensive decisions,
  and it only bites when a Stalker is in the queue (it's one of the random
  3-of-8 guards, so ~intermittent).
- **Verdict**: ✅ **CONFIRMED live** (2026-07-19). `data_fly:false`,
  `tooltip_says_flying:true`, and with a taunt Wall (DEF 6) up vs. Stalker
  ATK 5, `monsterPickTarget` returned `null` (blocked); `contradiction:
  true`.

### Caravan "persistent damage" is flavor-only; end-of-turn destruction check is dead code (Low)
- **Where**: `monsterAttackPermanent` only sets `disabled=true` (never reduces
  `currentDef`), so the end-of-turn destruction filter
  `S.permanents.filter(p=>p.isCaravan&&p.currentDef<=0)` never matches.
- **Effect**: not a functional break; an overrun (disabled) Caravan is still
  destroyed, but via the `if(perm.disabled)` branch in `startTurn`'s caravan
  resolution, not the `currentDef<=0` path. The bg15/bg16 card text "takes
  persistent damage" implies chip damage that isn't implemented (it's binary
  disable, same as every permanent).
- **Severity**: Low. Recommend either implementing real persistent damage for
  Caravans (reduce `currentDef` on attack) or removing the dead check and
  softening the card text. Not urgent for lockdown. Flagged for tcg-designer.

## v11.6. Modes (Long Winter + Augury Tutorial) QA; 2026-09-06
_Code-read QA of `simulator/connivances_simulator_v11_6_4.html` + `cards.json`.
No browser available to me; live-verification items are flagged for the parent.
Scope: card-data externalization, mode framework, The Long Winter, Augury
Tutorial. Iron rule (no shared card is re-statted per mode) reviewed and holds -
mode branches only touch setup / antagonist / pool filter / win-loss._

### Confirmed
- **cards.json is valid** and content-identical to `cards.js` in this build
  (byte-for-byte after removing the `window.CARDS_DATA=…;` wrapper). Data in
  sync now.
- **Load order is safe.** `AUSPICES/STARTER/…/HORSEMEN` are `let`-declared
  (line 1042), populated by `loadCardData()` (5262), and `computeSetEligible()`
  is deferred to after load (5265). `resetGame()` is only called from
  `loadCardData().then(...)` (5267) or `setMode()`. No top-level code reads the
  arrays before load.
- **Iron rule holds.** `permFoodBonus`/`permAtkBonus` read card fields directly
  with no mode branch; `modeRecruits/Buildings/Conjurations` only *filter* which
  cards appear, they don't re-stat. `computeSetEligible` uses the full
  (unfiltered) arrays. No shared card is mutated by mode.
- **Empty `monsterQueue` is safe in modes.** Setups clear the Creeping-Doom
  apparatus (2088 / 2203). All always-run per-turn code that touches
  `S.monsterQueue` uses `.forEach/.filter/.find/.some` (safe on `[]`); the
  render field-zone block (3876) yields empty and is skipped; `attack()` (3071,
  which would throw on a missing Portal) is only wired from the Creeping-Doom
  monster-zone render, not rendered in modes. `refill` (1056) and Death's reap
  (2101) both guard empty decks. No throw path found.
- **Reset hygiene is clean.** `setMode` → `resetGame` builds a fresh `S`; `S.lw`
  / `S.tut` do not exist in the Creeping-Doom `S` literal and every consumer
  guards with `if(!lw)`/`if(!t)`. Mode → mode and mode → Creeping switches leave
  no residue.
- **AUSPICES index stability.** Winter is appended at index 4; defaults
  (`S.auspice:2`=Harvest) and the hardcoded food indices (Harvest `===2`, Famine
  `===3` in `permFoodBonus`) are unaffected. Winter's `modes:['long_winter']`
  filter (render 3721) correctly hides it in other modes.
- **Tutorial is not soft-lockable / is winnable.** Pool includes the ATK paths
  the hint promises: Necromancer, Soothsayer, Channeler, Witchdoctor, Herbalist
  are all `guild:'Augury Mage'`; Poison Room is `subtype:'Library'` so it passes
  the `{Farm,Library,Armory,Granary}` building filter. Base Food is `3 + farms`
  each turn regardless of Famine lock, so the player can always play cards →
  generate auspice-change ATK (Necromancer) or buy conjurations (Soothsayer).
  `auguryTutorialTurn` has no loss state.

### BUG. Winter auspice status line renders literal "undefined" (Medium)
- **Where**: `render()`, line 3764; `auspiceStatus.textContent =
  statusMap[S.auspice];`. `statusMap` (3756) only has keys 0–3. In The Long
  Winter `setupLongWinter` sets `S.auspice` to Winter (index 4), so
  `statusMap[4]` is `undefined` and the status bar shows the string
  "undefined". Recurs every time the player switches back to Winter.
- **Repro**: select "The Long Winter" → New game. The auspice status bar under
  the tiles reads "undefined". Also the bg/color ternary (3762-3763) has no
  case for 4, so Winter is painted with Famine-red styling.
- **Expected**: a Winter description (e.g. "❄️ Winter active; the season
  deepens; farms yield base Food.") and Winter-appropriate tint.
- **Actual**: literal "undefined" text, Famine-red styling.
- **Severity**: Medium. Not a crash or progression block, but it is the first
  thing a Long Winter tester sees and reads as broken. Cosmetic-only.

### BUG; win/loss overlay text is hardcoded to the Portal in all modes (Medium)
- **Where**: `showGameEndOverlay(won)` (1078). Win sub = "The Seeping Portal
  has been sealed."; loss sub = "The darkness has consumed the Kingdom." Both
  new modes call this (2109/2132/2221).
- **Repro**: win The Long Winter (kill Death) → overlay says the *Portal* was
  sealed. Win the Augury Tutorial → same. Long Night loss → generic darkness
  text (acceptable) but titled the same as Portal defeat.
- **Expected**: mode-appropriate flavor ("The Long Winter is broken", "Tutorial
  complete", etc.).
- **Actual**: Portal flavor in every mode.
- **Severity**: Medium (immersion/copy). Also note `calcVP()` is shown on the
  tutorial end card, where VP is meaningless; harmless but odd.

### DESIGN FLAG. Death's `fly:true` is not enforced in Long Winter (needs design)
- **Where**: `attackHorseman` (2116) uses `lwPool('creature') = S.atk_creature`
  (all creature ATK). Death's card text ("Flying; wounded only by 🟡 Creature
  ATK") and `fly:true` imply the Creeping-Doom rule that flying monsters take
  damage only from *flying* creatures. Long Winter ignores fly entirely, so any
  creature ATK wounds Death; easier than the fiction states.
- **Not deciding intent**; flagging to design: is Long Winter meant to enforce
  flying-only against Death, or is "creature ATK" sufficient? Currently the
  `fly` flag is cosmetic here.

### DESIGN/CONTENT. Winter auspice food-tax is stubbed (Low, known)
- `permFoodBonus` has no branch for auspice index 4, so under Winter, Farms
  produce *base* Food (no penalty, no bonus). The Winter card text promises
  "less Food, slower tempo." This is missing content, not a correctness break.
  Flag to design if Winter is meant to tax food.

### RISK. Long Winter requires specific ATK types; wrong build → unrecoverable via Long Night (Low, telegraphed)
> **⚠️ SUPERSEDED / UPGRADED 2026-09-07**; see "Long Winter; winnability
> playtest" below. This entry called the mode "winnable" on the basis that all
> ATK types are *reachable* in the market. A playtest shows the binding
> constraint is not reachability but **tempo**: the first rider's required type
> (🔴 Siege) cannot be brought online before the hard-loss turn. Treat the
> issue below as the live finding; this entry is kept for history.

- Riders are sequential and type-gated: Conquest=🔴 siege, War=⚪ generic,
  Famine=any, Death=🟡 creature. All types are reachable (Long Winter uses the
  *full* market pool; `modeRecruits/Buildings/Conjurations` only filter for the
  tutorial), so the mode is winnable. But a player who over-invests in one ATK
  type cannot skip a rider and may hit the Long Night (stage 4) before pivoting.
  Each rider frame shows its glyph and `counter` text, so it is telegraphed.
  Balance/tempo concern for the pve-pressure-designer, not a code bug.

### Minor / informational
- **Mode persistence surprises testers**: `GAME_MODE` is read from
  `localStorage` at load (2059); a tester who last played a mode reboots into
  it, not Creeping Doom. Intended; telegraphed by the header dropdown.
- **`GAME_MODE` vs `S.mode`**: pool filters read the global `GAME_MODE` while
  turn/render read `S.mode`. Always equal within a game (setMode always resets),
  but the split is a latent trap if a future call sets one without the other.
- **`cards.js` / `cards.json` can drift**: two files, identical today. If an
  editor updates only `cards.json`, the file:// / embedded fallback silently
  serves stale data. Recommend a build step or a checked hash. Not a live bug
  now.

## Long Winter; winnability playtest (build `connivances_simulator_v11_6_4.html`, 2026-09-07)

### FINDING. The Long Winter is effectively unwinnable as tuned (Severity: HIGH; mode is a hard progression blocker)
The mode's first rider requires the slowest ATK type to bring online, and the
Winter hard-loss fires on the same turn that type can first produce meaningful
damage. There is no tempo margin. This is a **mode-level progression blocker**,
not a polish issue; the intended experience (kill 4 riders) is unreachable.
Corroborates a prior tcg-designer flag (typed immunity + fixed order + siege-first).

**Mechanics (re-verified in source, this build):**
- `setupLongWinter` (~L2084), `longWinterTurn` (~L2102), `attackHorseman` (~L2121);
  rider data `cards.json → horsemen` (L2756).
- Riders ride one at a time, fixed order Conquest→War→Famine→Death; only the
  active rider is attackable. `woundedBy`: Conquest=🔴 Siege (HP **8**),
  War=⚪ Generic (HP 10, +2 HP any turn unwounded), Famine=any (HP 9, locks
  auspice→Famine), Death=🟡 Creature + `fly` (HP 12).
- Winter clock is a pure turn counter: `turnsThisStage++` each end-of-turn; at
  `>=3` the stage deepens (1 First Frost → 2 Hard Frost → 3 Deep Winter →
  **4 THE LONG NIGHT**). At stage 4 with any rider alive → `S.gameOver` (L2114).
  Traced arithmetic: stage 4 is reached at **end of turn 9**. Killing a rider
  thaws one stage (`stage--`, `turnsThisStage=0`) but only `if(stage>1)` (L2132).
- Siege ATK sources: Siege buildings (Catapult `cost_inf 6/cost_food 1`,
  `atk_siege 2` recurring, L1748; Trebuchet cost 8) or Siegeman. Siege market is
  gated: a building with `requiresBuilder` opens for Siege only if a **Warrior or
  Siegeman was played that turn** (Option C, `siegeOk`, L3105). Mode starts on the
  **Winter** auspice (Dormancy) with no farm-food bonus (`permFoodBonus` has no
  Winter branch; already logged above), so early Food is 1–3 plays/turn.

**Methodology (QA-run, live engine; audited):**
- No headless JS runtime is available here; the engine is DOM-coupled, so the
  test drove the **live in-browser engine** with an automated auto-player,
  **15 matches per config**. Pickers stubbed to auto-resolve option 0 to prevent
  UI blocking. Bot policy each turn: play permanents/Warriors first (Food-capped
  at 1 Food/play) → strike active rider if matching typed pool > 0 → greedily buy
  the highest ATK/unlock-value affordable card across all three markets → end turn.
- Two bot versions: **v1** had a buy bug (stopped buying for the turn when its
  top pick was gate-locked); **v2** fixed it (skip gated picks, keep spending) and
  played permanents/Warriors first.
- **Caveat (QA audit):** this is a *greedy baseline bot, not an optimal human*.
  It does no auspice management and no long-horizon sequencing (e.g., banking
  Influence to buy Catapult the same turn a Warrior lands). The **win rate is a
  floor, not a measurement of the skill ceiling.** The load-bearing evidence is
  not the 0% itself but the **siege trajectory** (below): it shows the ceiling is
  also bounded, because the constraint is tempo, not decision quality.

**Results (real engine output):**
| Config | Matches | Wins | Avg turns | Riders killed | Stalled on |
|---|---|---|---|---|---|
| Bot v1 (greedy, buy-bug) | 15 | **0** | 9.3 | 0.07 avg (14×0, 1×1) | Conquest/siege ×14, War/generic ×1 |
| Bot v2 (buy-bug fixed, permanents-first) | 15 | **0** | 9.0 | **0 in all 15** | **Conquest/siege ×15** |
- All losses are **clock-driven** (Long Night ~turn 9), not the 45-turn safety cap.
- **Instrumented single run (v2), siege vs Conquest (HP 8):** first Warrior played
  turn 6 (earliest siege-market unlock) → Catapult bought turn 7 → Siege building
  actually **in play producing output only at turn 9** (siege ATK 3 → Conquest
  8→5); but turn 9 IS the Long Night, so the game ends with Conquest alive.

**Root cause (why even optimal play can't close the gap):**
The first rider gates on the longest build chain in the game:
draw+play a Warrior (opens Siege market) → hold 6+ Influence the *same* turn →
buy Catapult → draw it → play it (needs a Builder/Warrior that turn too) → wait
one turn for its first `atk_siege` tick → accumulate ≥8. Best realistic case puts
a Catapult *producing* around turn 7–8. Catapult is only **+2 🔴/turn**; Conquest
(8 HP) does not self-heal, so chip damage persists, but total siege output
deliverable by the turn-9 deadline is ~4–6 (one Catapult from turn 7 = turns 7,8,9
= 6). A second siege source is even harder to land in time. **Conclusion: the
turn-9 hard-loss precedes the turn at which 8 🔴 can be delivered, for any player.**
Winter-start food starvation widens the gap; it is not the sole cause. The QA
verdict: **the greedy 0/15 is a fair basis for a HIGH winnability finding**, and a
stronger player does not plausibly close a structural ~1–3-turn siege deficit.

**Ranked tuning recommendations** (owner tagged; pick 1–2, then re-test):
1. **Reorder the riders so 🔴 Siege is not first**; put a fast-online type
   (⚪ Generic / War, or any / Famine) at `order 1` and Siege later. Single
   highest-leverage change; directly removes the "slowest engine gates the
   earliest deadline" trap. **[pve-pressure-designer + tcg-designer]**
2. **Push the Long Night later / slow the first deepen**; deepen every **4**
   rider-phases instead of 3 (Long Night → ~turn 13), or make stage 1→2 take
   longer than later stages. Buys the siege engine time without touching cards.
   **[pve-pressure-designer]**
3. **Lower Conquest HP** to ~4–5, or let Conquest also take ⚪ Generic in the
   early stages, so the first kill is reachable off one Catapult tick or a Warrior.
   **[tcg-designer for HP; joint for the extra type]**
4. **Give the mode an early siege source or fix Winter food**; e.g. start with a
   Catapult / a free Siegeman in the opening, and/or add the missing Winter-auspice
   food branch so farms aren't dead on turn 1. Addresses the starvation half of the
   problem. **[tcg-designer for the card grant; design for the auspice branch]**
5. **Un-gate the Siege market in this mode** (skip Option C's Warrior requirement)
   so Catapult can be bought a turn or two earlier. Smallest lever; likely
   insufficient alone. **[tcg-designer]**

**Suggested re-test bar:** with the greedy baseline bot unchanged, a *balanced*
Long Winter should show roughly **20–40% wins** for the greedy bot (it is
deliberately suboptimal, so it should still lose often), which maps to a
**~60–75% win rate for a reasonable, non-expert human** who manages auspice and
sequencing. A greedy-bot win rate near 0% = still unwinnable; near/over 60% =
likely too easy for a "deepening doom" fantasy. Re-run 15 matches/config after
each tuning change; also report **avg riders killed** and **which rider stalls**,
since "0 riders killed" is the real regression signal, not turn count alone.

**Additional bot/config runs I can execute on request** (specify which; I'll run
15 matches each and report win rate, avg turns, avg riders killed, stall rider):
- (a) Riders reordered War→…→Conquest (Generic-first); same bot, no other change.
- (b) Clock deepens every **4** phases (Long Night ≈ turn 13).
- (c) Conquest HP lowered to 5, then to 4.
- (d) Mode grants a turn-1 Catapult (or free Siegeman) in the opening.
- (e) Winter-auspice food branch enabled (farms produce base+bonus).
- (f) A smarter bot: banks Influence to buy Catapult the same turn a Warrior
  lands, and manages auspice for food; to probe the *skill ceiling* directly
  rather than the floor. (Larger effort; worth it to settle "can any human win.")

## Out of Scope
_Things intentionally not being tested right now, and why._
