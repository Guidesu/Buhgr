// More of an NPC's life (phase 4): working materials, keeping goods, faith,
// company and leisure. Each is a routine the mind can pick by name; anything not
// covered here the mind can still attempt step by step through a plan (actions.dm).

/// Loose things worth picking up and keeping.
GLOBAL_LIST_INIT(npc_goods_types, list(
	/obj/item/reagent_containers/food/snacks,
	/obj/item/grown/log/tree,
	/obj/item/natural,
	/obj/item/roguecoin,
	/obj/item/ingot,
	/obj/item/rogueore,
))

/proc/npc_loose_goods(obj/item/I)
	return isturf(I.loc) && !I.anchored

/// NPC and task add-ons to the menu.
/proc/npc_register_more_tasks()
	var/list/more = list(
		"butcher" = list("butcher a dead animal nearby with a knife", /datum/npc_task/butcher),
		"gather" = list("pick up useful things lying around (wood, food, coin, ore)", /datum/npc_task/gather),
		"store" = list("put the goods you carry away in a chest", /datum/npc_task/store),
		"mine" = list("dig at rock nearby with a pick", /datum/npc_task/mine),
		"craft" = list("make something you have the materials for", /datum/npc_task/craft),
		"pray" = list("pray to your god about what troubles you", /datum/npc_task/pray),
		"socialize" = list("go and talk to someone nearby", /datum/npc_task/socialize),
		"follow_friend" = list("keep company with someone you like", /datum/npc_task/follow_friend),
		"patrol" = list("walk a watchful round of your area", /datum/npc_task/patrol),
		"tavern" = list("go to the tavern or inn", /datum/npc_task/tavern),
		"leisure" = list("pass the time: sit, whistle, hum, stretch", /datum/npc_task/leisure),
		"build" = list("build something with your own hands - add \"blueprint\": [npc_blueprint_menu()]", /datum/npc_task/build),
	)
	for(var/id in more)
		GLOB.npc_task_menu[id] = more[id]

/datum/controller/subsystem/npc_mind/Initialize(start_timeofday)
	npc_register_more_tasks()
	return ..()

// --- Butcher -------------------------------------------------------------------------

/datum/npc_task/butcher
	name = "butcher"
	timeout = 2 MINUTES

/proc/npc_dead_animal(mob/living/simple_animal/A)
	return A.stat == DEAD

/datum/npc_task/butcher/possible(datum/npc_brain/B)
	return npc_has_item(B.body, /obj/item/rogueweapon/huntingknife) && B.nearest(/mob/living/simple_animal, 8, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_dead_animal)))

/datum/npc_task/butcher/tick()
	if(QDELETED(target))
		if(target)
			return NPC_TASK_DONE
		target = brain.nearest(/mob/living/simple_animal, 8, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_dead_animal)))
		if(!target)
			return NPC_TASK_FAILED
	if(!brain.arrived(target, 1))
		if(!brain.walk_to_atom(target, 1))
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	if(!brain.wield(/obj/item/rogueweapon/huntingknife))
		return NPC_TASK_FAILED
	brain.click(target)
	return NPC_TASK_CONTINUE

// --- Gather and store ------------------------------------------------------------------

/datum/npc_task/gather
	name = "gather"
	timeout = 2 MINUTES
	var/picked = 0

/datum/npc_task/gather/possible(datum/npc_brain/B)
	return B.nearest(GLOB.npc_goods_types, 6, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_loose_goods)))

