// Redolent (Ratwood quirk): a strong personal scent that lingers on anyone you touch
// intimately and that nearby people notice. Ratwood makes it a quirk; this codebase has
// no quirk system, so it's a virtue. The scent type and text are chosen in the character
// menu (DreamValley card) and saved with the character.

/datum/virtue/utility/redolent
	name = "Redolent"
	desc = "My body odor is strong and distinct. Without regular baths, others will notice..."
	added_traits = list(TRAIT_REDOLENT)

/datum/virtue/utility/redolent/apply_to_human(mob/living/carbon/human/recipient)
	recipient.redolent_scent_type = recipient.client?.prefs?.redolent_type || "Neutral"
	recipient.redolent_scent = recipient.client?.prefs?.redolent_scent || ""

/datum/preferences
	var/redolent_type = "Neutral"
	var/redolent_scent = ""

/datum/preferences/proc/get_default_redolent_scent(scent_type)
	switch(scent_type)
		if("Gross")
			return "rotting meat and sour sweat"
		if("Pleasant")
			return "wildflowers and clean rain"
	return "earth and sweat"

// Ratwood runs this from human life.dm.
/mob/living/carbon/human/Life()
	. = ..()
	if(mind && HAS_TRAIT(src, TRAIT_REDOLENT))
		handle_redolent_scent()

// Ratwood hooks the soap; here any soap-strength wash (soap, baths) counts.
/mob/living/carbon/human/clean_blood(datum/source, strength)
	. = ..()
	if(strength < CLEAN_MEDIUM)
		return
	if(HAS_TRAIT(src, TRAIT_REDOLENT))
		redolent_on_bath()
	remove_status_effect(/datum/status_effect/debuff/stinky_contact)

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(user == src || get_dist(user, src) > 3)
		return
	var/reeking_naturally = is_redolent_reeking()
	if(!reeking_naturally && !has_status_effect(/datum/status_effect/debuff/stinky_contact))
		return
	var/can_see_stink = !isliving(user) // adminghost always sees it
	if(isliving(user))
		var/mob/living/living_user = user
		can_see_stink = living_user.can_smell() && !HAS_TRAIT(living_user, TRAIT_NOSTINK)
	if(!can_see_stink)
		return
	if(reeking_naturally)
		. += redolent_examine_text(redolent_scent_type, redolent_scent)
	else
		var/datum/status_effect/debuff/stinky_contact/contact_stink = has_status_effect(/datum/status_effect/debuff/stinky_contact)
		if(contact_stink)
			. += contact_stink.get_examine_text()


// Redolent scent state and behavior. This is purely quirk-driven now: the quirk applies
// TRAIT_REDOLENT, the mob holds the scent state, and life.dm drives handle_redolent_scent().
/mob/living/carbon/human
	/// How others perceive our scent: "Gross", "Neutral" or "Pleasant".
	var/redolent_scent_type = "Neutral"
	/// Player-written description of our scent.
	var/redolent_scent = ""
	/// Bathing suppresses our scent until this world.time.
	var/redolent_suppressed_until = 0
	/// The last time our scent aura pulsed.
	var/redolent_last_aura_tick = 0

/mob/living/carbon/human/proc/is_redolent_reeking()
	return HAS_TRAIT(src, TRAIT_REDOLENT) && world.time >= redolent_suppressed_until

/mob/living/carbon/human/proc/redolent_on_bath()
	redolent_suppressed_until = world.time + 30 MINUTES
	remove_status_effect(/datum/status_effect/debuff/redolent_stink)
	to_chat(src, span_notice("I scrub the stink away. I should stay fresh for a while."))

/mob/living/carbon/human/proc/redolent_apply_contact_stink(mob/living/carbon/human/target)
	target.apply_status_effect(/datum/status_effect/debuff/stinky_contact, redolent_scent_type, redolent_scent)

