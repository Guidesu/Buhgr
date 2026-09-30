// Reads a written prayer into clauses and works out how strongly it is answered.

#define PRAYER_MAX_CLAUSES 3

/datum/prayer_clause
	var/intent
	var/subject
	/// "self", "chosen" or "all"
	var/target_kind
	var/power_mult = 1
	var/cost_mult = 1
	var/duration_mult = 1
	/// Final strength after every modifier.
	var/power = 0

/datum/prayer_reading
	var/text
	var/list/datum/prayer_clause/clauses = list()
	var/invoked_god = FALSE
	var/named_domain = FALSE
	var/humble = 0
	var/arrogant = 0
	/// kind = bonus
	var/list/offerings = list()
	var/profane = FALSE
	var/affection = 0

/datum/prayer_reading/Destroy()
	QDEL_LIST(clauses)
	return ..()

/// Lowercases, turns punctuation into spaces and pads with spaces so every
/// form can be matched as " form ".
/proc/prayer_normalize(text)
	text = LOWER_TEXT(text)
	var/static/regex/strip = regex(@"[^a-z0-9'\s]", "g")
	text = strip.Replace(text, " ")
	var/static/regex/spaces = regex(@"\s+", "g")
	text = spaces.Replace(text, " ")
	return " [trim(text)] "

/// Finds every form from `forms` in `text`, longest first. Returns
/// list(list(position, key, meaning), ...) sorted by position, and blanks the
/// matched spans in text (passed by reference through a one-item list).
/proc/prayer_find(list/text_ref, list/forms)
	var/text = text_ref[1]
	var/list/sorted = list()
	for(var/form in forms)
		sorted += form
	sortTim(sorted, GLOBAL_PROC_REF(cmp_prayer_form_length))
	var/list/found = list()
	for(var/form in sorted)
		var/needle = " [form] "
		var/pos = findtext(text, needle)
		while(pos)
			found += list(list(pos, form, forms[form]))
			// Blank the word(s) but keep the surrounding spaces as boundaries.
			var/blank = ""
			for(var/i in 1 to length(form))
				blank += "#"
			text = copytext(text, 1, pos + 1) + blank + copytext(text, pos + 1 + length(form))
			pos = findtext(text, needle, pos + 1)
	text_ref[1] = text
	sortTim(found, GLOBAL_PROC_REF(cmp_prayer_found_position))
	return found

/// Every single word the vocabulary knows, built once.
/proc/prayer_known_words()
	var/static/list/known
	if(known)
		return known
	known = list()
	var/list/sources = list(GLOB.prayer_intents, GLOB.prayer_subjects, GLOB.prayer_targets, GLOB.prayer_qualifiers, GLOB.prayer_offerings)
	for(var/list/L in sources)
		for(var/form in L)
			for(var/word in splittext(form, " "))
				if(length(word) >= 4)
					known[word] = TRUE
	for(var/list/L in list(GLOB.prayer_humble_words, GLOB.prayer_arrogant_words, GLOB.prayer_affection_words))
		for(var/form in L)
			for(var/word in splittext(form, " "))
				if(length(word) >= 4)
					known[word] = TRUE
	return known

/// Edit distance where swapping two neighbouring letters counts as one slip
/// ("strenght"), giving up early past `limit`.
/proc/prayer_distance(a, b, limit)
	var/la = length(a)
	var/lb = length(b)
	if(abs(la - lb) > limit)
		return limit + 1
	var/list/prev2
	var/list/prev = list()
	for(var/j in 0 to lb)
		prev += j
	for(var/i in 1 to la)
		var/list/cur = list(i)
		var/row_best = i
		for(var/j in 1 to lb)
			var/cost = (copytext(a, i, i + 1) == copytext(b, j, j + 1)) ? 0 : 1
			var/v = min(prev[j + 1] + 1, cur[j] + 1, prev[j] + cost)
			if(prev2 && i > 1 && j > 1 && copytext(a, i, i + 1) == copytext(b, j - 1, j) && copytext(a, i - 1, i) == copytext(b, j, j + 1))
				v = min(v, prev2[j - 1] + 1)
			cur += v
			row_best = min(row_best, v)
		if(row_best > limit)
			return limit + 1
		prev2 = prev
		prev = cur
	return prev[lb + 1]

/// Mends small spelling slips ("strenght", "persistance") against the known words.
/proc/prayer_correct_spelling(text)
	var/list/known = prayer_known_words()
	var/list/words = splittext(trim(text), " ")
	for(var/i in 1 to length(words))
		var/word = words[i]
		// Short words are too often real words of their own ("fight" is not "light").
		if(length(word) < 6 || known[word])
			continue
		var/limit = length(word) >= 9 ? 2 : 1
		var/best
		var/best_d = limit + 1
		for(var/candidate in known)
			if(copytext(candidate, 1, 2) != copytext(word, 1, 2))
				continue
			var/d = prayer_distance(word, candidate, limit)
			if(d < best_d)
				best_d = d
				best = candidate
				if(d == 1)
					break
		if(best)
			words[i] = best
	return " [jointext(words, " ")] "

