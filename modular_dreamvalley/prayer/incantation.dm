// Incantations: spells a mage writes for themselves. The same words the prayer
// parser understands, but spoken to the Weave instead of a god - no devotion, no
// god to please. The mage's attuned aspects decide what comes easily; energy and
// the body pay for it; the spell check and Strain (magic/) decide how it goes.

/// What the arcane can do at all, without an aspect that favours it. 0 = only gods can.
GLOBAL_LIST_INIT(incantation_base_affinity, list(
	"raise" = 0, "forgive" = 0, "bless" = 0, "hallow" = 0, "renew" = 0,
	"heal" = 0.4, "cleanse" = 0.5, "banish" = 0.5, "calm" = 0.6, "courage" = 0.6,
))
#define INCANTATION_DEFAULT_AFFINITY 0.7

/// aspect type = list(intent = multiplier)
GLOBAL_LIST_INIT(incantation_aspect_affinity, list(
	/datum/magic_aspect/pyromancy = list("smite" = 1.4, "kindle" = 1.5, "warm" = 1.4, "rage" = 1.1, "light" = 1.2),
	/datum/magic_aspect/cryomancy = list("cool" = 1.5, "bind" = 1.3, "weaken" = 1.3, "endure" = 1.2, "quench" = 1.2),
	/datum/magic_aspect/fulgurmancy = list("smite" = 1.3, "quicken" = 1.4, "repel" = 1.3, "wake" = 1.2, "blind" = 1.1),
	/datum/magic_aspect/geomancy = list("shield" = 1.4, "fell" = 1.4, "bind" = 1.2, "endure" = 1.2, "grow" = 1.2),
	/datum/magic_aspect/kinesis = list("repel" = 1.5, "draw" = 1.5, "disarm" = 1.4, "fell" = 1.3),
	/datum/magic_aspect/telomancy = list("seek" = 1.5, "reveal" = 1.4, "truth" = 1.3, "nighteyes" = 1.3, "veil" = 1.2),
	/datum/magic_aspect/ferramancy = list("repair" = 1.5, "strengthen" = 1.3, "disarm" = 1.2, "shield" = 1.2),
	/datum/magic_aspect/battlewardry = list("shield" = 1.5, "endure" = 1.3, "courage" = 1.2),
	/datum/magic_aspect/conjuration = list("light" = 1.4, "feed" = 1.2, "quench" = 1.2, "draw" = 1.2),
	/datum/magic_aspect/augmentation = list("strengthen" = 1.4, "quicken" = 1.4, "vigor" = 1.4, "nighteyes" = 1.2),
	/datum/magic_aspect/artifice = list("repair" = 1.3),
	/datum/magic_aspect/exowardry = list("shield" = 1.3),
	/datum/magic_aspect/displacement = list("repel" = 1.2, "draw" = 1.2),
	/datum/magic_aspect/autowardry = list("shield" = 1.2),
	/datum/magic_aspect/lesser_augmentation = list("strengthen" = 1.15, "quicken" = 1.15),
	/datum/magic_aspect/illusion = list("veil" = 1.5, "blind" = 1.2, "madden" = 1.2, "frighten" = 1.2),
	/datum/magic_aspect/hearthcraft = list("warm" = 1.3, "feed" = 1.3, "quench" = 1.3, "light" = 1.3),
	/datum/magic_aspect/aegiscraft = list("shield" = 1.3),
	/datum/magic_aspect/hex = list("curse" = 1.5, "weaken" = 1.3, "sicken" = 1.3, "madden" = 1.2, "frighten" = 1.2),
))

/proc/incantation_aspects(mob/user)
	. = list()
	if(!user?.mind)
		return
	for(var/datum/magic_aspect/A in user.mind.major_aspects)
		. += A
	for(var/datum/magic_aspect/A in user.mind.minor_aspects)
		. += A

/proc/incantation_aspect_names(mob/user)
	var/list/names = list()
	for(var/datum/magic_aspect/A as anything in incantation_aspects(user))
		names += A.name
	return length(names) ? "the Weave, through [english_list(names)]" : "the Weave"

