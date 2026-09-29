// Intimacy merge: Twilight's engine runs every session, Ratwood's items and
// traits still apply. A chastity device blocks the organs it covers, forced or
// not. Ratwood's checks already handle cursed device modes, so reuse them.

/datum/erp_actor/human/is_organ_accessible_for(datum/erp_actor/by_actor, organ_type, allow_force = FALSE)
	var/mob/living/carbon/human/owner = get_human()
	if(owner?.sexcon && dreamvalley_chastity_blocks(owner.sexcon, organ_type))
		return FALSE
	return ..()

/proc/dreamvalley_chastity_blocks(datum/sex_controller/controller, organ_type)
	switch(organ_type)
		if(SEX_ORGAN_PENIS)
			return controller.has_chastity_penis()
		if(SEX_ORGAN_VAGINA)
			return controller.has_chastity_vagina()
		if(SEX_ORGAN_ANUS)
			return controller.has_chastity_anal()
	return FALSE
