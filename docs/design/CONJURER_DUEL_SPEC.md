# Conjurer Duel; "The Rival Summoner" (Design Spec)

**Status:** DESIGN PASS (2026-09-25). Not built. Design-only per Bryan's brief; do NOT
touch the simulator yet. This spec defines the mode's shape and rules; card-layer
specifics (exact card text, costs, keyword rules, stat blocks) defer to **tcg-designer**,
and the pressure/curve numbers to **pve-pressure-designer** where flagged.

**Purpose:** a single-player, no-netcode prototype that de-risks the planned networked PvP
(`PVP_MODE_BRIEF.md`) cheaply, before we spend on Godot netcode. You play a Conjurer against
ONE AI Conjurer who summons from its own pile and buys from the SAME market you do.

**Win-condition reframe (2026-09-25):** the prototype now uses a **castle assault + Occupy**
wincon (s2), NOT the VP race the first draft proposed. Key strategic call in s2.3: the castle
Duel and the big-table PvP are DIFFERENT games (castle elimination is a great 1v1 but dogpiles
at 3-5; the big table stays VP-based). The Duel therefore validates (a) the transferable PvP
tensions and (b) the one thing paper cannot prove, "is direct competition fun":
1. a **contested shared market** (your buy denies the rival) — transfers to the big table,
2. a **rival economy building in parallel** — transfers,
3. **direct competition against a live rival** (breach / occupy / kick out / counter-occupy)
   — the headline output; the VP-race loop is preserved as s2.6 for the big table.

It follows the Conjurer tutorial ("The Summoner's Plight", `CONJURER_TUTORIAL_SPEC.md`),
so the player already knows summon -> strike, the acquire-triggered possession backlash,
and Banish/Dispel. This mode assumes that literacy and adds an opponent.

---

## 1. Fantasy and framing

Two Conjurers, both reaching into the same young, half-leashed veil, both racing to prove
themselves worthy of the King's respect. Per canon (`WORLD_AND_LORE_REFERENCE.md`), magic
is newly rediscovered and imperfectly controlled; every summon is a hand into the dark.
Two rival summoners drawing from the same thinning well is a natural escalation of that
theme: you are not only gambling with the veil, you are gambling FASTER than the person
across from you, and the veil does not care which of you it bites.