/proc/incantation_affinity(mob/user, intent)
	var/base = GLOB.incantation_base_affinity[intent]
	if(isnull(base))
		base = INCANTATION_DEFAULT_AFFINITY
	if(base <= 0)
		return 0
	. = base
	for(var/datum/magic_aspect/A as anything in incantation_aspects(user))
		var/list/table = GLOB.incantation_aspect_affinity[A.type]
		if(islist(table) && table[intent])
			. = max(., table[intent])

/// How strongly the Weave answers this mage before any request is weighed.
/proc/incantation_base_power(mob/living/user)
	. = 0.55 + 0.12 * user.get_skill_level(/datum/skill/magic/arcane)
	. += (user.get_stat(STAT_INTELLIGENCE) - 10) * 0.04
	if(user.in_place_of_power())
		. *= 1.2
	. *= 1 - min(0.4, user.arcane_strain / 250)

/// Energy an incantation draws.
/proc/incantation_energy_cost(datum/prayer_reading/R, shape, sacrificed = 0, mob/living/user)
	var/medium_cost = 1
	if(istype(user))
		var/list/medium = user.arcane_medium()
		medium_cost = medium[3]
	return round(prayer_reading_cost(R) * 2 * prayer_shape_value(shape, "cost") * prayer_sacrifice_discount(sacrificed) * medium_cost)

// --- The spells ------------------------------------------------------------------

/datum/action/cooldown/spell/prayer_base/scribe/incantation
	name = "Incant"
	desc = "Write your own spell. Say what the working should do and to whom, as plainly as a prayer - no god hears it, the Weave does. \
		Your attuned aspects decide what comes easily; your Intelligence, arcane skill and Strain decide how well. It draws on your energy, \
		and like any spell it must pass a spell check.<br>Toggle Spell Alt Mode cycles through the incantations you know by heart (the Incantations verb).\
		<br>Examples: <i>\"Fire, strike down this foe!\"</i> - <i>\"Stone, shield me.\"</i> - <i>\"Take my blood and throw them back from me.\"</i>"
	button_icon = 'icons/effects/prayer_fx.dmi'
	button_icon_state = "vortex"
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	associated_skill = /datum/skill/magic/arcane
	preset_kind = PRESET_KIND_INCANTATION
	spell_tier = 2
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/prayer_base/preset/incantation
	desc = "An incantation I know by heart."
	associated_skill = /datum/skill/magic/arcane
	preset_kind = PRESET_KIND_INCANTATION
	spell_tier = 2

/datum/action/cooldown/spell/prayer_base/scribe/incantation/can_speak_words(mob/living/carbon/human/user)
	return incantation_can_speak_words(user)

/datum/action/cooldown/spell/prayer_base/preset/incantation/can_speak_words(mob/living/carbon/human/user)
	return incantation_can_speak_words(user)

