// The Prayer guide in the encyclopedia. Pages that list words are built from
// the vocabulary itself, so the guide never falls out of date.

/obj/item/recipe_book/prayer_guide
	name = "On Prayer: A Supplicant's Companion"
	desc = "A worn little book on how to speak to the gods, and how they listen."
	wiki_name = "Prayer"
	wiki_section = "Guides"
	icon_state = "basic_book_0"
	base_icon_state = "basic_book"
	can_spawn = FALSE
	wiki_only = TRUE
	types = list(/datum/book_entry/prayer)

/datum/book_entry/prayer
	abstract_type = /datum/book_entry/prayer
	category = null

/// Groups a form = meaning list by meaning: meaning = "form, form, form".
/proc/prayer_guide_group(list/forms)
	var/list/by_meaning = list()
	for(var/form in forms)
		var/meaning = forms[form]
		if(islist(meaning))
			continue
		LAZYADD(by_meaning["[meaning]"], form)
	var/list/rows = list()
	for(var/meaning in sortList(by_meaning.Copy()))
		rows += "<li><b>[capitalize(meaning)]</b>: <i>[jointext(by_meaning[meaning], ", ")]</i></li>"
	return "<ul>[jointext(rows, "")]</ul>"

/datum/book_entry/prayer/basics
	name = "01. How Prayer Works"

