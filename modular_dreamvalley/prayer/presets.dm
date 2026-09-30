// Saved prayers. A character keeps up to ten prayers they know by heart. Pray's
// alt mode (the Toggle Spell Alt Mode key while Pray is selected) cycles between
// writing freely and saying one of them; any of them can also be kept as its own
// spell with its own icon. A saved prayer is still read by the god word by word,
// so it is only as good as it is written.

#define PRAYER_PRESET_MAX 10
#define PRAYER_PRESET_NAME_LEN 24

/datum/preferences
	/// list of list("name", "text", "standalone", "icon", "shape")
	var/list/prayer_presets = list()
	/// The same, for arcane incantations.
	var/list/incantation_presets = list()

/datum/preferences/proc/preset_store(kind)
	return kind == PRESET_KIND_INCANTATION ? incantation_presets : prayer_presets

/datum/preferences/proc/dreamvalley_load_prayer_presets(savefile/S)
	prayer_presets = load_preset_list(S, "prayer_presets")
	incantation_presets = load_preset_list(S, "incantation_presets")

/datum/preferences/proc/load_preset_list(savefile/S, key)
	. = list()
	var/raw
	S[key] >> raw
	var/list/decoded = istext(raw) ? json_decode(raw) : null
	if(!islist(decoded))
		return
	for(var/list/entry in decoded)
		if(length(.) >= PRAYER_PRESET_MAX)
			break
		var/preset_name = copytext(sanitize_text("[entry["name"]]"), 1, PRAYER_PRESET_NAME_LEN + 1)
		var/preset_text = copytext(sanitize_text("[entry["text"]]"), 1, 601)
		if(!preset_name)
			continue
		var/icon_key = "[entry["icon"]]"
		if(!(icon_key in prayer_preset_icons()))
			icon_key = "Thaumaturgy"
		var/shape = "[entry["shape"]]"
		if(!GLOB.prayer_shapes[shape])
			shape = PRAYER_SHAPE_TARGETED
		. += list(list("name" = preset_name, "text" = preset_text, "standalone" = !!entry["standalone"], "icon" = icon_key, "shape" = shape))

/datum/preferences/proc/dreamvalley_save_prayer_presets(savefile/S)
	WRITE_FILE(S["prayer_presets"], json_encode(prayer_presets))
	WRITE_FILE(S["incantation_presets"], json_encode(incantation_presets))

/// Button icons a saved prayer may wear: "Label" = list(icon, state).
/proc/prayer_preset_icons()
	var/static/list/choices
	if(choices)
		return choices
	choices = list()
	for(var/state in icon_states('icons/mob/actions/genericmiracles.dmi'))
		if(state in list("spell", "spell0", "spell1", "spellpack"))
			continue
		choices[capitalize(replacetext(state, "_", " "))] = list('icons/mob/actions/genericmiracles.dmi', state)
	for(var/state in icon_states('icons/effects/prayer_fx.dmi'))
		var/label = capitalize(replacetext(state, "_", " "))
		if(choices[label])
			label += " (glow)"
		choices[label] = list('icons/effects/prayer_fx.dmi', state)
	return choices

// --- Pray, with modes --------------------------------------------------------

/// A spell that writes words freely, or says one of the owner's saved ones.
/datum/action/cooldown/spell/prayer_base/scribe
	/// 0 writes new words; 1-10 says that saved entry.
	var/prayer_mode = 0

/datum/action/cooldown/spell/prayer_base/scribe/written_prayer
	desc = "Write a prayer to your god and ask for something. Name your god, say what you want and for whom, and mind your tone. \
		Your domain decides what your god is willing to do; your devotion, your state of mind, holy ground and what you offer decide how well.\
		<br>Toggle Spell Alt Mode while Pray is readied cycles through the prayers you know by heart (set them under Prayer Presets).\
		<br>Examples: <i>\"Merciful Pestrah, I beg you, mend the wounds of this one.\"</i> - <i>\"Sun-Faced Astratha, smite the unholy dead before me!\"</i> \
		- <i>\"Mother of the Sea, take my blood and calm the fear in all of us.\"</i>"

