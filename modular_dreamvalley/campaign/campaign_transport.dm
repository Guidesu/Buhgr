/**
 * World saves for the DreamValley campaign.
 *
 * Layout on disk:
 *   data/dreamvalley/active_campaign.txt             which campaign boots
 *   data/dreamvalley/campaigns/<campaign>/slots/<slot>.json
 *   data/dreamvalley/campaigns/<campaign>/boot_slot.txt   which slot loads next boot
 *
 * Every save slot is a complete world save (changed turfs, persistent
 * objects, saved characters, clock, rules). The game autosaves into the
 * "autosave" slot. Admins can also save into named slots and pick which slot
 * the next boot loads. After a slot is loaded, the boot slot goes back to
 * "autosave", since autosaves continue from the loaded state.
 */
#define DREAMVALLEY_SAVE_ROOT "data/dreamvalley"
#define DREAMVALLEY_CAMPAIGNS_ROOT "[DREAMVALLEY_SAVE_ROOT]/campaigns"
#define DREAMVALLEY_LEGACY_SAVE_FILE "[DREAMVALLEY_SAVE_ROOT]/save.json"
#define DREAMVALLEY_ACTIVE_CAMPAIGN_FILE "[DREAMVALLEY_SAVE_ROOT]/active_campaign.txt"

/datum/dreamvalley_campaign_manager
	/// Slot that was loaded at boot (shown in the panel). Autosaves always go to DREAMVALLEY_AUTOSAVE_SLOT.
	var/loaded_slot = DREAMVALLEY_AUTOSAVE_SLOT
	/// When set, no more saves are written until reboot, so a slot staged for
	/// the next boot (campaign switch, "load now") isn't overwritten by the
	/// shutdown save of the world that's being discarded.
	var/saves_frozen = FALSE
	var/frozen_reason
	/// Cheap callers set this; the subsystem autosaves on its next tick.
	var/save_requested = FALSE
	/// world.realtime of the last successful save this session.
	var/last_save_at

/datum/dreamvalley_campaign_manager/proc/campaign_dir_path(for_campaign_id = campaign_id)
	return "[DREAMVALLEY_CAMPAIGNS_ROOT]/[for_campaign_id]"

/datum/dreamvalley_campaign_manager/proc/slot_file_path(slot)
	return "[campaign_dir_path()]/slots/[slot].json"

/datum/dreamvalley_campaign_manager/proc/boot_slot_file_path()
	return "[campaign_dir_path()]/boot_slot.txt"

SUBSYSTEM_DEF(dreamvalley)
	name = "DreamValley Campaign"
	init_order = INIT_ORDER_PERSISTENCE - 1
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	/// Autosave every this many fires (1 fire = 1 second).
	var/autosave_every_fires = 300
	/// After a turf changes, autosave within this many fires.
	var/changed_turf_delay_fires = 30
	var/fires_since_save = 0

/datum/controller/subsystem/dreamvalley/Initialize()
	var/datum/dreamvalley_campaign_manager/manager = GLOB.dreamvalley_campaign
	var/active_id = manager.read_active_campaign_id()
	if(active_id)
		manager.configure(active_id)
	manager.load_boot_slot()
	// Render the TAT shop icons now, in the background, so the first player to
	// open the TAT window doesn't wait for hundreds of icons to encode.
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(warm_tat_item_catalog))
	return ..()

/datum/controller/subsystem/dreamvalley/fire(resumed = FALSE)
	var/datum/dreamvalley_campaign_manager/manager = GLOB.dreamvalley_campaign
	if(!manager.enabled)
		return
	fires_since_save++
	var/full_autosave_due = fires_since_save >= autosave_every_fires
	var/turfs_due = length(manager.dirty_turfs) && fires_since_save >= changed_turf_delay_fires
	if(!manager.save_requested && !turfs_due && !full_autosave_due)
		return
	manager.save_requested = FALSE
	// Re-capturing every player is the expensive part, so only the periodic
	// autosave does it; saves triggered by map edits or beds skip it.
	if(full_autosave_due)
		fires_since_save = 0
		manager.save_all_player_characters("in_world")
	manager.write_world_save(DREAMVALLEY_AUTOSAVE_SLOT)

/datum/controller/subsystem/dreamvalley/Shutdown()
	var/datum/dreamvalley_campaign_manager/manager = GLOB.dreamvalley_campaign
	if(manager.enabled && !manager.saves_frozen)
		manager.save_all_player_characters("stored")
		manager.write_world_save(DREAMVALLEY_AUTOSAVE_SLOT)

// --- Active campaign -------------------------------------------------------

/datum/dreamvalley_campaign_manager/proc/read_active_campaign_id()
	if(!fexists(DREAMVALLEY_ACTIVE_CAMPAIGN_FILE))
		return null
	return sanitize_save_name(rustg_file_read(DREAMVALLEY_ACTIVE_CAMPAIGN_FILE))

