// Ratwood handholding check and Eora's consensual-partner tracking (renamed Miluše here).
// sexcon records a pair after consensual sex; Miluše's Heart reads it back.
// Ratwood obtains the Heart through its church-loop research, which isn't ported,
// so for now it only comes from admins or mapping.

var/global/list/EORA_PARTNERS_BY_ID = list()
var/global/list/EORA_ID_NAME = list()

/mob/proc/check_handholding()
	return

/mob/living/carbon/human/check_handholding()
	if(pulledby && pulledby != src)
		var/obj/item/bodypart/LH = get_bodypart(BODY_ZONE_PRECISE_L_HAND)
		var/obj/item/bodypart/RH = get_bodypart(BODY_ZONE_PRECISE_R_HAND)
		if(LH || RH)
			for(var/obj/item/grabbing/G in src.grabbedby)
				if(G.limb_grabbed == LH || G.limb_grabbed == RH)
					return TRUE

/obj/item/miluse_heart
	name = "Miluše's Heart"
	desc = "A velvet heart dedicated to Miluše. It remembers the names of bonds formed."
	icon = 'icons/roguetown/items/artefactsten.dmi'
	icon_state = "eoraartefact"
	w_class = WEIGHT_CLASS_TINY

/obj/item/miluse_heart/examine(mob/user)
	. = ..()
	. += "<hr><span class='info'>Use in hand: show your sex partners you had this week.</span><br>"
	. += "<span class='info'>Use on a player: asks their permission, then shows their unique partners this round.</span><br>"

/obj/item/miluse_heart/attack_self(mob/user)
	if(world.time < last_used + 300)
		to_chat(user, span_warning("The heart is quiet. Give it a moment."))
		return

	if(!ishuman(user) || !user.client)
		to_chat(user, span_warning("The heart needs a living player to answer."))
		return

	last_used = world.time

	var/mob/living/carbon/human/H = user
	var/cnt = eora_get_partner_count(H)
	var/list/names = eora_get_partner_names(H)

	to_chat(user, span_notice("Miluše's Whisper: You have <b>[cnt]</b> unique partner[cnt == 1 ? "" : "s"] this round."))
	if(names && names.len)
		to_chat(user, "<span class='info'>Names:</span>")
		for(var/N in names)
			to_chat(user, " • [html_encode(N)]")
	else
		to_chat(user, "<span class='info'>No names to show.</span>")

	playsound(user, 'sound/magic/whiteflame.ogg', 50, FALSE)

/obj/item/miluse_heart/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return

	if(!isliving(target))
		to_chat(user, span_warning("The heart only answers for living beings."))
		return

	if(!ishuman(target) || !target:client)
		to_chat(user, span_warning("The heart only tallies beings."))
		return

	var/mob/living/carbon/human/H = target

	if(H == user)
		attack_self(user)
		return

	if(world.time < last_used + 300)
		to_chat(user, span_warning("The heart is quiet. Give it a moment."))
		return

	var/consent = alert(H, "[user.name] wants to use Miluše's Heart on you and see your sex partners this week. Allow it?", "Miluše's Heart", "Allow", "Deny")
	if(consent != "Allow")
		to_chat(user, span_warning("[H.name] refuses to answer the heart."))
		to_chat(H, span_notice("You refuse Miluše's Heart."))
		return

	if(!src || !user || !H)
		return
	if(get_dist(user, H) > 1)
		to_chat(user, span_warning("Too far away."))
		return

	last_used = world.time

	var/cnt = eora_get_partner_count(H)
	var/list/names = eora_get_partner_names(H)

	to_chat(user, span_notice("Miluše's Whisper: [html_encode(H.name)] has <b>[cnt]</b> unique partner[cnt == 1 ? "" : "s"] this round."))
	if(names && names.len)
		to_chat(user, "<span class='info'>Names:</span>")
		for(var/N in names)
			to_chat(user, " • [html_encode(N)]")
	else
		to_chat(user, "<span class='info'>No names to show.</span>")

	to_chat(H, span_notice("Miluše's Heart answers [user.name]."))

	playsound(user, 'sound/magic/whiteflame.ogg', 50, FALSE)

/proc/eora_get_round_id(mob/living/carbon/human/H)
	if(!H) return null
	if(H.mind) return REF(H.mind)
	return REF(H)

/proc/eora_update_name(mob/living/carbon/human/H)
	if(!H) return
	var/id = eora_get_round_id(H)
	if(!id) return
	var/display = H.real_name ? H.real_name : H.name
	if(display && length(display))
		EORA_ID_NAME[id] = "[display]"

/proc/eora_lookup_name_by_id(id)
	if(!id) return "Unknown"

	if(islist(GLOB?.human_list))
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(eora_get_round_id(H) == id)
				return H.real_name ? H.real_name : H.name
	else
		for(var/mob/living/carbon/human/H in world)
			if(eora_get_round_id(H) == id)
				return H.real_name ? H.real_name : H.name

	if(EORA_ID_NAME[id])
		return "[EORA_ID_NAME[id]]"

	return "Unknown"

/proc/eora_register_consensual_pair(mob/living/carbon/human/A, mob/living/carbon/human/B)
	if(!A || !B) return
	if(!A.client || !B.client) return
	if(A == B) return

	var/idA = eora_get_round_id(A)
	var/idB = eora_get_round_id(B)
	if(!idA || !idB) return

	if(!EORA_PARTNERS_BY_ID[idA]) EORA_PARTNERS_BY_ID[idA] = list()
	if(!EORA_PARTNERS_BY_ID[idB]) EORA_PARTNERS_BY_ID[idB] = list()

	var/list/LA = EORA_PARTNERS_BY_ID[idA]
	var/list/LB = EORA_PARTNERS_BY_ID[idB]

	LA[idB] = TRUE
	LB[idA] = TRUE

	eora_update_name(A)
	eora_update_name(B)

/proc/eora_get_partner_count(mob/living/carbon/human/H)
	if(!H || !H.client) return 0
	var/id = eora_get_round_id(H)
	if(!id) return 0
	var/list/L = EORA_PARTNERS_BY_ID[id]
	if(!islist(L)) return 0
	var/c = 0
	for(var/_ in L) c++
	return c

/proc/eora_get_partner_names(mob/living/carbon/human/H)
	var/list/names = list()
	if(!H || !H.client) return names
	var/id = eora_get_round_id(H)
	if(!id) return names

	var/list/L = EORA_PARTNERS_BY_ID[id]
	if(!islist(L)) return names

	for(var/pid in L)
		var/n = eora_lookup_name_by_id(pid)
		if(n && !names.Find(n))
			names += n

	return sortList(names)
