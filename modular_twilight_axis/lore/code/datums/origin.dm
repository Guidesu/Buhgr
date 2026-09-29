/datum/virtue/origin
	var/map_group_order = 4
	var/map_state_order = 1
	var/map_origin_order = 1
	var/map_visible = FALSE
	var/map_x = 50
	var/map_y = 50
	var/map_state_id
	var/map_state_name
	var/map_origin_name
	var/list_group_id
	var/list_group_name
	var/list_group_order = 0
	var/list_item_order = 0
	var/list_subgroup_name

/datum/virtue/origin/unknown
	map_group_order = 4
	map_state_order = 100
	map_origin_order = 1
	map_visible = FALSE
	map_x = 50.0
	map_y = 50.0
	map_state_id = "unknown"
	map_state_name = "Nowhere"
	map_origin_name = "Nowhere"
	list_group_order = 100
	list_item_order = 1
	name = "Nowhere"
	origin_name = "Elsewhere"
	desc = "I come from one of the many small settlements scattered across Psydonia, often too humble or remote to matter. Since I come from nowhere, I don't know any local language.<br>"
	origin_desc = "   ,   ,     —   , \
	  ,    ,       .    , \
	       ,       , \
	   — , , ,   ."

/datum/virtue/origin/azuria
	map_group_order = 1
	map_state_order = 1
	map_origin_order = 1
	map_visible = TRUE
	map_x = 18.4
	map_y = 38.8
	map_state_id = "azuria"
	map_state_name = "The Grand Duchy of Azuria"
	map_origin_name = "The Grand Duchy of Azuria"
	name = "Azurian"
	origin_name = "Azuria"
	desc = "I come from Azuria, a small, independent mountain enclave in the north of the Grenzelhoft Empire's territory. The high ridges ringing the valley to the south and west make Azuria nearly impossible to reach overland, keeping it relatively safe from the world's upheavals and invading armies.<br>"
	restricted = FALSE
	added_languages = list(/datum/language/oldazurian)
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%92%D0%B5%D0%BB%D0%B8%D0%BA%D0%BE%D0%B5_%D0%93%D0%B5%D1%80%D1%86%D0%BE%D0%B3%D1%81%D1%82%D0%B2%D0%BE_%D0%90%D0%B7%D1%83%D1%80%D0%B8%D1%8F'>Azuria</a></b> is a small, independent mountain enclave in the north of the Grenzelhoft Empire's territory. The high ridges ringing the valley to the south and west make Azuria nearly impossible to reach overland, keeping it relatively safe from the world's upheavals and invading armies. Because of this, Azuria has become a haven for the desperate, for adventurers, and for refugees streaming in from all over Grimoria.<br><br>The throne of the Grand Duchy rules the comparatively small lands of the Azurian valley, walled off to the south and west by a nearly impassable mountain range, and to the east and north by the gulf known as the Azure Basin, which opens into the Black Ocean. All secular power in Azuria belongs to the Grand Duke (or Duchess), who rules from their seat in the city of the Twilight Axis. Though the Grand Duke's line is tied to the Grenzelhoft dynasty, they are not a vassal of the Empire and keep their independence and sovereignty.<br><br>Azuria's main religion is the Church of the Ten. A priest sent by the Holy See serves in the church of the Twilight Axis, and the heir of the previous Grand Duke cannot be crowned without their blessing. Even so, though the Pantheon is strong in the Duchy, there is also a magister of the Inquisition of the Church of the All-Father, sent from Otava and answering to the marshal of their Order, whose fortresses stand in neighbouring Grenzelhoft lands. The agreement allowing the Inquisition to act in the Grand Duchy was made under pressure from the Imperial Church of the Eleven, which feared that followers of the All-Father might be persecuted within Azuria's borders.<br><br>The alliance between the churches of the Pantheon and the All-Father in Azuria is shaky, but beyond Grenzelhoft's political pressure it is held together by a common enemy: the cultists of the Despised pantheon and the Cult of Salvation, who are plentiful in the Duchy. Though their relations fall solely under spiritual authority, in interfaith disputes the priest of the Ten and the magister of the Inquisition traditionally turn to the Grand Duke as a neutral third party.<br><br>The Grand Duchy's past is poorly recorded. It is widely known that the current ruler's dynasty descends from the line of Grenzelhoft, which now rules the colossal Empire to the Duchy's south. Some say Azuria was first conquered by the Black Empire and then granted to the current Grand Duke's ancestors for their service to the Imperial Crown; others claim that in time out of mind the Grand Duke's dynasty came to these lands, broke the vampire clans that ruled them, and built a new order under the Ten on the ruins of their dark kingdom; among the elven diaspora, it's said the valley belonged to the elven people before the Grand Duke's army, backed by Grenzelhoft, invaded.<br><br>Whichever theory is true, today the Grand Duchy of Azuria is a sovereign, independent state that keeps to neutrality in world affairs. The Grand Duke was the only ruler on the western continent to take no part in the Twilight War, and so refugees fleeing the conflict flooded into the cities under their rule. Only time will tell whether the melting pot of cultures and peoples that Azuria has become can survive as a single, independent Duchy.<br><br>"

