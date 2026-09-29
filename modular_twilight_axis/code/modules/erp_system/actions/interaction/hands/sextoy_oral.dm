/datum/erp_action/other/hands/toy_oral
	abstract = FALSE

	name = "Toy in their mouth"
	required_target_organ = SEX_ORGAN_MOUTH
	require_same_tile = FALSE
	message_start = "{actor} brings a toy to the lips of {dullahan?the severed head of :}{partner}."
	message_tick = "{actor} {force} and {speed} works the toy in the mouth of {dullahan?the severed head of :}{partner}."
	message_finish =  "{actor} takes the toy away from {dullahan?the severed head of :}{partner}."
	required_item_tags = list("dildo")
