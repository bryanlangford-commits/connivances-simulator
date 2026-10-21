# MD Update Queue — for `CONNIVANCES_Project_Master_Instructions_v2.3`

**Purpose:** everything from the Claude Code QA sessions that must be written into
the **next** master-instructions MD, so the artifacts (simulator, rulebook, Tracks
xlsx) can then be manually reconciled. Nothing here is applied to the MD yet.

Baseline reviewed: **v2.2** (`docs/design/CONNIVANCES_Project_Master_Instructions_v2_2.md`).
Code reviewed: `simulator/connivances_simulator_v11.html`.

---

## A. New changelog entries to add (V11 continued)

These are implemented + live-verified in the local `connivances_simulator_v11.html`
but are **not** yet in the MD changelog (v2.2 stops at V11-2.6).

| # | Item | Detail |
|---|---|---|
| **V11-3.1** | **Attached recruit now detaches on host disable** | §13B Item 30 already specifies *"On host disabled: attached recruit → player's discard pile. Host stays in play."* This was **never implemented** — `monsterAttackPermanent` / `executeWallSiege` only set `disabled=true`, stranding the recruit on the host and leaving its DEF in play. New `detachRecruitsOnDisable(perm)` pushes each attached **player recruit** to `S.discard` (`_attached:false`) and clears it from `attachedCards`; **enemy Possessions are kept**. Called from both disable sites. With the recruit gone, `recomputeStoredDef` on repair correctly returns base DEF + Wall Set only. |
| **V11-3.2** | **`defBonus` contract wired** | `recomputeStoredDef` (V11-2.6) reads `a.defBonus`, but **nothing ever wrote that field** — it was always 0. `confirmAttach` now stores `{...card, defBonus:2}`; Expediter placement stores `{...card, defBonus:-2}`; `detachCard` rebuilds via `recomputeStoredDef(host)` instead of a blind ±2 (the old ±2 also capped Expediter-on-Siege at base DEF, losing the Wall Set +2). Needed for **voluntary** detach and stacked attachments. |
| **V11-3.3** | **Swordsman top-deck no longer uses a blocked `confirm()`** | Violated the LOCKED §13B rule "No browser dialogs anywhere." In the iframe the dialog is silently blocked, so the top-deck branch never ran — **Swordsman effect2 was dead in the shipped build.** Now uses `showListPicker` (two options, mandatory). Picker is async, so the purchased card is located **by uid** at selection time instead of assuming it is still last in `S.discard`. |
| **V11-3.4** | **Templated opening hand removed — pure random 5 of 10** | Designer ruling (2026-07-20): §12A.1's fixed opening hand was **legacy test scaffolding** for verifying Legend + Farm behaviour, not a live rule. All templated-hand support removed; the opening hand is a pure random 5-card draw from the 10 starter cards (any card, including Rice Field, may open). The startup log that asserted *"Rice Field starts in deck"* was also removed — it is no longer true and was misleading. Verified over 200 games: 23 distinct openings, per-card appearance at the expected ~50% rate, pool always the correct 10 cards. |

---

## B. Rule text to add / correct in the MD body

### B1. §12A.6 Repair System — STALE, must be rewritten
Current text: *"Repairing restores `currentDef` to `card.def` and sets `disabled: false`."*
This contradicts §13B (V11-2.6), which correctly requires `recomputeStoredDef`.
**Replace with:** repair sets `disabled:false` and restores `currentDef` via
`recomputeStoredDef(p)` (base + remaining attachment `defBonus` + WallSets×2 for
`isCreatureType||atk_siege>0`) — never bare `p.def`.
**Also add** the disable/attachment interaction (V11-3.1): because an attached
recruit leaves for the discard pile when its host is disabled, a repaired
permanent does **not** regain that recruit's DEF.

### B2. §12A.3 "Real-Time Food Delta" — STALE, contradicts §12A.2
Line reads: `delta = (newBonus - oldBonus) × activeFarmCount` — that is exactly the
**±1 model that V11-2.3/2.4 removed**, and §12A.2 already documents the correct
true-output + `farmFoodDebt` behavior. **Delete or rewrite** this paragraph to
match §12A.2, otherwise a future build reading §12A.3 will regress the food-mint
exploit.

### B0. §12A.1 Starting State — LEGACY SCAFFOLDING, must be rewritten ⚠️ highest priority
Current text specifies a **fixed** opening hand (King's Note ×2, Devoted Aid ×1,
Farm Hand ×1, Augury Initiate ×1) with deck = Devoted Aid ×4 + Rice Field ×1.

**This is obsolete.** Per designer ruling (2026-07-20) that templated hand was only
ever test scaffolding used to verify Legend and Farm behaviour. **Replace with:**

> **Starting hand:** a pure random 5-card draw from the player's 10-card starter
> deck (King's Note ×2, Devoted Aid ×5, Farm Hand ×1, Augury Initiate ×1,
> Rice Field ×1). No forced or templated hand — any card, including Rice Field,
> may appear in the opening hand. The remaining 5 cards form the starting deck.

