/datum/homestead_builder
	var/client/owner
	var/datum/homestead_build/build

/datum/homestead_builder/New(client/C)
	owner = C
	build = new
	var/list/towner_prefs = get_homestead_prefs(C)
	build.load_from_list(towner_prefs?[HOMESTEAD_PREF_KEY])

/datum/homestead_builder/Destroy()
	owner = null
	QDEL_NULL(build)
	return ..()

/datum/homestead_builder/ui_state(mob/user)
	return GLOB.always_state

/datum/homestead_builder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HomesteadBuilder")
		ui.open()

/datum/homestead_builder/ui_close(mob/user)
	qdel(src)

/datum/homestead_builder/ui_static_data(mob/user)
	var/list/data = list()
	data["stat_points"] = HOMESTEAD_STAT_POINTS
	data["stat_min"] = HOMESTEAD_STAT_MIN
	data["stat_max"] = HOMESTEAD_STAT_MAX
	data["stat_max_gain"] = HOMESTEAD_STAT_MAX_GAIN
	data["skill_points"] = HOMESTEAD_SKILL_POINTS
	data["perk_points"] = HOMESTEAD_PERK_POINTS
	data["expertise_points"] = HOMESTEAD_EXPERTISE_POINTS
	data["expertise_category"] = HOMESTEAD_PERK_EXPERTISE
	data["max_kits"] = HOMESTEAD_MAX_KITS
	data["level_names"] = list("None", "Novice", "Apprentice", "Journeyman", "Expert", "Master", "Legendary")
	var/list/stats = list()
	for(var/stat in GLOB.homestead_stats)
		stats += list(list("key" = stat, "name" = GLOB.homestead_stats[stat]))
	data["stats"] = stats
	var/list/skill_categories = list()
	for(var/category in GLOB.homestead_skill_categories)
		var/list/skills = list()
		for(var/skill_type in GLOB.homestead_skill_categories[category])
			var/datum/skill/skill = GetSkillRef(skill_type)
			skills += list(list("type" = "[skill_type]", "name" = skill.name))
		skill_categories += list(list("name" = category, "skills" = skills))
	data["skill_categories"] = skill_categories
	var/list/perks = list()
	var/list/all_perks = get_homestead_perks()
	for(var/perk_type in all_perks)
		var/datum/homestead_perk/perk = all_perks[perk_type]
		perks += list(list("type" = "[perk_type]", "name" = perk.name, "desc" = perk.desc || get_perk_uncap_text(perk), "cost" = perk.cost, "category" = perk.category))
	data["perks"] = perks
	var/list/kits = list()
	var/list/all_kits = get_homestead_kits()
	for(var/kit_type in all_kits)
		var/datum/homestead_kit/kit = all_kits[kit_type]
		kits += list(list("type" = "[kit_type]", "name" = kit.name))
	data["kits"] = kits
	return data

/datum/homestead_builder/proc/get_perk_uncap_text(datum/homestead_perk/perk)
	var/list/names = list()
	for(var/skill_type in get_homestead_skills())
		var/datum/skill/skill = GetSkillRef(skill_type)
		for(var/trait in perk.traits)
			if(skill.trait_uncap?[trait] > skill.max_untraited_level)
				names |= skill.name
	return length(names) ? "Raises the cap of: [names.Join(", ")]." : null

