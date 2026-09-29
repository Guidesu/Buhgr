// What restores sanity and completes rest, the way CEV-Eris plays:
// company, a meal, a drink, prayer, music and a smoke all ease the mind.
// When insight fills up, the character gains two desires; indulging them
// (and much more slowly, anything else) fills their rest, and a full rest
// lets them turn that insight into a stat.

#define SANITY_GAIN_FOOD 2
#define SANITY_GAIN_ALCOHOL 0.3
#define SANITY_GAIN_PRAYER 3
#define SANITY_GAIN_MUSIC 0.4
#define SANITY_GAIN_SMOKE_TICK 0.2

#define REST_FOOD 25
#define REST_ALCOHOL 2
#define REST_PRAYER 30
#define REST_MUSIC 2
#define REST_SMOKE 2

/datum/sanity
	var/pray_time = 0

/datum/sanity/New(mob/living/carbon/human/H)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(on_owner_say))

/datum/sanity/Destroy()
	if(owner)
		UnregisterSignal(owner, COMSIG_MOB_SAY)
	return ..()

/// Insight builds from how much sanity moves, up or down (Eris counts both).
/datum/sanity/changeLevel(delta)
	var/old_level = level
	var/old_change = level_change
	..()
	level_change = old_change + abs(level - old_level)

/datum/sanity/onLife()
	..()
	if(owner && owner.stat != DEAD && level <= 0)
		check_breakdown()

/// Talking to someone who can hear you. Talking to yourself doesn't count.
/datum/sanity/proc/on_owner_say(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(world.time < say_time)
		return
	for(var/mob/living/carbon/human/listener in get_hearers_in_view(7, owner))
		if(listener == owner || listener.stat || !listener.client)
			continue
		say_time = world.time + SANITY_COOLDOWN_SAY
		changeLevel(SANITY_GAIN_SAY)
		return

/datum/sanity/proc/onEat()
	changeLevel(SANITY_GAIN_FOOD)
	add_rest(INSIGHT_DESIRE_FOOD, REST_FOOD)

/datum/sanity/proc/onAlcohol()
	changeLevel(SANITY_GAIN_ALCOHOL)
	add_rest(INSIGHT_DESIRE_ALCOHOL, REST_ALCOHOL)

/datum/sanity/proc/onPray()
	if(world.time < pray_time)
		return
	pray_time = world.time + 1 MINUTES
	changeLevel(SANITY_GAIN_PRAYER)
	add_rest(INSIGHT_DESIRE_PRAYER, REST_PRAYER)

/datum/sanity/proc/onMusic()
	changeLevel(SANITY_GAIN_MUSIC)
	add_rest(INSIGHT_DESIRE_MUSIC, REST_MUSIC)

/datum/sanity/proc/onSmoke()
	changeLevel(SANITY_GAIN_SMOKE_TICK)
	add_rest(INSIGHT_DESIRE_SMOKING, REST_SMOKE)

/// Rest only builds once there's insight to rest on.
/datum/sanity/add_rest(type, amount)
	if(resting <= 0)
		return
	return ..()

/datum/sanity/pick_desires()
	desires = list()
	var/list/candidates = list(
		INSIGHT_DESIRE_FOOD,
		INSIGHT_DESIRE_ALCOHOL,
		INSIGHT_DESIRE_PRAYER,
		INSIGHT_DESIRE_MUSIC,
		INSIGHT_DESIRE_SMOKING,
	)
	for(var/i in 1 to INSIGHT_DESIRE_COUNT)
		if(!length(candidates))
			break
		desires += pick_n_take(candidates)
	if(owner && length(desires))
		to_chat(owner, span_notice("I long for [english_list(get_desire_names())]. Indulging that would let me rest and reflect."))

/datum/sanity/proc/get_desire_names()
	var/static/list/names = list(
		INSIGHT_DESIRE_FOOD = "a good meal",
		INSIGHT_DESIRE_ALCOHOL = "a drink",
		INSIGHT_DESIRE_PRAYER = "prayer",
		INSIGHT_DESIRE_MUSIC = "music",
		INSIGHT_DESIRE_SMOKING = "a smoke",
		INSIGHT_DESIRE_DRUGS = "something stronger",
	)
	. = list()
	for(var/desire in desires)
		. += names[desire] || desire

/// Spending insight empties the rest stage too, so the next insight starts fresh.
/datum/sanity/level_up()
	..()
	resting = 0
	insight_rest = 0

// --- Hooks --------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/On_Consume(mob/living/eater)
	. = ..()
	var/mob/living/carbon/human/H = eater
	if(istype(H) && H.sanity)
		H.sanity.onEat()

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/carbon/M)
	var/mob/living/carbon/human/H = M
	if(istype(H) && H.sanity)
		H.sanity.onAlcohol()
	return ..()

/datum/emote/living/pray/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(istype(H) && H.sanity)
		H.sanity.onPray()

/datum/status_effect/buff/playing_music/tick()
	. = ..()
	if(!owner)
		return
	for(var/mob/living/carbon/human/listener in get_hearers_in_view(7, owner))
		if(listener.sanity && !listener.stat)
			listener.sanity.onMusic()

/obj/item/clothing/mask/cigarette/process()
	var/mob/living/carbon/human/H = loc
	if(istype(H) && H.wear_mask == src && H.sanity)
		H.sanity.onSmoke()
	return ..()

#undef SANITY_GAIN_FOOD
#undef SANITY_GAIN_ALCOHOL
#undef SANITY_GAIN_PRAYER
#undef SANITY_GAIN_MUSIC
#undef SANITY_GAIN_SMOKE_TICK
#undef REST_FOOD
#undef REST_ALCOHOL
#undef REST_PRAYER
#undef REST_MUSIC
#undef REST_SMOKE
