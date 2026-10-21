# The Omen Lock. Integrated Spec

**Status:** Design spec (not yet built). Assembled from a design-lead pass (progression +
experience) and a tcg-designer pass (mechanics + card fit). Build target:
`simulator/connivances_simulator_v11_6_4.html`.

## Concept

A **reward chest locked by an auspice "combination lock."** The load-bearing rule:

> **A tumbler clicks NOT when you *select* an auspice, but when you *produce that
> auspice's signature effect* while it's active.**

That single rule is what makes the device *teach* instead of matching symbols; you
cannot open the lock without experiencing what each auspice actually does. "Being in
the auspice is not the same as producing its effect" is the exact lesson (and the core
of the hidden pick-by-feel tier). We rejected DDR/rhythm (engine is turn-based) and
pure slot-machine symbol matching (teaches nothing).

**IRON RULE compliance:** the whole device is a mode-level actor (`S.lock`), mirroring
today's tutorial boss `S.tut`. It only *reads* public turn state + two tiny global
telemetry counters. **No card is re-stated.**

Auspice index map (confirmed in code): `0=Mystic, 1=Hunter, 2=Harvest, 3=Famine,
4=Winter, 5=Usurp`.

---

## 1. Tumbler → trigger table (mechanics)

| Tumbler | Clicks when you PRODUCE… | Actor reads | Plumbing |
|---|---|---|---|
| **Mystic 🌙** | a card drawn off Mystic's bonus (start-of-turn +1, or on-switch +1) | `S.mysticBonusDrawsTotal` delta | **1-line hook ×2** |
| **Harvest 🌾** | bonus farm food under Harvest (base+1 per active Farm) | `auspice===2` × active-Farm count, accrued each start-of-turn | none (derived) |
| **Famine 💀** | a turn ends held under Famine with ≥1 active Farm zeroed | end-turn: `auspice===3` && activeFarms≥1 && `!irrigatorPlayedThisTurn` | none (derived) |
| **Winter ❄️** | an unplayed card carried across a turn boundary (Dormancy) | hand-uid snapshot diff, `auspice===4` | none (derived) |
| **Usurp 🪙** | a recruit slot actually replaced by a reshape | `S.usurpReplacementsTotal` delta | **1-line hook** |
| **Hunter 🦅** | a card enters Legend while Hunter is active | `S.legendSentEver` delta && `auspice===1` | none (already emitted) |

**The only two hooks (pure telemetry, same category as existing `S.legendSentEver` /
`S.auspiceChangesTotal`; touch no card logic):**
1. Mystic bonus-draw sites (on-switch draw + start-of-turn draw): `S.mysticBonusDrawsTotal = (S.mysticBonusDrawsTotal||0) + drawn;`
2. Usurp reshape success branch (`if(fresh){…}`): `S.usurpReplacementsTotal = (S.usurpReplacementsTotal||0) + 1;`

Everything else derives from state that's already public. **Do not hook the cards; the
actor polls.**

Why these exact triggers: Mystic counts *only* its two draw calls (not any hand-size
bump; avoids Familiar/Scribe false positives). Harvest/Famine are passive, so the
honest observable is "farm output actually changed," which forces the player to build a
Farm engine first; that IS the lesson. Winter's freeze already logs. Hunter counts any
Legend entry while in auspice 1 (truthful: "a card went to Legend under Hunter").

## 2. Charge counts (N) per tumbler per tier

Charge is counted in each tumbler's **natural unit** (draws, cumulative food, carried
cards, replacements, sends, held-turns). "Dwell" tumblers scale up in the hard tier so
the player sits in the effect and feels it accumulate.

| Tumbler (unit) | Tier A Match-all | Tier B Sequential | Tier C Hidden |
|---|---|---|---|
| Mystic (bonus draws) | 1 | 1 | 2 |
| Harvest (cumulative bonus Food) | 2 | 2 | 4 |
| Winter (cards carried) | 1 | 1 | 2 |
| Usurp (replacements) | 1 | 1 | 2 |
| Hunter (Legend sends under Hunter) | 1 | 1 | 1 |
| Famine (turn-ends held, farm zeroed) | 1 | 1 | 2 |

Hunter stays 1 in every tier (it's already hardest to reach; needs a full 'any' augur -
and each send costs a card). Harvest carries the "watch it pile up" weight (food is cheap
per tick).

## 3. The three lock tiers

**Tier A. Match-all.** Click every tumbler to its charge count, any order. State:
per-tumbler `{auspice, need, have, clicked}`; `opened = tumblers.every(t=>t.clicked)`.
End-of-turn the actor folds in that turn's deltas. Pure "experience all six."

**Tier B. Sequential combination.** Tumblers must fill **in a fixed teaching order:**
**Mystic → Harvest → Famine → Winter → Usurp → Hunter** (draw an engine → grow food →
feel it die → learn to hold → learn to meddle → learn to sacrifice). State: `order[]`,
`ptr`. Only `tumblers[order[ptr]]` accrues; at `need`, `ptr++`.
**Out-of-order = NO-OP-WITH-HINT, not reset:** producing a later auspice's effect early
does nothing and logs *"The Omen Lock resists; it listens for the [Harvest] tumbler
next."* (Resetting punishes exploration and breaks the legibility contract; a reset
variant is a one-line swap if a puzzle mode is ever wanted, but not recommended for a
tutorial.)

