// ==========================================================================================
// SEXCON PORT - stubs for Ratwood-specific paths that don't exist in this codebase.
//
// The sexcon code was ported from Ratwood-2.0 and references several datums/types that are
// named differently or don't exist in this codebase's god-rename scheme. Rather than silently
// deleting every reference (which would silently disable features and make the port harder
// to diff against upstream), we define minimal stubs here so the code compiles and the logic
// remains intact. Where a Ratwood god was renamed (Xylix->Viator, Baotha->Hausvette), the stub
// re-routes to the equivalent. Where a status effect or stress event doesn't exist
// at all, the stub is a no-op so the feature is inert but the code paths are preserved for
// future porting.
// ==========================================================================================

// --- Missing charflaws ---------------------------------------------------------

/// Ratwood had a "malodorous" (bad smell) character flaw; this codebase doesn't. Stub so
/// has_flaw() returns FALSE (the type exists but no mob will ever have it assigned).
/datum/charflaw/malodorous
	name = "Malodorous (stub)"

// --- Missing status effects ----------------------------------------------------

// --- Missing stress events -----------------------------------------------------

// --- Missing confetti type (Xylix prank effect) --------------------------------

/obj/effect/decal/cleanable/confetti/xylix
	name = "confetti"
	desc = "A colorful scatter of confetti made of dyed parchment. It smells funny."
	icon = 'icons/effects/confetti.dmi'
	mouse_opacity = MOUSE_OPACITY_ICON
	random_icon_states = list("confetti1", "confetti2", "confetti3")

// --- Missing stress events (additional) ---------------------------------------

/datum/stressevent/thrill

// --- Missing proc: start_sex_session -------------------------------------------

/// Ratwood callers open the intimacy panel, which is Twilight's system.
/mob/living/proc/start_sex_session(mob/living/carbon/human/target)
	return start_erp_session(target)


/// Ratwood tracks knotting stats separately for lupians vs non-lupians. this codebase doesn't
/// distinguish, so this just aliases the existing STATS_KNOTTED counter.
#define STATS_KNOTTED_NOT_LUPIANS STATS_KNOTTED

// --- Missing mob vars ----------------------------------------------------------

// Ratwood tracks whether a mob was scented by a gnoll this round. this codebase has no gnolls,
// so this is a no-op var that lives on /mob/living/carbon/human and is always FALSE.
/mob/living/carbon/human
	/// Ported from Ratwood: tracks gnoll scent exposure for sexcon stinky_contact logic. Always FALSE here (no gnolls).
	var/has_gnoll_scent_this_round = FALSE

// --- Missing item var ---------------------------------------------------------

// Ratwood's bellsound var on /obj/item marks jingle-bell collars (the Twilight bell collars set it).
/obj/item
	/// TRUE if this item jingles when moved (bell collar).
	var/bellsound = FALSE

// --- Missing procs -------------------------------------------------------------

// --- Patron path aliases -------------------------------------------------------
// this codebase renamed Xylix -> Viator (under /datum/patron/concordat/) and Baotha -> Hausvette.
// The sexcon code references the old paths directly. Rather than editing every call site
// (and breaking the diff against upstream), we define type aliases that point to the new patrons.

/// this codebase's Viator patron is the renamed Xylix. This alias lets sexcon's Xylix-specific
/// prank logic compile and resolve to the right patron.
/datum/patron/divine/xylix
	parent_type = /datum/patron/concordat/viator

/// this codebase's Hausvette patron is the renamed Baotha. This alias lets sexcon's
/// Baotha-specific emberwine/knotting logic compile and resolve to the right patron.
/datum/patron/inhumen/baotha
	parent_type = /datum/patron/oldkin/hausvette

/datum/patron/divine/eora
	parent_type = /datum/patron/concordat/miluse

#define COMSIG_CARBON_LOSE_CHASTITY "carbon_lose_chastity"

// ============== Ratwood sexcon sync (2026-09) ==============
// Things the current Ratwood sexcon expects from Ratwood's core code.

/// Ratwood declares lock vars on every /obj; here doors/closets/keys declare their
/// own, so only the chastity device gets them.
/obj/item/chastity
	var/lockid
	var/lockhash
	var/locked

/// Ratwood keeps permanent addictions on reagents (used by emberwine).
/datum/reagent
	var/addiction_permanent = 0

/mob/living/proc/get_blood_volume()
	return blood_volume

/mob/living/proc/set_blood_volume(amount)
	blood_volume = amount



// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/status_effect/debuff/false_sensation
	id = "false_sensation"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/false_sensation
	effectedstats = null
	duration = 2 MINUTES
	status_type = STATUS_EFFECT_REFRESH

