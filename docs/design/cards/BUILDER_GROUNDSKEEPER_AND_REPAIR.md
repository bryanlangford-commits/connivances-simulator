# Builder — Groundskeeper + Repair Consolidation (Path A rework)

**Author:** tcg-designer · **Date:** 2026-09-15
**Owner:** card layer only (stats/numbers/copies). design-lead owns the parallel
identity pass (new Builder mechanic + Groundskeeper fantasy fit). Threat side is
`pve-pressure-designer`'s.
**Sources read (canonical, not memory):** live `simulator/cards.json` (Builder
recruits b1–b7, Farm buildings bg1/bg2, Granary); repair engine in
`simulator/connivances_simulator_v11.html` (`useRepair`, `repairUsesAvailable`,
`grantMidTurnIncome`, the ORDERING-TRAP note ~L1326); prior specs
`WARRIOR_SWARM_BUILDER_MORALE_CARDS.md` §2 & §5, `BUILDER_ATTACK_IDENTITY.md` §4;
`MD_UPDATE_QUEUE_v2_3.md` (Repair Master +3 buff); `docs/qa/TEST_PLAN.md` (repair
DEF-reset bugs — none of which this card touches).

---

## 0. Summary

| # | Item | Verdict |
|---|---|---|
| 1 | **Groundskeeper** (NEW) | Recruit · Builder · **id b9** · Cost 2 · +1 Inf · 1 VP · **Repair 1 disabled FARM only** · qty **2**. A cheap, early, narrow food-engine insurance card. Worth a slot; niche is clear (see §2). |
| 2 | **Repair consolidation, revised** | House Hand **b1 R1 ×7 → ×5**, Contractor **b3 R2 ×5** (unchanged), Groundskeeper **b9 R1(Farm) ×2** (new). Headline total repair uses stays **17**; *flexible* repair drops 17 → **15**, with 2 uses re-specialised into farm-only. Repair budget does **not** bloat. |
| 3 | **Combo/abuse** | No food/repair loop possible. Repair restores only a farm's *baseline* output (`grantMidTurnIncome`), never extra — it is protection, not printing. Hard-capped by copies drawn × Food × hand. Single-use → discard, no recursion. Safe. |
| ⚠ | **Engineering blocker** | Scoped repair **does not exist in the live engine** — `repairUsesAvailable` is one untyped pool. Groundskeeper (Farm-only) AND the already-spec'd Siegeman (Siege-only) both depend on a new typed-repair mechanism. Spec in §4. This is the one real build item. |

**ID note:** live Builder recruits end at **b7**. **b8 is reserved** for the
already-spec'd **War-Works Operator** (`WARRIOR_SWARM_BUILDER_MORALE_CARDS.md`
§3.4), which is not yet in `cards.json`. Groundskeeper therefore takes **b9**. If
War-Works Operator lands on a different id, Groundskeeper uses the next free b-id.

---

## 1. Groundskeeper — stat block

> **Groundskeeper** `b9` · Recruit · Builder · Cost **2 Inf / 1 Food** · **1 VP**
> **+1 Influence. Unlocks Buildings.**
> **Repair 1** disabled **Farm** (immediate on play; usable any time this turn;
> targets buildings of subtype `Farm` only).

Concrete data fields (mirrors the b1/b3 record shape in `cards.json`):

| field | value | note |
|---|---|---|
| `id` | `b9` | b8 reserved for War-Works Operator |
| `name` | Groundskeeper | |
| `guild` / `subtype` | Builder / Builder | |
| `type` | Recruit | non-permanent → Discard on play (§4 purchase rule) |
| `cost_inf` / `cost_food` | **2** / 1 | cheapest Builder repair; playable turn 2–3 |
| `vp` | **1** | matches every Builder recruit baseline |
| `inf` | **+1** | deliberately *below* House Hand's +2 (see §2 niche) |
| `atk_*` / `def` / `permanent` | 0 / 0 / false | no ATK on a recruit (Builder rule, `BUILDER_ATTACK_IDENTITY` §3) |
| `isBuilder` | true | so it is a Buildings-market key like b1/b3 |
| `repairCount` | **1** | one repair use granted on play |
| `repairScope` (NEW field) | **`"Farm"`** | the scoping tag — see §4; House Hand/Contractor = `null` (any) |
| `qty` | **2** | Bryan's "~2 copies" |

