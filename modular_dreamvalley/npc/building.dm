// NPC building (phase 5). An NPC builds from a blueprint: it picks a clear
// patch of ground, works out what each piece needs from the real crafting
// recipe, fetches the materials - picking up small logs, splitting felled logs
// with its axe, felling a tree if there is nothing else - and then places each
// piece exactly as a player does, standing next to the spot, facing it, and
// crafting the wall, door or bed. Pieces it cannot manage are skipped rather
// than stalling the whole house.

/// Blueprints: id = list(name, description, rows, legend).
/// Rows are read top to bottom. Legend letters name real crafting recipes.
/// "." must be clear ground inside; " " is ignored.
GLOBAL_LIST_INIT(npc_blueprints, list(
	"cabin" = list("a small cabin", "four wooden walls, a door and a straw bed inside", list(
		"WWWWW",
		"W...W",
		"W.B.W",
		"W...W",
		"WWDWW",
	)),
	"shed" = list("a lean-to shed", "three walls against the weather and a bed", list(
		"WWWW",
		"W.BW",
		"W..W",
	)),
	"hut" = list("a one-room hut", "a tight little wooden hut with a door", list(
		"WWW",
		"W.W",
		"WDW",
	)),
	"fence" = list("a fenced plot", "a ring of palisade for a garden or animals", list(
		"PPPPP",
		"P...P",
		"P...P",
		"P...P",
		"PP.PP",
	)),
	"camp" = list("a camp", "a straw bed beside a table, for sleeping out", list(
		"B.T",
	)),
))

/// Legend letter = crafting recipe name.
GLOBAL_LIST_INIT(npc_blueprint_legend, list(
	"W" = "wall (wood)",
	"D" = "wooden door",
	"B" = "bed, straw",
	"T" = "wooden table",
	"P" = "palisade (small log)",
))

/// Build order: furniture inside first, walls next, the door last from outside.
GLOBAL_LIST_INIT(npc_build_order, list("B", "T", "P", "W", "D"))

/proc/npc_recipe_named(recipe_name)
	for(var/datum/crafting_recipe/R as anything in GLOB.crafting_recipes)
		if(lowertext(R.name) == lowertext(recipe_name))
			return R
	return null

/// One piece of a building in progress.
/datum/npc_build_piece
	var/turf/spot
	var/letter
	var/datum/crafting_recipe/recipe
	var/attempts = 0
	var/done = FALSE

/datum/npc_build_piece/proc/is_built()
	if(recipe.ontile || !ispath(recipe.result, /turf))
		for(var/obj/O in spot)
			if(istype(O, recipe.result))
				return TRUE
		return FALSE
	return istype(spot, recipe.result)

// --- The task ------------------------------------------------------------------------------

/datum/npc_task/build
	name = "build"
	timeout = 40 MINUTES
	var/blueprint_id = "cabin"
	var/turf/origin
	var/list/datum/npc_build_piece/pieces
	var/datum/npc_build_piece/current
	/// "fetch" (getting materials) or "place" (building the current piece).
	var/stage = "fetch"
	var/crafting_until = 0
	var/atom/fetch_target

/datum/npc_task/build/possible(datum/npc_brain/B)
	// Wood can be had: an axe for trees and logs, or small logs lying about.
	return npc_has_item(B.body, /obj/item/rogueweapon/stoneaxe) || B.nearest(/obj/item/grown/log/tree/small, 8)

/datum/npc_task/build/Destroy()
	QDEL_LIST(pieces)
	current = null
	origin = null
	fetch_target = null
	return ..()

/datum/npc_task/build/tick()
	if(!origin)
		if(!choose_site())
			brain.note("You could find no clear ground to build [GLOB.npc_blueprints[blueprint_id][1]].")
			return NPC_TASK_FAILED
		brain.note("You mark out ground for [GLOB.npc_blueprints[blueprint_id][1]].")
		brain.body.emote("me", 1, "paces out a patch of ground, measuring it with [brain.body.p_their()] eyes.", TRUE, custom_me = TRUE)
		return NPC_TASK_CONTINUE
	if(crafting_until)
		if(brain.body.doing && world.time < crafting_until)
			return NPC_TASK_CONTINUE
		crafting_until = 0
		if(current.is_built())
			current.done = TRUE
			current = null
		else if(++current.attempts >= 3)
			brain.note("You couldn't manage the [current.recipe.name]; you leave it.")
			current.done = TRUE
			current = null
		return NPC_TASK_CONTINUE
	if(!current)
		current = next_piece()
		if(!current)
			brain.note("You finished building [GLOB.npc_blueprints[blueprint_id][1]].")
			brain.record.memories += "I built [GLOB.npc_blueprints[blueprint_id][1]] with my own hands."
			brain.record.save()
			brain.body.emote("me", 1, "steps back and looks over [brain.body.p_their()] work.", TRUE, custom_me = TRUE)
			return NPC_TASK_DONE
		stage = "fetch"
	if(stage == "fetch")
		return fetch_materials()
	return place_piece()