/datum/dreamvalley_campaign_manager/proc/write_text_file(text, path)
	var/result = rustg_file_write(text, path)
	return isnull(result) || result == "" || result == "true"

/// Letters, digits, underscore and hyphen, at most 64 characters. Null if nothing is left.
/datum/dreamvalley_campaign_manager/proc/sanitize_save_name(raw_name)
	if(!istext(raw_name))
		return null
	var/static/regex/bad_chars = regex(@"[^A-Za-z0-9_\-]", "g")
	var/cleaned = copytext(bad_chars.Replace(trim(raw_name), "_"), 1, 65)
	return length(cleaned) ? cleaned : null

// --- Loading ---------------------------------------------------------------

/// Loads whichever slot is set to load at boot (autosave by default).
/datum/dreamvalley_campaign_manager/proc/load_boot_slot()
	var/slot = DREAMVALLEY_AUTOSAVE_SLOT
	if(fexists(boot_slot_file_path()))
		slot = sanitize_save_name(rustg_file_read(boot_slot_file_path())) || DREAMVALLEY_AUTOSAVE_SLOT
	migrate_old_save_files()

	var/list/save_data = read_slot(slot)
	if(!save_data && slot != DREAMVALLEY_AUTOSAVE_SLOT)
		log_world("DreamValley: boot slot '[slot]' of campaign '[campaign_id]' is missing or unreadable; loading the autosave instead.")
		slot = DREAMVALLEY_AUTOSAVE_SLOT
		save_data = read_slot(slot)
	// Autosaves from here on continue this state, so the next boot should load them.
	if(fexists(boot_slot_file_path()))
		fdel(boot_slot_file_path())
	loaded_slot = slot
	if(!save_data)
		return FALSE

	var/saved_generation = save_data["checkpoint_generation"]
	if(isnum(saved_generation))
		checkpoint_generation = max(0, saved_generation)
	var/list/snapshot = save_data["snapshot"]
	if(islist(snapshot))
		load_snapshot(snapshot)
	log_world("DreamValley: loaded save slot '[slot]' of campaign '[campaign_id]' (save #[checkpoint_generation]).")
	return TRUE

/// Decoded save data of a slot, or null if it's missing or unreadable.
/datum/dreamvalley_campaign_manager/proc/read_slot(slot)
	var/path = slot_file_path(slot)
	if(!fexists(path))
		return null
	var/list/save_data
	try
		save_data = json_decode(rustg_file_read(path))
	catch
		log_world("DreamValley: save slot '[slot]' of campaign '[campaign_id]' is not valid JSON.")
		return null
	if(!islist(save_data) || save_data["schema_version"] != 1)
		return null
	return save_data

/// Older builds kept a single save.json (per campaign, or one global file for
/// "default"). Move it into the autosave slot once.
/datum/dreamvalley_campaign_manager/proc/migrate_old_save_files()
	var/autosave_path = slot_file_path(DREAMVALLEY_AUTOSAVE_SLOT)
	if(fexists(autosave_path))
		return
	var/old_path = "[campaign_dir_path()]/save.json"
	if(!fexists(old_path) && campaign_id == "default" && fexists(DREAMVALLEY_LEGACY_SAVE_FILE))
		old_path = DREAMVALLEY_LEGACY_SAVE_FILE
	if(!fexists(old_path))
		return
	var/raw = rustg_file_read(old_path)
	if(istext(raw) && length(raw) && write_text_file(raw, autosave_path))
		log_world("DreamValley: moved old save file [old_path] into the autosave slot.")

// --- Saving ----------------------------------------------------------------

/// Writes the current world into a slot. Returns TRUE on success.
/datum/dreamvalley_campaign_manager/proc/write_world_save(slot)
	if(!enabled || saves_frozen || !sanitize_save_name(slot))
		return FALSE
	drain_turf_deltas()
	checkpoint_generation++
	var/list/save_data = list(
		"schema_version" = 1,
		"campaign_id" = campaign_id,
		"slot" = slot,
		"checkpoint_generation" = checkpoint_generation,
		"saved_at" = time2text(world.realtime, "YYYY-MM-DD hh:mm"),
		"in_game_day" = GLOB.dayspassed,
		"snapshot" = capture_snapshot(),
	)
	if(!write_text_file(json_encode(save_data), slot_file_path(slot)))
		log_world("DreamValley: failed to write save slot '[slot]' of campaign '[campaign_id]'.")
		return FALSE
	last_save_at = world.realtime
	return TRUE

/// Asks the subsystem to autosave on its next tick instead of writing now.
/datum/dreamvalley_campaign_manager/proc/request_checkpoint_soon()
	save_requested = TRUE

/datum/dreamvalley_campaign_manager/proc/freeze_saves(reason)
	saves_frozen = TRUE
	frozen_reason = reason

// --- Slots -----------------------------------------------------------------