Timing/scope confirmed against the existing pattern: `playCard` does
`S.repairUsesAvailable += card.repairCount` on play, and the use is spent any time
that turn via `useRepair` (L2206–2208, L2607–2618). Groundskeeper rides that exact
path; the only delta is that its granted use must be **restricted to Farm-subtype
targets** (new — §4). Same "immediate, use any time this turn" timing as House Hand
and as the revised Siegeman's Siege-only repair.

### Why a Farm-only repairer earns a card (vs. just using House Hand)

House Hand (general R1, cost 3, +2 Inf) can already repair a farm. Groundskeeper is
still worth a slot on **four distinct axes**, each of which House Hand fails:

1. **Cheaper / lower on the curve.** Cost 2 vs 3. It is playable on turn 2–3 before
   the economy is online, when a general R1 is often unaffordable and House Hand is
   still buried in the deck. Early is exactly when a lost farm hurts most.
2. **Food-engine insurance, specifically.** Food gates *how many cards you can play
   each turn* (Food = 3 + farm permanents; the whole `min(Food, hand, drawn)` ceiling
   that every ATK proof in this line leans on). A farm disabled early is a tempo
   death-spiral: fewer Food → fewer plays → slower rebuild. Groundskeeper is dedicated
   protection for the resource that everything else is gated on.
3. **It does NOT dilute the flexible repair budget.** Because it *can't* touch
   Siege/Wall/Armory/Library, its 2 uses are worth strictly less than a general use —
   which is precisely why we can add it without bloating repair volume (§3). It is a
   sidegrade in scope, not an upgrade in power.
4. **Curve/variety ("mix it up").** Gives Builder a genuine 2-drop repair play so
   early hands are less likely to be dead, and gives deck-curation a cheap
   engine-protection pick that isn't the workhorse House Hand.

The balancing cost that keeps House Hand relevant is the **+1 Inf (vs +2) and the
Farm-only lock**: in any non-farm-repair situation House Hand is strictly better
economy and strictly more flexible. Groundskeeper never replaces House Hand; it
undercuts it *only* on cost, and *only* for the farm-protection job.

---

## 2. Role division — three repair cards, three clear jobs

The order must not end up over-repaired, and each card needs a lane. Post-change:

| Card | id | Cost | +Inf | Repair | Scope | qty | Lane |
|---|---|---|---|---|---|---|---|
| **Groundskeeper** (NEW) | b9 | **2** | +1 | R1 | **Farm only** | **2** | Cheap early food-engine insurance. First repair you can afford; narrow. |
| **House Hand** | b1 | 3 | +2 | R1 | **any** | **5** (was 7) | The flexible workhorse light repair + best light economy. Tutorial starter. |
| **Contractor** | b3 | 4 | +2 | R2 | **any** | 5 | Heavy general repair (2/card). The durability backbone for a wide late board. |

Clean separation on **three** axes so no two cards collapse into each other:

- **Cost axis:** 2 (Groundskeeper) < 3 (House Hand) < 4 (Contractor).
- **Scope axis:** Farm-only (Groundskeeper) ⊂ any (House Hand, Contractor).
- **Volume axis:** R1 (Groundskeeper, House Hand) < R2 (Contractor).

Groundskeeper wins on price and loses on flexibility; House Hand is the flexible
middle and the better economy; Contractor is the expensive heavy that carries a wide
disabled board. No card is a strict upgrade of another. **Repair Master (b2) stays
removed** (already agreed in the prior spec — its only distinction, the +3-Inf buff,
was not worth a type; `MD_UPDATE_QUEUE` "Repair Master +3").

---

## 3. Repair-budget math — volume stays controlled

Bryan's steer: reduce House Hand and consolidate so there is **room** for
Groundskeeper without bloating the repair budget. The move is to trim House Hand
7 → 5 (−2 flexible uses) and re-specialise that headroom into 2 farm-only uses.

