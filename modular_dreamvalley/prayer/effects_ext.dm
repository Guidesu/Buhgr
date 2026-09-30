// The wider range of answers: lasting blessings and afflictions, things done
// to the world around the target (water, weapons, gear, crops, beasts), and the
// newer requests (rage, veil, forgive, truth, tongues and the rest).

// --- Lasting effects ---------------------------------------------------------------

/datum/status_effect/prayer
	id = "prayer_effect"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 30 SECONDS
	/// Strength of the answer that made this.
	var/power = 1

/datum/status_effect/prayer/on_creation(mob/living/new_owner, new_duration, new_power = 1)
	if(new_duration)
		duration = new_duration
	power = new_power
	return ..()

/// Healing that keeps coming.
/datum/status_effect/prayer/renewal
	id = "prayer_renewal"
	tick_interval = 2 SECONDS

/datum/status_effect/prayer/renewal/tick()
	owner.heal_overall_damage(1.5 * power, 1 * power)
	owner.heal_wounds(2 * power)

/// Energy that keeps coming.
/datum/status_effect/prayer/vigor
	id = "prayer_vigor"
	tick_interval = 2 SECONDS

/datum/status_effect/prayer/vigor/tick()
	owner.energy_add(25 * power)

/// Battle-fury: strong and fast, careless and painless.
/datum/status_effect/buff/prayer_boon/rage
	id = "prayer_rage"

/datum/status_effect/buff/prayer_boon/rage/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOPAIN, "prayer_rage")
	owner.visible_message(span_danger("[owner]'s eyes go wild with holy fury!"))

/datum/status_effect/buff/prayer_boon/rage/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOPAIN, "prayer_rage")
	owner.energy_add(-200)
	to_chat(owner, span_warning("The fury leaves me, and leaves me spent."))
	return ..()

/// Unseen, or nearly.
/datum/status_effect/prayer/veil
	id = "prayer_veil"

/datum/status_effect/prayer/veil/on_apply()
	. = ..()
	animate(owner, alpha = clamp(round(120 - 40 * power), 35, 120), time = 1 SECONDS)

/datum/status_effect/prayer/veil/on_remove()
	animate(owner, alpha = 255, time = 1 SECONDS)
	return ..()

/// Dread: slowed, shaking, their nerve failing.
/datum/status_effect/buff/prayer_boon/dread
	id = "prayer_dread"
	tick_interval = 3 SECONDS

/datum/status_effect/buff/prayer_boon/dread/tick()
	owner.Jitter(4)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.sanity?.changeLevel(-1.5)
	if(prob(15))
		owner.emote("whimper")

/// Madness: the world slides sideways.
/datum/status_effect/prayer/madness
	id = "prayer_madness"
	tick_interval = 2 SECONDS

/datum/status_effect/prayer/madness/tick()
	owner.confused = max(owner.confused, round(3 * power))
	owner.set_dizziness(max(owner.dizziness, round(5 * power)))
	if(prob(10))
		to_chat(owner, span_warning(pick("The walls are breathing.", "Someone is whispering my name.", "My hands are not my hands.", "The floor tilts.")))

/// Rot: flesh going bad from within.
/datum/status_effect/prayer/rot
	id = "prayer_rot"
	tick_interval = 4 SECONDS

/datum/status_effect/prayer/rot/tick()
	owner.adjustToxLoss(1.5 * power)
	if(prob(8 * power) && iscarbon(owner))
		var/mob/living/carbon/C = owner
		var/obj/item/organ/O = pick_n_take(C.internal_organs.Copy())
		O?.add_internal_wound(/datum/internal_wound/organic/necrosis_start/damaged_tissue)

/// Courage: steady nerves, a mind that will not break.
/datum/status_effect/buff/prayer_boon/courage
	id = "prayer_courage"

/datum/status_effect/buff/prayer_boon/courage/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.sanity)
			H.sanity.sanity_invulnerability = world.time + duration

/// Weathering: heat and cold slide off.
/datum/status_effect/prayer/endure
	id = "prayer_endure"

/datum/status_effect/prayer/endure/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_RESISTCOLD, "prayer")
	ADD_TRAIT(owner, TRAIT_RESISTHEAT, "prayer")

/datum/status_effect/prayer/endure/on_remove()
	REMOVE_TRAIT(owner, TRAIT_RESISTCOLD, "prayer")
	REMOVE_TRAIT(owner, TRAIT_RESISTHEAT, "prayer")
	return ..()

/// Night eyes.
/datum/status_effect/prayer/nighteyes
	id = "prayer_nighteyes"

/datum/status_effect/prayer/nighteyes/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_DARKVISION, "prayer")
	owner.update_sight()

/datum/status_effect/prayer/nighteyes/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DARKVISION, "prayer")
	owner.update_sight()
	return ..()

