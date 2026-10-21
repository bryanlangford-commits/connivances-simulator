# Connivances — Game Modes (current)

**Corresponds to build:** `connivances_simulator_v11_6_4.html` (2026-10-02). **Seven** modes are implemented and live-verified. This supersedes the old `GAME_MODES_v11_6.md` (which covered four modes; two of those have since been redesigned — see notes).

## The iron rule (read first)

**The same card behaves identically in every mode.** No card is ever re-statted per mode. A mode may only change:

- **Pool** — which cards appear in the Recruit / Building / Conjuration markets (`modeRecruits` / `modeBuildings` / `modeConjurations`).
- **Starting deck** — forced unique starters, added via `seedStarterReplaceDA(ids)` (each replaces a Devoted Aid; hand stays 5, deck stays 10).
- **Setup** — starting Auspice, board apparatus (boss, clock, castle…).
- **Antagonist behaviour** — what the monster/boss/clock does each turn.
- **Win / loss conditions.**

Modes are picked from the header dropdown (`MODES` array / `#mode-select`), persisted in `localStorage`. Mode logic is isolated behind `S.mode` branches; switching calls `resetGame()`. **Creeping Doom is the default.** Mode-only actors (bosses, clocks, castles) live in the mode's `setup`/state, never in `cards.json`.

---

## 1. Creeping Doom — *The Seeping Portal*  `creeping_doom`

The full game; the baseline the other six reuse.

- **Pool:** full global pool (all recruits, buildings, conjurations incl. possessions).
- **Setup:** standard 5/10 opening; start on Harvest.
- **Antagonist:** four guardian monsters (**Ghoul Shaman always first** + 3 random of the 10) sit before the Portal, each with a **hidden unseal condition** (a **Seer** reveals one). Unsealed monsters enter the field and attack your Kingdom, **disabling** permanents and razing undefended market spaces.
- **Win:** close the exposed Portal. **Lose:** the monsters raze all **12 market positions**.
- This is the engine the planned **PvP** match is built on (the VP/Legend loop in `00_CURRENT_STATE_OVERVIEW.md §5`). Deep detail in the project's `V11_CREEPING_DOOM_BRIEF.md` / `V11_MONSTER_PRESSURE_BASELINE.md`.

---

## 2. The Long Winter — *Riders of the Frozen Gate*  `long_winter`

