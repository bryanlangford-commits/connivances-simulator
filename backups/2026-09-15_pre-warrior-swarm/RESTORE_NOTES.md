# Backup — 2026-09-15, pre Warrior-swarm / Builder-Morale rework

Known-good snapshot taken **before** the big faction-identity change (revive the Warrior
swarm, add the Builder "Morale" keyword, rework Siegeman, re-base the Sundering Stone pool).
Made because that rework touches card data and multiple modes.

## What this state includes (all working/verified at snapshot time)
- 6 modes: Sundering Stone (Warrior, default start), Storming the Castle (Builder),
  The Giving Tree + "Feed me" Blight finale (Augury), Clear the Haunted House / "The
  Summoner's Plight" (Conjurer), The Long Winter, Creeping Doom.
- Progression/unlock system (locked modes, win-screen "unlocked" rewards, resume-at-next).
- "How to Play" spotlight tour (bright pulsing button + first-visit auto-run).
- Lean tutorial pools + quest hooks on all 4 tutorials; farm/farmer halving in Warrior & Builder.
- Warlord siege-discount display fix (shared effectiveBuyCost helper).
- No em dashes anywhere.

## Files
- `connivances_simulator_v11_6_4.html` — the canonical build (source of truth for logic)
- `cards.json` — card data (source of truth); `cards.js` is generated from it
- `cards.js` — inlined copy for file:// loading (`window.CARDS_DATA=<cards.json>;`)
- `connivances_sim_v11_6_4_EMBEDDED.html` — the standalone playable (art + data inlined)

## To restore
Copy `connivances_simulator_v11_6_4.html`, `cards.json`, and `cards.js` back over
`simulator/`, then re-run the embedder (scratchpad `downscale_embed.ps1`) to regenerate
the EMBEDDED playable. Or just open the `..._EMBEDDED.html` here directly to play this exact state.
