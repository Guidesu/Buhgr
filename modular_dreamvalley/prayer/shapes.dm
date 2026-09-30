#define PRESET_KIND_PRAYER "prayer"
#define PRESET_KIND_INCANTATION "incantation"

// Prayer shapes. The words decide what a prayer does; the shape decides how it
// reaches the world - laid on one person, on yourself, cast as a bolt of light,
// breaking around you, falling on a place, or lingering there. Every shape runs
// the same prayer; the wider or quicker ones are weaker or cost more.

#define PRAYER_SHAPE_TARGETED "targeted"
#define PRAYER_SHAPE_SELF "self"
#define PRAYER_SHAPE_PROJECTILE "projectile"
#define PRAYER_SHAPE_BURST "burst"
#define PRAYER_SHAPE_AREA "area"
#define PRAYER_SHAPE_FIELD "field"
#define PRAYER_SHAPE_CONE "cone"
#define PRAYER_SHAPE_BEAM "beam"

/// shape = list(name, power, cost, time, clicks, desc)
GLOBAL_LIST_INIT(prayer_shapes, list(
	PRAYER_SHAPE_TARGETED = list("name" = "Laid on one", "range" = 4, "power" = 1, "cost" = 1, "time" = 1, "clicks" = TRUE,
		"desc" = "Click someone close by. The prayer falls on them alone."),
	PRAYER_SHAPE_SELF = list("name" = "Upon myself", "range" = 1, "power" = 1, "cost" = 0.9, "time" = 0.8, "clicks" = FALSE,
		"desc" = "No aiming: the prayer falls on you. A little cheaper and quicker."),
	PRAYER_SHAPE_PROJECTILE = list("name" = "Bolt of light", "range" = 7, "power" = 0.8, "cost" = 1.1, "time" = 0.5, "clicks" = TRUE,
		"desc" = "Click anywhere to cast the prayer as a bolt. Whoever it strikes receives it - healing, harm or anything else. Quick to say, a little weaker."),
	PRAYER_SHAPE_BURST = list("name" = "Burst around me", "range" = 1, "power" = 0.6, "cost" = 1.6, "time" = 1, "clicks" = FALSE,
		"desc" = "No aiming: the prayer breaks out around you, two steps wide. Harmful requests spare you."),
	PRAYER_SHAPE_AREA = list("name" = "Fall upon a place", "range" = 6, "power" = 0.6, "cost" = 1.8, "time" = 1.1, "clicks" = TRUE,
		"desc" = "Click a place you can see: the prayer falls on everyone within two steps of it."),
	PRAYER_SHAPE_FIELD = list("name" = "Lingering circle", "range" = 6, "power" = 0.35, "cost" = 2.2, "time" = 1.2, "clicks" = TRUE,
		"desc" = "Click a place: a circle stays there for a while, answering the prayer again every few seconds for whoever stands in it."),
	PRAYER_SHAPE_CONE = list("name" = "Fan before me", "range" = 4, "power" = 0.7, "cost" = 1.5, "time" = 0.8, "clicks" = TRUE,
		"desc" = "Click a direction: the prayer sweeps out in a widening fan three steps long. Harmful requests spare you."),
	PRAYER_SHAPE_BEAM = list("name" = "Line of light", "range" = 7, "power" = 0.75, "cost" = 1.4, "time" = 0.7, "clicks" = TRUE,
		"desc" = "Click a direction: a straight line of light seven steps long. Everyone it passes through receives the prayer."),
))

/// Requests that should never be turned on the one praying when cast wide.
GLOBAL_LIST_INIT(prayer_harmful_intents, list("smite", "banish", "curse", "weaken", "bind", "blind", "silence", "sleep",
	"frighten", "madden", "sicken", "rot", "disarm", "fell", "repel", "draw"))

/proc/prayer_shape_value(shape, key)
	var/list/info = GLOB.prayer_shapes[shape] || GLOB.prayer_shapes[PRAYER_SHAPE_TARGETED]
	return info[key]

/// Shapes that pick their own targets instead of the one clicked.
/proc/prayer_shape_delivers(shape)
	return shape in list(PRAYER_SHAPE_PROJECTILE, PRAYER_SHAPE_BURST, PRAYER_SHAPE_AREA, PRAYER_SHAPE_FIELD, PRAYER_SHAPE_CONE, PRAYER_SHAPE_BEAM)

