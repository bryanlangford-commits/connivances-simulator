# Connivances — Profiles, Inventory, Unlocks & Personalized Decks (vision)

Owner: Design Lead. Persistence/architecture notes flagged for the Godot client build;
card rarity/unlock grading owned by `tcg-designer`; the unlock *story* gating ties to
`ONBOARDING_ARC_VISION.md`. **Status: captured vision + challenge assessment, not a build
spec.** Records Bryan's intent (noted 2026-11-11). Nothing here is CURRENT; promote a
section to its own spec before building. Bryan rules; agents draft.

The Godot client is the oracle. This is a **meta-progression layer that sits ABOVE the
match engine** — it configures what cards/decks a player brings into `new_game`; it does
not branch the per-match rules. That keeps it aligned with "build general, not mode"
(see `connivances-build-general-not-mode`).

---

## What Bryan wants

1. **Profiles on the main menu.** A Profiles button; 2 or 3 unique profiles per player,
   each a separate play style and card collection.
2. **Persistence with a player inventory, per profile.** Each profile has its own saved
   inventory that outlives any single match.
3. **Inventory unlocks cards.** The inventory is the record of what a profile has opened
   up; playing earns unlocks.
4. **Every card is behind an unlock, and graded by rarity.** Limit all cards to an unlock
   gate and assign rarities (grading started in the card-catalog spreadsheet below).
5. **Personalized starting decks.** Once cards are unlocked, players build their own base
   starting deck from the cards allowed for base deck-building.
6. **Card-selection spreadsheet.** A sheet of every card so Bryan can pick which are
   allowed as base-deck-building cards. **Built:** `deliverables/Connivances_Card_Catalog_for_Unlocks.xlsx`
   (sheet "Player Cards": 88 candidates with Allowed?/Rarity/Unlock-tier/Notes columns;
   sheet "Reference": monsters/horsemen/auspices). Generated from the Godot `data/cards.json`.

## Challenges / assessment (Bryan asked: "tell me the challenges")

The persistence *mechanics* are easy in Godot (JSON files under `user://`). The hard parts
are architecture, migration, and a balance conflict, not storage.

- **Two-tier save, kept out of GameState.** There is already a per-match save/load
  (`save_load`, `resume_live_game`). Profiles add a SECOND, higher tier: persistent
  per-profile meta (inventory, unlocks, custom decks, settings) that outlives matches.
  This belongs in a new ProfileStore / MetaProgress autoload, **not** in GameState
  (which must stay presentation-free and per-match). At `new_game` time GameState only
  *reads* "which cards are unlocked / which deck is selected." Clean separation is the
  main design task. Low code risk, needs discipline.
- **Versioning & migration — the real ongoing cost.** A dev prototype's single-game save
  can break between builds; a **player's collection cannot** once real players exist.
  Every schema change must migrate, never wipe. Add a `version` field and a migration
  path from day one.
- **Card-id stability.** Inventory/unlocks key off card `id`s. Renaming or removing a card
  orphans saved collections. Id stability becomes a hard rule, plus a policy for retired
  cards (grandfather? convert? hide?).
- **Atomic writes.** Earned unlocks must be flushed reliably. We just saw NUL-byte
  corruption from an interrupted write (VS Code's product.json). Write-temp-then-rename so
  a crash never corrupts a profile.
- **Deck legality.** Custom decks must validate against unlocks + base-deck rules (size,
  allowed set, rarity caps). One shared legality checker used by both the builder UI and
  `new_game`. Handle decks that become illegal after a patch gracefully (flag, don't crash).
- **Tutorials vs. custom starting decks — a genuine conflict (see below).**
- **UI is the largest chunk.** Profiles screen, collection/inventory browser, deck builder,
  unlock/reward flow — more work than the persistence itself, and must hold the "LoR clean
  board" UX bar (`client-ux-and-platforms`).
- **Anticipate PvP identity.** The planned networked VP match (`pvp-intent`) will also need
  a profile identity. Cheap to design for now, expensive to retrofit — treat a profile as
  the player's identity across all modes, including future PvP.

## Conflicts with earlier statements

- **Tutorials script the opening hand.** The Giving Tree pulls the auspice-changer out of
  the opening hand and gifts specific tools; the warrior/builder tutorials seed fixed
  primers. A personalized *starting* deck would break scripted tutorials. **Resolution:**
  starting-deck customization applies to non-tutorial modes only; tutorials force their
  own fixed decks regardless of profile. Make this explicit in the deck/`new_game` path.
- **"King's Notes" already exist as a card.** `kn` = "King's Note" is the current basic
  influence starter ("+1 Influence"). The onboarding arc wants the King to issue King's
  Notes only *after* the Giving Tree. Gating `kn` therefore means gating the **basic
  economy**, so the pre-Giving-Tree tutorials must run on a reduced/guided economy without
  it. Strong, usable lever, but it is a real constraint to design around — not a drop-in.
- **No hard conflict with "build general, not mode."** This is a config layer above the
  engine; it reinforces that principle rather than fighting it.
- **Complementary with the onboarding arc.** The unlock/rarity system is the *mechanism* that
  powers the arc's "unlock cards" and card-pacing. See `ONBOARDING_ARC_VISION.md`.

## Cross-links

- `docs/design/ONBOARDING_ARC_VISION.md` — the story that gates unlocks (King's Notes after the Giving Tree).
- `deliverables/Connivances_Card_Catalog_for_Unlocks.xlsx` — the card-selection working sheet.
- `docs/design/FACTION_IDENTITIES.md` — faction fantasy, for rarity/archetype grading.