/datum/virtue/origin/enigma
	map_group_order = 3
	map_state_order = 3
	map_origin_order = 1
	map_visible = TRUE
	map_x = 64.2
	map_y = 75.0
	map_state_id = "enigma"
	map_state_name = "The Kingdom of Enigma"
	map_origin_name = "The Kingdom of Enigma"
	name = "Enigmian"
	origin_name = "Enigma"
	desc = "I come from the islands of Enigma, once a majestic kingdom famed for its hospitality and the many peoples living under its banners. Now the ancient pact that protected my home is broken, and the threat of vampires hangs over Enigma, sparing only the isle of Rockhill.<br>"
	restricted = FALSE
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%AD%D0%BD%D0%B8%D0%B3%D0%BC%D0%B0'>The Kingdom of Enigma</a></b> is a state on the large islands in the middle of the Sea of Travellers. Its foundations were built on the bones of slaves and convicts; cruelty and discipline in service of a common goal were honoured, while weakness, tenderness and above all defiance were foreign and suppressed. 'Rock and Stone, Discipline and Death', says the ancient motto that describes the philosophy of life in these lands. But... in these times the motto is losing its force. Truly hard times have come for the kingdom.<br><br>Today Enigma is a grim sight: the main island, the largest and once as rich as the wealthiest cities of Valoria, now fights for survival almost entirely alone. The ghoul invasion has destroyed any steady, stable communication between cities and fortresses, villages and hamlets.<br><br>Many castles, craft towns and settlements have suffered ruin and swift destruction, while the kingdom's largest cities fight on to survive: those mighty fortresses simply can't be taken without a long siege, and the scattered ghoul hordes, as everyone knows, don't know how to lay siege. Not yet.<br><br>Only around the city of Rockhill has any stable rural life survived. The peasants endure countless hardships, but at least the locals are protected from the vampires by a wide strait. The new Royal headquarters was set up here, from which the reconquest of the enslaved lands is planned. The Church of the Ten and the Inquisition are meant to play a key role in the king's plan.<br><br>"

/datum/virtue/origin/grenzelhoft
	map_group_order = 1
	map_state_order = 4
	map_origin_order = 1
	map_visible = TRUE
	map_x = 18.3
	map_y = 47.4
	map_state_id = "grenzelhoft"
	map_state_name = "The Grenzelhoft Empire"
	map_origin_name = "The Grenzelhoft Empire"
	name = "Grenzelhoftian"
	origin_name = "Grenzelhoft"
	added_languages = list(/datum/language/grenzelhoftian)
	desc = "I come from the lands of Grenzelhoft, which stretch from the northern mountains of Hammerhold to the Crimson Lands and the hot deserts of Naledi. My homeland's culture is built on militarism and national pride, which have made it the most powerful state in Grimoria.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%93%D1%80%D0%B5%D0%BD%D0%B7%D0%B5%D0%BB%D1%8C%D1%85%D0%BE%D1%84%D1%82,_%D0%A7%D1%91%D1%80%D0%BD%D0%B0%D1%8F_%D0%98%D0%BC%D0%BF%D0%B5%D1%80%D0%B8%D1%8F'>The Grenzelhoft Empire,</a></b> also known as the Great Imperial Pact of the Grenzelhoft Dynasty, the Zenitar Pact and the Black Empire, is a large feudal state at the heart of the western continent, covering much of its land. Uniting the most influential and wealthy western kingdoms under its flag, Grenzelhoft is rightly considered the most powerful empire in Grimoria.<br><br>Grenzelhoft's culture is built on militarism and national pride. The Empire's constant wars led to Grimoria's first professional army, and to a class of nobility who earned their status through military service rather than blood. Grenzelhoft spreads its culture by fire and sword, absorbing whole peoples. It was also Grenzelhoft that first fielded firearms on a mass scale in its armed forces.<br><br>The reigning ruler of the Empire, bearing the title His Imperial Majesty, by the Grace of the All-Father and the Ten Kaiser of the Zenitar Pact and King of Zentarion, is Alister IV Grenzelhoft. His power within the Pact is nearly unquestioned, but it rests heavily on the support of the Kaiserstag, the Grenzelhoft Empire's highest legislative council, which represents the imperial estates in making laws and handing down judgements.<br><br>In matters of religion, Grenzelhoft paints a mixed picture. Both the churches of the Ten and the cathedrals of the All-Father are common in the Empire, united by the Imperial Church of the Eleven. This vast compromise between the interests of the old faith and the new, formed by the marriage of the Supreme Magister of the Imperial Church of the All-Father Adrian VII and the High Priestess of the Ten Miranda II of Baston, is called behind closed doors <i>a holy union forged in Tartarus</i>.<br><br>"

/datum/virtue/origin/valorian
	map_group_order = 1
	map_state_order = 2
	map_origin_order = 1
	map_visible = TRUE
	map_x = 26.4
	map_y = 36.1
	map_state_id = "valoria"
	map_state_name = "The Valorian Trade League"
	map_origin_name = "The Valorian Trade League"
	name = "Valorian"
	origin_name = "Valoria"
	added_languages = list(/datum/language/valorian)
	desc = "I come from Valoria, the citadel of the Church of the Ten and home of the five trade Republics, on islands in the middle of the Black Ocean.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%92%D0%B0%D0%BB%D0%BE%D1%80%D0%B8%D0%B9%D1%81%D0%BA%D0%B8%D0%B9_%D1%82%D0%BE%D1%80%D0%B3%D0%BE%D0%B2%D1%8B%D0%B9_%D1%81%D0%BE%D1%8E%D0%B7'>Valoria,</a></b> also called the Valorian Trade League, or the Most Serene League of the Five Trade Republics of Valoria and the Church of the Indivisible Ten, is a union of five semi-independent states bound by the single authority of the Most Serene Doge. As the name says, it is a trading state whose influence spreads through, and is dictated by, trading posts, merchant quarters and a great many merchants travelling by sea and land.<br><br>The Valorian League, as it's sometimes called, is a confederation where four republics coexist as equal allies and partners and a fifth serves as the nominal administrative and legal center, where the Most Serene Doge is elected to settle disputes between the republics, conduct a single foreign policy, direct trade policy, and introduce new excises, levies, taxes and duties. The Valorian Church of the Indivisible Ten, the Church of the Ten, is the most widespread religion in all of Grimoria. It is here, in the city of Eterna, that the oldest Holy See of the Ten stands, and from here that the Patriarch's will is dictated to the many churches and temples where the whole indivisible pantheon is worshipped."

