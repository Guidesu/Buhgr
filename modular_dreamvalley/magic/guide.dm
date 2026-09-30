// Encyclopedia tutorials for magic and for guards, alongside the Prayer guide.

/obj/item/recipe_book/magic_guide
	name = "On the Weave: A Mage's Companion"
	desc = "A scorched, much-annotated primer on working magic without dying of it."
	wiki_name = "Magic Guide"
	wiki_section = "Guides"
	icon_state = "basic_book_0"
	base_icon_state = "basic_book"
	can_spawn = FALSE
	wiki_only = TRUE
	types = list(/datum/book_entry/magic_guide)

/datum/book_entry/magic_guide
	abstract_type = /datum/book_entry/magic_guide
	category = null

/datum/book_entry/magic_guide/basics
	name = "01. Casting a Spell"

/datum/book_entry/magic_guide/basics/inner_book_html(mob/user)
	return {"
		<div>
		<h3>Aspects and spells</h3>
		<p>A mage attunes to <b>aspects</b> - disciplines like Pyromancy, Cryomancy or Kinesis - and each grants its spells. Arcane spells cost energy or stamina, and most are charged by holding the click on a target and released to cast. Many have an alternate mode on the <b>Toggle Spell Alt Mode</b> key (Shift+G by default).</p>
		<h3>The spell check</h3>
		<p>Every arcane spell rolls a <b>d20</b> when cast, plus:</p>
		<ul>
			<li>half your Intelligence above 10 (or minus, below 10),</li>
			<li>your arcane skill level,</li>
			<li>minus 2 for each tier of the spell above the first,</li>
			<li>minus 1 for every 20 Strain,</li>
			<li>plus 2 in a place of power,</li>
			<li>plus 1 to 3 for a held staff or implement, and 1 more for an arcyne book,</li>
			<li>plus or minus your spell's mercurial quirk,</li>
			<li>plus whatever you have spellburned.</li>
		</ul>
		<p><b>Below 6</b>, the spell slips away and is lost (you still take half its Strain). <b>Below 2</b>, it also misfires. A <b>natural 1</b> always misfires, and may corrupt you. A <b>natural 20</b>, or a total of <b>22 or more</b>, is mastery: the spell costs no Strain at all.</p>
		<p>Shift-click (examine) any arcane spell to see your exact bonus, the rolls that lose it, and its quirk in your hands.</p>
		</div>
	"}

/datum/book_entry/magic_guide/strain
	name = "02. Strain"

/datum/book_entry/magic_guide/strain/inner_book_html(mob/user)
	return {"
		<div>
		<p>Every arcane spell adds <b>Strain</b> (0 to 100): more for higher tiers and costlier spells, less for high Intelligence, half or less in a place of power. It fades by 1 every two seconds - four times faster asleep, three times faster in a place of power. An alert shows it; examine the alert for the thresholds.</p>
		<ul>
			<li><b>30+ strained</b> - aches and headaches.</li>
			<li><b>60+ overdrawn</b> - every spell also costs blood, and nosebleeds come.</li>
			<li><b>85+ on the brink</b> - burns and blurred sight.</li>
			<li><b>100</b> - a <b>surge</b>. The next spell never happens: everything breaks out of you at once. 25 burn damage, knocked down, a hit to your sanity, and everyone next to you burned. Strain falls to 50.</li>
		</ul>
		<p>Prayers and miracles never strain. Only the Weave does.</p>
		</div>
	"}

/datum/book_entry/magic_guide/wild
	name = "03. Misfires, Corruption, Spellburn"

/datum/book_entry/magic_guide/wild/inner_book_html(mob/user)
	var/list/marks = list()
	for(var/id in GLOB.arcane_corruptions)
		var/list/info = GLOB.arcane_corruptions[id]
		var/list/stats = info[2]
		var/list/changes = list()
		for(var/stat_key in stats)
			changes += "[stats[stat_key] > 0 ? "+" : ""][stats[stat_key]] [stat_key]"
		marks += "<li>[info[1]][length(changes) ? " <i>([jointext(changes, ", ")])</i>" : ""]</li>"
	var/list/quirks = list()
	for(var/id in GLOB.mercurial_quirks)
		var/list/q = GLOB.mercurial_quirks[id]
		quirks += "<li>[q[1]]</li>"
	return {"
		<div>
		<h3>Misfires</h3>
		<p>A misfire rolls one of eight: sparks burn your hands; a blinding flash; you are thrown down; you glow a strange colour for a minute; frost floods your body; the spell leaps to strike someone near you; your clothes catch fire; or the working coils back and adds 15 Strain.</p>
		<h3>Corruption</h3>
		<p>A natural 1 has a 25% chance to leave a permanent mark - 50% if you were already strained. Others can see it when they look at you. Some change you:</p>
		<ul>[jointext(marks, "")]</ul>
		<h3>Spellburn</h3>
		<p>The <b>Spellburn</b> verb (Spells tab) burns 1 to 5 points of Strength, Constitution or Speed into your next spell check, one for one. The points come back in ten minutes, and it hurts.</p>
		<h3>Mercurial magic</h3>
		<p>About half of each mage's spells carry a quirk, fixed for that mage and that spell. It could be:</p>
		<ul>[jointext(quirks, "")]</ul>
		</div>
	"}

/datum/book_entry/magic_guide/places
	name = "04. Places of Power and Mediums"

/datum/book_entry/magic_guide/places/inner_book_html(mob/user)
	return {"
		<div>
		<h3>Places of power</h3>
		<ul>
			<li>Within three steps of a <b>ley stone</b>.</li>
			<li>Standing on or next to a drawn <b>arcyne rune</b>.</li>
			<li>Inside a <b>mage's tower</b> or the magician's quarters.</li>
		</ul>
		<p>There, spells strain half as much or less, spell checks get +2, Strain drains three times faster, and incantations are stronger.</p>
		<h3>Mediums</h3>
		<p>Hold what you cast through:</p>
		<ul>
			<li><b>Staff, wand or implement</b> (lesser, greater, grand) - +1, +2 or +3 to every spell check; incantations 20 / 27.5 / 35% stronger and cheaper.</li>
			<li><b>Arcyne book</b> in hand - +1 to spell checks; incantations 10% stronger and cheaper. Stacks with an implement.</li>
		</ul>
		</div>
	"}

/datum/book_entry/magic_guide/incant
	name = "05. Incantations and Latin"

/datum/book_entry/magic_guide/incant/inner_book_html(mob/user)
	var/list/aspect_rows = list()
	for(var/aspect_type in GLOB.incantation_aspect_affinity)
		var/datum/magic_aspect/A = aspect_type
		var/list/table = GLOB.incantation_aspect_affinity[aspect_type]
		var/list/favours = list()
		for(var/intent in table)
			favours += "[intent] x[table[intent]]"
		aspect_rows += "<li><b>[initial(A.name)]</b>: [jointext(favours, ", ")]</li>"
	var/list/latin_intents = list()
	for(var/form in GLOB.prayer_intents)
		if(form in GLOB.latin_forms)
			latin_intents += "<i>[form]</i> ([GLOB.prayer_intents[form]])"
	var/list/latin_subjects = list()
	for(var/form in GLOB.prayer_subjects)
		if(form in GLOB.latin_forms)
			latin_subjects += "<i>[form]</i> ([GLOB.prayer_subjects[form]])"
	var/list/latin_targets = list()
	for(var/form in GLOB.prayer_targets)
		if(form in GLOB.latin_forms)
			latin_targets += "<i>[form]</i> ([GLOB.prayer_targets[form]])"
	return {"
		<div>
		<h3>Incant</h3>
		<p>Every mage has <b>Incant</b>: write your own spell in plain words, the way a priest writes a prayer - <i>"Fire, strike this foe!"</i>, <i>"Stone, shield me."</i>, <i>"Take my blood and throw them all back."</i> It understands every request the Prayer guide lists, except the ones only gods grant (raise, bless, forgive, hallow, renew). It costs <b>energy</b>, rolls a spell check and adds Strain like any spell.</p>
		<p>Strength comes from your arcane skill and Intelligence, your medium, a place of power, how much Strain you already carry, and your aspects. Unfavoured requests work at 70%; healing, cleansing, calming and banishing work poorly. Your aspects favour:</p>
		<ul>[jointext(aspect_rows, "")]</ul>
		<p>The <b>Incantations</b> verb (IC tab) keeps up to ten by heart, with shapes, icons and their own spell buttons, exactly like saved prayers. Incant's alt mode cycles them.</p>
		<h3>Latin</h3>
		<p>The Weave answers the old tongue better: each Latin word adds <b>5%</b> power to an incantation, up to <b>30%</b>. You can write the whole working in Latin - <i>"Invoco ignem, feri hostem magna vi!"</i> Prayers understand Latin too, without the bonus.</p>
		<p><b>Requests:</b> [jointext(latin_intents, ", ")]</p>
		<p><b>What it acts on:</b> [jointext(latin_subjects, ", ")]</p>
		<p><b>Who:</b> [jointext(latin_targets, ", ")]</p>
		<p><b>How much:</b> <i>maxime, magna vi, toto robore</i> (stronger), <i>leniter, paulum</i> (gentler), <i>statim, celeriter</i> (at once), <i>diu, in aeternum, usque ad lucem</i> (longer).</p>
		<p><b>Sacrifices:</b> <i>cape sanguinem meum</i> (blood), <i>cape vires meas</i> (strength), <i>carnem meam</i> (flesh), <i>oculos meos</i> (sight), <i>accipe hoc</i> (what you hold).</p>
		<p><b>Flourishes</b> that count as Latin: <i>invoco, voco, fiat, in nomine, ex nihilo, arcanum, potestas, ego sum, veni vidi vici</i> and others.</p>
		</div>
	"}

// --- Guards --------------------------------------------------------------------------

/obj/item/recipe_book/guard_guide
	name = "On Guards: The Fighter's Stances"
	desc = "Woodcut figures in every guard, and marginal notes on what each is good for."
	wiki_name = "Guards"
	wiki_section = "Guides"
	icon_state = "basic_book_0"
	base_icon_state = "basic_book"
	can_spawn = FALSE
	wiki_only = TRUE
	types = list(/datum/book_entry/guard_guide)

/datum/book_entry/guard_guide
	abstract_type = /datum/book_entry/guard_guide
	category = null

/datum/book_entry/guard_guide/basics
	name = "01. Taking a Guard"

/datum/book_entry/guard_guide/basics/inner_book_html(mob/user)
	return {"
		<div>
		<p>Whenever you hold a weapon you have <b>journeyman</b> skill or better with, the <b>Take Guard</b> button appears; put the weapon away and it goes. Ready it, press <b>Toggle Spell Alt Mode</b> (Shift+G) to cycle the guards your weapon knows - or No Guard - and click to take it. The chosen guard shows on the button.</p>
		<p>While you hold a guard, a badge above your head shows it to everyone: the weapon drawn in the guard's pose, on a plate coloured by what the guard is for - <span style='color:#b2362c'>red</span> for offence, <span style='color:#3460aa'>blue</span> for defence, <span style='color:#a8842c'>gold</span> for balance, <span style='color:#3a8a48'>green</span> for speed, <span style='color:#288a8e'>teal</span> for evasion. A fighter who can read guards knows what is coming.</p>
		<p>A guard lasts until you change to a weapon of another kind, fall, pass out, or take No Guard. You need journeyman skill with <i>that</i> weapon.</p>
		<ul>
			<li><b>Parry / dodge</b> - added to your chance to parry or dodge.</li>
			<li><b>Foe's parry &amp; dodge</b> - how much harder your blows are to stop: taken off the parry and dodge chance of whoever you attack. A guard that gives "foe's parry &amp; dodge -10" makes every foe you strike 10 points worse at parrying or dodging you.</li>
			<li><b>Damage</b> - multiplies the force of your blows.</li>
			<li><b>Swings</b> - how long between blows.</li>
		</ul>
		<p>A guard's <b>strengths</b> grow with skill: x1.25 at expert, x1.5 at master, x1.75 at legendary. Its weaknesses stay as they are. Guards stack with the right-click intents (strong, swift, aimed...).</p>
		</div>
	"}

/datum/book_entry/guard_guide/list_all
	name = "02. Every Guard"

/datum/book_entry/guard_guide/list_all/inner_book_html(mob/user)
	var/list/out = list()
	for(var/skill_type in GLOB.weapon_guards)
		var/datum/skill/S = skill_type
		out += "<h3>[initial(S.name)]</h3><ul>"
		for(var/datum/guard/G as anything in GLOB.weapon_guards[skill_type])
			out += "<li><b>[G.name]</b> - [G.desc]<br><i>[G.summary()]</i></li>"
		out += "</ul>"
	return "<div>[jointext(out, "")]</div>"
