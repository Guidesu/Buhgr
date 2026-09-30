// The domains of Palimpseste. Miracle lists are drawn from the miracles the
// known gods already grant, regrouped by what they're about.

/datum/domain/sun
	name = "Sun"
	desc = "Light, fire, dawn and the right to rule. Sun gods are kings' gods: they are praised in daylight, sworn by in court, and called on to burn what hides from them."
	icon = "sun"
	gods = list(/datum/patron/concordat/auxentius, /datum/patron/severance/ignatius, /datum/patron/divine/astrata)
	pray_hint = "a lit fire, lamp or candle"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
		/datum/action/cooldown/spell/miracle/ignition/auxentius		= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal					= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
		/datum/action/cooldown/spell/auxentius/auxentian_gaze		= CLERIC_T1,
		/datum/action/cooldown/spell/ignatius_expansion/ember_touch	= CLERIC_T1,
		/datum/action/cooldown/spell/projectile/sacred_flame		= CLERIC_T2,
		/datum/action/cooldown/spell/miracle/fortify/auxentius		= CLERIC_T2,
		/datum/action/cooldown/spell/auxentius/miracle_pyre			= CLERIC_T3,
		/datum/action/cooldown/spell/auxentius/firecloak			= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/revive				= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/immolation			= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/auxentius	= CLERIC_T4,
	)

/datum/domain/sun/is_sacred_here(mob/living/follower)
	return near_fire(follower, 3)

/datum/domain/law
	name = "Law"
	desc = "Oaths, judgment, truth and the order that holds a people together. Law gods keep the scales; their priests bind contracts, hear testimony and pass sentence."
	icon = "scale-balanced"
	gods = list(/datum/patron/tribunal/praecursor, /datum/patron/tribunal/custodius, /datum/patron/tribunal/verita, /datum/patron/concordat/auxentius, /datum/patron/severance/kamenka, /datum/patron/divine/astrata, /datum/patron/divine/ravox)
	pray_hint = "a throne, or with a written contract or law in hand"
	traits_tier = list(TRAIT_JUSTICARSIGHT = CLERIC_T2)
	miracles = list(
		/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/diagnose					= CLERIC_ORI,
		/datum/action/cooldown/spell/undivided/recuperation				= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal/undivided				= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
		/datum/action/cooldown/spell/undivided/twinned_gaze				= CLERIC_T1,
		/datum/action/cooldown/spell/praecursor/endure					= CLERIC_T1,
		/datum/action/cooldown/spell/verita/zone_of_truth				= CLERIC_T2,
		/datum/action/cooldown/spell/custodius_expansion/oathbind		= CLERIC_T2,
		/datum/action/cooldown/spell/verita/binding_contract			= CLERIC_T3,
		/datum/action/cooldown/spell/praecursor_expansion/edict			= CLERIC_T3,
		/datum/action/cooldown/spell/miracle/fortify/undivided			= CLERIC_T3,
		/datum/action/cooldown/spell/verita/final_verdict				= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/undivided		= CLERIC_T4,
	)

/datum/domain/law/is_sacred_here(mob/living/follower)
	for(var/obj/structure/roguethrone/T in view(3, get_turf(follower)))
		return TRUE
	return follower.is_holding_item_of_type(/obj/item/paper)