/datum/virtue/origin/heartfelt
	map_group_order = 3
	map_state_order = 6
	map_origin_order = 1
	map_visible = TRUE
	map_x = 33.0
	map_y = 33.0
	map_state_id = "heartfelt"
	map_state_name = "The Free Isles of Heartfelt"
	map_origin_name = "The Free Isles of Heartfelt"
	list_group_order = 6
	list_item_order = 1
	name = "Heartfeltian"
	origin_name = "Heartfelt"
	desc = "I come from the isles of Heartfelt, once a majestic, beautiful kingdom, the pearl of the northern seas, and now a land burning in the flames of civil war.<br>"
	origin_desc = "<br><br>Once <b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%A5%D0%B0%D1%80%D1%82%D1%84%D0%B5%D0%BB%D1%82'>the Kingdom of Heartfelt</a></b> was the pearl of the northern seas, a little paradise where nobles from all over the world gathered to admire its dazzling nature, see the masterpieces of art made there, and taste the sweetest fruit in the world. The sages and craftsmen of these lands worked together in the name of light and order. But fourteen years ago that idyll came to an end, and today Heartfelt is a land torn apart by civil war. The united Kingdom is no more, and only the gods know what order will rise from its ruins."

/datum/virtue/origin/etrusca
	map_group_order = 3
	map_state_order = 1
	map_origin_order = 1
	map_visible = TRUE
	map_x = 43.9
	map_y = 40.2
	map_state_id = "etrusca"
	map_state_name = "The Kingdom of Etrusca"
	map_origin_name = "The Kingdom of Etrusca"
	name = "Etruscan"
	origin_name = "Etrusca"
	added_languages = list(/datum/language/etruscan)
	desc = "I belong to one of the countless cultures that grew up on the Etruscan archipelago. Refined tastes, exquisite clothes and the traditions of slaveholding are what defined the early years of my life.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%9A%D0%BE%D1%80%D0%BE%D0%BB%D0%B5%D0%B2%D1%81%D1%82%D0%B2%D0%BE_%D0%AD%D1%82%D1%80%D1%83%D1%81%D0%BA%D0%B0'>The Kingdom of Etrusca</a></b>, also known as the Isles of Etrusca or the Island Union of Zaragoza, is a kingdom in the middle of the Resting Ocean. Thanks to its isolation and focus on trade, one of the richest and most varied cultures in all of Grimoria formed here. The two main islands, Navarno and Montecarina, are so different they could be considered separate states, but the monarchy of the house of Zaragoza has united them into one."

/datum/virtue/origin/otava
	map_group_order = 3
	map_state_order = 5
	map_origin_order = 1
	map_visible = TRUE
	map_x = 18.1
	map_y = 90.2
	map_state_id = "otava"
	map_state_name = "The Otavan Theocracy"
	map_origin_name = "The Otavan Theocracy"
	name = "Otavan"
	origin_name = "Otava"
	added_languages = list(/datum/language/otavan)
	desc = "I come from the island of Otava, the holy bastion of faith in Psydon, Creator of All That Is, founded by the loyal followers of the wounded god.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%9E%D1%82%D0%B0%D0%B2%D0%B0,_%D0%9E%D1%81%D1%82%D1%80%D0%BE%D0%B2_%D0%A1%D0%B5%D1%80%D0%B5%D0%B1%D1%80%D0%B0_%D0%B8_%D0%9F%D0%BE%D1%80%D0%BE%D1%85%D0%B0'>The Otavan Theocracy</a></b> is the holy bastion of faith in Psydon, Creator of All That Is, founded by the loyal followers of the wounded god. Born from the fall of the holy comet Syon and united under the rule of the supreme magister, this small but influential theocracy holds spiritual wealth and knowledge envied the world over. In the new age of steam and powder, Otava is claiming its place in both the spiritual and political landscape of Psydonia, preparing to lead the fight against the forces of darkness with a strength never seen before.<br><br>Otava is an island southwest of Giza, in the southern ocean. Despite its small size, the theocracy's territory is strategically important thanks to its position and key ports. Besides the island itself, Otava controls many subject fortresses and port cities beyond its main territory, nominally belonging to the Church of the All-Father but in practice answering to the supreme magister and their chancery. Thanks to a well-developed fleet, this lets the small island supply itself with food and resources.<br><br>Otava is under the absolute rule of the supreme magister, to whom the local governors answer. The current supreme magister is Castellos Neratta. The government sits in the cathedral-fortress in Deilitis, cut off from the rest of the city by walls and a moat. It is there that the church's leadership and the high command of the Inquisition gather to decide matters of life and death. A key feature of this structure is the special status of the Marshal of the Inquisition, who is nearly a co-ruler with the supreme magister and the second most important person on the island and in the church. The Marshal's name is shrouded in mystery.<br><br>Otava is a state formed by the merging of many cultures, among them travellers, refugees, sailors and religious orders. The main thing uniting the islanders is faith in the All-Father. This is where the infamous Inquisition was formed, along with organizations such as the Order of Silver and the Order of Black Powder.<br><br>"

