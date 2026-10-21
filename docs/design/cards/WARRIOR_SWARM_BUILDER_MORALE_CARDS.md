# Warrior Swarm + Builder Morale; card-layer spec (Path A)

**Author:** tcg-designer · **Date:** 2026-09-14
**Owner:** card layer only. Threat side (Minotaur/portal pressure numbers) is
`pve-pressure-designer`'s; design-lead owns the structural pass in parallel.
**Sources read (canonical, not memory):** MD v2.2 §2/§2A/§3/§5/§7/§8; `FACTION_IDENTITIES.md`;
`BUILDER_ATTACK_IDENTITY.md`; `WARRIOR_GUILD_REVIEW.md` (all addenda A/B/C);
`MD_UPDATE_QUEUE_v2_3.md`; live card data in `simulator/cards.json`; the
`warrior_stone` (Sundering Stone) mode logic in `simulator/connivances_simulator_v11_6_4.html`.

**The one bar every ATK engine below is held to** (designer's hard constraint,
`FACTION_IDENTITIES.md` Warriors + `WARRIOR_GUILD_REVIEW.md` A2): **no card or
combination may reach 4–5 ⚪ ATK in a single early turn (before ~turn 8) from a
lucky/broken ramp.** Recurring board ATK that *accumulates over turns* is not a
spike; a *single-turn burst* of 4–5 before turn 8 is. Every number here is chosen
so the spike is impossible by construction, not by luck.

**Why the constraint is provable for the whole Warrior line (the load-bearing
fact):** the 10-card starter deck contains **zero Warriors** (§8A). Every Warrior
must be *bought* (→ discard, §4 "all purchases go to Discard"), cycled through a
reshuffle, drawn, then played for **1 Food each**. Food = 3 + farm permanents, so
with no farm down a player physically cannot play more than 3 cards, and a hand is
only 5 (6 under Mystic). Warrior *count in one turn* is therefore bounded by
`min(Food, hand size, warriors actually drawn)`, and all three bind hardest in the
early game. This is the identical proof the review used to bless the capped Dojo
(A2.2–A2.4); the swarm rides the same rails.

---

## 0. Summary of deliverables

| # | Item | Verdict |
|---|---|---|
| 1 | Warrior **SWARM** archetype | 3-rung Muster ladder (2 new recruits + Vanguard as anchor) + Dojo. Ephemeral ⚪, provably no early spike. |
| 2 | **Siegeman** rework | Keep the card; strip the market-unlock (now redundant). Becomes Siege operator: amplify + repair Siege + self-recur. |
| 3 | Builder **MORALE** keyword | Flat **+1 ⚪/turn per Morale building, hard-capped at +3 total**, gated to a war-engine. Carried by Encampment (new), repriced War Room, Granary. |
| 4 | **Dojo** | Confirm as-is (10 Inf, 3:1, cap = Warriors played). No retune needed; it is the swarm's Influence→⚪ pipe. |
| 5 | Repair consolidation | 3 repair types → 2 (House Hand R1 ×7, Contractor R2 ×5). Total repair uses held at 17. |
| + | **War-Works Operator** (design-lead's must-add) | Builder recruit; +1 ⚪/turn-burst per Siege/Armory/**Morale** building, **hard cap +4**, this-turn only. |

New card IDs proposed: **Footman `w10`**, **War-Captain `w11`**, **War-Works
Operator `b8`**, **Encampment `bg16`** (use next free ids at implementation).

---

## 1. Warrior SWARM archetype

### 1.1 The fantasy, mechanically

Warriors are **ephemeral mass**: many foot soldiers rallied *this turn*, "fighting
together" for a burst of ⚪ ATK, then gone to the discard (no permanents; §ident.
"Warriors do not build permanents, with the Dojo being the exception"). The swarm's
burst **escalates with the number of Warriors played this turn (N)** — but every
per-card payoff is a **capped threshold ("Muster N")**, never a `+X per Warrior`
multiplier. The escalation comes from *more payoff cards firing as N rises*, not
from any single card scaling without bound. That is the difference between "mass" and
"a spike printer," and it is what keeps the archetype inside the bar.

**Keyword — Muster N:** *"if you played **N or more** Warrior recruits this turn,
[effect]."* Trainer-converted Farmers count as Warriors (the pitchfork army;
`MD_UPDATE_QUEUE` D5 + A4.3 — one shared "counts as a Warrior this turn" predicate,
no exceptions). Reads off the live `warriorsPlayedThisTurn` counter. Already in the
game: **Vanguard `w9` = "Muster 3: +2 ⚪."** The seed is planted; this spec grows it
into a 3-rung ladder.

