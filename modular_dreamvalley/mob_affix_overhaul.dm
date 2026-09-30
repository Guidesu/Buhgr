// Mob modifiers (Giant, Vampiric, Blessed...) you can see and feel.
//
// Every modifier now glows in its colour and wears an effect of its own; auras,
// drains and pulses show on whoever they touch, with floating numbers; several
// modifiers that only nudged a stat now do something; and examining a mob lists
// each modifier, what it does and what it changes.

#define AFFIX_FX 'icons/effects/prayer_fx.dmi'

/datum/mob_affix
	/// Effect worn on the mob (prayer_fx state), tinted with `color`.
	var/fx_state
	/// Burst shown on anyone this modifier's aura or drain touches.
	var/hit_state
	/// What it does, in plain words, for examine. Falls back to `description`.
	var/examine_text
	var/mutable_appearance/fx_overlay

/datum/mob_affix/apply(mob/living/M, tier = 1)
	. = ..()
	M.add_filter("affix_[type]", 3, list("type" = "outline", "color" = color, "size" = 1, "alpha" = 80))
	if(fx_state)
		fx_overlay = mutable_appearance(AFFIX_FX, fx_state, ABOVE_MOB_LAYER)
		fx_overlay.color = color
		fx_overlay.alpha = 160
		fx_overlay.appearance_flags = RESET_COLOR | KEEP_APART
		M.add_overlay(fx_overlay)

/datum/mob_affix/remove(mob/living/M)
	M.remove_filter("affix_[type]")
	if(fx_overlay)
		M.cut_overlay(fx_overlay)
		fx_overlay = null
	return ..()

/// Floating number or word over a mob, in the modifier's colour.
/datum/mob_affix/proc/affix_float(mob/living/L, text)
	prayer_word(L, text, color, 7)

/datum/mob_affix/proc/affix_hit(mob/living/L)
	if(hit_state)
		prayer_burst(L, hit_state, color)

/datum/mob_affix/aura_damage(range, brute = 0, fire = 0, tox = 0)
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	var/hit_any = FALSE
	for(var/mob/living/L in view(range, parent_mob))
		if(L == parent_mob || L.stat == DEAD)
			continue
		if(faction_check(parent_mob.faction, L.faction))
			continue
		if(brute)
			L.adjustBruteLoss(brute)
		if(fire)
			L.adjustFireLoss(fire)
		if(tox)
			L.adjustToxLoss(tox)
		affix_hit(L)
		var/total = max(0, brute) + max(0, fire) + max(0, tox)
		if(total)
			affix_float(L, "-[total]")
		hit_any = TRUE
	if(hit_any)
		prayer_burst(parent_mob, "shockwave", color)

/datum/mob_affix/leech_nearby(range, damage = 3, heal = 3)
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	var/list/targets = list()
	for(var/mob/living/L in view(range, parent_mob))
		if(L == parent_mob || L.stat == DEAD)
			continue
		if(faction_check(parent_mob.faction, L.faction))
			continue
		targets += L
	if(!length(targets))
		return
	var/mob/living/T = pick(targets)
	T.adjustBruteLoss(damage)
	affix_hit(T)
	affix_float(T, "-[damage]")
	T.Beam(parent_mob, icon_state = "drain_life", time = 6, maxdistance = range + 2)
	if(heal)
		parent_mob.adjustBruteLoss(-heal)
		parent_mob.adjustFireLoss(-heal)
		affix_float(parent_mob, "+[heal]")

/// A plain summary of the stat changes, for examine.
/datum/mob_affix/proc/stat_summary()
	var/static/list/stat_names = list(
		MA_STAT_STR = "STR", MA_STAT_PER = "PER", MA_STAT_INT = "INT", MA_STAT_CON = "CON",
		MA_STAT_WIL = "WIL", MA_STAT_SPD = "SPD", MA_STAT_LUC = "FOR",
	)
	var/list/parts = list()
	for(var/stat in stat_mods)
		var/v = stat_mods[stat]
		parts += "[stat_names[stat] || stat] [v > 0 ? "+" : ""][v]"
	return jointext(parts, ", ")

