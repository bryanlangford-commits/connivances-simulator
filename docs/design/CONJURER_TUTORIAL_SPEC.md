# Conjurer Tutorial; "The Summoner's Plight" (Design Spec)

> **AS-BUILT NOTE (2026-09-19):** The redesign below was refined during the build. Two things
> changed from what this doc and its sibling docs (`cards/CONJURER_POSSESSION_MARKET_MECHANICS.md`,
> `CONJURER_TUTORIAL_PRESSURE.md`, `CONJURER_TREANT_AND_POSSESSION_PRESSURE.md`) describe:
> (1) the backlash triggers on **ACQUIRING** a conjuration (buying from the market refills a slot
> that can surface a possession), not on summoning; and (2) the win is **kill the treant**, the old
> seal-the-veil meter is retired. The shipped mechanic lives in the code (`setupHouse`, `houseTurn`,
> `attackTreant`, `seedConjurerPossessions`, `resolveDabblingCascade`, `banishPossession`,
> `dispelMarketPossession`, `renderManorZone`) and is summarized in the `conjurer-rework-state` memory.
> Treat the CODE as the source of truth; these docs are the design rationale that led to it.

**Status:** BUILT (2026-09-19), first-pass numbers pending playtest. Supersedes the "Clear the Haunted
House" build (mode `conjurer_house` in `simulator/connivances_simulator_v11_6_4.html`).

**What changed from the built version, and why:**
- The **treant is now a real, persistent boss**, not intro flavor. It has HP and an
  advance-on-town clock and is present the whole tutorial. Reason: the old build asked
  the player to summon into a vacuum (nothing to fight), so "summon" and "fight" were
  never connected until the back half. A visible enemy from turn 1 gives the summon
  verb an obvious purpose and a clean teach.
- **Possessions now consume the conjuration market**, not an abstract 3x3 manor grid.
  Reason: this is what the live game actually does (`attackPossession`,
  `dispelPossessionFromMarket`, `allMarketsUnavailable`, slots that block summons). The
  old `S.manor.rooms` grid and the "Veil Seal to 6" bar were bespoke scaffolding that
  taught a set-piece instead of the real system. This redesign deletes both.
- **Win is now "slay the treant / save the town,"** not "seal the veil at 6 banishes."
  Possessions are the cost of your own magic, not the objective.
- Net feasibility: this redesign reuses MORE live engine than the current build (boss
  pattern from Long Winter + live possession-in-market machinery). It is a rebuild of
  the mode's back half, not a tweak. See s7 and s8.

**Scope of THIS doc:** mode structure, phase/loop, win/loss framing, lore beats,
onboarding, tone. **Deferred:**
- Card-layer specifics (which Conjurers/possessions, stat blocks, possession DEF, the
  summon-to-possession spawn rule, reward hooks, the ATK economy that must out-race the
  treant) -> **tcg-designer**.
- Clock/curve numbers (treant HP, treant advance cadence, possession spawn rate per
  summon, market-clog pacing, soft-retry mercy ramp) -> **pve-pressure-designer**.
This doc gives those two the slots to fill and the shape the numbers must hit.

---

## 1. Concept and the one-line lesson

A feral treant is marching on your town. You are a Conjurer. You have no army; you have
the veil. So you **summon** creatures to fight it, and it works; each summon puts power
on the board and you drive the monster back. Then the veil doesn't close behind you.
The same reaching that summons your defenders is dragging **possessions** through, and
they lodge in your **conjuration market**, jamming the very slots you summon from. The
more you summon to kill the treant, the more you clog your own hand. You must slay the
treant before it reaches the town, while your own wild magic tries to disarm you.

**The lesson, one line:** *"Every summon is a gamble with the veil; the power that saves
the town is the same power that turns on you, and you have to spend it anyway."*

The Conjurer fantasy per `FACTION_IDENTITIES.md`: summoners playing with wild magics,
"curses and possessions hidden throughout the deck representing the untamed magics."
Possessions are the faction's built-in risk, not an external attack. This tutorial is
that identity, dramatized: summoning is not free, and the price is a second enemy you
made yourself.

