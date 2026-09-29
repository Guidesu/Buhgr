/datum/erp_action/other/hands/milking_breasts
	name = "Milk their breasts"
	abstract = FALSE
	required_target_organ = SEX_ORGAN_BREASTS
	active_arousal_coeff  = 0.4
	passive_arousal_coeff = 0.9
	inject_timing = INJECT_CONTINUOUS
	inject_source = INJECT_FROM_PASSIVE
	inject_target_mode = INJECT_CONTAINER
	message_start  = "{actor} lays their hands on {partner}'s breasts."
	message_tick   = "{actor} {force} and {speed} works their hands over {partner}'s breasts."
	message_finish = "{actor} takes their hands off {partner}'s breasts."
	message_climax_passive = "{partner} feels their breasts let down milk."
