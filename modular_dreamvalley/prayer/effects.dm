// What each answered request does. `p` is the clause's power (around 1 for an
// ordinary, well-made prayer), `dur` its duration multiplier. Each proc returns
// a short line for the supplicant, or null if there was nothing to act on.

/datum/status_effect/buff/prayer_boon
	id = "prayer_boon"
	alert_type = /atom/movable/screen/alert/status_effect/buff/prayer_boon
	duration = 1 MINUTES

/datum/status_effect/buff/prayer_boon/on_creation(mob/living/new_owner, new_duration, list/stats)
	if(new_duration)
		duration = new_duration
	if(islist(stats))
		effectedstats = stats.Copy()
	return ..()

/datum/status_effect/buff/prayer_boon/strength
	id = "prayer_boon_strength"
/datum/status_effect/buff/prayer_boon/speed
	id = "prayer_boon_speed"
/datum/status_effect/buff/prayer_boon/ward
	id = "prayer_boon_ward"
/datum/status_effect/buff/prayer_boon/fortune
	id = "prayer_boon_fortune"
/datum/status_effect/buff/prayer_boon/bane
	id = "prayer_bane"
/datum/status_effect/buff/prayer_boon/curse
	id = "prayer_curse"

/atom/movable/screen/alert/status_effect/buff/prayer_boon
	name = "Answered Prayer"
	desc = "A god has answered for me."
	icon_state = "buff"


/proc/prayer_is_undead(mob/living/L)
	return !!(L.mob_biotypes & MOB_UNDEAD)