/datum/npc_task/build/proc/next_piece()
	for(var/letter in GLOB.npc_build_order)
		for(var/datum/npc_build_piece/P as anything in pieces)
			if(P.done || P.letter != letter)
				continue
			if(P.is_built())
				P.done = TRUE
				continue
			return P
	return null

/// Finds clear ground for the whole blueprint, with a step of room around it.
/datum/npc_task/build/proc/choose_site()
	var/list/rows = GLOB.npc_blueprints[blueprint_id][3]
	var/height = length(rows)
	var/width = length(rows[1])
	var/list/candidates = list()
	for(var/turf/open/T in view(10, brain.body))
		candidates += T
	candidates = shuffle(candidates)
	for(var/turf/T in candidates)
		if(site_clear(T, width, height))
			origin = T
			break
	if(!origin)
		return FALSE
	pieces = list()
	for(var/y in 1 to height)
		var/row = rows[y]
		for(var/x in 1 to width)
			var/letter = copytext(row, x, x + 1)
			var/recipe_name = GLOB.npc_blueprint_legend[letter]
			if(!recipe_name)
				continue
			var/datum/crafting_recipe/R = npc_recipe_named(recipe_name)
			if(!R)
				continue
			var/datum/npc_build_piece/P = new
			P.spot = locate(origin.x + x - 1, origin.y - y + 1, origin.z)
			P.letter = letter
			P.recipe = R
			pieces += P
	return length(pieces)

/datum/npc_task/build/proc/site_clear(turf/corner, width, height)
	for(var/x in -1 to width)
		for(var/y in -1 to height)
			var/turf/T = locate(corner.x + x, corner.y - y, corner.z)
			if(!T || !isopenturf(T) || T.density || istype(T, /turf/open/water) || istype(T, /turf/open/transparent))
				return FALSE
			var/area/A = get_area(T)
			if(!A?.outdoors)
				return FALSE
			for(var/atom/movable/M in T)
				if(M.density || istype(M, /obj/structure) || istype(M, /obj/machinery))
					return FALSE
	return TRUE

// --- Materials -------------------------------------------------------------------------------

/// Counts what the builder has in reach (carried, or on its own and the next tiles).
/datum/npc_task/build/proc/have(material_type)
	. = 0
	for(var/obj/item/I in brain.body.get_all_gear())
		if(istype(I, material_type))
			. += 1
	for(var/obj/item/I in range(1, brain.body))
		if(isturf(I.loc) && istype(I, material_type))
			. += 1

/// The first requirement the builder lacks, and how many more it needs.
/datum/npc_task/build/proc/missing()
	for(var/material_type in current.recipe.reqs)
		var/need = current.recipe.reqs[material_type]
		var/got = have(material_type)
		if(got < need)
			return list(material_type, need - got)
	return null

/datum/npc_task/build/proc/fetch_materials()
	var/list/lack = missing()
	if(!lack)
		stage = "place"
		return NPC_TASK_CONTINUE
	var/material_type = lack[1]
	// Already carrying something to put down? Keep one hand free to pick up.
	var/obj/item/I = fetch_target
	if(istype(I) && !QDELETED(I) && isturf(I.loc))
		if(!brain.arrived(I, 1))
			if(!brain.walk_to_atom(I, 1))
				fetch_target = null
			return NPC_TASK_CONTINUE
		if(!body_free_hand(brain.body) || !brain.body.put_in_active_hand(I))
			// Hands full: carry what we have back to the site first.
			fetch_target = null
			return walk_back_to_site()
		fetch_target = null
		return NPC_TASK_CONTINUE
	// Lying about?
	fetch_target = brain.nearest(material_type, NPC_SEARCH_RANGE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_loose_goods)))
	if(fetch_target)
		return NPC_TASK_CONTINUE
	if(ispath(material_type, /obj/item/grown/log/tree/small))
		return make_small_logs()
	// Something we can't find or make: leave this piece.
	brain.note("You have no [initial(material_type:name)] for the [current.recipe.name].")
	current.done = TRUE
	current = null
	return NPC_TASK_CONTINUE

