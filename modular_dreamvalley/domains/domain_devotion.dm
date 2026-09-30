// Devotion grants the domain's miracles rather than the god's own list. Traits
// come from both: the god's (a Praecursor devotee is still Vaeltite) and the
// domain's.

/datum/devotion/proc/get_miracles()
	var/datum/domain/D = holder?.divine_domain
	if(!D && holder?.client?.prefs)
		D = holder.client.prefs.get_selected_domain()
		holder.divine_domain = D
	if(D && length(D.miracles))
		return D.miracles
	// Without a domain, still let them pray.
	. = list(/datum/action/cooldown/spell/prayer_base/scribe/written_prayer = CLERIC_ORI)
	if(length(patron?.miracles))
		. |= patron.miracles

/datum/devotion/proc/get_traits_tier()
	. = list()
	if(patron && length(patron.traits_tier))
		. += patron.traits_tier
	var/datum/domain/D = holder?.divine_domain
	if(D)
		for(var/trait in D.traits_tier)
			if(isnull(.[trait]) || D.traits_tier[trait] < .[trait])
				.[trait] = D.traits_tier[trait]
