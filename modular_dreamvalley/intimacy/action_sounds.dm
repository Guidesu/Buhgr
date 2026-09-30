// Intimacy merge: Twilight only made noise for thrusting, sucking and
// spanking. Every other action (fingering, rubbing, grinding, tails, feet...)
// was silent. Fill those in with Ratwood's sound set, scaled by force.

/datum/erp_vfx_service/play_tick_effects(list/active_links, dt)
	..()
	if(controller.hidden_mode)
		return
	var/list/E = build_tick_effect_bundle(active_links, dt)
	if(E?["thrust_link"] || E?["suck_link"] || E?["slap_link"])
		return // Twilight already played something for this tick.
	for(var/datum/erp_sex_link/L in active_links)
		if(!L || QDELETED(L) || !L.is_valid())
			continue
		var/mob/living/carbon/human/actor = L.actor_active?.get_effect_mob()
		if(istype(actor))
			play_generic_action_sound(actor, L)
			return

/datum/erp_vfx_service/proc/play_generic_action_sound(mob/living/carbon/human/actor, datum/erp_sex_link/L)
	var/init_t = L.init_organ?.erp_organ_type
	var/tgt_t = L.target_organ?.erp_organ_type
	var/strength = "gentle"
	switch(L.force)
		if(SEX_FORCE_HIGH)
			strength = "firm"
		if(SEX_FORCE_EXTREME, SEX_FORCE_LUDICROUS)
			strength = "brutal"

	if(init_t == SEX_ORGAN_HANDS && tgt_t == SEX_ORGAN_PENIS)
		playsound(actor, 'sound/misc/mat/fap.ogg', 35, TRUE, -2, ignore_walls = FALSE)
		return
	if(init_t == SEX_ORGAN_HANDS && (tgt_t in list(SEX_ORGAN_VAGINA, SEX_ORGAN_ANUS)))
		playsound(actor, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
		return
	// Everything else is skin on skin: rubbing, grinding, tails, feet, breasts.
	var/list/sounds = list()
	var/count = (strength == "brutal") ? 2 : 3
	for(var/i in 1 to count)
		sounds += "sound/misc/mat/outercourse/[strength] ([i]).ogg"
	playsound(actor, file(pick(sounds)), strength == "gentle" ? 15 : 30, TRUE, -2, ignore_walls = FALSE)