/mob/living/proc/affix_examine_lines()
	. = list()
	for(var/datum/mob_affix/A as anything in mob_affixes)
		if(!length(A.name))
			continue
		var/stats = A.stat_summary()
		. += "<span style='color:[A.color]'><b>[A.name]</b></span> - [A.examine_text || A.description][stats ? " <span style='color:#a89a86'>([stats])</span>" : ""]"

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	var/list/lines = affix_examine_lines()
	if(length(lines))
		. += span_info("<b>It bears marks of something more:</b><br>[jointext(lines, "<br>")]")

/mob/living/simple_animal/examine(mob/user)
	. = ..()
	var/list/lines = affix_examine_lines()
	if(length(lines))
		. += span_info("<b>It bears marks of something more:</b><br>[jointext(lines, "<br>")]")

// --- Per-modifier look and behaviour --------------------------------------------------------

/datum/mob_affix/berserker
	fx_state = "embers"
	examine_text = "Hits harder and closes in faster, but its body is less resilient."
/datum/mob_affix/regenerative
	fx_state = "motes"
	examine_text = "Knits its wounds shut every few seconds."
/datum/mob_affix/regenerative/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	if(parent_mob.getBruteLoss() + parent_mob.getFireLoss() <= 0)
		return
	parent_mob.adjustBruteLoss(-4)
	parent_mob.adjustFireLoss(-3)
	affix_float(parent_mob, "+7")
	prayer_burst(parent_mob, "motes", color)

/datum/mob_affix/radioactive
	fx_state = "motes"
	hit_state = "bubble_ring"
	examine_text = "Pulses sickness into everyone nearby every few seconds."
/datum/mob_affix/explosive
	fx_state = "embers"
	examine_text = "Bursts in a blast when it dies. Don't be close."
/datum/mob_affix/explosive/on_death(mob/living/M)
	prayer_burst(M, "big:sunburst", color)
	return ..()
/datum/mob_affix/venomous
	fx_state = "bubble_ring"
	hit_state = "bubble_ring"
	examine_text = "Seeps poison into anything that stands beside it."
/datum/mob_affix/swift
	fx_state = "feathers"
	examine_text = "Moves and strikes quicker than it should."
/datum/mob_affix/armored
	fx_state = "shield_dome"
	examine_text = "Takes much more punishment to bring down."
/datum/mob_affix/weak
	examine_text = "Frail and feeble; easier to kill."
/datum/mob_affix/fiery
	fx_state = "flame_wisp"
	hit_state = "flame_wisp"
	examine_text = "Burns everything close to it."
/datum/mob_affix/frostbound
	fx_state = "frost"
	hit_state = "frost"
	examine_text = "Its cold bruises and numbs those near it, and slows them."
/datum/mob_affix/frostbound/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	aura_damage(2, 3, 0, 0)
	for(var/mob/living/L in view(2, parent_mob))
		if(L != parent_mob && !faction_check(parent_mob.faction, L.faction))
			L.adjust_bodytemperature(-15)
			L.apply_status_effect(/datum/status_effect/buff/prayer_boon/bane, 4 SECONDS, list(STATKEY_SPD = -1))
/datum/mob_affix/shocking
	fx_state = "sparkle"
	examine_text = "Lightning leaps from it to those nearby."
/datum/mob_affix/shocking/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	for(var/mob/living/L in view(2, parent_mob))
		if(L == parent_mob || L.stat == DEAD || faction_check(parent_mob.faction, L.faction))
			continue
		L.electrocute_act(5, parent_mob)
		parent_mob.Beam(L, icon_state = "lightning[rand(1, 12)]", time = 4, maxdistance = 4)
		affix_float(L, "-5")
/datum/mob_affix/cursed
	fx_state = "tendrils"
	examine_text = "Unholy energy clings to it: magic slides off it, and it drains the luck of those beside it."
/datum/mob_affix/cursed/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + 6 SECONDS
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	for(var/mob/living/L in view(2, parent_mob))
		if(L == parent_mob || L.stat == DEAD || faction_check(parent_mob.faction, L.faction))
			continue
		L.apply_status_effect(/datum/status_effect/buff/prayer_boon/curse, 10 SECONDS, list(STATKEY_LCK = -2))
		prayer_burst(L, "tendrils", color)
