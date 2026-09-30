// Guards: real fighting stances for every weapon. A fighter of journeyman skill
// or better can take up a guard with the weapon in hand - High, Low, Hanging,
// Long and so on - each trading defence for offence, speed for weight. The
// "Take Guard" spell readies it; Toggle Spell Alt Mode cycles the guards your
// weapon knows; clicking takes the guard. Rough-and-ready fighters (below
// journeyman) have no guards to speak of.
//
// Hooks: parry.dm and dodge.dm (defence and press), item_attack.dm (damage and
// swing speed).

#define MOVESPEED_ID_GUARD "WEAPON_GUARD"

/// One guard's numbers. Positive parry/dodge help the one in guard; press lowers
/// the defences of whoever they attack; damage and speed are multipliers (speed
/// multiplies the time between swings, so under 1 is faster).
/datum/guard
	var/name = "Guard"
	var/desc = ""
	var/parry = 0
	var/dodge = 0
	var/press = 0
	var/damage = 1
	var/speed = 1
	/// Extra slowdown while standing in it.
	var/slowdown = 0
	/// Overhead badge in icons/effects/guards.dmi.
	var/fx

/datum/guard/New(name, desc, parry = 0, dodge = 0, press = 0, damage = 1, speed = 1, slowdown = 0)
	src.name = name
	src.desc = desc
	src.parry = parry
	src.dodge = dodge
	src.press = press
	src.damage = damage
	src.speed = speed
	src.slowdown = slowdown

/datum/guard/proc/summary()
	var/list/bits = list()
	if(parry)
		bits += "parry [parry > 0 ? "+" : ""][parry]"
	if(dodge)
		bits += "dodge [dodge > 0 ? "+" : ""][dodge]"
	if(press)
		bits += "foe's parry & dodge [press > 0 ? "-" : "+"][abs(press)]"
	if(damage != 1)
		bits += "damage [damage > 1 ? "+" : ""][round((damage - 1) * 100, 1)]%"
	if(speed != 1)
		bits += "swings [speed < 1 ? "[round((1 - speed) * 100, 1)]% faster" : "[round((speed - 1) * 100, 1)]% slower"]"
	if(slowdown)
		bits += "moves slower"
	return jointext(bits, ", ")

#define GUARD(n, d, p, dg, pr, dm, sp) new /datum/guard(n, d, p, dg, pr, dm, sp)
#define GUARD_SLOW(n, d, p, dg, pr, dm, sp, sl) new /datum/guard(n, d, p, dg, pr, dm, sp, sl)

/// Overhead badges, in the same order as each weapon's guards.
GLOBAL_LIST_INIT(weapon_guard_fx, list(
	/datum/skill/combat/swords = list("sword_middle", "sword_high", "sword_low", "sword_hanging", "sword_long", "sword_back", "sword_side", "sword_short"),
	/datum/skill/combat/axes = list("axe_shoulder", "axe_middle", "axe_low", "axe_back", "axe_choked"),
	/datum/skill/combat/maces = list("mace_hammer", "mace_middle", "mace_low", "mace_back"),
	/datum/skill/combat/polearms = list("polearm_middle", "polearm_high", "polearm_low", "polearm_long", "polearm_half"),
	/datum/skill/combat/staves = list("staff_middle", "staff_open", "staff_low", "staff_close"),
	/datum/skill/combat/knives = list("knife_forward", "knife_reverse", "knife_crouch", "knife_forearm"),
	/datum/skill/combat/whipsflails = list("flail_overhead", "flail_sweep", "flail_circle", "flail_lash"),
	/datum/skill/combat/shields = list("shield_wall", "shield_bash", "shield_high"),
	/datum/skill/combat/unarmed = list("fist_boxer", "fist_open", "fist_rush"),
	/datum/skill/combat/wrestling = list("wrestle_low", "wrestle_tie"),
))

/// The sound of settling into a guard with each kind of weapon.
/proc/guard_sound_for(skill)
	switch(skill)
		if(/datum/skill/combat/unarmed, /datum/skill/combat/wrestling)
			return 'sound/combat/shove.ogg'
		if(/datum/skill/combat/shields)
			return 'sound/combat/shieldraise.ogg'
		if(/datum/skill/combat/whipsflails)
			return 'sound/combat/wooshes/flail_swing.ogg'
		if(/datum/skill/combat/maces, /datum/skill/combat/axes, /datum/skill/combat/staves, /datum/skill/combat/polearms)
			return pick('sound/combat/wooshes/blunt/wooshhuge (1).ogg', 'sound/combat/wooshes/blunt/wooshhuge (2).ogg', 'sound/combat/wooshes/blunt/wooshhuge (3).ogg')
	return pick('sound/combat/wooshes/bladed/wooshmed (1).ogg', 'sound/combat/wooshes/bladed/wooshmed (2).ogg', 'sound/combat/wooshes/bladed/wooshmed (3).ogg')

