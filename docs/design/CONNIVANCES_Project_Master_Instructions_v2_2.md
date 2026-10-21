# CONNIVANCES. Project Master Instructions
## Card Game Design & Development Hub
**Version:** 2.2 | **Status:** Active Development | **Last Updated:** July 2026
**Source Truth:** `Connivances_Tracks_v3.xlsx` (New Card Index 1_10_24) + `connivances_simulator_v11.html` (current build) + `CONNIVANCES_V11_Session_Changelog.md` (running session record)

---

## CHANGE LOG; v2.1 → v2.2

v2.2 opens the **V11 session**. The simulator was renamed `connivances_simulator_v11.html` (zero mechanical changes at the bump, diff-verified). Three rulings from Bryan at V10 close are logged; two batches of verified bug fixes are implemented; open items are renumbered forward from 53.

### Bryan's Rulings (LOCKED; canonical text)

| # | Ruling | Status |
|---|---|---|
| **R1** | **Cleric choice economy.** Each Cleric played grants ONE use of a CHOICE: EITHER heal one creature OR +2 ATK toward Possessions. N Clerics = N uses; possession-ATK accumulates per use spent on it (2 Clerics = heal 2, or +4, or heal 1 + +2). Replaces BOTH the flat-+2 flag AND the V10 heal-on-play behavior; the two effects are now mutually exclusive per use. Exorcist/Enforcer heals unchanged. **Resolves item 22.** | ✅ Ruled · ⏳ Not implemented · UX open (item 58) |
| **R2** | **Blocked field monsters attack Recruit market slots.** Priority: (1) Monster Ability check *(system undesigned; item 53)*; (2) player permanents remain highest; if none attackable and no Wall Siege can form, attack a RANDOM Recruit market slot, shutting it down PERMANENTLY. Re-check permanents first each turn; when all Recruit slots are gone, move to random Building/Conjuration slots. NEVER Possessions. Creates market-strangulation loss pressure; largely removes field-monster retreat. | ✅ Ruled in principle · ⛔ Blocked on items 53–57 |
| **R3** | **Familiar draws on mid-turn heal.** A Familiar healed mid-turn retroactively grants its draw for that turn (extend `grantMidTurnIncome` / heal path). **Resolves item 25.** | ✅ Ruled · ⏳ Not implemented |

### Implemented in V11 so far