/// All slots of the active campaign: list of list(name, saved_at, in_game_day, characters, generation).
/datum/dreamvalley_campaign_manager/proc/list_slots()
	var/list/result = list()
	for(var/entry in flist("[campaign_dir_path()]/slots/"))
		if(copytext(entry, -5) != ".json")
			continue
		var/slot = copytext(entry, 1, -5)
		var/list/save_data = read_slot(slot)
		result += list(list(
			"name" = slot,
			"readable" = !!save_data,
			"saved_at" = save_data?["saved_at"],
			"in_game_day" = save_data?["in_game_day"],
			"generation" = save_data?["checkpoint_generation"],
			"characters" = length(save_data?["snapshot"]?["characters"]),
		))
	return result

/// Makes a slot load on the next boot. Returns TRUE if the slot exists.
/datum/dreamvalley_campaign_manager/proc/set_boot_slot(slot)
	slot = sanitize_save_name(slot)
	if(!slot || !read_slot(slot))
		return FALSE
	if(slot == DREAMVALLEY_AUTOSAVE_SLOT)
		if(fexists(boot_slot_file_path()))
			fdel(boot_slot_file_path())
		return TRUE
	return write_text_file(slot, boot_slot_file_path())

/datum/dreamvalley_campaign_manager/proc/get_boot_slot()
	if(!fexists(boot_slot_file_path()))
		return DREAMVALLEY_AUTOSAVE_SLOT
	return sanitize_save_name(rustg_file_read(boot_slot_file_path())) || DREAMVALLEY_AUTOSAVE_SLOT

/datum/dreamvalley_campaign_manager/proc/delete_slot(slot)
	if(slot == DREAMVALLEY_AUTOSAVE_SLOT || slot != sanitize_save_name(slot))
		return FALSE
	var/path = slot_file_path(slot)
	if(!fexists(path))
		return FALSE
	if(get_boot_slot() == slot)
		fdel(boot_slot_file_path())
	return fdel(path)

// --- Campaigns -------------------------------------------------------------

/// Every campaign directory, including ones never saved. campaign_id -> list(last_saved)
/datum/dreamvalley_campaign_manager/proc/list_campaigns()
	var/list/result = list()
	for(var/entry in flist("[DREAMVALLEY_CAMPAIGNS_ROOT]/"))
		if(copytext(entry, -1) != "/")
			continue
		var/dir_name = copytext(entry, 1, -1)
		if(!length(dir_name))
			continue
		var/last_saved
		var/autosave_path = "[campaign_dir_path(dir_name)]/slots/[DREAMVALLEY_AUTOSAVE_SLOT].json"
		if(fexists(autosave_path))
			var/list/save_data
			try
				save_data = json_decode(rustg_file_read(autosave_path))
			catch
				save_data = null
			last_saved = save_data?["saved_at"]
		result[dir_name] = list("last_saved" = last_saved)
	if(!result[campaign_id])
		result[campaign_id] = list("last_saved" = null)
	return result

/// Saves this campaign and makes new_campaign_id boot next. The caller reboots.
/datum/dreamvalley_campaign_manager/proc/switch_campaign(new_campaign_id)
	new_campaign_id = sanitize_save_name(new_campaign_id)
	if(!new_campaign_id || new_campaign_id == campaign_id || !list_campaigns()[new_campaign_id] || saves_frozen)
		return FALSE
	save_all_player_characters("stored")
	if(!write_world_save(DREAMVALLEY_AUTOSAVE_SLOT))
		return FALSE
	if(!write_text_file(new_campaign_id, DREAMVALLEY_ACTIVE_CAMPAIGN_FILE))
		return FALSE
	freeze_saves("Switching to campaign \"[new_campaign_id]\". The server is restarting.")
	return TRUE

/// Creates an empty campaign. Returns its sanitized ID, or null if invalid or taken.
/datum/dreamvalley_campaign_manager/proc/create_campaign(new_campaign_id)
	var/safe_id = sanitize_save_name(new_campaign_id)
	if(!safe_id || list_campaigns()[safe_id])
		return null
	write_text_file("", "[campaign_dir_path(safe_id)]/slots/.keep")
	return safe_id

/// Deletes a campaign and all its saves. The active campaign can't be deleted.
/datum/dreamvalley_campaign_manager/proc/delete_campaign(campaign_id_to_delete)
	if(campaign_id_to_delete != sanitize_save_name(campaign_id_to_delete) || campaign_id_to_delete == campaign_id)
		return FALSE
	var/campaign_dir = "[campaign_dir_path(campaign_id_to_delete)]/"
	if(!fexists(campaign_dir))
		return FALSE
	return fdel(campaign_dir)

#undef DREAMVALLEY_SAVE_ROOT
#undef DREAMVALLEY_CAMPAIGNS_ROOT
#undef DREAMVALLEY_LEGACY_SAVE_FILE
#undef DREAMVALLEY_ACTIVE_CAMPAIGN_FILE
