# Warrior Guild. PvE Viability Review (Creeping Doom)

**Author:** tcg-designer · **Date:** 2026-07-23
**Sources read:** MD v2.2 (§2, §2A, §3, §5, §7, §8B, §8C, §8E, §9, §10),
`V11_CREEPING_DOOM_BRIEF.md`, `V11_MONSTER_PRESSURE_BASELINE.md`,
`V11_CREEPING_DOOM_REVIEW.md`, `MD_UPDATE_QUEUE_v2_3.md`, `docs/qa/TEST_PLAN.md`,
plus the live card data in `simulator/connivances_simulator_v11.html`.

**Constraints honoured:** no card whose printed text/stats differ per mode; no
Warrior→ATK conversion of the recruit line (explicitly rejected by the designer);
no code written; threat-side behaviour left to `pve-pressure-designer`.

> ⚠️ **READ ADDENDUM A FIRST (end of document).** The designer supplied faction
> theme/spirit text on 2026-07-23, after §§0–6 were written. It **changes the lead
> recommendation** (A now leads, not C), **settles W3 and W6**, adds a hard
> anti-early-spike constraint, and revises the Dojo design. §§0–6 remain valid as
> analysis; Addendum A is the current recommendation.
>
> ⚠️ **THEN READ ADDENDUM B (very end).** Winnability triage (2026-07-25): the
> "can't win" problem is **~70% pressure-layer** (an unintended 11-ATK Portal bar
> from Ghoul retreat-to-guard), **~30% card-power**. This **re-orders everything**:
> no card change is worth shipping until the 11-ATK bar is ruled, because tuning
> card ATK against a doubled bar forces exactly the early-spike the designer
> forbade.

---

## 0. Corrections to the brief's premises (read this first)

Three of the framing claims do not survive contact with the data. They matter
because two of the four options below hang off them.

### 0.1 "Dojo is strictly dominated by Armory"; **false as stated**

| | Dojo (bg8) | Armory (bg11) |
|---|---|---|
| Cost | 12 Inf | 10 Inf |
| Exchange rate, **one card in play** | **3 Inf → 1 ⚪** | **4 Inf → 1 ⚪** |
| Rate at set completion | n/a (School has no `completionBonus`) | 3 Inf → 1 ⚪ |
| Cost to reach 3:1 | **12 Inf, one card** | **20 Inf (2× Armory)**; see 0.2 |
| Gate | any Warrior recruit (market always open, 22 copies, cost 2–5) | Builder recruit **or** Oracle |
| DEF / VP | 5 / 2 | 5 / 2 |

Dojo is the **cheapest single-card 3:1 Influence→⚪ ATK converter in the game.**
It is not dominated; it is *mispriced and mislabelled*. The 2-Influence premium
over Armory buys you 3:1 immediately instead of at double the investment.

What is actually true is weaker and more interesting: **a Builder deck already
wants Armory/War Room for other reasons, so Dojo is redundant *for that deck*.**
Dojo's problem is that it is a Warrior payoff sitting in a market a Warrior deck
has the least reason to visit.

### 0.2 ⚠️ Code/doc contradiction that decides how bad Dojo actually is; **needs a designer ruling**

- **MD §5 (Non-Wall Set Completion)** says a set forms when *two active permanents
  share a `subtype`* and at least one carries a `completionBonus`, and that
  *"Armory + War Room → both fire."* Under that rule **Armory + War Room (21 Inf)
  reaches 3:1**.
- **The live code** gates the ratio on card id, not subtype:
  `const armoryCount = S.permanents.filter(x => x.id==='bg11' && !x.disabled).length;`
  `const armoryRatio = armoryCount>=2 ? 3 : 4;`
  So in the build, **only two literal Armories (20 Inf) reach 3:1**; War Room does
  not help.

Per the project's standing warning (MD mixes live rules with scaffolding), I am
**not picking a side**. But note the direction of the risk: if the MD reading is
made live, Armory's 3:1 gets cheaper *and* comes attached to War Room's other
bonuses, and Dojo's margin shrinks to ~nothing. **Rule this before repricing Dojo.**

### 0.3 "Warriors' differentiator is VP"; **overstated**

Every Recruit in the game is 1 VP except Conjure Master (2) and Fallah (2).
Warrior's 22 VP is a function of copy count, not of guild identity. Builder is 22,
Conjurer ~25. Warriors are not a VP guild in PvP either. So "PvE strips their
differentiator by making VP inert" is not the real mechanism.

The real mechanism is worse, and it is §1.

---

## 1. Diagnosis

### 1.1 What the Warrior guild actually is

Warriors are the **velocity / economy-tempo guild**. Their payoff is not on any
single card; it is in three compounding layers:

| Layer | Cards | What it does |
|---|---|---|
| **Influence multipliers** | Negotiator (w4), Warlord (w8) | Superlinear Influence: k Warriors with both = `2k + 2(k−1)` |
| **Draw / deck manipulation** | Pikeman (free card if top is a Warrior), Swordsman (bought card → top of deck), Hunter (Legend thinning) | Raises the odds the multiplier turn actually assembles |
| **Cross-guild glue** | Trainer (Farmers count as Warriors), Commander (free Conjuration with Pikeman), Siegeman (Siege gate) | Lets a Warrior shell borrow other guilds' payoffs |

That is a coherent, well-built guild. Measured output: 5 Warriors incl.
Negotiator + Warlord = **18 Influence in one turn**, for 5 Food. That is the
largest single-turn economy burst any guild can produce.

### 1.2 Why it collapses in Creeping Doom; three independent taxes, not one

**Tax 1; the win condition is not economic.** The player wins with 7 burst ATK
inside an exposure window. Influence is a *means*; ATK is the *terminal currency*.
Every other guild produces something that is either directly terminal (Conjurer →
🟡 ATK permanents; Builder → Siege buildings and repair that keeps ATK sources
standing) or a rate-limiter on plays (Farmer → Food). Warriors produce the one
resource with **no terminal sink of its own**.

**Tax 2; the monsters actively destroy Influence's only sink.** This is the
finding I would lead with. The mode's loss condition is *"12 market positions
razed."* Influence buys from markets. So the doom clock is, mechanically, a
**countdown on the value of the Warrior guild's entire output.** At 6/12 razed the
Warriors' 18-Influence turn is worth roughly half what it was; at 12/12 it is
worth literally nothing. No other guild's output decays with the doom track -
Food, repair, and ATK are all still worth full value at 11/12.

That is a structural incompatibility, and it is invisible in a per-card audit.

**Tax 3; compounding needs time; the mode is ~16 turns (ruling 9).** Deck
thinning (Hunter), top-decking (Swordsman) and draw filtering (Pikeman) are
long-game value. In PvP, where games run long and end on a VP count, they compound
into a win. In a 16-turn race with a burst terminal, they get maybe 3–4 turns of
compounding before the game resolves.

Layer on the ambient PvE effects that specifically bite an Influence deck:
Ghoul's live **+1 Influence tax on every Conjuration purchase** while he is alive,
and the fact that the Warriors' one guaranteed unlock (Dojo, 12 Inf) is exactly
the kind of expensive purchase a shrinking market makes harder to justify.

### 1.3 So: underpowered in the abstract, or only in PvE?

**Not underpowered in the abstract. Genuinely broken in PvE, but not by a power
number; by a currency-conversion gap.**

- **In PvP: fine, arguably strong.** Influence velocity → more cards → more VP,
  and VP is the win condition. Negotiator + Warlord is the best economy turn in
  the game. Hunter's Legend thinning and Swordsman's top-decking are real
  competitive tools. I would not touch the Warrior line for PvP.
- **In PvE: the guild has no exit from Influence into the terminal currency**
  except Dojo; a 12-Influence building, gated behind a card the player has no
  other reason to buy, sitting in a market the Warrior deck cannot otherwise open,
  labelled in a way that makes it read as a worse Armory (0.1).

**The Warrior guild is not missing power. It is missing a pipe.** Dojo *is* that
pipe, already priced at a rate the designer implicitly sanctioned: the rejected
"Warriors print ATK" proposal produced 18 ATK; the same turn routed through Dojo
produces **6 ATK**; one short of the Portal's 7. The 3:1 tax is exactly the
throttle the designer wanted. The pipe just isn't wide enough or visible enough to
be worth building.

### 1.4 Not a known defect

I checked the Warrior line against `docs/qa/TEST_PLAN.md`. One Warrior card *was*
a live defect and is already fixed; **Swordsman's top-deck was dead in the
shipped build** (blocked `confirm()`; fixed as V11-3.3, verified). Negotiator's
retroactive Influence traced correct. Warlord's double-count is unreachable at
`qty:1`. **Nothing in the current Warrior weakness is a known bug.** This is a
design gap, not a defect.

---

## 2. Options

Ordered by how surgical they are. Each states change / PvE fix / player cost /
PvP landing / risk.

---

### Option A. Widen the pipe: make Dojo scale with Warriors (RECOMMENDED)

**What changes.** One card, one conditional clause, printed identically in both
modes. Replace Dojo's text with:

> **Dojo**. Building · School · Cost **10** · DEF 5 · 2 VP · Requires Warrior
> Exchange **3 Influence → +1 ⚪ ATK.**
> If you played **2 or more Warrior recruits this turn**, exchange **2 Influence →
> +1 ⚪ ATK** instead.

Optionally also: **cap the number of exchanges per turn at the number of Warrior
recruits played this turn.** (See "variant" below. I recommend the cap.)

This is exactly the shape of the game's existing per-card conditionals (Reaper
"Harvest: +2 instead", Scribe "The Mystic: draw per Library/Armory", Herbalist
"+1 Food per Augury Mage this turn"). No new keyword, no new UI pattern; the
existing exchange button already re-renders its number live, the way Armory's
already does at 3:1.

**Why it fixes the PvE gap.** It converts Warriors from "produce a currency the
monsters are deleting" into "produce ammunition." Worked numbers for a mature
Warrior turn (5 Warriors incl. Negotiator + Warlord = 18 Inf):

| Board | Rate | ⚪ ATK from 18 Inf |
|---|---|---|
| No converter |; | 0 |
| Armory ×1 | 4:1 | 4 |
| Dojo today | 3:1 | 6 |
| **Dojo, Option A** | **2:1** | **9** |

9 ⚪ clears the Portal's 7 and leaves change. It also ignites the mode's one real
escalation loop, which currently has no starter: Influence → burst ATK → kill a
field monster → **Trophy** → recurring ATK (Dank Beast +1/Trophy, Dragon +3) →
kill more. Warriors become the guild that *starts* the war machine; Trophies keep
it running. That is a martial identity with zero flat ATK printed on a recruit.

**What it costs the player.** Everything, and that's the point:
- 10 Influence and a Food to land Dojo, in a mode where market slots are burning.
- The Warrior recruits themselves (5 cards ≈ 15 Influence of prior purchases).
- **5 Food in one turn** for the 5-Warrior turn; which forces real Farm/Farmer
  investment, i.e. a second guild.
- The 18 Influence itself. Converted Influence is Influence **not** spent buying
  cards. The alpha strike is paid for by giving up a whole turn of board growth,
  which is precisely the designer's stated skill test: *"it's probably going to
  take a lot of food to drop in a lot of gear at that moment."*
- It only pays out if the exposure window is open that turn. Miss the window and
  the Influence is simply burned (unspent ATK does not carry; §4).

