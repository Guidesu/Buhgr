// Refuse heaps, after CEV-Eris's junk piles: scattered through cellars,
// sewers, caves and back alleys. Anyone can rummage through one for scraps,
// the odd useful find, and now and then an oddity. Heaps run dry after a few
// searches, and new ones keep turning up elsewhere.

#define JUNK_PILE_TARGET_COUNT 40
#define JUNK_PILE_ODDITY_CHANCE 3

/obj/structure/junk_pile
	name = "refuse heap"
	desc = "A reeking pile of rags, bones, broken crockery and worse. Someone might have thrown away something worth having."
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE
	layer = OBJ_LAYER
	/// How many more times it can be searched before it's picked clean.
	var/searches_left
	var/searching = FALSE

/obj/structure/junk_pile/Initialize(mapload)
	. = ..()
	searches_left = rand(3, 6)
	build_heap_appearance()

/// No heap sprite exists, so draw one from a jumble of scrap sprites.
/obj/structure/junk_pile/proc/build_heap_appearance()
	var/static/list/scraps = list(
		/obj/item/natural/bone,
		/obj/item/natural/cloth,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/natural/stone,
		/obj/item/grown/log/tree/stick,
		/obj/item/natural/fibers,
		/obj/item/natural/glass_shard,
	)
	cut_overlays()
	for(var/i in 1 to rand(5, 8))
		var/obj/item/scrap_type = pick(scraps)
		var/mutable_appearance/bit = mutable_appearance(initial(scrap_type.icon), initial(scrap_type.icon_state))
		bit.pixel_x = rand(-8, 8)
		bit.pixel_y = rand(-8, 4)
		bit.transform = matrix().Turn(rand(0, 359))
		add_overlay(bit)

/obj/structure/junk_pile/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	search(user, 5 SECONDS)

/obj/structure/junk_pile/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/rogueweapon/shovel))
		search(user, 2 SECONDS)
		return TRUE
	return ..()

/obj/structure/junk_pile/proc/search(mob/living/user, base_time)
	if(searching || !isliving(user))
		return
	searching = TRUE
	user.visible_message(span_notice("[user] starts rummaging through [src]."), span_notice("I start rummaging through [src]."))
	var/time = base_time / max(0.5, user.get_stat_speed(STATKEY_PER))
	if(!do_after(user, time, target = src))
		searching = FALSE
		return
	searching = FALSE

	// Refuse bites back sometimes.
	if(prob(8) && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/bodypart/hand = H.get_bodypart(H.active_hand_index == 1 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
		if(hand)
			to_chat(user, span_warning("Something sharp in the heap slices my hand!"))
			H.apply_damage(4, BRUTE, hand)
	if(prob(5))
		new /mob/living/simple_animal/hostile/retaliate/rogue/bigrat(get_turf(src))
		to_chat(user, span_danger("A rat bursts out of the heap!"))

	var/obj/item/found = roll_find(get_turf(src))
	if(found)
		to_chat(user, span_notice("I dig out [found]."))
		user.put_in_hands(found)
	else
		to_chat(user, span_notice("Nothing but rot and filth."))

	searches_left--
	if(searches_left <= 0)
		visible_message(span_notice("[src] is picked clean and scattered."))
		qdel(src)
	else
		build_heap_appearance()

/obj/structure/junk_pile/proc/roll_find(turf/T)
	if(prob(JUNK_PILE_ODDITY_CHANCE))
		var/oddity_type = pick(subtypesof(/obj/item/oddity))
		return new oddity_type(T)
	var/static/list/finds = list(
		"nothing" = 30,
		/obj/item/natural/bone = 12,
		/obj/item/natural/cloth = 12,
		/obj/item/natural/fibers = 10,
		/obj/item/grown/log/tree/stick = 8,
		/obj/item/natural/stone = 8,
		/obj/item/natural/glass_shard = 6,
		/obj/item/reagent_containers/glass/bottle = 6,
		/obj/item/reagent_containers/glass/cup = 4,
		/obj/item/natural/feather = 4,
		/obj/item/paper = 4,
		/obj/item/natural/worms = 4,
		/obj/item/rope = 3,
		/obj/item/candle/yellow = 3,
		/obj/item/roguecoin/copper = 5,
		/obj/item/needle = 2,
		/obj/item/natural/hide = 2,
		/obj/item/rogueore/iron = 2,
		/obj/item/clothing/mask/cigarette/pipe = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/roguecoin/silver = 1,
		/obj/item/ingot/iron = 1,
	)
	var/find_type = pickweight(finds)
	if(!ispath(find_type))
		return null
	return new find_type(T)

// --- Keeping heaps in the world -----------------------------------------

SUBSYSTEM_DEF(junk_piles)
	name = "Refuse Heaps"
	wait = 10 MINUTES
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/junk_piles/Initialize()
	top_up()
	return ..()

/datum/controller/subsystem/junk_piles/fire(resumed)
	top_up()

/datum/controller/subsystem/junk_piles/proc/top_up()
	var/existing = 0
	for(var/obj/structure/junk_pile/pile in world)
		existing++
	var/missing = JUNK_PILE_TARGET_COUNT - existing
	for(var/attempt in 1 to missing * 40)
		if(missing <= 0)
			break
		var/turf/T = locate(rand(1, world.maxx), rand(1, world.maxy), rand(2, world.maxz))
		if(!is_good_spot(T))
			continue
		new /obj/structure/junk_pile(T)
		missing--

/// Out-of-the-way ground: cellars, sewers, caves, and town/settlement outskirts.
/datum/controller/subsystem/junk_piles/proc/is_good_spot(turf/T)
	if(!isfloorturf(T) || istype(T, /turf/open/water) || T.density)
		return FALSE
	var/area/A = get_area(T)
	if(!is_type_in_list(A, list(/area/rogue/under, /area/rogue/outdoors/byos, /area/rogue/outdoors/town)))
		return FALSE
	for(var/atom/movable/AM in T)
		if(AM.density || istype(AM, /obj/structure))
			return FALSE
	for(var/mob/living/carbon/human/H in view(5, T))
		if(H.client)
			return FALSE
	return TRUE

#undef JUNK_PILE_TARGET_COUNT
#undef JUNK_PILE_ODDITY_CHANCE
