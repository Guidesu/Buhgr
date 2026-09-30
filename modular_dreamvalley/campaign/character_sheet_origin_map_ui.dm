// Map-based origin picker for the Character Sheet's "Origin" field. Replaces
// the plain dropdown's browsing experience with a clickable region map of
// Vaeltis (Auxentia, Vergenmark, Ognica, Kamenrad, Via Medulla, Ostrovia) -
// clicking a region shows its lore blurb, and confirming applies it via the
// same set_origin codepath the dropdown already uses.

/datum/preferences
	var/datum/character_origin_map_ui/dreamvalley_origin_map_ui

/datum/preferences/proc/dreamvalley_open_origin_map_ui(mob/user)
	if(!dreamvalley_origin_map_ui)
		dreamvalley_origin_map_ui = new(user.client)
	dreamvalley_origin_map_ui.ui_interact(user)

/datum/character_origin_map_ui
	var/client/owner

/datum/character_origin_map_ui/New(client/C)
	owner = C

/datum/character_origin_map_ui/Destroy()
	owner = null
	return ..()

/datum/character_origin_map_ui/proc/get_prefs()
	RETURN_TYPE(/datum/preferences)
	return owner?.prefs

/datum/character_origin_map_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_origin_map_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterOriginMap", "Where Do You Hail From?")
		ui.open()

/// Regions shown as hotspots on the map, in a fixed display order. Racial
/// origins (Underdark) are handled separately since they're species-gated,
/// not a place you pick off a map.
/datum/character_origin_map_ui/proc/build_region_list(datum/preferences/P)
	var/static/list/region_order = list(
		/datum/virtue/origin/palimpseste/seamvale,
		/datum/virtue/origin/palimpseste/skarnheim,
		/datum/virtue/origin/palimpseste/vyrlands,
		/datum/virtue/origin/palimpseste/conjunct,
		/datum/virtue/origin/palimpseste/tir_aenna,
		/datum/virtue/origin/palimpseste/faerhen,
		/datum/virtue/origin/palimpseste/thessadra,
		/datum/virtue/origin/palimpseste/golaren,
		/datum/virtue/origin/palimpseste/laurentine,
		/datum/virtue/origin/palimpseste/achaeon,
		/datum/virtue/origin/palimpseste/khemet,
		/datum/virtue/origin/palimpseste/athrae,
		/datum/virtue/origin/palimpseste/ashurim,
		/datum/virtue/origin/palimpseste/ile_orun,
		/datum/virtue/origin/palimpseste/hinomura,
		/datum/virtue/origin/palimpseste/turtles_back,
		/datum/virtue/origin/palimpseste/dunmoor,
		/datum/virtue/origin/palimpseste/yharrow,
		/datum/virtue/origin/palimpseste/varovia,
		/datum/virtue/origin/palimpseste/hinge,
		/datum/virtue/origin/palimpseste/psydonia,
		/datum/virtue/origin/unknown,
	)
	var/list/order = region_order.Copy()
	// Species origins (Underdweller and the like) have no spot on the map;
	// the window lists them under it.
	for(var/path in GLOB.virtues)
		var/datum/virtue/origin/racial/R = GLOB.virtues[path]
		if(istype(R) && R.name && (P.pref_species.type in R.races))
			order += path
	var/list/result = list()
	for(var/path in order)
		var/datum/virtue/origin/V = GLOB.virtues[path]
		if(!V)
			continue
		if(V.restricted && (P.pref_species.type in V.races))
			continue
		result += list(list(
			"path" = "[path]",
			"key" = V.origin_name,
			"name" = V.name,
			"desc" = V.desc,
			"origin_desc" = V.origin_desc,
			"selected" = (P.virtue_origin?.type == path),
		))
	return result

/datum/character_origin_map_ui/ui_data(mob/user)
	var/datum/preferences/P = get_prefs()
	var/list/data = list()
	if(!P)
		return data
	data["current_origin"] = P.virtue_origin?.name
	data["regions"] = build_region_list(P)
	return data

/datum/character_origin_map_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	var/datum/preferences/P = get_prefs()
	if(!P)
		return

	switch(action)
		if("choose_origin")
			var/origin_path = params["path"]
			if(!origin_path)
				return
			var/datum/virtue/chosen = GLOB.virtues[origin_path]
			if(!istype(chosen, /datum/virtue/origin))
				return
			if(chosen.restricted && (P.pref_species.type in chosen.races))
				return
			// Matches the classic picker: origins are assigned by reference to
			// the single shared GLOB.virtues instance, not a fresh copy.
			P.virtue_origin = chosen
			to_chat(user, P.process_virtue_text(chosen))
			return TRUE

		if("close_map")
			SStgui.close_uis(src)
			return TRUE
