#define ALT_TITLE_COOLDOWN (15 MINUTES)

/datum/advclass
	/// Title = requirements, see _alt_title_defines.dm.
	var/list/alt_titles

/mob/living/carbon/human
	var/alt_title
	var/alt_title_origin
	var/next_alt_title_change = 0

/// Shared by Residency virtue holders and Homesteaders.
GLOBAL_LIST_INIT(general_alt_titles, list(
	"Artisan",
	"Artisana",
	"Craftswoman",
	"Devotee",
	"Devotess",
	"Fieldworker",
	"Forager",
	"Freeholder",
	"Gardener",
	"Handiworker",
	"Hedgefolk",
	"Homesteadress",
	"Householder",
	"Househusband",
	"Housekeeper",
	"Housewife",
	"Laborer",
	"Local",
	"Newcomer",
	"Nun",
	"Pioneer",
	"Retiree",
	"Settler",
	"Tenant",
	"Townsman",
	"Townswoman",
	"Varlet",
	"Villager",
	"Woodsman",
	"Woodswoman"
))

GLOBAL_LIST_INIT(adventurer_alt_titles, list(
	"Cleric" = list(/datum/skill/magic/holy = SKILL_LEVEL_APPRENTICE),
	"Drifter",
	"Explorer" = list(/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN),
	"Fighter" = list(ALT_TITLE_ANY_MELEE(SKILL_LEVEL_JOURNEYMAN)),
	"Fortune Seeker",
	"Hireling" = list(ALT_TITLE_ANY_MELEE(SKILL_LEVEL_APPRENTICE)),
	"Mage" = list(TRAIT_ARCYNE, /datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE),
	"Monster Hunter" = list(ALT_TITLE_ANY_MELEE(SKILL_LEVEL_JOURNEYMAN)),
	"Ranger",
	"Rogue" = list(/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN, /datum/skill/misc/lockpicking = SKILL_LEVEL_APPRENTICE),
	"Scout" = list(/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN, /datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE),
	"Sorceress" = list(TRAIT_ARCYNE),
	"Spellcaster" = list(TRAIT_ARCYNE),
	"Traveler",
	"Treasure Seeker" = list(/datum/skill/misc/lockpicking = SKILL_LEVEL_APPRENTICE),
	"Wanderer",
	"Warrior" = list(ALT_TITLE_ANY_MELEE(SKILL_LEVEL_EXPERT)),
	"Wizard" = list(TRAIT_ARCYNE, /datum/skill/magic/arcane = SKILL_LEVEL_EXPERT)
))

/proc/get_reserved_role_titles()
	var/static/list/reserved
	if(reserved)
		return reserved
	reserved = list()
	for(var/datum/job/job_type as anything in subtypesof(/datum/job))
		for(var/title in list(initial(job_type.title), initial(job_type.f_title), initial(job_type.display_title)))
			if(title)
				reserved[lowertext(title)] = TRUE
	for(var/datum/advclass/class_type as anything in subtypesof(/datum/advclass))
		var/class_name = initial(class_type.name)
		if(class_name)
			reserved[lowertext(class_name)] = TRUE
	for(var/datum/skill/skill_type as anything in subtypesof(/datum/skill))
		var/expert_name = initial(skill_type.expert_name)
		if(expert_name)
			reserved[lowertext(expert_name)] = TRUE
	return reserved

/proc/filter_free_alt_titles(list/titles)
	. = list()
	var/list/reserved = get_reserved_role_titles()
	for(var/title in titles)
		if(!reserved[lowertext(title)])
			. += title

/proc/add_free_alt_titles(list/pool, list/titles)
	var/list/reserved = get_reserved_role_titles()
	for(var/title in titles)
		if(!reserved[lowertext(title)])
			pool[title] = titles[title]

/proc/describe_alt_title_requirements(list/requirements)
	var/list/parts = list()
	for(var/requirement in requirements)
		parts += describe_alt_title_requirement(requirement, requirements[requirement])
	return parts.Join(", ")

/proc/describe_alt_title_requirement(requirement, level)
	if(islist(requirement))
		var/list/any_of = requirement
		var/list/parts = list()
		var/shared_level = null
		var/list/skill_names = list()
		for(var/option in any_of)
			parts += describe_alt_title_requirement(option, any_of[option])
			if(!ispath(option, /datum/skill) || (shared_level && any_of[option] != shared_level))
				skill_names = null
				continue
			if(skill_names)
				var/datum/skill/skill = option
				shared_level = any_of[option]
				skill_names += initial(skill.name)
		if(length(skill_names))
			return "[skill_to_string(shared_level)] [skill_names.Join("/")]"
		return parts.Join(" or ")
	if(ispath(requirement, /datum/skill))
		var/datum/skill/skill = requirement
		return "[skill_to_string(level)] [initial(skill.name)]"
	return "[requirement]"

