// NPC life (phase 3): drives and tasks. The body has needs read from the real
// game - hunger, thirst, energy, wounds, company - and a task it is doing. The
// mind chooses the next task when the last one ends, when a need turns urgent,
// or every few minutes; without the mind, the most urgent need decides. Tasks
// use the game's own mechanics exactly as a player would: walking step by step,
// clicking things, eating food, biting water, swinging an axe with a chop.

#define NPC_TASK_CONTINUE 0
#define NPC_TASK_DONE 1
#define NPC_TASK_FAILED 2

/// Think about what to do next at least this often.
#define NPC_DECIDE_INTERVAL (3 MINUTES)
/// Look this far for things to use.
#define NPC_SEARCH_RANGE 12

/// Wild animals it is fair to hunt. Livestock belongs to someone.
GLOBAL_LIST_INIT(npc_prey_types, list(
	/mob/living/simple_animal/hostile/retaliate/rogue/saiga,
	/mob/living/simple_animal/hostile/retaliate/rogue/fox,
	/mob/living/simple_animal/hostile/retaliate/rogue/mole,
	/mob/living/simple_animal/hostile/retaliate/rogue/bigrat,
	/mob/living/simple_animal/hostile/retaliate/rogue/mudcrab,
	/mob/living/simple_animal/hostile/retaliate/rogue/boar,
))

/datum/npc_brain
	var/datum/npc_task/task
	/// Why the current task was chosen, in the NPC's words.
	var/task_why = ""
	var/next_decide = 0
	var/deciding = FALSE
	/// Walking.
	var/list/path
	var/turf/path_goal
	var/path_min_dist = 0
	var/next_step = 0
	var/path_failures = 0

/datum/npc_brain/New(datum/npc_record/record, mob/living/carbon/human/body)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	next_decide = world.time + 5 SECONDS

/datum/npc_brain/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(task)
	path = null
	path_goal = null
	return ..()

// --- Needs --------------------------------------------------------------------------

/// Each need 0 (fine) to 100 (desperate).
/datum/npc_brain/proc/needs()
	var/list/N = list()
	N["hunger"] = clamp(round((NUTRITION_LEVEL_HUNGRY + 100 - body.nutrition) / 4), 0, 100)
	N["thirst"] = clamp(round((HYDRATION_LEVEL_THIRSTY + 100 - body.hydration) / 4), 0, 100)
	N["tiredness"] = clamp(round((1 - body.energy / max(1, body.max_energy)) * 120), 0, 100)
	N["pain"] = clamp(round((1 - body.health / max(1, body.maxHealth)) * 150), 0, 100)
	var/last_talk = 0
	for(var/who in talking_with)
		last_talk = max(last_talk, talking_with[who])
	N["loneliness"] = clamp(round((world.time - last_talk) / (20 MINUTES) * 60), 0, 60)
	return N

/datum/npc_brain/proc/needs_in_words(list/N)
	var/list/words = list()
	var/static/list/names = list("hunger" = "hungry", "thirst" = "thirsty", "tiredness" = "tired", "pain" = "hurt", "loneliness" = "lonely")
	for(var/need in N)
		var/v = N[need]
		if(v >= 70)
			words += "very [names[need]]"
		else if(v >= 35)
			words += names[need]
	return length(words) ? english_list(words) : "well enough"

// --- Tasks ----------------------------------------------------------------------------

/// What an NPC can set about doing: id = list(description, task type).
GLOBAL_LIST_INIT(npc_task_menu, list(
	"eat" = list("eat something you have or can find nearby", /datum/npc_task/eat),
	"drink" = list("drink from water nearby", /datum/npc_task/drink),
	"sleep" = list("find a bed, or lie down, and sleep a while", /datum/npc_task/sleep),
	"rest" = list("sit or stand quietly and rest", /datum/npc_task/rest),
	"wander" = list("stroll around nearby, looking about", /datum/npc_task/wander),
	"go_home" = list("walk back to your home area", /datum/npc_task/go_home),
	"chop_wood" = list("chop down a tree nearby with an axe", /datum/npc_task/chop_wood),
	"forage" = list("search nearby bushes for berries and herbs", /datum/npc_task/forage),
	"hunt" = list("hunt a wild animal nearby with your weapon", /datum/npc_task/hunt),
	"work" = list("go about your trade where you work", /datum/npc_task/work),
	"flee" = list("get away from danger", /datum/npc_task/flee),
))

