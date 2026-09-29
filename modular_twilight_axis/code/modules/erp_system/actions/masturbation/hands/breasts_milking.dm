/datum/erp_action/self/hands/milking_breasts
	abstract = FALSE

	name = "Milk your breasts"
	required_target_organ = SEX_ORGAN_BREASTS

	inject_timing      = INJECT_CONTINUOUS
	inject_source      = INJECT_FROM_PASSIVE
	inject_target_mode = INJECT_CONTAINER

	message_start = "{actor} cups their breasts and slowly starts squeezing their nipples."
	message_tick = "{actor} {force} and {speed} squeezes their breasts, feeling them fill."
	message_finish = "{actor} stops squeezing, letting their nipples relax."
	message_climax_active =	"{actor} shudders as milk spills freely from their breasts."
