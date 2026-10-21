# Connivances — Mode & Expansion Ideas (parked)

A bank of **future mode / expansion concepts** — earmarked so they aren't lost, **not** a build backlog and **not** authoritative rules. Nothing here is current; do not implement as rules until it's promoted to a spec and marked CURRENT in the handoff pack. Companion to the gotcha-focused `EVIL_IDEAS_BANK.md` and the netcode-focused `PVP_MODE_BRIEF.md`.

**Status key:** 💤 parked idea · ✍️ has a partial spec · 🚧 in progress · ✅ built.

---

## 1. Hero / Commander mode 💤
*(earmarked 2026-10-04; floated earlier too)*

**Hook (Bryan):** at game start a player picks **1 of 4–6 Heroes**, each with a **special ability** (planeswalker-like). Straightforward on the surface; the work is making it *Connivances-only* rather than a generic hero bolt-on.

**Connivances-specific angles to explore:**
- **Heroes = lore figures, powers = native systems.** Draw from the "First Betrayals" cast so each Hero bends a Connivances-native lever, not a generic "+1 draw":
  - **Fallah** (the Augur) — reads/changes the **Auspice**; e.g. once/turn shift the omen, or peek the next monster seal.
  - **Laere** (the Conjurer who summoned Austis) — a **summoning / possession-control** power (tame one wild-magic backlash per turn, or a signature summon).
  - **The King** — a **Portal / Legend** power (he opened the Portal; e.g. manipulate the end-trigger clock, or bank Legend at a discount — fits the "King's favor = VP" fantasy).
  - A **Builder lord** (Set bonuses / Remodel) and a **Warlord** (Muster scaling) round out the guilds.
- **A "command zone" + loyalty-like track.** The Hero sits always-available (Commander-style); its ability may be gated by a **loyalty/favor track that climbs on VP or Legend milestones**, so Heroes reward playing the core loop, not just raw power.
- **Guard against power creep in a VP race.** Heroes must not be flat stat boosts — tie them to *choices* (Auspice, Legend timing, possession risk) so they add texture, not just advantage. A Hero could also carry a small **downside/oath** (very on-brand for a betrayal game).

**Open questions:** persistent permanent vs once-per-turn activation vs loyalty costs; how Heroes interact with the VP end-tally; draft/ban or free pick; do Heroes have their own starter tweak.

---

## 2. Portal Hoppers (a.k.a. Portal Tossers) 💤
*(earmarked 2026-10-04)*

**Hook (Bryan):** a **PvP** mode where players **acquire Portals into their deck** and use them to **summon controllable monsters** to fight each other. **More portals = more fun** (escalating chaos).

**Why it's deeply on-theme:** the base game's Seeping Portal is a *shared, uncontrollable threat*. This mode **flips it into a weapon** — exactly the game's central secret (the King + the society *opened* portals as a tool). Here the players are the conspirators, each tearing open their own portals and loosing beasts at a rival. The manufactured catastrophe becomes the arena.

**Mechanical sketch (to flesh out later):**
- **Portals as cards:** buy/play a Portal (from a portal market, or a Portal keyword on cards) that opens a **monster slot** and lets you summon from the monster pool — but now as a **controllable unit** carrying its stats, aimed at the opponent.
- **Reuse the Conjurer Duel substrate.** The Duel already has 1v1, two castles, and **all-or-nothing disable combat** (attack ≥ DEF; disable not destroy; walls/fliers; heal/repair). Portal-summoned monsters would plug into that as the attacking units, so most of the combat layer already exists.
- **"More portals, more fun":** each open portal = another summon slot / faster monster cadence; the fantasy is the board filling with beasts. Consider a soft cap or a backlash so infinite portals self-punish (wild-magic risk — possessions — would be very on-brand: the more you hop, the more your own magic turns on you).
- **Rebalance warning:** the 10 monsters are statted as *bosses* for the solo game; as player units they'd need their own cost/power pass. Their hidden-unseal/typed mechanics could be repurposed (a monster you command still has a "temper").

**Open questions:** win condition (raze the rival keep, like the Duel? most VP? last conjurer standing?); do commanded monsters obey fully or carry a control/possession risk; how portals enter the deck and the economy around them; 1v1 first (Duel-derived) then scale to the 2–5 big-table PvP (`PVP_MODE_BRIEF.md`).

**Relationship to existing work:** this is a natural evolution of **Conjurer Duel → networked PvP**: Duel teaches the combat substrate; Portal Hoppers adds the portal economy + controllable monsters on top. Best built in Godot alongside real multiplayer.

---

## Previously floated (one-liners, keep so they're not lost)
- **Bankers + gold economy** — a gold/second-currency faction or layer. 💤
- **Storytellers** — a faction/mode concept (narrative-driven?). 💤
- **Angels & Demons** — a faction/content hook. 💤
- **"Free Lances"** — mercenary card idea (see `EVIL_IDEAS_BANK.md` seeds). 💤