| State | Cards | Total uses | Flexible (any-target) | Farm-only |
|---|---|---|---|---|
| **Today (live)** | HouseHand ×7 (R1) + Repair Master ×4 (R1) + Contractor ×3 (R2) | **17** | 17 | 0 |
| **Prior spec (consolidation only)** | HouseHand ×7 (R1) + Contractor ×5 (R2) | **17** | 17 | 0 |
| **THIS spec (+ Groundskeeper)** | HouseHand ×5 (R1) + Contractor ×5 (R2) + Groundskeeper ×2 (R1 Farm) | **17** | **15** | **2** |

- **Headline repair uses stay at 17** — the durability pillar's nominal size is
  unchanged, so the number that gets quoted in reviews doesn't move.
- **Flexible repair actually DROPS 17 → 15.** The 2 new uses can only hit farms, so
  they are worth less than the 2 general uses they replaced. Net effect: the order's
  *general* repair power is slightly **reduced**, not bloated — exactly the guard
  Bryan asked for. Adding a card made repair narrower, not stronger.
- **Card count:** 14 (today) → 12 (prior spec) → **12** (this spec: 5 + 5 + 2).
  No sprawl; still down two cards from today.
- Both general repairers keep the "Unlocks Buildings" rider and "immediate on play,
  use any time this turn" timing. Repair stays 100% Builder-exclusive; Groundskeeper's
  Farm-only and Siegeman's Siege-only are scoped exceptions, not general repair leaking
  to other guilds.

**Why trim House Hand and not Contractor:** House Hand and Groundskeeper are the two
closest substitutes (both R1 light). Specialising part of the *light* repair budget
into farm-only is coherent; Contractor is the heavy backbone and should stay intact
so a wide late board can still be held up. Trimming the heavy card instead would hurt
Route-A durability, which is the point of the pillar.

---

## 4. Engineering blocker — scoped repair must be built (spec)

**The live engine has no scoped repair.** `useRepair(permUid)` (L2607) spends from a
single untyped integer `S.repairUsesAvailable` and accepts any disabled non-creature
building. Nothing in the data or the function reads a subtype restriction. Therefore:

- Groundskeeper's **Farm-only** repair, and
- the already-spec'd revised **Siegeman's Siege-only** repair
  (`WARRIOR_SWARM_BUILDER_MORALE_CARDS.md` §2),

**both** require the same new mechanism. Recommend building it once, cleanly:

**(a) Data.** Add a field `repairScope` to recruit records:
`null` = any building (House Hand b1, Contractor b3), `"Farm"` = Groundskeeper b9,
`"Siege"` = Siegeman w5. (Values are building `subtype` strings.)

**(b) State.** Replace the single `repairUsesAvailable` integer with a small **list
of scoped tokens**, e.g. `S.repairTokens = [{scope:null}, {scope:"Farm"}, …]`, pushed
on play (`repairCount` copies of `{scope: card.repairScope}`). Keep a derived count
for the existing UI banner (L3603/L4659) so the "N repair uses available" display and
the click-to-repair flow are unchanged for the player.

**(c) `useRepair` target check.** When repairing a building, only spend a token whose
`scope` is `null` OR equals the target's `subtype`. Reject the click otherwise ("This
repairer only fixes Farms").

**(d) Allocation order — avoid the ORDERING TRAP.** The engine already documents this
class of bug (the Ghoul/Famine farm ordering-trap, ~L1326): a scoped use silently
wasted because a general use was spent where the scoped one should have gone. When a
Farm is repaired and BOTH a `Farm`-scoped and a `null` token are available, spend the
**most restrictive matching token first** (Farm-scoped before general). That preserves
general uses for the buildings only they can fix. Same logic for Siege.

This is a contained change (one field + one small list + one filter + a spend-order
rule). No new UI/animation — it reuses the existing "click a disabled permanent to
repair" flow. **Handoff to qa-lead:** add a case confirming (i) Groundskeeper cannot
repair a disabled Wall/Siege/Armory/Library/Granary, (ii) a Farm token is spent
before a general token when a Farm is the target, (iii) headline repair count in the
banner still reads correctly with mixed scopes.

---

## 5. Combo / abuse check — "protect the engine," not "print resources"

