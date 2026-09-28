// DreamValley additions to the Ratwood fishing overhaul (fisher/rod.dm, tackle.dm, fishing_net.dm).
// The rod itself follows Ratwood; this file keeps the Azure Peak and DreamValley pieces that
// the Ratwood version doesn't have.

/// Azure Peak's bronze rod (mapped in several places).
/obj/item/fishingrod/bronze
	name = "bronze fishing rod"
	desc = "A tool of religious importance, used by wide-brimmed priests who offer wriggling sacrifices to the endless waves beneath."
	icon_state = "bronzerod"
	max_integrity = 200

/obj/item/fishingrod/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Put bait on the rod, then click water to fish. Worms, leeches and many other wriggling things make bait.")
	. += span_info("Cast mode plays the reeling game: keep the fish lined up with your marker, reel when it's in the green, and avoid the red. Auto mode is slower but plays itself, using your fishing skill and strength.")
	. += span_info("Hooks, lines and reels can be fitted to the rod. Better tackle makes larger and rarer catches easier to land.")
	. += span_info("Master fishers bait their rod from nearby bait on their own when they cast.")
	. += span_info("Perception makes bites come sooner; perception and fortune make them more likely.")

// Stat integration (see code/modules/mob/living/stat_integration.dm): PER shortens the wait
// for a bite, PER and LCK raise the chance of one.
/obj/item/fishingrod/get_cast_time_multiplier()
	. = ..()
	if(isliving(fisher))
		. /= fisher.get_stat_speed(STATKEY_PER)

/obj/item/fishingrod/get_bite_chance_multiplier(shore_distance)
	. = ..()
	if(isliving(fisher))
		. *= 1 + fisher.get_fishing_success_mod()

// Azure Peak: expert fishers pick up bait from the ground around them when casting unbaited.
/obj/item/fishingrod/afterattack(atom/target, mob/user, proximity, params)
	if(!baited && isliving(user) && user.get_skill_level(/datum/skill/labor/fishing) >= SKILL_LEVEL_EXPERT)
		find_bait(user)
	return ..()

/obj/item/fishingrod/proc/find_bait(mob/user)
	var/turf/T = get_turf(user)
	if(!T)
		return
	for(var/obj/item/I in view(1, T))
		if(I.isbait && try_attach_bait_item(I, user))
			user.playsound_local(T, 'sound/combat/vite.ogg', 100, TRUE)
			return
