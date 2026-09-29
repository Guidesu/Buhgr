// Quirk selection inside the Character Creation (TAT) window. The quirks
// themselves still live on /datum/preferences; this only exposes them here.

/datum/tat_build/ui_data(mob/user)
	. = ..()
	if(!islist(.) || .["disabled"] || !owner_preferences)
		return
	// Quirk slots depend on statpack and vices chosen in the main menu, so
	// this is rebuilt every time rather than kept in the build's cache.
	.["quirks"] = dreamvalley_build_ui_quirks(user)

/datum/tat_build/ui_act(action, list/params)
	if(action == "select_quirk")
		if(!owner_preferences)
			return FALSE
		if(!owner_preferences.dreamvalley_select_quirk(usr, text2num(params["id"]), params["quirk"]))
			return FALSE
		owner_preferences.save_character()
		invalidate_ui_data_cache()
		return TRUE
	return ..()

/datum/tat_build/proc/dreamvalley_build_ui_quirks(mob/user)
	var/datum/preferences/P = owner_preferences
	var/list/availability = list()
	for(var/list/entry as anything in P.ui_data_popup_quirk(user)["quirk_availability"])
		availability["[entry["path"]]"] = entry["unavailable"]

	var/list/options = list()
	for(var/path in GLOB.quirks)
		var/datum/quirk/Q = GLOB.quirks[path]
		if(!Q.name)
			continue
		options += list(list(
			"path" = "[path]",
			"name" = Q.name,
			"desc" = Q.desc,
			"mechdesc" = Q.mechdesc,
			"icon" = Q.ui_fa_icon,
			"greater" = !!Q.greater,
			// The greater-slot rule is shown per slot in the UI instead.
			"unavailable" = Q.greater && availability["[path]"] == "Can only be applied in a greater quirk slot." ? null : availability["[path]"],
		))

	var/list/slots = list()
	var/list/slot_names = P.get_quirk_slot_names()
	var/index = 1
	for(var/datum/quirk/Q as anything in P.get_all_quirks())
		slots += list(list(
			"id" = index,
			"slot_name" = slot_names[index],
			"path" = "[Q.type]",
			"name" = Q.name,
			"greater" = P.is_greater_quirk_slot(index),
			"spawn_error" = P.quirk_spawn_error(index, Q),
		))
		index++

	return list(
		"slots" = slots,
		"options" = options,
		"open_slots" = get_quirk_slots(P),
	)

// Six quirk slots: indices 1-2 are Azure Peak's lesser and greater slots,
// 3-5 are extra lesser slots and 6 is a second greater slot.
/datum/preferences
	var/datum/quirk/quirklesser2 = new /datum/quirk/none
	var/datum/quirk/quirklesser3 = new /datum/quirk/none
	var/datum/quirk/quirklesser4 = new /datum/quirk/none
	var/datum/quirk/quirkgreater2 = new /datum/quirk/none

/datum/preferences/get_all_quirks()
	return ..() + list(quirklesser2, quirklesser3, quirklesser4, quirkgreater2)

/datum/preferences/set_quirk_by_index(index, datum/quirk/new_quirk)
	switch(index)
		if(3)
			QDEL_NULL(quirklesser2)
			quirklesser2 = new_quirk
			return TRUE
		if(4)
			QDEL_NULL(quirklesser3)
			quirklesser3 = new_quirk
			return TRUE
		if(5)
			QDEL_NULL(quirklesser4)
			quirklesser4 = new_quirk
			return TRUE
		if(6)
			QDEL_NULL(quirkgreater2)
			quirkgreater2 = new_quirk
			return TRUE
	return ..()

/datum/preferences/get_quirk_slot_names()
	return list("Lesser Quirk", "Greater Quirk", "Lesser Quirk II", "Lesser Quirk III", "Lesser Quirk IV", "Greater Quirk II")

/datum/preferences/proc/is_greater_quirk_slot(index)
	return index == 2 || index == 6

/datum/preferences/proc/dreamvalley_load_extra_quirks(savefile/S)
	var/list/keys = list("quirklesser2", "quirklesser3", "quirklesser4", "quirkgreater2")
	for(var/i in 1 to length(keys))
		var/index = i + 2
		var/quirk_type
		S[keys[i]] >> quirk_type
		if(!ispath(quirk_type, /datum/quirk))
			quirk_type = /datum/quirk/none
		var/datum/quirk/path = quirk_type
		if(path::greater && !is_greater_quirk_slot(index))
			quirk_type = /datum/quirk/none
		set_quirk_by_index(index, new quirk_type)

/datum/preferences/proc/dreamvalley_save_extra_quirks(savefile/S)
	WRITE_FILE(S["quirklesser2"], quirklesser2.type)
	WRITE_FILE(S["quirklesser3"], quirklesser3.type)
	WRITE_FILE(S["quirklesser4"], quirklesser4.type)
	WRITE_FILE(S["quirkgreater2"], quirkgreater2.type)

/// Same checks as the preferences menu's quirk popup.
/datum/preferences/proc/dreamvalley_select_quirk(mob/user, index, quirk_path)
	if(!validate_quirk_index(index))
		return FALSE
	var/path = text2path(quirk_path)
	if(!ispath(path, /datum/quirk))
		return FALSE
	var/datum/quirk/Q = GLOB.quirks[path]
	if(!Q?.name)
		return FALSE
	if(!istype(Q, /datum/quirk/none) && (Q.name in get_all_quirk_names()))
		return FALSE
	// Greater quirks only fit the greater slot.
	if(Q.greater && !is_greater_quirk_slot(index))
		return FALSE
	if(!quirk_check(Q, src))
		return FALSE
	var/datum/quirk/old = get_quirk_by_index(index)
	var/datum/quirk/new_quirk = new Q.type()
	verbose_pref_log_change(user, "notice", "Quirk [index]", old.name, new_quirk.name)
	set_quirk_by_index(index, new_quirk)
	return TRUE

/datum/quirk/heat_acclimated
	name = "Heat Acclimated"
	desc = "I grew up under a harsh sun. Heat that would fell others barely bothers me."
	mechdesc = "Resistant to heat."
	added_traits = list(TRAIT_RESISTHEAT)
	ui_fa_icon = "sun"

/datum/quirk/cold_acclimated
	name = "Cold Acclimated"
	desc = "Long winters have hardened me. Cold that would fell others barely bothers me."
	mechdesc = "Resistant to cold."
	added_traits = list(TRAIT_RESISTCOLD)
	ui_fa_icon = "snowflake"
