# The Long Winter. Phase 2: "The Resurrection" (finale spec)

**Status:** buildable draft, awaiting first sim pass.
**Scope:** mode-level antagonist behaviour only (IRON RULE safe; no card behaviour changes).
**Target file:** `simulator/connivances_simulator_v11_6_4.html`.
**Owner:** pve-pressure-designer. Sim/impl: orchestrator.

---

## 0. Design intent (one paragraph)

Phase 1 (the relay) is a **type-diversity + tempo** test and currently wins 60% greedy-bot
(a touch too easy). The finale is where we re-add endgame teeth **without touching the ramp**.
When Death falls, all four Horsemen rise at once as a **field wave** that **disables the
player's board** while a **fixed short clock** counts to the Long Night. The player is no
longer solving "do I have the right damage type"; they are solving **"can I burn 24 HP
before my damage engine is ground down and the Night falls."** Repair and heals; dead
weight until now; become the load-bearing survival tool. Agency lives in the **damage race
and board upkeep**; inevitability lives in the **clock**. Neither can be switched off.

---

## 1. Phase trigger & transition

Today `attackHorseman()` (~L2139) makes **Death's death = instant win**
(`lw.won=true; showGameEndOverlay(true)`). Replace that leaf with a transition into the finale.

**On the strike that reduces Death (rider index 3) to ≤0 HP, when `lw.finale` is falsy:**

1. Do **not** win. Call `enterFinale()`.
2. `enterFinale()`:
   - `lw.finale = true`
   - Revive all four riders in place: for each `r` in `lw.riders`: `r.dead=false`,
     `r.hp = FIN_HP`, `r.maxHp = FIN_HP`, `r.finAtk = FIN_ATK`, `r.woundedBy='any'`
     (immunity dropped; see §2), clear `r.wardedThisTurn`.
   - `lw.finaleClock = FIN_CLOCK` (fresh countdown; see §4).
   - `lw.activeIdx = 0` becomes irrelevant; in the finale **all four are simultaneously
     attackable** (§3). Keep the field flag `lw.allActive = true` for the renderer.
   - Reset the auspice to **Winter**: `S.auspice = AUSPICES.findIndex(a=>a.id==='winter')`.
     (Thematic; and Winter Dormancy; unplayed cards freeze in hand; is a small mercy that
     offsets the burst. The player may still change it.)
   - Clear any leftover phase-1 freeze bookkeeping: `lw.frozen=[]`.
   - `addLog('❄️☠ THE RESURRECTION. All four Horsemen rise as one final wave; now all
     attackable, now striking your holdings. Destroy every one before THE LONG NIGHT falls in '
     +FIN_CLOCK+' turns.','bad')`.

**Why the player does NOT get a free instant-clear the turn Death dies:** the strike that
kills Death already zeroed the ATK pools (phase-1 combat drains the matched pool). So at the
moment of resurrection the player's pool is spent; they end the turn, eat one antagonist turn
(disables + clock tick), and only then attack the wave. This falls out of existing mechanics -
no special guard needed. It neutralises the "over-built player one-shots the finale" failure
mode for free.

---

## 2. Resurrection stat block

