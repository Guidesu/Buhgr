// Languages of Palimpseste.
//
// The six old Vaeltis tongues are still granted by jobs, migrants and noble
// classes, so rather than orphan them they are recast as Palimpseste tongues
// under their old keys. Nine new tongues take the free keys. Every origin grants
// its land's tongue; lands of one family share one.

// --- Recast ------------------------------------------------------------------

// Church, law and the old empire: the tongue priests and templars learn.
/datum/language/vergenmarkian
	name = "Laurentine"
	desc = "The tongue of the Laurentine Dominion, carried across Palimpseste by its legions, its law and its temples. Scholars and clergy learn it whatever their birth; it is precise, declined and fond of long clauses."
	speech_verb = "declaims"
	ask_verb = "inquires"
	exclaim_verb = "proclaims"
	mutually_intelligible = list()
	syllables = list("us", "um", "ae", "ius", "ver", "tas", "que", "dom", "ina", "pro", "sum", "cor", "lex", "ab", "ex", "fer", "ant", "ibus", "orum", "vox", "rex", "ti", "on", "is", "ad", "ne", "per", "ora")

// Sailors, islanders, foreigners from over the sea.
/datum/language/ostrovian
	name = "Achaean"
	desc = "The lilting tongue of the Achaeon Isles, full of heroes' epithets and oaths sworn on the gods. Sailors across the Stitching Sea pick up enough of it to haggle and to curse."
	speech_verb = "says"
	ask_verb = "asks"
	exclaim_verb = "cries"
	mutually_intelligible = list()
	syllables = list("os", "ai", "kle", "the", "phi", "eus", "kal", "ia", "mnos", "ark", "nik", "ol", "ymp", "po", "lis", "kho", "ros", "ta", "ei", "do", "me", "ne", "sto", "ly", "ga", "tho")

// The forest folk of the north and the mist-bound valley.
/datum/language/dvojezemi
	name = "Vyrlish"
	desc = "Spoken from the birch-woods of the Vyrlands to the shuttered villages of Varovia. Thick with consonants, blessings and warnings about what lives in the trees."
	speech_verb = "says"
	ask_verb = "asks"
	exclaim_verb = "shouts"
	mutually_intelligible = list()
	syllables = list("sla", "vo", "dzie", "ya", "kri", "bor", "zve", "mir", "ogo", "ich", "prze", "ne", "vol", "sko", "eta", "ruk", "zha", "ve", "gor", "dny", "chy", "lek", "ost", "ra")

// The trade tongue of the valley where the lands meet.
/datum/language/medullan
	name = "Seamspeak"
	desc = "The trade pidgin of the Seamvale, stitched together from every tongue that passes through it. Nobody's first language and everybody's second; most of its words have three meanings depending on who is buying."
	speech_verb = "says"
	ask_verb = "asks"
	exclaim_verb = "hollers"
	mutually_intelligible = list()
	syllables = list("ma", "ko", "sel", "ven", "ta", "ri", "do", "bar", "lo", "nu", "pe", "sa", "tor", "vi", "mer", "ka", "len", "ush", "ba", "ki", "sti", "ho", "ne", "wa")

// The broad common tongue of the western realms.
/datum/language/auxentian
	name = "Faerhenic"
	desc = "The broad tongue of Faerhen and Golaren, spoken in adventurers' taverns and wizard-towers alike. Easy to learn, rich in loanwords from every plane its merchants have visited."
	speech_verb = "remarks"
	ask_verb = "inquires"
	exclaim_verb = "asserts"
	mutually_intelligible = list()
	syllables = list("an", "el", "dor", "ith", "wen", "ar", "ros", "tha", "ven", "lor", "mir", "gar", "ell", "om", "ri", "sen", "bel", "dun", "wy", "hal", "ond", "es", "ta", "rin")

