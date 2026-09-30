// The NPC Workshop: make, keep and spawn NPC people. Frontend:
// tgui/packages/tgui/interfaces/NpcWorkshop.tsx

/datum/controller/subsystem/npc_mind/Initialize(start_timeofday)
	npc_load_records()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(npc_autospawn_all)))
	return ..()

/// Round start: bring every autospawn NPC into the world at home.
/proc/npc_autospawn_all()
	for(var/id in GLOB.npc_records)
		var/datum/npc_record/R = GLOB.npc_records[id]
		if(!R.autospawn)
			continue
		var/turf/T = npc_home_turf(R.home)
		if(T)
			R.spawn_at(T)

/// A free floor tile in the named area (by area name), or null.
/proc/npc_home_turf(home)
	if(!home)
		return null
	for(var/area/A in world)
		if(lowertext(A.name) != lowertext(home))
			continue
		var/list/floors = list()
		for(var/turf/open/floor/F in A)
			if(!F.density && !(locate(/mob/living) in F))
				floors += F
		if(length(floors))
			return pick(floors)
	return null

/client/proc/npc_workshop()
	set name = "NPC Workshop"
	set category = "Admin"
	if(!check_rights(R_SPAWN))
		return
	var/datum/npc_workshop/W = new(usr)
	W.ui_interact(usr)

/client/add_admin_verbs()
	. = ..()
	if(holder && check_rights_for(src, R_SPAWN))
		add_verb(src, /client/proc/npc_workshop)

/datum/npc_workshop
	var/mob/user
	var/datum/npc_record/editing
	var/test_reply
	var/test_pending = FALSE

/datum/npc_workshop/New(mob/user)
	src.user = user
	if(!length(GLOB.npc_records))
		npc_load_records()

/datum/npc_workshop/ui_state(mob/user)
	return ADMIN_STATE(R_SPAWN)

/datum/npc_workshop/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NpcWorkshop")
		ui.open()

/datum/npc_workshop/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/npc_workshop/ui_static_data(mob/user)
	var/list/species = list()
	for(var/path in NPC_RACES_TYPES)
		var/datum/species/S = path
		species += list(list("path" = "[path]", "name" = initial(S.name)))
	for(var/name in get_selectable_species())
		var/datum/species/S = GLOB.species_list[name]
		if(!S)
			continue
		var/path = "[S]"
		var/found = FALSE
		for(var/list/entry in species)
			if(entry["path"] == path)
				found = TRUE
				break
		if(!found)
			species += list(list("path" = path, "name" = name))
	var/list/origins = list(list("path" = "", "name" = "Nowhere in particular"))
	for(var/path in subtypesof(/datum/virtue/origin/palimpseste))
		var/datum/virtue/origin/O = path
		origins += list(list("path" = "[path]", "name" = capitalize(initial(O.origin_name))))
	var/list/domains = list(list("path" = "", "name" = "None", "gods" = list()))
	for(var/path in GLOB.divine_domains)
		var/datum/domain/D = GLOB.divine_domains[path]
		var/list/gods = list()
		for(var/god_type in D.gods)
			var/datum/patron/P = GLOB.patronlist[god_type]
			if(P)
				gods += list(list("path" = "[god_type]", "name" = P.name))
		domains += list(list("path" = "[path]", "name" = D.name, "gods" = gods))
	var/list/traits = list()
	for(var/axis in GLOB.npc_trait_axes)
		var/list/ends = GLOB.npc_trait_axes[axis]
		traits += list(list("id" = axis, "low" = ends[1], "high" = ends[2]))
	var/list/areas = list()
	for(var/area/A in world)
		if(A.z && length(A.contents))
			areas |= A.name
	return list(
		"species" = species,
		"origins" = origins,
		"domains" = domains,
		"jobs" = npc_job_choices(),
		"traits" = traits,
		"ages" = list("Young", "Adult", "Middle-Aged", "Old"),
		"areas" = sortList(areas),
	)

