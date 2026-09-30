GLOBAL_LIST_EMPTY(origins) // alist: origin name = origin desc. so we don't have to access client prefs midgame

// Race list means RESTRICTED from the LISTED races.
/datum/virtue/origin/unknown
	name = "Nowhere"
	origin_name = "Elsewhere"
	desc = "I originate from one of the many lesser settlements dotted around Vaeltis, oft-too demure or distant for the layman to recall. Since I hail from nowhere in particular, I know no regional tongue in particular. <br>"
	origin_desc = "For every greater realm that crests Vaeltis, there lies a hundred lesser settlements; villages and fiefdoms, cursed to bare a legacy that will \
	only be carried by the few who travel abroad. More distressingly, such a fate is strongly associated with the many souls who've been left to wander this bygone \
	world, bereft of an identity to call their own - peasants, refugees, orphans, erranteers and more."

/datum/virtue/origin/auxentia
	name = "Auxentian"
	origin_name = "Auxentia"
	added_languages = list(/datum/language/auxentian)
	desc = "I originate from the settled heartland of Auxentia, seat of the Vaeltis Compact and home to the Court of Six Seats. Famed for its river-trade, its craft-guilds, and the old stones of the Weeping Idols upon its northern border, Auxentia sits at the center of most worldly affairs - both past and present.<br>"
	restricted = FALSE
	origin_desc = "Auxentia is the broad river-plain heartland bound together under the Vaeltis Compact, the covenant by which the Domains's Court of Six Seats \
	governs in the name of its six gods - the Sun of law and kingship foremost among equals, but never above the other five. Its capital, Cynwic, sits astride \
	the river that threads the whole realm from the Vergenmark foothills to the southern coast. <br> Long before the Compact, the land bore witness to older, \
	quieter powers; the Weeping Idols still stand near the northern border, a ruin no living faith claims as its own, older than any of the Six. Auxentia's fields \
	and forests are dotted with the shrines of the Old Kin as much as the civic temples of the Domains, and most Sun faithful keep both without contradiction: a coin \
	left for the Forbidden at the hearth is no less pious than a vow sworn before the Sun's magistrates.<br> Auxentia is home to a wide mix of peoples drawn by trade \
	along the river and the roads to Via Medulla, and its craft-guilds - sworn, at least nominally, to the Craft's patronage - are counted among the finest in Vaeltis."

/datum/virtue/origin/vergenmark
	name = "Vergenmarker"
	origin_name = "Vergenmark"
	added_languages = list(/datum/language/vergenmarkian)
	desc = "I originate from Vergenmark, the craggy mountain enclave north of Auxentia proper, where the Ordo Iusta once ruled outright before its schism and long retreat. Its people are known for hard doctrine, harder winters, and a memory that does not forgive easily.<br>"
	origin_desc = "Vergenmark crowns Auxentia's northern border, a knot of craggy peaks and terraced mountain holds that was once the seat of the Ordo Iusta's \
	rule entire, before a war and schism folded most of Auxentia under the Domains's Court of Six Seats instead. What remains is a doctrinal enclave still bound \
	to Law's strict hierarchy - the Absent God's Word above all, Law's law enforcing it, Knowledge's truth binding every oath and contract sworn within its \
	valleys.<br> Vergenmarkers are raised on that history the way other folk are raised on scripture: a fall from dominance to enclave, remembered less as a defeat \
	than as a wound still owed repayment. Orthodox clergy hold the temples and the terraces, but a harsher fringe - the Inquisition, some call it, though never to \
	its face - grows from the same doctrine and answers to no seat but its own conviction. Both agree on one thing: that the Word does not bend, whatever the \
	Compact's Six Seats might tolerate on the plains below.<br> Vergenmark's stonework and its hard grey wool are prized as far as the Tidesworn Isles, and its \
	folk are known - not always fondly - for meaning exactly what they say, and expecting the same in return."