/mob/living/carbon/human/proc/handle_redolent_scent()
	var/should_reek = is_redolent_reeking() && can_smell()

	if(should_reek && mind?.antag_datums)
		for(var/datum/antagonist/D in mind.antag_datums)
			if(istype(D, /datum/antagonist/vampire/lord) || istype(D, /datum/antagonist/werewolf) || istype(D, /datum/antagonist/skeleton) || istype(D, /datum/antagonist/zombie) || istype(D, /datum/antagonist/lich))
				should_reek = FALSE
				break

	if(should_reek && redolent_scent_type != "Pleasant")
		apply_status_effect(/datum/status_effect/debuff/redolent_stink)
	else
		remove_status_effect(/datum/status_effect/debuff/redolent_stink)

	if(!should_reek)
		return
	if(world.time < redolent_last_aura_tick + redolent_aura_tick_delay(redolent_scent_type))
		return
	redolent_last_aura_tick = world.time
	redolent_visual_effect(src, redolent_scent_type)
	redolent_stink_aura(src, redolent_scent_type)

/proc/redolent_aura_tick_delay(scent_type)
	return 30 SECONDS

/proc/redolent_examine_text(scent_type, scent)
	var/scent_text = html_encode(scent || "an unusual scent")
	switch(scent_type)
		if("Gross")
			return span_greentext("They reek of [scent_text].")
		if("Pleasant")
			return "<span style='color:#FFB6C1'>They smell of [scent_text].</span>"
	return "<span style='color:#d8cf8a'>They smell of [scent_text].</span>"

/proc/redolent_visual_effect(mob/living/carbon/human/H, scent_type)
	switch(scent_type)
		if("Gross")
			new /obj/effect/temp_visual/flies(get_turf(H))
		if("Pleasant")
			new /obj/effect/temp_visual/pleasant_scent(get_turf(H))

/proc/redolent_stink_aura(mob/living/carbon/human/H, scent_type)
	for(var/mob/living/nearby in view(2, H))
		if(nearby == H)
			continue
		if(nearby.stat)
			continue
		if(!nearby.can_smell())
			continue
		if(HAS_TRAIT(nearby, TRAIT_NOSTINK))
			continue
		if(HAS_TRAIT(nearby, TRAIT_NOBREATH))
			continue
		switch(scent_type)
			if("Gross")
				if(!nearby.has_stress_event(/datum/stressevent/stinky_aura))
					to_chat(nearby, "<span class='warning' style='color:#48c75a'>Something nearby reeks.</span>")
					nearby.add_stress(/datum/stressevent/stinky_aura)
			if("Neutral")
				if(!nearby.has_stress_event(/datum/stressevent/prominent_scent))
					to_chat(nearby, "<span class='warning' style='color:#d8cf8a'>There's a prominent scent in the air.</span>")
					nearby.add_stress(/datum/stressevent/prominent_scent)
			if("Pleasant")
				if(!nearby.has_stress_event(/datum/stressevent/pleasant_scent))
					to_chat(nearby, "<span class='warning' style='color:#ffb6c1'>A pleasant scent drifts through the air.</span>")
					nearby.add_stress(/datum/stressevent/pleasant_scent)

/datum/status_effect/debuff/redolent_stink
	id = "redolent_stink"
	duration = 999 MINUTES
	alert_type = null

	mob_effect_icon = 'icons/effects/effects.dmi'
	mob_effect_icon_state = "mob_smell"
	mob_effect_layer = ABOVE_MOB_LAYER

/datum/status_effect/debuff/stinky_contact
	id = "stinky_contact"
	duration = 15 MINUTES
	tick_interval = 5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/debuff/stinky_contact
	var/scent_type = "Gross"
	var/scent = ""
	var/last_aura_tick = 0

/datum/status_effect/debuff/stinky_contact/on_creation(mob/living/new_owner, inherited_scent_type = "Gross", inherited_scent = "")
	set_inherited_scent(inherited_scent_type, inherited_scent)
	return ..()

/datum/status_effect/debuff/stinky_contact/refresh(mob/living/new_owner, inherited_scent_type = "Gross", inherited_scent = "")
	set_inherited_scent(inherited_scent_type, inherited_scent)
	if(owner)
		process_inherited_scent(TRUE)
	return ..()

