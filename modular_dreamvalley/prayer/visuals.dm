/// Height small prayer icons float at over a mob's head.
#define PRAYER_OVERHEAD_Y 22

// How an answered prayer looks and reads.
//
// Every request has a style: a colour, a few bursts (from our own prayer_fx
// sprites, or existing effects), a word that rises over the target, a beam
// from the supplicant, and for lasting effects an overlay that stays on the
// body as long as the effect does. The supplicant kneels in a turning rune
// circle of their domain's colour, and their god's answer is written over them.

#define PRAYER_FX 'icons/effects/prayer_fx.dmi'
#define PRAYER_FX_BIG 'icons/effects/prayer_fx_64.dmi'

/datum/domain
	/// The colour of this domain's light.
	var/colour = "#fff1b8"

/datum/domain/sun
	colour = "#ffd35a"
/datum/domain/law
	colour = "#e8e0c0"
/datum/domain/war
	colour = "#ff5a3c"
/datum/domain/hearth
	colour = "#ffa04a"
/datum/domain/harvest
	colour = "#b8d860"
/datum/domain/death
	colour = "#b0b8c8"
/datum/domain/sea
	colour = "#5ab4ff"
/datum/domain/moon
	colour = "#b8c0ff"
/datum/domain/love
	colour = "#ff8ab8"
/datum/domain/trickery
	colour = "#c080ff"
/datum/domain/trade
	colour = "#ffd070"
/datum/domain/craft
	colour = "#ff9b5a"
/datum/domain/knowledge
	colour = "#8ad0ff"
/datum/domain/healing
	colour = "#8cf08c"
/datum/domain/wilds
	colour = "#7fc85a"
/datum/domain/forbidden
	colour = "#9b3dd6"