/// Saved prayers kept under Pray, i.e. not made into their own spells.
/datum/action/cooldown/spell/prayer_base/scribe/proc/get_presets()
	. = list()
	for(var/list/entry in owner?.client?.prefs?.preset_store(preset_kind))
		if(!entry["standalone"])
			. += list(entry)

/datum/action/cooldown/spell/prayer_base/scribe/toggle_alt_mode(mob/user)
	var/list/presets = get_presets()
	if(!length(presets))
		prayer_mode = 0
		to_chat(user, span_notice("I know no prayers by heart to say under Pray. (Prayer Presets, in the IC tab or the character menu, lets me learn some. Those made into their own spells have their own buttons.)"))
		update_mode_maptext()
		return TRUE
	prayer_mode = (prayer_mode + 1) % (length(presets) + 1)
	if(prayer_mode)
		var/list/entry = presets[prayer_mode]
		to_chat(user, span_notice("I ready the prayer I call <b>[entry["name"]]</b> ([prayer_shape_value(entry["shape"], "name")]): <i>\"[entry["text"]]\"</i>"))
	else
		to_chat(user, span_notice("I will find my own words."))
	update_mode_maptext()
	return TRUE

/datum/action/cooldown/spell/prayer_base/scribe/proc/update_mode_maptext()
	var/label
	var/list/presets = get_presets()
	if(prayer_mode > length(presets))
		prayer_mode = 0
	if(prayer_mode)
		var/list/entry = presets[prayer_mode]
		label = "[prayer_mode]:[copytext(entry["name"], 1, 8)]"
		configure_prayer(entry["text"], entry["shape"] || PRAYER_SHAPE_TARGETED)
	else
		configure_prayer(null, PRAYER_SHAPE_TARGETED)
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/button = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in button.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(button)
			button.vis_contents += holder
		holder.maptext = label ? MAPTEXT(label) : null
		holder.color = "#f3dd9a"

/datum/action/cooldown/spell/prayer_base/scribe/get_shape()
	var/list/presets = get_presets()
	if(prayer_mode && prayer_mode <= length(presets))
		var/list/entry = presets[prayer_mode]
		return entry["shape"] || PRAYER_SHAPE_TARGETED
	return PRAYER_SHAPE_TARGETED

/datum/action/cooldown/spell/prayer_base/scribe/get_prayer_text(mob/living/carbon/human/user, mob/living/chosen)
	var/list/presets = get_presets()
	if(prayer_mode && prayer_mode <= length(presets))
		var/list/entry = presets[prayer_mode]
		return entry["text"]
	var/datum/prayer_writer/W = new(user, chosen, "", PRAYER_SHAPE_TARGETED, "compose", preset_kind)
	. = W.wait_for_prayer()
	qdel(W)

/datum/action/cooldown/spell/prayer_base/scribe/Grant(mob/grant_to)
	. = ..()
	if(grant_to)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dreamvalley_sync_prayer_spells), grant_to), 1 SECONDS)

// --- A saved prayer as its own spell ----------------------------------------

/datum/action/cooldown/spell/prayer_base/preset
	desc = "A prayer I know by heart."
	var/prayer_text = ""

/// A bolt can be arced over heads and walls with the alt mode key.
/datum/action/cooldown/spell/prayer_base/preset/toggle_alt_mode(mob/user)
	if(prayer_shape != PRAYER_SHAPE_PROJECTILE)
		to_chat(user, span_notice("Only a prayer shaped as a bolt can be arced."))
		return TRUE
	prayer_arc = !prayer_arc
	to_chat(user, span_notice("[name]: I will [prayer_arc ? "loose the bolt in an arc, over heads and walls" : "cast the bolt straight"]."))
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/button = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in button.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(button)
			button.vis_contents += holder
		holder.maptext = prayer_arc ? MAPTEXT("ARC") : null
		holder.color = "#f3dd9a"
	return TRUE

/datum/action/cooldown/spell/prayer_base/preset/get_prayer_text(mob/living/carbon/human/user, mob/living/chosen)
	return prayer_text

