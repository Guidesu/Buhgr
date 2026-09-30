// "Marked by Baotha" vice, from Ratwood. The brand is drawn from a greyscale
// sprite so it can be tinted: the player picks its colour when they spawn.

/datum/charflaw/marked_by_baotha
	name = "Marked by the Forbidden"
	desc = "Whether I sought out heretical ritualists or was taken against my will, I have been marked by the Forbidden. The brand shows on my groin, I can conceive regardless of what would normally prevent it, and I must sate my new urges often or suffer for it."

/mob/living/carbon/human
	var/mutable_appearance/baotha_mark_overlay

/datum/charflaw/marked_by_baotha/on_mob_creation(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	apply_mark(H, "#d4458c")
	if(H.client)
		INVOKE_ASYNC(src, PROC_REF(pick_mark_colour), H)

	addtimer(CALLBACK(src, PROC_REF(grant_fertility_boon), H), 4 SECONDS)
	var/obj/item/organ/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
	if(vagina && !vagina.fertility)
		vagina.fertility = TRUE
	// The brand brings its urges with it.
	if(!HAS_TRAIT(H, TRAIT_DEPRAVED) && !H.has_flaw(/datum/charflaw/addiction/baothamarked))
		var/datum/charflaw/addiction/baothamarked/urges = new
		H.charflaws += urges
		urges.on_mob_creation(H)

/datum/charflaw/marked_by_baotha/proc/pick_mark_colour(mob/living/carbon/human/H)
	var/colour = tgui_color_picker(H, "What colour does the Forbidden's brand glow on your skin?", "The Forbidden's Mark", "#d4458c")
	if(colour && !QDELETED(H))
		apply_mark(H, colour)

/datum/charflaw/marked_by_baotha/proc/apply_mark(mob/living/carbon/human/H, colour)
	if(H.baotha_mark_overlay)
		H.cut_overlay(H.baotha_mark_overlay)
	var/mutable_appearance/mark = mutable_appearance('icons/roguetown/misc/baotha_marking.dmi', "marking_[H.gender == MALE ? "m" : "f"]", -BODY_LAYER)
	mark.color = colour
	if(isdwarf(H) || isgoblinp(H) || iskobold(H))
		mark.pixel_y -= (H.gender == MALE) ? 5 : 3
	H.baotha_mark_overlay = mark
	H.add_overlay(mark)

/datum/charflaw/marked_by_baotha/proc/grant_fertility_boon(mob/living/carbon/human/H)
	if(!QDELETED(H))
		ADD_TRAIT(H, TRAIT_BAOTHA_FERTILITY_BOON, TRAIT_GENERIC)