**Knock-on edits required:**
- **§12A.2 Farm Hand rationale** — currently reads *"Its sole purpose is providing
  enough Food to play a fourth card on opening turns before the Rice Field has
  surfaced."* That wording implies Farm Hand is guaranteed in the opening hand,
  which is no longer true. Reword to describe its *purpose* (a cheap Food burst
  that enables extra plays) without implying guaranteed presence.
- Anywhere else implying Rice Field "starts in deck" — it may now open in hand.
- Note for balance work: opening-turn variance is now **intended**, so turn-1
  balance analysis must be done across a sample, not a single canonical opener.

### B3. §12A.1 monster-queue line contradicts §8E
§12A.1 says *"full pool of 9 monsters shuffled, The Portal always last (10 total)"*.
§8E says *"Single Player Queue: 4 monsters + The Portal (5 total)… Ghoul always
first, remaining 3 random."* **The code implements §8E.** Fix §12A.1 to match
(or state explicitly that 9+Portal is a future/other mode).

### B4. §13A vs §13B Item 30 — attachment stacking contradiction ✅ RULED
- §13A (must-not-regress) said: *"**One** recruit attachment per permanent. Already-attached permanents excluded from pickers."*
- §13B Item 30 spec said: *"**Stacking:** multiple recruits can attach to the same permanent. DEF bonus is additive."*

**Designer ruling (2026-07-20): §13B wins — attachments STACK, DEF additive.**
**MD edit required:** delete the §13A "one recruit attachment per permanent" row
(it is superseded, and leaving it in a *must-not-regress* table will cause a future
build to re-introduce the restriction as a "fix").

Implemented as **V11-3.5**: removed the `hasRecruitAttachment` eligibility filter from
all three attach sites (Meurtrière `b5`, Fortifier `b6`, Retinue `c4`) and deleted the
helper. Verified live: two Fortifiers on an Armory → DEF 5→7→9; `recomputeStoredDef`
agrees; detaching one leaves the other at 7 (the V11-3.2 `defBonus` work is what makes
this correct — the old blind ±2 could not); already-attached permanents are eligible
targets; disable sheds **all** attached recruits to discard and repair returns to base.

---

## C. Open items to annotate

- **Item 60 (Expediter −2 repair gap)** — partially addressed by V11-3.2: Expediter
  now carries `defBonus:-2`, so a rebuild preserves its penalty. But note V11-3.1
  means a disabled host sheds the Expediter to discard entirely, so on repair the
  building returns at full base DEF. Confirm that is the intended reading.
- **Item 61 (Portcullis bonded-set immunity scope)** — still open; V11-2.2 covers
  only the Portcullis card itself, not its bonded set.
- **Balance note (not a bug):** all guardians can be *unsealed* rather than killed
  to expose the Portal (`isPortalExposed` returns true when none are `guarding`),
  enabling a possible unseal-rush fast win. Already tracked as an open item.
- **Caravan "persistent damage" is flavor-only** — `monsterAttackPermanent` only
  disables; it never reduces `currentDef`, so the end-of-turn
  `isCaravan && currentDef<=0` destruction check is dead code. Caravans are still
  destroyed via the `disabled` branch in `startTurn`. Either implement real chip
  damage or soften the card text + drop the dead check.

---

## C2. V11 Creeping Doom — decision pass rulings (2026-07-20)

Worked through point-by-point with the designer. See
`V11_CREEPING_DOOM_BRIEF.md` and `V11_CREEPING_DOOM_REVIEW.md`.

### Point 1 — R2 targeting priority: **RESOLVED — permanents first, markets as fallback (unchanged)**
R2 stands as ruled. The three objections raised in review are answered:
- *"One chaff permanent stalls the clock"* — **wrong**: there are up to **four**
  monsters; one permanent absorbs one action, the rest still hit markets. Full
  stall requires 4+ *enabled* attackable permanents every turn, and attacked
  permanents become disabled — so sustaining it is a **repair-throughput race**
  (House Hand/Repair Master = 1, Contractor = 2). Legitimate strategic axis, not
  an exploit. Flagged as a tuning question, not a blocker.
- *"Repair just re-arms a decoy"* — **wrong**: a repaired permanent is usable the
  same turn. `grantMidTurnIncome` already restores ATK/Inf/Food, so repairing a
  Catapult with a 3-ATK pool yields 4 ATK that turn. Verified in code.
- *"Killing monsters accelerates market loss"* — **dissolved** by the Trophy
  ruling below.

### ⚠️ Point 1a — Trophies ARE monster-targetable in single-player (RULING REVERSAL)
**New ruling:** Trophies in play behave **like buildings** — monsters may target and
**DISABLE** them (never destroy), and they are **repairable** through the normal
repair path. A Trophy's DEF is its printed value **+1 while the active Auspice
matches its faction tag** (`auspiceTag` / `auspiceBuffHP`).

