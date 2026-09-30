// NPC social life (phase 6). A home it returns to and a bed it thinks of as its
// own; a day with a rhythm; reflection that turns the day into lasting beliefs;
// feelings about people that change what it does - helping friends, keeping
// clear of enemies, fighting back or running when struck; and a village's worth
// of talk: things witnessed become news that NPCs carry and pass on.

/// How often an NPC stops to reflect on what has happened.
#define NPC_REFLECT_INTERVAL (15 MINUTES)
/// News kept in the village's memory.
#define NPC_RUMOR_CAP 30

/// Things that happened that people talk about: list(text, world.time).
GLOBAL_LIST_EMPTY(npc_rumors)

/proc/npc_add_rumor(text)
	GLOB.npc_rumors += list(list(text, world.time))
	if(length(GLOB.npc_rumors) > NPC_RUMOR_CAP)
		GLOB.npc_rumors.Cut(1, 2)

/proc/npc_recent_rumors(count = 4)
	. = list()
	for(var/i in length(GLOB.npc_rumors) to 1 step -1)
		var/list/R = GLOB.npc_rumors[i]
		if(world.time - R[2] > 2 HOURS)
			break
		. += R[1]
		if(length(.) >= count)
			break

/datum/npc_record
	/// Where this NPC's own house stands this round: list(x, y, z, round id, bed x, bed y).
	var/list/house

/datum/npc_brain
	var/next_reflect = 0
	var/reflecting = FALSE
	/// Things noticed since the last reflection, to be turned into beliefs.
	var/unreflected = 0

// --- Home ------------------------------------------------------------------------------

/datum/npc_record/proc/house_turf()
	if(!islist(house) || length(house) < 4 || "[house[4]]" != "[GLOB.round_id]")
		return null
	return locate(house[1], house[2], house[3])

/datum/npc_record/proc/house_bed()
	if(!islist(house) || length(house) < 6 || !house_turf())
		return null
	var/turf/T = locate(house[5], house[6], house[3])
	return T ? (locate(/obj/structure/bed) in T) : null

/// Called when a build finishes.
/datum/npc_task/build/finish()
	if(!origin || !brain)
		return
	var/finished = TRUE
	for(var/datum/npc_build_piece/P as anything in pieces)
		if(!P.done)
			finished = FALSE
	if(!finished)
		// Remember the half-built site so the house can be finished later.
		brain.record.house = list(origin.x, origin.y, origin.z, "[GLOB.round_id]", 0, 0, blueprint_id, "unfinished")
		return
	var/bed_x = 0
	var/bed_y = 0
	for(var/datum/npc_build_piece/P as anything in pieces)
		if(P.letter == "B")
			bed_x = P.spot.x
			bed_y = P.spot.y
	brain.record.house = list(origin.x, origin.y, origin.z, "[GLOB.round_id]", bed_x, bed_y, blueprint_id, "done")
	brain.record.save()

/// Rebuilding picks up the same site if the last house was left unfinished.
/datum/npc_task/build/choose_site()
	var/list/H = brain.record.house
	if(islist(H) && length(H) >= 8 && H[8] == "unfinished" && "[H[4]]" == "[GLOB.round_id]" && H[7] == blueprint_id)
		var/turf/T = locate(H[1], H[2], H[3])
		if(T)
			origin = T
			var/list/rows = GLOB.npc_blueprints[blueprint_id][3]
			pieces = list()
			for(var/y in 1 to length(rows))
				for(var/x in 1 to length(rows[y]))
					var/letter = copytext(rows[y], x, x + 1)
					var/datum/crafting_recipe/R = npc_recipe_named(GLOB.npc_blueprint_legend[letter])
					if(!R)
						continue
					var/datum/npc_build_piece/P = new
					P.spot = locate(origin.x + x - 1, origin.y - y + 1, origin.z)
					P.letter = letter
					P.recipe = R
					pieces += P
			return length(pieces)
	return ..()