/// Tongues: every common language understood for a while.
/datum/status_effect/prayer/tongues
	id = "prayer_tongues"
	var/list/granted = list()

/datum/status_effect/prayer/tongues/on_apply()
	. = ..()
	for(var/datum/language/L as anything in GLOB.languages_character_selection)
		if(!owner.has_language(L))
			owner.grant_language(L)
			granted += L

/datum/status_effect/prayer/tongues/on_remove()
	for(var/datum/language/L as anything in granted)
		owner.remove_language(L)
	granted = null
	return ..()

// --- Things around the target --------------------------------------------------------

/// Requests aimed at objects, ground or beasts rather than at a body.
/// Returns feedback, FALSE if this isn't such a request, or null if it failed.
/proc/prayer_apply_special(datum/prayer_clause/C, mob/living/target, mob/living/user, datum/domain/D)
	var/p = C.power
	var/obj/item/held = user.get_active_held_item()
	switch(C.subject)
		if("water")
			if(!(C.intent in list("bless", "cleanse", "heal")))
				return FALSE
			var/obj/item/reagent_containers/RC = held
			if(!istype(RC) || !RC.reagents?.has_reagent(/datum/reagent/water))
				return "I must hold the water up to be blessed."
			var/amount = RC.reagents.get_reagent_amount(/datum/reagent/water)
			var/converted = min(amount, 15 * p)
			RC.reagents.remove_reagent(/datum/reagent/water, converted)
			RC.reagents.add_reagent(/datum/reagent/water/blessed, converted)
			return "The water in [RC] shines for a moment."
		if("weapon")
			if(C.intent == "disarm")
				return FALSE
			if(C.intent in list("bless", "strengthen", "shield"))
				var/obj/item/W = held
				if(!istype(W) || !W.force)
					return "I must hold the weapon to be blessed."
				if(HAS_TRAIT(W, TRAIT_HOLY))
					return "[W] is already blessed."
				var/bonus = round(3 + 3 * p)
				W.force += bonus
				ADD_TRAIT(W, TRAIT_HOLY, "prayer")
				W.add_filter("prayer_glow", 2, list("type" = "outline", "color" = "#f3e08a", "size" = 1))
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(prayer_unbless_weapon), W, bonus), (1 MINUTES) * p * C.duration_mult)
				return "[W] gleams with borrowed holiness."
			if(C.intent in list("heal", "repair"))
				return prayer_repair_item(held, p)
		if("gear")
			if(C.intent in list("heal", "repair", "strengthen", "bless"))
				return prayer_repair_item(held, p)
		if("crops")
			if(!(C.intent in list("grow", "bless", "feed", "quench", "heal", "quicken")))
				return FALSE
			var/grown = 0
			for(var/obj/structure/soil/S in range(2, user))
				S.adjust_water(40 * p)
				S.adjust_nutrition(40 * p)
				grown++
			return grown ? "The soil around me drinks deep and darkens." : "There is no tilled soil here to bless."
		if("beast")
			if(C.intent in list("tame", "calm", "bless"))
				if(ishuman(target))
					return FALSE
				var/tag = "[user.real_name]_faction"
				target.faction |= tag
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(prayer_untame), target, tag), (1 MINUTES) * p * C.duration_mult)
				target.Immobilize(2 SECONDS)
				return "[target] stills and regards me without hunger."
		if("food")
			if(!(C.intent in list("bless", "cleanse", "heal", "feed")))
				return FALSE
			var/obj/item/reagent_containers/food/F = held
			if(!istype(F))
				return "I must hold the food up to be blessed."
			F.reagents?.add_reagent(/datum/reagent/water/blessed, 3 * p)
			F.reagents?.add_reagent(/datum/reagent/consumable/nutriment, 3 * p)
			return "[F] smells richer, and faintly of incense."
		if("drink")
			if(C.intent in list("sober", "cleanse", "heal", "calm"))
				return prayer_sober(target, p)
	return FALSE

/proc/prayer_unbless_weapon(obj/item/W, bonus)
	if(QDELETED(W))
		return
	W.force = max(0, W.force - bonus)
	REMOVE_TRAIT(W, TRAIT_HOLY, "prayer")
	W.remove_filter("prayer_glow")

/proc/prayer_untame(mob/living/L, tag)
	if(!QDELETED(L))
		L.faction -= tag

/proc/prayer_repair_item(obj/item/I, p)
	if(!istype(I) || !I.max_integrity)
		return "I must hold what I want mended."
	if(I.obj_integrity >= I.max_integrity)
		return "[I] needs no mending."
	I.obj_integrity = min(I.max_integrity, I.obj_integrity + I.max_integrity * 0.25 * p)
	I.update_icon()
	return "[I] knits itself back together."

