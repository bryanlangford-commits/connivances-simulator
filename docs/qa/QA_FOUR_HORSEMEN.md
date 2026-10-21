# QA: Four Horsemen / Long Winter (`long_winter`)

Target build: `simulator/connivances_simulator_v11_6_4.html` (+ `simulator/cards.json`).
Scope: the mode-specific recruit copy override in `modeRecruits()` (siege
reachability fix) and its knock-on risks; win/loss logic; damage-type gating;
regression safety. This is a static logic + pool-math review (no browser / no
node available), so pure-logic checks are documented reasoning, not executed
scripts.

Style note: no em dashes used anywhere in this doc, per project rule.

---

## Verdict on the siege fix

Sound. The Famine answer (🔴 Siege) is reliably assemblable with the rebalanced
pool, and the override is correctly mode-scoped with no NaN/undefined risk. The
mode's real structural fragility is not siege supply; it is the "one rider at a
time, in fixed order" gate combined with War (creature-only) sitting *before*
Famine (siege-only), which can hard-stall a mono-type build. Details below.

---

## Pool math (grounded in `cards.json` + `modeRecruits()`/`modeBuildings()`)

`expandQty()` (line 1089) makes `qty` copies of each card. The `long_winter`
override map `q` (lines 2421-2426) is applied via
`RECRUITS.map(c => (c.id in q) ? Object.assign({},c,{qty:q[c.id]}) : c)`.

Recruit copies **in this mode** (override applied; unlisted keep global qty):

| Faction | Copies in mode |
|---|---|
| Builder (b1-b10) | **24** (b1:3, b2:2, b3:3, b4:2, b5:2, b6:2, b7:1, b8:3, b9:3, b10:3) |
| Warrior (w1-w11) | 23 (incl. Siegeman w5:3, Warlord w8:1) |
| Augury (a1-a10) | 21 |
| Conjurer (c1-c9) | 19 |
| Farmer (f1-f5) | 19 |
| Fallah | 2 |
| **Total** | **108** |

Builder is the most common faction (24/108 ~ 22%), matching stated intent.
Siege-market unlockers exist redundantly: any Builder (24) opens the Buildings
market including Siege (gate at line 4276 allows Siege when
`S.builderPlayedThisTurn`), and Siegeman w5 (3) / Warlord w8 (1) also open Siege
directly (`S.siegemanPlayedThisTurn`, line 4274). The chance of drawing zero
building-unlockers across a full game is negligible.

Siege **buildings** in the mode pool (`modeBuildings()` returns all buildings
except Caravan and Granary):

| Building | Cost inf | 🔴/turn | Copies |
|---|---|---|---|
| Hwacha (bg17) | 4 | 1 | 4 |
| Catapult (bg4) | 6 | 2 | 3 |
| Trebuchet (bg9) | 8 | 3 | 3 |
| Ballista (bg18) | 9 | 3 | 2 |

Siege = 12 copies out of ~49 building copies in the mode pool (~24%). A Siege
weapon will surface in a normal-length game with high probability, and the
cheapest (Hwacha, 4 inf) is also the most common. Famine is 9 HP; the ATK pool
is recomputed each turn from active permanents (`permAtkBonus()` -> `startTurn()`
lines 4966-4968), and `attackHorseman()` spends the whole siege pool per strike,
so even a single Catapult+Trebuchet board (5/turn) undoes Famine in ~2 turns.
**Conclusion: siege reachability is solid.**

---

## Findings (prioritized)

### F1. Ordering trap: War (creature-only) precedes Famine (siege-only), no skip. [MEDIUM - design flag, not a code bug]
Riders are strictly ordered and the next cannot be touched until the current one
dies (`activeIdx`, gate in `renderLongWinterZone`). Sequence: Conquest (any) ->
War (🟡 creature only, 10 HP, +2 HP every turn it is not wounded) -> Famine
(🔴 siege only, 9 HP) -> Death (any, 15 HP).
- The siege fix guarantees the Famine answer, but the symmetric requirement is
  War: a player who commits hard to Builders/Siege and neglects creature ATK
  cannot wound War at all, War escalates +2 HP/turn (line 2238), the winter
  clock deepens, and the run is lost *before Famine is ever reached*.
- Repro: start `long_winter`; buy only Builders/Farms/Siege; kill Conquest with
  siege; arrive at War with no Conjurer creatures in play.
- Expected: a path to catch up. Actual: War is unwoundable (Strike disabled,
  `pool<=0` on creature), it grows, Long Night falls. Hard-stuck.
- This is arguably the mode's intended "bring everything" thesis, so I am
  flagging it to design rather than deciding intended behavior. If it is
  intended, the UI should telegraph, before Conquest dies, that War needs
  Creature ATK and Famine needs Siege, so players provision both early. Confirm
  creature sources are as reachable as siege: Conjurers are 19/108 and open the
  Conjuration market, which is adequate, but they were *trimmed* by the same
  override (c2/c3/c4/c5 down to 2, c7 to 3), so double-check War remains
  answerable after the trim.

