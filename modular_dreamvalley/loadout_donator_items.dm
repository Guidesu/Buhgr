// The loadout offers the finished donator items directly instead of the
// morphing elixirs that turn a base item into them.

/proc/dreamvalley_expand_donator_kits()
	for(var/datum_path in GLOB.loadout_items.Copy())
		var/datum/loadout_item/kit_entry = GLOB.loadout_items[datum_path]
		if(!ispath(kit_entry.path, /obj/item/enchantingkit))
			continue
		var/obj/item/enchantingkit/kit = new kit_entry.path(null)
		var/list/results = list()
		if(ispath(kit.result_item, /obj/item))
			results |= kit.result_item
		for(var/target in kit.target_items)
			var/result = kit.target_items[target]
			if(ispath(result, /obj/item))
				results |= result
		qdel(kit)
		if(!length(results))
			continue

		GLOB.loadout_items -= datum_path
		GLOB.loadout_items_by_name -= kit_entry.name
		for(var/obj/item/result as anything in results)
			var/item_name = "Donator Item - [capitalize(initial(result.name))]"
			if(GLOB.loadout_items_by_name[item_name])
				continue
			var/datum/loadout_item/donator/entry = new
			entry.name = item_name
			entry.path = result
			entry.desc = initial(result.desc)
			entry.cost = kit_entry.cost
			entry.sort_category = kit_entry.sort_category
			entry.donoritem = kit_entry.donoritem
			entry.donator_unlocked = kit_entry.donator_unlocked
			entry.ckeywhitelist = kit_entry.ckeywhitelist
			GLOB.loadout_items["[result]"] = entry
			GLOB.loadout_items_by_name[item_name] = entry
