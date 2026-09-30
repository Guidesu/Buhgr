// The written prayer. The supplicant chooses who it is for, writes it out, and
// their god reads it. Nothing is guaranteed: the god weighs the words, the
// supplicant's devotion and state, the place, the hour and what is offered.

#define PRAYER_BASE_COST 20
#define PRAYER_MIN_LENGTH 12
#define PRAYER_REPEAT_WINDOW (10 MINUTES)

/mob/living
	/// normalized prayer text = list(times said, last time said)
	var/list/prayer_history

/// Shared by Pray and by saved prayers made into their own spells.
/datum/action/cooldown/spell/prayer_base
	name = "Pray"
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon_state = "thaumaturgy"
	sound = null
	charge_sound = null
	glow_intensity = GLOW_INTENSITY_LOW
	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE

	click_to_activate = TRUE
	self_cast_possible = TRUE
	cast_range = 4

	primary_resource_type = SPELL_COST_NONE
	invocation_type = INVOCATION_NONE
	charge_required = FALSE
	cooldown_time = 30 SECONDS

	associated_skill = /datum/skill/magic/holy
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/prayer_base
	/// How the prayer reaches the world; see shapes.dm.
	var/prayer_shape = PRAYER_SHAPE_TARGETED
	/// Prayer to a god, or an arcane incantation (incantation.dm).
	var/preset_kind = PRESET_KIND_PRAYER
	/// A bolt fired in an arc, over heads and walls.
	var/prayer_arc = FALSE

/// Readies the spell to say fixed words in a shape: its range, and a charge
/// held like any other spell - the longer the prayer, the longer the hold.
/datum/action/cooldown/spell/prayer_base/proc/configure_prayer(text, shape)
	cast_range = prayer_shape_value(shape, "range") || 4
	click_to_activate = prayer_shape_value(shape, "clicks")
	if(!text)
		charge_required = FALSE
		return
	charge_required = TRUE
	charge_time = max(0.5 SECONDS, (1 SECONDS + min(length(text), 300) / 60 SECONDS) * prayer_shape_value(shape, "time"))
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	if(!prayer_shape_delivers(shape) || shape == PRAYER_SHAPE_PROJECTILE || shape == PRAYER_SHAPE_BEAM)
		charge_slowdown = CHARGING_SLOWDOWN_SMALL
	else
		charge_slowdown = CHARGING_SLOWDOWN_MEDIUM

/datum/action/cooldown/spell/prayer_base/proc/get_shape()
	return prayer_shape

/datum/action/cooldown/spell/prayer_base/is_valid_target(atom/cast_on)
	if(get_shape() == PRAYER_SHAPE_TARGETED)
		return isliving(cast_on)
	return TRUE

/// The words to pray this time, or null to give up.
/datum/action/cooldown/spell/prayer_base/proc/get_prayer_text(mob/living/carbon/human/user, mob/living/chosen)
	return null

