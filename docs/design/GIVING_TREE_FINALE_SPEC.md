# The Giving Tree; "Little Shop" Twist Finale (Integrated Spec)

**Status:** ✅ BUILT 2026-09-11 in `simulator/connivances_simulator_v11_6_4.html` (behind the
`TREE_FINALE` const, default on). Functions: `enterPlantFinale` / `plantFinaleTurn` /
`attackPlant` / `plantFinaleWin` / `renderPlantFinaleZone` / `ensureFinaleGifts`; dispatched
from `treeTurn` (finale + finalePending branches) and the stage-6 interception. Numbers as
below (Sap 30 · Famine −10 · Winter −6 · Harvest +6/−15 life · Mystic +4/−10 life · lash to
Harvest each turn · Vitality-0 soft-retry · no-overkill ⚪ Strike). Verified via browser sim:
deny/feed/inert/lash/win/soft-reset/Strike + reveal timing through the real end-turn loop. Art
hook `tree_blight.png` (emoji 🌺 fallback until painted). Folds a design-lead pass
(reveal/structure/tone/stakes) and a tcg-designer pass (stat block, inversion table, numbers).

## Concept
You nurture a near-dead seedling for six wholesome stages. Stage 6 blossoms and "drops a
seed"; and then it turns on you. **"Feed me."** The auspice control you used to *save* it
is now the only way to *kill* it; **reverse-nurture**. Tone: Audrey II diva, camp,
teachable; never gore.

**The lesson, one line:** *"The season is a knife with no handle; it cuts whatever you
point it at."* Every feeding season that raised the seedling now feeds the monster.

**IRON RULE:** all mode-level actor logic; the plant only *reads* public state
(`S.auspice`, `S._playedThisTurn`, the ⚪ pool). Zero per-card re-stats; the auspices
behave identically to every other mode; only the *plant's interpretation* of them inverts.

---

## 1. The reveal beat (structure/tone)
Stage 6 ("The Tree Stands," Harvest + Reaper) lands **exactly as it does today**; blossom,
fruit, "drops a SEED," `🍎`. Let the player feel they won. **Then one enemy tick later** the
fruit doesn't fall:
1. The tree **speaks for the first time**: *"🌺 …Feeeed me."* Sprite snaps to a toothy bloom.
2. The **Vitality bar turns red and re-labels from "Vitality" to "YOU"**; the bar you spent
   six stages filling is now your own lifebar.
3. Banner: *"The Giving Tree has taken all it can give. Now it takes. You cannot flee, build,
   or strike it with steel; you have only the seasons. The hands that saved it must now
   starve it."*

Why it's an earned gotcha, not a rug-pull: no new verbs; the same five seasons the player
just drilled, but every lever now reads backwards. *"Oh no. I taught it to want this."*

