# Conjurer Tutorial. Card-Layer Spec ("The Haunted Manor")

**Author:** tcg-designer · **Date:** 2026-09-13
**Scope:** the CARD layer only; summon mechanic, featured card list, the
possession spawn/stat model, banish mechanic, and combo/degenerate prevention.
Structure/flow is design-lead's; the doom clock, monster-turn behaviour, and any
loss state are pve-pressure-designer's. I have deliberately kept the taught set
minimal and reused existing cards + existing engine hooks wherever possible.

**Sources read:** `simulator/cards.json` (single source of truth for card data),
MD v2.2 §7 (gates), §8 POSSESSIONS block + destruction rules, §8E, §9 schema,
§12A/§13 fidelity; `MD_UPDATE_QUEUE_v2_3.md` (esp. C2 Point 2 possession plug,
Point 13, "Possession location" open item, R1 Cleric choice economy, V10-EXOR
dispel, influence retune Cleric/Exorcist +2→+1); `FACTION_IDENTITIES.md`
(Conjurers = summon permanents; possessions = built-in wild-magic risk).

> ⚠️ **Two framing corrections to the brief; surfaced, not silently resolved:**
> 1. The brief says *"c5 Teramancer waives"* the Conjurer-to-acquire gate. It does
>    not. **Every** Conjurer recruit (c1–c9) unlocks the Conjuration market by its
>    `effect1 "Unlocks Conjurations"`. The card that *waives the Conjurer requirement
>    entirely* is **Soothsayer (a4, Augury Mage)** under the Mystic Auspice, plus the
>    Noxious Beast trophy and the Commander+Pikeman free-conjuration combo. Teramancer
>    is just a Conjurer that is *also* a Farmer (`isFarmer:true`). The tutorial should
>    teach the normal gate (play any Conjurer → market unlocks) and must **not**
>    introduce the waive; it is an advanced interaction.
> 2. The brief lists possession DEF as "3–5, VP 2–3, cost 0, on-defeat rewards."
>    That is the **main-game** balance, which depends on each of p1–p7 being a
>    **unique, once-each** card. The tutorial should **not** import that reward
>    economy (see §5, anti-farm). Tutorial possessions are stripped obstacles.

---

## 1. Q1. Procedural spawn vs. fixed 7-card pool → **AGREE: spawn procedurally**

Treat the 7 possessions (p1–p7) as **flavour templates** that a mode spawner
instantiates on demand, cycling/repeating as needed. Do **not** draw them from the
fixed conjuration deck for this mode. Reasons, card-design first:

- **A scripted "it goes wrong" beat cannot ride on shuffle variance.** The whole
  point of the tutorial arc is a *deterministic* lull-then-break. Drawing real
  possessions off the top of a shuffled conjuration deck makes the break time
  random; sometimes turn 2, sometimes never. Procedural spawning is the only way
  to guarantee the beat lands.
- **Pool size < haunt targets is real** (Bryan's flag). 7 uniques vs. up to 12
  market positions (6 Recruit + 3 Building + 3 Conjuration). "Overtaking the
  market" is impossible with 7 one-of cards. Templating removes the coupling -
  spawn count is now a mode parameter, not a deck-census artifact.
- **The main-game reward economy is balanced on uniqueness and MUST NOT be reused
  as-is.** p1–p7's on-defeat payoffs (draw 2/3, move-to-Legend, Undead Rising's
  triple-play) and their 2–3 VP are tuned for a card that appears **once per game**.
  Instantiating multiple copies turns every one of those into a repeatable engine
  (see §5). Procedural spawning lets us hand the spawner a **neutered** stat block
  while keeping the p1–p7 art/names for flavour.

**Is there a card-design reason to keep them as real market cards? No; and one
against.** The only thing a "real card" buys you is the host→bottom-of-deck
interaction and the once-each rewards; both are things we *want to strip* for a
tutorial. Keeping them real would also collide with the still-open "Possession
location" routing work (MD queue E, Open/parked) that isn't built yet. Procedural
is cleaner, safer, and buildable in one HTML mode.

**Consistency note:** this matches the designer's own C2-Point-13 ruling
("Possessions are a separate class; they do not act on the monster turn") and the
Point-2 plug (monsters ignore haunted slots). A mode-spawned tutorial possession
is the same *kind of actor* as the Minotaur/Risen/Blight mode actors Bryan cites -
it just wears a p1–p7 skin.

---

