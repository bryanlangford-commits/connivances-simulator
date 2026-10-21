# Conjurer Duel (reframed) — AI Mirror Match

**Status:** design brief for the Godot engineer. Replaces the asymmetric keep-siege
duel (`GAME_MODES.md` §7) with a **symmetric mirror match**: one AI opponent on the
same starter deck, same market, same creeping doom, racing the same Portal.
**Author:** Design Lead, 2026-10-20.

> **What changed and why:** the shipped Conjurer Duel is a 1v1 *keep-siege* with
> asymmetric win conditions (disable the rival Keep), two castles, and a combat model
> (all-or-nothing disable, back-line targeting) that diverges from the base game. That
> trains a bespoke mini-game, not multiplayer. Bryan's PvP vision is a **2–5 player VP
> race where closing the Portal ends the game and most VP wins** (project memory;
> `00_CURRENT_STATE_OVERVIEW.md §5`). This brief makes the single-player mode the
> **1-human + 1-AI instance of that** exact loop, so it is a true on-ramp and so the
> engine work is the first real PvP step rather than throwaway.

---

## 0. Design goal (one line)

A mirror match against a bot that plays Creeping Doom **the way a human opponent
would**: same rules, same market, same shared threat, racing you for VP before the
Portal closes. No special combat model, no asymmetry.

The iron rule still holds: **no card is re-statted.** This mode changes only *player
count* (1 → 2) and *win/loss framing*. Everything else is base Creeping Doom.

---

## 1. Win / loss + scoring

Identical to Creeping Doom, extended to two players.

- **End trigger (either of):**
  1. The **Portal is closed** (the exposed Portal is defeated by either player), OR
  2. The **shared board is razed out** (monsters take all 12 market positions).
- **Closing the Portal is an END trigger, not an auto-win.** The game stops; **highest
  total VP wins.** (`VP_TROPHY_ACQUISITION_RULES.md §2` — VP = sum over each player's
  deck + hand + discard + kingdom + legend.)
- **The Portal-killer still scores the Portal's VP** (acquisition rule, §1 of the VP
  doc; Portal → that player's Legend). That is a meaningful swing but not a win by
  itself — a player far behind on VP can still lose the turn they close the Portal.
- **Loser's turn-in-progress:** the end trigger **resolves immediately and ends the
  game** — there is no "symmetry turn" to equalize turn count. The Portal kill happens
  mid-turn, during the active player's turn, so by construction the *other* player does
  not get an equal number of actions on the final turn. This is intended and matches
  physical multiplayer (you choose *when* to close the Portal; closing it while behind
  is a blunder). Engineer: snapshot VP for all players at the instant of the end
  trigger, show the scoreboard, do not auto-advance.
- **Ties:** on equal VP, tie-break in order: (a) **player who dealt the end trigger**
  (closed the Portal, or — on a raze-out — the player with more market positions
  defended at the end), then (b) **fewer cards in deck+discard** (thinner engine = more
  skillful banking via Legend), then (c) **declare a draw**. *(b) and the raze-out
  sub-rule are Design Lead proposals; confirm with Bryan.*

---

## 2. Shared vs mirrored threat — **RECOMMENDATION: one shared board**

Both players face **one** creeping-doom board: the same four guardians + one Portal,
one monster queue, one set of 12 market positions, one Portal kill that ends the game.

**Why shared over parallel:**

- **It is the actual PvP model.** Bryan's architecture note (Godot `CLAUDE.md`,
  2026-10-06): "2–5 players share a market; monsters attack the shared board →
  'cooperate to slow the doom' vs 'you're racing ahead' VP tension." A mirrored/parallel
  threat would train a different game than the one being built.
- **It creates the core tension.** On a shared board, every monster the AI kills is VP
  *and* board relief it took from you; every market slot razed is denied to *both*.
  Players must weigh racing ahead vs. letting the doom pressure the leader.
- **Real denial is the whole point** (see §3) and only exists with shared objects.

**Fairness cost of shared (call out, do not hand-wave):**
- **Turn-order advantage** on the final Portal kill is real (see §1). Accept it as part
  of the skill test; do not add catch-up rules in the first playable.