---

## 2. Fit with the tutorial family

| Mode | Core verb taught | Antagonist | Structure |
|---|---|---|---|
| Giving Tree (Augury) | read/shift auspice | The Blight | 6 nurture stages -> scripted betrayal |
| Sundering Stone (Warrior) | mass ATK / race | Minotaur | parallel race clock |
| Storming the Castle (Builder) | permanents + set bonuses | enemy Keep | layered siege |
| Long Winter (finale) | typed ATK vs. a boss | Four Horsemen | boss HP + doom clock |
| **Conjurer (this)** | **summon -> fight, then throttle** | **The Treant (+ your own possessions)** | **live boss clock + self-inflicted second front** |

This mode is the only tutorial where the **second enemy is created by the player's own
correct play**. It borrows the boss-clock shape from Long Winter (a monster with HP and
an advancing loss timer) and the lull-then-betray reveal from Giving Tree, and it doubles
as first contact with the live possession-in-market system the campaign runs on.

---

## 3. Structure; two fronts, one continuous fight

**Recommendation: the treant fight is continuous from turn 1; the possession front opens
on a short scripted delay (a brief safe lull of the first 1-2 summons), then runs
continuously to the end.** This satisfies Bryan's "the treant never goes away; possessions
accumulate as you summon" while preserving a clean teach.

Why a brief lull for the possession front, when the treant is live immediately:

- You cannot teach "summoning betrays you" until the player knows what summoning IS. If
  possession #1 spawns on summon #1, the betrayal and the base mechanic arrive at the
  same instant and the player concludes "summoning just makes monsters; that's the rule,"
  rather than "the thing that was helping me just turned." The betrayal only reads as a
  betrayal if a baseline expectation ("summoning helps") is established first.
