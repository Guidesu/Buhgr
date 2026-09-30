/mob/living/carbon/human/proc/handle_curses()
	for(var/curse in curses)
		var/datum/curse/C = curse
		C.on_life(src)

/mob/living/carbon/human/proc/add_curse(datum/curse/C)
	if(is_cursed(C))
		return FALSE

	C = new C()
	curses += C
	var/curse_resist = FALSE
	if(HAS_TRAIT(src, TRAIT_CURSE_RESIST))
		curse_resist = 0.5
	C.on_gain(src, curse_resist)
	return TRUE

/mob/living/carbon/human/proc/remove_curse(datum/curse/C)
	if(!is_cursed(C))
		return FALSE

	var/curse_resist = FALSE
	if(HAS_TRAIT(src, TRAIT_CURSE_RESIST))
		curse_resist = 0.5
	for(var/datum/curse/curse in curses)
		if(curse.name == C.name)
			curse.on_loss(src, curse_resist)
			curses -= curse
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/is_cursed(datum/curse/C)
	if(!C)
		return FALSE

	for(var/datum/curse/curse in curses)
		if(curse.name == C.name)
			return TRUE
	return FALSE

/datum/curse
	var/name = "Debug Curse"
	var/description = "This is a debug curse."
	var/trait

/datum/curse/proc/on_life(mob/living/carbon/human/owner)
	return

/datum/curse/proc/on_death(mob/living/carbon/human/owner)
	return

/datum/curse/proc/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	ADD_TRAIT(owner, trait, TRAIT_CURSE)
	to_chat(owner, span_userdanger("Something is wrong... I feel cursed."))
	to_chat(owner, span_danger(description))
	owner.playsound_local(get_turf(owner), 'sound/misc/excomm.ogg', 80, FALSE, pressure_affected = FALSE)
	return

/datum/curse/proc/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	REMOVE_TRAIT(owner, trait, TRAIT_CURSE)
	to_chat(owner, span_userdanger("Something has changed... I feel relieved."))
	owner.playsound_local(get_turf(owner), 'sound/misc/bell.ogg', 80, FALSE, pressure_affected = FALSE)
	qdel(src)
	return

//////////////////////////
///   CONCORDAT CURSES  ///
//////////////////////////
// Auxentius+Auxentius merged into Auxentius; Noc+Eora merged into Miluse; Malum+Pestra merged into Handwerra;
// Necra+Matthios merged into Morwenna (see Old Kin / Tribunal sections below for the rest).

/datum/curse/auxentius
	name = "Curse of the Sun"
	description = "I am forsaken by the Sun and by Law. I will find no rest under their unwavering gaze, and my opponents will show me no clemency."
	trait = TRAIT_CURSE_AUXENTIUS

/datum/curse/miluse
	name = "Curse of the Moon"
	description = "I am forsaken by the Moon. I will find no salvation in its grace, and no beauty in this world."
	trait = TRAIT_CURSE_MILUSE

/datum/curse/ignatius
	name = "Curse of the Wilds"
	description = "I am forsaken by the Wilds. Reason and common sense abandon me."
	trait = TRAIT_CURSE_IGNATIUS //Needs something unique but come up with it later:tm:

/datum/curse/wulfric
	name = "Curse of the Sea"
	description = "I am forsaken by the Sea. Its waters will surely become my grave."
	trait = TRAIT_CURSE_WULFRIC

/datum/curse/morwenna
	name = "Curse of Death"
	description = "I am forsaken by Death. Even the lightest strike could send me into its embrace, and greed will be my only salvation."
	trait = TRAIT_CURSE_MORWENNA //Should be crit weakness still just flavour:tm:

/datum/curse/viator
	name = "Curse of Trickery"
	description = "I am forsaken by Trickery. Misfortune follows me on every step."
	trait = TRAIT_CURSE_VIATOR

/datum/curse/handwerra
	name = "Curse of the Craft"
	description = "I am forsaken by the Craft. My hands tremble, fog overwhelms my mind, and sickness renders even the simplest of tasks a challenge."
	trait = TRAIT_CURSE_HANDWERRA

//////////////////////////
///   OLD KIN CURSES    ///
//////////////////////////

/datum/curse/aurelian
	name = "Curse of the Forbidden"
	description = "I am forsaken by the Forbidden. Its grasp reaches for my heart."
	trait = TRAIT_CURSE_AURELIAN

/datum/curse/volkovoi
	name = "Curse of War"
	description = "I am forsaken by War. Bloodlust is the only thing I know for real."
	trait = TRAIT_CURSE_VOLKOVOI