/datum/status_effect/debuff/stinky_contact/proc/set_inherited_scent(inherited_scent_type, inherited_scent)
	scent_type = inherited_scent_type
	scent = inherited_scent
	last_aura_tick = 0

/datum/status_effect/debuff/stinky_contact/on_apply()
	. = ..()
	if(scent_type == "Pleasant")
		to_chat(owner, span_notice("I share someone else's pleasant scent now!"))
	else if(scent_type == "Neutral")
		to_chat(owner, span_notice("I stink of someone else now..."))
	else
		to_chat(owner, span_warning("I reek of someone else's stench now...ew..."))
	process_inherited_scent(TRUE)

/datum/status_effect/debuff/stinky_contact/tick()
	process_inherited_scent()

/datum/status_effect/debuff/stinky_contact/proc/process_inherited_scent(force = FALSE)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(!H.can_smell())
		H.remove_status_effect(/datum/status_effect/debuff/redolent_stink)
		return
	if(scent_type != "Pleasant")
		if(!H.has_status_effect(/datum/status_effect/debuff/redolent_stink))
			H.apply_status_effect(/datum/status_effect/debuff/redolent_stink)
	else if(H.has_status_effect(/datum/status_effect/debuff/redolent_stink))
		H.remove_status_effect(/datum/status_effect/debuff/redolent_stink)
	if(!force && world.time < last_aura_tick + redolent_aura_tick_delay(scent_type))
		return
	last_aura_tick = world.time
	redolent_visual_effect(H, scent_type)
	redolent_stink_aura(H, scent_type)

/datum/status_effect/debuff/stinky_contact/on_remove()
	to_chat(owner, span_notice("The lingering scent finally fades off me."))
	if(!HAS_TRAIT(owner, TRAIT_REDOLENT))
		owner.remove_status_effect(/datum/status_effect/debuff/redolent_stink)
	return ..()

/datum/status_effect/debuff/stinky_contact/proc/get_examine_text()
	return redolent_examine_text(scent_type, scent)

/atom/movable/screen/alert/status_effect/debuff/stinky_contact
	name = "Musked"
	desc = "Someone's stench rubbed off on me. I should be able to wash it off, or wait it out."
	icon_state = "debuff"

/obj/effect/temp_visual/pleasant_scent
	name = "pleasant scent"
	icon = 'icons/effects/effects.dmi'
	icon_state = "mob_smell"
	duration = 15
	plane = GAME_PLANE_UPPER
	layer = ABOVE_ALL_MOB_LAYER
	color = list(0,0,0,0, 1.0, 0.6, 0.8, 0, 0,0,0,0, 0,0,0,1, 0,0,0,0) // faint pastel pink tint

/obj/effect/temp_visual/pleasant_scent/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	animate(src, pixel_y = pixel_y + 32, alpha = 0, time = duration)

/datum/stressevent/stinky_aura
	timer = 1 MINUTES
	stressadd = 2
	desc = span_red("Something nearby reeks.")

/datum/stressevent/prominent_scent
	timer = 1 MINUTES
	stressadd = 1
	desc = span_red("There's a prominent scent in the air.")

/datum/stressevent/pleasant_scent
	timer = 1 MINUTES
	stressadd = -1
	desc = span_green("A pleasant scent lifts my mood.")


// Two more Ratwood quirks tied to sexcon, also as virtues.
/datum/virtue/utility/acquired_tastes
	name = "Acquired Tastes"
	desc = "Despite my unorthodox tastes, I'm always prepared to handle a guest with the toys I keep stashed."
	custom_text = "Adds a bag of sexual instruments, including a small vial of emberwine, to your stash."
	added_stashed_items = list("Bag of Fetish Gear" = /obj/item/storage/roguebag/fetish)

/datum/virtue/utility/rough_lover
	name = "Rough Lover"
	desc = "With strong intent, I am a violent partner in bed. Breaking pelvis and spirit alike."
	added_traits = list(TRAIT_DEATHBYSNUSNU)
