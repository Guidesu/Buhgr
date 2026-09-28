/**
 * The "Campaign" panel: the single entry point for campaign saves.
 *
 * Everyone: when the world last saved, and their own saved characters
 * (where they are, their bed, delete).
 * Admins (R_ADMIN or R_DEBUG): world save slots (save, load next boot, load
 * now, delete), every player's saved characters, and campaign management.
 * Saving and shutting down additionally needs R_SERVER.
 */
/datum/dreamvalley_campaign_manager/var/datum/dreamvalley_save_status_ui/save_status_ui

/mob/verb/dreamvalley_campaign_panel()
	set category = "OOC"
	set name = "Campaign"
	set desc = "See when the world last saved, manage your saved characters, and (admins) manage world saves."

	if(!GLOB.dreamvalley_campaign)
		to_chat(src, span_warning("Campaign saving is not active on this server."))
		return
	if(!GLOB.dreamvalley_campaign.save_status_ui)
		GLOB.dreamvalley_campaign.save_status_ui = new(GLOB.dreamvalley_campaign)
	GLOB.dreamvalley_campaign.save_status_ui.ui_interact(src)

/datum/dreamvalley_save_status_ui
	var/datum/dreamvalley_campaign_manager/manager

/datum/dreamvalley_save_status_ui/New(datum/dreamvalley_campaign_manager/owner_manager)
	manager = owner_manager

/datum/dreamvalley_save_status_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/dreamvalley_save_status_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CampaignSaveStatus", "Campaign")
		ui.open()

/datum/dreamvalley_save_status_ui/proc/is_admin_viewer(mob/user)
	return user?.client && check_rights_for(user.client, R_ADMIN|R_DEBUG)

/datum/dreamvalley_save_status_ui/proc/can_shutdown(mob/user)
	return user?.client && check_rights_for(user.client, R_SERVER)

/datum/dreamvalley_save_status_ui/proc/admin_log(mob/user, text)
	log_admin("[key_name(user)] [text]")
	message_admins("[key_name_admin(user)] [text]")

/datum/dreamvalley_save_status_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(!manager || !user?.client)
		return TRUE
	var/is_admin = is_admin_viewer(user)

	// Actions on a single saved character: the owner or an admin.
	if(action in list("delete_character", "forget_bed"))
		var/uid = params["uid"]
		var/list/record = manager.character_records[uid]
		if(!islist(record) || (record["owner_ckey"] != user.ckey && !is_admin))
			return TRUE
		if(action == "forget_bed")
			if(manager.clear_character_bed(uid))
				to_chat(user, span_notice("[record["name"]] will no longer wake up in a bed."))
			return TRUE
		if(record["state"] == "in_world" && record["owner_ckey"] == user.ckey && !is_admin)
			to_chat(user, span_warning("You can't delete a character you are currently playing."))
			return TRUE
		if(tgui_alert(user, "Delete the save of [record["name"]]? This can't be undone.", "Delete Saved Character", list("Delete", "Keep")) != "Delete")
			return TRUE
		manager.delete_character_record(uid)
		if(record["owner_ckey"] != user.ckey)
			admin_log(user, "deleted [record["owner_ckey"]]'s saved character [record["name"]] ([uid]).")
		return TRUE

	if(action == "save_and_shutdown")
		if(can_shutdown(user))
			save_and_shutdown(user)
		return TRUE

	if(!is_admin)
		return TRUE

	switch(action)
		if("save_now")
			if(manager.saves_frozen)
				to_chat(user, span_warning(manager.frozen_reason))
				return TRUE
			var/count = manager.save_all_player_characters("in_world")
			if(manager.write_world_save(DREAMVALLEY_AUTOSAVE_SLOT))
				to_chat(user, span_notice("World saved to the autosave slot ([count] player character(s) included)."))
			else
				to_chat(user, span_warning("The save failed. Check the server log."))
			return TRUE

		if("save_to_slot")
			var/slot = params["slot"]
			if(!slot)
				slot = manager.sanitize_save_name(tgui_input_text(user, "Name for the new save (letters, digits, - and _):", "Save World", max_length = 64))
				if(!slot)
					return TRUE
			else if(tgui_alert(user, "Overwrite the save \"[slot]\" with the current world?", "Save World", list("Overwrite", "Cancel")) != "Overwrite")
				return TRUE
			if(slot == DREAMVALLEY_AUTOSAVE_SLOT)
				to_chat(user, span_warning("\"[slot]\" is reserved for autosaves. Pick another name."))
				return TRUE
			var/count = manager.save_all_player_characters("in_world")
			if(manager.write_world_save(slot))
				to_chat(user, span_notice("World saved as \"[slot]\" ([count] player character(s) included)."))
				admin_log(user, "saved the campaign world to slot \"[slot]\".")
			else
				to_chat(user, span_warning("The save failed. Check the server log."))
			return TRUE

		if("load_next_boot")
			var/slot = params["slot"]
			if(manager.set_boot_slot(slot))
				to_chat(user, span_notice("\"[slot]\" will load the next time the server starts."))
				admin_log(user, "set campaign save \"[slot]\" to load on the next boot.")
			else
				to_chat(user, span_warning("That save can't be loaded (missing or damaged)."))
			return TRUE

		if("load_now")
			var/slot = params["slot"]
			if(tgui_alert(user, "Load \"[slot]\" now? The server restarts, and everything since that save is lost unless it's saved in another slot.", "Load Save", list("Load and restart", "Cancel")) != "Load and restart")
				return TRUE
			if(!manager.set_boot_slot(slot))
				to_chat(user, span_warning("That save can't be loaded (missing or damaged)."))
				return TRUE
			manager.freeze_saves("Loading \"[slot]\". The server is restarting.")
			admin_log(user, "loaded campaign save \"[slot]\" and restarted the server.")
			to_chat(world, span_boldannounce("An admin is loading an earlier save of the world. The server is restarting."))
			world.Reboot("Campaign save loaded by [user.client.key]")
			return TRUE

		if("delete_slot")
			var/slot = params["slot"]
			if(tgui_alert(user, "Delete the save \"[slot]\"? This can't be undone.", "Delete Save", list("Delete", "Keep")) != "Delete")
				return TRUE
			if(manager.delete_slot(slot))
				admin_log(user, "deleted campaign save \"[slot]\".")
			else
				to_chat(user, span_warning("That save can't be deleted."))
			return TRUE

		if("switch_campaign")
			var/target_id = params["campaign_id"]
			if(tgui_alert(user, "Save this campaign and switch to \"[target_id]\"? The server restarts.", "Switch Campaign", list("Switch", "Cancel")) != "Switch")
				return TRUE
			var/old_id = manager.campaign_id
			if(!manager.switch_campaign(target_id))
				to_chat(user, span_warning("Couldn't switch. Check the server log."))
				return TRUE
			admin_log(user, "switched the campaign from \"[old_id]\" to \"[target_id]\".")
			to_chat(world, span_boldannounce("The campaign is switching to \"[target_id]\". The server is restarting."))
			world.Reboot("Campaign switched by [user.client.key]")
			return TRUE

		if("create_campaign")
			var/new_id = tgui_input_text(user, "Name for the new campaign (letters, digits, - and _):", "New Campaign", max_length = 64)
			if(!new_id)
				return TRUE
			var/result = manager.create_campaign(new_id)
			if(result)
				to_chat(user, span_notice("Created campaign \"[result]\". Switch to it to start playing it."))
				admin_log(user, "created campaign \"[result]\".")
			else
				to_chat(user, span_warning("That name is invalid or already used."))
			return TRUE

		if("delete_campaign")
			var/target_id = params["campaign_id"]
			if(tgui_alert(user, "Delete the campaign \"[target_id]\" and all its saves? This can't be undone.", "Delete Campaign", list("Delete", "Keep")) != "Delete")
				return TRUE
			if(manager.delete_campaign(target_id))
				admin_log(user, "deleted campaign \"[target_id]\".")
			else
				to_chat(user, span_warning("That campaign can't be deleted."))
			return TRUE

