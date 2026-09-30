// The prayer book: one window for writing prayers. In "compose" it is the page
// a prayer is written on before it is said; in "edit" it is where prayers are
// learned by heart - named, shaped, given a sign, or kept as their own spell.
// The counsel reads along in both. Frontend: tgui/.../interfaces/PrayerBook.tsx

/datum/prayer_writer
	var/mob/user
	var/mob/living/chosen
	/// "compose" to write one prayer and say it; "edit" to manage saved prayers.
	var/mode = "compose"
	/// Prayers or incantations.
	var/kind = PRESET_KIND_PRAYER
	var/datum/preferences/prefs
	/// The page being written on.
	var/text = ""
	var/shape = PRAYER_SHAPE_TARGETED
	/// In edit mode, which saved prayer is open (0 for none).
	var/selected = 0
	var/done = FALSE
	var/result

/datum/prayer_writer/New(mob/user, mob/living/chosen, start_text = "", shape = PRAYER_SHAPE_TARGETED, mode = "compose", kind = PRESET_KIND_PRAYER)
	src.user = user
	src.chosen = chosen
	src.mode = mode
	src.kind = kind
	prefs = user?.client?.prefs
	text = start_text || ""
	src.shape = shape || PRAYER_SHAPE_TARGETED
	if(mode == "edit" && length(store()))
		select(1)

/datum/prayer_writer/Destroy()
	SStgui.close_uis(src)
	user = null
	chosen = null
	prefs = null
	return ..()

/// Opens the book and waits until it is closed. In compose mode, returns the prayer.
/datum/prayer_writer/proc/wait_for_prayer()
	if(!user?.client)
		return null
	ui_interact(user)
	var/deadline = world.time + 15 MINUTES
	while(!done && !QDELETED(src) && user?.client && world.time < deadline)
		stoplag(2)
	return result

/datum/prayer_writer/ui_state(mob/user)
	return GLOB.always_state

/datum/prayer_writer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrayerBook")
		ui.open()

/datum/prayer_writer/ui_close(mob/user)
	. = ..()
	if(mode == "edit" && prefs)
		dreamvalley_prayer_presets_changed(user, prefs)
	done = TRUE

/datum/prayer_writer/proc/store()
	return prefs?.preset_store(kind)

/datum/prayer_writer/proc/current_entry()
	var/list/presets = store()
	if(mode != "edit" || !prefs || selected < 1 || selected > length(presets))
		return null
	return presets[selected]

/datum/prayer_writer/proc/select(index)
	selected = index
	var/list/entry = current_entry()
	if(entry)
		text = entry["text"]
		shape = entry["shape"] || PRAYER_SHAPE_TARGETED

/datum/prayer_writer/ui_static_data(mob/user)
	var/static/list/icon_data
	if(!icon_data)
		icon_data = list()
		var/list/icons = prayer_preset_icons()
		for(var/key in icons)
			var/list/look = icons[key]
			icon_data += list(list("key" = key, "img" = icon2base64(icon(look[1], look[2], SOUTH, 1, FALSE))))
	var/list/shapes = list()
	for(var/id in GLOB.prayer_shapes)
		var/list/info = GLOB.prayer_shapes[id]
		shapes += list(list("id" = id, "name" = info["name"], "desc" = info["desc"], "power" = info["power"], "cost" = info["cost"], "time" = info["time"], "clicks" = info["clicks"]))
	return list(
		"icons" = icon_data,
		"shapes" = shapes,
		"max_presets" = PRAYER_PRESET_MAX,
		"max_name" = PRAYER_PRESET_NAME_LEN,
		"max_text" = 600,
		"min_text" = PRAYER_MIN_LENGTH,
	)