/mob/living/carbon/human/proc/get_alt_title_pool()
	. = list()
	var/datum/advclass/class = get_advclass_datum()
	if(class && !class.adaptive_name)
		add_free_alt_titles(., class.alt_titles)
	if(!HAS_TRAIT_FROM(src, TRAIT_RESIDENT, TRAIT_VIRTUE))
		return
	add_free_alt_titles(., GLOB.general_alt_titles)
	var/datum/job/our_job = SSjob.GetJob(job)
	if(our_job?.wanderer_examine)
		.[our_job.title] = null
		add_free_alt_titles(., GLOB.adventurer_alt_titles)

/mob/living/carbon/human/proc/meets_alt_title_requirements(list/requirements)
	for(var/requirement in requirements)
		if(!meets_alt_title_requirement(requirement, requirements[requirement]))
			return FALSE
	return TRUE

/mob/living/carbon/human/proc/meets_alt_title_requirement(requirement, level)
	if(islist(requirement))
		var/list/any_of = requirement
		for(var/option in any_of)
			if(meets_alt_title_requirement(option, any_of[option]))
				return TRUE
		return FALSE
	if(ispath(requirement, /datum/skill))
		return get_skill_level(requirement) >= level
	return HAS_TRAIT(src, requirement)

/mob/living/carbon/human/proc/get_alt_title_origin()
	var/datum/advclass/class = get_advclass_datum()
	if(!class)
		return job
	if(!job || job == "Towner")
		return class.name
	return "[job] ([class.name])"

/mob/living/carbon/human/proc/set_alt_title(new_title)
	alt_title = new_title
	if(new_title)
		alt_title_origin = get_alt_title_origin()
		advjob = new_title
		if(adaptive_name)
			adaptive_name_title = new_title
		return
	alt_title_origin = null
	if(adaptive_name)
		adaptive_name_title = null
		update_adaptive_name()
		return
	var/datum/advclass/class = get_advclass_datum()
	if(class)
		advjob = class.name

/mob/living/carbon/human/proc/get_alt_title_link()
	return "<a href='?src=[REF(src)];task=alt_title_origin'>[alt_title]</a>"

/mob/living/carbon/human/proc/show_alt_title_origin(mob/user)
	if(!alt_title || !alt_title_origin)
		return
	to_chat(user, span_info("[src] goes by <b>[alt_title]</b>. By trade: <b>[alt_title_origin]</b>."))

/mob/living/carbon/human/proc/choose_alt_title()
	set name = "Choose Title"
	set category = "IC"

	var/list/pool = get_alt_title_pool()
	if(!length(pool))
		to_chat(src, span_warning("I have no other name to go by."))
		remove_verb(src, /mob/living/carbon/human/proc/choose_alt_title)
		return
	if(world.time < next_alt_title_change)
		to_chat(src, span_warning("I must wait [DisplayTimeText(next_alt_title_change - world.time)] before changing my title again."))
		return
	var/datum/advclass/class = get_advclass_datum()
	var/own_option = class?.name || job
	var/list/options = list(own_option)
	var/list/option_titles = list()
	for(var/title in pool)
		var/list/requirements = pool[title]
		var/option = title
		if(!meets_alt_title_requirements(requirements))
			option = "[title] (needs [describe_alt_title_requirements(requirements)])"
		options += option
		option_titles[option] = title
	var/choice = tgui_input_list(src, "How should I be known?", "Choose Title", options, alt_title || own_option)
	if(!choice || QDELETED(src))
		return
	if(choice == own_option)
		if(!alt_title)
			return
		set_alt_title(null)
	else
		var/title = option_titles[choice]
		pool = get_alt_title_pool()
		if(!title || title == alt_title || !(title in pool))
			return
		if(!meets_alt_title_requirements(pool[title]))
			to_chat(src, span_warning("To go by [title], I need [describe_alt_title_requirements(pool[title])]."))
			return
		set_alt_title(title)
	next_alt_title_change = world.time + ALT_TITLE_COOLDOWN
	to_chat(src, span_notice("I will be known as [advjob]."))

#undef ALT_TITLE_COOLDOWN