Lore hook (flavor, not required for mechanics): frame the rival as another order-trained
Conjurer competing for a patron's favor, in the spirit of Laere's world of ambitious young
mages. Under the reframed (castle) wincon each Conjurer holds a keep and summons a force to
storm the rival's; it is a proving-ground siege between two summoners, still a contest of who
builds and commands the greater legend, not a war of extermination (the loser's keep is
taken, not their people slaughtered; keep the tone in the world's key).

**One-line pitch:** *"Two rival Conjurers, one wild well; summon a force, storm the other's
keep or hold it against them, and take the seat of favor while the veil bites you both."*

---

## 2. Win / loss (REFRAMED 2026-09-25; RECOMMENDATION: castle assault with Occupy, for the PROTOTYPE)

> **What changed and why:** the original draft recommended a pure VP race + closeable Portal
> (now demoted to option (b) below). Bryan is reconsidering toward castle-vs-castle. After
> weighing all three framings against the mode's actual job, this section now recommends
> **castle assault with an Occupy keyword for the PROTOTYPE**, layered on top of the
> contested shared market + possession backlash. The reasoning, and an explicit call on how
> the Duel and the big-table PvP diverge, are below. The VP-race design is preserved as a
> named option because it is what the big-table PvP still uses.

### 2.1 The three framings, weighed

| Framing | 1v1 feel | Reuses built systems | Rehearses which eventual PvP? | Scales to 3-5? |
|---|---|---|---|---|
| **(a) Castle assault (destroy/occupy the enemy keep)** | strong; a real duel, legible, dramatic | HIGH (the whole `setupCastle`/`attackCastle`/`castleTurn` stack) | a 1v1 / small-team SIEGE game | poorly (dogpile/kingmaking) |
| **(b) VP race + closeable Portal** (the prior draft) | weaker; parallel, solitaire-ish, hard to read moment-to-moment | MEDIUM (markets, Legend, `calcVP`, a Portal clock) | the PLANNED big-table VP match, directly | well (VP diffuses aggression) |
| **(c) Middle-ground: one central shared objective both fight** | good; contested center creates direct conflict without a private target | MEDIUM (castle/occupy on a neutral point + markets) | a hybrid that COULD unify small and big table | well (everyone fights the middle) |

### 2.2 Recommendation for the PROTOTYPE: (a) castle assault with Occupy

Reasons, in priority order:
1. **It is the cheapest fun.** The castle stack is fully built: a three-layer keep (Wall
   Line, Golem, Keep), siege doing double to walls, taunt-soaking walls, counter-fire that
   disables a permanent, and the Master Mason Remodel (+DEF) buff loop. A Duel that points
   the player at the AI's castle and the AI at the player's castle reuses almost all of it;
   the genuinely new work is instancing two castles and the Occupy keyword (s2.4).
2. **It gives an UNAMBIGUOUS read on the one thing hardest to prove on paper: is DIRECT PvP
   competition fun?** A VP race can look fun in a spreadsheet and still feel like two people
   playing solitaire next to each other. A castle duel cannot hide from that question; you
   either enjoy attacking and defending a keep against a live rival or you do not. That is
   the highest-value signal a cheap prototype can return.
3. **Occupy adds exactly the comeback tension a raw race lacks** (s2.4): a lead is not
   instant, the breached defender keeps agency, and overcommitting to attack exposes your own
   keep. That is a richer 1v1 than "most VP at the buzzer."

### 2.3 The strategic point Bryan raised (CONFIRMED, with a divergence call)

**I agree with Bryan's read, and I want to state its consequence plainly: castle assault and
the big-table VP match are DIFFERENT GAMES, and that is acceptable IF we are clear about what
the Duel is for.**

- **Castle "destroy/occupy the enemy keep" is a 1v1 / small-team game.** At 3-5 players a
  "raze each other's keeps" free-for-all dogpiles the weakest keep and kingmakes: whoever
  others choose to attack loses, which is a feel-bad the PvP brief already warns about
  ("kingmaking and pile-on-the-leader; use carefully"). Direct elimination does not scale.
- **The planned big-table PvP is, and should stay, VP-based.** VP racing diffuses aggression
  (there is no single "kill target"), keeps everyone building to the end, and is literally
  the King's-favor fantasy in the PvP brief. That is the marquee feature; do not repoint it
  at castle-elimination.

**So: the Duel is castle-based; the big-table PvP stays VP-based. They diverge on the WIN
CONDITION on purpose.** The cost of that divergence is real and must be acknowledged: a
castle Duel does NOT de-risk the big-table VP LOOP (the buy/bloat/Legend/close-the-game
levers). To recover most of that value cheaply, the prototype KEEPS the transferable PvP
tensions layered under the castle wincon:
- **the contested shared market** (buy-denial; s5),
- **the parallel rival economy** (the AI builds visibly; s4),
- **the possession backlash on both sides** (over-buying self-punishes; s8).

Those three transfer to the big-table VP PvP even though the win condition does not. So the
Duel validates (i) is direct competition fun, and (ii) do the shared-market/economy/veil
tensions hold up against a live rival, while the big table separately owns "is the VP race
fun at 3-5." That is a clean division of validation labor. **Confirm this divergence with
Bryan explicitly; it is the load-bearing decision in this reframe.**

**If Bryan wants ONE ruleset that scales from the Duel to the big table**, the bridge is
framing (c): a central shared objective with Occupy on a NEUTRAL point (king-of-the-hill on
the Portal itself, not on a private keep). Occupy-on-a-neutral-center scales to N players
without dogpiling any one player, because the contested thing is the middle, not a victim.
Recommend (c) as the eventual big-table direction ONLY IF he wants direct interaction at the
big table; otherwise keep the big table pure VP and let the Duel be its own 1v1 siege game.
See s2.5.

### 2.4 The Occupy keyword + castles-as-owned-permanents (prototype spec)

**Each side owns a castle**, instanced from the live `S.castle` shape, one per player:
`{ wallHp, wallMax, golemHp, golemMax, keepHp, keepMax, wallsDown, golemDown, occupier,
capture }`. Both castles render; you attack the OPPONENT's, you buff YOUR OWN.

**Breach sequence (reuse `attackCastle` gating verbatim).** You cannot touch a keep until its
defenders fall, in order: **Wall Line -> Golem -> Keep.** Siege (🔴) deals DOUBLE to the Wall
Line (`siegeDamageVs` / the `attackCastle('wall')` branch). Walls taunt-soak the enemy's
counter-fire (reuse the `isWall` first-target rule in `castleTurn`).

**Both sides BUFF their own castle (defense is an active project, not a static bar).** Reuse:
- **Master Mason Remodel:** +2 DEF to a building/wall (`raisedDef`), so counter-fire and
  siege bite less. Already live.
- **Fortifier / Wall Set bonus:** +DEF / re-raise wall HP; walls as permanents (`isWall`).
- **Attachments / Remodel tiers:** stack DEF onto the keep's defenders.
- **Re-raise a downed defender:** a breached side may spend builds to restore Wall HP or
  rebuild the Golem, which is the DEFENSIVE half of the comeback loop (s2.4 "comeback").

This is what makes the duel dynamic: you split effort between assaulting their keep and
shoring up yours, and the counter-fire disable loop (`castleTurn`, every other turn,
auto-repairs) keeps both economies churning.

**Two victory routes on the exposed keep (offer BOTH; they reward different builds):**
- **DESTROY:** raze `keepHp` to 0 (reuse `attackCastle('keep')`). Brute ATK; rewards a
  siege/burst build. Fast, final, no take-backs once the keep is at 0.
- **OCCUPY:** hold the exposed keep for a 3-turn countdown (below). Board-presence/tempo;
  rewards a creature-heavy build. Interruptible, comeback-friendly.

**OCCUPY, step by step (the new keyword to prototype):**
1. **Precondition:** the target keep is EXPOSED (`wallsDown && golemDown`). Same gate as a
   Destroy assault; you must breach first.
2. **Commit an occupying force.** Instead of striking `keepHp`, you COMMIT one or more of
   your creatures onto the exposed keep. Record `castle.occupier = { ownerId, forceDef }`
   where `forceDef` = the committed creatures' total effective DEF (reuse `effectivePermDef`).
   Committed creatures are **tapped/exposed**: they are NOT defending your own keep while
   committed. This tempo cost is the core tension; overcommitting to capture leaves you open
   to a counter-attack or counter-occupy on your own castle.
3. **Countdown.** Set `castle.capture = 3`. At the start of each of the occupier's turns
   while they still hold the keep uncontested, tick `capture` down: 3 -> 2 -> 1 -> **capture
   = 0 wins the game.** Show it as a visible bar on the occupied keep ("Occupied: 2 turns to
   capture").
4. **Kick out (the defender's interrupt).** On the defender's turn, they may KICK OUT the
   occupier by defeating the committed force: deal damage (ATK, or a fielded counter-force's
   DEF) **>= `castle.occupier.forceDef`**. On success: the occupier's committed creatures are
   sent home disabled (reuse the disable pattern), `castle.occupier = null`, `castle.capture`
   resets, and **the game continues.** The attacker must re-breach only if the defender also
   re-raised a wall/golem in the meantime (see comeback); otherwise they may re-commit next
   turn.
5. **Contest without full kick-out (optional, tune):** if the defender damages the force but
   does NOT meet `forceDef`, the countdown PAUSES for a turn (they held the line but did not
   evict). Keeps a partial defense meaningful. Flag as a tuning option, not required for v1.

**Comeback dynamics (why Occupy beats a raw race in 1v1):**
- The 3-turn window means a breach is not an instant loss; the defender gets up to three
  turns of agency to evict or rebuild.
- The defender can **re-fortify while contesting**: re-raise the Wall Line or rebuild the
  Golem so that even a successful kick-out forces the attacker to breach AGAIN. Defense
  regenerates, so a single breach is not terminal; this is the anti-snowball lever.
- Because occupying **taps the attacker's force**, a committed attacker is vulnerable at
  home. A defender who cannot evict directly can instead **race a counter-occupy** on the
  attacker's now-undefended keep. Two occupations in flight is the most exciting board state
  and is the "read the table" moment this prototype exists to test.

### 2.5 Fallback: (c) the middle-ground central objective

If castle-vs-castle does not feel good in playtest (e.g. it turtles, or the breach math is
swingy), collapse both castles into ONE neutral central objective both players fight and try
to Occupy: a contested Portal/tower in the middle. Same Occupy rules (s2.4), one target
instead of two. This is also the unifying path to the big table (s2.3): Occupy-on-a-neutral-
center scales to N players. Keep it in the back pocket; do not build it first.

### 2.6 Preserved option (b): the VP-race win (what the big table uses)

Retained for reference and as the big-table PvP design, NOT the prototype wincon:
- **Win = most VP** across deck + Legend at an end trigger (reuse `calcVP`).
- **End triggers:** a player CLOSES the shared Portal (player-controlled "call the game"), or
  the doom RAZES all market space, or a round limit.
- **Levers:** VP from owning cards; buying bloats the deck; **Legend** banks VP while thinning
  (reuse `hunterSendToLegend` / `legendSendsOptional`); the ahead player wants to close now,
  the behind player wants it open. This is the loop the big-table PvP validates on its own.
- Target match length either framing: **10-14 player turns** (see s7).

---

## 3. Turn / loop structure

Alternating turns, player and AI, to keep it readable and to mirror a structured PvP turn
order (the PvP brief lists "turn order vs simultaneous" as open; alternating is the safe,
teachable default for a solo-vs-AI dry run). Each side's turn:

1. **Upkeep:** draw to hand; resolve any start-of-turn possession spread on that player's
   own seized slots (s5).
2. **Main:** play economy (Farms/Aid), summon from hand to build ATK, BUY from the shared
   market (denying the rival), banish/dispel your own seized slots, optionally send a card
   to Legend.
3. **Assault / defend step (castle wincon):** spend ATK on the RIVAL's castle (breach the
   Wall Line with siege, then Golem, then Keep; or COMMIT an occupying force per s2.4), OR
   spend it defending your own (kick out an occupier, re-raise a wall, Remodel a defender).
   Committing to attack taps your force and exposes your own keep, so this step is the core
   read each turn. (Under the preserved VP wincon this step is instead: chip the shared
   Portal, or spend toward closing it to call the game.)
4. **End:** pass to the opponent.

The AI takes a symmetric turn (s4), fully visible in the log so the player can read the
rival's economy building in parallel (a key PvP feel: watching the opponent get stronger).

**Reused systems:** turn dispatch parallels `castleTurn()` / `houseTurn()` off `endTurnCore`;
the shared market reuses `mkMarket` / `refill` / the three market arrays; ATK spend reuses the
`atk_creature/siege/generic` pools via `attackCastle` (breach/destroy the rival's keep) and
`attackPossession` (clear the veil). Summon backlash reuses the acquire-trigger cascade
(`onManorSummon`/`seedConjurerPossessions`/`migratePossession`/`spreadPossessions`). (Under the
preserved VP wincon, `attackCastle` is instead an `attackTreant`-style spend onto a Portal
clock.)

---

## 4. The AI opponent (heuristic, solo-dev-buildable)

A **priority-ordered heuristic**, no ML. The AI runs the same legal turn a human would, in
a fixed decision order, reading only PUBLIC information. It should feel like a competent
rival, not an oracle.

### What the AI sees (public info only; mirrors PvP hidden-hand rules)
- The shared **market** (all three market rows, what is buyable, what is seized).
- Its **own** hand/deck/discard (it owns them).
- Both players' **VP totals**, **boards/permanents**, **Legend piles**, and the **Portal
  clock** (all OPEN, per the PvP brief: "VP and boards OPEN, hands hidden").
- It does NOT see the player's hand or deck order. This constraint is important: it keeps
  the AI honest as a stand-in for a human and prevents it from playing perfect denial.

### Decision order each AI turn (CASTLE wincon; evaluate top-down, act, repeat until out of resources)
1. **Emergency defense (highest priority).** If the AI's OWN keep is being occupied and the
   AI can meet the occupier's `forceDef`, KICK OUT the occupier this turn (s2.4). It never
   lets a capture countdown run if it can evict. If it cannot fully evict, it contests
   (partial-damage pause, if enabled) and/or re-raises a Wall / rebuilds the Golem to force a
   re-breach. Losing your keep is the loss; this always outranks offense.
2. **Survive the veil.** If a possession sits on the AI's OWN seized slots and it can afford
   to clear it, banish/dispel it (reuse `attackPossession` / `dispelPossessionFromMarket`).
   Weight scales with how choked its economy is. Keeps its ATK engine alive.
3. **Press an active occupation / assault.** If the AI already has a force committed on the
   RIVAL's exposed keep, it defends that commitment and lets the countdown tick. If the
   rival's keep is exposed (`wallsDown && golemDown`) and the AI has enough force, it chooses
   its finisher: DESTROY (raze `keepHp` if it can burst it low) or OCCUPY (commit a force if
   it cannot one-shot but can hold 3 turns). Tier governs how aggressively it commits versus
   keeps a force home to guard.
4. **Breach.** If the rival's keep is not yet exposed, spend ATK to break the Wall Line
   (siege first, doubled) then the Golem, in order (reuse `attackCastle` branches).
5. **Summon.** Play summonable conjurations from hand to build ATK/DEF (needs ATK to breach
   and DEF-bodies to occupy and to guard its own keep). Do it most turns.
6. **Buy for board + denial.** Buy from the shared market. Selection uses the scoring
   function below; it weights **denial** (take what the player visibly wants) and, under the
   castle wincon, biases toward siege (breach), DEF/creature bodies (occupy + guard), and
   Remodel/Fortifier (harden its keep). This still produces the buy-denial tension on purpose.
7. **Fortify.** Spend spare builds on its own castle (Remodel a defender, re-raise a wall)
   if not under immediate threat, banking defensive value for later.
8. **Pass.**

*(Under the preserved VP wincon, steps 1/3/4/7 collapse to: defend the shared Portal if
behind, and CLOSE the Portal to "call the game" if ahead by margin M. That behavior is the
key lever the big-table PvP AI will need; keep it specced even though the prototype uses the
castle order above.)*

### Card-buy scoring (first-pass, tcg-designer refines)
`score(card) = VP_weight * card.vp + utility_weight * needFit(card) + denial_weight *
playerWants(card) - bloat_penalty * (deckSize > target ? 1 : 0)`
- `needFit`: does it fill a gap in the AI's engine (needs ATK? economy? a banisher?).
- `playerWants`: heuristic that the card matches the player's visible board/faction or is
  the strongest remaining in its row.
- Tune the three weights per difficulty tier (below). Keep the function tiny and legible so
  it is debuggable and later portable to real PvP AI.

### Difficulty tiers
Three tiers, differing only in weights, thresholds, and one "handicap" knob, so a solo dev
maintains ONE codebase.

| Tier | Feel | Denial weight | Assault/Occupy aggression | Home-defense discipline | Handicap |
|---|---|---|---|---|---|
| **Apprentice** | learnable rival | low (rarely denies) | over-commits; occupies recklessly, leaves keep open | poor (slow to evict, under-forts) | starts 1 fewer card / draws avg |
| **Rival** | fair mirror match | medium (denies obvious wants) | commits when it can hold; guards home | decent (evicts when able, forts near threat) | none |
| **Master** | punishing | high (actively contests rows) | times Occupy to your exposure; counter-occupies your open keep | strong (evicts on schedule, pre-forts) | small economy edge (e.g. +1 buy tempo, or first-turn advantage) |

Recommend **Rival** as the default. Keep handicaps to economy tempo, NOT to information
(the AI must never peek at the player's hand, or the mode stops validating a fair PvP loop).
*(Under the preserved VP wincon, the "aggression" column becomes "uses the close-the-Portal
end-lever": Apprentice never, Rival when clearly ahead by margin M, Master times it to snipe
a lead. That is the big-table AI's key knob.)*

### AI feel guardrails
- The AI must **telegraph in the log** what it is doing ("The rival summons X", "The rival
  buys Y from under you", "The rival banishes a possession") so the player experiences the
  parallel economy and the denial as legible events, not silent state changes.
- The AI should occasionally make a legible non-optimal choice at lower tiers (it is the
  handicap surface), so beating Apprentice feels earned and losing to Master feels fair.

---

## 5. The shared / contested market (RECOMMENDATION: ONE shared market)

**Recommended: a single shared market both players draw from.** This is the core PvP
tension and the reason the mode exists. First-buy denies the other; you constantly weigh "do
I need this, or do I take it so the rival can't?" Mirrored/per-player markets would remove
exactly the tension we are trying to validate; reject them for this mode.

Rules:
- One recruit row, one conjuration row, one building row (or a trimmed subset), shared.
- When either player buys a slot, it refills from the shared deck (reuse `refill`). The
  refilled card is now available to whoever acts next; buying good cards early is denial.
- **Readability of denial:** when the AI buys, log it loudly and, if possible, briefly
  highlight the emptied slot in the UI ("the rival took it"). The player should FEEL the
  denial, since in real PvP that read-the-table moment is the fun. This is a UI/UX ask for
  engineering, flagged not owned here.
- **Possessions seize shared-market slots.** A seized conjuration slot is unbuyable by
  BOTH players until banished (see s5). This turns the veil backlash into a shared-board
  event with interaction potential.

**Open scaling note (for PvP later):** the PvP brief flags shared-vs-per-player market and
headcount scaling (2-5). This Duel only proves the 1v1 shared case. It does NOT resolve how
a shared market scales to 5 players; flag that as still open after this mode ships.

---

## 6. Interaction model (REFRAMED: DIRECT conflict is the main event, made safe by Occupy)

Under the castle wincon, direct conflict is no longer a spice to be minimized; it IS the game
(you win by taking the rival's keep). That inverts the prior draft's "mostly parallel racing".
The reason this is acceptable in 1v1 despite the PvP brief's dogpile warning is that the
warning is about SCALE: elimination dogpiles at 3-5 players (s2.3), which is exactly why the
big table stays VP-based and the castle wincon stays confined to the 1v1 Duel. In 1v1 there is
no third party to kingmake, so direct assault is fair.

**What keeps 1v1 direct conflict from being a feel-bad snowball is Occupy itself** (s2.4), not
its absence:
- A breach is not an instant loss; the 3-turn interruptible capture gives the defender agency.
- Defense regenerates (re-raise wall / rebuild golem), so a single breakthrough is recoverable.
- Committing to attack taps your force and exposes your keep, so aggression carries its own
  risk and cannot be one-sided. Overextension is punished by a counter-occupy.

**Secondary interaction, still on-theme and additive:**
- **Shared-market denial** (s5): buying to deny the rival's breach/defense pieces is a
  constant indirect pressure layered under the assault.
- **Spillover possessions** (s8): your dabbling can occasionally seize a slot that taxes the
  rival's economy; a small, self-capped nudge, kept low so it does not become a toxic vector.
- **Enforcer/Siegeman-style hooks:** the live PvP-scoped hooks (Enforcer c8 "heal any creature
  (not just yours; multiplayer scope)"; Siegeman) are candidates for shoring up a keep or a
  committed force. Exact card decisions -> **tcg-designer**.

**Hard guardrail against feel-bad:** the Occupy/re-fortify comeback loop must keep a breached
player in the game for at least the capture window; if playtest shows a single breach reliably
ends the match with no counterplay, lengthen the capture, cheapen re-fortify, or raise the
kick-out generosity until a breach is dangerous-but-survivable (s2.4, s11).

---

## 7. "Forced Conjurer recruits" (interpretation + spec)

**Interpretation of Bryan's note:** both sides must be guaranteed genuine conjuration
access, so the duel is actually a *summoning* contest and not one player lucking into a
summon engine while the other draws blanks. "Forced conjurer recruits" = a seeded guarantee
of Conjurer identity for BOTH players, tied to the possession backlash (dabbling risk) that
defines the faction.

**Spec:**
- **Both** the player and the AI start with a guaranteed Conjurer core: an opening hand /
  seed pile containing at least the summon engine (a couple of summonables + a Conjurer's
  Aid-style market unlock), mirroring how `setupHouse` gifts `['j1','j3','c1','c6']`. The AI
  gets a symmetric seed so it can summon from turn 1.
- The shared conjuration row is **guaranteed stocked** with summonables (mirror
  `modeConjurations` filtering to non-possession summonables), so both players can keep
  buying into the summon contest.
- **Both** decks/piles are seeded with the acquire-triggered possession backlash (reuse
  `seedConjurerPossessions`). This is the load-bearing tie to Conjurer identity: forcing
  Conjurer recruits ALSO forces the dabbling risk on both sides. It is not a summon contest
  unless it is also a *risk* contest. The rival who over-buys to out-VP you chokes on its
  own possessions, exactly as you would; that symmetry is the fair-race guarantee.
- The mode's card pool should draw on the Conjurer reward set already defined for the
  tutorial's win screen (`Sacrificer, Handler, Retinue, Teramancer, Enforcer, Conjure
  Master`) plus the tutorial's core (Conjurer's Aid, Exorcist, Cleric, farmers). Exact
  final pool -> **tcg-designer**; this doc just requires that both players share it.

---

## 8. Possessions / wild magic in a duel

Both players are Conjurers, so the acquire-triggered possession backlash applies to BOTH.
This is the richest, most on-theme lever in the mode and it does double duty: it regulates
over-buying (the PvP anti-farm cost) AND it is the natural home for capped direct
interaction (s6).

**Rules:**
- **Your dabbling looses your possessions.** When you acquire/refill and surface a
  possession (reuse `migratePossession`), it seizes a market slot. By default it targets
  slots that pressure YOUR economy first (as in the tutorial), so the primary cost of
  reckless buying falls on the recklessly-buying player. Fair and self-correcting.
- **Spillover (the interaction lever):** a tunable fraction of loosed possessions may seize
  a slot in a way that also, or instead, taxes the RIVAL. First-pass recommendation: keep
  spillover LOW (e.g. most possessions bite you, a minority spill toward the rival) so the
  dominant feel is "my magic is my own risk", with occasional "and it splashed on them".
  Exact spill rate and targeting -> **tcg-designer** / **pve-pressure-designer**. Flag: if
  spillover is too high it becomes a toxic direct-attack vector (see s6 guardrail); tune
  conservatively and playtest.
- **Banishing possessions banks VP.** `attackPossession` already sends a defeated
  possession to the banisher's Legend (VP counts) and can grant on-defeat draws / Legend
  sends. So clearing the veil is not only defense; it is a VP path. In a race this is a nice
  tension: a possession seizing a shared slot becomes a contested bounty (whoever spends the
  ATK to banish it banks the VP). Consider allowing either player to banish any seized
  shared slot; that makes possessions a shared objective, reinforcing "serve the kingdom".
  Confirm with tcg-designer whether cross-banishing shared slots is desirable or too swingy.
- **Spread:** the autonomous `spreadPossessions` escalation can run on the shared board but
  should be tuned GENTLY here; two players' combined dabbling already generates more
  possessions than the solo tutorial, so the base spawn rate likely needs to come DOWN to
  avoid choking the shared market too fast. -> **pve-pressure-designer**.

---

## 9. Onboarding + length

- **Assumes tutorial literacy.** No re-teaching summon/strike/banish. A single short intro
  beat establishes the rival and the two keeps, plus the one genuinely new verb, OCCUPY
  ("Another Conjurer holds the opposite keep. Throw down her walls and take her seat, or hold
  yours against her; and mind the veil, it bites you both."). Occupy is the only mechanic that
  needs a guided first use (commit a force -> the 3-turn bar -> get evicted once so the player
  sees the interrupt), since it is new even to a tutorial graduate.
- **Length target: 10-14 player turns**, one sitting, high replay. Alternating turns; the
  match should resolve in well under the tutorial's runway because both players are already
  competent.
- **Replayability drivers:** difficulty tier selection (s4), the variable shared-market
  stock, and the swing of the assault/occupy race (who breaches first, who occupies, who gets
  kicked out and counter-occupies). These give a different match each run without new content.
- **One difficulty-select screen** before the match (Apprentice / Rival / Master), default
  Rival.

---

## 10. How this validates PvP (explicit)

This mode is a checklist against `PVP_MODE_BRIEF.md`'s tensions, provable WITHOUT netcode:

Note the divergence from s2.3: the castle Duel and the big-table VP match are different games,
so the Duel validates the TRANSFERABLE tensions plus "is direct competition fun", NOT the
big-table VP win loop itself (which the big table owns separately).

| PvP brief tension | Transfers? | How the castle Duel exercises it |
|---|---|---|
| Shared contested market (first-buy denies) | YES | s5: one shared market; AI weights denial (s4) |
| Rival building an economy in parallel | YES | s4: AI summons + buys + forts every turn, telegraphed |
| Anti-free-rider (over-buying self-punishes) | YES | s8: possessions punish reckless buying, both sides |
| Hidden hands, open boards | YES | s4: AI reads only public info; hands stay hidden |
| Is DIRECT competition fun? (the paper-proof gap) | YES (this is the Duel's headline output) | s2.4: assault/occupy/kick-out against a live rival |
| VP race; buying bloats, Legend thins | NO (big table owns it) | preserved as s2.6, not the prototype wincon |
| Portal-close END TRIGGER ("call the game") | NO (big table owns it) | preserved in s2.6 / s4 note for the big-table AI |
| Direct-conflict pile-on / kingmaking risk | PARTIAL | s2.3: castle elimination dogpiles at 3-5; Duel is 1v1 only |

**What it deliberately does NOT validate (still open after this ships):**
- The big-table VP-race loop and the Portal-close end-lever (different wincon; s2.3, s2.6).
- Player-count scaling to 2-5; castle elimination in particular scales POORLY (s2.3).
- Real netcode / server-authoritative state (the whole point is to defer that).
- Simultaneous-phase turn structure (this uses alternating turns for legibility).
- Human social dynamics: kingmaking, table-talk, target-focusing (need 3+ real humans).

The single highest-value output of the reframed Duel is proving that **direct competition
against a live rival (breach, occupy, kick out, counter-occupy) is fun and readable**. That
is the question a spreadsheet cannot answer and the one a cheap 1v1 prototype answers best.
The big-table VP loop is de-risked separately (its own tests or a minimal LAN build).

---

## 11. Open questions / tensions

- **Win condition (Bryan), THE load-bearing call:** confirm the castle assault + Occupy
  wincon for the PROTOTYPE (s2.2) AND accept the explicit divergence in s2.3 (Duel = castle /
  1v1; big-table PvP = VP / scales). If Bryan wants ONE ruleset that scales, switch to the
  middle-ground central-objective framing (c, s2.5) instead. Recommend castle-for-prototype +
  keep big-table VP; flag the divergence loudly so it is a conscious choice.
- **Occupy tuning (pve + eng), the central balance risk of the reframe:** the capture length
  (3 turns), the kick-out threshold (`forceDef`), how fast a breached keep can re-fortify
  (comeback rate), and the tap/exposure cost of committing. Too slow a capture + easy evict =
  stalemate turtle; too fast + hard evict = a breach is an instant loss with no comeback.
  Prove a version where a breach is dangerous but survivable. Flag loudly.
- **Destroy vs Occupy balance (tcg + pve):** siege-burst (Destroy) and creature-body (Occupy)
  must both be viable finishers, or one route dominates and the keyword is dead weight.
- **Spillover possession rate (tcg + pve):** how much of your loosed wild magic may bite the
  rival. Too low = no direct interaction; too high = toxic pile-on. Tune conservatively.
- **Cross-banishing shared seized slots (tcg):** may either player banish any possession on
  a shared slot to bank the VP, or only clear slots that threaten them? The former makes
  possessions a contested bounty (rich) but adds swing; confirm.
- **Direct-conflict cards (tcg):** whether to include any Enforcer/Siegeman-style direct
  board interaction at all in a first pass, or ship pure market-denial + spillover only.
  Recommend shipping WITHOUT direct-attack cards first, add later only if the race feels too
  passive.
- **Central balance risk (tcg + pve, jointly):** a shared market + two dabbling Conjurers
  generates far more possessions and far more buy-competition than the solo tutorial. The
  spawn rate, spread rate, and market size must be re-tuned from scratch for two players; do
  NOT assume tutorial numbers transfer. Prove a stable, close race exists at each tier
  before build. This mirrors the tutorial's flagged joint-constraint risk.
- **AI legibility vs strength (eng):** the AI must telegraph its economy and denial clearly;
  a strong-but-silent AI would fail the mode's purpose (letting the player FEEL the PvP
  tensions). Legibility is a hard requirement, not polish.
- **Turn structure for real PvP (design, deferred):** this Duel uses alternating turns; the
  PvP brief leaves simultaneous-phase turns open. The Duel does not resolve that; flag it.

---

## 12. Handoffs

- **tcg-designer:** the shared card pool, exact costs, the buy-scoring inputs (which cards
  read as "player wants"), the **Occupy keyword's card text** (is it a keyword on creatures or
  an action; what "commit a force" means in card terms), the DESTROY-vs-OCCUPY finisher
  balance, Remodel/Fortifier/attachment DEF numbers, spillover targeting, cross-banish ruling,
  any direct-conflict cards, and the Legend/VP tuning (Legend still matters for deck-thinning
  even under the castle wincon).
- **pve-pressure-designer:** the two castles' HP/DEF (Wall/Golem/Keep per side), counter-fire
  cadence between two live economies, the **Occupy tuning** (capture length, kick-out
  `forceDef` threshold, re-fortify/comeback rate, commit exposure cost), possession spawn +
  spread rates re-tuned for two players, and the AI's assault/defend thresholds. (For the
  preserved VP wincon: the shared Portal clock and the AI's close-the-game margin M.)
- **Engineering (flagged, not owned):** the alternating turn dispatch, the AI decision loop,
  **instancing TWO castles** from the `S.castle` shape and pointing `attackCastle`/`castleTurn`
  at the opponent's, the **Occupy state + countdown + kick-out** (new bespoke), and reusing
  `mkMarket`/`refill`/`attackPossession`/`dispelPossessionFromMarket`/`calcVP`/
  `hunterSendToLegend` plus the denial/telegraph UI. Most of the castle stack
  (`setupCastle`/`attackCastle`/`castleTurn`/`renderCastleZone`, siege-doubles-vs-walls, wall
  taunt, Master Mason Remodel) is reused; the genuinely new work is the second castle instance,
  the Occupy keyword, and the AI turn.
