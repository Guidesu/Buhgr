/datum/action/cooldown/spell/readomen
	name = "Read Omen"
	desc = "Casting this spell, you draw upon the spirit lines themselves to reveal secrets of fate itself. \n\
	(Casting it gives you a vague explanation of which god currently holds sway over the land. If they are your patron, the explanation is less vague.)"
	button_icon = 'icons/mob/actions/mage_augmentation.dmi'
	button_icon_state = "readomen"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Miror quid.") // I wonder why
	invocation_type = INVOCATION_WHISPER

	charge_required = TRUE
	charge_swingdelay_type = SWINGDELAY_PENALTY
	charge_time = 1 SECONDS
	hold_drain = 0
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 1 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE

	point_cost = 1

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Read Omen", "tag" = "OMEN", "icon" = "readomen", "invocation" = "Caelum Feri!"),
		list("name" = "Orb of Wisdom", "tag" = "ORB", "icon" = "readomen", "invocation" = "Feri Fulmine Hostem!"),
	)

	var/list/reign_messages = list(
		/datum/faith/divine = list(
			/datum/faith/divine = "The Leylines feel still, and ready to be molded.",
			/datum/faith/inhumen = "They Leylines feel controlled, like it's potential is being suppressed.",
			/datum/faith/old_god = "They Leylines feel average, they could always be more controlled.",
		),
		/datum/faith/inhumen = list(
			/datum/faith/inhumen = "The Leylines feel ripe for change, excitement fills your Lux as you behold it.",
			/datum/faith/divine = "The Leylines feel unstable, something is causing the mana in them to fluxuate.",
			/datum/faith/old_god = "The Leylines are being leeched, something is manipulating Psydonia.",
		),
		/datum/faith/old_god = list(
			/datum/faith/divine = "The Leylines feel dull, perhaps they are healing.",
			/datum/faith/inhumen = "The Leylines power is being dulled, an insult to the Arcyne.",
			/datum/faith/old_god = "The Leylines are as they should be, a perfect balance of calm.",
		)
	)

	var/obj/item/rogueweapon/conjured_orb = null

/datum/action/cooldown/spell/readomen/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/readomen/proc/apply_mode(index)
	var/list/mode = modes[index]
	name = mode["name"]
	button_icon_state = mode["icon"]
	invocations = list(mode["invocation"])
	build_all_button_icons()
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/readomen/toggle_alt_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	to_chat(user, span_notice("[name]: [modes[current_mode]["name"]] mode."))
	return TRUE

/datum/action/cooldown/spell/readomen/proc/update_mode_maptext(tag)
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/B = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in B.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(B)
			B.vis_contents.Add(holder)
		holder.maptext = MAPTEXT(tag)
		holder.maptext_x = 5
		holder.color = GLOW_COLOR_LIGHTNING

/datum/action/cooldown/spell/readomen/cast()
	. = ..()

	var/mob/living/carbon/human/H = owner
	if(current_mode == 1)
		cast_omen(H)
	else
		cast_orb(H)
	return TRUE