**This reverses documented rulings in FOUR places — all must be struck/rewritten,
or a future pass will "re-fix" it as a regression:**
| Location | Current (now obsolete) text |
|---|---|
| **21-C** (v2.1 changelog) | "Trophies are immune to ALL monster targeting in single-player… scoped to future PvP only" |
| **§5A** | Same, marked "reconciled v2.1" |
| **§10 item 15** | Same |
| **§13A must-not-regress** | "Trophy monsters were valid monster targets — **Fixed**, Trophies are excluded from monster attack targeting" |

**Implementation notes (not yet applied):**
1. Remove the `!p.isTrophyMonster` filter from `monsterPickTarget`.
2. Apply `auspiceBuffHP` wherever a Trophy's DEF is evaluated — **both**
   `monsterPickTarget` (validity) **and** `monsterAttackPermanent` (resolution).
   If only one is updated they disagree and the "shouldn't happen" branch fires.
   Suggest a single shared helper.
3. Repair already accepts Trophies (all trophy monsters are `isCreatureType:false`;
   `useRepair` rejects only creatures). No change needed.
4. Note Trophies do **not** receive the Wall Set +2 (`recomputeStoredDef` gates on
   `isCreatureType||atk_siege>0`) — confirm that's intended.

### Point 2 — Possession plug: **RULED** (closes the "monsters can never win" hole)
1. **Monsters skip possessed market slots** when choosing a target — the slot is
   already denied to the player, so there is nothing to gain by attacking it.
2. **A slot destroyed by monsters never returns and can never be possessed.**
   ✅ *Confirmed:* a Possession requires a live market position to attach to (the
   "possession placement identifier"). With no position, the Possession simply goes
   away — discarded outright. Destroyed slots never refill and can never host one.
3. **If only possessed slots remain, monsters RETURN TO PORTAL DEFENCE.** The player
   may then clear the Possession for a long-shot win. The instant a Possession is
   cleared, that slot becomes attackable again.

**Why this works (analysis):** rule 3 converts the plug from a player-favourable
lock into a **mutual stalemate**. Because portal exposure is binary, monsters
returning to portal defence *also* blocks the player's win path — neither side can
close. To win, the player **must** clear the Possession, which immediately reopens
the monsters' win path. Additionally, at 9/12 destroyed the player has **no economy
left** (Recruit + Building slots gone, remaining Conjuration slots possessed), so
they cannot build up during the stall — it becomes a genuine last stand fought with
the deck already in hand.

**Possession flavour/intent (designer):** Possessions are a **greed tax**, not a
monster attack — *"you are playing with magics you don't understand… oh no, you've
cursed the world state by being greedy."* This is why the player controls clearing
them and why they are never a monster target. Noted for later: Possessions **may**
be reworked into "a lighter version of monster attacks," but **not now**.

### Point 5 (taken early) — Portal Ward: **REJECTED — binary exposure is intended**
Designer: *"the portal is squishy. The defenders are in front of it. If they all
leave, and a player is able to take advantage of that moment, then great, they can
close the portal and win. It's probably going to take a lot of food to drop in a lot
of gear at that moment to have the attack power needed, so I say good for them."*

The skill test is **mustering burst ATK inside the window**, not grinding down a
fortified portal. The review's graduated-Ward proposal (7 + 2/guarding + 1/field) is
**off the table.** This ruling is also what gives Point 2 rule 3 its force.

⚠️ **Known tension to watch in playtest:** under permanents-primary, monsters leave
portal defence in the *ordinary* case, so the portal is exposed **most turns**, not
rarely. That risks collapsing the design into a pure race (player reaches 7 burst ATK
vs. monsters clear 12 slots) with no timing skill. The reinforcement-wave idea below
may be the natural corrective. **Target game length remains unset** and governs which
clock wins.

### IDEA (not ruled, not implemented) — Reinforcement wave
Game starts with 4 monsters (Ghoul known + 3 random). A shuffled deck of **4 more**
monsters may come through the Portal, **one at a time**, only when "all four monster
slots are open." Ambiguity flagged to designer:
- **(a) open = monster is dead** → reinforcements arrive only after kills; attrition
  loop, 8 monsters total. Doesn't address the always-exposed tension.
- **(b) open = nobody standing in portal defence** (all four in the field) → a
  reinforcement steps up to plug the gap, so the Portal defends itself and the
  "window" concept survives.

Also open: do reinforcements arrive **pre-unsealed**, or carry their own unseal
condition? With up to 8 monsters the trigger set matters considerably more.

