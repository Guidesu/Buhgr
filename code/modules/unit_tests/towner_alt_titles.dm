/// Alt titles must not collide with a job, class or skill title, nor be claimed by two unrelated classes.
/datum/unit_test/towner_alt_titles/Run()
	var/list/reserved = get_reserved_role_titles()
	var/list/claimed_by = list()
	for(var/class_type in subtypesof(/datum/advclass))
		var/datum/advclass/class = new class_type
		for(var/title in class.alt_titles)
			var/key = lowertext(title)
			if(reserved[key])
				TEST_FAIL("[class_type] alt title \"[title]\" is already a job, class or skill title.")
			var/owner_type = claimed_by[key]
			if(owner_type && !ispath(class_type, owner_type) && !ispath(owner_type, class_type))
				TEST_FAIL("[class_type] alt title \"[title]\" is already claimed by [owner_type].")
			else if(!owner_type)
				claimed_by[key] = class_type
		qdel(class)
	var/list/shared_lists = list("General" = GLOB.general_alt_titles, "Adventurer" = GLOB.adventurer_alt_titles)
	for(var/list_name in shared_lists)
		for(var/title in shared_lists[list_name])
			var/key = lowertext(title)
			if(reserved[key])
				TEST_FAIL("[list_name] alt title \"[title]\" is already a job, class or skill title.")
			if(claimed_by[key])
				TEST_FAIL("[list_name] alt title \"[title]\" is already claimed by [claimed_by[key]].")
			else
				claimed_by[key] = "[list_name] titles"