/datum/mob_affix/blessed
	fx_state = "halo"
	examine_text = "Holy favour shields it, and it mends its allies nearby. Holy miracles hurt it far less."
/datum/mob_affix/blessed/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + 6 SECONDS
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	for(var/mob/living/L in view(3, parent_mob))
		if(L.stat == DEAD || !faction_check(parent_mob.faction, L.faction))
			continue
		if(L.getBruteLoss() + L.getFireLoss() <= 0)
			continue
		L.heal_overall_damage(3, 3)
		prayer_burst(L, "sparkle", color)
		affix_float(L, "+6")
/datum/mob_affix/giant
	examine_text = "Huge and strong, with far more life to spend; slow."
/datum/mob_affix/tiny
	examine_text = "Small, fast and fragile."
/datum/mob_affix/vampiric
	fx_state = "drops"
	examine_text = "Drains the blood of those near it to heal itself."
/datum/mob_affix/reflective
	fx_state = "shield_dome"
	hit_state = "shockwave"
	examine_text = "Throws back a stinging pulse at those near it."
/datum/mob_affix/reflective/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + process_interval
	aura_damage(1, 4, 0, 0)
/datum/mob_affix/toxic
	fx_state = "rot_flies"
	hit_state = "bubble_ring"
	examine_text = "A cloud of poison hangs around it."
/datum/mob_affix/undying
	fx_state = "skull_wisp"
	examine_text = "Refuses to die: the first time it falls, it gets back up."
	var/used_second_life = FALSE
/datum/mob_affix/undying/on_death(mob/living/M)
	. = ..()
	if(used_second_life || QDELETED(M))
		return
	used_second_life = TRUE
	addtimer(CALLBACK(src, PROC_REF(rise_again), M), 3 SECONDS)
/datum/mob_affix/undying/proc/rise_again(mob/living/M)
	if(QDELETED(M) || M.stat != DEAD)
		return
	M.revive(full_heal = FALSE)
	M.heal_overall_damage(M.maxHealth * 0.4, M.maxHealth * 0.4)
	M.visible_message(span_danger("[M] claws its way back to its feet!"))
	prayer_burst(M, "big:pillar", color)
	prayer_burst(M, "skull_wisp", color)
	affix_float(M, "RISES AGAIN")
/datum/mob_affix/frenzied
	fx_state = "embers"
	examine_text = "Attacks wildly and quickly, heedless of its own safety."
/datum/mob_affix/steadfast
	fx_state = "holy_glyph"
	examine_text = "Shrugs off crippling blows and does not break."
/datum/mob_affix/keen
	fx_state = "eye"
	examine_text = "Sharp-eyed and clever: it spots openings, and its attacks find their mark."
/datum/mob_affix/clumsy
	examine_text = "Slow and sloppy; an easy mark."
/datum/mob_affix/invisible
	fx_state = "moon"
	examine_text = "Hard to see until it's upon you."
/datum/mob_affix/lucky
	fx_state = "coins"
	examine_text = "Fortune favours it."
/datum/mob_affix/unlucky
	examine_text = "Misfortune follows it."
/datum/mob_affix/wild
	fx_state = "leaves"
	examine_text = "Unpredictable and aggressive; it never sleeps."
/datum/mob_affix/diseased
	fx_state = "rot_flies"
	hit_state = "rot_flies"
	examine_text = "Spreads sickness to those who come near."
/datum/mob_affix/feral
	fx_state = "embers"
	examine_text = "Savage and sharp-sensed; stronger than it looks."
/datum/mob_affix/eldritch
	fx_state = "mind_waves"
	examine_text = "Touched by something beyond: magic slides off it, and its presence frays the minds of those nearby."
/datum/mob_affix/eldritch/affix_process()
	if(world.time < next_process)
		return
	next_process = world.time + 6 SECONDS
	if(!parent_mob || parent_mob.stat == DEAD)
		return
	for(var/mob/living/carbon/human/H in view(3, parent_mob))
		if(H.stat == DEAD || faction_check(parent_mob.faction, H.faction))
			continue
		H.sanity?.changeLevel(-3)
		if(prob(25))
			H.apply_status_effect(/datum/status_effect/prayer/madness, 5 SECONDS, 0.6)
		prayer_burst(H, "mind_waves", color)

#undef AFFIX_FX