/proc/prayer_sober(mob/living/target, p)
	if(!target.reagents)
		return null
	var/did = FALSE
	for(var/datum/reagent/R as anything in target.reagents.reagent_list)
		if(istype(R, /datum/reagent/consumable/ethanol))
			target.reagents.remove_reagent(R.type, 15 * p)
			did = TRUE
	if(target.has_status_effect(/datum/status_effect/buff/drunk))
		target.remove_status_effect(/datum/status_effect/buff/drunk)
		did = TRUE
	return did ? "[target]'s head clears." : null

// --- The newer requests ------------------------------------------------------------------

/proc/prayer_apply_ext(datum/prayer_clause/C, mob/living/target, mob/living/user, datum/domain/D)
	var/p = C.power
	var/dur = C.duration_mult
	switch(C.intent)
		if("rage")
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/rage, (30 SECONDS) * p * dur, list(STATKEY_STR = clamp(round(1 + p), 1, 3), STATKEY_SPD = 1, STATKEY_INT = -2))
			return "[target] fills with holy fury."
		if("veil")
			target.apply_status_effect(/datum/status_effect/prayer/veil, (30 SECONDS) * p * dur, p)
			return "[target] fades at the edges."
		if("forgive")
			var/did = FALSE
			for(var/event_type in list(/datum/stressevent/psycurse, /datum/stressevent/viewsinpunish))
				if(target.has_stress_event(event_type))
					target.remove_stress(event_type)
					did = TRUE
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if(H.sanity)
					H.sanity.changeLevel(10 * p)
					did = TRUE
			return did ? "A weight lifts from [target]." : null
		if("truth")
			if(target == user)
				return "I already know my own heart. Or I should."
			var/list/told = list("[target] seems [target.get_stress_amount() > 0 ? "troubled" : "at ease"].")
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if(H.sanity)
					told += "Their mind is [H.sanity.level > 60 ? "steady" : (H.sanity.level > 30 ? "strained" : "close to breaking")]."
				if(H.patron)
					told += "Their prayers go to [H.patron.name]."
			to_chat(target, span_warning("I feel something weighing my heart."))
			return jointext(told, " ")
		if("tongues")
			target.apply_status_effect(/datum/status_effect/prayer/tongues, (2 MINUTES) * p * dur, p)
			return "The words of strangers begin to make sense to [target]."
		if("frighten")
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/dread, (20 SECONDS) * p * dur, list(STATKEY_SPD = -1, STATKEY_WIL = -2))
			target.add_stress(/datum/stressevent/psycurse)
			target.visible_message(span_warning("[target] blanches with sudden terror!"))
			return "Dread takes [target]."
		if("madden")
			target.apply_status_effect(/datum/status_effect/prayer/madness, (15 SECONDS) * p * dur, p)
			return "[target]'s thoughts come apart."
		if("sicken")
			target.adjustToxLoss(6 * p)
			if(iscarbon(target) && p >= 0.8)
				var/mob/living/carbon/Cb = target
				Cb.vomit(20)
			return "[target] turns grey and sick."
		if("rot")
			target.apply_status_effect(/datum/status_effect/prayer/rot, (40 SECONDS) * p * dur, p)
			return "Something begins to go bad inside [target]."
		if("renew")
			target.apply_status_effect(/datum/status_effect/prayer/renewal, (30 SECONDS) * p * dur, p)
			return "A slow warmth settles into [target]'s wounds."
		if("vigor")
			target.apply_status_effect(/datum/status_effect/prayer/vigor, (40 SECONDS) * p * dur, p)
			target.energy_add(150 * p)
			return "[target] feels they could walk forever."
		if("courage")
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/courage, (1 MINUTES) * p * dur, list(STATKEY_WIL = clamp(round(1 + p), 1, 3)))
			target.remove_status_effect(/datum/status_effect/buff/prayer_boon/dread)
			return "[target]'s fear burns away."
		if("endure")
			target.apply_status_effect(/datum/status_effect/prayer/endure, (2 MINUTES) * p * dur, p)
			return "The weather loses its bite on [target]."
		if("nighteyes")
			target.apply_status_effect(/datum/status_effect/prayer/nighteyes, (1 MINUTES) * p * dur, p)
			return "The dark grows thin before [target]'s eyes."
		if("speak")
			if(!ishuman(target))
				return null
			var/mob/living/carbon/human/H = target
			if(!H.silent)
				return null
			H.silent = 0
			return "[target] finds their voice."
		if("disarm")
			var/obj/item/I = target.get_active_held_item() || target.get_inactive_held_item()
			if(!I || target == user)
				return null
			if(p < 0.8 && prob(50))
				return "[target]'s grip holds."
			target.dropItemToGround(I)
			target.visible_message(span_warning("[I] is wrenched from [target]'s hand!"))
			return "[target] is disarmed."
		if("fell")
			if(target == user)
				return null
			target.Knockdown((1 SECONDS) + (1.5 SECONDS) * p)
			target.visible_message(span_warning("[target] is thrown to the ground by an unseen force!"))
			return "[target] falls."
		if("repel")
			if(target == user)
				return null
			var/turf/away = get_edge_target_turf(target, get_dir(user, target))
			target.safe_throw_at(away, clamp(round(1 + 2 * p), 1, 4), 1, user)
			return "[target] is hurled back."
		if("draw")
			if(target == user)
				return null
			target.safe_throw_at(get_turf(user), clamp(round(1 + 2 * p), 1, 4), 1, user)
			return "[target] is dragged towards me."
		if("banish")
			if(!prayer_is_undead(target))
				return "There is nothing unholy in [target] to banish."
			target.adjustFireLoss(30 * p)
			target.Knockdown(2 SECONDS)
			target.visible_message(span_danger("[target] shrieks as holy force tears at it!"))
			return "[target] is torn by the banishing."
		if("sober")
			return prayer_sober(target, p)
		if("kindle")
			var/lit = 0
			for(var/obj/machinery/light/rogue/L in view(3 + round(p), user))
				if(!L.on)
					L.fire_act()
					lit++
			for(var/obj/item/candle/candle in view(3 + round(p), user))
				if(!candle.lit)
					candle.light()
					lit++
			if(target != user && p >= 1.2 && !lit)
				target.adjust_fire_stacks(1, /datum/status_effect/fire_handler/fire_stacks/divine)
				target.ignite_mob()
				return "[target] catches holy fire."
			return lit ? "Flames leap up around me." : "There is nothing here to light."
		if("snuff")
			var/dark = 0
			for(var/obj/machinery/light/rogue/L in view(3 + round(p), user))
				if(L.on)
					L.extinguish()
					dark++
			for(var/obj/item/candle/candle in view(3 + round(p), user))
				if(candle.lit)
					candle.put_out_candle()
					dark++
			return dark ? "The lights around me gutter and die." : "There is no light here to put out."
		if("seek")
			return prayer_seek(C.subject, user, p)
		if("hallow")
			var/turf/T = get_turf(target)
			for(var/obj/effect/prayer_hallow/old in range(2, T))
				qdel(old)
			new /obj/effect/prayer_hallow(T, (1 MINUTES) * p * dur, p)
			return "The ground here is holy now."
		if("grow", "tame", "repair")
			// Handled by what they act on; without a fitting subject there is nothing to do.
			return null
	return null


