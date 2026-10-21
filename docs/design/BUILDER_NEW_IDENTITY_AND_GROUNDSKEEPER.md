# Builder: Groundskeeper + a New Order Signature (identity pass)

**Owner:** Design Lead (identity + structure). Card stats, costs, and copy counts
are `tcg-designer`'s call — this doc hands them the shape, not the numbers.
**Reads (current agreed design):** `BUILDER_ATTACK_IDENTITY.md`,
`WARRIOR_SWARM_AND_BUILDER_MORALE.md`,
`cards/WARRIOR_SWARM_BUILDER_MORALE_CARDS.md`, `FACTION_IDENTITIES.md`.

Answers two owner asks: (1) evaluate the **Groundskeeper** (cheap farm-only
repairer); (2) propose **one genuinely new** Builder-order signature beyond the
current pillars (siege, permanents, repair, set bonuses, Morale).

Builder recap this sits on: Builders **out-build** — a wide board of cheap durable
engines, recurring output, kept standing by repair; low/slow/steady; they own
siege + permanents. Warriors out-wield (ephemeral swarm). Repair is now
consolidated to two pillars: **House Hand** (R1 general) + **Contractor** (R2
general); Repair Master dropped.

---

## ASK 1 — The Groundskeeper (2-cost, farm-only repair, ~2 copies)

### Verdict: yes, it earns a slot — but as a satellite, not a third repair pillar.

The card is defensible **because its niche is more distinct than the card we just
cut.** Repair Master died because it differed from House Hand by only +1 Influence
— no real role. Groundskeeper differs on **three** axes at once:

| Axis | House Hand (b1) | Groundskeeper |
|---|---|---|
| Cost | 3 | **2** (cheaper; the "nothing else to do turn 2-3" play) |
| Target | any building (general R1) | **Farm-subtype only** |
| Role in the arc | late-game war-engine durability | **early-game economy insurance** |

That is a genuine micro-role, not a reskin. Keep it farm-**only**: the narrow
target is the guardrail that stops it collapsing back into "a cheap House Hand" and
re-creating the sprawl the consolidation just removed. The moment it can repair
anything, it *is* House Hand and should be cut.

### Is "protect your food engine early" a coherent Builder micro-role? Yes.

- Builders are the faction most dependent on a **standing economy**: low/slow/steady
  means the wide durable board only pays off if the Influence/Food substrate that
  funds it survives the early turns. Farms are that substrate.
- Protecting farms early is **economic defense**, a different job from House
  Hand/Contractor's job (keeping war engines — Siege/Armory/Morale buildings — above
  the disable threshold late). So it broadens the repair identity along the
  timeline rather than duplicating within it: early economy vs late war-works.
- It also feeds the rest of the out-build engine: farms up → Food up → the Builder
  reaches Encampment / War-Works Operator / Morale online sooner. Groundskeeper is
  quiet ramp-protection for the whole §Morale/§Route-B plan.
- No turf conflict: Farmers **make** food, Builders **repair**. Repair is 100%
  Builder-exclusive, so a Builder tending farms is on-theme, not a Farmer steal.

### Does it change House Hand / Contractor counts? Minimally, and only House Hand.

The two general-repair pillars stay exactly as consolidated (House Hand R1,
Contractor R2). Groundskeeper is a **third, narrow, cheap satellite** — state that
explicitly so the 2-pillar shape survives on paper.

- Source its ~2 copies primarily by **trimming ~1 House Hand copy**, not Contractor.
  Rationale: Groundskeeper overlaps House Hand's *early* window (both can patch a
  farm cheaply), so a small House Hand shave keeps the deck from carrying redundant
  cheap early repair. **Do not touch Contractor** (heavy repair is the load-bearing
  late-game pillar; it must not thin).