/datum/virtue/origin/gronn
	map_group_order = 1
	map_state_order = 5
	map_origin_order = 1
	map_visible = TRUE
	map_x = 11.3
	map_y = 31.6
	map_state_id = "gronn"
	map_state_name = "Gronn"
	map_origin_name = "Gronn"
	list_group_id = "gronn"
	list_group_name = "Gronn"
	name = "Gronnic"
	origin_name = "Gronn"
	added_languages = list(/datum/language/gronnic)
	desc = "I come from the cold, harsh lands of Gronn, either the Northern Isles or the Sister Lands, Fjall.<br>"
	origin_desc = "<br><br>The culture of the <b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%A1%D0%B5%D0%B2%D0%B5%D1%80%D0%BD%D1%8B%D0%B5_%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%B2%D0%B0'>Northern Isles</a></b> and the neighbouring lands of Gronn in the Northern Wastes, called 'the Sister Lands', differs greatly from the ways of other peoples. At first glance northerners are unfriendly and known for their barbarian raids on the southern lands, but they readily trade with anyone who can reach them alive and with goods.<br><br>Religion is one of the key things that set northerners apart from other peoples. Both on the isles and in the Sister Lands, the people don't recognize the divine order of the Ten or the teachings of Psydon, instead worshipping six great beasts, each embodying important principles and norms of life. Northern beliefs have clear parallels with the worship of some gods of the Pantheon, the Holy Ecclesiarchy and the Cult of Salvation, but the Gronn openly deny following those teachings, keeping to their own rites and traditions. The Gronn wage no open wars over faith, guarding their ways and not letting them be broken, helped by a harsh climate that invaders aren't used to."

/datum/virtue/origin/racial/crimson_lands
	map_group_order = 1
	map_state_order = 6
	map_origin_order = 1
	map_visible = TRUE
	map_x = 26.5
	map_y = 69.3
	map_state_id = "crimson_lands"
	map_state_name = "The Crimson Lands"
	map_origin_name = "The Crimson Lands"
	list_group_id = "crimson_lands"
	list_group_name = "The Crimson Lands"
	list_group_order = 7
	list_item_order = 1
	name = "Crimsonlander"
	origin_name = "Crimson Lands"
	added_languages = list(/datum/language/raneshi)
	races = list(/datum/species/anthromorph,
				/datum/species/anthromorphsmall)
	desc = "My life is bound to the Crimson Lands, whether as a homeland that fell victim to a magical catastrophe, or as the battlefields where, in the years of the Twilight War, the blood of soldiers, mercenaries and fortune-seekers from every corner of Grimoria was spilled. Whatever the reason, what I lived through among the scarlet wastes changed me forever.<br>"
	origin_desc = "<br><br><b>The Crimson Lands</b> are a vast region between the northern plains of the Black Empire and the holdings of the Naledi prefecture. Once dozens of independent tribes, small kingdoms and city-states existed here, whose rulers drew power from an ancient source of magic. During the Twilight War these lands became the main path for Grenzelhoft's armies invading the south, and later the stronghold of the Wolf Shah Zukhim, who gathered the northern tribes and kings of the Crimson Lands under his banner for a march on Dvergeil.<br><br>After the Wolf Shah's defeat, Basileus Mansa-Padashi resolved to end the threat from the north forever. At his order, the mages of the Tower of Noc overloaded the source that fed the sorcerers of the Crimson Lands. The released energy destroyed most of the local lords: the strongest mages turned to ash or became maddened wild-kin, and many ordinary people were twisted by magic, lost their minds or died. Only a few survived the catastrophe to witness the death of their homeland.<br><br>Today the Crimson Lands are a barren scarlet waste soaked in residual magical energy. The ruins of ancient fortresses and towers hide countless dangers and relics of the past, drawing adventurers, while the few settlements struggle to survive among cursed lands poor in greenery and game.<br><br>"

/datum/virtue/origin/raneshen
	map_group_order = 1
	map_state_order = 7
	map_origin_order = 1
	map_visible = TRUE
	map_x = 50.4
	map_y = 71.6
	map_state_id = "raneshen"
	map_state_name = "The Raneshen Prefecture"
	map_origin_name = "The Raneshen Prefecture"
	list_group_id = "zybantian_empire"
	list_group_name = "The Zybantine Empire"
	list_group_order = 8
	list_item_order = 3
	list_subgroup_name = "Prefectures"
	name = "Zybantu - Ranesheni"
	origin_name = "Raneshan"
	added_languages = list(/datum/language/raneshi)
	desc = "I come from the lands of Raneshen, a prefecture of Zybantu known as the land where the sabre rules, not gold. Worth in Raneshen is measured not by trade profits but by martial glory, conquest, and the number of slaves taken in battles for honour.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%97%D0%B8%D0%B1%D0%B0%D0%BD%D1%82%D0%B8%D0%B9%D1%81%D0%BA%D0%B0%D1%8F_%D0%98%D0%BC%D0%BF%D0%B5%D1%80%D0%B8%D1%8F#%D0%9F%D1%80%D0%B5%D1%84%D0%B5%D0%BA%D1%82%D1%83%D1%80%D0%B0_%D0%A0%D0%B0%D0%BD%D0%B5%D1%88%D0%B5%D0%BD'>Raneshen</a></b> is the second largest prefecture of Zybantu, on the eastern border of the Western Kingdoms. Like Naledi, Raneshen is governed by a kephale granted a high degree of autonomy. The prefecture holds a strategic position at the crossroads of the most important trade routes to the East. At the height of the Golden Empire, Raneshen grew rich from its monopoly on trade with the far East, receiving the rarest goods from Gyodzai. But with the fall of the Golden Empire's hegemony and the rise of new trade arrangements, eastern guests rarely visit Raneshen, and exotic goods have become rare again."