/datum/npc_task
	var/name = "idle"
	var/datum/npc_brain/brain
	var/started
	var/timeout = 3 MINUTES
	var/atom/target

/datum/npc_task/New(datum/npc_brain/brain)
	src.brain = brain
	started = world.time

/datum/npc_task/Destroy()
	brain = null
	target = null
	return ..()

/// Whether it can be done at all right now (the menu only offers these).
/datum/npc_task/proc/possible(datum/npc_brain/B)
	return TRUE

/datum/npc_task/proc/tick()
	return NPC_TASK_DONE

/// Called when the task ends, for tidy-up.
/datum/npc_task/proc/finish()
	return

/datum/npc_brain/proc/start_task(id, why = "")
	var/list/entry = GLOB.npc_task_menu[id]
	if(!entry)
		return FALSE
	var/task_type = entry[2]
	var/datum/npc_task/T = new task_type(src)
	if(!T.possible(src))
		qdel(T)
		return FALSE
	end_task()
	task = T
	task_why = why
	return TRUE

/datum/npc_brain/proc/end_task()
	if(task)
		task.finish()
		QDEL_NULL(task)
	stop_walking()

// --- The life loop ---------------------------------------------------------------------

/datum/npc_brain/process(seconds_per_tick)
	if(!body || QDELETED(body))
		return PROCESS_KILL
	if(body.stat != CONSCIOUS || body.client)
		return
	// Talking comes first: stand and face the one you're speaking with.
	if(addressed_by && world.time - (talking_with[addressed_by.name] || -INFINITY) < 30 SECONDS && get_dist(body, addressed_by) <= NPC_HEAR_RANGE)
		stop_walking()
		return
	step_along_path()
	if(task)
		if(world.time - task.started > task.timeout)
			end_task()
		else
			var/result = task.tick()
			if(result != NPC_TASK_CONTINUE)
				end_task()
				next_decide = min(next_decide, world.time + 3 SECONDS)
	var/list/N = needs()
	var/urgent = FALSE
	for(var/need in N)
		if(N[need] >= 80)
			urgent = TRUE
	if(!deciding && (world.time >= next_decide || (!task && world.time >= next_decide - NPC_DECIDE_INTERVAL + 20 SECONDS) || (urgent && task && !(task.name in list("eat", "drink", "sleep", "flee")))))
		decide(N)

// --- Deciding --------------------------------------------------------------------------

/datum/npc_brain/proc/decide(list/N)
	next_decide = world.time + NPC_DECIDE_INTERVAL
	var/list/options = list()
	for(var/id in GLOB.npc_task_menu)
		var/list/entry = GLOB.npc_task_menu[id]
		var/task_type = entry[2]
		var/datum/npc_task/probe = new task_type(src)
		if(probe.possible(src))
			options[id] = entry[1]
		qdel(probe)
	if(!SSnpc_mind.online)
		decide_by_needs(N, options)
		return
	deciding = TRUE
	var/list/option_lines = list()
	for(var/id in options)
		option_lines += "- [id]: [options[id]]"
	var/seen = perceive()
	var/list/crafts = craftable_now(10)
	var/list/messages = list(
		list("role" = "system", "content" = record.system_prompt() + "\n\n" + decide_rules()),
		list("role" = "user", "content" = "[situation()]\nYou feel [needs_in_words(N)]. You are [task ? "currently doing: [task.name]" : "not doing anything"].\nWhat you can see and have (use these ids in a plan):\n[seen]\n[length(crafts) ? "You could make right now: [jointext(crafts, ", ")].\n" : ""]Routines you could start:\n[jointext(option_lines, "\n")]\nWhat do you do next?"),
	)
	if(!SSnpc_mind.ask(messages, CALLBACK(src, PROC_REF(on_decided), N, options), 260, 0.9, TRUE))
		deciding = FALSE
		decide_by_needs(N, options)

