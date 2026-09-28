// Ratwood quirks (Ratwood PR #2650) in Azure Peak's quirk system (AP PR #8671).
// Only quirks whose effect exists in this codebase are here; Ratwood quirks that
// duplicate an AP one (Fabled Lover, Night Owl, Noble, Outdoorsy, Ugly) are covered
// by AP's version. Redolent, Acquired Tastes and Rough Lover live with the sexcon
// port in ported/ratwood/sexcon/redolent.dm.

/datum/quirk/annoyingface
	name = "Annoying Face"
	desc = "I am cursed with an odd voice and appearance."
	added_traits = list(TRAIT_COMICSANS)
	ui_fa_icon = "face-grin-tongue"

/datum/quirk/deadnose
	name = "Dead Nose"
	desc = "My nose is numb to the smell of decay."
	mechdesc = "Rot and stench don't bother you."
	added_traits = list(TRAIT_NOSTINK)
	ui_fa_icon = "head-side-mask"

/datum/quirk/empath
	name = "Empath"
	desc = "I can read people's feelings at a glance."
	added_traits = list(TRAIT_EMPATH)
	restricted_virtues = list(/datum/virtue/utility/socialite)
	ui_fa_icon = "heart"

/datum/quirk/selfaware
	name = "Self Aware"
	desc = "I've always been conscious about how hurt my body can get."
	added_traits = list(TRAIT_SELF_AWARE)
	ui_fa_icon = "user-injured"

/datum/quirk/largeframe
	name = "Large Frame"
	desc = "I'm simply built bigger than most. My strength and hardiness has nothing to show for my size, though."
	mechdesc = "Makes your character larger. Cannot be combined with the Giant virtue."
	restricted_virtues = list(/datum/virtue/size/giant)
	ui_fa_icon = "up-right-and-down-left-from-center"

/datum/quirk/largeframe/apply_to_human(mob/living/carbon/human/recipient)
	recipient.transform = recipient.transform.Scale(1.25, 1.25)
	recipient.transform = recipient.transform.Translate(0, (0.25 * 16))
	recipient.update_transform()

/datum/quirk/secondvoice
	name = "Second Voice"
	desc = "From performance, deception, or by a need to change yourself in uncanny ways, I've acquired a second, perfect voice. I may switch between them at any point."
	mechdesc = "Adds verbs to set and swap to a second voice."
	ui_fa_icon = "masks-theater"

/datum/quirk/secondvoice/apply_to_human(mob/living/carbon/human/recipient)
	add_verb(recipient, /mob/living/carbon/human/proc/changevoice)
	add_verb(recipient, /mob/living/carbon/human/proc/swapvoice)

// AP PR #8671 hooks these quirks into AP's sexcon2 sessions; this codebase runs Ratwood's
// sexcon, so the same effects hook in here.

/// Prickly (TRAIT_CAUSTIC): intimate contact with a prickly partner hurts a little.
#define CAUSTIC_PAIN_DMG 5
/datum/sex_controller/perform_sex_action(mob/living/carbon/human/action_target, arousal_amt, pain_amt, giving)
	. = ..()
	if(!action_target || action_target == user)
		return
	if(HAS_TRAIT(user, TRAIT_CAUSTIC) && action_target.sexcon)
		action_target.sexcon.damage_from_pain(CAUSTIC_PAIN_DMG)
		action_target.sexcon.try_do_pain_effect(CAUSTIC_PAIN_DMG, giving)
	if(HAS_TRAIT(action_target, TRAIT_CAUSTIC))
		damage_from_pain(CAUSTIC_PAIN_DMG)
		try_do_pain_effect(CAUSTIC_PAIN_DMG, giving)
#undef CAUSTIC_PAIN_DMG

/// Unlanded Noble: being seen bedding a commoner (face uncovered) is a scandal in the making.
/datum/sex_controller/after_intimate_climax(oral, mob/living/carbon/human/climax_target = null)
	. = ..()
	var/mob/living/carbon/human/partner = climax_target
	if(!partner || partner == user || !HAS_TRAIT(user, TRAIT_NOBLE_UNLANDED))
		return
	if(partner.get_face_name() == partner.real_name && !partner.is_burgher() && !partner.is_courtier() && !partner.is_noble())
		user.add_stress(/datum/stressevent/unlanded_noble_scandal_in_the_making)
