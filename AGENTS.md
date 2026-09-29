# DreamValley — Agent Notes

## Build / Compile

This project compiles with BYOND DreamMaker (dm.exe).

```powershell
& "C:\Users\lugin\Desktop\BYOND\bin\dm.exe" -max_errors 0 roguetown.dme
```

A clean compile prints `0 errors, 0 warnings`.
The `roguetown.dmb` output is the compiled game file.

OpenDream can also be used but the path in older docs is stale; DreamMaker
is the primary compiler.

## Simple Animals

Animals are Azure Peak's simple mobs: `/mob/living/simple_animal` (defined in
`code/modules/mob/living/simple_animal/simple_animal.dm`). They are not carbon
mobs and have no bodyparts or organs. Hit locations, weak points and
part damage come from Azure Peak's anatomy profiles
(`code/modules/mob/living/simple_animal/weakpoints.dm`).

An earlier DreamValley experiment made every animal a carbon mob
(`/mob/living/carbon/simple_animal`) with per-limb natural armor. That was
fully reverted in September 2026; don't reintroduce the carbon type path.
`issimple()` / `isanimal()` check `/mob/living/simple_animal`.

## Sexcon / Chastity Port

The sexcon system was ported from Ratwood-2.0. Ratwood-specific paths that
don't exist in this codebase are stubbed in
`code/datums/sexcon/sexcon_port_stubs.dm` so the ported code compiles without
editing every call site. Key stub categories:

- **Patron aliases**: Xylix→Viator, Baotha→Hausvette, Eora→Miluse
- **Status effects**: stinky_contact, emberwine, cum_consumed, surrender/collar
- **Stress events**: cumok, cummax, unseemly_made_love, thrill, chastity_*
- **Components**: collar_master (minimal), intimate_reaction (full, in modular/)
- **Vars/procs**: has_gnoll_scent_this_round, bellsound, check_handholding,
  eora_register_consensual_pair, start_sex_session, log_chastity_command

The full chastity device system (core, equip, variants, cursed, keys, sprite
accessory, bodypart feature) lives under
`modular/code/game/objects/items/lewd/chastity/` and
`code/game/objects/items/rogueitems/keys_chastity.dm`.

Chastity-related defines are in `code/__DEFINES/sexcon_defines.dm`
(TRAIT_CHASTITY__, CHASTITY__ constants, BODYPART_FEATURE_CHASTITY,
COMSIG_CARBON_LOSE_CHASTITY).

## Stat Integration System

DreamValley has 7 core stats (STR/PER/INT/CON/WIL/SPD/LCK) defined on
`/mob/living` in `code/modules/mob/living/stats.dm`. The stat integration
system in `code/modules/mob/living/stat_integration.dm` extends these stats
to affect non-combat actions, ported from CEV-Eris design.

**Utility procs:**

- `get_stat_mult(stat, cap)` — action-time multiplier (0-1) based on stat
- `get_stat_speed(stat)` — speed multiplier (0.5-2.0), 1.0 at baseline 10
- `get_min_stat(list)`, `get_max_stat(list)`, `get_sum_stat(list)`, `get_avg_stat(list)` — compound checks
- `stat_check(stat, difficulty, chance_per_point)` — returns quality tier 0-5
- `stat_check_best(list, ...)`, `stat_check_all(list, ...)` — multi-stat versions
- `add_temp_stat(stat, amount, duration, id)` / `remove_temp_stat(stat, id)` — timed buffs/debuffs

**Convenience procs** (all defined on `/mob/living`):

- `get_crafting_speed_mult()`, `get_crafting_quality_mod()` — INT/PER
- `get_surgery_success_mod()`, `get_surgery_speed_mult()` — INT/PER
- `get_mining_speed_mult()`, `get_mining_yield_mod()` — STR/CON
- `get_lumber_speed_mult()` — STR/SPD
- `get_alchemy_quality_mod()` — INT/WIL
- `get_cooking_quality_mod()` — INT/PER
- `get_lockpick_success_mod()`, `get_lockpick_speed_mult()` — PER/SPD
- `get_fishing_success_mod()` — PER/LCK
- `get_foraging_success_mod()` — PER/INT

