// The general action layer. Instead of only choosing from ready-made tasks, the
// mind can see everything around it and on it as a numbered list, and ask for a
// short plan of concrete steps on any of those things - pick up, hold, use one
// thing on another, touch, open, store, give, equip, craft, attack, follow, say,
// emote. Each step is carried out through the same clicks and procs a player's
// actions go through, so anything a player could do with those verbs, an NPC can
// try. What worked and what didn't goes back into its memory for the next thought.

#define NPC_PERCEIVE_RANGE 6
#define NPC_PERCEIVE_CAP 28

/datum/npc_brain
	/// id ("i3", "o7") = the atom it named, from the last look around.
	var/list/perceived = list()

/// Builds the numbered view of the world the mind plans against.
/datum/npc_brain/proc/perceive()
	perceived = list()
	var/list/lines = list()
	var/n = 0
	for(var/obj/item/I in body.get_all_gear())
		if(++n > 14)
			break
		var/id = "i[n]"
		perceived[id] = I
		var/where = (I in body.held_items) ? "in hand" : (I.loc == body ? "worn" : "carried in [I.loc]")
		lines += "[id]: [I.name] ([where])"
	var/list/near = list()
	for(var/atom/movable/A in view(NPC_PERCEIVE_RANGE, body))
		if(A == body || A.invisibility || !A.name || (A in body.get_all_gear()))
			continue
		if(!isitem(A) && !isliving(A) && !istype(A, /obj/structure) && !istype(A, /obj/machinery))
			continue
		if(istype(A, /obj/structure/flora/roguegrass) && !istype(A, /obj/structure/flora/roguegrass/bush))
			continue
		near += A
	GLOB.npc_sort_origin = body
	sortTim(near, GLOBAL_PROC_REF(cmp_npc_distance_to_brain_body))
	var/o = 0
	for(var/atom/movable/A as anything in near)
		if(++o > NPC_PERCEIVE_CAP)
			break
		var/id = "o[o]"
		perceived[id] = A
		lines += "[id]: [npc_describe_thing(A)], [get_dist(body, A)] steps [dir2text(get_dir(body, A)) || "here"]"
	for(var/turf/open/water/W in view(NPC_PERCEIVE_RANGE, body))
		var/id = "w1"
		perceived[id] = W
		lines += "[id]: water ([W.name]), [get_dist(body, W)] steps"
		break
	return jointext(lines, "\n")

/// For sorting: set before sorting a perception list.
GLOBAL_DATUM(npc_sort_origin, /atom)

/proc/cmp_npc_distance_to_brain_body(atom/A, atom/B)
	return get_dist(GLOB.npc_sort_origin, A) - get_dist(GLOB.npc_sort_origin, B)

