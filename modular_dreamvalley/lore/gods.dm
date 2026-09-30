// Gods of Palimpseste's lands. Each land brought its own faith when it bled in;
// the names echo their home settings without copying them. Every god names the
// domains it holds (dv_domains) and is heard by that domain's holy objects.

/datum/patron/palimpseste
	preference_accessible = TRUE
	undead_hater = TRUE
	worshippers = "Those born to its land, and converts along the seams"

/datum/patron/palimpseste/can_pray(mob/living/follower)
	. = ..()
	var/datum/domain/D = follower.divine_domain
	if(!D || D.can_pray_here(follower))
		return TRUE
	to_chat(follower, span_danger("For [name] to hear me I must pray at [D.pray_hint]."))
	return FALSE

/datum/faith/palimpseste
	preference_accessible = FALSE

// ============================================================================
// TAMAREL - the Nine Lights and the Daedric Princes
// ============================================================================

/datum/faith/palimpseste/nine_lights
	name = "The Nine Lights"
	desc = "The imperial faith of Tamarhel: eight Aedric gods who gave of themselves to make the world, and the ninth, a mortal hero who climbed to godhood."
	worshippers = "Most Tamarhelians, the Imperial legions, Skarnheim's jarls"

/datum/faith/palimpseste/princes
	name = "The Daedric Princes"
	desc = "The Princes of Oblivion, who never gave anything to the world and so were never diminished by it. They bargain, they tempt and they collect."
	worshippers = "Cultists, witches, the desperate and the curious"

/datum/patron/palimpseste/nine_lights
	associated_faith = /datum/faith/palimpseste/nine_lights
/datum/patron/palimpseste/princes
	associated_faith = /datum/faith/palimpseste/princes

/datum/patron/palimpseste/nine_lights/akatash
	name = "Akatash"
	domain = "God of Time, Dragons and Endurance"
	desc = "The Dragon of Time, first and chief of the Nine Lights. Kings are crowned in his name and his fire keeps the world from unravelling."
	dv_domains = list(/datum/domain/sun, /datum/domain/law)
/datum/patron/palimpseste/nine_lights/arkey
	name = "Arkey"
	domain = "God of Birth, Death and the Cycle"
	desc = "Keeper of the turning wheel of life. His priests bury the dead properly and put down those who refuse to stay buried."
	dv_domains = list(/datum/domain/death)
/datum/patron/palimpseste/nine_lights/maera
	name = "Maera"
	domain = "Goddess of Love, Compassion and the Home"
	desc = "The Mother-Goddess, oldest of the Nine. Marriages are sworn before her and hearths kept in her honour."
	dv_domains = list(/datum/domain/love, /datum/domain/hearth)
/datum/patron/palimpseste/nine_lights/stendaal
	name = "Stendaal"
	domain = "God of Mercy, Charity and Righteous Might"
	desc = "The merciful god whose vigilant order hunts daedra-worshippers and vampires with no mercy at all."
	dv_domains = list(/datum/domain/healing, /datum/domain/law)
/datum/patron/palimpseste/nine_lights/kynarath
	name = "Kynarath"
	domain = "Goddess of Air, Sky and the Wild"
	desc = "Queen of the heavens and the winds, patron of sailors, hunters and anyone who sleeps under the open sky."
	dv_domains = list(/datum/domain/wilds, /datum/domain/sea)
/datum/patron/palimpseste/nine_lights/julanos
	name = "Julanos"
	domain = "God of Wisdom, Logic and Law"
	desc = "The god of scholars and magistrates alike, who holds that a contract is a kind of spell."
	dv_domains = list(/datum/domain/knowledge, /datum/domain/law)
/datum/patron/palimpseste/nine_lights/dibelle
	name = "Dibelle"
	domain = "Goddess of Beauty, Art and Passion"
	desc = "Patron of artists and lovers, whose temples are the most beautiful buildings in every city and the least chaste."
	dv_domains = list(/datum/domain/love)
/datum/patron/palimpseste/nine_lights/zennar
	name = "Zennar"
	domain = "God of Work, Commerce and Honest Wealth"
	desc = "The merchant-god, who blesses a fair trade and a hard day's work and scorns the idle rich."
	dv_domains = list(/datum/domain/trade, /datum/domain/craft)
/datum/patron/palimpseste/nine_lights/talus
	name = "Talus"
	domain = "God of War, Heroes and Governance"
	desc = "The Ninth Light: a mortal emperor who conquered the continent and then heaven. Elves say he is no god; Skarnheim says otherwise, loudly."
	dv_domains = list(/datum/domain/war)

/datum/patron/palimpseste/princes/molag_vaal
	name = "Molag Vaal"
	domain = "Prince of Domination and Enslavement"
	desc = "The King of Rape and Chains, who wants every soul in his cage and usually gets it."
	dv_domains = list(/datum/domain/forbidden, /datum/domain/war)
/datum/patron/palimpseste/princes/sheogarath
	name = "Sheogarath"
	domain = "Prince of Madness"
	desc = "The Mad God, whose blessings and curses are indistinguishable. Prayers to him are answered, which is the problem."
	dv_domains = list(/datum/domain/trickery)
/datum/patron/palimpseste/princes/hermaeon_mora
	name = "Hermaeon Mora"
	domain = "Prince of Forbidden Knowledge and Fate"
	desc = "The Woodland Man, a sea of eyes and tentacles who trades secrets for souls and always gets the better bargain."
	dv_domains = list(/datum/domain/knowledge, /datum/domain/forbidden)
