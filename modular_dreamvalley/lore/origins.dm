// Origins of Palimpseste. The world is a patchwork: lands that bled in from other
// planes over eons, each one certain it was always here. Where the patches meet
// the seams show - coastlines that don't agree, calendars that don't line up,
// ruins older than the ground under them. The server sits in the Seamvale, where
// more patches touch than anywhere else.
//
// The old Vaeltis origins stay defined because other code refers to them, but
// they can no longer be picked, and saves that used them fall back to Nowhere.

GLOBAL_LIST_INIT(dreamvalley_retired_origins, list(
	/datum/virtue/origin/auxentia,
	/datum/virtue/origin/vergenmark,
	/datum/virtue/origin/ognica,
	/datum/virtue/origin/kamenrad,
	/datum/virtue/origin/viamedulla,
	/datum/virtue/origin/ostrovia,
))

/datum/preferences/proc/dreamvalley_migrate_origin()
	if(!virtue_origin || (virtue_origin.type in GLOB.dreamvalley_retired_origins))
		virtue_origin = new /datum/virtue/origin/unknown

/datum/virtue/origin/unknown
	name = "Nowhere"
	origin_name = "Elsewhere"
	desc = "I come from nowhere anyone would know - a hamlet, a wagon, a patch of land too small to have a name on any map of Palimpseste. I speak no regional tongue in particular.<br>"
	origin_desc = "For every great land stitched into Palimpseste there are a hundred scraps too small to be called lands at all: a valley that belongs to no \
	neighbour, an island that appears on one chart and not the next, a village whose people swear it has always stood where it stands. Folk from such places \
	are counted as from nowhere, and many are glad of it - refugees, orphans, wanderers and those who would rather their past not follow them."

// --- The Seamvale ------------------------------------------------------------

/datum/virtue/origin/palimpseste/seamvale
	name = "Seamvaler"
	origin_name = "the Seamvale"
	desc = "I was born in the Seamvale, the valley where more lands of Palimpseste meet than anywhere else. Half my neighbours came from somewhere else, and so did their gods.<br>"
	origin_desc = "The Seamvale is a long green valley where at least five lands press against one another: northern pine gives way to olive groves within a \
	day's walk, and a river that rises in snow runs out into warm reed-marsh. The seams are plain to see here. Roads end at cliffs that were not there on older \
	maps; one village keeps two calendars because its east and west halves never agreed on the length of a year. <br> Everyone passes through the Seamvale \
	eventually, and many stay. Its people are traders, guides and fence-sitters by necessity, fluent in borrowed customs and suspicious of anyone who claims \
	their own land was the first."

// --- North ---------------------------------------------------------------------

/datum/virtue/origin/palimpseste/skarnheim
	name = "Tamarhelian"
	origin_name = "Tamarhel"
	desc = "I come from Tamarhel, the continent of many provinces under one crumbling empire - from the snows of Skarnheim to the swamps of the south. Dragons, daedra and old gods walk its history, and sometimes its roads.<br>"
	origin_desc = "Tamarhel is a whole continent stitched into Palimpseste, each of its provinces a people of its own. Skarnheim is its frozen north of jarls, \
	long halls and dragon-bones in the snow, where the Voice can still shake a mountain. The heartland of Cyrodel holds the Imperial City and its Elder \
	Council; the ash-lands of Morrowvale shelter the dark elves and their living gods; High Rook breeds kings, wizards and endless intrigue; the golden \
	isles of Sumersette are home to proud high elves; the sands of Hammerfel to sword-singers; the jungles of Elswyr to the cat-folk; the Black Marsh to \
	the scaled Argonians; and the forests of Valenwood to wood elves bound by the Green Pact.<br> Its empire has fallen and risen more times than anyone can \
	count, and its gods - the Nine and the daedric princes who scheme against them - are older than most of its maps. Tamarhelians are proud of their \
	province first and their continent second, and have a bad habit of becoming heroes whether anyone asked them to or not."

/datum/virtue/origin/palimpseste/vyrlands
	name = "Vyrlander"
	origin_name = "the Vyrlands"
	desc = "I come from the Vyrlands, the endless birch forests and marsh-villages where the leshy walks and a hut on chicken legs may answer if you knock.<br>"
	origin_desc = "The Vyrlands are forest without end: birch, bog and black water, dotted with villages that keep bread and salt on the sill for whatever \
	might come in from the trees. The spirits here are close and many - the leshy of the wood, the rusalka of the river, the domovoi behind the stove - and \
	the old woman in the deep wood is treated with more respect than any prince. <br> Vyrlanders are superstitious, stubborn and generous to guests, because \
	one never knows which guest is a spirit testing the house."