/// intent = list(colour, list(bursts), rising word, beam state or null)
/// A burst is a prayer_fx state, "big:<state>" for the 64px sheet, or an effect type.
GLOBAL_LIST_INIT(prayer_intent_style, list(
	"heal" = list("#8cf08c", list("sparkle", "motes", /obj/effect/temp_visual/heal_rogue), "Healed", "medbeam"),
	"renew" = list("#b6f5a0", list("motes", "leaves"), "Renewal", "medbeam"),
	"cleanse" = list("#bff4ff", list("bubble_ring", "sparkle"), "Cleansed", "medbeam"),
	"shield" = list("#f5d76e", list("shield_dome", "holy_glyph"), "Warded", "sendbeam"),
	"smite" = list("#ffcf5a", list("big:sunburst", "embers", /obj/effect/temp_visual/scorch_flash), "Smitten", "solar_beam"),
	"banish" = list("#fff6c8", list("big:pillar", "holy_glyph", "skull_wisp"), "Banished", "necra_beam"),
	"calm" = list("#a9c9ff", list("mind_waves", "bubble_ring"), "Calmed", "sendbeam"),
	"forgive" = list("#e6e0ff", list("feathers", "halo"), "Absolved", "sendbeam"),
	"courage" = list("#ffb45a", list("sun_rays", "embers"), "Emboldened", "sendbeam"),
	"strengthen" = list("#ff9a5a", list("embers", "shockwave"), "Strengthened", "sendbeam"),
	"rage" = list("#ff3b30", list("flame_wisp", "blood_sigil", "shockwave"), "FURY!", "blood_beam"),
	"vigor" = list("#9cf5c8", list("motes", "shockwave"), "Vigour", "medbeam"),
	"quicken" = list("#9fe8ff", list("vortex", "feathers"), "Hastened", "sendbeam"),
	"weaken" = list("#8a7a9e", list("tendrils", "motes"), "Weakened", "drainbeam"),
	"curse" = list("#9b3dd6", list("big:dark_circle", "tendrils", /obj/effect/temp_visual/curse), "Cursed", "purple_lightning"),
	"bind" = list("#c8b27a", list("chains", "ghost_hands"), "Bound", "chain"),
	"sleep" = list("#7a88c8", list("zzz", "moon"), "Sleep...", "sendbeam"),
	"wake" = list("#fff1a8", list("sun_rays", "sparkle"), "Awake!", "sendbeam"),
	"feed" = list("#e8c07a", list("leaves", "motes"), "Fed", "sendbeam"),
	"quench" = list("#7ac8ff", list("drops", "bubble_ring"), "Refreshed", "sendbeam"),
	"warm" = list("#ffaa55", list("embers", "flame_wisp"), "Warmed", "sendbeam"),
	"cool" = list("#aef0ff", list("frost", "drops"), "Cooled", "sendbeam"),
	"light" = list("#fff4d0", list("big:sunburst", "sparkle"), "Light", null),
	"kindle" = list("#ff9933", list("flame_wisp", "embers"), "Kindled", null),
	"snuff" = list("#3a3350", list("tendrils", /obj/effect/temp_visual/small_smoke/halfsecond), "Darkness", null),
	"reveal" = list("#fff8e0", list("eye", "sun_rays"), "Revealed", "sendbeam"),
	"truth" = list("#fff8e0", list("eye", "holy_glyph"), "Weighed", "sendbeam"),
	"blind" = list("#2b2440", list("tendrils", "eye"), "Blinded", "drainbeam"),
	"silence" = list("#6b6b7a", list("chains", "mind_waves"), "Silenced", "chain"),
	"speak" = list("#dff5ff", list("mind_waves", "sparkle"), "Voice!", "sendbeam"),
	"bless" = list("#ffe680", list("halo", "sparkle", "feathers"), "Blessed", "sendbeam"),
	"raise" = list("#ffffff", list("big:pillar", "big:wings", "feathers"), "RETURNED", "necra_beam"),
	"veil" = list("#6e6aa8", list("moon", "tendrils"), "Veiled", null),
	"tongues" = list("#c8e6ff", list("pages", "mind_waves"), "Understanding", "sendbeam"),
	"frighten" = list("#5a1a2e", list("skull_wisp", "tendrils"), "TERROR", "drainbeam"),
	"madden" = list("#c040ff", list("vortex", "mind_waves", "eye"), "Madness", "tentacle"),
	"sicken" = list("#9acd32", list("rot_flies", "bubble_ring"), "Sickened", "drainbeam"),
	"rot" = list("#6b8e23", list("rot_flies", /obj/effect/temp_visual/rot_ring_tell), "Rotting", "drain_life"),
	"endure" = list("#d8c8a8", list("shield_dome", "frost"), "Weathered", "sendbeam"),
	"nighteyes" = list("#88ffcc", list("eye", "moon"), "Night Eyes", "sendbeam"),
	"disarm" = list("#e0e0e0", list("ghost_hands", "shockwave"), "Disarmed!", "chain"),
	"fell" = list("#d2b48c", list("crack", "shockwave"), "Felled!", "sendbeam"),
	"repel" = list("#e8f0ff", list("shockwave", "big:sunburst"), "Repelled!", "sendbeam"),
	"draw" = list("#e8f0ff", list("vortex", "chains"), "Drawn!", "chain"),
	"sober" = list("#dfffe0", list("bubble_ring", "drops"), "Sober", "medbeam"),
	"grow" = list("#7fdc5a", list("leaves", "thorns"), "Growth", "vine"),
	"tame" = list("#c8e6a0", list("hearts", "leaves"), "Tamed", "vine"),
	"repair" = list("#d8d8e8", list("sparkle", "embers"), "Mended", null),
	"seek" = list("#fff4d0", list("eye", "vortex"), "Seeking", null),
	"hallow" = list("#fff6c8", list("big:rune_circle", "big:pillar", "holy_glyph"), "Hallowed", null),
))