/// Weapon skill = the guards it knows. Names follow the old fencing books where they have them.
GLOBAL_LIST_INIT(weapon_guards, list(
	/datum/skill/combat/swords = list(
		GUARD("Middle Guard", "Point at the eyes, hilt at the belly - the Plough. Ready for anything, committed to nothing.", 5, 0, 5, 1, 1),
		GUARD("High Guard", "Sword raised over the head or shoulder - From the Roof. Every blow falls from above, hard.", -10, -5, 10, 1.15, 1),
		GUARD("Low Guard", "Point to the ground before you - the Fool. It looks open. It is not; it waits to break the blow and answer it.", 15, 5, -5, 0.9, 1),
		GUARD("Hanging Guard", "Hilt high, point hanging down across the body - the Ox. A roof over your head that sheds cuts.", 20, -10, 0, 0.85, 1.05),
		GUARD("Long Guard", "Arms and blade thrust out long toward the foe. It keeps them at the point's length.", 5, 5, 10, 0.95, 0.95),
		GUARD("Back Guard", "Blade trailed low behind you - the Tail. The foe cannot read it, and the cut that comes from it is the heaviest there is.", -15, -5, 5, 1.25, 1.2),
		GUARD("Side Guard", "Blade held at the side, body turned. Light on the feet, quick to step out of the way.", -5, 15, 0, 1, 1),
		GUARD("Short Guard", "Hilt drawn in close, point up. For crowded places: quick, short, and tight to the body.", 5, 0, 5, 0.9, 0.85),
	),
	/datum/skill/combat/axes = list(
		GUARD("Shoulder Guard", "Haft over the shoulder, ready to hew.", -5, 0, 10, 1.15, 1),
		GUARD("Middle Guard", "Head forward, haft across the body - it can hook as well as hew.", 10, 0, 5, 1, 1),
		GUARD("Low Hang", "Head low and hanging, waiting to hook a leg or a shield.", 10, 5, 0, 0.9, 1),
		GUARD("Back Swing", "Axe drawn far back for the biggest blow you have.", -15, -5, 5, 1.3, 1.25),
		GUARD("Choked Grip", "Hand slid up under the head for short, fast chops.", 5, 0, 5, 0.9, 0.85),
	),
	/datum/skill/combat/maces = list(
		GUARD("Hammer Guard", "Weapon cocked high to drop like a smith's hammer.", -10, 0, 10, 1.2, 1.05),
		GUARD("Middle Guard", "Held before you, ready to meet a blow with a blow.", 10, 0, 5, 1, 1),
		GUARD("Low Guard", "Hanging low at the side, rising to break knees and parries alike.", 10, 5, 0, 0.9, 1),
		GUARD("Back Guard", "Drawn back to the shoulder for a blow meant to finish things.", -15, -5, 5, 1.3, 1.2),
	),
	/datum/skill/combat/polearms = list(
		GUARD("Middle Guard", "Point at the chest, shaft level - the middle iron door. The polearm's home.", 10, 0, 10, 1, 1),
		GUARD("High Guard", "Raised over the head to strike down, like a window thrown open.", -10, -5, 10, 1.2, 1.05),
		GUARD("Low Guard", "Point low, butt high - the whole iron door. Hard to get past.", 20, 0, 0, 0.85, 1.05),
		GUARD("Long Guard", "Shaft run out to its full length. The foe must come through the point.", 5, 0, 15, 0.95, 1),
		GUARD("Half Staff", "Hands spread up the shaft, fighting close with both ends.", 10, 5, 0, 0.9, 0.85),
	),
	/datum/skill/combat/staves = list(
		GUARD("Middle Ward", "Staff held across and forward, both ends working.", 15, 0, 5, 1, 1),
		GUARD("Open Fight", "Staff raised high to crack down on the head.", -10, -5, 10, 1.2, 1),
		GUARD("Low Ward", "Point low toward the foe's feet, the back end guarding the head.", 15, 5, 0, 0.9, 1),
		GUARD("Close Ward", "Hands spread, fighting at half-staff. Quick and tight.", 10, 5, 5, 0.9, 0.85),
	),
	/datum/skill/combat/knives = list(
		GUARD("Forward Grip", "Blade forward, point toward the foe. Quick cuts and thrusts.", 0, 10, 5, 1, 0.9),
		GUARD("Reverse Grip", "Blade down along the forearm, driven in like an icepick.", -10, 0, 10, 1.2, 1),
		GUARD_SLOW("Low Crouch", "Knees bent, knife low, the other hand guarding. A knife-fighter's crouch.", 0, 20, 0, 0.9, 1, 0.3),
		GUARD("Forearm Guard", "Blade laid along the forearm to catch blows on it.", 20, 0, 0, 0.85, 1),
	),
	/datum/skill/combat/whipsflails = list(
		GUARD("Overhead", "Swung high and brought down in a great arc.", -10, 0, 10, 1.2, 1.05),
		GUARD("Low Sweep", "Kept low to wrap ankles and knees.", 5, 5, 5, 0.95, 1),
		GUARD("Warding Circle", "Kept moving in a circle before you, a wall of chain.", 20, -10, 0, 0.85, 1.1),
		GUARD("Long Lash", "Played out to its full length, striking from far off.", 0, 5, 15, 0.95, 1),
	),
	/datum/skill/combat/shields = list(
		GUARD_SLOW("Shield Wall", "Shield up, body tucked behind it. Nothing gets through - including you.", 25, -15, 0, 0.8, 1.1, 0.5),
		GUARD("Bash Guard", "Shield forward and low, ready to shove and strike.", 5, 0, 10, 1.1, 1),
		GUARD("Hanging Shield", "Shield raised high, rim covering the head from above.", 15, 0, 0, 0.95, 1),
	),
	/datum/skill/combat/unarmed = list(
		GUARD("Boxer's Guard", "Fists high, chin down, elbows in.", 10, 5, 5, 1, 1),
		GUARD("Open Hands", "Hands open and forward, ready to catch and throw.", 5, 5, 0, 0.9, 0.9),
		GUARD("Brawler's Rush", "Head down and swinging.", -10, -5, 10, 1.2, 1),
	),
	/datum/skill/combat/wrestling = list(
		GUARD_SLOW("Low Stance", "Knees bent, weight low, hands reaching. Hard to throw.", 10, 10, 0, 0.9, 1, 0.3),
		GUARD("Collar Tie", "Hands up to seize the head and neck.", 0, 0, 10, 1.05, 1),
	),
))