// --- Finding things ----------------------------------------------------------------

/proc/prayer_seek(subject, mob/living/user, p)
	var/range = round(20 + 20 * p)
	var/atom/best
	var/best_dist = INFINITY
	switch(subject)
		if("water")
			for(var/turf/open/water/W in range(range, user))
				var/d = get_dist(user, W)
				if(d < best_dist)
					best = W
					best_dist = d
		else
			for(var/mob/living/L in range(range, user))
				if(L == user)
					continue
				var/match = FALSE
				switch(subject)
					if("dead")
						match = (L.stat == DEAD)
					if("undead")
						match = prayer_is_undead(L)
					if("beast")
						match = !ishuman(L) && L.stat != DEAD
					if("foe")
						match = (L.stat != DEAD) && !L.faction_check_mob(user)
					else
						match = (L.stat == DEAD)
				if(!match)
					continue
				var/d = get_dist(user, L)
				if(d < best_dist)
					best = L
					best_dist = d
	if(!best)
		return "My god shows me nothing of what I seek, near or far."
	var/how_far = best_dist <= 5 ? "very close" : (best_dist <= 15 ? "close" : "some way off")
	return "My god turns my gaze [dir2text(get_dir(user, best))], [how_far]."

// --- Hallowed ground -------------------------------------------------------------------

/obj/effect/prayer_hallow
	name = "hallowed ground"
	desc = "The air here is still and clean. Something is watching over this place."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	alpha = 60
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/power = 1

/obj/effect/prayer_hallow/Initialize(mapload, duration = 1 MINUTES, new_power = 1)
	. = ..()
	power = new_power
	START_PROCESSING(SSobj, src)
	QDEL_IN(src, duration)

/obj/effect/prayer_hallow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/prayer_hallow/process()
	for(var/mob/living/L in range(2, src))
		if(prayer_is_undead(L))
			L.adjustFireLoss(3 * power)
			if(prob(20))
				to_chat(L, span_danger("The holy ground burns!"))
		else if(L.stat != DEAD)
			L.heal_overall_damage(0.5 * power, 0.5 * power)