### 1.2 The payoff curve (roles, numbers, copies)

All three are **Recruit · Warrior · non-permanent (→ discard) · ⚪ Generic ATK**
(⚪ so the swarm can hit anything including Portcullis; §2A). ⚪ ATK is added to the
pool on play and does not sit on the board — **disable-proof**, exactly what the
review (B3) wanted for Warriors, and permanent-free, honouring the identity.

| Rung | Card | Cost | +Inf | Muster clause | ⚪ cap/copy | qty |
|---|---|---|---|---|---|---|
| Body / baby rally | **Footman** `w10` (NEW) | 2 | +2 | **Muster 2:** +1 ⚪ | +1 | **4** |
| Mid payoff (anchor) | **Vanguard** `w9` (exists) | 4 | +2 | **Muster 3:** +2 ⚪ | +2 | **3** (was 2) |
| Capstone (stepped) | **War-Captain** `w11` (NEW) | 5 | +2 | **The Muster:** +1 ⚪ (2+), +2 ⚪ (4+), **+3 ⚪ (6+)** | +3 | **1** |

- **Footman** is the cheap, common body that makes going *wide* feel rewarding: two
  bodies already earns a point. Its low cost (2) is the "many foot soldiers" card;
  qty capped at 4 (not 5) so that 2-Warrior hands don't become common *too* early
  (see §1.4 proof).
- **Vanguard** stays the mid rung; qty raised 2→3 so the archetype has a reliable
  middle. This is the only stat change to an existing Warrior recruit.
- **War-Captain** is the escalation engine on a *single card*: a monotonic step
  table, **hard-capped at +3**, whose top tier demands **6 Warriors in one turn**
  (= 6 Food = two farm permanents + a big hand; a turn-12+ event). qty 1 keeps it a
  build-around payoff, not a staple.

Bodies also feed the guild's existing count-scalers — **Negotiator** (+1 Inf/other
Warrior) and **Warlord** (+1 Inf/other Warrior) — which turn mass into Influence,
which **Dojo** (§4) turns into more ⚪. So the swarm has two ⚪ channels off the same
bodies: the **Muster bursts** (instant, ephemeral) and the **Dojo pipe** (Influence
→ ⚪). Both escalate with N; both are individually capped.

### 1.3 What a mature swarm turn looks like (turn ~10, no siege)

Harvest, 2 farm permanents down (Food 5–7), Dojo in play, hand = Footman, Footman,
Vanguard, War-Captain, Negotiator → **N = 5 Warriors**:

- Footman ×2 (Muster 2) → **+2 ⚪**
- Vanguard (Muster 3) → **+2 ⚪**
- War-Captain (4+ tier; 6+ not met) → **+2 ⚪**
- Base Influence: 5×2 + Negotiator (+4) = **14 Inf**
- Dojo: cap = N = 5, 14 Inf ÷ 3 = 4 trains → **+4 ⚪**

**Total ≈ 10 ⚪ this turn, entirely non-siege, ephemeral, disable-proof.** That is a
fully-assembled turn-10 mass strike (the sanctioned window), and it is *far* more
than the Sundering Stone tutorial needs (§4.3). Crucially it is **unreachable before
turn 8** — proven next.

### 1.4 Combo-prevention: the early-spike is impossible by construction

The only thing the constraint cares about is the **early** bound. Held to the same
`min(Food, hand, warriors-drawn)` ceiling as the Dojo:

| Milestone | Earliest turn | Why it cannot come sooner |
|---|---|---|
| Any swarm ⚪ at all | ~turn 5–6 | Starter deck has 0 Warriors; the first bought Footmen must reshuffle and be redrawn before a **Muster 2** (2 bodies) can even fire. |
| **+3 swarm ⚪** | ~turn 6–7 (high-roll) | Needs 3 Warriors in one 5-card hand, all bought turns 3–5 and cycled. Food 3 suffices, so no farm required, but drawing the specific trio is high-variance. |
| **+4 swarm ⚪** | **turn 7 at the absolute floor** | Requires exactly {Footman, Footman, Vanguard} = 3 bought bodies in hand. This equals the review's own blessed floor ("4 ATK earliest turn 8, structurally impossible before turn 7", A2.3). |
| **+5 swarm ⚪** | **turn 8+** | Requires **4+ bodies** in one turn → 4 Food → **a farm permanent already down** → not a turn-≤7 event by the Food proof. |
| War-Captain **+3 tier** | ~turn 12+ | Needs **6 Warriors** in one turn = 6 Food (2 farms) + a 6-card hand of bought Warriors. |