**Claim: a cheap Farm-only repairer over a wide farm board cannot create a
degenerate food/repair loop.** Verified against the engine:

1. **Repair restores baseline, never extra.** `useRepair` sets `disabled=false` and
   calls `grantMidTurnIncome(p,'Repair')`, which restores the farm's *printed*
   +Food/turn (bg1 = +2, bg2 = +1) — the food it would have produced un-disabled. It
   does **not** grant bonus food, does not double-harvest, does not re-trigger on
   subsequent turns. Repairing a farm gives back only what disabling took away. This
   is protection, not generation. There is no positive feedback term, so no loop.
2. **Hard-capped by physical resources.** Groundskeeper grants exactly
   `repairCount:1` per copy on play; qty 2 → **at most 2 farm repairs per turn**, and
   only if both copies are drawn *and* affordable (2 Food + 2 Inf + 2 hand slots).
   Bounded by the same `min(Food, hand, copies-drawn)` ceiling as everything else in
   this line.
3. **No recursion.** Groundskeeper is a non-permanent recruit → Discard on play. It
   cannot repair itself, cannot re-grant its own use, cannot chain. Each use is a
   one-shot from a card that has already left play.
4. **Scope caps the ceiling.** Even a full farm board (bg1 ×5 + bg2 ×6 available) does
   nothing to change that only 2 Groundskeeper uses exist per turn; a wide board does
   not multiply the repairer the way it would multiply a "+1 per building" printer.
   Groundskeeper reads off *nothing* about board width.
5. **Famine interaction is safe (and not an exploit).** Repairing a farm under Famine
   (Auspice 3) restores 0 food that turn, because farms produce 0 during Famine. You
   cannot farm-repair to dodge Famine. (`GHOUL_FAMINE_PASSIVE` is currently `false`,
   so the historical ordering-trap does not apply; if it is ever re-enabled, honour
   the §4(d) spend-order rule so the Farm token isn't wasted while Famine holds.)

**Verdict:** the worst case is a player spending a cheap card to undo a disable on a
farm, recovering the food that farm normally makes. That is the intended "keep the
engine running" outcome and is strictly weaker, per point, than House Hand's general
repair. It stays firmly on the "protect the engine" side of the line.

---

## 6. Handoffs

| # | Item | Owner |
|---|---|---|
| G1 | **Identity fit.** Confirm Groundskeeper's fantasy sits under the new Builder mechanic and the faction's "they repair / keep engines standing" spirit (`FACTION_IDENTITIES.md`). Numbers here assume a pure utility recruit with no ATK. | design-lead |
| G2 | **Granary scope decision.** This spec locks Groundskeeper to subtype `Farm` **only** (bg1, bg2) and **excludes Granary** (subtype `Granary`) — Granary banks food, it isn't a per-turn producer, and a tight scope keeps the card clean. If design-lead wants Granary covered, widen `repairScope` to accept `{Farm, Granary}` (trivial data change). Recommend keeping it Farm-only. | design-lead |
| G3 | **Scoped-repair engine mechanism (§4)** — the one real build item; shared with Siegeman's Siege-only repair. Confirm no hidden coupling with the repair DEF-reset fixes already in `TEST_PLAN.md` (§B1 / Wall-Set-strip). Those touch `recomputeStoredDef`, not the use-counter, so expected independent — please verify. | engineering |
| G4 | **QA cases** for scope enforcement + spend-order + banner count (§4). | qa-lead |
| G5 | **Tutorial-pool inclusion.** Groundskeeper is a natural fit for the `builder_castle` allow-list (cheap, teaches "keep the food engine up"), but pool membership is the mode owner's call — flagging, not deciding. | mode owner |
| G6 | **ID confirmation.** Groundskeeper = **b9**, assuming War-Works Operator takes **b8**. If implementation order differs, assign the next free b-id and update this table. | engineering |

**PvP note:** Groundskeeper adds no flat ATK, no VP-race stat beyond the standard
1 VP / +1 Inf recruit baseline, and only a scoped defensive utility — it self-taxes
in the VP race and does not touch any PvP-sensitive multiplier. Safe.