/datum/virtue/origin/palimpseste/conjunct
	name = "Conjunct-born"
	origin_name = "the Conjunct"
	desc = "I come from the Conjunct, the war-torn kingdoms where monsters came through when the worlds last collided. We hire mutants to kill them, then spit at the mutants.<br>"
	origin_desc = "The Conjunct takes its name from the Conjunction, the day the lands of Palimpseste last shifted and ghouls, drowners and worse spilled in \
	from somewhere else. Its northern kingdoms have never stopped fighting each other since, and their villages rely on hired monster-slayers - scarred men \
	and women changed by alchemy - whom they pay badly and fear openly. <br> Sorceresses advise its kings and plot against them; its elves remember when all of \
	it was theirs. People of the Conjunct are cynical, practical and hard to impress, and most of them have buried someone something came for."

// --- West ----------------------------------------------------------------------

/datum/virtue/origin/palimpseste/tir_aenna
	name = "Aennach"
	origin_name = "Tír Aenna"
	desc = "I come from Tír Aenna, the green hill-country where the Fair Folk live under the mounds and a bargain spoken aloud is binding.<br>"
	origin_desc = "Tír Aenna is rain, stone walls and hills that are not always hills. The Otherworld lies closer here than anywhere in Palimpseste: the fae \
	keep their courts beneath the barrows, and a traveller who dances in the wrong ring may come home to find a century gone. <br> The Aennach are poets, \
	cattle-raiders and oath-keepers, careful of their words because words here have teeth. They leave milk for the Good Neighbours, never say their true \
	names lightly, and hang iron over every door."

/datum/virtue/origin/palimpseste/faerhen
	name = "Faerhenian"
	origin_name = "Faerhen"
	desc = "I come from Faerhen, the sprawling realm of wizard-towers, adventuring companies and cities where every race and a dozen planes do business.<br>"
	origin_desc = "Faerhen is vast and crowded with history: fallen elven empires, dwarven holds, sunken netherese cities and a hundred petty kingdoms \
	between. Magic is common here, if never cheap, and adventuring is a respectable trade - companies are chartered, dungeons are mapped, and taverns keep \
	boards of posted bounties. <br> Faerhenians are cosmopolitan and restless, used to strange peoples and stranger gods, and they tend to treat the rest of \
	Palimpseste as somewhere to go and make a name."

/datum/virtue/origin/palimpseste/thessadra
	name = "Thessadran"
	origin_name = "Thessadra"
	desc = "I come from Thessadra, where mages are kept in towers under guard, the dead dream in the Veil, and the taint rises from the Deep Roads every generation.<br>"
	origin_desc = "Thessadra is a land of old empires and old fears. Its mages draw on the Veil, the dream-world beside the waking one, and demons wait on \
	the other side for a weak mind to open the door - so mages are gathered into circles and watched by sworn templars. Beneath it, the Deep Roads carry a \
	blight that boils up into great hordes every few generations. <br> Thessadrans are politic and wary, raised on the understanding that power always has a \
	price and someone is always watching who pays it."

/datum/virtue/origin/palimpseste/golaren
	name = "Golarene"
	origin_name = "Golaren"
	desc = "I come from Golaren, a world-in-miniature of rival nations, lost empires and secret societies that catalogue everything under the sun.<br>"
	origin_desc = "Golaren holds more nations than any other land in Palimpseste, each with its own gods, grudges and histories: devil-bargaining empires, \
	free cities, frozen witch-queendoms and ruins of peoples who fell from the sky. Scholarly lodges send pathfinders out across all of it to record, loot \
	and occasionally save what they find. <br> Golarenes are curious, argumentative and well-travelled; there is no land so strange that a Golarene has not \
	written a monograph about it."

// --- South ---------------------------------------------------------------------