### Point 3 (queued) — "Defence is anti-defence" targeting threshold
Confirmed in code: `beatable = active.filter(p => atk >= (p.currentDef||p.def||0))`.
A permanent whose DEF **exceeds** the attacker's ATK is filtered out of targeting
entirely, so the monster falls through to the markets. **Building tougher pushes
monsters onto your markets.** Interacts with the Trophy ruling: the Auspice **+1** can
lift a Trophy over an attacker's threshold, so optimal play can be to switch *away*
from your own Trophy's Auspice to keep it weak enough to keep soaking hits.
⚠️ Caution on the review's proposed fix (monster attacks the toughest permanent and
fails, wasting its action): risks a **free permanent stall** — one high-DEF wall
absorbs one monster every turn forever at zero repair cost. Generalizing the existing
**Wall Siege** (monsters combine ATK against something too tough) may be cleaner.

### Point 4 — Monster targeting: the three board states **RULED** ⭐ core rule
The phrase "no attackable permanent" covers three distinct states. They resolve
**differently** — this is the load-bearing rule of the whole mode:

| State | Board | Monster behaviour |
|---|---|---|
| **1** | No permanents at all | **RAZE** a market position |
| **2** | Permanents exist but **all Disabled** | **RAZE** a market position |
| **3** | A **standing (active)** permanent it cannot beat | **Retreat** to portal defence |

Designer: *"if all monsters are unlocked, they should raze market slots unless there
is a wall or other notion stopping them."* A **standing** defender turns monsters
away; a **smashed** realm is an undefended realm.

**Why this matters — it closes two exploits:**
- *Chump-block:* play one Farm, let monster 1 disable it, and under a naive
  "no valid target → retreat" rule monsters 2–4 would go home. **1 Food/turn would
  stall the entire game.** State 2 razing kills this.
- *Turtle vacuum:* if every state retreated, markets would never be razed at all and
  the monster win condition could never fire.

This makes **repair throughput** the real currency: you hold monsters off by keeping
defenders *standing*, not by owning wreckage.

### Point 4a — Wall Siege generalised beyond taunt Walls: **RULED (overrides §13B)**
Monsters may combine ATK against **any** too-tough permanent, not only taunt Walls.
Designer rationale: *"I think yes, because it plays to the player's success"* — the
monster response scales with the strength of the player's board.

⚠️ **This explicitly overrides the §13B must-not-regress entry** *"only taunt Walls are
siege targets."* That entry must be struck, or a future pass will revert it.

**Numerically validated (measured 2026-07-20):** max DEF that combat actually reads is
**18** (Familiar 4 + Retinue ×3 + Wall Sets ×4). Highest single monster ATK is **9**;
combined top-4 ATK is **31**. So a maxed board is immune to any *one* monster but
falls to a combined siege — the fortress line closes without touching any card.

### Points 6–13 — remaining decision-pass rulings
| # | Ruling |
|---|---|
| **6** | **Ghoul unseal** = 10 Food **spent on anything**, including Exchange conversions (Poison Room etc.). Excludes end-of-turn waste and Granary banking. Fires ~turn 2–3. |
| **7** | **Ghoul Famine passive** fires **every turn while Ghoul is alive**; lifts on his death. Designer accepts the Mode 3 overlap for now: *"get mad if we can't use our farms until we kill that guy."* ⚠️ Note this partially collapses Mode 1 into Mode 3 — revisit when "Survive the Famine" is built, and see Mode 3's own open question (breakable vs absolute lock), which this ruling effectively pre-answers as **breakable at the cost of an Auspice use**. |
| **8** | **Unseal trigger set: UNCHANGED for now.** 7 of 8 non-Ghoul triggers are player-elective; designer considers full lockout rare. Revisit if playtest shows dead games. |
| **9** | **Target game length ≈ 16 turns.** Track how often games run long. Designer has never seen the monster win condition fire. |
| **10** | **Market slot states:** not formalising exhausted-vs-razed yet. Run it and revisit. |
| **11** | **Telegraphing:** explained — deterministic raze order + a visible N/12 doom track, so the creep is legible rather than surprising. Designer wants to understand further before ruling. **STILL OPEN.** |
| **12** | **Simultaneous victory → PLAYER wins.** Rationale: Creeping Doom is currently an onboarding mode; it will later become the first step of a progressive difficulty ladder. |
| **13** | **Possessions** are wild-magic backlash — in fiction, kids learning conjuring who can't control it and let ghostly demons slip through. A **separate class** from portal monsters; they do **not** act on the monster turn. |

### Terminology — market position states (adopted)
- **Open** — live and purchasable.
- **Haunted** — holds a Possession. Player-clearable; monsters ignore it; blocks purchase.
- **Razed** — destroyed by a monster. Permanent, never refills, can never be Haunted,
  counts toward the monsters' 12.

### Ghoul Shaman reworked into a soft GATE (player test, 2026-07-21) — IMPLEMENTED
Replaces the parked Famine passive. Live in `connivances_simulator_v11.html`:
- **Unseal: 10 → 15 Food consumed** (revised down from an initial 20).
- **Ghoul no longer razes markets** — attacks player permanents only (farm-priority);
  retreats to Portal defence when he has no target. `decideMonsterAction` special-cases him.