/datum/virtue/origin/ognica
	name = "Ognican"
	origin_name = "Ognica"
	added_languages = list(/datum/language/dvojezemi)
	desc = "I originate from Ognica, the volcanic western half of Dvojezem, the Severance made land - young, restless, given to the Wilds above all. My people build in ash and rebuild after, and count that a virtue rather than a curse.<br>"
	origin_desc = "Ognica is the volcanic, ash-black half of Dvojezem, the realm the Severance split from one being into two: The Wilds, god of growth, change, \
	risk, and fire, and the Hearth, god of stillness, preservation, duty, and stone, once one god before something - no two accounts agree what - tore them apart. \
	Ognica keeps to the Wilds's half of that inheritance, and it shows: settlements are built expecting to burn or be buried, and rebuilt without much mourning \
	when they are. <br> Shrines here are still raised in pairs, one face to the Wilds and one left dark for the Hearth, and most Ognicans venerate both across a \
	lifetime rather than choosing - though a life spent chasing risk, trade, and reinvention marks an Ognican as surely as the ash under their nails. In the \
	ash-flats stands the Gallows Oak, a single gnarled dead tree where the old folk-custom of War's winter-offering is still kept, untouched by either god \
	of the Severance. <br> A narrow strait connects Ognica south to its sister-land Kamenrad, and further on to the free-city road of Via Medulla; caravans and \
	ships alike stop first at Blackcrag before braving the crossing."

/datum/virtue/origin/kamenrad
	name = "Kamenradi"
	origin_name = "Kamenrad"
	added_languages = list(/datum/language/dvojezemi)
	desc = "I originate from Kamenrad, the terraced highland half of Dvojezem, the Severance's stiller inheritance - the Hearth's stone rather than the Wilds's fire. My people build to last, and measure a life well-lived by what it leaves standing.<br>"
	origin_desc = "Kamenrad is the terraced highland peninsula south of volcanic Ognica, the two together making up Dvojezem - one people, split since the \
	Severance between the Wilds's fire and the Hearth's stone. Kamenrad keeps to stillness: preservation, duty, and the slow, exact work of building terraces that \
	will still hold soil for one's great-grandchildren. <br> The two halves of Dvojezem are governed jointly by a Threshold Council, seated wherever Ognica and \
	Kamenrad's roads meet, since neither half claims seniority over the other - they are one being remembering itself as two. Most Kamenradi keep shrines to both \
	the Wilds and the Hearth as Ognicans do, though a Kamenradi is more likely to be the one who finally finishes building the shrine. <br> Kamenrad's terraced \
	slopes produce the finest stoneware and hill-wine in Vaeltis, carried north along the strait or south into the free-city corridor of Via Medulla, and its \
	people have a reputation - not unearned - for outlasting whatever trouble finds them."

/datum/virtue/origin/viamedulla
	name = "Medullan"
	origin_name = "Via Medulla"
	added_languages = list(/datum/language/medullan)
	desc = "I originate from the Marrow Roads of Via Medulla, a fragmented patchwork of free cities bound by trade rather than any single crown. No god's law here goes unquestioned - the Forbidden's heresy runs freer in Via Medulla than anywhere else in Vaeltis, and at least one city has gone fully tithe-free.<br>"
	origin_desc = "Via Medulla - the Marrow Roads - is not a nation so much as a corridor: a scatter of free cities strung along the trade route between \
	Auxentia, the sundered lands of Dvojezem, and the sea beyond, none of them answering to a single crown or a single seat of the Domains. What holds it \
	together is coin and caravan, not doctrine, which is exactly why Via Medulla is where the Forbidden's heresy has taken deepest root: The Forbidden's claim that \
	no priesthood should stand between a soul and the divine finds easy purchase in cities that already answer to no one god or king. <br> The Forbidden \
	themselves are divided between the gentle 'Plainfolk' majority, content to simply worship without clergy, and a violent 'Stripping' minority that has taken \
	to actively unmaking the shrines of older gods within the cities they've won over - at least one free city has abolished tithes to any temple entirely on \
	their urging. <br> Medullans are traders, caravaners, and free-city artisans first and believers second, practical people who measure a god's worth by \
	what it costs to keep faith with, rather than what it promises after death."

/datum/virtue/origin/ostrovia
	name = "Ostrovian"
	origin_name = "Ostrovia"
	added_languages = list(/datum/language/ostrovian)
	desc = "I originate from Ostrovia, the Tidesworn Isles - an island port-confederation southeast of Auxentia that lives and dies by open sea-lanes. My people keep Trickery's roads and the Moon's tides both, and trust the sea long before they trust a crown.<br>"
	origin_desc = "Ostrovia - the Tidesworn Isles - is a confederation of island ports scattered southeast of Auxentia's coast, bound together less by any \
	single government than by shared dependence on open sea-lanes and fair trade. No land in Vaeltis is more alarmed by instability elsewhere, since a war on the \
	mainland or a blockade in Via Medulla can starve an island city as surely as a siege. <br> Ostrovians keep Trickery's patronage of trade, travel, and the \
	luck of the road close, but at sea it is the Moon they invoke first - moon, tide, and the fickle fortune of open water all falling under one figure's \
	clustered domain. A ship's captain who scorns the tide-shrine before departure is thought a fool, whatever seat of the Domains they answer to on land. \
	<br> The isles export little but trust little in return: fine coral-work, salt, and the sharpest pilots in Vaeltis, along with a healthy suspicion of anyone \
	whose fortune doesn't depend on the sea the way theirs does."

