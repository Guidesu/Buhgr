// Quirks as point-buy, picked in the Character Creation window's Quirks tab
// alongside vices. Every character gets QUIRK_BASE_POINTS; each vice adds
// QUIRK_POINTS_PER_VICE. Lesser quirks cost 1, greater quirks 3, and drawback
// quirks (negative quirk_cost) give points back.

#define QUIRK_BASE_POINTS 4
#define QUIRK_POINTS_PER_VICE 2

/datum/quirk
	/// Point cost. Null means "work it out" (1 lesser, 3 greater). Negative = drawback.
	var/quirk_cost

// Cost standard. Every quirk is priced by what it does, on one scale:
//   1  Flavour or knowledge: changes what you notice or how you're seen.
//   2  Useful: a real edge in some situations.
//   3  Strong: an edge most rounds, or opens content others can't reach.
//   4  Exceptional: changes how fights go for you.
// Drawbacks use the same scale in reverse (-1 nuisance ... -4 crippling).
// A vice is worth QUIRK_POINTS_PER_VICE.
GLOBAL_LIST_INIT(quirk_costs, list(
	// 1 - flavour / knowledge
	/datum/quirk/heat_acclimated = 1,
	/datum/quirk/cold_acclimated = 1,
	/datum/quirk/cicerone = 1,
	/datum/quirk/appraiser = 1,
	/datum/quirk/intellectual = 1,
	/datum/quirk/seed_knower = 1,
	/datum/quirk/cautious_fisher = 1,
	/datum/quirk/nightowl = 1,
	/datum/quirk/nistean = 1,
	/datum/quirk/feytouched = 1,
	/datum/quirk/wellknown = 1,
	/datum/quirk/redolent = 1,
	/datum/quirk/secondvoice = 1,
	/datum/quirk/selfaware = 1,
	/datum/quirk/acquired_tastes = 1,
	/datum/quirk/empath = 1,
	/datum/quirk/deadnose = 1,
	/datum/quirk/tainted = 1,
	// 2 - useful
	/datum/quirk/keen_ears = 2,
	/datum/quirk/wyrdbeauty = 2,
	/datum/quirk/caustic = 2,
	/datum/quirk/steelhearted = 2,
	/datum/quirk/deceiving_meekness = 2,
	/datum/quirk/largeframe = 2,
	/datum/quirk/rough_lover = 2,
	/datum/quirk/linguist = 2,
	// 3 - strong
	/datum/quirk/wyldeater = 3,
	/datum/quirk/noble = 3,
	// 4 - exceptional
	/datum/quirk/hard_dismemberment = 4,
	// Drawbacks
	/datum/quirk/technophobe = -1,
	/datum/quirk/shirtless = -1,
	/datum/quirk/annoyingface = -1,
	/datum/quirk/ugly = -1,
	/datum/quirk/bad_mood = -2,
	/datum/quirk/nihilist = -1,
	/datum/quirk/vegan = -2,
	/datum/quirk/outlander = -2,
	/datum/quirk/nudist = -3,
	/datum/quirk/pacifist = -4,
))

/// Quirks that duplicate a Character Creation trait or a vice; the other copy stays.
GLOBAL_LIST_INIT(dreamvalley_hidden_quirks, list(
	/datum/quirk/amphibious,		// Fabled Lover: a trait
	/datum/quirk/outdoorsman,		// Outdoorsman: a trait
	/datum/quirk/critical_weakness,	// Critical Weakness: a vice
))

/datum/quirk/proc/get_cost()
	var/listed = GLOB.quirk_costs[type]
	if(!isnull(listed))
		return listed
	if(!isnull(quirk_cost))
		return quirk_cost
	return greater ? 3 : 1

/datum/quirk/proc/is_pickable()
	return name && type != /datum/quirk/none && !(type in GLOB.dreamvalley_hidden_quirks)

/datum/preferences
	/// Chosen quirk types, in any number the points allow.
	var/list/quirk_list = list()
	/// Instances built from quirk_list, for code that wants datums.
	var/list/datum/quirk/quirk_instances

/datum/preferences/proc/rebuild_quirk_instances()
	QDEL_LIST(quirk_instances)
	quirk_instances = list()
	for(var/path in quirk_list)
		if(ispath(path, /datum/quirk) && path != /datum/quirk/none)
			quirk_instances += new path()

/datum/preferences/get_all_quirks()
	if(isnull(quirk_instances))
		rebuild_quirk_instances()
	return quirk_instances.Copy()

/datum/preferences/proc/get_quirk_budget()
	. = QUIRK_BASE_POINTS
	for(var/cf_type in charflaws)
		if(cf_type != /datum/charflaw/noflaw)
			. += QUIRK_POINTS_PER_VICE

