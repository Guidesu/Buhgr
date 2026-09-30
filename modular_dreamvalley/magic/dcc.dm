// Wild magic, in the manner of Dungeon Crawl Classics. Every arcane working is
// a gamble: a spell check decides whether it goes off, a bad roll misfires, a
// terrible one leaves a mark on the caster for good. A desperate mage can burn
// their own body to push the odds, and no two mages' spells behave alike.


/mob/living
	/// Result of the last spell check, read after the cast.
	var/last_spell_check_result = SPELL_CHECK_NORMAL
	/// Body burned into the next spell check (spellburn).
	var/spellburn_pending = 0
	/// Marks magic has left on this body: list of corruption ids.
	var/list/arcane_corruptions

// --- The spell check ------------------------------------------------------------

/// The bonus a caster adds to their d20 for this spell.
/mob/living/proc/spell_check_bonus(datum/action/cooldown/spell/S)
	. = round((get_stat(STAT_INTELLIGENCE) - 10) / 2)
	. += get_skill_level(/datum/skill/magic/arcane)
	. -= (max(1, S.spell_tier) - 1) * 2
	. -= round(arcane_strain / 20)
	. += mercurial_check_bonus(S)
	if(in_place_of_power())
		. += 2
	var/list/medium = arcane_medium()
	. += medium[1]

/// Rolls a spell check. Returns FALSE if the spell is lost.
/mob/living/proc/spell_check(datum/action/cooldown/spell/S)
	var/roll = rand(1, 20)
	var/bonus = spell_check_bonus(S) + spellburn_pending
	var/burned = spellburn_pending
	spellburn_pending = 0
	var/total = roll + bonus
	var/shown = "d20 [roll] [bonus >= 0 ? "+" : "-"] [abs(bonus)] = [total]"
	if(roll == 1)
		last_spell_check_result = SPELL_CHECK_LOST
		balloon_alert_to_viewers("misfire!", "misfire! ([total])", 5)
		to_chat(src, span_danger("<b>Misfire!</b> ([shown])"))
		spell_misfire(S)
		if(prob(arcane_strain >= STRAIN_STRAINED ? 50 : 25))
			add_arcane_corruption()
		add_arcane_strain(S.strain_for_cast(src) * 0.5)
		return FALSE
	if(total < 6)
		last_spell_check_result = SPELL_CHECK_LOST
		balloon_alert(src, "fizzled ([total])")
		if(total < 2)
			spell_misfire(S)
		add_arcane_strain(S.strain_for_cast(src) * 0.5)
		return FALSE
	if(roll == 20 || total >= 22)
		last_spell_check_result = SPELL_CHECK_MASTERY
		balloon_alert(src, "mastery! no strain ([total])")
		new /obj/effect/temp_visual/strain_crackle(get_turf(src))
		return TRUE
	last_spell_check_result = SPELL_CHECK_NORMAL
	if(burned)
		balloon_alert(src, "spellburn carries it ([total])")
	return TRUE

// --- Misfires --------------------------------------------------------------------