/// Overlays that stay on a body while a lasting effect runs: status id = list(state, colour, big?)
GLOBAL_LIST_INIT(prayer_lasting_overlays, list(
	"prayer_boon_ward" = list("shield_dome", "#f5d76e", FALSE),
	"prayer_boon_strength" = list("embers", "#ff9a5a", FALSE),
	"prayer_boon_speed" = list("feathers", "#9fe8ff", FALSE),
	"prayer_boon_fortune" = list("halo", "#ffe680", FALSE),
	"prayer_bane" = list("tendrils", "#8a7a9e", FALSE),
	"prayer_curse" = list("tendrils", "#9b3dd6", FALSE),
	"prayer_rage" = list("flame_wisp", "#ff3b30", FALSE),
	"prayer_courage" = list("sun_rays", "#ffb45a", FALSE),
	"prayer_dread" = list("skull_wisp", "#7a2a40", FALSE),
	"prayer_renewal" = list("motes", "#8cf08c", FALSE),
	"prayer_vigor" = list("motes", "#9cf5c8", FALSE),
	"prayer_madness" = list("mind_waves", "#c040ff", FALSE),
	"prayer_rot" = list("rot_flies", "#6b8e23", FALSE),
	"prayer_endure" = list("frost", "#d8c8a8", FALSE),
	"prayer_nighteyes" = list("moon", "#88ffcc", FALSE),
	"prayer_tongues" = list("pages", "#c8e6ff", FALSE),
))

// --- Pieces -----------------------------------------------------------------------

/obj/effect/temp_visual/prayer_fx
	icon = PRAYER_FX
	icon_state = "sparkle"
	duration = 1 SECONDS
	randomdir = FALSE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR | KEEP_APART

/obj/effect/temp_visual/prayer_fx/Initialize(mapload, state, colour, big = FALSE, new_duration)
	if(new_duration)
		duration = new_duration
	. = ..()
	if(big)
		icon = PRAYER_FX_BIG
		pixel_x = -16
		pixel_y = -16
		layer = BELOW_MOB_LAYER
	icon_state = state
	color = colour

/// The word that drifts up from a target's feet - kept low so it never covers speech.
/obj/effect/temp_visual/prayer_word
	name = ""
	icon = null
	duration = 1.6 SECONDS
	randomdir = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE_UPPER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_TRANSFORM

/obj/effect/temp_visual/prayer_word/Initialize(mapload, text, colour, size = 6, stagger = 0)
	. = ..()
	maptext_width = 128
	maptext_height = 24
	maptext_x = -48 + (stagger % 2 ? 14 : -14) * (stagger > 0)
	maptext_y = -6 + stagger * 7
	alpha = 0
	maptext = "<span style='font-family: \"Pterra\", serif; font-size: [size]px; text-align: center; color: [colour]; -dm-text-outline: 1px #120c06;'>[text]</span>"
	animate(src, alpha = 230, pixel_y = 4, time = duration * 0.3, easing = SINE_EASING | EASE_OUT)
	animate(pixel_y = 8, alpha = 0, time = duration * 0.7, easing = SINE_EASING | EASE_IN)

/proc/prayer_word(atom/where, text, colour, size = 6)
	var/turf/T = get_turf(where)
	if(!T)
		return
	var/stagger = 0
	for(var/obj/effect/temp_visual/prayer_word/other in T)
		stagger++
	new /obj/effect/temp_visual/prayer_word(T, text, colour, size, min(stagger, 3))

/proc/prayer_style(intent)
	return GLOB.prayer_intent_style[intent] || list("#ffffff", list("sparkle"), capitalize(intent), null)

/proc/prayer_burst(atom/where, burst, colour)
	var/turf/T = get_turf(where)
	if(!T)
		return
	if(ispath(burst))
		var/obj/effect/E = new burst(T)
		if(!QDELETED(E) && !ispath(burst, /obj/effect/temp_visual/thunderstrike_actual))
			E.color = colour
		return
	var/state = "[burst]"
	var/big = FALSE
	if(copytext(state, 1, 5) == "big:")
		state = copytext(state, 5)
		big = TRUE
	new /obj/effect/temp_visual/prayer_fx(T, state, colour, big)

/// An overlay on a mob for a while (chains while bound, Z's while asleep).
/proc/prayer_timed_overlay(mob/living/target, state, colour, duration, big = FALSE)
	var/mutable_appearance/MA = mutable_appearance(big ? PRAYER_FX_BIG : PRAYER_FX, state, ABOVE_MOB_LAYER)
	MA.color = colour
	MA.appearance_flags = RESET_COLOR | KEEP_APART
	MA.plane = ABOVE_LIGHTING_PLANE // drawn over the body, never behind it
	if(big)
		MA.pixel_x = -16
		MA.pixel_y = -16
	else
		MA.pixel_y = PRAYER_OVERHEAD_Y // above the head, not over the body
	target.add_overlay(MA)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/atom, cut_overlay), MA), duration)

