/datum/erp_action/other/hands/milking_penis
	name = "Milk their cock"
	abstract = FALSE
	required_target_organ = SEX_ORGAN_PENIS
	active_arousal_coeff  = 0.6
	passive_arousal_coeff = 1.0
	inject_timing = INJECT_ON_FINISH
	inject_source = INJECT_FROM_PASSIVE
	inject_target_mode = INJECT_CONTAINER

	message_start  = "{actor} lays their hands on {partner}'s cock."
	message_tick   = "{actor} {force} and {speed} works their hands along {partner}'s cock."
	message_finish = "{actor} takes their hands off {partner}'s cock."
	message_climax_passive = "{partner} climaxes in {actor}'s hands."