**How it lands in PvP.** Mildly positive, self-correcting. A PvP Warrior deck can
now convert economy into pressure against opponent permanents and Possessions.
But PvP is won on **VP**, and every Influence spent on ATK is Influence not spent
on a VP card. The card taxes itself against the PvP win condition. Dojo is `qty:2`
and School has no set bonus, so it cannot be doubled into a runaway.

**Risk.**
- *PvE:* Warrior + Dojo becomes the dominant Creeping Doom line. Real, and partly
  intended (the guild currently has no line at all), but it should not be the
  *only* line; mitigated by Option C, which gives Warriors a second, slower
  ATK channel.
- *Rate risk:* 2:1 with unlimited exchanges means **any** deck with a big
  Influence pile and one Warrior card can buy the Portal kill. That is the
  legitimate version of the objection that killed the ATK-recruit proposal.
  → **This is why I recommend the per-turn cap variant.**

**Variant (recommended): cap exchanges at Warriors-played-this-turn.**
> Exchange 3 Influence → +1 ⚪ ATK, **up to once per Warrior recruit you played
> this turn.** If you played 2+ Warriors this turn, the rate is 2 Influence instead.

5 Warriors → max 5 exchanges → 10 Inf spent → **5 ⚪ ATK**, plus 8 Inf left to
actually buy something. That is a *smaller* number than uncapped 2:1 (9) but a
much healthier one: throughput is tied to Warrior density, not to raw Influence,
so it cannot be borrowed by a non-Warrior deck, and it leaves the player money to
keep building. Combined with a Catapult/Trebuchet (Option C) or a Trophy, 7 is
comfortably reachable without any single turn feeling like a solved puzzle.
⚠️ Cost: it makes Dojo's button stateful (a counter), which is slightly more UI
than the current stateless exchange. Small, but non-zero; flagging for the
digital-implementation budget.

---

### Option B. Mode-level: "Muster". Warriors intercept market razing

**What changes.** No card data at all. A **Creeping Doom mode rule**, reading off
the existing `isWarrior` flag:

> **Muster.** Once per monster turn, if you played **2 or more Warrior recruits on
> your previous turn**, you may prevent **one** market position from being razed.
> The monster's action is spent; the slot survives. Muster cannot be used twice in
> the same monster turn.

**Why it fixes the PvE gap.** It gives Warriors the one job in the mode nobody
currently owns: **holding the line at the markets.** Walls explicitly do *not*
protect markets (ruled, MD_UPDATE_QUEUE §2b), and the review's proposed "Intercept"
valve (§E2) is unbuilt; so the mode currently has *no* counterplay to razing
except killing monsters. Warriors become that counterplay. It is thematically
perfect (soldiers defending the town outside the keep), it is martial, and it
prints no ATK.

It also directly repairs Tax 2 from §1.2: Warriors stop being the guild whose
output the doom clock deletes and become the guild that *slows the deletion*.

**What it costs the player.** Two Warriors' worth of Food and hand slots, every
single turn, forever; a standing tax on tempo. And Muster protects the market,
not the board, so a Muster-heavy turn is a turn spent not building and not
attacking. Missing a turn drops the shield.

