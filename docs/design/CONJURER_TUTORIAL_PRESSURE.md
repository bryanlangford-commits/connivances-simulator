# Conjurer Tutorial. Threat-Layer Pass ("The Haunting")

**Owner:** pve-pressure-designer · **Date:** 2026-09-13 · **Scope:** single-player tutorial mode.
**Companions:** design-lead owns mode structure/flow; tcg-designer owns the card layer
(possession pool stats, creature ATK values, Cleric/Exorcist gifts). Handoffs flagged inline.

This doc covers only the pressure side: the escalation curve, the possession (doom) win
condition, the player win condition, the lull→backlash arc, loss framing, and tuning against
death-spiral / trivial-win. Numbers are concrete and buildable as one HTML mode, reusing the
possession machinery already in `connivances_simulator_v11_6_4.html`.

---

## 0. Verdict on Claude's proposed loop

The loop is sound; **summon → veil cracks → possession spawns → spread → banish with creature
ATK → win by stabilizing / lose by house-overtaken** is the right shape. Two pressure-side
corrections before it's buildable:

1. **Split "spawn" from "spread."** They must have *different triggers* or the mode collapses
   into one of the baseline's two failure modes.
   - **Spawn = summon-driven** (your wild magic; your fault; immediate).
   - **Spread = time-driven** (the infestation growing on its own; unavoidable once cracked).
   If spread were *also* summon-driven, a player who stops summoning freezes the whole threat -
   the exact inverted-incentive turtling failure documented in `V11_MONSTER_PRESSURE_BASELINE.md`
   §3. The time-driven spread floor is what stops that.

2. **Spread must be sub-linear (capped), not per-possession.** "Each possession spreads each
   turn" is exponential = guaranteed death spiral, which the pressure philosophy forbids. Cap it
   at +1/turn early, +2/turn late (§1). The player must always be able to out-banish it if they
   play well.

Everything else below builds on the corrected loop.

---

## 1. The escalation curve (answers Q1; spread rate & trigger)

**The manor = 9 rooms** (a legible 3×3 board; mode-specific, rendered where the field zone lives,
exactly as `tutorial_augury` swaps in its tree zone). Each room is Open or Haunted. Rooms are not
razed in this mode; haunting only. Keeps the teaching surface to a single concept.

Two doom inputs, deliberately different triggers:

### Spawn; summon-driven backlash (your fault, immediate)
| Event | Effect |
|---|---|
| Summon #1, #2 | **No backlash.** The veil holds. (This is the lull; see §3.) |
| Summon #3 | **THE CRACK.** Spawn **2** possessions. Telegraphed hard (§3). |
| Every summon after the crack | Spawn **1** possession into a random Open room. |

Spawning is the price of power and it is *legibly the player's own action*. "I summoned, and a
thing came through" is the entire faction fantasy in one beat.

### Spread; time-driven infestation (unavoidable floor, escalates)
Fires in the enemy phase (mode-turn dispatch, alongside `longWinterTurn`/`treeTurn` at line 4194),
**only after the veil has cracked**. Let `h` = haunted rooms at start of the enemy phase:

| Corruption `h` | Spread this enemy turn | Curve phase |
|---|---|---|
| 0 | none | clean; nothing to spread |
| 1–3 | **+1 room** | the squeeze |
| 4–8 | **+2 rooms** | inevitability; act now or lose the house |

Early slack comes from the pre-crack lull; the mid-game squeeze from +1/turn stacking on top of
summon-spawns; late inevitability from the +2 break at `h≥4`. If a spread/spawn has no Open room
to fill, the excess is dropped; but 0 Open rooms = all 9 haunted = the doom trigger (§4).

**Why time-driven spread and not pure-turn-count:** a fixed doom clock (§2) ignores whether the
player is coping; a corruption-scaled spread means the threat *responds to how far behind the
player is falling*, which is what makes falling behind feel like a spiral you can still climb out
of; pressure that is survivable-but-costly, never a pure countdown.

---

## 2. The possession win condition (answers Q2)

**Possession win = all 9 rooms haunted simultaneously** ("the house is overtaken"), i.e. the
existing `allMarketsUnavailable()` idea scoped to the 9-room manor: `hauntedCount() >= 9`.

**Why this over a corruption meter or a fixed doom-clock turn count, as a *teaching* tool:**
- A **fixed turn-count clock** teaches "run out the timer," not "manage possessions." Wrong lesson.
- A **standalone corruption meter** (abstract 0–100 bar) hides *where* the doom is. The whole
  point of this tutorial is that possessions are physical things sitting in rooms you can point a
  creature at. The board *is* the meter; 9 rooms filling up reads instantly and teaches the exact
  verb (banish that one).
- The **player win is the meter** (§below); the doom is the board. Two different representations,
  each teaching its own half.