/datum/action/cooldown/spell/readomen/proc/cast_omen(mob/living/user)
	var/dominant_faith = GLOB.dominant_faith_tracker.dominant_faith
	user.visible_message(span_info("The eyes of [user] roll back into their head for a moment!"), span_info("Your eyes roll into the back of your head!"))
	if(!istype(user) || !user.patron || ispath(user.patron.associated_faith, /datum/faith/godless))
		to_chat(user, "<span class='warning'>For some reason, I cannot get a good grasp of the Leylines.</span>")
		return FALSE
	if(ispath(user.patron.associated_faith, /datum/faith/accelerationism))
		to_chat(user, "<span class='warningbig'>FUCK THE LEYLINES, THEY ARE A TOOL, I DON'T CARE HOW THEY FEEL. I'LL BLOW THEM THE FUCK UP TOO WHEN I'M DONE.</span>")
		return FALSE
	if(ispath(user.patron.associated_faith, /datum/faith/mossmother))
		to_chat(user, "<span class='blue'>The Leylines moods are of no concern to me.</span>")
		return FALSE
	if(ispath(dominant_faith, /datum/faith/old_god))
		to_chat(user, span_blue(replacetext(reign_messages[user.patron.associated_faith][dominant_faith], "$patron", get_god_name(user.patron))))
	else if(ispath(user.patron.associated_faith, dominant_faith))
		to_chat(user, span_boldgreen(replacetext(reign_messages[user.patron.associated_faith][dominant_faith], "$patron", get_god_name(user.patron))))
	else
		to_chat(user, span_warningbig(replacetext(reign_messages[user.patron.associated_faith][dominant_faith], "$patron", get_god_name(user.patron))))

	var/datum/storyteller/current_god = SSgamemode.storytellers[SSgamemode.ruling_god]
	
	if(istype(current_god, /datum/storyteller/auxentius))
		if(istype(user.patron, /datum/patron/concordat/auxentius))
			to_chat(user, "<span class='warning'>You know this feeling well. That is the warmth of the sun on your cheeks. Auxentius light beams upon you in this moment.</span>")
		else
			to_chat(user, "<span class='warning'>You feel warm for a moment, like you are beginning to get flush from a fever, and then it fades.</span>")
			
	if(istype(current_god, /datum/storyteller/miluse))
		if(istype(user.patron, /datum/patron/concordat/miluse))
			to_chat(user, "<span class='warning'>With your eyes rolled into the back of you head, a feeling you are familiar with comes to mind. Darkness, the comforting darkness of night.</span>")
		else
			to_chat(user, "<span class='warning'>With your eyes rolled into the back of your head, you don't quite feel anything other than the opressive darkness that is the inside of your skull.</span>")
			
	if(istype(current_god, /datum/storyteller/wulfric))
		if(istype(user.patron, /datum/patron/concordat/wulfric))
			to_chat(user, "<span class='warning'>You concentrate on the spell, and are immediately hit with the familiar feeling of a lucid dream, you know this feeling well.</span>")
		else
			to_chat(user, "<span class='warning'>In your concentration of the spell, you feel yourself drift for a moment, like the feeling right before you are about to fall asleep.</span>")
			
	if(istype(current_god, /datum/storyteller/ignatius))
		if(istype(user.patron, /datum/patron/severance/ignatius))
			to_chat(user, "<span class='warning'>The spell takes effect, and you hear it immediately. You hear peaceful nature in your ears, winds billowing through trees, a distant volf bark. It is comforting.</span>")
		else
			to_chat(user, "<span class='warning'>You feel the spell take effect, but cannot notice anything quite different. Though, you swear you hear the sound of a nearby rustling tree.</span>")
			
	if(istype(current_god, /datum/storyteller/auxentius))
		if(istype(user.patron, /datum/patron/concordat/auxentius))
			to_chat(user, "<span class='warning'>It hits you quickly, this is the feeling you get right before a fight. You feel your body tense for a moment, excitement, duty, honor- before, it fades, that adrenaline quickly draining.</span>")
		else
			to_chat(user, "<span class='warning'>The spell takes effect, but all you feel is that feeling you get right before a fight. That brief jump in adrenaline before nothing once more.</span>")
			
	if(istype(current_god, /datum/storyteller/miluse))
		if(istype(user.patron, /datum/patron/concordat/miluse))
			to_chat(user, "<span class='warning'>This is the feeling of love, I know it well. Those butterflies in your stomach before you're about to confess, the excitement, the small amount of fear.</span>")
		else
			to_chat(user, "<span class='warning'>You feel something in your stomach, you aren't quite sure how to put it but it's a feeling akin to butterflies.</span>")
			
	if(istype(current_god, /datum/storyteller/morwenna))
		if(istype(user.patron, /datum/patron/concordat/morwenna))
			to_chat(user, "<span class='warning'>There is a deathly stillness in the air. You know this feeling and find comfort in it. You stand there and bask in the peacefulness of it for a moment before reality returns.</span>")
		else
			to_chat(user, "<span class='warning'>You swear for a moment you heard something whisper in your ear, perhaps it was the wind?</span>")
			
	if(istype(current_god, /datum/storyteller/handwerra))
		if(istype(user.patron, /datum/patron/concordat/handwerra))
			to_chat(user, "<span class='warning'>You finish the incantation of the spell and instantly notice the distinct smell of decay, a smell you know oh so well. It fills your mind with all sorts of machinations before the spell finishes.</span>")
		else
			to_chat(user, "<span class='warning'>You struggle for a moment in the silence, trying to concentrate on the spell, but the sound of a damned fly keeps distracting you before you lose concentration entirely.</span>")
			
	if(istype(current_god, /datum/storyteller/handwerra))
		if(istype(user.patron, /datum/patron/concordat/handwerra))
			to_chat(user, "<span class='warning'>You enter a state of meditation while you concentrate on the spell. You feel the familiar warmth on your cheeks for a moment, like you just stuck your head infront of a forge or oven.</span>")
		else
			to_chat(user, "<span class='warning'>You sit in silence, not knowing if the spell has actually taken effect, but you can swear you hear the sound of a distant ting from a blacksmith working away.</span>")
			
	if(istype(current_god, /datum/storyteller/aurelian))
		if(istype(user.patron, /datum/patron/unveiled/aurelian))
			to_chat(user, "<span class='warning'>You finish the incantations of the spell, but you know the answer already.</span>")
		else
			to_chat(user, "<span class='warning'>As you finish the spell, you are met with a feeling. You can't quite put your thumb on it but, something does not feel right.</span>")
			
	if(istype(current_god, /datum/storyteller/morwenna))
		if(istype(user.patron, /datum/patron/concordat/morwenna))
			to_chat(user, "<span class='warning'>The spell takes effect, and as your eyes are rolled back into your head, you swear you feel someone brush up against you, and instinctively reach for your coin pouch, only to realize that it never happened.</span>")
		else
			to_chat(user, "<span class='warning'>You feel your eyes roll into the back of your head, and begin to question if this was really worth casting. Before you have a chance to focus it's all over, what a ripoff.</span>")
			
	if(istype(current_god, /datum/storyteller/hausvette))
		if(istype(user.patron, /datum/patron/oldkin/hausvette))
			to_chat(user, "<span class='warning'>Once you finish the spell, you are hit with absolutely nothing, the same feeling you get after a line of Ozium. Dull and numb.</span>")
		else
			to_chat(user, "<span class='warning'>Your stomach immediately churns, you aren't quite sure if it's guilt, or if it's too much drink. It feels horrible.</span>")

	if(istype(current_god, /datum/storyteller/volkovoi))
		if(istype(user.patron, /datum/patron/oldkin/volkovoi))
			to_chat(user, "<span class='warning'>You finish the incantation and feel something well up inside you. Rage, excitement, the thirst you know so well. You snap back to reality, heart beating fast.</span>")
		else
			to_chat(user, "<span class='warning'>You finish the spell, however after a few moments you don't feel much difference, it leaves you frustrated and angry.</span>")
			
	if(istype(current_god, /datum/storyteller/praecursor))
		if(istype(user.patron, /datum/patron/tribunal/praecursor))
			to_chat(user, "<span class='warning'>You finish the incantation of the spell, but nothing happens. It is a nice moment of peace.</span>")
		else
			to_chat(user, "<span class='warning'>You finish the incantation of the spell, but nothing happens.</span>")
			
	if(istype(current_god, /datum/storyteller/viator))
		if(istype(user.patron, /datum/patron/concordat/viator))
			to_chat(user, "<span class='warning'>The spell incantation finishes and you feel a s- no. No that isn't right. That was a trick! Heehee, you can't trick me that easily.</span>")
		else
			var/list/possible_messages = list(
				"<span class='warning'>You feel warm for a moment, like you are beginning to get flush from a fever, and then it fades.</span>",
				"<span class='warning'>With your eyes rolled into the back of your head, you don't quite feel anything other than the opressive darkness that is the inside of your skull.</span>",
				"<span class='warning'>In your concentration of the spell, you feel yourself drift for a moment, like the feeling right before you are about to fall asleep.</span>",
				"<span class='warning'>You feel the spell take effect, but cannot notice anything quite different. Though, you swear you hear the sound of a nearby rustling tree.</span>",
				"<span class='warning'>The spell takes effect, but all you feel is that feeling you get right before a fight. That brief jump in adrenaline before nothing once more.</span>",
				"<span class='warning'>You feel something in your stomach, you aren't quite sure how to put it but it's a feeling akin to butterflies.</span>",
				"<span class='warning'>You swear for a moment you heard something whisper in your ear, perhaps it was the wind?</span>",
				"<span class='warning'>You struggle for a moment in the silence, trying to concentrate on the spell, but the sound of a damned fly keeps distracting you before you lose concentration entirely.</span>",
				"<span class='warning'>You sit in silence, not knowing if the spell has actually taken effect, but you can swear you hear the sound of a distant ting from a blacksmith working away.</span>",
				"<span class='warning'>As you finish the spell, you are met with a feeling. You can't quite put your thumb on it but, something does not feel right.</span>",
				"<span class='warning'>You feel your eyes roll into the back of your head, and begin to question if this was really worth casting. Before you have a chance to focus it's all over, what a ripoff.</span>",
				"<span class='warning'>Your stomach immediately churns, you aren't quite sure if it's guilt, or if it's too much drink. It feels horrible.</span>",
				"<span class='warning'>You finish the spell, however after a few moments you don't feel much difference, it leaves you frustrated and angry.</span>",
				"<span class='warning'>You finish the incantation of the spell, but nothing happens.</span>"
			)
			to_chat(user, pick(possible_messages))