/datum/patron/palimpseste/princes/azhura
	name = "Azhura"
	domain = "Princess of Dusk, Dawn and Prophecy"
	desc = "The Queen of the twilight between day and night, the one Prince the dark elves love and trust."
	dv_domains = list(/datum/domain/moon)
/datum/patron/palimpseste/princes/hirceen
	name = "Hirceen"
	domain = "Prince of the Hunt"
	desc = "The Huntsman, father of werebeasts, who asks only a worthy chase and a fair kill."
	dv_domains = list(/datum/domain/wilds)
/datum/patron/palimpseste/princes/noctural
	name = "Noctural"
	domain = "Princess of Night, Shadow and Luck"
	desc = "The Night Mistress, patron of thieves, who keeps her own secrets best of all."
	dv_domains = list(/datum/domain/moon, /datum/domain/trickery)

// ============================================================================
// THE CONJUNCT
// ============================================================================

/datum/faith/palimpseste/conjunct
	name = "The Temples of the North"
	desc = "The many small cults of the Conjunct's kingdoms, each with its own temple, its own priests and its own opinion of the others."
	worshippers = "Northern kingdoms, Skelligers, peasants and kings"
/datum/patron/palimpseste/conjunct
	associated_faith = /datum/faith/palimpseste/conjunct

/datum/patron/palimpseste/conjunct/melitelle
	name = "Melitelle"
	domain = "Goddess of Harvest, Motherhood and Healing"
	desc = "The kindly goddess of the Conjunct's hospices and fields; her priestesses heal anyone, even monster-slayers."
	dv_domains = list(/datum/domain/harvest, /datum/domain/healing)
/datum/patron/palimpseste/conjunct/undying_flame
	name = "The Undying Flame"
	domain = "The Eternal Fire"
	desc = "A faith of fire, zeal and witch-burning that has spread through the cities like the thing it worships."
	dv_domains = list(/datum/domain/sun, /datum/domain/law)
/datum/patron/palimpseste/conjunct/kreva
	name = "Kreva"
	domain = "God of War, Storms and Wrath"
	desc = "A thundering old god whose priests are as quick to curse as to bless."
	dv_domains = list(/datum/domain/war)
/datum/patron/palimpseste/conjunct/freyja
	name = "Freyja"
	domain = "Goddess of Fertility, Love and Seeing"
	desc = "The island goddess of the Skelliger clans, mother of warriors and seers."
	dv_domains = list(/datum/domain/love, /datum/domain/harvest)
/datum/patron/palimpseste/conjunct/lebiod
	name = "Lebiod"
	domain = "The Prophet of Law"
	desc = "A prophet who once tamed a dragon with words alone; his followers keep his long and exacting teachings."
	dv_domains = list(/datum/domain/law, /datum/domain/knowledge)

// ============================================================================
// FAERHEN
// ============================================================================

/datum/faith/palimpseste/faerhen
	name = "The Faerhenic Pantheon"
	desc = "A crowded heaven of gods great and small, who live, fight and occasionally die among themselves."
	worshippers = "Faerhenians of every race and alignment"
/datum/patron/palimpseste/faerhen
	associated_faith = /datum/faith/palimpseste/faerhen

/datum/patron/palimpseste/faerhen/lathandre
	name = "Lathandre"
	domain = "God of Dawn, Renewal and Beginnings"
	desc = "The Morninglord, whose clerics greet each sunrise and destroy the undead with righteous cheer."
	dv_domains = list(/datum/domain/sun)
/datum/patron/palimpseste/faerhen/seluna
	name = "Selûna"
	domain = "Goddess of the Moon, Stars and Navigation"
	desc = "The Moonmaiden, guide of lost travellers and eternal enemy of her dark sister."
	dv_domains = list(/datum/domain/moon)
/datum/patron/palimpseste/faerhen/tymara
	name = "Tymara"
	domain = "Goddess of Good Fortune"
	desc = "Lady Luck, patron of adventurers and gamblers: fortune favours the bold."
	dv_domains = list(/datum/domain/trickery)
/datum/patron/palimpseste/faerhen/tempos
	name = "Tempos"
	domain = "God of War"
	desc = "The Foehammer, who cares only that war is fought well, not for which side."
	dv_domains = list(/datum/domain/war)
/datum/patron/palimpseste/faerhen/mystrel
	name = "Mystrel"
	domain = "Goddess of Magic"
	desc = "Mother of the Weave through which all magic flows; when she falters, spells fail across the land."
	dv_domains = list(/datum/domain/knowledge)
/datum/patron/palimpseste/faerhen/kelvemor
	name = "Kelvemor"
	domain = "God of the Dead and Judgment"
	desc = "The Lord of the Dead, a once-mortal who judges fairly and hates the undead."
	dv_domains = list(/datum/domain/death, /datum/domain/law)
/datum/patron/palimpseste/faerhen/chauntae
	name = "Chauntae"
	domain = "Goddess of Agriculture and Growing Things"
	desc = "The Great Mother of farmers and gardeners."
	dv_domains = list(/datum/domain/harvest)
/datum/patron/palimpseste/faerhen/moradun
	name = "Moradun"
	domain = "God of Dwarves, Forge and Creation"
	desc = "The Soul Forger, father of the dwarves, who hammered them from the stone."
	dv_domains = list(/datum/domain/craft)
/datum/patron/palimpseste/faerhen/corellan
	name = "Corellan"
	domain = "God of Elves, Art and Magic"
	desc = "The Creator of the Elves, patron of poetry, music and graceful magic."
	dv_domains = list(/datum/domain/knowledge, /datum/domain/love)
