# V11. Creeping Doom: Design Brief (designer-authored, 2026-07-20)

**Status:** design intent captured, NOT yet implemented, NOT yet in the Project MD.
Destined for the next Master Instructions MD once we're happy with it.

> Scope note: **Creeping Doom is the single-player PvE mode. The original game is PvP.**
> **Cards must stay identical and function in BOTH modes.** No card may be redesigned
> for PvE alone. Many individual cards were built to test ideas and carry stats (e.g.
> VP) that matter in PvP even when inert here.

---

## 1. Theme / flavor

Monsters are pouring out of the Portal to establish a **foothold in the human world**.
The player is the **lord of the land**, building buildings and hiring armies to halt the
incursion and **close the Portal**. Closing the Portal = player wins. The monsters must
stop the player's progression and ultimately **shut down the player's ability to be a
threat at all**.

## 2. Victory conditions

| Side | Wins by |
|---|---|
| **Player** | Destroying / closing the Portal |
| **Monsters** | **Closing all markets**; eliminating every selling position from the board: **6 Recruit + 3 Building + 3 Conjuration = 12 positions**, all removed from the game |

**Victory Points do not matter in Creeping Doom.** The player currently still plays
toward VP, which is meaningless in this mode. (A monsters-collect-VP variant was
considered and rejected as unthematic.) VP remains on cards for PvP.

## 3. How monsters achieve it

Monsters attack **open market positions** when they have **no player permanents to
attack**. This requires restructuring the monster turn order.

## 4. Definitions (designer-locked)

- **In the field**; the monster has moved out of portal defense and is **standing on
  top of** a player permanent or market position, denoting it has been attacked.
- **Portal defense area**; the staging ground from which monsters protect the Portal
  or attack the player.

## 5. Current monster turn order (as-is)

1. Begin Monster Turn
   a. Check for unsealed monsters. Sealed monsters cannot act.
2. Unsealed monsters check for a valid target among player permanents
   a. Valid = enabled state AND defense lower than the monster's attack value
   b. Priority order assigned by position in the Portal defense area. Ghoul Shaman is
      always #1 and prefers Farms; if no Farms, attacks other player items.
3. If a valid target appears, the monster leaves portal defense to attack it.
4. If no valid targets appear, the monster returns to its portal-defense position.
5. Monster turn ends.

## 6. NEW monster turn / behavior order (target design)

1. **Begin Monster Turn**
   a. **In order of monster position 1–4** (1 = Ghoul Shaman, 4 = last random monster),
      check whether the monster is sealed. Sealed monsters cannot act. **Once unsealed,
      a monster is never sealed again; monsters do not unseal twice.**
2. **Unsealed monsters check for a valid target among player permanents**
   a. Valid = enabled state AND defense lower than the monster's attack value.
   b. Priority order by position in the Portal defense area. Ghoul Shaman is always #1
      with a proclivity for Farms; if none, other player items. Other monsters occupy
      positions 2, 3, or 4.
   c. If a valid target appears, the monster leaves "portal defense" (or its current
      "in the field" position) to attack **a player permanent OR a market position**.
   d. If no valid targets appear, the monster returns to portal defense; *though this
      should only tend to happen if the market cannot be attacked due to player
      intervention such as Walls (open question).*
3. **Check unsealed monster passive abilities and act on them.** Passives are not yet
   implemented. **For now add exactly one:** Ghoul Shaman passive; **change the Auspice
   to Famine**. Fires from anywhere (in the field or in portal defense).
4. *(Observation, not confirmed)* possible rules to let **more monsters come through the
   Portal** over time.
5. Monster turn ends.

## 7. Rule change. Ghoul Shaman unseal

**New unseal condition:** *Unseals after a total of **10 Food has been consumed in the
realm**.*
(Replaces the current `famineEverActive` trigger.)

## 8. Designer-flagged concerns / open threads

- **Possessions** temporarily make market positions unpurchasable until destroyed -
  interaction with market-position destruction needs definition.
- **Walls currently block monsters** from reaching targets; if that extends to market
  positions it may neutralize the monster win condition. Needs watching.
- The **unseal conditions merit a review** generally (later).
- New element to mind: **any unsealed portal protector can enter the field.**
- **All monsters will eventually get passive abilities** checked during monster turns
  (future work).

---

## 9. Open questions raised in review (NOT designer-answered yet)

These are analysis questions for the designer, not decisions:

1. **Portal-exposure paradox.** `isPortalExposed()` currently returns true when **no
   monster is `guarding`**. Under the new rules monsters leave portal defense to attack
   markets; which would leave the Portal exposed and let the player simply kill it.
   The monsters' offense currently undermines their own defense. Does Portal exposure
   need to require monsters **dead** rather than **absent**?
2. **Do Walls protect the market?** If yes, one unbeatable Wall re-creates the current
   "zero pressure forever" exploit. Thematically the market sits outside the keep.
3. **Is market destruction permanent or occupancy-based?** "Eliminating the selling
   position… removed from the game" reads permanent, but "standing on top of" suggests
   the monster *occupies* the slot. Does killing the occupying monster reopen it?
   (Occupancy would give the player counterplay; permanence is a purer ratchet.)
4. **Destroyed vs. purchased slots.** A purchased slot refills from its market deck.
   A destroyed slot must **not** refill. These need to be distinct states.
5. **What does "Food consumed" mean?** Food *spent playing cards* only, or does it
   include unspent food lost at end of turn, Exchange costs (Poison Room 3 Food → ATK),
   and Granary storage? Materially changes Ghoul's timing (~turn 2–3 if spend-only).
6. **Ghoul's Famine passive cadence.** Every monster turn, or only once/on some
   condition? If every turn, the player is locked in permanent Famine unless they hold
   Auspice-change cards; a tug-of-war that could be oppressive.
7. **Player counterplay to market loss.** Is there any way to reopen a market position?
   If not, the ratchet is one-way (thematic, but check it doesn't feel hopeless).
8. **PvP compatibility of market destruction.** Markets are shared in PvP; does any of
   this mechanic surface there, or is it strictly a monster (PvE) ability?
