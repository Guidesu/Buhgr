// Strain. Magic is not free on Palimpseste: every arcane working pulls on the
// caster, and the pull builds faster than it fades. A little Strain is nothing;
// a lot bleeds you, burns you, and at the edge the magic turns on you.
// Places of power - ley stones, arcyne circles, mage towers - make it easier.

#define SPELL_CHECK_LOST 0
#define SPELL_CHECK_NORMAL 1
#define SPELL_CHECK_MASTERY 2

#define STRAIN_MAX 100
#define STRAIN_STRAINED 30
#define STRAIN_OVERDRAWN 60
#define STRAIN_BRINK 85

/mob/living
	/// Arcane Strain, 0-100.
	var/arcane_strain = 0

/// Only arcane workings strain; miracles and prayer do not.
/proc/is_arcane_spell(datum/action/cooldown/spell/S)
	return istype(S) && ispath(S.associated_skill, /datum/skill/magic/arcane)

/// How much a place eases magic: 1 = ordinary, lower is easier.
/mob/living/proc/strain_place_factor()
	var/turf/T = get_turf(src)
	if(!T)
		return 1
	var/area/A = get_area(T)
	if(istype(A, /area/rogue/indoors/town/magician) || istype(A, /area/rogue/outdoors/exposed/magiciantower) || istype(A, /area/wizard_station))
		return 0.5
	for(var/obj/structure/leystone/stone in range(3, T))
		return 0.4
	for(var/obj/effect/decal/cleanable/roguerune/arcyne/rune in range(1, T))
		return 0.6
	return 1

/mob/living/proc/in_place_of_power()
	return strain_place_factor() < 1

/// What a cast adds to the caster's Strain.
/datum/action/cooldown/spell/proc/strain_for_cast(mob/living/caster)
	var/base = 3 + max(1, spell_tier) * 3
	base += min(10, (primary_resource_cost + secondary_resource_cost) / 25)
	// A trained mind holds more before it tears.
	var/intellect = caster.get_stat(STAT_INTELLIGENCE)
	base *= clamp(1 - (intellect - 10) * 0.03, 0.6, 1.3)
	return base * caster.strain_place_factor()

/mob/living/proc/add_arcane_strain(amount)
	if(amount <= 0)
		return
	arcane_strain = clamp(arcane_strain + amount, 0, STRAIN_MAX)
	apply_status_effect(/datum/status_effect/arcane_strain)
	var/datum/status_effect/arcane_strain/S = has_status_effect(/datum/status_effect/arcane_strain)
	S?.update_alert()

/// Called right before an arcane spell goes off. Returns TRUE if the spell is lost.
/// At the very edge the magic breaks out; otherwise the spell check decides (dcc.dm).
/mob/living/proc/strain_before_arcane_cast(datum/action/cooldown/spell/S)
	if(arcane_strain >= STRAIN_MAX)
		strain_surge()
		return TRUE
	return !spell_check(S)

/// Called after an arcane spell is cast: the body pays, and Strain builds.
/mob/living/proc/strain_after_arcane_cast(datum/action/cooldown/spell/S)
	if(arcane_strain >= STRAIN_OVERDRAWN && iscarbon(src))
		var/mob/living/carbon/C = src
		C.blood_volume = max(BLOOD_VOLUME_SURVIVE, C.blood_volume - max(1, S.spell_tier) * 6)
		if(prob(40))
			balloon_alert(src, "costs blood")
	var/gained = S.strain_for_cast(src) * mercurial_strain_mult(S)
	if(last_spell_check_result == SPELL_CHECK_MASTERY)
		gained = 0
	add_arcane_strain(gained)
	mercurial_flavour(S)