/datum/npc_brain/proc/decide_rules()
	return {"You decide what to do next with your time, like a real person living here. Answer ONLY with JSON, one of:
{"task": "a routine id from the list", "why": "a few words in your own voice", "mutter": "optional thing you say to yourself, or empty" }
or, to do something specific yourself:
{"plan": \[ up to 6 steps \], "why": "...", "mutter": "..." }
Plan steps (use the ids you were shown):
{"do":"go","on":"o3" } walk to something
{"do":"pickup","what":"o5" }  {"do":"drop","what":"i2" }  {"do":"hold","what":"i2" }  {"do":"equip","what":"i4" }
{"do":"use","what":"i2","on":"o7","until_gone":true} use a held thing on something (axe on tree, knife on carcass, key on door, torch on firepit)
{"do":"touch","on":"o4" } empty hand: open a door or chest, search a bush, sit, pull a lever
{"do":"use_self","what":"i3" } eat, drink or use an item
{"do":"put","what":"i2","on":"o6" } store it in a container
{"do":"give","what":"i2","to":"o1" }
{"do":"craft","recipe":"exact name from the list" }
{"do":"attack","on":"o2" }  {"do":"follow","to":"o1" }
{"do":"say","text":"..." }  {"do":"emote","text":"..." }  {"do":"wait" }
Be sensible: you only have two hands, and you must be able to reach things. Choose what someone like you would really do now."}

/datum/npc_brain/proc/on_decided(list/N, list/options, text, error)
	deciding = FALSE
	if(!body || QDELETED(body) || body.stat != CONSCIOUS)
		return
	var/list/reply = text ? npc_parse_reply(text) : null
	if(!reply)
		decide_by_needs(N, options)
		return
	var/why = npc_clean_line(reply["why"], 120) || ""
	var/started = FALSE
	var/list/steps = reply["plan"]
	if(islist(steps) && length(steps))
		var/datum/npc_task/plan/P = new(src)
		for(var/list/S in steps)
			if(islist(S) && S["do"])
				P.steps += list(S)
			if(length(P.steps) >= NPC_PLAN_MAX)
				break
		if(length(P.steps))
			end_task()
			task = P
			task_why = why
			started = TRUE
			note("You set out to: [why || "do a few things"].")
		else
			qdel(P)
	else
		var/choice = "[reply["task"]]"
		if(choice == "build" && options["build"])
			if(start_build("[reply["blueprint"]]", why))
				started = TRUE
				note("You decided to build [GLOB.npc_blueprints["[reply["blueprint"]]"] ? GLOB.npc_blueprints["[reply["blueprint"]]"][1] : "something"][why ? " ([why])" : ""].")
		else if(options[choice] && start_task(choice, why))
			started = TRUE
			note("You decided to [choice][why ? " ([why])" : ""].")
	if(!started)
		decide_by_needs(N, options)
		return
	var/mutter = npc_clean_line(reply["mutter"], 160)
	if(mutter && prob(60))
		body.say(mutter)

/// Without the mind: the most urgent need decides, else something ordinary.
/datum/npc_brain/proc/decide_by_needs(list/N, list/options)
	var/static/list/need_task = list("thirst" = "drink", "hunger" = "eat", "tiredness" = "sleep", "pain" = "rest")
	var/worst
	var/worst_value = 40
	for(var/need in need_task)
		if(N[need] > worst_value && options[need_task[need]])
			worst = need
			worst_value = N[need]
	if(worst)
		start_task(need_task[worst], "I need to")
		return
	var/list/ordinary = list()
	for(var/id in list("work", "wander", "rest", "forage", "go_home"))
		if(options[id])
			ordinary += id
	if(length(ordinary))
		start_task(pick(ordinary), "")

// --- Walking --------------------------------------------------------------------------

/datum/npc_brain/proc/walk_to_atom(atom/A, min_dist = 1)
	var/turf/T = get_turf(A)
	if(!T)
		return FALSE
	if(path_goal == T && length(path))
		return TRUE
	path_goal = T
	path_min_dist = min_dist
	path = get_path_to(body, T, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 60, 60, min_dist, adjacent = TYPE_PROC_REF(/turf, reachableTurftest3d))
	return length(path) || get_dist(body, T) <= min_dist

/datum/npc_brain/proc/stop_walking()
	path = null
	path_goal = null

/datum/npc_brain/proc/arrived(atom/A, min_dist = 1)
	return get_dist(body, A) <= min_dist

/datum/npc_brain/proc/step_along_path()
	if(!length(path) || world.time < next_step || body.incapacitated() || body.buckled)
		return
	var/turf/next = path[1]
	var/turf/before = get_turf(body)
	if(get_dist(body, next) > 1)
		path = null
		return
	body.setDir(get_dir(body, next))
	step(body, get_dir(body, next))
	if(get_turf(body) != before)
		path.Cut(1, 2)
		path_failures = 0
	else if(++path_failures >= 4)
		path_failures = 0
		// Something is in the way: find another way round.
		if(path_goal)
			path = get_path_to(body, path_goal, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d), 60, 60, path_min_dist, adjacent = TYPE_PROC_REF(/turf, reachableTurftest3d))
	// A walking pace, slowed by whatever slows the body.
	next_step = world.time + max(3, round(2 + (body.cached_multiplicative_slowdown || 0)))