/datum/patron/palimpseste/faerhen/baen
	name = "Baen"
	domain = "God of Tyranny and Fear"
	desc = "The Black Hand, who teaches that the strong should rule and the weak should serve."
	dv_domains = list(/datum/domain/law, /datum/domain/forbidden)
/datum/patron/palimpseste/faerhen/sharr
	name = "Sharr"
	domain = "Goddess of Darkness, Loss and Secrets"
	desc = "The Mistress of the Night, Selûna's dark twin, who offers the relief of forgetting."
	dv_domains = list(/datum/domain/moon, /datum/domain/forbidden)

// ============================================================================
// THESSADRA
// ============================================================================

/datum/faith/palimpseste/thessadra
	name = "The Chantry and the Old Ways"
	desc = "Thessadra's Chantry sings to a Maker who turned away, through the Prophet who died for him; its elves remember older gods, and its dwarves only their ancestors."
	worshippers = "Thessadrans, templars, circle mages, the elves of the forests"
/datum/patron/palimpseste/thessadra
	associated_faith = /datum/faith/palimpseste/thessadra

/datum/patron/palimpseste/thessadra/maker
	name = "The Turned-Away Maker"
	domain = "The Creator Who Left"
	desc = "The god who made the world and walked away in grief. The Chantry sings to call him back."
	dv_domains = list(/datum/domain/law, /datum/domain/hearth)
/datum/patron/palimpseste/thessadra/andrastae
	name = "Andrastae"
	domain = "The Prophet-Bride"
	desc = "A warrior-prophet burned by her enemies, now venerated as the Maker's bride."
	dv_domains = list(/datum/domain/war, /datum/domain/law)
/datum/patron/palimpseste/thessadra/mythael
	name = "Mythael"
	domain = "Elven Goddess of Motherhood and Justice"
	desc = "The Great Protector of the old elves, who judged and avenged."
	dv_domains = list(/datum/domain/love, /datum/domain/law)
/datum/patron/palimpseste/thessadra/fen_harrow
	name = "Fen'Harrow"
	domain = "The Dread Wolf"
	desc = "The elven trickster who sealed the gods away, and whom elves still curse."
	dv_domains = list(/datum/domain/trickery, /datum/domain/forbidden)
/datum/patron/palimpseste/thessadra/old_wyrms
	name = "The Old Wyrms"
	domain = "The Sleeping Dragon-Gods"
	desc = "Seven dragon-gods sealed beneath the earth, whose whispers corrupted an empire."
	dv_domains = list(/datum/domain/forbidden)

// ============================================================================
// GOLAREN
// ============================================================================

/datum/faith/palimpseste/golaren
	name = "The Golarene Pantheon"
	desc = "Twenty gods of the Inner Sea, some born divine, some ascended from mortality through a stone that no longer works."
	worshippers = "Golarenes of every nation"
/datum/patron/palimpseste/golaren
	associated_faith = /datum/faith/palimpseste/golaren

/datum/patron/palimpseste/golaren/iomedea
	name = "Iomedea"
	domain = "Goddess of Valour, Justice and Honour"
	desc = "The Inheritor, a knight who ascended and now leads crusades against demons."
	dv_domains = list(/datum/domain/war, /datum/domain/law)
/datum/patron/palimpseste/golaren/desnae
	name = "Desnae"
	domain = "Goddess of Dreams, Stars, Travel and Luck"
	desc = "The Song of the Spheres, beloved of wanderers and lovers of freedom."
	dv_domains = list(/datum/domain/moon, /datum/domain/trickery)
/datum/patron/palimpseste/golaren/pharasme
	name = "Pharasme"
	domain = "Goddess of Birth, Death and Fate"
	desc = "The Lady of Graves, who judges every soul and loathes the undead above all things."
	dv_domains = list(/datum/domain/death)
/datum/patron/palimpseste/golaren/sarenra
	name = "Sarenra"
	domain = "Goddess of the Sun, Healing and Redemption"
	desc = "The Dawnflower, who heals the repentant and burns the unrepentant."
	dv_domains = list(/datum/domain/sun, /datum/domain/healing)
/datum/patron/palimpseste/golaren/abadran
	name = "Abadran"
	domain = "God of Cities, Law and Wealth"
	desc = "The Master of the First Vault, patron of civilisation and fair markets."
	dv_domains = list(/datum/domain/trade, /datum/domain/law)
/datum/patron/palimpseste/golaren/gorun
	name = "Gorun"
	domain = "God of Strength and Battle"
	desc = "Our Lord in Iron, who is prayed to only by fighting."
	dv_domains = list(/datum/domain/war)
/datum/patron/palimpseste/golaren/nethis
	name = "Nethis"
	domain = "God of Magic"
	desc = "The All-Seeing Eye, split between the urge to create and to destroy."
	dv_domains = list(/datum/domain/knowledge)
/datum/patron/palimpseste/golaren/lamashta
	name = "Lamashta"
	domain = "Mother of Monsters"
	desc = "The demon-goddess of madness and deformity, worshipped by gnolls and worse."
	dv_domains = list(/datum/domain/forbidden)

// ============================================================================
// THE ACHAEON ISLES
// ============================================================================

/datum/faith/palimpseste/achaeon
	name = "The Olympic Twelve"
	desc = "The quarrelsome gods of the high mountain, and their brother below in Erebor Deep. They meddle, they feud and they remember every slight."
	worshippers = "Achaeons, heroes, and anyone who fears hubris"
/datum/patron/palimpseste/achaeon
	associated_faith = /datum/faith/palimpseste/achaeon

