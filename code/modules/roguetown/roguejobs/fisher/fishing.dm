/proc/getfishingloot(mob/living/carbon/human/fisherman, list/modlist, turf/target, skill_power = 1)
	var/frwt = list(/turf/open/water/river, /turf/open/water/cleanshallow, /turf/open/water/pond)
	var/salwt_coast = list(/turf/open/water/ocean)
	var/salwt_deep = list(/turf/open/water/ocean/deep, /turf/open/water/ocean/deep/dark)
	var/salwt_abyssal = list(/turf/open/water/ocean/abyssal)
	var/mud = list(/turf/open/water/swamp, /turf/open/water/swamp/deep)
	if(ishuman(fisherman))
		if(fisherman.patron.type == /datum/patron/concordat/wulfric)
			modlist["dangerFishingMod"] *= 1.10  // +10% danger
			modlist["treasureFishingMod"] *= 0.90  // -10% treasure
			modlist["rareFishingMod"] *= 1.25  // +25% rare
		if(fisherman.STALUC > 10)
			var/trait_bonus = 0
			if(HAS_TRAIT(fisherman, TRAIT_CAUTIOUS_FISHER))
				trait_bonus = 0.20
			var/tier1_bonus = min(fisherman.STALUC - 10, 5) // 5% bonus per point up until 15
			var/tier2_bonus = max(fisherman.STALUC - 15, 0) // 1% bonus per point past 15
			var/total_bonus = ((tier1_bonus * 0.05) + (tier2_bonus * 0.01) + (trait_bonus)) * skill_power
			modlist["rareFishingMod"] *= (1 + total_bonus)
			modlist["treasureFishingMod"] *= (1 + total_bonus)
			modlist["dangerFishingMod"] *= (1 - (trait_bonus * 3))
	var/fishingloot
	if(target.type in frwt)
		fishingloot = pickweightAllowZero(createFreshWaterFishWeightListModlist(modlist))
	else if(target.type in salwt_coast)
		fishingloot = pickweightAllowZero(createCoastalSeaFishWeightListModlist(modlist))
	else if(target.type in salwt_deep)
		fishingloot = pickweightAllowZero(createDeepSeaFishWeightListModlist(modlist))
	else if(target.type in salwt_abyssal)
		fishingloot = pickweightAllowZero(createAbyssalSeaFishWeightListModlist(modlist))
	else if(target.type in mud)
		fishingloot = pickweightAllowZero(createMudFishWeightListModlist(modlist))
	return fishingloot

/proc/upgradecagemodlist(mob/living/carbon/human/fisherman, list/modlist, skill_power = 1)
	if(ishuman(fisherman))
		if(fisherman.patron.type == /datum/patron/concordat/wulfric)
			modlist["dangerFishingMod"] *= 1.10  // +10% danger
			modlist["treasureFishingMod"] *= 0.90  // -10% treasure
			modlist["rareFishingMod"] *= 1.25  // +25% rare
		if(fisherman.STALUC > 10)
			var/trait_bonus = 0
			if(HAS_TRAIT(fisherman, TRAIT_CAUTIOUS_FISHER))
				trait_bonus = 0.30
			var/tier1_bonus = min(fisherman.STALUC - 10, 5) // 5% bonus per point up until 15
			var/tier2_bonus = max(fisherman.STALUC - 15, 0) // 1% bonus per point past 15
			var/total_bonus = ((tier1_bonus * 0.05) + (tier2_bonus * 0.01) + (trait_bonus)) * skill_power
			modlist["rareFishingMod"] *= (1 + total_bonus)
			modlist["treasureFishingMod"] *= (1 + total_bonus)
			modlist["dangerFishingMod"] *= (1 - (trait_bonus * 3))
	return modlist

/proc/getbaitlife(fishing_skill, obj/item/bait, basechance = 80)
	if(bait.baitresilience > 0)
		if(fishing_skill >= SKILL_LEVEL_MASTER)
			bait.baitresilience = max(0, bait.baitresilience - 1)
		else
			bait.baitresilience = max(0, bait.baitresilience - 2)
		return FALSE
	if(prob(basechance - (fishing_skill * 10)))
		return TRUE
	return FALSE