/datum/virtue/origin/racial/underdark
	name = "Underdweller"
	added_languages = list(/datum/language/undercommon)
	origin_name = "the Underdark"
	desc = "I originate from the treacherous Underdark, a cavernous region beneath Auxentia and Vergenmark. This unforgiving land is dominated by the prosperous and cruel dark elves and their pets. Most surfacedwellers only come here in chains.<br>"
	races = list(/datum/species/elf/dark,
				/datum/species/human/halfelf,
				/datum/species/kobold,
				/datum/species/dwarf/mountain,
				/datum/species/dwarf/gnome,
				/datum/species/goblinp,
				/datum/species/moth,			//They are from the Underdark. source: moth.dm
				/datum/species/anthromorphsmall,
				/datum/species/dullahan,
				/datum/species/ooze,
				/datum/species/construct/metal,
)
	origin_desc = "Underdwellers are those who are descendants of their lengthy lineage that settled, lived and toiled in the darkest and deepest \
	of depths of the vast, deadly Underdark a millennia ago. When one speaks of a 'Underdweller', a dark elf first comes to mynd, though despite them\
	dominating these vast cavern riddled depths, there are more that can call the Underdark their home: Dwarves in their deep fortresses, mostly\
	isolated from the rest of the depths they reside, Kobolds that scavenge and roam in a nomadic fashion, moving away as soon as they\
	strip their dugout clear of valuables and Gnomes, often referred to as 'Deep Gnomes' due to their natural affinity for boasting\
	dark elf-like complexions. Goblins have scurried their way into the shallowest of depths, but struggle to survive in this hostile\
	environment due to their fragility and lack of necessary instincts to survive.\n<br><br>\
	\
	Despite vast differences amongst these races, they all have things in common. Their forms over the generations have garnered darker or \
	paler complexions, their bodies slightly shorter than their surface dwelling compatriots, dark elves being amongst the tallest species in \
	the Underdark, despite on average being shorted than an average Vergenmarker humen. Despite this in most cases noticable lack of height, these \
	races have also grown sturdier, more resilient and more cautious and keen, out of pure necessity. Survival in these depths demands one's all.  \
	A fact those of the surface that delve deep into these cavers, tend to forget, resulting in their untimely demise. Or worse.\n<br><br>\
	\
	The Underdark itself is a gigantic system of different caves, caverns tunnels and hollowed out underground regions that span leagues upon \
	leagues both across and deep into Vaeltis's soil. Not all of these systems are inherenty connected, paved or make logical sense, but the \
	Underdwellers always have a knack for traversing them. The Underdark as a whole is split into Western and Eastern, Western being the one that \
	resides beneath Auxentia and Vergenmark, and the Eastern that is located deep beneath Dvojezem and the Marrow Roads, noticeably less populated \
	than the western counterpart, shrouded in mystery; more so than the other. Most important fact remains, Western and Eastern Underdark are NOT \
	connected directly, only point where one could pass from one into the other, in theory being a marvel of artifice, constructed by the deep \
	dwarves, known as Duergar. Their hostile and isolationist nature prevents any who seek passage through their fortress of artifice that sits \
	above the vast molten sea in the deepest of depths, from obtaining it in this lyfe. This makes Eastern Underdwellers somewhat more rare in \
	places lyke Auxentia due to the sheer difficulty and amount of hoops one'd need to jump through to reach its forests.\n<br><br>\
	\
	Underdwellers live a harsh lyfe, filled with hard toil, sweat and blood, and thusly they are no strangers to violence and darker things one \
	could experience in mortal lyfe. Most settlements in these depths practice some sort of violent cultural tradition, engage in bloodsports, or \
	both. And so much more. They live and have lived very different lives for a millennia, which often causes Underdwellers to have trouble adapting \
	to surface cultures and communities, often perceived as strange at best, and downright evil at worst. A stigma developed by those who live upon \
	the surface about their home and culture, believing all things evil crawl out of the very depths they reside in. A stigma that has lessened in \
	recent yils, but still vastly present nonetheless."