/datum/patron/palimpseste/achaeon/zeon
	name = "Zeon"
	domain = "King of the Gods, Sky and Thunder"
	desc = "The thunder-king of the mountain, oath-keeper and oath-breaker in equal measure."
	dv_domains = list(/datum/domain/law, /datum/domain/war)
/datum/patron/palimpseste/achaeon/haedes
	name = "Haedes"
	domain = "Lord of the Dead and Erebor Deep"
	desc = "The unsmiling king below, who keeps the dead and resents anyone who tries to leave."
	dv_domains = list(/datum/domain/death)
/datum/patron/palimpseste/achaeon/poseidos
	name = "Poseidos"
	domain = "God of the Sea and Earthquakes"
	desc = "The Earth-Shaker, whose temper drowns fleets."
	dv_domains = list(/datum/domain/sea)
/datum/patron/palimpseste/achaeon/athenea
	name = "Athenea"
	domain = "Goddess of Wisdom, Craft and Strategy"
	desc = "The grey-eyed goddess, patron of heroes who think before they strike."
	dv_domains = list(/datum/domain/knowledge, /datum/domain/war)
/datum/patron/palimpseste/achaeon/areos
	name = "Areos"
	domain = "God of Bloodshed and Battle-Lust"
	desc = "The brute of the Twelve, loved by no one but soldiers."
	dv_domains = list(/datum/domain/war)
/datum/patron/palimpseste/achaeon/aphrodel
	name = "Aphrodel"
	domain = "Goddess of Love and Beauty"
	desc = "Born of sea-foam, she answers every lover's prayer - usually badly."
	dv_domains = list(/datum/domain/love)
/datum/patron/palimpseste/achaeon/demetra
	name = "Demetra"
	domain = "Goddess of Grain and the Seasons"
	desc = "The harvest-mother, whose grief for her stolen daughter is winter."
	dv_domains = list(/datum/domain/harvest)
/datum/patron/palimpseste/achaeon/hestea
	name = "Hestea"
	domain = "Goddess of the Hearth"
	desc = "The gentlest of the Twelve, given the first offering of every meal."
	dv_domains = list(/datum/domain/hearth)
/datum/patron/palimpseste/achaeon/hermon
	name = "Hermon"
	domain = "God of Travellers, Thieves and Messengers"
	desc = "The swift-footed trickster who guides the dead and the living alike."
	dv_domains = list(/datum/domain/trade, /datum/domain/trickery)
/datum/patron/palimpseste/achaeon/hephestos
	name = "Hephestos"
	domain = "God of the Forge"
	desc = "The lame smith of the gods, whose works outshine their makers."
	dv_domains = list(/datum/domain/craft)
/datum/patron/palimpseste/achaeon/artemia
	name = "Artemia"
	domain = "Goddess of the Hunt and the Moon"
	desc = "The virgin huntress, protector of the wild and of girls."
	dv_domains = list(/datum/domain/wilds, /datum/domain/moon)
/datum/patron/palimpseste/achaeon/apollon
	name = "Apollon"
	domain = "God of the Sun, Music, Prophecy and Healing"
	desc = "The shining archer, whose oracles speak truth in riddles."
	dv_domains = list(/datum/domain/sun, /datum/domain/healing)
/datum/patron/palimpseste/achaeon/dionyseus
	name = "Dionyseus"
	domain = "God of Wine, Revelry and Madness"
	desc = "The twice-born, who frees the mind and sometimes forgets to give it back."
	dv_domains = list(/datum/domain/love, /datum/domain/trickery)
/datum/patron/palimpseste/achaeon/persephae
	name = "Persephae"
	domain = "Queen of the Underworld and Spring"
	desc = "Half the year below, half above; the dead pray to her for mercy and the living for flowers."
	dv_domains = list(/datum/domain/harvest, /datum/domain/death)
/datum/patron/palimpseste/achaeon/hekatia
	name = "Hekatia"
	domain = "Goddess of Crossroads, Witchcraft and the Night"
	desc = "Torch-bearer at the three-way road, mistress of witches."
	dv_domains = list(/datum/domain/moon, /datum/domain/forbidden)
/datum/patron/palimpseste/achaeon/nyxa
	name = "Nyxa"
	domain = "Primordial Night"
	desc = "Older than the Twelve, feared even by the thunder-king."
	dv_domains = list(/datum/domain/moon)

// ============================================================================
// THE LAURENTINE DOMINION
// ============================================================================

/datum/faith/palimpseste/laurentine
	name = "The State Cults of the Dominion"
	desc = "The Dominion's official gods, honoured by law, with room in the pantheon for any conquered people's gods who pay their taxes."
	worshippers = "Laurentine citizens, legionaries, magistrates"
/datum/patron/palimpseste/laurentine
	associated_faith = /datum/faith/palimpseste/laurentine

/datum/patron/palimpseste/laurentine/jovian
	name = "Jovian"
	domain = "Best and Greatest, God of the State and Sky"
	desc = "Chief of the Dominion's gods, in whose temple the senate swears its oaths."
	dv_domains = list(/datum/domain/law)
/datum/patron/palimpseste/laurentine/marsus
	name = "Marsus"
	domain = "Father of the Legions"
	desc = "God of war and of the spring planting that feeds the armies."
	dv_domains = list(/datum/domain/war, /datum/domain/harvest)
/datum/patron/palimpseste/laurentine/vestra
	name = "Vestra"
	domain = "Goddess of the Sacred Hearth"
	desc = "Her eternal flame is kept by sworn virgins; if it goes out, the Dominion falls."
	dv_domains = list(/datum/domain/hearth)
