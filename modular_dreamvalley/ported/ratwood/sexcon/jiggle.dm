// Ratwood breast jiggle (the "Bath Dance" feature, as on Ratwood
// main), plus Ratwood's "jiggle on rough intent": breasts jiggle during rough (high force) sex.
// Sprites: icons/mob/sprite_accessory/genitals/breasts.dmi carries the *_jiggle states.

#define MIN_JIGGLE_BREASTS_SIZE 1
#define BREAST_JIGGLE_CYCLE (0.8 SECONDS)
#define BREAST_JIGGLE_MIN_DURATION 8
#define BREAST_JIGGLE_MAX_DURATION 100
#define BREAST_JIGGLE_FREE_DURATION 50
#define BREAST_JIGGLE_STAMINA_PER_SECOND 0.83
#define BREAST_JIGGLE_ENDLESS_STAMINA_MULT 3
#define BREAST_JIGGLE_HOP_HEIGHT 4
#define BREAST_JIGGLE_ENDLESS 0
#define BREAST_JIGGLE_PROMPT_STEP (BREAST_JIGGLE_CYCLE * 2)

/obj/item/organ/breasts
	var/can_jiggle = TRUE
	var/is_jiggling = FALSE
	var/jiggle_endless = FALSE
	var/jiggle_costs_stamina = FALSE
	var/jiggle_cycles_left = 0
	var/jiggle_timerid
	var/static/list/jiggle_interrupt_signals = list(
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_ITEM_BEING_ATTACKED,
		COMSIG_MOB_ATTACK_HAND,
		COMSIG_MOB_ATTACKED_BY_HAND,
		COMSIG_MOB_APPLY_DAMGE,
	)

/obj/item/organ/breasts/Destroy()
	stop_jiggle()
	return ..()

/obj/item/organ/breasts/get_cache_key()
	return "[..()]-[breast_size]-[is_jiggling]"

/obj/item/organ/breasts/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	stop_jiggle()
	return ..()

/obj/item/organ/breasts/Remove(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	stop_jiggle()
	return ..()

/obj/item/organ/breasts/proc/start_jiggle(duration, endless = FALSE, costs_stamina = FALSE)
	if(is_jiggling || !ishuman(owner))
		return FALSE
	is_jiggling = TRUE
	jiggle_endless = endless
	jiggle_costs_stamina = costs_stamina
	jiggle_cycles_left = endless ? 0 : max(1, round(duration / BREAST_JIGGLE_CYCLE, 1))
	var/mob/living/carbon/human/H = owner
	RegisterSignal(H, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_MOB_ATTACK_HAND), PROC_REF(on_jiggle_attacking))
	RegisterSignal(H, COMSIG_MOB_ITEM_BEING_ATTACKED, PROC_REF(on_jiggle_attacked_with_item))
	RegisterSignal(H, COMSIG_MOB_ATTACKED_BY_HAND, PROC_REF(on_jiggle_attacked_by_hand))
	RegisterSignal(H, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_jiggle_damaged))
	H.update_body_parts(TRUE)
	jiggle_cycle()
	return TRUE

/obj/item/organ/breasts/proc/jiggle_cycle()
	jiggle_timerid = null
	if(!is_jiggling)
		return
	var/mob/living/carbon/human/H = owner
	if(QDELETED(H) || !ishuman(H) || H.stat != CONSCIOUS || H.cmode || H.doing || !(H.mobility_flags & MOBILITY_STAND))
		stop_jiggle()
		return
	if(jiggle_costs_stamina && !H.jiggle_stamina_is_free())
		var/cycle_cost = BREAST_JIGGLE_STAMINA_PER_SECOND * (BREAST_JIGGLE_CYCLE / (1 SECONDS))
		if(jiggle_endless)
			cycle_cost *= BREAST_JIGGLE_ENDLESS_STAMINA_MULT
		if(!H.stamina_add(cycle_cost))
			stop_jiggle()
			return
	H.do_jiggle_hop()
	if(!jiggle_endless)
		jiggle_cycles_left--
		if(jiggle_cycles_left <= 0)
			stop_jiggle()
			return
	jiggle_timerid = addtimer(CALLBACK(src, PROC_REF(jiggle_cycle)), BREAST_JIGGLE_CYCLE, TIMER_STOPPABLE)

/obj/item/organ/breasts/proc/stop_jiggle()
	if(jiggle_timerid)
		deltimer(jiggle_timerid)
		jiggle_timerid = null
	if(!is_jiggling)
		return
	is_jiggling = FALSE
	jiggle_endless = FALSE
	jiggle_costs_stamina = FALSE
	jiggle_cycles_left = 0
	var/mob/living/carbon/human/H = owner
	if(QDELETED(H) || !ishuman(H))
		return
	UnregisterSignal(H, jiggle_interrupt_signals)
	H.update_body_parts(TRUE)

/obj/item/organ/breasts/proc/interrupt_jiggle(mob/living/attacker)
	if(attacker?.used_intent?.type == INTENT_HELP)
		return
	stop_jiggle()

/obj/item/organ/breasts/proc/on_jiggle_attacking(datum/source)
	SIGNAL_HANDLER
	interrupt_jiggle(owner)

/obj/item/organ/breasts/proc/on_jiggle_attacked_with_item(datum/source, mob/living/victim, mob/living/attacker)
	SIGNAL_HANDLER
	interrupt_jiggle(attacker)