- **While Ghoul is ALIVE, Conjuration purchases cost +1 Influence** (a TAX, not a lockout;
  revised from the first-pass "silence"). Applies from game start, on top of the normal
  Conjurer/Soothsayer/Noxious gate; never applied to a free Commander+Pikeman conjuration.
  Killing him (HP 4) removes it. Wired in `buyCard`, the render gate, and per-card cost/
  button display (shows the taxed number + 💀). Helper: `ghoulAlive()` / `ghoulConjTax()`.
- Intent: Ghoul becomes a **gate, not a doom-driver**, creating a two-tier purchase path
  (Siege/exchange ATK → kill Ghoul → cheaper creature/conjuration ATK). Doom rests on the
  3 random monsters.

**Tax-vs-silence note:** switching to a tax auto-resolved two flags the silence created —
(a) the **pure-creature-player wall** (they can still buy, just pay +1), and (b) **Noxious
Beast's unseal** ("2 Conjuration purchases") is reachable again while Ghoul lives (verified).

**⚠️ Remaining flags to watch in playtest:**
1. **Doom may go quiet early** — Ghoul (always position 1) razes nothing and Fiend
   (turn 3) is the only reliable early razer among the random three. Makes the tabled
   unseal-trigger reliability question load-bearing.
2. **Soft-lock tail** — 11/12 endgames converge on Haunted conjuration slots; the +1 tax
   (vs. the old silence) no longer *blocks* clearing/buying there, which softens it.
3. **"Keep Ghoul alive" line** on a Siege/Warrior build: the tax is cheap, and not killing
   anything keeps Nightmare/Dank Beast (kill-triggered) dormant. Intended counter: killing
   Ghoul *wakes* them if present. Confirm the trade feels right.
4. This is a **PLAYER TEST** — may revert. Flag `GHOUL_FAMINE_PASSIVE` still parked
   separately for the future "Survive the Famine" mode.

### V11 UNSEAL SET — full retune (designer, 2026-07-22) — IMPLEMENTED + boundary-verified
| Monster | New trigger | Was |
|---|---|---|
| Ghoul Shaman | **20 Food consumed** | 15 |
| Fiend | **Turn 8** | Turn 3 |
| Silent Stalker | **5 cards in Legend** | 3 |
| Minotaur | 4+ permanents *(unchanged)* | — |
| Nightmare | **4 Auspice changes** (game total) | a monster defeated |
| Gargantuan | **Library or Armory played** | a Wall played |
| Dank Beast | **A Conjuration summoned into play** | first monster defeated |
| Dragon | **🔒 HIDDEN — 25 Victory Points** | Legend ≥ 3 |
| Noxious Beast | **4+ unspent Food at turn end** | 2 Conjuration purchases |

**New trackers added:** `auspiceChangesTotal` (game-wide; the existing
`auspiceChangesThisTurn` still resets per turn for Necromancer),
`libraryOrArmoryEverPlayed` (also set on the Expediter straight-into-play path, which
would otherwise bypass it), `conjurationEverSummoned` (played into play, not merely
purchased). Noxious is evaluated during the monster turn, when `S.food` is exactly the
player's unspent leftover.

**Dragon is a HIDDEN unseal** — the UI must never name the 25 VP threshold. Hint reads
"??? — its waking is a mystery"; the fired message reads "your realm grew too proud."

**Measured effect:** doom-quiet games dropped from **4/10 → 1/12** — this retune solved
the M1 backstop problem organically (Fiend at turn 8 is wholly non-elective; Noxious,
Minotaur and Dragon all fire from ordinary play), so no crude turn-cap was needed.
Trade-off: first raze slid to ~turn 15.7 and monster win to ~turn 22 (designer:
**acceptable**).

### M2 — monster victory when no market can be purchased: **RULED + IMPLEMENTED**
**Superseded ruling (2026-07-25):** the earlier 3-turn "Last Stand" countdown is
**removed** — there was no real recovery path, so it was needless delay. New rule:
**the monsters win the moment every one of the 12 market positions is unavailable to
purchase from — i.e. each is Razed OR Haunted.** No grace period.

- Helper `allMarketsUnavailable()`; checked in `runMonsterTurn`'s victory step (fires
  every turn cycle, so it catches both raze-driven and possession-driven transitions).
- **Empty/exhausted (null) slots do NOT count** — they are razeable and get razed on a
  normal turn, so buying out a market deck can never hand the monsters the game
  (protects against the deck-exhaustion auto-loss the review flagged).
- **Recovery** exists implicitly: the player may clear a Possession on their own turn
  (reopening a slot) before ending it. Doom track now shows `🕯 haunted N`.

**Verified live:** 11 razed + 1 haunted → immediate monster win; all 12 razed → win;
11 razed + 1 empty → NOT an instant win (empty gets razed first, then win); normal
mid-game → no win; clearing the Possession → no win. `hauntedStallTurns` state removed.

