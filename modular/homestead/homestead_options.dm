GLOBAL_LIST_INIT(homestead_skill_categories, list(
	"Smithing" = list(
		/datum/skill/craft/armorsmithing,
		/datum/skill/craft/blacksmithing,
		/datum/skill/craft/engineering,
		/datum/skill/craft/smelting,
		/datum/skill/craft/weaponsmithing
	),
	"Crafting" = list(
		/datum/skill/craft/alchemy,
		/datum/skill/craft/carpentry,
		/datum/skill/craft/ceramics,
		/datum/skill/craft/cooking,
		/datum/skill/craft/crafting,
		/datum/skill/craft/masonry,
		/datum/skill/craft/sewing,
		/datum/skill/craft/tanning,
		/datum/skill/craft/traps
	),
	"Labor" = list(
		/datum/skill/labor/butchering,
		/datum/skill/labor/farming,
		/datum/skill/labor/fishing,
		/datum/skill/labor/lumberjacking,
		/datum/skill/labor/mining
	),
	"Wilderness" = list(
		/datum/skill/misc/athletics,
		/datum/skill/misc/climbing,
		/datum/skill/misc/hunting,
		/datum/skill/misc/riding,
		/datum/skill/misc/swimming,
		/datum/skill/misc/tracking
	),
	"Learning & Arts" = list(
		/datum/skill/misc/medicine,
		/datum/skill/misc/music,
		/datum/skill/misc/reading
	),
	"Underhanded" = list(
		/datum/skill/misc/lockpicking,
		/datum/skill/misc/sneaking,
		/datum/skill/misc/stealing
	),
	"Combat" = list(
		/datum/skill/combat/axes,
		/datum/skill/combat/bows,
		/datum/skill/combat/knives,
		/datum/skill/combat/maces,
		/datum/skill/combat/polearms,
		/datum/skill/combat/slings,
		/datum/skill/combat/staves,
		/datum/skill/combat/unarmed,
		/datum/skill/combat/wrestling
	)
))

/proc/get_homestead_skills()
	var/static/list/skills
	if(!skills)
		skills = list()
		for(var/category in GLOB.homestead_skill_categories)
			skills += GLOB.homestead_skill_categories[category]
	return skills

/proc/is_homestead_combat_skill(skill_type)
	return ispath(skill_type, /datum/skill/combat)

GLOBAL_LIST_INIT(homestead_stats, list(
	STATKEY_STR = "Strength",
	STATKEY_PER = "Perception",
	STATKEY_INT = "Intelligence",
	STATKEY_CON = "Constitution",
	STATKEY_WIL = "Willpower",
	STATKEY_SPD = "Speed",
	STATKEY_LCK = "Fortune"
))

/datum/homestead_perk
	var/name
	var/desc
	var/cost = 1
	var/category = HOMESTEAD_PERK_TALENT
	var/list/traits
	/// Skill type = level, granted free on top of bought skills.
	var/list/granted_skills
	/// Name = item path, stashed like kit items.
	var/list/items
	/// Applied as if picked in character setup.
	var/datum/virtue/virtue

/datum/homestead_perk/smithing
	name = "Expert Forgehand"
	cost = 2
	category = HOMESTEAD_PERK_EXPERTISE
	traits = list(TRAIT_SMITHING_EXPERT)

/datum/homestead_perk/alchemy
	name = "Expert Alchemist & Enchanter"
	desc = "Expert Alchemist and Enchanter, trained in the arcyne and its rituals. Apprentice Arcane, with chalk, mortar and pestle stashed."
	cost = 3
	category = HOMESTEAD_PERK_EXPERTISE
	traits = list(TRAIT_ALCHEMY_EXPERT, TRAIT_ENCHANTING_EXPERT, TRAIT_ARCYNE, TRAIT_LEYLINE_ATTUNEMENT)
	granted_skills = list(/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE)
	items = list("Pestle" = /obj/item/pestle, "Mortar" = /obj/item/reagent_containers/glass/mortar, "Chalk" = /obj/item/chalk)

/datum/homestead_perk/sewing
	name = "Expert Clothier"
	cost = 2
	category = HOMESTEAD_PERK_EXPERTISE
	traits = list(TRAIT_SEWING_EXPERT)

/datum/homestead_perk/survival
	name = "Expert Survivalist"
	cost = 2
	category = HOMESTEAD_PERK_EXPERTISE
	traits = list(TRAIT_SURVIVAL_EXPERT)

/datum/homestead_perk/homestead
	name = "Expert Homesteader"
	cost = 2
	category = HOMESTEAD_PERK_EXPERTISE
	traits = list(TRAIT_HOMESTEAD_EXPERT)

/datum/homestead_perk/medicine
	name = "Expert Physicker"
	cost = 2
	category = HOMESTEAD_PERK_EXPERTISE
	traits = list(TRAIT_MEDICINE_EXPERT)

/datum/homestead_perk/jack_of_all_trades
	name = "Jack of All Trades"
	desc = "Skills cost half as much to raise through dreams."
	cost = 2
	category = HOMESTEAD_PERK_EXPERTISE
	traits = list(TRAIT_JACKOFALLTRADES)