/// Plays one answered request.
/proc/prayer_visual(mob/living/target, intent, power, mob/living/user)
	if(QDELETED(target))
		return
	var/list/style = prayer_style(intent)
	var/colour = style[1]
	var/list/bursts = style[2]
	// The show scales with the request: small mercies are quiet, great workings are not.
	var/tier = prayer_intent_cost(intent)
	var/grand = (tier >= 120) || power >= 1.8
	var/shown = 0
	for(var/burst in bursts)
		var/is_big = !ispath(burst) && copytext("[burst]", 1, 5) == "big:"
		if(is_big && !grand)
			continue
		if(!grand && tier < 90 && shown >= 1)
			break
		prayer_burst(target, burst, colour)
		shown++
	prayer_word(target, style[3], colour, grand ? 7 : 6)
	var/beam_state = style[4]
	if(beam_state && (tier >= 90 || grand) && user && user != target && get_dist(user, target) <= 8)
		user.Beam(target, icon_state = beam_state, time = 8, maxdistance = 9)
	// The target's outline swells with light and fades.
	var/filter_name = "prayer_answer"
	target.remove_filter(filter_name)
	target.add_filter(filter_name, 4, list("type" = "outline", "color" = colour, "size" = 1 + round(min(power, 2))))
	var/filter = target.get_filter(filter_name)
	if(filter)
		animate(filter, alpha = 0, size = 0, time = 2 SECONDS, easing = SINE_EASING)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/atom/movable, remove_filter), filter_name), 2 SECONDS)
	target.mob_light(_color = colour, _range = grand ? 3 : 1, _power = grand ? 1 : 0.6, _duration = (grand ? 1.5 : 0.8) SECONDS)
	// Only strong answers shake the air around them.
	if(power >= 1.5 && tier >= 90)
		prayer_burst(target, "shockwave", colour)
	if(power >= 2)
		prayer_burst(target, "big:wings", colour)
	// Some requests leave something on the body for their length.
	switch(intent)
		if("bind")
			prayer_timed_overlay(target, "chains", colour, (2 SECONDS) + (3 SECONDS) * power)
		if("sleep")
			if(target.IsSleeping())
				prayer_timed_overlay(target, "zzz", colour, (4 SECONDS) * power)
		if("silence")
			prayer_timed_overlay(target, "chains", colour, (6 SECONDS) * power)
		if("blind")
			prayer_timed_overlay(target, "tendrils", colour, (3 SECONDS) * power)

// --- The supplicant ------------------------------------------------------------------

/// The rune circle and rising motes while someone prays.
/obj/effect/prayer_kneel
	icon = PRAYER_FX_BIG
	icon_state = "rune_circle"
	pixel_x = -16
	pixel_y = -16
	layer = BELOW_MOB_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR | KEEP_APART

/proc/prayer_kneel_start(mob/living/user, colour, grand = FALSE)
	var/obj/effect/prayer_kneel/K
	var/mutable_appearance/motes
	if(grand)
		K = new(get_turf(user))
		K.color = colour
		K.alpha = 0
		animate(K, alpha = 220, time = 6)
		motes = mutable_appearance(PRAYER_FX, "motes", ABOVE_MOB_LAYER)
		motes.color = colour
		motes.appearance_flags = RESET_COLOR | KEEP_APART
		user.add_overlay(motes)
	user.add_filter("prayer_kneel", 3, list("type" = "outline", "color" = colour, "size" = 1, "alpha" = grand ? 110 : 60))
	var/filter = user.get_filter("prayer_kneel")
	if(filter)
		animate(filter, alpha = 30, time = 8, loop = -1, easing = SINE_EASING)
		animate(alpha = 150, time = 8, easing = SINE_EASING)
	return list(K, motes)

