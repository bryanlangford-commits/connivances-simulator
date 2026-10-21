# Connivances V10. Lockdown Bug Fixes (paste-ready for the Project chat)

**How to use this doc:** paste the whole thing (or one fix at a time) into your
claude.ai Connivances Project chat and ask it to apply the changes to the
current simulator. It's written against **function names and logic**, not line
numbers, so it applies even if the Project's copy has drifted a version from
`connivances_simulator_v10_23`.

All six were found and **verified live** against v10_23 by driving the engine
directly (injecting state, calling the real functions). A reference
implementation with every fix already applied and re-verified lives at
`simulator/connivances_simulator_v10_23_PATCHED.html` in the Claude Code repo.

Context worth giving the Project assistant up front: **the engine mixes two
strategies for ongoing effects**; "recompute live" (Golem, Gargantuan,
Fortress, Library/Armory/Farm set pairs, `permFoodBonus`) vs. "write once into
state and never reconcile" (Wall Set DEF, the food delta, the VP played-copy).
Three of these six bugs are the written-once effects breaking when state
changes underneath them.

---

## Fix 1. Permanents double-counted in VP (High) ✅ verified

**Symptom:** the turn you play a permanent, ⭐ Projected VP jumps by *twice*
the card's VP; it corrects next turn. If you defeat the Portal on a turn you
played permanents, the **final score is inflated** too.

**Cause:** in `calcVP()`, a played permanent exists in *both* `S.permanents`
and `S.played` with **different** `uid`s (each gets its own `genUid()`), so the
`uid` dedup meant to prevent double-counting never matches.

**Fix:** in `calcVP`, skip `isPermanent` entries in the `S.played` loop -
permanents are already counted via `S.permanents`.

```js
// before
S.played.forEach(p=>{if(!all.find(x=>x.uid===p.uid))all.push(p);});
// after
S.played.forEach(p=>{if(!p.isPermanent && !all.find(x=>x.uid===p.uid))all.push(p);});
```

---

## Fix 2. Portcullis "Immune to 🟡 Creature ATK" never enforced (Medium) ✅ verified