/datum/action/cooldown/spell/prayer_base/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = owner
	var/shape = get_shape()
	var/mob/living/chosen = isliving(cast_on) ? cast_on : user
	if(shape == PRAYER_SHAPE_SELF)
		chosen = user
	if(!istype(user) || (shape == PRAYER_SHAPE_TARGETED && !isliving(cast_on)))
		return FALSE
	if(!can_speak_words(user))
		return FALSE

	var/text = get_prayer_text(user, chosen)
	if(!text || QDELETED(user) || QDELETED(chosen) || user.stat != CONSCIOUS)
		return FALSE
	if(length(text) < PRAYER_MIN_LENGTH)
		to_chat(user, span_warning("That is hardly a prayer."))
		return FALSE

	var/datum/patron/P = user.patron
	if(P && preset_kind == PRESET_KIND_PRAYER)
		for(var/profanity in P.profane_words)
			var/regex/cuss = regex("\\b[profanity]\\b", "i")
			if(cuss.Find(text))
				P.punish_prayer(user)
				return FALSE

	user.say(text, forced = "prayer")
	var/datum/domain/D = user.divine_domain
	// Words held in a charge were already said under the breath; release them.
	if(charge_required)
		answer_words(user, chosen, text, shape, cast_on)
		share_cooldown(user)
		return TRUE
	user.visible_message(span_notice(preset_kind == PRESET_KIND_INCANTATION ? "[user] traces a sigil in the air and begins to chant." : "[user] bows their head in prayer."))
	// Only great workings get the full rune circle while kneeling.
	var/grand = FALSE
	var/datum/prayer_reading/preview = read_prayer(text, list(), null)
	for(var/datum/prayer_clause/PC as anything in preview.clauses)
		if(prayer_intent_cost(PC.intent) >= 120 || PC.target_kind == "all")
			grand = TRUE
	qdel(preview)
	var/list/kneel = prayer_kneel_start(user, D?.colour || "#fff1b8", grand)
	// Praying on the move is possible, but slow going.
	var/obj/effect/overlay/prayer_mark = new
	prayer_mark.maptext = MAPTEXT("<span style='font-size:14pt;color:[D?.colour || "#fff1b8"]'><b>!</b></span>")
	prayer_mark.maptext_width = 32
	prayer_mark.maptext_height = 32
	prayer_mark.maptext_x = 12
	prayer_mark.pixel_y = 30
	prayer_mark.appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	prayer_mark.plane = ABOVE_LIGHTING_PLANE
	prayer_mark.layer = ABOVE_MOB_LAYER
	user.vis_contents += prayer_mark
	user.add_movespeed_modifier(MOVESPEED_ID_SPELL_CASTING, override = TRUE, multiplicative_slowdown = 2)
	var/finished = do_after(user, (2 SECONDS + min(length(text), 300) / 50 SECONDS) * prayer_shape_value(shape, "time"), target = user, allow_movement = TRUE)
	user.remove_movespeed_modifier(MOVESPEED_ID_SPELL_CASTING)
	user.vis_contents -= prayer_mark
	qdel(prayer_mark)
	if(!finished)
		prayer_kneel_end(user, kneel)
		to_chat(user, span_warning("My prayer is broken off."))
		return FALSE
	prayer_kneel_end(user, kneel)
	answer_words(user, chosen, text, shape, cast_on)
	share_cooldown(user)
	return TRUE

/// Whether the caster can use this at all.
/datum/action/cooldown/spell/prayer_base/proc/can_speak_words(mob/living/carbon/human/user)
	if(!user.devotion)
		to_chat(user, span_warning("My god does not know me well enough to answer."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/prayer_base/proc/answer_words(mob/living/carbon/human/user, mob/living/chosen, text, shape, atom/aim)
	answer_prayer(user, chosen, text, shape, aim)

/// Every way of praying shares one breath; so does every incantation.
/datum/action/cooldown/spell/prayer_base/proc/share_cooldown(mob/living/user)
	for(var/datum/action/cooldown/spell/prayer_base/other in user.mind?.spell_list)
		if(other != src && other.preset_kind == preset_kind)
			other.StartCooldown(cooldown_time)

/datum/action/cooldown/spell/prayer_base/proc/answer_prayer(mob/living/carbon/human/user, mob/living/chosen, text, shape = PRAYER_SHAPE_TARGETED, atom/aim)
	var/datum/domain/D = user.divine_domain
	var/datum/patron/P = user.patron
	var/list/names = list()
	if(P)
		names += P.name
		names += P.titles
	var/datum/prayer_reading/R = read_prayer(text, names, D?.name)
	if(!length(R.clauses))
		to_chat(user, span_notice("I pour my heart out, but I never actually ask for anything. (Say what you want: heal, shield, strengthen, calm, smite... The Prayer guide in the encyclopedia lists every word.)"))
		user.devotion.update_devotion(1, 1)
		qdel(R)
		return

	// --- How strongly is this prayer heard? ---------------------------------
	var/base = 0.7 + 0.15 * user.devotion.level
	var/list/notes = list()

	if(R.invoked_god)
		base *= 1.25
	else if(R.named_domain)
		base *= 1.1
	else
		base *= 0.6
		notes += "I never named who I was praying to."

	var/bold = D && (D.type in GLOB.prayer_bold_domains)
	base *= 1 + min(0.3, R.humble * 0.06)
	if(R.arrogant)
		if(bold)
			base *= 1 + min(0.2, R.arrogant * 0.05)
		else
			base *= max(0.4, 1 - R.arrogant * 0.15)
			notes += "My god does not care for being ordered about."

	if(D && D.can_pray_here(user))
		base *= 1.25
	var/datum/sanity/S = user.sanity
	if(S)
		if(S.level < 25)
			base *= 0.75
			notes += "My mind is too frayed to pray clearly."
		else if(S.level > 80)
			base *= 1.05
	base *= prayer_hour_modifier(D)

	var/key = prayer_normalize(text)
	LAZYINITLIST(user.prayer_history)
	var/list/said = user.prayer_history[key]
	if(said && world.time - said[2] < PRAYER_REPEAT_WINDOW)
		base *= 0.5 ** said[1]
		notes += "I have said these exact words before. They mean less each time."
		said[1]++
		said[2] = world.time
	else
		user.prayer_history[key] = list(1, world.time)

	if(length(text) > 150)
		base *= 1.1
	else if(length(text) < 25)
		base *= 0.8

	// Offerings are paid now, whatever comes of them.
	var/offered = 0
	/// What was given up of the body or in hand; it eases the devotion asked.
	var/sacrificed = 0
	for(var/kind in R.offerings)
		if(kind == "item")
			var/gift = offer_held_item(user, D)
			offered += gift
			sacrificed += gift
			continue
		offered += R.offerings[kind]
		if(kind in GLOB.prayer_sacrifice_kinds)
			sacrificed += R.offerings[kind]
		pay_offering(user, kind)

	// Circumstance.
	if(R.affection && chosen != user)
		base *= (D && (D.type in list(/datum/domain/love, /datum/domain/hearth))) ? 1.2 : 1.05
	if(GLOB.is_blood_moon)
		base *= istype(D, /datum/domain/forbidden) ? 1.4 : 0.9
	if(user.health < user.maxHealth * 0.35 && user.stat == CONSCIOUS)
		base *= 1.15
		notes += "Desperation lends my words weight."
	if(chosen != user && chosen.patron && user.patron && chosen.patron.type == user.patron.type)
		base *= 1.1
	base *= 1 + min(1, offered)
	base *= prayer_shape_value(shape, "power")

	// --- Cost ---------------------------------------------------------------
	var/clause_count = length(R.clauses)
	var/spread = 1 + 0.35 * (clause_count - 1)
	var/list/relief = prayer_cost_relief(user)
	var/cost = round(prayer_reading_cost(R) * prayer_shape_value(shape, "cost") * relief[1] * prayer_sacrifice_discount(sacrificed))
	if(user.devotion.devotion < cost)
		base *= max(0.1, user.devotion.devotion / max(1, cost))
		notes += "I have too little devotion left to ask this much."
		cost = user.devotion.devotion
	user.devotion.update_devotion(-cost)

	for(var/note in notes)
		to_chat(user, span_warning(note))

	// A gamble: the god may take what was offered and give nothing, or give more.
	if(R.offerings["gamble"])
		base *= pick(0, 0.5, 1.5, 2)

	// --- The answer ----------------------------------------------------------
	var/answered = 0
	var/list/report = list()
	var/best_power = 0
	var/list/live = list()
	for(var/datum/prayer_clause/C as anything in R.clauses)
		var/affinity = 1
		if(D)
			var/list/table = GLOB.prayer_domain_affinity[D.type]
			if(islist(table) && !isnull(table[C.intent]))
				affinity = table[C.intent]
			var/list/ext = GLOB.prayer_domain_affinity_ext[D.type]
			if(islist(ext) && !isnull(ext[C.intent]))
				affinity = ext[C.intent]
		var/asked = prayer_asking_phrase(C.intent)
		if(affinity <= 0)
			report += "<span style='color:#c89a8a'>[GLOB.prayer_refusals[C.intent] || "When I ask for [asked], I feel my god turn away."]</span>"
			continue
		C.power = base * affinity * C.power_mult / spread
		// The dying are heard first.
		if((C.intent in list("heal", "renew", "cleanse")) && chosen.health <= 0 && chosen.stat != DEAD)
			C.power *= 1.3
		if(C.power < 0.3)
			report += "<span style='color:#8a8274'>I ask for [asked], and hear only silence.</span>"
			continue
		if(prayer_shape_delivers(shape))
			live += C
			best_power = max(best_power, C.power)
			continue
		var/list/targets = prayer_targets_for(C, user, chosen)
		var/list/lines = list()
		for(var/mob/living/T as anything in targets)
			var/line = prayer_apply_resisted(C, T, user, D)
			if(line)
				lines += line
				prayer_visual(T, C.intent, C.power, user)
		if(length(lines))
			answered++
			best_power = max(best_power, C.power)
			report += jointext(lines, " ")
		else
			report += "<span style='color:#a89a86'>My god hears me ask for [asked], but finds nothing there to answer.</span>"

	if(length(live))
		answered++
		report += prayer_shape_release(shape, live, R, user, aim, D, shape == PRAYER_SHAPE_PROJECTILE && prayer_arc)
		R = null // the shape owns the reading now

	var/god_name = P?.name || "my god"
	prayer_answer_presence(user, D?.colour || "#fff1b8", best_power, answered)
	var/colour = D?.colour || "#fff1b8"
	var/list/told = list("<span style='color:[colour]'><i>[prayer_answer_opening(god_name, best_power, answered)]</i></span>")
	for(var/line in report)
		told += "<i>[line]</i>"
	if(cost >= 150)
		told += "<span style='color:#a89a86'><i>The asking leaves me hollowed out - so much of my devotion spent at once that little remains for other prayers until it returns.</i></span>"
	to_chat(user, jointext(told, "<br>"))
	if(answered)
		user.devotion.update_devotion(0, 2 * answered)
		if(base >= 1.8)
			user.visible_message(span_boldnotice("For a moment, something vast seems to lean close to [user]."))
	cooldown_time = (20 SECONDS) + (15 SECONDS) * clause_count
	if(R)
		qdel(R)

/datum/action/cooldown/spell/prayer_base/proc/prayer_targets_for(datum/prayer_clause/C, mob/living/user, mob/living/chosen)
	switch(C.target_kind)
		if("self")
			return list(user)
		if("all")
			. = list()
			for(var/mob/living/L in view(2, user))
				. += L
			if(C.intent in list("smite", "curse", "weaken", "bind", "blind", "silence", "sleep"))
				. -= user
			return .
	return list(chosen)

/datum/action/cooldown/spell/prayer_base/proc/pay_offering(mob/living/carbon/human/user, kind)
	switch(kind)
		if("blood")
			user.blood_volume = max(BLOOD_VOLUME_SURVIVE, user.blood_volume - 40)
			to_chat(user, span_warning("Blood wells from my palms."))
		if("stamina")
			user.energy_add(-300)
			to_chat(user, span_warning("My strength drains out of me."))
		if("flesh")
			user.adjustBruteLoss(15)
			to_chat(user, span_warning("Something takes its due from my body."))
		if("sight")
			user.adjust_blindness(10)
			to_chat(user, span_warning("The world goes dark."))

/// A held item given up to the god. Fitting gifts please more; coin by weight.
/datum/action/cooldown/spell/prayer_base/proc/offer_held_item(mob/living/carbon/human/user, datum/domain/D)
	var/obj/item/I = user.get_active_held_item()
	if(!I)
		to_chat(user, span_warning("I offer nothing - my hands are empty."))
		return 0
	var/bonus = 0.15
	for(var/item_type in GLOB.prayer_item_offerings)
		if(istype(I, item_type))
			bonus = 0.25
			if(D && (D.type in GLOB.prayer_item_offerings[item_type]))
				bonus = 0.5
			break
	if(istype(I, /obj/item/roguecoin))
		var/obj/item/roguecoin/coin = I
		bonus += min(0.4, coin.get_real_price() / 400)
	user.visible_message(span_notice("[user] lays [I] down as an offering, and it is gone."))
	qdel(I)
	return bonus

/// How a request reads in narration: "I ask for [this]".
/proc/prayer_asking_phrase(intent)
	var/static/list/phrases = list(
		"heal" = "healing", "renew" = "lasting healing", "cleanse" = "cleansing", "shield" = "protection",
		"smite" = "wrath", "banish" = "the dead to be banished", "calm" = "calm", "forgive" = "forgiveness",
		"courage" = "courage", "strengthen" = "strength", "rage" = "fury", "vigor" = "vigour", "quicken" = "swiftness",
		"weaken" = "their weakening", "curse" = "a curse", "bind" = "them to be held", "sleep" = "sleep", "wake" = "waking",
		"feed" = "food", "quench" = "water", "warm" = "warmth", "cool" = "coolness", "light" = "light", "reveal" = "sight",
		"truth" = "the truth", "blind" = "their blinding", "silence" = "silence upon them", "speak" = "a voice",
		"bless" = "a blessing", "raise" = "the dead to return", "veil" = "a veil", "tongues" = "understanding",
		"frighten" = "terror upon them", "madden" = "madness upon them", "sicken" = "sickness upon them", "rot" = "rot",
		"endure" = "shelter from the weather", "nighteyes" = "eyes for the dark", "disarm" = "their disarming",
		"fell" = "their fall", "repel" = "them to be driven back", "draw" = "them drawn near", "sober" = "a clear head",
		"grow" = "growth", "tame" = "the beast's taming", "repair" = "mending", "kindle" = "fire", "snuff" = "darkness",
		"seek" = "guidance", "hallow" = "holy ground",
	)
	return phrases[intent] || intent

/// The first line of the answer, by how strongly it came.
/proc/prayer_answer_opening(god_name, power, answered)
	if(!answered)
		return "I wait for an answer, and none comes."
	if(power < 0.6)
		return "Something stirs, faint and far off. [god_name] has heard - barely."
	if(power < 1)
		return "I feel [god_name] listening."
	if(power < 1.5)
		return "[god_name] answers."
	if(power < 2)
		return "[god_name]'s presence floods through me."
	return "For a heartbeat [god_name] is here - vast, near, and looking at me."

/// Devotion each kind of request costs. Prayer is the most expensive way to ask a god for anything.
/proc/prayer_intent_cost(intent)
	switch(intent)
		if("raise")
			return 400
		if("renew", "rot", "banish", "hallow")
			return 120
		if("rage", "smite", "curse", "weaken", "bind", "blind", "silence", "frighten", "madden", "sicken", "disarm", "fell", "repel", "draw")
			return 90
		if("heal", "cleanse", "shield", "strengthen", "quicken", "bless", "forgive", "truth", "courage", "vigor", "veil", "grow", "tame", "repair", "sleep")
			return 70
	return 40

/// The hour and the moon matter to some domains.
/datum/action/cooldown/spell/prayer_base/proc/prayer_hour_modifier(datum/domain/D)
	if(!D)
		return 1
	var/night = (GLOB.tod == "night" || GLOB.tod == "dusk")
	switch(D.type)
		if(/datum/domain/sun)
			return night ? 0.8 : 1.2
		if(/datum/domain/moon)
			if(GLOB.moon_phase == MOON_PHASE_FULL)
				return 1.35
			if(GLOB.moon_phase == MOON_PHASE_NEW)
				return 0.85
			return night ? 1.15 : 0.95
		if(/datum/domain/death, /datum/domain/forbidden)
			return night ? 1.1 : 1
	return 1


/// Devotion a reading will ask for.
/proc/prayer_reading_cost(datum/prayer_reading/R)
	var/cost = PRAYER_BASE_COST
	for(var/datum/prayer_clause/C as anything in R.clauses)
		cost += prayer_intent_cost(C.intent) * C.cost_mult * (C.target_kind == "all" ? 2 : 1)
	if(R.offerings["devotion"])
		cost += 20
	return round(cost)