/datum/virtue/origin/naledi
	map_group_order = 1
	map_state_order = 8
	map_origin_order = 1
	map_visible = TRUE
	map_x = 34.7
	map_y = 77.5
	map_state_id = "naledi"
	map_state_name = "The Naledi Prefecture"
	map_origin_name = "The Naledi Prefecture"
	list_group_id = "zybantian_empire"
	list_group_name = "The Zybantine Empire"
	list_group_order = 8
	list_item_order = 2
	list_subgroup_name = "Prefectures"
	name = "Zybantu - Naledian"
	origin_name = "Naledi"
	added_languages = list(/datum/language/raneshi)
	desc = "I come from the lands of Naledi, a prefecture of Zybantu known for its endless deserts and unique beliefs. My homeland was largely ravaged by the Twilight War, and that couldn't help but affect me.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%97%D0%B8%D0%B1%D0%B0%D0%BD%D1%82%D0%B8%D0%B9%D1%81%D0%BA%D0%B0%D1%8F_%D0%98%D0%BC%D0%BF%D0%B5%D1%80%D0%B8%D1%8F#%D0%9F%D1%80%D0%B5%D1%84%D0%B5%D0%BA%D1%82%D1%83%D1%80%D0%B0_%D0%9D%D0%B0%D0%BB%D0%B5%D0%B4%D0%B8'>Naledi</a></b> is one of the two largest prefectures of Zybantu, governed by a kephale appointed by the Basileus. Despite formal subordination to the central government, Naledi has a high degree of autonomy in local government, culture and religion. The region is a unique cultural and religious entity, sharply different from the rest of Zybantu in both traditions and beliefs.<br><br>Unlike the rest of Zybantu, the Naledi hold not to the faith of the Ten but to the Psydonite faith. Most Naledi believe the All-God still lives, and this faith reaches into nearly every part of their daily lives, giving the region's culture exceptional fervour and cultural unity.<br><br>According to the Naledi confession of the Psydonite faith, known as the Teaching of Fate, Psydon foresaw his defeat at the hands of Zizo (called Iblis here) and, seeing it was inevitable, willingly left his heavenly throne. Since then he has wandered among ordinary mortals, watching them and waiting for the day people become worthy of his return to power. According to legend, it was Psydon who taught the Naledi to wear golden masks, a second face meant to protect their soul and mind from the influence of demons and djinn."

/datum/virtue/origin/zybantian
	map_group_order = 1
	map_state_order = 9
	map_origin_order = 1
	map_visible = TRUE
	map_x = 40.8
	map_y = 67.4
	map_state_id = "zybantu"
	map_state_name = "The Zybantine Empire"
	map_origin_name = "The Zybantine Empire"
	list_group_id = "zybantian_empire"
	list_group_name = "The Zybantine Empire"
	list_group_order = 8
	list_item_order = 1
	name = "Zybantian"
	origin_name = "Zybantu"
	added_languages = list(/datum/language/raneshi)
	desc = "I come from the lands of the Ziggurat of Zybantu, which now unites the shards of the fallen Golden Empire under a single flag. My homeland is known for its crowded and varied cities, a developed magical tradition, the slave trade, and a complex system of government combining central power with regional autonomy.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%97%D0%B8%D0%B1%D0%B0%D0%BD%D1%82%D0%B8%D0%B9%D1%81%D0%BA%D0%B0%D1%8F_%D0%98%D0%BC%D0%BF%D0%B5%D1%80%D0%B8%D1%8F'>The Zybantine Empire,</a></b> or the Ziggurat of Zybantu, is a large southern state formed on the ruins of the Golden Empire, which Grenzelhoft defeated in the Twilight War. Despite the hard circumstances of its founding, Zybantu stays true to ancient traditions and is slowly regaining its lost strength and influence.<br><br>The supreme ruler of Zybantu is Basileus Manasa-Padashi. Under his rule are united both the Zybantine lands proper and the prefectures of Naledi and Raneshen. The center of spiritual authority is the Ecumenical Patriarchate of Dvergeil, which preaches the authority of a Pantheon led by Noc rather than Astrata.<br><br>Zybantu's economy is built on the slave trade. In the past the Golden Empire's Purple Fleet dominated the Black Ocean, charging every merchant ship that tried to pass through its waters, but after the Twilight War that hegemony came to an end. What's more, the lands of Naledi, ravaged by Grenzelhoft's jaegers, still swarm with escaped slaves who live by banditry or, worse, Matthiosism.<br><br>Zybantine mages are also widely known. Many great orders of arcane masters, such as the Order of the New Moon, were destroyed by Grenzelhoft during the war, but the Psydonite sorcerers of Naledi and other wizards still hold an important place in Zybantine society.<br><br>"

/datum/virtue/origin/kazengun
	map_group_order = 3
	map_state_order = 4
	map_origin_order = 1
	map_visible = TRUE
	map_x = 84.8
	map_y = 66.9
	map_state_id = "kazengun"
	map_state_name = "The Kazen Shogunate"
	map_origin_name = "The Kazen Shogunate"
	list_group_id = "kazengun"
	list_group_name = "The Kazen Shogunate"
	list_group_order = 7
	list_item_order = 1
	name = "Kazengun - Mainlander"
	origin_name = "Kazengun"
	added_languages = list(/datum/language/kazengunese)
	desc = "I come from the mist-wrapped lands of Kazengun. The traditions and culture I've known since childhood still surprise and astonish the westerners I meet.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%A1%D1%91%D0%B3%D1%83%D0%BD%D0%B0%D1%82_%D0%9A%D0%B0%D0%B7%D0%B5%D0%BD'>The Kazen Shogunate,</a></b> also known as the Kazengunate or the Kazengun Shogunate, is a large feudal state on great islands in the eastern part of the world ocean. The power of the Shogun, the military ruler, unites the mighty Au'ra peoples, the strong clans of the southern and northern Kazengun islands, and the recently acquired lands of Joseon in the east of the eastern continent.<br><br>Social stratification, aristocracy and the Order of Aisata are the pillars of Kazengun society. Trying to climb higher, or challenging someone above you, is an unthinkable scandal bordering on heresy. Yet if an aspirant succeeds in their ambitions and secures a new, respected status, for example a very wealthy merchant rising to daimyo, it's seen as 'proper and just', meaning it was intended by the Order of Aisata. Even so, cultural dogma still insists that 'change is unnatural to the Order'."