/datum/homestead_builder/ui_data(mob/user)
	var/list/data = list()
	data["enabled"] = build.enabled
	data["stat_values"] = build.stats
	var/list/skill_levels = list()
	var/list/skill_caps = list()
	for(var/skill_type in get_homestead_skills())
		skill_levels["[skill_type]"] = build.skills[skill_type] || 0
		skill_caps["[skill_type]"] = build.get_skill_cap(skill_type)
	data["skill_levels"] = skill_levels
	data["skill_caps"] = skill_caps
	var/list/skill_costs = list()
	for(var/skill_type in get_homestead_skills())
		var/list/costs = list()
		for(var/level in 0 to HOMESTEAD_SKILL_CAP)
			costs += homestead_skill_cost(skill_type, level)
		skill_costs["[skill_type]"] = costs
	data["skill_costs"] = skill_costs
	var/list/perk_types = list()
	for(var/perk_type in build.perks)
		perk_types += "[perk_type]"
	data["selected_perks"] = perk_types
	var/list/kit_types = list()
	for(var/kit_type in build.kits)
		kit_types += "[kit_type]"
	data["selected_kits"] = kit_types
	data["stat_spent"] = build.get_stat_points_spent()
	data["stat_gain"] = build.get_stat_gain()
	data["skill_spent"] = build.get_skill_points_spent()
	data["perk_spent"] = build.get_perk_points_spent()
	data["expertise_spent"] = build.get_perk_points_spent(TRUE)
	data["problems"] = build.get_problems()
	var/list/notes = list()
	var/list/all_perks = get_homestead_perks()
	for(var/perk_type in build.perks)
		var/datum/homestead_perk/perk = all_perks[perk_type]
		if(perk.virtue && (istype(owner?.prefs?.virtue, perk.virtue) || istype(owner?.prefs?.virtuetwo, perk.virtue)))
			notes += "[perk.name] is already one of your virtues, so the perk does nothing."
	data["notes"] = notes
	return data

/datum/homestead_builder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_enabled")
			build.enabled = !build.enabled
		if("set_stat")
			var/stat = params["stat"]
			if(!GLOB.homestead_stats[stat])
				return
			var/value = clamp(round(text2num("[params["value"]]") || 0), HOMESTEAD_STAT_MIN, HOMESTEAD_STAT_MAX)
			var/old_value = build.stats[stat] || 0
			if(build.get_stat_points_spent() - old_value + value > HOMESTEAD_STAT_POINTS)
				return
			if(build.get_stat_gain() - max(old_value, 0) + max(value, 0) > HOMESTEAD_STAT_MAX_GAIN)
				return
			build.stats[stat] = value
		if("set_skill")
			var/skill_type = text2path(params["skill"])
			if(!(skill_type in get_homestead_skills()))
				return
			var/level = clamp(round(text2num("[params["level"]]") || 0), 0, build.get_skill_cap(skill_type))
			var/old_cost = homestead_skill_cost(skill_type, build.skills[skill_type] || 0)
			if(build.get_skill_points_spent() - old_cost + homestead_skill_cost(skill_type, level) > HOMESTEAD_SKILL_POINTS)
				return
			if(level)
				build.skills[skill_type] = level
			else
				build.skills -= skill_type
		if("toggle_perk")
			var/perk_type = text2path(params["perk"])
			var/list/all_perks = get_homestead_perks()
			var/datum/homestead_perk/perk = all_perks[perk_type]
			if(!perk)
				return
			if(build.has_perk(perk_type))
				build.perks -= perk_type
				build.clamp_skills()
			else
				var/expertise = perk.category == HOMESTEAD_PERK_EXPERTISE
				if(build.get_perk_points_spent(expertise) + perk.cost > (expertise ? HOMESTEAD_EXPERTISE_POINTS : HOMESTEAD_PERK_POINTS))
					return
				build.perks += perk_type
		if("toggle_kit")
			var/kit_type = text2path(params["kit"])
			var/list/all_kits = get_homestead_kits()
			if(!all_kits[kit_type])
				return
			if(kit_type in build.kits)
				build.kits -= kit_type
			else if(length(build.kits) < HOMESTEAD_MAX_KITS)
				build.kits += kit_type
		if("reset")
			var/was_enabled = build.enabled
			qdel(build)
			build = new
			build.enabled = was_enabled
		else
			return
	var/list/towner_prefs = get_homestead_prefs(owner)
	if(towner_prefs)
		towner_prefs[HOMESTEAD_PREF_KEY] = build.export_to_list()
	return TRUE
