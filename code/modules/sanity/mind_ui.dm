// "Mind" window: mood (stress events), sanity, insight, rest and desires in
// one place, like Skills & Traits. Opened from the stress indicator or the
// Mind verb.

/mob/living/carbon/human/verb/open_mind_window()
	set name = "Mind"
	set category = "IC"
	set desc = "See your mood, sanity and insight."
	open_mind_ui()

/mob/living/carbon/human/proc/open_mind_ui()
	var/datum/mind_status_ui/ui = new(src)
	ui.ui_interact(src)

/datum/mind_status_ui
	var/mob/living/carbon/human/owner

/datum/mind_status_ui/New(mob/living/carbon/human/H)
	owner = H

/datum/mind_status_ui/Destroy()
	owner = null
	return ..()

/datum/mind_status_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/mind_status_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MindStatus", "Mind")
		ui.open()

/datum/mind_status_ui/ui_close(mob/user)
	qdel(src)

/datum/mind_status_ui/ui_data(mob/user)
	var/list/data = list()
	if(!owner)
		return data

	var/datum/sanity/S = owner.sanity
	data["has_sanity"] = !!S
	if(S)
		data["sanity"] = round(S.level)
		data["sanity_max"] = round(S.max_level)
		data["sanity_text"] = sanity_status_text(S.level)
		data["insight"] = round(S.insight)
		data["insight_threshold"] = INSIGHT_REST_THRESHOLD
		data["resting"] = S.resting > 0
		data["rest"] = round(S.insight_rest)
		data["rest_threshold"] = INSIGHT_REST_THRESHOLD
		data["desires"] = S.get_desire_names()
		var/list/breakdown_names = list()
		for(var/datum/breakdown/B as anything in S.breakdowns)
			breakdown_names += B.name || "a breakdown"
		data["breakdowns"] = breakdown_names

	data["stress"] = owner.get_stress_amount()
	data["good_moods"] = collect_moods(owner.get_positive_stressors())
	data["bad_moods"] = collect_moods(owner.get_negative_stressors())

	var/list/vices = list()
	for(var/datum/charflaw/cf in owner.charflaws)
		vices += list(list("name" = cf.name, "desc" = cf.desc))
	data["vices"] = vices

	var/static/list/stat_names = list(
		STAT_STRENGTH = "Strength", STAT_PERCEPTION = "Perception",
		STAT_INTELLIGENCE = "Intelligence", STAT_CONSTITUTION = "Constitution",
		STAT_WILLPOWER = "Willpower", STAT_SPEED = "Speed", STAT_FORTUNE = "Fortune",
	)
	var/list/bonuses = list()
	for(var/stat_key in owner.oddity_stat_bonuses)
		var/bonus = owner.oddity_stat_bonuses[stat_key]
		if(bonus)
			bonuses += list(list("name" = stat_names[stat_key] || "[stat_key]", "value" = bonus))
	data["oddity_bonuses"] = bonuses
	return data

/// Groups identical mood events: list(list(desc, count), ...)
/datum/mind_status_ui/proc/collect_moods(list/events)
	var/list/by_type = list()
	var/list/out = list()
	for(var/datum/stressevent/E as anything in events)
		if(by_type[E.type])
			var/list/entry = by_type[E.type]
			entry["count"]++
			continue
		var/text = islist(E.desc) ? pick(E.desc) : E.desc
		// Stress texts carry span markup; drop the tags, keep the words.
		var/static/regex/html_tags = regex(@"<[^>]*>", "g")
		text = html_decode(html_tags.Replace("[text]", ""))
		var/list/entry = list("desc" = text, "count" = 1)
		by_type[E.type] = entry
		out += list(entry)
	return out

/proc/sanity_status_text(level)
	switch(level)
		if(80 to INFINITY)
			return "My mind is clear and strong."
		if(60 to 80)
			return "I feel slightly on edge."
		if(40 to 60)
			return "I feel uneasy and distracted."
		if(20 to 40)
			return "My mind is fraying. Something feels wrong."
		if(1 to 20)
			return "I'm on the verge of breaking."
	return "My mind has shattered."