/// A working goes wrong and burns its caster.
/mob/living/proc/strain_backlash(datum/action/cooldown/spell/S)
	visible_message(span_danger("The magic around [src] snaps back on [p_them()]!"), span_userdanger("The working tears loose and lashes back into me!"))
	playsound(src, 'sound/magic/magic_nulled.ogg', 70, TRUE)
	apply_damage(10 + max(1, S?.spell_tier) * 3, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
	Immobilize(1 SECONDS)
	new /obj/effect/temp_visual/strain_crackle(get_turf(src))
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.onPsyDamage(5)

/// At the very edge, the gathered magic breaks all at once.
/mob/living/proc/strain_surge()
	visible_message(span_danger("Light and noise burst out of [src] as the magic in [p_them()] breaks all at once!"), span_userdanger("Too much. It all comes out of me at once!"))
	playsound(src, 'sound/magic/lightning.ogg', 80, TRUE)
	apply_damage(25, BURN)
	Knockdown(3 SECONDS)
	for(var/turf/T in range(1, src))
		new /obj/effect/temp_visual/strain_crackle(T)
	for(var/mob/living/L in range(1, src))
		if(L != src)
			L.apply_damage(8, BURN)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.onPsyDamage(15)
	arcane_strain = 50
	var/datum/status_effect/arcane_strain/S = has_status_effect(/datum/status_effect/arcane_strain)
	S?.update_alert()

/proc/strain_word(strain)
	if(strain >= STRAIN_BRINK)
		return "on the brink"
	if(strain >= STRAIN_OVERDRAWN)
		return "overdrawn"
	if(strain >= STRAIN_STRAINED)
		return "strained"
	return "steady"

// --- The status effect that carries it ----------------------------------------

/datum/status_effect/arcane_strain
	id = "arcane_strain"
	duration = -1
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/arcane_strain
	var/next_symptom = 0

/datum/status_effect/arcane_strain/proc/update_alert()
	var/atom/movable/screen/alert/status_effect/arcane_strain/A = linked_alert
	if(!istype(A))
		return
	var/strain = round(owner.arcane_strain)
	A.name = "Strain: [strain_word(strain)] ([strain])"
	A.desc = "Arcane Strain [strain]/[STRAIN_MAX] ([strain_word(strain)]). -[round(strain / 20)] to spell checks. It fades with time - faster asleep or in a place of power.\n30+ aches, 60+ spells cost blood, 85+ burns, 100 the magic breaks out."
	A.icon_state = strain >= STRAIN_OVERDRAWN ? "debuff" : "buff"
	// The number on the icon, so it reads at a glance.
	var/colour = strain >= STRAIN_BRINK ? "#ff5a4a" : (strain >= STRAIN_OVERDRAWN ? "#ffa04a" : (strain >= STRAIN_STRAINED ? "#ffe07a" : "#bfe6ff"))
	A.maptext = MAPTEXT("<span style='color:[colour];font-size:8pt;'><b>[strain]</b></span>")
	A.maptext_width = 32
	A.maptext_height = 16
	A.maptext_x = strain >= 100 ? 2 : (strain >= 10 ? 8 : 12)
	A.maptext_y = 2

/datum/status_effect/arcane_strain/tick()
	var/mob/living/L = owner
	var/fade = 1
	if(L.IsSleeping())
		fade *= 4
	if(L.in_place_of_power())
		fade *= 3
	L.arcane_strain = max(0, L.arcane_strain - fade)
	if(L.arcane_strain <= 0)
		qdel(src)
		return
	update_alert()
	if(world.time < next_symptom)
		return
	next_symptom = world.time + rand(25, 45) SECONDS
	if(L.arcane_strain >= STRAIN_BRINK)
		L.balloon_alert(L, "hands shaking")
		L.blur_eyes(3)
		L.apply_damage(3, BURN)
	else if(L.arcane_strain >= STRAIN_OVERDRAWN)
		L.balloon_alert(L, "nosebleed")
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.blood_volume = max(BLOOD_VOLUME_SURVIVE, C.blood_volume - 8)
	else if(L.arcane_strain >= STRAIN_STRAINED)
		L.balloon_alert(L, "headache")

/atom/movable/screen/alert/status_effect/arcane_strain
	name = "Strain"
	desc = "Arcane Strain."
	icon_state = "buff"

/atom/movable/screen/alert/status_effect/arcane_strain/examine_ui(mob/user)
	var/mob/living/L = user
	var/strain = istype(L) ? round(L.arcane_strain) : 0
	var/list/inspec = list("----------------------")
	inspec += "<br><span class='notice'><b>Arcane Strain: [strain]/[STRAIN_MAX] ([strain_word(strain)])</b></span>"
	inspec += "<br>Every arcane working pulls on me. Strain fades with time, four times faster asleep, three times faster in a place of power."
	inspec += "<br>Every 20 Strain is -1 to my spell checks."
	inspec += "<br><b>30+</b> strained: aches and headaches."
	inspec += "<br><b>60+</b> overdrawn: every spell also costs blood; nosebleeds."
	inspec += "<br><b>85+</b> on the brink: burns and blurred sight."
	inspec += "<br><b>100</b>: my next spell never happens - the magic breaks out of me all at once."
	if(istype(L) && L.in_place_of_power())
		inspec += "<br><span class='nicegreen'>I stand in a place of power. Magic comes easier here.</span>"
	inspec += "<br>----------------------"
	to_chat(user, "[inspec.Join()]")

/obj/effect/temp_visual/strain_crackle
	icon = 'icons/effects/prayer_fx.dmi'
	icon_state = "crack"
	color = "#9fd4ff"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER
	plane = ABOVE_LIGHTING_PLANE

// --- Places of power ----------------------------------------------------------

/obj/structure/leystone
	name = "ley stone"
	desc = "A tall standing stone scored with old marks. The air around it hums faintly, and magic comes easier near it."
	icon = 'icons/effects/prayer_fx.dmi'
	icon_state = "leystone"
	density = TRUE
	anchored = TRUE
	max_integrity = 600
	light_outer_range = 2
	light_color = "#9fd4ff"

/obj/structure/leystone/examine(mob/user)
	. = ..()
	. += span_notice("A place of power: magic cast within three steps of it strains the caster far less, and Strain fades quickly here.")
