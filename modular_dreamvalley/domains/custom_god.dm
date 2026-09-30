// A god of the character's own making. Each worshipper gets their own copy of
// this patron with the name, titles and description they wrote, so prayers
// that name it are heard like any other god's.

/datum/faith/private_devotion
	name = "Private Devotion"
	desc = "Not every god has a temple. Some are known to a single family, a single village or a single believer, and are no less real for it: on Palimpseste, belief is what makes a god."
	worshippers = "Hedge-priests, hermits, villagers and anyone whose god the churches never heard of"
	godhead = /datum/patron/custom

/datum/patron/custom
	name = "A God of My Own"
	domain = "Whatever domain the worshipper serves"
	desc = "A god named and described by the one who worships them."
	worshippers = "Their own faithful"
	associated_faith = /datum/faith/private_devotion
	undead_hater = TRUE
	confess_lines = list(
		"MY GOD HEARS ME!",
		"I KEEP THE OLD FAITH!",
	)

/datum/patron/custom/can_pray(mob/living/follower)
	. = ..()
	var/datum/domain/D = follower.divine_domain
	if(!D)
		return TRUE
	if(D.can_pray_here(follower))
		return TRUE
	to_chat(follower, span_danger("For [name] to hear me I must pray at [D.pray_hint]."))
	return FALSE

/// Builds the per-character copy of a written god.
/proc/make_custom_god(god_name, list/god_titles, god_desc, datum/domain/D)
	var/datum/patron/custom/P = new()
	P.name = god_name || "the Nameless"
	P.titles = islist(god_titles) ? god_titles.Copy() : list()
	if(god_desc)
		P.desc = god_desc
	if(D)
		P.domain = "[D.name]"
		P.miracles = D.miracles
		P.traits_tier = D.traits_tier
	return P