- Total repair *volume* is `tcg-designer`'s to hold. Their consolidation pinned it
  at 17 uses. Two options, their call: (a) keep 17 by shaving House Hand to offset
  the farm-repair uses Groundskeeper adds, or (b) let volume tick up slightly as
  deliberate early insurance. My structural lean: **hold ~17**, source from House
  Hand — this is a *reshaping* of early repair, not more of it.

### Handoffs / flags for ASK 1

- **To `tcg-designer`:** exact cost (owner says 2), Influence rider, Repair value
  (R1 vs "restore a disabled Farm to active"), copy count (owner says ~2), and the
  House-Hand offset. Keep total repair volume ~constant; keep Contractor untouched.
- **Kill-criterion for QA/playtest:** if it plays as "a cheaper House Hand" rather
  than "early farm insurance," it has failed its niche — cut it. The farm-only
  restriction is the thing that must earn its keep.
- **Scope note:** this is the *only* place the clean 2-pillar repair shape gets a
  satellite. Do not let a "Wall-only" or "Siege-only" repairer follow it in — those
  are Fortifier/Meurtrière and Siegeman territory already.

---

## ASK 2 — A new Builder signature: **RAISE** (fortification tiering)

One mechanic, and I'd build this one: Builders alone can **RAISE a standing
building in place — upgrade it to a stronger tier without rebuilding it.** The
castle-raising verb, made literal. "You don't tear it down and start over; you
raise the walls higher."

### The pitch

Certain Builder permanents are printed as the **base tier** of a short chain. A
Builder card (or an on-building action) can spend Influence to **advance an active
building one tier**: same board slot, same instance, upgraded profile — more DEF,
more output, and (the signature payoff) a **higher disable threshold**, so raised
buildings shrug off the monster attacks that knock plain ones offline.

Rough shape (numbers to `tcg-designer`):

```
Watchtower (base)  --RAISE-->  Keep  --RAISE-->  Citadel
  DEF 3, +1 output       DEF 5, +2 output    DEF 7, +3 output, disable-resistant
```

- **RAISE is incremental and cheap per step**, not a lump upgrade — you climb over
  several turns, low/slow/steady by construction.
- A building can only be raised while **Active** (not disabled), so **repair gates
  raising**: you must keep it standing to build on it. This laces RAISE directly
  into the existing durability pillar rather than bolting on a new subsystem.
- Raised buildings still count for **Morale**, **War-Works Operator**, and **set
  bonuses** at their subtype — RAISE deepens the board the other pillars already
  read, it doesn't sidestep them.

### Why it's Builder, and only Builder

- **Genuinely new.** No faction transforms a permanent it already owns. Conjurers
  *summon* fresh permanents; Warriors/Augury make none. Upgrading-in-place is
  unclaimed design space and unmistakably "carpenter/mason."
- **Reinforces the durability pillar instead of adding a rival one.** The payoff of
  raising is *survivability* (higher tier = above the disable threshold). Builders
  become the one faction whose board gets **harder to disable over time** — a direct,
  memorable answer to the Creeping Doom pressure model, where every rival's board
  degrades. That is the Builder fantasy (the keep that only grows stronger under
  siege) expressed as a mechanic.
- **Keeps the out-build verb, adds a depth axis.** Breadth is horizontal (Morale /
  War-Works count buildings); RAISE is the **vertical** axis on the same board. It
  stays distinct from the Warrior verb precisely because it is **permanent and
  slow** — no this-turn multiplier, no spike window. You invest turns, not tempo.
  Guardrail below keeps it from drifting into "few big engines" (the Warrior lane).

### Distinctness check (vs the other orders)

| Order | Their verb | Why RAISE doesn't collide |
|---|---|---|
| Warrior | out-wield: ephemeral swarm, single-turn spike | RAISE is permanent + slow, no burst window |
| Augury | Auspice/global-state control, draw, one burst | RAISE touches your own board, no global state, no draw |
| Conjurer | summon *new* permanents | RAISE upgrades an *existing* one; opposite motion |
| Builder (existing) | breadth (Morale/War-Works), repair, sets | RAISE = new *depth* axis; feeds all three, duplicates none |