**Tone lock:** greedy needy diva, not a demon. Barks are comedic entitlement ("More Harvest!
Is that ALL?", "Winter? You'd do Winter to ME?"). No gore; it "exhausts" you, doesn't devour.

---

## 2. The boss: "The Blight"; stat block

| Stat | Value | Notes |
|---|---|---|
| **HP (Sap)** | **30** | Starve to 0 = win |
| **Famine tick** (deny) | **−10 HP/turn**, no attack | Expert path; needs an `'any'` changer |
| **Winter tick** (deny) | **−6 HP/turn**, no attack | Accessible path (Augury Initiate); also banks your hand |
| **Harvest** (feed/trap) | **+6 HP heal, −15 Vitality** | Heal capped at 30 |
| **Mystic** (feed) | **+4 HP heal, −10 Vitality** | Lesser heal, but draws you a card; tempting |
| **Hunter / Usurp** | **inert** (flavor log only) |; |
| **Player Vitality** | **100, no floor** | The bar's meaning flips: now YOUR life, drained only by feeding seasons |

Resolved per-turn on the **ending auspice** in the antagonist phase (same read as Winter
dormancy / the tree actor already use). **No "turns-held-in-season" counter needed.**

**The lash:** each enemy turn the plant **snaps the auspice back to Harvest** (its favorite)
- the exact inversion of the old Famine tutorial (which snapped *to* Famine). So you must
**re-deny it (Famine/Winter) every single turn**; that re-flip is the whole control exercise.

### Pacing proof
- **Expert (Famine every turn):** 30→20→10→0 = **3 turns, 0 Vitality lost**.
- **Accessible (Winter every turn, Initiate-only):** 30→24→18→12→6→0 = **5 turns, 0 Vitality lost**.
- **Confused (sits in Harvest):** plant heals to full, you bleed −15 Vit/turn → ~7 turns to soft-reset; "the plant GORGES" fires every turn (loud, legible mistake).

---

## 3. The auspice-inversion table (2 deny / 2 feed / 2 inert)

| Auspice | Nurture meaning (stages 1–6) | FINALE effect on the Blight | Reachable via |
|---|---|---|---|
| **Famine** | the drought that nearly killed it | **DENY −10 HP**, no attack | `'any'` (Channeler/Witchdoctor/Fallah) |
| **Winter** | rest / hold hand | **DENY −6 HP**, no attack; freezes changers in hand | Augury Initiate (`'mystic-harvest'`) |
| **Harvest** | fed the roots | **FEED +6 HP, attack −15 Vitality**; the trap | Augury Initiate |
| **Mystic** | growth magic | **FEED +4 HP, attack −10 Vitality**; draws a card | Augury Initiate |
| **Hunter** | pruned deadwood | **INERT**; "does not fear the hunt" | `'any'` |
| **Usurp** |; | **INERT**; "cares nothing for coin" | Augury Initiate |

The reachability tier is a gift: **Winter = accessible denial** (the Initiate the player
mastered), **Famine = expert denial** (needs a real changer). And the trap is real; the
cheap Initiate also reaches **Harvest**, the season they were taught to love, which now
feeds the monster.

---

## 4. Win / lose

- **Primary win; starve HP to 0.** Requires only correct season denial. Fully winnable
  **without** Necromancer (the accessible Winter path clears it in 5 turns, 0 Vitality lost).
- **Necromancer ⚪-burst (flourish, recommended IN):** a **"🌑 Strike the Blight"** button
  spends the full ATK pool as direct HP damage, **1 ⚪ = 1 HP, no overkill** (reuse
  `attackHorsemanFinale`'s drain block). Precondition: a Necromancer (`a8`) in play; then
  every `setAuspice` already mints +1 ⚪. The elegant climax: **flipping to Famine to deny it
  also earns the ⚪ that finishes it**; control *is* the weapon. Capped (~≤2 ⚪/turn via gift
  throttling) so it shaves ~1 turn, never replaces the starve.
- **Fail = SOFT (finale-retry loop).** The whole tutorial is "you cannot fail, only learn" -
  don't break that at the climax. On **Vitality ≤ 0:** the Blight heals to full (30),
  Vitality resets to 100, dramatic log ("it gorged and surged back; deny it: Famine or
  Winter"). Real consequence (lost HP progress), zero terminal loss. **No doom clock** -
  Vitality *is* the clock, and it only ticks when you misplay. At **Vitality ≤ 25**, a mercy
  bark + explicit hint names the lever that saves you.

---

## 5. What it teaches (keep vs cut)
**Keep; the aha's:** (1) *control is a weapon*; invert everything from stages 1–6;
(2) *Winter banks your ammo*; holding an `'any'` changer under Winter guarantees you reach
Famine next turn (stage 5's dormancy lesson pays off); (3) *Necromancer burst*; denying
while Necromancer is out mints ⚪, Augury's one aggressive window, generated by the control
you're already doing.
**Cut; avoid clutter:** Hunter/Usurp are inert on purpose; don't teach multi-flip ⚪-farming
(allow as a hidden ceiling, never require); the feed-attack is pure **Vitality drain** (tree
players build ~no permanents, so don't lean on permanent-disable).

---

## 6. Build plan (reuse vs bespoke)
A small bespoke **`plantFinaleTurn()`** gated by `S.tree.finale`, reusing three patterns from
the Long Winter "Risen" finale:
1. **Phase flag + dispatch**; mirror `if(lw.finale){…}`; in `treeTurn`, `if(T.finale){ plantFinaleTurn(); return; }`.
2. **No-overkill Strike**; copy `attackHorsemanFinale`'s pool-drain into `attackPlant()` (single target; leftover ⚪ persists).
3. **Soft-reset**; replace Long Winter's hard `finaleClock` game-over with the Vitality-0 heal-and-restart above.

New logic ≈ 15 lines: read `S.auspice`, apply the inversion table to `T.plantHp` and
`T.vitality`, lash the auspice to Harvest, check win/soft-reset.

**⚠ Do NOT copy `monsterAttackPermanent`**; this mode has ~no permanents; the attack is
**Vitality drain + auspice-lash**, not board disable.

**Gift cadence (load-bearing):** each finale turn the seer gifts an **Augury Initiate**
(`ai`, guarantees the Winter path) and, for the expert path, a **Channeler** (`a3`, the
`'any'` use) every *other* turn. Without an `'any'` changer in hand, Famine is unreachable -
so the gift loop must keep at least Winter always available. For the burst path, keep/gift a
**Necromancer** (`a8`); ⚪ then accrues automatically on each `setAuspice`, spent same-turn on
`attackPlant`.

**Reuse `S.tree.vitality`** as the finale life total: on entry set `vitality=100`, drop the
`floor`, and **recolor/relabel** the meter (green "plant health" → red "YOUR life") so a
draining bar doesn't misread as progress.

---

## 7. The ending (dark-comedy button)
On the kill it deflates mid-tantrum: *"🥀 'But I'm still… HUNGRY-'"* → curls into a single
warm, rattling seed. Vitality re-labels back to green "Vitality (yours, kept)." Reward copy:
> **"🌰 You keep the seed. You've learned both halves of the season's knife; the hand that
> feeds and the hand that starves. Plant it if you dare."**

---

## 8. QA-testable checklist
- [ ] Reveal fires **once**, only after stage 6 blossoms (not before).
- [ ] Starve path wins **without** Necromancer (Winter-only clears in ~5 turns, 0 Vitality lost).
- [ ] Burst path (Necromancer in play) shortens the kill but can't one-shot (⚪ throttled ≤ Famine tick).
- [ ] Feeding season = plant heals + Vitality drop, with an explicit log each time.
- [ ] Lash re-snaps auspice to Harvest each enemy turn (player must re-deny).
- [ ] Vitality ≤ 0 → **retries the finale only** (plant to full, Vitality 100), never `resetGame`, never a terminal loss.
- [ ] Vitality ≤ 25 → mercy hint names the saving lever.
- [ ] Meter recolors/relabels on entry (no "draining = progress" misread).
- [ ] Famine always reachable when needed (gift cadence supplies an `'any'` changer or Winter stays lethal).
