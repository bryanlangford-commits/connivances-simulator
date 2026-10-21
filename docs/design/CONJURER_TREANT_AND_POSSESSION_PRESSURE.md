# Conjurer Tutorial; Treant Boss Clock + Possession Self-Clock (Pressure Spec)

**Owner:** pve-pressure-designer (threat layer only).
**Mode:** `conjurer_house` ("Conjurer Training: The Summoner's Plight").
**Status:** DESIGN pass, first-pass numbers for playtest tuning. Do NOT edit the sim from
this doc; engineering builds against it.
**Supersedes (threat layer only):** the veil-seal-to-6 win and the 9-room-manor spread
clock in `CONJURER_TUTORIAL_SPEC.md` / the current v11_6_4 build. See "What changes vs the
current build" and the tensions section. Card numbers (summon ATK, dispel cadence) belong
to **tcg-designer**; overall structure/teaching order belongs to **design-lead**.

Style note: this doc uses no em dashes by owner rule.

---

## 0. The reframe in one paragraph

The Treant stops being flavor and becomes a **persistent boss attacker with HP**, modeled
like a Long Winter Horseman: it stands in play the whole tutorial and chews a **Town
Integrity** bar every enemy turn. The player **summons creatures to build an ATK pool and
strike it down before the town falls**. The catch: every summon leaks **wild-magic
backlash** that spawns **possessions into the Conjuration Market**, choking the very engine
that produces your ATK. So the player's single ATK pool is pulled two ways each turn:
**hit the Treant (win progress)** or **banish possessions (protect your engine)**. That
split is the whole game. Throttle-and-clear wins; reckless over-summoning drowns its own
market and loses.

Two clocks, deliberately coupled:
- **EXTERNAL clock (autonomous):** the Treant damages the Town every turn. You cannot turn
  it off by doing nothing; only by killing the Treant.
- **SELF-INFLICTED clock (player-driven):** possessions accumulate only when you summon.
  It does not tick on its own; recklessness is the only thing that advances it.

The clocks cross-check each other so neither degenerate strategy is safe: turtling starves
the Treant of nothing (it keeps advancing, you have no ATK, town falls); flooding summons
keeps the Treant fed with ATK but buries your market, then starves your ATK, and town falls.

---

## 1. The Treant clock (external, autonomous)

Patterned on `longWinterTurn` / the Horseman riders: a named boss with HP, an escalating
per-turn assault, and a player lever that buys time.

### 1.1 Boss stats (first pass, TUNE)
| Field | Value | Notes |
|---|---|---|
| Treant HP | **28** | Killed over the whole Phase C race. ~= 5x the throttle player's per-turn treant-facing ATK. |
| Town Integrity | **12** | The doom bar. Reaches 0 = loss beat (see §4). |
| Treant town damage | **1 / 1 / 2 / 2 / 3 / 3+** | Per Phase-C enemy turn (tier schedule below). Escalates as it settles in at the gates. |
| Stagger trigger | **single-turn strike >= 8** | A big hit staggers it (see §1.3). |
| Stagger effect | **0 town damage on its next turn** | Buys exactly one turn of town safety. |

The Treant **only damages Town Integrity.** It does not disable the player's creatures or
buildings (that would be a third pressure and would muddy the ATK-split lesson). Flagged as
a possible hard-mode escalation later, out of scope for the tutorial.

### 1.2 Approach and the two-phase timeline
The Treant is **visible and advancing during Phase A** but does not damage the town yet;
this preserves the tutorial family's scripted lull while keeping Bryan's "persistent
attacker" promise.

- **Phase A (approach, ~2-3 turns):** the Treant closes a distance counter **3 -> 2 -> 1**,
  one step per end-turn, as the player summons their first three creatures. No town damage,
  no possessions. Pure slack; the dopamine window.
- **Reveal (on the 3rd summon, one enemy tick later):** the Treant **reaches the gates**
  and the **veil cracks** in the same beat. From the next enemy turn: Town damage begins AND
  the first possessions appear (§2). Both clocks start together, so the reveal is a single
  legible "now it is real" moment.
- **Phase C (the race):** the dual-clock loop below until the Treant dies (win) or the town
  falls (loss beat).

### 1.3 Town-damage tier schedule (Phase C)
Count Phase-C enemy turns from the reveal.

