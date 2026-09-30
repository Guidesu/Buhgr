// Divine domains. On Palimpseste no god made the world: gods are belief given
// form, and many of them answer for the same things. What a character picks is a
// domain (which decides their miracles and devotion traits) and then a god who
// holds it, either one of the known gods listed under it or one they write
// themselves. The chosen god still sets the character's patron, so everything
// that cares about a specific god keeps working.

GLOBAL_LIST_INIT(divine_domains, init_divine_domains())

/proc/init_divine_domains()
	. = list()
	for(var/path in subtypesof(/datum/domain))
		var/datum/domain/D = new path()
		if(D.name)
			.[path] = D
	// Gods can also name their own domains (see /datum/patron/var/dv_domains).
	for(var/patron_path in subtypesof(/datum/patron))
		var/datum/patron/P = GLOB.patronlist[patron_path] || new patron_path()
		var/list/claimed = P.dv_domains
		if(!islist(claimed))
			continue
		for(var/domain_path in claimed)
			var/datum/domain/D = .[domain_path]
			if(D)
				D.gods |= patron_path

/datum/patron
	/// Domains this god belongs to, as /datum/domain types.
	var/list/dv_domains

/proc/get_divine_domain(path)
	if(istype(path, /datum/domain))
		return path
	return GLOB.divine_domains[path]

/datum/domain
	var/name
	var/desc
	/// Font Awesome icon for menus.
	var/icon = "star"
	/// Known gods who hold this domain, as patron types. The first is shown first.
	var/list/gods = list()
	/// Miracles granted by devotion, type = CLERIC tier. Replaces the god's own list.
	var/list/miracles = list()
	/// Traits unlocked by devotion tier, added on top of the god's own.
	var/list/traits_tier = list()
	/// Shown to worshippers of a god of their own when they can't pray.
	var/pray_hint = "a holy object"

/datum/domain/proc/holds_god(patron_type)
	return (patron_type in gods)

/// Holy objects let any god hear you: a cross, ritual chalk, a god's statue, or
/// a holy amulet held in hand. Prayer goes by objects, not map areas.
/datum/domain/proc/is_sanctuary(mob/living/follower)
	var/turf/T = get_turf(follower)
	if(!T)
		return FALSE
	for(var/obj/structure/fluff/psycross/cross in view(4, T))
		if(cross.divine)
			return TRUE
	for(var/obj/structure/ritualcircle/circle in view(1, T))
		return TRUE
	for(var/obj/structure/fluff/statue/S in view(2, T))
		if(istype(S, /obj/structure/fluff/statue/astrata) || istype(S, /obj/structure/fluff/statue/abyssor) || istype(S, /obj/structure/fluff/statue/psy))
			return TRUE
	if(follower.is_holding_item_of_type(/obj/item/clothing/neck/roguetown/psicross))
		return TRUE
	for(var/obj/effect/prayer_hallow/H in range(2, T))
		return TRUE
	return FALSE

/// A lit fire, lamp or candle within range.
/datum/domain/proc/near_fire(mob/living/follower, dist = 2)
	var/turf/T = get_turf(follower)
	for(var/obj/machinery/light/rogue/L in view(dist, T))
		if(L.on)
			return TRUE
	for(var/obj/item/candle/C in view(dist, T))
		if(C.lit)
			return TRUE
	return FALSE

/// Places and moments sacred to this domain in particular.
/datum/domain/proc/is_sacred_here(mob/living/follower)
	return FALSE

/datum/domain/proc/can_pray_here(mob/living/follower)
	return is_sanctuary(follower) || is_sacred_here(follower)

/datum/domain/proc/ui_entry()
	var/list/god_entries = list()
	for(var/path in gods)
		var/datum/patron/P = GLOB.patronlist[path]
		if(!P?.name || !P.preference_accessible)
			continue
		god_entries += list(list(
			"type" = "[path]",
			"name" = P.name,
			"domain" = P.domain,
			"desc" = P.desc,
			"worshippers" = P.worshippers,
		))
	// What this domain's gods answer best in prayer.
	var/list/miracle_names = list()
	var/list/merged = list()
	if(islist(GLOB.prayer_domain_affinity[type]))
		merged += GLOB.prayer_domain_affinity[type]
	if(islist(GLOB.prayer_domain_affinity_ext[type]))
		merged += GLOB.prayer_domain_affinity_ext[type]
	for(var/intent in merged)
		if(merged[intent] >= 1.3)
			miracle_names += capitalize(intent)
	return list(
		"type" = "[type]",
		"name" = name,
		"desc" = desc,
		"icon" = icon,
		"pray_hint" = pray_hint,
		"gods" = god_entries,
		"miracles" = miracle_names,
	)

// Miracles a written prayer now covers (healing, raising, kindling, night
// sight...) are dropped from the domain lists; everything prayer can't do -
// orison, summons, wildshape, the unique projectiles and stances - stays.
GLOBAL_LIST_INIT(miracles_replaced_by_prayer, list(
	/datum/action/cooldown/spell/miracle/heal,
	/datum/action/cooldown/spell/miracle/bloodmiracle,
	/datum/action/cooldown/spell/miracle/fortify,
	/datum/action/cooldown/spell/miracle/ignition,
	/datum/action/cooldown/spell/miracle/necra_consecrate,
	/obj/effect/proc_holder/spell/invoked/revive,
	/obj/effect/proc_holder/spell/invoked/resurrect,
	/obj/effect/proc_holder/spell/invoked/cure_rot,
	/obj/effect/proc_holder/spell/invoked/pestra_heal,
	/obj/effect/proc_holder/spell/invoked/pestra_leech,
	/obj/effect/proc_holder/spell/invoked/abyssheal,
	/obj/effect/proc_holder/spell/invoked/painkiller,
	/obj/effect/proc_holder/spell/invoked/bud,
	/obj/effect/proc_holder/spell/invoked/bless_food,
	/obj/effect/proc_holder/spell/invoked/eoracurse,
	/obj/effect/proc_holder/spell/targeted/blesscrop,
	/obj/effect/proc_holder/spell/self/locate_dead,
	/datum/action/cooldown/spell/noc/nitevision,
	/datum/action/cooldown/spell/noc/invisibility,
	/datum/action/cooldown/spell/zizo/snuff_lights,
	/datum/action/cooldown/spell/undivided/recuperation,
	/datum/action/cooldown/spell/mending/malum,
	/datum/action/cooldown/spell/auxentius/battle/tug,
	/datum/action/cooldown/spell/projectile/ravox_tug,
))

/// Unique versions kept by antagonists and special roles.
GLOBAL_LIST_INIT(miracles_kept_despite_prayer, list(
	/obj/effect/proc_holder/spell/invoked/resurrect/hag,
))

/proc/miracle_replaced_by_prayer(spell_type)
	for(var/kept in GLOB.miracles_kept_despite_prayer)
		if(ispath(spell_type, kept))
			return FALSE
	for(var/replaced in GLOB.miracles_replaced_by_prayer)
		if(ispath(spell_type, replaced))
			return TRUE
	return FALSE

/datum/domain/New()
	. = ..()
	var/list/kept = list(/datum/action/cooldown/spell/prayer_base/scribe/written_prayer = CLERIC_ORI)
	for(var/spell_type in miracles)
		if(!miracle_replaced_by_prayer(spell_type))
			kept[spell_type] = miracles[spell_type]
	miracles = kept