/// Sends the answered requests out in the given shape. Takes ownership of R.
/// Returns a line for the supplicant.
/proc/prayer_shape_release(shape, list/clauses, datum/prayer_reading/R, mob/living/user, atom/aim, datum/domain/D, arc = FALSE)
	var/datum/prayer_delivery/delivery = new(clauses, R, user, D)
	var/colour = D?.colour || "#fff1b8"
	var/turf/aim_turf = get_turf(aim) || get_turf(user)
	switch(shape)
		if(PRAYER_SHAPE_PROJECTILE)
			var/obj/projectile/prayer_bolt/bolt = new(get_turf(user))
			bolt.delivery = delivery
			bolt.color = colour
			bolt.firer = user
			bolt.fired_from = get_turf(user)
			bolt.def_zone = user.zone_selected
			bolt.arcshot = arc
			bolt.preparePixelProjectile(aim_turf, user)
			bolt.fire()
			return "My prayer leaves my hands as a bolt of light."
		if(PRAYER_SHAPE_BURST, PRAYER_SHAPE_AREA)
			var/turf/centre = shape == PRAYER_SHAPE_BURST ? get_turf(user) : aim_turf
			prayer_burst(centre, "big:sunburst", colour)
			var/list/caught = list()
			for(var/mob/living/L in view(2, centre))
				caught += L
			var/list/lines = delivery.apply_to(caught, 1)
			qdel(delivery)
			if(!length(lines))
				return "My prayer breaks over the ground, and finds no one there to answer."
			return jointext(lines, " ")
		if(PRAYER_SHAPE_CONE, PRAYER_SHAPE_BEAM)
			var/turf/start = get_turf(user)
			var/list/caught = list()
			if(shape == PRAYER_SHAPE_BEAM)
				var/turf/far = aim_turf
				if(far == start)
					far = get_step(start, user.dir)
				var/angle = Get_Angle(start, far)
				far = get_turf_in_angle(angle, start, 7)
				for(var/turf/T in getline(start, far))
					if(T != start && T.density)
						break
					if(T != start)
						prayer_burst(T, "sparkle", colour)
					for(var/mob/living/L in T)
						caught += L
			else
				var/facing = aim_turf == start ? dir2angle(user.dir) : Get_Angle(start, aim_turf)
				for(var/turf/T in view(3, start))
					if(T == start)
						continue
					var/diff = abs(closer_angle_difference(facing, Get_Angle(start, T)))
					if(diff > 45)
						continue
					prayer_burst(T, "sparkle", colour)
					for(var/mob/living/L in T)
						caught += L
			var/list/lines = delivery.apply_to(caught, 1)
			qdel(delivery)
			if(!length(lines))
				return "My prayer sweeps out before me, and finds no one there to answer."
			return jointext(lines, " ")
		if(PRAYER_SHAPE_FIELD)
			var/best = 0
			for(var/datum/prayer_clause/C as anything in clauses)
				best = max(best, C.power)
			new /obj/effect/prayer_field(aim_turf, delivery, (8 SECONDS) + (8 SECONDS) * best, colour)
			return "Where I prayed, a circle of light settles on the ground and stays."
	qdel(delivery)

/// Answered requests waiting to land on someone.
/datum/prayer_delivery
	var/list/clauses
	var/datum/prayer_reading/reading
	var/mob/living/user
	var/datum/domain/domain

/datum/prayer_delivery/New(list/clauses, datum/prayer_reading/R, mob/living/user, datum/domain/D)
	src.clauses = clauses
	reading = R
	src.user = user
	domain = D

/datum/prayer_delivery/Destroy()
	clauses = null
	QDEL_NULL(reading)
	user = null
	domain = null
	return ..()

/// Applies every request to each target at the given share of its strength.
/datum/prayer_delivery/proc/apply_to(list/targets, mult = 1)
	. = list()
	if(QDELETED(user))
		return
	for(var/datum/prayer_clause/C as anything in clauses)
		var/full = C.power
		C.power = full * mult
		for(var/mob/living/T as anything in targets)
			if(QDELETED(T))
				continue
			if(T == user && (C.intent in GLOB.prayer_harmful_intents))
				continue
			var/line = prayer_apply_resisted(C, T, user, domain)
			if(line)
				. += line
				prayer_visual(T, C.intent, C.power, user)
		C.power = full

// --- The bolt ---------------------------------------------------------------

/obj/projectile/prayer_bolt
	name = "prayer"
	icon = 'icons/effects/prayer_fx.dmi'
	icon_state = "holy_glyph"
	damage = 0
	nodamage = TRUE
	damage_type = BURN
	speed = 1
	range = 12
	light_outer_range = 3
	light_color = "#fff1b8"
	hitsound = null
	var/datum/prayer_delivery/delivery

/obj/projectile/prayer_bolt/Destroy()
	QDEL_NULL(delivery)
	return ..()