| # | Item | Detail |
|---|---|---|
| V11-0 | Version bump | v10 → v11 file rename; title/masthead/footer only. |
| V11-1 | **Wall Siege self-participation fix** | A freshly unsealing monster (state set to `field` pre-check) was counted as its own siege partner; one monster double-counted its ATK and satisfied the ≥2-participant rule alone. `checkWallSiege` now excludes the initiating monster from the field-partner gather. **Companion fix:** `executeWallSiege` only sends a `guarding` initiator on the one-turn `siege` excursion; a freshly unsealed `field` initiator stays `field` (it is permanently unsealed and must not be retracted to `guarding` by Step 0). |
| V11-2.1 | **VP double-count fix** | Played permanents carry a different uid in `S.played` than in `S.permanents`, so `calcVP`'s uid dedup never matched; permanents scored twice on their play turn (inflating final score on portal-kill turns). `calcVP` now skips `isPermanent` entries in the `S.played` loop. |
| V11-2.2 | **Portcullis creature immunity enforced** | The printed "Immune to 🟡 Creature ATK" had no live code path (only a dead branch in `checkWallSiege`). `monsterPickTarget` now filters Portcullis from creature-type attackers' candidates (Fiend, Nightmare). Non-creature monsters unaffected. ⚠️ Scope note: item 4's bonded-set extension is NOT yet enforced; see item 61. |
| V11-2.3 | **Farm food delta corrected** | `setAuspice`'s real-time delta used a ±1 model that disagreed with `farmFoodValue` (Famine zeroes farms) for base-2 Farms. Delta now diffs true output per auspice. |
| V11-2.4 | **Food-mint exploit closed** | The `max(0,…)` clamp swallowed negative deltas at low food but re-credited on switch-back (Harvest→Famine→Harvest minted food). New per-turn `S.farmFoodDebt` ledger repays clamp-swallowed losses before crediting positive deltas; reset in `startTurn`. Round trips net zero. |
| V11-2.5 | **Silent Stalker flies** | Data had `fly:false`, contradicting its tooltip, targeting comment, and §13/§13A (Stalker = flying, bypasses Walls). Doc-wins: `fly:true`. |
| V11-2.6 | **Repair/heal no longer strips Wall Set DEF** | The Wall Set +2 is written into `currentDef` once at bond time; `useRepair`, the heal picker, and `dispelPossession` reset to base `def`, permanently losing it. New canonical `recomputeStoredDef(p)` (base + attachment `defBonus` + WallSets×2 for Creature/Siege, matching `applyWallBond`'s criterion) used at all three sites. Golem/Gargantuan/Fortress remain live via `effectivePermDef`. |

### New / updated open items (Section 10)

Items **53–61** added (Monster Ability system; R2's cut-off "3+" tier; recruit-slot destruction details; retreat reconciliation; field turn order; R1 UX; unseal-rush fast win; Expediter −2 repair gap; Portcullis bonded-set immunity scope). Items **22** and **25** marked ruled. Items **17, 19, 23** annotated with V11 status.

---

## CHANGE LOG; v2.0 → v2.1

v2.0 was generated from a **mid-session snapshot** of the V10 changelog. v2.1 integrates the **final V10 state**: one correction, six new open decisions, eight late-session implemented mechanics, and six must-not-regress additions. v2.0 is archived.

| # | Item | Resolution in v2.1 |
|---|---|---|
| **CORRECTION** | Wall Siege was mislabeled | v2.0 item V10-16 said Wall Siege was "flagged / deferred; not implemented." **This was wrong for the final build.** Wall Siege **IS fully implemented.** Section 13B rewritten from a deferred spec into implemented rules. State machine reconciled to the code's actual `guarding | field | siege | dead`. |
| 21-A | Cleric stacking vs Possessions | ⚠️ **NEW open. BLOCKS V11.** Cleric anti-Possession bonus is currently flat +2 regardless of Cleric count. Stack / flat / cap decision needed. Section 10 item 22. |
| 21-B | Seeping Portal has no reachable loss | ⚠️ **NEW open. BLOCKS V11.** Monsters disable but never destroy, and the deck cycles forever, so `checkLossCondition` is unreachable and the Portal cannot win. Four options framed. Section 10 item 23. |
| 21-C | Trophy immunity scope | ✅ **RESOLVED; documented.** Trophies are immune to ALL monster targeting in single-player (Trophy Zone purpose). The "Trophies can be Disabled / Repair restores them" ruling is scoped to **future PvP only.** The two rulings do not conflict. Section 5A + Section 10 item 15 updated. |
| 21-D | Demented Architect effect2 unimplemented | ⚠️ **NEW open.** "Building bought this turn may change subtype, then → Legend" has no handler; interacts with subtype-keyed set pairing. Section 10 item 24. |
| 21-E | Familiar draw on mid-turn heal | ⚠️ **NEW open.** `grantMidTurnIncome` deliberately does not re-fire draw passives; ruling needed on whether healed Familiars retroactively draw. Section 10 item 25. |
| 21-F | Supplier multiples | ⚠️ **NEW open.** Supplier convert is a turn-flag; multiple Suppliers add nothing extra. Same decision class as Cleric stacking. Section 10 item 26. |
| V10-L1 | All remaining browser dialogs eliminated | ✅ Six interactions that were silently failing now use a generic `showListPicker()` overlay. See Section 13A / 14. |
| V10-L2 | Repair is buildings-only | ✅ `useRepair` rejects creatures; heals are the creature path. Explicit 🔨 Repair buttons on disabled non-creature cards. |
| V10-L3 | Mid-turn income restore | ✅ `grantMidTurnIncome()` restores a permanent's per-turn ATK/Inf/Food when healed/repaired mid-turn (Auspice-aware Food). Draw passives excluded. |
| V10-L4 | Granary stored-food chip | ✅ "🌾 N Food stored" between turns; "🌾 +N Food in pool" on release turn. Pool math unchanged. |
| V10-L5 | Supplier convert on its card | ✅ Global actions-bar button removed; "🌾 Convert 1 Food → Draw (N left)" renders on the Supplier card. |
| V10-L6 | Siege monsters attackable | ✅ `attackFieldMonster` accepts `siege` as well as `field`, matching the locked Wall Siege rule. |
| V10-L7 | Dark Magic famine flag | ✅ Dark Magic setting Famine now sets `famineEverActive` (Ghoul unseal fired one turn late before). All Auspice-assignment sites audited. |
| V10-L8 | Portal defeat + endgame overlays | ✅ Defeated Portal renders "🏆 THE PORTAL IS SEALED"; VICTORY / DEFEAT overlays show final VP with View Board / New Game. |

---

## CHANGE LOG; v1.9 → v2.0

All items below were resolved and implemented during **V10 development ("The Seeping Portal" single-player build), June 2026.** Section 13 upgraded from design-spec-only to implemented. New Section 13A added for the implemented monster system. Section 14 gains a Faction Unlock Campaign stub.

| # | Item | Resolution |
|---|---|---|
| V10-1 | Single-player mode implemented | ✅ **The Seeping Portal is built and playtested.** Section 13 Mode 1 is no longer design-only. Modes 2 (Time Crisis) and 3 (Survive the Famine) remain designed-but-unbuilt. |
| V10-2 | Simulator version | ✅ `connivances_simulator_v9.html` → `connivances_simulator_v10.html`. V9 frozen. V10 extends `S`, never restructures it. |
| V10-3 | Single-player monster queue | ✅ Queue = Ghoul Shaman (always first) + 3 random non-Ghoul monsters + The Portal (always last). 5 total. |
| V10-4 | Monster state machine | ✅ Four states: **Corked** (at portal, not yet unsealed), **Guard** (unsealed, still blocking portal), **Field** (actively attacking Kingdom), **Dead**. |
| V10-5 | Monster turn | ✅ A monster turn fires between player turns. All Field monsters attack Kingdom permanents. Guard monsters block portal access but do not attack. |
| V10-6 | Unseal timing | ✅ Monsters attack the **same turn** they unseal. Unseal conditions **never re-trigger** once fired; a monster that retreats stays permanently unsealed. |
| V10-7 | Retreat / re-entry | ✅ A retreated monster can re-enter the field on a later monster turn if valid targets exist. Its unseal condition does not re-evaluate. |
| V10-8 | Portal exposure rule | ✅ Resolved (was open "3 of 9" in v1.9). The Portal becomes directly attackable only once **no guards remain corked**; every monster must be killed or in the field. |
| V10-9 | Monster targeting priority | ✅ Caravans → lowest-DEF Wall → monster-specific priority → highest-VP permanent → random. |
| V10-10 | Monster combat vs Walls | ✅ Non-flying monsters must break Walls first. Flying monsters (Nightmare) bypass the Wall row. Disabled permanents can't be re-attacked until repaired. |
| V10-11 | Trophy zone column | ✅ Kingdom layout changed from a two-zone vertical stack to a **three-column layout**: `kingdom-main` (Wall Row over Buildings & Conjurations) on the left, and a dedicated **Trophy zone column** on the right spanning both rows (gold border, label "🏆 TROPHIES; not targeted by monsters", "No trophies yet" when empty). **Trophy permanents are excluded from monster targeting**. Field monsters never attack them. |
| V10-12 | Set-pair visual grouping | ✅ Bonded set pairs render with chain-link connectors in the Kingdom UI. |
| V10-13 | Auspice tooltips | ✅ All Auspice pills always show their effect description on hover. |
| V10-14 | Portal queue tooltips | ✅ Queue monsters show tooltips with their unseal condition and attack priority. |
| V10-15 | Overlay pickers replace prompts | ✅ `prompt()` dialogs are silently blocked in-browser. All wall-bond and attach-target UI replaced with overlay pickers. See Section 12A. |
| V10-SETS | Set completion redesigned | ✅ Non-Wall set completion moved from id-based one-time checks to a **subtype-driven (`Key_Word_Type`) model with a code lookup table.** A set forms when two active permanents share a subtype AND at least one carries a `completionBonus`. Both bonuses fire if two different bonus-carriers of the same subtype pair (Armory + War Room → both). Locked after first completion per subtype. Recurs each turn only while both members active. ⚠️ The **recurring-vs-one-time behavior for Draw-type bonuses is left OPEN** pending Bryan's ruling (Section 10, item 18). Wall sets still use the separate bonding system. |
| V10-TAUNT | isTaunt distinction | ✅ Only the **Walls card (bg3, `isTaunt:true`)** forces "must be attacked first." Portcullis and Fortress keep `isWall:true` for set bonding but **no longer block monster targeting**. `monsterPickTarget` and `checkWallSiege` gate on `isTaunt`, not `isWall`. Fixes the bug where Portcullis/Fortress wrongly stonewalled monsters. |
| V10-STACK | Set bonuses stack | ✅ Identical bonuses in a pair **stack** rather than dedupe: two Irrigated Fields = +4 Influence; Trophy Room + Scriptorium = Draw 4. Recurring bonuses (Influence, ATK) fire at completion and every subsequent turn while both members active; disabling either member pauses the bonus (label shows "(paused)"). |
| V10-CHIPS | Buff/debuff chip visualization | ✅ Cards show chips below stats: green ▲ for buffs, red ▼ for debuffs, each with a hover tooltip naming source and amount (e.g. "Sir Cluckles ×2: +2 🟡 ATK"). Reads live from buff sources via `getCreatureBuffs()`; reports only, never modifies the pool. Turn-only buffs (Handler) vanish at end of turn; passive buffs (Golem Defender, Sir Cluckles, Fortress, Wall Set) persist while the source is active. |
| V10-EXOR | Exorcist dispel | ✅ While an Exorcist is played this turn, market Possessions show a free "🧿 Dispel" button (no ATK cost): Possession → player Legend (VP kept), on-defeat effects fire, host to bottom of its deck. **Limit: one dispel per turn** (`exorcistDispelUsedThisTurn`). After use, remaining Possessions revert to Attack buttons until a future Exorcist. |
| V10-ATTACH | Attachment limit | ✅ **One recruit attachment per permanent.** Already-attached permanents are excluded from pickers. Targeting: Meurtrière → Walls; Fortifier → buildings (Farms valid; NOT creatures, walls, or trophies); Retinue → creatures. Attached cards show a 📎 badge. Possessions do not count toward the limit. |
| V10-HUNTER | Hunter legend-send deferral | ✅ The mandatory Hunter legend-send picker now has "↩ Cancel; play more cards first"; closes the overlay while keeping the obligation live, re-openable after more cards are played. Still enforced by end of turn. |
| V10-MARKET | Unified market layout | ✅ Markets rebuilt as a unified horizontal layout with full-detail cards. Badge redesign (Option A: render-time stripping of redundant resource phrases from market cards only; card data untouched) approved; glow/aura polish (Option C) stored for future consumer-facing work. |
| V10-16 | Wall Siege mechanic | ✅ **Implemented** (corrected in v2.1; v2.0 wrongly marked this deferred). Full rules in Section 13B. |
| V10-17 | Faction Unlock Campaign | 📓 Concept stub added to Section 14 (Future Ideas). Not scoped. |
| V10-BUGS | V10 bug fixes | ✅ Nine playtest bugs fixed; see Section 12A.13A (V10 Must-Not-Regress). |

---

## CHANGE LOG; v1.8 → v1.9

All items below were resolved during v9 simulator development (May 2026). Section 3 and Section 10 updated accordingly.

| # | Item | Resolution |
|---|---|---|
| NEW | Auspice real-time food adjustment | ✅ Switching Auspice mid-turn immediately adjusts `S.food` by the delta of Farm bonus/penalty. If 2 Farms are in play and you switch from Harvest (+1/farm) to Mystic (0/farm), food drops by 2 immediately. Switching back restores it. This applies every time the Auspice changes within a turn. |
| NEW | Mystic immediate draw on switch | ✅ Switching TO Mystic mid-turn draws 1 card immediately. Switching away from Mystic (to any other Auspice) does not remove cards already drawn. Switching back to Mystic again draws another card. This is in addition to the end-of-turn 6-card draw. |
| NEW | Auspice change is persistent for the turn | ✅ Cards that grant an Auspice change (Channeler, Witchdoctor, Fallah, Augury Initiate) unlock free switching for the **rest of the turn**; the ability is not consumed on first use. Players may switch back and forth freely. Each switch triggers real-time food and Mystic draw effects as above. |
| NEW | Augury Initiate restriction scope | ✅ Augury Initiate restricts switches to Mystic or Harvest only, for the rest of the turn. Playing a second Auspice-change card (e.g. Channeler) in the same turn lifts the restriction, allowing all four. |
| NEW | Hunter auspice mid-turn Legend | ✅ Under Hunter Auspice, non-permanent cards in the Played area show a → Legend button. Clicking it sends that card to Legend immediately (removing it from the discard pile). One Legend send available per turn under Hunter Auspice. |
| NEW | Hunter Warrior card | ✅ Playing the Hunter (Warrior) recruit also grants one → Legend send from the Played area, independent of the Auspice. |
| NEW | Irrigator Famine immunity | ✅ Playing Irrigator sets a `irrigatorPlayedThisTurn` flag. While set, the Famine penalty (farms produce 0 Food) is not applied for the rest of that turn; farms produce normally. |
| NEW | Reaper Harvest bonus | ✅ Reaper gives +2 Food (instead of +1) when played under Harvest Auspice. Evaluated at play time. |
| NEW | Conjurer's Aid Mystic draw | ✅ Conjurer's Aid draws 1 extra card immediately when played if Mystic Auspice is currently active. |
| NEW | Scribe Mystic draw | ✅ Scribe draws 1 card per Armory or Library in your Kingdom when played under Mystic Auspice. |
| NEW | Herbalist food count | ✅ Herbalist gives +1 Food per Augury Mage played this turn (including itself). Evaluated at play time. |
| NEW | Guild color system | ✅ Cards display a colored left border and tinted guild chip. Farmer=brown, Warrior=pink, Augury Mage=blue, Conjurer=red, Builder=green, Factionless/Starter=grey, Possession=dark red. |
| NEW | Card hover tooltip | ✅ All hand cards and market cards show a dark floating tooltip with full effect text on hover. Cards no longer need to fit all text within the card body. |

---

## CHANGE LOG; v1.7 → v1.8

All items below were resolved in a single design session (May 2026). Section 10 updated accordingly.

| # | Item | Resolution |
|---|---|---|
| 1 | Rice Field food output | ✅ +2 Food/turn as permanent. Respects Harvest (+1 bonus) and Famine (0 output). |
| 3 | Warlord inclusion | ✅ Included in v1.7 and v9. Effect applies retroactively and forthcoming. Two Warlords double the effect. |
| 6 | Possession trigger timing | ✅ Possessions trigger on draw into the market row. |
| 7 | Commander free Conjuration | ✅ Gate bypass + cost 0. Requires both Pikeman AND Commander played same turn (either order). |
| 8 | Trophy lifecycle | ✅ Defeated Trophies → Discard. On draw + play → enter Kingdom as permanents with printed DEF as HP. PvP: attackable. Rewards fire on placement and once per turn while Active. Auspice tag = +1 HP defensive buff when matching Auspice is active (not a reward condition). Repair restores to printed DEF + Auspice bonus if applicable; all rewards reactivate instantly including draw effects. |
| 9 | Repair timing | ✅ No formal combat phase. ATK pool spent freely at any point during turn. Repair triggers the moment a Repair card is played. Repair count: Repair = 1 building, Repair 2 = 2 buildings, stacking across multiple cards. |
| 13 | Portcullis ATK type immunity | ✅ Portcullis (and its bonded Wall set) immune to 🟡 Creature ATK only. Three ATK token types now formally defined. |
| NEW | ATK token type system | ✅ Three distinct ATK types defined: 🟡 Creature, 🔴 Siege, ⚪ Generic. See Section 2A. |
| NEW | Creature keyword full list | ✅ Confirmed: Brood, Armored Hound, Familiar, Gryphon, Golem Defender, Tiger, Sir Cluckles, Fiend, Nightmare. |
| NEW | Fiend & Nightmare lifecycle | ✅ Non-Trophy. Played from hand → resolve effect → Discard. Standard reshuffle/replay lifecycle. Creature-type ATK when played by a player. Nightmare retains Flying. Fiend retains +2 ATK and discard-shuffle ability. |
| NEW | Trophy reward timing | ✅ Triggers on placement (one-time). Recurring rewards fire once per turn at any point during owning player's turn. Disabled Trophies suspend all rewards. See Section 5A. |
| NEW | Warlord effect clarification | ✅ Retroactive burst on play + forthcoming Warriors that turn. Two Warlords = double effect. |

---

## EXECUTIVE SUMMARY (For CEO Briefing)

**What this document is:**
This file is the single authoritative reference that all other development conversations in this project must pull from. It captures the complete game design; every card, every mechanic, every rule; extracted from the working prototype and the official card index. Any future Claude conversation in this project folder that is building a feature, UI, rules document, balance sheet, or new mechanic should be pointed to this file first. It eliminates rework, prevents design drift, and ensures every output is consistent with the creative vision.

**What it enables:**
- Designers get a reference without re-reading the code
- Developers get the data schema and mechanic rules in one place
- A CEO or investor can understand the full scope of the game without playing it
- Conversations can be spun up for specific tasks (card art prompts, rule book writing, digital UI, balance testing) with zero ambiguity

---

## SECTION 1. GAME IDENTITY

| Property | Value |
|---|---|
| **Title** | Connivances |
| **Genre** | Deck-Building Card Game |
| **Format** | 1–4 Players (Competitive / Co-op vs. Monster Queue) |
| **Win Condition** | Defeat the Guardian Monster queue including The Portal; most VP wins |
| **Core Loop** | Play cards from hand → spend resources → buy better cards → build kingdom → attack monsters → repeat |
| **Design Pillars** | Economy management, faction synergy, deck thinning (Legend mechanic), kingdom building, auspice control |

---

## SECTION 2. RESOURCE SYSTEM

| Resource | Symbol | Description |
|---|---|---|
| **Food** | 🌾 | Turn currency. Each card costs 1 Food to play. Starting: 3/turn. Produced by Farm buildings. |
| **Influence** | 💠 | Purchase currency. Generated by playing Recruit cards. Used to buy from all three markets. |
| **Attack (ATK)** | ⚔ | Combat pool. Spent to damage monsters and permanents. Cannot carry over turns. Three distinct types; see Section 2A. |
| **Defense (DEF)** | 🛡 | Permanent HP for buildings and creatures. Reduced when attacked. |
| **Victory Points (VP)** | ⭐ | Face value on all owned cards at game end. Trophied monsters add VP. |
| **Legend** | 📜 | A permanent exile zone. Cards in Legend are retired from the deck but their VP still counts. Deck-thinning mechanic. |

**Resource Flow Per Turn:**
1. Start: Food = 3 + (permanent farm bonus) ± Auspice modifier
2. Play cards from hand, each costing 1 Food
3. Resolve card effects (Influence, ATK, Food, draws accumulate)
4. Spend Influence to purchase cards from markets (if gates are unlocked)
5. Spend ATK freely at any point during the turn; no formal combat phase
6. End Turn: discard hand + played non-permanents, draw 5 cards (6 if Mystic Auspice)

---

## SECTION 2A. ATK TOKEN TYPE SYSTEM

Three distinct ATK types coexist in the pool. They can be spent jointly against valid targets, but each type has its own targeting restrictions. Physical play uses colored tokens. Digital play tracks them as separate counters.

| Type | Token | Source | Targeting Restrictions |
|---|---|---|---|
| **Creature ATK** | 🟡 Yellow | Any card with the Creature keyword: Brood, Armored Hound, Familiar, Gryphon, Golem Defender, Tiger, Sir Cluckles, Fiend, Nightmare | Cannot target Portcullis or any Wall card bonded to Portcullis in a Wall Set |
| **Siege ATK** | 🔴 Red | Siege-subtype buildings (Catapult, Trebuchet) and Siegeman bonus | Can target anything. **Reserved flag:** potential double-damage-to-Walls ruling under design consideration. Not yet implemented. |
| **Generic ATK** | ⚪ White | All other sources: Recruit cards, Trophy passive ATK (Dank Beast, Dragon), building exchanges (Dojo, Armory, Poison Room, War Room), and any source not tagged Creature or Siege | Can target anything |

**Portcullis Immunity Rule (Full):** Portcullis and any Wall card bonded to it in a completed Wall Set are immune to 🟡 Creature ATK entirely. A player with an ATK pool of 7 where 3 points are Creature-sourced has only 4 points of usable ATK against Portcullis and its bonded set. The full 7 may be spent against any other target.

**Flying Bypass:** A single Flying creature (Gryphon, or Nightmare when played by a player) in the attacker's field allows the full ATK pool; all three types; to bypass the Wall row entirely and target any Back Row permanent directly. Flying overrides Wall row protection but does not override Portcullis creature immunity. A flying attacker targeting Portcullis still cannot apply 🟡 Creature ATK to it.

**Siege Double-Damage (Future):** 🔴 Siege ATK is formally separated now in anticipation of a potential ruling that Siege deals double damage to Wall-type buildings. This is not yet implemented. The type separation ensures no rework is needed when this decision is made.

---

## SECTION 3. AUSPICE SYSTEM

The Auspice is a global modifier. Only one is active at a time. **Auspice effects are real-time**; they apply immediately when the Auspice changes, not only at turn start or end.

| Auspice | Icon | Effect | Changed By |
|---|---|---|---|
| **Mystic** | 🌙 | Cleanup draw = 5 (standard for all players). Start of turn: +1 additional card drawn. Mid-turn switch: draw 1 card immediately. Cards with "The Mystic:" text gain bonus effects when played. | Channeler, Witchdoctor, Augury Initiate (Mystic or Harvest only), Fallah, any Augury Mage ability |
| **Hunter** | 🦅 | May move one card played this turn to Legend. Applies for the rest of the turn once active. | Hunter (Warrior card), Silent Stalker (Trophy) |
| **Harvest** | 🌾 | Farms produce +1 Food per Farm per turn. **Real-time: switching to Harvest mid-turn immediately adds +1 Food per active Farm. Switching away removes it immediately.** Reaper gives +2 Food instead of +1 when played under Harvest. | Augury Initiate (Mystic or Harvest only), Channeler, Witchdoctor, Fallah |
| **Famine** | 💀 | Farms produce **no Food** (output set to 0, regardless of base value). **Real-time: switching to Famine mid-turn immediately zeroes all active Farm food contributions. Switching away restores them.** Irrigator blocks Famine penalty for the turn it is played. | Dark Magic (forces Famine, no player choice), Noxious Beast (Trophy, passive) |

**Real-time food adjustment rule (critical):**
Every time the Auspice changes, `S.food` is adjusted immediately by the delta of the Farm bonus across all active (non-Disabled) Farm permanents. Formula per Farm: `delta = newBonus - oldBonus` where `bonus` is `+1` for Harvest, `0` for Mystic or Hunter, and under Famine the farm output is set to `0` entirely (not just -1). Multiple changes in one turn each trigger a fresh delta calculation.

**Auspice change unlock rules:**
- Only specific cards grant the ability to change the Auspice. The pills are locked by default.
- Each auspice-change card grants **one use**, added to a queue (`auspiceUses[]`). Each use is either `'any'` or `'mystic-harvest'`.
- Playing N auspice-change cards banks N uses, spent independently at any point during the turn.
- You cannot switch to the **currently active** Auspice (a switch must actually change it).
- Each switch consumes the first queue entry that permits the target Auspice.
  - `'any'` permits all four Auspices.
  - `'mystic-harvest'` permits only Mystic (0) or Harvest (2).
- Multiple switches are possible in one turn if multiple uses are banked. Switching Harvest → Mystic → Hunter → Mystic requires three cards granting changes (two must be `'any'`).
- Card grants: Augury Initiate → `'mystic-harvest'`; Channeler, Witchdoctor, Fallah → `'any'`.
- Dark Magic → forces Famine immediately on play; does not add a use to the queue.
- All uses reset at end of turn.

**Hunter Auspice mid-turn Legend:**
While Hunter Auspice is active, a → Legend button appears on non-permanent cards in the Played area. Clicking it sends that card to Legend immediately (removed from discard). One Legend send per turn. The Hunter (Warrior card) also grants this independently of the Auspice.

---

## SECTION 4. TURN STRUCTURE

There are no locked phases in Connivances. The turn is fluid. The following is a logical ordering of typical play, not a rigid sequence.

```
TURN FLOW (Fluid; no locked phase order):

  START OF TURN
  └─ Reset Food = 3 + permanent Farm bonuses ± Auspice modifier
  └─ Collect passive bonuses from Active permanents (Inf, ATK, Food)
  └─ Trophy recurring rewards may fire at any time during your turn (once each)

  PLAY CARDS (ongoing; any time during turn)
  └─ Play cards from hand (1 Food each)
  └─ Resolve effects: gain Influence / ATK / Food / draws
  └─ Permanent cards (Buildings, Creatures) go to Kingdom
  └─ Non-permanent cards go to Discard after play
  └─ King's Note may optionally be sent to Legend instead

  REPAIR (any time after a Repair card is played)
  └─ Playing a card with "Repair" or "Repair 2" grants that many repair uses immediately
  └─ Uses may be spent at any point during the turn
  └─ Repairing ATK-contributing permanents before spending ATK is strategically optimal
  └─ Repair count: Repair = 1 building, Repair 2 = 2 buildings, stacks across cards
  └─ Trophies may be repaired (subject to multiplayer testing)

  PURCHASE (any time during turn, if gates are open)
  └─ Recruits: always available
  └─ Buildings. Walls & Farms: always open, no Builder required
  └─ Buildings. Specialized: requires Builder in play (or Siegeman for Siege; Warrior for Dojo)
  └─ Conjurations: requires Conjurer in play
  └─ All purchases go to Discard pile (not hand)

  ATTACK (any time during turn, as many times as ATK pool allows)
  └─ Spend ATK pool against Guardian Monster or opponent permanents (PvP)
  └─ Must equal or exceed target DEF to destroy/disable
  └─ Partial ATK spend against a target is wasted; use it or lose it
  └─ ATK types (🟡/🔴/⚪) determine valid targets; see Section 2A
  └─ Multiple attack windows allowed in one turn as ATK accumulates

  END TURN
  └─ Unused Influence and ATK are lost; always spend everything
  └─ Hand discarded; played non-permanent cards discarded
  └─ Draw 5 cards (always). Start of turn: Mystic draws +1, Familiar draws +1 per active Familiar
  └─ If deck empty: shuffle Discard into new Deck first
  └─ Turn flags reset (builderPlayed, conjurerPlayed, etc.)
```

---

## SECTION 5. KINGDOM (PERMANENT CARDS)

Permanents placed in your Kingdom remain in play across turns and provide ongoing bonuses.

**Three Zones (V10 layout):**
- **Wall Row (Front):** Wall-subtype buildings. **Only the Walls card (bg3, `isTaunt:true`) forces "must be attacked first"**; non-flying attackers must break it before reaching the Back Row. **Portcullis and Fortress are Wall-subtype for set bonding only; they do NOT block targeting**; a monster bypasses them freely and hits the Back Row. Flying creatures bypass the taunt Wall entirely.
- **Back Row:** All other non-Trophy buildings and conjured creatures. Protected only while an active **taunt** Wall (bg3) exists.
- **Trophy Zone:** Trophy permanents only, in a dedicated column (gold border, label "🏆 TROPHIES; not targeted by monsters"). **Trophies are never valid monster attack targets**. Field monsters cannot reach them. In PvP they remain attackable by opponents.

**States:**
- **Active:** Full DEF, all passive bonuses apply
- **Disabled:** DEF reduced to 0 by attack. All bonuses suspended until Repaired.

**Repair:** Any card bearing the keyword "Repair" or "Repair 2" restores that many Disabled permanents the moment it is played. Restored permanents return to full printed DEF. All bonuses reactivate immediately.

**Set Bonuses (Completion; 0/2):** Any two Wall-type buildings paired together complete a Wall Set. Non-Wall sets use the subtype-driven system below.

**Non-Wall Set Completion (subtype-driven. V10):**
- Sets are **pairs (exactly 2 cards)**, keyed by shared subtype (`Key_Word_Type`).
- A subtype is **set-eligible** only if some card of that subtype carries a `completionBonus` in the `COMPLETION_BONUSES` lookup table. Eligible now: **Farm, Library, Armory** (plus Wall via the separate bonding system). **Not eligible** (never pair): Caravan, Granary, School, plain Creature, etc.
- Within an eligible subtype, any two unpaired active permanents **pair greedily in play order**. Pairs lock permanently. **Four Farms = two independent pairs.**
- A set forms when **two active permanents share a `subtype`** AND at least one carries a `completionBonus`.
- The bonus travels with whichever card carries it. If only one card in the pair has a bonus, that bonus fires. Example: Rice Field (no bonus) + Irrigated Field (+2 Influence) → +2 Influence fires.
- If **both** cards carry *different* bonuses of the same subtype, **both fire.** Example: Armory (3-for-1 ratio) + War Room (+1 ⚪ ATK) → both apply.
- **Identical bonuses stack** rather than dedupe. Two Irrigated Fields = +4 Influence; Trophy Room + Scriptorium (both "Draw 2") = Draw 4.
- Once a subtype's set completes, it is **locked**; it never fires again for that subtype, even if more bonus-carrying cards of that subtype join.
- Bonuses come from a **code lookup table by subtype**, not parsed from display text. Adding a new set requires a code touch.
- **Recurring bonuses** (Influence, ATK) fire immediately at completion AND at the start of every subsequent turn; but **only while both pair members remain active.** If either member is disabled, the bonus pauses (pair label shows "(paused)") until repaired.
- **One-time bonuses** (Draw) fire once at completion. ⚠️ Whether Draw-type should instead recur is an **open decision** (Section 10, item 18).
- Current lookup table: Irrigated Field → +2 Influence/turn (recurring); Trophy Room → Draw 2; Scriptorium → Draw 2; Armory → 3-for-1 exchange ratio (passive live-read, auto-pauses on disable); War Room → +1 ⚪ ATK/turn (recurring).
- Wall subtype is excluded from this system. Walls use the separate bonding system below.

**Wall Set Bonus Rules:**

| Set Combination | Fortress Passive | Set Bonus on Completion |
|---|---|---|
| Walls + Portcullis |; | +2 DEF to all Creatures & Siege |
| Walls + Walls |; | +4 DEF to all Creatures & Siege |
| Walls + Fortress | +2 DEF (Fortress passive) | +4 DEF to all Creatures & Siege |
| Portcullis + Fortress | +2 DEF (Fortress passive) | +4 DEF to all Creatures & Siege |
| Fortress + Fortress | +4 DEF (both Fortress passives) | +4 DEF to all Creatures & Siege |

**Stacking:** Multiple completed Wall sets stack fully. Two completed Wall + Fortress sets = +8 DEF to all Creatures & Siege.

**Lock Rule:** Once two Wall cards form a set union, they are permanently bonded. They cannot be reassigned to form a new set with a different card.

**Bonding Prompt Rule:** Set bonding is never automatic. When a second Wall-type card enters the Kingdom and one or more unbonded Wall-type cards already exist in play, the player is prompted: *"Bond [new card] with [existing card] to complete a Wall Set? This cannot be undone."* If multiple unbonded Wall-type cards exist, each is listed as a selectable option. The player may decline. Once confirmed, the bond is permanent.

**Suspension Rule:** If one card in a completed set is Disabled (DEF reduced to 0), the set bonus is suspended for all cards bonded in that set. The bonus reactivates fully once the Disabled card is Repaired.

**Portcullis Special Note:** Portcullis retains its passive (+2 Influence/turn) and 🟡 Creature ATK immunity on top of participating in set bonuses. When bonded in a Wall Set, the creature immunity extends to all Wall and Fortress cards in that bonded set. 🔴 Siege ATK and ⚪ Generic ATK may still target Portcullis and any bonded set members.

**Flying Rule:** Creatures with the Flying keyword (Gryphon, Nightmare) ignore the Wall row entirely. Their full ATK pool bypasses Walls and may target any Back Row permanent directly. Flying does not override Portcullis creature immunity; 🟡 Creature ATK from a Flying attacker still cannot be applied to Portcullis or its bonded set.

**Creature Keyword List (Full):** Brood, Armored Hound, Familiar, Gryphon, Golem Defender, Tiger, Sir Cluckles, Fiend, Nightmare.

---

## SECTION 5A. TROPHY PERMANENTS

Trophies are a special class of permanent earned by defeating Trophy-flagged Guardian Monsters.

**Lifecycle:**
1. Defeat a Trophy-flagged monster → card goes to defeating player's Discard pile
2. On draw → play from hand → enters Kingdom as a permanent (costs 1 Food to play)
3. Enters the **Trophy Zone** (dedicated column, V10 layout). Attackable by opponents in PvP mode. **Not** targetable by Seeping Portal monsters.
4. Has printed DEF as its HP while in Kingdom
5. Standard non-Trophy monsters (Fiend, Nightmare) do not follow this lifecycle; they are played, resolved, and discarded like any Recruit card

**Auspice Buff:** Each Trophy card has an Auspice tag. While the matching Auspice is active, that Trophy gains +1 HP (DEF). This is a defensive buff only; it does not affect whether the reward fires.

| Trophy | Auspice Tag | HP Buff | Recurring Reward | Reward Type |
|---|---|---|---|---|
| Ghoul Shaman | Mystic | +1 HP under Mystic | MAY change the Auspice | Once per turn, any time |
| Minotaur | Harvest | +1 HP under Harvest | MAY draw a card | Once per turn, any time |
| Silent Stalker | Hunter | +1 HP under Hunter | MAY move a card to Legend | Once per turn, any time |
| Gargantuan | Mystic | +1 HP under Mystic | All your creatures have +2 DEF | Passive; always active while not Disabled |
| Dank Beast | Mystic | +1 HP under Mystic | +1 ⚪ Generic ATK per Active Trophy you control | Passive. Disabled Trophies do not count toward this bonus |
| Dragon | Mystic | +1 HP under Mystic | +3 ⚪ Generic ATK/turn passive; MAY draw a card from discard | ATK is passive always; draw is once per turn, any time |
| Noxious Beast | Famine | +1 HP under Famine | Conjurations need no Conjurer permanently | Passive; always active while not Disabled |

**Reward Timing:**
- **On placement:** Reward fires immediately when the Trophy enters the Kingdom from hand
- **Recurring:** Once per turn, at any point during the owning player's turn
- **Disabled:** All rewards suspended while the Trophy is Disabled. If repaired mid-turn, all rewards reactivate immediately; including draw effects which fire on the spot
- **MAY rewards:** Optional; player chooses when during their turn to use them

**Repair and Trophies (single-player vs PvP; reconciled v2.1):** In **single-player**, Trophies live in the Trophy Zone and are **immune to all monster targeting**; they can never be Disabled, so repair/heal eligibility is moot. The ruling that "a Disabled Trophy can be Repaired to full DEF with all rewards reactivating on the spot" is scoped to **future PvP only** (opponent-vs-player combat), which is unbuilt. The two rulings do not conflict (Section 10, item 15).

---

## SECTION 6. LEGEND MECHANIC

The Legend Zone is Connivances' signature deck-refinement system.

**Rules:**
- Cards sent to Legend are permanently removed from the player's deck
- Their VP face value still counts at game end
- One King's Note may be sent to Legend per turn (costs 1 Food to play)
- Several cards enable Legend sends: Hunter (Warrior), Sacrificer (Conjurer), Silent Stalker (Trophy), Lesser Demon, Demon (on defeat)
- The Hunter Auspice grants a Legend send each turn as a global ability

**Design Intent:** Legend is the primary power-ramp mechanic. Thinning weak starter cards accelerates draw quality and makes the deck more efficient.

---

## SECTION 7. MARKET GATES (UNLOCK CONDITIONS)

| Market | Gate Condition | Exception |
|---|---|---|
| **Recruits** | Always open |; |
| **Buildings. Walls & Farms** | Always open; no Builder required | Walls, Portcullis, Fortress, Tiered Field, Irrigated Field are available to all players at all times |
| **Buildings. Specialized** | Play any Builder recruit this turn | Applies to: Catapult, Trophy Room, Trebuchet, Poison Room, Armory, Scriptorium, War Room. Siege buildings also unlocked by Siegeman. Dojo requires a Warrior recruit (not a Builder) |
| **Conjurations** | Play any Conjurer recruit this turn | Soothsayer (Mystic Auspice) bypasses requirement; Noxious Beast Trophy bypasses permanently while in Kingdom |

**Commander Special Rule:** When both a Pikeman AND a Commander are played in the same turn (either order), the Commander effect fires: one Conjuration may be acquired at cost 0. This is both a gate bypass and a cost reduction to zero. Only one free Conjuration per Commander played this way.

**`requiresBuilder` Dev Flag:** The authoritative source for all building gate logic is the `requiresBuilder` column in `Connivances_Tracks_v2.xlsx`. Walls, Portcullis, Fortress, Tiered Field, and Irrigated Field have `requiresBuilder = FALSE`.

---

## SECTION 8. COMPLETE CARD REGISTRY

### 8A. STARTER DECK (10 cards per player)

| Name | Type | Effect 1 | Effect 2 | DEF | Qty |
|---|---|---|---|---|---|
| King's Note | Recruit | +1 Influence | MAY move to Legend (once per turn) |; | 2 |
| Devoted Aid | Recruit | +1 Influence |; |; | 5 |
| Rice Field | Building/Farm | +2 Food/turn (permanent) | Respects Harvest/Famine Auspice | 2 | 1 |
| Farm Hand | Recruit/Farmer | +2 Food this turn |; |; | 1 |
| Augury Initiate | Recruit/Augury Mage | +1 Influence | MAY change Auspice to Mystic or Harvest |; | 1 |

---

### 8B. RECRUITS MARKET

#### WARRIOR GUILD
| Name | Cost | VP | Inf | Effect | Qty |
|---|---|---|---|---|---|
| Pikeman | 2 | 1 | +2 | Reveal top of deck; if Warrior, draw it | 3 |
| Swordsman | 3 | 1 | +2 | Warriors bought this turn may go to top of deck | 3 |
| Trainer | 3 | 1 | +2 | Farmers count as Warriors this turn | 4 |
| Negotiator | 3 | 1 | +2 | Each other Warrior played this turn: +1 Influence | 3 |
| Siegeman | 3 | 1 | +2 | Siege +1 ATK this turn; buying Siege needs no Builder | 3 |
| Hunter | 3 | 1 | +2 | The Hunter: Move a card you played this turn into Legend | 3 |
| Commander | 4 | 1 | +2 | If Pikeman played this turn (either order): gain one free Conjuration (cost 0, gate bypass) | 2 |
| Warlord | 5 | 1 | +2 | Each other Warrior played this turn gains +1 Influence; applies retroactively to Warriors already played and forthcoming Warriors played after. Two Warlords double the effect. | 1 |

#### AUGURY MAGE GUILD
| Name | Cost | VP | Inf | Effect | Qty |
|---|---|---|---|---|---|
| Oracle | 3 | 1 | +2 | Libraries and Armories need no Builder this turn | 4 |
| Mage Caller | 3 | 1 | +2 | Reveal top of deck; if Augury Mage, draw it | 2 |
| Channeler | 3 | 1 | +2 | You may change the Auspice | 4 |
| Soothsayer | 3 | 1 | +2 | The Mystic: Conjurations need no Conjurer to acquire | 3 |
| Scribe | 3 | 1 | +2 | The Mystic: Draw a card per Armory or Library you control | 3 |
| Herbalist | 3 | 1 | +2 | Each Augury Mage played this turn: +1 Food | 3 |
| Witchdoctor | 4 | 1 | +3 | You may change the Auspice | 2 |
| Necromancer | 5 | 1 | +2 | Each Augury Mage gains +1 ATK per Auspice change this turn | 1 |

#### BUILDER GUILD
| Name | Cost | VP | Inf | Effect | Qty |
|---|---|---|---|---|---|
| House Hand | 3 | 1 | +2 | Repair 1 building (immediate on play, use any time during turn) | 7 |
| Repair Master | 4 | 1 | +2 | Repair 1 building (immediate on play, use any time during turn) | 4 |
| Contractor | 4 | 1 | +2 | Repair 2 buildings (immediate on play, use any time during turn) | 3 |
| Expediter | 3 | 1 | +2 | The next building you purchase this turn may go straight into play. Expediter attaches to that building and reduces its DEF by 2 while attached. If host is disabled, Expediter → discard. | 2 |
| Meurtrière | 3 | 1 | +2 | Attach to any Wall: +2 DEF while attached | 3 |
| Fortifier | 4 | 1 | +2 | Attach to any building: +2 DEF while attached | 2 |
| Demented Architect | 5 | 1 | +2 | Building bought this turn may change type for any set bonus; then move Demented Architect to Legend ⚠️ **effect2 UNIMPLEMENTED; no handler (Section 10, item 24)** | 1 |

#### CONJURER GUILD
| Name | Cost | VP | Inf | Effect | Qty |
|---|---|---|---|---|---|
| Conjurer's Aid | 3 | 1 | +2 | Unlocks Conjurations; The Mystic: Draw a card | 2 |
| Sacrificer | 3 | 1 | +2 | Unlocks Conjurations; End of turn: move a card of yours to Legend | 3 |
| Handler | 3 | 1 | +2 | Unlocks Conjurations; on play: +1 🟡 Creature ATK **per active creature permanent in Kingdom** (not a flat +1). 2 Handlers × 3 creatures = +6 🟡 ATK. `atk_creature:0` in card data. | 3 |
| Retinue | 3 | 1 | +2 | Unlocks Conjurations; Attach to creature: +2 DEF while attached | 3 |
| Teramancer | 3 | 1 | +2 | Unlocks Conjurations; +1 Food. **Dual identity; counts as a Farmer for all Farmer synergies (War Room, Trainer, Reaper-style effects).** `isFarmer:true` in schema. | 3 |
| Exorcist | 3 | 1 | +2 | Unlocks Conjurations; Heal a creature; Possession killed without destroying host | 3 |
| Cleric | 3 | 1 | +2 | Unlocks Conjurations; Heal a creature; +2 ATK against Possessions | 4 |
| Enforcer | 4 | 1 | +2 | Unlocks Conjurations; Heal any creature in any field | 2 |
| Conjure Master | 6 | 2 | +3 | Unlocks Conjurations; May replace a Conjurer from market; +1 🟡 Creature ATK per creature you control | 1 |

#### FARMER GUILD
| Name | Cost | VP | Inf | Food | Effect | Qty |
|---|---|---|---|---|---|---|
| Farmer | 2 | 1 | +2 | +1 |; | 4 |
| Irrigator | 3 | 1 | +2 | +1 | Ignore Famine Auspice this turn | 4 |
| Agriculturist | 3 | 1 | +2 | +2 |; | 4 |
| Reaper | 3 | 1 | +2 | +1 | Harvest: +2 Food instead | 4 |
| Supplier | 3 | 1 | +2 | +1 | May convert unused food into card draws | 3 |

#### FACTIONLESS
| Name | Cost | VP | Inf | Effect | Qty |
|---|---|---|---|---|---|
| Fallah (Failed Augur) | 3 | 2 | +2 | May change the Auspice freely | 2 |

---

### 8C. BUILDINGS MARKET

All Buildings are permanent. All cost 1 Food to play into Kingdom.

| Name | Subtype | Cost | VP | DEF | Passive | Bonus | Requires | Qty |
|---|---|---|---|---|---|---|---|---|
| Tiered Field | Farm | 4 | 2 | 4 | +2 Food/turn. Respects Harvest/Famine. |; | **None; open to all** | 5 |
| Irrigated Field | Farm | 4 | 2 | 4 | +1 Food/turn. Respects Harvest/Famine. | (0/2): +2 Influence | **None; open to all** | 6 |
| Walls | Wall | 7 | 2 | 6 | `isTaunt`; must be attacked first by all non-flying attackers (the only taunt Wall) | Set Bonus with any Wall-type: +2 DEF to all Creatures & Siege. Bonus suspends if either set card is Disabled. | **None; open to all** | 4 |
| Catapult | Siege | 6 | 2 | 3 | +1 🔴 Siege ATK/turn |; | Builder or Siegeman | 3 |
| Trophy Room | Library | 7 | 2 | 6 | +1 ⚪ Generic ATK per Active Trophy you control | (0/2): Draw 2 cards | Builder | 3 |
| Portcullis | Wall | 8 | 2 | 7 | +2 Influence/turn; Immune to 🟡 Creature ATK. **Not a taunt; does NOT block monster targeting** (Wall-subtype for set bonding only). When bonded in a Wall Set, immunity extends to all bonded Wall/Fortress cards. 🔴 Siege and ⚪ Generic ATK may still target it. | Set Bonus with any Wall-type: +2 DEF to all Creatures & Siege. Bonus suspends if either set card is Disabled. | **None; open to all** | 3 |
| Fortress | Wall | 12 | 2 | 6 | Passive: Creatures & Siege always gain +2 DEF while Fortress is Active (no set required). **Not a taunt; does NOT block monster targeting** (Wall-subtype for set bonding only) | Set Bonus with any Wall-type: additional +2 DEF to all Creatures & Siege. Bonus suspends if either set card is Disabled. | **None; open to all** | 2 |
| Dojo | School | 12 | 2 | 5 | Exchange 3 Influence for +1 ⚪ Generic ATK |; | **Warrior** | 2 |
| Trebuchet | Siege | 8 | 2 | 4 | +2 🔴 Siege ATK/turn |; | Builder or Siegeman | 3 |
| Poison Room | Library | 10 | 2 | 6 | Exchange 3 Food for +2 ⚪ Generic ATK |; | Builder | 2 |
| Armory | Armory | 10 | 2 | 5 | Exchange 4 Inf for +1 ⚪ Generic ATK | (0/2): 3-for-1 ratio | Builder | 3 |
| Scriptorium | Library | 7 | 2 | 6 | Spells cost 2 less Influence | (0/2): Draw 2 cards | Builder | 2 |
| War Room | Armory | 11 | 3 | 5 | Farmers gain +1 ⚪ Generic ATK | (0/2): +1 ⚪ Generic ATK to pool | Builder | 2 |
| Granary | Granary | 5 | 2 | 3 | At end of turn, stores unused Food (up to 5 per Granary). Stored Food is added to the pool at the start of the next turn and spends like normal Food. |; | Builder | 3 |
| Caravan: Wayfarers' Court | Caravan | 4 | 1 | 4 | One-round permanent. Takes persistent damage (damage carries over between attacks; not reset each turn). Survives one full round to start of owner's next turn → enters Legend: **+5 Influence**. **Destroyed before owner's next turn (DEF reduced to 0): removed from play and lost entirely; no Legend, no reward, no VP (Option 1: overrun caravans are lost).** |; | Builder | 3 |
| Caravan: Supply Route | Caravan | 4 | 1 | 4 | One-round permanent. Takes persistent damage. Survives one full round → enters Legend: **+4 Food**. **Destroyed before owner's next turn (DEF reduced to 0): removed from play and lost entirely; no Legend, no reward, no VP (Option 1: overrun caravans are lost).** |; | Builder | 3 |

---

### 8D. CONJURATIONS MARKET

#### CREATURES (Permanent. Creature keyword. ATK contributes to 🟡 Creature ATK pool)
| Name | Cost | VP | ATK | DEF | Effect | Qty |
|---|---|---|---|---|---|---|
| Brood | 5 | 2 | +1 🟡 | 2 |; | 5 |
| Armored Hound | 5 | 2 | +1 🟡 | 3 |; | 4 |
| Familiar | 6 | 2 | +1 🟡 | 4 | Draw a card when played | 3 |
| Gryphon | 10 | 3 | +2 🟡 | 4 | Flying; full ATK pool bypasses Wall row; targets Back Row directly. 🟡 ATK still cannot target Portcullis or its bonded set. | 3 |
| Golem Defender | 7 | 3 | +1 🟡 | 4 | All your creatures have +2 DEF while in play | 3 |
| Tiger | 8 | 3 | +2 🟡 | 3 |; | 3 |
| Sir Cluckles, Venerable Roost Master | 9 | 3 | +1 🟡 | 4 | **Passive:** while Active in Kingdom, each Brood in Kingdom gains +1 🟡 ATK. Stacks; two Sir Cluckles = +2 🟡 ATK per Brood. `subfaction:'Brood'`; he is also Brood. | 2 |

#### SPELLS (Non-Permanent, discard after use)
| Name | Cost | VP | Effect | Qty |
|---|---|---|---|---|
| Empowered Spell Book | 6 | 2 | Draw 2 cards | 3 |
| Dark Magic | 7 | 2 | Change Auspice to Famine; Draw 3 cards | 3 |
| Amelioration | 9 | 3 | Draw 3 cards | 2 |

#### POSSESSIONS (Special. Cannot Be Purchased; Lurk in Conjuration Deck)
> ⚠ Possession cards are shuffled into the Conjuration deck. They cannot be bought. **They trigger when drawn into the market row**; appearing face-up as a warning. They attack your permanents passively.

| Name | Trigger Condition | VP | DEF | Auspice Buff | On Defeat Effect | Qty |
|---|---|---|---|---|---|---|
| Nether Beast | 1st Creature Possession drawn | 2 | 3 | +1 HP under Famine | Draw 2 cards | 1 |
| Lesser Demon | 2nd Creature Possession drawn | 2 | 3 | +1 HP under Hunter | Move a card of yours to Legend | 1 |
| Evil Possession | 3rd Creature Possession drawn | 3 | 3 | +1 HP under Mystic | Draw 3 cards | 1 |
| Cursed | 1st Building Possession drawn | 3 | 5 | +1 HP under Harvest | Draw 3 cards | 1 |
| Haunting | 2nd Building Possession drawn | 3 | 4 | +1 HP under Mystic | Draw 2 cards | 1 |
| Undead Rising | 3rd Building Possession drawn | 3 | 4 | +1 HP under Famine | **Draw top 3 cards of your deck. You may play any of them this turn. At end of turn, each unplayed card: keep in hand, return to top of deck, or send to Legend.** ⚠ Famine: all 3 are played automatically this turn, then all 3 go to Legend. | 1 |
| Demon | 3rd Recruit Possession drawn | 3 | 4 | +1 HP under Hunter | Move a card of yours to Legend | 1 |

**Possession Destruction Rules:**
- The **Possession card** → moves to the **destroying player's Legend** and counts toward their VP at game end
- The **host card** (possessed Building, Conjuration, or Recruit) → is permanently removed from the owning player's kingdom/deck/discard and returned to the **bottom of its original market deck**
- The host card is gone from the owning player forever; no VP, no recovery for them
- In multiplayer; the player who lands the killing blow claims the Possession VP. The host always returns to the bottom of its market deck regardless of who owned it

**VP Display Rules:**
- During live play (final product). VP is hidden from all players until the game ends
- During testing/simulator. VP display remains visible to verify mechanic correctness
- VP is counted from all zones: hand, deck, discard, permanents, and legend
- Possessed host cards that are destroyed count toward no one's VP

**Multiplayer Possession Note:** In multiplayer, destroying a Possession on an opponent's card sends their host card back to the market where any player can purchase it again. This is an intentional indirect sabotage mechanic.

---

### 8E. GUARDIAN MONSTERS (Portal Queue)

**Single Player Queue:** 4 monsters + The Portal (5 total). **Ghoul Shaman is always selected and always goes first**; in V10 he will have the first unseal/cork definition. The remaining 3 are randomly drawn from the non-Ghoul pool. The Portal is always last.

**Multiplayer (future):** 1 monster per player + 1, with The Portal always last.

Monsters appear in a shuffled queue (with Ghoul fixed at position 1). The Portal is always last. Defeating a monster rewards its VP (card goes to defeating player's Discard).

| Name | HP/DEF | Player ATK | VP | Trophy? | Special Ability |
|---|---|---|---|---|---|
| Fiend | 7 | 7 | 4 | No | **Non-Trophy.** On defeat → Discard. When played from hand by a player: +2 ⚪ Generic ATK, MAY shuffle discard into deck. Standard reshuffle/replay lifecycle. **Creature-type**; contributes 🟡 Creature ATK when played. Cannot attack Portcullis. |
| Nightmare | 7 | 7 | 4 | No | **Non-Trophy.** On defeat → Discard. When played from hand by a player: +3 ⚪ Generic ATK, retains Flying. Standard reshuffle/replay lifecycle. **Creature-type**; contributes 🟡 Creature ATK when played. Flying; ignores all Wall mechanics. Cannot attack Portcullis. |
| Ghoul Shaman | 4 | 4 | 4 | ✅ | Trophy. Auspice buff: +1 HP under Mystic. Recurring: MAY change the Auspice (once per turn, any time). |
| Minotaur | 5 | 5 | 4 | ✅ | Trophy. Auspice buff: +1 HP under Harvest. Recurring: MAY draw a card (once per turn, any time). |
| Silent Stalker | 5 | 5 | 4 | ✅ | Trophy. Auspice buff: +1 HP under Hunter. Recurring: MAY move a card into Legend (once per turn, any time). |
| Gargantuan | 6 | 6 | 5 | ✅ | Trophy. Auspice buff: +1 HP under Mystic. Passive: all your creatures have +2 DEF while Active. |
| Dank Beast | 6 | 6 | 5 | ✅ | Trophy. Auspice buff: +1 HP under Mystic. Passive: +1 ⚪ Generic ATK per Active Trophy you control (Disabled Trophies do not count). |
| Dragon | 8 | 8 | 6 | ✅ | Trophy. Auspice buff: +1 HP under Mystic. Passive: +3 ⚪ Generic ATK/turn always. Recurring: MAY draw a card from your discard (once per turn, any time). |
| Noxious Beast | 9 | 9 | 7 | ✅ | Trophy. Auspice buff: +1 HP under Famine. Passive: Conjurations need no Conjurer while Active. |
| **The Portal** | **7** | **0** | **6** | No | **Defeating this ends the game. Count all VP.** |

> **Trophy Lifecycle:** Defeat → Discard → draw → play (1 Food) → enter Kingdom as permanent with printed DEF as HP. All Trophy rewards fire on placement and recur once per turn. See Section 5A for full rules.

> **Non-Trophy Monsters:** Fiend and Nightmare go to Discard on defeat. They are played, resolved, and discarded like any non-permanent card. They do not enter the Kingdom. Both are Creature-type; their ATK when played by a player contributes to the 🟡 Creature ATK pool.

---

## SECTION 9. DATA SCHEMA (For Digital Development)

All cards follow this universal schema. Unused fields default to `null` or `false`.

```json
{
  "id": "string; unique identifier",
  "name": "string",
  "deck": "Starter | Recruits | Buildings | Conjurations | Portal",
  "guild": "Starter | Warrior | Augury Mage | Builder | Conjurer | Farmer | Factionless | Possession | Portal Monster",
  "type": "Recruit | Building | Conjuration | Monster",
  "subtype": "Farm | Wall | Siege | Library | Armory | School | Creature | Spell | Possession | Trophy | null",
  "cost_inf": "number | null",
  "cost_food": 1,
  "vp": "number | 0",
  "inf": "number | 0",
  "food": "number | 0",
  "atk_creature": "number | 0",
  "atk_siege": "number | 0",
  "atk_generic": "number | 0",
  "def": "number | 0",
  "permanent": "boolean",
  "isWall": "boolean",
  "fly": "boolean",
  "isCreatureType": "boolean",
  "canLegend": "boolean",
  "drawOnPlay": "number | 0",
  "isPossession": "boolean",
  "isTrophy": "boolean",
  "requiresBuilder": "boolean",
  "requiresWarrior": "boolean",
  "requiresConjurer": "boolean",
  "isBuilder": "boolean",
  "isConjurer": "boolean",
  "isWarrior": "boolean",
  "isSiegeman": "boolean",
  "isFarmer": "boolean",
  "subfaction": "string | null",
  "auspiceTag": "Mystic | Hunter | Harvest | Famine | null",
  "auspiceBuffHP": "number | 0",
  "completionBonus": "string | null",
  "trophyRewardOnPlay": "string | null",
  "trophyRewardRecurring": "string | null",
  "trophyRewardIsPassive": "boolean",
  "repairCount": "number | 0",
  "effect1": "string",
  "effect2": "string | null",
  "notes": "string | null",
  "qty": "number"
}
```

**Schema Changes from v1.7:**
- `atk` field split into `atk_creature`, `atk_siege`, `atk_generic` to support ATK token type system
- `isCreatureType` added as explicit boolean (was previously inferred from subtype)
- `auspiceBuffHP` added to capture the Trophy +1 HP defensive buff value
- `isFarmer` added in v1.9; explicit boolean for cards with Farmer synergy that aren't primary Farmer guild (currently only Teramancer). Used by Trainer, War Room, and any future Farmer-counting effects. Check `card.isFarmer || card.subtype === 'Farmer'` in all Farmer synergy logic.
- `subfaction` added in v1.9; named creature order for sub-faction synergies. Currently: `'Brood'` on both the Brood card **and** Sir Cluckles (he is also Brood subfaction). Sir Cluckles' passive in `permAtkBonus()` counts `p.subfaction === 'Brood'` permanents (which includes himself; but his own `atk_creature:1` already accounts for his base; the passive adds `clucklesCount × broodCount` on top). Future expansion cards can use any subfaction string. Most cards have `subfaction: null`.
- `trophyRewardOnPlay`, `trophyRewardRecurring`, `trophyRewardIsPassive` added for Trophy reward modeling
- `repairCount` added to capture Repair/Repair 2 values on Builder cards

---

## SECTION 10. KNOWN DESIGN DISCREPANCIES & OPEN QUESTIONS

| # | Card / Mechanic | Issue | Status |
|---|---|---|---|
| 1 | Rice Field | Food output | ✅ Resolved; +2 Food/turn as permanent. Respects Harvest/Famine Auspice. |
| 2 | Fallah (Failed Augur) | Influence printed | ✅ Consistent; no action needed |
| 3 | Warlord | Inclusion & effect | ✅ Resolved; included in v1.7 and v9. Retroactive + forthcoming. Two Warlords double the effect. |
| 4 | Portcullis | Creature immunity scope | ✅ Resolved. Portcullis immunity applies to Portcullis and its bonded Wall Set. 🟡 Creature ATK cannot target any bonded set member. |
| 5 | King's Note | Qty | ✅ Consistent |
| 6 | Possession trigger | Timing | ✅ Resolved. Possessions trigger on draw into the market row. |
| 7 | Commander | Free Conjuration effect | ✅ Resolved; gate bypass + cost 0. Requires Pikeman AND Commander same turn (either order). |
| 8 | Trophy lifecycle | Permanence & rewards | ✅ Resolved; see Section 5A for full rules. |
| 9 | Repair timing | Phase lock | ✅ Resolved; no phase lock. Repair fires on card play, uses available any time during turn. |
| 10 | Dojo cost | Cost | ✅ Consistent at 12 Inf; intentional |
| 11 | Simulator schema migration | Architecture | ✅ Resolved. Option C: v8 untouched, migration is Task 0 of v9 |
| 12 | Card Tracks xlsx format | Dev flags | ✅ Resolved. Option C: hybrid format, dev flags block right side. `requiresBuilder` is authoritative for building gate logic. |
| 13 | Portcullis. ATK type targeting | Type clarity | ✅ Resolved; three ATK token types defined (🟡🔴⚪). Portcullis and bonded set immune to 🟡 Creature ATK only. Recruit ATK is ⚪ Generic and may target Portcullis. |
| 14 | Siege double-damage to Walls | Future ruling | ⚠️ Open; 🔴 Siege ATK separated as a distinct type in anticipation of this ruling. Not yet implemented. Flagged for design pass before final rulebook. |
| 15 | Trophy repair in multiplayer (PvP-only) | Balance | ⚠️ Open (scoped to PvP). **Reconciled in v2.1:** in single-player, Trophies are immune to ALL monster targeting (Trophy Zone), so they can never be Disabled and repair/heal eligibility is moot. The "Trophies have DEF, can be Disabled, and Repair restores them with rewards reactivating" ruling applies **only to future PvP**, which is unbuilt. The two rulings do not conflict. See Section 5A. |
| 17 | Lone-monster-cannot-solo-a-wall softlock | V10 single-player | ⚠️ Open (narrowed); **Wall Siege is implemented** (Section 13B) and resolves the softlock **when ≥2 participants can combine to beat a taunt Wall**. The remaining open case is a *single* stonewalled monster with no siege partners; it stays blocked with no escape valve. Intended for now; revisit after playtesting. **V11-1 note:** a bug briefly let a lone freshly-unsealing monster siege *with itself* (double-counting its own ATK); fixed; participants must be ≥2 **distinct** monsters, so this softlock is again intentional, not bypassed. Ruling 2 (market-slot attacks) may give lone blocked monsters a target and moot this item; evaluate with items 53–57. |
| 18 | Draw-type set-completion bonus: recurring vs one-time | V10 set redesign | ⚠️ Open; the subtype-driven set completion system (V10) recurs bonuses each turn while both members are active. For **Draw-type** bonuses (Trophy Room, Scriptorium; "Draw 2"), it is undecided whether the draw should recur every turn or fire only once on completion. Recurring draws may be too strong. Awaiting Bryan's ruling before the set system is finalized. |
| 19 | Monster priority overhaul | V10 single-player | ⚠️ Open (partially ruled); **Ruling 2 (v2.2 changelog) now defines the blocked-field-monster path** (market-slot attacks). Still open: the Monster Ability step (item 53), the cut-off "3+" tier (item 54), retreat reconciliation (item 56), and field turn order / tie-breaking (item 57). |
| 20 | Dank Beast vs Nightmare identical unseal | V10 single-player | ⚠️ Open. Dank Beast and Nightmare currently share identical unseal conditions. Needs differentiation. Flagged for design meeting. |
| 21 | Option C glow/aura buff palette | V10 visuals | ⚠️ Open; the consumer-facing glow/aura buff visualization (Option C) needs a color palette for multi-buff cards. Deferred to the presentation-layer phase (Section 14). |
| 22 | **Cleric stacking vs Possessions** | ✅ **RULED (R1, v2.2); implementation pending** | Bryan's ruling: **Cleric choice economy.** Each Cleric played grants ONE use of a CHOICE; heal one creature OR +2 ATK toward Possessions. N Clerics = N uses; possession-ATK stacks per use spent on it (2 Clerics = heal 2, or +4, or heal 1 + +2). Supersedes the flat-+2 flag AND the V10 both-effects behavior (V10 granted heal-on-play *plus* the flat flag; the ruling makes them mutually exclusive per use). Exorcist/Enforcer heals unchanged. Implementation: replace the `clericPlayedThisTurn` boolean with a per-turn choice-use counter; update the `clericBonus` calcs to read accumulated possession-ATK. **UX sub-question open (item 58): choose-on-play vs banked uses.** |
| 23 | **Seeping Portal has no reachable loss condition** | ⚠️ **KEY. BLOCKS Mode 1 done** | Monsters **Disable** permanents (turned sideways, stay in play); they never destroy them, and only overrun Caravans ever leave play. The deck cycles forever, so hand/deck/discard never empties. Net: `checkLossCondition` (all permanents destroyed AND hand+deck+discard empty) is **unreachable**; the Portal cannot win. Options: **(1)** turn limit (Portal wins if not sealed by turn N); **(2)** all-disabled collapse (if every permanent is disabled at end of a monster turn, the kingdom falls); **(3)** portal escalation (once all monsters unseal, the Portal itself attacks/spawns); **(4)** accept no-loss (Mode 1 is the learning mode; real fail states live in Time Crisis / Survive the Famine). Interacts with monster priority overhaul, the Wall Siege softlock, and Faction Unlock boss win/loss patterns.  **v2.2 note:** Ruling 2 (market strangulation) creates the first real loss *pressure*; a blocked monster permanently destroys market slots. Whether "all market slots destroyed" IS the loss trigger, or a separate trigger is still needed, is open; see item 57 companion question in the v2.2 changelog and Open Item 5 of the session changelog. Evaluate together with the unseal-rush fast win (item 59). |
| 24 | **Demented Architect effect2 unimplemented** | ⚠️ Open | The `isBuilder` unlock works, but "Building bought this turn may change subtype, then → Legend" has **no handler**. It interacts with subtype-keyed set pairing (changing a subtype could form/break a set), so it needs design before code. |
| 25 | **Familiar draw on mid-turn heal** | ✅ **RULED (R3, v2.2); implementation pending** | Bryan's ruling: a Familiar healed mid-turn DOES retroactively grant its draw for that turn. Implementation: extend `grantMidTurnIncome()` (or the heal path) to fire the Familiar draw on heal. Repair path unaffected (repair rejects creatures). The 12A.13B "draw passives are NOT re-fired" row is superseded for Familiars once implemented. |
| 26 | **Supplier multiples** | ⚠️ Open | Supplier's Food→Draw convert is a turn-flag ability; **multiple Suppliers in one turn add nothing extra** (non-stacking). Same decision class as Cleric stacking (item 22); resolve together for consistency. |
| 53 | **Monster Ability system (R2 Step 1)** | ⚠️ **NEW. BLOCKS R2** | Ruling 2 places a "Check Monster Ability" step first in field-monster priority, but the system is not designed: which abilities exist, when they check, per-monster definitions. Options: design now, or ship R2 with a no-op placeholder and design abilities as a separate pass. |
| 54 | **R2 cut-off "3+" tier** | ⚠️ **NEW. BLOCKS R2** | Bryan's ruling notes were cut off after "3+)". Confirm what the third-and-beyond priority tier was meant to say (or whether it was the Cleric N-generalization bleeding into the wrong note). |
| 55 | **Recruit-slot destruction details** | ⚠️ **NEW. BLOCKS R2** | When a monster destroys a Recruit market slot: does the deck behind it survive (fewer visible slots, same deck depth) or is the refill stream lost? Visual treatment of destroyed slots? Can anything restore one? Must share a single "destroyed slot" representation with **Time Crisis**, which also consumes market slots; design together. |
| 56 | **Retreat rule reconciliation** | ⚠️ **NEW. BLOCKS R2** | Under R2 a blocked field monster always has a market target, so the 13A Step-1 retreat-to-`guarding` path largely dies for field monsters. Confirm: once fielded, never returns to guard (portal exposure monotonic)? Or is retreat preserved for some case? Interacts with items 23 and 59. |
| 57 | **Field turn order & tie-breaking** | ⚠️ **NEW** | Still queue order? Unconfirmed under R2. |
| 58 | **R1 UX; choose-on-play vs banked uses** | ⚠️ **NEW. BLOCKS R1** | Cleric choice: pick heal-or-possession-ATK at each Cleric play via overlay, or bank N uses and spend any time during the turn (more flexible; e.g. heal a creature disabled later that turn; but more UI)? |
| 59 | **Unseal-rush fast win** | ⚠️ **NEW (balance)** | Portal exposes when zero monsters are `guarding`; unsealing (not killing) all guards plus cheap triggers (Fiend @ Turn 3) may let a player skip the combat loop entirely. Under R2's no-retreat direction, exposure becomes monotonic, making the rush strictly easier. Evaluate with items 23 and 56. |
| 60 | **Expediter −2 not re-applied on repair** | ⚠️ Open (pre-existing, low) | Repairing a building with an Expediter attached does not re-apply Expediter's −2 DEF (tracked via attach/detach math, not `defBonus`, so `recomputeStoredDef` cannot see it). Flagged for a later pass. |
| 61 | **Portcullis bonded-set immunity scope** | ⚠️ **NEW (code vs doc)** | Item 4 rules that 🟡 Creature immunity extends to **any member of Portcullis's bonded Wall Set**. V11-2.2 enforces immunity for the **Portcullis card only** (creature-type monsters can still target its bonded partner). Confirm whether the bonded-set extension applies to monster attacks in single-player; if yes, extend the `monsterPickTarget` filter to `bondedTo` partners. |
| 16 | Portcullis. Recruit ATK targeting | Type clarity | ✅ Resolved. Recruit ATK is ⚪ Generic. Can target Portcullis. Clean ruling. |
| 32 | Farm Hand food value | Physical card correction | ✅ Fixed. Farm Hand gives +2 Food (not +1). 0 cost, 0 influence. Designed to enable playing a fourth card on opening turns before Rice Field has surfaced. Both v8 and the prior master doc had +1 incorrectly. |
| 33 | Teramancer dual identity | Missing in both v8 and master doc | ✅ Fixed. Teramancer is both a Conjurer (unlocks Conjurations, `isConjurer:true`) and a Farmer (`isFarmer:true`) for all Farmer synergies (War Room, Trainer, future Farmer-counting effects). Card displays two guild chips. `isFarmer` is a new schema field added in v1.9. `subtype` stays `'Conjurer'` so Mage Caller does not draw it. |
| 34 | Subfaction system + Sir Cluckles passive | New design decisions | ✅ Implemented; `subfaction` field in schema. `subfaction:'Brood'` on Brood card AND Sir Cluckles (he is also Brood). Sir Cluckles passive lives in `permAtkBonus()`: `cr += clucklesCount × broodCount`. Stacks per Sir Cluckles. `creatureAtkSpentThisTurn` flag removed; the "waited for leader" design was replaced by the always-on passive. |
| 18 | Famine penalty in permFoodBonus | v8 bug | ✅ Fixed in v9. Further updated: Famine now sets farm output to 0 entirely (not -1). |
| 19 | Building gate. Walls/Farms always open | v8 bug | ✅ Fixed in v9; v8 gated ALL buildings behind Builder. v9 correctly uses requiresBuilder:false for Walls, Farms, Portcullis, Fortress. |
| 20 | Soothsayer. Conjuration gate bypass | Missing in both | ✅ Fixed in v9. Soothsayer under Mystic Auspice bypasses the Conjurer gate. soothsayerPlayedThisTurn flag added. |
| 21 | Commander + Pikeman combo | Missing in both | ✅ Fixed in v9; combo detected in either play order; grants one free Conjuration (cost 0, gate bypass). commanderComboUsed prevents double-trigger. |
| 22 | Pikeman; reveal top of deck | Missing in both | ✅ Fixed in v9; reveals top card, draws if Warrior, returns to top if not. Player sees the card name and guild either way. |
| 23 | Mage Caller; reveal top of deck | Missing in both | ✅ Fixed in v9; reveals top card, draws if Augury Mage, returns to top if not. Player sees the card name and guild either way. |
| 24 | Swordsman. Warriors to top of deck | Missing in both | ✅ Fixed in v9; `swordsmanPlayedThisTurn` flag. After buying a qualifying card (Warrior subtype, or Farmer if Trainer active), a browser confirm prompt asks: OK = top of deck, Cancel = discard. Applies to any number of purchases this turn. |
| 25 | Trainer. Farmers count as Warriors | Missing in both | ✅ Fixed in v9; `trainerPlayedThisTurn` flag. Retroactive for Farmers already played; forthcoming Farmers also count as Warriors. Unlocks Warrior gate. Synergises with Negotiator. |
| 26 | Negotiator; +1 inf per other Warrior | Missing in both | ✅ Fixed in v9; `negotiatorPlayedThisTurn` flag. Retroactive burst on play (+1 Inf per Warrior already played). Forthcoming Warriors each give +1 Inf as played. Trainer-buffed Farmers count. |
| 27 | Warlord; retroactive +1 inf per Warrior | Missing in both | ⚠️ Open; complex retroactive effect. Deferred to Bundle C. |
| 28 | Supplier; convert unused Food to draws | Missing in both | ✅ Fixed in v9; mid-turn button in actions bar. Each click: 1 Food → 1 card drawn. Repeatable while food > 0. `supplierPlayedThisTurn` flag. |
| 29 | Sacrificer; end-of-turn Legend send | Missing in both | ✅ Fixed; `sacrificerPlayedThisTurn` flag. At end of turn, before cleanup, player is shown a numbered prompt listing their hand. Choose a card to send to Legend or cancel to skip. Card removed from hand, pushed to `S.legend`. |
| 30 | Expiditor → Expediter; attach mechanic | Renamed + redesigned | ⚠️ Open; renamed to "Expediter" (fixed spelling). New effect: "The next building purchased this turn may go straight into play. Expediter attaches to that building, reducing its DEF by 2 while attached." Full attach mechanic deferred to Bundle C. |
| 35 | Handler flat ATK bug | Wrong card data + missing engine logic | ✅ Fixed; `atk_creature:1` in card data caused flat +1 regardless of creature count. Fixed to `atk_creature:0`. Engine logic added: on play, counts active `isCreatureType` permanents and adds that count to `S.atk_creature`. Each Handler played gives a full per-creature burst. |
| 36 | ATK double-counting | `totalAtk()` and render both added `permAtkBonus()` to pools that already contained perm contributions | ✅ Fixed; `S.atk_creature/siege/generic` are set at `startTurn()` to include all permanent contributions. `totalAtk()`, render, attack function, `attackPossession`, and exchange log lines all removed their redundant `+ permAtkBonus()` calls. Creature permanents played mid-turn now add their ATK to the pool immediately on play. |
| 37 | Market slot shifting | `splice + push` collapsed array on purchase | ✅ Fixed; `refill(market, deck, idx)` now takes the slot index and does `market[idx] = newCard` in place. No card ever shifts position. Null slots (empty deck) render as "Empty slot" placeholder. Applies to both purchases and Possession defeats. |
| 38 | Possession attack missing | No way to spend ATK against a Possession in the Conjuration market | ✅ Fixed. Possession cards in the market show a red "⚔ Attack" button with DEF and available ATK displayed. Clicking spends ATK (generic→siege→creature order), sends Possession to Legend (VP counts), fires on-defeat draw reward, refills slot in place via `refill(market, deck, idx)`. |
| 39 | King's Note / Hunter Legend flag collision | `legendedKnThisTurn` shared by both KN sends and Hunter sends | ✅ Fixed. Two independent flags: `legendedKnThisTurn` (only set when KN goes to Legend, only gates KN button) and `hunterLegendUsedThisTurn` (only set in `hunterSendToLegend`, only gates Hunter buttons). Neither blocks the other. |
| 40 | Monster auspice buff not shown or applied | `auspiceTag` and `auspiceBuffHP` on monster data ignored by engine and render | ✅ Fixed; `effectiveMonsterHp()` and `effectiveMonsterBase()` compute live HP including auspice bonus. Combat comparison uses `effHp`. Render shows auspice badge always; orange ⚠ when active. Reactive to auspice changes. |
| 41 | Herbalist not forthcoming | Only counted prior mages on play; subsequent Augury Mages gave no food | ✅ Fixed; `herbalistPlayedThisTurn` flag. On play: prior mages + self. Each subsequent Augury Mage played after Herbalist triggers +1 food. |
| 42 | Monster queue | All monsters in queue; Ghoul not guaranteed first | ✅ Fixed; single player queue is 4 monsters + Portal. Ghoul always selected and always first. 3 random non-Ghoul monsters fill remaining slots. Portal always last. |
| 43 | Granary | New card | ✅ Implemented; `isGranary:true`. Stores unused Food at end of turn (max 5 × active Granary count) in `S.granaryFood`. Added back to pool at `startTurn()`. |
| 44 | Caravan cards | New card type | ✅ Implemented; `isCaravan:true`. Tracked in `S.caravansDeployed[]`. Resolves at start of owner's next turn: removed from `S.permanents`, pushed to `S.legend`, reward fires (+5 Inf or +4 Food). Takes persistent damage (standard `currentDef` system; damage does not reset between turns). **Destruction rule (V10 final. Option 1):** if a Caravan's `currentDef` reaches 0 before the owner's next turn (via PvP or monster attack), it is **destroyed and lost entirely**; removed from play, no Legend, no reward, no VP. Destruction handling requires the PvP permanent damage mechanic (future build); flagged for implementation when that system is built. |
| 45 | Undead Rising; stale effect text | Old text "reveal top cards, make 2nd attack" was unclear and unimplemented | ✅ Redesigned. `onUndeadRising:true` flag. On defeat: draw top 3 cards into hand. Player may play any this turn. End-of-turn prompt per unplayed card: keep in hand / return to top of deck / send to Legend. **Famine variant:** all 3 auto-played immediately, all 3 sent to Legend; "casualties of the moment." Tracked via `S.undeadRisingCards[]` uid array. |
| 46 | Trophy rewards not implemented | All Trophy recurring and passive rewards missing from engine | ✅ Implemented; `useTrophyReward(uid)` function. `trophyRewardUsedThisTurn` Set resets each turn. Ghoul: grants auspice use. Minotaur: draw 1. Silent Stalker: optional legend send. Dragon: draw from discard. Passives: Gargantuan +2 DEF to creatures via `effectivePermDef`, Dank Beast +1 ATK per Trophy via `permAtkBonus`, Noxious Beast gates Conjuration market. |
| 47 | Portal monster attack; partial spend trap | Input field allowed spending less than monster DEF, wasting ATK with no damage applied | ✅ Redesigned; binary kill or don't. `attack()` reads no input. Button shows "⚔ Attack (N needed; you have M)" enabled only when pool ≥ DEF. Spends exactly DEF from pool (generic → siege → creature). Remaining ATK carries forward for next monster. |
| 48 | Card subtype not shown on market/hand cards | Players couldn't identify card types (Library vs Farm vs Siege etc.) | ✅ Fixed; subtype shown as italic grey label below card name on all market and hand cards. Condition `card.subtype !== card.guild` prevents redundant labels. |
| 49 | Hunter recruit scope too broad | Could send cards from hand and discard; should be in-play only | ✅ Fixed; eligible targets: Played This Turn area (non-permanent recruits) + attached recruits in Kingdom only. Hand and discard removed. Legend send button moved to below Played This Turn area for visibility. |
| 50 | Hunter Auspice mandatory not re-establishing each turn | After end-of-turn mandatory send, obligation not re-set for next turn | ✅ Fixed; `startTurn()` sets `S.legendSendMandatory = (S.auspice===1)` each turn. Switching away from Hunter clears obligation immediately in `setAuspice`. |
| 51 | Expediter cycling back to deck | Expediter was stored in attachedCards but also remained in S.played, cycling to discard | ✅ Fixed; on attach, Expediter is spliced out of S.played entirely. Lives only in `bldg.attachedCards`. Effect text changed to "The next building you acquire" (singular). Name corrected to Expediter. |
| 52 | Siegeman name misspelling | "Siegeman" throughout simulator and tracks | ✅ Fixed; all instances corrected to "Siegeman". Internal variable names `isSiegeman`, `siegemanPlayedThisTurn` preserved as-is. |
| 31 | Demented Architect; self-Legend on play | Missing in both | ⚠️ Open. Deferred to Bundle C. |

---

### Decision Point 11. Simulator Schema Migration
**Status:** ✅ Approved. Option C. v8 untouched and playable. Schema migration is Task 0 of v9 build.

---

### Decision Point 12. Card Tracks xlsx Format
**Status:** ✅ Approved. Option C. Hybrid format. Designer columns preserved left side. Dev Flags block right side. `requiresBuilder` column is authoritative for all building gate logic.

---

## SECTION 11. DEVELOPMENT BUCKETS

### 🪣 BUCKET 1. RULES & DOCUMENTATION
**Goal:** Produce a complete, print-ready rulebook for human players.
**Tasks:**
- [ ] Write full turn-by-turn rules from scratch using Sections 1–7 and Section 5A of this document
- [ ] Write a Quick-Start Guide (1 page, first game, no jargon)
- [ ] Write FAQ section: Portcullis immunity, ATK token types, Possession triggers, Trophy lifecycle, Repair timing, Commander + Pikeman combo, Warlord retroactive burst, Auspice use queue
- [ ] Write card glossary (Legend, Repair, Trophy, Possession, Flying, Auspice, Gate, Creature-type, Siege-type, Generic ATK)
- [ ] Format and layout rulebook as a print-ready document
**Deliverable:** `Connivances_Rulebook_v1.docx`
**Prompt Starter:** "Using CONNIVANCES_Project_Master_Instructions_v2_0.md Sections 1–7, Section 5A, and Section 12A, write a complete game rulebook..."

---

### 🪣 BUCKET 2. DIGITAL SIMULATOR UPGRADE
**Goal:** Evolve the existing simulator from a functional prototype to a feature-complete digital playtesting tool.

**Bundle A. COMPLETE (v9):**
- [x] Task 0: Schema migration to v1.9 (atk_creature/siege/generic, isCreatureType, Trophy reward fields, repairCount)
- [x] Three ATK token types (🟡🔴⚪) with Portcullis targeting restrictions
- [x] Free-form turn structure (no phase locks; Repair on card play; ATK spend any time)
- [x] Auspice system: use queue, per-use restriction, real-time food delta, Mystic immediate draw
- [x] Per-card conditional effects: Reaper, Herbalist, Conjurer's Aid, Scribe, Augury Initiate, Channeler, Witchdoctor, Fallah, Dark Magic, Irrigator
- [x] Hunter auspice + Hunter card → Legend from Played area
- [x] Oracle gate bypass (Libraries + Armories)
- [x] Soothsayer gate bypass (Conjurations under Mystic)
- [x] Commander + Pikeman free Conjuration combo
- [x] Pikeman: reveal top of deck, draw if Warrior (Item 22)
- [x] Mage Caller: reveal top of deck, draw if Augury Mage (Item 23)
- [x] Guild color system (faction border + chip)
- [x] Card hover tooltips

**Bundle B. NEXT:**
- [ ] Trophy lifecycle (Discard → play → Kingdom permanent; placement reward; recurring rewards; Auspice HP buff)
- [ ] Possession card system (trigger on draw into market, host destruction, defeat effects)
- [ ] Wall Set bonuses / Completion tracking (0/2 bonds)

**Bundle C. AFTER B:**
- [ ] Swordsman: Warriors bought this turn may go to top of deck (Item 24)
- [x] Swordsman: Warriors bought this turn may go to top of deck (Item 24)
- [x] Trainer: Farmers count as Warriors this turn (Item 25)
- [x] Negotiator: +1 inf per other Warrior played this turn (Item 26)
- [ ] Warlord: retroactive +1 inf per Warrior, forthcoming Warriors too (Item 27)
- [ ] Supplier: convert unused Food to card draws at end of turn (Item 28)
- [ ] Sacrificer: end-of-turn Legend send (Item 29)
- [ ] Expiditor + Attach mechanic (Item 30)
- [ ] Demented Architect: self-Legend + building subtype change (Item 31)
- [ ] VP scoreboard and end-game summary screen

**Bundle D. LAST:**
- [ ] Multi-player support (2–4 players with separate state objects)
- [ ] Animated card transitions and visual polish
**Deliverable:** `connivances_simulator_v10.html` (ongoing iteration)

---

### 🪣 BUCKET 3. CARD ART & VISUAL DESIGN
**Goal:** Establish visual identity for the game and produce art briefs for every card.
**Tasks:**
- [ ] Define visual style guide: color palette, typography, border treatments, badge system
- [ ] Write art direction brief for each Guild (Warrior, Augury Mage, Builder, Conjurer, Farmer)
- [ ] Write individual art prompt for each unique card
- [ ] Design card frame template (front face: name, art box, guild, stats, effect text; ATK token type badge)
- [ ] Design card back
- [ ] Design Monster / Portal / Trophy card frames (distinct from standard cards)
- [ ] Design Auspice indicator cards
- [ ] Design physical ATK token components (🟡🔴⚪)
**Deliverable:** `Connivances_Art_Brief.md` + `card_frame_template.html`

---

### 🪣 BUCKET 4. BALANCE & GAME DESIGN ANALYSIS
**Goal:** Validate that card costs, VP values, and quantities are balanced for competitive play.
**Tasks:**
- [ ] Build balance spreadsheet: cost efficiency for all Recruits
- [ ] Evaluate ATK token type economy: is Siege ATK undervalued if double-damage-to-Walls is added?
- [ ] Evaluate Trophy HP balance with Auspice buff (+1 HP): does this make Trophies too durable?
- [ ] Evaluate Food economy: is 3 starting Food appropriate?
- [ ] Evaluate Legend ramp: is King's Note 1-per-turn appropriate?
- [ ] Evaluate Warlord retroactive burst for dominant strategy potential
- [ ] Evaluate monster HP curve vs. ATK generation curve
- [ ] Evaluate Possession frequency vs. player counter ability
- [ ] Recommend quantity and cost adjustments
**Deliverable:** `Connivances_Balance_Analysis.xlsx`

---

### 🪣 BUCKET 5. PHYSICAL CARD PRODUCTION
**Goal:** Prepare all files for physical print production.
**Tasks:**
- [ ] Generate complete card list with final quantities for print
- [ ] Create card template in correct dimensions (2.5" × 3.5" / 63.5mm × 88.9mm)
- [ ] Create ATK token components (🟡 Creature, 🔴 Siege, ⚪ Generic)
- [ ] Create token/resource tracker cards or components
- [ ] Create Auspice indicator card
- [ ] Create Monster queue reference card
- [ ] Export print-and-play PDF with bleed marks
- [ ] Create Tabletop Simulator mod data file (JSON using Section 9 v1.8 schema)
**Deliverable:** `Connivances_Print_Files/` folder

---

### 🪣 BUCKET 6. MARKETING & PITCH MATERIALS
**Goal:** Produce materials to pitch Connivances to publishers, investors, or crowdfunding backers.
**Tasks:**
- [ ] Write one-page game overview (elevator pitch format)
- [ ] Write competitive market analysis (Dominion, Aeon's End, Star Realms)
- [ ] Create feature comparison table vs. comparable deck-builders
- [ ] Write narrative lore overview
- [ ] Design pitch deck slides (10 slides)
- [ ] Write Kickstarter campaign page draft
**Deliverable:** `Connivances_Pitch_Deck.pptx` + `Connivances_Kickstarter_Draft.md`

---

## SECTION 12. HOW TO USE THIS DOCUMENT IN OTHER CONVERSATIONS

When starting a new Claude conversation within this project folder to work on a specific Bucket:

1. Reference this file by name: `CONNIVANCES_Project_Master_Instructions_v2_0.md`
2. Specify which Bucket and task you are working on
3. Specify if you need Claude to use a specific Section
4. Always ask Claude to flag any new discrepancies it notices against Section 10

**Example prompt for Bucket 2:**
> "I'm working on Bucket 2 from CONNIVANCES_Project_Master_Instructions_v2_0.md. The current simulator is connivances_simulator_v10.html. Read Section 12A before writing any code."

---

## SECTION 12A. SIMULATOR FIDELITY CONTRACT

**This section is mandatory reading before writing a single line of code for any new simulator version.** It captures every design decision, edge case, and behaviour that is easy to miss when building from the rules tables alone. A build is not complete until every item here is implemented and verified.

---

### 1. Starting State

- Starting hand (5 cards): King's Note × 2, Devoted Aid × 1, Farm Hand × 1, Augury Initiate × 1
- Starting deck (5 cards, shuffled): Devoted Aid × 4, Rice Field × 1
- Starting food: 3
- Starting auspice: Harvest (index 2)
- Monster queue: full pool of 9 monsters shuffled, The Portal always last (10 total)
- Market slots: 6 Recruits, 3 Buildings, 3 Conjurations

---

### 2. Food System

- **Turn start food** = `3 + permFoodBonus()`
- `permFoodBonus()` sums all active (non-Disabled) Farm permanents. Each Farm contributes `card.food + auspiceBonus` where:
  - Harvest auspice: `+1` per Farm
  - Famine auspice: farm output set to `0` entirely (zeroed, not -1)
  - Mystic or Hunter: `0` bonus
  - `irrigatorPlayedThisTurn = true` blocks the Famine penalty; farms produce normally for that turn
- **Rice Field base food = 2.** This was corrected in v1.8. Do not regress to 1.
- **Farm Hand base food = 2.** Starter card. 0 cost, 0 influence. Its sole purpose is providing enough Food to play a fourth card on opening turns before the Rice Field has surfaced. Do not regress to 1.
- **Farm entering play mid-turn**: immediately contributes its food (with current Auspice bonus) to `S.food` for that turn.
- **Auspice switch mid-turn (V11-2.3/2.4):** `setAuspice` diffs each active Farm's **true output** between the old and new Auspice (Harvest = base+1, Famine = 0 unless Irrigator, else base); never a flat ±1. When a negative delta is clamped at food 0, the shortfall accrues to the per-turn `S.farmFoodDebt` ledger and is repaid out of later positive deltas before any food is credited. Auspice round trips are net zero. `farmFoodDebt` resets each `startTurn`. Do not regress to the ±1 model or to an unledgered clamp (food-mint exploit).
- **1 Food to play each card** from hand; applies to all card types including permanents (buildings, creatures).
- Food does not carry over between turns. Resets to `3 + permFoodBonus()` each turn start.

---

### 3. Auspice System

**The Auspice is real-time. Every effect fires immediately when the Auspice changes.**

#### Auspice Effects (all real-time)
| Auspice | Index | Global Effect | Immediate on Switch |
|---|---|---|---|
| Mystic | 0 | Cleanup draw = 5 (standard). **Start of turn:** +1 additional card drawn via `startTurn()`. | Draw 1 card immediately when switching TO Mystic mid-turn |
| Hunter | 1 | May send one played card to Legend this turn | → Legend buttons appear on Played area immediately |
| Harvest | 2 | Farms produce +1 Food/turn | Food adjusts immediately per farm count |
| Famine | 3 | Farms produce 0 Food/turn (output zeroed entirely) | Food adjusts immediately; all active Farm contributions drop to 0 |

#### Real-Time Food Delta
Every Auspice change immediately calculates: `delta = (newBonus - oldBonus) × activeFarmCount` and applies it to `S.food`. Respects `irrigatorPlayedThisTurn` for Famine calculations. Switching Harvest→Mystic with 2 Farms: food drops by 2. Switching back: food rises by 2. Each switch triggers a fresh delta.

#### Auspice Use Queue
- Pills are **locked by default**. No free clicking.
- Auspice-change cards push entries to `S.auspiceUses[]`:
  - Augury Initiate (`ai`): pushes `'mystic-harvest'`; permits only index 0 or 2
  - Channeler (`a3`), Witchdoctor (`a7`), Fallah (`falla`): push `'any'`; permits all four
  - Dark Magic (`j5`): forces Famine immediately on play; no queue entry, no pill click
- Each switch **consumes one queue entry** (the first valid entry for the target auspice)
- Cannot switch to the **currently active** Auspice
- Multiple switches per turn are possible if multiple cards were played
- Queue resets at end of turn
- Pills show pulse animation when clickable. Display counter "X any + Y Mystic/Harvest" when uses are banked.

---

### 4. Per-Card Conditional Effects

These fire at **card play time** based on current state. All must be explicitly coded; they do not derive from card data alone.

| Card | ID | Effect |
|---|---|---|
| Augury Initiate | `ai` | Pushes `'mystic-harvest'` to auspice queue |
| Channeler | `a3` | Pushes `'any'` to auspice queue |
| Witchdoctor | `a7` | Pushes `'any'` to auspice queue |
| Fallah | `falla` | Pushes `'any'` to auspice queue |
| Soothsayer | `a4` | Sets `soothsayerPlayedThisTurn = true`. Under Mystic Auspice, bypasses the Conjurer gate for Conjuration purchases |
| Swordsman | `w2` | Sets `swordsmanPlayedThisTurn = true`. In `buyCard`: after any Recruit purchase, if the card qualifies (Warrior subtype, OR Farmer subtype/`isFarmer` when Trainer is active), triggers a confirm prompt. OK = `S.discard.pop()` + `S.deck.unshift()` (card moves to top of deck). Cancel = stays in discard. Applies to any number of purchases per turn. |
| Trainer | `w3` | Sets `trainerPlayedThisTurn = true`. **Retroactive:** any Farmer already in `S.played` this turn now counts as a Warrior; sets `warriorPlayedThisTurn = true`, increments `warriorsPlayedThisTurn`, and triggers Negotiator bonus if Negotiator was played. **Forthcoming:** any Farmer played while flag is true `countsAsWarrior` in the turn flags block. Farmers identified by `card.subtype === 'Farmer' || card.isFarmer`. |
| Negotiator | `w4` | Sets `negotiatorPlayedThisTurn = true`. **Retroactive burst:** `+1 Inf × (warriorsPlayedThisTurn - 1)` immediately on play (all other Warriors already played this turn). **Forthcoming:** each subsequent card that `countsAsWarrior` triggers `+1 Inf` via the turn flags block. Trainer-buffed Farmers count. |
| Conjurer's Aid | `c1` | If Mystic active: draw 1 card immediately |
| Familiar | `j3` | **On play:** `drawOnPlay:1`; draw 1 card immediately when entering Kingdom. **Start-of-turn passive:** `startTurn()` counts active non-Disabled Familiars and calls `drawCards(familiarCount)` after the cleanup 5-card draw. Suspends when Disabled. Multiple Familiars stack. |
| Scribe | `a5` | If Mystic active: draw 1 card per active Armory/Library in Kingdom |
| Herbalist | `a6` | Sets `herbalistPlayedThisTurn = true`. **On play:** counts Augury Mages already in `S.played` + 1 for self, adds that food immediately. **Forthcoming:** any other Augury Mage played after Herbalist (checked via `card.subtype==='Augury Mage' && card.id!=='a6' && S.herbalistPlayedThisTurn`) gives +1 food when it resolves, offsetting its play cost. Reset at end of turn. |
| Reaper | `f4` | If Harvest active: give +2 Food instead of +1 |
| Teramancer | `c5` | `isConjurer:true`; unlocks Conjurations gate. `isFarmer:true`; counts for all Farmer synergies (Trainer, War Room, future effects). No extra conditional logic needed; +2 Inf and +1 Food resolve from standard fields. Displays dual guild chips: Conjurer + Farmer. |
| Irrigator | `f2` | Sets `irrigatorPlayedThisTurn = true`. Log if Famine is active |
| Hunter (Warrior) | `w6` | Sets `hunterLegendAvailable = true`. → Legend buttons appear on non-permanent Played cards |
| Mage Caller | `a2` | Peek at `S.deck[0]`. If Augury Mage subtype: draw it. If not: leave on top. Log the card name and guild either way. Reshuffle discard into deck first if deck is empty |
| Pikeman | `w1` | Peek at `S.deck[0]`. If Warrior subtype: draw it. If not: leave on top. Log the card name and guild either way. Reshuffle if needed. ALSO: if Commander already played this turn (and combo not yet used), grant free Conjuration |
| Commander | `w7` | If Pikeman already played this turn (and combo not yet used), grant free Conjuration |
| Dark Magic | `j5` | Forces Auspice to Famine immediately. Increment `auspiceChangesThisTurn`. No queue entry granted |
| Sacrificer | `c2` | Sets `sacrificerPlayedThisTurn = true`. At end of turn (before cleanup, while hand still exists): player shown numbered prompt of hand cards. Choose one to send to Legend (removed from `S.hand`, pushed to `S.legend`) or cancel to skip. Reset at end of turn. |
| Handler | `c3` | `atk_creature:0` in card data (flat field must be zero). On play: counts active non-Disabled `isCreatureType` permanents in `S.permanents`. Adds that count to `S.atk_creature`. Repeatable; each Handler played gives another full per-creature burst. 3 creatures + 2 Handlers = +6 🟡 ATK. |
| Sir Cluckles | `j10` | **Passive in `permAtkBonus()`**; not a play-time burst. While Active in Kingdom: `cr += clucklesCount × broodCount`. Two Sir Cluckles with three Brood = +6 🟡 ATK. Sir Cluckles is also `subfaction:'Brood'`; he counts as a Brood for other effects but his own passive counts OTHER Brood, not himself. `atk_creature:1` is his own base contribution. Suspends when Disabled. |

#### Commander + Pikeman Combo
- Either play order fires the combo (Pikeman-then-Commander or Commander-then-Pikeman)
- `commanderComboUsed` flag prevents double-trigger in the same turn
- Effect: sets `freeConjurationAvailable = true`
- In `buyCard`: if `mType === 'conjuration'` and `freeConjurationAvailable`: cost = 0, gate bypassed, flag consumed

---

### 5. Market Gates

| Market | Gate | Notes |
|---|---|---|
| Recruits | Always open | No gate |
| Buildings. Wall subtype | Always open | `requiresBuilder: false` |
| Buildings. Farm subtype | Always open | `requiresBuilder: false` |
| Buildings. Portcullis | Always open | `requiresBuilder: false` |
| Buildings. Fortress | Always open | `requiresBuilder: false` |
| Buildings. Siege subtype | Builder OR Siegeman | `siegemanPlayedThisTurn` bypasses |
| Buildings. Library/Armory subtype | Builder OR Oracle | `oraclePlayedThisTurn` bypasses |
| Buildings. Dojo (School) | Warrior only | `requiresWarrior: true`. Builder does NOT unlock Dojo |
| Buildings; all other | Builder | `builderPlayedThisTurn` required |
| Conjurations | Conjurer OR Soothsayer+Mystic OR Noxious Beast in Kingdom | `conjurerPlayedThisTurn` OR `soothsayerPlayedThisTurn && S.auspice === 0` OR Noxious Beast trophy active |

Gates are enforced in **both** `buyCard()` (functional) and `renderMarket()` (visual). All flags reset at end of turn.

> ⚠️ **Critical:** The render's `conjOpen` variable must be computed from ALL valid bypass sources; `conjurerPlayedThisTurn || (soothsayerPlayedThisTurn && auspice===0) || noxiousBeastActive`. A mismatch between render and buyCard causes the gate to appear locked visually even when buyCard would allow the purchase. Always keep these in sync.

---

### 6. Repair System

- Builder cards with `repairCount > 0` grant repair uses **immediately on play**
  - `repairCount: 1` = House Hand, Repair Master (repair 1 permanent)
  - `repairCount: 2` = Contractor (repair 2 permanents)
- Repair uses are added to `S.repairUsesAvailable` and can be spent **at any time** during the turn
- Clicking a Disabled permanent in the Kingdom consumes one repair use
- Repairing restores `currentDef` to `card.def` and sets `disabled: false`; all bonuses reactivate immediately
- `repairUsesAvailable` resets to 0 at end of turn

---

### 7. Hunter Legend Send

- Triggered by: Hunter Auspice (`S.auspice === 1`) OR Hunter Warrior card played (`hunterLegendAvailable = true`)
- While active: non-permanent cards in the Played area show a clickable → Legend button
- Clicking sends that card to Legend: **removes from `S.played`** (not `S.discard`; the card hasn't moved there yet), pushes to `S.legend`, sets `hunterLegendUsedThisTurn = true`
- `hunterLegendAvailable` set to false after use
- **`hunterLegendUsedThisTurn` is completely separate from `legendedKnThisTurn`.** Using Hunter to send a card to Legend does NOT block King's Note from going to Legend that turn, and vice versa.
- King's Note → Legend (the standard one-per-turn mechanic) only checks and sets `legendedKnThisTurn`

---

### 7B. Exchange Mechanic (Poison Room, Armory, Dojo)

Certain permanent buildings have an **Exchange** active ability; spend a resource to gain ⚪ Generic ATK immediately. This is:
- **Repeatable**; can be used as many times as the player can afford during their turn
- **Any time**; no phase restriction; interleave freely with card plays and purchases
- **Shown as a button** on the permanent card in the Kingdom (only when Active, not Disabled)
- Button disables automatically when the player can't afford the cost; shows how much more is needed

| Card | ID | Cost | Gain | Notes |
|---|---|---|---|---|
| Poison Room | `bg10` | 3 Food | +2 ⚪ Generic ATK | Food resource spent; reduces cards playable this turn |
| Armory | `bg11` | 4 Influence | +1 ⚪ Generic ATK | Base ratio. Becomes 3:1 at 0/2 completion (Bundle B) |
| Dojo | `bg8` | 3 Influence | +1 ⚪ Generic ATK | |

ATK gained goes directly into `S.atk_generic`. It is permanent for the turn (not consumed until spent in combat). Exchange uses do not carry over to the next turn.

### 8. ATK Type System

Three separate counters: `S.atk_creature`, `S.atk_siege`, `S.atk_generic`.

| Type | Token | Sources | Cannot Target |
|---|---|---|---|
| Creature | 🟡 | Creature-subtype permanents (Brood, Armored Hound, Familiar, Gryphon, Golem Defender, Tiger, Sir Cluckles), Handler buff, Conjure Master dynamic | Portcullis and its bonded Wall Set |
| Siege | 🔴 | Catapult (+1/turn), Trebuchet (+2/turn) | Nothing |
| Generic | ⚪ | All other sources (Recruits, exchanges, Dragon Trophy, Siegeman bonus) | Nothing |

- Turn start: `S.atk_creature/siege/generic` reset to `permAtkBonus()` values (permanent passives), not to zero
- Combat UI shows three token stacks with counts. Player selects which type to spend before attacking
- Partial attack (spend < monster DEF) is legal but wasted. ATK is subtracted, no damage dealt
- Flying (Gryphon, Nightmare when played): full ATK pool bypasses Wall row. 🟡 ATK still cannot target Portcullis even when Flying

---

### 9. Kingdom Zones

- **Three-column layout (V10):** `kingdom-main` (left) stacks Wall Row over Buildings & Conjurations; `trophy-zone` (right, gold border) spans both rows.
- **Wall Row (front of kingdom-main):** Wall-subtype permanents. Non-flying attackers must target this row before back row
- **Back Row (Buildings & Conjurations):** All other non-Trophy buildings, creatures
- **Trophy zone:** Trophy permanents only. Label "🏆 TROPHIES; not targeted by monsters"; "No trophies yet" when empty. **Trophies are filtered out of `monsterPickTarget`. Field monsters can never attack them.**
- Disabled permanents (DEF reduced to 0): all bonuses suspended. Show visually rotated/greyed
- `currentDef` tracks remaining DEF

---

### 10. Deck Management

**Played card timing; critical rule:**
- **Non-permanent played cards stay in `S.played` for the entire turn.** They do NOT enter `S.discard` until end-of-turn cleanup. This mirrors the physical game; a card sitting in the played zone on the table is not in the discard pile and cannot be reshuffled. If any draw effect (Mystic switch, Supplier, Scribe, Conjurer's Aid, Familiar, etc.) exhausts the deck and forces a reshuffle mid-turn, only cards already in `S.discard` before this turn started are eligible. Cards played this turn are immune to mid-turn reshuffling.
- **Permanent played cards** (`isPermanent:true`) go to `S.permanents`. Also pushed to `S.played` with `isPermanent:true` for display. They never enter discard.
- **Purchased cards** go to `S.discard` immediately on purchase (correct; they were never played from hand and the player needs to know they're in the pool).

**End-of-turn cleanup order (strict):**
1. Unplayed hand cards → `S.discard`
2. `S.played` non-permanents → `S.discard`
3. `S.played` cleared
4. If deck is empty: shuffle `S.discard` into new `S.deck`, clear `S.discard`
5. Draw exactly **5 cards**; no more, no less (reshuffle mid-draw if deck exhausts again)
6. Reset all turn flags
7. Call `startTurn()` immediately after

**Start-of-turn (passive/active abilities; fires after cleanup draw):**
1. Reset resources: `S.food = 3 + permFoodBonus()`, `S.inf = permInfBonus()`, `S.atk = permAtkBonus()`
2. **Mystic auspice:** draw 1 additional card
3. **Familiar passive:** draw 1 additional card per active (non-Disabled) Familiar in Kingdom
4. **Wall Set / building completion bonuses** (Bundle B): two distinct effects:
   - **One-time completion trigger:** fires immediately when the second card is played (mid-turn, on that turn). Example: playing a second Irrigated Field triggers "+2 Influence" that turn.
   - **Ongoing passive:** once the set is complete and both cards are Active, the improved effect (e.g. Armory 3:1 ratio, Fortress passive DEF buff) is available every turn going forward. The ongoing portion follows the same rule as other passives; it is in effect at the start of each turn and suspends if either set card is Disabled.
5. **All other `(0/2)` completion bonuses** follow the same two-part pattern above.
6. (Future: Trophy recurring rewards also fire here; see Section 5A)

**Key distinction:** The cleanup draw is always exactly 5. Start-of-turn abilities add to the hand *after* those 5 are drawn. This matches the physical game; you draw your hand, then your abilities activate. This applies equally to: Mystic draw, Familiar draw, Wall Set bonuses, building completion bonuses, and Trophy recurring rewards.

**Other deck rules:**
- Deck empty AND discard empty during draw: stop drawing, do not crash
- Card reveal (Mage Caller `a2`, Pikeman `w1`): peek `S.deck[0]` without removing. If match: splice out and push to hand. If no match: leave on top. Reshuffle discard → deck first if deck is empty before peeking
- Mid-turn reshuffle (during `drawCards()`): if deck empties while drawing, shuffle discard into new deck and continue. Only `S.discard` contents at that moment are eligible; not `S.played`

---

### 11. VP Calculation

`calcVP()` counts face value from all zones: `S.hand + S.deck + S.discard + S.permanents + S.legend + S.played`. The `S.played` array must be included because non-permanent played cards live there during the turn and are NOT yet in `S.discard`. **Permanents are counted ONLY from `S.permanents`; the `S.played` loop must skip `isPermanent` entries** (V11-2.1). uid-based dedup alone is NOT sufficient: a played permanent's `S.played` display copy is minted with a *different* uid than its Kingdom copy, so the dedup never matches and permanents scored twice on their play turn. Do not regress to uid-only dedup. Trophy monsters in discard count their VP. The Portal's 6 VP goes to whoever defeats it.

---

### 12. UI Requirements

- **Guild color system:** Left border stripe + tinted guild chip on every card (hand and market)
  - Farmer = brown (`#8B5E3C`)
  - Warrior = pink (`#D4709A`)
  - Augury Mage = blue (`#4A7CC7`)
  - Conjurer = red (`#B03030`)
  - Builder = green (`#3A7A44`)
  - Factionless/Starter/Possession = grey
  - Dual-identity cards (Teramancer): show two chips side by side
- **Hover tooltips:** Every card element (hand cards, market cards, played chips, legend chips, permanent cards) shows a dark floating tooltip with full effect text on hover.
  - Parent containers need `position:relative; overflow:visible` all the way up the DOM tree
  - Played chips and legend chips must use `display:inline-flex; width:fit-content; white-space:nowrap` so the tooltip `div` child does not expand the chip size
  - Card text must be in a `<span>` child, not a bare text node, so the tooltip `div` sibling has no layout impact
  - Tooltip itself uses `white-space:normal` so its text wraps correctly inside the popup
- **Auspice status bar:** Below the pills, always shows what the current Auspice is actively doing this turn
- **Repair notice:** When `repairUsesAvailable > 0`, show a notice bar. Disabled permanents in Kingdom become clickable
- **Played area:** Chips are `inline-flex`, `width:fit-content`. Under Hunter: shows → Legend button inside the chip
- **Legend zone:** Chips are `inline-flex`, `width:fit-content`. Cards remain permanently
- **Supplier button:** Hidden by default. Appears in actions bar when `supplierPlayedThisTurn = true`. Shows current food count. Disables at food = 0. Each click: 1 Food → 1 card drawn
- **Exchange buttons:** Appear on Poison Room, Armory, Dojo permanents in Kingdom. Only shown when Active (not Disabled). Disable when player can't afford cost

---

### 13. Things That Were Bugs in v8. Must Not Regress

| Bug | Correct Behaviour in v9+ |
|---|---|
| Famine never penalised farms at turn start | `permFoodBonus()` sets Farm food to `0` under Famine (not -1). `irrigatorPlayedThisTurn` blocks this; farms produce normally when Irrigator was played. |
| All buildings gated behind Builder | Walls, Farms, Portcullis, Fortress have `requiresBuilder: false`; always open |
| Auspice freely clickable at all times | Pills locked; use queue gates all changes |
| Rice Field food = 1 | Rice Field base food = **2** |
| Farm Hand food = 1 | Farm Hand base food = **2** (physical card correction) |
| Soothsayer did nothing | Sets `soothsayerPlayedThisTurn`; bypasses Conjurer gate under Mystic |
| Soothsayer gate: render didn't match buyCard | `conjOpen` in render computed from all three sources: conjurer \|\| soothsayer+Mystic \|\| Noxious Beast |
| Commander+Pikeman combo did nothing | `commanderComboUsed` flag, `freeConjurationAvailable` grant |
| Mage Caller / Pikeman did nothing | Reveal-and-draw implemented with deck peek |
| Trainer / Negotiator / Swordsman did nothing | All three fully implemented with retroactive+forthcoming logic |
| Teramancer was Conjurer-only | `isFarmer:true`; dual identity. All Farmer synergy logic checks `card.isFarmer \|\| card.subtype === 'Farmer'` |
| Played cards entered discard immediately on play | Non-permanent played cards stay in `S.played` all turn. Only move to `S.discard` at end-of-turn cleanup. This prevents mid-turn reshuffling of cards already played this turn; matching physical game behaviour |
| Hunter Legend send removed from wrong zone | `hunterSendToLegend` removes from `S.played` directly (not `S.discard`) since the card hasn't moved there yet |
| VP calculation missed played non-permanents | `calcVP()` includes all of `S.played` (with deduplication) since non-permanents live there mid-turn |
| Sir Cluckles Brood buff was unimplemented | Now a **permanent passive in `permAtkBonus()`**: `cr += clucklesCount × broodCount`. NOT a play-time burst. `creatureAtkSpentThisTurn` flag removed entirely; no longer needed. Two Sir Cluckles + three Brood = +6 🟡 ATK/turn. Sir Cluckles also has `subfaction:'Brood'`. |
| Familiar passive draw missing | `j3` has two draw effects: (1) `drawOnPlay:1` fires immediately on entry into Kingdom. (2) Passive: `startTurn()` counts active non-Disabled Familiars and calls `drawCards(familiarCount)`; fires at start of turn AFTER the 5-card cleanup draw, not during cleanup. |
| Handler flat +1 bug | `c3` has `atk_creature:0` in card data. Effect fires in per-card block: count active `isCreatureType` permanents, add to `S.atk_creature`. Never a flat +1. 2 Handlers × 3 creatures = +6. |
| Herbalist not forthcoming | `herbalistPlayedThisTurn` flag required. On play: counts prior mages + self. Each subsequent Augury Mage played after Herbalist automatically gets +1 food via the per-card effects block check `card.subtype==='Augury Mage' && card.id!=='a6' && S.herbalistPlayedThisTurn`. |
| Monster auspice buff ignored | `effectiveMonsterHp()` = `S.monsterHp + auspiceBuffHP` when `AUSPICES[S.auspice].name === m.auspiceTag`. Always use `effectiveMonsterHp()` in combat and render; never raw `S.monsterHp`. Reactive; recomputed every render call. |
| ATK double-counting | `S.atk_creature/siege/generic` set at `startTurn()` already include all perm contributions. `totalAtk()`, render, attack fn, `attackPossession`, exchange logs must use pool values directly; never add `permAtkBonus()` on top. Permanents played mid-turn add their ATK immediately on play. |
| Market slot shifting | `refill(market, deck, idx)` replaces `market[idx]` in place. Never `splice + push`. All other slot positions preserved. Null slots show "Empty slot" placeholder. Applies to purchases and Possession defeats. |
| King's Note / Hunter flag collision | Two independent flags: `legendedKnThisTurn` (KN only, gates KN button) and `hunterLegendUsedThisTurn` (Hunter only, gates Hunter buttons). Never cross-set. |
| Monster auspice buff not shown or applied | Each Trophy monster has `auspiceTag` and `auspiceBuffHP:1`. `effectiveMonsterHp()` = `S.monsterHp + (auspiceMatch ? auspiceBuffHP : 0)`. Combat comparison uses `effHp`, never raw `S.monsterHp`. Render shows auspice tag badge always; badge turns orange with ⚠ warning when active. HP bar and HP/Max both use effective values. Reactive; updates instantly when auspice changes. |
| Portal monster attack is binary | `attack()` takes no input. Button only enabled when total ATK pool ≥ `effectiveMonsterHp()`. Spends exactly `effHp` from pool (generic → siege → creature). No partial spend, no wasted ATK. Remaining pool carries forward. |
| Hunter legend send scope | Hunter Auspice and Hunter Recruit legend sends are in-play only: Played This Turn area (non-permanent recruits) + attached recruits in Kingdom. NOT hand, NOT discard. `legendSendMandatory` re-established at `startTurn()` if auspice is still Hunter. |
| Expediter not cycling | After attaching, Expediter is spliced out of `S.played` entirely; lives only in `bldg.attachedCards`. `_attached=true` prevents discard cycling. DEF restored to host when Expediter is detached or sent to Legend. |
| Siegeman spelling | All display text uses "Siegeman". Internal variable names `isSiegeman`, `siegemanPlayedThisTurn` preserved as-is; do not rename them. |
| Trophy rewards per-turn | `trophyRewardUsedThisTurn` (Set) resets each `endTurn()`. One use per Trophy per turn. Passive Trophies (Gargantuan, Dank Beast, Noxious Beast) have no button; always-on via engine. |

---

### 13A. Things That Were Bugs in V10. Must Not Regress

These were found and fixed through playtesting during the V10 (Seeping Portal) build. Do not reintroduce them.

| Bug | Correct Behaviour in V10+ |
|---|---|
| Monster attack button did nothing | The attack button `onclick` had a quote-escaping issue that prevented monster attacks from firing. Fixed; button invokes the attack handler cleanly. |
| Monsters never unsealed | A double-`break` in the cork check exited the unseal loop early. Fixed; loop evaluates every corked monster's condition. |
| Monsters re-unsealed infinitely | Missing `monstersUnsealed` tracking caused conditions to re-fire every turn. Fixed; once a monster unseals it is recorded and never re-evaluated. |
| Portal attack hit the wrong target | Portal attack routed through a stale `S.monsterIdx`. Fixed; the portal is located directly rather than by cached index. |
| Fortifier targeted creatures | Fortifier (attach to any building) incorrectly offered creature-type permanents as targets. Fixed; buildings only. |
| Exorcist dispel missing on market Possessions | The Exorcist dispel option did not appear on Possessions sitting in the market. Fixed; dispel available on market Possessions. |
| Irrigated Field set fired with one card | Set completion counted all Farm-subtype permanents, so a single Irrigated Field triggered the 0/2 bonus. Fixed; counts Irrigated Field specifically for its own set. |
| Wall bond / attach prompts silently blocked | `prompt()` dialogs are silently blocked in-browser, so bonding and attach-target selection never appeared. Fixed; all replaced with overlay pickers throughout. |
| Trophy monsters were valid monster targets | Field monsters could target Trophy permanents in the Kingdom. Fixed. Trophies are excluded from monster attack targeting. |
| Portcullis/Fortress stonewalled monsters | Only the Walls card (bg3, `isTaunt`) blocks. Portcullis and Fortress are `isWall` for set bonding but do not block targeting. `monsterPickTarget` and `checkWallSiege` gate on `isTaunt`. |
| Set bonuses deduped instead of stacking | Identical bonuses stack (two Irrigated Fields = +4 Influence; Trophy Room + Scriptorium = Draw 4). Recurring bonuses pause when either pair member is disabled. |
| Exorcist dispel unlimited | One dispel per turn (`exorcistDispelUsedThisTurn`). Remaining market Possessions revert to Attack buttons after the dispel is used. |
| Multiple attachments per permanent | One recruit attachment per permanent. Already-attached permanents excluded from pickers. Fortifier targets buildings (Farms valid, not creatures/walls/trophies); Meurtrière targets Walls; Retinue targets creatures. |
| Buff chips modifying the pool | `getCreatureBuffs()` reports only; it never modifies state. Turn-only buffs vanish at end of turn; passive buffs persist while source active. |
| Familiar tied to Auspice | Familiar is draw-engine only; **no Auspice interaction** (confirmed). |
| Granary treated as set-eligible | Granary subtype is `Granary`; it carries no completion bonus, so it never pairs. Not set-eligible. |
| Ghoul targeting the Walls card as a "farm" | Ghoul farm priority filters on subtype `Farm` only; the Walls card (bg3) was wrongly included and has been removed. |
| Market badge stripping mangling card data | `stripRedundantResources()` removes leading unconditional gain phrases **at render time only, market cards only**; card data is untouched. Conditionals and "/turn" phrases are preserved. |
| Set completion self-bonding first Wall | Set completion passes the placed permanent's uid (`newPerm`); the first-Wall self-bond bug is fixed. |

---

### 13B. Final V10 Late-Session Mechanics. Must Not Regress

Locked in the final V10 build (post-v2.0-snapshot). Do not reintroduce the old behavior.

| Rule | Correct Behaviour |
|---|---|
| No browser dialogs anywhere | No `prompt()` / `confirm()` / `alert()` anywhere in the codebase; every choice goes through the `showListPicker()` / `showHealPicker()` overlay. Browser dialogs are silently blocked in the iframe. |
| Siege monsters attackable | `attackFieldMonster` accepts both `field` AND `siege` states. |
| Famine flag on every path | `famineEverActive` is set by EVERY path to Famine; `setAuspice`, Dark Magic (j5), and `startTurn`. Never bypass `setAuspice` without also setting the flag. |
| Heal/repair grants mid-turn income | Healing or repairing a permanent mid-turn restores its per-turn ATK/Inf/Food via `grantMidTurnIncome()`; Food is Auspice-aware (`farmFoodValue`). Draw passives are NOT re-fired (open ruling, item 25). |
| Repair rejects creatures | `useRepair` is buildings-only; heals (Cleric/Exorcist/Enforcer) are the creature restore path. |
| Portal read directly | Portal attack and render read the portal's HP directly, never via a cached `monsterIdx`. |
| Undead Rising disposition mandatory | `endTurn()` runs the mandatory sequential Undead Rising disposition picker before `endTurnCore()`; Legend sends increment `legendSentEver`. |
| Wall Siege needs 2 DISTINCT monsters | `checkWallSiege` excludes the initiating monster from the field-partner gather; a monster can never be its own siege partner / double-count its ATK (V11-1). |
| Siege excursion is guard-only | `executeWallSiege` sets `siege` state (and logs "left the portal") ONLY when the initiator was `guarding`. A freshly unsealed `field` initiator stays `field`; never retracted to `guarding` by Step 0 (V11-1). |
| Permanents counted once in VP | `calcVP` skips `isPermanent` entries in the `S.played` loop; uid dedup cannot catch them (different uids per copy) (V11-2.1). |
| Portcullis creature immunity live | `monsterPickTarget` filters Portcullis from creature-type attackers' candidates (`m.isCreatureType`). Non-creature monsters may still target it (V11-2.2; bonded-set scope open. Section 10 item 61). |
| Farm delta = true output + debt ledger | Auspice-switch food delta diffs true farm output; `farmFoodDebt` ledger makes round trips net zero; reset in `startTurn` (V11-2.3/2.4). |
| Silent Stalker flies | `mn_stalker` data is `fly:true`; matches §13/§13A (bypasses Walls) (V11-2.5). |
| Stored-DEF resets use recomputeStoredDef | `useRepair`, the heal picker, and `dispelPossession` reset `currentDef` via `recomputeStoredDef(p)` (base + attachment `defBonus` + WallSets×2 for `isCreatureType||atk_siege>0`); never bare `p.def`, which strips the Wall Set +2 permanently (V11-2.6). Golem/Gargantuan/Fortress stay live via `effectivePermDef`. |

These are tracked in Section 10. Do not implement them unless the user explicitly asks. Do not implement partial versions that conflict with the correct spec.

- [x] Sacrificer: end-of-turn Legend send (Item 29) ✅
- Warlord: retroactive +1 Inf per Warrior, forthcoming Warriors too (Item 27)
- **Expediter + Attach mechanic**. Meurtrière, Fortifier, Retinue (Item 30). Design spec locked:
  - **Retinue** (Conjurer): attach to a creature → +2 DEF while attached. Effect 1 (+2 Inf) fires on play regardless of attach choice.
  - **Meurtrière** (Builder): attach to any Wall → +2 DEF while attached. Effect 1 fires on play.
  - **Fortifier** (Builder): attach to any building → +2 DEF while attached. Effect 1 fires on play.
  - **Expediter** (Builder, renamed from Expiditor): the next building purchased this turn goes straight into play. Expediter auto-attaches to that specific building, reducing its DEF by 2 while attached. Effect 1 fires on play.
  - **Attach timing:** Retinue/Meurtrière/Fortifier prompt the player to choose a valid target immediately when played. Optional; player may decline.
  - **On host disabled:** attached recruit → player's discard pile. Host stays in play (just disabled). Recruit can cycle back through deck and be played again. Effect 1 available again when replayed.
  - **Stacking:** multiple recruits can attach to the same permanent. DEF bonus is additive.
  - **VP:** attached recruits count VP from whatever zone they're in (attached = in Kingdom for VP purposes).
- Demented Architect: self-Legend + building subtype change (Item 31)
- Trophy lifecycle and recurring rewards (Bundle B); **Trophy recurring rewards fire in `startTurn()`, not in cleanup**
- Possession card system (Bundle B)
- Wall Set bonuses and bonding; ✅ **Implemented**; `checkSetCompletion()` fires mid-turn when second card is played. One-time triggers: Irrigated Field (+2 Inf), Trophy Room (draw 2), Scriptorium (draw 2), War Room (+1 ⚪ ATK) are automatic. **Wall Sets are player-prompted:** when a Wall-type permanent is played and unbonded walls exist, the player is shown a confirm (1 option) or numbered prompt (2+ options) and may choose to bond or decline. On bonding: both permanents get `bondedTo` pointing to each other's uid. +2 DEF fires on Creatures & Siege. Bond is permanent. Armory exchange updates to 3:1 automatically when 2 active Armories exist. `completionFiredFor` Set prevents re-firing of non-wall bonuses. `wallSetsCompleted` counter tracks stacking.
- VP scoreboard and end-game summary screen (Bundle C)
- Multiplayer state objects (Bundle D)

**Already implemented (do not re-defer):**
- Swordsman top-deck (Item 24) ✅
- Trainer Farmer-as-Warrior (Item 25) ✅
- Negotiator retroactive+forthcoming +1 Inf (Item 26) ✅
- Supplier Food→Draw mid-turn button (Item 28) ✅
- Exchange mechanic: Poison Room, Armory, Dojo ✅

---

## SECTION 13. SINGLE PLAYER MODES

**Status update (v2.0):** Mode 1 (The Seeping Portal) is **implemented and playtested** in `connivances_simulator_v10.html`. Its live implementation specification is in **Section 13A** below. The design notes that follow for Mode 1 are retained as historical/design context. Modes 2 (Time Crisis) and 3 (Survive the Famine) remain **designed but not built**.

---

### Mode 1. The Seeping Portal

**Core concept:** Monsters are not passive queue targets; they are active, staged at the portal entrance and slowly drift out based on individual unseal conditions. The portal itself becomes more accessible as more monsters leave its protection.

**Staging mechanic:**
- Each monster has a unique **unseal condition** that triggers it to begin attacking
- Monsters are corked at the portal entrance at game start
- As each unseals, it attacks the kingdom using standard combat rules (Walls first, then Back Row)
- More monsters outside = portal has less protection = easier for players to reach and attack

**Unseal condition examples:**
- Ghoul Shaman (originally first monster in physical game): *"Begins attacking when Famine Auspice becomes active for the first time. Must prioritise attacking Farm permanents when possible."*; note: this trigger needs updating for digital play as Famine can now be triggered easily; a revised trigger is needed
- Second monster example: *"Begins attacking when any player controls a Creature permanent"*
- Conditions should escalate in difficulty; early monsters have easy triggers, later ones have harder ones

**Win condition for monsters:** If any monster destroys every permanent in a player's Kingdom and that player has nothing left to defend, the portal wins. Thematically: the darkness consumed all contributions to the lands.

**Combat rules:** Only the **Walls card (bg3, `isTaunt`)** must be attacked first by non-flying monsters. Portcullis and Fortress do not block; monsters bypass them to reach the Back Row. Flying monsters (Nightmare) bypass the taunt Wall. Disabled permanents cannot be attacked again until repaired.

**Open design questions:**
- What are the revised unseal conditions for all 9 monsters?
- Does the portal become directly attackable once all monsters have left it, or is there a threshold (e.g. 5 of 9 unsealed)?
- In multiplayer: do monsters target the player with the most VP? Most permanents? The active player?

---

### Mode 2. Time Crisis

**Core concept:** A darkness track consumes the playable board turn by turn. Players must defeat the portal by turn 16 or lose. Monsters defend the portal rather than attacking the kingdom.

**Shadow track:**
- Each turn, one card is permanently removed from a market (starting cheapest/weakest)
- Suggested order: Recruits first (turns 1–6), then Buildings (turns 7–11), then Conjurations (turns 12–15)
- By turn 16: if the portal stands, all markets are consumed and darkness wins

**Monster role:** Monsters position defensively around the portal. Players must fight through them to reach it. Rather than attacking player kingdoms, monsters reduce the ATK pool available to attack the portal each turn (they absorb some damage as shields).

**Urgency:** The disappearing market creates a natural deadline; players who wait to build their engine find themselves with nothing left to buy. Aggressive play rewarded. The portal's VP still counts at game end if defeated before turn 16.

**Multiplayer note:** In multiplayer Time Crisis, players may compete for who delivers the killing blow to the portal (VP reward) while cooperating to clear monster shields. Creates a tense free-rider problem.

---

### Mode 3. Survive the Famine

**Core concept:** Auspice is locked to Famine at the start of every turn. A gloomy, scarcity-focused mod that can layer onto any other game mode.

**Mechanical effects:**
- Farms always produce **0 Food** (output completely zeroed); food is permanently absent from permanents
- Irrigator and Reaper become high-value cards
- Draw-generating Conjurations (Familiar, Spell Book, Amelioration) become primary food alternatives via Supplier
- Players who invested heavily in Farms are most vulnerable
- Famine-synergy cards (Nether Beast, Undead Rising, Dark Magic) gain elevated value

**Tone:** Deliberately punishing and gloomy. Intended to feel like survival under pressure rather than kingdom-building prosperity.

**As a mod:** Can be layered onto Mode 1 (Seeping Portal under permanent Famine; very dark) or Mode 2 (Time Crisis + Famine = racing against both the clock and starvation). Also works as a standalone challenge mode.

**Open design question:** Should players be able to break out of Famine by playing certain cards (e.g. Augury Initiate), or is the lock absolute? Absolute lock is harsher and more thematic; breakable lock creates interesting card prioritisation.

---

### Multiplayer Design Notes

**Standard multiplayer format (2–5 players):**
- Victory point race; not a kill-the-portal-first format
- All players fighting the same monster queue cooperatively, but competing for VP
- Players CAN attack each other's kingdoms (Possessions, direct ATK on permanents)
- Thematic framing: who contributed most to the community (farms, buildings, warriors hired); not who killed the most

**Three emergent player archetypes:**
1. **The Contributor**; ignores combat, builds VP through farms, buildings, recruits
2. **The Warrior**; races to kill monsters and claim Trophy VP before others
3. **The Saboteur**; attacks other players' kingdoms to slow their VP accumulation

**Monster targeting in multiplayer (open question):**
- Current single-player rules have monsters target the active player
- For multiplayer, leading candidates:
  - **Highest VP target:** monsters attack the most prosperous kingdom; creates natural catch-up mechanic and raises the cost of being in the lead
  - **Most permanents target:** monsters attack the most built-up kingdom; punishes turtling
  - **Active player target:** simplest, but removes cooperative tension
- Recommendation: **Highest VP target**; most thematically consistent with the "darkness comes for the most prosperous" framing, and creates the most interesting strategic tension in a VP race

**Mode 1 multiplayer tension:** Famine-heavy players may accidentally unseal the Ghoul early, creating a shared threat. Natural alliance pressure (coordinate to handle monsters) that the VP race then betrays. The common enemy creates cooperation that the win condition punishes; this is the most interesting design tension in the game.

---

### Single Player Win & Loss Conditions

**Player Win:** Defeat The Portal. Count all VP; highest possible score.

**Player Loss (basic single player. The Seeping Portal):**
If any monster reaches your Kingdom and destroys your **last active permanent**, you lose. The darkness has consumed all contributions to the lands.

- Secondary loss state: if the player has no permanents, no cards in hand, no cards in deck or discard, and cannot rebuild; functionally lost even if no formal trigger (edge case, likely Time Crisis scope)
- Caravans destroyed by monsters count as "permanent destroyed" for loss checking purposes

---

### Monster Unseal Conditions (V10. The Seeping Portal)

All 9 monsters (excluding The Portal) have individual unseal conditions. Once unsealed, a monster begins attacking the Kingdom each turn using standard combat rules. Monsters respect Wall Row; non-flying monsters must attack Walls first. Flying monsters (Nightmare) bypass Walls entirely.

**Targeting priority for all unsealed monsters:**
1. **Caravans**; highest priority, always. One-turn window, high reward, easy kill.
2. **Lowest current DEF Wall**; methodical breaching. Focus fire cracks a Wall faster than spreading damage.
3. **Monster-specific priority** (see below)
4. **Highest VP permanent** if no other preference
5. **Random** if all else equal

**Wall vulnerability design:** Monsters focus fire on the lowest DEF Wall. Two Walls means one gets cracked faster. Three Walls is genuinely safer; monster picks one and the other two remain intact. Players who double up on Walls create a vulnerability; players who triple up earn real protection.

---

**Unseal conditions by monster (in suggested appearance order):**

| Monster | Unseal Condition | Special Targeting | Notes |
|---|---|---|---|
| **Ghoul Shaman** | Famine Auspice becomes active for the first time | Prioritises Farm permanents | Always first in queue. Famine is a player choice; genuine risk/reward tension around Famine mechanics |
| **Fiend** | Start of Turn 3, regardless of board state | Standard priority order | The countdown monster; always coming, everyone knows it. Forces Wall by turn 3 |
| **Silent Stalker** | Any card is sent to Legend for the first time | Standard priority order | Drawn to sacrifice. First Legend card (even King's Note) unseals it. Flying; bypasses Walls |
| **Minotaur** | Player has 4 or more permanents in Kingdom | Prioritises highest DEF permanent | Building your engine wakes the Minotaur. Targets what it can't break through as a challenge |
| **Nightmare** | Any other monster has been defeated | Standard priority order | Smells blood. Defeating a monster wakes the Nightmare. Flying; bypasses Walls |
| **Gargantuan** | Any Wall enters the Kingdom | Prioritises lowest DEF Wall; always | Walls are a provocation. Two attacks on the same Wall can disable it and expose the back row |
| **Dank Beast** | Player defeats their first portal monster | Standard priority order | Guards the remaining queue. Pack reacts to losing one of their own |
| **Dragon** | Player's Legend zone reaches 3 or more cards | Standard priority order | Hoards power, drawn to those accumulating it. Late-game threat for Legend-heavy strategies |
| **Noxious Beast** | Player has purchased from the Conjuration market twice | Standard priority order | Creature realm stirs when its own are being claimed. Punishes Conjurer-heavy strategies |

**The Portal:** Becomes directly attackable once **zero monsters remain in the `guarding` state** (all dead, in field, or on siege). *(Implemented in V10; supersedes the earlier "3 of 9" proposal. See Section 13A.)*

---

### V10 Implementation Sequence (Recommended)

1. **Basic single player (The Seeping Portal)**; implement unseal conditions, monster attack AI, targeting priority, win/loss conditions. No Time Crisis track, no Famine lock yet.
2. **The Creeping Doom**; polish and balance The Seeping Portal. Add monster ATK values firing against Kingdom permanents. Tune unseal trigger difficulty.
3. **Time Crisis**; add shadow/darkness track consuming market slots. Turn 16 deadline.
4. **Survive the Famine**. Famine lock mod, layerable on top of any mode.
5. **Multiplayer**; multi-state, targeting rules, PvP permanent damage.

---

*Section 13 design notes last updated June 2026. Mode 1 is now implemented; see Section 13A for the authoritative live spec.*

---

## SECTION 13A. THE SEEPING PORTAL (IMPLEMENTED. V10)

**This is the authoritative specification for the single-player mode as built in V10 and carried forward into `connivances_simulator_v11.html` (current build).** Where these rules differ from the Section 13 design notes above, this section wins. ⚠️ **Ruling 2 (v2.2 changelog) will change the blocked-field-monster path** (market-slot attacks, retreat largely removed) once its open items (Section 10, items 53–57) are resolved; until then, the behavior below remains live.

### Queue Composition
- Single-player queue = **5 entries:** Ghoul Shaman (always position 1) + 3 random non-Ghoul monsters + The Portal (always last).
- Ghoul Shaman is always selected and always first. The 3 middle monsters are drawn randomly from the non-Ghoul pool.
- `monstersUnsealed` tracks which monsters have fired their unseal condition. Once a monster is in this set, its condition never re-evaluates.

### Monster State Machine
Every monster (except The Portal) is in exactly one state (`S` field: `guarding | field | siege | dead`):

| State | Meaning |
|---|---|
| **guarding** | At the portal, blocking access. Does not attack. Covers both never-unsealed monsters and unsealed monsters with no valid target. |
| **field** | Actively attacking the Kingdom each monster turn. No longer blocks the portal. |
| **siege** | A one-turn excursion: a guarding monster has joined a Wall Siege. Attackable while out. Returns to `guarding` at the start of the next monster turn. Does not consume/record the unseal condition (see 13B). |
| **dead** | Defeated. Removed from portal protection permanently. |

> **Note:** The implemented simulator uses `guarding` as the resting state (there is no separate "corked" state). A monster that has never unsealed and one that has unsealed but has no target are both `guarding`; the difference is tracked by membership in `monstersUnsealed`.

### Monster Turn Sequence
A **monster turn** fires between player turns (at `endTurn`, before `startTurn`):

- **Step 0. Siege reset:** All `siege` monsters return to `guarding` (their one-turn excursion ends).
- **Step 1. Field attacks:** Each `field` monster, in queue order, picks a target and attacks; or **retreats to `guarding`** if no valid target exists. *(Ruling 2 direction: retreat is expected to largely disappear; blocked field monsters will attack market slots instead. Pending items 53–57.)*
- **Step 2. Position-1 guard check:** The first living `guarding` monster in queue order is evaluated. **Only ONE monster may leave the portal per monster turn.**
  - If it is **already unsealed** (in `monstersUnsealed`): it checks for a valid target. Target found → re-enters `field` and attacks immediately. None → stays `guarding`. Unseal conditions never re-trigger; re-entry is target-driven.
  - If it has **never unsealed**: it checks its unseal condition. Met → permanently unseals (recorded in `monstersUnsealed`), enters `field`, attacks immediately if a valid target exists. If unsealed but blocked, it may join a **Wall Siege** with the existing field monsters (see 13B); in that case it **remains in `field` state** (it is permanently unsealed; only a `guarding` initiator takes the one-turn `siege` excursion. V11-1).

Monsters attack the **same turn they unseal**.

### Unseal Conditions
- Each monster has an individual unseal condition (full table in Section 13, "Monster Unseal Conditions").
- Once fired, a condition **never re-triggers**. A monster that retreats stays unsealed permanently.
- A retreated monster may **re-enter the field** on a later monster turn if valid targets exist.

### Targeting Priority (all Field monsters)
1. **Taunt-Wall gate**; only the Walls card (bg3, `isTaunt`) blocks. A non-flying monster that cannot beat a standing taunt Wall is stopped (Portcullis/Fortress do not block).
2. **Caravans**; highest priority once past the gate. One-turn window, high reward, easy kill.
3. **Monster-specific priority**. Ghoul → Farms (subtype); Minotaur → highest-DEF permanent; Gargantuan → Walls; Noxious Beast → Conjurations; fliers (Silent Stalker, Nightmare) bypass Walls.
4. **Highest-VP permanent** if no other preference.
5. **Random** if all else equal.

**Only the taunt Walls card (bg3) must be broken first by non-flying monsters.** Portcullis and Fortress do not block. **Portcullis is immune to creature-type monsters** (Fiend, Nightmare cannot target it. V11-2.2; bonded-set scope open, Section 10 item 61). Flying monsters (Silent Stalker, Nightmare) bypass the taunt Wall entirely. **Trophy permanents are never valid monster attack targets**; they live in a dedicated Trophy zone column and are filtered out of `monsterPickTarget` (see 12A.13A). Monsters **Disable** permanents (ATK ≥ current DEF → turned sideways, stays in play, repair/heal to restore); never destroyed outright, except Caravans (Section 8C). Disabled permanents cannot be attacked again until repaired.

### Kingdom Layout (V10)
The Kingdom renders as a **three-column layout**:

```
┌─────────────────────────┐ ┌──────────────────┐
│ WALL ROW                │ │ 🏆 TROPHIES      │
│ (attacked first)        │ │                  │
├─────────────────────────┤ │ ; not targeted  │
│ BUILDINGS &              │ │    by monsters; │
│ CONJURATIONS            │ │                  │
└─────────────────────────┘ └──────────────────┘
        kingdom-main              trophy-zone
```

The left column (`kingdom-main`) stacks the Wall Row above Buildings & Conjurations. The right column (`trophy-zone`, gold border) spans both rows and holds Trophy permanents, which monsters cannot target.

### Portal Exposure
- The Portal becomes **directly attackable only when zero monsters are in `guarding`**; every monster must be `dead`, in the `field`, or on `siege`.
- Portal attack reads the portal's own HP directly (never via a cached `monsterIdx`; fixed stale-index bugs).
- This replaced the earlier open "threshold of 3 of 9" proposal from v1.9.

### Win / Loss
- **Win:** Defeat The Portal. Count all VP.
- **Loss:** **All permanents destroyed AND hand + deck + discard are empty.** ⚠️ **Currently unreachable**; monsters Disable (never destroy) permanents and the deck cycles forever, so the Portal cannot actually win. This is a **KEY open decision blocking Mode 1 completion** (Section 10, item 23). The DEFEAT overlay (§13A.9) is wired but near-unreachable until that decision lands.

### Player Targeting (what the player may attack)
- Any `guarding` monster directly (Option A), any `field` monster, any `siege` monster, and the Portal once exposed.
- Monster kills go to the player's Discard. Trophy monsters are playable later as Trophy permanents (Section 5A).

### 13A.9. Late-Session Implemented Mechanics (final V10 build)

These landed after the mid-session snapshot that produced v2.0 and are all live in `connivances_simulator_v10.html`:

1. **All browser dialogs eliminated.** Browser `prompt()` is silently blocked in the artifact iframe; six interactions were failing invisibly and now use a generic `showListPicker()` overlay: **Dragon** trophy reward (discard picker; Skip refunds the once-per-turn use); **Exorcist / Cleric / Enforcer** heals (shared `showHealPicker()`; these had been silently failing all session); **Conjure Master** market-Conjurer swap; and **Undead Rising** end-of-turn disposition (`endTurn()` is now a wrapper running a MANDATORY sequential per-card picker; keep in hand / top of deck / Legend, "1 of N"; before `endTurnCore()`; Legend sends increment `legendSentEver`).

2. **Repair is buildings-only.** `useRepair` rejects creatures; explicit 🔨 Repair buttons appear on eligible disabled non-creature cards. Disabled creatures' status reads "heal required (Cleric/Exorcist/Enforcer)"; heals are the creature restore path.

3. **Mid-turn income restore.** `grantMidTurnIncome()` (mirrors the Expediter pattern): healing or repairing a permanent mid-turn immediately restores the per-turn ATK/Inf/Food that `startTurn` skipped. Food is Auspice-aware via `farmFoodValue()`. **Draw passives (Familiar) are intentionally NOT re-fired**; open ruling (Section 10, item 25).

4. **Granary stored-food chip.** Green chip shows "🌾 N Food stored" between turns and "🌾 +N Food in pool" during the release turn (`granaryReleasedThisTurn`). Pool math unchanged; stored food merges into the pool at turn start and is inherently spent first.

5. **Supplier convert on its card.** The global actions-bar button was removed; the Supplier card in Played This Turn carries "🌾 Convert 1 Food → Draw (N left)" (same pattern as Dojo exchange / Possession dispel). Multiple Suppliers drive the same non-stacking turn-flag (Section 10, item 26).

6. **Siege monsters attackable.** `attackFieldMonster()` accepts state `siege` as well as `field`; the render showed the Attack button but the guard previously rejected clicks. Matches the locked Wall Siege rule that siege monsters are exposed during their one-turn excursion.

7. **Dark Magic famine flag.** Dark Magic (j5) previously forced `S.auspice=3` directly, bypassing `setAuspice()`, so `famineEverActive` never set and the Ghoul unseal fired one turn late. Fixed. Dark Magic sets `famineEverActive=true`. All `S.auspice` assignment sites audited: only `setAuspice` and Dark Magic exist, both now correct.

8. **Portal defeat presentation + endgame overlays.** A defeated Portal renders as a gold "🏆 THE PORTAL IS SEALED" marker (live card / EXPOSED banner suppressed). A game-end overlay covers both outcomes; 🏆 VICTORY / ☠ DEFEAT; showing final VP via `calcVP()` with View Board / New Game buttons. Flags: `portalDefeated`, `gameOver`.

---

## SECTION 13B. WALL SIEGE MECHANIC (IMPLEMENTED. V10)

✅ **Status: fully implemented in `connivances_simulator_v10.html`.** (v2.0 incorrectly marked this deferred; corrected in v2.1.) `checkWallSiege()` and `executeWallSiege()` are live.

**Problem it solves; the lone-monster softlock:** A single Field monster whose ATK is lower than a taunt Wall's DEF can never break that Wall alone. Wall Siege lets a guard temporarily reinforce the field so a stonewalled attack can break through.

**Trigger conditions (all must hold):**
- The **position-1 guard** (first living `guarding` monster in queue order) cannot solo any taunt Wall on its own, AND
- The guard's ATK **combined with the non-flying field monsters'** ATK is **≥ some taunt Wall's DEF**, AND
- There are **≥2 DISTINCT monster participants** in the combined siege; the initiating monster is never counted as its own partner (V11-1 fix: a freshly unsealing monster, already flipped to `field`, was double-counting its own ATK to siege alone).

**Behavior:**
- A **`guarding`** initiator enters the **`siege`** state; a one-turn excursion out of the portal. It is **attackable by the player** while on siege (see `attackFieldMonster`, which accepts both `field` and `siege`). A **freshly unsealed initiator** (already in `field` state when the siege fires) **stays `field`**; it is permanently unsealed and must not be returned to `guarding` by Step 0 (V11-1).
- The guard **returns to `guarding`** at the start of the next monster turn (Step 0 of the monster turn sequence, Section 13A).
- The siege **does NOT consume or record the unseal condition**; it is **repeatable** every turn the trigger conditions hold.
- **Only taunt Walls (bg3) are siege targets.** Portcullis and Fortress are never siege targets since they don't block.
- **Portcullis interaction (preserved in logic):** creature (🟡) ATK is excluded from the combined siege total against a Portcullis. This is moot now that only taunt Walls are siege targets, but the guard is retained in code.

**Open (design meeting):** the lone-monster-cannot-solo-a-wall case still has **no escape valve** when Wall Siege's ≥2-participant condition isn't met; a single stonewalled monster stays stonewalled. This is intended for now; revisit after playtesting. Tracked in Section 10 (item 17).

---

## SECTION 14. FUTURE CARD & MECHANIC IDEAS

Design notes captured during development. Not scoped to any specific version yet.

### Market Refresh Card / Spell
**Concept:** A card or spell that allows a player to reshuffle one entire market section (Recruits, Buildings, or Conjurations) and deal a fresh set of cards from that deck. The current market slots are replaced with new draws from the deck, and all removed cards return to the bottom of that market's deck.

**Design considerations:**
- Could be a Spell in the Conjuration market (cost TBD)
- Could be a Factionless recruit; a "Merchant" or "Envoy" type card
- Player chooses which market to refresh; adds strategic depth (refresh Recruits to chase a Warrior, refresh Conjurations to clear a Possession)
- Should the current market cards shuffle back into the deck or be discarded permanently? Shuffling back preserves card availability; discarding permanently is more aggressive
- In multiplayer, refreshing a market your opponent was relying on is a viable sabotage move
- Could interact with Conjure Master (c9) which already replaces individual Conjurers; this would be the full-market version

---

### Faction Unlock Campaign (Stub; logged during V10, not scoped)

**Concept:** A progression/campaign mode where guilds (Warriors, Augury Mages, Builders, Conjurers, Farmers) are not all available at the start. The player unlocks factions over the course of a campaign; by completing objectives, winning matches, or hitting milestones; gradually opening up the full card pool.

**Open considerations (nothing decided):**
- What is the starting faction set? (e.g. Farmers + one combat guild?)
- Are unlocks permanent across the campaign, or per-run?
- Does this pair with the single-player modes (Seeping Portal as the campaign's match format) or stand alone?
- Could tie into a meta-progression layer above individual games.

**Status:** Idea only, logged to `journal.txt` during the V10 session. Not scoped to any version. Revisit after single-player modes 2 and 3 are built.

---

### Godot Migration Plan (logged during V10; deferred until simulator complete)

**Engine choice:** Godot, recommended over UE5 for this genre. Proof point: Slay the Spire 2 shipped on Godot (3M+ first week, 574K peak concurrent).

**Three-phase plan:**
1. **Phase 1. Extract the rules engine** from the simulator (the pure game logic, separated from the HTML/DOM presentation).
2. **Phase 2. Port to GDScript** with an xlsx → Godot resource pipeline and **parity tests** that check the Godot engine's output against the simulator (the simulator becomes the reference spec).
3. **Phase 3. Presentation layer:** animations, audio, tutorial, Steam integration.

**Approach:** A Claude Code multi-agent team. QA (Section 12A as executable tests), game designer, engineer, UI/UX; with a shared Design Tokens file as the contract. Claude Code can run Godot headless for automated testing; Bryan remains "the eyes" via the screenshot-driven loop proven in simulator development.

**Guiding principle:** The cleaner V10/the simulator lands; every rule locked in this master doc, every ambiguity resolved through Section 10; the cheaper the port. The simulator is not throwaway; it is the specification the Godot version is tested against.

---

### Option C. Glow/Aura Buff Visualization (stored concept)

A consumer-facing polish pass on the buff/debuff chip system (Section V10-CHIPS): replace or augment the ▲/▼ chips with a glow/aura "anime vibe" around buffed cards. Color palette for multi-buff scenarios is TBD. Stored for the presentation-layer phase, not the rules-verification simulator.

---

## SECTION 15. NEXT-SESSION KICKOFF PROMPT (V11 CONTINUATION)

*Use this prompt verbatim when starting (or restarting) a Connivances V11 development chat.*

---

**PASTE THIS INTO THE NEW CHAT:**

You are continuing development of **Connivances**, a competitive deck-building card game by Bryan. This is the **V11 session**. V10 is locked, frozen, and archived.

**Before writing any code, you MUST:**
1. Read `CONNIVANCES_Project_Master_Instructions_v2_2.md` in full; the single source of truth. It incorporates the full V10 build, Bryan's three V11 rulings (v2.2 changelog), and the V11-1/V11-2 verified bug fixes.
2. Read `connivances_simulator_v11.html`; the current build. Do NOT rewrite it from scratch. It already contains: the version bump, the Wall Siege self-participation fix (V11-1), and the six lockdown fixes (V11-2.1–2.6).
3. Read `Connivances_Tracks_v3.xlsx`; the canonical card index (90 cards).
4. If present, read `CONNIVANCES_V11_Session_Changelog.md`; the running session record; it and this doc must agree.

**Bryan's rulings (LOCKED; full text in the v2.2 changelog):**
- **R1. Cleric choice economy** (resolves item 22): N Clerics = N choice-uses; each use = heal one creature OR +2 possession-ATK. ⏳ Not implemented; UX open (item 58).
- **R2. Blocked field monsters attack Recruit market slots** (permanent slot destruction; never Possessions). ⛔ Blocked on items 53–57.
- **R3. Familiar draws on mid-turn heal** (resolves item 25). ⏳ Not implemented.

**Open items blocking implementation (Section 10):** 53 (Monster Ability system), 54 (cut-off "3+" tier), 55 (recruit-slot destruction details; design together with Time Crisis), 56 (retreat reconciliation), 57 (field turn order), 58 (R1 UX), plus balance items 59 (unseal-rush) and 61 (Portcullis bonded-set immunity scope), and the loss condition (item 23, now interacting with R2's market strangulation).

**V11 scope order:** rulings logged → resolve blockers with Bryan → implement R1, R3, then R2 → Time Crisis → Survive the Famine → Wall Siege playtest refinements → polish bugs.

**Critical constraints:**
- Do NOT modify any locked mechanic without explicit instruction. V10 behavior per this doc is locked except where Bryan's rulings explicitly change it
- Do NOT reinvent state management; extend `S` with new fields, never restructure it
- Read Section 12A (Fidelity Contract) and its 13 / 13A / 13B Must-Not-Regress tables; **including the eight V11 rows** (distinct siege participants; guard-only siege excursion; VP `isPermanent` skip; live Portcullis immunity; true-output farm delta + `farmFoodDebt` ledger; Stalker `fly:true`; `recomputeStoredDef` at all stored-DEF resets)
- **No browser `prompt()`/`confirm()`/`alert()` anywhere**; all choices via the in-page overlays (`showListPicker` / `showAttachPicker` / `showHealPicker` / `showWallBondPicker`)
- The master doc is authoritative; if code contradicts it, the doc wins unless Bryan says otherwise
- Document-first: log design decisions to the changelog before implementing; analysis before rulings; Bryan approves before code
- Surgical, additive changes only; `node --check` the extracted script after every edit; ship to outputs with `present_files` after every change
- Bug workflow: Bryan reports via screenshots + event log excerpts; diagnose root cause in code before editing; state the root cause when shipping
- Canonical spelling: Siegeman, Expediter (`isSiegeman`, `siegemanPlayedThisTurn` variable names preserved as-is)

**First task:** Confirm the v11 simulator loads cleanly, then continue resolving the R2 blockers (items 53–56 first) with Bryan, or implement R1/R3 once item 58 is answered.

---

*Section 15 updated July 2026 for v2.2. V11 session continuation: three rulings logged, V11-1 and V11-2 fixes shipped, blockers enumerated. Supersedes the v2.1 (V10 continuation) version.*
