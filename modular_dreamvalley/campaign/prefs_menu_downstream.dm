// DreamValley options in Azure Peak's character menu, wired through AP's
// downstream hooks (see code/modules/client/character_setup/_README.md).
// Frontend: tgui/.../PreferencesMenu/downstream/tabs/CharacterCreator/subtabs/Identity.tsx

#define DREAMVALLEY_MANOR_TYPES list( \
	"Manor" = "manor", \
	"Hunter Mansion" = "hunter_mansion", \
	"Village" = "village", \
	"Fisher Hamlet" = "fisher_hamlet", \
	"Mining Settlement" = "mining_settlement", \
)

/datum/preferences/ui_act_character_creator(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user

	switch(action)
		if("dv_toggle_have_manor")
			have_manor = !have_manor
			verbose_pref_log_change(user, "notice", "Has Manor", !have_manor ? "Yes" : "No", have_manor ? "Yes" : "No")
			return CHARACTER_ACT_DATA_UPDATE

		if("dv_set_manor_name")
			var/new_name = tgui_input_text(user, "Name your holding:", "Manor Name", manor_name, max_length = MAX_NAME_LEN, encode = FALSE)
			if(isnull(new_name))
				return CHARACTER_ACT_DATA_UPDATE
			new_name = reject_bad_name(new_name)
			if(!new_name)
				to_chat(user, span_warning("Invalid manor name."))
				return CHARACTER_ACT_DATA_UPDATE
			verbose_pref_log_change(user, "notice", "Manor Name", manor_name, new_name)
			manor_name = new_name
			return CHARACTER_ACT_DATA_UPDATE

		if("dv_set_manor_type")
			var/static/list/manor_types = DREAMVALLEY_MANOR_TYPES
			var/type_path = manor_types[params["value"]]
			if(!type_path)
				return CHARACTER_ACT_DATA_UPDATE
			verbose_pref_log_change(user, "notice", "Manor Type", get_manor_type_display_name(), params["value"])
			manor_type = type_path
			return CHARACTER_ACT_DATA_UPDATE

		if("dv_open_tat")
			dreamvalley_open_tat(user)
			return CHARACTER_ACT_DATA_UPDATE

		if("dv_open_origin_map")
			dreamvalley_open_origin_map_ui(user)
			return CHARACTER_ACT_DATA_UPDATE

		// Redolent scent (only used if the Redolent virtue is picked).
		if("dv_set_scent_type")
			var/new_type = params["value"]
			if(new_type in list("Gross", "Neutral", "Pleasant"))
				verbose_pref_log_change(user, "notice", "Scent", redolent_type, new_type)
				redolent_type = new_type
			return CHARACTER_ACT_DATA_UPDATE

		if("dv_set_scent_text")
			var/new_scent = tgui_input_text(user, "What do you smell of? Leave empty for the default.", "Scent", redolent_scent, max_length = 100)
			if(isnull(new_scent))
				return CHARACTER_ACT_DATA_UPDATE
			redolent_scent = STRIP_HTML_SIMPLE(new_scent, 100)
			return CHARACTER_ACT_DATA_UPDATE

		// Adult content toggles (Ratwood verbs, see ported/ratwood/sexcon/content_toggles.dm).
		if("dv_toggle_content")
			var/client/C = user.client
			switch(params["id"])
				if("erp_panel")
					C.toggle_ERP()
				if("erp_visuals")
					C.toggle_ERP_visuals()
				if("chastity")
					C.toggle_Chastity()
				if("permanent_binding")
					C.toggle_Chastity_Hardmode()
				if("extreme_erp")
					C.toggle_extreme_ERP()
				if("edging")
					C.toggle_edging()
				if("cursed_collars")
					C.toggle_cursed_collars()
			return CHARACTER_ACT_DATA_UPDATE

/datum/preferences/ui_data_character_creator(mob/user)
	var/list/data = ..()
	var/static/list/manor_type_names
	if(!manor_type_names)
		manor_type_names = list()
		var/list/manor_types = DREAMVALLEY_MANOR_TYPES
		for(var/type_name in manor_types)
			manor_type_names += type_name
	data += list(
		"dv_have_manor" = have_manor,
		"dv_manor_name" = manor_name,
		"dv_manor_type" = get_manor_type_display_name(),
		"dv_manor_type_options" = manor_type_names,
		"dv_scent_type" = redolent_type,
		"dv_scent_text" = redolent_scent || get_default_redolent_scent(redolent_type),
		"dv_content" = list(
			"erp_panel" = !!sexable,
			"erp_visuals" = !!erp_visuals,
			"chastity" = !!chastenable,
			"permanent_binding" = chastity_hardmode == CHASTITY_HARDMODE_ENABLED,
			"extreme_erp" = !!extreme_erp,
			"edging" = !!edging,
			"cursed_collars" = !!cursed_collarable,
		),
	)
	return data

#undef DREAMVALLEY_MANOR_TYPES