/datum/homestead_perk/drilled
	name = "Militia-Drilled"
	desc = "Combat skills can be raised to Journeyman."
	cost = 2

/datum/homestead_perk/seedknow
	name = "Seed Knower"
	traits = list(TRAIT_SEEDKNOW)

/datum/homestead_perk/cautious_fisher
	name = "Cautious Fisher"
	traits = list(TRAIT_CAUTIOUS_FISHER)

/datum/homestead_perk/empath
	name = "Empath"
	traits = list(TRAIT_EMPATH)

/datum/homestead_perk/intellectual
	name = "Intellectual"
	traits = list(TRAIT_INTELLECTUAL)

/datum/homestead_perk/steelhearted
	name = "Steelhearted"
	traits = list(TRAIT_STEELHEARTED)

/datum/homestead_perk/good_writer
	name = "Great Writer"
	desc = "Skillbooks you write teach faster."
	traits = list(TRAIT_GOODWRITER)

/datum/homestead_perk/appraiser
	name = "Appraiser"
	desc = "Roughly tell the price of things."
	traits = list(TRAIT_SEEPRICES_SHITTY)

/datum/homestead_perk/cicerone
	name = "Cicerone"
	desc = "Tell brews and spirits apart at a glance."
	traits = list(TRAIT_CICERONE)

/datum/homestead_perk/outdoorsman
	name = "Outdoorsman"
	desc = "Sleep on branches and rough ground as if in a bed."
	traits = list(TRAIT_OUTDOORSMAN)

/datum/homestead_perk/dead_nose
	name = "Dead Nose"
	desc = "The smell of decay doesn't bother you."
	category = HOMESTEAD_PERK_QUIRK
	traits = list(TRAIT_NOSTINK)

/datum/homestead_perk/night_owl
	name = "Night Owl"
	desc = "You enjoy the night hours."
	category = HOMESTEAD_PERK_QUIRK
	traits = list(TRAIT_NIGHT_OWL)

/datum/homestead_perk/fast_sleeper
	name = "Fast Sleeper"
	desc = "You drift off quickly."
	category = HOMESTEAD_PERK_QUIRK
	traits = list(TRAIT_FASTSLEEP)


/datum/homestead_perk/virtue
	category = HOMESTEAD_PERK_VIRTUE

/datum/homestead_perk/virtue/New()
	. = ..()
	name = initial(virtue.name)
	desc = initial(virtue.desc)

/datum/homestead_perk/virtue/arcyne_potential
	cost = 2
	virtue = /datum/virtue/combat/magical_potential

/datum/homestead_perk/virtue/devotee
	cost = 2
	virtue = /datum/virtue/combat/devotee

/datum/homestead_perk/virtue/tracker
	virtue = /datum/virtue/utility/tracker

/datum/homestead_perk/virtue/provisioner
	virtue = /datum/virtue/utility/granary

/datum/homestead_perk/virtue/prepared
	virtue = /datum/virtue/utility/preperation

/datum/homestead_kit
	var/name
	var/list/items

/datum/homestead_kit/proc/apply(mob/living/carbon/human/H)
	if(!H.mind)
		return
	for(var/item_name in items)
		H.mind.special_items[item_name] = items[item_name]

/datum/homestead_kit/smith
	name = "Smith's Tools"
	items = list("Hammer" = /obj/item/rogueweapon/hammer/steel)

/datum/homestead_kit/woodcutter
	name = "Woodcutter's Axe"
	items = list("Woodcutter's Axe" = /obj/item/rogueweapon/stoneaxe/woodcut/steel/woodcutter)

/datum/homestead_kit/barber
	name = "Barber's Bag"
	items = list("Barber's Innocuous Bag" = /obj/item/storage/belt/rogue/surgery_bag/full)

/datum/homestead_kit/miner
	name = "Trusty Pick"
	items = list("Trusty Pick" = /obj/item/rogueweapon/pick/bronze)

/datum/homestead_kit/fisher
	name = "Fishing Rod"
	items = list("Fishing Rod" = /obj/item/fishingrod/crafted)

/datum/homestead_kit/cook
	name = "Frying Pan"
	items = list("Pan for Frying" = /obj/item/cooking/pan)

/datum/homestead_kit/laborer
	name = "Laborer's Knife"
	items = list("Laborer's Knife" = /obj/item/rogueweapon/huntingknife/throwingknife/triumph, "Sheathe" = /obj/item/rogueweapon/scabbard/sheath)

/datum/homestead_kit/musician
	name = "Instrument"

/datum/homestead_kit/musician/apply(mob/living/carbon/human/H)
	H.mind?.special_items["Tuneful Instrument"] = pick(subtypesof(/obj/item/rogue/instrument))

/proc/get_homestead_perks()
	var/static/list/perks
	if(!perks)
		perks = list()
		for(var/datum/homestead_perk/perk_type as anything in subtypesof(/datum/homestead_perk))
			if(perk_type == /datum/homestead_perk/virtue)
				continue
			perks[perk_type] = new perk_type
	return perks

/proc/get_homestead_kits()
	var/static/list/kits
	if(!kits)
		kits = list()
		for(var/kit_type in subtypesof(/datum/homestead_kit))
			kits[kit_type] = new kit_type
	return kits
