# CONNIVANCES. Game Modes (v11.6)

Companion to `CONNIVANCES_Master_Rules_v2_3.md`. Canonical build:
`connivances_simulator_v11_6_4.html`. All four modes are implemented and
live-verified.

## The iron rule (read first)

**The same card behaves identically in every mode.** No card is ever re-statted
per mode. A mode may only change:

- **Pool**; which cards appear in the Recruit / Building / Conjuration markets.
- **Starting deck**; how many copies of each starter seed *this* mode's deck.
- **Setup**; starting auspice, board apparatus (boss, boulder, clock…).
- **Antagonist behaviour**; what the monster/boss/clock does each turn.
- **Win / loss conditions.**

Modes are selected from a header dropdown (`#mode-select`) and persisted in
`localStorage['conniv_mode']`. Mode logic is isolated behind `S.mode` branches;
switching modes calls `resetGame()`. Creeping Doom is the default.

---

## Mode 1. Creeping Doom · *The Seeping Portal*  `creeping_doom`

The full game. Four guardian monsters (Ghoul Shaman always first + 3 random) sit
in front of the Portal; each has a hidden unseal condition. Unsealed monsters
attack your Kingdom (three-board-states targeting; Wall Siege; markets razed when
undefended). **Win:** muster burst ATK to close the exposed Portal. **Lose:** the
monsters render all 12 market positions Razed-or-Haunted.

Full rules: master §13A (state machine, targeting, Wall Siege) + change-log §2–§5
(three board states, Possession plug, unseal set, Ghoul gate, Fifth Protector).
This is the baseline mode; the other three reuse its engine with a different
antagonist and win/loss.

---

## Mode 2. The Long Winter · *Riders of the Frozen Gate*  `long_winter`

A sequential boss relay against a deepening Winter clock.

- **Antagonist:** the Four Horsemen ride **one at a time, in order**. Conquest →
  War → Famine → Death. Only the active rider can be attacked.
- **Typed immunity:** each rider is wounded only by a specific ATK type
  (`woundedBy`): Conquest = 🔴 Siege, War = generic/⚪, Famine = any, Death = 🟡
  Creature (Death also **flies**). Attacking with the wrong pool does nothing.
- **Rider turn effects:** Conquest −2 Influence; War +2 HP if unwounded that turn;
  Famine locks the auspice to Famine (farms → 0); Death exiles the top of your
  deck.
- **The Winter clock:** advances a stage every 3 rider-phases through *First Frost
  → Hard Frost → Deep Winter → **The Long Night***. A timely kill **thaws** it back
  a stage.
- **Win:** kill all four riders (Death last). **Lose:** reach **The Long Night**
  with any rider still alive; the world freezes.
- **Auspice:** starts on the **Winter** auspice (this auspice exists only in this
  mode; `"modes":["long_winter"]` in `cards.json`).

State: `S.lw` (`stage`, `turnsThisStage`, `activeIdx`, `riders[]`). Horsemen data
lives in `cards.json → horsemen`.

---

## Mode 3. Tutorial: Augury Mages  `tutorial_augury`

Teaches auspice control feeding ⚪ ATK. **No loss condition; you cannot fail,
only learn.**

- **Pool:** Recruits filtered to **Augury Mage + Farmer**. Buildings limited to
  Farm / Library / Armory / Granary. Conjurations kept (Augury buys them via
  Soothsayer under Mystic) **minus Possessions** (no Conjurer in-pool to clear
  them).
- **Antagonist:** a single **Famine** boss (HP 9) that **re-locks the auspice to
  Famine every turn** (farms → 0). The lesson: change it back on your turn to
  restore food, and turn each auspice change into ATK.
- **Teaching loop:** **Necromancer** gives +1 ⚪ ATK per auspice change; **Poison
  Room** converts Farmer Food → ⚪; or play **Soothsayer** under **Mystic** to buy
  Conjurations with no Conjurer. Build ATK, then Strike (Famine takes any type).
- **Win:** reduce Famine to 0. **Setup:** starts on the **Harvest** auspice so
  farms visibly work before Famine disrupts.

State: `S.tut` (`boss`, `won`).

---

## Mode 4. Tutorial: Warriors · *The Sundering Stone*  `warrior_stone`

A damage **RACE** that teaches the Warrior/Siege ATK engine and repair.

- **The objective:** a shared **100-HP Boulder**. You and the Minotaur both smash
  it. **When it breaks, the higher damage total wins; ties go to the player.**
  Two live ledgers (`playerDealt` vs `minoDealt`). The Boulder takes **any** ATK
  type (⚪ + 🔴).
- **Two targets each turn:** *Strike Boulder* (your whole ATK pool → the Boulder,
  credited to you) or *Stagger Minotaur*.
- **The Minotaur cannot be killed.** Striking him to 0 HP **staggers** him: he
  skips his next **2 smashes** (buying you a lead), then returns at **full HP**.
- **He escalates:** boss HP 15; heals **+5 every 3rd turn**; smash power starts
  **3, +1 every 4th turn** (cap 7).
- **Gore (attacks your board):** when you're even or ahead on the ledger he
  **gores your best weapon** instead of smashing. Dojo > Trebuchet > Catapult -
  **disabling it for 2 turns**. Countered by **House Hand** repair. When he's
  behind with no weapon to gore, he just smashes.
- **Pool:** Recruits = **Warriors + Farmers, no Commander** (`w7` excluded).
  Buildings = **Farms + Dojo + Siege** only (any Warrior opens Siege; House Hand,
  a Builder, also opens the building market). **No Conjurations.**
- **Starting deck (mode-specific):** swaps **2 Devoted Aids → 2 House Hands**
  (`b1`). House Hand gives Builder access (buy Siege without waiting on a Warrior
  draw) **and** "Repair 1 disabled permanent"; the direct counter to the gore.
  Deck: King's Note ×2, Devoted Aid ×3, House Hand ×2, Farm Hand ×1, Augury
  Initiate ×1, Rice Field ×1 (10 cards).
- **Win:** break the Boulder with the higher damage total. **Lose:** the Minotaur
  breaks it first.
- **Setup:** starts on **Harvest** (farms feed the war effort). The Boulder and
  the boss config are **mode apparatus** (`S.ss`), not cards; `mn_minotaur`'s
  5/5 card stats are untouched (iron rule).

**Design note (tuning knobs, all in `setupWarriorStone` / `warriorStoneTurn`):**
boss HP & heal cadence, `baseDmg` escalation cap, gore target priority, the
2-turn disable window, and the House-Hand count in the starter deck. House Hand is
`vp:1`, so the two freebies add +2 starting VP; negligible in a tutorial, worth
noting if these runs are ever scored.

---

## Adding a new mode (pattern)

1. Add `{id,name,sub}` to the `MODES` array and an `<option>` to `#mode-select`.
2. Add `modeRecruits/modeBuildings/modeConjurations` filters for the new `id`.
3. Write `setupX() / xTurn() / attackX() / renderXZone()`; keep all state under a
   single `S.<key>`.
4. Branch on `S.mode==='<id>'` in: `resetGame` (setup + any starter-deck swap),
   `endTurnCore` (antagonist phase), `render` (monster-zone), `showGameEndOverlay`
   (win/loss text).
5. Never re-stat a shared card. Mode-only actors (bosses, clocks, objectives) live
   in the mode's `setup`/state, not in `cards.json`.
