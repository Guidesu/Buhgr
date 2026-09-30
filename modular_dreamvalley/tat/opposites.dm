// Opposite quirks, Character Creation traits and vices can't be combined.
// One table covers all three: each entry is two sides, and nothing from one
// side can be taken alongside anything from the other. Keys are game traits,
// Character Creation trait ids, or vice types.

GLOBAL_LIST_INIT(dreamvalley_opposites, list(
	list(list(TRAIT_BEAUTIFUL, TRAIT_BEAUTIFUL_UNCANNY), list(TRAIT_UNSEEMLY, TRAIT_COMICSANS)),
	list(list(TRAIT_VEGAN), list(TRAIT_WILD_EATER, TRAIT_NASTY_EATER)),
	list(list(TRAIT_CRITICAL_WEAKNESS), list(TRAIT_CRITICAL_RESISTANCE)),
	list(list(TRAIT_NUDIST), list(TRAIT_SHIRTLESS)),
	list(list(TRAIT_OUTLANDER), list(TRAIT_NOBLE, TAT_TRAIT_RESIDENT)),
	list(list(TAT_TRAIT_WANTED), list(TRAIT_NOBLE)),
	list(list(TRAIT_PACIFISM), list(TAT_TRAIT_SAVAGE_RAGE, TAT_TRAIT_BERSERKER_RAGE, /datum/charflaw/addiction/sadist)),
	list(list(TRAIT_NIHILIST), list(/datum/charflaw/addiction/godfearing)),
))

/// Everything this character already has, as key -> display name.
/// exclude_key skips whatever is being re-checked.
/datum/preferences/proc/dreamvalley_character_keys(exclude_key)
	var/list/keys = list()
	for(var/path in quirk_list)
		if(path == exclude_key)
			continue
		var/datum/quirk/Q = GLOB.quirks[path]
		if(!Q)
			continue
		keys[path] = Q.name
		for(var/trait in Q.added_traits)
			keys[trait] = Q.name
	for(var/cf_type in charflaws)
		if(cf_type == exclude_key || cf_type == /datum/charflaw/noflaw)
			continue
		var/datum/charflaw/cf = GLOB.character_flaws_singletons[cf_type]
		keys[cf_type] = cf?.name || "a vice"
	var/datum/tat_traits/tat = tat_build?.traits
	if(tat)
		for(var/trait_id in tat.selected)
			if(trait_id == exclude_key)
				continue
			keys[trait_id] = tat.get_trait_display_name(trait_id)
	return keys

/// Name of whatever this candidate clashes with, or null. candidate_keys are
/// the keys the new pick would bring (its traits, its own id or type).
/datum/preferences/proc/dreamvalley_opposite_of(list/candidate_keys, exclude_key)
	var/list/have = dreamvalley_character_keys(exclude_key)
	for(var/list/pair as anything in GLOB.dreamvalley_opposites)
		for(var/side in 1 to 2)
			var/list/mine = pair[side]
			var/list/theirs = pair[3 - side]
			var/touches = FALSE
			for(var/key in candidate_keys)
				if(key in mine)
					touches = TRUE
					break
			if(!touches)
				continue
			for(var/key in theirs)
				if(have[key])
					return have[key]
	// Character Creation's own conflict table also names quirk traits
	// (Pacifist, Nudist...), which now come from quirks; honour it both ways.
	var/datum/tat_traits/tat = tat_build?.traits
	var/list/tat_conflicts = tat?.get_trait_conflict_map()
	if(islist(tat_conflicts))
		for(var/key in candidate_keys)
			for(var/other in tat_conflicts[key])
				if(have[other])
					return have[other]
		for(var/other_key in have)
			var/list/theirs = tat_conflicts[other_key]
			if(!islist(theirs))
				continue
			for(var/key in candidate_keys)
				if(key in theirs)
					return have[other_key]
	return null

/datum/quirk/proc/get_conflict_keys()
	. = list(type)
	for(var/trait in added_traits)
		. += trait

// --- Enforcement ----------------------------------------------------------

/datum/preferences/quirk_block_reason(datum/quirk/Q)
	. = ..()
	if(. || (Q.type in quirk_list))
		return
	var/clash = dreamvalley_opposite_of(Q.get_conflict_keys(), Q.type)
	if(clash)
		return "Can't be combined with [clash]."

/datum/preferences/proc/dreamvalley_vice_block_reason(vice_type)
	var/clash = dreamvalley_opposite_of(list(vice_type), vice_type)
	if(clash)
		return "Can't be combined with [clash]."

/// Vices that exist only so ported code compiles, or duplicate another vice.
GLOBAL_LIST_INIT(dreamvalley_hidden_vices, list(
	/datum/charflaw/malodorous,
	/datum/charflaw/addiction/baothamarked, // "Marked by the Forbidden" is the real one
	/datum/charflaw/randflaw, // meaningless when vices are bought for points
))

/datum/preferences/ui_add_charflaw(mob/user, cf_type)
	if(cf_type in GLOB.dreamvalley_hidden_vices)
		return CHARACTER_ACT_DATA_UPDATE
	var/reason = dreamvalley_vice_block_reason(cf_type)
	if(reason)
		to_chat(user, span_warning(reason))
		return CHARACTER_ACT_DATA_UPDATE
	return ..()

/datum/tat_traits/can_select_trait(trait_id, is_revalidation = FALSE)
	. = ..()
	if(!. || is_revalidation || !owner_build?.owner_preferences)
		return
	if(owner_build.owner_preferences.dreamvalley_opposite_of(list(trait_id), trait_id))
		return FALSE

/// Fill in the Traits tab's reason when the clash is with a quirk or vice.
/datum/tat_build/proc/dreamvalley_explain_trait_conflicts(list/available)
	if(!islist(available) || !owner_preferences)
		return
	for(var/trait_id in available)
		var/list/entry = available[trait_id]
		if(!islist(entry) || entry["can_add"] || entry["conflict_reason"])
			continue
		var/clash = owner_preferences.dreamvalley_opposite_of(list(trait_id), trait_id)
		if(clash)
			entry["conflict_reason"] = "Conflicts with \"[clash]\""

// Heretic moved from the Traits tab to the vices; traits that build on it
// (Ritualist, Berserkers Rage) look for the vice.
/datum/tat_traits/has_trait(trait_id)
	if(trait_id == TAT_TRAIT_HERETIC)
		return !!owner_build?.owner_preferences?.has_flaw(/datum/charflaw/gefheretic)
	return ..()
