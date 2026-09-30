/// Dungeon framework core definitions.
///
/// This file defines the missing pieces that the dungeon_generator subsystem
/// (code/controllers/subsystem/dungeon_generator.dm) depends on:
///
///   - /turf/closed/dungeon_void: the "empty" turf that rooms replace
///   - /obj/effect/dungeon_directional_helper: markers that seed room growth
///   - /datum/map_template/dungeon: base template type with connection offsets
///   - /area/rogue/under/tomb: the dungeon area used by .dmm templates
///
/// Without these, the generator's subtypesof() calls return empty lists and
/// the dungeon never generates.

// ============================================================================
// Void turf — the "nothing" that dungeon rooms carve out of
// ============================================================================

/turf/closed/dungeon_void
	name = "void"
	desc = "The dungeon has not yet reached here."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "rockyashbed"
	density = TRUE
	opacity = TRUE
	/// Prevents mining/tunneling into void before generation fills it.
	max_integrity = 10000000
	damage_deflection = 99999999

/turf/closed/dungeon_void/attackby(obj/item/I, mob/user, params)
	return FALSE

/turf/closed/dungeon_void/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/dungeon_void/acid_act(acidpwr, acid_volume, acid_id)
	return 0

/turf/closed/dungeon_void/Melt()
	to_be_destroyed = FALSE
	return src

// ============================================================================
// Directional helper — marker object placed in the dungeon .dmm map
// ============================================================================

/obj/effect/dungeon_directional_helper
	name = "dungeon marker"
	desc = "Marks a direction for dungeon generation to expand."
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = FALSE
	/// Direction in which generation should expand from this marker.
	/// Set by subtypes or by the map.
	var/spawn_dir = null

/obj/effect/dungeon_directional_helper/Initialize(mapload)
	. = ..()
	if(spawn_dir)
		dir = spawn_dir
	else if(dir)
		spawn_dir = dir

/obj/effect/dungeon_directional_helper/north
	name = "dungeon marker (north)"
	spawn_dir = NORTH

/obj/effect/dungeon_directional_helper/south
	name = "dungeon marker (south)"
	spawn_dir = SOUTH

/obj/effect/dungeon_directional_helper/east
	name = "dungeon marker (east)"
	spawn_dir = EAST

/obj/effect/dungeon_directional_helper/west
	name = "dungeon marker (west)"
	spawn_dir = WEST

// ============================================================================
// Dungeon map template — base type for room/hallway templates
// ============================================================================

/datum/map_template/dungeon
	/// Weight for how often this template type is selected (higher = more common).
	var/type_weight = 10
	/// Connection offsets: where on each edge the "doorway" is.
	/// null = no connection on that edge.
	/// For NORTH/SOUTH: x-offset from the left edge (0-based).
	/// For EAST/WEST: y-offset from the bottom edge (0-based).
	var/north_offset = null
	var/south_offset = null
	var/east_offset = null
	var/west_offset = null
	/// Biome tag — used by the multi-biome generator to group templates.
	/// Examples: "crypt", "cave", "sewer", "ruins", "lair"
	var/biome = "crypt"
	/// Depth tier — controls how deep in the dungeon this template can appear.
	/// 0 = any depth, 1 = shallow, 2 = mid, 3 = deep
	var/depth_tier = 0
	/// If TRUE, this template is a hallway/corridor rather than a room.
	var/is_hallway = FALSE

/// Entry template — the starting room of the dungeon.
/// This is excluded from normal generation (see Initialize() in dungeon_generator.dm).
/datum/map_template/dungeon/entry
	abstract_type = /datum/map_template/dungeon/entry

// ============================================================================
// Tomb area — used by the dungeon .dmm template files
// ============================================================================

/area/rogue/under/tomb
	name = "tomb"
	icon_state = "tomb"
	droning_sound = 'sound/music/area/dungeon2.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ambientsounds = AMB_GENCAVE
	ambientnight = AMB_GENCAVE
	spookysounds = SPOOKY_CAVE
	spookynight = SPOOKY_CAVE
	ceiling_protected = TRUE
	loot_budget = LOOT_BUDGET_NECRAN_LABYRINTH
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/indoors
	name = "tomb interior"
	icon_state = "tomb_i"

// Sub-areas used by the room .dmm templates in _maps/dungeon_generator.
/area/rogue/under/tomb/indoors/church
	name = "abandoned chapel"

/area/rogue/under/tomb/indoors/royal
	name = "forgotten royal hall"

/area/rogue/under/tomb/cave/lava
	name = "burning caverns"

/area/rogue/under/tomb/cave/wet
	name = "dripping caverns"

