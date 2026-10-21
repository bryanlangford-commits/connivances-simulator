# Conjurer Tutorial. Possession-in-the-Market Mechanics ("The Summoner's Plight")

**Author:** tcg-designer · **Date:** 2026-09-18
**Mode:** `conjurer_house` ("Conjurer Training: The Summoner's Plight")
**Scope:** the CARD layer for Bryan's redesigned loop. Owns: the summon->possession
trigger, how possessions occupy the real conjuration market, the kill/dispel rules,
the anti-death-spiral escape valve, and card-pool changes with first-pass numbers.
**Not mine (handed off):** treant HP tuning, per-turn town damage, the doom clock,
and the market-fully-clogged loss/soft-retry (pve-pressure-designer); mode flow,
seer scripting, and win-screen framing (design-lead).

**Sources read:** `simulator/connivances_simulator_v11_6_4.html`
(`onManorSummon` 3010, `manorSpawn` 2983, `setupHouse` 2993, `attackPossession` 5546,
`dispelPossessionFromMarket` 5639, `attackHorseman` 2234, `attackCastle` 2882,
`mkMarket` 1064/3348-3350, `refill` 1065, `slotIsHaunted`/haunt counters 1319-1338),
`cards.json` (c1/c6/c7, j1/j3/j4/j7, f3/f4, p1/p3), `CONJURER_TUTORIAL_SPEC.md`,
`CONJURER_TUTORIAL_PRESSURE.md`, `cards/CONJURER_TUTORIAL_CARDS.md`,
`FACTION_IDENTITIES.md`.

---

## 0. What changes from the mode as built (read this first)

The shipped `conjurer_house` uses an **abstract 9-room manor** (`S.manor.rooms[]`) and
wins by **sealing the veil (6 banishes)**; the treant is art/lore only. Bryan's new
vision changes two load-bearing things, and BOTH are tensions the other two designers
must reconcile (see §8):

1. **Win moves to the treant.** The treant becomes a persistent HP boss (Horseman-style).
   The player wins by driving its HP to 0 with summoned-creature ATK. "Seal the veil /
   banish 6 times" is **no longer the win**; banishing is now the tempo tax you pay to
   keep summoning.
2. **The obstacle becomes the real market.** Possessions no longer live in abstract
   rooms; they spawn **into the live `S.conjurationMarket`** and occupy slots, exactly
   like the main game. This makes the tutorial genuine first-contact with the shipped
   possession system instead of a bespoke room grid.

Everything below specs the card layer for that loop. It reuses `attackPossession`,
`dispelPossessionFromMarket`, and `refill` unchanged; it needs a new `attackTreant`
(a clone of the `attackHorseman` HP-drain pattern) which is design/engine glue, not a
card. The abstract room machinery (`manorSpawn`/`manorHauntedCount`/rooms) is retired.

---

## 1. THE TRIGGER. "The veil holds once per turn" (per-turn safe-summon budget)

**Recommendation: a per-turn summon budget, not a running meter.** Of Bryan's three
options (running Nth-summon meter / first-few-safe / per-turn budget) the per-turn
budget is the most teachable because it is a **repeatable rule the player can obey every
turn**, and it hands the player a guaranteed clean line (see §5). A running meter teaches
"summoning has a vague cumulative cost"; a per-turn budget teaches the exact discipline
the faction is about: *don't gorge on wild magic in a single breath.*

**The rule:**

- Each turn you get **one SAFE summon**. The **first Creature you summon each turn**
  parts the veil and it closes cleanly. No backlash.
- The **second and every further Creature summoned the same turn TEARS the veil**:
  each one immediately **spawns one Possession into the conjuration market** (§2).
- **Spells do not count and never backlash.** `j4 Empowered Spell Book` is a Spell; it
  builds no body and reaches through the veil for nothing living, so it is always safe.
  Only `subtype:"Creature"` summons consume the safe-summon and can trigger backlash.
  This preserves the "creatures are the wild magic" flavor cleanly.