- **Monster targeting must be player-aware.** Today `_monster_pick_target` scans one
  Kingdom. With two Kingdoms on a shared threat, the monster turn needs a rule for
  *whose* board a field monster attacks. **This is a `pve-pressure-designer` question**
  (see §4 / §8) — options include: attack the player whose board best satisfies the
  monster's existing priority (highest-VP permanent across both boards), alternate, or
  target the current VP leader. Do **not** decide this unilaterally.

**Parallel threat is explicitly rejected** for this mode (it would be two solitaire
games with a shared scoreboard — no interaction, no denial, not PvP-shaped).

---

## 3. Shared market — **CONFIRMED: one market, real denial**

Both players buy from **one** market: recruit (6) / building (3) / conjuration (3),
one supply deck behind each slot.

- **Denial is real:** if the AI buys the last affordable Siege or the Conjurer you
  needed, it is gone for you until the slot refills with something else. This is the
  single most important "feels like multiplayer" property; keep it.
- **Refill:** a bought slot refills from its supply deck immediately on purchase, same
  as single-player — the refill belongs to whoever buys next, not reserved.
- **Possession surfacing** on a conjuration refill haunts the **shared** slot (unbuyable
  for both, skipped by raze, counts toward raze-out loss) — same as today. Either
  player may banish it (spends their own ATK; acquires it to their own Legend for VP).
- **Raze vs two buyers:** razing removes a market *position* for both players (shared
  board). No change to raze mechanics; it just now denies two players at once.
- **Open question for `tcg-designer`:** supply-deck **depth / copy counts** may need a
  pass for 2 buyers (the market drains ~2× faster; running a guild's supply dry earlier
  changes archetype viability). Flag, do not re-tune here.

---

## 4. Turn structure — **RECOMMENDATION: alternating turns, threat once per round**

- **Alternating full turns.** Player A takes a complete turn (draw → play/buy/attack →
  end), then Player B. This maps 1:1 to the current single-player loop and to
  table-game PvP, and keeps the engine deterministic and debuggable. **Simultaneous
  turns are rejected** for the first playable (race conditions on shared market/threat,
  much harder to port to netcode cleanly).
- **The monster/threat turn runs ONCE PER ROUND, after the last player's turn** — not
  after each player. One round = every player takes one turn, then the doom advances
  once. Rationale: the threat cadence (`V11_MONSTER_PRESSURE_BASELINE`) is tuned to one
  advance per player-turn in single-player; firing it after *each* of two players would
  **double the pressure** and likely lose both players fast. One advance per round keeps
  per-player pressure roughly constant.
  - **This cadence is a `pve-pressure-designer` decision — flag it.** The alternative
    (threat after each player, with HP/seal/raze rates halved to compensate) is also
    valid and may feel more responsive. Do not finalize the rate without that review.
- **First-turn advantage:** Player A always draws/acts first. In a 2-player race this is
  a measurable edge. For the first playable, **randomize who goes first** and move on;
  revisit only if playtest shows it dominates.

---

## 5. The AI opponent — deterministic priority policy

The AI runs the **same engine actions a human has** (play, buy, attack monsters/Portal,
change auspice, repair/heal/banish, send to Legend). No hidden resources, no extra
cards. It should be a **readable rules-based policy**, not ML. One full AI turn:

**Phase A — Play for resources & board (maximize this turn):**
1. Play all **Farmers / Food** cards first (unlock food for the rest of the turn).
2. Play **unlock gate** cards it will need (Builder, Conjurer, Siegeman, Oracle,
   Warrior, Channeler) *before* the cards they gate.
3. Play **permanents** (buildings, summons, walls) into its Kingdom — these are VP,
   board presence (monster targets), and recurring ATK.
4. Play remaining recruits/spells for their one-shot inf/food/draw.
5. **Auspice:** if it holds an auspice use, set the auspice that **maximizes its own
   food/draw this turn** (Harvest if it has Farms; Mystic if it wants draw). Do **not**
   model "starve the opponent" griefing in the first playable (that is an advanced
   Augury line — defer to a later difficulty tier).

