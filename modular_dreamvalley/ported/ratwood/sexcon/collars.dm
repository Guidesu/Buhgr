// Ratwood leash/collar integration that lives in Ratwood's core files.
// The leash itself is modular_twilight_axis/.../rogueitems/leash.dm (Ratwood's leash
// plus Twilight's desync fixes); the slave collar is modular/code/modules/slave_collar/.

/// Carbon attackby tries surgery steps first outside combat mode, which swallowed the
/// leash click; Ratwood lets the leash through before that.
/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/leash))
		return I.attack(src, user)
	return ..()

/// A leashed pet unhooks the leash when resisting (Ratwood checks this right before
/// slipping restraints).
/mob/living/carbon/resist_restraints()
	if(has_status_effect(/datum/status_effect/leash_pet))
		resist_leash()
		return
	return ..()

/mob/living/proc/resist_leash()
	return

/mob/living/carbon/resist_leash()
	to_chat(src, span_notice("I reach for the hook on my collar..."))
	var/deleash = handcuffed ? 20 SECONDS : 5 SECONDS
	if(move_after(src, deleash, 0, target = src) && !QDELETED(src))
		to_chat(src, span_warning("I have removed my leash!"))
		remove_status_effect(/datum/status_effect/leash_pet)

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(has_status_effect(/datum/status_effect/leash_pet))
		. += span_warning("A leash is hooked to [p_their()] collar. [p_theyre(TRUE)] being led like a pet.")

/// Ratwood makes AP's cursed collar leashable too.
/obj/item/clothing/neck/roguetown/gorget/cursed_collar
	leashable = TRUE

/// The collar keeps its own shock/arousal loop ids per pet. Ratwood stores them in the
/// per-datum timer list; here that list is _active_timers (timer subsystem), so the
/// collar gets its own list instead.
/mob/living/carbon/human
	var/list/active_timers

/mob/living/proc/adjust_blood_volume(amount)
	return set_blood_volume(blood_volume + amount)

/mob/living/carbon/proc/get_damage_condition_summary()
	var/list/conditions = list()
	var/brute_condition = get_damage_descriptor_text(getBruteLoss(), "some bruises", "a lot of bruises", "black and blue")
	if(brute_condition)
		conditions += brute_condition
	var/fire_condition = get_damage_descriptor_text(getFireLoss(), "some burns", "many burns", "dragon food")
	if(fire_condition)
		conditions += fire_condition
	if(!length(conditions))
		return "No obvious bruises or burns"
	return capitalize(jointext(conditions, "; "))
/mob/living/carbon/proc/get_damage_descriptor_text(damage_amount, minor_text, moderate_text, severe_text)
	if(!damage_amount)
		return null
	if(damage_amount < 25)
		return minor_text
	if(damage_amount < 50)
		return moderate_text
	return severe_text