/datum/npc_workshop/ui_data(mob/user)
	var/list/records = list()
	for(var/id in GLOB.npc_records)
		var/datum/npc_record/R = GLOB.npc_records[id]
		records += list(list("id" = id, "name" = R.name, "summary" = R.summary(), "spawned" = !!R.spawned_mob(), "autospawn" = R.autospawn))
	var/list/current
	if(editing)
		current = editing.to_list()
		current["personality"] = editing.personality_words()
		current["spawned"] = !!editing.spawned_mob()
		current["saved"] = !!GLOB.npc_records[editing.id]
		var/mob/living/carbon/human/H = editing.spawned_mob()
		if(H?.npc_brain)
			var/datum/npc_brain/B = H.npc_brain
			current["doing"] = B.task ? B.task.name : (B.deciding ? "deciding" : "nothing")
			current["why"] = B.task_why
			current["needs"] = B.needs()
			current["log"] = B.log.Copy(max(1, length(B.log) - 5))
	return list(
		"records" = records,
		"editing" = current,
		"mind_online" = SSnpc_mind.online,
		"mind_answered" = SSnpc_mind.answered,
		"mind_failed" = SSnpc_mind.failed,
		"mind_latency" = round(SSnpc_mind.last_latency / 10, 0.1),
		"mind_queue" = length(SSnpc_mind.queue) + length(SSnpc_mind.active),
		"test_reply" = test_reply,
		"test_pending" = test_pending,
	)

/datum/npc_workshop/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(. || !check_rights(R_SPAWN))
		return
	switch(action)
		if("new")
			editing = new
			editing.id = npc_new_id()
			test_reply = null
			return TRUE
		if("roll")
			editing = npc_roll_random()
			editing.id = npc_new_id()
			test_reply = null
			return TRUE
		if("select")
			editing = GLOB.npc_records[params["id"]]
			test_reply = null
			return TRUE
		if("clone")
			if(!editing)
				return
			var/datum/npc_record/copy = new
			copy.from_list(editing.to_list())
			copy.id = npc_new_id()
			copy.name = "[editing.name] (copy)"
			copy.memories = list()
			copy.relationships = list()
			copy.created = null
			editing = copy
			return TRUE
		if("set")
			if(!editing)
				return
			set_field(params["field"], params["value"])
			return TRUE
		if("set_trait")
			if(editing && (params["trait"] in GLOB.npc_trait_axes))
				editing.traits[params["trait"]] = clamp(round(text2num("[params["value"]]")), -100, 100)
			return TRUE
		if("save")
			editing?.save()
			return TRUE
		if("delete")
			if(!editing)
				return
			editing.despawn()
			editing.remove()
			editing = null
			return TRUE
		if("spawn")
			if(!editing)
				return
			if(!GLOB.npc_records[editing.id])
				editing.save()
			var/mob/living/carbon/human/H = editing.spawn_at(get_turf(ui.user))
			if(H)
				log_admin("[key_name(ui.user)] spawned NPC [editing.name] at [AREACOORD(H)].")
			return TRUE
		if("despawn")
			editing?.despawn()
			return TRUE
		if("jump")
			var/mob/living/carbon/human/H = editing?.spawned_mob()
			if(H)
				ui.user.forceMove(get_turf(H))
			return TRUE
		if("test")
			if(!editing || test_pending)
				return
			var/said = copytext(trim("[params["text"]]"), 1, 400)
			if(!said)
				return
			test_pending = TRUE
			test_reply = null
			var/list/messages = list(
				list("role" = "system", "content" = editing.system_prompt()),
				list("role" = "user", "content" = "A stranger comes up to you and says: \"[said]\""),
			)
			if(!SSnpc_mind.ask(messages, CALLBACK(src, PROC_REF(on_test_reply)), 160))
				test_pending = FALSE
				test_reply = "(The NPC mind is not running. Start tools/dreamvalley/npc_ai/start_npc_ai.bat and wait for it to load.)"
			return TRUE

/datum/npc_workshop/proc/on_test_reply(text, error)
	test_pending = FALSE
	test_reply = text || "([error])"
	SStgui.update_uis(src)

/datum/npc_workshop/proc/set_field(field, value)
	var/text = "[value]"
	switch(field)
		if("name")
			var/clean = reject_bad_name(text, TRUE)
			if(clean)
				editing.name = clean
		if("gender")
			if(text in list(MALE, FEMALE))
				editing.gender = text
		if("age")
			editing.age = text
		if("species")
			var/path = text2path(text)
			if(ispath(path, /datum/species))
				editing.species_path = path
		if("job")
			editing.job_title = (text in npc_job_choices()) ? text : null
		if("origin")
			editing.origin_path = text ? text2path(text) : null
		if("domain")
			editing.domain_path = text ? text2path(text) : null
			editing.god_path = null
		if("god")
			editing.god_path = text ? text2path(text) : null
		if("speech")
			editing.speech = copytext(sanitize_text(text), 1, 300)
		if("backstory")
			editing.backstory = copytext(sanitize_text(text), 1, 2000)
		if("goals")
			editing.goals = copytext(sanitize_text(text), 1, 600)
		if("autospawn")
			editing.autospawn = !editing.autospawn
		if("home")
			editing.home = copytext(sanitize_text(text), 1, 100)
		if("forget")
			editing.memories = list()
			editing.relationships = list()