**Player win = seal the veil by banishing.** A **VEIL SEAL** meter, 0→6. Each banish (`attackPossession`,
already implemented) = **+1 seal**. At **6/6** the veil closes: all remaining possessions dissipate,
tutorial won. This directly rewards the core verb (banishing) and makes the risk/reward legible:
banish power comes from summoned creatures, but summoning is what spawns the possessions.

So the mode is a **visible two-bar race**: Veil Seal (player, 0→6) vs Haunted Rooms (doom, 0→9),
both driven by the player's own summon/banish tempo.

---

## 3. The lull and the telegraph (answers Q3)

**Two safe summons, backlash on the third.** Two is enough to teach the summon verb and lull the
player ("this is easy, summoning is free"); the third is the turn (§1) it goes wrong. Three total
summons before the first backlash matches Bryan's "2–3 summons" brief exactly.

**Telegraph the crack so it feels earned, Blight-style:**
- After **summon #2**: a quiet omen, no mechanical effect -
  *"The candle-flames lean toward the new-summoned thing. Something on the other side is listening."*
- On **summon #3 (THE CRACK)**, the "…Feeeed me" beat -
  *"The veil tears like wet paper. Two shapes pour through into the house; they were always there,
  waiting for you to open the door. THE HAUNTING BEGINS."*