**The scripted opening beat rides on top of the rule, once.** To keep design-lead's
authored lull-then-betray (spec §3/§4), the **3rd Creature summoned in the whole game**
force-spawns the first possession even if it was that turn's safe summon. That is the
one-time "it goes wrong." From the next summon on, the plain per-turn rule governs.
So: summon 1 and 2 are pure dopamine; summon 3 is the authored crack; after that the
player is playing the real system.

**Why this is fair and legible:**
- Deterministic. No coin flips. The player can always predict the next possession.
- A visible one-line HUD state does all the teaching: `Veil: SAFE SUMMON READY` vs
  `Veil: SPENT. next Creature this turn tears it (+1 possession)`. This replaces the
  `+2 creature / +1 spell, threshold 5` instability meter in the built code.
- The player who wants to ramp faster **can** summon twice or thrice in a turn; they just
  pay in possessions. That is the risk/reward dial, made explicit and self-inflicted.

---

## 2. POSSESSION MARKET OCCUPATION

Possessions spawn into and occupy the **live conjuration market**, reusing the shipped
possession-in-slot machinery.

- **It REPLACES the card in an open slot** (does not stack on top, does not raze). Pick a
  random slot that currently holds a real Conjuration (not already a possession, not
  empty). Overwrite that slot with the possession card object (`isPossession:true`).
  **Send the displaced Conjuration to the BOTTOM of `conjurationDeck`** so it is not lost;
  it can cycle back after the slot is cleared and refilled. This matches how `refill`
  already treats the deck as a queue.
- **A possessed slot is unavailable.** You cannot buy or summon-source that slot until it
  is cleared. The market renderer already draws possessions distinctly and swaps the buy
  button for Attack/Dispel (5425-5517), so no new UI verb is needed.
