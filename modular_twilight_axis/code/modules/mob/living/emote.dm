/datum/emote/living/blush
	key_third_person = "blushes"
	message = "blushes."
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_blush()
	set name = "Blush"
	set category = "Emotes"

	emote("blush", intentional = TRUE)

/datum/emote/living/pray
	key_third_person = "prays"
	message = "says a prayer."
	
/datum/emote/living/meditate
	key_third_person = "meditates"
	message = "meditates."

/datum/emote/living/bow
	key_third_person = "bows"
	message = "bows."
	message_param = "bows to %t."

/datum/emote/living/burp
	key_third_person = "burps"
	message = "burps."
	message_muffled = "makes a muffled sound." 

/datum/emote/living/choke
	key_third_person = "chokes"
	message = "chokes!"

/datum/emote/living/cross
	key_third_person = "crosses their arms"
	message = "crosses their arms."

/datum/emote/living/collapse
	key_third_person = "faints"
	message = "faints."

/datum/emote/living/whisper
	key_third_person = "whispers"
	message = "whispers."
	message_mime = "whispers something."

/datum/emote/living/cough
	key_third_person = "coughs"
	message = "coughs."

/datum/emote/living/clearthroat
	key_third_person = "clears their throat"
	message = "clears their throat."
	message_muffled = "makes a muffled sound." 

/datum/emote/living/dance
	key_third_person = "dances"
	message = "dances."

/datum/emote/living/drool
	key_third_person = "drools"
	message = "drools."

/datum/emote/living/faint
	key_third_person = "collapses"
	message = "collapses."

/datum/emote/living/frown
	key_third_person = "frowns"
	message = "frowns."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/gag
	key_third_person = "gags"
	message = "gags."

/datum/emote/living/gasp
	key_third_person = "gasps"
	message = "gasps!"
	message_muffled = "makes a muffled sound, trying to scream." 

/datum/emote/living/breathgasp
	key_third_person = "gasps for air"
	message = "gasps for air!"

/datum/emote/living/giggle
	key_third_person = "giggles"
	message = "giggles."

/datum/emote/living/chuckle
	key_third_person = "smirks"
	message = "smirks."


/datum/emote/living/glare
	key_third_person = "glares"
	message = "glares."
	message_param = "glares at %t."

/datum/emote/living/grin
	key_third_person = "grins"
	message = "grins."

/datum/emote/living/groan
	key_third_person = "sighs heavily"
	message = "sighs heavily."
	message_muffled = "lets out a muffled sigh." 

/datum/emote/living/grimace
	key_third_person = "grimaces"
	message = "grimaces."

/datum/emote/living/jump
	key_third_person = "jumps"
	message = "jumps!"


/datum/emote/living/leap
	key_third_person = "hops"
	message = "hops!"

/datum/emote/living/kiss
	key_third_person = "kisses"
	message = "blows a kiss."
	message_param = "kisses %t."
	emote_type = EMOTE_VISIBLE
	use_params_for_runechat = TRUE

/datum/emote/living/lick
	key_third_person = "licks"
	message = "licks their lips."
	message_param = "licks %t."

/datum/emote/living/spit
	key_third_person = "spits"
	message = "spits on the ground."
	message_param = "spits at %t."

/datum/emote/living/spit/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mouth)
			if(H.mouth.spitoutmouth)
				H.visible_message(span_warning("[H] spits out [H.mouth]."))
				H.dropItemToGround(H.mouth, silent = FALSE)
			return
	..()

/datum/emote/living/hug
	key_third_person = "hugs"
	message = ""
	message_param = "hugs %t."

/datum/emote/living/slap
	key_third_person = "slaps"
	message = ""
	message_param = "slaps %t across the face."

/datum/emote/living/slap/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.zone_selected == BODY_ZONE_PRECISE_GROIN)
			message_param = "slaps %t on the ass."
		else if(H.zone_selected == BODY_ZONE_PRECISE_SKULL)
			message_param = "cuffs %t on the back of the head."
		else if(H.zone_selected == BODY_ZONE_PRECISE_L_HAND || H.zone_selected == BODY_ZONE_PRECISE_R_HAND)
			message_param = "slaps %t's hand."
		else if(H.zone_selected == BODY_ZONE_CHEST)
			message_param = "slaps %t's chest."
	..()

/datum/emote/living/pinch
	message = ""
	message_param = "pinches %t."

/datum/emote/living/pinch/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.zone_selected == BODY_ZONE_HEAD)
			message_param = "pinches %t's cheek."
		else if(H.zone_selected == BODY_ZONE_PRECISE_L_HAND || H.zone_selected == BODY_ZONE_PRECISE_R_HAND)
			message_param = "pinches %t's arm."
		else if(H.zone_selected == BODY_ZONE_CHEST)
			message_param = "pinches %t's chest."
		else
			var/ru_zone_selected = zone_translations[user.zone_selected]
			message_param = "pinches %t's [ru_zone_selected]."
	..()