### F2. Globally-retired card b2 (Repair Master) is revived only in this mode. [MEDIUM - confirm with design]
b2 has global `qty:0` in `cards.json` (retired/cut). The `q` map sets `b2:2`,
so Long Winter is the only mode that offers Repair Master. Repair is valuable
here (counters Death's freeze and the finale freeze), so this is plausibly
intentional, but reviving a card that was cut elsewhere can reintroduce whatever
balance reason retired it.
- Action: confirm with design that b2 is meant to exist in `long_winter`. If
  yes, leave a code comment saying so, since a future reader will read `qty:0`
  as "this card is dead" and be surprised it appears in one mode.
- Note: `expandQty` uses `(c.qty||1)`, so a `qty:0` card actually yields **1**
  copy if it is ever passed through unoverridden. This is a pre-existing global
  quirk, out of scope for this change, but worth a separate ticket: `qty:0`
  does not mean "excluded" anywhere that relies on `||1`.

### F3. Dead-weight DEF cards remain purchasable, contradicting the code's own comment. [LOW - player trap + doc mismatch]
The comment above `modeRecruits()` (lines 2414-2416) states the intent to
"drop Meurtrière (b5), Fortifier (b6), Retinue (c4)" because horsemen do not
besiege permanents, so pure DEF-attach cards are dead weight. The implementation
does **not** drop them; it keeps b5:2 and c4:2 (via `q`) and b6:2 (global). They
remain in the market as trap purchases that do nothing useful in this mode.
- Impact: market dilution and a mild newbie trap; not a crash or blocker.
- Fix: either filter these three out (match the comment) or delete the stale
  comment (match the code). Pick one so intent and behavior agree.

### F4. Stale `modeBuildings()` comment contradicts the code. [LOW - doc cleanup]
Lines 2442-2444 say the mode should "HALVE each Farm's copies (round up)" and
"drop all Caravans & Granaries." The active comment just below (2445-2447) and
the code (2448) keep **full** Farm copies and only drop Caravan + Granary. The
code matches the newer comment; the older comment is stale and misleading.
Remove the stale block. Minor gameplay note: Farms are low value here anyway
(while Famine rides, the auspice is forced to Famine and farms yield 0), so full
farm copies add some inert dilution to the building market, but Siege still
surfaces at ~24%.

### F5. Finale can be unrecoverable without Repair or high-DEF attackers. [LOW - balance watch, not a bug]
`enterFinale()` raises all four as The Risen at 6 HP each (24 HP total), any ATK,
`finaleClock=5`. Each finale turn `finaleAntagonistTurn()` disables up to 2 of
your attacking permanents (`FIN_ATK=3`, targets `defVsMonster(p)<=3`) with **no
thaw**. A board that cannot output ~5 ATK/turn while losing 2 attackers/turn, and
has no Repair, loses. This is the intended climax, and it is self-mitigating:
attackers with DEF > 3 are immune to the freeze, Repair (Builders/House Hand,
the most common faction here) restores frozen attackers, and the freeze cap
scales down as Risen die (`cap=min(2,alive)`). Flagging only as a balance value
to watch in playtest, not a correctness defect.

### F6. Death's phase-1 freeze does not detach attached recruits; the finale freeze does. [LOW - consistency]
Phase-1 Death sets `victim.disabled=true` directly (line 2246) and does not call
`detachRecruitsOnDisable()`. The finale freeze routes through
`monsterAttackPermanent()` (line 1738-1739), which *does* detach and discard
attached recruits. Same "freeze" concept, two different side effects. Phase 1 is
the more lenient of the two, so no player harm, but the inconsistency is a latent
surprise. Decide whether attach-on-disable should apply to Death's freeze too.

---

## Correctness confirmations (passed review)

- **Damage-type gating (attackHorseman, lines 2261-2283):** `pool =
  lwPool(r.woundedBy)` reads only the matching pool (siege->`S.atk_siege`,
  creature->`S.atk_creature`, any->sum). On strike it zeroes only the matching
  type (line 2267). The UI matches: "Wounded by <type>" label (line 2388) and
  the Strike button is disabled with the correct tooltip when `pool<=0`
  (lines 2390-2391). Wrong/insufficient ATK cannot wound a rider. Correct.
- **Win logic:** the only win is `attackHorsemanFinale()` when
  `lw.riders.every(dead)` in the finale (line 2308) -> `lw.won=true`,
  `portalDefeated=true`, `showGameEndOverlay(true)`. Killing all four in phase 1
  does **not** win; slaying Death (rider 4) calls `enterFinale()` (line 2279),
  which resurrects all four at 6 HP, `woundedBy='any'`, `dead=false`. The Risen
  "any ATK" flip is applied to every rider (lines 2291-2293). Correct per spec.
- **Loss logic:** phase 1 loses when `lw.stage>=4 && some rider alive`
  (lines 2254-2258); finale loses when `finaleClock<=0 && some Risen alive`
  (lines 2325-2328). The stage clock is forgiving: a kill while `stage>1` thaws
  one stage (`stage--`, line 2272), and `finale` short-circuits the phase-1
  clock (line 2226). No off-by-one into `stageNames[-1]` (decrement guarded by
  `stage>1`). Correct.
- **War escalation cannot silently outpace:** `wardedThisTurn` is set true on any
  wounding strike (line 2266) and checked before the +2 (line 2238), then reset
  (line 2251). Any nonzero creature strike in a turn prevents that turn's growth,
  so War only runs away if the player has *no* creature source at all (see F1).
- **Regression safety of the override:** `Object.assign({},c,...)` copies each
  card and `.map` returns a fresh array, so global `RECRUITS`/`BUILDINGS` are not
  mutated. The whole block is gated by `GAME_MODE==='long_winter'`. Creeping
  Doom is explicitly neutralized in `setupLongWinter()` (lines 2216-2217:
  `monsterQueue`, `monsterStates`, `reinforcements`, `monstersUnsealed`,
  `monstersWin` cleared). Tutorial and other-mode branches are separate and
  untouched. All `q` values are integer literals >= 1 and only applied when
  `(c.id in q)`, so no NaN/undefined qty can reach `expandQty`. Clean.

---

## Manual test plan (browser)

Run `simulator/serve.ps1` (static server on :8791); `file://` is blocked. Fastest
verification is the console (`S`, `resetGame`, and the Long Winter globals). Set
mode to Long Winter in the mode selector, or drive `GAME_MODE` then `resetGame()`.

### TP-1 Siege reachability (F-fix core)
1. Start `long_winter`. Inspect the recruit market over several refreshes;
   confirm Builders appear frequently and Siegeman/Warlord appear.
2. Play a Builder (or Siegeman/Warlord); confirm the Buildings market unlocks
   and a Siege weapon (Hwacha/Catapult/Trebuchet/Ballista) is buyable that turn.
3. Console check of pool composition:
   `RECRUITS_MODE = modeRecruits(); ` then count builders vs total, and
   `modeBuildings().filter(b=>b.subtype==='Siege')` should list 4 ids (bg17, bg4,
   bg9, bg18). Confirm no Caravan/Granary present.
4. Buy a Catapult; end turn; confirm `S.atk_siege` is >= its per-turn value at
   the next `startTurn`. Reach Famine and confirm you can chip it to 0 over 2-3
   turns.

### TP-2 Win path
1. Kill Conquest (any ATK), War (creature ATK), Famine (siege ATK), Death (any).
2. On Death's death, confirm the log shows THE RISEN and all four return at 6 HP,
   `woundedBy` flipped to any (`S.lw.riders.map(r=>[r.name,r.hp,r.woundedBy])`).
3. Spend pool across the Risen; confirm no-overkill carryover (a strike caps at
   the target's remaining HP and leftover is spendable on another Risen the same
   turn). Undo all four before `finaleClock` hits 0; confirm the WIN overlay.

### TP-3 Loss paths
1. Phase-1 timeout: never kill a rider; confirm winter deepens every 4 monster
   turns and Long Night at stage 4 with a rider alive ends the run.
2. Finale timeout: enter the finale, do not kill all four in 5 turns; confirm the
   defeat log/overlay.
3. War runaway (F1): reach War with zero creature ATK; confirm War is unwoundable
   and grows +2/turn until loss. Log this as expected-or-not for design.

### TP-4 Damage-type gating
1. On War with only siege/generic in pool: confirm Strike is disabled with tip
   "Need 🟡 Creature".
2. On Famine with only creature/generic: confirm Strike disabled, tip
   "Need 🔴 Siege".
3. Confirm a strike only drains the matching pool (e.g. striking Famine leaves
   `S.atk_creature` untouched).

### TP-5 Death freeze + finale freeze
1. During Death's ride, confirm one attacking permanent is frozen per turn and
   thaws after one turn; confirm attached recruits stay attached (F6).
2. In the finale, confirm up to 2 attackers are disabled per turn with no thaw,
   attached recruits detach, and Repair restores an attacker. Confirm attackers
   with DEF > 3 are never frozen.

### TP-6 Regression guard
1. In `standard`/Creeping Doom and each tutorial mode, confirm recruit/building
   counts are unchanged (spot-check `modeRecruits().length` and a couple of
   qtys) and that b2 Repair Master does NOT appear outside `long_winter`.
2. Confirm switching into and out of `long_winter` and back to standard leaves
   the monster queue / doom apparatus intact for the standard game.
