// Body temperature effects, on one ladder that matches the HUD indicator:
//   very cold < 150 < cold < 250 < normal < 350 < hot < 450 < very hot
// Cold and heat are uncomfortable first (hunger/thirst, shivering/sweating),
// then dangerous with prolonged exposure (hypothermia / heat exhaustion), and
// only deal damage at the true extremes.

#define TEMPERATURE_FROSTBITE_LIMIT 100
#define TEMPERATURE_SCORCH_LIMIT 500
#define TEMPERATURE_WARN_DELAY (20 SECONDS)
#define TEMPERATURE_AFFLICTION_DELAY (2 MINUTES)

/mob/living/carbon/human
	/// Tier from the last environment tick, to notice when it changes.
	var/last_temperature_state = TEMP_STATE_NORMAL

/// Temperature tier from body temperature. Works for NPCs and without a HUD.
/mob/living/carbon/human/get_temperature_state()
	if(bodytemperature < BODYTEMP_COLD_LEVEL_ONE_MAX)
		return TEMP_STATE_VERY_COLD
	if(bodytemperature < BODYTEMP_NORMAL_MIN)
		return TEMP_STATE_COLD
	if(bodytemperature <= BODYTEMP_NORMAL_MAX)
		return TEMP_STATE_NORMAL
	if(bodytemperature < BODYTEMP_HEAT_LEVEL_ONE_MAX)
		return TEMP_STATE_HOT
	return TEMP_STATE_VERY_HOT

/// Called every environment tick from species/handle_environment().
/mob/living/carbon/human/proc/handle_temperature_effects(heat_mult = 1, cold_mult = 1)
	var/state = get_temperature_state()
	if(state < TEMP_STATE_NORMAL && HAS_TRAIT(src, TRAIT_RESISTCOLD))
		state = TEMP_STATE_NORMAL
	if(state > TEMP_STATE_NORMAL && HAS_TRAIT(src, TRAIT_RESISTHEAT))
		state = TEMP_STATE_NORMAL

	if(state != last_temperature_state)
		on_temperature_state_changed(last_temperature_state, state)
		last_temperature_state = state

	if(stat == DEAD)
		return

	switch(state)
		if(TEMP_STATE_VERY_COLD)
			adjust_nutrition(-0.2)
			add_movespeed_modifier(MOVESPEED_ID_COLD, override = TRUE, multiplicative_slowdown = (BODYTEMP_NORMAL_MIN - bodytemperature) / (COLD_SLOWDOWN_FACTOR * 5), blacklisted_movetypes = FLOATING)
			if(prob(8))
				emote("shiver")
			if(bodytemperature < TEMPERATURE_FROSTBITE_LIMIT)
				apply_damage(COLD_DAMAGE_LEVEL_1 * cold_mult * physiology.cold_mod, BURN, spread_damage = TRUE)
		if(TEMP_STATE_COLD)
			remove_movespeed_modifier(MOVESPEED_ID_COLD)
			adjust_nutrition(-0.1)
			if(prob(3))
				emote("shiver")
		if(TEMP_STATE_NORMAL)
			remove_movespeed_modifier(MOVESPEED_ID_COLD)
		if(TEMP_STATE_HOT)
			remove_movespeed_modifier(MOVESPEED_ID_COLD)
			adjust_hydration(-0.1)
			if(prob(3))
				to_chat(src, span_warning("Sweat runs down my back."))
		if(TEMP_STATE_VERY_HOT)
			remove_movespeed_modifier(MOVESPEED_ID_COLD)
			adjust_hydration(-0.2)
			energy_add(-2)
			if(bodytemperature > TEMPERATURE_SCORCH_LIMIT)
				var/burn = round(max(log(2, bodytemperature - BODYTEMP_NORMAL) - 5, 0)) * heat_mult * physiology.heat_mod
				if(HAS_TRAIT(src, TRAIT_FIRE_RESIST))
					burn *= 0.5
				apply_damage(burn, BURN, spread_damage = TRUE)

/mob/living/carbon/human/proc/on_temperature_state_changed(old_state, new_state)
	// Cancel whatever the old tier had pending.
	if(hypothermia_timer_id && new_state != TEMP_STATE_VERY_COLD)
		deltimer(hypothermia_timer_id)
		hypothermia_timer_id = null
	if(heatstroke_timer_id && new_state != TEMP_STATE_VERY_HOT)
		deltimer(heatstroke_timer_id)
		heatstroke_timer_id = null

	switch(new_state)
		if(TEMP_STATE_NORMAL)
			clear_alert("temp")
			if(old_state < TEMP_STATE_NORMAL)
				to_chat(src, span_notice("Warmth returns to my limbs."))
			else
				to_chat(src, span_notice("I've cooled down."))
		if(TEMP_STATE_COLD, TEMP_STATE_VERY_COLD)
			addtimer(CALLBACK(src, PROC_REF(cold_warn)), TEMPERATURE_WARN_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)
			relieve_heatstroke_from_cold()
			if(new_state == TEMP_STATE_VERY_COLD && !hypothermia_timer_id)
				hypothermia_timer_id = addtimer(CALLBACK(src, PROC_REF(apply_hypothermia)), TEMPERATURE_AFFLICTION_DELAY, TIMER_STOPPABLE)
		if(TEMP_STATE_HOT, TEMP_STATE_VERY_HOT)
			addtimer(CALLBACK(src, PROC_REF(heat_warn)), TEMPERATURE_WARN_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)
			if(new_state == TEMP_STATE_VERY_HOT && !heatstroke_timer_id)
				heatstroke_timer_id = addtimer(CALLBACK(src, PROC_REF(apply_heatexhaust)), TEMPERATURE_AFFLICTION_DELAY, TIMER_STOPPABLE)

#undef TEMPERATURE_FROSTBITE_LIMIT
#undef TEMPERATURE_SCORCH_LIMIT
#undef TEMPERATURE_WARN_DELAY
#undef TEMPERATURE_AFFLICTION_DELAY

// --- What the air around you actually feels like ------------------------
// Tiles used to sit at a flat 20C all year. Now season, time of day, shelter,
// water, fires and weather all set the temperature a body reacts to.

/// Kelvin, by season, for open air at midday.
/proc/season_outdoor_temperature()
	switch(SSseason?.current_season)
		if(SEASON_WINTER)
			return T0C - 20
		if(SEASON_AUTUMN)
			return T0C + 2
		if(SEASON_SPRING)
			return T0C + 10
		if(SEASON_SUMMER)
			return T0C + 27
	return T20C

/turf/proc/get_ambient_temperature()
	var/area/A = get_area(src)
	var/ambient
	if(istype(A, /area/rogue/under))
		ambient = T0C + 10 // caves and cellars hold a steady cool
	else
		ambient = season_outdoor_temperature()
		if(GLOB.tod == "night")
			ambient -= 8
		if(!A?.outdoors)
			// Walls and a roof take the edge off either way.
			ambient = T20C + (ambient - T20C) * 0.4
	if(istype(src, /turf/open/water))
		ambient -= 15
	var/turf/open/floor/F = src
	if(istype(F) && F.heat)
		ambient += min(F.heat * 8, 45)
	// Weather chill is kept as a drop below 20C on the tile itself.
	if(temperature < T20C)
		ambient -= (T20C - temperature)
	return ambient