/datum/emote/living/laugh
	key_third_person = "laughs"
	message = "laughs."
	message_mime = "laughs silently."
	message_muffled = "laughs, muffled."

/datum/emote/living/look
	key_third_person = "looks"
	message = "looks."
	message_param = "looks %t over."
/mob/living/carbon/human/verb/emote_look()
	set name = "Look"
	set category = "Emotes"

	emote("look", intentional = TRUE)

/datum/emote/living/nod
	key_third_person = "nods"
	message = "nods."
	message_param = "nods at %t."

/datum/emote/living/point
	key_third_person = "points"
	message = "points."
	message_param = "points at %t."

/datum/emote/living/pout
	key_third_person = "pouts"
	message = "pouts."
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE
/mob/living/carbon/human/verb/emote_pout()
	set name = "Pout"
	set category = "Emotes"

	emote("pout", intentional = TRUE)

/datum/emote/living/scream
	key_third_person = "screams"
	message = "screams!"
	message_mime = "pretends to scream!"
	message_muffled = "makes a strangled sound, trying to scream."
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE

/datum/emote/living/scream/painscream
	message = "screams in pain!"

/datum/emote/living/scream/strain
	message = "strains!"

/datum/emote/living/scream/agony
	message = "screams in agony!"

/datum/emote/living/haltyell
	message = "demands they stop!"

/datum/emote/living/rage
	message = "screams in rage!"

/datum/emote/living/attnwhistle
	message = "whistles for attention!"
	message_muffled = "makes a muffled sound." 

/datum/emote/living/scowl
	key_third_person = "scowls"
	message = "scowls."
	emote_type = EMOTE_AUDIBLE
	show_runechat = FALSE
/mob/living/carbon/human/verb/emote_scowl()
	set name = "Scowl"
	set category = "Emotes"

	emote("scowl", intentional = TRUE)


/datum/emote/living/shakehead
	key_third_person = "shakes their head"
	message = "shakes their head."

/datum/emote/living/shake
	key_third_person = "shakes their head hard"
	message = "shakes their head hard."

/datum/emote/living/shiver
	key_third_person = "trembles"
	message = "trembles."

/datum/emote/living/sigh
	key_third_person = "sighs"
	message = "sighs."
	message_muffled = "lets out a muffled sigh." 

/datum/emote/living/whistle
	key_third_person = "whistles"
	message = "whistles."
	message_muffled = "makes a muffled sound." 

/datum/emote/living/hmm
	key_third_person = "hums"
	message = "hums."
	message_muffled = "hums, muffled." 

/datum/emote/living/huh
	key_third_person = "hums?"
	message_muffled = "makes a muffled sound." 

/datum/emote/living/hum
	key_third_person = "sings softly"
	message = "sings softly."
	message_muffled = "sings softly, muffled." 

/datum/emote/living/smile
	key_third_person = "smiles"
	message = "smiles."

/datum/emote/living/carbon/clap
	key_third_person = "claps"
	message = "claps."

/datum/emote/living/sneeze
	key_third_person = "sneezes"
	message = "sneezes."
	message_muffled = "sneezes, muffled."

/datum/emote/living/hmph
	key = "hmph"
	key_third_person = "scoffs!"
	message = "scoffs!"
	message_muffled = "hums, muffled."
/mob/living/carbon/human/verb/emote_hmph()
	set name = "Scoff!"
	set category = "Emotes.Noises"

	emote("hmph", intentional = TRUE)

/datum/emote/living/shh
	key_third_person = "shushes"
	message = "shushes."
	message_muffled = "shushes, muffled."

/datum/emote/living/smug
	key_third_person = "smirks smugly"
	message = "smirks smugly."
/mob/living/carbon/human/verb/emote_smug()
	set name = "Smirk smugly"
	set category = "Emotes"

	emote("smug", intentional = TRUE)

/datum/emote/living/sniff
	key_third_person = "sniffs"
	message = "sniffs."
/mob/living/carbon/human/verb/emote_sniff()
	set name = "Sniff"
	set category = "Emotes"

	emote("sniff", intentional = TRUE)

/datum/emote/living/snore
	key_third_person = "snores"
	message = "snores."
	message_mime = "breathes heavily."

/datum/emote/living/stare
	key_third_person = "stares"
	message = "stares."
	message_param = "stares at %t."
/mob/living/carbon/human/verb/emote_stare()
	set name = "Stare"
	set category = "Emotes"

	emote("stare", intentional = TRUE)

