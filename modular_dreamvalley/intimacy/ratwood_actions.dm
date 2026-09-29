// Intimacy merge: Ratwood actions that Twilight's set didn't already cover,
// rebuilt as Twilight action data so they show up in the one panel.

/datum/erp_action/other/mouth/bathe_with_tongue
	abstract = FALSE
	name = "Bathe with tongue"
	required_target_organ = SEX_ORGAN_BODY
	require_same_tile = FALSE
	message_start = "{actor} starts running their tongue over {partner}."
	message_tick = "{actor} {force} and {speed} licks along {partner}'s {zone}."
	message_finish = "{actor} lifts their tongue from {partner}."

/datum/erp_action/other/mouth/nuzzle_crotch
	abstract = FALSE
	name = "Nuzzle their crotch"
	required_target_organ = SEX_ORGAN_BODY
	message_start = "{actor} buries their face in {partner}'s crotch."
	message_tick = "{actor} {force} and {speed} nuzzles {partner}'s crotch."
	message_finish = "{actor} draws their face back from {partner}'s crotch."

/datum/erp_action/other/mouth/nuzzle_armpit
	abstract = FALSE
	name = "Nuzzle their armpit"
	required_target_organ = SEX_ORGAN_BODY
	require_same_tile = FALSE
	message_start = "{actor} presses their face into {partner}'s armpit."
	message_tick = "{actor} {force} and {speed} nuzzles into {partner}'s armpit."
	message_finish = "{actor} draws their face back from {partner}'s armpit."

/datum/erp_action/other/mouth/suck_balls
	abstract = FALSE
	name = "Suck their balls"
	required_target_organ = SEX_ORGAN_PENIS
	action_tags = list("testicles")
	message_start = "{actor} takes {partner}'s balls into their mouth."
	message_tick = "{actor} {force} and {speed} sucks on {partner}'s balls."
	message_finish = "{actor} lets {partner}'s balls slip from their mouth."
	message_climax_passive = "{partner} climaxes as {actor} sucks their balls."

/datum/erp_action/other/hands/rub_ears
	abstract = FALSE
	name = "Rub their ears"
	required_target_organ = SEX_ORGAN_BODY
	require_same_tile = FALSE
	message_start = "{actor} reaches up to {partner}'s ears."
	message_tick = "{actor} {force} and {speed} rubs {partner}'s ears."
	message_finish = "{actor} takes their hands from {partner}'s ears."

/datum/erp_action/other/breasts/smother
	abstract = FALSE
	name = "Smother them with your breasts"
	required_target_organ = SEX_ORGAN_MOUTH
	message_start = "{actor} pulls {partner}'s face into their breasts."
	message_tick = "{actor} {force} and {speed} smothers {partner} between their breasts."
	message_finish = "{actor} lets {partner} up for air."

/datum/erp_action/other/legs/smother_feet
	abstract = FALSE
	name = "Smother them with your feet"
	required_target_organ = SEX_ORGAN_MOUTH
	message_start = "{actor} presses their feet over {partner}'s face."
	message_tick = "{actor} {force} and {speed} smothers {partner}'s face with their feet."
	message_finish = "{actor} lifts their feet from {partner}'s face."

/datum/erp_action/other/penis/grind_knot
	abstract = FALSE
	name = "Grind your knot"
	required_target_organ = SEX_ORGAN_BODY
	message_start = "{actor} presses their knot against {partner}."
	message_tick = "{actor} {force} and {speed} grinds their knot against {partner}'s {zone}."
	message_finish = "{actor} draws their knot away from {partner}."
	message_climax_active = "{actor} climaxes, grinding their knot against {partner}."