/datum/virtue/origin/lingyue
	map_group_order = 3
	map_state_order = 7
	map_origin_order = 1
	map_visible = TRUE
	map_x = 81.3
	map_y = 36.4
	map_state_id = "jeoseon"
	map_state_name = "Joseon"
	map_origin_name = "Joseon"
	list_group_id = "kazengun"
	list_group_name = "The Kazen Shogunate"
	list_group_order = 7
	list_item_order = 2
	name = "Kazengun - Jeoseonese"
	origin_name = "Kazengun"
	added_languages = list(/datum/language/lingyuese)
	desc = "I come from the lands of Joseon, a vassal kingdom of the Kazen Shogunate. My homeland once declared independence from the Gyodzai Tsardom, and though my people were forced to bow before the invaders, their freedom-loving spirit is still strong.<br>"
	origin_desc = "<br><br>Since time out of mind the lands of Joseon were part of <b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%93%D1%91%D0%B4%D0%B7%D0%B0%D0%B9%D1%81%D0%BA%D0%BE%D0%B5_%D0%A6%D0%B0%D1%80%D1%81%D1%82%D0%B2%D0%BE'>the Gyodzai Tsardom.</a></b> Gyodzai historians hold that Joseon was the first remotely civilized state to swear loyalty to the Gyodzai Tsardom, having seen their countless legions carrying the word and will of the Malachite Huangdi decades before the Arch-Betrayal and the start of the War in the Heavens.<br><br>Relations between Gyodzai and Joseon were always tense, largely because Gyodzai considered the state barbaric and 'unworthy' of equal ties; their diplomats always behaved like victors toward the vanquished, which embittered the latter. Centuries of oppression came to a head in the 11th century of the New Order, when Joseon, taking advantage of the metropole's weakness after a string of civil wars and undead activity, declared independence. And though today this land is under the Kazen Shogunate, which conquered the weakened state soon after the devastating Red Turban uprising, its people haven't forgotten the taste of freedom, and their spirit remains unbroken.<br><br>"

/datum/virtue/origin/gyedzenese
	map_group_order = 2
	map_state_order = 3
	map_origin_order = 1
	map_visible = TRUE
	map_x = 72.4
	map_y = 36.6
	map_state_id = "gyedzai"
	map_state_name = "The Gyodzai Tsardom"
	map_origin_name = "The Gyodzai Tsardom"
	list_group_order = 3
	list_item_order = 1
	name = "Gyedzenese"
	origin_name = "Gyedzai"
	added_languages = list(/datum/language/gyedzenese)
	desc = "I come from the lands of Gyodzai, once under the single rule of the Huangdi. Now my homeland isn't the unified state that survived the War in the Heavens, just a handful of scattered cliques fighting over influence and resources.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%93%D1%91%D0%B4%D0%B7%D0%B0%D0%B9%D1%81%D0%BA%D0%BE%D0%B5_%D0%A6%D0%B0%D1%80%D1%81%D1%82%D0%B2%D0%BE'>The Gyodzai Tsardom,</a></b> also known as the Gyodzai Empire, is the common name for the territories once under the single rule of a Huangdi (emperor, tsar) of a noble dynasty. It fell apart over four hundred years ago, and the name Gyodzai now just points to the territories united by shared cultural, religious and linguistic traditions. The state is known for its silks, since it was here that the mulberry silkworm was first bred, and for its tea ceremonies, since no other culture in the world has matched so fine and majestic a tea ceremony, used in diplomacy, daily life and as a way of showing respect.<br><br>There is no single state in the Gyodzai Tsardom, only a handful of cliques and alliances that have fought each other mercilessly for several hundred years for the right to be called Huangdi, the one ruler of these lands. Nothing and no one has yet managed to unite them under a single banner. Ten dynasties fight one another, armies march against each other, while within each dynasty intrigues are woven in the struggle for influence inside their own lands.<br><br>"

/datum/virtue/origin/hammerhold
	map_group_order = 1
	map_state_order = 10
	map_origin_order = 1
	map_visible = TRUE
	map_x = 23.1
	map_y = 18.8
	map_state_id = "hammerhold"
	map_state_name = "The Tsardom of Hammerhold"
	map_origin_name = "The Tsardom of Hammerhold"
	name = "Hammerholdian"
	origin_name = "Hammerhold"
	added_languages = list(/datum/language/elvish)
	desc = "I come from the lands of Hammerhold, the cold lands that became home to the elven people after the fall of the Divine Empire.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%A6%D0%B0%D1%80%D1%81%D1%82%D0%B2%D0%BE_%D0%A5%D0%B0%D0%BC%D0%BC%D0%B5%D1%80%D1%85%D0%BE%D0%BB%D0%B4'>The Tsardom of Hammerhold,</a></b> also known as the Six Great Principalities, is small in size but vast in importance. Hammerhold is the Shield of the North, the bulwark against the three great calamities of the north: the goblin tribes, the march of the dead, and the ogre clans, whose invasion threatens to bring Dark Times upon the Western Continent. Here silent cold rules, and a warm summer and rich harvest are an impossible luxury; but it is in these lands that the hardiest sons and daughters of the North are born, who turn their oaken will against the worst enemies of the civilized world.<br><br>The land of Hammerhold is divided between the Tsar's Court and five march-principalities that serve as the northern and southern keepers of peace in the Tsardom. At the head of Hammerhold stands the ancient elven house of Khmelnitsky, whose forefathers witnessed the rule of the All-Father with their own eyes, or so the legends say. It was the elves who ennobled the wild human lands, bringing the civilized word. Century after century, the women of the house place the royal Cap of Monomakh upon their heads, heralding a long and unhurried reign. On the border between the Wild North and the Restless South stand vassal principalities sworn to guard their borders against outside forces.<br><br>"