/datum/virtue/origin/palimpseste/laurentine
	name = "Laurentine"
	origin_name = "the Laurentine Dominion"
	desc = "I come from the Laurentine Dominion, the empire of roads, legions and senates, where every god is welcome so long as it pays tax.<br>"
	origin_desc = "The Laurentine Dominion is the great empire of the south: paved roads, aqueducts, legions that march in step and a senate that argues \
	while they do. It has conquered its neighbours and absorbed their gods whole, raising temples to each beside the state cult of the emperor's genius. \
	<br> Laurentines are orderly, legalistic and proud of their citizenship, convinced that civilisation is something built by hand and kept by law - and that \
	most of Palimpseste has yet to learn it."

/datum/virtue/origin/palimpseste/achaeon
	name = "Achaeon"
	origin_name = "the Achaeon Isles"
	desc = "I come from the Achaeon Isles, where heroes are born of gods, the underworld has a door you can walk through, and the Fates keep their thread close.<br>"
	origin_desc = "The Achaeon Isles are wine-dark sea, white stone and quarrelling city-states, each claiming a hero and a patron god. The gods here meddle \
	openly: half the noble houses claim a divine ancestor, and some of them are right. Beneath the islands lies Erebor Deep, the realm of the dead, whose \
	gates can be found by the desperate - and a few, it is said, have fought their way back out. <br> Achaeons prize glory, hospitality and cleverness, and \
	fear hubris above all, because the gods of the Isles are always listening for it."

/datum/virtue/origin/palimpseste/khemet
	name = "Khemeti"
	origin_name = "the Khemet Sands"
	desc = "I come from the Khemet Sands, the river-kingdom of priest-kings, where the dead are embalmed for a journey and the sun is rowed across the sky.<br>"
	origin_desc = "The Khemet Sands are a single great river and the desert on both sides of it. Its god-kings rule from the river's banks and build tombs \
	larger than cities to carry them into the afterlife, where hearts are weighed against a feather. Its priests keep vast libraries of rites for the dead, \
	and its tomb-robbers keep vaster ones of ways around them. <br> Khemeti are patient, ceremonious and deeply concerned with how they will be remembered, \
	and they find other peoples' careless burial customs faintly horrifying."

/datum/virtue/origin/palimpseste/athrae
	name = "Athraen"
	origin_name = "Athrae"
	desc = "I come from Athrae, the sun-scorched waste where magic drank the land dry. We know better than anyone what spellcraft costs.<br>"
	origin_desc = "Athrae was green once. Its sorcerer-kings drew on the life of the land to fuel their magic until the land had nothing left, and now it is \
	obsidian plain, salt flat and dust under a red sun. City-states cling to the last oases under tyrant rule; out in the waste, raiders, psionic hermits and \
	stranger things roam. <br> Athraens are tough, suspicious and thrifty with water, and many of them regard any open use of magic as a crime against the \
	living - which, in Athrae, it is."

/datum/virtue/origin/palimpseste/ashurim
	name = "Ashurite"
	origin_name = "Ashurim"
	desc = "I come from Ashurim, the land of ziggurats and bound djinn, where kings write laws in stone and demons are signed to contracts.<br>"
	origin_desc = "Ashurim lies between two rivers, a land of brick cities crowned by stepped temples. Its kings were the first in Palimpseste - so they \
	claim - to write their laws down, and its sorcerers the first to bind spirits of fire and wind by contract. Every great house keeps a djinn in a lamp or \
	a ring, and every Ashurite child learns to read the fine print. <br> Ashurites are shrewd, legalistic and proud of their antiquity, and they treat oaths \
	and bargains with a seriousness other peoples find alarming."

/datum/virtue/origin/palimpseste/ile_orun
	name = "Oruni"
	origin_name = "the Ilé-Orun Coast"
	desc = "I come from the Ilé-Orun Coast, where the orisha walk in the market, the griots keep every family's history, and a clever spider taught the world its stories.<br>"
	origin_desc = "The Ilé-Orun Coast is a long shore of trading kingdoms, bronze-casting cities and savanna beyond. Its spirits are many and near: the orisha \
	are honoured with drums and offerings and answer through their devotees, and the trickster-spider who stole the world's stories is loved and blamed in \
	equal measure. <br> Oruni value memory, kinship and eloquence; griots can recite a family back forty generations, and a debt of honour outlives the one \
	who owed it."

// --- East and across the sea ----------------------------------------------------