**The provable guarantee:** because 5 ⚪ from the swarm requires **4 Warriors**, and
4 Warriors requires **4 Food = a farm permanent already in play**, the swarm cannot
produce a 4–5 ⚪ *spike* before a farm is down and the bodies are cycled — a turn-8+
composite in every line. No single card exceeds +3 (War-Captain, and only at 6
bodies), so no lucky single draw can spike. This is the **identical bar** the
Warriors were held to before, now honoured by the swarm.

**Un-splashable:** every payoff is gated on *Warriors played this turn*, so a
Conjurer/Builder deck holding a Footman gains nothing — same protection the capped
Dojo has (A2.5). The swarm belongs to the guild that commits bodies.

### 1.5 Roster note

Warriors go 9 → 10 recruit **types** (Footman, War-Captain added; a plain
+2-Inf-body was avoided so the additions carry the archetype rather than pad it).
This is within tolerance; the guild's identity is *count*, and the two new cards are
count-payoffs, not economy sprawl.

---

## 2. Siegeman rework

**Keep the card. Remove the market-unlock** — it is now dead weight, because *any*
Warrior in play already opens the Siege market (W9, APPROVED and live;
`MD_UPDATE_QUEUE` "Warriors guild; market-gate rulings"). Repurpose the freed text
into the **Siege operator/amplifier** the crossover was always meant to be.

> **Siegeman** `w5` · Recruit · Warrior · Cost 3 · 1 VP · +2 Influence
> **Operate the engines.** Your active Siege buildings gain **+1 🔴 Siege ATK this
> turn per active Siege building you control.**
> **Repair 1** disabled Siege building (immediate; any Siege-subtype only).
> You **may place this Siegeman on top of your deck** instead of discarding it.

Notes on each clause:

- **Amplify (+1 🔴 per active Siege permanent):** with 1 Catapult down = +1 🔴; with
  Catapult + 2 Trebuchets = +3 🔴 added to the pool this turn. Two Siegemen in a turn
  double it (+6 🔴 on that board). This is the Warrior *"out-wield: few engines, big
  multiplier, one window"* verb (`BUILDER_ATTACK_IDENTITY` §6), distinct from the
  Builder's breadth verb.
- **Repair 1 Siege only:** gives the operator staying power without stealing Builder's
  general repair (Builder keeps *all* non-Siege repair; §5). Scoped and thematic — the
  crew keeps *its own* engine firing. Also the exact ability the Sundering Stone
  tutorial's copy already promises ("a Siegeman can repair Siege").
- **Self-top-deck:** the operator "stays with the engine" — replay Siegeman next turn
  to re-amplify. A soft recursion (not a Legend send, not card advantage), reusing the
  existing Swordsman top-deck UI pattern.

**Anti-spike check:** the amplifier is bounded by *Siege permanents owned* — each
costs 6–8 Inf, DEF 3–4, must be bought + cycled + played, and monsters actively
disable them. Earliest 1 Siege down ≈ turn 7–8, so earliest Siegeman value is **+1
🔴 at turn 8**. +3 needs 3 Siege permanents (turn ~12); the big +6 two-Siegemen turn
is a turn-12+ heavy-board alpha strike — the sanctioned decisive blow, never an early
spike. No hard cap needed: the Siege-permanent count is self-limiting (expensive,
fragile, disable-able).

**Is it still worth a card without the unlock?** Yes, decisively. It is now the only
Warrior card that (a) repairs anything, (b) multiplies Siege output on the wield
axis, and (c) recurs itself. Three distinct Warrior-flavoured jobs on one recruit,
where before it was a redundant key + a weak +1.

> ⚠️ **PvP flag (W4, still open):** if PvP ever keeps a Builder-only Siege gate,
> Siegeman loses its only key there. Recommend the printed text also retain a small
> "(unlocks Siege)" rider in PvP builds, or raise Siegeman qty. Coupled to W4/W9 —
> hold that half until the gate ruling lands; the amplifier/repair/recur half is safe
> to ship now.