- So: 1-2 clean summons that only help (front #1 only), then the scripted tear. This is
  the proven Giving Tree / current-build recipe, just with the treant fight already live
  underneath it instead of a flavor placeholder.

The difference from the old build: in the old build the lull had **no real front at all**
(the treant was text). Here the lull already has the treant advancing and taking damage;
only the **possession** front is gated. Front #1 is real from turn 1; front #2 arrives on
the reveal and never leaves.

### Phase A; "Answer the Call" (scripted lull, ~1-2 summons)
- Mentor hands the player a crisis and a verb: the treant is at the gates, summon a
  defense NOW. Goal banner: **treant HP bar + advance clock, visible from turn 1.**
- The player plays a Conjuration -> it adds ATK -> **Strike the Treant.** Treant HP drops;
  treant advances one step on its clock. The summon->fight loop is learned against a
  single, obvious target. Every summon here lands clean and helps. This is the dopamine.
- One telegraph, easy to miss on first play (keep the current build's line; it is good):
  after the 2nd summon, a single cosmetic omen in a market slot plus a mentor aside
  ("the candle-flames are leaning the wrong way"). No mechanical effect yet. Makes the
  reveal feel foreshadowed on replay, not cheap.

### Phase B; "OH NO" (the reveal, hard-scripted, fires on a summon)
- Trigger: the next summon after the lull (deterministic; the player earns the reveal by
  doing the verb, exactly like the tree blossoms on a completed stage, not on a clock).
- The summon resolves; the player expects the usual ATK. Instead the veil tears and the
  thing that answers is **not theirs.** A **possession lodges in a conjuration market
  slot**, visibly corrupting it and blocking summons from that slot. See s5 for the beat.
- The Banish/Dispel verb, and an Exorcist gift, appear here (not before; a cleanup tool
  with nothing to clean is just clutter on the Phase-A screen). Guided first banish.

### Phase C; "Two Fronts" (continuous to the end)
- The treant keeps advancing and must keep taking damage; so you must keep summoning.
- Every summon now feeds the possession front (spawn rule owned by tcg-designer; see s8).
  Over-summon and the market clogs; under-summon and the treant reaches the town.
- The player wins by **slaying the treant** (s5) before either clock expires, while
  clearing or throttling possessions enough to keep summoning.

**Why this order works:** the player learns the summon verb's purpose against a clear
enemy (A), pays for it once in a way they caused (B), then discovers the payment is a
standing tax they must manage with the tools they already have (C). The risk/reward
lesson is lived, not lectured.

---

## 4. The mechanical coupling; why the two fronts are one lesson

The elegance to protect in build: **possessions occupy the market you summon from.** So
the two loss conditions are mechanically linked, not two unrelated timers:

- The treant clock forces you to deal damage, which forces you to summon.
- Summoning feeds possessions into the conjuration market.
- As the market clogs, your **summon throughput drops**, so your **treant damage drops**,
  so the **treant clock wins.**

That means neglecting the possession front literally causes the treant front to fail. The
"self-inflicted second front" is not a metaphor; it is the same resource (your summons)
strangling itself. Keep this coupling front-and-center; it is the whole design.

**Open lever for tcg-designer:** the treant and possessions currently both drain the same
ATK pool (`attackHorseman`-style spend vs. `attackPossession` spend both pull
`atk_creature/siege/generic`). Two options:
1. **Shared pool (max tension):** every banish is ATK you didn't spend on the treant.
   Cleanest thematic "one power, two mouths," but raises the death-spiral risk; flag for
   pacing.
2. **Split tools (softer):** raw ATK pool goes at the treant; possessions are cleared
   mainly by the **Exorcist free Dispel** and the **Cleric +2 vs-possession bonus** (both
   already live). Banishing then costs tempo/cards, not treant damage, which reduces the
   "cleaning up steals my progress" feel-bad while keeping the throttle lesson.
Recommend starting from option 2 for a tutorial (gentler), and letting tcg-designer decide
the mix. Either way the throttle lesson must survive.

---

## 5. Win / loss framing

**Position: the tutorial is UNFAILABLE (soft-retry), but both loss states must be real,
visible, reachable near-misses. The win is singular and framed: slay the treant, save the
town.**

**Player win condition (one, clear):** **treant HP reaches 0.** Town saved. The mode ends
in victory regardless of how many possessions remain. Possessions are the cost, not the
objective; forcing a full market clean-up after the treant dies would be an anticlimactic
grind. Optional wry epilogue: "The town stands. The manor, however, has guests." Model the
success close on `attackCastle`/`attackHorseman` landing the final blow.
- *Alternative to confirm with Bryan:* require the market cleared as a coda before the win
  screen. Recommend against; it dilutes the single objective. Flagged as an open question.

**Loss conditions (two, both soft-retry, never terminal):**
1. **Treant reaches the town** (advance clock expires). The framed, visible threat; the
   HP bar and the clock are the thing the player watches. This is the primary loss.
2. **Possessions fully consume the conjuration market** (`allMarketsUnavailable()`; in
   this mode possessions haunt but do not raze, so it reduces to "every conjuration slot
   haunted"). You can no longer summon, so you can no longer build ATK, so front #1 will
   fail. The self-inflicted, secondary loss; the punishment for over-summoning.

**How they resolve against each other:** the treant clock is the hard deadline you can see;
the market-clog is the soft deadline you cause. The stable winning line (which MUST exist;
see s6) is a summon cadence where treant-damage-per-turn stays ahead of the treant clock
while possession accrual stays clearable. A careless first-timer's likely failure is the
market-clog (they panic-summon), which teaches the throttle lesson; the retry then rewards
restraint. An attentive player kills the treant before either clock expires and never sees
a reset.

**On either loss -> dramatic soft-retry, not `resetGame` and not the fail overlay.** Match
the family promise (Giving Tree soft-resets on Vitality; Sundering Stone lets you rebuild).
- Market-clog retry: the old wards flare and beat back roughly half the possessions,
  clearing enough conjuration slots to summon again; drop the spawn rate one notch; gift an
  Exorcist. Mentor line names the lesson ("you fed the veil faster than you could close it;
  summon only what you must").
- Treant-reaches-town retry: the treant is staggered back a step on its clock; refresh the
  player's board/gifts; ease pacing one notch. Never a terminal game-over.
- Mercy hint at the boundary: when the market is ~75% clogged, a loud mentor warning names
  the lever ("you are being disarmed; banish now, or Dispel a slot free with an Exorcist").
  Same role as the tree's Vitality <= 25 hint.

**Handoff to pve-pressure-designer:** own the numbers that make both near-misses real but
survivable; treant HP and advance cadence, possession spawn-per-summon, market slot count,
the ~75% mercy and 100% soft-retry thresholds, and the retry mercy ramp. Target feel: a
careless player gets disarmed or nearly overrun once (learns the stakes), then the
mercy-ramped retry is winnable; an attentive player never sees a reset. The tree's
proof-of-pacing table (expert ~3 turns / accessible ~5 / confused ~7 to soft-reset) is the
model.

---

## 6. Keep it a tutorial; the stable winning line

Bounded and teachable:
- Treant HP + clock sized so a competent line kills it in roughly 6-10 player turns
  (pve-designer to set exact).
- A **stable winning line must provably exist**: a summon cadence where
  treant-damage-per-turn >= what the clock demands AND possession accrual per turn <= what
  the player can clear per turn. This is a JOINT constraint across tcg (ATK output per
  summon, banish cost) and pve (treant HP/clock, spawn rate). **This is the central balance
  risk of the mode; flag it loudly.** If Conjurer ATK is too thin to both feed the treant
  and clear possessions at the required rate, the mode has no honest winning line and the
  lesson becomes "you were always going to lose." See s8.

---

## 7. Lore delivery; land the gamble, earn the gut-punch

"Magic is wild and uncertain" must be planted BEFORE the betrayal so the reveal reads as a
predicted-but-ignored consequence, not a random gotcha. Three beats:

1. **The warning (turn 0, mentor dialogue).** The Conjuration Master establishes the
   Chekhov's gun under duress: the veil is wild, summons come at a price, but there is no
   time to be careful and the town is at the gates. Something like: *"Reach through the
   veil and grab what answers. Pray only what you called answers back. Now GO; the town
   cannot wait for a careful Conjurer."* Consent-to-risk is stated in words, then ignored
   under pressure. The player is TOLD it is a gamble, then forced to gamble.
2. **The omen (Phase-A telegraph).** Keep the current build's "candle-flames lean the
   wrong way" line after the 2nd summon. Cosmetic; makes the reveal foreshadowed on replay.
3. **The reveal (Phase B, on a summon).** The player plays a Conjuration expecting ATK;
   the veil tears and what comes through is not theirs and lodges in the market. Mentor:
   *"That is not yours. You reached too far, too fast; and something reached back."* The
   slot corrupts visibly and blocks summons. The gut-punch is that the exact action that
   was saving the town just planted an enemy inside the player's own toolkit.
4. **The escalation rule, barked in-fiction (first repeat spawn).** The first time a second
   possession spawns from summoning, make the causal rule explicit through flavor, not a
   popup: *"Every door you open, another slips through. Summon only what you must."*

Key to "earned, not a rules dump": the mechanic is always revealed through a consequence of
the player's own chosen action, with the warning pre-planted, never via a modal that reads
"RULE: summoning spawns possessions."

**Tone (carry over from the built version, still correct):** eerie setup, campy fallback;
lean ~60/40 toward genuinely uneasy. The reveal is quiet-wrong then plainly wrong; the
soft-retry and possession barks can be wry ("the chandelier has opinions now") so a new
player never feels punished. Hard lock: unsettling, never grisly. Possessions overtake and
disarm; they do not devour the player.

---

## 8. Onboarding; pool, opening hand, first three turns

**Pool stays Conjurer + Farmer only** (no buildings), matching the current build. Available
cards: Conjurer's Aid (c1), Exorcist (c6), Cleric (c7), farmers (f3/f4); summonable
conjurations (j1/j3/j7/j4) seeded in the conjuration market; possessions are mode-spawned
into the market, not drawn. Exact list and stat blocks -> tcg-designer.

**Opening hand shape** (guarantee the lesson order summon -> fight -> backlash -> banish):
- 2x summonable Conjurations in hand, so turns 1-2 are clean summons that build ATK.
- One economy piece (Conjurer's Aid or a Farmer) so the market is usable and Harvest funds
  the summoning (setup already forces the Harvest auspice; keep).
- **Withhold the Exorcist from the opening hand.** Introduce it as a gift AT the reveal
  (Phase B), so the cleanup verb appears only when it has a target. This declutters the
  Phase-A teach. (Difference from the current build, which seeds c6 at start.)

**Ideal first three turns:**
- **Turn 1:** summon creature #1 -> ATK added -> first **Strike the Treant.** Treant HP
  drops; treant advances one step. Lesson: summon = your weapon against the monster.
- **Turn 2:** summon creature #2 -> strike again. Omen telegraph fires. Treant advances.
- **Turn 3 (the reveal):** this summon tears the veil; possession #1 lodges in a
  conjuration market slot. Banish/Dispel UI + Exorcist gift appear. Guided first banish
  (highlight the possession, highlight the lever, "point your power at it; banish"). Two
  fronts from here on.

Teach order delivered: SUMMON (t1) -> STRIKE (t1) -> repeat + omen (t2) -> BACKLASH (t3)
-> BANISH (t3). One new thing at a time; each verb only appears when it has a target.

**Gift cadence (load-bearing, like every tutorial):** each Phase-C turn, ensure the player
can act on at least one front; never let a clogged market plus an empty ATK pool softlock
them. Pattern: `ensureStageGifts()` / `treeGift()` / the current build's `manorGift`.

---

## 9. Buildable structure (reuse map for engineering)

This redesign reuses more live engine than the built version; it removes bespoke pieces.

- **Treant = the Long Winter boss pattern.** Model one boss like a single Horseman: an
  object with `hp`/`maxHp`, an advance clock, and a strike function that spends the ATK
  pool onto its HP (mirror `attackHorseman()` at ~L2234 and the `S.lw` rider shape at
  ~L2181). The advance-on-town clock mirrors Winter's `deepenEvery` -> Long Night loss at
  ~L2226-2231. This is a smaller bespoke add than the old manor grid.
- **Possessions-in-market = live machinery, do not rebuild.** `attackPossession(uid)`
  (~L5546) spends ATK >= possession DEF, sends it to Legend, refills the slot; already
  applies the Cleric +2-vs-possession bonus. `dispelPossessionFromMarket(uid)` (~L5639) is
  the Exorcist free Dispel. `allMarketsUnavailable()` (~L1332) is the market-clog loss test
  and reduces here to "all conjuration slots haunted." `slotIsHaunted` (~L1319) already
  reads `isPossession`.
- **DELETE from the built version:** the 3x3 `S.manor.rooms` grid, `manorSpawn`,
  `manorBanish`/`manorDispel` (replaced by the live `attackPossession`/`dispel...`),
  `manorSurge`'s room logic, the `seal`/`sealMax` Veil Seal bar and `manorWin`. Keep and
  repurpose the phase/telegraph/gift scaffolding (`onManorSummon`, the omen line, gift
  cadence).
- **Spawn on summon into the market**, not into rooms: on the reveal and thereafter, a
  summon injects a possession card into a conjuration market slot (spawn rule owned by
  tcg-designer). Reuse the existing possession card templates rather than mode-local room
  objects.
- **Setup:** `setupHouse()` seeds the treant boss object, the opening hand (s8), Harvest
  auspice (keep), and neutralizes the Creeping Doom apparatus (the mode drives its own
  clock), as Long Winter's setup does at ~L2190-2191.
- **Turn logic:** `houseTurn()` (dispatched from `endTurnCore` at ~L4620) advances the
  treant clock every turn, checks treant HP <= 0 (win), the market-clog test (soft-retry),
  and fires the scripted reveal on the gated summon.
- **Render:** `renderManorZone` (renamed conceptually) shows, from turn 1, the treant HP
  bar + advance clock and a "Strike the Treant" button; post-reveal, the conjuration market
  row surfaces the possessions and the Banish/Dispel affordances (largely already rendered
  by `renderMarket` for haunted slots).

New bespoke logic is small: one boss object + clock, the scripted reveal, the summon->market
spawn hook, and the two soft-retry checks. Everything else is existing engine.

---

## 10. Open design questions / tensions (not all mine to rule)

- **CENTRAL BALANCE RISK (tcg + pve, jointly):** does a Conjurer + Farmer pool generate
  enough ATK to BOTH out-damage the treant clock AND clear/throttle possessions at the
  spawn rate? If Conjurers are ATK-light early (they lack the Warrior mass-ATK tools), the
  two-front math may have no honest winning line. This must be proven against real stats
  before build. See s6.
- **Shared vs. split ATK pool (tcg):** treant and possessions currently drain the same
  pool. Shared = max tension but high death-spiral risk; split (treant = ATK pool,
  possessions = Exorcist/Cleric tools) = gentler and recommended for a tutorial. See s4.
- **Spawn rule (tcg):** every summon spawns a possession (1:1, punishing; risks teaching
  "never summon"), or only past an instability threshold, or only creature-summons (not
  spell-summons)? Recommend a meter/threshold so a single measured summon is fairly safe
  but over-summoning in one turn breaks the veil, preserving "throttle" without "stop."
- **Which clock is the framed threat (pve):** recommend the treant clock is the visible
  countdown and the market-clog is the silent-but-real punish; confirm.
- **Does killing the treant win even with possessions remaining (Bryan)?** Recommend YES
  (single clear objective; possessions are the cost). Alternative: a clean-the-market coda
  before the win screen. Flagged for Bryan's call. See s5.
- **Possession rewards in a tutorial (tcg):** `attackPossession` sends possessions to
  Legend with VP/draw rewards. Keep a light reward (e.g., first banish draws 1, the
  "closing veil gives a little back" beat) or make them reward-neutral? tcg-designer's call.
- **Technical: driving market haunts without the full monsterQueue (engineering).** Whether
  the mode-local spawner can inject possessions into the conjuration market without spinning
  up `monsterQueue`/`monsterStates`, or whether a lightweight local spawner is cleaner, is
  an implementation call. Flagging; unchanged from the prior spec.
- **Out of scope here:** the deeper "Feed me"-style finale for this mode (Evil Ideas Bank
  #4) remains on ice; this pass is the core lull-then-backlash only.

---

## 11. QA-testable checklist (for qa-lead to expand)

- [ ] Treant HP bar and advance clock are visible from turn 1; "Strike the Treant" works
      on turn 1 after the first summon; treant HP drops and the clock advances each turn.
- [ ] Phase A: no possession can appear before the scripted reveal; the omen after summon
      #2 fires exactly once and is purely cosmetic.
- [ ] Reveal fires once, deterministically, on the gated summon (not a raw turn timer);
      possession #1 lands in a conjuration market slot and blocks summons from it.
- [ ] Banish (`attackPossession`) and Exorcist Dispel (`dispelPossessionFromMarket`) are
      unavailable before the reveal, available after; the first banish is guided.
- [ ] Treant HP <= 0 ends the mode in victory regardless of market state (per s5 ruling).
- [ ] `allMarketsUnavailable()` (all conjuration slots haunted) triggers soft-retry, never
      `resetGame`, never the fail overlay; ~half the market cleared, spawn eased one notch.
- [ ] Treant reaching the town triggers soft-retry, never a terminal game-over.
- [ ] The player can always act on at least one front each turn (gift cadence never
      softlocks a clogged-market + empty-pool state).
- [ ] Mercy hint fires at ~75% market clog and names a concrete lever.
- [ ] Lore: warning lands turn 0; omen at summon #2; reveal reads as an earned consequence
      of a summon; escalation rule barked in-fiction on the first repeat spawn.
- [ ] Tone: reveal copy reads eerie; fallback/soft-retry copy reads wry; nothing gory.
</content>
</invoke>
