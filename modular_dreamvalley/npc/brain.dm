// The NPC brain (phase 2: talk). A spawned Workshop NPC hears what players say
// around it, thinks through the mind, and answers in the world like a player:
// the typing bubble while it thinks, then an emote and a line of speech. It
// keeps a running log of what it saw, and what it decides to remember is saved
// to its record for good, along with its opinion of the people it met.

/// How far an NPC listens.
#define NPC_HEAR_RANGE 7
/// Wait this long after speech before thinking, to gather a whole exchange.
#define NPC_THINK_DELAY (2 SECONDS)
/// An exchange counts as a conversation for this long after the last line.
#define NPC_CONVERSATION_WINDOW (90 SECONDS)
/// Lines kept in short-term memory.
#define NPC_LOG_SIZE 16
/// Long-term memories kept on the record.
#define NPC_MEMORY_CAP 40
/// Steps in one self-made plan.
#define NPC_PLAN_MAX 6

/datum/npc_brain
	var/datum/npc_record/record
	var/mob/living/carbon/human/body
	/// Short-term memory: what happened lately, in order.
	var/list/log = list()
	/// name = world.time of the last exchange with them.
	var/list/talking_with = list()
	var/thinking = FALSE
	/// NPC name = replies given to them lately, and when that count resets.
	var/list/npc_chat_counts = list()
	var/npc_chat_reset = 0
	var/think_timer
	/// The most recent speaker who prompted a thought.
	var/mob/living/addressed_by

/datum/npc_brain/New(datum/npc_record/record, mob/living/carbon/human/body)
	src.record = record
	src.body = body
	RegisterSignal(body, COMSIG_PARENT_QDELETING, PROC_REF(on_body_gone))

/datum/npc_brain/Destroy()
	if(think_timer)
		deltimer(think_timer)
	body = null
	record = null
	addressed_by = null
	return ..()

/datum/npc_brain/proc/on_body_gone()
	SIGNAL_HANDLER
	qdel(src)

/datum/npc_brain/proc/note(text)
	log += "[station_time_timestamp("hh:mm")] [text]"
	if(length(log) > NPC_LOG_SIZE)
		log.Cut(1, length(log) - NPC_LOG_SIZE + 1)

/mob/living/carbon/human
	var/datum/npc_brain/npc_brain

// --- Hearing ----------------------------------------------------------------------

/mob/living/carbon/human/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode, original_message)
	. = ..()
	if(npc_brain && speaker != src && isliving(speaker) && !radio_freq)
		npc_brain.heard(speaker, raw_message)

/datum/npc_brain/proc/heard(mob/living/speaker, text)
	if(!body || body.stat != CONSCIOUS || !text)
		return
	note("[speaker.name] said: \"[text]\"")
	// Players can always talk to an NPC. Another NPC can too, but only for a few
	// exchanges at a time, so two NPCs cannot talk each other into a loop.
	if(!speaker.client)
		var/mob/living/carbon/human/other = speaker
		if(!istype(other) || !other.npc_brain)
			return
		if(world.time > npc_chat_reset)
			npc_chat_counts = list()
			npc_chat_reset = world.time + 5 MINUTES
		if(npc_chat_counts[other.name] >= 3)
			return
		npc_chat_counts[other.name]++
	if(!wants_to_answer(speaker, text))
		return
	addressed_by = speaker
	talking_with[speaker.name] = world.time
	if(think_timer)
		deltimer(think_timer)
	think_timer = addtimer(CALLBACK(src, PROC_REF(think)), NPC_THINK_DELAY, TIMER_STOPPABLE)

/// Whether a line was meant for this NPC, the way a player would judge it.
/datum/npc_brain/proc/wants_to_answer(mob/living/speaker, text)
	var/lowered = lowertext(text)
	var/first_name = lowertext(splittext(body.real_name, " ")[1])
	if(findtext(lowered, first_name))
		return TRUE
	if(world.time - (talking_with[speaker.name] || -INFINITY) < NPC_CONVERSATION_WINDOW)
		return TRUE
	if(get_dist(body, speaker) > 2)
		return FALSE
	// Standing close, and nobody else is closer to them.
	for(var/mob/living/carbon/human/other in view(2, speaker))
		if(other != speaker && other != body && other.stat == CONSCIOUS && get_dist(other, speaker) < get_dist(body, speaker))
			return FALSE
	return TRUE

// --- Thinking ----------------------------------------------------------------------

/datum/npc_brain/proc/think()
	think_timer = null
	if(thinking || !body || body.stat != CONSCIOUS)
		return
	thinking = TRUE
	body.display_typing_indicator(60 SECONDS, TRUE)
	var/list/messages = list(
		list("role" = "system", "content" = record.system_prompt() + "\n\n" + reply_rules()),
		list("role" = "user", "content" = situation()),
	)
	if(!SSnpc_mind.ask(messages, CALLBACK(src, PROC_REF(on_thought)), 220, 0.85, TRUE, TRUE))
		thinking = FALSE
		body.clear_typing_indicator()