**How it lands in PvP.** Not at all; there is no razing in PvP. That is fine
(Warriors don't need help in PvP) but it means this option does **nothing** to
unify the guild's identity across modes: the same cards would do two unrelated
jobs. That is a real design cost, not just an implementation one.

**Risk.**
- **Pacing risk is the big one, and it is not mine to own.** Muster brakes the
  doom clock directly. Ruling 9 targets ~16 turns and the designer *has never seen
  the monster win condition fire*. Adding a player-controlled brake before the
  clock has been observed working is backwards. → **Hand to `pve-pressure-designer`
  and hold until the doom track is measured.**
- **8+ legibility risk:** it is an off-card rule that fires during the *monster*
  turn, on a condition set on the *previous* player turn. That is two levels of
  indirection with nothing printed on any card. Worst option in the set for an
  onboarding audience.
- Interacts with the unresolved retreat/raze rules (Point 4 states 1/2/3); those
  must land first or Muster's trigger has no stable definition.

---

### Option C. Broaden the Warrior market gate: any Warrior unlocks Siege

**What changes.** One line in **MD §7 Market Gates**. No card text, no stats:

> Buildings. Siege (Catapult, Trebuchet): unlocked by a **Builder** or **any
> Warrior recruit** (was: Builder or Siegeman).

Siegeman's printed text stays valid; it still unlocks Siege *and* gives Siege +1
ATK this turn; it simply stops being the guild's only key.

**Why it fixes the PvE gap.** It corrects a factual error in the guild table: the
Warriors' market access is not "Dojo only," it is "Dojo + Siege," but only through
**3 of 22 copies** (Siegeman), which is thin enough to be unreliable. Catapult
(+1 🔴/turn) and Trebuchet (+2 🔴/turn) are the **only recurring-ATK buildings in
the game**, and 🔴 Siege ATK is unrestricted (§2A; "can target anything"). Making
them reliably Warrior-accessible gives the guild a **slow, permanent** ATK channel
to complement Dojo's burst one, without printing a single point of ATK on a recruit.

It also composes with the ruled Wall-Siege generalisation and with the DEF
threshold model: Siege permanents are the things Wall Sets buff (+2 DEF to
Creatures & Siege, `recomputeStoredDef` gates on `isCreatureType || atk_siege>0`),
so a Warrior/Siege board is a board that keeps *standing*; which under Point 4's
three board states is what turns monsters away from the markets. The pieces
already fit; only the gate is in the way.

**What it costs the player.** Nothing new; it removes a restriction. The cost is
the buildings themselves (6 and 8 Influence) and the fact that recurring ATK is
slow: Trebuchet pays 2/turn, so it is a turn-4 investment for a turn-12 payoff.

**How it lands in PvP.** Neutral-to-slightly-positive and very low variance. It
widens who can buy two mid-cost buildings. No new interaction.

**Risk.** Lowest of the four. Two things to watch:
1. It devalues Siegeman's unlock clause, leaving him a vanilla 2-Influence recruit
   with a situational +1. Acceptable; his +1 ATK to Siege is still a Warrior-only
   payoff, and he becomes the *scaling* card for a Siege board rather than the key.
   ⚠️ If the designer dislikes that, the alternative is to raise Siegeman's copy
   count (3 → 5) instead of broadening the gate. Same effect, less elegant.
2. Builder loses a slice of exclusivity. Builder still holds Trophy Room, Poison
   Room, Armory, Scriptorium, War Room, Granary, Caravans; plus repair. It can
   afford it.

**8+ note:** this is the *only* option that makes the rules **simpler**. "A Warrior
lets you buy war machines" is a rule an 8-year-old already expects to be true.

---

### Option D. Give VP a job in Creeping Doom (⚠️ designer call, not mine)

**What changes.** A mode-level scoring rule. VP stops being inert and becomes the
run's **score**, feeding whatever meta-progression sits above the mode. Ruling 12
already states that Creeping Doom *"is currently an onboarding mode; it will later
become the first step of a progressive difficulty ladder"*; a ladder needs a
per-run score, and the game already computes one (`calcVP`).

Two sub-shapes, both designer's call:
- **(D1) Score only.** VP does not affect in-run play; it ranks the run. Zero
  balance risk, zero rules load. Restores Warriors' *narrative* differentiator
  without touching in-run power.
- **(D2) VP gates something.** e.g. VP thresholds unlock later ladder rungs or
  starting bonuses. Higher risk: it creates a second, parallel win condition
  inside a mode whose whole point is a single race, and it can pull the player
  away from the actual doom clock.

**Why it (partly) fixes the PvE gap.** It does not fix §1.2's currency problem at
all; inside the run, Warrior Influence is still un-terminal. It fixes *motivation*
and it repairs the mode/PvP identity split: the same card means roughly the same
thing in both modes. It is a good **companion** to A or C, and a poor substitute.

**PvP landing.** None. VP is already fully live in PvP. That is precisely the
appeal: it is the only option that makes the two modes agree about what cards are
*for*.

**Risk.** D1: essentially none. D2: real, and it competes with the doom clock for
the player's attention in a mode that is meant to teach one clock.

> **Flagged as a designer ruling, per the brief's instruction.** The brief states
> *"Victory Points do not matter in Creeping Doom"* as design intent. I am not
> overriding that; I am noting that ruling 12's ladder implies a score, and VP is
> the score that already exists. Recommend **D1 only**, and only after A/C land.

---

## 3. The Dojo problem specifically

**Verdict: fix it, don't cut it.** Dojo is the only Warrior-exclusive card in the
game and the only single-card 3:1 converter. Cutting it would leave the guild with
literally zero exclusive content. But it needs four changes:

1. **Reprice 12 → 10 Influence**, matching Armory. Dojo is Warrior-gated *and*
   sits in a market a Warrior deck otherwise ignores; it should not also cost more
   than the Builder equivalent. MD §10 item 10 currently reads *"Dojo cost ✅
   Consistent at 12 Inf; intentional"*; ⚠️ **that item must be reopened**, or a
   future pass will revert the reprice as a regression.
2. **Add the Warrior-count conditional** (Option A). This is the actual fix: it
   turns Dojo from "a converter that happens to need a Warrior" into "the Warrior
   guild's payoff card."
3. **Retemplate so the differentiation is readable.** Current text -
   *"Exchange 3 Influence for +1 ⚪ ATK"*; is word-for-word Armory's completed
   text, which is why it reads as dominated. Proposed:
   > **Dojo**; *Train the levy.*
   > Exchange **3 Influence → +1 ⚪ ATK**. **Warriors ×2+ this turn: 2 Influence
   > instead.**
   The market card should also surface the comparison the player cannot currently
   see: Dojo is 3:1 **alone**; Armory needs a second Armory-subtype building.
4. **Resolve §0.2 first.** Whether Armory reaches 3:1 at 20 Inf (code) or 21 Inf
   with War Room's extra bonuses attached (MD) changes how much headroom Dojo has.
   **Do not set Dojo's final numbers until that ruling lands.**

**One thing I would *not* do:** give School a `completionBonus` so two Dojos form
a set. `qty:2` makes that a 20–24 Influence, two-card requirement for a guild that
is already Influence-starved for board development, and it would push the alpha
strike into "solved puzzle" territory. Keep Dojo a one-card payoff.

---

## 4. Recommendation

**Ship C first, then A (capped variant). Defer B. Take D1 only as a follow-up.**

**Sequencing rationale:**

1. **Option C (Siege gate) is free and safe.** It removes a rule rather than
   adding one, needs no new numbers, is the least risky thing in this document for
   an 8+ audience, and it re-bases the guild's market access from "Dojo only" to
   "Dojo + the game's only recurring-ATK buildings." It should go in regardless of
   what happens to Dojo. If C alone measurably moves Warrior PvE viability, A can
   be tuned smaller.
2. **Option A (Dojo) is the actual fix**, because it addresses the structural
   diagnosis in §1.2. Warriors need a terminal sink for Influence that does not
   depend on the market surviving. Nothing else in this document does that.
   Take the **capped variant**: the cap is what keeps a Conjurer/Builder deck from
   borrowing the Warrior payoff with one splashed Pikeman, and it is what keeps
   the 2:1 rate from re-creating the trivialised-Portal problem that killed the
   ATK-recruit proposal.
3. **Defer B (Muster).** It is a good idea in the wrong order. The mode's doom
   clock has *never been observed firing*; adding a player brake to an unfired
   clock is premature, and the trigger depends on raze/retreat rules that are still
   open. It is also threat-side pacing; hand it to `pve-pressure-designer` with
   the note that Warriors are the natural fictional owner of an Intercept valve if
   one is ever built.
4. **D1 as polish**, once the ladder exists.

**Safest option for an 8+ onboarding audience: Option C, clearly.** It is a
simplification. Second safest is **A without the cap** (one printed conditional,
same shape as Reaper/Scribe/Herbalist, visible as a changing number on a button
the player already understands). **A with the cap** adds a per-turn counter -
still fine, but it is genuinely more to hold in your head, and it is the one place
I would accept slightly worse balance for a cleaner read if the designer prefers.
**B is the worst fit for 8+** and should not be the onboarding-mode fix.

**What Warriors uniquely are, after this:** the guild that *fuels the war machine
without being the war machine.* They buy the war rooms and the war engines
(Siege), and they turn the realm's wealth into a single decisive blow (Dojo). They
own the burst; Conjurers own the standing army; Builders own the walls and the
repairs; Farmers own the tempo. No flat ATK printed anywhere on the line.

---

## 5. Needs a designer ruling (not my call)

| # | Question | Why it blocks | Blocks |
|---|---|---|---|
| **W1** | **Does Armory's 3:1 fire on the Armory *subtype* (MD §5. Armory + War Room) or only on two literal Armory cards (live code)?** | Determines Dojo's entire competitive headroom. §0.2. | Dojo repricing (Option A/§3.1) |
| **W2** | **Reopen MD §10 item 10** (*"Dojo cost 12 Inf; intentional"*). If the reprice to 10 is approved, that row must be struck or a future pass reverts it. | Must-not-regress hygiene. | §3.1 |
| **W3** | **Is a Warrior-gated Influence→ATK pipe acceptable at all, given the rejected Warriors-print-ATK proposal?** My read: yes; 18 Inf → 5–9 ATK *through a 10-Inf building, on a 5-Food turn*, is the throttled version of what was rejected. But it is the same idea taxed, and the designer should confirm the tax is sufficient rather than have me assume it. | The whole of Option A. | Option A |
| **W4** | **Does Siege access belong to Warriors as a guild, or only to Siegeman?** Broadening the gate is a faction-identity call, not a balance one. Alternative: raise Siegeman `qty` 3→5. | Which form Option C takes. | Option C |
| **W5** | **Does VP get a job in Creeping Doom (score/ladder), or stay fully inert?** Brief says inert; ruling 12's difficulty ladder implies a per-run score. | Option D; also whether the two modes agree about what cards mean. | Option D |
| **W6** | **Should the Dojo exchange be capped per turn?** Cap = safer, tied to Warrior density, un-splashable, but stateful UI. Uncapped = simpler and more readable for 8+. Genuine trade, no right answer. | Option A variant | Option A |
| **W7** | *(Handoff, not mine)* **Should Warriors own a market-razing Intercept valve?** Threat-side pacing. Recommend routing Option B to `pve-pressure-designer` after the doom track is measured firing. | Option B | Option B |

---

## 6. Measurement I would want before final numbers

Consistent with `V11_CREEPING_DOOM_REVIEW.md` §F5 ("do not tune before you
re-measure"), none of the numbers above should be locked until:

1. **Earliest turn a Warrior/Dojo bot reaches 7+ single-turn ATK**, at 3:1 (today),
   2:1 uncapped, and 2:1 capped. If 2:1 uncapped puts it before ~turn 8, take the
   cap. Cross-reference the review's §H3 open measurement; this is the same
   number, asked from the Warrior side.
2. **Influence-value decay curve:** average Influence a bot can usefully spend per
   turn at 0, 3, 6, 9 razed slots. This is the empirical version of Tax 2 (§1.2)
   and it is currently an argument, not a measurement. If the decay is shallower
   than I claim, Option A can be tuned down.
3. **Warrior-density distribution:** how often a real deck actually gets 2+ /5+
   Warriors into one hand. The whole of Option A's conditional is priced off that,
   and the opening hand is now a pure random 5-of-10 (V11-3.4) so turn-1 variance
   is intended and the sample must be wide.

---
---

# ADDENDUM A. Revision after the designer's faction theme/spirit text (2026-07-23)

The designer supplied authoritative faction intent after §§0–6 were written. It is
decisive on three points, and it changes my lead recommendation. Summary of what
moves:

| Item | Before | After theme |
|---|---|---|
| Lead recommendation | C then A | **A leads. C is the companion, not the opener.** |
| Dojo shape | rate tier (3:1 → 2:1) + optional cap | **Cap only. One exchange per Warrior played. Single rate, single scaling axis.** |
| **W3** (is an Inf→ATK pipe allowed) | open | ✅ **YES; confirmed. It is the Dojo's stated purpose.** |
| **W6** (cap or not) | genuine trade | ✅ **Settled: CAP.** The anti-early-spike constraint kills the uncapped rate tier. |
| **W1** (Armory subtype vs id) | blocking Dojo pricing | Still open, but **de-risked**; the new Dojo no longer competes with Armory on rate. |
| Trainer-Farmers | not addressed | **Count fully toward the cap.** This is the pitchfork army, mechanically realised. |

---

## A1. Confirmations

**W3; agreed, yes.** *"The dojo is where the warriors train for the fight and
convert their influence into attack"* is a statement of the card's design purpose.
The rejected proposal was never "a pipe"; it was **an untaxed, untimed pipe on the
recruits themselves**; 5 recruits in hand = 18 ATK with no building, no gate, no
conversion cost, on any turn a good hand shows up. Routing the same fantasy through
a 10–12 Influence building that must be bought, discarded, redrawn and played is
the taxed version. Confirmed.

**Warrior identity = MASS, not individual power; agreed, and it sharpens the
design.** Everything in the guild already scales with **count**: Negotiator (+1 per
other Warrior), Warlord (+1 per other Warrior), Trainer (converts a whole guild
into Warriors), Pikeman (chains into more Warriors), Swordsman (stacks the top of
the deck with more Warriors). The live code even keeps a counter for it -
`S.warriorsPlayedThisTurn`. There is no Warrior card anywhere that rewards *one big
Warrior*. So the payoff must scale on **count**, and only count.

**That single observation kills my own rate-tier idea.** A rate tier (3:1 → 2:1)
scales on *efficiency*, which is a second axis. Two axes multiply, which is exactly
how you get an unintended spike, and it is off-theme besides. **Drop the tier.**

---

## A2. The anti-early-spike constraint; the math, and why the capped design
provably satisfies it

**Constraint:** Warriors must not reach 4–5 ATK in the early game "if the ramp
breaks."

### A2.1 Revised Dojo (this is the recommendation)

> **Dojo**. Building · School · Requires Warrior · DEF 5 · 2 VP · Cost **10** ⚠️(W1)
> *The warriors train for the fight.*
> **Each Warrior recruit you played this turn may train:** exchange
> **3 Influence → +1 ⚪ ATK.** One exchange per Warrior played this turn.

Changes from the printed card: cost 12 → 10 (⚠️ contingent on W1 and W2); the
exchange is no longer unlimited; the exchange now **requires Warriors on the turn
you use it**, not merely on the turn you bought it.

**Rate stays 3:1.** Mass is the scaling axis.

### A2.2 The hard bound

```
ATK_dojo(turn) = min( W , floor(Inf_spare / 3) )
       where W = Warrior recruits played this turn
       and   W ≤ Food available  (every card costs 1 Food)
       and   W ≤ cards in hand   (5, or 6 under Mystic)
```

Three independent ceilings, all of which bind hardest exactly in the early game.
**Food is the one that makes this provable:** Food = 3 + farm permanents. A player
with no farm permanent physically cannot play more than 3 cards, so cannot exceed
**3 ATK from Dojo**, no matter how much Influence they hold or how lucky the draw.
4 ATK requires a farm permanent already in play; 5 requires two.

### A2.3 Earliest turn to reach each threshold

The dominant constraint is not the exchange at all; it is that **purchases go to
Discard, not hand** (§4). Dojo must be bought, then cycled through a reshuffle,
then drawn, then played for 1 Food.

*Influence-per-turn ceiling for a max-speed Warrior deck (starter deck = 8 cards at
+1 Inf, 5 cards drawn/turn, 3 Food base):*

| Turn | Food | Realistic max Inf | Note |
|---|---|---|---|
| 1 | 3 (5 w/ Farm Hand) | **~4** | Buys 1–2 cheap recruits; they go to Discard |
| 2 | 3–5 | **~4–5** | Still drawing the other half of the starter deck; turn-1 buys are unavailable |
| 3 | 5 (Rice Field down) | **~6** | First reshuffle; first bought Warriors appear |
| 4 | 5 | **~6–8** | |
| 5 | 5–6 | **~7–9** | |
| 6 | 5–7 | **~9–12** | ← **earliest Dojo purchase** |

| Milestone | Earliest | Typical | Why |
|---|---|---|---|
| Dojo **purchased** | **turn 5–6** | turn 6–7 | Needs 10 Inf in a single turn (Influence does not carry over, §4) |
| Dojo **in play** | **turn 7** | turn 8–9 | Bought → Discard → reshuffle (~every 3 turns at 5 draws) → drawn → played |
| Dojo in play, **Expediter line** | **turn 6** | turn 7–8 | Builder splash: buy Expediter (3 Inf) ~turn 3, draw it, buy Dojo same turn → straight into play at DEF 3 |
| **First 1–3 ATK** | **turn 7** | turn 8–9 | Not on the buy turn; 10–12 Inf is already gone |
| **First 4 ATK** | **turn 8** | turn 9–11 | Needs W≥4 **and** 12 spare Inf **and** a farm permanent for the 4th Food |
| **First 5 ATK** | **turn 9** | turn 10–12 | Needs W≥5, 15 spare Inf, 5 Food |
| **7 ATK from Dojo alone** | **~turn 14+, if ever** |; | Needs W≥7 (7 Food = 2 farm permanents; 7+ card hand = Mystic/draw engine) **and 21 spare Inf**; above the guild's measured 18-Inf ceiling |

**Worked example of the earliest 4-ATK turn.** Play Negotiator + Warlord + 2 other
Warriors (4 cards, 4 Food, so a farm permanent is mandatory):
base 4×2 = 8 Inf, Negotiator +3, Warlord +3 = **14 Inf**. Spend 12 on four
exchanges → **4 ATK**, 2 Inf left over. Requires Warlord (5 Inf, `qty:1`) *and*
Negotiator *and* Dojo already in play *and* 4 Warriors in one 5-card hand. That
composite is a turn-8 event at the absolute earliest, turn 10ish typically.

### A2.4 The three answers the constraint asks for

1. **Earliest 4 ATK: turn 8** (typical 9–11), and **structurally impossible before
   turn 7** because Dojo cannot physically be in play sooner.
2. **Earliest 7 ATK: not reachable from Dojo alone.** 7 exchanges cost 21
   Influence, which exceeds the guild's own best-case single-turn output (18).
3. **Therefore the Portal kill must be a combination**. Dojo burst (3–5) plus
   Siege recurring (Catapult +1, Trebuchet +2) or a Trophy (Dragon +3, Dank Beast
   +1/Trophy). **This is the single most important consequence of the design and it
   is why Option C is no longer optional:** the capped Dojo deliberately cannot
   close the game by itself, so Warriors need a reliable second channel or they
   trade one dead end for another.

**And a fourth, unasked but load-bearing: the uncapped rate tier fails the
constraint and is withdrawn.** At 2:1 uncapped, 4 ATK costs 8 Influence with *no
Warrior requirement at the point of use*; any deck holding a Dojo and 8 spare
Influence draws into 4 ATK around turn 6–7. That is precisely the failure the
designer named. The cap is not a safety valve bolted on; under this constraint it
**is** the card.

### A2.5 The extra thing the cap buys: it un-splashes Dojo

Today the exchange has no Warrior gate at the point of use; the code renders the
button on any active Dojo, and `requiresWarrior` is checked only in `buyCard`. So a
Conjurer or Builder deck that acquires one Dojo gets a permanent 3:1 converter
forever, with zero ongoing Warrior commitment. **The capped design closes that**:
no Warriors played, no exchanges. A dojo with no students trains nobody.

That also **de-risks W1**. Dojo stops competing with Armory on *rate* and starts
competing on *shape*:

| | Armory | Dojo (revised) |
|---|---|---|
| Rate | 4:1, 3:1 at set | 3:1 flat |
| Throughput | **unlimited** per turn | **capped at Warriors played** |
| Gate at point of use | none | **Warriors this turn** |
| Guild | Builder (generic converter) | Warrior (mass converter) |

Neither dominates. Armory is the reliable trickle for any deck; Dojo is the burst
for a deck that commits bodies. W1's outcome no longer decides Dojo's viability -
though it still decides whether **10** is the right cost.

---

## A3. Ask 1; does the theme change C-then-A? **Yes. A now leads.**

**Reasoning.** The theme text does two things:

1. It names Dojo as the Warrior's defining card and states its purpose. That makes
   Option A an **identity fix**, not a balance patch. You do not lead with a patch
   when the identity card is broken.
2. It reframes the diagnosis. My §1.2 said Warriors lack a *terminal sink*. The
   designer's words are *"it feels like a very narrow ramp."* Same defect, better
   name. Narrow means low throughput per turn; and throughput is exactly what the
   cap-on-count model widens, because it widens with the thing the guild is
   already built to produce (bodies).

**C's role changes but its priority does not drop; it inverts.** Before, C was the
safe opener. Now it is the **necessary completion**: because the capped Dojo
provably cannot reach 7 alone (A2.4), Warriors need a second ATK channel or Option
A ships a guild that can attack but cannot win. Catapult/Trebuchet are that
channel. **A and C are now a single package, not alternatives.** Ship both or ship
neither; A alone leaves the guild 2 ATK short of the Portal forever, and C alone is
2 recurring ATK on an otherwise unchanged guild.

**Order of implementation** (unchanged, for a different reason): C first because it
is a one-line gate change with no numbers to tune, so it can land while W1/W2 are
still being ruled; A follows once Dojo's cost is settled.

---

## A4. Ask 2; the pitchfork army: is it viable, and does it count toward the cap?

### A4.1 Is it viable today? **Mechanically yes, economically the best line in the
guild; and it has a live bug.**

Trainer (w3, 3 Inf, `qty:4`) makes Farmers count as Warriors for the turn. The live
code implements this as a **single shared predicate**, which is the right
architecture:

```js
const countsAsWarrior = card.isWarrior ||
  (S.trainerPlayedThisTurn && (card.subtype==='Farmer' || card.isFarmer));
```

That one predicate feeds the Warrior gate, the Warrior counter, Negotiator and
Warlord. `card.isFarmer` also picks up **Teramancer** (a Conjurer with
`isFarmer:true`), so Trainer reaches into a third guild.

**Why the pitchfork line is economically superior to the pure-Warrior line; and
this is the important finding:** Warriors cost 1 Food and produce 0 Food, so a
pure-Warrior turn is **Food-bound** (`W ≤ Food`). Farmers cost 1 Food and produce
**+1 or +2 Food**, so a Trainer turn is **Food-neutral or Food-positive** and is
bound only by **hand size**. The pitchfork army escapes the tighter of my two
safety ceilings.

Quantified, best realistic pitchfork turn: Trainer + Negotiator + 4 Farmers (6
cards, ~6 Food, self-funded by the Farmers) = 6 Warriors.
Influence: 6 × 2 = 12, + Negotiator's +5 = **17 Inf**. Cap = 6, but 3:1 only affords
5 → **5 ATK**, and it cost 15 of the 17 Influence. Add a Trebuchet (+2 🔴) and that
is the **7-ATK Portal kill, around turn 10–12**; against a ~16-turn target
(ruling 9). That is a good number and it is the guild's win condition made real.

Also note the pitchfork line is *cheaper to assemble* than the pure-Warrior line:
Farmers cost 2–3 Inf with 19 copies; Warriors cost 2–5 with 22. Combined with the
Food self-funding, **the pitchfork build is likely to be strictly better than the
pure-Warrior build.** I read the theme as endorsing that (*"the likes of which can
overwhelm"*); but it is a designer call, so it is logged as **W8**.

### A4.2 🔴 Live defect found in the signature line. Trainer's retroactive path
does not increment the Warrior **count**

`simulator/connivances_simulator_v11.html`, Trainer branch (~line 2136). When
Trainer is played *after* Farmers, it sets the boolean gate but never the counter:

```js
if(farmerCount>0){
  S.warriorPlayedThisTurn=true;      // gate; set
  // ...                              // S.warriorsPlayedThisTurn. NEVER incremented
}
```

**Repro:** play Farmer, Farmer, Trainer, Negotiator.
Negotiator's burst reads `const otherWarriors = S.warriorsPlayedThisTurn - 1;`
→ counter is **2** (Trainer + Negotiator), so it awards **+1**.
Correct value is **+3** (Trainer + 2 converted Farmers).
**Under-counts by 2 Influence**, silently.

Play the same cards in the order Trainer, Farmer, Farmer, Negotiator and it is
correct; the forward path increments properly. So the bug is order-dependent,
which is why it is easy to miss.

- **Severity: Medium**, rising to **High** if any count-based payoff ships. My
  capped Dojo reads `S.warriorsPlayedThisTurn`, so it would inherit the same
  under-count; a player who plays Farmers before Trainer would silently lose
  exchanges.
- **Not in `docs/qa/TEST_PLAN.md`.** That file records Negotiator as *"✅ traced
  correct across single/stacked/mixed sequences"*; evidently the
  Farmers-before-Trainer sequence was not among them.
- **Fix direction:** the retroactive branch should raise `warriorsPlayedThisTurn`
  by `farmerCount` and let the existing Negotiator/Warlord logic pay out, rather
  than hand-crediting Influence in a parallel code path (which is also why Warlord
  is missing from that branch entirely; it credits Negotiator only).
- **→ Handing to `qa-lead` to verify and log.** Fix this **before** any
  count-based Warrior payoff ships.

### A4.3 Recommended rule

> **Trainer-converted Farmers count fully as Warriors for the Dojo exchange cap,**
> identically to how they count for Negotiator, Warlord, Swordsman and the Warrior
> market gate. One shared "counts as a Warrior this turn" predicate governs all
> Warrior-count effects, with no exceptions and no discounts.

**Why full, not discounted:**
- **Precedent.** `MD_UPDATE_QUEUE_v2_3.md` §D5 already rules Trainer-Farmers count
  for Swordsman *"consistent with Trainer's rule"*; the designer has ruled once
  that Trainer's conversion is total for the turn.
- **Architecture.** One predicate is already how the code works. A discount would
  fork it, and forked predicates are where the A4.2 class of bug breeds.
- **Theme.** A discount would say the pitchfork army is a *worse* Warrior army.
  The designer's text says it is the one that *overwhelms*.
- **8+ legibility.** "This turn, your Farmers are Warriors" is one rule with no
  asterisk. Any exception makes it two rules.

**If it proves too strong** (W8), the dial should be on **Trainer**, not on the
cap: reduce Trainer `qty` 4 → 2, or narrow it to Farmers played *after* Trainer
(which would also delete the A4.2 bug by deleting its code path). Do not weaken the
Dojo cap to compensate; that would punish the pure-Warrior line for the Farmer
line's efficiency.

---

## A5. Ask 3; does Option C dilute Builder identity? **No. The theme endorses it
explicitly.**

*"They are meant to be low, slow and steady, but their engines of war can be
wielded easily by other factions."*

That is a direct statement that Builder permanents are **meant** to be cross-faction
tools. Option C does not erode Builder identity; it is Builder identity working as
designed. Builder's identity is *"we build the engines and we repair them"*; not
*"only we may fire them."* And Builder retains everything that actually defines it:
**Repair is 100% Builder-exclusive** (17 repair across the guild, zero elsewhere),
plus Trophy Room, Poison Room, Armory, Scriptorium, War Room, Granary and Caravans.

**Two refinements the theme prompts:**

1. **The gate pattern already exists and is good. C extends it rather than
   breaking it.** Each faction holds a key to part of the Buildings market:
   Builder → everything; Siegeman → Siege; Oracle (Augury) → Library + Armory;
   any Warrior → Dojo. C simply widens the Warrior key from 3 copies (Siegeman) to
   22. The pattern survives.
2. **It costs Siegeman his unlock clause.** He keeps the +1 ATK to Siege, becoming
   the *scaling* card for a Siege board instead of the *key* to it. I think that is
   a better card; a key you must draw is a tax; a multiplier you want to draw is a
   payoff. ⚠️ But it is a faction-identity call (**W4**). Conservative fallback if
   the designer wants to keep the key: raise Siegeman `qty` 3 → 5 and change
   nothing else. Same reliability, less elegance, zero rules change.

**One theme-driven find worth acting on separately; see A7.3:** the game's actual
"Farmers attack" card is **War Room** (Builder guild, Armory subtype, *"Farmers
gain +1 ⚪ ATK"*). It is the pitchfork army's natural engine, and per the theme
being a Builder engine wielded by another faction is *correct*. But its gate is
`requiresBuilder`, and the other card that opens it is **Oracle; an Augury Mage**
(Oracle unlocks Library **and Armory**, and War Room is Armory subtype). So the
signature Warrior line's best engine is currently keyed by Builders and Augury
Mages and by no Warrior at all. Consider adding War Room to whatever Warrior key
Option C establishes, or accept it as an intentional cross-faction handshake.

---

## A6. Ask 4. Augury Mage mid-game attack (SEPARATE WORKSTREAM)

> **Scope note:** this is a distinct workstream from the Warrior fix. Nothing here
> should gate or delay A/C. It also **depends on a ruling** (A7.2) that the Warrior
> work does not.

### A6.0 First; they may already have one, and nobody has signposted it

**Oracle** (a3, 3 Inf, `qty:4`) unlocks *"Libraries and Armories"* for the turn.
That is not a small key. By subtype it opens:

| Card | Subtype | What it does for an Augury deck |
|---|---|---|
| **Poison Room** (10) | Library | **Exchange 3 Food → +2 ⚪ ATK**; repeatable |
| **Armory** (10) | Armory | Exchange 4 Inf → +1 ⚪ ATK (3:1 at set) |
| **War Room** (11) | Armory | Farmers +1 ⚪ ATK; set: +1 ⚪ /turn recurring |
| Trophy Room (7) | Library | +1 ⚪ per active Trophy; set: Draw 2 |
| Scriptorium (7) | Library | Spells −2 Inf; set: Draw 2 |

**Poison Room is the strongest fit that already exists.** Augury Mages control the
**Harvest** Auspice (+1 Food per Farm, real-time on switch) and Herbalist gives +1
Food per Augury Mage played. So the deck that can manufacture Food on demand is the
Augury deck; and Poison Room is the game's only **Food → ATK** converter, at a
generous **2 ATK per 3 Food**. That is a mid-game attack method, on-identity
(Auspice manipulation is the enabler), already printed, already gated to them.

**Why it isn't being used:** (a) it costs 10 Influence and needs Oracle in hand on
the buy turn; (b) it contradicts the theme statement that Augury Mages *"do not
create permanents"* (A7.2), so it may not be a route the designer wants; (c) it is
completely unsignposted; nothing on Oracle, Poison Room, or any Augury card hints
at the combination.

**Recommendation: rule A7.2 before designing a new card.** If Augury Mages *may*
own permanents, the cheapest fix is to signpost the Oracle → Poison Room line and
possibly drop Poison Room's cost, and you may need no new card at all.

If the answer is *"no permanents; that is what makes them different"*, then:

### A6.1 AM-1; "The Hunter" martial line ⭐ recommended

> **[New Augury Mage recruit]**. Cost 4 · 1 VP · +2 Influence
> **The Hunter:** each Augury Mage you played this turn gains **+1 ⚪ ATK**.

**Why this is the right shape:**
- **It fills the game's emptiest slot.** Of four Auspices, Mystic pays in draw,
  Harvest pays in Food, Famine is a weapon/hazard; and **Hunter pays in exactly
  one Legend send per turn.** It is by far the thinnest, and it is the *only*
  Auspice with no economic engine attached. Giving Hunter a martial payoff costs
  the design nothing and makes all four Auspices worth switching to.
- **"Hunter" already means aggression** in the fiction. No new vocabulary.
- **It scales on the axis the guild already has.** Their stated engine is *"hands
  recycled quickly because of their abilities to draw other augury mages"*; so
  mages-played-this-turn is their equivalent of the Warrior's body count. 3 mages
  → 3 ATK. Same design grammar as the Warrior fix, different currency.
- **It is properly taxed.** Reaching Hunter costs an Auspice use, and only
  Channeler / Witchdoctor / Fallah grant `'any'`; **Augury Initiate cannot reach
  Hunter at all** (`'mystic-harvest'` only, §3). So the ATK turn is a turn you are
  *not* spending on Mystic draw or Harvest food. That is a real, legible,
  self-imposed cost, and it is the exact tension the guild is built around.
- **No permanents.** Constraint satisfied.
- **Coherent with Necromancer**, which is the *burst* on the same axis (+1 ATK per
  Augury Mage **per Auspice change**). AM-1 is the mid-game, single-change version;
  Necromancer remains the multi-change payoff. One axis, two rungs. ⚠️ Note
  Necromancer at 2 Auspice changes and 4 mages is already 8 ATK; see A7.5.

**Magnitude check:** 3 mages → 3 ⚪ ATK for 3 Food, 1 Auspice use, and a card. Under
the same food/hand ceilings as the Warrior model, so no early spike: an Auspice-
change card plus 3 mages plus this card is a 4-card, 4-Food turn; turn 6+ at best.

### A6.2 AM-2; "Legend as ammunition" (alternative)

> **[New Augury Mage recruit]**. Cost 4 · 1 VP · +2 Influence
> You may send **one card from your hand to Legend**: **+2 ⚪ ATK**.

- **Converts their signature mechanic into a weapon.** Legend is the guild's
  identity (thinning, "starve out other players in PvP") and currently has no
  combat face anywhere in the game.
- **Self-limiting by construction**; bounded by hand size and by the fact that
  every point of ATK costs a real card. Card advantage is the price, which is the
  most honest currency a support guild can pay.
- **Genuinely dual-purpose:** the thinning you wanted to do anyway now also
  pressures the Portal. Very strong feel.
- **Risk:** it is guild-agnostic in spirit; any deck could want it; so it needs
  an Augury-count rider to stay on-faction (e.g. *"…once per Augury Mage you played
  this turn"*, mirroring the Dojo cap). With that rider it is nearly as good as
  AM-1; without it, it is a colour-pie break.

**My pick: AM-1**, because it uses an existing under-served Auspice and needs no
new vocabulary. **AM-2 as the alternative** if the designer prefers Legend to grow
a combat face. Do not ship both; that is two mid-game ATK engines for a support
guild.

---

## A7. Ask 5; theme text vs. card data / MD: contradictions to surface

Seven, roughly in order of how much they matter. I am flagging, not reconciling.

### A7.1 🔴 "Warriors do not build permanents, with the Dojo being the exception" -
vs. Siegeman

Siegeman (w5) unlocks **Catapult and Trebuchet**. Siege *permanents*; and buffs
them +1 ATK. Buying and playing Siege buildings is, today, a core Warrior line and
the guild's only recurring ATK. Two readings:
- **(a)** The theme means *the guild's own cards* create no permanents; Siege are
  Builder engines that Warriors merely wield (consistent with the Builder theme
  text). Option C is then squarely on-theme.
- **(b)** The theme means Warriors *should not be a permanents deck at all*, in
  which case **Option C is off-theme** and the Warrior ATK channel must be
  found elsewhere.

**This ruling decides whether Option C ships.** I read (a) as clearly intended -
"engines wielded by other factions" only means something if other factions wield
them; but it is not mine to declare. **W9.**

### A7.2 🔴 "Augury Mages do not create permanents"; contradicted by their own
card data

- **Oracle** exists solely to unlock **Library and Armory permanents**.
- **Scribe**'s payoff is *"Draw a card per Armory or Library **you control**"* -
  the card is worthless unless the Augury player **owns those permanents**. The
  live code confirms it counts `S.permanents`.

So two of eight Augury recruits are built around owning buildings. Either the theme
statement is about the *recruit line only* (they print no permanents themselves,
but they hold keys and payoffs for others'), or Oracle and Scribe are off-faction.
**This gates ask #4**; it decides whether A6.0's already-existing Poison Room route
is legitimate or whether a new non-permanent card is required. **W10.**

### A7.3 🟠 The pitchfork army's best engine belongs to the wrong two factions

**War Room**; *"Farmers gain +1 ⚪ ATK"*; is the printed Farmers-attack card. It
is **Builder guild**, `requiresBuilder`, and its Armory subtype means the *other*
card that opens it is **Oracle (Augury Mage)**. No Warrior card unlocks it. The
faction the designer names as the pitchfork-army faction is the one faction that
cannot reach it. Per the Builder theme this may be intentional (a shared engine),
but the combination "Trainer + Farmers + War Room" is so obviously the designed
pitchfork engine that the gate looks like an oversight. Flagging for a ruling.

### A7.4 🔴 Live defect in the pitchfork line; see **A4.2**. Trainer's retroactive
branch sets the Warrior *gate* but not the Warrior *count*, silently under-paying
Negotiator (and omitting Warlord entirely) when Farmers are played before Trainer.
Not in `TEST_PLAN.md`. Must be fixed before any count-based Warrior payoff ships.

### A7.5 🟠 Necromancer is under-specified and possibly the real Augury spike

Printed text: *"Each Augury Mage gains +1 ATK per Auspice change this turn."*
- **ATK type is not stated** anywhere in §8B. Per §2A's catch-all it defaults to
  ⚪ Generic, but every other ATK source in the registry names its type. Templating
  gap; should read **⚪**.
- **Magnitude is unbounded on two axes at once** (mages × Auspice changes), which
  is the exact double-scaling failure I removed from my Dojo proposal. 4 mages × 2
  changes = **8 ATK**; above the Portal threshold, from one card. Its only limiter
  is Auspice-use supply, and Witchdoctor/Channeler/Fallah supply it.
  ⚠️ **Before adding any Augury ATK card (ask #4), measure Necromancer.** The
  designer's *"you can quick burst a lot of damage"* suggests this is intended, but
  the same designer's anti-spike constraint on Warriors should probably apply here
  too. Also relevant: `V11_CREEPING_DOOM_REVIEW.md` §E6 flags that the per-turn
  Auspice-use budget has never been measured; that unmeasured number is
  Necromancer's *only* ceiling.

### A7.6 🟡 "Builders are low, slow and steady"; vs. two burst/acceleration cards

**Poison Room** (3 Food → +2 ⚪ ATK, repeatable in-turn) is a burst tool, and
**Expediter** (next building purchased goes straight into play) is an acceleration
tool that specifically defeats the buy→discard→reshuffle→draw delay which is the
main thing making Builders slow. Both are Builder cards. Minor tension; noting it
because Expediter is also the fastest legal route to an early Dojo (A2.3), so it
sits directly on the anti-spike constraint.

### A7.7 🟡 Possession deck placement. MD internally inconsistent, and it touches
Creeping Doom

The theme says *"curses and possessions are hidden throughout the deck"* (singular),
matching MD §8D's header: *"Possession cards are shuffled into the Conjuration
deck."* All seven carry `type:'Conjuration'` in the live data. **But their trigger
text reads "1st **Building** Possession drawn", "3rd **Recruit** Possession
drawn."** If they all live in the Conjuration deck those labels are meaningless
flavour; if they are distributed across three market decks, the §8D header and the
card data are wrong.

**This is not cosmetic for Creeping Doom**; it decides which market slots can
become **Haunted**, which is load-bearing for the Possession-plug ruling
(`MD_UPDATE_QUEUE_v2_3.md` §C2 Point 2) and for the 12-slot loss condition. The
review's analysis assumed Conjuration slots only. **→ Also relevant to
`pve-pressure-designer`.**

---

## A8. Revised ruling requests

W1, W2, W4, W5, W7 from §5 stand. **W3 → resolved YES. W6 → resolved CAP.** New:

| # | Question | Blocks |
|---|---|---|
| **W8** | **Is the pitchfork line being *better* than the pure-Warrior line acceptable?** Farmers are cheaper (2–3 Inf, 19 copies) and self-fund Food, so Trainer + Farmers escapes the Food ceiling that bounds pure Warriors (A4.1). Theme suggests yes. If not, dial **Trainer** (qty 4→2, or forward-only conversion), not the Dojo cap. | Option A magnitude |
| **W9** | **Does "Warriors do not build permanents" exclude Siege buildings?** (A7.1) Reading (a) = Option C is on-theme; reading (b) = Option C is off-theme and the second ATK channel must come from elsewhere. | **Option C entirely** |
| **W10** | **Does "Augury Mages do not create permanents" exclude Oracle/Scribe's Library-Armory line?** (A7.2) Decides whether ask #4 needs a new card at all, or just signposting of the existing Poison Room route. | Ask #4 |
| **W11** | **Measure Necromancer before adding Augury ATK** (A7.5); 4 mages × 2 Auspice changes = 8 ATK, above the Portal threshold, and its only ceiling is the never-measured Auspice-use budget. | Ask #4 |
| **W12** | **War Room's gate** (A7.3); should the Warrior key open the game's printed Farmers-attack card, or is Builder/Oracle gating intentional? | Pitchfork completeness |

## A9. Revised measurement asks

Replacing §6.1 (the 2:1-uncapped comparison is withdrawn; that design is dead):

1. **Turn-by-turn distribution of `min(warriorsPlayedThisTurn, floor(Inf/3))`** for
   a Warrior bot and a Trainer/pitchfork bot. Confirms or refutes the A2.3 table.
   **Pass condition: P(≥4 ATK from Dojo before turn 7) ≈ 0.**
2. **Warrior-vs-pitchfork throughput comparison** (W8); same metric, both builds.
3. **Turn at which Dojo first enters play**, with and without the Expediter line.
   This is the real anti-spike bound and it is a pure deck-cycling question,
   independent of any balance number.
4. **Auspice-use budget per turn** (already requested in
   `V11_CREEPING_DOOM_REVIEW.md` §E6); now doubly needed as Necromancer's only
   ceiling (W11).
5. §6.2 (Influence-value decay vs. razed slots) still stands and is unchanged.

---
---

# ADDENDUM B. Winnability triage (2026-07-25)

The coordinator reports the designer cannot win Creeping Doom and supplied clean
direct-injection measurements. The headline is a mechanical bar independent of bot
skill, so I can reason about it directly. **This addendum re-orders the whole
review's priority; read it as the current top of the stack.**

---

## B1. TRIAGE; ~70% pressure-layer, ~30% card-power, and the split is not additive

**The dominant blocker is a win-condition bug, not a card-power gap.**

### B1.1 The 11-ATK bar is pressure-layer, and it is almost certainly unintended

Confirmed in code (`decideMonsterAction`, line 1306):

```js
if(m.id==='mn_ghoul') return {action:'retreat'};   // Ghoul: no raze, no siege → back to guarding
```

Combined with `isPortalExposed()` (line 1570: *any* monster `guarding` → Portal
blocked), the Ghoul-as-gate change (`MD_UPDATE_QUEUE_v2_3.md` C2, 2026-07-21)
produced an emergent consequence nobody specified:

- Ghoul never razes, so on every monster turn with no permanent to hit he **retreats
  to `guarding`**.
- A guarding monster blocks exposure. So **the Portal can never be attacked while
  Ghoul lives**, regardless of how many other monsters are dead or fielded.
- Ghoul's 4 HP is therefore **welded onto the Portal's 7**. The real bar is
  **11 burst in one turn** (kill Ghoul → exposure flips → still need 7 for the
  Portal, same turn, because exposure re-checks and Ghoul is the only guard). And
  it must be **11 in a single turn**, because unspent ATK does not carry (§4) and
  next monster turn Ghoul would retreat back to guarding if he were somehow still
  alive.

This is the same class of finding as the `V11_MONSTER_PRESSURE_BASELINE.md` Cork B
("a field monster with no valid target retreats to guarding → re-corks the
queue"). The Ghoul-gate rework **re-introduced Cork B for one specific monster**,
and because that monster is pinned to position 1 in 30/30 games, it corks the win
path in every game. The reinforcement system makes it worse: `maybeReinforce`
(line 1357) inserts reserve monsters **sealed and `guarding`**, so each one is a
*fresh* welded-on HP block in front of the Portal.

**Verdict: pressure-layer. Not my domain to fix, but I am flagging it as the #1
blocker (see B4), because no card recommendation is safe until it is ruled.**

### B1.2 Why the split is not additive; and why card-power can't be tuned first

The two problems **multiply**, they don't add. Here is the trap:

- If I tune Warrior/Augury ATK to clear an **11**-ATK bar by turn 14, I have to
  roughly double their output vs. clearing a **7** bar.
- Doubling burst output is *exactly* the early-4-5-ATK spike the designer forbade
  (constraint from the theme pass). There is no way to hit 11-by-turn-14 without a
  curve steep enough to also produce 5-by-turn-8.
- So **tuning the card layer against the buggy bar forces me to violate the card
  layer's own hard constraint.** The bug doesn't just add difficulty; it makes the
  card problem *unsolvable within constraints*.

**This is the decisive triage point.** The 11-ATK bar must be ruled (ideally back
to 7) **before** any Warrior/Augury number is set. Fix order is pressure-first,
card-second; not because pressure is "more broken," but because the card fix is
mathematically blocked until the bar is known.

### B1.3 The residual ~30% card-power problem is real and survives the bar fix

Even at a corrected **7**-ATK bar, the measured facts stand:
- Economy ramp is ~3–4 Inf/turn; a mediocre build made 1–3 permanents in 24 turns.
- The burst-conversion menu is **thin**: Dojo (capped ~5), Poison Room (Food-bound,
  slow), Necromancer (one window), Handler (needs a creature board). None reaches 7
  alone before ~turn 10, and the recurring-ATK permanents that would top them up
  (Siege, Dragon) **get disabled by the very monsters you're racing**.
- Warriors and Augury Mages specifically have **no disable-proof path to burst
  ATK**; which is the actual card-layer finding (B3).

So: **both**, but sequenced. ~70% of *why the designer can't win right now* is the
11-ATK bar; ~30% is that even at 7, the two guilds in question don't convert their
strength into a decisive-turn strike. Fixing only the bar makes the game winnable
by a Siege/Builder turtle; fixing the bar **and** the two guilds makes it winnable
*the way the designer wants those guilds to win*.

---

## B2. Is any current build fast enough to hit the bar by turn ~14–16?

### B2.1 Against the buggy 11-ATK bar: no realistic build, and here's why

**No single burst converter can reach 11**, by construction:
- **Dojo (capped):** max ≈ warriors played ≈ 5–6 → **6 ATK ceiling**, and only on a
  6-Food turn (needs farm permanents) at ~turn 10+.
- **Poison Room:** 11 ⚪ needs ~17 Food in one turn (3 Food → 2 ⚪). That is
  4+ farm permanents all producing, under a mode where Ghoul historically targets
  farms. Not reachable by turn 16.
- **Necromancer:** mages × Auspice changes. 4 mages × 2 changes = 8. To reach 11
  needs 4 mages × 3 changes (three `'any'` Auspice cards in one hand) or 5–6 mages.
  A once-per-game lightning strike, not a reliable line.
- **Handler / creature burst:** bounded by creatures in play, which get disabled.

So 11 **requires stacking recurring + burst**, e.g. 2 Trebuchets (4 🔴 standing) +
Catapult (1 🔴) + a 5-Warrior Dojo turn (5 ⚪) = 10, still short, and it assumes the
three Siege buildings are all **un-disabled** on the strike turn; against monsters
whose whole job is disabling your board. **The fastest curve I can honestly
construct tops out around 9–10 on the turn everything aligns, and collapses if any
Siege piece is disabled.** Practically: **not winnable at 11 by turn 16.** This
matches the designer's lived experience and the measured 7-vs-11 result.

### B2.2 Against a corrected 7-ATK bar: yes, but only just, and only Siege/turtle

Fastest curve to **7 burst**, disable-aware, best case:

| Turn | Action | Standing recurring ATK | Burst available | Total if struck |
|---|---|---|---|---|
| 3–4 | Buy Catapult (6 Inf) | +1 🔴 |; | 1 |
| 5–6 | Buy Trebuchet (8 Inf) | +3 🔴 |; | 3 |
| 7–8 | 2nd Trebuchet | +5 🔴 |; | 5 |
| 9–10 | Dojo in play + 2-Warrior turn | +5 🔴 | +2 ⚪ (Dojo) | **7** ✅ |

So a **Siege-forward Warrior/Builder hybrid clears 7 around turn 9–10**; *if* the
Siege line survives disabling. With Wall Sets buffing Siege DEF (+2 to Creatures &
Siege) and Builder repair keeping them standing, that is achievable, which is why
"turtle behind Walls, build Siege, repair, alpha the Portal" is the game's real
intended solution. The capped Dojo (Option A) is the **top-up that closes the last
2 points** without needing a 4th Siege building; which is precisely the role I
designed it for. **At a 7 bar, A + C do their job.** At 11, they cannot.

**Conclusion for #2:** current cards reach the *intended* 7 bar around turn 9–10 in
a Siege/turtle build; they do **not** reach the *buggy* 11 bar by turn 16 in any
build. The gap between "unwinnable" and "winnable by turn 10" is almost entirely the
4 HP of Ghoul weld.

---

## B3. Card recommendations that make Warriors and Augury *contribute to a win*

Framed around the real card-layer finding (B1.3): **neither guild has a
disable-proof burst.** Recurring ATK permanents get disabled; these two guilds need
a way to convert their *turn's economy/tempo* into ATK that doesn't sit on the board
waiting to be smashed. All of the below assume a **corrected 7-ATK bar** and respect
the three constraints (PvP-identical, no flat-ATK-on-recruit, no early 4-5 spike).

### B3.1 Warriors; the capped Dojo is the right answer; do NOT buff it further

Option A (Addendum A) already gives Warriors a **disable-proof** burst: Dojo
converts *this turn's Influence* to ATK, so the only thing that can be disabled is
the single Dojo building (repairable by a Builder splash; the intended cross-guild
handshake). Its ~5–6 ceiling is the top-up that turns a 5-ATK Siege board into a
7-ATK strike. **That is contribution-to-win, not economy.** No change from Addendum
A. The anti-spike math (A2) already proves it can't produce 4 before turn 8.

The one addition worth considering **only if the bar stays high** (which I
recommend against): let Dojo's exchange accept **🔴 Siege ATK sources as
"students"**; i.e. a Warrior deck's Siege buildings count toward a small flat
bonus. I am flagging and *not* recommending this; it is a band-aid for a bar that
should be fixed at the source.

### B3.2 Augury Mages. AM-1 ("The Hunter") is the win-contribution fix

Restating Addendum A6.1 in win-terms: AM-1 gives Augury a **disable-proof burst on
their own axis** (mages played this turn → ⚪ ATK), gated behind reaching the Hunter
Auspice (an `'any'` Auspice card, which Augury Initiate cannot supply). Because
their hands recycle fast (they draw their own guild), a 3–4 mage turn is repeatable,
making them the guild that can *reliably* contribute 3–4 of the 7 in the decisive
turn; the "another method for mid-game attack" the designer explicitly asked for.
**This is the single highest-value new card in either guild for winnability**,
because it converts the fast-ramp/draw engine (which the designer says is strong)
into terminal damage without a permanent.

⚠️ **Gate it on W11 (measure Necromancer first).** Necromancer already scales on
mages × Auspice-changes and can hit 8 from one card; adding AM-1 on the same axis
risks a combined Augury burst that clears even the corrected 7 bar trivially and
resurrects the spike problem in a different guild. Measure, then set AM-1's per-mage
value (I'd start at exactly +1 and a Hunter-Auspice gate, which Necromancer does not
require; the gate is the differentiator).

### B3.3 The combined-build target (why both, not either)

At a 7 bar the designer's ideal winning turn should read: *Siege board (3–5 standing
🔴, kept alive by Builder repair behind Walls) + a Warrior Dojo top-up OR an Augury
Hunter-turn burst = 7+, struck the turn the exposure window opens.* That is three
guilds cooperating. Builder builds/repairs the engines, Warrior or Augury supplies
the closing burst. It is exactly the cross-faction "engines wielded by other
factions" fantasy from the theme text, and it is **the reason the fixes are a
package**. Neither guild needs to solo 7; each needs to reliably supply its share.

---

## B4. The Ghoul-retreat behaviour; my read (flagged for designer, not my layer)

**Strong recommendation: change it. This is the #1 winnability blocker and it is
almost certainly an unintended emergent bug, not a design choice.** Handing to
`pve-pressure-designer` and the designer, with my card-layer perspective on the
options:

| Option | Mechanic | Card-layer view |
|---|---|---|
| **(a) Ghoul stays `field` once unsealed** (never retreats to guarding) | Once unsealed he's out of portal defence permanently; exposure needs only the *reinforcement* guards cleared | **My preferred.** Restores the intended 7-ATK bar cleanly. Matches the baseline's own recommendation ("queue advancement independent of position-1"). Makes the Dojo/Siege/Hunter math in B2.2/B3 actually reach the win. |
| **(b) A killed guard doesn't need re-killing / exposure keyed on `dead`, not `absent`** | Exposure requires guards *dead*, not merely *not-guarding* | Also works, but changes the whole exposure model (the review §B "Portal Ward" territory the designer already rejected in favour of binary exposure). Bigger blast radius. |
| **(c) Ghoul retreats but exposure ignores Ghoul specifically** | Special-case the gate monster out of `isPortalExposed` | Narrowest fix, but special-casing one monster is fragile and interacts oddly with reinforcements. |

**Why (a):** it is the smallest change that makes the intended bar (7) the actual
bar, it doesn't touch the binary-exposure decision the designer already made, and it
converts Ghoul back into what the rework *intended* him to be; a purchase-tax gate
(the +1 Conjuration Influence tax while alive) rather than an accidental +4 HP weld
on the Portal. The reinforcement-guards-block-exposure interaction should be reviewed
in the same pass (each sealed reinforcement is another weld; that may be intended as
the attrition loop, but it should be a *decision*, not an emergent surprise).

**On "monsters coming too fast" (hypothesis 3):** the *timing* looks roughly right -
12/12 razed by ~turn 19, target ~16, Fiend the reliable turn-8 driver. The problem
is **not** that the doom clock is too fast; it is that the **win clock is broken** by
the 11-ATK weld, so the doom clock always wins by default. Fix the bar and the two
clocks are in a fair race (win reachable ~turn 10, loss ~turn 16–19). I would not
slow the monsters until after the Ghoul fix is measured; that would be treating a
symptom of the win-path bug.

---

## B5. Answers to the three hypotheses, directly

1. **"Warriors aren't strong enough."** *Partly true, mostly downstream of the bar.*
   At the intended 7 bar, capped Dojo + Siege unlock make them a winning closer by
   ~turn 10 (B2.2). At the buggy 11 bar, nothing makes them strong enough without a
   forbidden spike. **Their ceiling is fine; the bar is wrong.** No further Warrior
   buff beyond Addendum A.
2. **"Augury Mages aren't useful enough."** *True, and a real card-layer gap even
   after the bar fix.* In a burst-ATK mode with inert VP, their draw/Auspice/thin
   engine produces no terminal damage except the one Necromancer window. **AM-1
   ("The Hunter") fixes this** and is the highest-value winnability card in the
   review; gated on measuring Necromancer (W11).
3. **"Monsters coming too fast."** *No; the win clock is broken, not the doom
   clock.* Timing is ~right; the 11-ATK weld makes the win unreachable so the doom
   clock wins uncontested. Fix the Ghoul retreat, don't slow the monsters.

---

## B6. New ruling requests (winnability)

| # | Question | Owner | Blocks |
|---|---|---|---|
| **W13** ⭐ | **Fix the Ghoul retreat-to-guard weld** (11-ATK bar → intended 7). Recommend option (a): Ghoul stays `field` once unsealed. | pve-pressure-designer + designer | **Every card number in this review.** Nothing ships until this is ruled. |
| **W14** | **Do sealed reinforcement guards intentionally re-weld HP onto the Portal?** Each `maybeReinforce` insert is another guarding body blocking exposure. Attrition loop or accident? | pve-pressure-designer | Win-path pacing |
| **W15** | **Confirm the intended Portal bar is 7** (not "7 + guards"). If the designer *wants* an 11-ish bar, then AM-1/Dojo need re-tuning upward and the anti-spike constraint must be revisited; flag the collision. | designer | Whether the card layer is even solvable within constraints |

**Bottom line for the coordinator:** pull in `pve-pressure-designer`; the primary
fix (W13) is theirs. My card work (Addendum A: capped Dojo + Siege unlock; AM-1 for
Augury) is correct and ready, but **should not be tuned or shipped until W13 lands**,
because its numbers are only safe against a 7-ATK bar. Fixing cards first would
either underdeliver (against 11) or force an early-game spike (to reach 11) that
breaks the designer's own constraint.

---
---

# ADDENDUM C. Power-curve numbers (2026-07-25, W13/W15 RESOLVED)

The weld is fixed: **Ghoul holds in `field` once unsealed; the "Fifth Protector"
arrives awake+guarding as a one-time final gate and never acts; the player kills it,
then the Portal stays exposed and 7 ATK closes it the *next* turn.** Confirmed
intended bar: **7 ATK to close, achievable across turns (two-turn split), not a
single-turn 11-burst.** This unblocks the card layer and the designer has approved
raising the curve. Concrete numbers below.

**Design frame for every number here:** "spike" = a *single-turn burst* of 4–5 ⚪
from a broken/lucky ramp before ~turn 8. **Recurring board ATK is not a spike**; it
accumulates over turns and rides on permanents the monsters actively disable, so it
is self-limiting. That distinction is what makes a blanket +1 to permanents safe
while a flat +2 on a recruit is not.

---

## C1. Recommended per-turn ATK curve

### C1.1 The "+1 to permanents". I read it as: +1 to the printed per-turn ATK of every ATK-*producing* permanent. Confirmed, with a scope list.

Yes, that is my reading: Siege buildings and creature Conjurations each get **+1 to
their per-turn ATK output**. Not a +1 to DEF, not a +1 to recruits. Exact list:

| Card | Type | Cost | DEF | ATK now | **ATK rec.** | Notes |
|---|---|---|---|---|---|---|
| **Catapult** | Siege 🔴 | 6 | 3 | +1 | **+2** | recurring; DEF 3 is fragile; repair-dependent |
| **Trebuchet** | Siege 🔴 | 8 | 4 | +2 | **+3** | the Siege backbone |
| **Brood** | Creature 🟡 | 5 | 2 | +1 | **+2** | cheap chaff; DEF 2 disables instantly |
| **Armored Hound** | Creature 🟡 | 5 | 3 | +1 | **+2** | |
| **Familiar** | Creature 🟡 | 6 | 4 | +1 | **+2** | + draw on play |
| **Golem Defender** | Creature 🟡 | 7 | 4 | +1 | **+2** | + gives creatures +2 DEF |
| **Tiger** | Creature 🟡 | 8 | 3 | +2 | **+3** | |
| **Gryphon** | Creature 🟡 | 10 | 4 | +2 | **+3** | Flying; the premium closer |
| **Sir Cluckles** | Creature 🟡 | 9 | 4 | +1 | **+2** | +1 🟡/Brood passive rides on top |

**Blanket +1 is the right move here; do NOT make it selective.** Reasons:
1. **It preserves the existing cost/power ordering.** Every card moves up one step,
   so the relative curve (Brood < Tiger < Gryphon) is untouched; no card leapfrogs
   another and no new "best creature" emerges. A selective +1 would reshuffle the
   ranking and require re-tuning costs.
2. **It cannot spike.** The biggest single new permanent is Gryphon/Tiger at 3 🟡,
   cost 8–10, earliest ~turn 8, and it's recurring not burst. One permanent = 3 ATK;
   reaching 7 still needs 2–3 permanents surviving disable across turns.
3. **It is one rule, trivially legible for 8+** ("every fighting unit hits for one
   more"), and one code change (add 1 to `atk_creature`/`atk_siege` at the data
   layer).

⚠️ **One interaction to hand-verify** (`qa-lead`): count-multipliers read the *base*
per-turn value. **Handler** (+1 🟡 per active creature; unchanged, it's a burst not
a per-turn stat), **Sir Cluckles** (+1 🟡 per Brood), **Conjure Master** (+1 🟡 per
creature) all *count* creatures rather than summing their ATK, so the +1 does **not**
double-dip through them. Confirm that live. Golem Defender's DEF aura is unaffected.

### C1.2 The fastest legal curve to 7, with the new numbers

Three builds, all landing in the target turn-9–12 window, none spiking before turn 8:

**Siege / Builder (the backbone):**
| Turn | Buy/play | Standing 🔴 |
|---|---|---|
| 4 | Catapult (6) | 2 |
| 6 | Trebuchet (8) | 5 |
| 8–9 | Trebuchet (8) | **8** (→ 7 useful even with one disabled) |

Reaches 7 by **turn 8–9** if the board survives; realistically turn 9–10 with one
piece disabled and repaired. Wall Sets (+2 DEF to Siege) + Builder repair are what
keep it standing; the intended cross-guild handshake.

**Creature / Conjurer:**
| Turn | Buy/play | Standing 🟡 |
|---|---|---|
| 6 | Brood (5) | 2 |
| 8 | Tiger (8) | 5 |
| 10 | Armored Hound (5) or Handler burst | **7** |

Reaches 7 by **turn 10**, faster with a Handler burst turn (+1 🟡 per creature).

**Warrior / pitchfork + Siege splash:**
Dojo in play ~turn 8 + a 2-Warrior turn (2 ⚪) on top of a Catapult+Trebuchet base
(5 🔴) = **7 by ~turn 9–10.** Dojo is the disable-proof top-up that closes the last
2 without a 4th building.

All three respect the anti-spike bound: earliest 4-ATK is turn 8 (two mid creatures
or a Trebuchet+Catapult), never from a single lucky turn-5 hand.

---

## C2. Trophy ATK values; leave the printed ATK as-is; do NOT apply the +1 to Trophies

Now that killing guards is the mid-game path, Trophies are earned ATK. Current values:

| Trophy | Guard HP to earn | ATK reward | Verdict |
|---|---|---|---|
| **Dragon** | 8 | **+3 ⚪/turn** passive | Correct. Big HP investment → premium reward. Do not raise. |
| **Dank Beast** | 6 | **+1 ⚪ per Active Trophy** | Correct; and now the *engine*: it scales as you stack trophies (2 trophies → +2, 3 → +3). This is the intended "killing guards improves your side" flywheel. Leave as-is. |
| Gargantuan | 6 | +2 DEF to creatures (no ATK) | Enables the creature curve to survive disable; indirectly worth more now. Unchanged. |
| Ghoul / Minotaur / Silent Stalker | 4 / 5 / 5 | utility (Auspice/draw/Legend), no ATK | Fine. |

**Do NOT blanket +1 the Trophies.** Two reasons:
1. **They already scale by construction** (Dank Beast) or are premium one-offs
   (Dragon +3). Adding +1 to Dragon (→4) and letting Dank Beast count it makes a
   Dragon+Dank Beast pair a runaway (+4, +2 = 6 ⚪ from two trophies, before board).
2. **The +1 is a purchasable-permanent buff** to fix the *ramp*; Trophies are the
   *reward*, already tuned as a premium. Mixing the two double-dips the reward path.

⚠️ **The one Trophy number worth a designer look: Dank Beast counts *Active* Trophies
including itself.** With the new curve, a 3-Trophy board yields +3 ⚪ from Dank Beast
alone, on top of each trophy's own ATK. That's a genuine late-game engine (good), but
confirm the designer wants trophy-stacking to be a primary ATK source vs. Siege. Flag,
not a change. → **W16.**

---

## C3. Warrior mid-game ATK abilities (identity = MASS, anti-spike held)

Warriors already get the capped Dojo (Addendum A) + Siege unlock (Option C). The
designer wants 1–2 new/replacement *recruit* abilities. Constraint: no flat ATK on a
recruit, count-scaling, no early spike. Here is the one I'd add and the one I'd
*not*.

### C3.1 ADD; "Vanguard" (new Warrior recruit) ⭐

> **Vanguard**. Recruit · Warrior · Cost 4 · 1 VP · +2 Influence
> **The Muster:** if you played **3 or more Warrior recruits this turn**, gain
> **+2 ⚪ ATK.** (Trainer-converted Farmers count.)

**Why this shape:**
- **Threshold, not per-warrior.** A per-warrior ATK recruit (5 Warriors → 4–5 ⚪) is
  exactly the spike the designer forbade. A **binary 3+ threshold capped at +2** can
  never exceed +2 no matter how many bodies, so it cannot spike, while still
  demanding *mass* (3 Warriors in one turn; a turn-8+ event, gated by hand size and
  Food). It rewards the count identity without scaling into a burst.
- **⚪ Generic**; can hit anything including Portcullis (unlike creature 🟡), so it's
  a clean closer, and it stacks with a Dojo turn: 3 Warriors → Vanguard +2 ⚪ + 3
  Dojo exchanges (3 ⚪) = 5 ⚪ from the Warrior half, + Siege base = the 7. That is the
  designer's "mass overwhelms" turn, and it lands ~turn 9–10, never early.
- **Disable-proof** (it's a recruit burst, nothing on the board to smash).
- **PvP-safe:** in PvP it's 2 ⚪ toward opponent permanents on a heavy-Warrior turn -
  modest, and it competes with the VP-buying the guild does in PvP (Influence spent
  attacking is Influence not spent on VP cards). Self-taxing, same as Dojo.
- `qty` 2–3. Keep it uncommon so it's a payoff you build toward, not a staple.

### C3.2 REPLACE (optional); retune **Siegeman** into the sustained-ATK bridge

Siegeman today: *"Siege +1 ATK this turn; buying Siege needs no Builder."* If Option
C (any Warrior unlocks Siege) lands, the gate clause is redundant. Repurpose the freed
text into a count-scaling **Siege** buff, which keeps Warrior ATK on the recurring
(non-spike) axis:

> **Siegeman**. Recruit · Warrior · Cost 3 · 1 VP · +2 Influence
> Your Siege buildings gain **+1 🔴 ATK this turn per Siegeman you played this turn.**
> (Also unlocks Siege buying, redundant once any Warrior does; kept for PvP.)

- Scales on *Siegeman count* (mass) and on *Siege buildings owned* (board investment),
  so its ceiling is bounded by two slow things at once; no spike.
- Keeps the "Warriors wield Builder engines" theme literal.
- **PvP note:** the unlock clause must STAY in the printed text (Option C is a PvE
  *and* PvP mode-gate change, but if PvP keeps the Builder-only gate for some reason,
  Siegeman is still the Warrior key). Flag for W4.

**Recommendation: ship Vanguard (C3.1) now; hold Siegeman's retune (C3.2) until
Option C's gate ruling (W4/W9) lands**; the two are coupled and retuning Siegeman
before the gate is decided risks stranding the guild's only Siege key.

---

## C4. Augury Mage mid-game ATK abilities. AND the Necromancer numbers you asked for

### C4.1 🔴 Necromancer: measured; it is the OPPOSITE of a spike, plus a type bug

I flagged "up to 8" from the **card text** (MD §8B: *"Each Augury Mage gains +1 ATK
per Auspice change"* = mages × changes). **The live code does not implement that.**
`playCard` (line 2376):

```js
if(S.auspiceChangesThisTurn>0){ S.atk_creature += S.auspiceChangesThisTurn; ... }
```

So the code adds **the number of Auspice changes, once, as 🟡 Creature ATK**; it does
**not** multiply by Augury Mage count. Actual output:

| Auspice changes this turn | Necromancer ATK (as coded) | Card-text intent (mages × changes) |
|---|---|---|
| 1 | **+1 🟡** | mages × 1 |
| 2 | **+2 🟡** | mages × 2 |
| 3 | **+3 🟡** | mages × 3 |

Realistic ceiling ~**2–3 🟡** (bounded by the Auspice-use budget, which
`V11_CREEPING_DOOM_REVIEW.md` §E6 notes has never been measured). **Two bugs:**
1. **Type:** adds 🟡 Creature; text says "+1 ATK" (untyped → ⚪ by §2A catch-all).
   🟡 can't hit Portcullis; wrong for a mage burst. **Should be ⚪.**
2. **Scaling:** code ignores the "each Augury Mage" clause entirely.

**Ruling needed (W17); two clean options, I recommend (b):**
- **(a) Make code match text: mages × changes, as ⚪.** This *is* the spike I
  originally feared; 4 mages × 2 changes = 8 ⚪. If chosen, **cap it** at
  `min(mages × changes, 5)` or cap counted changes at 2. More power, more UI, needs
  the Auspice-budget measurement first.
- **(b) Keep code behaviour, fix type to ⚪, and correct the text to match:**
  > **Necromancer**; *"+1 ⚪ ATK per Auspice change you make this turn."*
  Flat on the change-count, no per-mage multiply. Caps naturally at ~2–3 (the Auspice
  budget). No spike, no cap logic, one-line text fix. **Recommended**; it makes
  Necromancer a modest, reliable closer on the *Auspice* axis, and leaves the
  *mage-count* axis free for AM-1 so the two don't multiply each other into a spike.

### C4.2 ADD. AM-1 "The Hunter" (confirmed, refined) ⭐

> **[New Augury Mage recruit]**. Recruit · Augury Mage · Cost 4 · 1 VP · +2 Influence
> **The Hunter:** each Augury Mage you played this turn gains **+1 ⚪ ATK.**

Confirmed as the highest-value Augury winnability card. Refinements after measuring
Necromancer:
- **Type ⚪** (hits Portcullis; clean closer).
- **Gated by the Hunter Auspice**; the "The Hunter:" prefix means it only fires while
  Hunter is active, and reaching Hunter costs an `'any'` Auspice use (Channeler /
  Witchdoctor / Fallah; **Augury Initiate cannot reach Hunter**; `mystic-harvest`
  only, §3). So the ATK turn is a turn *not* spent on Mystic draw or Harvest food.
- **This gate is the anti-spike guarantee and the anti-stack-with-Necromancer
  guarantee:** AM-1 scales on **mage count under Hunter**; Necromancer (option b)
  scales on **change count** and does not require Hunter. Different axes, different
  gates; a player can't trivially fire both at max in the same turn (firing AM-1
  needs Hunter active; each Necromancer change is a separate Auspice use competing for
  the same budget).
- **Magnitude:** 3 mages under Hunter → 3 ⚪, for 3 Food + 1 Auspice use + the card.
  Same food/hand ceiling as the Warrior model → earliest turn 8, typically 9–11.
  No early spike.
- `qty` 3. It should be findable; it's the guild's *only* reliable terminal damage.

### C4.3 The combined Augury closer (why this is enough, not too much)

A mature Augury turn: reach Hunter (1 use) → AM-1 with 3 mages = 3 ⚪; Necromancer
(option b) on 2 changes = +2 ⚪ = **5 ⚪ burst**, disable-proof, on their own
draw-recycle engine. Add a single Poison Room (Oracle-gated, if W10 permits their
owning permanents) or a Trophy and they clear 7. That is the "mid-game attack method"
the designer asked for, on-identity (Auspice + draw), no permanent required.

⚠️ **Do not also make Necromancer per-mage (option a) if AM-1 ships.** Two per-mage ⚪
bursts on the same guild = the spike returns. Pick option (b) for Necromancer, or if
the designer insists on (a), then AM-1 must be the *only* per-mage card and (a) must
be capped. **These two decisions are coupled; rule them together (W17 + AM-1).**

---

## C5. What must stay UNCHANGED to protect PvP

| Keep as-is | Why |
|---|---|
| **All recruit Influence values (+2, Negotiator/Warlord multipliers)** | The PvP economy→cards→VP engine. Untouched by everything above. |
| **All VP values on all cards** | PvP win condition. The ATK buffs add no VP. |
| **Legend mechanic + Hunter/Sacrificer/King's Note Legend sends** | PvP deck-thinning identity. |
| **Dojo's per-turn exchange CAP (= Warriors played)** | The cap is what stops a non-Warrior PvP deck splashing one Dojo for unlimited Influence→ATK. Load-bearing in both modes. |
| **AM-1 / Vanguard as ⚪ recruit *abilities*, not flat stats** | Keeps them self-taxing against PvP's VP race (ATK spent ≠ VP bought) and honours "no flat ATK on recruits." |
| **Draw/Auspice engines (Pikeman, Swordsman, Scribe, Channeler, etc.)** | PvP tempo/consistency identity; none touched. |

**The one thing above that DOES touch PvP balance, flagged honestly:** the blanket +1
to creature/Siege permanents is a global combat buff that applies in PvP too (more
aggressive board removal and Possession-clearing). It is **symmetric** (both players
get it) and **modest** (one step per unit), so I judge it PvP-safe, but it is the only
change here that isn't PvE-isolated. → **W18: confirm the +1 is intended to apply in
PvP, or should be a Creeping-Doom mode rule.** Note that making it PvE-only would
violate the "same cards in both modes" constraint (it's a stat, not a mode rule), so
my recommendation is to accept it globally.

---

## C6. New ruling requests (Addendum C)

| # | Question | Recommendation |
|---|---|---|
| **W16** | Should trophy-stacking (Dank Beast +1/Active Trophy) be a *primary* ATK source alongside Siege, or capped? | Leave uncapped; it's the earned mid-game flywheel; watch in playtest. |
| **W17** ⭐ | **Necromancer:** (a) mages × changes as ⚪ (capped), or (b) flat +1 ⚪ per change, text corrected? | **(b)**; fixes the type bug, no spike, leaves the mage-count axis to AM-1. |
| **W18** | Does the blanket +1 to permanent ATK apply in PvP (global stat) or only Creeping Doom (would need to be a mode rule)? | Apply globally; it's a stat, symmetric and modest; PvE-only would break the same-cards constraint. |
| **W4/W9** (open) | Siege gate + "Warriors build no permanents"; gates Option C and Siegeman's retune (C3.2). | As Addendum A/B. |
| **W10/W11** (open) | Do Augury Mages own permanents (Oracle/Poison Room line)? Auspice-use budget measurement. | Gates the Augury Poison Room closer and option (a) for Necromancer. |

**Implementation order for the coordinator:** (1) blanket +1 to the C1.1 list; (2)
Necromancer type→⚪ + option-(b) text; (3) AM-1; (4) Vanguard; (5) hold Siegeman
retune for W4/W9. Each is independently verifiable live, and none of (1)–(4) can
produce a pre-turn-8 4-ATK burst; that bound is preserved by cost, Food, hand size,
and the threshold/gate structures, not by luck.