### Repair Master (b2): +2 → +3 Influence (2026-07-25)
Designer buff. `inf:2 → inf:3`, effect text "+2 → +3 Influence." Cost (4) and
`repairCount` (1) unchanged. Verified: grants +3 on play.

### Warriors guild — market-gate rulings (2026-07-24) — IMPLEMENTED + verified
Designer rulings, live in `connivances_simulator_v11.html`:
- **W9 — Option C APPROVED:** any Warrior in play unlocks the **Siege** market (was
  Siegeman-only). Siegeman keeps its "+1 🔴 ATK per active Siege permanent" ability — it
  simply no longer needs to be the unlocker. A Warrior's building access is now exactly
  **Siege + Dojo, nothing else** (verified: Warrior cannot buy Walls, Library, Armory,
  etc.). Enforced in both `buyCard` and `isBuildingUnlocked`.
- **Walls require a Builder again:** `bg3` Walls, `bg6` Portcullis, `bg7` Fortress
  flipped `requiresBuilder:false → true`. **Farms stay always-open** (Tiered/Irrigated
  Field unchanged). ⚠️ MD §7 gate table lists Walls/Portcullis/Fortress as "Always open"
  — must be updated to "Builder" for all three wall-subtype buildings.
- **W1 — set-completion keying:** left as the **code's behaviour (two literal same-id
  cards)**; MD §5's "subtype" wording is the stale side and should be corrected to match,
  OR ruled the other way if the designer wants subtype pairing. Only affects the Armory
  3:1 rate / Dojo pricing, not gameplay gating. Low priority.

- **Option A — capped Dojo: IMPLEMENTED + verified (2026-07-24).** Dojo `bg8` repriced
  **12 → 10 Inf**; effect reworded to *"Each Warrior you played this turn may train:
  3 Influence → +1 ⚪ ATK."* New `useDojoTrain` / `dojoTrainsRemaining`; cap =
  `warriorsPlayedThisTurn` (includes Trainer-converted Farmers after the count fix);
  `dojoTrainsThisTurn` resets per turn. Verified: splash-prevention (0 warriors → 0
  trains — closes the old "any deck holds a Dojo" unlimited converter), cap honoured,
  Trainer-Farmers count, influence-bound, per-turn reset, and the anti-spike bound
  (no farm → Food 3 → ≤3 cards → ≤3 ATK; 4+ needs a farm already down; 7 from Dojo
  alone unreachable).
- **Trainer-Farmer count bug: FIXED + verified** (prerequisite for the above) — see
  `qa/TEST_PLAN.md`.

**The full Warriors package (A + C + gates + count fix) is now implemented and verified.**
Remaining Warriors follow-ups are doc-only: update MD §7 (Wall gates → Builder; Warrior
unlocks Siege) and §8C (Dojo cost/text), and W1's §5 wording. The Augury Mage mid-game
ATK request (AM-1) and the 7 contradictions from `cards/WARRIOR_GUILD_REVIEW.md`
(esp. Necromancer measurement, Possession market-type field) remain open, separate work.

### Winnability fix + power curve (2026-07-25) — IMPLEMENTED + verified
**Pressure layer (restores the intended 7-ATK bar; W13/W15):**
- **Ghoul no longer retreats to guarding** — once unsealed it `hold`s in the field
  (killable mid-game → trophy, drops the conjuration tax). Stops the 4-HP weld that made
  the real bar ~11 in one turn.
- **Fifth Protector** (revised reinforcement): a SINGLE random reserve monster, ONCE,
  arrives AWAKE + GUARDING as a pure final gate (`isFinalGuard`, never acts) the first
  time all four originals leave portal defence. Player kills it, then the Portal stays
  exposed and 7 ATK closes it next turn (two-turn split). Reserve reduced 3 → 1.

**Card layer (designer-approved; tcg-designer Addendum C), all live-verified:**
- **Blanket +1 to ATK-producing permanents:** Catapult 1→2, Trebuchet 2→3, Brood 1→2,
  Armored Hound 1→2, Familiar 1→2, Golem 1→2, Tiger 2→3, Gryphon 2→3, Sir Cluckles 1→2
  (data + printed text). **Trophies NOT bumped** (Dragon stays +3 — avoids double-dip;
  W16 = trophies are earned premiums). Applies globally incl. PvP (W18 accepted — it's a
  stat, not a mode rule).