/datum/domain/war
	name = "War"
	desc = "Battle, courage, sacrifice and the shield-wall. War gods are prayed to before every fight and blamed after it; they favour the bold and the ones who stand their ground."
	icon = "shield-halved"
	gods = list(/datum/patron/concordat/wulfric, /datum/patron/concordat/auxentius, /datum/patron/oldkin/volkovoi, /datum/patron/tribunal/custodius, /datum/patron/divine/ravox, /datum/patron/inhumen/graggar)
	pray_hint = "with a weapon in hand"
	traits_tier = list(TRAIT_BATTLEMASTER = CLERIC_T1)
	miracles = list(
		/datum/action/cooldown/spell/touch/orison							= CLERIC_ORI,
		/datum/action/cooldown/spell/auxentius/battle/tug					= CLERIC_T0,
		/datum/action/cooldown/spell/auxentius/battle/provocation			= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal							= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle					= CLERIC_T1,
		/datum/action/cooldown/spell/auxentius/battle/strikeoraegis			= CLERIC_T1,
		/datum/action/cooldown/spell/graggar/hamstring						= CLERIC_T1,
		/datum/action/cooldown/spell/auxentius/battle/withstand				= CLERIC_T2,
		/datum/action/cooldown/spell/auxentius/battle/challenge				= CLERIC_T2,
		/datum/action/cooldown/spell/auxentius/battle/persistence			= CLERIC_T3,
		/datum/action/cooldown/spell/auxentius/battle/battlecry				= CLERIC_T3,
		/datum/action/cooldown/spell/wulfric_expansion/sacrificial_strike	= CLERIC_T3,
		/datum/action/cooldown/spell/undivided/undivided_battlecry			= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/ravox				= CLERIC_T4,
	)

/datum/domain/war/is_sacred_here(mob/living/follower)
	return follower.is_holding_item_of_type(/obj/item/rogueweapon)

/datum/domain/hearth
	name = "Hearth"
	desc = "Home, family, hospitality and the fire that keeps the dark out. Hearth gods live in kitchens and doorways; they are thanked for every meal and every safe night."
	icon = "house"
	gods = list(/datum/patron/concordat/wulfric, /datum/patron/oldkin/hausvette, /datum/patron/divine/eora)
	pray_hint = "a hearth or firebowl"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison								= CLERIC_ORI,
		/datum/action/cooldown/spell/undivided/recuperation						= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal								= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle						= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/bless_food						= CLERIC_T1,
		/datum/action/cooldown/spell/summon_bed									= CLERIC_T1,
		/datum/action/cooldown/spell/wulfric_expansion/hearthfire_aura			= CLERIC_T2,
		/datum/action/cooldown/spell/hausvette_expansion/communitys_shield		= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/painkiller						= CLERIC_T3,
		/datum/action/cooldown/spell/miracle/fortify							= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/resurrect/malum					= CLERIC_T4,
	)

/datum/domain/hearth/is_sacred_here(mob/living/follower)
	for(var/obj/machinery/light/rogue/hearth/H in view(3, get_turf(follower)))
		return TRUE
	for(var/obj/machinery/light/rogue/firebowl/F in view(2, get_turf(follower)))
		return TRUE
	return FALSE

/datum/domain/harvest
	name = "Harvest"
	desc = "Fields, seasons, plenty and the labour that earns it. Harvest gods are the oldest in most villages; they are paid in the first sheaf and feared in a bad year."
	icon = "wheat-awn"
	gods = list(/datum/patron/oldkin/hausvette, /datum/patron/severance/ignatius, /datum/patron/concordat/miluse, /datum/patron/divine/dendor)
	pray_hint = "tilled soil or a crop"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison								= CLERIC_ORI,
		/obj/effect/proc_holder/spell/targeted/blesscrop						= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal								= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle						= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/bud								= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/bless_food						= CLERIC_T1,
		/datum/action/cooldown/spell/hausvette_expansion/harvest_blessing		= CLERIC_T2,
		/obj/effect/proc_holder/spell/targeted/conjure_vines					= CLERIC_T3,
		/datum/action/cooldown/spell/ignatius_expansion/wild_growth				= CLERIC_T3,
		/datum/action/cooldown/spell/trnava/wild_regrowth						= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/root_affinity						= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/ignatius				= CLERIC_T4,
	)

/datum/domain/harvest/is_sacred_here(mob/living/follower)
	for(var/obj/structure/soil/S in view(2, get_turf(follower)))
		return TRUE
	return FALSE