/// Gives a character a spell for each saved prayer or incantation they keep
/// apart, and takes away the ones they no longer do.
/proc/dreamvalley_sync_prayer_spells(mob/living/carbon/human/H)
	if(!istype(H) || !H.mind)
		return
	// Editing must not reset a running cooldown.
	var/cooldown_end = 0
	for(var/datum/action/cooldown/spell/prayer_base/P in H.mind.spell_list)
		cooldown_end = max(cooldown_end, P.next_use_time)
	sync_preset_kind(H, PRESET_KIND_PRAYER, /datum/action/cooldown/spell/prayer_base/scribe/written_prayer, /datum/action/cooldown/spell/prayer_base/preset, cooldown_end)
	sync_preset_kind(H, PRESET_KIND_INCANTATION, /datum/action/cooldown/spell/prayer_base/scribe/incantation, /datum/action/cooldown/spell/prayer_base/preset/incantation, cooldown_end)

/proc/sync_preset_kind(mob/living/carbon/human/H, kind, scribe_type, preset_type, cooldown_end)
	var/can_use = FALSE
	for(var/datum/action/cooldown/spell/prayer_base/scribe/W in H.mind.spell_list)
		if(W.type == scribe_type)
			can_use = TRUE
			W.update_mode_maptext()
	var/datum/preferences/prefs = H.client?.prefs
	var/list/wanted = list()
	if(can_use && prefs)
		for(var/list/entry in prefs.preset_store(kind))
			if(entry["standalone"] && length(entry["text"]) >= PRAYER_MIN_LENGTH)
				wanted += list(entry)
	var/list/icons = prayer_preset_icons()
	var/list/existing = list()
	for(var/datum/action/cooldown/spell/prayer_base/preset/old in H.mind.spell_list)
		if(old.type == preset_type)
			existing += old
	// Reuse the buttons already there, in order; add or remove only the difference.
	for(var/i in 1 to max(length(wanted), length(existing)))
		var/datum/action/cooldown/spell/prayer_base/preset/S = i <= length(existing) ? existing[i] : null
		if(i > length(wanted))
			H.mind.RemoveSpell(S)
			continue
		var/list/entry = wanted[i]
		var/fresh = !S
		if(fresh)
			S = new preset_type
		S.name = entry["name"]
		S.prayer_text = entry["text"]
		S.prayer_shape = entry["shape"] || PRAYER_SHAPE_TARGETED
		S.configure_prayer(S.prayer_text, S.prayer_shape)
		S.desc = "[kind == PRESET_KIND_INCANTATION ? "An incantation" : "A prayer"] I know by heart: <i>\"[entry["text"]]\"</i><br>[prayer_shape_value(S.prayer_shape, "name")]: [prayer_shape_value(S.prayer_shape, "desc")]"
		var/list/look = icons[entry["icon"]]
		if(look)
			S.button_icon = look[1]
			S.button_icon_state = look[2]
			if(S.mob_charge_effect)
				S.mob_charge_effect.icon = look[1]
				S.mob_charge_effect.icon_state = look[2]
		if(fresh)
			H.mind.AddSpell(S, H)
		else
			S.build_all_button_icons()
		if(cooldown_end > world.time && S.next_use_time < cooldown_end)
			S.StartCooldown(cooldown_end - world.time)

// --- Learning prayers by heart ----------------------------------------------

/mob/living/carbon/human/verb/prayer_presets_verb()
	set name = "Prayer Presets"
	set category = "IC"
	if(client?.prefs)
		dreamvalley_edit_prayer_presets(src, client.prefs)

/mob/living/carbon/human/verb/incantation_presets_verb()
	set name = "Incantations"
	set category = "IC"
	if(client?.prefs)
		dreamvalley_edit_prayer_presets(src, client.prefs, PRESET_KIND_INCANTATION)

/// The editor, shared by the character menu and the game.
/proc/dreamvalley_edit_prayer_presets(mob/user, datum/preferences/prefs, kind = PRESET_KIND_PRAYER)
	var/datum/prayer_writer/W = new(user, null, "", PRAYER_SHAPE_TARGETED, "edit", kind)
	W.wait_for_prayer()
	qdel(W)

/proc/dreamvalley_prayer_presets_changed(mob/user, datum/preferences/prefs)
	prefs.save_character()
	if(ishuman(user))
		dreamvalley_sync_prayer_spells(user)