Symmetric, no typing (per orchestrator lean #1; type diversity was already tested in the relay):

| Param | Symbol | First-sim value | Notes |
|---|---|---|---|
| HP each | `FIN_HP` | **6** | 4 × 6 = **24 total HP** to clear |
| ATK each | `FIN_ATK` | **3** | drives the beatable gate: disables any perm with DEF ≤ 3 |
| Wounded by |; | **any** | immunity dropped; every ATK type hits every rider |
| Count |; | 4, all alive | pressure decays as they die (see cap, §3) |

All four identical. Asymmetry is a future hard-mode lever, not needed for the first cut.

---

## 3. Their turn behaviour (the finale antagonist phase)

Do **not** reuse `monsterPickTarget` / `runMonsterTurn`; those carry Creeping-Doom-specific
priorities (caravans, ghoul/minotaur, taunt walls, market raze) that are absent or wrong here.
Spec a **bespoke** `finaleAntagonistTurn()`, called from `longWinterTurn()` when `lw.finale`:

```
function longWinterTurn():
    if lw.finale: return finaleAntagonistTurn()   // skip ALL phase-1 effects & stage logic
    ... existing phase-1 body unchanged ...
```

### 3.1 Disable step (the load-bearing knob)

```
aliveRiders = count(r in lw.riders where !r.dead)
cap = min(DISABLE_CAP, aliveRiders)      // DISABLE_CAP = 2 (first-sim)
for i in 1..cap:
    target = finalePickTarget(FIN_ATK)   // recompute each iteration → spreads, no double-hit
    if target == null: break             // no beatable board left this turn
    disable(target)                      // reuse monsterAttackPermanent(fakeM, target)
```

- `cap = min(2, aliveRiders)` means **pressure auto-decays as the player wins**: 4/3 alive → 2
  disables, 2 alive → 2, 1 alive → 1. This is the primary anti-death-spiral valve late.
- Reuse `monsterAttackPermanent({name:'The Risen', monsterAtk:FIN_ATK}, target)` so you inherit
  the existing rules: `disabled=true`, `detachRecruitsOnDisable(perm)` (attached recruits detach
  → discard), and the log line. **This intentionally hurts:** disabling a Siege building or a
  host strips its recurring ATK *and* its attachments, dropping next turn's pool.

### 3.2 `finalePickTarget(atk)`; priority (targets the damage engine)

```
active   = S.permanents where !disabled
beatable = active where defVsMonster(p) <= atk
if beatable empty: return null
score(p) = atk_creature+atk_siege+atk_generic + sum(attached ATK)   // recurring ATK contribution
pick max score; tiebreak max VP; tiebreak random
```

This makes **repair and heals matter** (Siege buildings / War Room / attacking creatures are
the prime targets) and gives the player real counterplay with a price: **DEF ≥ 4 on an ATK
piece makes it un-disable-able** (beatable gate fails at ATK 3). Investing DEF to armour your
damage engine competes with buying more ATK/economy; a genuine cost.

### 3.3 Clock step

```
lw.finaleClock -= 1
if lw.finaleClock <= 0 and any rider alive:
    S.gameOver = true; showGameEndOverlay(false)   // THE LONG NIGHT; defeat
```

**Kills do NOT thaw / extend the finale clock** (orchestrator lean; correct; thawing would
make it unbeatable-to-end). The clock is pure inevitability; the player's agency is the damage
race, not the clock. That is the right split and does not violate "a threat is not a countdown"
- the player influences *whether they beat it*, just not *its length*.

### 3.4 Edge cases

- **No attackable permanents** (thin/wiped board): disable loop finds `null`, disables nothing,
  clock still ticks. Long Winter does **not** use the 12-market raze loss, so nothing is razed.
  A boardless player can still race via one-shot ATK cards played from hand (they add to the pool
  that turn). **Do NOT accelerate the clock on an empty board**; that would punish the weakest
  player into a death spiral. Clock stays fixed.
- **All perms already disabled:** same as above (beatable set empty).
- **Player has DEF ≥ 4 everywhere:** finale may disable nothing → pure damage-vs-clock race.
  Intended; if this makes it too easy, raise `FIN_ATK` (§7).
- **Creatures disabled:** they can't be Repaired (card rule), only healed (Cleric/Exorcist/
  Enforcer). This asymmetry is intended bite; note it, don't special-case it. Buildings remain
  the repairable ATK sources, which is exactly why Repair earns its keep here.

---

## 4. The finale clock

- `FIN_CLOCK = 5` (first-sim). One decrement per finale antagonist turn.
- Represented as a dedicated counter, **not** the phase-1 `stage`/`deepenEvery` machinery
  (simpler to reason about and tune). Reuse the `stageNames[3]` label ("THE LONG NIGHT") for
  flavour in the UI: `THE LONG NIGHT falls in N turn(s)`.