/datum/virtue/origin/racial/underdark/apply_to_human(mob/living/carbon/human/H)
	..()
	var/list/choices = list("Normal (Default)", "Strict (Sunlight Sensitivity + Advanced Darksight)")
	var/complex = tgui_input_list(H, "How adapted are you to the Underdark?", "Underdweller Upbringing", choices)
	if(!complex)
		complex = "Normal (Default)"
	switch(complex)
		if("Strict (Sunlight Sensitivity + Advanced Darksight)")
			ADD_TRAIT(H, TRAIT_SUNLIGHT_SENSITIVE, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_NITEVISION, TRAIT_GENERIC)
			to_chat(H, span_notice("The sun is irritantly bright for you, but your eyes cut the darkness better!"))
		else
			to_chat(H, span_notice("You're quick to adapt."))

/datum/virtue/origin/apply_to_human(mob/living/carbon/human/recipient)
	recipient.dna.species.origin = origin_name
	// Climate acclimation is picked as a quirk (Heat/Cold Acclimated).

// Restored from origin/main during 2026-09 mainstream merge

/datum/virtue/origin/unselectable/fae
	name = "Fae"
	origin_name = "The Faewyld"
	origin_desc = "Little and less is known about where the fae come from. Some say another plane, layered over Psydonia; others say merely hidden groves, tucked far away from mortal sight. All that is certain is that wherever they come from, they rarely seem to leave."

/datum/virtue/origin/unselectable/elemental
	name = "Elemental"
	origin_name = "The Depths"
	origin_desc = "Little and less is known about where elementals come from. Some say another plane, layered over Psydonia; others say they're merely deep underground, far below the caves-and-tunnels of mortals. All that is certain is that wherever they come from, they rarely seem to leave."

/datum/virtue/origin/unselectable/void
	name = "Voidborn"
	origin_name = "The Void"
	origin_desc = "Little and less is known about the origin of void beings. Some magi claim it is the space between realms, filled with unfathomable predators; others claim it is the far past. Whatever the case, seeing a voidborn being can only mean two things: a powerful magos has been at work here, and you are in danger."

/datum/virtue/origin/unselectable/infernal
	name = "Infernal"
	origin_name = "The Hells"
	origin_desc = "Infernals are tight-lipped about their home, and mortals tend to prefer sylver'd blades to questions. All that is known is that every being that crawls out of the hellish pits bears a deep-rooted malice towards Psydonia and all that dwell upon it."

// Inherent to Lich/Skeletons, they aren't of this era. Ancient kynds.

/datum/virtue/origin/unselectable/skeleton
	name = "Ancient Times"
	origin_name = "The Forgotten Empires"
	origin_desc = "Throughout the history of Psydonia there were are many, many great empires that once stood the test of aeon's grip; most notably there was the Holy Celestrial Empyre, \
	which stood for yills upon yills as the largest and most notable during Psydonia's Golden eras of the Domains, whom sheparded by the Domains displaying their divinity \
	and true power against the Old Faith worshippers of past, brought upon a new era of worship and the rise of Celestia as the world's \
	largest empire to stand the test of aeon. Notably one of the most tolerant empires of the many yills in the history of Psydonia which accepted the worship of the Absent God \
	and the Domains's faithful alyke, yet when the Forbidden rose and ascended to divinity, everything crumbled apart.\n<br><br>\
	\
	Now all that remains is but hollow shells, rubble and ruins of the greatest empyre that stood the test of time; hundreds and thousands of the fallen; \
	legionnaries, soldiers, warriors, toilers, heros, champions and forgotten souls were given lyfe anew, \
	yet from such hubris came nothing but legions upon legions of myndless, gibbering deadites in what was a second chance in lyfe, quickly turned into a war of rage \
	against the lyving; as their lyfelux withered and with it, their mynds and purpose turned from steps towards Progress into endless war without reason.\n<br><br>\
	\
	Some say the Forbidden weeps for the lost, others say She still continues without much regards to break free beyond her failings of the past, either way nothing changes what was left behind from her hubris \
	as most of the dead shamble these now empty halls, the wylds or under word and pact to a master. Those who don't remain unbound and decaying into ferals that will one dae too fight anything that lyves lyke the rest of long-past before them, \
	all of the undead risen by the Forbidden, feel the calling from the empty halls of these forgotten ruins, these desecrated lands of once-paradice. Humenity's greatest acheivements buried \
	in rot, rust, rubble and decay. never to see the lite of dae, lest you be branded and cast out from the pantheon's embrace as a heretic from the leyman's superstition borne from Her Hubris.\n<br><br><br>\
	\
	And for the so-called lucky-few to ascend beyond simple unlyfe to the greater works of lychdom, before or after the Forbidden's ascension remain shattered in mynd by their hubris; to touch the filament and yet only be left with a sliver of the divinity promised."