/// Sleep in your own bed if you have one.
/datum/npc_task/sleep/New(datum/npc_brain/brain)
	. = ..()
	var/obj/structure/bed/own = brain?.record.house_bed()
	if(own && own.z == brain.body.z && npc_free_bed(own))
		target = own

/// Home is your house if you built one, else your home area.
/datum/npc_task/go_home/possible(datum/npc_brain/B)
	var/turf/H = B.record.house_turf()
	if(H)
		return get_dist(B.body, H) > 3 && H.z == B.body.z
	return ..()

/datum/npc_task/go_home/tick()
	var/turf/H = brain.record.house_turf()
	if(H && !target)
		target = H
	return ..()

// --- The day's rhythm -------------------------------------------------------------------

/// What someone like this would usually be doing at this hour.
/datum/npc_brain/proc/routine_hint()
	switch(GLOB.tod)
		if("dawn")
			return "At dawn you usually wake, eat and get ready for the day."
		if("day")
			return record.job_title ? "By day you usually work at your trade." : "By day you usually get on with your chores and needs."
		if("dusk")
			return "At dusk you usually finish work and go to the tavern or spend time with people."
		if("night")
			return "At night you usually go home and sleep."
	return ""

/// Without the mind, the hour guides an idle choice.
/datum/npc_brain/decide_by_needs(list/N, list/options)
	var/static/list/need_task = list("thirst" = "drink", "hunger" = "eat", "tiredness" = "sleep", "pain" = "rest")
	for(var/need in need_task)
		if(N[need] > 40 && options[need_task[need]])
			return ..()
	var/list/by_hour = list(
		"dawn" = list("eat", "go_home", "work"),
		"day" = list("work", "gather", "chop_wood", "forage", "craft", "patrol"),
		"dusk" = list("tavern", "socialize", "leisure"),
		"night" = list("go_home", "sleep"),
	)
	for(var/id in by_hour[GLOB.tod] || list())
		if(options[id] && prob(60) && start_task(id, "It's that time of day"))
			return
	return ..()

// --- Reflection ---------------------------------------------------------------------------

/datum/npc_brain/process(seconds_per_tick)
	. = ..()
	if(. == PROCESS_KILL || !body || body.stat != CONSCIOUS || reflecting)
		return
	if(!next_reflect)
		next_reflect = world.time + NPC_REFLECT_INTERVAL
	if(world.time >= next_reflect && unreflected >= 4)
		reflect()

/datum/npc_brain/note(text)
	. = ..()
	unreflected++

/// Turns recent events into a few lasting beliefs.
/datum/npc_brain/proc/reflect()
	next_reflect = world.time + NPC_REFLECT_INTERVAL
	if(!SSnpc_mind.online || !length(log))
		return
	reflecting = TRUE
	var/list/messages = list(
		list("role" = "system", "content" = record.system_prompt() + "\n\nYou are thinking back over what has happened lately. Answer ONLY with JSON: {\"beliefs\": \[\"up to 3 short lasting conclusions, in your own words\"\], \"mood\": \"one or two words for how you feel now\"}"),
		list("role" = "user", "content" = "What happened lately:\n[jointext(log, "\n")]\nWhat do you make of it?"),
	)
	if(!SSnpc_mind.ask(messages, CALLBACK(src, PROC_REF(on_reflected)), 200, 0.7, TRUE))
		reflecting = FALSE

/datum/npc_brain/proc/on_reflected(text, error)
	reflecting = FALSE
	unreflected = 0
	var/list/reply = text ? npc_parse_reply(text) : null
	if(!reply)
		return
	var/list/beliefs = reply["beliefs"]
	if(islist(beliefs))
		for(var/belief in beliefs)
			var/line = npc_clean_line(belief, 200)
			if(line)
				record.memories += line
		while(length(record.memories) > NPC_MEMORY_CAP)
			record.memories.Cut(1, 2)
	record.mood = npc_clean_line(reply["mood"], 40) || record.mood
	record.save()
	// The log has been digested; keep only the last few lines.
	if(length(log) > 4)
		log.Cut(1, length(log) - 3)

