// Psyiadonia: the land of the usual Roguetown lore, stitched into Palimpseste like
// every other. Its gods (the Ten, Psydon, the Inhumen) are made selectable and
// sit in the domains that fit them (see domain_list.dm).

/datum/patron/divine/undivided
	name = "The Ten"

/datum/patron/divine/astrata
	preference_accessible = TRUE
/datum/patron/divine/noc
	preference_accessible = TRUE
/datum/patron/divine/dendor
	preference_accessible = TRUE
/datum/patron/divine/abyssor
	preference_accessible = TRUE
/datum/patron/divine/ravox
	preference_accessible = TRUE
/datum/patron/divine/necra
	preference_accessible = TRUE
/datum/patron/divine/xylix
	preference_accessible = TRUE
/datum/patron/divine/pestra
	preference_accessible = TRUE
/datum/patron/divine/malum
	preference_accessible = TRUE
/datum/patron/divine/eora
	preference_accessible = TRUE
/datum/patron/divine/undivided
	preference_accessible = TRUE
/datum/patron/old_god
	preference_accessible = TRUE
/datum/patron/inhumen/zizo
	preference_accessible = TRUE
/datum/patron/inhumen/graggar
	preference_accessible = TRUE
/datum/patron/inhumen/matthios
	preference_accessible = TRUE
/datum/patron/inhumen/baotha
	preference_accessible = TRUE

/datum/virtue/origin/palimpseste/psydonia
	name = "Psyiadonian"
	origin_name = "Psyiadonia"
	desc = "I come from Psyiadonia, the grim old world where the Allfather Psyiadon lies slain, the Ten keep what he left behind, and the Inhumen gnaw at the edges. Azure Peak and its duchy are home, or near enough.<br>"
	origin_desc = "Psyiadonia remembers a creator. The Allfather Psyiadon made its lands and was slain for it, and from his death rose the Ten: radiant Astratha and \
	her brother Nokk, Dendhor of the wilds, Abyssar of the deep, Ravokh the just, Nekhra who keeps the dead, Zylix the jester, Pestrah of plague and cure, Malumm \
	of the forge and Eorah of love. Against them stand the Inhumen - Zyzo, who clawed her way to godhood and broke an empire doing it; Gragghar the butcher; \
	Mathios the thief of fire; Baothe of excess - and the faithful of old Psyiadon, who insist their god is not dead but only sleeping.<br> Its heart is the \
	Grand Duchy of Azuria and the town beneath Azure Peak, ringed by bog, forest and mountain and never more than one bad winter from ruin. Beyond it lie \
	Grenzelhoft's knights, the Otavan inquisitors, the desert of the Ranesheni and the Naledi, and the ruins of the Holy Celestial Empire that Zyzo's \
	ascension destroyed.<br> Psyiadonians are hard, pious and suspicious: they tithe to the Ten, fear the Inhumen and burn heretics, and most of them have \
	never once asked why their world has seams."

// The Ten together cover every domain one of its gods holds.
/datum/patron/divine/undivided
	dv_domains = list(/datum/domain/sun, /datum/domain/moon, /datum/domain/knowledge, /datum/domain/harvest, /datum/domain/wilds, /datum/domain/sea, /datum/domain/war, /datum/domain/law, /datum/domain/death, /datum/domain/trickery, /datum/domain/healing, /datum/domain/craft, /datum/domain/love, /datum/domain/hearth)

// Psyiadonia's gods under slightly altered names. The old name stays a title,
// so prayers that invoke it are still heard as naming the god.
/datum/patron/divine/astrata
	name = "Astratha"
	titles = list("Astrata", "Sun-Faced", "The Radiant")
/datum/patron/divine/noc
	name = "Nokk"
	titles = list("Noc")
/datum/patron/divine/dendor
	name = "Dendhor"
	titles = list("Dendor")
/datum/patron/divine/abyssor
	name = "Abyssar"
	titles = list("Abyssor")
/datum/patron/divine/ravox
	name = "Ravokh"
	titles = list("Ravox")
/datum/patron/divine/necra
	name = "Nekhra"
	titles = list("Necra")
/datum/patron/divine/xylix
	name = "Zylix"
	titles = list("Xylix")
/datum/patron/divine/pestra
	name = "Pestrah"
	titles = list("Pestra")
/datum/patron/divine/malum
	name = "Malumm"
	titles = list("Malum")
/datum/patron/divine/eora
	name = "Eorah"
	titles = list("Eora")
/datum/patron/old_god
	name = "Psyiadon"
	titles = list("Psydon", "Allfather")
/datum/patron/inhumen/zizo
	name = "Zyzo"
	titles = list("Zizo")
/datum/patron/inhumen/graggar
	name = "Gragghar"
	titles = list("Graggar")
/datum/patron/inhumen/matthios
	name = "Mathios"
	titles = list("Matthios")
/datum/patron/inhumen/baotha
	name = "Baothe"
	titles = list("Baotha")