- Turn accounting: `enterFinale` sets clock 5. Player kills Death → ends turn → antagonist turn
  #1 (disable + clock→4) → player turn → ... The player effectively gets ~5 attack-turns against
  the wave before the Night. See math §6.

---

## 5. Player strike model (finale)

Phase-1 combat (`attackHorseman`, matched-pool, zero-on-strike) is **working and tested; do not
change it.** Branch a **separate finale strike** that (a) lets the player pick which rider and
(b) uses a **no-overkill combined-pool spend** so the wave is clearable under a short clock:

```
function attackHorsemanFinale(idx):
    r = lw.riders[idx]; if !r or r.dead: return
    pool = S.atk_creature + S.atk_siege + S.atk_generic     // all types hit (immunity dropped)
    if pool <= 0: log("no ATK"); return
    spend = min(pool, r.hp)                                  // NO overkill waste
    r.hp -= spend
    drainPools(spend)   // subtract 'spend' from the three pools in any fixed order
    if r.hp <= 0: r.dead = true; log(r.name+" is destroyed!")
    if all four dead: lw.won=true; S.portalDefeated=true; showGameEndOverlay(true)   // WIN
    render()
```

`drainPools(spend)`: subtract from `atk_creature`, then `atk_siege`, then `atk_generic` (order
irrelevant since all hit). **No-overkill is essential:** it lets a big pool clear multiple weak
riders in one turn (e.g. 12 pool → kill two 6-HP riders), which is the only way a strong board
beats a 4-body wave inside 5 turns. Overkill-waste (dump-whole-pool-per-target) would make the
clock the sole arbiter and gate out legitimate wins.

**Win = all four finale riders dead. Lose = finaleClock hits 0 with any alive.**

---

## 6. Repair / damage-race math (feasibility check)

**Total to clear:** 24 HP. **Turns available:** ~5 (clock).
**Player effective damage/turn** = combined recurring ATK (`permAtkBonus`) + cards played that
turn − ATK lost to disables. Pools reset each turn to the permanent baseline, so a **disabled
ATK permanent costs its recurring ATK every subsequent turn until repaired/healed.**

**Repair throughput:** repair uses reset to 0 each turn; you regain them only by drawing+playing
repair builders. House Hand (Repair 1), Repair Master (Repair 1), Contractor (Repair 2). A deck
with 2–3 repair builders draws ≈1 per turn ⇒ ≈1–2 repairs/turn. Heals (Cleric/Exorcist) cover
creatures. **Disable cap 2/turn ≈ repair+heal throughput 1–2/turn** ⇒ the board **erodes slowly,
not catastrophically**, and the erosion reverses as riders die (cap → 1).

**Illustrative solid board (sustained P ≈ 7 combined ATK, ~1 repair/turn):**

| Turn | Wave HP start | Player deals | Wave HP end | Disables (cap) | Notes |
|---|---|---|---|---|---|
| Death dies |; | (pool spent on Death) | 24 |; | resurrect; clock 5 |
| A | 24 | 7 | 17 | 2 (→P≈5–6) | clock 4 |
| B | 17 | 6 | 11 | 2 (repair 1 back) | clock 3 |
| C | 11 | 6 | 5 (1 rider dead) | 2 | clock 2 |
| D | 5 | 6 → **clear** | 0 |; | **WIN on clock 1** |

Solid board clears in ~4 attack-turns; a **tight** win. **Thin board (P ≈ 4, few repairs):**
24 / 4 ≈ 6 turns > 5 clock ⇒ **loss.** The cut sits right around **sustained P ≈ 5–6**, which
should split the current 60% roughly in half → overall into the target band.

---

## 7. Difficulty target & sim order

Goal: pull **overall** mode win-rate from 60% greedy → **~20–40% greedy (≈40–55% skilled)**.
The finale should be where a chunk of today's "wins" now fail.