/mob/living
	var/hand_fishing_mode = null
	var/hand_fishing_mode_until = 0
	var/turf/hand_fishing_reel_turf = null
	var/hand_fishing_reel_until = 0
	var/hand_fishing_reel_loot = null
	var/hand_fishing_reel_size_tag = null
	/// Temp fishingrod used for the cast hand-fishing minigame UI. Null when not in minigame.
	var/obj/item/fishingrod/hand_fishing_cast_rod = null

/proc/get_fish_habitat(fish_path)
	var/static/list/freshwater_only = list(
		/obj/item/reagent_containers/food/snacks/fish/eel,
		/obj/item/reagent_containers/food/snacks/fish/carp,
		/obj/item/reagent_containers/food/snacks/fish/salmon,
		/obj/item/reagent_containers/food/snacks/fish/black_bass,
		/obj/item/reagent_containers/food/snacks/fish/sturgeon,
	)
	var/static/list/saltwater_only = list(
		/obj/item/reagent_containers/food/snacks/fish/cod,
		/obj/item/reagent_containers/food/snacks/fish/sole,
		/obj/item/reagent_containers/food/snacks/fish/bass,
		/obj/item/reagent_containers/food/snacks/fish/salmon/black_headed,
		/obj/item/reagent_containers/food/snacks/fish/flounder,
		/obj/item/reagent_containers/food/snacks/fish/mackerel,
		/obj/item/reagent_containers/food/snacks/fish/plaice,
		/obj/item/reagent_containers/food/snacks/fish/lobster,
		/obj/item/reagent_containers/food/snacks/fish/angler,
		/obj/item/reagent_containers/food/snacks/fish/beaksnapper,
		/obj/item/reagent_containers/food/snacks/fish/octopus,
	)
	if(fish_path in freshwater_only)
		return "fresh"
	if(fish_path in saltwater_only)
		return "salt"
	return "any" // junk, mobs, etc — treated as habitat-agnostic

/proc/get_handfishingloot(mob/living/carbon/human/fisherman, list/modlist, turf/target, skill_power = 1, cage_roll_chance = 30)
	if(!istype(target, /turf/open/water))
		return null
	if(!islist(modlist))
		modlist = list(
			"commonFishingMod" = 1,
			"rareFishingMod" = 1,
			"treasureFishingMod" = 1,
			"trashFishingMod" = 1,
			"dangerFishingMod" = 1,
			"ceruleanFishingMod" = 0,
			"cheeseFishingMod" = 0,
		)

	var/list/base_mods = modlist.Copy()
	var/base_loot = getfishingloot(fisherman, base_mods, target, skill_power)
	if(cage_roll_chance <= 0 || !prob(cage_roll_chance))
		return base_loot

	var/list/cage_mods = upgradecagemodlist(fisherman, modlist.Copy(), skill_power)
	var/cage_loot = pickweightAllowZero(createCageFishWeightListModlist(cage_mods, target))
	if(cage_loot)
		return cage_loot
	return base_loot

/proc/is_excluded_fishing_border_turf(turf/T)
	if(!T)
		return FALSE
	var/type_string = "[T.type]"
	if(findtext(type_string, "/turf/open/floor/rogue/dirt"))
		return TRUE
	if(findtext(type_string, "/turf/open/floor/rogue/grass"))
		return TRUE
	if(findtext(type_string, "/turf/open/floor/rogue/sand"))
		return TRUE
	if(findtext(type_string, "/turf/open/floor/rogue/mud"))
		return TRUE
	return FALSE

/proc/get_fishing_excluded_turf_distance(turf/open/water/W, max_scan = 6)
	if(!W)
		return 0
	var/closest_dist = max_scan + 1
	for(var/turf/T in spiral_range_turfs(max_scan, W))
		if(!is_excluded_fishing_border_turf(T))
			continue
		closest_dist = min(closest_dist, get_dist(W, T))
	if(closest_dist > max_scan)
		return max_scan + 1
	return closest_dist