**Tier C. Hidden pick-by-feel.** Each tumbler's target auspice is face-down; revealed
on its first charge (or via Seer, §4). **Warmer/colder tell** derived purely from
`S.auspice`: switching into auspice X makes any still-hidden tumbler whose secret target
is X **half-turn** (warm glow, *"A tumbler stirs…"*); producing that effect finishes the
click and reveals it. Per-tumbler adds `hidden`, `revealed`, and a transient `warm`
(a live function of `S.auspice`, no persistence). Uses the Tier-C charge column.

## 4. The Seer (a10). YES, and it fits Tier C beautifully

Seer's "reveal hidden fate" maps perfectly onto revealing a face-down tumbler; the same
verb it already performs. **Iron-rule-safe:** Seer's own `revealsSeal` branch runs
unchanged; in this mode `S.monsterQueue` is empty, so the card harmlessly logs "no seals
to reveal." The **mode actor** adds the tumbler reveal by watching public play state: at
end-of-turn, if `S.played` contains a Seer (`c.revealsSeal` / `id==='a10'`), reveal the
still-hidden tumbler **closest to completion** (highest `have/need`) and log *"🔮 The
Seer's eye opens a tumbler: [Harvest]."* Restricted to **Tier C** (inert in A/B, which is
correct). Balance: Seer qty 3 → reveals 3 of 6, leaving 3 to find by feel; reveal-closest
(not player-picked) keeps it a *tell*, not a *skip*.

**Other cards to feature as lock-pick tools:** Augury Initiate (`ai`, the cheap
`mystic-harvest` enabler; backbone, reaches the 4 benign tumblers; seed generously);
Channeler/Witchdoctor/Fallah (the 'any' augurs; the ONLY way to reach Hunter & Famine
tumblers, so any tier including those must guarantee at least one 'any' augur reachable);
Reaper (`f4`, Harvest gives +2 food; accelerates the Harvest charge).

**Trivializers to keep scarce/out:** stacked 'any' augurs let a player bounce
auspices and cheaply charge the on-switch tumblers (Mystic/Usurp); acceptable for a
tutorial, but keep 'any' augurs comparatively scarce so Hunter/Famine still take effort.
Necromancer (`a8`) does nothing in a combat-free room; leave out or keep as a harmless
red herring, never required. Irrigator (`f2`) actively *suppresses* the Famine tumbler
(see §10); feature only to teach the counter; otherwise keep rare.

---

## 5. Reward-progression map (experience)

**The Lock is the tutorial campaign's connective tissue**; it teaches the *auspice
layer that sits on top of all guilds*, not a single guild's loop. Spine metaphor:
**each guild tutorial you finish "cuts a key"** (demonstrating one auspice adds its
tumbler to your known ring); the capstone asks for the whole ring.

**Two forms, distinct jobs:**
- **Embedded chest**; a small themed lock that appears in the tutorial's boss slot
  *after the boss falls*, as a victory-lap objective. Recurrence + painless onboarding.
  Low tumbler count, easiest tier, unfailable. Reuses the `mz` slot + the post-win state.
- **The Omen Vault**; a standalone capstone mode (`{id:'omen_vault'}`), placed *after*
  the guild tutorials in the dropdown so it reads as the final exam. All six auspices,
  the hard tiers, scored.

**Pedagogical auspice order (easy-to-produce → hard):** Harvest → Mystic → Famine →
Usurp → Winter → Hunter.

**Tier ramp mapped onto progression:**

| Stage | Where | Tier | Tumblers | Charge | Failable |
|---|---|---|---|---|---|
| First contact | end of Tutorial: Augury | match-all | 1 (Harvest) | 1 | No |
| Warm-up | Seer's Apprentice (Augury II) | match-all | 3 (Harvest, Mystic, Famine) | 2 | No |
| Recurrence | end of each other guild tutorial | match-all | 1 (themed) | 1 | No |
| Combination | Omen Wheel mode (if built) | sequential | 3–4 | 2–3 | Soft (no-op hint) |
| **Graduation** | **The Omen Vault** | hidden pick-by-feel | 6 (all) | Tier-C | Soft (scored) |

**Rewards = access + cosmetics, NOT VP** (keep VP inside real modes; the tutorial
layer's currency is *access to the next mode* + *fantasy*: a "seal" cosmetic per chest,
a master-key flourish at the Vault). Card-pack rewards stay small (training wheels).

## 6. Mode structure & failability

- **Embedded chests / match-all: unfailable** (matches the existing tutorial philosophy -
  "you cannot fail, only learn"). You can only take longer.
- **Sequential & pick-by-feel: soft-fail**; a wrong action is a no-op-with-hint or a
  reel that simply hasn't charged; **never a defeat screen.**
- **The Vault is scored, not won/lost:** star rating on turns-to-open + leftover auspice
  uses (3★ = under par with uses to spare; 1★ = opened at all).