/proc/incantation_can_speak_words(mob/living/carbon/human/user)
	if(user.get_skill_level(/datum/skill/magic/arcane) < 1)
		to_chat(user, span_warning("I know the words, but not how to make them mean anything."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/prayer_base/scribe/incantation/answer_words(mob/living/carbon/human/user, mob/living/chosen, text, shape, atom/aim)
	answer_incantation(user, chosen, text, shape, aim)

/datum/action/cooldown/spell/prayer_base/preset/incantation/answer_words(mob/living/carbon/human/user, mob/living/chosen, text, shape, atom/aim)
	answer_incantation(user, chosen, text, shape, aim)

/datum/action/cooldown/spell/prayer_base/proc/answer_incantation(mob/living/carbon/human/user, mob/living/chosen, text, shape, atom/aim)
	var/datum/prayer_reading/R = read_prayer(text, list(), null)
	if(!length(R.clauses))
		to_chat(user, span_notice("The words have no shape. Nothing in the Weave answers them. (Say what the working should do: strike, shield, bind, throw back...)"))
		qdel(R)
		return

	var/base = incantation_base_power(user)
	var/list/medium = user.arcane_medium()
	base *= medium[2]
	base *= latin_power_mult(text)
	if(user.last_spell_check_result == SPELL_CHECK_MASTERY)
		base *= 1.3
	if(length(text) > 150)
		base *= 1.1
	else if(length(text) < 20)
		base *= 0.85
	base *= prayer_shape_value(shape, "power")

	// The body may pay in place of energy.
	var/offered = 0
	var/sacrificed = 0
	for(var/kind in R.offerings)
		if(kind == "item")
			var/gift = offer_held_item(user, null)
			offered += gift
			sacrificed += gift
			continue
		if(!(kind in GLOB.prayer_sacrifice_kinds))
			continue
		offered += R.offerings[kind]
		sacrificed += R.offerings[kind]
		pay_offering(user, kind)
	base *= 1 + min(1, offered)

	var/cost = incantation_energy_cost(R, shape, sacrificed, user)
	if(user.energy < cost)
		base *= max(0.15, user.energy / max(1, cost))
		to_chat(user, span_warning("I haven't the energy for all of it. The working comes out thin."))
		cost = user.energy
	user.energy_add(-cost)
	// A bigger working strains more.
	spell_tier = clamp(length(R.clauses) + (cost >= 300 ? 2 : 1), 1, 4)

	var/clause_count = length(R.clauses)
	var/spread = 1 + 0.35 * (clause_count - 1)
	var/list/report = list()
	var/list/live = list()
	var/answered = 0
	for(var/datum/prayer_clause/C as anything in R.clauses)
		var/asked = prayer_asking_phrase(C.intent)
		var/affinity = incantation_affinity(user, C.intent)
		if(affinity <= 0)
			report += "<span style='color:#c89a8a'>I reach for [asked], but that is not a thing the Weave gives. Only gods do that.</span>"
			continue
		C.power = base * affinity * C.power_mult / spread
		if(C.power < 0.3)
			report += "<span style='color:#8a8274'>The words for [asked] come out thin, and nothing happens.</span>"
			continue
		if(prayer_shape_delivers(shape))
			live += C
			continue
		var/list/lines = list()
		for(var/mob/living/T as anything in prayer_targets_for(C, user, chosen))
			var/line = prayer_apply_resisted(C, T, user, null)
			if(line)
				lines += line
				prayer_visual(T, C.intent, C.power, user)
		if(length(lines))
			answered++
			report += jointext(lines, " ")
		else
			report += "<span style='color:#a89a86'>The working for [asked] finds nothing to take hold of.</span>"
	if(length(live))
		answered++
		report += prayer_shape_release(shape, live, R, user, aim, null, shape == PRAYER_SHAPE_PROJECTILE && prayer_arc)
		R = null

	var/list/told = list("<span style='color:#9fd4ff'><i>[answered ? "The working takes hold." : "The working unravels."]</i></span>")
	for(var/line in report)
		told += "<i>[line]</i>"
	to_chat(user, jointext(told, "<br>"))
	new /obj/effect/temp_visual/strain_crackle(get_turf(user))
	cooldown_time = (15 SECONDS) + (10 SECONDS) * clause_count
	if(R)
		qdel(R)

// --- Mages learn to incant ---------------------------------------------------------

/datum/mind/AddSpell(datum/spell_or_action, mob/living/user)
	var/learns_incant = istype(spell_or_action, /datum/action/cooldown/spell) && is_arcane_spell(spell_or_action) && !istype(spell_or_action, /datum/action/cooldown/spell/prayer_base)
	. = ..()
	if(learns_incant && !has_spell(/datum/action/cooldown/spell/prayer_base/scribe/incantation))
		AddSpell(new /datum/action/cooldown/spell/prayer_base/scribe/incantation, user)

// --- The counsel, for incantations -------------------------------------------------

/proc/incantation_counsel_html(mob/user, mob/living/chosen, text, shape = PRAYER_SHAPE_TARGETED, list/summary)
	if(length(trim(text)) < PRAYER_MIN_LENGTH)
		return "<p class='dim'><i>Too few words yet to call an incantation.</i></p>"
	var/mob/living/living_user = isliving(user) ? user : null
	var/datum/prayer_reading/R = read_prayer(text, list(), null)
	var/list/out = list()
	var/list/aspects = incantation_aspects(user)
	if(length(aspects))
		out += "<p>You draw on [incantation_aspect_names(user)]. What they favour comes easily.</p>"
	else
		out += "<p class='dim'>You are attuned to no aspect. Every working comes to you only middlingly.</p>"
	if(!length(R.clauses))
		out += "<p class='warn'>But the words ask for nothing. Say what the working should do: strike, shield, bind, throw back...</p>"
		qdel(R)
		return jointext(out, "")
	var/base = living_user ? incantation_base_power(living_user) : 0.7
	base *= prayer_shape_value(shape, "power")
	var/latin = latin_word_count(text)
	base *= latin_power_mult(text)
	if(latin)
		out += "<p class='good'>You speak [latin] word[latin == 1 ? "" : "s"] of the old tongue. The Weave was first bound in Latin, and answers it better (+[min(30, latin * 5)]%).</p>"
	else
		out += "<p class='dim'>Spoken in the common tongue. The Weave answers Latin better.</p>"
	if(living_user)
		var/list/medium = living_user.arcane_medium()
		base *= medium[2]
		var/list/medium_names = medium[4]
		if(length(medium_names))
			out += "<p class='good'>You channel it through [english_list(medium_names)]: surer, stronger and cheaper.</p>"
		else
			out += "<p class='dim'>You hold no staff, wand or book to channel it through.</p>"
	var/spread = 1 + 0.35 * (length(R.clauses) - 1)
	for(var/datum/prayer_clause/C as anything in R.clauses)
		var/asked = prayer_asking_phrase(C.intent)
		var/affinity = incantation_affinity(user, C.intent)
		if(affinity <= 0)
			if(summary)
				summary["requests"] += list(list("asked" = asked, "intent" = C.intent, "strength" = 0, "refused" = TRUE))
			out += "<p class='warn'>You reach for <b>[asked]</b>. The Weave does not give that; only gods do.</p>"
			continue
		var/strength = base * affinity * C.power_mult / spread
		if(summary)
			summary["requests"] += list(list("asked" = asked, "intent" = C.intent, "strength" = round(strength, 0.01), "refused" = FALSE, "harmful" = (C.intent in GLOB.prayer_harmful_intents)))
		var/list/info = GLOB.prayer_intent_info[C.intent]
		var/whom = prayer_shape_delivers(shape) ? "for whoever the [lowertext(prayer_shape_value(shape, "name"))] reaches" : (C.target_kind == "self" ? "on yourself" : (chosen && chosen != user ? "on [chosen]" : "on whomever you aim at"))
		var/fav = affinity > 1 ? " <span class='good'>Your aspects favour this.</span>" : (affinity < INCANTATION_DEFAULT_AFFINITY ? " <span class='warn'>The arcane does this poorly.</span>" : "")
		out += "<p><span class='ask'>You work <b>[asked]</b> [whom].</span>[fav]<br><span class='dim'>[info ? info[1] : ""]</span></p>"
	var/sacrificed = 0
	for(var/kind in R.offerings)
		if(!(kind in GLOB.prayer_sacrifice_kinds))
			continue
		var/list/about = GLOB.prayer_offering_info[kind]
		sacrificed += kind == "item" ? 0.3 : R.offerings[kind]
		out += "<p>You sacrifice <b>[about[1]]</b>. [about[2]] It lowers the energy the working draws.</p>"
	var/cost = incantation_energy_cost(R, shape, sacrificed, living_user)
	var/have = living_user ? round(living_user.energy) : null
	if(summary)
		summary["cost"] = cost
		summary["have"] = have
		summary["cost_label"] = "energy"
	out += "<p>This draws about <b>[cost]</b> energy[isnull(have) ? "" : "; you have [have]"].</p>"
	if(living_user)
		var/static/datum/action/cooldown/spell/prayer_base/scribe/incantation/probe
		if(!probe)
			probe = new
		var/check = living_user.spell_check_bonus(probe)
		out += "<p class='dim'>Like any spell it must pass a spell check (d20 [check >= 0 ? "+" : "-"] [abs(check)]; lost below 6), and it adds to your Strain ([round(living_user.arcane_strain)] now).</p>"
	if(shape != PRAYER_SHAPE_TARGETED)
		out += "<p class='dim'>Shaped as <b>[prayer_shape_value(shape, "name")]</b>: [prayer_shape_value(shape, "desc")]</p>"
	qdel(R)
	return jointext(out, "")