/datum/emote/living/strech
	key_third_person = "stretches"
	message = "stretches."
/mob/living/carbon/human/verb/emote_strech()
	set name = "Stretch"
	set category = "Emotes"

	emote("stretch", intentional = TRUE)

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways."
/mob/living/carbon/human/verb/emote_sway()
	set name = "Sway"
	set category = "Emotes"

	emote("sway", intentional = TRUE)

/datum/emote/living/tremble
	key_third_person = "trembles"
	message = "trembles with fear!"
/mob/living/carbon/human/verb/emote_tremble()
	set name = "Tremble with fear"
	set category = "Emotes"

	emote("tremble", intentional = TRUE)

/datum/emote/living/twitch
	key_third_person = "twitches"
	message = "twitches convulsively."

/datum/emote/living/twitch_s
	message = "twitches."

/datum/emote/living/warcry
	key_third_person = "lets out a war cry!"
	message = "shouts a rousing war cry!"
	message_muffled = "lets out a muffled shout."

/datum/emote/living/wave
	key_third_person = "waves"
	message = "waves."
	
/datum/emote/living/whimper
	key_third_person = "sobs"
	message = "sobs."
	message_mime = "sobs."
	message_muffled = "sobs, muffled."

/datum/emote/living/wsmile
	key_third_person = "smiles weakly"
	message = "smiles weakly."
/mob/living/carbon/human/verb/emote_wsmile()
	set name = "Smile weakly"
	set category = "Emotes"

	emote("wsmile", intentional = TRUE)

/datum/emote/living/yawn
	key_third_person = "yawns"
	message = "yawns."
	message_muffled = "yawns, muffled."

/datum/emote/living/squint
	key_third_person = "squints"
	message = "squints."

/datum/emote/living/snap
	key_third_person = "snaps their fingers"
	message = "snaps their fingers!"

/datum/emote/living/blink
	key_third_person = "blinks."
	message = "blinks."

/datum/emote/living/stomp
	key_third_person = "stomps"
	message = "stomps!"

/datum/emote/living/snap2
	key_third_person = "snaps their fingers twice"
	message = "snaps their fingers twice!"

/datum/emote/living/snap3
	key_third_person = "snaps their fingers three times"
	message = "snaps their fingers three times!"

/datum/emote/living/fsalute
	key_third_person = "proclaims their faith"
	message = "proclaims their faith."

/datum/emote/living/ffsalute
	key_third_person = "proclaims their faith"
	message = "proclaims their faith."

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
/datum/emote/living/carbon/human/cry/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.can_speak())
			message = "sobs. A stream of tears runs down their face."

/*
/datum/emote/living/carbon/human/sexmoanlight/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.can_speak())
			message = "makes a noise."
*/

/datum/emote/living/carbon/human/eyebrow
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/grumble
	key_third_person = "grumbles"
	message = "grumbles."
	message_muffled = "grumbles, muffled."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	message = "shakes their own hand"
	message_param = "shakes %t's hand."

/datum/emote/living/carbon/human/pale
	message = "goes pale for a moment."
/mob/living/carbon/human/verb/emote_pale()
	set name = "Go pale"
	set category = "Emotes"

	emote("pale", intentional = TRUE)

/datum/emote/living/carbon/human/raise
	key_third_person = "raises a hand"
	message = "raises a hand."
/mob/living/carbon/human/verb/emote_raise()
	set name = "Raise a hand"
	set category = "Emotes"

	emote("raise", intentional = TRUE)

/datum/emote/living/carbon/human/salute
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes %t."
	restraint_check = TRUE
/mob/living/carbon/human/verb/emote_salute()
	set name = "Salute"
	set category = "Emotes"

	emote("salute", intentional = TRUE)

/datum/emote/living/carbon/human/shrug
	key_third_person = "shrugs"
	message = "shrugs."
/mob/living/carbon/human/verb/emote_shrug()
	set name = "Shrug"
	set category = "Emotes"

	emote("shrug", intentional = TRUE)

/datum/emote/living/carbon/human/wag
	key_third_person = "wags"
	message = "wags their tail."

/datum/emote/living/carbon/human/wing
	key_third_person = "flaps their wings"
	message = "flaps their wings."

/datum/emote/living/softmoan
	key = "softmoan"
	key_third_person = "moans softly"
	message = "moans softly."
	message_muffled = "moans, muffled."
	emote_type = EMOTE_AUDIBLE
	show_runechat = TRUE

/mob/living/carbon/human/verb/emote_softmoan()
	set name = "Moan softly"
	set category = "Emotes.Noises"

	emote("softmoan", intentional = TRUE)