**Quality tier defines** (in `code/__DEFINES/roguetown.dm`):
`STAT_QUALITY_FAILURE` (0) through `STAT_QUALITY_MASTERWORK` (5).
`STAT_BASELINE` (10), `STAT_CEILING` (20).

**Integrated systems:**

- Crafting (`code/datums/components/crafting/crafting.dm`) — speed + success + quality
- Blacksmithing (`code/modules/roguetown/roguejobs/blacksmith/anvil_recipes/_anvil_recipe.dm`) — success chance
- Item quality (`code/game/objects/items.dm` `apply_quality()`) — roll bonus from INT/PER
- Surgery (`code/modules/surgery/_surgery_step.dm`) — success chance from INT/PER
- Mining (`code/_onclick/item_attack.dm`) — damage multiplier from STR/CON
- Lumberjacking (`code/_onclick/item_attack.dm`) — damage multiplier from STR/SPD
- Alchemy (`code/modules/roguetown/roguecrafting/alchemy/mortarpestle.dm`) — bonus output from INT/WIL
- Cooking (`modular/Neu_Food/cooking_helpers.dm` `get_cooktime_divisor_stat()`) — speed from INT/SPD
- Lockpicking (`code/game/objects/structures/mineral_doors.dm`) — speed + success from PER/SPD
- Fishing (`code/modules/roguetown/roguejobs/fisher/rod.dm`) — wait time + success from PER/LCK
- Foraging (`code/game/objects/structures/roguetown/rogueflora.dm`) — success from PER/INT

## Weapon Modification System

A weapon attachment system ported from CEV-Eris gun_upgrade design,
fantasy-reskinned. Allows applying removable mods to weapons that modify
their stats (force, defense, armor penetration, durability, balance, etc.)
and add on-hit effects (burn, toxin, holy damage).

**Files:**

- Defines: `code/__DEFINES/weapon_mods.dm` (slots, upgrade keys, weapon type tags)
- Component: `code/datums/components/weapon_mods.dm` (`/datum/component/weapon_mods`)
- Items: `code/game/objects/items/rogueweapons/weapon_mods/weapon_mods.dm`

**How it works:**

1. Use a mod item on a weapon (via `afterattack`) to attach it
2. The component is auto-created on the weapon if it doesn't exist
3. Mods are stored in `attached_mods` list, keyed by slot
4. Each weapon can have at most one mod per slot
5. Use a crowbar or hammer on a modded weapon to remove mods (tgui list prompt)
6. Removing the last mod deletes the component

**Slots:** blade, grip, pommel, guard, shaft, bowstring, sight, crank,
boss, rim, coating

**Upgrade keys** (in `upgrades` list on each mod item):

- `WMOD_FORCE_ADD` / `WMOD_FORCE_MULT` — damage
- `WMOD_WDEFENSE_ADD` / `WMOD_WDEFENSE_WBONUS_ADD` — defense
- `WMOD_ARMOR_PEN_ADD` — armor penetration
- `WMOD_MAX_INTEGRITY_ADD` — durability
- `WMOD_INTDAMAGE_MULT` — integrity damage factor
- `WMOD_MINSTR_ADD` — STR requirement
- `WMOD_WBALANCE_SHIFT` — balance (heavier/swifter)
- `WMOD_THROWFORCE_ADD` — throw damage
- `WMOD_BLOCK_CHANCE_ADD` / `WMOD_COVERAGE_ADD` — shield stats
- `WMOD_CHARGESPEED_MULT` / `WMOD_RELOADTIME_MULT` — crossbow speed
- `WMOD_DAMFACTOR_MULT` / `WMOD_ACCFACTOR_MULT` — bow/crossbow stats
- `WMOD_SHARPNESS_SET` — set sharpness level
- `WMOD_BURN_DAMAGE` / `WMOD_TOX_DAMAGE` / `WMOD_HOLY_DAMAGE` — on-hit effects