/proc/prayer_kneel_end(mob/living/user, list/kneel)
	if(!islist(kneel))
		return
	var/obj/effect/prayer_kneel/K = kneel[1]
	if(K && !QDELETED(K))
		animate(K, alpha = 0, time = 5)
		QDEL_IN(K, 5)
	if(user)
		if(kneel[2])
			user.cut_overlay(kneel[2])
		user.remove_filter("prayer_kneel")

/// The god's presence shown on the supplicant, without words over their head.
/proc/prayer_answer_presence(mob/living/user, colour, power, answered)
	if(!answered)
		prayer_burst(user, /obj/effect/temp_visual/small_smoke/halfsecond, "#6a645a")
		return
	if(power >= 1.8)
		prayer_burst(user, "big:wings", colour)
		prayer_burst(user, "big:sunburst", colour)
		user.mob_light(_color = colour, _range = 2, _power = 1, _duration = 1 SECONDS)
	else if(power >= 1.2)
		prayer_burst(user, "halo", colour)

/// How strong an answer was, in words.
/proc/prayer_strength_word(power)
	if(power < 0.6)
		return "<span style='color:#a89a86'>faint</span>"
	if(power < 1)
		return "<span style='color:#d8c9a8'>modest</span>"
	if(power < 1.5)
		return "<span style='color:#f0d88a'>strong</span>"
	if(power < 2)
		return "<span style='color:#ffcf5a'>mighty</span>"
	return "<span style='color:#fff6c8'><b>overwhelming</b></span>"

// --- Lasting glows and overlays on status effects -----------------------------------------------

/proc/prayer_status_aura_on(mob/living/owner, id)
	var/list/look = GLOB.prayer_lasting_overlays[id]
	if(!islist(look))
		return null
	owner.add_filter("prayer_aura_[id]", 2, list("type" = "outline", "color" = look[2], "size" = 1, "alpha" = 90))
	var/mutable_appearance/MA = mutable_appearance(look[3] ? PRAYER_FX_BIG : PRAYER_FX, look[1], ABOVE_MOB_LAYER)
	MA.color = look[2]
	MA.alpha = 170
	MA.appearance_flags = RESET_COLOR | KEEP_APART
	MA.plane = ABOVE_LIGHTING_PLANE
	if(look[3])
		MA.pixel_x = -16
		MA.pixel_y = -16
	else
		MA.pixel_y = PRAYER_OVERHEAD_Y
	owner.add_overlay(MA)
	return MA

/proc/prayer_status_aura_off(mob/living/owner, id, mutable_appearance/MA)
	owner.remove_filter("prayer_aura_[id]")
	if(MA)
		owner.cut_overlay(MA)

/datum/status_effect/buff/prayer_boon
	var/mutable_appearance/aura_overlay

/datum/status_effect/buff/prayer_boon/on_apply()
	. = ..()
	if(.)
		aura_overlay = prayer_status_aura_on(owner, id)

/datum/status_effect/buff/prayer_boon/on_remove()
	prayer_status_aura_off(owner, id, aura_overlay)
	aura_overlay = null
	return ..()

/datum/status_effect/prayer
	var/mutable_appearance/aura_overlay

/datum/status_effect/prayer/on_apply()
	. = ..()
	if(.)
		aura_overlay = prayer_status_aura_on(owner, id)

/datum/status_effect/prayer/on_remove()
	prayer_status_aura_off(owner, id, aura_overlay)
	aura_overlay = null
	return ..()

// Named status icons, each saying what it does.
/atom/movable/screen/alert/status_effect/prayer
	icon_state = "buff"

/atom/movable/screen/alert/status_effect/prayer/ward
	name = "Divine Ward"
	desc = "A god's hand rests on me: tougher and steadier than I should be."
/atom/movable/screen/alert/status_effect/prayer/strength
	name = "God-Given Strength"
	desc = "My arm is stronger than my own."
/atom/movable/screen/alert/status_effect/prayer/speed
	name = "Hastened"
	desc = "I move as if the wind were at my back."
/atom/movable/screen/alert/status_effect/prayer/fortune
	name = "Blessed"
	desc = "Fortune smiles on me. For now."
/atom/movable/screen/alert/status_effect/prayer/bane
	name = "Sapped"
	desc = "Someone's prayer drew the strength out of me."
	icon_state = "debuff"
