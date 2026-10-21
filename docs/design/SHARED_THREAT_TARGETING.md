# Shared Creeping-Doom Targeting (2+ players)

**Status:** implementation spec for the Godot engineer. Extends the single-Kingdom
antagonist (`Connivances_Godot/connivances/scripts/antagonists/portal_guardians.gd`) to
the player-indexed engine used by the AI mirror match, and forward to 3-5 player PvP.
**Author:** pve-pressure-designer, 2026-10-20.
**Reads with:** `AI_MIRROR_MATCH_BRIEF.md` (§2 shared threat, §4 cadence),
`V11_MONSTER_PRESSURE_BASELINE.md` (the tuning this preserves), Godot `CLAUDE.md`
(player-indexed engine, mode port status).

Locked upstream (do not re-litigate here): one shared board + market + threat; threat
fires **once per round, after the last player's turn**; win = highest VP at the
end-trigger (Portal close or market raze-out), ties allowed; auspice is shared.

---

## 0. The one structural fix (why today is unfair)

Today the antagonist reads the engine working set (`gs.kingdom`, `gs.food_spent_total`,
`gs.calc_vp()`, ...). Because the threat fires after the last player's turn, the working
set is **the last player's board and counters**. So the last player eats every hit and
every seal reads only their progress. That is the naive bias the brief flagged.

**Fix:** the shared antagonist must never read the working set for targeting or seals.
It iterates `gs.player(i)` for every player `i` in `0..gs.player_count()`, reads each
player's `kingdom` / counters, and mutates the permanent dicts inside
`gs.player(i).kingdom` directly (those dicts are the same refs the working set aliases,
so a disable lands correctly when that player next becomes active). Tie-breaks across
players are **uniform random**, never defaulting to `current_player`.

---

## 1. One act per monster per round (the pressure budget)

Each field monster **acts exactly once per round**, against **one chosen Kingdom**. It
does **not** act once per Kingdom. This is the whole point of the once-per-round cadence:
per-player pressure stays at roughly the single-player rate (`V11_MONSTER_PRESSURE_BASELINE`).
Acting against each Kingdom would multiply pressure by player count and is rejected for
the same reason the cadence is once-per-round, not once-per-player-turn.

Consequence to accept: with few field monsters and two Kingdoms, a player can go a round
untouched. That is fine. The race is the pressure; the market-raze gate (§C) is the
shared loss floor. See §H for how this is retuned at 3-5 players.

---

## A. Which Kingdom a monster hits

