/**
 * Beds as save points.
 *
 * Lying down to sleep in a bed saves the character and makes that bed the
 * place they wake up the next time they are resumed from the lobby.
 *
 * COMSIG_SLEEPING_ON_BED fires on every life tick spent lying in bed, so the
 * save only happens when the bed changes or DREAMVALLEY_BED_SAVE_INTERVAL has
 * passed since the last one, and the disk write is left to the next autosave
 * tick rather than done here.
 */
#define DREAMVALLEY_BED_SAVE_INTERVAL (5 MINUTES)

/mob/living/carbon/human
	/// world.time of this body's last bed save.
	var/dreamvalley_last_bed_save = 0

/obj/structure/bed/rogue/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SLEEPING_ON_BED, PROC_REF(on_sleeping_on_bed))

/obj/structure/bed/rogue/proc/on_sleeping_on_bed(datum/source, mob/living/sleeper)
	SIGNAL_HANDLER
	if(!GLOB.dreamvalley_campaign?.enabled || !ishuman(sleeper))
		return
	INVOKE_ASYNC(GLOB.dreamvalley_campaign, TYPE_PROC_REF(/datum/dreamvalley_campaign_manager, save_at_bed), sleeper, src)

/datum/dreamvalley_campaign_manager/proc/save_at_bed(mob/living/carbon/human/sleeper, obj/structure/bed/rogue/bed)
	if(QDELETED(sleeper) || QDELETED(bed) || !sleeper.client || sleeper.stat == DEAD)
		return
	var/turf/bed_turf = get_turf(bed)
	if(!bed_turf)
		return

	var/list/old_record = sleeper.dreamvalley_character_uid ? character_records[sleeper.dreamvalley_character_uid] : null
	var/list/old_bed = old_record?["bed"]
	var/same_bed = islist(old_bed) && old_bed["x"] == bed_turf.x && old_bed["y"] == bed_turf.y && old_bed["z"] == bed_turf.z
	if(same_bed && world.time < sleeper.dreamvalley_last_bed_save + DREAMVALLEY_BED_SAVE_INTERVAL)
		return
	sleeper.dreamvalley_last_bed_save = world.time

	var/list/record = save_character(sleeper, "in_world")
	if(!record)
		return
	var/area/bed_area = get_area(bed)
	record["bed"] = list(
		"x" = bed_turf.x,
		"y" = bed_turf.y,
		"z" = bed_turf.z,
		"location" = bed_area ? bed_area.name : "unknown",
	)
	request_checkpoint_soon()
	if(same_bed)
		to_chat(sleeper, span_notice("Your progress is saved."))
	else
		to_chat(sleeper, span_notice("Your progress is saved. When you return, you will wake up in this bed."))

/// Forget a character's bed; they will resume where they were last saved instead.
/datum/dreamvalley_campaign_manager/proc/clear_character_bed(uid)
	var/list/record = character_records[uid]
	if(!islist(record) || !record["bed"])
		return FALSE
	record["bed"] = null
	request_checkpoint_soon()
	return TRUE

#undef DREAMVALLEY_BED_SAVE_INTERVAL
