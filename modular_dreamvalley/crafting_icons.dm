// Small icons beside each recipe in the crafting menu, drawn from one cached
// spritesheet of every recipe's result (like the Character Creation item grid).

/datum/asset/spritesheet_batched/crafting_results
	name = "crafting_results"
	ignore_dir_errors = TRUE

/datum/asset/spritesheet_batched/crafting_results/create_spritesheets()
	var/list/states_by_file = list()
	var/list/done = list()
	for(var/datum/crafting_recipe/R as anything in GLOB.crafting_recipes)
		var/result_path = crafting_result_path(R)
		if(!ispath(result_path, /atom) || done[result_path])
			continue
		done[result_path] = TRUE
		var/atom/typed = result_path
		var/icon_file = initial(typed.icon)
		var/icon_state = initial(typed.icon_state)
		if(!icon_file)
			continue
		var/list/valid_states = states_by_file[icon_file]
		if(!valid_states)
			valid_states = states_by_file[icon_file] = icon_states(icon_file)
		if(!(icon_state in valid_states))
			continue
		insert_icon(crafting_icon_key(result_path), get_display_icon_for(result_path))

/proc/crafting_result_path(datum/crafting_recipe/R)
	if(islist(R.result))
		return length(R.result) ? R.result[1] : null
	return R.result

/proc/crafting_icon_key(result_path)
	return "craft[replacetext("[result_path]", "/", "-")]"

/datum/component/personal_crafting/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet_batched/crafting_results))

/datum/component/personal_crafting/ui_static_data(mob/user)
	. = ..()
	var/datum/asset/spritesheet_batched/crafting_results/sheet = get_asset_datum(/datum/asset/spritesheet_batched/crafting_results)
	var/list/by_name = list()
	for(var/datum/crafting_recipe/R as anything in GLOB.crafting_recipes)
		if(R.name)
			by_name[R.name] = R
	var/list/categories = .["crafting_recipes"]
	for(var/category in categories)
		var/list/rows = categories[category]
		var/list/new_rows = list()
		for(var/list/row as anything in rows)
			var/list/copy = row.Copy()
			var/datum/crafting_recipe/R = by_name[row["name"]]
			var/result_path = R ? crafting_result_path(R) : null
			copy["icon_class"] = result_path ? sheet.icon_class_name(crafting_icon_key(result_path)) : null
			new_rows += list(copy)
		categories[category] = new_rows