/datum/domain/death
	name = "Death"
	desc = "The end, the grave, memory and what is owed to the dead. Death gods are not cruel; they keep the ledger closed. Their priests bury, remember and turn back what should stay down."
	icon = "skull"
	gods = list(/datum/patron/concordat/morwenna, /datum/patron/oldkin/klokner, /datum/patron/unveiled/aurelian, /datum/patron/divine/necra, /datum/patron/old_god)
	pray_hint = "a grave, an open grave or a corpse"
	traits_tier = list(TRAIT_DEATHSIGHT = CLERIC_T0)
	miracles = list(
		/datum/action/cooldown/spell/touch/orison							= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/necras_sight					= CLERIC_T0,
		/obj/effect/proc_holder/spell/self/locate_dead						= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal							= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle					= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/avert							= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/fog_ward						= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance		= CLERIC_T2,
		/datum/action/cooldown/spell/miracle/necra_consecrate				= CLERIC_T2,
		/obj/effect/proc_holder/spell/invoked/bless_cross					= CLERIC_T3,
		/datum/action/cooldown/spell/klokner/echoing_dark					= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/deaths_door					= CLERIC_T4,
		/datum/action/cooldown/spell/klokner/banish_beyond					= CLERIC_T4,
	)

/datum/domain/death/is_sacred_here(mob/living/follower)
	var/turf/T = get_turf(follower)
	for(var/obj/structure/gravemarker/G in view(3, T))
		return TRUE
	for(var/obj/structure/closet/dirthole/D in view(2, T))
		return TRUE
	for(var/mob/living/carbon/human/corpse in view(2, T))
		if(corpse.stat == DEAD)
			return TRUE
	return FALSE

/datum/domain/sea
	name = "Sea"
	desc = "Deep water, storms, sailors and drowned things. Sea gods are bargained with, never trusted; they give fish and passage and take ships when it suits them."
	icon = "water"
	gods = list(/datum/patron/concordat/wulfric, /datum/patron/concordat/miluse, /datum/patron/divine/abyssor)
	pray_hint = "water"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/aquatic_compulsion		= CLERIC_T0,
		/obj/effect/proc_holder/spell/self/abyssor_wind					= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal						= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/abyssor_bends				= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/abyssor_undertow			= CLERIC_T2,
		/obj/effect/proc_holder/spell/invoked/abyssheal					= CLERIC_T2,
		/obj/effect/proc_holder/spell/invoked/call_mossback				= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/call_dreamfiend			= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/abyssal_infusion			= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/abyssor			= CLERIC_T4,
	)

/datum/domain/sea/is_sacred_here(mob/living/follower)
	for(var/turf/open/water/W in view(2, get_turf(follower)))
		return TRUE
	return FALSE

/datum/domain/moon
	name = "Moon"
	desc = "Night, dreams, secrets, tides and witchcraft. Moon gods keep what is hidden; they are prayed to by witches, lovers, thieves and anyone who works while others sleep."
	icon = "moon"
	gods = list(/datum/patron/concordat/miluse, /datum/patron/oldkin/klokner, /datum/patron/divine/noc)
	pray_hint = "a mirror, or candlelight at night"
	traits_tier = list(TRAIT_DARKVISION = CLERIC_T1)
	miracles = list(
		/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
		/datum/action/cooldown/spell/noc/nitevision						= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal						= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
		/datum/action/cooldown/spell/noc/enlightenment					= CLERIC_T1,
		/datum/action/cooldown/spell/projectile/moonscorch				= CLERIC_T2,
		/datum/action/cooldown/spell/noc/invisibility					= CLERIC_T2,
		/datum/action/cooldown/spell/noc/spellpack						= CLERIC_T3,
		/datum/action/cooldown/spell/noc/moonlight						= CLERIC_T4,
		/obj/effect/proc_holder/spell/self/howl/call_of_the_moon		= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/noc				= CLERIC_T4,
	)

/datum/domain/moon/is_sacred_here(mob/living/follower)
	for(var/obj/structure/mirror/M in view(2, get_turf(follower)))
		return TRUE
	return (GLOB.tod == "night" || GLOB.tod == "dusk") && near_fire(follower, 2)