**Phase B — Buy (spend Influence):** pick the single highest-value affordable card by a
static priority score, repeat until it can't afford anything or chooses to hold:
   - Score = `card.vp` (banked value) `+ boardValue` (recurring ATK/food/unlock a
     permanent adds) `+ denialBonus` (small bump if the card is the last copy in its
     slot / something it predicts the human wants). Weights are the **difficulty dial
     input** (see below). Buying always sends the copy to the AI's discard (deck cycle),
     same as a human.
   - **tcg-designer owns the per-card priority weights** — the engineer should read them
     from a tunable table, not bake them in.

**Phase C — Attack (spend ATK pools, binary-kill rule):**
1. If the **Portal is exposed** and `ai.total_atk ≥ Portal_eff_hp` **and** the AI judges
   it is **ahead on VP or will be after the Portal's VP**, **close the Portal** (win the
   race). Otherwise hold the Portal (closing while behind loses — the AI must know this;
   it is the single most important strategic check).
2. Else kill the **highest-VP monster** it can afford (acquisition = VP + board relief),
   spending pools generic → siege → creature (base binary-kill rule).
3. Banish a haunting possession if it blocks a card it wants and it has spare ATK.

**Phase D — End-of-turn:** if in Hunter, send a high-VP played card to **Legend** to
bank points and thin (the AI should use Legend — it is "the heart of the game"). Freeze
hand under Winter as the rules dictate.

