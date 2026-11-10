# Connivances — Connected Onboarding Arc (vision)

Owner: Design Lead. Narrative companion owned by `lore-keeper`; tutorial pressure
beats by `pve-pressure-designer`; the slow card-introduction / unlock schedule by
`tcg-designer`. **Status: captured vision, not a build spec.** This records Bryan's
intent (noted 2026-11-09) for threading the existing tutorials into one story. Nothing
here is CURRENT or authoritative rules; promote a section to its own spec and mark it
CURRENT in the handoff pack before building. Bryan owns canon; the agents draft.

The Godot client is the oracle. Each tutorial already exists as a mode
(`ward_stone` / Sundering Stone, `giving_tree` / The Giving Tree, `castle_siege` /
Storming the Castle, `treant_siege` / The Summoner's Plight). This doc is about the
**connective tissue between them**, not a rebuild of any one.

---

## The problem Bryan is solving

Today the flow is **menu → a tutorial that drops you in cold**. The Sundering Stone in
particular is "too stark": it opens on a combat puzzle with almost no orientation and no
story reason to care. The menu-to-game jump gives the player limited orientation and no
narrative spine connecting one tutorial to the next. The arc below removes that
starkness by making the four tutorials a single, slowly unfolding story that also paces
the introduction of card mechanics.

## The vision, in Bryan's points

1. **Add a story onboarding before the first tutorial.** The Sundering Stone should not
   be the player's first contact. Lead in with narrative so the Stone encounter has a
   reason and a frame. (The entry-story-card pattern already used for Storming the
   Castle is the right surface; see the briefing pop-out idea below.)

2. **Weave the Sundering Stone into the lore.** It is not just a combat dummy. It is a
   named thing in the world. See point 4's reveal: it is one of the **portal stones**.

3. **The Giving Tree is the kingdom's health, made symbolic.** The dying tree *represents
   the kingdom*. When the player finds it dying, that is the kingdom in peril. This is
   what pulls the **King** into the story: the king responds to the threat and begins
   sending out his **King's Notes**.
   - **3b. Slow introduction to cards; no King's Notes until after the Giving Tree.**
     The early tutorials introduce cards gradually. The King's Notes mechanic is **gated
     off until the Giving Tree is complete** — the king only starts issuing them once the
     kingdom's peril (the dying tree) is revealed. This paces how much of the card system
     the player has to hold at once.

4. **Give a reason to siege the castle in "Storming the Castle."** The siege needs a
   story motive, not just a target. The uprising being quelled is the hook.

   **Shared device for 3 and 4:** use **unlock cards**, or let the story introduce
   **additional King's forces (not the player's own deck)** sent in to quell uprisings.
   Those forces / that uprising later turn out to be tied to the **portal stones** —
   **and the Sundering Stone is one of them.** This is the reveal that pays off point 2.

5. **The portal-stone thread leads into learning conjurations in the final tutorial.**
   The Summoner's Plight (conjurer tutorial) is where the portal-stone mystery resolves
   into the player learning conjurations. The stones are the bridge from "quelling
   uprisings for the king" to "the portals are the real threat."

## The through-line

> Cold open on the kingdom → the Sundering Stone (framed, not stark) → the Giving Tree,
> whose sickness *is* the kingdom's sickness → the King is roused and starts issuing
> King's Notes → he lends forces to put down uprisings (Storming the Castle) → the
> uprisings trace back to the portal stones, the Sundering Stone among them → the final
> tutorial teaches conjurations as the player confronts what the portals really are.

Each tutorial becomes a chapter, the Sundering Stone pays off twice (opening frame, then
late reveal), and the card system is introduced on a schedule the story motivates rather
than dumped at the menu.

## What this touches (open questions to resolve before building)

- **"King's Notes" mechanic:** needs a concrete definition. Is it the recruit / market
  acquisition economy, a drafted-card drip, or a distinct resource? Whatever it maps to,
  the design requirement is that it stays **locked until the Giving Tree completes**.
- **"King's forces, not your own":** a second, story-owned mini-deck or a set of **unlock
  cards** granted for the siege, distinct from the player's constructed deck. Decide
  whether these are antagonist-driven allies or temporary additions to the player's hand.
- **Unlock-card schedule:** `tcg-designer` owns which cards appear in which chapter so the
  "slow introduction" is actually paced, not front-loaded.
- **Briefing surface:** a per-mode briefing pop-out (title + story + how-you-win +
  how-you-lose + current stage), auto-shown once on chapter entry and re-openable from a
  button by the objective banner. This is the delivery vehicle for point 1's story
  onboarding and unifies with the existing entry-story-card and primer steps. (Proposed
  2026-11-09; `on_turn_start()` hook work landed the same day is unrelated plumbing.)
- **Canon ownership:** the portal-stone reveal and the Sundering-Stone-as-portal-stone
  ruling are canon; `lore-keeper` drafts, Bryan rules.

## Cross-links

- `docs/design/ONBOARDING_COMBAT_TUTORIAL.md` — the Warrior / Sundering Stone tutorial as built.
- `docs/design/SUNDERING_STONE_HIDDEN_PHASE.md` — the Stone's hidden phase.
- `docs/design/GIVING_TREE_FINALE_SPEC.md` — the Giving Tree (Augury) tutorial.
- `docs/design/CONJURER_TUTORIAL_SPEC.md` — the Summoner's Plight (conjurations).
- `docs/design/narrative/first_betrayals.md` + `docs/design/WORLD_AND_LORE_REFERENCE.md` — world canon for the portal stones.
- `docs/design/MODE_AND_EXPANSION_IDEAS.md` — parked mode/expansion bank (sibling to this).