**Symptom:** a creature-type monster can target and disable a Portcullis,
contradicting its printed immunity. (The only code that special-cased
`isPortcullis` was in `checkWallSiege`, which only runs for `isTaunt` walls -
Portcullis isn't taunt; so it was dead code.)

**Fix:** in `monsterPickTarget(m)`, drop Portcullis permanents from the
candidate list when the attacker is creature-type. Make `active` reassignable
and filter it:

```js
let active = S.permanents.filter(p => !p.disabled && !p.isTrophyMonster);
if(m.isCreatureType) active = active.filter(p => !p.isPortcullis);
if(!active.length) return null;
```

**Note:** this is type-specific; non-creature monsters can still hit a
Portcullis (verified with Minotaur). Only creature-type attackers are blocked.

---

## Fix 3 + 6. Mid-turn Auspice switch mis-calculates Farm food (Medium) ✅ verified

Two defects, one code block (the "Real-time food delta" in `setAuspice`).

- **Magnitude:** the old model used `±1` (Harvest `+1`, Famine `-1`) relative
  to a neutral baseline, but `permFoodBonus`/`farmFoodValue` zero a Farm's
  *entire* output under Famine. They only agree for a base-1 Farm; a base-2
  Farm (Rice/Tiered Field) keeps 1 phantom food after switching to Famine.
- **Exploit:** `Math.max(0, S.food + delta)` swallowed the negative delta when
  food was low, but the positive delta re-added on switch-back; so
  Harvest→Famine→Harvest minted `2 × (farm count)` food from nothing.

**Fix:** diff *true* farm output, and repay clamp-lost food via a per-turn
`farmFoodDebt` ledger before crediting new food:

```js
let farmFoodDelta=0;
S.permanents.forEach(p=>{
  if(p.disabled||p.subtype!=='Farm')return;
  const base=p.food||0;
  const outFor=(a)=>(a===2?base+1:(a===3&&!S.irrigatorPlayedThisTurn?0:base));
  farmFoodDelta+=(outFor(i)-outFor(oldAuspice));
});
if(farmFoodDelta!==0){
  if(S.farmFoodDebt==null)S.farmFoodDebt=0;
  let applied=farmFoodDelta;
  if(applied>0&&S.farmFoodDebt>0){
    const repay=Math.min(applied,S.farmFoodDebt);
    applied-=repay;S.farmFoodDebt-=repay;
  }
  let newFood=S.food+applied;
  if(newFood<0){S.farmFoodDebt+=(-newFood);newFood=0;}
  S.food=newFood;
}
```

Also reset the ledger each turn; in `startTurn`, right after `S.food=3+pfb;`:

```js
S.farmFoodDebt=0;
```

This preserves the intended "switches apply in real time" behavior (a legit
Harvest→Famine with food in the pool still drops the right amount) while making
round-trips net zero. Verified: Harvest→Famine→Harvest from food 0 → stays 0;
Famine from food 6 with a Rice Field → drops to 3.

---

## Fix 4. Silent Stalker described as Flying but doesn't fly (Medium) ✅ verified

**Symptom:** its tooltip (`getMonsterPriority`) and the `monsterPickTarget`
comment both call Silent Stalker flying/wall-bypassing, but its data has
`fly:false`, so a taunt Wall blocks it.

**Fix (data):** set `fly:true` on the `mn_stalker` entry in `MONSTERS`, to
match the description and its pairing with Nightmare.

> ⚠️ **Design check for Bryan:** I made it match the *text* (Stalker flies). If
> you actually intend it grounded, do the opposite instead; fix the tooltip in
> `getMonsterPriority` and the comment in `monsterPickTarget`. Either way,
> data and description should agree.

---

## Fix 5. Repair/Heal strips the Wall Set +2 DEF permanently (Medium) ✅ verified

**Symptom:** the Wall Set bond writes `+2` directly into `currentDef` once
(`applyWallBond`) and it's never reapplied. But `useRepair`, the heal picker,
and `dispelPossession` reset `currentDef = p.def` (base), so a disabled +
repaired/healed Creature/Siege comes back permanently 2 DEF short.

**Fix:** add one canonical helper (next to `golemDefBonus`/`effectivePermDef`)
and use it wherever `currentDef` is reset:

```js
function recomputeStoredDef(p){
  let d=(p.def||0)+((p.attachedCards||[]).reduce((s,a)=>s+(a.defBonus||0),0));
  if((p.isCreatureType||p.atk_siege>0) && S.wallSetsCompleted>0) d+=S.wallSetsCompleted*2;
  return d;
}
```

Then replace the three resets:
- `useRepair`: `p.currentDef=p.def;` → `p.currentDef=recomputeStoredDef(p);`
- heal picker (`showHealPicker`): `perm.currentDef=perm.def;` →
  `perm.currentDef=recomputeStoredDef(perm);`
- `dispelPossession`: `host.currentDef=host.def+(host.attachedCards||[])...` →
  `host.currentDef=recomputeStoredDef(host);`

(Golem/Gargantuan/Fortress DEF stays live via `effectivePermDef` and is
intentionally NOT stored here.) **Known limitation:** repairing a building that
has an Expediter attached still doesn't re-apply Expediter's `-2` (that penalty
is tracked via explicit attach/detach math, not a `defBonus`). Pre-existing
behavior; flagged for a later pass.

---

## Fix 7. Disabled permanents don't detach their attached recruit (Medium) ✅ verified
*(Found in the V11 audit. If you're on V11 and applied Fixes 1–6 already, this
is the only new code change.)*

**Game rule (designer):** when a permanent is disabled, an attached player
recruit is "dead"; it detaches and goes to the discard pile (redraw + re-attach
later). So a repaired permanent must **not** carry that attachment's bonus.

**Bug:** `monsterAttackPermanent` and the Wall Siege `wall.disabled` only set
`disabled=true`; they never removed the attachment, so the recruit stayed
stranded on the disabled host and its DEF lingered.

**Fix:** add a helper and call it wherever a permanent is disabled.

```js
// Place next to recomputeStoredDef:
function detachRecruitsOnDisable(perm){
  if(!perm.attachedCards||!perm.attachedCards.length) return;
  const kept=[];
  perm.attachedCards.forEach(a=>{
    if(a.isPossession){ kept.push(a); return; } // enemy Possession stays
    S.discard.push(Object.assign({},a,{uid:genUid(),_attached:false}));
    addLog('📎 '+perm.name+' disabled; attached '+a.name+' detaches → discard.','bad');
  });
  perm.attachedCards=kept;
}
```

- `monsterAttackPermanent`: after `perm.disabled = true;` add
  `detachRecruitsOnDisable(perm);`
- `executeWallSiege`: after `wall.disabled = true;` add
  `detachRecruitsOnDisable(wall);`

With the recruit gone, `recomputeStoredDef` on repair naturally returns base
DEF + Wall Set (no attachment bonus). **Prereqs:** this assumes Fix 5's
`recomputeStoredDef` is present. Also wire `defBonus` so *voluntary* detach and
live stacked-attachment DEF stay correct: `confirmAttach` stores
`{...card, defBonus:2}`; Expediter placement stores `{...card, defBonus:-2}`;
and `detachCard` rebuilds via `recomputeStoredDef(host)` after `splice` instead
of a blind ±2.

Verified live: Fortifier on Armory (DEF 7) → monster disables → Fortifier in
discard, host at repair → DEF 5; a Possession stays attached; voluntary detach
returns base DEF; Fixes 1–6 still pass.

---

## Not a bug. Enforcer "heal any creature in any field"
This is a **multiplayer/PVP** feature: in a multiplayer game the Enforcer's
owner can heal *another player's* Conjurations; deliberate design to enable a
facade-of-cooperation / barter dynamic ("I'll heal your Familiar if you don't
attack me"). The single-player simulator has no other player's field, so the
current behavior (heal your own disabled creatures) is the correct
single-player projection. No change needed.

---

## Not bugs (checked, cleared); don't waste time on these
- **Negotiator retroactive Inf**; traces correct across single/stacked/mixed
  Warrior sequences.
- **Warlord retroactive burst** over-counts with 2+ Warlords, but Warlord is
  `qty:1` and resets each turn, so two can never coexist. Unreachable.
- **Trophy-kill paths** (field / guard / portal); all consistent (→ discard).
- **Empty-deck reshuffle** (`drawCards`); correct.

## Balance note (design, not a bug); for tcg-designer / your call
All guardians can be **unsealed** (not killed) to expose the Portal
(`isPortalExposed` returns true when none are `guarding`). Combined with cheap
unseal conditions (e.g. Fiend at Turn 3), this may allow a fast-win that skips
the combat the mode is built around. Worth a balance look for V11.
