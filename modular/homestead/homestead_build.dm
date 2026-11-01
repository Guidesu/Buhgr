/datum/homestead_build
	var/enabled = FALSE
	/// STATKEY = delta
	var/list/stats = list()
	/// Skill type = level
	var/list/skills = list()
	var/list/perks = list()
	var/list/kits = list()

/proc/homestead_skill_cost(skill_type, level)
	var/static/list/level_costs = list(1, 1, 2, 3, 4, 5)
	. = 0
	for(var/i in 1 to min(level, length(level_costs)))
		. += level_costs[i]
	if(is_homestead_combat_skill(skill_type))
		. *= HOMESTEAD_COMBAT_SKILL_COST_MULT

/datum/homestead_build/proc/has_perk(perk_type)
	return perk_type in perks

/datum/homestead_build/proc/get_perk_traits()
	. = list()
	var/list/all_perks = get_homestead_perks()
	for(var/perk_type in perks)
		var/datum/homestead_perk/perk = all_perks[perk_type]
		. |= perk.traits

/// Virtues from perks, minus any already picked in character setup.
/datum/homestead_build/proc/get_perk_virtues(mob/living/carbon/human/H)
	. = list()
	var/datum/preferences/prefs = H.client?.prefs
	var/list/all_perks = get_homestead_perks()
	for(var/perk_type in perks)
		var/datum/homestead_perk/perk = all_perks[perk_type]
		if(!perk.virtue)
			continue
		if(istype(prefs?.virtue, perk.virtue) || istype(prefs?.virtuetwo, perk.virtue))
			continue
		. += perk.virtue

/// Bought skills plus those granted by perks.
/datum/homestead_build/proc/get_spawn_skills()
	. = skills.Copy()
	var/list/all_perks = get_homestead_perks()
	for(var/perk_type in perks)
		var/datum/homestead_perk/perk = all_perks[perk_type]
		for(var/skill_type in perk.granted_skills)
			.[skill_type] = max(.[skill_type] || 0, perk.granted_skills[skill_type])

/datum/homestead_build/proc/get_skill_cap(skill_type)
	if(is_homestead_combat_skill(skill_type))
		return has_perk(/datum/homestead_perk/drilled) ? HOMESTEAD_DRILLED_COMBAT_SKILL_CAP : HOMESTEAD_COMBAT_SKILL_CAP
	if(!(skill_type in get_homestead_skills()))
		return SKILL_LEVEL_NONE
	var/datum/skill/skill = GetSkillRef(skill_type)
	var/cap = skill.max_untraited_level
	for(var/trait in get_perk_traits())
		cap = max(cap, skill.trait_uncap?[trait] || SKILL_LEVEL_NONE)
	return min(cap, HOMESTEAD_SKILL_CAP)

/datum/homestead_build/proc/get_stat_points_spent()
	. = 0
	for(var/stat in stats)
		. += stats[stat]

/datum/homestead_build/proc/get_stat_gain()
	. = 0
	for(var/stat in stats)
		. += max(stats[stat], 0)

/datum/homestead_build/proc/get_skill_points_spent()
	. = 0
	for(var/skill_type in skills)
		. += homestead_skill_cost(skill_type, skills[skill_type])

/// Points spent from the expertise pool, or from the regular perk pool.
/datum/homestead_build/proc/get_perk_points_spent(expertise = FALSE)
	. = 0
	var/list/all_perks = get_homestead_perks()
	for(var/perk_type in perks)
		var/datum/homestead_perk/perk = all_perks[perk_type]
		if((perk.category == HOMESTEAD_PERK_EXPERTISE) == expertise)
			. += perk.cost