**Weapon type tags** (type paths for `is_type_in_list` compatibility):
`WEAPON_TAG_SWORD`, `WEAPON_TAG_AXE`, `WEAPON_TAG_DAGGER`,
`WEAPON_TAG_POLEARM`, `WEAPON_TAG_BLUNT`, `WEAPON_TAG_WHIP`,
`WEAPON_TAG_BOW`, `WEAPON_TAG_CROSSBOW`, `WEAPON_TAG_SHIELD`,
`WEAPON_TAG_MELEE` (any `/obj/item/rogueweapon`),
`WEAPON_TAG_RANGED`, `WEAPON_TAG_ALL` (any `/obj/item`)

**Available mods** (20+ items):

- Melee: blade oils (fire/poison/holy), razor edge, rust coating, leather/wire/balanced grips, heavy/light/gemstone pommels, reinforced/basket guards, reinforced/metal shafts
- Ranged: silk/sinew bowstrings, sighting pin, quick/heavy cranks
- Shield: iron/steel bosses, metal/spiked rims, sanctified coating

## Sanity / Insight System (Eris Port)

A medieval-fantasy adaptation of CEV-Eris's sanity and Insight system,
integrated with DreamValley's existing stats and stress architecture.

**Files:**

- Defines: `code/__DEFINES/sanity.dm`
- Subsystem: `code/modules/sanity/sanity_subsystem.dm` (SSsanity, 10s tick)
- Core datum: `code/modules/sanity/sanity_mob.dm` (`/datum/sanity`)
- Human integration: `code/modules/sanity/sanity_human.dm`
- Breakdowns: `code/modules/sanity/breakdown.dm`, `breakdowns.dm`
- Effects: `code/modules/sanity/sanity_effects.dm` (emotes, quotes, sounds, hallucinations)
- Oddities: `code/modules/sanity/oddities.dm` (meditation artifacts)
- Clothing protection: `code/modules/sanity/sanity_clothing.dm`
- Inspiration: `code/modules/sanity/inspiration_component.dm`
- Atom assignments: `code/modules/sanity/sanity_atom_assignments.dm`

**How it works:**

1. Every human gets a `/datum/sanity` on Initialize (unless `TRAIT_NOMOOD`)
2. SSsanity processes each sanity datum every 10 seconds
3. Sanity passively recovers (SANITY_PASSIVE_GAIN = 0.2)
4. Sanity drains from: environmental hazards, viewing disturbing atoms,
   taking damage, witnessing death, psychic/magic damage
