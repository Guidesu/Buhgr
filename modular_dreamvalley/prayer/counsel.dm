// The counsel: a quiet voice beside the page that reads a prayer as it is
// written and says what the god will make of it - what each request will do,
// for whom, how gladly, and what it costs. Shown in the prayer book (book.dm).

/// What the counsel says about a prayer before it is said.
/proc/prayer_counsel_domain(mob/user)
	var/mob/living/L = user
	if(istype(L) && L.divine_domain)
		return L.divine_domain
	return user.client?.prefs?.get_selected_domain()

/proc/prayer_counsel_html(mob/user, mob/living/chosen, text, shape = PRAYER_SHAPE_TARGETED, list/summary)
	if(length(trim(text)) < PRAYER_MIN_LENGTH)
		return "<p class='dim'><i>Too few words yet to call a prayer.</i></p>"
	var/datum/domain/D = prayer_counsel_domain(user)
	var/mob/living/living_user = isliving(user) ? user : null
	var/datum/preferences/prefs = user.client?.prefs
	var/datum/patron/P = living_user ? living_user.patron : prefs?.selected_patron
	var/god = (living_user ? P?.name : prefs?.get_god_display_name()) || "your god"
	var/mob/living/carbon/human/human_user = ishuman(user) ? user : null
	var/datum/devotion/devotion = human_user?.devotion
	var/list/names = list(god)
	if(P)
		names += P.name
		names += P.titles
	if(!living_user && prefs?.uses_custom_god())
		names += prefs.get_custom_god_titles()
	var/datum/prayer_reading/R = read_prayer(text, names, D?.name)
	var/list/out = list()

	// Who is being spoken to, and how.
	if(R.invoked_god)
		out += "<p class='good'>You call [god] by name. You will be heard plainly.</p>"
	else if(R.named_domain)
		out += "<p>You speak to the [D?.name] but not to [god] by name. You may be heard.</p>"
	else
		out += "<p class='warn'>You name no one. Words sent to no one are easily lost.</p>"
	var/bold = D && (D.type in GLOB.prayer_bold_domains)
	if(R.arrogant)
		out += bold ? "<p>You speak boldly, and [god] likes boldness.</p>" : "<p class='warn'>You speak as if giving orders. [god] will not care for it.</p>"
	else if(R.humble)
		out += "<p class='good'>Your humility will be counted in your favour.</p>"
	if(R.affection && chosen != user)
		out += "<p>Love for the one you pray for colours your words.</p>"

	if(!length(R.clauses))
		out += "<p class='warn'>But you never ask for anything. Say what you want: mend, shield, strengthen, calm, smite...</p>"
		qdel(R)
		return jointext(out, "")

	// Each request.
	var/level = devotion?.level || 1
	var/base = 0.7 + 0.15 * level
	base *= R.invoked_god ? 1.25 : (R.named_domain ? 1.1 : 0.6)
	base *= prayer_shape_value(shape, "power")
	if(D && living_user && D.can_pray_here(living_user))
		base *= 1.25
	var/spread = 1 + 0.35 * (length(R.clauses) - 1)
	for(var/datum/prayer_clause/C as anything in R.clauses)
		var/asked = prayer_asking_phrase(C.intent)
		var/affinity = 1
		if(D)
			var/list/table = GLOB.prayer_domain_affinity[D.type]
			if(islist(table) && !isnull(table[C.intent]))
				affinity = table[C.intent]
			var/list/ext = GLOB.prayer_domain_affinity_ext[D.type]
			if(islist(ext) && !isnull(ext[C.intent]))
				affinity = ext[C.intent]
		if(affinity <= 0)
			if(summary)
				summary["requests"] += list(list("asked" = asked, "intent" = C.intent, "strength" = 0, "refused" = TRUE))
			out += "<p class='warn'>You ask for <b>[asked]</b>. That is not [god]'s to give; they will turn away from it.</p>"
			continue
		var/whom
		if(prayer_shape_delivers(shape))
			whom = "for whoever the [lowertext(prayer_shape_value(shape, "name"))] reaches"
		else switch(C.target_kind)
			if("self")
				whom = "for yourself"
			if("all")
				whom = "for everyone close by (it costs twice as much)"
			else
				whom = chosen ? (chosen == user ? "for yourself" : "for [chosen]") : "for whomever you choose"
		var/strength = base * affinity * C.power_mult / spread
		var/how
		if(strength < 0.3)
			how = "<span class='warn'>so faintly it may go unanswered</span>"
		else if(strength < 0.8)
			how = "grudgingly, and only a little"
		else if(strength < 1.3)
			how = "as asked"
		else if(strength < 1.9)
			how = "<span class='good'>gladly and strongly</span>"
		else
			how = "<span class='good'>with a strength that will be felt by all who see it</span>"
		if(summary)
			summary["requests"] += list(list("asked" = asked, "intent" = C.intent, "strength" = round(strength, 0.01), "refused" = FALSE, "harmful" = (C.intent in GLOB.prayer_harmful_intents)))
		var/list/info = GLOB.prayer_intent_info[C.intent]
		var/what = info ? info[1] : ""
		var/about = (C.subject && C.subject != GLOB.prayer_default_subject[C.intent] && GLOB.prayer_subject_info[C.subject]) ? " Concerning <b>[C.subject]</b>: [lowertext(GLOB.prayer_subject_info[C.subject])]" : ""
		if((C.intent in GLOB.prayer_harmful_intents) && chosen != user)
			out += "<p class='dim'>A strong-willed target may blunt this, or refuse it outright. The stronger the prayer, the harder it is to refuse.</p>"
		out += "<p><span class='ask'>You ask for <b>[asked]</b> [whom].</span> [god] would answer [how].<br><span class='dim'>[what][about]</span></p>"

	// What is offered and what it costs.
	var/sacrificed = 0
	for(var/kind in R.offerings)
		var/list/about_offering = GLOB.prayer_offering_info[kind]
		var/given = about_offering ? about_offering[1] : kind
		var/eases = (kind in GLOB.prayer_sacrifice_kinds)
		if(eases)
			sacrificed += kind == "item" ? 0.3 : R.offerings[kind]
		out += "<p>You sacrifice <b>[given]</b>. [about_offering ? about_offering[2] : ""] It is given whether or not you are answered[eases ? ", and makes the prayer both stronger and cheaper" : ""].</p>"
	var/list/relief = prayer_cost_relief(human_user)
	var/cost = round(prayer_reading_cost(R) * prayer_shape_value(shape, "cost") * relief[1] * prayer_sacrifice_discount(sacrificed))
	var/list/eased_by = relief[2]
	if(length(eased_by))
		out += "<p class='good'>The asking is eased by [english_list(eased_by)].</p>"
	if(shape != PRAYER_SHAPE_TARGETED)
		out += "<p class='dim'>Shaped as <b>[prayer_shape_value(shape, "name")]</b>: [prayer_shape_value(shape, "desc")]</p>"
	var/have = devotion?.devotion || 0
	if(summary)
		summary["cost"] = cost
		summary["have"] = devotion ? round(have) : null
		summary["eased"] = eased_by
	if(!devotion)
		out += "<p>This asks about <b>[cost]</b> devotion.</p>"
	else if(have < cost)
		out += "<p class='warn'>This asks about <b>[cost]</b> devotion; you have only [round(have)]. What you lack will weaken the answer.</p>"
	else
		out += "<p>This asks about <b>[cost]</b> of your devotion. You have [round(have)].</p>"
	if(cost >= 150)
		out += "<p class='dim'>This is a heavy asking (150 devotion or more). It will leave you <b>hollowed out</b>: most of your devotion spent at once, with little left for other prayers or miracles until it slowly returns.</p>"
	var/list/said = living_user?.prayer_history?[prayer_normalize(text)]
	if(said && world.time - said[2] < PRAYER_REPEAT_WINDOW)
		out += "<p class='warn'>You said these same words not long ago. They will mean less.</p>"
	if(length(R.clauses) > 1)
		out += "<p class='dim'>Asking for several things divides the god's attention between them.</p>"
	qdel(R)
	return jointext(out, "")