/datum/patron/palimpseste/laurentine/minerve
	name = "Minerve"
	domain = "Goddess of Wisdom and Crafts"
	desc = "Patron of guilds, schools and strategists."
	dv_domains = list(/datum/domain/knowledge, /datum/domain/craft)
/datum/patron/palimpseste/laurentine/janos
	name = "Janos"
	domain = "God of Doors, Beginnings and Endings"
	desc = "Two-faced, looking back and forward; his temple doors open in war and close in peace."
	dv_domains = list(/datum/domain/trickery, /datum/domain/law)
/datum/patron/palimpseste/laurentine/mercurion
	name = "Mercurion"
	domain = "God of Merchants and Messages"
	desc = "Winged patron of every trade road in the Dominion."
	dv_domains = list(/datum/domain/trade)
/datum/patron/palimpseste/laurentine/cerea
	name = "Cerea"
	domain = "Goddess of Grain"
	desc = "Her festival feeds the plebs; her anger starves them."
	dv_domains = list(/datum/domain/harvest)
/datum/patron/palimpseste/laurentine/plutor
	name = "Plutor"
	domain = "God of the Underworld and Buried Wealth"
	desc = "Lord of the dead and of everything dug from the ground."
	dv_domains = list(/datum/domain/death, /datum/domain/trade)
/datum/patron/palimpseste/laurentine/venara
	name = "Venara"
	domain = "Goddess of Love and Victory"
	desc = "Mother of the Dominion's founding line, patron of lovers and generals."
	dv_domains = list(/datum/domain/love)
/datum/patron/palimpseste/laurentine/sol_invicta
	name = "Sol Invicta"
	domain = "The Unconquered Sun"
	desc = "The legions' favourite god: the sun that rises every day, whatever happened the night before."
	dv_domains = list(/datum/domain/sun)

// ============================================================================
// THE KHEMET SANDS
// ============================================================================

/datum/faith/palimpseste/khemet
	name = "The Gods of the Two Lands"
	desc = "The ancient gods of the river-kingdom, who guide the sun across the sky and the dead through the hall of judgment."
	worshippers = "Khemeti, priests, embalmers, tomb-builders"
/datum/patron/palimpseste/khemet
	associated_faith = /datum/faith/palimpseste/khemet

/datum/patron/palimpseste/khemet/rahn
	name = "Rahn"
	domain = "God of the Sun and Kingship"
	desc = "The falcon-headed sun who sails the sky by day and fights the serpent of chaos by night."
	dv_domains = list(/datum/domain/sun, /datum/domain/law)
/datum/patron/palimpseste/khemet/osirith
	name = "Osirith"
	domain = "God of the Afterlife and Resurrection"
	desc = "The murdered king who rose again to rule the dead."
	dv_domains = list(/datum/domain/death, /datum/domain/harvest)
/datum/patron/palimpseste/khemet/isset
	name = "Isset"
	domain = "Goddess of Magic, Motherhood and Healing"
	desc = "Who gathered her husband's scattered body and breathed life back into it."
	dv_domains = list(/datum/domain/healing, /datum/domain/love)
/datum/patron/palimpseste/khemet/anubet
	name = "Anubet"
	domain = "Guardian of Tombs and Weigher of Hearts"
	desc = "The jackal-headed embalmer, who guides the dead to judgment."
	dv_domains = list(/datum/domain/death)
/datum/patron/palimpseste/khemet/thothe
	name = "Thothe"
	domain = "God of Writing, Wisdom and the Moon"
	desc = "The ibis-headed scribe who records the verdict of every soul."
	dv_domains = list(/datum/domain/knowledge, /datum/domain/moon)
/datum/patron/palimpseste/khemet/setekh
	name = "Setekh"
	domain = "God of Storms, Deserts and Chaos"
	desc = "The red god, murderer of his brother, feared and needed in equal measure."
	dv_domains = list(/datum/domain/forbidden, /datum/domain/war)
/datum/patron/palimpseste/khemet/maahet
	name = "Ma'ahet"
	domain = "Goddess of Truth and Cosmic Order"
	desc = "Her feather is weighed against every heart."
	dv_domains = list(/datum/domain/law)
/datum/patron/palimpseste/khemet/bastai
	name = "Bastai"
	domain = "Goddess of the Home, Cats and Protection"
	desc = "The cat-goddess who guards the household from snakes, plague and evil spirits."
	dv_domains = list(/datum/domain/hearth)
/datum/patron/palimpseste/khemet/sobekh
	name = "Sobekh"
	domain = "God of the River and its Crocodiles"
	desc = "Lord of the flood and of the teeth beneath it."
	dv_domains = list(/datum/domain/sea)
/datum/patron/palimpseste/khemet/hathora
	name = "Hathora"
	domain = "Goddess of Love, Music and Joy"
	desc = "The cow-horned goddess of dancing and drunkenness, and in her rage, the lioness."
	dv_domains = list(/datum/domain/love)

// ============================================================================
// ASHURIM (and the dry gods of Athrae)
// ============================================================================

/datum/faith/palimpseste/ashurim
	name = "The Gods of the Two Rivers"
	desc = "The gods of the first cities, who made mankind from clay to do their labour and have never let them forget it."
	worshippers = "Ashurites, Athraen oasis-dwellers, scribes and kings"
/datum/patron/palimpseste/ashurim
	associated_faith = /datum/faith/palimpseste/ashurim

/datum/patron/palimpseste/ashurim/mardukh
	name = "Mardukh"
	domain = "King of the Gods and Order"
	desc = "Who slew the chaos-dragon and built the world from her body."
	dv_domains = list(/datum/domain/law, /datum/domain/war)