### Guardrails (hand the numbers to `tcg-designer`)

- ⚠️ **Depth must not become the Warrior spike.** RAISE output climbs slowly and
  **permanently**; there is no this-turn multiplier. Cap the chain length (2-3
  tiers) and keep top-tier output modest (≈ a Trebuchet, not a finisher). The
  Builder still wins on cumulative total, never on peak.
- ⚠️ **Fold raised output under the existing Builder ATK budget.** The three-channel
  budget (Siege + Morale + War-Works) already has a "steady-not-spiky, behind the
  swarm's peak, ahead on sustain" ceiling in `cards/WARRIOR_SWARM_BUILDER_MORALE_CARDS.md`
  §3.4. A raised building's extra output must be budgeted **inside** that ceiling,
  not on top of it — otherwise raising becomes a fourth uncapped printer.
- ⚠️ **Anti-early-spike, same hard bar as everything else.** Each RAISE step costs
  Influence and requires the base building already down and Active; getting to top
  tier is a multi-turn composite (build → keep alive → raise → raise). Prove the
  top tier is unreachable before ~turn 8-10, the same way Morale/War-Works were
  proven.
- **Un-splashable:** gate RAISE on a Builder (the raising card requires Builder, or
  raiseable buildings require a Builder to advance), so it belongs to the order that
  commits to the board — same protection Morale/Muster carry.

### ⚠️ Technical-risk flag (not mine to rule — engineering must confirm)

- **RAISE itself looks low-to-moderate risk.** It's a data-level transform of one
  `S.permanents` entry into a higher-tier profile (much like the existing
  disable/repair flag toggle, or swapping the card's stat block). No new UI class;
  it can reuse the permanent-card render + a tier chip.
- **One coupling to check before spec-final:** set-completion (`COMPLETION_BONUSES`)
  and Morale both key off **subtype**. If RAISE changes a building's subtype
  (Watchtower→Keep→Citadel as distinct subtypes), it could silently break or
  double-count set bonuses / Morale eligibility. Safer engine shape: **keep the
  subtype stable across the chain and only swap the stat/output profile.** Engineering
  to confirm which is cheaper and whether anything else reads the permanent's identity.

### Runner-up I considered and rejected (for the record, not the spec)

- **Adjacency / placement bonuses** (buildings buff neighbors). Strong flavor, but
  the engine appears to model permanents as an **unordered list** with no spatial
  layout — adjacency would need a positional/grid system built from scratch. That is
  a real engineering lift and outside my competence to price. **Not recommended as
  the pick** for that reason; RAISE delivers the same "castle grows" fantasy with a
  data-level change instead of a new spatial subsystem. If the owner loves adjacency,
  route a feasibility question to engineering first — don't spec on the assumption
  it's cheap.

---

## Consolidated handoffs

**To `tcg-designer` (numbers + safety):**
- Groundskeeper: cost, Influence, Repair value/wording (farm-only), ~2 copies, and
  the House-Hand copy offset; hold total repair volume ~constant, leave Contractor
  untouched.
- RAISE: tier count (2-3), per-step cost, per-tier DEF/output, disable-threshold
  values, and the mechanism (upgrade card vs on-building action). Fold raised output
  **inside** the existing 3-channel Builder ATK ceiling. Prove no pre-turn-8 spike.
  Keep subtype stable across the chain (see tech flag).

**To engineering (feasibility, not mine to rule):**
- Confirm a `S.permanents` entry can be transformed in place (tier swap) with no
  hidden coupling — specifically that set-completion and Morale keying off subtype
  won't misfire if a building's stat profile changes. Confirm subtype-stable chains
  are the cheaper path.

**To mode owner:**
- If Groundskeeper and/or a raiseable building should teach in the Builder tutorial
  (`builder_castle`), they'll need adding to that allow-list once stats land — same
  as the War-Works Operator hook already flagged in `BUILDER_ATTACK_IDENTITY.md` §7.