/obj/projectile/prayer_bolt/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!delivery)
		return
	var/turf/T = get_turf(target)
	prayer_burst(T, "sparkle", color)
	if(isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check())
			visible_message(span_warning("[src] fades harmlessly against [L]!"))
		else
			var/list/lines = delivery.apply_to(list(L), 1)
			if(length(lines) && delivery.user)
				to_chat(delivery.user, "<i>[jointext(lines, " ")]</i>")
	QDEL_NULL(delivery)

// --- The lingering circle ---------------------------------------------------

/obj/effect/prayer_field
	name = "circle of prayer"
	desc = "A ring of pale light on the ground. The air inside it feels listened to."
	icon = 'icons/effects/prayer_fx_64.dmi'
	icon_state = "rune_circle"
	pixel_x = -16
	pixel_y = -16
	alpha = 170
	anchored = TRUE
	layer = TURF_LAYER + 0.1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/prayer_delivery/delivery
	var/next_pulse = 0

/obj/effect/prayer_field/Initialize(mapload, datum/prayer_delivery/new_delivery, duration = 10 SECONDS, colour = "#fff1b8")
	. = ..()
	delivery = new_delivery
	color = colour
	set_light(2, 2, 1, l_color = colour)
	START_PROCESSING(SSobj, src)
	QDEL_IN(src, duration)

/obj/effect/prayer_field/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(delivery)
	return ..()

/obj/effect/prayer_field/process()
	if(!delivery || world.time < next_pulse)
		return
	next_pulse = world.time + 3 SECONDS
	var/list/inside = list()
	for(var/mob/living/L in range(1, src))
		inside += L
	if(length(inside))
		delivery.apply_to(inside, 1)

// --- Holy things lighten the asking ------------------------------------------

/// How much a prayer's devotion cost is eased by holy things worn or held.
/// Returns list(multiplier, list of reasons).
/proc/prayer_cost_relief(mob/living/carbon/human/user)
	var/relief = 0
	var/list/why = list()
	if(!istype(user))
		return list(1, why)
	if(istype(user.wear_neck, /obj/item/clothing/neck/roguetown/psicross))
		relief += 0.15
		why += "the amulet at my neck"
	var/held_symbol = FALSE
	var/held_book = FALSE
	for(var/obj/item/I in user.held_items)
		if(istype(I, /obj/item/clothing/neck/roguetown/psicross))
			held_symbol = TRUE
		else if(istype(I, /obj/item/book/rogue/bibble))
			held_book = TRUE
	if(held_symbol)
		relief += 0.1
		why += "the holy symbol in my hand"
	if(held_book)
		relief += 0.1
		why += "the holy book I hold"
	if(prayer_amulet_fits_domain(user.wear_neck, user.divine_domain))
		relief += 0.05
		why += "a sign of my own domain"
	return list(1 - min(relief, 0.35), why)

// --- Willpower against hostile prayer ----------------------------------------

/// Applies a request to a target, letting a strong-willed target shrug off or
/// blunt a harmful one aimed at them by someone else.
/proc/prayer_apply_resisted(datum/prayer_clause/C, mob/living/target, mob/living/user, datum/domain/D)
	if(target == user || !(C.intent in GLOB.prayer_harmful_intents))
		return prayer_apply(C, target, user, D)
	var/will = target.get_stat(STAT_WILLPOWER)
	var/edge = will - 10
	if(edge > 0)
		// A strong enough prayer overpowers even a strong will.
		var/negate = clamp(edge * 6 - (C.power - 1) * 25, 0, 60)
		if(prob(negate))
			to_chat(target, span_notice("Something presses on my soul, and I refuse it. It breaks against my will."))
			prayer_word(target, "RESISTED", "#c8c8ff")
			return "<span style='color:#a89a86'>[target] sets their will against my prayer, and it breaks on them.</span>"
	var/full = C.power
	C.power = full * clamp(1 - edge * 0.04, 0.6, 1.2)
	. = prayer_apply(C, target, user, D)
	C.power = full

/// Whether an amulet belongs to one of the domain's gods (or to all of them).
/proc/prayer_amulet_fits_domain(obj/item/amulet, datum/domain/D)
	if(!D || !istype(amulet, /obj/item/clothing/neck/roguetown/psicross))
		return FALSE
	var/list/parts = splittext("[amulet.type]", "/psicross/")
	if(length(parts) < 2)
		return FALSE
	var/god_key = splittext(parts[2], "/")[1]
	if(god_key == "undivided")
		return TRUE
	for(var/god_path in D.gods)
		var/list/segments = splittext("[god_path]", "/")
		if(segments[length(segments)] == god_key)
			return TRUE
	return FALSE