**Difficulty dial — RECOMMENDATION: a single `foresight` knob, with `income` as the
coarse fallback.**
- **`income` (coarse, matches today's `ai.income`):** flat bonus Influence/turn. Cheap
  to implement, but it makes the AI *richer*, not *smarter* — reads as unfair rather than
  challenging. Keep only as a blunt low-effort tier.
- **`foresight` (recommended primary knob):** how many of the priority checks the AI
  actually evaluates.
  - *Easy:* buys by raw VP only; never banks to Legend; closes the Portal greedily the
    first turn it can (often while behind — punishable).
  - *Normal:* full Phase A–D policy; the "don't close while behind" check on.
  - *Hard:* adds **denial** (buys to deny the human, tracks what the human is building)
    and **threat timing** (holds the Portal to let the doom pressure the human when the
    human leads). No income cheat.
- Keep **aggression** (how readily it spends ATK on the Portal vs. monsters) as a
  secondary tuning value folded into `foresight`, not a separate UI knob.
- **All three difficulties use the same legal actions and the same resources** — only
  the policy depth changes. This is what makes it a fair trainer.

---

## 6. Opponent visibility — **RECOMMENDATION: "open board, hidden hand, revealed plays"**

Mirror what a human opponent across a table would legitimately see, because the trainer
must teach reads that transfer to real PvP.

**Always visible (the AI's public state):**
- The AI's **Kingdom** (permanents, with Active/Disabled and DEF/ATK) — it is a physical
  board.
- The AI's **current VP** and **deck/discard/legend counts** (not contents). VP is public
  in this game; seeing the race is the point.
- The AI's **resource pools this turn** while it acts (Food/Influence/ATK), so the human
  can read its options.

**Hidden:**
- The AI's **hand contents** and **draw order** (as in real PvP).
- The AI's **internal priority scores / intent** (no "it will buy X next" telegraph).

**Revealed as it happens (step-through the AI turn, don't resolve instantly):**
- Each **play, buy, attack, auspice change, banish, Legend send** animates/logs as the
  AI performs it, with a brief beat so the human can follow. This is the core teaching
  surface: the human learns a plausible opponent line by watching it unfold.
- A **concise turn summary** afterward ("Rival: played 2 Farms, bought a Conjurer, killed
  the Ghoul Shaman (+VP), set Harvest").

This set is **both** a good trainer **and** fair for a match (it is exactly a tabletop
opponent's public information). Do **not** show the AI's hand even on Easy — seeing hands
teaches a read that does not exist in real PvP. (If a gentler tutorial variant is ever
wanted, surface *hints* about the AI's plan, never its literal hand.)

---

## 7. Scope & sequencing — this is the two-player engine refactor

**This mode cannot be built on the current engine as-is.** `GameState` is single-player:
one deck/hand/kingdom/discard/legend, one Food/Influence/ATK set, one auspice-use pool.
The mirror match requires **player-indexed state** — and that is precisely **the first
real step toward networked PvP**, so it is worth doing properly, not faked.

**Minimal first playable (build this):**
- **2 players:** 1 human + 1 AI.
- **Player-indexed state:** refactor `GameState` so every per-player field
  (deck/hand/discard/kingdom/legend/played, the three ATK pools, Food/Influence, auspice
  & repair/heal/legend/usurp use tokens, per-turn flags) is indexed by `player_id`.
  Keep **shared state** separate: the one market, the one monster queue + Portal, the
  12 market positions, the auspice *world-state* (one shared wheel — confirm with
  pve/tcg whether auspice is shared or per-player; **Design Lead lean: shared**, since
  it is the "global passive" of the world and PvP Augury play is about contesting it).
- **Shared creeping-doom threat**, **alternating turns**, **threat once per round**
  (§2, §4).
- **Rules-based AI** at a single Normal difficulty (§5), driving the same action API the
  human UI calls.
- **Visibility** per §6.
- The **Antagonist seam already exists** (`portal_guardians.gd`); the refactor is on the
  *player* side of `GameState`, and the antagonist's targeting needs the player-aware
  rule from §2.

**Later (post first-playable, roughly in order):**
1. **Difficulty tiers** (Easy/Hard via the `foresight` knob).
2. **3–5 players** (same shared-board model; turn order round-robin; threat still once
   per round — pve-pressure to confirm scaling of monster HP/count/raze rate with player
   count).
3. **Networked PvP** (replace the AI driver with remote players over Godot high-level
   multiplayer; the player-indexed state + action API is the same seam). This is the big
   least-reversible lift — `00_CURRENT_STATE_OVERVIEW.md §8` says build it on Godot's
   first-class multiplayer, not throwaway netcode.

**Risk flags (engineering feasibility — Design Lead not qualified to judge):**
- The **player-indexed `GameState` refactor** touches the 24 existing headless tests and
  `table.gd`. Scope/effort of that refactor, and whether to version it behind the
  existing single-player path, is an **engineering call** — flagging it as the gating
  risk for this whole mode.
- **UI for a second board + step-through AI turns** is new table work (ux-director).
- **Netcode** is out of scope here and explicitly deferred to post-funding.

---

## 8. Specialist hand-offs (do not decide here)

- **`pve-pressure-designer`:**
  - Monster targeting rule on a **shared** board between two Kingdoms (§2).
  - Threat **cadence** with two players: once-per-round (recommended) vs per-player with
    halved rates (§4).
  - How monster **count / HP / raze rate** scale with 3–5 players (later).
- **`tcg-designer`:**
  - Market **supply-deck depth / copy counts** for 2+ buyers draining the shared market
    faster (§3).
  - The AI's **per-card buy-priority weights** (§5 Phase B) as a tunable table.
  - Whether the **auspice wheel is shared or per-player** in PvP (§7) — interacts
    directly with Augury faction identity ("starve opponents by forcing Famine",
    `FACTION_IDENTITIES.md`).

---

## 9. Testability (for QA)

Concrete checks an engineer/QA can assert against the first playable:

1. **End trigger:** closing the exposed Portal ends the game the same tick; scoreboard
   snapshots both players' VP at that instant; no extra turn is granted.
2. **Winner:** with scripted decks, the higher `calc_vp(player)` wins; a player who
   closes the Portal while behind on VP (even counting the Portal's VP) **loses**.
3. **Ties:** force equal VP → tie-break resolves per §1 order deterministically.
4. **Shared denial:** AI buys the last copy of a card → that slot no longer offers it to
   the human until refill; refilled card is available to whoever buys next.
5. **Shared raze:** a razed market position is gone for **both** players and counts once
   toward the raze-out loss.
6. **Cadence:** the monster turn fires exactly **once per round** (after the 2nd player),
   not after each player.
7. **AI legality:** every AI action passes the same validators as a human action (no
   negative resources, no playing cards it doesn't hold, binary-kill respected).
8. **AI Portal discipline:** on Normal, the AI does **not** close the Portal on a turn
   where doing so leaves it behind on VP.
9. **Visibility:** the human UI can read the AI's Kingdom + VP + pile counts but **never**
   its hand contents; each AI action is observable as it resolves.