/datum/language/valorian
	name = "Thessic"
	desc = "The courtly tongue of Thessadra, where every sentence is weighed for who might be listening. Its mages keep an older, stranger register for speaking of the Veil."
	speech_verb = "says"
	ask_verb = "asks"
	exclaim_verb = "exclaims"
	mutually_intelligible = list()
	syllables = list("ser", "ah", "vel", "esh", "tan", "or", "iel", "vin", "kah", "dor", "ash", "eth", "nal", "sha", "rim", "oth", "ven", "ara", "is", "lae")

// --- New ---------------------------------------------------------------------

/datum/language/palimpseste
	speech_verb = "says"
	ask_verb = "asks"
	exclaim_verb = "exclaims"
	space_chance = 40
	default_priority = 80
	icon_state = "galcom"

/datum/language/palimpseste/skarnic
	name = "Tamarhelic"
	desc = "The common tongue of Tamarhel's provinces, heard from Skarnheim's fjords to Cyrodel's Imperial City. The Nords of the north salt it with dragon-speech; the elves of every province look down on it and speak it anyway."
	exclaim_verb = "bellows"
	key = "f"
	syllables = list("hja", "ald", "ur", "skar", "ger", "thor", "ing", "dur", "vald", "sko", "ol", "fri", "ei", "ym", "heim", "rok", "brand", "ulf", "sig", "mund", "ra", "ek")

/datum/language/palimpseste/nordling
	name = "Nordling"
	desc = "The speech of the Conjunct's northern kingdoms, salted with Elder words the elves never forgave them for borrowing. Blunt, cynical and very good at insults."
	key = "l"
	syllables = list("wie", "dz", "aen", "ess", "vatt", "ghern", "ced", "sidh", "gwe", "lok", "ar", "cea", "przy", "bla", "ker", "moch", "zer", "ith", "vel", "ne")

/datum/language/palimpseste/aennach
	name = "Aennach"
	desc = "The soft, rain-coloured tongue of Tír Aenna. It has a dozen words for a promise and none for breaking one, which is exactly why the Fair Folk like to bargain in it."
	key = "m"
	syllables = list("mha", "ach", "bhe", "dubh", "ean", "sidhe", "oir", "gha", "caoi", "lle", "nn", "ta", "iar", "mor", "fe", "rua", "cai", "dh", "bri")

/datum/language/palimpseste/khemeti
	name = "Khemeti"
	desc = "The ceremonial tongue of the Khemet Sands, written in pictures and spoken in the measured cadence of funeral prayers."
	speech_verb = "intones"
	key = "j"
	syllables = list("ankh", "ra", "nef", "ka", "ba", "het", "ptah", "sen", "mut", "neb", "dja", "hot", "ep", "wes", "ir", "tem", "amun", "sa", "ren", "maat")

/datum/language/palimpseste/ashurite
	name = "Ashurite"
	desc = "The old tongue of Ashurim's two rivers, the first ever pressed into clay. The desert peoples of Athrae speak a hard, dry dialect of it. Contracts in Ashurite are notoriously full of clauses."
	key = "a"
	syllables = list("ki", "ilu", "shar", "gal", "dingir", "ur", "nam", "lu", "eshu", "ab", "zi", "ku", "an", "ninu", "bab", "ilim", "gid", "ma", "tum", "sin")

/datum/language/palimpseste/oruni
	name = "Oruni"
	desc = "The tonal tongue of the Ilé-Orun Coast, where the same word sung high or low means two different things. Its proverbs are endless; its griots never forget one."
	key = "t"
	syllables = list("o", "ba", "ku", "ile", "ade", "ol", "ju", "se", "mo", "wa", "e", "ti", "ayo", "dun", "ifa", "ase", "omo", "ko", "yi", "run", "la")

/datum/language/palimpseste/hinomuran
	name = "Hinomuran"
	desc = "The tongue of Hinomura's islands, layered with courtesy: there are six ways to say 'yes', and four of them mean 'no'."
	key = "v"
	syllables = list("ka", "ki", "shi", "to", "no", "ra", "mi", "yo", "ha", "tsu", "ne", "ru", "sen", "ga", "do", "ku", "mo", "ri", "sa", "wa", "yu", "ke")