| Phase-C turn | 1 | 2 | 3 | 4 | 5 | 6+ |
|---|---|---|---|---|---|---|
| Town damage (if not staggered) | 1 | 1 | 2 | 2 | 3 | 3 |
| Unmitigated cumulative | 1 | 2 | 4 | 6 | 9 | 12 |

**Unmitigated town-fall = end of Phase-C turn 6.** That is the hard outer deadline for a
player who never staggers the Treant. Killing it sooner, or staggering to skip damage turns,
extends the town's life.

### 1.4 Stagger: the player's lever on the external clock
If the player lands a **single-turn strike of >= 8** on the Treant, it **recoils and deals 0
town damage on its next turn.** This is the only way to slow the external clock short of
killing the boss, and it is deliberately expensive: to burst 8 into the Treant you spend
little or nothing banishing that turn, so a possession lingers and your market tightens.
**Stagger trades external-clock relief for self-inflicted-clock pressure.** That coupling is
the point; the player should feel the trade every time they take it.

Design intent: a competent player triggers 1-2 staggers across the race, landing the kill
with the town in the red (a visible near-miss), not comfortably.

---

## 2. The possession clock (self-inflicted, player-driven)

Possessions are **wild-magic backlash from summoning**, per `FACTION_IDENTITIES.md` (the
Conjurer's own mess, not external portal monsters). They **choke the Conjuration Market**,
which is the player's engine for growing ATK. They **do not spread on their own**; the only
thing that advances this clock is the player summoning.

### 2.1 Where they land (implementation choice, flag to engineering)
Bryan's vision: possessions "occupy the player's Conjuration market." The live conjuration
market is only **3 slots** (`mkMarket(modeConjurations(),3)`), which is a very brittle,
swingy clock (2 possessions and you are almost locked). Two options:

- **Recommended: a 6-gate "Conjuration Market saturation" track.** Reskin the existing
  `S.manor.rooms` array (already built, already renders) from "rooms" to **6 summoning
  gates** representing the market's veil-saturation. Gives tuning granularity while keeping
  Bryan's framing. Failure edge = 6/6 gates locked.
- **Alternative: bind to the literal 3 live market slots** (reuse `isPossession` market
  machinery at lines ~3894 / ~5547). Maximum system fidelity, but halve every backlash
  number below and expect a much twitchier clock. Engineering's call; I default to the
  6-gate track for playtest.

Everything below assumes the **6-gate** track. Halve spawn counts for the 3-slot variant.

### 2.2 Backlash and spawn rate (first pass, TUNE)
| Field | Value | Notes |
|---|---|---|
| Backlash per Creature summon | **+2** | Creatures are wilder magic. |
| Backlash per Spell summon | **+1** | Spells are safer. |
| Spawn threshold | **>= 4 backlash** | On crossing, spawn **1 possession** into an open gate; backlash -= 4. |
| Reveal seeding | **1 possession** | The scripted first possession at the reveal (down from the current 2, so a 6-gate track opens at 1/6, not 2/9). |
| Possession DEF (banish cost) | **3** | Flat. Spend ATK pool >= 3 to banish one; frees the gate. |
| Auto-spread | **none** | Possessions never multiply on their own. Player summoning is the only source. |
| Gate cap | **6 locked** | All gates choked = self-inflicted failure edge (§4). |

So: ~1 possession per **two** creature summons. A throttle player summoning ~1 creature/turn
generates a possession roughly every other turn and can clear it and still have ATK left for
the Treant. A reckless player summoning 3-4/turn generates 1-2 possessions/turn and cannot
both clear them and meaningfully hit the Treant.

### 2.3 What a sitting possession costs
The lock itself is the cost: a locked gate cannot be used to buy/restock conjurations, so
your ability to grow the ATK engine is throttled in proportion to how many gates are
choked. This is a slow squeeze by design; the sharp edge is only reached by a player who
keeps flooding summons without clearing.

Optional "bite" toggle for tuning if the slow squeeze reads as too soft in playtest: each
gate left locked at end of turn reduces next turn's ATK pool by 1. Default OFF; turn on only
if playtest shows players ignoring possessions with no felt consequence.

---

## 3. The crux: one ATK pool, two demands (interleaving)

Each Phase-C turn the player builds a single ATK pool from their summoned creatures, then
**allocates it** via the UI:
- **Strike the Treant** (a button that spends from the pool into Treant HP; a >= 8 burst
  staggers).
- **Banish a possession** (per-gate button; spends >= 3 to free that gate).

The tension is a budget split, turn after turn:

> ATK spent banishing is ATK not spent on the Treant. ATK spent bursting the Treant (to
> stagger and buy town time) is ATK not spent clearing your market, so a gate stays locked.

### 3.1 The intended tension curve, turn by turn
Assume the throttle player's total ATK pool grows roughly +2 per creature on board (exact
values are tcg-designer's; these are illustrative to show the SHAPE, labeled ILLUSTRATIVE).

**Throttle-and-clear line (the winning line):**

| Phase-C turn | Pool (ILL.) | Banish (cost) | Treant strike | Treant HP | Town dmg | Town |
|---|---|---|---|---|---|---|
| start | - | - | - | 28 | - | 12 |
| 1 | 7 | 1 poss (3) | 4 | 24 | 1 | 11 |
| 2 | 8 | 1 poss (3) | 5 | 19 | 1 | 10 |
| 3 | 9 | 1 poss (3) | 6 | 13 | 2 | 8 |
| 4 | 10 | 1 poss (3) | 7 | 6 | 2 | 6 |
| 5 | 11 | 0 (burst) | 11 -> **kill** | 0 | 3 (staggered? see note) | 3-6 |

Town ends in the red (~3-6 / 12): a felt near-miss, not a walk. If the player instead
bursts the Treant earlier (>= 8) to stagger and protect the town, a possession lingers and
their market tightens; they trade one clock for the other. Either disciplined line wins; the
win is never free.

**Reckless over-summon line (the losing line):**

| Phase-C turn | Summons | Possessions spawned | Gates locked | What happens |
|---|---|---|---|---|
| 1 | 3-4 | +2 | 3 | Pool is high but 2-3 gates already choked; player dumps ATK on Treant, does not banish. |
| 2 | 3-4 | +2 | 5 | Market nearly gone; can no longer restock conjurations; ATK growth stalls. |
| 3 | any | +1 | 6 -> **SURGE** | Self-inflicted soft-lock; surge clears half, but tempo is lost and the Treant has been chewing town at rising tiers the whole time. |

The reckless player either keeps surging (bleeding tempo while the town damage tier climbs
to 3) or finally starts banishing (and falls hopelessly behind on Treant HP). Both roads
run the town to 0. The loss is legible: "you fed the veil faster than you fought the tree."

### 3.2 Why the two degenerate strategies both fail
- **Turtle (summon nothing):** no possessions, clean market, but no ATK. The Treant is
  autonomous; town falls by turn 6 with the boss near full HP. Doing nothing is a loss, which
  is exactly the anti-turtle property the V11 baseline says the main mode lacks.
- **Flood (summon everything):** maximum ATK but the market chokes in 2-3 turns; ATK growth
  stalls and every surge costs tempo the town cannot afford. Loss.

Only **throttle-and-clear** threads both clocks. That is the lesson.

---

## 4. Loss states (recommendation)

Two doom edges exist; they read very differently and I recommend treating them very
differently.

### 4.1 LOSS A (external): Town Integrity reaches 0. PRIMARY, terminal-feel.
This is the dramatic, headline loss: the Treant breaks the gates. It is the state the whole
race is measured against, and it is the one that should feel like a real defeat.

Reading: a full Town Integrity bar at the top of the objective zone (mirror the Long Winter
stage bar), the Treant art advancing, and at 0 a clear "the town is overrun" beat.

**Tutorial-family reconciliation (flag to design-lead):** `CONJURER_TUTORIAL_SPEC.md` §5
argues this tutorial is UNFAILABLE (soft-retry only). Bryan's new vision asks for "real loss
states." These conflict. My recommendation, splitting the difference and keeping the family
promise:
- **First town-fall = a mercy soft-reset of Phase C**, not the fail overlay. Restore Town to
  ~half (6/12), leave the Treant's current HP (you keep your progress on it), drop the town
  damage tier by one notch, and drop a stern seer line. Real lost ground, no `resetGame`,
  never `showGameEndOverlay(false)`. This mirrors the tree's Vitality soft-reset and the
  current `manorSurge` mercy.
- If Bryan wants THIS tutorial to be genuinely failable (a deliberate departure from the
  family), the terminal hook is trivial (`showGameEndOverlay(false)`), but that is a
  structure decision for design-lead, not a threat-layer call. I default to soft-reset.

### 4.2 LOSS B (self-inflicted): all Conjuration gates locked. NOT terminal; a soft-lock we must never let dead-end.
A "you can no longer act at all" state is the worst kind of loss: it removes counterplay
entirely. So **LOSS B is never terminal.** All-gates-locked triggers a **SURGE soft-retry**
(reuse `manorSurge`): the old wards flare, **clear half the gates**, reset backlash to 0, and
**gift an Exorcist** (a free dispel). The player resumes with lost tempo, which is punishment
enough because the Treant kept advancing during the scramble.

Reading: "the veil has swallowed your summoning" -> wards flare -> "you survived by inches;
stop feeding the veil." Wry/theatrical per the tone lock, so a learning player never feels
punished by the soft-lock itself, only by the tempo they lost.

### 4.3 The escape valve (coordinate cadence with tcg-designer)
LOSS B is guaranteed never to dead-end because the **Exorcist free dispel** always relieves
it. What I need from tcg-designer for that guarantee:
- **>= 1 free dispel reachable per 2 Phase-C turns** (via gift cadence and/or buyable
  Exorcists), so the player can always clear at least one gate without spending ATK.
- **A gifted Exorcist whenever locked gates >= 4** (mercy hint threshold), naming the lever
  in-line, exactly as the current `manorHauntedCount()>=7` mercy gift does.

The Exorcist is the pressure-relief that lets a player who over-summoned once claw back
without spending the ATK they need for the Treant. It is the designated valve for the
self-inflicted clock; the Treant clock has no free valve except the kill and the stagger.

---

## 5. Escalation curve summary (early slack -> mid squeeze -> late inevitability)

- **Phase A (approach):** pure slack. Summon freely, feel powerful, the Treant is a distant
  silhouette closing 3 -> 1. No town damage, no possessions.
- **Early Phase C (turns 1-2):** low squeeze. Town damage 1/turn, few possessions, the
  player learns the split and the first stagger feels great.
- **Mid Phase C (turns 3-4):** the squeeze bites. Town damage rises to 2/turn; if the player
  over-summoned early, gates are locking and the ATK-split hurts. This is where reckless
  players hit their first surge.
- **Late Phase C (turn 5+):** inevitability. Town damage 3/turn; if the Treant is not near
  death the town collapses fast. The throttle player lands the kill here with the town in the
  red, the intended near-miss.

---

## 6. First-pass number block (single place to tune)

| Parameter | First pass | Lever it controls |
|---|---|---|
| Treant HP | 28 | Length of the race; raise = longer, more grind. |
| Town Integrity | 12 | Slack before the external deadline. |
| Town damage tiers | 1,1,2,2,3,3 | Shape of the external escalation. |
| Stagger threshold | strike >= 8 | How hard it is to buy town time. |
| Stagger effect | skip 1 town-damage turn | Value of buying time. |
| Backlash: creature / spell | +2 / +1 | How fast summoning feeds the self-clock. |
| Spawn threshold | 4 | Summons per possession (currently ~2 creatures each). |
| Reveal possession seed | 1 | Opening self-clock pressure. |
| Possession DEF | 3 | ATK cost to clear one; the size of the "banish tax." |
| Gate count / cap | 6 | Granularity + how many mistakes before a surge. |
| Free-dispel cadence | >= 1 per 2 turns | tcg-designer owns; the LOSS B safety guarantee. |
| Mercy-gift threshold | gates locked >= 4 | When the game hands help. |

**Parametric handoff to tcg-designer.** Let `A` = the throttle player's steady per-turn ATK
**after** paying ~3 to banish one possession (i.e., ATK actually landing on the Treant).
Target relationships to hold once real card ATK is known:
- **Treant HP ~= 5 * A**, so the throttle line kills it in ~5 Phase-C turns.
- **Town Integrity** set so the unmitigated town-fall turn is ~1 turn AFTER the expected kill
  turn, i.e., the throttle player wins with roughly a quarter to a third of the town bar left.
- **Reckless per-turn banish demand (2 possessions = 6 ATK)** should exceed the extra ATK a
  reckless summon burst yields, so flooding is a net loss of Treant-facing ATK, not a gain.

If tcg-designer's real numbers make `A` much smaller than assumed, scale Treant HP and Town
Integrity down together to preserve the ~5-turn race and the near-miss.

---

## 7. Edge cases (build against these)

- **Zero ATK on a Phase-C turn:** player summoned nothing and has no board ATK. They can
  neither strike nor banish; the Treant deals its tier damage; the town clock advances. This
  is the correct anti-turtle consequence. Ensure the gift cadence has by then handed enough
  summonables that this is a choice, not a softlock (design-lead's gift-cadence rule).
- **All gates locked (LOSS B):** fire the SURGE soft-retry (§4.2), never a dead-end. Verify a
  free Exorcist is gifted on the same beat.
- **Town at 0 (LOSS A):** fire the mercy soft-reset (§4.1) on first occurrence; Treant HP is
  preserved so progress is not erased.
- **Backlash at/over threshold with no open gate:** if backlash crosses 4 but all 6 gates are
  already locked, do NOT drop the possession on the floor; hold the overflow and immediately
  route to the LOSS B surge (the market is already saturated).
- **No possession to banish but player has ATK:** all ATK is free to hit the Treant; fine and
  intended (a clean-market turn is the reward for good throttling).
- **Stagger on the killing turn:** if the strike that kills the Treant is also >= 8, the
  stagger is moot (boss dead); no need to track a post-death town skip.
- **Treant killed with LOSS-B surge queued the same turn:** resolve the Treant kill first;
  a dead Treant = win regardless of gate state. The win check must precede the gate-cap check
  in the turn order.
- **Player bursts >= 8 every turn (all-in on Treant, never banish):** legal and sometimes
  correct near the end, but early it will lock the market to a surge; the surge tempo loss is
  the built-in check. Verify it does not let them ignore the self-clock entirely.

---

## 8. What changes vs the current v11_6_4 build

For design-lead / engineering awareness; these are threat-layer changes, surfaced not
unilaterally decided:

1. **Win condition moves from veil-seal-to-6 to Treant-HP-to-0.** The `manorWin` /
   `M.seal`/`M.sealMax` race is retired as the win. (Optional: keep a cosmetic "veil seal"
   tick on banish, or grant a small tidy-up reward for a fully clean market, but it is no
   longer the objective.)
2. **The Treant gains real stats** (HP, town-damage clock, stagger) instead of being intro
   flavor text. New boss state on `S.manor` (e.g. `treantHp`, `townHp`, `townTier`,
   `staggerNext`) modeled on the `lw.riders` pattern.
3. **The 9-room manor spread clock is retired** in favor of the 6-gate Conjuration Market
   saturation track (a reskin of the same `rooms` array). Crucially, **possessions no longer
   auto-spread**; they are summon-driven only, which flips the current time-driven spread and
   removes the current tuning that rewards not summoning.
4. **Reveal seeds 1 possession, not 2** (a 6-gate track should open at 1/6).
5. **Two doom bars replace one:** Town Integrity (external) and gate saturation
   (self-inflicted), instead of the single haunted-rooms bar.

---

## 9. Tensions with the other two agents' layers (report these up)

- **With design-lead (structure):** the biggest open conflict is §4.1. The tutorial spec's
  UNFAILABLE stance vs Bryan's "real loss states." I recommend soft-reset-on-first-town-fall
  to keep the family promise while making the doom genuinely reachable and dramatic, but the
  final failable/unfailable call is design-lead's. Also flag that this rework **changes the
  win condition** (§8.1), which is a structure-level change, not just a number.
- **With tcg-designer (card layer):** three hard dependencies. (a) The **parametric target
  in §6**: Treant HP and Town Integrity must be re-derived once real summon ATK is known;
  the ~5-turn race and near-miss only hold if `A` lands where assumed. (b) The **free-dispel
  cadence** (§4.3) is the sole guarantee that LOSS B never dead-ends; I need >= 1 free dispel
  reachable per 2 turns and a gifted Exorcist at >= 4 locked gates. (c) **Banish math**: for
  the reckless line to lose, the extra ATK a summon burst yields must be less than the banish
  tax it creates (2 possessions = 6 ATK); if Conjurer creatures are ATK-heavy early, flooding
  could become net-positive and break the tension, so the DEF-3 banish cost and the +2/+1
  backlash rates need a joint pass with real card ATK.
- **Cross-check with `FACTION_IDENTITIES.md`:** this design assumes possessions are the
  Conjurer's OWN wild-magic backlash (self-inflicted), not external portal monsters. The
  entire self-clock framing depends on that ruling holding.