- **Necromancer type BUGFIX:** was `atk_creature` (🟡, can't hit Portcullis) at both sites
  (`playCard` + `setAuspice`); now `atk_generic` (⚪) to match the printed text. Still flat
  (+1 ⚪ per Auspice change, ~2-3 ceiling — NOT the spike once feared; W17 = keep flat).
- **NEW — Vanguard** (Warrior recruit `w9`, cost 4): *"The Muster: if you played 3+
  Warriors this turn, +2 ⚪ ATK."* Binary threshold, capped at +2 — demands mass, can't spike.
- **NEW — Doomsayer** (Augury recruit `a9`, cost 4): *"The Hunter: each Augury Mage you
  played this turn gains +1 ⚪ ATK."* Gated behind the Hunter Auspice (Augury Initiate
  can't reach it) — the anti-spike + anti-Necromancer-stack gate.

Anti-spike bound confirmed for all: starter deck has 0 warriors/no early ATK; recurring
board ATK accumulates on disable-able permanents; new cards are threshold/gate-limited.
**Still HELD:** Siegeman count-scaling retune (pending W4/W9 — already ruled: Warriors
unlock Siege, so revisit). PvP untouched: Influence, Negotiator/Warlord multipliers, VP,
Legend, Dojo cap, draw/Auspice engines.

### Card bugfixes + influence retune (2026-07-25) — IMPLEMENTED + verified
**Bugs fixed:**
- **Attached recruit duplication** (Retinue/Meurtrière/Fortifier): `confirmAttach` copied
  the recruit into `attachedCards` but never removed its `S.played` copy, so at end of turn
  that copy *also* went to discard — 2 bought → 4, and its VP double-counted. Now the played
  copy is spliced on attach. Verified: 2 Retinue attached → 2 total after end of turn.
- **Handler buff lost on mid-turn heal:** Handler's per-creature +1 🟡 is a turn-long buff,
  but `grantMidTurnIncome` restored only base ATK. A creature Disabled when Handler was
  played (so excluded from Handler's play-time count) missed the +1 when later healed. Now
  `grantMidTurnIncome` adds `handlerBuffThisTurn` for creatures. Verified: disabled creature
  + Handler + heal → +3 (base 2 + Handler 1).

**Influence retune (per designer):**
- +2 → **+3**: Enforcer (c8). *(Witchdoctor a7, Repair Master b2, Conjure Master c9 already
  printed +3 — no change needed.)*
- +2 → **+1**: Cleric (c7), Exorcist (c6).

**R3 (MD item 25) IMPLEMENTED (2026-07-28):** a Familiar Disabled at start of turn skipped
its start-of-turn draw; healing it mid-turn now retroactively grants that draw
(`grantMidTurnIncome` draws 1 for `j3`). Cannot double-draw — grantMidTurnIncome only runs
for permanents disabled at turn start. Verified: disabled Familiar + heal → +1 card; empty
deck safe; non-Familiar creatures don't draw. **This closes R3 (was "ruled · not implemented").**

**Fortifier message clarified (design A kept):** Meurtrière→Walls, Fortifier→non-wall
buildings stays. Portcullis/Fortress are subtype Wall (Meurtrière's targets). The "no
eligible buildings" message now explains this instead of the misleading "all are disabled."

**Non-wall Set completion is now PLAYER-PROMPTED (2026-07-29).** Farm/Library/Armory sets
previously auto-paired the *first* eligible partner via `S.permanents.find` — denying the
player a choice that matters (e.g. playing Tiered Field with both Rice Field and Irrigated
Field in play auto-picked Rice for **no bonus**, when Irrigated gives **+2 Influence/turn**).
Now, with 2+ eligible partners, `checkSetCompletion` shows a picker (each option labeled
with the bonus it grants) — mirroring the Wall-bond picker; a single partner still
auto-pairs. Bonus-firing extracted into `formSetPair()` shared by both paths. Verified:
prompt appears, choosing Irrigated fires +2 Inf and leaves Rice unpaired; single-partner
auto-pairs with no prompt.

**Set-pairing REFINEMENT — timing lockout closed + re-pairing (2026-08-01).** The 07-29
version still let *timing* rob the choice: because a lone free partner auto-paired
silently, an earlier field could greedily consume the only partner (e.g. Rice+Tiered, a
**no-bonus** pair) before the bonus-carrying Irrigated arrived — and Irrigated then found
**no free partner**, so its +2 Influence was permanently wasted with no prompt. This is the
"I played Tiered and it auto-joined Rice, I wasn't allowed to choose" report. Fix in
`checkSetCompletion`: (a) candidates now include **already-paired** same-subtype
permanents as **↻ re-pair** options — choosing one dissolves its old pair to form the new
one, so timing can never lock you out of the optimal set; (b) silent auto-pair survives
**only** in the truly unambiguous case (exactly one same-subtype card in play, and it is
free) — every other situation prompts; (c) `formSetPair` now sets a per-permanent
`setBonusFired` flag so a broken-then-reformed partner cannot **re-fire** a one-time
bonus (closes a Library "Draw 2" break/reform exploit); freshly-played cards still get
their legitimate first-completion bonus. Verified live (4 scenarios): unambiguous
auto-pair preserved; late Irrigated rescued via re-pair; the exact user scenario now
prompts with `Irrigated — +2 Influence/turn` selectable; Library re-pair draws once, not twice.

### Point 2b — Walls do NOT protect market positions: **RULED**
Thematic basis (designer): *"the market is outside the walls — walls protect what
you own, not what is for sale."* Closes brief open-question #2 and prevents the
measured zero-pressure exploit from returning via an unbeatable Wall.

---

## D. Designer rulings captured verbally (not yet in any MD)

From the 2026-07-19 session — worth writing down so they survive:
1. **Attached recruit on host disable → discard** (now also confirmed by §13B Item 30).
2. **Enforcer "heal any creature in any field"** is a **multiplayer/PVP** feature —
   the owner may heal *another player's* Conjurations, to enable a barter /
   facade-of-cooperation dynamic. Single-player healing your own disabled creatures
   is the correct single-player projection. **Not a bug.**
3. **Silent Stalker flies** — confirmed; `fly:true` is correct.
4. **Opening hand = pure random 5 of 10.** The §12A.1 fixed hand is legacy test
   scaffolding (used to verify Legend + Farm behaviour). See B0 above.
5. **Swordsman spirit (confirmed 2026-07-20):** after Swordsman is played, **any**
   Warriors purchased that turn MAY go to **either** the discard pile **or** the top
   of the draw pile — **the player's choice**, per purchase, unlimited times per
   turn. This is what V11-3.3's picker implements (two explicit options, mandatory
   choice, fires on every qualifying purchase). Trainer-buffed Farmers count as
   Warriors for this, consistent with Trainer's rule.

---

## E. v11.6 Presentation & Systems layer (2026-08 → 09)

The v11.6 sim (`connivances_simulator_v11_6_4.html`) is now the canonical build. Almost
all of this cycle's work is **presentation, not rules** — noted here so the backup record
is complete. None of it changes card economy or win/loss logic.

**Card art + frame system (full portrait frames).** A kit-based card frame (`cf-card` /
`cardFrameHTML` / `monsterFrameHTML`) renders every card as a portrait with art window,
crest (VP), cost globe, DEF flame, guild ribbon, and category tag. Art loads from
`art/<id>.png` (embed-aware `window.ART_EMBED` for the single-file project build). The
`deliverables/` embedded HTML bakes all art in as base64 (Photoshop/CO M downscaled to ~512px).
Companion design docs: `card_frame_kit.html`, `art_style_bible.html`, `art_prompt_sheet.html`
(art direction = high-fantasy in a Japanese key). Full-res masters live in `simulator/art/`.

**Guild-colored borders (recruits) + green buildings.** Border encodes guild for recruits
(Warrior dull-pink `#c07d96`, Augury blue, Builder green, Farmer tan `#c2a066`, Conjurer red),
every Building green, Possessions dark-plum `#5c1836` with no banner + a "Possession" tag.
Ribbon labels corrected: Conjurer recruits say "Conjurer" (not "Creature"), Builder recruits
say "Builder" (not "Building").

**Farms carry no "Building" banner** (they were already always-open / no builder required;
this only removes the misleading ribbon). Subtype `Farm` → `cfGuildRibbon` returns null.

**The Portal is now a framed monster card** (was a bespoke mini-render) so it can show
`art/mn_portal.png`; "Non-Trophy" tab suppressed for it.

**Ghoul Shaman conjuration tax is now visible.** The +1 Influence tax (while the Ghoul lives)
was always applied in `buyCard` but the frame reskin had hidden it; conjuration market cards
now show the effective cost + a 💀 marker. Rule unchanged; nothing bypasses it except a free
(Commander+Pikeman) conjuration.

**Auspice art tiles + board mood theming.** The four auspices render as borderless landscape
art tiles (`art/aus_<id>.png`) with the effect text overlaid. The board's dark gutters + HUD
crossfade to an auspice-themed color when the auspice changes (`body[data-auspice]`).

**Layout / HUD.** Pinned resource HUD (Food/Influence/Attack/Legend/VP) at top; floating Event
Log pinned right; End Turn / New Game pinned above the log (spaced to avoid mis-restart);
vertical section order reworked. All CSS-`order` / fixed-position — no logic touched.

**New card — `a10` Seer (Augury Mage).** cost 3 inf, +2 Influence, "Reveal one hidden monster
seal condition." (Came in on the project-side v11.6 build; recorded here for completeness.)

**Randomized monster seals (V11.4) confirmed working.** Unseal conditions are dealt from a
shuffled pool (`buildSealAssignments`), decoupled from monster identity; Ghoul is pinned to
his 20-Food seal. Verified unbiased over 400-game sampling.

### Open / parked
- **Possession location.** Possessions carry "Nth Creature/Building/Recruit Possession" text
  but all live in the Conjuration deck, so they only ever haunt Conjuration slots — the
  Building/Recruit text is currently flavor only. Designer confirmed the intended rule:
  place each by its literal text (Building→Building market, Creature→Conjuration, Recruit→
  Recruit market). **Not yet built** — needs a location field + per-market routing + haunt
  handling in the Building/Recruit markets. See [[connivances-game-rules]].
