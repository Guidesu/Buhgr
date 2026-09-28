/mob/living/carbon/human/species/human/northern/bog_deserters
	npc_archetype = /datum/npc_archetype/bog_deserter/mixed
	ai_controller = /datum/ai_controller/human_npc
	faction = list(FACTION_BANDITS)
	ambushable = FALSE
	cmode = 1
	setparrytime = 30
	a_intent = INTENT_HELP
	d_intent = INTENT_PARRY
	possible_mmb_intents = list(INTENT_BITE, INTENT_JUMP, INTENT_KICK, INTENT_SPECIAL)
	blood_toll_bucket = STATS_KILLED_BOGMEN

/mob/living/carbon/human/species/human/northern/bog_deserters/ambush
	threat_point = THREAT_DANGEROUS
	ambush_faction = "bandits"



/mob/living/carbon/human/species/human/northern/bog_deserters/Initialize(mapload)
	. = ..()
	//Begin RANDOMISE here
	set_species(pick(NPC_RACES_TYPES))
	gender = pick(MALE, FEMALE)
	dna.species.random_character(src) //Now we just randomise here, MUST be called after both race + gender
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)


/mob/living/carbon/human/species/human/northern/bog_deserters/after_creation()
	..()
	AddComponent(/datum/component/ai_aggro_system)
	SEND_SIGNAL(src, COMSIG_MOB_MODIFY_AGGRO_LINES, GLOB.highwayman_aggro, TRUE)
	job = "Garrison Deserter"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_LEECHIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_BREADY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NPC_EXAMINE, TRAIT_GENERIC)
	equipOutfit(new deserter_outfit)
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	head.sellprice = HEAD_BOUNTY_DESERTER
	AddComponent(/datum/component/npc_death_line, null, 25)
	dna.species.handle_body(src)
	random_voice_NPC()
	random_hair_NPC()
	random_eye_color_NPC()
	correct_features_NPC()

	if(gender == FEMALE)
		real_name = pick(world.file2list("strings/names/first_female.txt"))
	else
		real_name = pick(world.file2list("strings/names/first_male.txt"))
	update_hair()
	update_body()
	src.regenerate_icons() //Fixes the weird body


/datum/outfit/job/roguetown/human/northern/bog_deserters/pre_equip(mob/living/carbon/human/H)
	..()
	//skill Stuff
	H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_EXPERT, TRUE) //NPCs do not get these skills unless a mind takes them over, hopefully in the future someone can fix
	H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_JOURNEYMAN, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
	H.adjust_skillrank_up_to(/datum/skill/misc/athletics, SKILL_LEVEL_JOURNEYMAN, TRUE)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	H.STASTR = rand(12,14)
	H.STASPD = 11
	H.STACON = 8
	H.STAWIL = 8
	H.STAPER = 11
	H.STAINT = 10
	//Chest Gear
	add_random_deserter_cloak(H)
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron
	//Head Gear
	neck = /obj/item/clothing/neck/roguetown/coif/heavypadding
	head = /obj/item/clothing/head/roguetown/helmet/kettle/iron
	//wrist Gear
	gloves = /obj/item/clothing/gloves/roguetown/chain/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/iron
	//Lower Gear
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
	//Weapons
	if(prob(30)) // ranged
		belt = /obj/item/storage/belt/rogue/leather
		backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
		backl = /obj/item/quiver/npc
		r_hand = /obj/item/rogueweapon/sword/iron
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
		armor = /obj/item/clothing/suit/roguetown/shirt/rags
		head = null
		neck = null
		gloves = /obj/item/clothing/gloves/roguetown/leather
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
		pants = /obj/item/clothing/under/roguetown/trou/leather
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		H.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.upgrade_ai_controller(/datum/ai_controller/human_npc/archer)
		H.STASTR -= 2
		H.STAPER = 11
	else if(prob(25)) // tossblade
		belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
		H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_JOURNEYMAN, TRUE)
		add_random_deserter_weapon(H)
	else
		belt = /obj/item/storage/belt/rogue/leather
		add_random_deserter_weapon(H)
	add_random_deserter_beltl_stuff(H)
	add_random_deserter_beltr_stuff(H)

	if(prob(30))
		var/voicepack_choice = rand(1, 4)
		switch(voicepack_choice)
			if(1)
				H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/warrior]
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/warrior]
			if(2)
				H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/stern]
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/haughty]
			if(3)
				H.dna.species.soundpack_m = GLOB.voice_packs[/datum/voicepack/male/foppish]
				H.dna.species.soundpack_f = GLOB.voice_packs[/datum/voicepack/female/dainty]

/mob/living/carbon/human/species/human/northern/bog_deserters/better_gear
	npc_archetype = /datum/npc_archetype/bog_deserter/better_gear
	faction = list(FACTION_BANDITS, FACTION_STATION)

/mob/living/carbon/human/species/human/northern/bog_deserters/better_gear/ambush
	threat_point = THREAT_DANGEROUS

/mob/living/carbon/human/species/human/northern/bog_deserters/tosser
	npc_archetype = /datum/npc_archetype/bog_deserter/tosser

/mob/living/carbon/human/species/human/northern/bog_deserters/tosser/ambush
	threat_point = THREAT_DANGEROUS
	ambush_faction = "bandits"

/mob/living/carbon/human/species/human/northern/bog_deserters/tosser/better_gear
	npc_archetype = /datum/npc_archetype/bog_deserter/tosser/better_gear

/mob/living/carbon/human/species/human/northern/bog_deserters/tosser/better_gear/ambush
	threat_point = THREAT_DANGEROUS

/mob/living/carbon/human/species/human/northern/bog_deserters/archer
	npc_archetype = /datum/npc_archetype/bog_deserter/archer

/mob/living/carbon/human/species/human/northern/bog_deserters/archer/ambush
	threat_point = THREAT_DANGEROUS
	ambush_faction = "bandits"

/mob/living/carbon/human/species/human/northern/bog_deserters/crossbowman
	npc_archetype = /datum/npc_archetype/bog_deserter/crossbowman

/mob/living/carbon/human/species/human/northern/bog_deserters/crossbowman/ambush
	threat_point = THREAT_DANGEROUS
	ambush_faction = "bandits"

/mob/living/carbon/human/species/human/northern/bog_deserters/marshal
	npc_archetype = /datum/npc_archetype/bog_deserter/better_gear/marshal
	threat_point = THREAT_ELITE

/mob/living/carbon/human/species/human/northern/bog_deserters/marshal/ambush
	threat_point = THREAT_ELITE
	ambush_faction = "bandits"