---

## 3. The Builder MORALE keyword

Bryan's idea: buildings that otherwise wouldn't hold weapons gain a "Morale" tag that
grants **recurring per-turn ATK** — the Builder's "buildings add attack" identity,
*low/slow/steady breadth*. This is the single most dangerous mechanic in this pass
(recurring permanent ATK over a cheap wide durable board = an ATK printer), so its
caps are load-bearing and stated first.

### 3.1 Precise definition

> **Morale (permanent):** at the **start of your turn**, while this building is
> Active, add **+1 ⚪ Generic ATK** to your attack pool.
> **Cap:** your total Morale contribution is **at most +3 ⚪ per turn**, no matter how
> many Morale buildings you control.
> **Gate (recommended):** Morale ⚪ counts only while you also control at least one
> **Siege or Armory** building (troops need a war effort to have morale for).

Four properties do the safety work:

1. **Flat +1, never "per building" — linear, not superlinear.** Each Morale building
   is worth exactly +1 ⚪/turn. There is no multiplier that a wide cheap board
   (Farms/Walls) can amplify. This is the difference between Morale and the forbidden
   "+1 ⚪ per active building" printer.
2. **Hard global cap +3.** Fielding 5 Morale buildings still yields +3. This is the
   explicit answer to "must not enable an unbounded late engine." +3 ⚪/turn is
   meaningful (≈ one Trebuchet) but bounded forever.