/datum/virtue/origin/avar
	map_group_order = 2
	map_state_order = 2
	map_origin_order = 1
	map_visible = TRUE
	map_x = 62.2
	map_y = 24.8
	map_state_id = "aavnr"
	map_state_name = "The Aavnr Highlands"
	map_origin_name = "The Aavnr Highlands"
	name = "Aavnic"
	origin_name = "Avar"
	added_languages = list(/datum/language/aavnic)
	desc = "I come from the Aavnr highlands, a land of endless steppes, warriors and nomads, which only recently breathed freely after centuries under Gyodzai's yoke.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%9D%D0%B0%D0%B3%D0%BE%D1%80%D1%8C%D0%B5_%D0%90%D0%B0%D0%B2%D0%BD%D1%80'>The Aavnr Highlands,</a></b> or the Aavnrian Highlands, is the common name for a vast region of mountains and steppes north of Gyodzai. In recent years Aavnr has been in a drawn-out crisis of statehood, caused by the conservatism of its nomadic population, which still resists settling down, while a more developed feudal civilization slowly forms in the north.<br><br>Formally there's no single state on Aavnr's land, but its political prototype has taken shape: a confederation institutionally tied to the city-state of Serendnizhina. There, tribal chiefs, city rulers and steppe khans periodically gather to share news, settle disputes, make trade agreements or, on the contrary, declare feuds. Aavnr's seven most influential figures form the Council, meant to make key decisions. In practice this confederal mechanism often remains an empty formality: in serious conflicts the parties prefer to act on their own, relying on their own strength and alliances rather than the Council's decisions."

/datum/virtue/origin/racial/lirvas
	map_group_order = 2
	map_state_order = 1
	map_origin_order = 1
	map_visible = TRUE
	map_x = 75.3
	map_y = 48.5
	map_state_id = "lirvas"
	map_state_name = "Lirvas, the Hundred and Eleventh Empire"
	map_origin_name = "Lirvas, the Hundred and Eleventh Empire"
	name = "Lirvasian"
	origin_name = "Lirvas"
	added_languages = list(/datum/language/draconic)
	races = list(/datum/species/kobold,
				/datum/species/lizardfolk,
				/datum/species/anthromorph,
				/datum/species/dracon)
	desc = "I come from the jungles of Lirvas, where on the ruins of dozens of fallen civilizations the descendants of majestic dragons built the Eternal Empire.<br>"
	origin_desc = "<br><br><b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%9B%D0%B8%D1%80%D0%B2%D0%B0%D1%81,_%D0%A1%D1%82%D0%BE_%D0%9E%D0%B4%D0%B8%D0%BD%D0%BD%D0%B0%D0%B4%D1%86%D0%B0%D1%82%D0%B0%D1%8F_%D0%98%D0%BC%D0%BF%D0%B5%D1%80%D0%B8%D1%8F'>The Hundred and Eleventh Empire of Lirvas,</a></b> as the naga prophecy says, is meant to be the last, and eternal. Thousands of kobolds, lizardfolk and dragonkin are hurrying home to have a hand in fulfilling the ancient prophecy and put an end to their old enemies in Gyodzai."

/datum/virtue/origin/racial/underdark
	map_group_order = 4
	map_state_order = 3
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "underdark"
	map_state_name = "The Underdark"
	map_origin_name = "The Underdark"
	list_group_order = 3
	list_item_order = 1
	name = "Underdweller"
	origin_name = "the Underdark"
	desc = "I come from the Underdark, a vast network of caves deep beneath Grimoria's surface, stretching under nearly all the Western Kingdoms.<br>"
	added_languages = list(/datum/language/undercommon)
	races = list(/datum/species/elf/dark,
				/datum/species/human/halfelf,
				/datum/species/kobold,
				/datum/species/dwarf/mountain,
				/datum/species/dwarf/gnome,
				/datum/species/goblinp,
				/datum/species/anthromorphsmall,
				/datum/species/ooze)
	origin_desc = "<br><br>Deep beneath Grimoria's surface, where the light of Astrata and Noc never reaches, lies <b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%9F%D0%BE%D0%B4%D0%B7%D0%B5%D0%BC%D1%8C%D0%B5'>the Underdark</a></b>, a vast network of caves stretching under nearly all the Western Kingdoms. Exploring its countless mysteries is made much harder by the fact that since time out of mind the Underdark has been the haven and home of the drow, whose majestic underground cities often prove a deadly trap for careless travellers.<br><br>The Underdark is divided into three levels:<br><br>The Upper Underdark is a rough entrance to the deeper levels. Most often these are ancient caves and catacombs, cellars with hidden passages, temples, ancient ruins and the like. Anyone can be met there, but most often adventurers and smugglers who use its passages to cover long distances off the surface, which it lies closest to.<br><br>The Middle Underdark lies far deeper, down to about 15 miles into the dark and the depths. It's a place where the sun never shines and water is a luxury. Both drow and more dangerous creatures live here. Purple worms dig ever new tunnels in search of prey; umber hulks, huge moles, eat the legs of lost travellers instead of carrots; beholders, huge eyes with many tentacles, enslave with their gaze and turn people into living statues. These are only a small part of what awaits an unprepared, lost miner.<br><br>The Lower Underdark is a place no one has returned from, at least not in their right mind. Even the most dangerous creatures of the Middle Underdark are reluctant to go there. In the eternal dark illusions fade and light quickly dies; magical anomalies twist space and time, warping the body and mind of the careless traveller."