/datum/domain/love
	name = "Love"
	desc = "Desire, beauty, devotion and heartbreak. Love gods are the most prayed to and the least predictable; they bind people together and make fools of them."
	icon = "heart"
	gods = list(/datum/patron/concordat/miluse, /datum/patron/oldkin/hausvette, /datum/patron/divine/eora, /datum/patron/inhumen/baotha)
	pray_hint = "beside someone you hold dear"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/eora_blessing				= CLERIC_T0,
		/datum/action/cooldown/spell/baotha/emotional_sway				= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal						= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/heart_on_sleeve			= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/griefflower				= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/heartweave				= CLERIC_T2,
		/obj/effect/proc_holder/spell/invoked/eoracurse					= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/pomegranate				= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/baotha			= CLERIC_T4,
	)

/datum/domain/love/is_sacred_here(mob/living/follower)
	for(var/mob/living/carbon/human/other in view(1, get_turf(follower)))
		if(other != follower && other.stat == CONSCIOUS && other.client)
			return TRUE
	return FALSE

/datum/domain/trickery
	name = "Trickery"
	desc = "Luck, lies, jests and the crossroads. Trickster gods break the rules the other gods keep; they are thanked for narrow escapes and cursed for everything else."
	icon = "masks-theater"
	gods = list(/datum/patron/concordat/viator, /datum/patron/oldkin/klokner, /datum/patron/divine/xylix, /datum/patron/inhumen/matthios)
	pray_hint = "a crossroads, or with cards in hand"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison							= CLERIC_ORI,
		/obj/effect/proc_holder/spell/self/xylixslip						= CLERIC_T0,
		/obj/effect/proc_holder/spell/invoked/ventriloquism					= CLERIC_T0,
		/obj/effect/proc_holder/spell/invoked/mimicry						= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal							= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle					= CLERIC_T1,
		/datum/action/cooldown/spell/projectile/vicious_mockery				= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/vendetta						= CLERIC_T2,
		/obj/effect/proc_holder/spell/invoked/mastersillusion				= CLERIC_T2,
		/obj/effect/proc_holder/spell/targeted/touch/parlor_trick			= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/abscond						= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/xylix				= CLERIC_T4,
	)

/datum/domain/trickery/is_sacred_here(mob/living/follower)
	if(follower.is_holding_item_of_type(/obj/item/toy/cards))
		return TRUE
	var/roads = 0
	for(var/turf/open/floor/rogue/dirt/road/R in range(1, get_turf(follower)))
		roads++
	return roads >= 5

/datum/domain/trade
	name = "Trade"
	desc = "Coin, roads, bargains and debts. Trade gods keep accounts; they bless fair deals, punish broken ones and remember what everyone owes."
	icon = "coins"
	gods = list(/datum/patron/concordat/viator, /datum/patron/concordat/morwenna, /datum/patron/inhumen/matthios)
	pray_hint = "with coin in hand"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison								= CLERIC_ORI,
		/datum/action/cooldown/spell/matthios/freemans_tools					= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal								= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle						= CLERIC_T1,
		/datum/action/cooldown/spell/matthios/mammonite							= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/tipscales							= CLERIC_T1,
		/datum/action/cooldown/spell/matthios/transact							= CLERIC_T2,
		/datum/action/cooldown/spell/matthios/barter							= CLERIC_T2,
		/datum/action/cooldown/spell/viator_expansion/roadwardens_step			= CLERIC_T2,
		/datum/action/cooldown/spell/matthios/equalize							= CLERIC_T3,
		/datum/action/cooldown/spell/viator_expansion/fortunes_favor			= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/resurrect/matthios				= CLERIC_T3,
		/datum/action/cooldown/spell/matthios/churn								= CLERIC_T4,
	)

/datum/domain/trade/is_sacred_here(mob/living/follower)
	return follower.is_holding_item_of_type(/obj/item/roguecoin)

