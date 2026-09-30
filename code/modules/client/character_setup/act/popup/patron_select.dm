/datum/preferences/proc/ui_act_popup_patron_select(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(dreamvalley_domain_popup_act(ui.user, action, params))
		return CHARACTER_ACT_DATA_UPDATE
