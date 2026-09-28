// Emberwine (Ratwood): how players get the aphrodisiac wine. The reagent and its
// effects live in code/datums/sexcon/sexcon_reagents.dm.

// Alchemy: Ratwood makes emberwine at the cauldron. AP rebalanced which ingredient
// makes what, so only rosa takes Ratwood's mapping (its middle slot, which made
// antidote here - antidote still has eight other sources).
/datum/alch_cauldron_recipe/aphrodisiac
	name = "Aphrodisiac Wine"
	smells_like = "ardent sweetness"
	output_reagents = list(/datum/reagent/consumable/ethanol/beer/emberwine = 60)

/obj/item/alch/rosa
	med_pot = /datum/alch_cauldron_recipe/aphrodisiac

/obj/item/reagent_containers/glass/bottle/alchemical/emberwine
	list_reagents = list(/datum/reagent/consumable/ethanol/beer/emberwine = 5)
	desc = "A small vial labeled as containing emberwine, a potent aphrodisiac."

/obj/item/reagent_containers/glass/bottle/alchemical/emberwine/full
	list_reagents = list(/datum/reagent/consumable/ethanol/beer/emberwine = 30)

/obj/item/reagent_containers/glass/bottle/rogue/emberwine
	list_reagents = list(/datum/reagent/consumable/ethanol/beer/emberwine = 24)
	desc = "A bottle with an unmarked, tannin-tinted cork-seal. Zybantine red or another such cheap wine, in all likelihood."

// Bathhouse matron's drug order, as in Ratwood.
/datum/supply_pack/rogue/drugs/emberwine
	name = "Emberwine"
	cost = 80
	contains = list(/obj/item/reagent_containers/glass/bottle/rogue/emberwine)

// Ratwood's bandit medicaments pack; the wretch camp is this codebase's equivalent.
/datum/supply_pack/rogue/medical_supplies_wretch/emberwine
	name = "Emberwine"
	cost = 120
	contains = list(/obj/item/reagent_containers/glass/bottle/rogue/emberwine)

// Ratwood fetish kit bag.
/obj/item/storage/roguebag/fetish
	populate_contents = list(
		/obj/item/clothing/mask/rogue/blindfold,
		/obj/item/chastity/chastity_cage,
		/obj/item/chastity/chastity_belt,
		/obj/item/reagent_containers/glass/bottle/alchemical/emberwine,
		/obj/item/dildo/wood,
		/obj/item/natural/cloth,
		/obj/item/rope/chain,
		/obj/item/rogueweapon/whip,
		/obj/item/rogueweapon/surgery/cautery // Ratwood: crude branding iron (branding system not ported)
	)
