# Seer — Second Skill: Options Menu

Ideation only. A menu of candidate replacements/upgrades for the Seer's generic
`effect1` ("+2 Influence."), so the Seer stays live in modes **without** hidden
seals (Bot, Conjurer Duel). The signature `effect2` ("Reveal one hidden monster
seal condition." / `revealsSeal`) stays untouched as the doom/PvP skill.

Card baseline (cards.json `a10`): Augury Mage, 3 Inf + 1 Food, VP 1, +2 Inf,
non-permanent recruit, qty 3.

**Design frame:** modest, low rules-overhead, forecaster/"sees through the veil."
Must avoid the niches already held by other Augury Mages — plain draw (Mage
Caller), plain change-Auspice (Channeler/Witchdoctor/Initiate/Fallah), unlock
Libraries/Armories (Oracle), Conjuration bypass (Soothsayer), +Food-per-mage
(Herbalist), Augury-Mage ATK payoffs (Necromancer/Doomsayer). All numbers are
first-pass; **tcg-designer owns final costing/balance.**

Mode families referenced: **Doom** (creeping-doom PvE, hidden seals, monsters
hit permanents), **Duel** (Conjurer castle-vs-castle: summons, siege, walls,
fliers, persistent damage), **Bot** (single-player VP race).

---

## Option A — "Read the Omens" (foresight discount) ★ recommended

> **Read the Omens:** Look at the top card of your deck; you may place it on the
> bottom. The next card you play this turn costs 1 less Influence (min 0).

- **Hook:** the forecaster reads the immediate future and times a good bargain.
  Peek + shove-to-bottom is veil-sight; the discount is "I saw this coming."
- **Doom:** tempo to deploy answers a turn sooner; the bottom-shove smooths a
  bad topdeck under clock pressure.
- **Duel:** brings a summon/siege/wall online one beat earlier — pure tempo,
  no new attack printed.
- **Bot:** straightforward efficiency in a VP race; always relevant.
- **Power/complexity:** low overhead, one peek + one discount. Universally
  useful without being splashy.
- **Risk:** chains with cheap recruits for a mini-ramp turn; keep the discount
  at 1 and non-stacking (only the *next* card). tcg-designer to confirm it
  can't enable an early Warrior/attack spike via a discounted body.

## Option B — "Portent" (call-it, delayed hedge)

> **Portent:** Name Influence, Food, or Draw. At the start of your next turn,
> gain 1 of the named thing.

- **Hook:** the augur commits a prediction now and is rewarded when it comes to
  pass. The *choice* is the forecasting act; it's a hedge, not raw card draw.
- **Doom / Duel / Bot:** identical value everywhere — a small banked resource
  you steer toward what next turn needs. Never dead.
- **Power/complexity:** low; one deferred trigger. Distinct from Mage Caller
  because it's a chosen, delayed, cross-resource payoff, not a scry-draw.
- **Risk:** the "Draw" mode brushes the Augury draw identity — could cap it to
  Influence/Food only if that overlap worries tcg-designer. Delayed value is
  weak on a losing final turn (acceptable for a cheap card).

## Option C — "Storm Warning" (foresee incoming harm)

> **Storm Warning:** Prevent the next 2 damage dealt to your Kingdom this round.

- **Hook:** classic forecaster — sees the blow coming and braces for it.
- **Doom:** blunts a monster strike on a permanent; strong under the clock.
- **Duel:** absorbs incoming siege/creature/persistent damage to walls or
  castle — a cheap defensive tempo tool the attack-light Augury guild lacks.
- **Bot:** **weak-to-dead** if Bot mode has no incoming damage (VP solitaire).
- **Power/complexity:** low. Good, but fails the "meaningful in ALL modes" bar.
- **Risk:** ⚠️ **Technical/scope flag:** I can't confirm whether Bot mode deals
  damage to the player at all. If it doesn't, this violates the brief. Offered
  as the best *defensive-forecast* flavor; only pick if Bot has real threats.

## Option D — "Weak-Point Sight" (veil-sight → an opening)

> **Weak-Point Sight:** Your next attack this turn ignores up to 2 Wall DEF
> (see the flaw in the defense).

- **Hook:** seeing through the veil literally = seeing through the wall; the
  augur spots the crack. Also partially answers the designer's standing ask for
  a mid-game Augury attack method.
- **Duel:** directly relevant — chip a wall or slip damage past it once. Real
  duel utility for a guild with almost no board presence.
- **Doom:** minor — helps clear a sealed/walled threat if the mode uses walls.
- **Bot:** **weak** if Bot has no enemy walls/castle to attack.
- **Power/complexity:** low text, but it's an attack modifier.
- **Risk:** ⚠️ touches the attack layer — **defer to tcg-designer**, and it must
  respect the hard Warrior constraint (no early 4–5 ATK). This prints *pierce*,
  not raw ATK, so the spike risk is indirect, but confirm. Mode coverage is
  narrower than A/B.

## Option E — "Foretell" (Scry 2, reorder)

> **Foretell:** Look at the top 2 cards of your deck and put them back in any
> order.

- **Hook:** ordering the future is the purest forecaster fantasy.
- **Doom / Duel / Bot:** consistent, small consistency-smoothing everywhere.
- **Power/complexity:** very low; trivial to grok.
- **Risk:** ⚠️ **niche overlap** — Mage Caller already does top-of-deck scry
  (reveal top, draw if Augury). This is sequencing-only (no draw), so it's
  *adjacent, not identical*, but it's the weakest differentiator on the menu.
  Include only if tcg-designer is comfortable with two top-of-deck lookers.

## Option F — "Ward the Omen" (insurance vs. forced fate)

> **Ward the Omen:** The next time an effect would force an Auspice on you
> (e.g. Famine) or trigger a Possession/curse against you this turn, prevent it.

- **Hook:** the augur foresees the ill omen and averts it — hedging fate rather
  than changing the Auspice yourself (stays off the Channeler/Witchdoctor niche).
- **Doom:** strong insurance vs. Noxious Beast / Dark Magic forced Famine and
  seal/curse triggers.
- **Duel:** useful vs. Conjurer possessions/curses (the faction's built-in
  wild-magic backlash).
- **Bot:** **situational-to-dead** if the Bot rarely forces these.
- **Power/complexity:** low text but conditional; value swings by matchup.
- **Risk:** feast-or-famine reliability; narrowest of the set outside Doom/Duel.

---

## Comparison

| Option | Fantasy fit | Doom | Duel | Bot | Overhead | Overlap risk |
|---|---|---|---|---|---|---|
| A Read the Omens | High | Good | Good | Good | Low | Very low |
| B Portent | High | Good | Good | Good | Low | Low (Draw mode) |
| C Storm Warning | High | Strong | Good | Weak/none | Low | Low |
| D Weak-Point Sight | High | Minor | Strong | Weak | Low | Attack layer |
| E Foretell (Scry 2) | Highest | OK | OK | OK | Very low | Mage Caller |
| F Ward the Omen | High | Strong | Good | Situational | Low | Low |

## Recommendation

**#1 — Option A "Read the Omens."** It's the only option that is clearly
useful, approachable, and low-overhead in **all three** mode families, reads as
genuine foresight (peek + timed bargain), and stays clear of every existing
Augury niche. Best fit for "approachable across all modes."

**#2 — Option B "Portent."** The purest "see the future" fantasy with a small
player choice, equally live in every mode, and no attack/damage dependency. A
safe fallback if A's discount feels too tempo-forward.

If the goal is instead to give Augury a duel identity and chip at the attack
gap, **Option D** is the sharpest — but its mode coverage is narrower and it
needs tcg-designer sign-off on the attack layer.

**Open questions for the caller / tcg-designer:**
- Does **Bot mode** deal damage to the player, and does it feature enemy
  walls/castles? That answer decides whether C and D are viable there.
- Final costing: is a 1-Influence discount (A) the right magnitude on a
  3-cost/1-VP body, or should it be 1 Food / capped otherwise?
