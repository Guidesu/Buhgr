/datum/erp_action/other/mouth/breast_feed
	abstract = FALSE
	name = "Lick their breasts"
	required_target_organ = SEX_ORGAN_BREASTS
	require_same_tile = FALSE
	active_arousal_coeff  = 0.3
	passive_arousal_coeff = 0.8
	inject_timing = INJECT_CONTINUOUS
	inject_source = INJECT_FROM_PASSIVE
	inject_target_mode = INJECT_ORGAN

	message_start  = "{actor} puts their lips to {partner}'s breasts and licks them."
	message_tick   = "{actor} {force} and {speed} licks {partner}'s nipples."
	message_finish = "{actor} takes their lips from {partner}'s breasts."

	message_climax_active  = "{partner}'s breasts throb under {actor}'s touch."
	message_climax_passive = "{partner} feels their breasts throb under {actor}'s touch."