/datum/homestead_build/proc/get_problems()
	. = list()
	if(get_stat_points_spent() > HOMESTEAD_STAT_POINTS)
		. += "Too many stat points spent."
	if(get_stat_gain() > HOMESTEAD_STAT_MAX_GAIN)
		. += "Too many stat bonuses."
	for(var/stat in stats)
		if(!GLOB.homestead_stats[stat] || stats[stat] > HOMESTEAD_STAT_MAX || stats[stat] < HOMESTEAD_STAT_MIN)
			. += "Invalid stat: [stat]."
	if(get_skill_points_spent() > HOMESTEAD_SKILL_POINTS)
		. += "Too many skill points spent."
	for(var/skill_type in skills)
		if(skills[skill_type] > get_skill_cap(skill_type))
			var/datum/skill/skill = skill_type
			. += "[initial(skill.name)] is above its cap."
	if(get_perk_points_spent() > HOMESTEAD_PERK_POINTS)
		. += "Too many perk points spent."
	if(get_perk_points_spent(TRUE) > HOMESTEAD_EXPERTISE_POINTS)
		. += "Too many expertise points spent."
	if(length(kits) > HOMESTEAD_MAX_KITS)
		. += "Too many kits."

/datum/homestead_build/proc/is_valid()
	return !length(get_problems())

/// Lowers skills that a removed perk no longer allows.
/datum/homestead_build/proc/clamp_skills()
	for(var/skill_type in skills.Copy())
		skills[skill_type] = min(skills[skill_type], get_skill_cap(skill_type))
		if(skills[skill_type] <= 0)
			skills -= skill_type

/datum/homestead_build/proc/export_to_list()
	var/list/saved_skills = list()
	for(var/skill_type in skills)
		saved_skills["[skill_type]"] = skills[skill_type]
	var/list/saved_perks = list()
	for(var/perk_type in perks)
		saved_perks += "[perk_type]"
	var/list/saved_kits = list()
	for(var/kit_type in kits)
		saved_kits += "[kit_type]"
	return list(
		"enabled" = enabled,
		"stats" = stats.Copy(),
		"skills" = saved_skills,
		"perks" = saved_perks,
		"kits" = saved_kits,
	)

/datum/homestead_build/proc/load_from_list(list/data)
	if(!islist(data))
		return
	enabled = !!data["enabled"]
	stats = list()
	var/list/saved_stats = data["stats"]
	for(var/stat in saved_stats)
		if(GLOB.homestead_stats[stat])
			stats[stat] = round(text2num("[saved_stats[stat]]") || 0)
	perks = list()
	var/list/all_perks = get_homestead_perks()
	for(var/perk_text in data["perks"])
		var/perk_type = text2path(perk_text)
		if(all_perks[perk_type])
			perks |= perk_type
	kits = list()
	var/list/all_kits = get_homestead_kits()
	for(var/kit_text in data["kits"])
		var/kit_type = text2path(kit_text)
		if(all_kits[kit_type])
			kits |= kit_type
	skills = list()
	var/list/saved_skills = data["skills"]
	for(var/skill_text in saved_skills)
		var/skill_type = text2path(skill_text)
		if(skill_type in get_homestead_skills())
			skills[skill_type] = round(text2num("[saved_skills[skill_text]]") || 0)

/proc/get_homestead_prefs(client/C)
	if(!C?.prefs)
		return null
	if(!islist(C.prefs.job_subprefs))
		C.prefs.job_subprefs = list()
	if(!islist(C.prefs.job_subprefs["Towner"]))
		C.prefs.job_subprefs["Towner"] = list()
	return C.prefs.job_subprefs["Towner"]

/mob/living/carbon/human
	var/datum/homestead_build/homestead_build
	var/homestead_build_resolved = FALSE

/// The custom build H should spawn with, or null to use the default Homesteader.
/proc/get_active_homestead_build(mob/living/carbon/human/H)
	if(H.homestead_build_resolved)
		return H.homestead_build
	H.homestead_build_resolved = TRUE
	var/list/towner_prefs = H.client?.prefs?.job_subprefs?["Towner"] || H.mind?.job_subprefs?["Towner"]
	var/list/data = towner_prefs?[HOMESTEAD_PREF_KEY]
	if(!data)
		return null
	var/datum/homestead_build/build = new
	build.load_from_list(data)
	if(!build.enabled)
		return null
	if(!build.is_valid())
		to_chat(H, span_warning("My custom homestead build is invalid, so I start as a common homesteader instead."))
		return null
	H.homestead_build = build
	return build