/datum/curse/hausvette
	name = "Curse of Love"
	description = "I am forsaken by Love. I am drowning in its promises."
	trait = TRAIT_CURSE_HAUSVETTE

//////////////////////
///	ON LIFE		///
//////////////////////

/datum/curse/auxentius/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return

	if(world.time % 5)
		if(GLOB.tod != "night")
			if(isturf(H.loc))
				var/turf/T = H.loc
				if(T.can_see_sky())
					if(T.get_lumcount() > 0.15)
						H.fire_act(1,5)

/datum/curse/miluse/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return

	if(world.time % 5)
		if(GLOB.tod != "day")
			if(isturf(H.loc))
				var/turf/T = H.loc
				if(T.can_see_sky())
					if(T.get_lumcount() > 0.15)
						H.fire_act(1,5)


//////////////////////
/// ON GAIN / LOSS ///
//////////////////////

//AUXENTIUS// (Auxentius's sleeplessness + Auxentius's combat malus)
/datum/curse/auxentius/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	if(curse_resist && prob(50))
		return
	ADD_TRAIT(owner, TRAIT_NOSLEEP, TRAIT_GENERIC)

/datum/curse/auxentius/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOSLEEP, TRAIT_GENERIC)

//MORWENNA// (Necra's crit weakness/CON nuke)
/datum/curse/morwenna/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STACON -= (10 * (1 - curse_resist))
	if(curse_resist && prob(50))
		return
	ADD_TRAIT(owner, TRAIT_CRITICAL_WEAKNESS, TRAIT_GENERIC)

/datum/curse/morwenna/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STACON += (10 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_CRITICAL_WEAKNESS, TRAIT_GENERIC)

//VIATOR// (Xylix's luck nuke)
/datum/curse/viator/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STALUC -= (20 * (1 - curse_resist))

/datum/curse/viator/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STALUC += (20 * (1 - curse_resist))

//HANDWERRA// (Pestra's stamina/no-run/missing nose)
/datum/curse/handwerra/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAWIL -= (10 * (1 - curse_resist))
	if(curse_resist && prob(50))
		return
	ADD_TRAIT(owner, TRAIT_NORUN, TRAIT_GENERIC)
	ADD_TRAIT(owner, TRAIT_MISSING_NOSE, TRAIT_GENERIC)

/datum/curse/handwerra/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAWIL += (10 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_NORUN, TRAIT_GENERIC)
	REMOVE_TRAIT(owner, TRAIT_MISSING_NOSE, TRAIT_GENERIC)

//MILUSE// (Eora's trait trio)
/datum/curse/miluse/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	var/curse_chance = (100 * (1 - curse_resist))
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_GENERIC)
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_UNSEEMLY, TRAIT_GENERIC)
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_BAD_MOOD, TRAIT_GENERIC)

/datum/curse/miluse/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_GENERIC)
	REMOVE_TRAIT(owner, TRAIT_UNSEEMLY, TRAIT_GENERIC)
	REMOVE_TRAIT(owner, TRAIT_BAD_MOOD, TRAIT_GENERIC)

//OLD KIN//

//AURELIAN//
/datum/curse/aurelian/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAINT -= (20 * (1 - curse_resist))
	ADD_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, TRAIT_GENERIC)

/datum/curse/aurelian/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAINT += (20 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, TRAIT_GENERIC)

//VOLKOVOI//
/datum/curse/volkovoi/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STASTR -= (14 * (1 - curse_resist))
	ADD_TRAIT(owner, TRAIT_DISFIGURED, TRAIT_GENERIC)
	ADD_TRAIT(owner, TRAIT_INHUMEN_ANATOMY, TRAIT_GENERIC)

/datum/curse/volkovoi/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STASTR += (14 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_DISFIGURED, TRAIT_GENERIC)
	REMOVE_TRAIT(owner, TRAIT_INHUMEN_ANATOMY, TRAIT_GENERIC)

//HAUSVETTE//
/datum/curse/hausvette/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	var/curse_chance = (100 * (1 - curse_resist))
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_NUDIST, TRAIT_GENERIC)
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_NUDE_SLEEPER, TRAIT_GENERIC)
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_GENERIC)

/datum/curse/hausvette/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NUDIST, TRAIT_GENERIC)
	REMOVE_TRAIT(owner, TRAIT_NUDE_SLEEPER, TRAIT_GENERIC)
	REMOVE_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_GENERIC)