// --- Hands ----------------------------------------------------------------------------

/// Puts an item of the given type in the active hand, from hands or inventory.
/datum/npc_brain/proc/wield(item_type)
	var/obj/item/held = body.get_active_held_item()
	if(istype(held, item_type))
		return held
	var/obj/item/other = body.get_inactive_held_item()
	if(istype(other, item_type))
		body.swap_hand()
		return other
	for(var/obj/item/I in body.get_all_gear())
		if(!istype(I, item_type) || (I in body.held_items))
			continue
		if(held)
			body.swap_hand()
			if(body.get_active_held_item())
				return null
		if(body.put_in_active_hand(I))
			return I
	return null

/// Picks the first of the held item's intents matching one of the given types.
/datum/npc_brain/proc/use_intent(list/intent_types)
	for(var/i in 1 to length(body.possible_a_intents))
		var/datum/intent/I = body.possible_a_intents[i]
		for(var/intent_type in intent_types)
			if(istype(I, intent_type))
				body.rog_intent_change(i, 0)
				return TRUE
	return FALSE

/// Swings at or uses something, the way a player's click does.
/datum/npc_brain/proc/click(atom/A)
	if(world.time < body.next_move)
		return
	body.face_atom(A)
	body.ClickOn(A, list())

/// Nearest thing of a type in sight, with an optional check.
/datum/npc_brain/proc/nearest(type_or_list, range = NPC_SEARCH_RANGE, datum/callback/check)
	var/atom/best
	var/best_dist = INFINITY
	var/list/types = islist(type_or_list) ? type_or_list : list(type_or_list)
	for(var/atom/A in view(range, body))
		if(!is_type_in_list(A, types))
			continue
		if(check && !check.Invoke(A))
			continue
		var/d = get_dist(body, A)
		if(d < best_dist)
			best = A
			best_dist = d
	return best

// ======================================================================================
// The tasks
// ======================================================================================

/datum/npc_task/eat
	name = "eat"
	timeout = 2 MINUTES

/datum/npc_task/eat/possible(datum/npc_brain/B)
	return B.body.nutrition < NUTRITION_LEVEL_FULL - 150 && find_food(B)

/datum/npc_task/eat/proc/find_food(datum/npc_brain/B)
	for(var/obj/item/reagent_containers/food/snacks/S in B.body.get_all_gear())
		return S
	return B.nearest(/obj/item/reagent_containers/food/snacks)