/mob/living/proc/spell_misfire(datum/action/cooldown/spell/S)
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/strain_crackle(T)
	switch(rand(1, 8))
		if(1)
			visible_message(span_danger("Sparks burst from [src]'s hands!"), span_userdanger("Sparks burst from my hands and burn them!"))
			apply_damage(10, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(2)
			visible_message(span_danger("A blinding flash bursts from [src]!"), span_userdanger("Everything goes white!"))
			for(var/mob/living/L in view(2, T))
				L.blur_eyes(L == src ? 6 : 3)
			adjust_blindness(2)
		if(3)
			visible_message(span_danger("[src] is thrown off [p_their()] feet by [p_their()] own magic!"), span_userdanger("The working throws me down!"))
			Knockdown(2 SECONDS)
		if(4)
			var/colour = pick("#ff5fd2", "#5fff9d", "#ffe15f", "#8f5fff", "#5fd7ff")
			visible_message(span_notice("[src] begins to glow a strange colour."), span_notice("I am glowing. I did not mean to be glowing."))
			mob_light(colour, 3, 1, 1 MINUTES)
		if(5)
			visible_message(span_danger("Frost spreads across [src]'s skin!"), span_userdanger("Cold floods my body!"))
			adjust_bodytemperature(-60)
			apply_damage(5, BURN)
		if(6)
			var/list/near = list()
			for(var/mob/living/L in view(3, T))
				if(L != src && L.stat != DEAD)
					near += L
			if(length(near))
				var/mob/living/hit = pick(near)
				visible_message(span_danger("The magic leaps wild from [src] and strikes [hit]!"))
				hit.apply_damage(8, BURN)
				new /obj/effect/temp_visual/strain_crackle(get_turf(hit))
			else
				to_chat(src, span_warning("The magic leaps out of me and grounds itself in the earth."))
		if(7)
			visible_message(span_danger("Smoke pours from [src]'s clothes!"), span_userdanger("I am smouldering!"))
			adjust_fire_stacks(1)
			ignite_mob()
		if(8)
			to_chat(src, span_userdanger("The failed working coils back into me."))
			add_arcane_strain(15)

// --- Corruption ------------------------------------------------------------------

/// id = list(examine line, stat changes, what I feel)
GLOBAL_LIST_INIT(arcane_corruptions, list(
	"eyes" = list("Their eyes shine faintly, like a cat's in lamplight.", null, "Something settles behind my eyes. They feel... brighter."),
	"cold" = list("Their skin is cold to the touch, whatever the weather.", null, "The warmth drains from my skin and does not come back."),
	"withered" = list("One of their hands is blackened and withered.", list(STATKEY_STR = -1), "My hand withers and blackens before my eyes."),
	"echo" = list("Their voice carries a faint echo.", null, "My voice comes back to me a moment late."),
	"shadow" = list("Their shadow moves a moment after they do.", null, "My shadow no longer quite keeps up with me."),
	"ozone" = list("They smell of storms and ozone.", null, "I smell lightning on my own skin."),
	"white" = list("A streak of their hair has gone white as bone.", null, "A lock of my hair turns white."),
	"sigils" = list("Faint sigils are scarred into their skin, glowing when they are angry.", list(STATKEY_INT = 1, STATKEY_CON = -1), "Marks burn into my skin and stay there. My thoughts run sharper."),
	"veins" = list("Their veins run dark beneath the skin.", list(STATKEY_CON = -1), "My veins darken. My blood feels thick and slow."),
	"teeth" = list("Their teeth are a little too sharp.", null, "My teeth ache, and sharpen."),
	"luck" = list("Candle flames lean away from them.", list(STATKEY_LCK = -1), "Something unlucky has fastened itself to me."),
	"tremor" = list("Their hands never stop trembling.", list(STATKEY_PER = -1), "My hands start to shake and will not stop."),
))

/mob/living/proc/add_arcane_corruption()
	var/list/options = GLOB.arcane_corruptions.Copy() - arcane_corruptions
	if(!length(options))
		return
	var/id = pick(options)
	LAZYADD(arcane_corruptions, id)
	var/list/info = GLOB.arcane_corruptions[id]
	to_chat(src, span_userdanger("<i>Corruption.</i> [info[3]]"))
	var/list/stats = info[2]
	for(var/stat_key in stats)
		change_stat(stat_key, stats[stat_key], "arcane_corruption_[id]")

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	for(var/id in arcane_corruptions)
		var/list/info = GLOB.arcane_corruptions[id]
		if(info)
			. += span_warning(info[1])

// --- Spellburn ------------------------------------------------------------------

/mob/living/carbon/human/verb/spellburn()
	set name = "Spellburn"
	set category = "Spells"
	if(stat != CONSCIOUS)
		return
	if(get_skill_level(/datum/skill/magic/arcane) < 1)
		to_chat(src, span_warning("I know nothing of burning the body into magic."))
		return
	var/static/list/stats = list("Strength" = STATKEY_STR, "Constitution" = STATKEY_CON, "Speed" = STATKEY_SPD)
	var/which = tgui_input_list(src, "Which part of my body will I burn into my next working? It comes back in ten minutes.", "Spellburn", stats)
	if(!which || stat != CONSCIOUS)
		return
	var/amount = tgui_input_number(src, "How much? Each point burned adds one to my next spell check.", "Spellburn", 2, 5, 1)
	if(!amount || stat != CONSCIOUS)
		return
	var/stat_key = stats[which]
	add_temp_stat(stat_key, -amount, 10 MINUTES, "spellburn_[stat_key]_[world.time]")
	spellburn_pending += amount
	apply_damage(amount * 2, BRUTE)
	visible_message(span_danger("[src] clenches [p_their()] fists; blood beads under [p_their()] nails."), span_warning("I burn [amount] of my [lowertext(which)] into the magic. My next working will be stronger for it."))

// --- Mercurial magic --------------------------------------------------------------

/// Each mage's spells are their own: a quirk fixed by who casts it and what it is.
/// id = list(description, check bonus, strain multiplier, flavour or null)
GLOBAL_LIST_INIT(mercurial_quirks, list(
	"none" = list("Behaves as the books say.", 0, 1, null),
	"easy" = list("Comes naturally to me (+2 to spell checks).", 2, 1, null),
	"stubborn" = list("Fights me every time (-2 to spell checks, but half the Strain).", -2, 0.5, null),
	"hungry" = list("Hungry: it draws more out of me (x1.5 Strain, +1 to spell checks).", 1, 1.5, null),
	"gentle" = list("Gentle on the body (x0.7 Strain).", 0, 0.7, null),
	"brimstone" = list("Leaves a smell of brimstone behind.", 0, 1, "The air around %M smells of brimstone."),
	"birdsong" = list("Is followed by distant birdsong.", 0, 1, "Birdsong, from nowhere, follows %M's working."),
	"frost" = list("Leaves frost on the caster's fingertips.", 0, 1, "Frost creeps over %M's fingertips."),
	"whispers" = list("Is accompanied by whispers.", 0, 1, "Something whispers along with %M's working."),
	"petals" = list("Scatters a few flower petals.", 0, 1, "A few petals drift down around %M."),
	"shadows" = list("Makes nearby shadows lean toward the caster.", 0, 1, "The shadows near %M lean toward them."),
	"hair" = list("Makes the caster's hair stand on end.", 1, 1.1, "%M's hair stands on end."),
))

/mob/living/proc/mercurial_quirk_id(datum/action/cooldown/spell/S)
	var/seed = md5("[real_name]|[S.type]")
	var/n = hex2num(copytext(seed, 1, 5))
	var/list/ids = GLOB.mercurial_quirks
	// Most spells are ordinary; roughly half carry a quirk.
	if(n % 2)
		return "none"
	return ids[(n % length(ids)) + 1]

/mob/living/proc/mercurial_check_bonus(datum/action/cooldown/spell/S)
	var/list/q = GLOB.mercurial_quirks[mercurial_quirk_id(S)]
	return q ? q[2] : 0

/mob/living/proc/mercurial_strain_mult(datum/action/cooldown/spell/S)
	var/list/q = GLOB.mercurial_quirks[mercurial_quirk_id(S)]
	return q ? q[3] : 1

/mob/living/proc/mercurial_flavour(datum/action/cooldown/spell/S)
	var/list/q = GLOB.mercurial_quirks[mercurial_quirk_id(S)]
	if(!q || !q[4] || !prob(35))
		return
	visible_message(span_notice(replacetext(q[4], "%M", "[src]")))

/datum/action/cooldown/spell/get_spell_statistics(mob/living/user)
	. = ..()
	if(!istype(user) || !is_arcane_spell(src))
		return
	var/list/q = GLOB.mercurial_quirks[user.mercurial_quirk_id(src)]
	if(q)
		. += span_info("In my hands: [q[1]]")
	var/bonus = user.spell_check_bonus(src)
	var/fail = clamp(6 - bonus - 1, 1, 20)
	. += span_info("Spell check: d20 [bonus >= 0 ? "+" : "-"] [abs(bonus)]. Lost on [fail > 1 ? "1-[fail]" : "a 1"], a 1 misfires, 20 costs no Strain.")

// --- Mediums: staves, wands and books -------------------------------------------

/// What the caster holds to channel magic through.
/// Returns list(spell check bonus, power multiplier, cost multiplier, list of names).
/mob/living/proc/arcane_medium()
	var/check = 0
	var/power = 1
	var/cost = 1
	var/list/names = list()
	var/best_refund = 0
	var/obj/item/best_implement
	for(var/obj/item/held in held_items)
		if(istype(held, /obj/item/rogueweapon))
			var/obj/item/rogueweapon/W = held
			if(W.implement_refund > best_refund)
				best_refund = W.implement_refund
				best_implement = W
		else if(istype(held, /obj/item/book/rogue/arcyne))
			check += 1
			power *= 1.1
			cost *= 0.9
			names += "[held.name]"
	if(best_implement)
		// Lesser 0.2, greater 0.275, grand 0.35.
		var/tier = best_refund >= IMPLEMENT_REFUND_GRAND ? 3 : (best_refund >= IMPLEMENT_REFUND_GREATER ? 2 : 1)
		check += tier
		power *= 1 + best_refund
		cost *= 1 - best_refund
		names += "[best_implement.name]"
	return list(check, power, cost, names)

/// Latin words in an incantation. The Weave was first bound in the old tongue.
/proc/latin_word_count(text)
	var/static/regex/strip = regex(@"[^a-z\s]", "g")
	var/clean = " [strip.Replace(lowertext(text), " ")] "
	. = 0
	for(var/form in GLOB.latin_forms)
		if(findtext(clean, " [form] "))
			.++

/// Power multiplier for speaking an incantation in Latin: +5% a word, up to +30%.
/proc/latin_power_mult(text)
	return 1 + min(0.3, latin_word_count(text) * 0.05)
