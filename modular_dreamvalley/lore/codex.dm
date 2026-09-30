// The Codex of Palimpseste: the setting's reference, in the encyclopedia.
// Lists (domains, gods, lands, tongues, aspects) are built from the game's own
// data, so the book never disagrees with what players can pick.

/obj/item/recipe_book/palimpseste_codex
	name = "A Traveller's Codex of Palimpseste"
	desc = "A fat, much-corrected book on the world as it is, as far as anyone can agree."
	wiki_name = "Palimpseste"
	wiki_section = "Lore"
	icon_state = "basic_book_0"
	base_icon_state = "basic_book"
	can_spawn = FALSE
	wiki_only = TRUE
	types = list(/datum/book_entry/codex)

/datum/book_entry/codex
	abstract_type = /datum/book_entry/codex
	category = null

// --- 01 ---------------------------------------------------------------------------

/datum/book_entry/codex/world
	name = "01. The World"

/datum/book_entry/codex/world/inner_book_html(mob/user)
	return {"
		<div>
		<h3>A scraped page</h3>
		<p>A palimpsest is a page scraped clean and written over, so many times that the old ink shows through the new. The world is called that because it is one. Lands arrived here from somewhere else - other worlds, other planes, nobody agrees - and settled one over another like silt. Each came with its own history, its own gods and its own story of creation, and each woke up certain it had always been here.</p>
		<p>Nobody in Palimpseste thinks of themselves as living on a patch. A Vyrlander lives in the Vyrlands, which have always been there. It is only at the edges that the truth gets awkward.</p>
		<h3>Seams</h3>
		<p>Where two lands meet there is a <b>seam</b>. Some are gentle: pine gives way to olive trees over a morning's walk and nobody notices. Some are not: a road runs into a cliff, a river runs uphill for a stretch, a ruin is older than the hill it stands on. Border towns often keep two calendars and two sets of weights because the lands on either side never agreed how long a year or a pound should be.</p>
		<p>Seams move. Not often and not far, but enough that maps go out of date. Lately they have been moving more - shepherds find new cliffs, fishermen pull up fish nobody can name, stars change over the hills. Most people blame drink. The ones who live on a seam don't.</p>
		<h3>The Hinge</h3>
		<p>Somewhere in the middle of it all is a city without a sky, where any doorway may open onto anywhere. Its people learned how the world was made as children and find the rest of Palimpseste touchingly naive about it. Getting there is easy. Getting there on purpose is not.</p>
		<h3>The Stitching Sea</h3>
		<p>Between the larger lands lie seas that belong to none of them. Sailors call them all the Stitching Sea, as if it were one water. Charts of it are guesswork and pilots are paid accordingly.</p>
		<h3>Where you are</h3>
		<p>There is no one centre to Palimpseste. A story might start in a Skarnheim longhall, a Conjunct village, a caravan camp in the Seamvale or a muddy town under Azure Peak. Wherever it starts, you will not be the only stranger there.</p>
		</div>
	"}

// --- 02 ---------------------------------------------------------------------------

/datum/book_entry/codex/history
	name = "02. How It Came to Be"

/datum/book_entry/codex/history/inner_book_html(mob/user)
	return {"
		<div>
		<p><i>Every land has its own history, and most of them start with its own gods making it. What follows is what the scholars of the Hinge teach, and they are not neutral either.</i></p>
		<h3>Before counting</h3>
		<p>Nobody knows what was here before the first land. The Hinge calls it the Blank and leaves it at that. Some say it was an empty sea; some say it was nothing at all; a few say it was another world entirely, scraped away to make room.</p>
		<h3>The Settling</h3>
		<p>Lands arrived one after another over a span nobody can measure, because each brought its own calendar. The oldest seams - in the deep south and under the Hinge - are worn smooth and hard to find. The newest are raw. Every land remembers its arrival as its creation, if it remembers anything at all.</p>
		<h3>The Crowding</h3>
		<p>Once there were enough lands that they pressed against each other, trade began, and so did war. Tongues mixed into Seamspeak along the borders. Gods met other gods who claimed the same jobs, and priests started talking about <b>domains</b> so they could argue about something else. Most of what people think of as history happened in this age: empires, crusades, plagues, the fall of this crown and the rise of that one, all of it inside lands that each think they are the whole world.</p>
		<h3>The Restless Seams</h3>
		<p>This is now. Seams are moving more than anyone's grandparents remember. New ground appears; old ground goes quiet. Some say another land is on its way in. Some say one is on its way out. The Hinge says it has seen this before and will not say how it ended.</p>
		</div>
	"}

// --- 03 ---------------------------------------------------------------------------

/datum/book_entry/codex/gods
	name = "03. Gods and Domains"

/datum/book_entry/codex/gods/inner_book_html(mob/user)
	var/list/rows = list()
	for(var/path in GLOB.divine_domains)
		var/datum/domain/D = GLOB.divine_domains[path]
		var/list/names = list()
		for(var/god_type in D.gods)
			var/datum/patron/P = GLOB.patronlist[god_type]
			if(P)
				names += P.name
		rows += "<li><b>[D.name]</b> - [D.desc][length(names) ? "<br><i>Held by, among others: [jointext(names, ", ")].</i>" : ""]</li>"
	return {"
		<div>
		<h3>What a god is</h3>
		<p>The gods are real. They answer prayers, they punish blasphemy, and some of them walk about in borrowed bodies at festivals. What they did not do is make the world, whatever their priests say.</p>
		<p>The heretics' account, which is also the Hinge's: a god is what happens when enough people believe in the same thing for long enough, or one person believes in it hard enough. Every land that arrived brought its believers, and so its gods. Gods grow with worship and shrink without it. There are shrines in the Vyrlands to gods nobody can name any more, and nobody is sure whether anyone still answers.</p>
		<p>This is not said in temples.</p>
		<h3>Domains</h3>
		<p>With so many gods doing the same work, priests group them by <b>domain</b> - what a god has power over. A sailor does not much care whether the god calming the sea is Poseidos or Abyssar. A Death-priest of Haedes and one of Nekhra will argue theology all night and then bury the dead the same way.</p>
		<p>A domain decides what a god can do for you. The god decides whether to.</p>
		<ul>[jointext(rows, "")]</ul>
		<h3>Private devotion</h3>
		<p>You do not need a temple. Many families keep a god of their own that nobody outside the house has heard of. If it is believed in, it listens.</p>
		<h3>Sway</h3>
		<p>Where many followers of one domain gather, that domain holds sway over the land for a while: its miracles come easier, and everyone else's come harder. Nobody decrees it. It simply happens, and priests notice.</p>
		</div>
	"}

// --- 04 ---------------------------------------------------------------------------

/datum/book_entry/codex/faith
	name = "04. Prayer and Miracles"

/datum/book_entry/codex/faith/inner_book_html(mob/user)
	return {"
		<div>
		<p>A priest asks and the god decides. Devotion - a life of faithful service - earns a god's attention, and with it deeper miracles. Nobody is owed an answer.</p>
		<h3>Prayer</h3>
		<p>Anyone with devotion can pray in their own words. The god hears every word: whether you named them, whether you asked humbly or gave orders, what you asked for and for whom. Holy ground helps. A frayed mind, a mumbled prayer or the same words said too often do not. War, law, trickery and forbidden gods like a firm voice; the rest do not.</p>
		<p>A prayer can be paid for with more than devotion. Blood, strength, flesh or sight given up with the words make the answer stronger and the asking cheaper. So does a fitting gift. So does a holy amulet worn, a symbol held, or the holy book in hand.</p>
		<p>A prayer said often enough is known by heart, and can be said quickly: laid on one person, cast as a bolt of light, broken out around you, or left lingering on the ground.</p>
		<p>A strong will can refuse a hostile prayer outright. A strong enough prayer can overpower even that.</p>
		<p><i>In play: the Prayer guide in the encyclopedia covers every word, shape and number.</i></p>
		<h3>Holy places</h3>
		<p>Gods hear best near a holy cross, ritual chalk or their own statue, or somewhere their domain cares about: by the water for the Sea, at the anvil for the Craft, by a grave for Death.</p>
		</div>
	"}

// --- 05 ---------------------------------------------------------------------------

/datum/book_entry/codex/magic
	name = "05. Magic"

/datum/book_entry/codex/magic/inner_book_html(mob/user)
	var/list/aspects = list()
	for(var/aspect_type in subtypesof(/datum/magic_aspect))
		var/datum/magic_aspect/A = aspect_type
		var/aspect_name = initial(A.name)
		if(!aspect_name || aspect_name == "Aspect" || ispath(aspect_type, /datum/magic_aspect/pseudo))
			continue
		aspects |= aspect_name
	return {"
		<div>
		<h3>The Weave</h3>
		<p>Magic is not given; it is taken. Mages call what they draw on the <b>Weave</b> - the tangle of every land's magic caught up together where the lands meet. It answers study and nerve, not faith. It does not care who you are.</p>
		<p>A mage attunes to <b>aspects</b>: disciplines of the Weave, each with its own spells and its own habits. The ones taught in Palimpseste include [english_list(aspects)].</p>
		<h3>The cost</h3>
		<p>Every working pulls on the one who makes it. The pull builds faster than it fades. Mages call it <b>Strain</b>.</p>
		<ul>
			<li>A little Strain is an ache behind the eyes.</li>
			<li>More, and every spell costs blood as well as effort, and some lash back and burn.</li>
			<li>At the very edge, everything gathered breaks out of the mage at once - fire, light and noise, and whoever stands close pays too.</li>
		</ul>
		<p>Strain fades with rest, fastest in sleep.</p>
		<h3>Places of power</h3>
		<p>Some places sit where the Weave runs thick: <b>ley stones</b>, old standing stones scored with marks; an arcyne circle properly drawn; a mage's tower. Magic worked there strains the mage less, comes more easily, and Strain drains away quickly. Mages fight over such places more than they admit.</p>
		<h3>Nothing is certain</h3>
		<p>No working is sure. Every spell is a gamble against the Weave: a trained mind wins more often, a hard spell or a strained body less. Most failures just slip away. Some <b>misfire</b> - sparks, blinding light, frost, fire, a spell leaping to strike the wrong person. The worst leave a mark for good: <b>corruption</b>. Mages with long careers have shining eyes, cold skin, a withered hand, a shadow that keeps up late. They are not ashamed of it, mostly.</p>
		<p>A desperate mage can <b>spellburn</b>: burn their own strength, health or speed into the next working to force it through. It comes back, slowly, and it hurts.</p>
		<p>No two mages' spells behave quite alike. A spell one mage finds easy fights the next; one caster's fire smells of brimstone and another's is followed by birdsong. Mages call it mercurial magic and stop being surprised by it early.</p>
		<h3>Incantations</h3>
		<p>A mage who knows what they are doing can work the Weave in their own words - say plainly what the working should do and to whom. Their aspects decide what comes easily. It draws on the mage's energy instead of devotion, and it gambles and strains like any other spell. Only gods raise the dead, forgive or bless; the Weave does not.</p>
		<p>The Weave was first bound in <b>Latin</b>, or so the Laurentine schools claim, and it still answers the old tongue better: <i>"Ignis, feri hostem!"</i> works harder than the same words in Seamspeak. Most mages learn a few hundred words of it whether they like the language or not. <i>Sana vulnera</i>, <i>protege me</i>, <i>fiat lux</i>, <i>liga eum</i>, <i>repelle omnes</i>, <i>cape sanguinem meum</i> - the prayer parser knows them all, and priests may pray in it too.</p>
		<h3>Mediums</h3>
		<p>A mage working bare-handed works harder. A <b>staff, wand or other implement</b> steadies the working: a surer spell check (+1 to +3 by its quality), more power and less energy drawn. An <b>arcyne book</b> in hand helps a little more on top.</p>
		<p><i>In play: Strain shows as an alert; examine it for the thresholds. The Spellburn verb is in the Spells tab. Examine any arcane spell to see its spell check and quirk. Incant writes your own spells; the Incantations verb keeps them.</i></p>
		<h3>Mages and priests</h3>
		<p>They mostly tolerate each other. In some lands the tolerance is thin, and in Athrae open magic will get you killed.</p>
		</div>
	"}

// --- 06 ---------------------------------------------------------------------------

/datum/book_entry/codex/lands
	name = "06. Lands"

/datum/book_entry/codex/lands/inner_book_html(mob/user)
	var/list/rows = list()
	for(var/origin_type in subtypesof(/datum/virtue/origin/palimpseste))
		var/datum/virtue/origin/O = origin_type
		var/origin_name = initial(O.origin_name)
		var/origin_desc = initial(O.origin_desc)
		if(!origin_name || !origin_desc)
			continue
		rows += "<h3>[capitalize(origin_name)]</h3><p>[origin_desc]</p>"
	return {"
		<div>
		<p><i>Every land of Palimpseste that people come from, as its own people tell it.</i></p>
		[jointext(rows, "")]
		<h3>Elsewhere</h3>
		<p>For every great land there are a hundred scraps too small to count: a valley no neighbour owns, an island on one chart and not the next. Folk from such places are counted as from nowhere, and many are glad of it.</p>
		</div>
	"}

// --- 07 ---------------------------------------------------------------------------

/datum/book_entry/codex/tongues
	name = "07. Tongues"

/datum/book_entry/codex/tongues/inner_book_html(mob/user)
	var/list/paths = list(/datum/language/palimpseste, /datum/language/vergenmarkian, /datum/language/ostrovian, /datum/language/dvojezemi,
		/datum/language/medullan, /datum/language/auxentian, /datum/language/valorian, /datum/language/gyedzenese)
	paths |= subtypesof(/datum/language/palimpseste)
	var/list/rows = list()
	for(var/language_type in paths)
		var/datum/language/L = language_type
		var/language_name = initial(L.name)
		var/language_desc = initial(L.desc)
		if(!language_name || !language_desc)
			continue
		rows += "<li><b>[language_name]</b> - [language_desc]</li>"
	return {"
		<div>
		<p>Most lands brought their own tongue. At the borders they rub together into <b>Seamspeak</b>, a trade pidgin nobody grows up speaking and everybody ends up speaking some of. Clergy nearly everywhere learn Laurentine for the old texts.</p>
		<ul>[jointext(rows, "")]</ul>
		</div>
	"}

// --- 08 ---------------------------------------------------------------------------

/datum/book_entry/codex/glossary
	name = "08. Words You'll Hear"

/datum/book_entry/codex/glossary/inner_book_html(mob/user)
	return {"
		<div>
		<ul>
			<li><b>Palimpseste</b> - the world.</li>
			<li><b>Seam</b> - where two lands meet and do not quite fit.</li>
			<li><b>The Hinge</b> - the city of doors.</li>
			<li><b>The Stitching Sea</b> - the seas between lands, which belong to none of them.</li>
			<li><b>The Blank</b> - whatever was here before the first land.</li>
			<li><b>Domain</b> - what a god has power over. Sea, Death, Craft and so on.</li>
			<li><b>Sway</b> - a domain holding sway over a place, by weight of its followers.</li>
			<li><b>Devotion</b> - a god's attention, earned by service.</li>
			<li><b>Private devotion</b> - worship of a god no church knows. It still counts.</li>
			<li><b>The Weave</b> - what mages draw on.</li>
			<li><b>Aspect</b> - a discipline of the Weave.</li>
			<li><b>Strain</b> - what magic takes from the mage.</li>
			<li><b>Misfire</b> - a spell gone wrong.</li>
			<li><b>Corruption</b> - a mark magic leaves for good.</li>
			<li><b>Spellburn</b> - burning your own body into a spell.</li>
			<li><b>Ley stone</b> - a standing stone where the Weave runs thick.</li>
			<li><b>Incantation</b> - a spell in a mage's own words.</li>
			<li><b>The Ten</b> - Psyiadonia's gods: Astratha, Nokk, Dendhor, Abyssar, Ravokh, Nekhra, Zylix, Pestrah, Malumm, Eorah.</li>
			<li><b>The Inhumen</b> - the gods Psyiadonia burns people for: Zyzo, Gragghar, Mathios, Baothe.</li>
			<li><b>Elsewhere</b> - where you're from, if you'd rather not say.</li>
		</ul>
		</div>
	"}