/datum/npc_record
	/// How they feel lately, from reflection.
	var/mood = ""

/datum/npc_record/to_list()
	. = ..()
	.["house"] = house
	.["mood"] = mood

/datum/npc_record/from_list(list/L)
	. = ..()
	house = islist(L["house"]) ? L["house"] : null
	mood = L["mood"] || ""

/datum/npc_record/system_prompt()
	. = ..()
	if(mood)
		. += "\nLately you feel [mood]."

// --- Feelings about the people around them -----------------------------------------------

/// The situation, with how they feel about each person in view and the news.
/datum/npc_brain/situation()
	. = ..()
	var/list/feelings = list()
	for(var/mob/living/carbon/human/H in view(NPC_HEAR_RANGE, body))
		var/list/rel = record.relationships[H.name]
		if(H != body && rel)
			feelings += "[H.name]: [rel[2]]"
	if(length(feelings))
		. += "\nHow you feel about people here: [jointext(feelings, "; ")]."
	var/list/news = npc_recent_rumors(3)
	if(length(news))
		. += "\nNews going around: [jointext(news, " ")]"
	var/hint = routine_hint()
	if(hint)
		. += "\n[hint]"
	var/turf/H = record.house_turf()
	if(H)
		. += "\nYou have a house you built, [get_dist(body, H)] steps away."
	if(GLOB.dominant_faith_tracker?.dominant_domain)
		var/datum/domain/D = get_divine_domain(GLOB.dominant_faith_tracker.dominant_domain)
		if(D)
			. += "\nThe [D.name] holds sway over this land now."

/datum/npc_brain/proc/opinion_of(name)
	var/list/rel = record.relationships[name]
	return rel ? rel[1] : 0

/datum/npc_brain/proc/change_opinion(name, amount, reason)
	var/list/rel = record.relationships[name] || list(0, "")
	rel[1] = clamp(rel[1] + amount, -100, 100)
	rel[2] = reason || (rel[1] >= 40 ? "a friend" : (rel[1] >= 10 ? "you like them" : (rel[1] <= -40 ? "you hate them" : (rel[1] <= -10 ? "you dislike them" : "you barely know them"))))
	record.relationships[name] = rel
	record.save()

/// Help a friend who is hurt nearby.
/datum/npc_task/help_friend
	name = "help_friend"
	timeout = 2 MINUTES
	var/offered = FALSE

/datum/npc_task/help_friend/proc/hurt_friend(datum/npc_brain/B)
	for(var/mob/living/carbon/human/H in view(8, B.body))
		if(H != B.body && H.stat != DEAD && H.health < H.maxHealth * 0.6 && B.opinion_of(H.name) >= 20)
			return H
	return null

/datum/npc_task/help_friend/possible(datum/npc_brain/B)
	return hurt_friend(B)

/datum/npc_task/help_friend/tick()
	var/mob/living/carbon/human/friend = target || hurt_friend(brain)
	if(!friend || friend.stat == DEAD)
		return NPC_TASK_DONE
	target = friend
	if(!brain.arrived(friend, 1))
		if(!length(brain.path))
			brain.walk_to_atom(friend, 1)
		return NPC_TASK_CONTINUE
	if(offered)
		return friend.health >= friend.maxHealth * 0.8 ? NPC_TASK_DONE : NPC_TASK_CONTINUE
	offered = TRUE
	brain.body.face_atom(friend)
	// Food and drink are what most folk have to give.
	var/obj/item/gift = npc_has_item(brain.body, /obj/item/reagent_containers/food/snacks)
	if(gift && brain.hold(gift))
		if(friend.npc_brain)
			brain.body.dropItemToGround(gift)
			friend.put_in_hands(gift)
		else
			brain.body.offer_item(friend, gift)
	brain.body.emote("me", 1, "kneels beside [friend] and looks [friend.p_them()] over with worry.", TRUE, custom_me = TRUE)
	brain.change_opinion(friend.name, 3)
	return NPC_TASK_CONTINUE