/datum/patron/palimpseste/ashurim/ishtara
	name = "Ishtara"
	domain = "Goddess of Love, War and the Morning Star"
	desc = "Who descended into the underworld and came back; lovers and soldiers pray to her alike."
	dv_domains = list(/datum/domain/love, /datum/domain/war)
/datum/patron/palimpseste/ashurim/enkai
	name = "Enkai"
	domain = "God of Fresh Water, Wisdom and Craft"
	desc = "The clever god of the deep waters who taught the arts of civilisation."
	dv_domains = list(/datum/domain/sea, /datum/domain/knowledge, /datum/domain/craft)
/datum/patron/palimpseste/ashurim/ereshkigul
	name = "Ereshkigul"
	domain = "Queen of the Land of No Return"
	desc = "The grim sister who rules the dust-eating dead."
	dv_domains = list(/datum/domain/death)
/datum/patron/palimpseste/ashurim/nergul
	name = "Nergul"
	domain = "God of Plague, War and the Scorching Sun"
	desc = "The destroyer, husband of the queen below, bringer of fever and famine."
	dv_domains = list(/datum/domain/war, /datum/domain/forbidden)
/datum/patron/palimpseste/ashurim/shamashu
	name = "Shamashu"
	domain = "God of the Sun and Justice"
	desc = "The all-seeing sun who hands the law to kings."
	dv_domains = list(/datum/domain/sun, /datum/domain/law)
/datum/patron/palimpseste/ashurim/tiamet
	name = "Tiamet"
	domain = "The Chaos-Dragon of the Salt Sea"
	desc = "Mother of monsters, slain and not quite dead. Athrae's sorcerer-kings are said to have learned from her."
	dv_domains = list(/datum/domain/forbidden, /datum/domain/sea)

// ============================================================================
// THE ILÉ-ORUN COAST
// ============================================================================

/datum/faith/palimpseste/ile_orun
	name = "The Orisha"
	desc = "The spirits who walk among the people of the coast, honoured with drums, offerings and possession-dances."
	worshippers = "Oruni, their diviners and devotees"
/datum/patron/palimpseste/ile_orun
	associated_faith = /datum/faith/palimpseste/ile_orun

/datum/patron/palimpseste/ile_orun/shangoh
	name = "Shangoh"
	domain = "Orisha of Thunder, Fire and Justice"
	desc = "A king who became thunder, wielder of the double axe."
	dv_domains = list(/datum/domain/war, /datum/domain/law)
/datum/patron/palimpseste/ile_orun/oguun
	name = "Oguun"
	domain = "Orisha of Iron, Labour and War"
	desc = "Who cleared the first path through the forest with his machete; every smith and soldier owes him."
	dv_domains = list(/datum/domain/craft, /datum/domain/war)
/datum/patron/palimpseste/ile_orun/oshuna
	name = "Oshuna"
	domain = "Orisha of Rivers, Love and Fertility"
	desc = "The sweet-water goddess of beauty and healing, generous and quick to anger."
	dv_domains = list(/datum/domain/love, /datum/domain/healing)
/datum/patron/palimpseste/ile_orun/yemojah
	name = "Yemojah"
	domain = "Mother of the Sea"
	desc = "Great mother of the waters and of all the orisha."
	dv_domains = list(/datum/domain/sea, /datum/domain/hearth)
/datum/patron/palimpseste/ile_orun/eshuun
	name = "Eshuun"
	domain = "Orisha of Crossroads, Messages and Mischief"
	desc = "The messenger who stands at every crossroads; every offering starts with him or goes nowhere."
	dv_domains = list(/datum/domain/trickery, /datum/domain/trade)
/datum/patron/palimpseste/ile_orun/orunmilah
	name = "Orunmilah"
	domain = "Orisha of Wisdom and Divination"
	desc = "Witness to fate, whose diviners read destiny in palm-nuts."
	dv_domains = list(/datum/domain/knowledge)
/datum/patron/palimpseste/ile_orun/oyah
	name = "Oyah"
	domain = "Orisha of Winds, Storms and the Gates of Death"
	desc = "The storm-warrior who guards the cemetery gate."
	dv_domains = list(/datum/domain/death, /datum/domain/war)
/datum/patron/palimpseste/ile_orun/ananse
	name = "Ananse"
	domain = "The Spider Who Owns the Stories"
	desc = "The trickster who bought every story in the world from the sky-god."
	dv_domains = list(/datum/domain/trickery, /datum/domain/knowledge)

// ============================================================================
// TURTLE'S BACK
// ============================================================================

/datum/faith/palimpseste/turtles_back
	name = "The Spirit Nations"
	desc = "The spirits of the animal nations and the sky, kept in balance through ceremony and the counsel of spirit-walkers."
	worshippers = "The peoples of Turtle's Back"
/datum/patron/palimpseste/turtles_back
	associated_faith = /datum/faith/palimpseste/turtles_back

/datum/patron/palimpseste/turtles_back/sky_mother
	name = "Sky-Mother"
	domain = "She Who Fell and Made the Land"
	desc = "Who fell from the sky-world onto the turtle's back and planted the first seeds."
	dv_domains = list(/datum/domain/harvest, /datum/domain/hearth)
/datum/patron/palimpseste/turtles_back/thunder_bird
	name = "The Thunder-Bird"
	domain = "Spirit of Storms and Protection"
	desc = "Whose wingbeats are thunder, and who battles the horned serpents below."
	dv_domains = list(/datum/domain/war, /datum/domain/sun)