#undef GUARD
#undef GUARD_SLOW

/mob/living
	/// The guard currently held, if any.
	var/datum/guard/current_guard
	/// The skill the current guard belongs to.
	var/current_guard_skill

/// The weapon skill of what the fighter holds, for guards. The weapon in the
/// active hand comes first, then one in the other hand (a two-handed grip, or a
/// weapon carried off-hand). Bare hands count only in combat mode.
/mob/living/proc/guard_skill_for_held()
	var/obj/item/active = get_active_held_item()
	var/obj/item/other = get_inactive_held_item()
	for(var/obj/item/held in list(active, other))
		if(!istype(held, /obj/item/rogueweapon) || istype(held, /obj/item/rogueweapon/shield))
			continue
		if(held.associated_skill && GLOB.weapon_guards[held.associated_skill])
			return held.associated_skill
	for(var/obj/item/rogueweapon/shield/S in list(active, other))
		return /datum/skill/combat/shields
	if(!active && !other && cmode)
		return get_skill_level(/datum/skill/combat/wrestling) > get_skill_level(/datum/skill/combat/unarmed) ? /datum/skill/combat/wrestling : /datum/skill/combat/unarmed
	return null

/// Whether the fighter can stand in a guard with what they hold right now.
/mob/living/proc/can_guard_with_held()
	var/skill = guard_skill_for_held()
	return skill && get_skill_level(skill) >= SKILL_LEVEL_JOURNEYMAN

/// How much better a trained fighter holds their guard: journeyman x1, expert x1.25, master x1.5, legend x1.75.
/mob/living/proc/guard_mastery()
	if(!current_guard_skill)
		return 1
	return 1 + max(0, get_skill_level(current_guard_skill) - SKILL_LEVEL_JOURNEYMAN) * 0.25

/// Only the benefits grow with skill; the costs of a guard stay what they are.
/proc/guard_scale(value, mastery)
	return value > 0 ? round(value * mastery) : value

/mob/living/proc/guard_parry()
	return current_guard ? guard_scale(current_guard.parry, guard_mastery()) : 0