3. **Recurring, not burst; ⚪; disable-pausable.** Reuses the *existing*
   COMPLETION_BONUSES recurring-⚪ path (War Room's set bonus already renders "+1 ⚪ to
   pool" each turn and auto-pauses on disable). **Near-zero new UI/animation budget** —
   it is the same "+N ⚪ at start of turn, chip on the card, pauses when disabled"
   pattern the engine already ships.
4. **Gate ties it to offense.** A pure Farm/Granary turtle with no war engine gets no
   Morale ⚪. Optional (the +3 cap alone already prevents the unbounded case) but it
   adds coherence and blocks the "3 cheap civic buildings, zero attack, grind" cheese.
   For an 8+ audience the cap is mandatory; the gate is a recommended-not-required
   second lock — ship the cap first, add the gate if playtest shows civic-turtle abuse.

### 3.2 Which buildings carry Morale

Only the "wouldn't otherwise hold weapons" civic/support permanents:

| Building | Change | Rationale |
|---|---|---|
| **Encampment** `bg16` (NEW) | Cost 5 · DEF 5 · 2 VP · subtype `Encampment` · **Morale: +1 ⚪/turn** · requires Builder · qty 3 | The flagship durable, cheap, wide Morale body — the "encampment" permanent from the Path-A intent. Non-set-eligible (no completionBonus); breadth is rewarded by Morale up to the cap, not by pairs. |
| **War Room** `bg13` | **Reprice 11 → 8 Inf**; add **Morale: +1 ⚪/turn**; keep Armory subtype + set bonus "+1 ⚪ pool" | Fixes the documented **trap** (11 Inf, needs a 22-Inf pair before it did anything). A single War Room now contributes +1 via Morale *immediately*, self-satisfies the Morale gate (it IS Armory), and its Armory set bonus still stacks. This is design-lead's Route B "reprice War Room" pick, realised. |
| **Granary** `bg14` | Add **Morale: +1 ⚪/turn** (cost/DEF unchanged) | The storehouse that feeds the troops — a small martial upside for the food-banker, on-theme. |

Three Morale sources → the +3 cap is reached exactly by a *full civic board*, which
is the Builder's slow-win shape: buy durable buildings, keep them standing with
repair, bank +3 ⚪ every turn.

### 3.3 Interaction with set bonuses

Morale and COMPLETION_BONUSES are **independent, separately-bounded systems** that
stack:

- Morale (capped +3) is a per-building tag.
- The **Armory set bonus** on War Room ("+1 ⚪ pool", recurring, `bg13`
  completionBonus) is a *pair* payoff and is **not** counted against the Morale cap.
- Two War Rooms → +2 from Morale (2 buildings, under cap) **+** +1 from the completed
  Armory set = **+3 ⚪/turn from 16 Inf**. Bounded on both axes (Morale cap; one set
  per subtype, locked after completion — §5). No runaway.

### 3.4 Interaction with the War-Works Operator (design-lead's recruit)

This is the pairing the combo-prevention flag in `BUILDER_ATTACK_IDENTITY` §B1
worried about. Designed so the two **compose but cannot multiply into a printer**:

> **War-Works Operator** `b8` · Recruit · Builder · Cost 4 · 1 VP · +2 Influence
> **War Drums:** gain **+1 ⚪ ATK this turn** per active **Siege, Armory, or Morale**
> building you control, **maximum +4.** Unlocks the Buildings market.

- **Counts only engine/war-effort subtypes** (Siege, Armory, Morale-tagged) — **never
  Farm, never Wall.** A wide cheap Farm/Wall board gives it nothing. This is the
  design-lead's "count only a subset of subtypes" mitigation, made concrete.
- **Hard cap +4.**
- **This-turn burst, not recurring.** It is a Handler-style on-play conversion (mirror
  of Handler's "+1 🟡 per active creature"), so it does **not** add to the standing
  Morale engine — it doesn't create an unbounded permanent stack.
- **Anti-spike:** +2 needs 2 engine buildings down (turn ~7–8); +4 needs 4 (turn
  ~12+). Bounded at +4 forever. A recruit, so disable-proof, and gated by how many
  Operators you can play (hand/Food/qty).

**Combined Builder ⚪ ceiling** (a maxed turn-14+ board — the intended "war economy
battering the keep"): Morale **+3** (recurring) + Operator **+4** (burst/copy) + Siege
recurring **~5–7** (fragile, disable-able) + Armory set **+1**. Every component is
capped or board-bound; **none can spike before turn 8** (each ⚪ point costs a full
durable building or a gated recruit), and the late total cannot run away because Morale
and Operator are both hard-capped and Siege is self-limiting. That is *low/slow/steady
breadth* with a real payoff and no printer.

---

## 4. The Dojo

**Confirm as-is — no retune needed.** Current live data (`bg8`): Building · School ·
Cost 10 · DEF 5 · 2 VP · requires Warrior · *"Each Warrior you played this turn may
train: 3 Influence → +1 ⚪ ATK"* (cap = `warriorsPlayedThisTurn`).

- It is the Warriors' **reliable non-siege ATK source** ("train to fight", Inf → ⚪),
  and the only Warrior permanent (identity-correct).
- 3:1 rate + cap-at-Warriors is already proven anti-spike (`MD_UPDATE_QUEUE`: no
  farm → Food 3 → ≤3 cards → ≤3 ⚪; 4+ needs a farm; 7-from-Dojo-alone unreachable).
  It rides the exact same Food proof as §1.4, so the swarm and the Dojo are held to
  one bar.
- **Do not make it cheaper or 2:1.** The cap already ties throughput to Warrior
  density (mass), which is the correct scaling axis; a rate cut would add a second
  axis and re-open the spike (the withdrawn 2:1 design, review A1).

The Dojo is the swarm's **fifth channel body-count already feeds**: bodies → Inf
(Negotiator/Warlord) → Dojo ⚪, on top of the Muster bursts. Confirmed good.

### 4.3 Sundering Stone (Minotaur) tutorial: swarm + Dojo alone must win — it does

The `warrior_stone` mode is a **race**: a shared **100-HP Boulder**; whoever deals
more damage to it wins (ties to the player). The **Minotaur** deals ≈ base 3 → +1
every 4 turns → capped 6 to the Boulder, minus his Guard/Gore/Recover/War-Cry-windup
turns (many turns he deals the Boulder 0). Net Boulder damage ≈ **3–4/turn early,
5–6 late**. The player must simply out-pace that with the pool each turn (Strike
Boulder), or kill the 28-HP Minotaur to freeze his total and finish uncontested.

**Swarm + Dojo output vs. that pace (no siege):**

| Turn | Player ⚪ available (swarm + Dojo) | Minotaur Boulder dmg |
|---|---|---|
| 6–7 | ~2–3 (a Footman/Vanguard Muster + first Dojo trains) | ~3–4 |
| 8–9 | ~4–5 (Muster 3–4 bodies + Dojo) | ~4–5 |
| 10+ | ~6–10 (§1.3 mature turn) | ~5–6 |

From turn ~8 the swarm matches then overtakes the Minotaur's Boulder pace, and the
mature turn (§1.3) can also **burst the 28-HP Minotaur down** in ~4–5 turns to end
his contribution entirely. **Swarm + Dojo alone clears the tutorial; siege is
optional flavour, not mandatory** — which is the Path-A goal (siege refocused onto
Builders). It stays inside the bar because the early-turn (≤7) output is
farm/hand/cycle-bound to ≤3 ⚪, so the player cannot trivialise the race with an early
spike.

**Handoff to the mode owner (not a card change):** the `warrior_stone` recruit
allow-list is currently `{w1,w5,w6,w8,f3,f4}` with Vanguard/etc. held as win-rewards.
To teach *swarm + Dojo*, add the swarm ladder to the pool: **`w9` Vanguard, `w10`
Footman, `w11` War-Captain** (and keep `f3/f4` farms so Food reaches 4–5 for the mass
turns). The Dojo (School) is already in `modeBuildings` for this mode. This makes the
sanctioned tutorial win-line the swarm, not the guaranteed-Siegeman siege line.

---

## 5. Repair consolidation

Collapse three near-redundant repair recruits to **two** (light + heavy), higher
copies, **total repair volume held constant** (Builder's durability pillar must not
be diluted; only the type count is).

| Keep/merge | Card | Cost | +Inf | Repair | qty | Uses |
|---|---|---|---|---|---|---|
| **Keep** (light) | **House Hand** `b1` | 3 | +2 | **Repair 1** | **7** | 7 |
| **Merge b2→b3** (heavy) | **Contractor** `b3` | 4 | +2 | **Repair 2** | **5** | 10 |
| **Remove** | ~~Repair Master `b2`~~ | — | — | — | — | — |

- **Total repair uses = 7×1 + 5×2 = 17** — exactly today's 17 (House Hand 7×1 +
  Repair Master 4×1 + Contractor 3×2). Volume preserved; card *types* 3 → 2; total
  cards 14 → 12.
- **Repair Master's only distinction** was its recent +3-Inf buff — not worth a
  distinct type (design-lead §4). Folded away; Contractor stays +2 Inf (the repair
  volume is its payoff). If a heavy-repair Influence sweetener is wanted, +3 Inf on
  Contractor is a safe dial — it touches no ATK math.
- Both keep the "unlock Buildings market" rider and "immediate on play, use any time"
  timing. Repair stays **100% Builder-exclusive** (Siegeman's Siege-only repair in §2
  is a scoped exception, not general repair).
- The freed recruit-type slot absorbs the **War-Works Operator** (§3.4), so Builder
  recruit *types* stay flat at 7 while the guild finally gains its own ⚪ producer.

---

## 6. Open items / handoffs

| # | Item | Owner |
|---|---|---|
| M1 | **Morale global cap value.** Set to **+3**; derived from "a full 3-building civic board is the intended ceiling." If playtest wants more Builder breadth reward, +4 is the only safe upward dial (adds one more Morale building's headroom); do **not** remove the cap. | tcg-designer + playtest |
| M2 | **Morale gate (Siege/Armory required).** Recommended but optional; ship the cap first. Confirm whether an 8+ audience should carry the extra clause. | design-lead |
| S1 | **Siegeman PvP unlock rider** (W4/W9). The amplify/repair/recur rework is safe now; hold the "remove unlock" half for PvP builds until the gate ruling lands. | designer |
| W1 | **War Room reprice 11 → 8 + Morale tag** touches the Armory set/Dojo-headroom question (still open in `MD_UPDATE_QUEUE`). Rate-independent — War Room no longer competes with Dojo on ⚪ *rate* — so low risk, but flag it with the W1 set-keying ruling. | designer |
| Q1 | **Verify no double-dip:** confirm Morale ⚪ (permanent start-of-turn) and the War-Works Operator burst (this-turn) are summed once each, and that the Operator's building count and Morale's cap read the same `S.permanents` active set. Same class of check as the C1.1 count-multiplier note. | qa-lead |
| T1 | **`warrior_stone` allow-list** add `w9/w10/w11` so the tutorial teaches swarm + Dojo (not siege). | mode owner |

**PvP protection (unchanged from review C5):** all recruit Influence values,
Negotiator/Warlord multipliers, VP, Legend, the Dojo cap, and the draw/Auspice
engines are untouched. New swarm ⚪ and Builder ⚪ are **recruit/permanent abilities,
not flat stats on the card face**, so they self-tax against PvP's VP race (ATK spent
≠ VP bought) and honour "no flat ATK on a recruit." The only globally-applied stat is
Morale's +3-capped recurring ⚪, which is symmetric and modest.
