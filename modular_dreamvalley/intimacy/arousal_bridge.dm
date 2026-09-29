// Intimacy merge: one arousal value. Twilight's arousal component owns it (it
// drives scenes, moans, climax and the pink screen). Ratwood's controller is
// still used by its extras (emberwine, collars, aphrodisiacs), so its changes
// write through to the component and the component copies the result back.

/datum/sex_controller/set_arousal(amount)
	var/datum/component/arousal/component = user?.GetComponent(/datum/component/arousal)
	if(!component)
		return ..()
	if(amount > arousal)
		last_arousal_increase_time = world.time
	component.set_arousal(user, amount)
	arousal = component.arousal
	update_erect_state()

/datum/component/arousal/set_arousal(datum/source, amount, forced = FALSE)
	. = ..()
	var/mob/living/carbon/human/owner = parent
	if(istype(owner) && owner.sexcon)
		owner.sexcon.arousal = arousal
		owner.sexcon.update_erect_state()