**Sim #1 (primary; run this first):**
`FIN_HP=6, FIN_ATK=3, DISABLE_CAP=2 (min with alive), FIN_CLOCK=5`, no-overkill strike,
targeting = highest-ATK-contributor. Report: overall win%, avg finale-turns-survived,
% losses that are clock-timeout vs. board-wipe, avg riders killed in finale.

**If still too easy (>40% greedy), tune in this order (one knob at a time):**
1. `FIN_CLOCK` 5 → **4** (largest lever on the race).
2. `FIN_HP` 6 → **7** (24 → 28 total).
3. `FIN_ATK` 3 → **4** (beats DEF-armoured pieces; only if DEF is trivially shutting out disables).

**If too hard (<20% greedy):**
1. `FIN_CLOCK` 5 → **6**.
2. `FIN_HP` 6 → **5** (20 total).
3. `DISABLE_CAP` 2 → `min(1, alive)`.

Change **one** knob per 15-match batch so the sim signal stays legible.

---

## 8. Risks & failure modes (and how the numbers answer them)

- **Disable-spiral (unrecoverable board wipe):** answered by `cap = min(2, aliveRiders)` (decays
  as you win) + no-overkill strike (kills relieve pressure fast) + Winter Dormancy holding cards
  in hand. Watch the "board-wipe" loss share in sim #1; if it dominates over clock-timeout losses,
  the cap is too high; drop to `min(1, alive)` *before* touching HP/clock.
- **Finale trivial if over-built:** answered for free; the pool that killed Death is spent, so no
  same-turn clear; strong boards still win in 3–4 turns (intended; those are the "should-win"
  players). Watch that finale win% isn't ~100% for high-perm-count games; if it is, raise `FIN_HP`.
- **Clock-only game (no agency):** avoided; the clock is fixed but the player fully controls the
  damage race and board upkeep. If sim shows losses are ~all clock-timeout with near-full boards,
  the clock is too short for the achievable P; lengthen `FIN_CLOCK` before other knobs.
- **Repair still dead:** if sim shows repair/heal plays ≈0 in the finale, targeting isn't biting
  ATK buildings; verify `finalePickTarget` scoring, and/or raise `FIN_ATK` so more DEF tiers are
  beatable.
- **Boardless-but-racing exploit:** a player who dumps everything as one-shot ATK from hand each
  turn can't be disabled. This is fine; it's slower (no recurring ATK, capped by draws) and the
  clock still bites. Only revisit if sim shows it as a dominant winning line.

---

## 9. Code touch-points (for implementation)

| Function (approx line) | Change |
|---|---|
| `setupLongWinter` (L2084) | init `lw.finale=false` (finale fields set at transition) |
| `attackHorseman` (L2139) | on Death (idx 3) death when `!lw.finale` → `enterFinale()` instead of win |
| **new** `enterFinale()` | revive all 4 at `FIN_HP`, `woundedBy='any'`, set `finaleClock`, auspice→Winter |
| **new** `attackHorsemanFinale(idx)` | per-rider, no-overkill combined-pool spend; all-dead → win |
| `longWinterTurn` (L2103) | `if(lw.finale) return finaleAntagonistTurn();` (skip phase-1 body) |
| **new** `finaleAntagonistTurn()` | disable loop (cap) + clock decrement + loss check |
| **new** `finalePickTarget(atk)` | highest-ATK-contributor among beatable; tiebreak VP, random |
| `renderLongWinterZone` (L2178) | finale branch: all riders show a Strike button (→ `attackHorsemanFinale(i)`), show `finaleClock` |
| **sim harness / bot** | teach the bot to strike finale riders (multiple targets, focus-fire lowest-HP-first to exploit no-overkill) |

**Tunables to expose at top of the LW block:**
`const FIN_HP=6, FIN_ATK=3, DISABLE_CAP=2, FIN_CLOCK=5;`