- **Length:** embedded 1–3 turns; Seer's Apprentice 4–6; the Vault 6–10.
- **First-time onboarding:** freeze the board on the win beat, spotlight one reel, one
  line; *"This is an Omen Lock. It listens for results, not choices. Switch to Harvest
  and let a Farm pay out; the tumbler reacts when the food actually lands."* Teach by the
  animation, not a wall of text.

## 7. Moment-to-moment & the "satisfying click"

Renders into the same `mz` host as `renderTutorialZone`. Lock face = a vertical stack of
tumbler reels + a shackle + a charge readout, styled like the existing `cf-host` block.
When embedded post-boss, the boss frame fades to ~40% and the lock slides into its place.

| Moment | Sight | Feel | Board link |
|---|---|---|---|
| Idle reel | dim, glyph greyed, `0/N` pips | silent |; |
| Effect produced (1 charge) | reel spins ¼-turn, a pip lights, glyph brightens | soft *tick* | trail from the changed resource to the reel |
| Reels filling (N>1) | pips light in sequence, reel climbs | rising *tick…tick…* | trail each charge |
| Tumbler clicks | reel SNAPS vertical, glyph flares gold | firm **CLACK** | brief flash |
| Pick-by-feel warmer | face-down reel half-turns, amber glow | low *hum up* |; |
| Pick-by-feel colder | reel recoils, dims blue | dull *thunk* |; |
| Final click → lid pop | reels aligned, shackle springs, lid hinges open, reward rises | big **CH-CLUNK** |; |

The **produce → trail → tick** chain is load-bearing; it teaches "results, not choices"
without words. The satisfying click *is* the feature, so at minimum CSS transforms + one
audio cue per beat should be budgeted.

## 8. Composition with the Almanac & the Omen Wheel

**The Lock is the substrate; the Almanac and Omen Wheel are *drivers* upstream of it.**
- **Seer's Almanac** (per-turn demand → set the omen): each answered demand clicks a
  tumbler. Almanac = the challenge, Lock = the payoff; same loop, two faces.
- **Omen Wheel** (spin many auspices for a burst): each productive spin clicks a tumbler.
  Wheel *spends* auspice-uses for a short-term burst while the Lock *collects* for a
  long-term payoff; they share the auspice-use pool, so frame them as *two payoffs from
  the same spins*, not rival sinks.

Net: **one reward mechanism (the Lock), multiple drivers (raw play / Almanac demands /
Wheel spins).**

## 9. Ship this FIRST (v1); both agents agree

**Match-all, 3 tumblers (Harvest → Mystic → Famine), charges Harvest 2 / Mystic 1 /
Famine 1, embedded as a post-boss victory chest at the end of the existing
`tutorial_augury` mode.**

Why: reuses the mode that already teaches auspice switching (Harvest/Famine are already
its fiction; Mystic is one step away; the tutorial text already mentions Soothsayer under
Mystic). Match-all is the most forgiving tier (no ordering/hidden logic), so it validates
the tumbler UI, the "produce-not-select" reading, and the satisfying-click feedback with
the least new rules. Slots into existing plumbing (new post-win state in `mz`, no new
`MODES` entry, doesn't touch Creeping Doom). Get the click feeling right here, then
escalate to sequential (Wheel) and pick-by-feel (Vault).

## 10. Build notes, risks & the legibility contract

**Plumbing:** two one-line telemetry counters (`S.mysticBonusDrawsTotal`,
`S.usurpReplacementsTotal`); the other four tumblers derive from existing public state.
Actor plugs into the `endTurnCore` mode-branch (`else if(S.mode==='omen_lock'){ omenLockTurn(); }`)
+ a `renderOmenLockZone(mz)`, mirroring `S.tut`.

**Risks:**
- **Pick-by-feel warmer/colder** has no natural distance metric over 6 discrete auspices -
  the tell is *scripted proximity* (in vs. not-in the secret auspice), not a real
  gradient. Expect this tier to need the most iteration; prototype the click feel in v1
  first.
- **Board-state gates:** Harvest needs an active Farm; Hunter needs a recruit in play to
  send; Famine needs a Farm to zero; Usurp no-ops on an empty recruit deck. If the
  prerequisite is missing, the actor MUST log the reason.
- **Irrigator vs. Famine tumbler:** Irrigator keeps farms alive under Famine, so the
  Famine tumbler correctly *won't* click that turn; log *"Irrigator kept your farms alive
 . Famine's tumbler stays silent."* so it doesn't read as a bug.
- **Starting auspice:** if the room starts in Harvest, turn-1 farm food auto-charges the
  Harvest tumbler before the player "chose" it; fine for Tier A; for B/C start in an
  auspice that's last in the teaching order, or begin scoring after the first
  player-initiated switch.

**Legibility contract (all tiers):** every charge, click, and near-miss emits an
`addLog`. Click: *"🔓 Mystic tumbler clicks (1/1); you drew off the Mystic bonus."*
Near-miss: *"You are in Winter, but no card was held; end a turn with a card still in
hand to turn the tumbler."* The player must never see a tumbler move (or refuse to) with
no printed reason.
