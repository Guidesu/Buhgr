// Which domain holds sway over the land this round. Every worshipper counts
// towards their god's domain; when one domain clearly leads, its followers'
// miracles come easier and everyone else's come harder.

/datum/dominant_faith_tracker
	/// How far ahead of the next domain the leader must be to hold sway.
	var/sway_margin = 2
	/// Domains whose followers count for more, being fewer and more fervent.
	var/list/weights = list(
		/datum/domain/forbidden = 2,
	)
	/// domain type = weighted followers
	var/list/totals = list()
	/// The domain holding sway, or null when none clearly leads.
	var/dominant_domain
	var/last_announce_time = 0

/mob/living/carbon/human/proc/debug_faiths(recalc = FALSE)
	if(recalc)
		GLOB.dominant_faith_tracker.calculate_dominant_faith(TRUE)
	GLOB.dominant_faith_tracker.last_announce_time = 0
	GLOB.dominant_faith_tracker.announce_reign()
	to_world("debugged faiths. current dominant domain: [GLOB.dominant_faith_tracker.dominant_domain || "none"]")

/datum/dominant_faith_tracker/proc/roundstart_setup()
	addtimer(CALLBACK(src, PROC_REF(calculate_dominant_faith), TRUE), 5 MINUTES) // wait a bit after roundstart spam settles down and the first wave of latejoins pops in

/datum/dominant_faith_tracker/proc/counts(mob/living/carbon/human/H)
	return istype(H) && H.patron && H.divine_domain && !ispath(H.patron.associated_faith, /datum/faith/godless)

/datum/dominant_faith_tracker/proc/calculate_dominant_faith(force = FALSE)
	var/old_dominant = dominant_domain
	full_recalculate()
	var/best
	var/best_total = 0
	var/second_total = 0
	for(var/domain_type in totals)
		var/total = totals[domain_type]
		if(total > best_total)
			second_total = best_total
			best_total = total
			best = domain_type
		else if(total > second_total)
			second_total = total
	dominant_domain = (best && best_total - second_total >= sway_margin) ? best : null

	if(old_dominant == dominant_domain) // we only want to announce actual changes
		return
	var/no_metagaming = (force ? 1 : (pick(list(1,2,3,4,5)) MINUTES))
	// cooldown for this is at the top of the announce_reign proc, so it's fine to call it every time we recalc
	addtimer(CALLBACK(src, PROC_REF(announce_reign), TRUE), no_metagaming) // a small random delay so a latejoin can't be read off the change

/// 1 if the domain holding sway is the user's, -1 if another holds it, 0 if none does.
/datum/dominant_faith_tracker/proc/favour_for(mob/living/user)
	if(!dominant_domain || !user?.divine_domain)
		return 0
	return user.divine_domain.type == dominant_domain ? 1 : -1

/// Tells a worshipper which domain holds the land and what it means for them.
/datum/dominant_faith_tracker/proc/describe_sway(mob/living/H)
	var/datum/domain/D = get_divine_domain(dominant_domain)
	var/god = H.patron ? get_god_name(H.patron) : "my god"
	if(!D)
		to_chat(H, span_blue("No one domain holds this land now. The gods are balanced, and [god] is neither nearer nor further than before."))
	else if(favour_for(H) > 0)
		to_chat(H, span_boldgreen("The [D.name] holds sway over this land, and [god] stands high above it. My miracles will come easier."))
	else
		to_chat(H, span_warningbig("The [D.name] holds sway over this land now. [god] feels further away, and my miracles will come harder."))

/datum/dominant_faith_tracker/proc/announce_reign()
	if((last_announce_time != 0) && (world.time <= (last_announce_time + 10 MINUTES)))
		return // no announcement spam
	for(var/mob/i in GLOB.player_list)
		var/mob/living/carbon/human/H = i
		if(!counts(H) || !H.devotion)
			continue
		describe_sway(H)
	if(last_announce_time == 0) // first announcement of the round: extra grace for latejoins to settle in
		last_announce_time = world.time + 14 MINUTES
	else
		last_announce_time = world.time

/datum/dominant_faith_tracker/proc/full_recalculate()
	totals = list()
	for(var/mob/i in GLOB.player_list)
		var/mob/living/carbon/human/H = i
		if(!counts(H))
			continue
		var/domain_type = H.divine_domain.type
		totals[domain_type] += (weights[domain_type] || 1)

// Call these when someone enters or leaves the round, or changes god.
/datum/dominant_faith_tracker/proc/handle_addition(mob/living/carbon/human/H)
	if(counts(H))
		calculate_dominant_faith()

/datum/dominant_faith_tracker/proc/handle_removal(mob/living/carbon/human/H)
	if(counts(H))
		calculate_dominant_faith()

/datum/dominant_faith_tracker/proc/handle_conversion(mob/living/carbon/human/H, datum/patron/old_patron)
	calculate_dominant_faith()

GLOBAL_DATUM_INIT(dominant_faith_tracker, /datum/dominant_faith_tracker, new)