/area/rogue/under/tomb/wilds
	name = "overgrown depths"
	icon_state = "cave"

// ============================================================================
// Getting in and out of the tomb
// ============================================================================

GLOBAL_LIST_EMPTY(dungeon_entrances)

/// A collapsed tomb mouth on the surface. Leads down to the tomb's center.
/obj/structure/dungeon_entry
	name = "collapsed tomb entrance"
	desc = "Worn steps lead down into the dark, into the Tomb of Alotheos. The air from below is cold and old."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "ladderearth"
	anchored = TRUE
	density = FALSE
	var/dungeon_id = "center"

/obj/structure/dungeon_entry/Initialize(mapload)
	. = ..()
	GLOB.dungeon_entrances += src

/obj/structure/dungeon_entry/Destroy()
	GLOB.dungeon_entrances -= src
	return ..()

/obj/structure/dungeon_entry/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/obj/structure/dungeon_exit/exit = locate_exit()
	if(!exit)
		to_chat(user, span_warning("The way down is choked with rubble."))
		return
	user.visible_message(span_notice("[user] starts down into the tomb."), span_notice("I start down the worn steps."))
	if(!do_after(user, 3 SECONDS, target = src))
		return
	user.forceMove(get_turf(exit))

/obj/structure/dungeon_entry/proc/locate_exit()
	for(var/obj/structure/dungeon_exit/exit in GLOB.dungeon_exits)
		if(exit.dungeon_id == dungeon_id)
			return exit

GLOBAL_LIST_EMPTY(dungeon_exits)

/// The way back up, placed at the tomb's center.
/obj/structure/dungeon_exit
	name = "tomb stairs"
	desc = "Steps climbing back toward daylight."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "ladder11"
	anchored = TRUE
	density = FALSE
	var/dungeon_id = "center"

/obj/structure/dungeon_exit/Initialize(mapload)
	. = ..()
	GLOB.dungeon_exits += src

/obj/structure/dungeon_exit/Destroy()
	GLOB.dungeon_exits -= src
	return ..()

/obj/structure/dungeon_exit/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/obj/structure/dungeon_entry/entry
	for(var/obj/structure/dungeon_entry/E in GLOB.dungeon_entrances)
		if(E.dungeon_id == dungeon_id)
			entry = E
			break
	if(!entry)
		to_chat(user, span_warning("The way up has collapsed."))
		return
	user.visible_message(span_notice("[user] starts climbing out of the tomb."), span_notice("I start the long climb up."))
	if(!do_after(user, 3 SECONDS, target = src))
		return
	user.forceMove(get_turf(entry))

/// If the surface map has no entrance, open one in a cave so the tomb is reachable.
/proc/ensure_dungeon_entrance()
	if(length(GLOB.dungeon_entrances) || !length(GLOB.dungeon_exits))
		return
	for(var/attempt in 1 to 400)
		var/turf/T = locate(rand(1, world.maxx), rand(1, world.maxy), rand(2, world.maxz))
		if(!isfloorturf(T) || T.density)
			continue
		var/area/A = get_area(T)
		if(!istype(A, /area/rogue/under/cave) || istype(A, /area/rogue/under/tomb))
			continue
		var/blocked = FALSE
		for(var/atom/movable/AM in T)
			if(AM.density)
				blocked = TRUE
				break
		if(blocked)
			continue
		new /obj/structure/dungeon_entry(T)
		log_world("Tomb of Alotheos entrance placed at [T.x],[T.y],[T.z].")
		return

// ============================================================================
// Multi-biome area definitions
// ============================================================================

/area/rogue/under/tomb/crypt
	name = "ancient crypt"
	icon_state = "crypt"
	ambientsounds = AMB_GENCAVE
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/cave
	name = "caverns"
	icon_state = "cave"
	ambientsounds = AMB_GENCAVE
	droning_sound = 'sound/music/area/decap.ogg'
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/sewer
	name = "flooded sewers"
	icon_state = "sewer"
	ambientsounds = AMB_BEACH
	droning_sound = 'sound/music/area/dungeon2.ogg'
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/ruins
	name = "sunken ruins"
	icon_state = "ruins"
	ambientsounds = AMB_GENCAVE
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/lair
	name = "monster lair"
	icon_state = "lair"
	ambientsounds = SPOOKY_CAVE
	droning_sound = 'sound/music/area/dragonden.ogg'
	loot_pool_key = "tomb_of_alotheos"

/area/rogue/under/tomb/treasure
	name = "treasure vault"
	icon_state = "treasure"
	loot_budget = LOOT_BUDGET_LICH_ARENA
	loot_pool_key = "tomb_of_alotheos"
	ceiling_protected = TRUE