/proc/cmp_prayer_form_length(a, b)
	return length(b) - length(a)

/proc/cmp_prayer_found_position(list/a, list/b)
	return a[1] - b[1]

/// Reads the prayer. god_names are the names and titles that count as invoking the god.
/proc/read_prayer(raw_text, list/god_names, domain_name)
	var/datum/prayer_reading/R = new
	R.text = raw_text
	var/list/ref = list(prayer_correct_spelling(prayer_normalize(raw_text)))

	for(var/name in god_names)
		if(findtext(ref[1], " [LOWER_TEXT(name)]"))
			R.invoked_god = TRUE
			break
	if(domain_name && findtext(ref[1], " [LOWER_TEXT(domain_name)]"))
		R.named_domain = TRUE

	// Offerings and tone first: they share words with targets ("my blood").
	for(var/list/hit in prayer_find(ref, GLOB.prayer_offerings))
		var/list/offer = hit[3]
		R.offerings[offer[1]] = max(R.offerings[offer[1]], offer[2])
	var/list/tone_ref = list(ref[1])
	var/list/humble_forms = list()
	for(var/w in GLOB.prayer_humble_words)
		humble_forms[w] = TRUE
	R.humble = length(prayer_find(tone_ref, humble_forms))
	var/list/arrogant_forms = list()
	for(var/w in GLOB.prayer_arrogant_words)
		arrogant_forms[w] = TRUE
	R.arrogant = length(prayer_find(tone_ref, arrogant_forms))
	var/list/affection_forms = list()
	for(var/w in GLOB.prayer_affection_words)
		affection_forms[w] = TRUE
	R.affection = length(prayer_find(tone_ref, affection_forms))

	// Now the clauses: every intent opens one; subjects, targets and
	// qualifiers attach to the nearest intent before them.
	var/list/intents = prayer_find(ref, GLOB.prayer_intents)
	var/list/subjects = prayer_find(ref, GLOB.prayer_subjects)
	var/list/targets = prayer_find(ref, GLOB.prayer_targets)
	var/list/qualifiers = prayer_find(ref, GLOB.prayer_qualifiers)
	var/list/intent_positions = list()
	var/last_form

	for(var/list/hit in intents)
		if(length(R.clauses) >= PRAYER_MAX_CLAUSES)
			break
		// The very same words twice in a row are one request, said twice.
		if(length(R.clauses) && hit[2] == last_form)
			continue
		last_form = hit[2]
		var/datum/prayer_clause/C = new
		C.intent = hit[3]
		// Phrases like "give me strength" or "stop the bleeding" carry their own target or subject.
		if(findtext(" [hit[2]] ", " me "))
			C.target_kind = "self"
		C.subject = GLOB.prayer_intent_implies[hit[2]]
		R.clauses += C
		intent_positions += hit[1]

	for(var/list/hit in subjects)
		var/datum/prayer_clause/C = prayer_owning_clause(R, intent_positions, hit[1])
		if(C && !C.subject)
			C.subject = hit[3]
	for(var/list/hit in targets)
		var/datum/prayer_clause/C = prayer_owning_clause(R, intent_positions, hit[1])
		if(C && !C.target_kind)
			C.target_kind = hit[3]
	for(var/list/hit in qualifiers)
		var/datum/prayer_clause/C = prayer_owning_clause(R, intent_positions, hit[1])
		if(!C)
			continue
		var/list/q = hit[3]
		C.power_mult *= q[1]
		C.cost_mult *= q[2]
		C.duration_mult *= q[3]

	var/datum/prayer_clause/previous
	for(var/datum/prayer_clause/C as anything in R.clauses)
		if(!C.subject)
			C.subject = GLOB.prayer_default_subject[C.intent]
		if(!C.target_kind)
			C.target_kind = previous?.target_kind || "chosen"
		// Nobody asks to be smitten themselves by accident ("smite the dead before me").
		if(C.target_kind == "self" && (C.intent in list("smite", "curse", "weaken", "bind", "blind", "silence")))
			C.target_kind = "chosen"
		previous = C
	return R

/// The clause whose intent comes last before `pos`, or the first clause for
/// words that come before any intent ("my wounds, heal them").
/proc/prayer_owning_clause(datum/prayer_reading/R, list/intent_positions, pos)
	if(!length(R.clauses))
		return null
	var/owner = 1
	for(var/i in 1 to length(intent_positions))
		if(intent_positions[i] <= pos)
			owner = i
	return R.clauses[owner]

#undef PRAYER_MAX_CLAUSES