/datum/preferences/proc/get_quirk_points_spent()
	. = 0
	for(var/path in quirk_list)
		var/datum/quirk/Q = GLOB.quirks[path]
		if(Q)
			. += Q.get_cost()

/// Why this quirk can't be taken right now, or null.
/datum/preferences/proc/quirk_block_reason(datum/quirk/Q)
	if(Q.type in quirk_list)
		return null
	if(!quirk_check(Q, src))
		return "Not available to this character."
	if(get_quirk_points_spent() + Q.get_cost() > get_quirk_budget())
		return "Not enough quirk points."
	if(length(job_preferences))
		for(var/title in job_preferences)
			if(job_preferences[title] != JP_HIGH)
				continue
			var/datum/job/J = SSjob.GetJob(title)
			if(J && (Q.type in J.quirk_restrictions))
				return "Not allowed for [title]."
	return null

/datum/preferences/proc/toggle_quirk(mob/user, quirk_path)
	var/path = text2path(quirk_path)
	var/datum/quirk/Q = GLOB.quirks[path]
	if(!Q)
		return FALSE
	if(path in quirk_list)
		quirk_list -= path
	else
		if(!Q.is_pickable())
			return FALSE
		var/reason = quirk_block_reason(Q)
		if(reason)
			to_chat(user, span_warning("[Q.name]: [reason]"))
			return FALSE
		quirk_list += path
	rebuild_quirk_instances()
	return TRUE

// --- Saving -------------------------------------------------------------

/datum/preferences/proc/dreamvalley_load_extra_quirks(savefile/S)
	var/list/saved
	S["quirk_list"] >> saved
	quirk_list = list()
	if(islist(saved))
		for(var/entry in saved)
			var/path = ispath(entry) ? entry : text2path("[entry]")
			var/datum/quirk/saved_quirk = GLOB.quirks[path]
			if(saved_quirk?.is_pickable())
				quirk_list |= path
	else
		// Older saves used fixed slots; carry those picks over.
		for(var/datum/quirk/Q in list(quirklesser, quirkgreater))
			if(Q && Q.type != /datum/quirk/none)
				quirk_list |= Q.type
		for(var/key in list("quirklesser2", "quirklesser3", "quirklesser4", "quirkgreater2"))
			var/old_type
			S[key] >> old_type
			if(ispath(old_type, /datum/quirk) && old_type != /datum/quirk/none)
				quirk_list |= old_type
	rebuild_quirk_instances()

/datum/preferences/proc/dreamvalley_save_extra_quirks(savefile/S)
	var/list/out = list()
	for(var/path in quirk_list)
		out += "[path]"
	WRITE_FILE(S["quirk_list"], out)

// --- Character Creation window ------------------------------------------

/datum/tat_build/ui_data(mob/user)
	. = ..()
	if(!islist(.) || .["disabled"] || !owner_preferences)
		return
	.["quirks"] = dreamvalley_build_ui_quirks(user)
	dreamvalley_explain_trait_conflicts(.["available_traits"])

/datum/tat_build/ui_act(action, list/params)
	switch(action)
		if("toggle_quirk")
			if(!owner_preferences?.toggle_quirk(usr, params["quirk"]))
				return FALSE
		if("toggle_vice")
			var/path = text2path(params["vice"])
			if(!owner_preferences || !(path in GLOB.character_flaws_singletons))
				return FALSE
			if(owner_preferences.has_flaw(path))
				owner_preferences.ui_remove_charflaw(usr, path)
			else
				owner_preferences.ui_add_charflaw(usr, path)
		else
			return ..()
	owner_preferences.save_character()
	invalidate_ui_data_cache()
	return TRUE

/datum/tat_build/proc/dreamvalley_build_ui_quirks(mob/user)
	var/datum/preferences/P = owner_preferences
	var/list/quirks = list()
	for(var/path in GLOB.quirks)
		var/datum/quirk/Q = GLOB.quirks[path]
		if(!Q.is_pickable())
			continue
		quirks += list(list(
			"path" = "[path]",
			"name" = Q.name,
			"desc" = Q.desc,
			"mechdesc" = Q.mechdesc,
			"icon" = Q.ui_fa_icon,
			"cost" = Q.get_cost(),
			"taken" = (path in P.quirk_list),
			"blocked" = P.quirk_block_reason(Q),
		))

	var/list/vices = list()
	for(var/cf_path in GLOB.character_flaws_singletons)
		var/datum/charflaw/cf = GLOB.character_flaws_singletons[cf_path]
		var/denial = P.cannot_take_flaw(cf)
		var/taken = P.has_flaw(cf_path)
		if(!taken && (cf_path in GLOB.dreamvalley_hidden_vices))
			continue
		if(denial == PREFERENCE_CHARFLAW_DENIAL_HIDE && !taken)
			continue
		vices += list(list(
			"path" = "[cf_path]",
			"name" = cf.name,
			"desc" = cf.desc,
			"taken" = taken,
			"blocked" = taken ? null : (P.flaw_denial_to_string(denial) || P.dreamvalley_vice_block_reason(cf_path)),
		))

	return list(
		"budget" = P.get_quirk_budget(),
		"spent" = P.get_quirk_points_spent(),
		"per_vice" = QUIRK_POINTS_PER_VICE,
		"quirks" = quirks,
		"vices" = vices,
	)