/datum/domain/craft
	name = "Craft"
	desc = "The forge, the chisel, stone and patient work. Craft gods are the gods of makers; they are prayed to at the anvil and honoured in every well-made thing."
	icon = "hammer"
	gods = list(/datum/patron/concordat/handwerra, /datum/patron/severance/kamenka, /datum/patron/divine/malum)
	pray_hint = "an anvil"
	traits_tier = list(TRAIT_FORGEBLESSED = CLERIC_T1)
	miracles = list(
		/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
		/datum/action/cooldown/spell/miracle/ignition/malum				= CLERIC_T0,
		/datum/action/cooldown/spell/malum/reconstruction				= CLERIC_T0,
		/datum/action/cooldown/spell/kamenka/stones_patience			= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal						= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
		/datum/action/cooldown/spell/malum/vigorousexchange				= CLERIC_T1,
		/datum/action/cooldown/spell/arcyne_forge/miracle				= CLERIC_T1,
		/datum/action/cooldown/spell/kamenka/preserve					= CLERIC_T1,
		/datum/action/cooldown/spell/malum/hammerfall					= CLERIC_T2,
		/datum/action/cooldown/spell/mending/malum						= CLERIC_T2,
		/datum/action/cooldown/spell/malum/heatmetal					= CLERIC_T3,
		/datum/action/cooldown/spell/malum_blessing						= CLERIC_T3,
		/datum/action/cooldown/spell/kamenka/petrify					= CLERIC_T3,
		/datum/action/cooldown/spell/malum/fortress						= CLERIC_T4,
		/datum/action/cooldown/spell/kamenka/monument					= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/malum			= CLERIC_T4,
	)

/datum/domain/craft/is_sacred_here(mob/living/follower)
	for(var/obj/machinery/anvil/A in view(2, get_turf(follower)))
		return TRUE
	return FALSE

/datum/domain/knowledge
	name = "Knowledge"
	desc = "Learning, truth, memory and forbidden questions. Knowledge gods reward the curious and sometimes punish them; their faithful keep libraries, archives and secrets."
	icon = "book-open"
	gods = list(/datum/patron/concordat/handwerra, /datum/patron/tribunal/verita, /datum/patron/concordat/miluse, /datum/patron/unveiled/aurelian, /datum/patron/divine/noc, /datum/patron/old_god, /datum/patron/inhumen/zizo)
	pray_hint = "a bookcase, or with a book in hand"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/diagnose					= CLERIC_ORI,
		/datum/action/cooldown/spell/miracle/heal						= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
		/datum/action/cooldown/spell/noc/enlightenment					= CLERIC_T1,
		/datum/action/cooldown/spell/undivided/twinned_gaze				= CLERIC_T1,
		/datum/action/cooldown/spell/verita/zone_of_truth				= CLERIC_T2,
		/datum/action/cooldown/spell/undivided/undivided_spellpack		= CLERIC_T2,
		/datum/action/cooldown/spell/noc/spellpack						= CLERIC_T3,
		/datum/action/cooldown/spell/klokner/lost_and_found				= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/resurrect/noc				= CLERIC_T4,
	)

/datum/domain/knowledge/is_sacred_here(mob/living/follower)
	for(var/obj/structure/bookcase/B in view(2, get_turf(follower)))
		return TRUE
	return follower.is_holding_item_of_type(/obj/item/book)

/datum/domain/healing
	name = "Healing"
	desc = "Medicine, mercy, poison and cure. Healing gods know the two are the same thing in different doses; their faithful are the physicians and herbwives of every village."
	icon = "staff-snake"
	gods = list(/datum/patron/concordat/handwerra, /datum/patron/oldkin/trnava, /datum/patron/divine/pestra, /datum/patron/old_god)
	pray_hint = "beside someone hurt"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/diagnose					= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/pestra_leech				= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal						= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/pestra_heal				= CLERIC_T2,
		/obj/effect/proc_holder/spell/invoked/attach_bodypart			= CLERIC_T2,
		/obj/effect/proc_holder/spell/invoked/cure_rot					= CLERIC_T3,
		/datum/action/cooldown/spell/trnava/poison_ward					= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/painkiller				= CLERIC_T3,
		/datum/action/cooldown/spell/trnava/wild_regrowth				= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/pestra			= CLERIC_T4,
	)