/// Keep clear of someone you hate.
/datum/npc_task/avoid
	name = "avoid"
	timeout = 60 SECONDS

/datum/npc_task/avoid/proc/enemy(datum/npc_brain/B)
	for(var/mob/living/carbon/human/H in view(6, B.body))
		if(H != B.body && H.stat == CONSCIOUS && B.opinion_of(H.name) <= -30)
			return H
	return null

/datum/npc_task/avoid/possible(datum/npc_brain/B)
	return enemy(B)

/datum/npc_task/avoid/tick()
	var/mob/living/carbon/human/E = enemy(brain)
	if(!E)
		return NPC_TASK_DONE
	if(!length(brain.path))
		brain.walk_to_atom(get_ranged_target_turf(brain.body, get_dir(E, brain.body), 7), 1)
	return NPC_TASK_CONTINUE

/proc/npc_register_social_tasks()
	GLOB.npc_task_menu["help_friend"] = list("go to a friend who is hurt and help them", /datum/npc_task/help_friend)
	GLOB.npc_task_menu["avoid"] = list("keep away from someone you hate", /datum/npc_task/avoid)

/datum/controller/subsystem/npc_mind/Initialize(start_timeofday)
	npc_register_social_tasks()
	return ..()

// --- Reacting to the world --------------------------------------------------------------------

/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(npc_brain && user && user != src)
		npc_brain.on_attacked(user, I)

/datum/npc_brain/proc/on_attacked(mob/living/attacker, obj/item/weapon)
	if(!body || body.stat != CONSCIOUS)
		return
	var/was_friend = opinion_of(attacker.name) >= 20
	note("[attacker.name] struck you[weapon ? " with [weapon.name]" : ""]!")
	change_opinion(attacker.name, was_friend ? -40 : -25, was_friend ? "they betrayed you and attacked you" : "they attacked you")
	npc_add_rumor("[attacker.name] attacked [body.real_name] near [get_area(body)].")
	// Bold folk with a weapon fight back; the rest run and shout.
	var/bold = record.traits["boldness"] >= 20
	var/armed = npc_has_item(body, /obj/item/rogueweapon)
	end_task()
	if(bold && armed)
		var/datum/npc_task/plan/P = new(src)
		perceive()
		var/id
		for(var/key in perceived)
			if(perceived[key] == attacker)
				id = key
		if(id)
			P.steps = list(list("do" = "attack", "on" = id))
			task = P
			task_why = "I'll not stand for that"
	else
		start_task("flee", "run")
	// And they say something about it, right away.
	addressed_by = attacker
	talking_with[attacker.name] = world.time
	if(!thinking)
		think()

/mob/living/carbon/human/death(gibbed, nocutscene = FALSE)
	var/who = real_name
	var/turf/where = get_turf(src)
	. = ..()
	if(!where)
		return
	var/witnessed = FALSE
	for(var/mob/living/carbon/human/H in view(7, where))
		if(H == src || !H.npc_brain || H.stat != CONSCIOUS)
			continue
		witnessed = TRUE
		var/datum/npc_brain/B = H.npc_brain
		B.note("You saw [who] die.")
		var/feeling = B.opinion_of(who)
		if(feeling >= 20)
			B.record.memories += "I watched [who], my friend, die."
			B.record.save()
			H.emote(pick("cry", "gasp", "scream"))
		else if(feeling <= -30)
			H.emote("me", 1, "looks down at [who]'s body without pity.", TRUE, custom_me = TRUE)
		else
			H.emote(pick("gasp", "shiver"))
	if(witnessed)
		npc_add_rumor("[who] died near [get_area(where)].")
	if(npc_brain)
		npc_brain.record.memories += "I died once, in [get_area(where)]. I remember the cold."
		npc_brain.record.save()