/datum/virtue/origin/palimpseste/hinomura
	name = "Hinomuran"
	origin_name = "Hinomura"
	desc = "I come from Hinomura, the island realm where every mountain and river has its kami, and the yokai come out when the lanterns go dark.<br>"
	origin_desc = "Hinomura is a chain of mountainous islands where the sacred is everywhere: every spring, rock and old tree holds a kami, and shrines stand \
	at the roadside to keep them content. When they are not, yokai come - foxes that wear faces, umbrellas that walk, the long-necked thing at the window. \
	<br> Its warrior houses serve lords under strict codes, and its people value duty, courtesy and composure, though beneath the courtesy lies a sharp \
	sense of every slight."

/datum/virtue/origin/palimpseste/turtles_back
	name = "Turtle's Back"
	origin_name = "Turtle's Back"
	desc = "I come from Turtle's Back, the great land carried on the shell of the first turtle, where the spirit-walkers speak for the animals and some hungers must never be named.<br>"
	origin_desc = "Turtle's Back is prairie, forest and river-country under a wide sky, home to many nations who say the land rests on the back of a great \
	turtle who rose from the first waters. Its peoples keep the land in balance through ceremony and the counsel of spirit-walkers, who travel in dreams \
	and speak with the animal nations. <br> They also keep warnings: of the starving spirit of the winter woods, of the ones who wear skins that are not theirs. \
	Those who come from Turtle's Back tend to be careful listeners, and slow to trust anyone who takes more than they need."

/datum/virtue/origin/palimpseste/dunmoor
	name = "Dunmoorish"
	origin_name = "the Dunmoor Isles"
	desc = "I come from the Dunmoor Isles, the grey whaling empire of oil-lamps, plague and the Void that whispers to the chosen.<br>"
	origin_desc = "The Dunmoor Isles are grey cities of stone and iron that burn whale-oil for light and power, where science has advanced faster than anywhere \
	in Palimpseste and conscience a great deal slower. Rat-plague stalks the poor quarters; the rich hide behind walls of light. Carved bone charms whisper to \
	those who hold them, and a strange figure is said to appear in dreams to mark a chosen few. <br> Dunmoorish folk are sharp, cynical and inventive, and \
	accustomed to the idea that power belongs to whoever is ruthless enough to take it."

/datum/virtue/origin/palimpseste/yharrow
	name = "Yharrowan"
	origin_name = "Yharrow"
	desc = "I come from Yharrow, the gothic city famed for its healing blood - and for the beasts that come out on the night of the hunt.<br>"
	origin_desc = "Yharrow is a city of spires, lamplit alleys and churches built on a miracle: its blood-ministration heals any ill, and pilgrims come from \
	across Palimpseste to receive it. The price is kept quiet. Every so often, on the night of the hunt, some of the healed become beasts, and the city's \
	hunters take to the streets. <br> Yharrowans are devout, secretive and wary of outsiders, and they do not speak of what they see when the moon runs red."

/datum/virtue/origin/palimpseste/varovia
	name = "Varovian"
	origin_name = "Varovia"
	desc = "I come from Varovia, the valley swallowed by mists, ruled by a dark lord in a castle on the cliff. No one leaves Varovia - but here I am.<br>"
	origin_desc = "Varovia is a gloomy valley of mud villages and black forest, ringed by a mist that kills those who try to leave. Its lord is ancient, cruel \
	and not alive; the villagers lock their shutters at dusk and keep garlic in the rafters, and the travelling folk who come and go through the mist as \
	though it were not there are not trusted. <br> A Varovian who has escaped carries the valley with them - a fatalism that never quite fades, and a fear of \
	the dark older than their name."

/datum/virtue/origin/palimpseste/hinge
	name = "Hinge-born"
	origin_name = "the Hinge"
	desc = "I come from the Hinge, the city of doors, where every portal leads somewhere else - and where everyone knows the truth about Palimpseste.<br>"
	origin_desc = "The Hinge is a city that should not exist: a ring of streets with no sky, whose every arch and doorway may open onto another land of \
	Palimpseste, or another world entirely. It is ruled by factions of philosophers who argue about the nature of reality, and watched over by a silent Lady \
	whom no one crosses twice. <br> In the Hinge the seams are common knowledge. Its folk know that Palimpseste was stitched together from many places, that its \
	gods are made of belief, and that none of it was ever anyone's first. Elsewhere this is heresy. In the Hinge it is small talk."