/datum/domain/healing/is_sacred_here(mob/living/follower)
	for(var/mob/living/carbon/human/patient in view(1, get_turf(follower)))
		if(patient != follower && patient.health < patient.maxHealth * 0.75)
			return TRUE
	return FALSE

/datum/domain/wilds
	name = "Wilds"
	desc = "Forests, beasts, winter and the hunt. Wild gods do not care for walls; they are prayed to by hunters, herders and anyone lost among the trees."
	icon = "paw"
	gods = list(/datum/patron/oldkin/trnava, /datum/patron/severance/ignatius, /datum/patron/oldkin/volkovoi, /datum/patron/divine/dendor, /datum/patron/inhumen/graggar)
	pray_hint = "among trees"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison								= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/spiderspeak						= CLERIC_T0,
		/datum/action/cooldown/spell/graggar/rush								= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal								= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle						= CLERIC_T1,
		/datum/action/cooldown/spell/graggar/hamstring							= CLERIC_T1,
		/obj/effect/proc_holder/spell/invoked/infestation						= CLERIC_T1,
		/datum/action/cooldown/spell/trnava/thorn_burst							= CLERIC_T2,
		/obj/effect/proc_holder/spell/self/wildshape							= CLERIC_T2,
		/datum/action/cooldown/spell/volkovoi_expansion/winters_bite			= CLERIC_T2,
		/datum/action/cooldown/spell/trnava/mothers_wrath						= CLERIC_T3,
		/datum/action/cooldown/spell/volkovoi_expansion/hungers_call			= CLERIC_T3,
		/obj/effect/proc_holder/spell/self/howl/call_of_the_moon				= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/graggar					= CLERIC_T4,
	)

/datum/domain/wilds/is_sacred_here(mob/living/follower)
	var/trees = 0
	for(var/obj/structure/flora/roguetree/T in view(3, get_turf(follower)))
		if(++trees >= 3)
			return TRUE
	return FALSE

/datum/domain/forbidden
	name = "Forbidden"
	desc = "Undeath, hubris and the magic the other gods forbid. Forbidden gods promise more than any other and ask the most; their faithful are hunted everywhere, and some of them deserve it."
	icon = "book-skull"
	gods = list(/datum/patron/unveiled/aurelian, /datum/patron/inhumen/zizo, /datum/patron/inhumen/baotha)
	pray_hint = "darkness"
	miracles = list(
		/datum/action/cooldown/spell/touch/orison								= CLERIC_ORI,
		/datum/action/cooldown/spell/zizo/snuff_lights							= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal								= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle						= CLERIC_T1,
		/datum/action/cooldown/spell/projectile/zizo/profane					= CLERIC_T1,
		/datum/action/cooldown/spell/conjure_summon/zizo/skeleton_swarm			= CLERIC_T2,
		/datum/action/cooldown/spell/zizo/bone_cataclysm						= CLERIC_T2,
		/datum/action/cooldown/spell/aurelian_expansion/grave_bolt				= CLERIC_T2,
		/datum/action/cooldown/spell/tame_undead/zizo							= CLERIC_T3,
		/datum/action/cooldown/spell/zizo/rituos								= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/resurrect/zizo					= CLERIC_T3,
		/datum/action/cooldown/spell/lacrima/zizo								= CLERIC_T4,
		/datum/action/cooldown/spell/aurelian_expansion/unmake					= CLERIC_T4,
	)

/datum/domain/forbidden/is_sacred_here(mob/living/follower)
	var/turf/T = get_turf(follower)
	return T && T.get_lumcount() < 0.2