/datum/prayer_writer/ui_data(mob/user)
	var/datum/domain/D = prayer_counsel_domain(user)
	var/mob/living/living_user = isliving(user) ? user : null
	var/god = (living_user ? living_user.patron?.name : prefs?.get_god_display_name()) || "your god"
	if(kind == PRESET_KIND_INCANTATION)
		god = incantation_aspect_names(user)
	var/list/presets = list()
	for(var/list/entry in store())
		presets += list(list("name" = entry["name"], "text" = entry["text"], "shape" = entry["shape"] || PRAYER_SHAPE_TARGETED, "icon" = entry["icon"], "standalone" = !!entry["standalone"]))
	var/list/summary = list("requests" = list())
	var/counsel = kind == PRESET_KIND_INCANTATION ? incantation_counsel_html(user, chosen, text, shape, summary) : prayer_counsel_html(user, chosen, text, shape, summary)
	var/who
	if(chosen)
		who = chosen == user ? "myself" : "[chosen]"
	return list(
		"mode" = mode,
		"kind" = kind,
		"who" = who,
		"god" = god,
		"domain" = D?.name,
		"colour" = D?.colour || "#b08a3e",
		"text" = text,
		"shape" = shape,
		"selected" = selected,
		"presets" = presets,
		"counsel" = counsel,
		"summary" = summary,
		"in_game" = ishuman(user),
	)

/datum/prayer_writer/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(. || done)
		return
	var/list/entry = current_entry()
	var/list/presets = store()
	switch(action)
		if("set_text")
			text = copytext("[params["text"]]", 1, 601)
			if(entry)
				entry["text"] = copytext(sanitize_text(text), 1, 601)
			return TRUE
		if("set_shape")
			var/new_shape = params["shape"]
			if(!GLOB.prayer_shapes[new_shape])
				return
			shape = new_shape
			if(entry)
				entry["shape"] = new_shape
			return TRUE
		if("pray")
			if(mode != "compose")
				return
			if(!isnull(params["text"]))
				text = copytext("[params["text"]]", 1, 601)
			result = trim(text)
			done = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("load")
			// Compose mode: start from a saved prayer's words.
			var/index = text2num(params["index"])
			if(index >= 1 && index <= length(presets))
				var/list/saved = presets[index]
				text = saved["text"]
			return TRUE
		if("select")
			var/index = text2num(params["index"])
			if(index >= 1 && index <= length(presets))
				select(index)
			return TRUE
		if("new")
			if(!prefs || length(presets) >= PRAYER_PRESET_MAX)
				return
			var/preset_name = "[kind == PRESET_KIND_INCANTATION ? "Incantation" : "Prayer"] [length(presets) + 1]"
			presets += list(list("name" = preset_name, "text" = "", "standalone" = FALSE, "icon" = "Thaumaturgy", "shape" = PRAYER_SHAPE_TARGETED))
			select(length(presets))
			dreamvalley_prayer_presets_changed(ui.user, prefs)
			return TRUE
		if("delete")
			if(!entry)
				return
			presets.Cut(selected, selected + 1)
			select(min(selected, length(presets)))
			if(!selected)
				text = ""
			dreamvalley_prayer_presets_changed(ui.user, prefs)
			return TRUE
		if("move")
			if(!entry)
				return
			var/to_index = selected + (params["dir"] == "up" ? -1 : 1)
			if(to_index < 1 || to_index > length(presets))
				return
			presets.Swap(selected, to_index)
			selected = to_index
			dreamvalley_prayer_presets_changed(ui.user, prefs)
			return TRUE
		if("rename")
			if(!entry)
				return
			var/preset_name = copytext(sanitize_text("[params["name"]]"), 1, PRAYER_PRESET_NAME_LEN + 1)
			if(preset_name)
				entry["name"] = preset_name
			return TRUE
		if("set_icon")
			if(entry && (params["icon"] in prayer_preset_icons()))
				entry["icon"] = params["icon"]
			return TRUE
		if("toggle_standalone")
			if(entry)
				entry["standalone"] = !entry["standalone"]
				dreamvalley_prayer_presets_changed(ui.user, prefs)
			return TRUE
		if("save")
			if(prefs)
				dreamvalley_prayer_presets_changed(ui.user, prefs)
			return TRUE