/datum/patron/palimpseste/turtles_back/old_coyote
	name = "Old Coyote"
	domain = "The Laughing Trickster"
	desc = "Creator, fool and thief, whose mistakes shaped as much of the world as his cleverness."
	dv_domains = list(/datum/domain/trickery, /datum/domain/wilds)
/datum/patron/palimpseste/turtles_back/grandfather_raven
	name = "Grandfather Raven"
	domain = "Bringer of Light and Secrets"
	desc = "Who stole the sun from a box and let it into the world."
	dv_domains = list(/datum/domain/trickery, /datum/domain/knowledge)
/datum/patron/palimpseste/turtles_back/starving_one
	name = "The Starving One"
	domain = "The Hunger of the Winter Woods"
	desc = "A spirit of greed and famine. Nobody worships it. A few feed it."
	dv_domains = list(/datum/domain/forbidden, /datum/domain/wilds)

// ============================================================================
// HINOMURA
// ============================================================================

/datum/faith/palimpseste/hinomura
	name = "The Way of the Kami"
	desc = "The worship of the countless kami of Hinomura, from the sun-goddess to the spirit of a single old tree."
	worshippers = "Hinomurans, shrine-keepers, warrior houses"
/datum/patron/palimpseste/hinomura
	associated_faith = /datum/faith/palimpseste/hinomura

/datum/patron/palimpseste/hinomura/amaterasa
	name = "Amaterasa"
	domain = "Kami of the Sun"
	desc = "Ancestor of the imperial line, who once hid in a cave and plunged the world into darkness."
	dv_domains = list(/datum/domain/sun, /datum/domain/law)
/datum/patron/palimpseste/hinomura/susanowo
	name = "Susanowo"
	domain = "Kami of Storms and the Sea"
	desc = "The unruly storm-brother, slayer of the eight-headed serpent."
	dv_domains = list(/datum/domain/sea, /datum/domain/war)
/datum/patron/palimpseste/hinomura/tsukuyame
	name = "Tsukuyame"
	domain = "Kami of the Moon"
	desc = "The cold moon-brother, estranged from the sun forever."
	dv_domains = list(/datum/domain/moon)
/datum/patron/palimpseste/hinomura/inarei
	name = "Inarei"
	domain = "Kami of Rice, Prosperity and Foxes"
	desc = "Whose fox messengers guard ten thousand red gates."
	dv_domains = list(/datum/domain/harvest, /datum/domain/trade)
/datum/patron/palimpseste/hinomura/hachimon
	name = "Hachimon"
	domain = "Kami of Archery and War"
	desc = "Protector of the warrior houses."
	dv_domains = list(/datum/domain/war)
/datum/patron/palimpseste/hinomura/izanamu
	name = "Izanamu"
	domain = "Kami of Creation and Death"
	desc = "Mother of the islands, who died giving birth to fire and now rules the land of the dead."
	dv_domains = list(/datum/domain/death)
/datum/patron/palimpseste/hinomura/raijen
	name = "Raijen"
	domain = "Kami of Thunder"
	desc = "The drum-beating thunder demon, who eats the navels of careless children."
	dv_domains = list(/datum/domain/war, /datum/domain/trickery)

// ============================================================================
// TÍR AENNA
// ============================================================================

/datum/faith/palimpseste/tir_aenna
	name = "The Folk of the Mounds"
	desc = "The old gods of Tír Aenna, who retreated into the hills and became the Fair Folk; they are bargained with more than worshipped."
	worshippers = "The Aennach, druids and poets"
/datum/patron/palimpseste/tir_aenna
	associated_faith = /datum/faith/palimpseste/tir_aenna

/datum/patron/palimpseste/tir_aenna/daghda
	name = "The Daghda"
	domain = "The Good God, of Plenty and the Seasons"
	desc = "Owner of the cauldron that never empties and the harp that turns the seasons."
	dv_domains = list(/datum/domain/harvest, /datum/domain/hearth)
/datum/patron/palimpseste/tir_aenna/bridhe
	name = "Bridhe"
	domain = "Goddess of the Forge, Poetry and Healing"
	desc = "Her flame is kept in three forms: the smith's fire, the healer's warmth, the poet's inspiration."
	dv_domains = list(/datum/domain/craft, /datum/domain/healing, /datum/domain/hearth)
/datum/patron/palimpseste/tir_aenna/morrigaun
	name = "The Morrigaun"
	domain = "The Phantom Queen of War and Fate"
	desc = "Who washes the armour of those about to die."
	dv_domains = list(/datum/domain/war, /datum/domain/death)
/datum/patron/palimpseste/tir_aenna/lughan
	name = "Lughan"
	domain = "God of All Skills and the Sun"
	desc = "Master of every art, who won his place among the gods by being good at everything."
	dv_domains = list(/datum/domain/craft, /datum/domain/sun)
/datum/patron/palimpseste/tir_aenna/manannaun
	name = "Manannaun"
	domain = "God of the Sea and the Otherworld"
	desc = "Who rides the waves like a plain and guards the way to the Otherworld."
	dv_domains = list(/datum/domain/sea)
/datum/patron/palimpseste/tir_aenna/cernonos
	name = "Cernonos"
	domain = "The Horned One of the Forest"
	desc = "Lord of beasts and the wild wood."
	dv_domains = list(/datum/domain/wilds)

// ============================================================================
// THE VYRLANDS (and Varovia)
// ============================================================================

/datum/faith/palimpseste/vyrlands
	name = "The Old Gods of the Birchwood"
	desc = "The gods of the Vyrlish forests: thunder in the oak, the serpent in the roots, the spinning mother at the hearth."
	worshippers = "Vyrlanders, Varovians, forest villages"