/datum/npc_brain/proc/reply_rules()
	return {"Answer ONLY with a JSON object, no other text:
{"emote": "optional short action you do, third person without your name, e.g. 'scratches her chin' - or empty",
 "say": "what you say out loud, one to three sentences - or empty to stay silent",
 "remember": "optional: one short fact worth remembering for years (a name, a promise, a slight) - or empty",
 "opinion": {"Name": number from -3 to 3 for how this changes your feelings about someone present}}
Talk like a real person of your time and place. You may refuse, lie, joke, get angry, ask questions or walk away in words. Never describe the other person's actions."}

/// What the NPC perceives right now, as the mind's prompt.
/datum/npc_brain/proc/situation()
	var/list/lines = list()
	var/area/A = get_area(body)
	lines += "Where you are: [A ? A.name : "somewhere"]. It is [lowertext(station_time_timestamp("hh:mm"))], [GLOB.tod || "day"]."
	var/list/nearby = list()
	for(var/mob/living/carbon/human/H in view(NPC_HEAR_RANGE, body))
		if(H == body || H.stat == DEAD)
			continue
		nearby += "[H.name] ([npc_describe_person(H)], [get_dist(body, H)] steps away)"
	lines += length(nearby) ? "People near you: [jointext(nearby, "; ")]." : "Nobody else is near."
	var/obj/item/held = body.get_active_held_item()
	if(held)
		lines += "You are holding: [held.name]."
	var/hurt = body.health < body.maxHealth * 0.6
	if(hurt)
		lines += "You are hurt."
	if(length(log))
		lines += "What just happened:\n[jointext(log, "\n")]"
	if(addressed_by)
		lines += "\n[addressed_by.name] is talking to you. How do you respond?"
	return jointext(lines, "\n")

/proc/npc_describe_person(mob/living/carbon/human/H)
	var/list/bits = list()
	bits += H.gender == FEMALE ? "a woman" : "a man"
	if(H.dna?.species)
		bits += lowertext(H.dna.species.name)
	var/obj/item/weapon = H.get_active_held_item()
	if(istype(weapon, /obj/item/rogueweapon))
		bits += "holding a [weapon.name]"
	if(H.wear_armor)
		bits += "in [H.wear_armor.name]"
	return jointext(bits, ", ")

// --- Acting on the thought -------------------------------------------------------------

/datum/npc_brain/proc/on_thought(text, error)
	thinking = FALSE
	if(!body || QDELETED(body))
		return
	body.clear_typing_indicator()
	if(!text || body.stat != CONSCIOUS)
		return
	var/list/reply = npc_parse_reply(text)
	if(!reply)
		// A small model sometimes forgets the format; treat it all as speech.
		reply = list("say" = text)
	if(addressed_by && get_dist(body, addressed_by) <= NPC_HEAR_RANGE)
		body.face_atom(addressed_by)
	var/emote_text = npc_clean_line(reply["emote"], 200)
	var/say_text = npc_clean_line(reply["say"], 400)
	if(emote_text)
		body.emote("me", 1, emote_text, TRUE, custom_me = TRUE)
		note("You [emote_text].")
	if(say_text)
		if(emote_text)
			addtimer(CALLBACK(body, TYPE_PROC_REF(/atom/movable, say), say_text), 1 SECONDS)
		else
			body.say(say_text)
		note("You said: \"[say_text]\"")
	var/remember = npc_clean_line(reply["remember"], 200)
	if(remember)
		record.memories += remember
		if(length(record.memories) > NPC_MEMORY_CAP)
			record.memories.Cut(1, 2)
	var/list/opinions = reply["opinion"]
	if(islist(opinions))
		for(var/who in opinions)
			var/delta = clamp(text2num("[opinions[who]]") || 0, -3, 3)
			if(!delta || !npc_is_present(body, who))
				continue
			var/list/rel = record.relationships[who] || list(0, "")
			rel[1] = clamp(rel[1] + delta * 5, -100, 100)
			rel[2] = rel[1] >= 40 ? "a friend" : (rel[1] >= 10 ? "you like them" : (rel[1] <= -40 ? "you hate them" : (rel[1] <= -10 ? "you dislike them" : "you barely know them")))
			record.relationships[who] = rel
	if(remember || islist(opinions))
		record.save()

/proc/npc_parse_reply(text)
	var/start = findtext(text, "{")
	var/finish = findlasttext(text, "}")
	if(!start || finish <= start)
		return null
	try
		var/list/L = json_decode(copytext(text, start, finish + 1))
		return islist(L) ? L : null
	catch
		return null

/proc/npc_clean_line(value, max_len)
	if(!istext(value))
		return null
	var/line = trim(copytext(strip_html_simple(value), 1, max_len))
	// Emotes and speech come from the model; keep them to one line.
	line = replacetext(line, "\n", " ")
	return length(line) ? line : null

/proc/npc_is_present(mob/living/body, name)
	for(var/mob/living/L in view(NPC_HEAR_RANGE, body))
		if(L.name == name)
			return TRUE
	return FALSE