/proc/npc_describe_thing(atom/movable/A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		return "[H.name] ([npc_describe_person(H)][H.stat == DEAD ? ", dead" : (H.stat ? ", unconscious" : "")])"
	if(isliving(A))
		var/mob/living/L = A
		return "[L.name] (creature[L.stat == DEAD ? ", dead" : ""])"
	if(istype(A, /obj/structure/closet))
		var/obj/structure/closet/C = A
		return "[A.name] (container, [C.opened ? "open" : "closed"][C.locked ? ", locked" : ""])"
	if(istype(A, /obj/item/reagent_containers/food/snacks))
		return "[A.name] (food)"
	if(istype(A, /obj/item/rogueweapon))
		return "[A.name] (weapon/tool)"
	if(isitem(A))
		return "[A.name] (item)"
	return "[A.name]"

// --- The plan task -----------------------------------------------------------------------

/// A short plan of concrete steps the mind wrote itself.
/datum/npc_task/plan
	name = "plan"
	timeout = 3 MINUTES
	var/list/steps = list()
	var/step_started = 0
	var/list/results = list()

/datum/npc_task/plan/tick()
	if(!length(steps))
		if(length(results))
			brain.note("How it went: [jointext(results, " ")]")
		return NPC_TASK_DONE
	var/list/S = steps[1]
	if(!step_started)
		step_started = world.time
	var/outcome = brain.do_step(S)
	if(outcome == NPC_TASK_CONTINUE && world.time - step_started < 40 SECONDS)
		return NPC_TASK_CONTINUE
	var/label = "[S["do"]][S["what"] ? " [brain.name_of(S["what"])]" : ""][S["on"] ? " on [brain.name_of(S["on"])]" : ""][S["to"] ? " to [brain.name_of(S["to"])]" : ""]"
	results += outcome == NPC_TASK_DONE ? "[label]: done." : "[label]: couldn't."
	steps.Cut(1, 2)
	step_started = 0
	brain.stop_walking()
	return NPC_TASK_CONTINUE

/datum/npc_brain/proc/thing(id)
	var/atom/A = perceived["[id]"]
	return (A && !QDELETED(A)) ? A : null

/datum/npc_brain/proc/name_of(id)
	var/atom/A = thing(id)
	return A ? A.name : "[id]"

/// Walks into reach of something. Returns TRUE once there.
/datum/npc_brain/proc/reach(atom/A, dist = 1)
	if(arrived(A, dist))
		return TRUE
	walk_to_atom(A, dist)
	return FALSE

/// Holds a specific item in the active hand.
/datum/npc_brain/proc/hold(obj/item/I)
	if(body.get_active_held_item() == I)
		return TRUE
	if(body.get_inactive_held_item() == I)
		body.swap_hand()
		return TRUE
	if(body.get_active_held_item())
		body.swap_hand()
		if(body.get_active_held_item() && !body.dropItemToGround(body.get_active_held_item()))
			return FALSE
	if(I.loc != body && !(I in body.get_all_gear()) && !arrived(I, 1))
		return FALSE
	return body.put_in_active_hand(I)

/// One step of a plan. Returns NPC_TASK_CONTINUE while working on it.
/datum/npc_brain/proc/do_step(list/S)
	var/atom/what = thing(S["what"])
	var/atom/on = thing(S["on"])
	var/atom/to_who = thing(S["to"])
	switch("[S["do"]]")
		if("go")
			if(!on && !to_who)
				return NPC_TASK_FAILED
			return reach(on || to_who, 1) ? NPC_TASK_DONE : NPC_TASK_CONTINUE
		if("pickup")
			var/obj/item/I = what || on
			if(!istype(I))
				return NPC_TASK_FAILED
			if(!reach(I, 1))
				return NPC_TASK_CONTINUE
			if(body.get_active_held_item())
				body.swap_hand()
			return body.put_in_active_hand(I) ? NPC_TASK_DONE : NPC_TASK_FAILED
		if("drop")
			var/obj/item/I = what
			if(!istype(I))
				return NPC_TASK_FAILED
			return body.dropItemToGround(I) ? NPC_TASK_DONE : NPC_TASK_FAILED
		if("hold")
			var/obj/item/I = what
			if(!istype(I))
				return NPC_TASK_FAILED
			if(I.loc != body && !(I in body.get_all_gear()) && !reach(I, 1))
				return NPC_TASK_CONTINUE
			return hold(I) ? NPC_TASK_DONE : NPC_TASK_FAILED
		if("use")
			// Use the held item (or this item) on something: chop, dig, cut, light, unlock...
			var/obj/item/I = what
			if(!on)
				return NPC_TASK_FAILED
			if(I && !hold(I))
				return I.loc == body || (I in body.get_all_gear()) ? NPC_TASK_FAILED : NPC_TASK_CONTINUE
			if(!reach(on, 1))
				return NPC_TASK_CONTINUE
			if(world.time < body.next_move)
				return NPC_TASK_CONTINUE
			click(on)
			// Keep at it while it is being worked (a tree, a rock, a carcass).
			if(!QDELETED(on) && S["until_gone"])
				return NPC_TASK_CONTINUE
			return NPC_TASK_DONE
		if("touch")
			// Empty hand: open a door or chest, search a bush, pull a lever, pick fruit.
			if(!on)
				return NPC_TASK_FAILED
			if(!reach(on, 1))
				return NPC_TASK_CONTINUE
			if(body.get_active_held_item())
				body.swap_hand()
				if(body.get_active_held_item())
					return NPC_TASK_FAILED
			if(world.time < body.next_move)
				return NPC_TASK_CONTINUE
			click(on)
			return NPC_TASK_DONE
		if("use_self")
			// Eat, drink, read, light, open: use the item on yourself or in hand.
			var/obj/item/I = what
			if(!istype(I) || !hold(I))
				return NPC_TASK_FAILED
			if(world.time < body.next_move)
				return NPC_TASK_CONTINUE
			if(istype(I, /obj/item/reagent_containers))
				I.melee_attack_chain(body, body)
			else
				I.attack_self(body)
			return NPC_TASK_DONE
		if("put")
			// Store an item into a container.
			var/obj/item/I = what
			if(!istype(I) || !on)
				return NPC_TASK_FAILED
			if(!hold(I))
				return NPC_TASK_FAILED
			if(!reach(on, 1))
				return NPC_TASK_CONTINUE
			if(istype(on, /obj/structure/closet))
				var/obj/structure/closet/C = on
				if(!C.opened)
					C.open(body)
			click(on)
			return I.loc == body ? NPC_TASK_FAILED : NPC_TASK_DONE
		if("give")
			var/obj/item/I = what
			var/mob/living/receiver = to_who || on
			if(!istype(I) || !istype(receiver))
				return NPC_TASK_FAILED
			if(!hold(I))
				return NPC_TASK_FAILED
			if(!reach(receiver, 1))
				return NPC_TASK_CONTINUE
			if(ishuman(receiver) && receiver:npc_brain)
				body.dropItemToGround(I)
				receiver.put_in_hands(I)
			else
				body.offer_item(receiver, I)
			return NPC_TASK_DONE
		if("equip")
			var/obj/item/I = what
			if(!istype(I) || !hold(I))
				return NPC_TASK_FAILED
			return body.equip_to_appropriate_slot(I) ? NPC_TASK_DONE : NPC_TASK_FAILED
		if("craft")
			return craft_named("[S["recipe"]]") ? NPC_TASK_DONE : NPC_TASK_FAILED
		if("attack")
			var/mob/living/victim = on || to_who
			if(!istype(victim) || victim.stat == DEAD)
				return victim ? NPC_TASK_DONE : NPC_TASK_FAILED
			if(!body.cmode)
				body.toggle_cmode()
			if(!reach(victim, 1))
				stop_walking()
				walk_to_atom(victim, 1)
				return NPC_TASK_CONTINUE
			click(victim)
			return NPC_TASK_CONTINUE
		if("follow")
			var/mob/living/leader = to_who || on
			if(!istype(leader))
				return NPC_TASK_FAILED
			if(!arrived(leader, 2))
				stop_walking()
				walk_to_atom(leader, 1)
			return NPC_TASK_CONTINUE
		if("say")
			var/line = npc_clean_line(S["text"], 300)
			if(line)
				body.say(line)
				note("You said: \"[line]\"")
			return NPC_TASK_DONE
		if("emote")
			var/line = npc_clean_line(S["text"], 200)
			if(line)
				body.emote("me", 1, line, TRUE, custom_me = TRUE)
			return NPC_TASK_DONE
		if("wait")
			return NPC_TASK_DONE
	return NPC_TASK_FAILED

// --- Crafting ----------------------------------------------------------------------------

/// Recipes the NPC could make right now with what is on and around them.
/datum/npc_brain/proc/craftable_now(limit = 12)
	. = list()
	var/datum/component/personal_crafting/craft = body.GetComponent(/datum/component/personal_crafting)
	if(!craft)
		return
	var/list/surroundings = craft.get_surroundings(body)
	for(var/datum/crafting_recipe/R as anything in GLOB.crafting_recipes)
		if(!R.name || !length(R.reqs))
			continue
		if(!craft.check_contents(R, surroundings) || !craft.check_tools(body, R, surroundings))
			continue
		. += R.name
		if(length(.) >= limit)
			break

/datum/npc_brain/proc/craft_named(recipe_name)
	var/datum/component/personal_crafting/craft = body.GetComponent(/datum/component/personal_crafting)
	if(!craft || !recipe_name)
		return FALSE
	for(var/datum/crafting_recipe/R as anything in GLOB.crafting_recipes)
		if(lowertext(R.name) != lowertext(recipe_name))
			continue
		INVOKE_ASYNC(craft, TYPE_PROC_REF(/datum/component/personal_crafting, construct_item), body, R)
		note("You set about making \a [R.name].")
		return TRUE
	return FALSE