- **Only the conjuration market can be clogged.** Possessions never touch the recruit
  market. This is deliberate and load-bearing: the **recruit market stays clean so the
  Exorcist (the escape valve, §5) is always purchasable.** The tutorial has no building
  market in play, so conjurations are the only cloggable row; fiction holds ("your own
  summoning school is infested").
- **Slot count / how many can be lost:** run the conjuration market at **4 slots** for
  this mode (up from the default 3 at `mkMarket(...,3)` line 3350); recruit stays 6. Four
  gives a legible clog bar and a real near-miss without instantly reaching the loss state.
  Losing **all 4** conjuration slots is the "market overtaken" condition; the response
  (soft-retry vs terminal) is **pve-pressure-designer's** call, mirroring the existing
  `allMarketsUnavailable()` idea scoped to this one row.
- **Concurrent cap = the slot count (4).** A hard cap is mandatory so an ignored
  infestation cannot spill past the market and so the loss state is reached only by
  genuine over-summoning, never by a single unlucky turn.

---

## 3. KILL / DISPEL (reuse existing verbs; no new removal code)

Two live paths, both already implemented, both operating on the same conjuration-market
slot:

1. **BRUTE BANISH. `attackPossession(uid)` (5546).** Spend the creature-ATK pool; if
   total ATK >= possession DEF, the possession is cleared and `refill` restocks the slot.
   **This spends the exact ATK you would otherwise throw at the treant.** That shared pool
   is the whole tension (§5); a banish is a turn you did not hit the boss.
2. **CLEAN DISPEL. `dispelPossessionFromMarket(uid)` (5639).** Requires an **Exorcist**
   (c6) played this turn; clears one possession **for free, no ATK spent**, one dispel per
   turn (`exorcistDispelUsedThisTurn` already gates it). This is the escape valve: it
   removes a possession **without taxing your treant damage.**
3. **CLERIC assist (c7).** Its live effect is **+2 generic ATK vs Possessions only**
   (applied inside `attackPossession`, 5554-5556). It makes a brute banish cheaper but
   does **nothing against the treant**, which correctly keeps it a cleanup tool, not a
   damage tool.

Teach order (unchanged from `CONJURER_TUTORIAL_CARDS.md` §6): Exorcist dispel first (the
surgical, faction-signature answer), brute ATK + Cleric second (the always-available
fallback).

**Anti-farm carries forward (mandatory).** The main-game possessions p1-p7 grant 2-3 VP
and draw 2-3 on defeat; instantiated repeatedly by a spawner that is now infinite, that is
an unbounded VP + card engine (documented in `CONJURER_TUTORIAL_CARDS.md` §5). Tutorial
possessions therefore spawn from a **neutered template: DEF 3 (later 4), VP 0, no
on-defeat draw, no Legend-send, no auspice HP buff**, wearing a p-series name/art for
flavor only. The only reward is the single scripted "draw 1" on the very first banish.

---

## 4. THE TREANT (card-layer interface only; HP tuning is pve's)

- The treant is an HP boss on the `attackHorseman`/`attackCastle` pattern: an
  `attackTreant()` that drains the player's creature-ATK pool into treant HP and zeroes
  the spent pool, exactly as `attackHorseman` does (2239-2241).
- **Wounded by Creature ATK (🟡) only.** Conjurer summons are the counter, matching the
  Horseman "War" precedent ("wounded only by 🟡 Creature ATK; Conjurers", cards.json
  3030). This keeps farmers as economy and keeps Cleric/Exorcist as cleanup, so the ONLY
  way to hurt the boss is the summoned army; summoning is genuinely the taught skill.
- **Win = treant HP 0** -> `S.portalDefeated=true; S.gameOver=true;` success overlay, in
  the `attackCastle` keep-fall pattern (2901-2903).
- **The core decision each turn:** your creature-ATK pool is one resource with two claims
  on it, the treant and the clogged market. That single shared pool is the entire
  risk/reward engine; do not give the treant and the possessions separate damage types.

---

## 5. ANTI-DEATH-SPIRAL. The guaranteed out, with proof

The mode must never trap a learning player. Three independent escape valves, in priority
order:

1. **The safe summon is a clean line by itself.** A player who summons **exactly once per
   turn never spawns a possession at all.** Their whole game is a pure treant race with an
   uncluttered market. This is the floor guarantee: competent play cannot lose to the
   possession mechanic, only to the treant clock (pve's to keep beatable). The tension is
   opt-in; the player clogs the market only by choosing to gorge.

2. **Exorcist dispel out-paces throttled spawns.** If a player over-summoned and clogged
   slots, the recovery loop is: throttle to the 1 safe summon (0 new possessions) and
   dispel 1 for free each turn (no ATK spent). Net -1 possession/turn with zero cost to
   treant damage. Because the recruit market is never cloggable (§2), Exorcists are always
   buyable, so this cadence is always reachable. Add a brute banish when ATK is spare and
   recovery is -2/turn.

3. **Guaranteed gift cadence (setup lever, design-lead owns the exact timing).** Seed an
   Exorcist in the opening hand (the built `setupHouse` already gifts `c6`, line 3003) and
   drip one more when the clog crosses ~75% of slots (3 of 4), mirroring the existing
   `manorGift('c6')` mercy at line 3042. This makes valve #2 available even to a player who
   never bought their own Exorcist.

**No decay.** Deliberately not adding "possessions fade on their own"; it teaches the wrong
lesson ("the problem solves itself") and undercuts the discipline the mode exists to teach.
The safe-summon valve + Exorcist cadence is a sufficient and more honest out.

**Worked winning line (disciplined player; assumes treant HP 15, Brood = 2 creature ATK):**

| Turn | Action | Treant HP | Market possessions | Note |
|---|---|---|---|---|
| 1 | Summon Brood (safe). Attack treant 2. | 13 | 0 | Pure dopamine. |
| 2 | Summon Brood (safe). Attack treant 4. | 9 | 0 | Omen telegraph. |
| 3 | Summon Familiar (safe) -> **scripted crack**: +1 possession. Attack treant 6. | 3 | 1 | Authored "it went wrong." |
| 4 | Summon Brood (safe). Dispel the possession (free). Attack treant 8. | **dead** | 0 | Escape valve shown; win. |

Efficient players close in ~4-5 turns; a wobbler who over-summons stretches longer but the
valves guarantee recovery. **Constraint handed to pve:** recovery from a full 4-slot clog
takes ~2-3 throttled turns; the treant clock must leave at least that much slack before its
town-loss fires, or the "survivable near-miss" promise breaks.

**Losing line (the lesson):** a player who summons 3 Creatures every turn spawns 2
possessions/turn, out-running any dispel cadence, and clogs all 4 slots in ~2 turns ->
market overtaken -> pve's soft-retry, taught explicitly. Over-summoning is the mistake the
mode is built to surface.

---

## 6. CARD POOL. Confirmation and changes

**The lean conjurer + farmer pool supports the loop with NO new card required.** Mapping:

| Need | Covered by | Notes |
|---|---|---|
| Unlock conjuration market | **c1 Conjurer's Aid** (isConjurer, +2 inf) | Lesson 1; seeded in hand. |
| Treant damage / army | **j1 Brood** (2 🟡, DEF 2), **j3 Familiar** (2 🟡, DEF 4, draw), **j7 Golem Defender** (2 🟡, team +2 DEF) | ~2 recurring creature-ATK each; the boss counter. |
| Controlled (safe) summon | **the per-turn budget itself** | No card needed; the 1st Creature/turn IS the controlled summon. |
| Reliable free banisher | **c6 Exorcist** (free dispel, 1/turn) | The escape valve; recruit market keeps it always buyable. |
| Brute banish assist | **c7 Cleric** (+2 vs Possessions) | Cheaper brute banish; useless vs treant (intended). |
| Economy to afford summons | **f3 Agriculturist** (+2 inf/+2 food), **f4 Reaper** (+2 inf/+1-2 food) | Broods cost 5 inf/1 food; farmers fund the curve. |
| Card flow | **j3 Familiar**, optional **j4 Empowered Spell Book** (draw 2, always safe) | Keeps the summon engine fed. |

**Do not feature** c2/c3/c4/c5/c8/c9 or j2/j5/j6/j9/j10; each adds an orthogonal mechanic
that dilutes the two lessons (per `CONJURER_TUTORIAL_CARDS.md` §3). Stays inside the
no-market-unlock scope: Conjurer + Farmer only.

### Required text/stat tweaks (not new cards)

1. **Possession spawn template (tutorial instances only), exact block:**
   `{ isPossession:true, cost:0, def:3 (first 3 spawns) / 4 (later), vp:0, drawOnPlay:0,
   onDefeatLegend:false, onUndeadRising:false, auspiceBuffHP:0, name/art cycled from
   p1-p7 }`. This is a spawner template, not an edit to the canonical p1-p7 rows in
   cards.json; the shipped possessions keep their main-game values.
2. **Conjuration market size 4** for this mode (mode parameter at the `mkMarket` call, not
   a card stat; keeps §12A fidelity since no card's printed stats change per mode).

### Optional new card (ship ONLY if playtest shows the market clogs faster than the pool clears)

Contingency insurance, not a launch requirement. If the race math is ATK-starved because
brute-banishing steals too much treant damage, add one cheap Conjurer conjuration that
doubles as a controlled clear:

> **Ward-Brood** (Conjuration, Creature, Brood). Cost 4 inf / 1 food. `atk_creature 1`,
> DEF 2, VP 0.
> *Effect1:* "+1 🟡 ATK. DEF 2."
> *Effect2:* "When summoned, banish one Possession in the conjuration market for free
> (no ATK). Does not consume your safe summon."
>
> It is a weak body (1 ATK, so it barely helps the treant) whose real job is a scheduled,
> summon-triggered dispel that does not eat the safe-summon budget; a self-serve escape
> valve if the Exorcist cadence proves too thin. Its VP 0 and tiny ATK keep it from
> warping the main game if it ever leaks out of the tutorial pool. **Default: do not
> ship; the Exorcist + safe-summon valves should suffice.**

---

## 7. FIRST-PASS NUMBERS (playtest-tunable)

| Parameter | Value | Owner / note |
|---|---|---|
| Safe summons per turn | **1** (Creatures only) | tcg. The core throttle. |
| Backlash per extra Creature summon | **+1 possession** | tcg. |
| Spell summons (j4) | never backlash, never consume the safe summon | tcg. |
| Scripted first crack | on the **3rd Creature summoned in the game** | tcg + design-lead beat. |
| Conjuration market size | **4** slots | tcg (mode param). |
| Cloggable rows | conjuration only (recruit stays clean) | tcg. |
| Possession DEF | **3** first three spawns, **4** later | tcg. |
| Possession VP / rewards | **0 / none** (except first-banish draw 1) | tcg (anti-farm). |
| Concurrent possession cap | **4** (= slot count) | tcg. |
| Exorcist dispel cadence | **1 free/turn per Exorcist played** | reuse c6. |
| Cleric assist | **+2 ATK vs Possessions only** | reuse c7. |
| Treant HP | **~15** (starting guess) | **pve** owns final; assume ~2 ATK/creature. |
| Treant wounded by | **Creature ATK (🟡) only** | tcg fiction / boss interface. |
| Treant town-damage / doom clock | **pve** | must leave ~2-3 turns of clog-recovery slack. |
| Market-overtaken (all 4 clogged) response | soft-retry vs terminal | **pve** decides. |
| Mercy Exorcist gift | at ~3 of 4 slots clogged | reuse `manorGift('c6')` pattern. |

---

## 8. Tensions to reconcile (surfaced, not silently resolved)

1. **Win condition moved.** Design-lead's `CONJURER_TUTORIAL_SPEC.md` §5 and
   pve's `CONJURER_TUTORIAL_PRESSURE.md` §2 both make the win **"seal the veil = 6
   banishes,"** with a VEIL SEAL 0->6 meter as the player's win bar. Bryan's new vision
   makes the win **"kill the treant (HP 0)"** and demotes banishing to a tempo tax. These
   cannot both be the win. My card layer assumes **treant-kill is the win**; design-lead
   and pve must retire the seal-meter-as-win (it can survive as flavor, or be cut). Flagged
   for the design-lead's structure pass.

2. **Obstacle moved from abstract rooms to the real market.** Both existing docs and the
   shipped code use a **9-room `S.manor` grid** as the doom surface. This spec deletes that
   and uses the **live 4-slot conjuration market**. pve's spread curve (§1 of their doc:
   `h=1-3 -> +1/turn`, `h>=4 -> +2/turn`, doom at 9 rooms) must be **re-scoped to 4 market
   slots**, and pve should decide whether time-driven ambient spread still exists at all
   now that clogging is purely summon-driven. My recommendation: keep spawns
   **summon-driven only** (cleaner cause->effect for a tutorial); if pve wants an ambient
   floor to prevent turtling, cap it hard given only 4 slots exist.

3. **Treant HP vs shared ATK pool.** Because banishing and hitting the treant draw the same
   pool, treant HP must be tuned **with the expectation that some turns are spent banishing
   instead of attacking.** ~15 HP is my starting guess assuming ~2 ATK/creature and a couple
   of banish-turns; pve should confirm against their clock.

4. **Faction fidelity: confirmed.** `FACTION_IDENTITIES.md` states possessions are the
   Conjurer's **own wild-magic backlash**, not external portal monsters. The
   summon->possession trigger and the "your own market gets infested" framing honor that
   exactly; no conflict.
</content>
</invoke>