/atom/movable/screen/alert/status_effect/debuff/false_sensation
	name = "False Sensation"
	desc = "My body is aflame, but it's not real. Only a real touch of passion will sate my urges."
	icon_state = "debuff"

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/obj/effect/temp_visual/heart/sex_effects/invisible
	icon_state = null

/obj/effect/temp_visual/heart/sex_effects/invisible/Initialize(mapload, mob/seers, custom_state = "redheart")
	. = ..()
	layer = prob(50) ? ABOVE_MOB_LAYER : BELOW_MOB_LAYER
	var/image/I = image(icon = 'icons/effects/erpeffects.dmi', icon_state = custom_state, layer = layer, loc = src)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/People, "erp_effect", I, seers)
	I.alpha = 255
	I.appearance_flags = RESET_ALPHA
	I.pixel_x = rand(-10, 10)
	I.pixel_y = rand(-10, 10)
	animate(I, pixel_x = I.pixel_x + rand(-5, 5), pixel_y = I.pixel_y + rand(28, 40), alpha = 0, time = duration)

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/stressevent/blue_balls
	timer = 1 MINUTES
	stressadd = 2
	desc = "<span class='red'>I'm pent up and can't find release.</span>"

/datum/stressevent/cumok
	timer = 15 MINUTES
	stressadd = -2
	desc = "<span class='green'>I came.</span>"

/datum/stressevent/cummax
	timer = 30 MINUTES
	stressadd = -4
	desc = "<span class='green'>I came, and it was incredible.</span>"

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/stressevent/unseemly_made_love
	stressadd = 3
	desc = span_red("That ugly fiend... Touched me!")
	timer = 30 MINUTES

/datum/stressevent/unseemly_made_love/beautiful
	desc = span_red("That ugly thing... RUINED me!")
	timer = 45 MINUTES

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/status_effect/debuff/emberwine
	id = "emberwine"
	effectedstats = list("strength" = -1, "willpower" = -2, "speed" = -2, "intelligence" = -3)
	duration = 1 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/emberwine

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/status_effect/buff/cum_consumed
	id = "cum_consumed"
	alert_type = /atom/movable/screen/alert/status_effect/buff/cum_consumed
	duration = 10 MINUTES

/datum/status_effect/buff/cum_consumed/on_apply()
	. = ..()
	if(owner.has_flaw(/datum/charflaw/addiction/lovefiend))
		owner.add_stress(/datum/stressevent/cumconsumed)

/datum/status_effect/buff/cum_consumed/on_remove()
	if(owner.has_flaw(/datum/charflaw/addiction/lovefiend))
		owner.remove_stress(/datum/stressevent/cumconsumed)
	. = ..()

/atom/movable/screen/alert/status_effect/buff/cum_consumed
	name = "Cumdrunk"
	desc = "I've swallowed someone's load..."
	icon_state = "drunk"

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/charflaw/addiction/baothamarked
	name = "Forbidden Marked"
	desc = "I've been branded by a Forbidden mark."
	time = 45 MINUTES
	needsate_text = "My brand burns painfully."
	sated_text = "The brand's glow lessens, relief washing over me..."
	debuff = /datum/status_effect/debuff/addiction/baothamarked

/datum/status_effect/debuff/addiction/baothamarked
	id = "addiction_baothamark"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/addiction/baothamarked
	effectedstats = list(STATKEY_CON = -1, STATKEY_WIL = -1)

/atom/movable/screen/alert/status_effect/debuff/addiction/baothamarked
	name = "Forbidden Mania"
	desc = "That accursed rune. It burns brightly across my flesh, searing my loins with a painful desire for release."
	icon_state = "nymphomaniac"


// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/stressevent/cumconsumed
	timer = 10 MINUTES
	stressadd = -2
	desc = "<span class='green'>The taste of cum has sated my desire.</span>"

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/stressevent/chastity_devout
	timer = INFINITY
	stressadd = -1
	desc = span_green("This restraint steadies my spirit.")

/datum/stressevent/chastity_masochist
	timer = INFINITY
	stressadd = -1
	desc = span_green("The spikes keep me pleasantly focused.")

/datum/stressevent/chastity_church
	timer = INFINITY
	stressadd = -1
	desc = span_green("My vows feel stronger in this restraint.")

// Restored from ratwood-2.0/main during 2026-09 mainstream merge

/datum/stressevent/chastity_frustration
	timer = INFINITY
	stressadd = 1
	desc = span_red("This restraint is maddening.")

/datum/stressevent/chastity_flat_cramped
	timer = INFINITY
	stressadd = 1
	desc = span_red("This cage is too cramped for me.")
