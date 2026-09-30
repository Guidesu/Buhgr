/// List of language prototypes to reference, assoc [type] = prototype
GLOBAL_LIST_INIT_TYPED(language_datum_instances, /datum/language, init_language_prototypes())
/// List if all language typepaths learnable, IE, those with keys
GLOBAL_LIST_INIT(all_languages, init_all_languages())
/// List of language prototypes to reference, assoc "name" = typepath
GLOBAL_LIST_INIT(language_types_by_name, init_language_types_by_name())
/// List of language prototypes to reference, assoc "key" = typepath.
GLOBAL_LIST_INIT(language_types_by_key, init_language_types_by_key())
/// List of languages selectable in character setup
GLOBAL_LIST_INIT(languages_character_selection, list(
	/datum/language/elvish,
	/datum/language/dwarvish,
	/datum/language/orcish,
	/datum/language/hellspeak,
	/datum/language/draconic,
	/datum/language/celestial,
	// Tongues of Palimpseste
	/datum/language/medullan,
	/datum/language/auxentian,
	/datum/language/vergenmarkian,
	/datum/language/ostrovian,
	/datum/language/dvojezemi,
	/datum/language/valorian,
	/datum/language/palimpseste/skarnic,
	/datum/language/palimpseste/nordling,
	/datum/language/palimpseste/aennach,
	/datum/language/palimpseste/khemeti,
	/datum/language/palimpseste/ashurite,
	/datum/language/palimpseste/oruni,
	/datum/language/palimpseste/hinomuran,
	/datum/language/palimpseste/shelltongue,
	/datum/language/palimpseste/dunmoorish,
))

/proc/init_language_prototypes()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue

		lang_list[lang_type] = new lang_type()
	return lang_list

/proc/init_all_languages()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue
		lang_list += lang_type
	return lang_list

/proc/init_language_types_by_name()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue
		lang_list[initial(lang_type.name)] = lang_type
	return lang_list

/proc/init_language_types_by_key()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		var/key = LOWER_TEXT(initial(lang_type.key))
		if(!key || lang_list[key])
			continue
		lang_list[key] = lang_type
	return lang_list