/atom/movable/screen/alert/status_effect/prayer/curse
	name = "Cursed"
	desc = "Someone prayed against me, and was heard. My luck and will are failing."
	icon_state = "debuff"
/atom/movable/screen/alert/status_effect/prayer/rage
	name = "Holy Fury"
	desc = "Stronger, faster, feeling no pain - and not thinking clearly. It will leave me exhausted."
/atom/movable/screen/alert/status_effect/prayer/courage
	name = "Steady Heart"
	desc = "My nerve holds. My mind cannot be shaken."
/atom/movable/screen/alert/status_effect/prayer/dread
	name = "Dread"
	desc = "Terror has me by the throat. I am slow, shaking, and my mind is slipping."
	icon_state = "debuff"
/atom/movable/screen/alert/status_effect/prayer/renewal
	name = "Renewal"
	desc = "My wounds are knitting, a little at a time."
/atom/movable/screen/alert/status_effect/prayer/vigor
	name = "Vigour"
	desc = "Fresh strength keeps flowing into me."
/atom/movable/screen/alert/status_effect/prayer/veil
	name = "Veiled"
	desc = "I am hard to see."
/atom/movable/screen/alert/status_effect/prayer/madness
	name = "Madness"
	desc = "The world keeps sliding sideways."
	icon_state = "debuff"
/atom/movable/screen/alert/status_effect/prayer/rot
	name = "Rotting"
	desc = "Something is going bad inside me."
	icon_state = "debuff"
/atom/movable/screen/alert/status_effect/prayer/endure
	name = "Weathered"
	desc = "Heat and cold slide off me."
/atom/movable/screen/alert/status_effect/prayer/nighteyes
	name = "Night Eyes"
	desc = "The dark does not hide much from me."
/atom/movable/screen/alert/status_effect/prayer/tongues
	name = "Gift of Tongues"
	desc = "I understand every common tongue."

/datum/status_effect/buff/prayer_boon/ward
	alert_type = /atom/movable/screen/alert/status_effect/prayer/ward
/datum/status_effect/buff/prayer_boon/strength
	alert_type = /atom/movable/screen/alert/status_effect/prayer/strength
/datum/status_effect/buff/prayer_boon/speed
	alert_type = /atom/movable/screen/alert/status_effect/prayer/speed
/datum/status_effect/buff/prayer_boon/fortune
	alert_type = /atom/movable/screen/alert/status_effect/prayer/fortune
/datum/status_effect/buff/prayer_boon/bane
	alert_type = /atom/movable/screen/alert/status_effect/prayer/bane
/datum/status_effect/buff/prayer_boon/curse
	alert_type = /atom/movable/screen/alert/status_effect/prayer/curse
/datum/status_effect/buff/prayer_boon/rage
	alert_type = /atom/movable/screen/alert/status_effect/prayer/rage
/datum/status_effect/buff/prayer_boon/courage
	alert_type = /atom/movable/screen/alert/status_effect/prayer/courage
/datum/status_effect/buff/prayer_boon/dread
	alert_type = /atom/movable/screen/alert/status_effect/prayer/dread
/datum/status_effect/prayer/renewal
	alert_type = /atom/movable/screen/alert/status_effect/prayer/renewal
/datum/status_effect/prayer/vigor
	alert_type = /atom/movable/screen/alert/status_effect/prayer/vigor
/datum/status_effect/prayer/veil
	alert_type = /atom/movable/screen/alert/status_effect/prayer/veil
/datum/status_effect/prayer/madness
	alert_type = /atom/movable/screen/alert/status_effect/prayer/madness
/datum/status_effect/prayer/rot
	alert_type = /atom/movable/screen/alert/status_effect/prayer/rot
/datum/status_effect/prayer/endure
	alert_type = /atom/movable/screen/alert/status_effect/prayer/endure
/datum/status_effect/prayer/nighteyes
	alert_type = /atom/movable/screen/alert/status_effect/prayer/nighteyes
/datum/status_effect/prayer/tongues
	alert_type = /atom/movable/screen/alert/status_effect/prayer/tongues

#undef PRAYER_FX
#undef PRAYER_FX_BIG