A sequential boss relay against a deepening Winter clock. **Reworked this cycle** ("uncorked": the Horsemen are the land's own buried suffering, not Portal invaders; the typed-attack callouts were corrected).

- **Antagonist:** the **Four Horsemen** ride **one at a time, in order** — Conquest → War → Famine → Death; only the active rider can be attacked.
- **Typed immunity (current, from `cards.json → horsemen`):** **Conquest** HP 8, wounded by **any**; **War** HP 10, wounded only by **🟡 Creature**; **Famine** HP 9, wounded only by **🔴 Siege**; **Death** HP 15, wounded by **any** and **flies**. Attacking with the wrong pool does nothing.
- **Winter clock:** advances through First Frost → Hard Frost → Deep Winter → **The Long Night**; timely kills thaw it back. Finale detail in `LONG_WINTER_FINALE_SPEC.md`.
- **Pool (current):** **all cards EXCEPT Granary and Caravans** (Walls, attach cards, all Builders included), plus a **mode-specific copy override** so Siege (which Famine demands) reliably surfaces: **Builder 24, Warrior 23, Augury 21, Conjurer 19, Farmer 19**. (Global pools are Warrior 30 / Augury 27 / Conjurer 24 / Builder 22 / Farmer 19; this override trims the over-represented guilds.) QA'd in `QA_FOUR_HORSEMEN.md`.
- **Win:** kill all four riders (Death last). **Lose:** reach The Long Night with any rider alive.
- **Auspice:** starts on **Winter** (that auspice and the horsemen carry `"modes":["long_winter"]`).

> ⚠️ The old pack listed a different typing (Conquest=Siege, War=generic, Death=Creature). That is **superseded**; use the table above.

---

## 3. Tutorial: Augury — *The Giving Tree*  `tutorial_augury`

**Redesigned this cycle.** (The old "Famine boss, reduce to 0" version is gone.) A **scripted** auspice lesson: you can't attack or build; you save a dying seedling by turning the seasons and letting the right hands work each one.

- **Pool:** Augury Mages + Farmers; buildings limited to Farm / Library / Armory / Granary; Conjurations kept minus Possessions.
- **Setup:** opens in **Famine**; it hands you the **Irrigator in hand** (and keeps the opening at 5/10 by trimming a Devoted Aid). State `S.tree` tracks vitality (70/100) and the current stage.
- **Six stages, each needs a specific play:** Drought (Famine → play Irrigator f2) → Turn the Season (Harvest → Agriculturist f3) → Growth Magic (Mystic → Herbalist a6) → Prune the Deadwood (Hunter → send a card to Legend) → First Winter (Winter → end turn holding cards) → The Tree Stands (Harvest → Reaper f4). The seer **gifts the tool for each stage** into your hand; re-gifts spent tools to prevent softlocks.
- **Finale:** once the tree blossoms, a "feed me" plant finale (`GIVING_TREE_FINALE_SPEC.md`).
- **Win:** carry the tree through the seasons / finish the finale. **No hard-fail loss** — it's a guided lesson.

---

## 4. Tutorial: Warriors — *The Sundering Stone*  `warrior_stone`

**Redesigned this cycle.** (The old "100-HP Boulder damage-race" is gone.) A beat-the-clock kill that teaches the Warrior **Muster** swarm, Dojo conversion, and Siege.

- **Antagonist:** a bull-headed **Minotaur (20 HP)** battering an ancient **ward-stone** whose seal is a slow clock. The Minotaur telegraphs its move each turn (⚡ War Cry / 🐂 Gore / 🛡 Guard). **Gore disables one of your permanents** for a window (never your rallied soldiers, which are ephemeral); countered by repair.
- **Teaching loop:** play several Warriors in one turn for a **Muster** burst of ⚪ (Footman at 2+, Vanguard at 3+, War-Captain stepped), and train Influence → ⚪ at the **Dojo**; then cut the Minotaur down.
- **Setup:** seeds a starting **rally** (w10, w10, w9) into the 10-card deck via `seedStarterReplaceDA`; no pre-placed permanents.
- **Pool:** Warriors + Farmers (+ Siege via Siegeman/Warlord; Dojo via any Warrior).
- **Win:** kill the Minotaur. **Lose:** the seal clock reaches 0 (the stone shatters). Detail: `SUNDERING_STONE_HIDDEN_PHASE.md`.

---

## 5. Tutorial: Builders — *Storming the Castle*  `builder_castle`

Teaches Siege-vs-walls, **Set bonuses**, and the Builder war-economy by sieging an enemy keep.

- **Antagonist:** a castle with three layers you breach in order — **Wall Line (14) → Golem (5) → Keep (10)**. The castle's **Wall Set (Walls 🔗 Portcullis)** makes the wall **+2 DEF** tough; **🔴 Siege does double to walls** (the counter). The castle counter-fires each turn; a standing Wall soaks the hit.
- **Setup:** seeds a **House Hand** (Builder) into the 10-card deck (opens Siege early) and pre-places a starting **Morale economy** (2 Encampments → +2 ⚪/turn). Start on Harvest.
- **Teaching loop:** build **two of the same building** for a recurring Set bonus; raise Siege to breach; keep a Wall up; **Remodel** (Master Mason) and Fortifier harden your buildings; Groundskeeper keeps farms running.
- **Win:** raze the Keep. State `S.castle`.

---

## 6. Conjurer Training — *The Summoner's Plight*  `conjurer_house`

**Rebuilt this cycle** (treant-boss + acquire-triggered possessions). Teaches summoning, the possession risk, and Cleric/Exorcist upkeep.

- **Antagonist:** a live **Treant** boss marching on a **Town** clock; every turn it batters the town and its roots **grapple (disable)** your summoned creatures. Fell it before Town Integrity hits 0.
- **The possession layer:** **acquiring** a conjuration is dabbling in wild magic — the refilled market slot can surface a **possession** (seeded at scripted depths in the conjuration deck) that flies off to **seize a market slot** until **banished** (spend ATK; a Cleric adds +2 vs possessions; without an Exorcist the covered card is destroyed) or **dispelled** (Exorcist spares the card beneath). Possessions spread on odd turns.
- **Setup:** seeds your Conjurer core into the 10-card deck (2 creatures + Conjurer's Aid + Exorcist); deliberately only two starting creatures so you must **buy reinforcements** (which risk possessions) to win. Start on Harvest.
- **Pool:** Conjurers + Farmers.
- **Win:** fell the Treant before the town falls. **Lose:** Town Integrity 0, or markets choked by possessions. Detail: `CONJURER_TUTORIAL_SPEC.md`, `CONJURER_TREANT_AND_POSSESSION_PRESSURE.md`.

---

## 7. Conjurer Duel — *The Rival Summoner*  `conjurer_duel`

**New this cycle; the no-netcode PvP trainer.** 1v1 vs a heuristic AI. State `S.duel`. Full spec: `CONJURER_DUEL_SPEC.md`.

- **Two castles, as real permanents:** your **Main Wall** (a `bg3` Walls permanent, DEF 14, in your Wall Row) and **Main Keep** (a `bg7` Fortress renamed "Keep", DEF 12, in your perm row) — so Meurtrière / Fortifier / Remodel / repair / Set-bonuses all work on them. The rival's wall/keep are simple structs. "Main" distinguishes them from weaker purchasable Walls (DEF 6).
- **All-or-nothing disable combat:** to disable a target your attack must meet its **DEF in one shot** — no chip, no carryover, unused attack is lost. Defeated units are **disabled**, not destroyed; the owner **heals** (creature) or **repairs** (building/wall) to re-enable it, and its ATK re-joins the **same turn**.
- **Wall rules:** Siege ×2 vs walls; **fliers** (currently the Gryphon) bypass the wall to hit creatures/keep. **Breaching a wall does not also take the keep the same turn** — the defender gets a turn to repair or re-wall. Disabling the enemy **Keep** wins.
- **The AI:** starts with a Builder unlock + 2 Broods deployed; must **recruit a Conjurer** to summon more; buys from the **same market** (real denial); **deploys purchases a turn later** (mirrors the deckbuilder cycle). Difficulty dial = `ai.income` (4 = "Rival").
- **UI:** the battlefield shows only the **rival** side (your target) with DEF + attackability per tile and **hover popovers** of each rival card; your own wall/keep/creatures live in your Kingdom with DEF + Active/Disabled.
- **Win:** disable the rival Keep. **Lose:** your Keep is disabled.
- **Parked (NOT current):** the **Occupy** keyword (king-of-mountain countdown), AI difficulty tiers beyond "Rival", and a larger flier roster are spec'd/proposed but **not built**. See `CHANGES_SINCE_v2_3.md`.

---

## Adding a new mode (pattern)

1. Add `{id,name,sub}` to the `MODES` array and an `<option>` to `#mode-select`.
2. Add `modeRecruits` / `modeBuildings` / `modeConjurations` filters for the new `id`.
3. Write `setupX()` / `xTurn()` / `renderXZone()`; keep all state under a single `S.<key>`. Use `seedStarterReplaceDA` for forced starters.
4. Branch on `S.mode==='<id>'` in `resetGame` (setup), `endTurnCore` (antagonist phase), `render` (objective zone), and the end overlay.
5. Never re-stat a shared card.