## 2. Q2. The summon-backlash mechanic → **a visible "Veil Instability" meter**

Reject the coin-flip (feel-bad, unteachable, unfair on a first play) and reject a
pure hidden "every Nth summon" counter (invisible cause→effect teaches nothing).
Use a **single visible meter** whose increments *are* the "every Nth summon" rule,
so it is deterministic **and** legible.

**The rule (this is the whole mechanic):**

- A **Veil Instability** track, shown on the HUD, starts at **0**.
- **Summoning a Conjuration raises it:** creature summon **+2**, spell summon **+1**.
  (Creatures are the "wilder" magic; spells are safer; a small teachable nuance.)
- **Threshold = 5.** The instant Instability reaches ≥ 5, a possession **spawns**
  (see §4) and Instability drops by 5 (carry the remainder, so momentum persists).
- The meter is **telegraphed**: at 3–4 the HUD shows a "The veil strains…" warning,
  so the break is *foreshadowed*, never a surprise; exactly the legibility the
  designer wants for the doom track (MD queue C2, Point 11).

**Why this produces the exact arc Bryan asked for:** summon #1 (creature) → 2,
summon #2 → 4 (lull, player feels powerful, warning glows), summon #3 → 6 ≥ 5 →
**first possession spawns, "it goes wrong"**, meter resets to 1. Every 2–3 summons
thereafter breaks the veil again → the market "gets overtaken." No scripting of
the trigger is required; tuning the increments and threshold *is* the script.

**Optional mitigation (teaches that the removal cards also prevent):** playing an
**Exorcist or Cleric** may "steady the veil," **−2 Instability** on play. This
gives the player agency and ties lesson (a) summoning to lesson (b) removal in one
loop. Safe against farming because tutorial possessions carry no reward (§5). Ship
this only if UI budget allows; the core mechanic stands without it.

**Fairness properties:** fully deterministic, fully visible, foreshadowed, and the
first two summons are *always* safe; the player is rewarded for engaging before
they are taught the risk. That is textbook tutorial pacing.

---

## 3. Q3. Featured cards + gating (keep the taught set minimal)