/// Applies one clause to one target. Returns a feedback line or null.
/proc/prayer_apply(datum/prayer_clause/C, mob/living/target, mob/living/user, datum/domain/D)
	var/p = C.power
	var/dur = C.duration_mult
	var/mob/living/carbon/human/H = ishuman(target) ? target : null
	var/undead = prayer_is_undead(target)

	var/special = prayer_apply_special(C, target, user, D)
	if(special != FALSE)
		return special

	switch(C.intent)
		if("heal")
			// Holy healing burns the unholy.
			if(undead && user.patron?.undead_hater && !istype(D, /datum/domain/forbidden))
				target.adjustFireLoss(15 * p)
				return "Light sears [target]'s unliving flesh."
			switch(C.subject)
				if("burns")
					if(!target.getFireLoss())
						return null
					target.heal_overall_damage(0, 22 * p)
					return "[target]'s burns cool and close."
				if("bones")
					if(!target.heal_wounds(40 * p, list(/datum/wound/fracture)))
						return null
					return "[target]'s bones grind back into place."
				if("blood")
					return prayer_mend_blood(target, p)
				if("poison")
					return prayer_cleanse_poison(target, p)
				if("fever")
					return prayer_cleanse_fever(target, p)
				if("pain")
					return prayer_numb(target, p, dur)
				if("mind")
					return prayer_calm_mind(target, p)
				if("fatigue")
					target.energy_add(300 * p)
					return "Strength flows back into [target]'s limbs."
				if("eyes")
					return prayer_clear_eyes(target, p)
				if("hunger")
					target.adjust_nutrition(120 * p)
					return "[target]'s hunger fades."
				if("thirst")
					target.adjust_hydration(120 * p)
					return "[target]'s thirst fades."
				if("dead")
					return prayer_raise(target, user, p, D)
			if(!target.getBruteLoss() && !target.getFireLoss() && !length(target.get_wounds()))
				return null
			target.heal_overall_damage(20 * p, 10 * p)
			target.heal_wounds(20 * p)
			return "[target]'s wounds knit closed."

		if("cleanse")
			switch(C.subject)
				if("fever")
					return prayer_cleanse_fever(target, p)
				if("fire")
					return prayer_douse(target)
				if("mind")
					return prayer_calm_mind(target, p)
				if("undead", "darkness")
					if(undead)
						target.adjustFireLoss(22 * p)
						return "The corruption in [target] burns away - and so does [target]."
					return prayer_calm_mind(target, p * 0.5)
				if("blood")
					return prayer_cleanse_poison(target, p) || prayer_mend_blood(target, p * 0.5)
				if("eyes")
					return prayer_clear_eyes(target, p)
			return prayer_cleanse_poison(target, p)

		if("shield")
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/ward, (45 SECONDS) * p * dur, list(STATKEY_CON = clamp(round(1 + p), 1, 3), STATKEY_WIL = 1))
			if(p >= 1.2)
				target.apply_status_effect(/datum/status_effect/buff/fortify)
			return "A god's hand settles over [target]."

		if("smite")
			if(target == user)
				target.adjustFireLoss(10 * p)
				return "I asked my god to strike, and it struck the one who asked."
			var/dmg = 24 * p
			if(undead && (C.subject == "undead" || user.patron?.undead_hater))
				dmg *= 2.5
			target.adjustFireLoss(dmg)
			if(p >= 1.4)
				target.adjust_fire_stacks(2, /datum/status_effect/fire_handler/fire_stacks/divine)
				target.ignite_mob()
			target.visible_message(span_danger("Divine wrath falls upon [target]!"))
			return "[target] is struck."

		if("calm")
			switch(C.subject)
				if("pain")
					return prayer_numb(target, p, dur)
				if("fire")
					return prayer_douse(target)
			return prayer_calm_mind(target, p)

		if("strengthen")
			if(C.subject == "fatigue")
				target.energy_add(300 * p)
				return "Fresh strength fills [target]."
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/strength, (1 MINUTES) * p * dur, list(STATKEY_STR = clamp(round(1 + p), 1, 3), STATKEY_CON = 1))
			return "[target] stands a little taller."

		if("quicken")
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/speed, (40 SECONDS) * p * dur, list(STATKEY_SPD = clamp(round(1 + p), 1, 3)))
			return "[target] moves as if the wind were at their back."

		if("weaken")
			if(C.subject == "fatigue")
				target.energy_add(-300 * p)
				return "[target] sags with sudden weariness."
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/bane, (45 SECONDS) * p * dur, list(STATKEY_STR = -clamp(round(1 + p), 1, 3), STATKEY_SPD = -1))
			return "[target]'s strength drains away."

		if("bind")
			if(C.subject == "blood")
				return prayer_mend_blood(target, p)
			target.Immobilize((2 SECONDS) + (3 SECONDS) * p * dur)
			target.visible_message(span_warning("[target] is held fast by an unseen hand!"))
			return "[target] is held."

		if("sleep")
			if(target == user)
				target.Sleeping((10 SECONDS) * p * dur)
				return "Sleep takes me."
			target.adjust_blurriness(4 * p)
			if(p >= 0.9)
				target.Sleeping((4 SECONDS) * p * dur)
				return "[target] slumps into sleep."
			return "[target]'s eyelids grow heavy."

		if("wake")
			target.SetSleeping(0)
			target.SetUnconscious(0)
			target.energy_add(100 * p)
			return "[target] stirs."

		if("feed")
			if(C.subject == "thirst")
				target.adjust_hydration(150 * p)
				return "[target]'s thirst is slaked."
			target.adjust_nutrition(150 * p)
			return "[target]'s belly feels full."

		if("quench")
			if(C.subject == "fire")
				return prayer_douse(target)
			target.adjust_hydration(150 * p)
			return "[target]'s thirst is slaked."

		if("warm")
			if(target.bodytemperature >= BODYTEMP_NORMAL)
				return null
			target.adjust_bodytemperature(min(BODYTEMP_NORMAL - target.bodytemperature, 15 * p))
			return "Warmth spreads through [target]."

		if("cool")
			if(C.subject == "fire" || target.fire_stacks > 0 || target.on_fire)
				return prayer_douse(target)
			if(target.bodytemperature <= BODYTEMP_NORMAL)
				return null
			target.adjust_bodytemperature(-min(target.bodytemperature - BODYTEMP_NORMAL, 15 * p))
			return "[target] cools."

		if("light")
			target.mob_light(_color = "#fff4d0", _range = 3 + round(p * 2), _power = 1, _duration = (1 MINUTES) * p * dur)
			return "Light gathers around [target]."

		if("reveal")
			if(C.subject == "darkness")
				target.mob_light(_color = "#e8f0ff", _range = 4 + round(p * 2), _power = 1, _duration = (40 SECONDS) * p * dur)
				return "The shadows around [target] draw back."
			return prayer_clear_eyes(target, p) || "Nothing was hidden from [target]'s eyes."

		if("blind")
			target.adjust_blindness(3 * p * dur)
			target.adjust_blurriness(6 * p * dur)
			return "Darkness closes over [target]'s eyes."

		if("silence")
			if(!H)
				return null
			H.silent = max(H.silent, round(8 * p * dur))
			return "[target]'s voice is taken."

		if("bless")
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/fortune, (3 MINUTES) * p * dur, list(STATKEY_LCK = clamp(round(1 + p), 1, 3)))
			target.add_stress(/datum/stressevent/blessed)
			return "[target] is blessed."

		if("curse")
			target.apply_status_effect(/datum/status_effect/buff/prayer_boon/curse, (2 MINUTES) * p * dur, list(STATKEY_LCK = -clamp(round(1 + p), 1, 3), STATKEY_WIL = -1))
			target.add_stress(/datum/stressevent/psycurse)
			return "[target] is cursed."

		if("raise")
			return prayer_raise(target, user, p, D)
		else
			return prayer_apply_ext(C, target, user, D)
	return null

