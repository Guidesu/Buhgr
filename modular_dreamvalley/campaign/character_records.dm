/**
 * Saved characters.
 *
 * Every player character that has been saved has one record, identified by a
 * uid ("ckey:number") that also lives on the body as dreamvalley_character_uid,
 * so later saves of the same body update the same record.
 *
 * A record is in one of two states:
 * - "stored":   the character is not in the world. Its owner can resume it
 *               from the lobby.
 * - "in_world": the character is being played right now; the record is only a
 *               backup. It can't be resumed (that would duplicate the body).
 *               On boot every "in_world" record becomes "stored", because no
 *               bodies survive a restart.
 *
 * Saving never refuses: whatever the capture engine (character_graph.dm)
 * can't represent is skipped and logged, and the rest is kept.
 */
/datum/dreamvalley_campaign_manager
	/// uid -> record. Saved inside every world save slot.
	var/list/character_records = list()
	/// Counter for new character uids. Saved with the world.
	var/next_character_number = 1

/mob/living/carbon/human
	/// DreamValley saved-character uid for this body, or null if never saved.
	var/dreamvalley_character_uid

/// The ckey that owns a body, whether or not the player is connected.
/datum/dreamvalley_campaign_manager/proc/character_owner_ckey(mob/living/carbon/human/character)
	if(character.ckey)
		return character.ckey
	if(character.mind?.key)
		return ckey(character.mind.key)
	return null

/**
 * Saves a body into its record and returns the record (or null if the body
 * has no owning player). new_state is "stored" or "in_world".
 */
/datum/dreamvalley_campaign_manager/proc/save_character(mob/living/carbon/human/character, new_state)
	if(!istype(character) || QDELETED(character))
		return null
	var/owner = character_owner_ckey(character)
	if(!owner)
		return null

	var/uid = character.dreamvalley_character_uid
	// A fresh body of a character this player already saved updates that save
	// instead of starting a second copy of them.
	if(!uid)
		uid = find_record_by_name(owner, character.real_name)
	var/list/previous = uid ? character_records[uid] : null
	// A uid that belongs to someone else (body handed over by an admin) starts a new record.
	if(!islist(previous) || previous["owner_ckey"] != owner)
		uid = "[owner]:[next_character_number++]"
		previous = null
		character.dreamvalley_character_uid = uid

	var/list/core = capture_character_core(character)
	var/list/skipped = core?["validation_issues"]
	if(length(skipped))
		log_world("DreamValley: saved [key_name(character)] as [uid]; skipped [length(skipped)] unsupported detail(s): [skipped.Join(", ")]")

	var/turf/here = get_turf(character)
	var/area/here_area = get_area(character)
	var/list/record = list(
		"schema_version" = 2,
		"uid" = uid,
		"owner_ckey" = owner,
		"name" = character.real_name,
		"state" = new_state,
		"saved_at" = time2text(world.realtime, "YYYY-MM-DD hh:mm"),
		"saved_day" = GLOB.dayspassed,
		"location" = here_area ? here_area.name : "unknown",
		"position" = here ? list("x" = here.x, "y" = here.y, "z" = here.z, "dir" = character.dir) : previous?["position"],
		"bed" = previous?["bed"],
		"mob_type" = "[character.type]",
		"skipped_count" = length(skipped),
		"core" = core,
	)
	character_records[uid] = record
	return record

/// The newest record of a character with this name, or null.
/datum/dreamvalley_campaign_manager/proc/find_record_by_name(owner, char_name)
	var/list/best
	for(var/uid in character_records)
		var/list/record = character_records[uid]
		if(!islist(record) || record["owner_ckey"] != owner || record["name"] != char_name)
			continue
		if(!best || sorttext(best["saved_at"] || "", record["saved_at"] || "") > 0)
			best = record
	return best?["uid"]

/// Characters a player can resume right now, newest first. Older saves of the
/// same character are hidden; only the latest can be resumed.
/datum/dreamvalley_campaign_manager/proc/get_resumable_characters(player_ckey)
	var/list/newest = list()
	for(var/uid in character_records)
		var/list/record = character_records[uid]
		if(!islist(record) || record["owner_ckey"] != player_ckey)
			continue
		var/list/current = newest[record["name"]]
		if(!current || sorttext(current["saved_at"] || "", record["saved_at"] || "") > 0)
			newest[record["name"]] = record
	var/list/result = list()
	for(var/char_name in newest)
		var/list/record = newest[char_name]
		if(record["state"] == "stored")
			result += list(record)
	return sort_list(result, GLOBAL_PROC_REF(cmp_character_records_newest_first))

/// Every record a player owns (stored and in the world), newest first.
/datum/dreamvalley_campaign_manager/proc/get_owned_characters(player_ckey)
	var/list/result = list()
	for(var/uid in character_records)
		var/list/record = character_records[uid]
		if(islist(record) && record["owner_ckey"] == player_ckey)
			result += list(record)
	return sort_list(result, GLOBAL_PROC_REF(cmp_character_records_newest_first))

/proc/cmp_character_records_newest_first(list/a, list/b)
	return sorttext(a["saved_at"] || "", b["saved_at"] || "")

/// Records as written into a world save.
/datum/dreamvalley_campaign_manager/proc/copy_character_records()
	var/list/result = list()
	for(var/uid in character_records)
		var/list/record = character_records[uid]
		if(islist(record))
			result[uid] = record.Copy()
	return result

/// Loads records from a world save. Every body is gone after a restart, so
/// every record becomes resumable. Old-format (schema 1) records are converted.
/datum/dreamvalley_campaign_manager/proc/load_character_records(list/records)
	character_records = list()
	if(!islist(records))
		return
	for(var/key in records)
		var/list/record = records[key]
		if(!islist(record) || !islist(record["core"]))
			continue
		record = record.Copy()
		if(record["schema_version"] != 2)
			record = convert_legacy_character_record(key, record)
			if(!record)
				continue
		record["state"] = "stored"
		character_records[record["uid"]] = record

/// Schema 1 records were keyed "ckey/preference-slot" and used "parked" states.
/datum/dreamvalley_campaign_manager/proc/convert_legacy_character_record(old_key, list/record)
	var/owner = record["owner_ckey"]
	if(!istext(owner) || !length(owner))
		return null
	var/list/identity = record["core"]["identity"]
	record["schema_version"] = 2
	record["uid"] = "[owner]:[next_character_number++]"
	record["name"] = identity?["real_name"] || "Unnamed"
	record["saved_at"] = "before the save update"
	record["location"] = "unknown"
	record["skipped_count"] = 0
	return record

/datum/dreamvalley_campaign_manager/proc/delete_character_record(uid)
	if(!character_records[uid])
		return FALSE
	character_records -= uid
	request_checkpoint_soon()
	return TRUE

/**
 * Saves every player body in the world. At shutdown bodies are about to
 * vanish, so they are saved as "stored"; otherwise as "in_world" backups.
 * Returns how many were saved.
 */
/datum/dreamvalley_campaign_manager/proc/save_all_player_characters(new_state)
	var/saved = 0
	for(var/mob/living/carbon/human/H as anything in GLOB.human_list)
		if(QDELETED(H) || H.stat == DEAD || !character_owner_ckey(H))
			continue
		if(istype(H, /mob/living/carbon/human/dummy))
			continue
		if(save_character(H, new_state))
			saved++
	return saved