/mob/living/proc/guard_dodge()
	return current_guard ? guard_scale(current_guard.dodge, guard_mastery()) : 0

/mob/living/proc/guard_press()
	return current_guard ? guard_scale(current_guard.press, guard_mastery()) : 0

/mob/living/proc/guard_damage_mult()
	if(!current_guard)
		return 1
	var/d = current_guard.damage
	return d > 1 ? 1 + (d - 1) * guard_mastery() : d

/mob/living/proc/guard_speed_mult()
	if(!current_guard)
		return 1
	var/s = current_guard.speed
	return s < 1 ? 1 - (1 - s) * guard_mastery() : s

/mob/living/proc/take_guard(datum/guard/G, skill)
	drop_guard(TRUE)
	current_guard = G
	current_guard_skill = skill
	if(!G.fx)
		var/list/guards = GLOB.weapon_guards[skill]
		var/list/fx = GLOB.weapon_guard_fx[skill]
		var/index = guards.Find(G)
		if(index && index <= length(fx))
			G.fx = fx[index]
	if(G.slowdown)
		add_movespeed_modifier(MOVESPEED_ID_GUARD, override = TRUE, multiplicative_slowdown = G.slowdown)
	apply_status_effect(/datum/status_effect/guard)
	var/obj/item/held = get_active_held_item()
	if(!istype(held, /obj/item/rogueweapon))
		held = get_inactive_held_item()
	balloon_alert_to_viewers(lowertext(G.name), lowertext(G.name), 5)
	// The same sounds as raising a guard in a fight, and a short settle of the body.
	playsound(src, guard_sound_for(skill), 60, TRUE)
	playsound(src, 'sound/combat/clash_initiate.ogg', 35, TRUE)
	var/old_y = pixel_y
	animate(src, pixel_y = old_y - 2, time = 1)
	animate(pixel_y = old_y, time = 2, easing = SINE_EASING)

/mob/living/proc/drop_guard(silent = FALSE)
	if(!current_guard)
		return
	if(!silent)
		balloon_alert(src, "guard lowered")
	current_guard = null
	current_guard_skill = null
	remove_movespeed_modifier(MOVESPEED_ID_GUARD)
	remove_status_effect(/datum/status_effect/guard)

// --- Holding it ----------------------------------------------------------------------

/datum/status_effect/guard
	id = "weapon_guard"
	duration = -1
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/guard

/datum/status_effect/guard
	var/obj/effect/overlay/guard_badge/badge

/obj/effect/overlay/guard_badge
	icon = 'icons/effects/guards.dmi'
	layer = MOB_EFFECT_LAYER_GUARD
	plane = ABOVE_LIGHTING_PLANE
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | KEEP_APART
	vis_flags = NONE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// Always floats clear above the head.
	pixel_y = 20

/datum/status_effect/guard/on_apply()
	. = ..()
	var/mob/living/L = owner
	if(L.current_guard?.fx)
		badge = new
		badge.icon_state = L.current_guard.fx
		L.vis_contents += badge
	addtimer(CALLBACK(src, PROC_REF(update_alert)), 1)

/datum/status_effect/guard/proc/update_alert()
	var/mob/living/L = owner
	if(!linked_alert || !L?.current_guard)
		return
	linked_alert.name = L.current_guard.name
	linked_alert.desc = "[L.current_guard.desc]\n\n[replacetext(L.current_guard.summary(), ", ", "\n")]"

/datum/status_effect/guard/tick()
	var/mob/living/L = owner
	if(!L.current_guard)
		qdel(src)
		return
	// Changing weapons, falling, or losing consciousness breaks a guard.
	if(L.stat != CONSCIOUS || !(L.mobility_flags & MOBILITY_STAND) || L.guard_skill_for_held() != L.current_guard_skill)
		L.drop_guard(!(L.stat == CONSCIOUS))

/datum/status_effect/guard/on_remove()
	var/mob/living/L = owner
	if(badge)
		L.vis_contents -= badge
		QDEL_NULL(badge)
	if(L.current_guard)
		L.current_guard = null
		L.current_guard_skill = null
		L.remove_movespeed_modifier(MOVESPEED_ID_GUARD)
	return ..()

/atom/movable/screen/alert/status_effect/guard
	name = "Guard"
	desc = "I am standing in a guard."
	icon_state = "buff"

/atom/movable/screen/alert/status_effect/guard/examine_ui(mob/user)
	var/mob/living/L = user
	if(!istype(L) || !L.current_guard)
		return ..()
	to_chat(user, span_notice("<b>[L.current_guard.name]</b> - [L.current_guard.desc]<br><i>[L.current_guard.summary()]</i>"))