/datum/dreamvalley_save_status_ui/proc/save_and_shutdown(mob/user)
	if(manager.saves_frozen)
		to_chat(user, span_warning(manager.frozen_reason))
		return
	if(manager.save_and_shutdown_in_progress)
		return
	if(tgui_alert(user, "Save the world and every character, then shut the server down?", "Save and Shut Down", list("Save and shut down", "Cancel")) != "Save and shut down")
		return
	manager.save_and_shutdown_in_progress = TRUE
	var/count = manager.save_all_player_characters("stored")
	if(!manager.write_world_save(DREAMVALLEY_AUTOSAVE_SLOT))
		manager.save_and_shutdown_in_progress = FALSE
		to_chat(user, span_boldwarning("The save failed, so the server stays up. Check the server log."))
		return
	manager.freeze_saves("The server is shutting down.")
	to_chat(world, span_boldannounce("The world and [count] character(s) have been saved. The server is shutting down."))
	admin_log(user, "saved the campaign and shut the server down.")
	sleep(1 SECONDS)
	Master.Shutdown()
	world.Del()

/datum/dreamvalley_save_status_ui/ui_data(mob/user)
	var/list/data = list()
	var/is_admin = is_admin_viewer(user)
	data["is_admin"] = is_admin
	data["can_shutdown"] = can_shutdown(user)
	data["enabled"] = manager?.enabled || FALSE
	data["campaign_id"] = manager?.campaign_id
	data["frozen_reason"] = manager?.saves_frozen ? manager.frozen_reason : null
	data["last_saved"] = describe_time_since(manager?.last_save_at)
	data["loaded_slot"] = manager?.loaded_slot
	data["my_characters"] = build_character_rows(manager?.get_owned_characters(user.ckey))

	if(is_admin)
		data["boot_slot"] = manager.get_boot_slot()
		data["slots"] = manager.list_slots()
		var/list/everyone = list()
		for(var/uid in manager.character_records)
			everyone += list(manager.character_records[uid])
		data["all_characters"] = build_character_rows(sort_list(everyone, GLOBAL_PROC_REF(cmp_character_records_newest_first)))
		var/list/campaigns = manager.list_campaigns()
		var/list/campaign_rows = list()
		for(var/cid in campaigns)
			campaign_rows += list(list(
				"id" = cid,
				"last_saved" = campaigns[cid]["last_saved"],
				"active" = cid == manager.campaign_id,
			))
		data["campaigns"] = campaign_rows
	return data

/datum/dreamvalley_save_status_ui/proc/build_character_rows(list/records)
	var/list/rows = list()
	for(var/list/record in records)
		rows += list(list(
			"uid" = record["uid"],
			"owner" = record["owner_ckey"],
			"name" = record["name"],
			"in_world" = record["state"] == "in_world",
			"saved_at" = record["saved_at"],
			"location" = record["location"],
			"bed" = record["bed"]?["location"],
		))
	return rows

/datum/dreamvalley_save_status_ui/proc/describe_time_since(at_time)
	if(!isnum(at_time))
		return "not yet since the server started"
	var/minutes = round((world.realtime - at_time) / (1 MINUTES))
	if(minutes < 1)
		return "less than a minute ago"
	if(minutes == 1)
		return "1 minute ago"
	if(minutes < 60)
		return "[minutes] minutes ago"
	var/hours = round(minutes / 60)
	return hours == 1 ? "1 hour ago" : "[hours] hours ago"