/datum/npc_task/eat/tick()
	var/mob/living/carbon/human/H = brain.body
	if(H.nutrition >= NUTRITION_LEVEL_FULL - 100)
		return NPC_TASK_DONE
	var/obj/item/reagent_containers/food/snacks/S = target
	if(QDELETED(S))
		S = find_food(brain)
		target = S
		if(!S)
			return NPC_TASK_DONE
	if(S.loc != H && !(S in H.get_all_gear()))
		if(!brain.arrived(S, 1))
			if(!brain.walk_to_atom(S, 1))
				return NPC_TASK_FAILED
			return NPC_TASK_CONTINUE
		if(!H.put_in_active_hand(S))
			return NPC_TASK_FAILED
	else if(H.get_active_held_item() != S)
		if(!brain.wield(S.type))
			return NPC_TASK_FAILED
	if(world.time >= H.next_move)
		S.melee_attack_chain(H, H)
	return NPC_TASK_CONTINUE

/datum/npc_task/drink
	name = "drink"
	timeout = 3 MINUTES
	var/drinking = FALSE

/datum/npc_task/drink/possible(datum/npc_brain/B)
	return B.body.hydration < HYDRATION_LEVEL_FULL - 150 && find_water(B)

/proc/npc_good_water(turf/open/water/W)
	return !istype(W, /turf/open/water/sewer) && !istype(W, /turf/open/water/bloody)

/datum/npc_task/drink/proc/find_water(datum/npc_brain/B)
	return B.nearest(/turf/open/water, NPC_SEARCH_RANGE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_good_water)))

/datum/npc_task/drink/tick()
	var/mob/living/carbon/human/H = brain.body
	if(H.hydration >= HYDRATION_LEVEL_FULL - 100)
		return NPC_TASK_DONE
	if(drinking)
		return NPC_TASK_CONTINUE
	if(!target)
		target = find_water(brain)
		if(!target)
			return NPC_TASK_FAILED
	if(!brain.arrived(target, 1))
		if(!brain.walk_to_atom(target, 1))
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	drinking = TRUE
	var/turf/open/water/W = target
	INVOKE_ASYNC(src, PROC_REF(do_drink), W)
	return NPC_TASK_CONTINUE

/datum/npc_task/drink/proc/do_drink(turf/open/water/W)
	var/mob/living/carbon/human/H = brain?.body
	if(!H)
		return
	H.face_atom(W)
	// A few mouthfuls, the same way a player drinks by biting the water.
	for(var/i in 1 to 8)
		if(QDELETED(src) || H.hydration >= HYDRATION_LEVEL_FULL - 100)
			break
		if(W.drink_act(H, H))
			break
	drinking = FALSE

/datum/npc_task/sleep
	name = "sleep"
	timeout = 8 MINUTES
	var/asleep = FALSE

/datum/npc_task/sleep/possible(datum/npc_brain/B)
	return B.needs()["tiredness"] >= 35 || GLOB.tod == "night"

/datum/npc_task/sleep/tick()
	var/mob/living/carbon/human/H = brain.body
	if(asleep)
		if(H.energy >= H.max_energy * 0.95 && GLOB.tod != "night")
			H.SetSleeping(0)
			H.set_resting(FALSE, TRUE)
			return NPC_TASK_DONE
		if(!H.IsSleeping())
			H.Sleeping(30 SECONDS)
		return NPC_TASK_CONTINUE
	if(!target)
		target = brain.nearest(/obj/structure/bed, NPC_SEARCH_RANGE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_free_bed)))
	if(target)
		if(!brain.arrived(target, 0))
			if(!brain.walk_to_atom(target, 0))
				target = null
			return NPC_TASK_CONTINUE
	H.visible_message(span_notice("[H] lies down to sleep."))
	H.set_resting(TRUE, TRUE)
	H.Sleeping(30 SECONDS)
	asleep = TRUE
	return NPC_TASK_CONTINUE

