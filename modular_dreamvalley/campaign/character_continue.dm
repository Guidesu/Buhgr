/**
 * Resuming a saved character from the lobby.
 *
 * Resume skips job setup and outfits entirely: the body is rebuilt from the
 * saved record. If the character's bed still exists, they wake up lying in
 * it; otherwise they appear where they were last saved.
 */

/// Lets a lobby player pick one of their saved characters and resume it.
/datum/dreamvalley_campaign_manager/proc/prompt_resume_character(mob/dead/new_player/lobby)
	if(!istype(lobby) || !lobby.client)
		return
	if(!SSticker?.IsRoundInProgress())
		to_chat(lobby, span_warning("You can resume a character once the game has started."))
		return
	var/list/records = get_resumable_characters(lobby.ckey)
	if(!length(records))
		to_chat(lobby, span_notice("You have no saved characters. Use Far Travel or sleep in a bed to save one."))
		return

	var/list/choices = list()
	for(var/list/record in records)
		choices["[record["name"]] - saved [record["saved_at"]], [record["bed"] ? "in bed at [record["bed"]["location"]]" : "at [record["location"]]"]"] = record["uid"]
	var/choice = tgui_input_list(lobby, "Which character do you want to play?", "Saved Characters", choices)
	if(!choice || QDELETED(lobby) || !lobby.client)
		return
	resume_character(lobby, choices[choice])

/datum/dreamvalley_campaign_manager/proc/resume_character(mob/dead/new_player/lobby, uid)
	var/list/record = character_records[uid]
	if(!islist(record) || record["owner_ckey"] != lobby.ckey)
		to_chat(lobby, span_warning("That character is no longer available."))
		return FALSE
	if(record["state"] != "stored")
		to_chat(lobby, span_warning("[record["name"]] is already in the world."))
		return FALSE
	var/mob_path = text2path(record["mob_type"])
	if(!ispath(mob_path, /mob/living/carbon/human))
		to_chat(lobby, span_warning("[record["name"]]'s save is damaged (unknown body type). Ask an admin for help."))
		return FALSE

	var/obj/structure/bed/rogue/bed = find_saved_bed(record)
	var/turf/spawn_turf = bed ? get_turf(bed) : find_saved_position(record)
	if(!spawn_turf)
		to_chat(lobby, span_warning("[record["name"]]'s saved location no longer exists. Ask an admin for help."))
		return FALSE

	var/mob/living/carbon/human/body = new mob_path(spawn_turf)
	var/datum/mind/body_mind = new /datum/mind()
	body.mind = body_mind
	body_mind.current = body
	body_mind.active = FALSE
	if(!restore_character_core(body, record["core"]))
		qdel(body)
		qdel(body_mind)
		to_chat(lobby, span_warning("[record["name"]] could not be rebuilt from the save. The save was kept; ask an admin for help."))
		log_world("DreamValley: failed to rebuild [uid] for [lobby.ckey].")
		return FALSE

	dreamvalley_restore_missing_appearance(body, lobby.client?.prefs, record)
	body.dreamvalley_character_uid = uid
	var/list/position = record["position"]
	if(islist(position) && isnum(position["dir"]))
		body.setDir(position["dir"])
	SSticker.minds |= body_mind
	lobby.spawning = TRUE
	body.key = lobby.key
	if(!body.client)
		lobby.spawning = FALSE
		qdel(body)
		qdel(body_mind)
		to_chat(lobby, span_warning("Could not move you into [record["name"]]. Please try again."))
		return FALSE

	record["state"] = "in_world"
	request_checkpoint_soon()
	qdel(lobby)

	if(bed)
		bed.buckle_mob(body, force = TRUE)
		body.set_resting(TRUE)
		body.SetSleeping(5 SECONDS)
		to_chat(body, span_notice("You wake up in your bed."))
	else
		to_chat(body, span_notice("You return to [record["location"]]."))
	log_game("[key_name(body)] resumed saved character [uid] ([record["name"]]).")
	return TRUE

/// The character's bed, if the save has one and a bed is still at that spot.
/datum/dreamvalley_campaign_manager/proc/find_saved_bed(list/record)
	var/list/bed_state = record["bed"]
	if(!islist(bed_state))
		return null
	var/turf/bed_turf = locate(bed_state["x"], bed_state["y"], bed_state["z"])
	if(!bed_turf)
		return null
	var/obj/structure/bed/rogue/bed = locate() in bed_turf
	if(!bed || bed.has_buckled_mobs())
		return null
	return bed

/datum/dreamvalley_campaign_manager/proc/find_saved_position(list/record)
	var/list/position = record["position"]
	if(!islist(position))
		return null
	return locate(position["x"], position["y"], position["z"])

// Lobby menu hook (tgui/packages/tgui/interfaces/NewPlayerPanel.tsx).
/mob/dead/new_player/ui_data(mob/user)
	var/list/data = ..()
	data["dv_saved_characters"] = GLOB.dreamvalley_campaign?.enabled ? length(GLOB.dreamvalley_campaign.get_resumable_characters(ckey)) : null
	return data

/mob/dead/new_player/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "dv_saved_characters")
		GLOB.dreamvalley_campaign?.prompt_resume_character(src)
		return TRUE

/// Saves written while appearance wasn't being restored lost the hair and
/// features. When that's the case, fill them back in from the character's
/// own preferences (only if the preference slot is that same character).
/datum/dreamvalley_campaign_manager/proc/dreamvalley_restore_missing_appearance(mob/living/carbon/human/body, datum/preferences/prefs, list/record)
	if(!prefs || prefs.real_name != record["name"])
		return
	if(!record["core"]?["taur"] && prefs.taur_type && !body.get_taur_tail())
		body.Taurize(prefs.taur_type, prefs.taur_color)
	// Saves from before the profile fields were saved: take them from preferences.
	if(!("vocal_bark_id" in record["core"]?["identity"]))
		body.flavortext_cached = prefs.flavortext_cached
		body.ooc_notes_cached = prefs.ooc_notes_cached
		body.nsfwflavortext_cached = prefs.nsfwflavortext_cached
		body.erpprefs_cached = prefs.erpprefs_cached
		body.rumour = prefs.rumour
		body.rumour_cached = prefs.rumour_cached
		body.noble_gossip = prefs.noble_gossip
		body.noble_gossip_cached = prefs.noble_gossip_cached
		body.img_gallery = prefs.img_gallery
		body.nsfw_img_gallery = prefs.nsfw_img_gallery
		body.ooc_extra = prefs.ooc_extra
		body.ooc_extra_img = prefs.ooc_extra_img
		body.nsfw_ooc_extra_img = prefs.nsfw_ooc_extra_img
		body.examine_theme = prefs.examine_theme
		body.song_title = prefs.song_title
		body.song_artist = prefs.song_artist
		body.set_bark(prefs.bark_id)
		body.vocal_speed = prefs.bark_speed
		body.vocal_pitch = prefs.bark_pitch
		body.vocal_pitch_range = prefs.bark_variance
		prefs.apply_descriptors(body)
	var/obj/item/bodypart/head/head = body.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		return
	for(var/datum/bodypart_feature/feature as anything in head.bodypart_features)
		if(feature.accessory_type)
			return
	prefs.apply_customizers_to_character(body)
	body.update_body()
	body.update_hair()
	body.update_body_parts(TRUE)