/// Split a felled log with the axe, or fell a tree if there is no log.
/datum/npc_task/build/proc/make_small_logs()
	if(!npc_has_item(brain.body, /obj/item/rogueweapon/stoneaxe))
		brain.note("You need wood and have no axe to cut it.")
		current.done = TRUE
		current = null
		return NPC_TASK_CONTINUE
	var/obj/item/grown/log/tree/big = brain.nearest(/obj/item/grown/log/tree, NPC_SEARCH_RANGE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_whole_log)))
	var/atom/work = big || brain.nearest(/obj/structure/flora/roguetree, NPC_SEARCH_RANGE + 4, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_standing_tree)))
	if(!work)
		brain.note("There is no wood anywhere near.")
		return NPC_TASK_FAILED
	if(!brain.arrived(work, 1))
		if(!brain.walk_to_atom(work, 1))
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	if(!brain.wield(/obj/item/rogueweapon/stoneaxe))
		return NPC_TASK_FAILED
	brain.use_intent(list(/datum/intent/axe/chop))
	brain.click(work)
	return NPC_TASK_CONTINUE

/proc/npc_whole_log(obj/item/grown/log/tree/L)
	return isturf(L.loc) && L.type == /obj/item/grown/log/tree

/datum/npc_task/build/proc/walk_back_to_site()
	if(brain.arrived(current.spot, 2))
		return NPC_TASK_CONTINUE
	brain.walk_to_atom(current.spot, 1)
	return NPC_TASK_CONTINUE

// --- Placing -------------------------------------------------------------------------------

/// Where to stand to build a piece: on it for things built underfoot, else beside it.
/datum/npc_task/build/proc/work_spot()
	if(current.recipe.ontile)
		return current.spot
	var/list/footprint = list()
	for(var/datum/npc_build_piece/P as anything in pieces)
		footprint += P.spot
	var/turf/best
	for(var/dir in GLOB.cardinals)
		var/turf/T = get_step(current.spot, dir)
		if(!T || !isopenturf(T) || T.density)
			continue
		// Walls and doors are built from outside the footprint, so the builder
		// never walls itself in; furniture from inside.
		var/outside = !(T in footprint) && !npc_inside_blueprint(T, origin, GLOB.npc_blueprints[blueprint_id][3])
		if(current.letter in list("W", "D", "P"))
			if(outside)
				return T
		else if(!outside)
			return T
		best = best || T
	return best

/proc/npc_inside_blueprint(turf/T, turf/origin, list/rows)
	var/x = T.x - origin.x + 1
	var/y = origin.y - T.y + 1
	return T.z == origin.z && y >= 1 && y <= length(rows) && x >= 1 && x <= length(rows[1])

/datum/npc_task/build/proc/place_piece()
	if(missing())
		stage = "fetch"
		return NPC_TASK_CONTINUE
	var/turf/stand = work_spot()
	if(!stand)
		current.done = TRUE
		current = null
		return NPC_TASK_CONTINUE
	if(get_turf(brain.body) != stand)
		if(!brain.walk_to_atom(stand, 0))
			if(++current.attempts >= 3)
				current.done = TRUE
				current = null
		return NPC_TASK_CONTINUE
	brain.stop_walking()
	if(stand != current.spot)
		brain.body.setDir(get_dir(stand, current.spot))
	// Materials in hand get in the way of nothing; crafting reads hands, bag and the tiles around.
	var/datum/component/personal_crafting/craft = brain.body.GetComponent(/datum/component/personal_crafting)
	if(!craft)
		return NPC_TASK_FAILED
	INVOKE_ASYNC(craft, TYPE_PROC_REF(/datum/component/personal_crafting, construct_item), brain.body, current.recipe)
	crafting_until = world.time + max(current.recipe.time * 3, 10 SECONDS) + 2 SECONDS
	return NPC_TASK_CONTINUE

// --- Choosing what to build ------------------------------------------------------------------

/datum/npc_brain/proc/start_build(blueprint_id, why = "")
	if(!GLOB.npc_blueprints[blueprint_id])
		blueprint_id = "cabin"
	var/datum/npc_task/build/T = new(src)
	T.blueprint_id = blueprint_id
	if(!T.possible(src))
		qdel(T)
		return FALSE
	end_task()
	task = T
	task_why = why
	return TRUE