/datum/patron/palimpseste/vyrlands
	associated_faith = /datum/faith/palimpseste/vyrlands

/datum/patron/palimpseste/vyrlands/peruun
	name = "Peruun"
	domain = "God of Thunder and War"
	desc = "Who strikes the serpent from the top of the great oak."
	dv_domains = list(/datum/domain/war, /datum/domain/law)
/datum/patron/palimpseste/vyrlands/velos
	name = "Velos"
	domain = "God of the Underworld, Cattle and Trade"
	desc = "The serpent in the roots, herdsman of the dead, patron of merchants."
	dv_domains = list(/datum/domain/death, /datum/domain/trade, /datum/domain/wilds)
/datum/patron/palimpseste/vyrlands/mokosha
	name = "Mokosha"
	domain = "Goddess of Women, Weaving and Moist Earth"
	desc = "The spinning mother, keeper of hearth and harvest."
	dv_domains = list(/datum/domain/harvest, /datum/domain/hearth)
/datum/patron/palimpseste/vyrlands/dazhbogh
	name = "Dazhbogh"
	domain = "God of the Sun and Giving"
	desc = "The giving god, whose sun warms the fields."
	dv_domains = list(/datum/domain/sun)
/datum/patron/palimpseste/vyrlands/moranna
	name = "Moranna"
	domain = "Goddess of Winter and Death"
	desc = "Whose straw effigy is drowned each spring to send the cold away."
	dv_domains = list(/datum/domain/death)
/datum/patron/palimpseste/vyrlands/svarogh
	name = "Svarogh"
	domain = "God of Fire and the Forge"
	desc = "The heavenly smith, who forged the sun."
	dv_domains = list(/datum/domain/craft)
/datum/patron/palimpseste/vyrlands/dawnlord
	name = "The Dawnlord"
	domain = "The Morning Light of Varovia"
	desc = "The god Varovia's villagers pray to for a sunrise that never quite comes."
	dv_domains = list(/datum/domain/sun, /datum/domain/healing)
/datum/patron/palimpseste/vyrlands/mist_powers
	name = "The Mist Powers"
	domain = "The Dark That Holds Varovia"
	desc = "Whatever made the mist and chose its lord. They listen to prayers, which is worse than not listening."
	dv_domains = list(/datum/domain/forbidden)

// ============================================================================
// THE DUNMOOR ISLES and YHARROW
// ============================================================================

/datum/faith/palimpseste/dunmoor
	name = "The Abbey and the Void"
	desc = "The austere Abbey preaches the Seven Strictures and burns heretics; in the poor quarters, people carve bone charms and whisper to the Void."
	worshippers = "Dunmoorish overseers, dockhands, heretics"
/datum/patron/palimpseste/dunmoor
	associated_faith = /datum/faith/palimpseste/dunmoor

/datum/patron/palimpseste/dunmoor/strictures
	name = "The Seven Strictures"
	domain = "The Abbey's Law"
	desc = "Not a god but a law, which the Abbey worships more faithfully than most gods are."
	dv_domains = list(/datum/domain/law)
/datum/patron/palimpseste/dunmoor/outsidar
	name = "The Outsidar"
	domain = "The Voice of the Void"
	desc = "A young man with black eyes who appears in dreams, marks the curious and watches what they do with it."
	dv_domains = list(/datum/domain/forbidden, /datum/domain/trickery)

/datum/faith/palimpseste/yharrow
	name = "The Blood Ministry"
	desc = "Yharrow's church of healing blood, and the unspeakable things it learned from."
	worshippers = "Yharrowans, pilgrims, hunters"
/datum/patron/palimpseste/yharrow
	associated_faith = /datum/faith/palimpseste/yharrow

/datum/patron/palimpseste/yharrow/blood_ministry
	name = "The Holy Blood"
	domain = "The Ministration That Heals All Ills"
	desc = "The blood that cures every sickness. The church does not say where it comes from."
	dv_domains = list(/datum/domain/healing)
/datum/patron/palimpseste/yharrow/great_ones
	name = "The Great Ones Beyond"
	domain = "Eldritch Truths"
	desc = "Vast beings beyond the veil of the waking world, who reward insight with madness."
	dv_domains = list(/datum/domain/forbidden, /datum/domain/knowledge)
/datum/patron/palimpseste/yharrow/kosh
	name = "Kosh"
	domain = "The Drowned One of the Coast"
	desc = "A great one found dead on the shore, whose orphan still cries under the sea."
	dv_domains = list(/datum/domain/sea, /datum/domain/forbidden)

// ============================================================================
// THE HINGE and THE SEAMVALE
// ============================================================================

/datum/faith/palimpseste/seams
	name = "The Faiths of the Seams"
	desc = "Gods born where the lands meet: the belief of travellers, traders and those who know the world was stitched."
	worshippers = "Seamvalers, Hinge-born, planar travellers"
/datum/patron/palimpseste/seams
	associated_faith = /datum/faith/palimpseste/seams

/datum/patron/palimpseste/seams/lady_of_blades
	name = "The Lady of Blades"
	domain = "Silent Warden of the Hinge"
	desc = "A vast masked figure who glides through the Hinge's streets. She forbids worship; those who try are found flayed by her shadow."
	dv_domains = list(/datum/domain/law, /datum/domain/forbidden)
/datum/patron/palimpseste/seams/seamwarden
	name = "The Seamwarden"
	domain = "God of Thresholds, Travellers and Meetings"
	desc = "A young god of the Seamvale, born from every traveller's hope of a safe crossing. Nobody agrees what he looks like."
	dv_domains = list(/datum/domain/hearth, /datum/domain/trade)