/proc/prayer_mend_blood(mob/living/target, p)
	var/did = FALSE
	for(var/datum/wound/W as anything in target.get_wounds())
		if(W?.bleed_rate > 0)
			W.set_bleed_rate(p >= 0.8 ? 0 : W.bleed_rate / 2)
			did = TRUE
	if(target.blood_volume < BLOOD_VOLUME_NORMAL)
		target.blood_volume = min(BLOOD_VOLUME_NORMAL, target.blood_volume + 60 * p)
		did = TRUE
	return did ? "[target]'s bleeding slows and their colour returns." : null

/proc/prayer_cleanse_poison(mob/living/target, p)
	var/did = FALSE
	if(target.getToxLoss())
		target.adjustToxLoss(-20 * p)
		did = TRUE
	if(target.reagents)
		for(var/datum/reagent/R as anything in target.reagents.reagent_list)
			if(istype(R, /datum/reagent/toxin))
				target.reagents.remove_reagent(R.type, 10 * p)
				did = TRUE
	return did ? "The poison in [target] thins and fades." : null

/proc/prayer_cleanse_fever(mob/living/target, p)
	var/did = FALSE
	var/budget = max(1, round(p * 2))
	if(iscarbon(target))
		var/mob/living/carbon/Cb = target
		for(var/obj/item/organ/O as anything in Cb.internal_organs)
			for(var/datum/internal_wound/IW as anything in O.internal_wounds.Copy())
				if(budget <= 0)
					break
				if(istype(IW, /datum/internal_wound/organic/infection) || istype(IW, /datum/internal_wound/organic/poisoning) || istype(IW, /datum/internal_wound/organic/necrosis_start))
					O.remove_internal_wound(IW)
					budget--
					did = TRUE
	if(target.getToxLoss())
		target.adjustToxLoss(-10 * p)
		did = TRUE
	return did ? "The sickness in [target] breaks." : null

/proc/prayer_numb(mob/living/target, p, dur)
	ADD_TRAIT(target, TRAIT_NOPAIN, "prayer")
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_NOPAIN, "prayer"), (20 SECONDS) * p * dur)
	return "[target]'s pain goes quiet."

/proc/prayer_calm_mind(mob/living/target, p)
	var/did = FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.sanity)
			H.sanity.changeLevel(15 * p)
			did = TRUE
	if(target.get_stress_amount() > 0)
		target.add_stress(/datum/stressevent/psyprayer)
		did = TRUE
	return did ? "[target]'s mind grows still." : null

/proc/prayer_clear_eyes(mob/living/target, p)
	if(!target.eye_blind && !target.eye_blurry)
		return null
	target.adjust_blindness(-10 * p)
	target.adjust_blurriness(-20 * p)
	return "[target]'s sight clears."

/proc/prayer_douse(mob/living/target)
	if(target.fire_stacks <= 0 && !target.on_fire)
		return null
	target.extinguish_mob()
	return "The flames on [target] die."

/// The heaviest request. Only a strong prayer, to a willing god, on a body
/// that can still hold a soul.
/proc/prayer_raise(mob/living/target, mob/living/user, p, datum/domain/D)
	if(target.stat != DEAD)
		return null
	if(p < 1.3)
		return "I feel the god consider it, and turn away. I did not ask with enough."
	if(target.getBruteLoss() + target.getFireLoss() > 250)
		return "There is too little left of [target] to return to."
	if(ishuman(target) && !target.getorganslot(ORGAN_SLOT_BRAIN))
		return "There is nothing of [target] left for a soul to return to."
	target.revive(full_heal = FALSE)
	target.heal_overall_damage(40, 40)
	user.adjustBruteLoss(25)
	user.visible_message(span_boldnotice("[target] draws a shuddering breath!"))
	return "[target] returns."