/datum/npc_task/sleep/finish()
	var/mob/living/carbon/human/H = brain?.body
	if(H && asleep)
		H.SetSleeping(0)
		H.set_resting(FALSE, TRUE)

/proc/npc_free_bed(obj/structure/bed/B)
	return !length(B.buckled_mobs) && !(locate(/mob/living) in get_turf(B))

/datum/npc_task/rest
	name = "rest"
	timeout = 90 SECONDS

/datum/npc_task/rest/tick()
	if(prob(2))
		brain.body.emote(pick("sigh", "yawn", "stretch"))
	return NPC_TASK_CONTINUE

/datum/npc_task/wander
	name = "wander"
	timeout = 2 MINUTES
	var/legs = 0

/datum/npc_task/wander/tick()
	if(length(brain.path))
		return NPC_TASK_CONTINUE
	if(++legs > 4)
		return NPC_TASK_DONE
	var/list/spots = list()
	for(var/turf/open/T in view(6, brain.body))
		if(!T.density && !istype(T, /turf/open/water) && !istype(T, /turf/open/transparent))
			spots += T
	if(!length(spots))
		return NPC_TASK_FAILED
	brain.walk_to_atom(pick(spots), 0)
	return NPC_TASK_CONTINUE

/datum/npc_task/go_home
	name = "go_home"
	timeout = 4 MINUTES

/datum/npc_task/go_home/possible(datum/npc_brain/B)
	if(!B.record.home)
		return FALSE
	var/area/A = get_area(B.body)
	return !A || lowertext(A.name) != lowertext(B.record.home)

/datum/npc_task/go_home/tick()
	if(!target)
		target = npc_home_turf(brain.record.home)
		if(!target || target.z != brain.body.z)
			return NPC_TASK_FAILED
	if(brain.arrived(target, 2))
		return NPC_TASK_DONE
	if(!brain.walk_to_atom(target, 2))
		return NPC_TASK_FAILED
	return NPC_TASK_CONTINUE

/datum/npc_task/chop_wood
	name = "chop_wood"
	timeout = 4 MINUTES

/datum/npc_task/chop_wood/possible(datum/npc_brain/B)
	return npc_has_item(B.body, /obj/item/rogueweapon/stoneaxe) && B.nearest(/obj/structure/flora/roguetree)

/datum/npc_task/chop_wood/tick()
	if(QDELETED(target) || !istype(target, /obj/structure/flora/roguetree) || istype(target, /obj/structure/flora/roguetree/stump))
		if(target)
			return NPC_TASK_DONE
		target = brain.nearest(/obj/structure/flora/roguetree, NPC_SEARCH_RANGE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_standing_tree)))
		if(!target)
			return NPC_TASK_FAILED
	if(!brain.arrived(target, 1))
		if(!brain.walk_to_atom(target, 1))
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	if(!brain.wield(/obj/item/rogueweapon/stoneaxe))
		return NPC_TASK_FAILED
	brain.use_intent(list(/datum/intent/axe/chop))
	brain.click(target)
	return NPC_TASK_CONTINUE

/proc/npc_standing_tree(obj/structure/flora/roguetree/T)
	return !istype(T, /obj/structure/flora/roguetree/stump) && !istype(T, /obj/structure/flora/roguetree/burnt)

/proc/npc_has_item(mob/living/carbon/human/H, item_type)
	for(var/obj/item/I in H.get_all_gear())
		if(istype(I, item_type))
			return I
	return null

/datum/npc_task/forage
	name = "forage"
	timeout = 2 MINUTES
	var/searched = 0

/datum/npc_task/forage/possible(datum/npc_brain/B)
	return B.nearest(/obj/structure/flora/roguegrass/bush)

