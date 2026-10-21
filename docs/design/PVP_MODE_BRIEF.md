# PvP Mode: intent & design brief (planning, not yet built)

Bryan's stated intent for the next big undertaking (2026-09-21). NOTHING here is built yet; this is
the record we start from. PvP networking is the project's biggest, least-reversible lift, so we
validate the DESIGN before committing to production netcode.

## Bryan's vision
- **2-5 players, networked** (NOT couch co-op / hotseat). Likely friends on their own laptops.
- **All cards available** (full pool, not tutorial-trimmed).
- A **Victory-Point match** with a **shared threat: the Portal** (Creeping Doom).
- **End trigger:** the game ENDS when the Portal is CLOSED, regardless of whether all monsters are
  killed.
- **Winner = the most VP**, NOT the player who closed the Portal.
- **VP = "the King's respect":** earned by serving the kingdom, giving people jobs (Builders,
  Warriors), raising Morale buildings, building a forward defense, and so on. Multiple paths.

## Why this design is strong (and thematically perfect)
It is a semi-competitive race under a shared clock. The Portal (which, in canon, the King secretly
created as a false-flag common enemy) looms over rival lords who compete for the King's favor by
BUILDING and DEFENDING, not by slaying the most monsters. That is literally the King's story played
out at the table: the war-hardened houses who "wanted to build, have an identity, and become
something," competing to serve under a manufactured threat. The theme and the mechanic are the same
thing.

## Core economy loop (base game, confirmed by Bryan 2026-09-22)
This is how the game already works and it is the heart of the PvP match:
- **VP comes from OWNING cards.** So you want to buy more, but every purchase **bloats your deck** and
  dilutes your draws (engine + attack come up less often). Greedy VP-buying self-punishes.
- **Legend is the release valve.** Send a card to Legend: its VP still counts at game end, but it
  LEAVES your deck. You bank the points AND thin your engine. The skill is knowing WHAT to send and
  WHEN.
- **Any player can attack the Portal's monsters** (the Creeping Doom); fighting is shared
  pressure-relief, not a private win.
- **Two end triggers, both just END the game and tally VP:** (a) the Portal is CLOSED, or (b) the
  monsters RAZE all the market spaces (the doom overruns the map).
- **Winner = most VP** across deck + Legend at that moment.

## The core design tensions to solve
1. **Free-rider is already regulated (no patch needed).** Farming VP has a built-in cost (deck bloat),
   and Legend is the earned escape, so "why fight instead of farm" resolves itself: you cannot pure-farm
   without choking your own engine, and the doom clock (market-raze end) punishes ignoring the monsters.
   The remaining lever to tune is whether unchecked monsters should also directly cost VP / raze OWNED
   value, to keep defense meaningful in a multiplayer race.
2. **The Portal close as a player-controlled END TRIGGER (elegant, lean into it).** If a player can
   spend to close the Portal, then closing becomes a strategic "call the game" lever: the player
   AHEAD on VP wants to close NOW to lock in the lead; the player BEHIND wants it kept open to catch
   up. That single decision creates constant tension and reads the table. Strong, distinctive.
3. **Direct PvP vs parallel racing.** The card layer already has PvP hooks (Enforcer PVP, Siegeman).
   Decide how much DIRECT aggression (attack a rival's board) vs INDIRECT competition (market denial,
   racing VP). Direct conflict adds spice but risks kingmaking and pile-on-the-leader; use carefully.
4. **VP economy breadth.** Jobs (Builders/Warriors), Morale buildings, forward defense, completed
   Sets, monster Trophies. Broad enough that "serve the kingdom" has several viable paths.
5. **Player-count scaling (2-5).** Shared contested market (first-buy denies others) vs per-player
   markets; Portal/monster pressure scaling with headcount; turn order vs simultaneous phases.
6. **Hidden vs open info.** Hands hidden; VP and boards OPEN, so the "close the Portal now" decision
   can read who is ahead.

## Networking: how to actually do 2-5 players
Two SEPARATE problems: the netcode (how) and the game design (what). Solve the design first, cheaply.

- **Server-authoritative is mandatory** for a hidden-hand card game. The server holds the full state
  (all hands, decks, market, Portal) and sends each client only its own hand plus the public state;
  clients send ACTIONS, the server validates and broadcasts. You cannot trust clients (they would see
  hidden info and could make illegal moves). Peer-to-peer/WebRTC is a bad fit here.
- **The sim's architecture helps.** It is already `state S + pure rules + render()`. The rules engine
  can lift to a small server; render stays on each client. Non-trivial but feasible.
- **For "friends with laptops":** a small WebSocket server (Node) with ROOM CODES, run on one machine
  on the LAN; others connect to its IP. No internet or hosting needed. Good for local playtests and a
  crowdfunding demo table.
- **Strategic caveat (important):** production netcode in the HTML build is a large, largely THROWAWAY
  investment, because the target engine (Godot 4) has first-class multiplayer (high-level multiplayer
  API, ENet) and Steam networking via GodotSteam. RECOMMENDATION: build only a MINIMAL LAN prototype
  to validate that the 2-5 player VP-race is FUN, then build the real, shippable PvP in Godot after
  funding. Do not sink months into HTML netcode you will rebuild.

## Recommended sequencing
1. Lock the PvP DESIGN on paper / in single-player-ish tests (the tensions above).
2. Ship the two remaining single-player modes (they are cheap in the sim and strengthen the pitch).
3. Optional: a minimal LAN prototype to prove the multiplayer loop is fun.
4. Build production networked PvP in Godot, post-funding, as the marquee feature / stretch goal.

## Open questions for Bryan
- What exactly CLOSES the Portal (collective damage? a player action? a cost?), and who can trigger it?
- How much DIRECT player-vs-player attacking do you want vs parallel racing?
- Real-time turns, or structured turn order? Simultaneous economy phases?
- Is a minimal LAN prototype worth building now, or do we validate the design another way first?