5. Willpower (STAT_WIL) reduces sanity damage (maps to Eris's VIG)
6. Low sanity triggers effects: emotes, quotes, phantom sounds, hallucinations
7. At sanity 0, a breakdown triggers (positive or negative)
8. Insight accumulates passively and from experiences
9. At INSIGHT_REST_THRESHOLD insight, the player can "level up" —
   choosing a stat to increase
10. Oddities can be meditated on for larger stat boosts

**Key values:**

- Sanity starts at 100, max 100 (increases with positive breakdowns)
- Insight starts at 0, rest threshold 100
- Breakdown probability: positive_prob (default 30), negative_prob (default 70)
- Clothing protection: holy symbols (+2.0), armor (+0.5), hoods (+0.3)

**Breakdown types:**

- Positive: Stalwart (heal), Adaptation (max sanity up), Concentration
  (invulnerability), Determination, A Lesson Learnt (stat up)
- Negative: Self-harm, Hysteric (stunned), Delusion (phantom sounds),
  Downward-spiral (worse future breakdowns), Kleptomania, Paranoia
- Common: Pilgrimage (drawn to holy areas for insight reward)

**Integration with existing systems:**

- Respects `TRAIT_NOMOOD` (no sanity datum created)
- Respects `TRAIT_NOMOOD` in onLife (skips processing)
- `apply_damage()` on humans triggers `sanity.onHurt()`
- `death()` on humans triggers `sanity.onWitnessDeath()` for nearby humans
- Clothing protection reduces sanity damage from psychic and injury sources
- Area `sanity_hazard` var affects passive sanity gain/loss
- Atom `sanity_damage` var affects viewers' sanity

**Oddities (meditation artifacts — Eris-style stat scaling):**

- `/obj/item/oddity` — base type, meditate for insight/stat boost
- Subtypes: crystal, bone_charm, ancient_coin, bloodstone, wolf_fang,
  elf_mirror, wind_chime, grimoire_fragment, holy_relic
- Cursed subtypes: cursed_idol, dark_totem, shadow_mirror (negative stats)
- Each has an `aligned_stat`, `sanity_aura`, and `oddity_stats` list
- `oddity_stats` format: `list(STAT_DEFINE = max_value)` — randomized on init
  like Eris: `rand(2, max_value)` for positive, `rand(max_value, -2)` for negative
- On use, each stat value is **doubled** (Eris: `stat_up = L[stat] * 2`)
  and added to the owner's `oddity_stat_bonuses` layer
- Some oddities are single-use, others reusable (grimoire_fragment, holy_relic)
- Examining an oddity with INT >= 10 shows its stat aspects

**Eris-style stat scaling layer:**

- Base stats (STASTR, STAPER, etc.) stay 1-20 for character creation
- `oddity_stat_bonuses` list on `/mob/living` tracks bonus/penalty per stat
- Range: -200 to +200 per stat (ODDITY_STAT_BONUS_MIN/MAX)
- `get_stat()` returns **base + oddity bonus** (effective stat)
- `get_base_stat()` returns just the base stat (1-20)
- `add_oddity_stat_bonus(stat, amount)` adds to the bonus layer
- `get_oddity_stat_bonus(stat)` reads the bonus for a stat
- All stat_integration.dm procs use `get_stat()`, so they automatically scale
- Existing code that reads STASTR directly still gets 1-20 (backward compatible)
- Breakdown "A Lesson Learnt" also uses the oddity bonus layer
- HUD shows oddity bonuses when clicking the stress indicator

**Inspiration component:**

- `/datum/component/inspiration` — attach to atoms for examine-based insight
- Presets: art, literature, holy, nature, dark
- Cooldown-based to prevent spamming

## ERISMED — Internal Wound System (Eris Port)

A medieval-fantasy adaptation of CEV-Eris's internal wound system,
integrated with DreamValley's existing organ and surgery architecture.

**Files:**

- Subsystem: `code/modules/erismed/erismed_subsystem.dm` (SSerismed, 10s tick)
- Core datum: `code/modules/erismed/internal_wounds/_internal_wound.dm`
- Organic wounds: `code/modules/erismed/internal_wounds/organic_wounds.dm`
- Organ integration: `code/modules/erismed/organ_integration.dm`
- Surgery: `code/modules/erismed/surgery_internal_wounds.dm`

**How it works:**

1. Internal wounds are datums attached to organs (`obj/item/organ.internal_wounds`)
2. SSerismed processes each wound every 10 seconds
3. Wounds progress over time (severity increases up to severity_max)
4. At max severity, wounds can transform into worse types (next_wound)
5. Wounds damage their parent organ and can spread to other organs
6. Wounds can be treated with: items (bandages, honey), chemicals
   (salglu_solution, medicine), or surgery
7. Some wounds have psychic damage (affects sanity) or hallucinations
8. Surgery step `treat_internal_wound` allows surgeons to treat wounds
   during organ manipulation surgery

**Wound categories:**

- Blunt: rupture, hemorrhage, contusion
- Sharp: perforation, cavitation, gored tissue
- Edge: laceration, deep gash, ripped tissue
- Burn: scorched, charred, incinerated flesh
- Necrosis: damaged tissue, necrotizing tissue
- Poisoning: pustule, minor poisoning, foreign accumulation
- Infection: abscess, sepsis (spreads to other organs)
- Inflammation: inflammation, fibrosis, cirrhosis (organ efficiency loss)
- Swelling: inflamed tissue, edema
- Psychic: soul damage, corruption, haunting (affects sanity)

**Organ integration:**

- `obj/item/organ/add_internal_wound(type)` — adds or escalates a wound
- `obj/item/organ/remove_internal_wound(IW)` — removes a wound
- `obj/item/organ/take_internal_damage(amount, type)` — damage with wound chance
- `obj/item/organ/examine()` — shows wounds if INT check passes
- Wounds are cleaned up when organs are removed

**Surgery:**

- `/datum/surgery/treat_internal_wounds` — full surgery chain
- Steps: incise → retract → clamp → treat_internal_wound → cauterize
- Treatment tools: bandages, honey, glass bottles
- Requires SURGERY_INCISED | SURGERY_RETRACTED flags

**Organ efficiency system:**

- `code/modules/erismed/organ_efficiency.dm`
- `obj/item/organ/get_efficiency()` — returns 0-100 based on damage + wounds
- `mob/living/carbon/human/process_organ_efficiency()` — called from Life()
- Low efficiency causes: blurry vision (eyes), tox buildup (liver),
  stamina loss (heart), oxy loss (lungs), nutrition loss (stomach)
- Internal wounds reduce efficiency via `organ_efficiency_multiplier`

**Additional breakdown types:**

- Negative: Fugue (wandering), Tremors (shaking), Voices (hallucinated
  whispers), Berserk (random attacks)
- Positive: Epiphany (large insight gain), Divine Vision (temporary
  invulnerability)

**Loot & integration:**

- Oddities added to dungeon loot spawner tables
- Area `sanity_hazard` assigned to existing areas (church +1.5, woods -0.3,
  bog -0.6, vampire_manor -1.0, lich_lair -1.2, shelter +0.8)
- Inspiration component attached to: paintings, books, instruments
- Sanity HUD: clicking stress indicator shows sanity/insight status;
  low sanity (<20) overrides stress icon to show distress

## Procedural Multi-Biome Dungeon

The "Tomb of Alotheos" dungeon on the "Dungeon Map" Z-level is now a
procedurally generated multi-biome dungeon inspired by Dungeon Meshi and
deep-maint SS13 dungeons.

**Files:**

- Framework: `code/controllers/subsystem/dungeon_framework.dm` (void turf, directional helpers, map_template/dungeon base, tomb areas)
- Templates: `code/controllers/subsystem/dungeon_templates.dm` (datum definitions for .dmm room/hallway files)
- Biomes: `code/controllers/subsystem/dungeon_biomes.dm` (biome definitions, procedural room generation, enhanced generator)
- Generator: `code/controllers/subsystem/dungeon_generator.dm` (template-based expansion engine)
- Map: `_maps/map_files/shared/dungeon.dmm` (entry map with 4 directional markers)
- Room .dmm files: `_maps/dungeon_generator/room/` (TownRuins, SmallChurch, sewers, rousecamp, hctomb2, queensretreat)
- Hallway .dmm files: `_maps/dungeon_generator/hallway/` (Malphpiece5)

**Biome layers (shallow to deep):** 0. ruins — collapsed buildings, wood/stone floors, rats/skeletons

1. crypt — ancient burial chambers, hexstone, skeletons
2. cave — natural caverns, dirt/rock, spiders/wolves
3. sewer — flooded corridors, metal grates, goblins/rats
4. lair — monster nests, volcanic rock, lava, minotaurs/trolls
5. treasure — deepest vault, richest loot, dragons

**How it works:**

1. The dungeon.dmm map loads with 4 directional helper markers
2. SSdungeon_generator expands from markers, placing templates or procedural rooms
3. Each room/hallway spawns new markers at its edges for further growth
4. Depth increases with each room from the entrance
5. Biome selection is depth-based — deeper = more dangerous
6. Procedural rooms (30% chance) are generated on-the-fly with biome-specific turfs, loot, and mobs
7. Template rooms (70% chance) use pre-made .dmm files
8. Loot is budget-controlled via the loot_pool system (key: "tomb_of_alotheos")