// --- Quirks -------------------------------------------------------------

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

// Small traits moved here from Character Creation's Traits tab.

/datum/quirk/cicerone
	name = "Cicerone"
	desc = "I know my brews and spirits, and can tell them apart at a glance."
	added_traits = list(TRAIT_CICERONE)
	ui_fa_icon = "wine-glass"

/datum/quirk/appraiser
	name = "Appraiser"
	desc = "I can tell what things are worth down to the coin."
	added_traits = list(TRAIT_SEEPRICES)
	ui_fa_icon = "coins"

/datum/quirk/intellectual
	name = "Intellectual"
	desc = "I have a keen eye for a person's wit and skill with a blade."
	added_traits = list(TRAIT_INTELLECTUAL)
	ui_fa_icon = "book"

/datum/quirk/keen_ears
	name = "Keen Ears"
	desc = "I recognise voices and catch whispers from farther away."
	added_traits = list(TRAIT_KEENEARS)
	quirk_cost = 2
	ui_fa_icon = "ear-listen"

/datum/quirk/seed_knower
	name = "Seed Knower"
	desc = "I know which seeds grow which crops."
	added_traits = list(TRAIT_SEEDKNOW)
	ui_fa_icon = "seedling"

/datum/quirk/cautious_fisher
	name = "Cautious Fisher"
	desc = "I know the dangers of fishing and how to avoid unwanted attention from the depths."
	added_traits = list(TRAIT_CAUTIOUS_FISHER)
	ui_fa_icon = "fish"

/datum/quirk/steelhearted
	name = "Steelhearted"
	desc = "Hardened nerves. I don't waver at the sight of violence."
	added_traits = list(TRAIT_STEELHEARTED)
	ui_fa_icon = "shield-heart"

/datum/quirk/deceiving_meekness
	name = "Deceiving Meekness"
	desc = "People think I'm weak. They're mistaken."
	added_traits = list(TRAIT_DECEIVING_MEEKNESS)
	ui_fa_icon = "mask"

/datum/quirk/hard_dismemberment
	name = "Hard to Dismember"
	desc = "My limbs are harder to hack off."
	added_traits = list(TRAIT_HARDDISMEMBER)
	ui_fa_icon = "bone"

// Drawbacks: they give quirk points back.

/datum/quirk/outlander
	name = "Outlander"
	desc = "The locals see me as not of their land."
	added_traits = list(TRAIT_OUTLANDER)
	quirk_cost = -2
	ui_fa_icon = "person-walking-luggage"

/datum/quirk/technophobe
	name = "Technophobe"
	desc = "I can't make heads or tails of Meister devices."
	added_traits = list(TRAIT_TECHNOPHOBE)
	quirk_cost = -1
	ui_fa_icon = "gears"

/datum/quirk/bad_mood
	name = "Bad Mood"
	desc = "Everything gets to me. All stress I receive is doubled."
	added_traits = list(TRAIT_BAD_MOOD)
	quirk_cost = -1
	ui_fa_icon = "face-frown"

/datum/quirk/pacifist
	name = "Pacifist"
	desc = "I cannot bring myself to harm a living being."
	added_traits = list(TRAIT_PACIFISM)
	quirk_cost = -4
	ui_fa_icon = "dove"

/datum/quirk/critical_weakness
	name = "Critical Weakness"
	desc = "I'm far more vulnerable to critical wounds."
	added_traits = list(TRAIT_CRITICAL_WEAKNESS)
	quirk_cost = -3
	ui_fa_icon = "heart-crack"

/datum/quirk/nudist
	name = "Nudist"
	desc = "I refuse to wear clothes."
	added_traits = list(TRAIT_NUDIST)
	quirk_cost = -3
	ui_fa_icon = "person"

/datum/quirk/shirtless
	name = "Shirtless"
	desc = "I can't bear covering myself from the waist up."
	added_traits = list(TRAIT_SHIRTLESS)
	quirk_cost = -1
	ui_fa_icon = "shirt"

#undef QUIRK_BASE_POINTS
#undef QUIRK_POINTS_PER_VICE

// The Traits tab's "Disfigured" is a different thing (nobody can recognise you);
// this quirk makes you ugly, so it gets its own name.
/datum/quirk/ugly
	name = "Unseemly"