// --- Taking it -----------------------------------------------------------------------

/datum/action/cooldown/spell/take_guard
	name = "Take Guard"
	desc = "Settle into one of your weapon's guards. Toggle Spell Alt Mode while readied cycles through the guards your weapon knows; click to take the chosen one, or choose No Guard to drop it. \
		A guard trades defence for offence or speed for weight, and holds until you change weapons, fall or drop it. Journeyman skill with the weapon is needed; more skill makes a guard's strengths stronger."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "shieldsparkles"
	sound = null
	charge_sound = null
	has_visual_effects = FALSE
	hide_charge_effect = TRUE
	spell_impact_intensity = SPELL_IMPACT_NONE
	click_to_activate = TRUE
	self_cast_possible = TRUE
	cast_range = 30
	primary_resource_type = SPELL_COST_NONE
	invocation_type = INVOCATION_NONE
	charge_required = FALSE
	cooldown_time = 2 SECONDS
	associated_skill = null
	/// 0 = no guard; 1+ = that guard of the held weapon.
	var/guard_index = 1

/datum/action/cooldown/spell/take_guard/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/take_guard/proc/available_guards(mob/living/user)
	var/skill = user.guard_skill_for_held()
	if(!skill || user.get_skill_level(skill) < SKILL_LEVEL_JOURNEYMAN)
		return list()
	return GLOB.weapon_guards[skill]

/datum/action/cooldown/spell/take_guard/toggle_alt_mode(mob/user)
	var/mob/living/L = user
	var/list/guards = available_guards(L)
	if(!length(guards))
		to_chat(L, span_warning("I don't know this weapon well enough to stand in any guard with it. (Journeyman skill needed.)"))
		return TRUE
	guard_index = (guard_index + 1) % (length(guards) + 1)
	if(guard_index)
		var/datum/guard/G = guards[guard_index]
		L.balloon_alert(L, G.name)
	else
		L.balloon_alert(L, "no guard")
	update_guard_maptext(guards)
	return TRUE

/datum/action/cooldown/spell/take_guard/proc/update_guard_maptext(list/guards)
	var/label = "NONE"
	if(guard_index && guard_index <= length(guards))
		var/datum/guard/G = guards[guard_index]
		label = uppertext(copytext(G.name, 1, findtext(G.name, " ") || 0))
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/button = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in button.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(button)
			button.vis_contents += holder
		holder.maptext = MAPTEXT(label)
		holder.color = "#e8d8b8"

/datum/action/cooldown/spell/take_guard/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = owner
	if(!istype(L))
		return FALSE
	if(!guard_index)
		L.drop_guard()
		return TRUE
	var/list/guards = available_guards(L)
	if(!length(guards))
		to_chat(L, span_warning("I don't know this weapon well enough to stand in any guard with it. (Journeyman skill needed.)"))
		return FALSE
	if(guard_index > length(guards))
		guard_index = 1
	// Using it again on the guard already held lowers it.
	if(L.current_guard == guards[guard_index])
		L.drop_guard()
		return TRUE
	L.take_guard(guards[guard_index], L.guard_skill_for_held())
	update_guard_maptext(guards)
	return TRUE

/// The Take Guard button is there only while holding a weapon you know well enough.
/mob/living/proc/check_guard_training()
	if(!mind)
		return
	var/has = mind.has_spell(/datum/action/cooldown/spell/take_guard)
	var/should = can_guard_with_held()
	if(should && !has)
		mind.AddSpell(new /datum/action/cooldown/spell/take_guard, src)
	else if(!should && has)
		drop_guard(TRUE)
		mind.RemoveSpell(/datum/action/cooldown/spell/take_guard)

/mob/living/carbon/human/update_inv_hands()
	. = ..()
	check_guard_training()

/mob/living/carbon/human/swap_hand(held_index)
	. = ..()
	check_guard_training()

/mob/living/carbon/human/on_cmode()
	. = ..()
	check_guard_training()

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SKILL_RANK_INCREASED, PROC_REF(on_guard_skill_up))

/mob/living/carbon/human/proc/on_guard_skill_up(datum/source, datum/skill/skill, new_level, old_level)
	SIGNAL_HANDLER
	if(new_level >= SKILL_LEVEL_JOURNEYMAN)
		addtimer(CALLBACK(src, PROC_REF(check_guard_training)), 1 SECONDS)