### Summonables (Conjurations); 3 cards, one of each "shape"
| id | Card | Cost | Stat | What it teaches |
|---|---|---|---|---|
| **j1** | Brood | 5 | 2 🟡 / DEF 2 | The basic body. Cheapest creature → the **first summon**. Doubles as your first anti-possession attacker (2 🟡 counts against a possession's DEF). |
| **j3** | Familiar | 6 | 2 🟡 / DEF 4, draw engine | Summons can have **ongoing effects** (draw on play + start-of-turn draw). Teaches "keep your summon alive." Its DEF 4 also survives the early board. |
| **j7** | Golem Defender | 7 | 2 🟡 / DEF 4, **team +2 DEF** | The **defensive** summon: shows summons can protect each other, and its +2 DEF helps your board weather the infestation beat. *Optional / stretch; drop first if trimming.* |

Rationale: j1 → j3 → j7 walks basic body → effect creature → support creature,
which is the whole "summoning creatures/permanents" lesson in three cards. Skip
Gryphon/Tiger/Sir Cluckles (cost 8–10, flying/brood-lord nuance; main-game depth,
not tutorial). Include **one spell** only if design-lead wants the spell/creature
Instability distinction to be felt: use **j4 Empowered Spell Book** (6, draw 2) -
it is the cleanest, no Auspice side-effects (unlike j5 Dark Magic's Famine flip).

### Removal / cleanse; center Exorcist + Cleric (confirmed as the removal cards)
| id | Card | Cost | Role in tutorial |
|---|---|---|---|
| **c6** | Exorcist | 3 (inf **1** post-retune) | **The primary lesson.** Free "🧿 Dispel" on a market possession; no ATK cost, host **survives** and stays purchasable, one per turn (existing V10-EXOR hook). The clean, faction-signature removal. |
| **c7** | Cleric | 3 (inf **1** post-retune) | **The fallback lesson.** Per R1 choice economy, each Cleric grants one use = **+2 ATK vs Possessions**. Teaches "if you have no Exorcist, buff your attack and *kill* the possession by DEF." |
| **c1** | Conjurer's Aid | 3 | **The gate-opener.** Cheapest plain Conjurer; its `effect1` unlocks the Conjuration market. This is lesson 1 (see gating). |

Do **not** feature c2 Sacrificer, c3 Handler, c4 Retinue, c5 Teramancer, c8
Enforcer, c9 Conjure Master in the tutorial; each adds an orthogonal mechanic
(Legend send, per-creature ATK, attach, Farmer dual-identity, cross-field heal,
scaling) that dilutes the two lessons. They remain in the full game.

### Gating (teach the normal gate; no waives)
- **Conjuration market is locked until the player plays a Conjurer recruit this
  turn** (MD §7). Lesson 1 = *buy & play **Conjurer's Aid** → the Conjuration
  market lights up → summon your first Brood.*
- Give the player one **Conjurer's Aid in the opening setup** (or make buying it
  the first guided click) so the first summon is frictionless.
- **Do not** introduce Soothsayer/Noxious/Commander-Pikeman gate bypasses, the
  Ghoul conjuration tax, or Teramancer's Farmer identity. All are advanced.
- Summoning cost is unchanged from the data (Brood 5, Familiar 6, Golem 7); the
  tutorial's economy scaffolding (starting Influence/Food) is design-lead's lever,
  not a per-card rewrite (keeps §12A fidelity: no card whose stats differ per mode).

---

## 4. The possession spawn/stat model (tutorial instances)

Spawner instantiates a **stripped template**. NOT the p1–p7 data block. Flavour
(name/art) cycles through the p-series; stats are fixed by the table below.

| Field | Tutorial value | Why it differs from main-game p1–p7 |
|---|---|---|
| `isPossession` | true | Reuses all existing possession UI/attack/dispel hooks. |
| `cost` | 0 / not purchasable | Same as main game. |
| **DEF** | **3** (first two spawns), **4** (later spawns) | Escalates gently. DEF 3 is beatable by one Brood (2 🟡) + one Cleric use (+2) = 4 ≥ 3, or a free Exorcist dispel. |
| **VP** | **0** | **Anti-farm (see §5).** Main-game 2–3 VP would make banishing a free VP faucet. |
| **On-defeat reward** | **none** (except the scripted first-banish "draw 1" teaching beat) | Main-game draw-2/3 / move-to-Legend rewards are the farm engine; strip them. |
| Auspice buff (+1 DEF) | **off** for tutorial | Removes an invisible stat swing a new player can't reason about. |
| Attacks player? | **no**; passive blocker only | Matches C2-Point-13 ("do not act on the monster turn") and the "greed tax" framing. |

**Spawn location + escalation (the "overtake"):** spawn into an **open market
slot**, prioritising **Conjuration → Building → Recruit** in that order. Starting
in the Conjuration market keeps the fiction tight ("your own summoning school is
infested"); bleeding into Building/Recruit as Instability keeps breaking is what
sells "the possessions are overtaking the market." This sidesteps the unbuilt
"Possession location routing" work (MD queue E); the *spawner* picks the slot, so
no per-card location field is needed.

**Spawn cap:** **max 3 concurrent** haunted slots (4 if design-lead wants a
tenser climax). A hard cap is essential: without it the meter would eventually
haunt every slot and trip the main-game `allMarketsUnavailable()` monster-win -
which must **not** fire in an onboarding tutorial. The cap keeps the infestation
*scary but survivable*. Loss-state handling belongs to pve-pressure-designer; from
the card side I only require that a full-market lock is **unreachable** here.

**Banish → refill:** on banish, the slot refills normally. Because these are
mode-spawned (no real host card), a **brute-ATK** banish simply clears the slot
(no host to send to bottom-of-deck); an **Exorcist dispel** clears it identically
but is free and one-per-turn. See §6 for the teaching distinction.

---

## 5. Q4. Combo / degenerate prevention

**Yes, there is a real farm exploit if p1–p7 are imported as-is.** With cost-0
possessions that (a) carry 2–3 VP, (b) draw 2–3 on defeat, and (c) can be spawned
repeatedly by summoning, the loop is:

> summon (cheap) → Instability crosses → possession spawns → banish it → **gain 2–3
> VP into Legend + draw 2–3 cards** → the extra cards/economy fund the next summon →
> repeat.

That is an unbounded VP + card-advantage engine, and procedural spawning (§1) makes
it *worse* than the main game because supply is infinite. The uniqueness of p1–p7 is
the main game's natural cap; the tutorial has no such cap, so we must impose one.

**The cap (all three, together):**
1. **Tutorial possessions grant 0 VP.** They do not enter the player's Legend as
   scoring cards; on banish they are exiled. Kills the VP faucet.
2. **No on-defeat card draw** (except a single, scripted "draw 1" on the *first ever*
   banish, purely as the teaching reward). Kills the card-advantage engine.
3. **Meter ratchets, banishing does not rewind it below its floor.** Clearing a
   possession never *reduces* Instability (only Exorcist/Cleric *play* does, and only
   −2, §2). So a player cannot summon→banish→summon in a safe steady state to farm;
   each summon still pushes toward the next break.

With rewards at zero, every loop is net-negative in tempo (you spent a summon and a
removal action to clear an obstacle worth nothing); which is precisely the "greed
tax" the designer intends. Nothing to farm.

**Second-order checks:**
- **Instability from spells (+1) vs creatures (+2):** confirmed non-exploitable -
  spells cost 6+ and produce no board, so "spam cheap spells" is not a cheaper path
  to anything.
- **Exorcist dispel is already one-per-turn** (`exorcistDispelUsedThisTurn`); reused
  as-is, so no new per-turn-limit code.
- **Cleric R1 choice economy is already capped** at one use per Cleric; reused as-is.
- **Spawn cap (§4)** prevents a runaway board even if the player ignores everything.

---

## 6. Q5. The banish mechanic → **teach Exorcist first, ATK second**

Both live paths are correct Conjurer removal; teach them in this order because it
maps onto "the faction has a *clean* tool, and a *brute* fallback."

1. **Exorcist dispel = the headline lesson (surgical).** Free 🧿 Dispel button on a
   market possession, host survives, one per turn (V10-EXOR). This is the
   faction-signature answer and the emotional beat: *"you summoned the problem; the
   Exorcist is how a Conjurer cleans up after wild magic."* First spawned possession
   → guide the player to buy/play an Exorcist and dispel it.
2. **ATK + Cleric = the fallback lesson (brute force).** Possessions have DEF; you
   can also just **kill** one by spending ATK ≥ its DEF (existing attack path,
   generic→siege→creature order). Cleric adds **+2 ATK vs Possessions** per use, and
   your summoned **Brood (2 🟡)** can chip in; so the player learns their *summons
   double as anti-possession weapons.* Second spawned possession (no Exorcist in
   hand) → teach: play Cleric (+2) + attack with Brood (2) = 4 ≥ DEF 3 → banished.

**Why this ordering teaches Conjurer removal best:** it introduces the dedicated,
cost-free, host-preserving tool as *the answer*, then reveals the general combat
route as the *always-available* backstop, and in doing so demonstrates the payoff
difference (Exorcist keeps the market card; brute force in the main game would cost
you the host; worth a one-line callout even though tutorial spawns have no real
host). The player leaves understanding *why the Exorcist is worth a slot.*

---

## 7. Buildability checklist (one HTML mode, reuses existing hooks)

- **Reused as-is (no new card logic):** possession market rendering, ⚔ Attack path
  (generic→siege→creature), Exorcist 🧿 Dispel (+ its per-turn flag), Cleric R1
  +2-vs-Possession use, Conjuration gate (`isConjurer` unlock), Conjuration summon
  play path, `refill(market, deck, idx)` in-place slot refill.
- **New for the mode (small):** the Veil Instability meter (integer + HUD readout +
  threshold check on summon), the tutorial possession **template factory** (fixed
  DEF/VP=0/no-reward block + slot-priority spawner + concurrent cap), and the
  scripted first-banish "draw 1" beat.
- **Explicitly NOT touched:** the fixed 7-card conjuration deck (untouched; main
  game keeps it), `allMarketsUnavailable()` monster-win (must not fire here; cap
  guarantees it can't), Teramancer/Soothsayer/Ghoul gate interactions, the
  unbuilt "Possession location routing."

## 8. Handoffs
- **design-lead:** owns starting Influence/Food scaffolding, guided-step ordering,
  and where the three summon lessons and two removal lessons sit in the flow. The
  card list above (j1/j3[/j7], j4 optional, c1/c6/c7) and the Instability numbers
  (+2 creature / +1 spell / threshold 5) are the levers to pace against.
- **pve-pressure-designer:** owns whether the infestation feeds any doom clock and
  any loss state. My only card-side constraint: the **3-concurrent spawn cap** and
  the **0-VP / 0-reward** possession stat block must hold, so the tutorial stays
  non-lethal and non-farmable regardless of the threat layer wrapped around it.