- From then on, a **live end-turn preview** (copy the Blight's preview line, 2649–2655): the manor
  zone always shows *"▶ End turn now: spread +1 room (h=2). Banish first."* so the player sees the
  spread coming and makes a real decision, never a surprise.

**Why the crack spawns 2, not 1:** if the crack spawned a single possession the player could banish
it same-turn and never feel the backlash; the lesson wouldn't land. Two means one haunt carries
into the next turn no matter what, so the player *feels* "it went wrong" and enters the race a step
behind. That carried haunt is the emotional hook of the whole tutorial.

---

## 4. Loss framing. SOFT-RETRY (answers Q4, argued)

**Position: unfailable soft-retry, with a genuinely frightening near-loss.** Not a terminal loss.

Argument: this tutorial teaches a *brand-new risk mechanic* (possessions as wild-magic backlash).
Punishing a first-timer with a terminal game-over on the very mechanic they're still learning is
bad pedagogy; they don't yet have the vocabulary to have "earned" it, so the loss reads as
arbitrary, which the pressure philosophy explicitly rejects. But a threat you cannot lose to is
scenery, not a threat, and teaches nothing. The Blight already resolves this tension in-engine
(vitality hits 0 → surge back to full, warn hard, never terminal; line 2632–2640). Match it.

**The SURGE (fires when `hauntedCount()` reaches 9):**
- Dramatic beat: *"The house is lost; for a heartbeat. Then the old wards in the walls flare white
  and beat the shapes back into the dark."*
- Mechanically: clear rooms back to **3 haunted**, and **gift one Exorcist** (free dispel, no ATK -
  the recovery lever, mirroring `ensureFinaleGifts`).
- Hard warning: *"You survived by inches. Banish faster, and stop feeding the veil."*
- **Never terminal.** Repeated surges just repeat the beat (with escalating help, §5). The player
  can only *win* or *keep trying*, which is correct for a tutorial.

**Hand-off note (design-lead):** if a "graduated / hard" variant is ever wanted, the terminal
version is trivial; on the *second* surge in one game, set `S.gameOver` instead of resetting.
Flag it as a distinct mode, not the default tutorial.

---

## 5. Self-feeding tension; tuning against spiral and trivial win (answers Q5)

The knife-edge: summoning both **arms** you (creature ATK to banish) and **endangers** you (spawns
possessions). Four levers keep it in the survivable-but-costly band:

1. **Banishing can't fully keep pace with summon-spawn + spread.** A possession is DEF 3
   (`attackPossession` needs ATK ≥ 3). *Handoff to tcg-designer: creatures in this pool should give
   ~2 passive creature-ATK each*, so banishing one possession costs roughly two creatures' output.
   Result: a player who **summons every turn** nets **+1 haunted/turn** even while banishing
   (spawn +1, spread +1, banish −1); and spirals to +2/turn once `h≥4`. **Over-summoning loses.**
   This is the lesson: wild magic outruns you if you gorge on it.

2. **Ambient spread is independent of the player's actions.** It ticks even if the player stops
   summoning, so you cannot freeze the board and grind safely; this closes the baseline's turtling
   exploit. **Under-arming loses too:** a player with only 1 creature (~2 ATK) can't reach DEF 3
   reliably and drowns under +1/turn spread.

3. **The winning line is the middle.** Summon **2–3 creatures** (enough for ~6 ATK = banish ~2/turn),
   then **throttle summoning** and out-banish the ambient spread. "Build a controlled force, then
   stabilize" is exactly the strategic lesson the mode should impart. This is winnable but not
   automatic; it requires the player to *stop* doing the fun thing (summoning), which is the whole
   Conjurer discipline.

4. **ATK resets each turn (existing engine behavior).** Banish power comes from *permanent* creature
   passives, so the player must keep creatures on the board; but summoning *more* re-cracks the
   veil. The engine's per-turn ATK reset does this tuning work for free; no new rule needed.

**Anti-death-spiral floor:** spread is capped at +2/turn (never per-possession), and a **mercy gift**
fires at `h≥7` (gift an Exorcist / Cleric, mirroring `ensureStageGifts` at 2514) so a player who
falls behind always has a lever to claw back. Combined with the soft-retry surge (§4), the player
literally cannot get stuck.

**Anti-trivial-win floor:** the crack's 2-spawn burst (§3) guarantees a carried haunt, ambient
spread guarantees ongoing pressure, and over-summoning actively loses; so there is no "banish every
spawn same-turn and coast" line. The player must find the throttle.

---

## 6. Turn-by-turn pacing (illustrative, a learning player who wobbles then recovers)

Assumes ~2 creature-ATK per summoned creature (passive), possessions DEF 3, VP 2–3 (engine values).
"Summon" = played a creature this turn. Enemy phase resolves spread after the player phase.

| Turn | Player phase | h after player | Enemy spread | h end | Seal | Beat |
|---|---|---|---|---|---|---|
| 1 | Summon #1 (safe) | 0 |; (veil intact) | 0 | 0 | Learn summoning. Lull. |
| 2 | Summon #2 (safe) | 0 |; | 0 | 0 | Omen: "the flames lean…" |
| 3 | Summon #3 → **CRACK** (+2), banish 1 | 1 | h1 → +1 | 2 | 1 | "It went wrong." First banish taught. |
| 4 | Summon #4 (+1), banish 1 | 2 | h2 → +1 | 3 | 2 | Over-summons; falls behind. |
| 5 | Summon #5 (+1), banish 1 | 3 | h3 → +1 | 4 | 3 | Still gorging; squeeze bites. |
| 6 | **Stops summoning**, banish 2 | 2 | h2 → +1 | 3 | 5 | Learns the throttle. |
| 7 | No summon, banish 2 | 1 | h1 → +1 | 2 | 6 → **WIN** | Veil sealed; house saved. |

A player who *keeps* over-summoning past turn 5 rides `h` to 4+ (spread jumps to +2/turn), hits 9,
takes the **surge** (§4), gets an Exorcist, and is taught the lesson explicitly; then recovers and
wins a few turns later. Efficient players close in ~7 turns; wobblers stretch toward 12–15; the
soft-retry guarantees no one hard-fails. This is the intended ~15-turn envelope.

---

## 7. Edge cases (for the engineer)

- **No Open room on a spawn/spread:** drop the excess; if that means 0 Open rooms (all 9 haunted),
  fire the surge (§4), not silent loss.
- **Banish at h=0:** no-op (button hidden / disabled, as `attackPossession` already guards).
- **Seal reaches 6 with possessions still on board:** dissipate all, `S.portalDefeated=true`, win
  overlay. Do not require a clean board to win; the seal is the win.
- **Player has 0 ATK with possessions present:** allowed; mercy gift at `h≥7` provides the lever.
- **Player never reaches summon #3:** veil never cracks, no threat; acceptable, the tutorial simply
  waits. (Optional gentle nudge after 3 idle turns: the seer prompts a third summon.)
- **Surge while seal is near 6:** surge still fires (board takes priority); seal is untouched, so the
  player can win on the recovery turn; a satisfying come-from-behind, not a punish.
- **Double-source same room in one enemy phase:** a room is a boolean haunted/open; a second hit on
  an already-haunted room is a no-op (pick from Open rooms only).

---

## 8. Reuse map (buildable in one HTML mode)

Already in `connivances_simulator_v11_6_4.html`; reuse, don't rebuild:
- `slotIsHaunted` / `hauntedCount` (1276, 1283); corruption readout.
- `attackPossession` (5082); the banish verb, ATK ≥ DEF, possession → Legend (VP). Wire "+1 seal".
- Possession pool `p1`–`p5` in `cards.json` (DEF 3, VP 2–3); the haunts. *tcg-designer owns whether
  the tutorial uses a trimmed subset.*
- Cleric (+2 ATK vs possessions, 3524) and Exorcist (free dispel, 5175); the recovery gifts.
- Mode dispatch at 4194 and mode-turn precedent (`treeTurn`, `plantFinaleTurn`); add `manorTurn()`.
- Blight preview/telegraph/soft-retry (2632–2685); copy the pattern for the manor zone.

New, mode-specific (small): a 9-room manor board (`S.manor.rooms[]`), `veilCracked`/`summonCount`
state, a `VEIL SEAL` counter, `renderManorZone()`, and the spawn/spread rules in §1.

**Card-layer handoffs (tcg-designer):** exact creature-ATK values (~2 passive each, per §5.1),
possession-pool subset & VP, Cleric/Exorcist as mercy gifts. **Structure handoffs (design-lead):**
mode entry/exit, seer scripting for the lull nudges, and any "hard mode" terminal-loss variant (§4).