/datum/npc_task/gather/tick()
	if(picked >= 6)
		return NPC_TASK_DONE
	var/obj/item/I = target
	if(QDELETED(I) || !isturf(I.loc))
		target = brain.nearest(GLOB.npc_goods_types, 6, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_loose_goods)))
		if(!target)
			return picked ? NPC_TASK_DONE : NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	if(!brain.arrived(I, 1))
		if(!brain.walk_to_atom(I, 1))
			target = null
		return NPC_TASK_CONTINUE
	if(body_free_hand(brain.body) && brain.body.put_in_active_hand(I))
		// Into the bag if there is room; otherwise carry it.
		if(!brain.body.equip_to_appropriate_slot(I))
			var/obj/item/storage/bag = locate() in brain.body.get_all_gear()
			if(bag)
				SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, I, brain.body, TRUE)
		picked++
	target = null
	return NPC_TASK_CONTINUE

/proc/body_free_hand(mob/living/carbon/human/H)
	if(!H.get_active_held_item())
		return TRUE
	H.swap_hand()
	return !H.get_active_held_item()

/datum/npc_task/store
	name = "store"
	timeout = 3 MINUTES

/datum/npc_task/store/proc/goods_on(datum/npc_brain/B)
	for(var/obj/item/I in B.body.get_all_gear())
		if(is_type_in_list(I, GLOB.npc_goods_types) && !istype(I, /obj/item/roguecoin))
			return I
	return null

/datum/npc_task/store/possible(datum/npc_brain/B)
	return goods_on(B) && B.nearest(/obj/structure/closet, NPC_SEARCH_RANGE)

/datum/npc_task/store/tick()
	var/obj/item/I = goods_on(brain)
	if(!I)
		return NPC_TASK_DONE
	if(!target)
		target = brain.nearest(/obj/structure/closet, NPC_SEARCH_RANGE)
		if(!target)
			return NPC_TASK_FAILED
	var/obj/structure/closet/C = target
	if(!brain.arrived(C, 1))
		if(!brain.walk_to_atom(C, 1))
			return NPC_TASK_FAILED
		return NPC_TASK_CONTINUE
	if(C.locked)
		return NPC_TASK_FAILED
	if(!C.opened)
		C.open(brain.body)
	if(!brain.hold(I))
		return NPC_TASK_FAILED
	brain.body.dropItemToGround(I)
	I.forceMove(get_turf(C))
	C.close(brain.body)
	return NPC_TASK_CONTINUE

// --- Mine ----------------------------------------------------------------------------

/datum/npc_task/mine
	name = "mine"
	timeout = 4 MINUTES

/datum/npc_task/mine/possible(datum/npc_brain/B)
	return npc_has_item(B.body, /obj/item/rogueweapon/pick) && B.nearest(/turf/closed/mineral, 8)

/datum/npc_task/mine/tick()
	if(!target || !istype(target, /turf/closed/mineral))
		if(target)
			return NPC_TASK_DONE
		target = brain.nearest(/turf/closed/mineral, 8)
		if(!target)
			return NPC_TASK_FAILED
	if(!brain.arrived(target, 1))
		if(!brain.walk_to_atom(target, 1))
			target = null
		return NPC_TASK_CONTINUE
	if(!brain.wield(/obj/item/rogueweapon/pick))
		return NPC_TASK_FAILED
	brain.click(target)
	return NPC_TASK_CONTINUE

// --- Craft ---------------------------------------------------------------------------

/datum/npc_task/craft
	name = "craft"
	timeout = 90 SECONDS
	var/started_craft = FALSE

/datum/npc_task/craft/possible(datum/npc_brain/B)
	return length(B.craftable_now(1))

/datum/npc_task/craft/tick()
	if(started_craft)
		return brain.body.doing ? NPC_TASK_CONTINUE : NPC_TASK_DONE
	var/list/options = brain.craftable_now(8)
	if(!length(options))
		return NPC_TASK_FAILED
	var/choice = brain.task_why && (brain.task_why in options) ? brain.task_why : pick(options)
	started_craft = brain.craft_named(choice)
	return started_craft ? NPC_TASK_CONTINUE : NPC_TASK_FAILED

// --- Pray ----------------------------------------------------------------------------

/datum/npc_task/pray
	name = "pray"
	timeout = 2 MINUTES
	var/asked = FALSE
	var/done = FALSE

