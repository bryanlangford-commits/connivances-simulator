# Parked idea: The Sundering Stone's hidden second phase ("you want the Minotaur to win")

**Status:** IDEA, parked for a future conversation. Not built. Captured 2026-09-15.
Owner: Bryan. Builds on the current seal-stone rework of `warrior_stone` (Minotaur batters a
ward-stone that binds an oni; currently seal-integrity-to-0 = a hard DEFEAT).

## The twist
The ward-stones contain a magic element that **only the Minotaur can break/release** (the
players do not know this). On the surface the tutorial reads as "PROTECT the seal, kill the
Minotaur before the stone shatters, or you lose." So a diligent player races to fell him.

But secretly, **letting the Minotaur shatter the stone is the *better* line** for the player
who dares (or who fails to protect it). When the stone breaks, instead of a plain defeat it
**starts a NEW boss phase** — finish the Minotaur (or the thing the broken seal loosed) under
different rules — with **alternative / richer rewards** than the "clean" kill.

The hook: *"You want the Minotaur to win, but you don't know you want the Minotaur to win."*
A hidden risk/reward secret that rewards curiosity, replay, and reading the flavor closely.

## Design questions to resolve when building
- **Loss becomes a secret second chance, not a defeat.** Today seal=0 calls
  `sealShattered()` -> `showGameEndOverlay(false)`. The hidden version replaces that with a
  phase-2 boss setup (reuse the "Risen"/Blight finale pattern: a phase flag on `S.ss`).
- **What is phase 2?** The freed oni (ties to the seal lore) as a second boss, OR an
  empowered Minotaur "gorged on the stone's magic." Alternative rewards = e.g. a unique card,
  extra unlocks, or a lore reveal about the Portal/summoning-stones.
- **How to hint without revealing.** A first-time player should still be able to win the
  "safe" way (kill the Minotaur, seal holds). The secret path is discovered by the bold or the
  observant (a subtle flavor tell, an achievement, replay). Do NOT telegraph it in the main
  objective text.
- **Balance:** the secret path should be *higher risk* (you deliberately let a doom clock run
  out) for *higher reward*, never strictly better, or it stops being a secret and becomes the
  obvious play.
- **Tie-in:** the oni/veil-magic connects to the Creeping Doom / Portal lore Bryan set for the
  Warrior tutorial ("first sign the region is not safe"). Phase 2 could foreshadow the
  campaign's real threat.

## Why it's on ice
The current priority is the Warrior swarm rework + Builder/Castle updates. This is a
polish/depth idea for after the core faction-identity pass lands and the seal-stone tutorial
has been playtested. Revisit when Bryan raises it.
