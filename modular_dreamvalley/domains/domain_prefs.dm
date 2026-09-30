// Domain and god choice in preferences, saving, and applying it to the mob.

#define CUSTOM_GOD_NAME_LEN 40
#define CUSTOM_GOD_TITLES_LEN 120
#define CUSTOM_GOD_DESC_LEN 600

/mob/living
	/// The domain this character serves. Decides their miracles.
	var/datum/domain/divine_domain

/datum/preferences
	var/selected_domain
	var/custom_god_name = ""
	/// Comma separated, as typed.
	var/custom_god_titles = ""
	var/custom_god_desc = ""

/datum/preferences/proc/uses_custom_god()
	return istype(selected_patron, /datum/patron/custom)

/datum/preferences/proc/get_selected_domain()
	return get_divine_domain(selected_domain)

/// Keeps the domain and god consistent: the god must hold the domain, and every
/// character has a domain.
/datum/preferences/proc/validate_domain()
	var/datum/domain/D = get_selected_domain()
	if(uses_custom_god())
		if(!D)
			selected_domain = /datum/domain/hearth
		return
	var/patron_type = selected_patron?.type
	if(D && D.holds_god(patron_type))
		return
	for(var/path in GLOB.divine_domains)
		var/datum/domain/candidate = GLOB.divine_domains[path]
		if(candidate.holds_god(patron_type))
			selected_domain = path
			return
	// A god no domain lists (old saves, removed gods): keep them, give a domain.
	if(!D)
		selected_domain = /datum/domain/hearth

/datum/preferences/proc/get_custom_god_titles()
	. = list()
	for(var/title in splittext(custom_god_titles, ","))
		title = trim(title)
		if(length(title) >= 3)
			. += title

/// Name shown for the chosen god.
/datum/preferences/proc/get_god_display_name()
	if(uses_custom_god())
		return custom_god_name || "a nameless god"
	return selected_patron?.name

/datum/preferences/proc/dreamvalley_load_domain(savefile/S)
	var/domain_text
	S["selected_domain"] >> domain_text
	selected_domain = ispath(domain_text) ? domain_text : text2path("[domain_text]")
	if(!GLOB.divine_domains[selected_domain])
		selected_domain = null
	S["custom_god_name"] >> custom_god_name
	S["custom_god_titles"] >> custom_god_titles
	S["custom_god_desc"] >> custom_god_desc
	custom_god_name = sanitize_text(custom_god_name) || ""
	custom_god_titles = sanitize_text(custom_god_titles) || ""
	custom_god_desc = sanitize_text(custom_god_desc) || ""
	// Validated when first shown or applied; the patron loads after this.

/datum/preferences/proc/dreamvalley_save_domain(savefile/S)
	WRITE_FILE(S["selected_domain"], "[selected_domain]")
	WRITE_FILE(S["custom_god_name"], custom_god_name)
	WRITE_FILE(S["custom_god_titles"], custom_god_titles)
	WRITE_FILE(S["custom_god_desc"], custom_god_desc)

/// Called from copy_to right after the patron is set.
/datum/preferences/proc/dreamvalley_apply_domain(mob/living/character)
	validate_domain()
	var/datum/domain/D = get_selected_domain()
	character.divine_domain = D
	if(uses_custom_god())
		character.set_patron(make_custom_god(custom_god_name, get_custom_god_titles(), custom_god_desc, D))

// --- Selection popup ------------------------------------------------------

/datum/preferences/proc/dreamvalley_domain_popup_data()
	validate_domain()
	var/list/domains = list()
	for(var/path in GLOB.divine_domains)
		var/datum/domain/D = GLOB.divine_domains[path]
		domains += list(D.ui_entry())
	return list(
		"domains" = domains,
		"selected_domain" = "[selected_domain]",
		"selected_patron" = "[selected_patron?.type]",
		"custom" = uses_custom_god(),
		"custom_name" = custom_god_name,
		"custom_titles" = custom_god_titles,
		"custom_desc" = custom_god_desc,
		"name_max" = CUSTOM_GOD_NAME_LEN,
		"titles_max" = CUSTOM_GOD_TITLES_LEN,
		"desc_max" = CUSTOM_GOD_DESC_LEN,
	)

/datum/preferences/proc/dreamvalley_domain_popup_act(mob/user, action, list/params)
	switch(action)
		if("set_domain")
			var/path = text2path(params["domain"])
			var/datum/domain/D = GLOB.divine_domains[path]
			if(!D)
				return FALSE
			selected_domain = path
			// Keep a known god only if they also hold the new domain.
			if(!uses_custom_god() && !D.holds_god(selected_patron?.type))
				for(var/god in D.gods)
					var/datum/patron/P = GLOB.patronlist[god]
					if(P?.preference_accessible)
						selected_patron = P
						break
			return TRUE
		if("set_patron")
			var/datum/domain/D = get_selected_domain()
			var/path = text2path(params["patron"])
			var/datum/patron/picked = GLOB.preference_patrons[path]
			if(!picked?.name || !D?.holds_god(path))
				return FALSE
			verbose_pref_log_change(user, "notice", "Patron", selected_patron?.name, picked)
			selected_patron = picked
			return TRUE
		if("use_custom")
			var/datum/patron/P = GLOB.patronlist[/datum/patron/custom]
			if(!P)
				return FALSE
			selected_patron = P
			if(!custom_god_name)
				custom_god_name = "the Nameless"
			return TRUE
		if("set_custom_name")
			custom_god_name = copytext_char(sanitize_text(trim(params["value"])), 1, CUSTOM_GOD_NAME_LEN + 1)
			return TRUE
		if("set_custom_titles")
			custom_god_titles = copytext_char(sanitize_text(trim(params["value"])), 1, CUSTOM_GOD_TITLES_LEN + 1)
			return TRUE
		if("set_custom_desc")
			custom_god_desc = copytext_char(sanitize_text(trim(params["value"])), 1, CUSTOM_GOD_DESC_LEN + 1)
			return TRUE
	return FALSE

// --- Restrictions -----------------------------------------------------------
// Jobs and classes list the gods they accept. With domains, following any god
// of a domain one of those gods holds is enough: a Law-domain worshipper can
// take a job that asks for Praecursor.

/proc/dreamvalley_patron_permitted(datum/patron/P, datum/domain/D, list/allowed)
	if(!length(allowed))
		return TRUE
	if(P && (P.type in allowed))
		return TRUE
	if(!D)
		return FALSE
	for(var/god in allowed)
		if(D.holds_god(god))
			return TRUE
	return FALSE

/proc/dreamvalley_prefs_patron_permitted(datum/preferences/prefs, list/allowed)
	if(!prefs)
		return !length(allowed)
	return dreamvalley_patron_permitted(prefs.selected_patron, prefs.get_selected_domain(), allowed)

/proc/dreamvalley_mob_patron_permitted(mob/living/L, list/allowed)
	if(!L)
		return !length(allowed)
	return dreamvalley_patron_permitted(L.patron, L.divine_domain, allowed)

#undef CUSTOM_GOD_NAME_LEN
#undef CUSTOM_GOD_TITLES_LEN
#undef CUSTOM_GOD_DESC_LEN