/datum/book_entry/prayer/basics/inner_book_html(mob/user)
	return {"
		<div>
		<h3>Praying</h3>
		<p>Anyone with devotion has the <b>Pray</b> spell. Click the person you're praying for (or yourself), write your prayer, and speak it. Your god reads every word and decides what to do.</p>
		<p>A prayer is made of <b>requests</b>. Each request is something you ask for (heal, shield, smite...), usually something it acts on (wounds, fear, fire...), and sometimes who it's for and how much. You can make up to three requests in one prayer; each one you add splits the strength.</p>
		<h3>What makes a prayer strong</h3>
		<ul>
			<li><b>Name your god.</b> Their name or one of their titles. Naming only the domain helps a little. Naming no one weakens the prayer badly.</li>
			<li><b>Mind your tone.</b> Humble words help. Orders hurt - except with War, Trickery, Law and Forbidden gods, who respect a firm voice.</li>
			<li><b>Devotion.</b> Your devotion tier is the backbone of every prayer.</li>
			<li><b>Place.</b> Holy crosses, ritual chalk, gods' statues and your domain's sacred places make you easier to hear.</li>
			<li><b>Your mind.</b> A frayed, near-broken mind prays badly.</li>
			<li><b>The hour.</b> Sun gods are stronger by day, Moon gods at night and at the full moon, Death and Forbidden gods after dark. A blood moon favours the Forbidden and dims everyone else.</li>
			<li><b>Effort.</b> A long, careful prayer is heard a little better than a mumble.</li>
			<li><b>Love.</b> Words of love or kinship for someone else please gods of Love and the Hearth.</li>
			<li><b>Need.</b> The dying are heard first. So are the desperate praying for themselves.</li>
			<li><b>Shared faith.</b> Praying for someone of your own god helps.</li>
			<li><b>Repetition.</b> The same exact prayer said again within ten minutes loses half its strength each time.</li>
		</ul>
		<h3>What it costs</h3>
		<p>Prayer is the costliest way to ask a god for anything. Every prayer costs 20 devotion, and each request on top of that:</p>
		<ul>
			<li><b>40</b> - small mercies: light, sight, food, water, warmth, sobriety, voice, understanding, night eyes, weathering, calm, waking.</li>
			<li><b>70</b> - blessings and healing: heal, cleanse, shield, strengthen, quicken, bless, forgive, truth, courage, vigour, veil, growth, taming, mending, sleep.</li>
			<li><b>90</b> - harm and battle-fury: rage, smite, curse, weaken, bind, blind, silence, frighten, madden, sicken, disarm, fell, repel, draw near.</li>
			<li><b>120</b> - the great workings: renewal, rot, banishing, hallowing.</li>
			<li><b>400</b> - raising the dead.</li>
		</ul>
		<p>Asking for everyone nearby doubles a request's cost; "gently" and the like lower it, "utterly" and the like raise it, and "take my faith" adds 20 more. If you don't have enough devotion, you spend what you have and the whole prayer weakens to match. Weak requests are met with silence.</p>
		<p>Small spelling slips are forgiven. Swearing at your god is not.</p>
		</div>
	"}

/datum/book_entry/prayer/requests
	name = "02. What You Can Ask For"

/// Domains that answer an intent well, poorly, or not at all.
/proc/prayer_guide_domain_views(intent)
	var/list/good = list()
	var/list/bad = list()
	var/list/never = list()
	for(var/path in GLOB.divine_domains)
		var/datum/domain/D = GLOB.divine_domains[path]
		var/m = 1
		var/list/a = GLOB.prayer_domain_affinity[path]
		var/list/b = GLOB.prayer_domain_affinity_ext[path]
		if(islist(a) && !isnull(a[intent]))
			m = a[intent]
		if(islist(b) && !isnull(b[intent]))
			m = b[intent]
		if(m <= 0)
			never += D.name
		else if(m >= 1.3)
			good += D.name
		else if(m < 1)
			bad += D.name
	return list(good, bad, never)

/datum/book_entry/prayer/requests/inner_book_html(mob/user)
	var/list/forms_by_intent = list()
	for(var/form in GLOB.prayer_intents)
		LAZYADD(forms_by_intent[GLOB.prayer_intents[form]], form)
	var/list/out = list()
	var/list/intents = list()
	for(var/intent in GLOB.prayer_intent_info)
		intents += intent
	for(var/intent in intents)
		var/list/info = GLOB.prayer_intent_info[intent]
		var/list/style = prayer_style(intent)
		var/list/views = prayer_guide_domain_views(intent)
		var/list/forms = forms_by_intent[intent] || list()
		var/list/examples = forms.Copy(1, min(length(forms), 6) + 1)
		var/list/rest = length(forms) > 6 ? forms.Copy(7) : list()
		var/html = "<h3 style='color:[style[1]]'>[capitalize(intent)]</h3>"
		html += "<p>[info[1]]</p>"
		if(info[2])
			html += "<p><b>What you name changes it:</b> [info[2]]</p>"
		html += "<p><b>Cost:</b> [prayer_intent_cost(intent)] devotion (doubled for everyone nearby). "
		html += "<b>If you name nothing:</b> [GLOB.prayer_default_subject[intent] || "the target"].</p>"
		var/list/views_text = list()
		if(length(views[1]))
			views_text += "<b>Answered best by:</b> [jointext(views[1], ", ")]"
		if(length(views[2]))
			views_text += "<b>Answered poorly by:</b> [jointext(views[2], ", ")]"
		if(length(views[3]))
			views_text += "<b>Refused by:</b> [jointext(views[3], ", ")]"
		if(length(views_text))
			html += "<p>[jointext(views_text, "<br>")]</p>"
		html += "<p><b>Say it like:</b> <i>[jointext(examples, ", ")]</i></p>"
		if(length(rest))
			html += "<details><summary>...and [length(rest)] more ways</summary><p><i>[jointext(rest, ", ")]</i></p></details>"
		out += html
	return {"
		<div>
		<p>Each request below says what it does, what naming a subject changes, what it costs, and which gods answer it best. Numbers are for an ordinary prayer (strength about 1); a weak prayer does less, a mighty one more. Durations stretch with words like <i>for a time</i> or <i>until dawn</i>.</p>
		[jointext(out, "<hr>")]
		</div>
	"}

/datum/book_entry/prayer/subjects
	name = "03. What It Acts On"

/datum/book_entry/prayer/subjects/inner_book_html(mob/user)
	var/list/forms_by_subject = list()
	for(var/form in GLOB.prayer_subjects)
		LAZYADD(forms_by_subject[GLOB.prayer_subjects[form]], form)
	var/list/rows = list()
	for(var/subject in GLOB.prayer_subject_info)
		var/list/forms = forms_by_subject[subject] || list()
		rows += "<li><b>[capitalize(subject)]</b> - [GLOB.prayer_subject_info[subject]]<br><i>[jointext(forms, ", ")]</i></li>"
	return {"
		<div>
		<p>Name what a request should act on and it changes what happens - <i>heal the bones</i> sets fractures, <i>heal the burns</i> soothes burns. Each request's page lists what its subjects do. Some subjects act on the world rather than a body: hold the water, weapon, gear or food you want blessed or mended, or stand by the soil you want to grow.</p>
		<ul>[jointext(rows, "")]</ul>
		</div>
	"}

/datum/book_entry/prayer/who_and_how
	name = "04. For Whom, and How Much"

/datum/book_entry/prayer/who_and_how/inner_book_html(mob/user)
	var/list/q = list()
	for(var/form in GLOB.prayer_qualifiers)
		var/list/v = GLOB.prayer_qualifiers[form]
		q += "<li><i>[form]</i> - strength x[v[1]], cost x[v[2]], duration x[v[3]]</li>"
	return {"
		<div>
		<h3>For whom</h3>
		<p>By default a request is for whoever you clicked. Harmful requests never fall on you by accident.</p>
		[prayer_guide_group(GLOB.prayer_targets)]
		<h3>How much, how long</h3>
		<ul>[jointext(q, "")]</ul>
		</div>
	"}

/datum/book_entry/prayer/offerings
	name = "05. Offerings and Tone"

/datum/book_entry/prayer/offerings/inner_book_html(mob/user)
	var/list/by_kind = list()
	for(var/form in GLOB.prayer_offerings)
		var/list/v = GLOB.prayer_offerings[form]
		LAZYADD(by_kind[v[1]], "<i>[form]</i>")
	var/list/rows = list()
	for(var/kind in GLOB.prayer_offering_info)
		if(!by_kind[kind])
			continue
		var/list/info = GLOB.prayer_offering_info[kind]
		var/eases = (kind in GLOB.prayer_sacrifice_kinds) ? " <b>Makes the prayer cheaper.</b>" : ""
		rows += "<li><b>Sacrificing [info[1]]</b> - [info[2]][eases]<br>Say: [jointext(by_kind[kind], ", ")]</li>"
	return {"
		<div>
		<h3>Offerings</h3>
		<p>You can give something of yourself with a prayer. Whatever you sacrifice is taken the moment you pray, whether or not you are answered. In return the answer is stronger, and a sacrifice of your body or of something you hold also lowers the devotion the prayer costs - up to 60% less for a great enough sacrifice.</p>
		<p>A gift held in hand pleases more when it fits the god: coin for Trade and Law, food for Harvest and Hearth, weapons for War and Craft, books for Knowledge, candles for Sun, Moon and Death, gems, flowers, bones and organs for the gods who like such things.</p>
		<ul>[jointext(rows, "")]</ul>
		<h3>Humble words</h3>
		<p><i>[jointext(GLOB.prayer_humble_words, ", ")]</i></p>
		<h3>Demanding words</h3>
		<p><i>[jointext(GLOB.prayer_arrogant_words, ", ")]</i></p>
		<h3>Words of love</h3>
		<p><i>[jointext(GLOB.prayer_affection_words, ", ")]</i></p>
		</div>
	"}

/datum/book_entry/prayer/domains
	name = "06. What Each Domain Favours"

/datum/book_entry/prayer/domains/inner_book_html(mob/user)
	var/list/out = list()
	for(var/path in GLOB.divine_domains)
		var/datum/domain/D = GLOB.divine_domains[path]
		var/list/merged = list()
		var/list/a = GLOB.prayer_domain_affinity[path]
		var/list/b = GLOB.prayer_domain_affinity_ext[path]
		if(islist(a))
			merged += a
		if(islist(b))
			merged += b
		var/list/good = list()
		var/list/bad = list()
		var/list/never = list()
		for(var/intent in merged)
			var/m = merged[intent]
			if(m <= 0)
				never += intent
			else if(m >= 1.3)
				good += intent
			else if(m < 1)
				bad += intent
		out += "<h3>[D.name]</h3><p>Pray at: [D.pray_hint].<br><b>Answers well:</b> [length(good) ? jointext(good, ", ") : "-"]<br><b>Answers poorly:</b> [length(bad) ? jointext(bad, ", ") : "-"][length(never) ? "<br><b>Refuses:</b> [jointext(never, ", ")]" : ""]</p>"
	return "<div>[jointext(out, "")]</div>"

/datum/book_entry/prayer/examples
	name = "07. Examples"

/datum/book_entry/prayer/examples/inner_book_html(mob/user)
	return {"
		<div>
		<h3>Some prayers that work</h3>
		<ul>
			<li><i>"Merciful Pestrah, I beg you, mend the wounds of this one and stop the bleeding."</i> - heals wounds and closes bleeds.</li>
			<li><i>"Sun-Faced Astratha, smite the unholy dead before me!"</i> - holy fire, doubled on the undead.</li>
			<li><i>"Mother of the Sea, take my blood and calm the fear in all of us."</i> - costs blood, calms everyone nearby.</li>
			<li><i>"Lady of the Harvest, feed my children and bless this house."</i> - feeds and blesses those around you.</li>
			<li><i>"Holy Mother, renew this child's wounds through the night and give her courage."</i> - lasting healing and a steady nerve.</li>
			<li><i>"Gragghar, fill me with fury and knock down my enemy!"</i> - battle rage, then a foe thrown down.</li>
			<li><i>"Noctural, cloak me in shadow and give me night eyes."</i> - fading from sight and seeing in the dark.</li>
			<li><i>"Zennar, I offer this coin; let me understand their tongue."</i> - a paid-for gift of languages.</li>
			<li><i>"Kind Dendhor, bless the fields."</i> - stand by tilled soil; it drinks and feeds.</li>
			<li><i>"Zyzo, let them rot and madden their thoughts, I offer this bone."</i> - the Forbidden at work.</li>
		</ul>
		</div>
	"}

/datum/book_entry/prayer/shapes
	name = "08. Shaping a Prayer"

/datum/book_entry/prayer/shapes/inner_book_html(mob/user)
	var/list/rows = list()
	for(var/shape in GLOB.prayer_shapes)
		var/list/info = GLOB.prayer_shapes[shape]
		rows += "<li><b>[info["name"]]</b> - [info["desc"]]<br><i>Strength x[info["power"]], devotion x[info["cost"]], time to say x[info["time"]][info["clicks"] ? ", reaches [info["range"]] steps" : ", no aiming"].</i></li>"
	return {"
		<div>
		<h3>Prayers known by heart</h3>
		<p>You can learn up to ten prayers by heart under <b>Prayer Presets</b> (the IC tab, or the character menu). With Pray readied, the <b>Toggle Spell Alt Mode</b> key cycles between writing freely and saying one of them. A prayer can also be kept as its own spell, with its own name and icon.</p>
		<p>A prayer said by heart is still read word by word. It is only as good as it is written - and saying the same words over and over still wears them thin.</p>
		<h3>Shapes</h3>
		<p>Each prayer known by heart has a <b>shape</b>: how it reaches the world. The words decide what happens; the shape decides who it happens to. A healing prayer cast as a bolt heals whoever it strikes; a smiting prayer cast as a burst smites everyone around you. Wider or quicker shapes are weaker or cost more.</p>
		<ul>[jointext(rows, "")]</ul>
		<p>Harmful requests in wide shapes spare the one praying. Helpful ones do not choose sides: a healing burst heals your foes as well.</p>
		<h3>Saying a prayer by heart</h3>
		<p>A prayer known by heart is cast like any other spell: ready it, then <b>hold</b> the click on your target while you say it under your breath, and <b>release</b> to let it go. The longer the prayer and the wider its shape, the longer the hold, and you walk slowly while holding it. Instant shapes (Upon myself, Burst around me) are held without aiming.</p>
		<p>A prayer shaped as a <b>Bolt of light</b> and kept as its own spell can be switched to an <b>arc</b> with the Toggle Spell Alt Mode key: it flies over heads and low walls instead of straight.</p>
		</div>
	"}

/datum/book_entry/prayer/will
	name = "09. Will, Holy Things and Sacrifice"

/datum/book_entry/prayer/will/inner_book_html(mob/user)
	return {"
		<div>
		<h3>Setting your will against a prayer</h3>
		<p>When someone prays <b>harm</b> upon you - smite, curse, bind, blind, silence, sleep, frighten, madden, sicken, rot, disarm, fell, repel or draw - your <b>Willpower</b> stands in the way.</p>
		<ul>
			<li><b>Refusing it outright.</b> Each point of Willpower above 10 gives a 6% chance to break the prayer entirely (at most 60%). A strong prayer is harder to refuse: every point of prayer strength above ordinary takes 25% off that chance. Those around see the word <i>RESISTED</i> rise from you.</li>
			<li><b>Blunting it.</b> If it is not refused, each point of Willpower above 10 weakens it by 4%, down to 60% of its strength. A weak will makes it worse: below 10, it lands up to 20% harder.</li>
		</ul>
		<p>Your own prayers upon yourself, and helpful prayers from others, are never resisted.</p>
		<h3>Holy things lighten the asking</h3>
		<p>Holy things carried in the right way lower the devotion a prayer costs, up to 35% in all:</p>
		<ul>
			<li>A holy amulet worn at the neck - 15% less.</li>
			<li>A holy symbol held in hand - 10% less.</li>
			<li>The holy book held in hand - 10% less.</li>
			<li>If the amulet you wear belongs to one of your domain's gods (or to all of them) - 5% more on top.</li>
		</ul>
		<h3>Sacrifice lightens it further</h3>
		<p>Sacrificing your blood, your strength, your flesh, your sight, or something you hold makes the answer stronger <b>and</b> the prayer cheaper - up to 60% less. See <i>05. Offerings and Tone</i> for what each sacrifice takes from you and how to say it.</p>
		<p>The counsel beside your prayer always shows the cost after all of this.</p>
		<h3>Hollowed out</h3>
		<p>A prayer that asks 150 devotion or more leaves you <b>hollowed out</b>: so much of your devotion spent at once that little remains for other prayers or miracles until it slowly returns. It is a warning, not an ailment.</p>
		</div>
	"}