/datum/virtue/origin/racial/underdark_drow
	map_group_order = 4
	map_state_order = 3
	map_origin_order = 2
	map_visible = FALSE
	map_state_id = "underdark"
	map_state_name = "The Underdark"
	map_origin_name = "Underdark cities"
	list_group_order = 3
	list_item_order = 2
	name = "Underdweller - Drow Cities"
	origin_name = "the Underdark"
	desc = "I come from a grim city of the dark elves in the Middle Underdark. My youth was spent in a web of intrigue, a struggle to survive, and prayers to the Lady of Darkness, sincere or feigned.<br>"
	added_languages = list(/datum/language/undead)
	races = list(/datum/species/elf/dark,
				/datum/species/human/halfelf)
	origin_desc = "<br><br>Deep beneath Grimoria's surface, where the light of Astrata and Noc never reaches, lies <b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%9F%D0%BE%D0%B4%D0%B7%D0%B5%D0%BC%D1%8C%D0%B5'>the Underdark</a></b>, a vast network of caves stretching under nearly all the Western Kingdoms. Exploring its countless mysteries is made much harder by the fact that since time out of mind the Underdark has been the haven and home of the drow, whose majestic underground cities often prove a deadly trap for careless travellers.<br><br>The Underdark is divided into three levels:<br><br>The Upper Underdark is a rough entrance to the deeper levels. Most often these are ancient caves and catacombs, cellars with hidden passages, temples, ancient ruins and the like. Anyone can be met there, but most often adventurers and smugglers who use its passages to cover long distances off the surface, which it lies closest to.<br><br>The Middle Underdark lies far deeper, down to about 15 miles into the dark and the depths. It's a place where the sun never shines and water is a luxury. Both drow and more dangerous creatures live here. Purple worms dig ever new tunnels in search of prey; umber hulks, huge moles, eat the legs of lost travellers instead of carrots; beholders, huge eyes with many tentacles, enslave with their gaze and turn people into living statues. These are only a small part of what awaits an unprepared, lost miner.<br><br>The Lower Underdark is a place no one has returned from, at least not in their right mind. Even the most dangerous creatures of the Middle Underdark are reluctant to go there. In the eternal dark illusions fade and light quickly dies; magical anomalies twist space and time, warping the body and mind of the careless traveller."

/datum/virtue/origin/racial/akhdruk
	map_group_order = 4
	map_state_order = 4
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "akhdruk"
	map_state_name = "Drud Akhdruk"
	map_origin_name = "Drud Akhdruk"
	list_group_order = 4
	list_item_order = 1
	name = "Akhdruki"
	added_languages = list(/datum/language/dwarvish)
	origin_name = "Drud Akhdruk"
	desc = "I come from Drud Akhdruk, the single dwarven kingdom uniting dozens of fortresses across Grimoria.<br>"
	races = list(/datum/species/dwarf/mountain,
				/datum/species/dwarf/gnome)
	origin_desc = "<br><br>The most important thing in dwarven society is usually the sum of three things: age, wealth and mastery. The more of these a dwarf has, the higher their standing. But dwarves don't boast of their families' achievements.<br><br>Dwarves are attached to their people's past and traditions and always strive to remember their ancestors, repairing and maintaining their works. Every smith of this people knows how to reforge ancient weapons and always tries to use ancient relics in their new work. All the most powerful of these weapons are forged from blacksteel.<br><br>Dwarves have a hard, unyielding sense of honour centred on oaths and promises. A promise doesn't die with the oathbreaker, just as a betrayal doesn't die with the one who broke the oath. A dwarf will be bound by an unfulfilled promise made by an ancestor and pledge to keep it. Likewise, they will seek redress from the descendants of oathbreakers.<br><br>Serious breaches of faith or law are recorded in the Book of Grudges. Every self-respecting dwarf must carry a personal book to record the personal grudges done to them by anyone or anything."

/datum/virtue/origin/racial/infernal
	map_group_order = 4
	map_state_order = 5
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "infernal"
	map_state_name = "The Inferno"
	map_origin_name = "The Inferno"
	list_group_order = 5
	list_item_order = 1
	name = "Infernal"
	added_languages = list(/datum/language/hellspeak)
	origin_name = "the Inferno"
	desc = "I come from the Inferno, one of the outer Planes of reality and the home of demons. Having survived that world of unprincipled evil and institutional cruelty, I made my way out to the foreign lands of Grimoria.<br>"
	races = list(/datum/species/tieberian,
				/datum/species/dullahan,
				/datum/species/demihuman)
	origin_desc = "<br><br>As the closest of the outer Planes, <b><a href='https://wiki.twilight-fortress-axis.ru/index.php?title=%D0%98%D0%BD%D1%84%D0%B5%D1%80%D0%BD%D0%BE'>the Inferno</a></b> has a great influence on Grimoria and its people. It appears in the mythology of many peoples and civilizations under different names: the Etruscan islands use the word Averno, while the peoples of the Western Kingdoms call it Hell. Some Psydonite clergy identify this Plane with Tartarus, where the souls of sinners go after death, but by the account of its own inhabitants this isn't quite right: only the souls of those who made a magical pact with a devil in life end up in the Inferno.<br><br>Because the Inferno and Grimoria are so close cosmologically, ambitious demon lords often invade across the border between worlds to steal resources or simply show off their power. Such invasions usually leave behind great destruction, ravaged lands and new generations of tieflings."

/datum/virtue/origin/racial/ancient
	map_group_order = 4
	map_state_order = 6
	map_origin_order = 1
	map_visible = FALSE
	map_state_id = "ancient"
	map_state_name = "The Ancient Age"
	map_origin_name = "The Ancient Age"
	list_group_order = 6
	list_item_order = 1
	name = "Ancient"
	origin_name = "Age Long Gone"
	added_languages = list(/datum/language/celestial)
	desc = "The roots of my origin are lost in the ages. I come from lands that no longer hold any trace of my culture, or I was brought into the world purely by divine intervention.<br>"
	races = list(/datum/species/elf/wood,
				/datum/species/elf/dark,
				/datum/species/elf/sun,
				/datum/species/aasimar,
				/datum/species/dracon)
	origin_desc = "<br>Not everyone alive today can boast that their homeland is still on the map of the world. The War in the Heavens and the Era of Strife wiped many places from the face of Grimoria that were once home to millions. Only rare chronicles still mention the hegemonies of old."