/datum/npc_task/forage/tick()
	if(searched >= 3)
		return NPC_TASK_DONE
	if(QDELETED(target))
		target = brain.nearest(/obj/structure/flora/roguegrass/bush)
		if(!target)
			return NPC_TASK_DONE
	if(!brain.arrived(target, 1))
		if(!brain.walk_to_atom(target, 1))
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	if(world.time < brain.body.next_move)
		return NPC_TASK_CONTINUE
	// Empty-handed, like a player searching a bush.
	var/obj/item/held = brain.body.get_active_held_item()
	if(held)
		brain.body.swap_hand()
		if(brain.body.get_active_held_item())
			return NPC_TASK_FAILED
	brain.click(target)
	searched++
	target = null
	return NPC_TASK_CONTINUE

/datum/npc_task/hunt
	name = "hunt"
	timeout = 4 MINUTES

/datum/npc_task/hunt/possible(datum/npc_brain/B)
	return npc_has_item(B.body, /obj/item/rogueweapon) && B.nearest(GLOB.npc_prey_types, NPC_SEARCH_RANGE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_living_prey)))

/proc/npc_living_prey(mob/living/L)
	return L.stat != DEAD

/datum/npc_task/hunt/tick()
	var/mob/living/prey = target
	if(prey && prey.stat == DEAD)
		brain.note("You killed \a [prey.name].")
		return NPC_TASK_DONE
	if(QDELETED(prey))
		target = brain.nearest(GLOB.npc_prey_types, NPC_SEARCH_RANGE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_living_prey)))
		if(!target)
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	if(!brain.wield(/obj/item/rogueweapon))
		return NPC_TASK_FAILED
	if(!brain.arrived(prey, 1))
		// Chase: the animal moves, so keep re-aiming.
		brain.stop_walking()
		if(!brain.walk_to_atom(prey, 1))
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	brain.click(prey)
	return NPC_TASK_CONTINUE

/datum/npc_task/work
	name = "work"
	timeout = 4 MINUTES

/datum/npc_task/work/possible(datum/npc_brain/B)
	return !!B.record.job_title && GLOB.tod != "night"

/datum/npc_task/work/tick()
	// Go where you work, then keep busy there.
	if(brain.record.home)
		var/area/A = get_area(brain.body)
		if(!A || lowertext(A.name) != lowertext(brain.record.home))
			if(!target)
				target = npc_home_turf(brain.record.home)
			if(target && !brain.arrived(target, 2))
				if(!brain.walk_to_atom(target, 2))
					target = null
				return NPC_TASK_CONTINUE
	if(!length(brain.path) && prob(8))
		var/list/spots = list()
		for(var/turf/open/T in view(3, brain.body))
			if(!T.density)
				spots += T
		if(length(spots))
			brain.walk_to_atom(pick(spots), 0)
	if(prob(2))
		brain.body.emote("me", 1, pick("goes about [brain.body.p_their()] work.", "busies [brain.body.p_them()]self with [brain.body.p_their()] trade.", "wipes [brain.body.p_their()] hands and gets back to it."), TRUE, custom_me = TRUE)
	return NPC_TASK_CONTINUE

/datum/npc_task/flee
	name = "flee"
	timeout = 40 SECONDS

/datum/npc_task/flee/possible(datum/npc_brain/B)
	return B.needs()["pain"] >= 40 || B.threat()

/datum/npc_task/flee/tick()
	var/mob/living/danger = brain.threat()
	if(!danger)
		return NPC_TASK_DONE
	if(length(brain.path))
		return NPC_TASK_CONTINUE
	var/turf/away = get_ranged_target_turf(brain.body, get_dir(danger, brain.body), 8)
	if(!brain.walk_to_atom(away, 1))
		return NPC_TASK_FAILED
	return NPC_TASK_CONTINUE

/// The nearest thing that is trying to hurt us, if any.
/datum/npc_brain/proc/threat()
	for(var/mob/living/simple_animal/hostile/H in view(7, body))
		if(H.stat != DEAD && H.target == body)
			return H
	for(var/mob/living/carbon/human/H in view(7, body))
		if(H != body && H.stat == CONSCIOUS && H.cmode && istype(H.get_active_held_item(), /obj/item/rogueweapon) && record.relationships[H.name] && record.relationships[H.name][1] <= -40)
			return H
	return null