/datum/language/palimpseste/shelltongue
	name = "Shelltongue"
	desc = "The shared speech of Turtle's Back's many nations, used between peoples and with the animal nations in dreams. Long pauses are part of it; interrupting one is rude."
	key = "0"
	syllables = list("wa", "ki", "ta", "ho", "ska", "sha", "ne", "ya", "cha", "to", "ma", "we", "hin", "pe", "lu", "ko", "ni", "ah", "win", "go")

/datum/language/palimpseste/dunmoorish
	name = "Dunmoorish"
	desc = "The clipped, soot-stained tongue of the Dunmoor Isles and the lamplit streets of Yharrow. Its gentry speak it slowly; its dockhands, very quickly."
	key = "7"
	syllables = list("the", "wick", "ham", "ston", "bur", "ly", "ock", "wor", "sha", "ell", "ton", "gri", "dun", "moor", "cro", "ash", "ing", "ble", "fen", "ord")

// --- Origins -------------------------------------------------------------------

/datum/virtue/origin/palimpseste/seamvale
	added_languages = list(/datum/language/medullan)
/datum/virtue/origin/palimpseste/skarnheim
	added_languages = list(/datum/language/palimpseste/skarnic)
/datum/virtue/origin/palimpseste/vyrlands
	added_languages = list(/datum/language/dvojezemi)
/datum/virtue/origin/palimpseste/varovia
	added_languages = list(/datum/language/dvojezemi)
/datum/virtue/origin/palimpseste/conjunct
	added_languages = list(/datum/language/palimpseste/nordling)
/datum/virtue/origin/palimpseste/tir_aenna
	added_languages = list(/datum/language/palimpseste/aennach)
/datum/virtue/origin/palimpseste/faerhen
	added_languages = list(/datum/language/auxentian)
/datum/virtue/origin/palimpseste/golaren
	added_languages = list(/datum/language/auxentian)
/datum/virtue/origin/palimpseste/thessadra
	added_languages = list(/datum/language/valorian)
/datum/virtue/origin/palimpseste/laurentine
	added_languages = list(/datum/language/vergenmarkian)
/datum/virtue/origin/palimpseste/achaeon
	added_languages = list(/datum/language/ostrovian)
/datum/virtue/origin/palimpseste/khemet
	added_languages = list(/datum/language/palimpseste/khemeti)
/datum/virtue/origin/palimpseste/athrae
	added_languages = list(/datum/language/palimpseste/ashurite)
/datum/virtue/origin/palimpseste/ashurim
	added_languages = list(/datum/language/palimpseste/ashurite)
/datum/virtue/origin/palimpseste/ile_orun
	added_languages = list(/datum/language/palimpseste/oruni)
/datum/virtue/origin/palimpseste/hinomura
	added_languages = list(/datum/language/palimpseste/hinomuran)
/datum/virtue/origin/palimpseste/turtles_back
	added_languages = list(/datum/language/palimpseste/shelltongue)
/datum/virtue/origin/palimpseste/dunmoor
	added_languages = list(/datum/language/palimpseste/dunmoorish)
/datum/virtue/origin/palimpseste/yharrow
	added_languages = list(/datum/language/palimpseste/dunmoorish)
// The Hinge opens onto everywhere: its folk pick any tongue.
/datum/virtue/origin/palimpseste/hinge
	extra_language = TRUE

// The Linguist quirk offers the same tongues as the extra-language pick.
/datum/quirk/linguist/New()
	. = ..()
	allowed_languages = list()
	for(var/datum/language/L as anything in GLOB.languages_character_selection + /datum/language/undercommon)
		allowed_languages[initial(L.name)] = L

// Gyedzenese shared "z" with Faerhenic; "3" belonged to an unused SS13 tongue.
/datum/language/gyedzenese
	key = "3"