/obj/item/organ/breasts/proc/on_jiggle_attacked_by_hand(datum/source, mob/living/attacker, mob/living/victim)
	SIGNAL_HANDLER
	interrupt_jiggle(attacker)

/obj/item/organ/breasts/proc/on_jiggle_damaged(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(damage <= 0)
		return
	stop_jiggle()

// Rough intent: a short jiggle on each rough thrust (called from sexcon do_thrust_animate()).
/obj/item/organ/breasts/proc/thrust_jiggle_on()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(H.stat != CONSCIOUS || H.cmode || H.doing)
		return
	if(is_jiggling)
		return
	is_jiggling = TRUE
	H.update_body_parts(TRUE)
	refresh_viewers(H)

/obj/item/organ/breasts/proc/thrust_jiggle_off()
	stop_jiggle()
	refresh_viewers(owner)

/// Refreshes the vision of everyone who can see source, so icon_state changes show.
/proc/refresh_viewers(atom/source)
	for(var/mob/M in viewers(7, source))
		if(M.client)
			M.update_vision_cone()

/datum/sprite_accessory/breasts
	var/can_jiggle = FALSE

/datum/sprite_accessory/breasts/pair
	can_jiggle = TRUE

/datum/sprite_accessory/breasts/quad
	can_jiggle = TRUE

/datum/sprite_accessory/breasts/sextuple
	can_jiggle = TRUE

/datum/sprite_accessory/breasts/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/breasts/badonkers = organ
	if(can_jiggle && owner && badonkers.is_jiggling)
		return "[icon_state]_[badonkers.breast_size]_jiggle"
	return ..()

/datum/species/proc/can_jiggle_breasts(mob/living/carbon/human/H)
	if(!H || H.cmode)
		return FALSE
	var/obj/item/organ/breasts/B = H.getorganslot(ORGAN_SLOT_BREASTS)
	if(!B || B.is_jiggling)
		return FALSE
	if(!B.can_jiggle || B.breast_size < MIN_JIGGLE_BREASTS_SIZE)
		return FALSE
	return TRUE

/datum/emote/living/carbon/human/bjiggle
	key = "bjiggle"
	key_third_person = "jiggles"
	message = "shakes their chest and bounces on the spot!"
	emote_type = EMOTE_VISIBLE
	show_runechat = TRUE

/proc/jiggle_duration_label(duration)
	if(duration > BREAST_JIGGLE_FREE_DURATION)
		return "[duration / 10] seconds (tiring)"
	return "[duration / 10] seconds"

/proc/jiggle_duration_choices()
	var/static/list/choices
	if(choices)
		return choices
	choices = list()
	for(var/duration = BREAST_JIGGLE_MIN_DURATION; duration < BREAST_JIGGLE_MAX_DURATION; duration += BREAST_JIGGLE_PROMPT_STEP)
		choices[jiggle_duration_label(duration)] = duration
	choices[jiggle_duration_label(BREAST_JIGGLE_MAX_DURATION)] = BREAST_JIGGLE_MAX_DURATION
	choices["Until I stop myself (very tiring)"] = BREAST_JIGGLE_ENDLESS
	return choices

/datum/emote/living/carbon/human/bjiggle/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.dna || !H.dna.species || !H.dna.species.can_jiggle_breasts(H))
		return
	var/duration = BREAST_JIGGLE_MIN_DURATION
	var/endless = FALSE
	if(intentional && H.client)
		var/list/choices = jiggle_duration_choices()
		var/picked = tgui_input_list(H, "How long should I keep it up?", "Jiggle", choices)
		if(isnull(picked))
			return
		if(QDELETED(H) || !H.dna || !H.dna.species || !H.dna.species.can_jiggle_breasts(H))
			return
		var/chosen = choices[picked]
		if(chosen == BREAST_JIGGLE_ENDLESS)
			endless = TRUE
		else
			duration = chosen
	. = ..()
	if(!.)
		return
	var/obj/item/organ/breasts/B = H.getorganslot(ORGAN_SLOT_BREASTS)
	if(!B)
		return
	var/costs_stamina = endless || (duration > BREAST_JIGGLE_FREE_DURATION)
	if(costs_stamina && !H.jiggle_stamina_is_free() && H.stamina >= H.max_stamina)
		to_chat(H, span_warning("I am far too weary to keep this up."))
		duration = BREAST_JIGGLE_MIN_DURATION
		endless = FALSE
		costs_stamina = FALSE
	B.start_jiggle(duration, endless, costs_stamina)

/datum/emote/living/carbon/human/bjiggle/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return H.dna && H.dna.species && H.dna.species.can_jiggle_breasts(H)

/mob/living/carbon/human/proc/do_jiggle_hop()
	animate(src, pixel_z = BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_z = -BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_IN, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_z = BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_z = -BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_IN, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)

/mob/living/carbon/human/proc/jiggle_stamina_is_free()
	if(!HAS_TRAIT(src, TRAIT_BATHHOUSE_DANCER))
		return FALSE
	return istype(get_area(src), /area/rogue/indoors/town/bath)

/mob/living/carbon/human/verb/emote_bjiggle()
	set name = "Jiggle"
	set category = "Emotes"

	var/obj/item/organ/breasts/B = getorganslot(ORGAN_SLOT_BREASTS)
	if(B?.is_jiggling)
		B.stop_jiggle()
		return
	emote("bjiggle", intentional = TRUE)
