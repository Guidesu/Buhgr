/**
 * Far Travel in a campaign: save the character and return to the lobby.
 *
 * The normal Far Travel path deletes the character for good (forgets known
 * people, removes bounties, forfeits bank balances). In a campaign the
 * character is saved instead and can be resumed later from the lobby.
 */
/datum/dreamvalley_campaign_manager/proc/handle_far_travel(mob/living/carbon/human/traveller, mob/user, obj/structure/far_travel/source)
	if(!enabled)
		return DREAMVALLEY_TRAVEL_UNHANDLED
	if(!traveller || !user || !source)
		return DREAMVALLEY_TRAVEL_HANDLED

	if(traveller != user || !traveller.client)
		to_chat(user, span_warning("Only the person travelling can do this."))
		return DREAMVALLEY_TRAVEL_HANDLED
	if(traveller.stat != CONSCIOUS)
		to_chat(user, span_warning("You are in no state to travel."))
		return DREAMVALLEY_TRAVEL_HANDLED

	if(tgui_alert(user, "Leave for now? Your character, belongings and injuries are saved, and you can resume from the lobby later.", "Far Travel", list("Save and leave", "Stay")) != "Save and leave")
		return DREAMVALLEY_TRAVEL_HANDLED
	if(QDELETED(traveller) || !traveller.client || get_dist(source, traveller) > 2)
		return DREAMVALLEY_TRAVEL_HANDLED

	source.in_use = TRUE
	traveller.visible_message(span_notice("[traveller] prepares to travel far away."), span_notice("You prepare to travel."))
	if(!do_after(traveller, 5 SECONDS, target = source))
		source.in_use = FALSE
		return DREAMVALLEY_TRAVEL_HANDLED
	source.in_use = FALSE
	if(QDELETED(traveller) || !traveller.client)
		return DREAMVALLEY_TRAVEL_HANDLED

	var/list/record = save_character(traveller, "stored")
	if(!record)
		to_chat(traveller, span_warning("Your character could not be saved, so you stayed. Please tell an admin."))
		return DREAMVALLEY_TRAVEL_HANDLED

	traveller.visible_message(span_notice("[traveller] leaves [SSticker.realm_name]."))
	log_game("[key_name(traveller)] far-travelled; saved as [record["uid"]].")
	release_job_slot(traveller)

	var/mob/dead/new_player/lobby = new()
	lobby.key = traveller.key
	var/datum/mind/old_mind = traveller.mind
	qdel(traveller)
	if(old_mind && !QDELETED(old_mind))
		qdel(old_mind)
	request_checkpoint_soon()
	to_chat(lobby, span_nicegreen("[record["name"]] is saved. Choose \"Saved Characters\" in the lobby to continue playing them."))
	return DREAMVALLEY_TRAVEL_HANDLED

/// Frees the traveller's job slot so someone else can take the role.
/datum/dreamvalley_campaign_manager/proc/release_job_slot(mob/living/carbon/human/traveller)
	var/datum/job/job = SSjob.GetJob(traveller.mind?.assigned_role)
	if(!job)
		return
	job.current_positions = max(0, job.current_positions - 1)
	var/datum/advclass/advclass = traveller.get_advclass_datum()
	if(advclass)
		SSrole_class_handler.adjust_class_amount(advclass, -1)

/proc/dreamvalley_handle_far_travel(mob/living/carbon/human/traveller, mob/user, obj/structure/far_travel/source)
	if(!GLOB.dreamvalley_campaign)
		return DREAMVALLEY_TRAVEL_UNHANDLED
	return GLOB.dreamvalley_campaign.handle_far_travel(traveller, user, source)
