// Ratwood hover-examine: item stat tooltips on examine. AP already has its own tooltip
// hook (generate_tooltip(), armor ratings for clothing), so Ratwood's text is shown
// through it: items AP doesn't cover get Ratwood's tooltip, and items that define extra
// hover lines (chastity devices, cursed collars) add them to AP's.

/obj/item
	var/always_show_examine_link = FALSE
	var/nudist_approved = FALSE

/obj/item/generate_tooltip(examine_text)
	. = ..()
	if(. != examine_text || !show_examine_hover_tooltip())
		return
	var/tooltip_html = get_hover_examine_html(usr, usr?.contents && (src in usr.contents))
	if(!tooltip_html)
		return
	var/label = always_show_examine_link ? examine_text : "<u><font color='#add8e6'>[examine_text]</font></u>"
	return SPAN_TOOLTIP_DANGEROUS_HTML(tooltip_html, label)

/obj/item/clothing/neck/roguetown/cursed_collar/generate_tooltip(examine_text)
	. = ..()
	var/extra = get_hover_examine_html(usr)
	if(extra && . == examine_text)
		return SPAN_TOOLTIP_DANGEROUS_HTML(extra, examine_text)

/obj/item/proc/show_examine_hover_tooltip()
	if(always_show_examine_link)
		return TRUE
	if(minstr || minstr_req)
		return TRUE
	if(force >= 5)
		return TRUE
	if(gripped_intents && force_wielded)
		return TRUE
	if(wbalance)
		return TRUE
	if(wlength != WLENGTH_NORMAL)
		return TRUE
	if(gripped_intents || twohands_required)
		return TRUE
	if(can_parry || max_blade_int)
		return TRUE
	if(associated_skill && associated_skill.name)
		return TRUE
	if(intdamage_factor != 1)
		return TRUE
	return FALSE

/obj/item/proc/get_true_durability_percent_text()
	if(!max_integrity)
		return null
	var/percent = round(((obj_integrity / max_integrity) * 100), 1)
	return "[percent]% ([floor(obj_integrity)])"

/obj/item/proc/get_hover_examine_description()
	if(!desc)
		return null
	return html_encode(desc)

/obj/item/proc/get_hover_examine_condition_text()
	return null

/obj/item/proc/get_hover_examine_stat_lines(mob/user, self_examine = FALSE)
	var/list/lines = list()
	if(minstr)
		lines += "<b>MIN.STR:</b> [minstr]"
	if(minstr_req)
		lines += "<b>NO HALVING ON WIELD</b>"
	if(force)
		lines += "<b>FORCE:</b> [get_force_string(force)]"
	if(gripped_intents && force_wielded)
		lines += "<b>WIELDED FORCE:</b> [get_force_string(force_wielded)]"
	if(wbalance)
		var/balance_text = ""
		if(wbalance == WBALANCE_HEAVY)
			balance_text = "Heavy"
		if(wbalance == WBALANCE_SWIFT)
			balance_text = "Swift"
		if(balance_text)
			lines += "<b>BALANCE:</b> [balance_text]"
	if(wlength != WLENGTH_NORMAL)
		var/length_text = ""
		switch(wlength)
			if(WLENGTH_SHORT)
				length_text = "Short"
			if(WLENGTH_LONG)
				length_text = "Long"
			if(WLENGTH_GREAT)
				length_text = "Great"
		if(length_text)
			lines += "<b>LENGTH:</b> [length_text]"
	var/shaft_text = get_blade_dulling_text(src, verbose = TRUE)
	if(shaft_text)
		lines += "<b>SHAFT:</b> [html_encode(shaft_text)]"
	if(gripped_intents)
		lines += "<b>TWO-HANDED</b>"
	if(twohands_required)
		lines += "<b>BULKY</b>"
	if(can_parry)
		lines += "<b>DEFENSE:</b> [wdefense_dynamic]"
	if(max_blade_int)
		var/blade_percent = round(((blade_int / max_blade_int) * 100), 1)
		lines += "<b>SHARPNESS:</b> [blade_percent]% ([blade_int])"
	if(associated_skill && associated_skill.name)
		lines += "<b>SKILL:</b> [html_encode(associated_skill.name)]"
	if(intdamage_factor != 1 && force >= 5)
		lines += "<b>INTEGRITY DAMAGE:</b> [intdamage_factor * 100]%"
	if(self_examine)
		var/true_durability = get_true_durability_percent_text()
		if(true_durability)
			lines += "<b>Durability:</b> [true_durability]"
	return lines

/obj/item/proc/get_hover_examine_html(mob/user, self_examine = FALSE)
	var/list/sections = list()
	var/description_text = get_hover_examine_description()
	if(description_text)
		sections += description_text
	var/list/stat_lines = get_hover_examine_stat_lines(user, self_examine)
	if(length(stat_lines))
		sections += stat_lines.Join("<br>")
	return sections.Join("<br>")