A field monster scans **all** Kingdoms, resolves its best reachable in-Kingdom target
per Kingdom (respecting that Kingdom's own walls, §B), then picks across Kingdoms by its
appetite. Three appetite tiers, checked in order:

1. **High-value magnet (all monsters, §E):** if any Kingdom offers a beatable
   high-value permanent (Caravan etc.), hit the highest-VP one; ties uniform-random
   across Kingdoms. This overrides everything below.
2. **Preference monster (Ghoul, §D):** its own rule.
3. **Free-for-all (every non-preference monster):** no per-Kingdom loyalty. Apply the
   monster's existing priority **globally** across the pooled beatable targets of all
   Kingdoms:
   - Minotaur -> highest effective DEF anywhere
   - Gargantuan -> lowest effective DEF anywhere
   - default -> highest VP anywhere
   - all ties resolved uniform-random across the tied permanents (which spreads hits
     across players by construction).

This makes the monster hit "the juiciest target wherever it is." It is an intentional
rubber-band: the player who built more (the likely VP leader) presents more and juicier
targets, so the doom leans on the leader. That is the shared-board tension the brief
wants, not a bug. It replaces today's turn-order bias with an appetite-driven,
player-symmetric rule.

---

## B. Walls are per-Kingdom

A Taunt wall in player A's Kingdom gates monsters **only when they are attacking A**. It
does not protect B and does not protect the shared market row. Confirmed per the brief's
lean. The shared protection is the market-raze gate (§C), not walls.

Implementation: the existing wall logic in `_monster_pick_target` is applied **inside
each Kingdom's per-Kingdom resolution**. A non-flier resolving its target in Kingdom K
must first beat K's lowest-DEF beatable Taunt wall; if it cannot beat any of K's walls,
K offers that monster **nothing** (the monster looks to other Kingdoms, or falls through
to siege/retreat/raze). Fliers ignore walls as today. Creature-type monsters still
cannot target a Portcullis (checked per-Kingdom).

---

## C. The market-raze gate (the shared defeat point)

**Confirmed and made exact.** A market slot may be razed **only when every player's
Kingdom has zero active (non-disabled) permanents at the moment of the raze check.**

```
func raze_allowed() -> bool:
    for i in gs.player_count():
        for p in gs.player(i).kingdom:
            if not p.disabled:
                return false   # someone still has a standing permanent
    return true
```

While any one player has a single active permanent anywhere, the market is safe for
**both** players. This is what forces cooperative defense: it can be correct to repair a
rival's wall or heal a rival's creature to keep the raze gate shut, even though that
rival is also your VP opponent. Intended.

Reachability (the V11 cardinal rule): the gate is still reachable. If both players build
nothing, all Kingdoms are empty from turn 1 and raze proceeds immediately. If the
free-for-all monsters strip every active permanent off both boards in one round, the gate
opens that round. So raze-out is rare but real, which is correct: Portal-close is the
normal end, raze-out is the catastrophe end.

**Match-mode loss scope:** in the mirror match / PvP there is no per-player "realm
overrun" loss. The only doom end-trigger is **market raze-out** (all 12 positions gone),
which snapshots VP for all players and ends the game as a scored result, not a defeat.
Suppress the `kingdom.is_empty() and no cards` branch of `_check_monster_loss` in match
mode; keep only `_no_market_remains()` as the raze-out end-trigger.

---

## D. The Ghoul (preference monster): unseal, bounce, and no-Farm fallback

Define `first_player = gs.turn_order[0]` (the coin-flip winner; a stable identity for the
whole match, not "the last to act").

**Unseal round** (the round the Ghoul's seal is first met, `guarding -> field`): target
`first_player` only. Pick `first_player`'s lowest-DEF beatable **Farm**. If `first_player`
has no beatable Farm, start the bounce immediately (fall to the subsequent-round rule) so
the turn is not wasted.

**Every later round:** bounce. Pick a **uniform-random beatable Farm across all
Kingdoms** (uniform over the set of all beatable Farms, which naturally spreads across
players as they repair). This is the "repaired Farms" loop: Ghoul disables a Farm, the
owner repairs it, the Ghoul may land on any player's repaired Farm next round.

**No beatable Farm anywhere (the fallback Bryan was unsure about):**
1. If a non-flying **wall siege** is available in any Kingdom (a blocked, breakable Taunt
   wall, §G), the Ghoul **joins that siege** (contributes its ATK to the pool).
2. Otherwise the Ghoul **HOLDS** in the field (does nothing, stays exposed).

**Recommendation: HOLD, never RETREAT.** Retreat re-guards the Portal and turns the Ghoul
into scenery, the exact V11 failure (a threat the player can switch off by not building
Farms). Holding keeps it present and exposed, so the moment any player repairs or builds a
Farm the Ghoul bounces back onto it, and players must still kill the Ghoul to expose the
Portal. The Ghoul also still never razes (designer canon). Holding costs the player
nothing this round, which is acceptable because the Ghoul is a *specialist*; the
free-for-all monsters and the raze gate carry the general pressure. Retreat is rejected.

---

## E. High-value targeting across Kingdoms

A **high-value** permanent is a magnet that outranks every monster's normal priority
(§A tier 1), in any Kingdom. The initial set is `{Caravan}`; the exact card list and
whether "high-value" is a per-card data flag (e.g. `isHighValueTarget`) or derived from
VP threshold is a **`tcg-designer` call** (new/renamed card properties are the card
layer). Engineer: read the set from a flag/table, do not hard-code card ids.

Selection when high-value targets exist in more than one Kingdom: hit the highest-VP
beatable high-value permanent; ties uniform-random across Kingdoms. A high-value target
behind a wall the monster cannot beat does **not** count as reachable for that monster (it
falls to tier 2/3). This keeps a Caravan a genuine "defend me or lose me" object for both
players without re-biasing toward turn order.

---

## F. Seal counters in a shared game

**Recommendation: per-player, "any one player meeting it unseals."** A seal is met if its
threshold is met by **any** player (the max across players). Do **not** sum counters
across players.

Rationale: per-player preserves the single-player clock semantics exactly, so the
`V11_MONSTER_PRESSURE_BASELINE` tuning carries over with **no rescaling** (reachability and
rates stay known). Combined/summed counters would hit thresholds ~Nx faster and reintroduce
the double-pressure problem the once-per-round cadence exists to avoid, and would require a
re-tune we have no data for. Per-player also makes the **fastest/leading player wake the
doom for everyone**, a built-in leader-punish that matches the §A targeting rubber-band and
the shared-board fantasy ("your racing ahead pressures us both").

Per-counter source (shared counters stay shared; per-player counters take the max):

| Seal      | Source                                   | Met when                                   |
|-----------|------------------------------------------|--------------------------------------------|
| food20    | `player(i).food_spent_total`             | any player >= 20                           |
| turn8     | `gs.turn` (shared)                       | turn >= 8                                  |
| legend5   | `player(i).legend.size()`                | any player >= 5                            |
| perm4     | `player(i).kingdom.size()`               | any player >= 4                            |
| auspice4  | `gs.auspice_changes_total` (auspice is shared) | shared total >= 4                    |
| libarm    | `player(i).library_or_armory_ever_played`| any player true                            |
| conj      | `player(i).conjuration_ever_summoned`    | any player true                            |
| proud25   | `player(i).calc_vp()` (per-player VP)    | any player >= 25                           |
| food4     | see note                                 | any player ended a turn with >= 4 food     |

**food4 note (engine detail to add):** unspent food is per-player and resets at each
player's end-of-turn, so the once-per-round threat turn cannot read it live for everyone.
Add a sticky per-player bool `food4_ever`, set in `end_turn` when that player's unspent
food >= 4 before the reset. The seal reads `any player(i).food4_ever`. (Sticky is correct:
unseal is permanent once met.)

---

## G. Wall siege and the Fifth Protector

**Wall siege is per-Kingdom.** A siege pools the ATK of the non-flying field monsters that
**chose to attack Kingdom K this round and were wall-blocked there**, against K's lowest-DEF
breakable Taunt wall. Scoping the pool to K (rather than the whole row) prevents both
Kingdoms' attackers from ganging one wall, which would make walls worthless on a shared
board.

Implementation: process monsters in queue order (as `take_turn` already does). Maintain a
per-round `siege_pool: Dictionary` keyed by player index. When a non-flier's chosen Kingdom
K offers only an unbeatable (solo) Taunt wall, add its ATK to `siege_pool[K]` and
immediately test `siege_pool[K] >= def_vs_monster(K_lowest_wall)`; if met, disable that
wall now so later monsters this round pass the opened wall (matches single-player ordering,
scoped to K). The Ghoul's no-Farm fallback (§D) feeds `siege_pool[K]` the same way.
*Cheaper acceptable fallback for the first playable:* keep the single-player whole-row
pool but still target one chosen Kingdom's wall; flag it as a known over-strength
simplification for QA to watch.

**Fifth Protector is unchanged.** It reads the shared monster queue, so `_maybe_reinforce`
needs no edit: it reinforces the one shared Portal the first round no non-Portal monster is
`guarding`. One caution carried over from single-player: non-preference monsters that
**retreat** to `guarding` (no reachable target and raze gate shut, §A fallthrough below)
keep a guard standing and can delay reinforcement, same as today.

**Non-preference no-target fallthrough** (parallels the Ghoul's §D, but these monsters may
retreat): a non-Ghoul field monster with no reachable target in any Kingdom, when the raze
gate is **not** yet open (§C), first joins any available wall siege, else **retreats** to
`guarding`. Retreat is acceptable for non-preference monsters because `take_turn` re-enters
an unsealed retreated guard to the field next round automatically, so it is effectively a
one-round skip, not a switch-off. When the raze gate **is** open, it razes instead (§C).

---

## Combined pseudocode (port target for `_monster_act` / `_monster_pick_target`)

```
# Runs once per round, after the last player's turn. `m` = one field monster.
func monster_act_shared(m):
    target = pick_target_shared(m)          # {player_id, perm} or {}
    if target:
        target.perm.disabled = true
        emit permanent_disabled(target.perm, m.name, target.player_id)
        return

    # no reachable target
    if m.id == "mn_ghoul":
        if join_any_wall_siege(m): return   # §G, feeds siege_pool
        return                              # HOLD (never retreat, never raze)

    if non_flier(m) and join_any_wall_siege(m):
        return
    if raze_allowed():                      # §C: EVERY player's kingdom has 0 active perms
        gs._raze_one_market()               # shared slot; counts once toward raze-out end
    else:
        m.state = "guarding"                # retreat; re-enters field next round


func pick_target_shared(m) -> {player_id, perm}:
    # per-Kingdom reachable sets (walls applied inside each Kingdom, §B)
    reach = {}                              # player_id -> array of beatable perms it can reach
    for i in gs.player_count():
        reach[i] = reachable_targets(m, gs.player(i).kingdom)   # existing wall/portcullis/beatable logic, scoped to this kingdom

    # tier 1: high-value magnet (all monsters, §E)
    hv = all beatable high-value perms across reach[*]
    if hv not empty: return argmax_vp(hv) with uniform-random tie across players

    # tier 2: Ghoul preference (§D)
    if m.id == "mn_ghoul":
        farms = all beatable Farms across reach[*]
        if not ghoul_unsealed_before_this_round:        # unseal round
            f = first_player's lowest-DEF beatable Farm
            if f: return {first_player, f}
            # else fall through to bounce
        if farms not empty: return uniform_random(farms) # bounce across all kingdoms
        return {}                                        # no Farm -> §D fallback in act

    # tier 3: free-for-all global priority (§A)
    pool = all beatable perms across reach[*]
    if pool empty: return {}
    match m.id:
        "mn_minotaur":   return argmax def_vs_monster(pool)   # uniform-random tie
        "mn_gargantuan": return argmin def_vs_monster(pool)   # uniform-random tie
        _:               return argmax vp(pool)               # uniform-random tie
```

`reachable_targets(m, kingdom)` is today's `_monster_pick_target` body with the final
priority/selection removed: it returns the set of perms `m` can actually hit in that one
Kingdom (fliers skip walls; non-fliers must beat the lowest Taunt wall or the Kingdom
returns empty; creature-types skip Portcullis; only `def_vs_monster(p) <= atk`). Selection
now happens globally in `pick_target_shared`.

---

## H. Scaling to 3-5 players

- **Keep one act per monster per round.** Do not let acts scale with Kingdom count by
  default, or pressure multiplies. Same global scan over N Kingdoms.
- **Per-player seals (§F) auto-accelerate** the doom with more players (more players
  crossing thresholds sooner). This is desirable (more players = more ambient doom) but the
  thresholds may need a modest bump at 4-5 players. **Tune against measured data, do not
  guess numbers now** (reachability before balance).
- **Coverage problem at scale:** with ~3 field monsters and 5 Kingdoms, 2 Kingdoms escape
  untouched each round. If playtest shows this is too soft, the lever is to let each field
  monster make `ceil(N/2)` acts against **distinct** Kingdoms per round (so about half the
  table is hit), and/or add guardians/HP with player count. Both are tuning knobs to set
  from data, flagged, not fixed here.
- **The raze gate (§C) gets strictly harder** with more players (all N Kingdoms must be
  stripped at once), so raze-out becomes near-impossible at 5p and the Portal-close
  end-trigger dominates. Acceptable and intended; no change needed.

---

## Handoffs (not pve-pressure calls)

- **`tcg-designer`:** the high-value target set and whether it is a data flag
  (`isHighValueTarget`) or a VP-threshold derivation (§E). Market supply depth for 2+
  buyers (already flagged in the brief). Any new monster abilities that introduce new
  targeting appetites.
- **Engineer:** the `food4_ever` sticky flag (§F); suppressing the realm-overrun loss in
  match mode (§C); operating on `gs.player(i).kingdom` not the working set (§0).

---

## QA assertable test cases

1. **No turn-order bias.** Scripted: player A (acts first) and player B (acts last) each
   hold one identical beatable high-VP permanent, nothing else. Over many seeded runs the
   free-for-all monster hits A and B at ~50/50 (uniform tie), never always B.
2. **Appetite over owner.** A has a DEF-2 permanent, B has a DEF-8 permanent, both beatable.
   The Minotaur hits B's (highest DEF) regardless of who acted last; the Gargantuan hits A's.
3. **Ghoul unseal targets first player.** Force the Ghoul to unseal on a round where both
   players have a beatable Farm. The first disabled Farm belongs to `turn_order[0]`.
4. **Ghoul bounce.** After unseal, repair both Farms each round for several rounds; assert
   the Ghoul's target Farm is not always the same player's (it bounces across Kingdoms).
5. **Ghoul holds with no Farms.** Remove all Farms, provide no breakable wall: the Ghoul
   does not raze, does not retreat to `guarding`, and remains `field`.
6. **Walls are per-Kingdom.** A has an unbreakable Taunt wall over a juicy target; B has the
   same juicy target exposed. The monster hits B (A's wall does not protect B, and does not
   stop the monster from choosing B).
7. **Raze gate shut by one survivor.** Strip every active permanent off A; leave B one
   active permanent. `raze_allowed()` is false; no market slot is razed that round.
8. **Raze gate opens.** Both Kingdoms have zero active permanents: a non-Ghoul field monster
   with no target razes exactly one shared slot, counted once toward raze-out.
9. **Seal is per-player, any-one.** Only player B spends 20 food (A spends 0). The food20
   guardian unseals that round (max across players, not the sum, not A-only).
10. **Once per round.** In a 2-player match the monster turn runs exactly once per round
    (after the 2nd player), and each field monster disables at most one permanent per round.