/datum/npc_task/pray/possible(datum/npc_brain/B)
	return B.body.devotion && B.body.patron

/datum/npc_task/pray/tick()
	if(done)
		return NPC_TASK_DONE
	if(asked)
		return NPC_TASK_CONTINUE
	asked = TRUE
	var/list/messages = list(
		list("role" = "system", "content" = brain.record.system_prompt() + "\n\nYou kneel to pray. Write ONLY the words of your prayer, one to three sentences, in your own voice: name your god, say plainly what you ask for and for whom."),
		list("role" = "user", "content" = "[brain.situation()]\nYou feel [brain.needs_in_words(brain.needs())]. Pray."),
	)
	if(!SSnpc_mind.ask(messages, CALLBACK(src, PROC_REF(on_prayer)), 120, 0.8))
		return NPC_TASK_FAILED
	brain.body.visible_message(span_notice("[brain.body] kneels and bows [brain.body.p_their()] head."))
	return NPC_TASK_CONTINUE

/datum/npc_task/pray/proc/on_prayer(text, error)
	done = TRUE
	var/mob/living/carbon/human/H = brain?.body
	if(!H || !text || H.stat != CONSCIOUS)
		return
	text = npc_clean_line(text, 500)
	if(!text)
		return
	H.say(text, forced = "prayer")
	// Heard by the god exactly as a player's written prayer is.
	var/datum/action/cooldown/spell/prayer_base/scribe/written_prayer/P = new
	P.owner = H
	P.answer_prayer(H, H, text)
	qdel(P)
	brain.note("You prayed: \"[text]\"")

// --- Company --------------------------------------------------------------------------

/datum/npc_task/socialize
	name = "socialize"
	timeout = 2 MINUTES
	var/opened = FALSE
	var/waited = 0

/proc/npc_awake_person(mob/living/carbon/human/H)
	return H.stat == CONSCIOUS

/datum/npc_task/socialize/possible(datum/npc_brain/B)
	for(var/mob/living/carbon/human/H in view(8, B.body))
		if(H != B.body && H.stat == CONSCIOUS)
			return TRUE
	return FALSE

/datum/npc_task/socialize/tick()
	var/mob/living/carbon/human/other = target
	if(!other)
		var/list/people = list()
		for(var/mob/living/carbon/human/H in view(8, brain.body))
			if(H != brain.body && H.stat == CONSCIOUS)
				people += H
		if(!length(people))
			return NPC_TASK_FAILED
		// People they like first.
		for(var/mob/living/carbon/human/H in people)
			var/list/rel = brain.record.relationships[H.name]
			if(rel && rel[1] > 10)
				target = H
		if(!target)
			target = pick(people)
		return NPC_TASK_CONTINUE
	if(QDELETED(other) || other.stat != CONSCIOUS)
		return NPC_TASK_DONE
	if(!brain.arrived(other, 2))
		brain.stop_walking()
		brain.walk_to_atom(other, 2)
		return NPC_TASK_CONTINUE
	if(!opened)
		opened = TRUE
		brain.start_conversation(other)
		return NPC_TASK_CONTINUE
	if(++waited > 300)
		return NPC_TASK_DONE
	return NPC_TASK_CONTINUE

/// Opens a conversation with someone, the NPC speaking first.
/datum/npc_brain/proc/start_conversation(mob/living/other)
	addressed_by = other
	talking_with[other.name] = world.time
	note("You walk up to [other.name] to talk.")
	think()

/datum/npc_task/follow_friend
	name = "follow_friend"
	timeout = 4 MINUTES

/datum/npc_task/follow_friend/proc/friend(datum/npc_brain/B)
	for(var/mob/living/carbon/human/H in view(10, B.body))
		var/list/rel = B.record.relationships[H.name]
		if(H != B.body && H.stat == CONSCIOUS && rel && rel[1] >= 20)
			return H
	return null