/datum/emote/living/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans."
	message_muffled = "moans, muffled."
	emote_type = EMOTE_AUDIBLE
	show_runechat = TRUE

/mob/living/carbon/human/verb/emote_moan()
	set name = "Moan"
	set category = "Emotes.Noises"

	emote("moan", intentional = TRUE)

/datum/emote/living/pat
	key = "pat"
	key_third_person = "pats on the head"
	message = ""
	message_param = "pats %t on the head."
	emote_type = EMOTE_VISIBLE
	restraint_check = TRUE

/mob/living/carbon/human/verb/emote_pat()
	set name = "Pat"
	set category = "Emotes"

	emote("pat", intentional = TRUE, targetted = TRUE)

/datum/emote/living/pat/adjacentaction(mob/user, mob/target)
	. = ..()
	if(!user || !target)
		return
	if(ishuman(target))
		playsound(target.loc, 'sound/vo/hug.ogg', 100, FALSE, -1)

/*
/datum/emote/living/stat_roll/strength
	attempt_message_list = list(
		"tests their strength...",
		"strains...",
		"flexes their muscles...",
	)

	success_message_list = list(
		"shows off their strength!",
		"proves those muscles are earned!",
		"proves they're strong!",
	)

	failure_message_list = list(
		"has arms like twigs",
		"couldn't even lift a chair",
		"should have eaten more meat",
	)

/datum/emote/living/stat_roll/perception
	attempt_message_list = list(
		"peers very carefully...",
		"focuses their gaze...",
		"squints...",
	)

	success_message_list = list(
		"has eyes like an eagle!",
		"sees what others can't!",
		"spots the tiniest detail!",
	)

	failure_message_list = list(
		"seems to be short-sighted!",
		"looks like they have cataracts!",
		"is blind....",
	)

/datum/emote/living/stat_roll/intelligence
	attempt_message_list = list(
		"thinks it over...",
		"knits their brows...",
		"scratches their chin thoughtfully...",
	)

	success_message_list = list(
		"proves they're among the sharpest!",
		"proves the keenness of their mind!",
		"knows what they're doing!",
	)

	failure_message_list = list(
		"has no idea where they are...",
		"has a head like a cabbage stump",
		"how to add two and two remains a mystery...",
	)

/datum/emote/living/stat_roll/constitution
	attempt_message_list = list(
		"tests their toughness",
		"braces for a blow...",
		"steels themselves to endure...",
	)

	success_message_list = list(
		"didn't even flinch!",
		"is as sturdy as an oak!",
		"didn't even raise an eyebrow!",
	)

	failure_message_list = list(
		"is nothing but skin and bones...",
		"sways like a blade of grass in the wind",
		"is as fragile as crystal",
	)

/datum/emote/living/stat_roll/willpower
	modifiers_list = list(
		TRAIT_TOLERANT = -1,
	)

	attempt_message_list = list(
		"tests their willpower...",
		"gathers their thoughts...",
		"prepares to prove their resolve...",
	)

	success_message_list = list(
		"pushes through it",
		"never gives up!",
		"would walk through fire and water",
	)

	failure_message_list = list(
		"is as cowardly as a chicken",
		"loses heart...",
		"would be scared even if nobody shouted",
	)

/datum/emote/living/stat_roll/speed
	attempt_message_list = list(
		"readies their best move...",
		"shows off their flexibility...",
		"tries to build up speed...",
	)

	success_message_list = list(
		"shows brilliant control of their body",
		"bends like a cat",
		"incredible flexibility",
	)

	failure_message_list = list(
		"seems to have two left feet",
		"outplays themselves",
		"slower than a snail...",
	)

/datum/emote/living/stat_roll/fortune
	attempt_message_list = list(
		"tests their luck...",
		"seizes the moment...",
		"weighs the stakes...",
	)

	success_message_list = list(
		"could find an ingot in a puddle",
		"must have a rabbit's foot in their pocket!",
		"shines with true luck!",
	)

	failure_message_list = list(
		"realizes the game was lost from the start...",
		"luck clearly isn't on their side",
		"all the odds are against them...",
	)

/datum/emote/living/stat_roll/charisma
	attempt_message_list = list(
		"tries to keep their composure...",
		"tries to make an impression...",
		"considers their next move...",
	)

	success_message_list = list(
		"is brimming with unshakable confidence!",
		"- a face like a stone mask",
		"... a countenance like a god's",
	)

	failure_message_list = list(
		"seethes with uncertainty...",
		"not very convincing...",
		"their composure hangs by a thread...",
	)
*/

/datum/emote/living/carbon/slowclap
	key_third_person = "claps"
	message = "claps slowly."

/datum/emote/living/carbon/clap1
	key_third_person = "claps"
	message = "claps their hands."