/datum/npc_task/follow_friend/possible(datum/npc_brain/B)
	return friend(B)

/datum/npc_task/follow_friend/tick()
	if(!target || QDELETED(target))
		target = friend(brain)
		if(!target)
			return NPC_TASK_DONE
	if(get_dist(brain.body, target) > 12)
		return NPC_TASK_DONE
	if(!brain.arrived(target, 2) && !length(brain.path))
		brain.walk_to_atom(target, 1)
	return NPC_TASK_CONTINUE

// --- Watch, tavern, leisure --------------------------------------------------------------

/datum/npc_task/patrol
	name = "patrol"
	timeout = 4 MINUTES
	var/legs = 0

/datum/npc_task/patrol/possible(datum/npc_brain/B)
	var/job = lowertext(B.record.job_title || "")
	return findtext(job, "guard") || findtext(job, "watch") || findtext(job, "knight") || findtext(job, "soldier") || findtext(job, "man at arms") || findtext(job, "warden")

/datum/npc_task/patrol/tick()
	if(length(brain.path))
		return NPC_TASK_CONTINUE
	if(++legs > 6)
		return NPC_TASK_DONE
	var/list/spots = list()
	for(var/turf/open/T in view(10, brain.body))
		if(!T.density && get_dist(brain.body, T) >= 5)
			spots += T
	if(!length(spots))
		return NPC_TASK_DONE
	brain.walk_to_atom(pick(spots), 0)
	if(prob(20))
		brain.body.emote("me", 1, "keeps a watchful eye on [brain.body.p_their()] surroundings.", TRUE, custom_me = TRUE)
	return NPC_TASK_CONTINUE

/datum/npc_task/tavern
	name = "tavern"
	timeout = 5 MINUTES

/proc/npc_tavern_turf()
	for(var/area/A in world)
		var/n = lowertext(A.name)
		if(findtext(n, "tavern") || findtext(n, "inn"))
			var/turf/T = npc_home_turf(A.name)
			if(T)
				return T
	return null

/datum/npc_task/tavern/possible(datum/npc_brain/B)
	var/area/A = get_area(B.body)
	var/n = lowertext(A?.name)
	return !findtext(n, "tavern") && !findtext(n, "inn") && GLOB.tod != "dawn"

/datum/npc_task/tavern/tick()
	if(!target)
		target = npc_tavern_turf()
		if(!target || target.z != brain.body.z)
			return NPC_TASK_FAILED
	if(brain.arrived(target, 3))
		return NPC_TASK_DONE
	if(!length(brain.path) && !brain.walk_to_atom(target, 3))
		return NPC_TASK_FAILED
	return NPC_TASK_CONTINUE

/datum/npc_task/leisure
	name = "leisure"
	timeout = 2 MINUTES
	var/sat = FALSE

/datum/npc_task/leisure/tick()
	var/mob/living/carbon/human/H = brain.body
	if(!sat)
		var/obj/structure/chair/C = brain.nearest(/obj/structure/chair, 5)
		if(C && !length(C.buckled_mobs))
			if(!brain.arrived(C, 0))
				if(!brain.walk_to_atom(C, 0))
					sat = TRUE
				return NPC_TASK_CONTINUE
			C.buckle_mob(H)
		sat = TRUE
	if(prob(3))
		H.emote(pick("whistle", "hum", "stretch", "yawn", "sigh", "smile"))
	return NPC_TASK_CONTINUE

/datum/npc_task/leisure/finish()
	var/mob/living/carbon/human/H = brain?.body
	if(H?.buckled)
		H.buckled.unbuckle_mob(H)

/proc/npc_blueprint_menu()
	var/list/bits = list()
	for(var/id in GLOB.npc_blueprints)
		var/list/B = GLOB.npc_blueprints[id]
		bits += "\"[id]\" ([B[2]])"
	return jointext(bits, ", ")
