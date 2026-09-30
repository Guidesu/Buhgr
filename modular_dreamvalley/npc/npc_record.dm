// An NPC person: everything about them, kept as one JSON file under
// data/dreamvalley/npcs/. Made and edited in the NPC Workshop (workshop.dm),
// spawned into the world as a real human, and - from phase 2 on - given a mind.

#define NPC_RECORD_DIR "data/dreamvalley/npcs/"

/// Personality sliders, -100 to 100: id = list(low word, high word).
GLOBAL_LIST_INIT(npc_trait_axes, list(
	"boldness" = list("timid", "bold"),
	"warmth" = list("cold", "warm"),
	"honesty" = list("deceitful", "honest"),
	"piety" = list("irreverent", "pious"),
	"greed" = list("generous", "greedy"),
	"curiosity" = list("incurious", "curious"),
	"temper" = list("patient", "hot-tempered"),
	"humour" = list("grave", "playful"),
))

/// id = record, for every NPC on disk.
GLOBAL_LIST_EMPTY(npc_records)
/// id = the living NPC, for every one spawned.
GLOBAL_LIST_EMPTY(npc_spawned)

/datum/npc_record
	var/id
	var/name = "Nameless"
	var/gender = MALE
	var/age = "Adult"
	var/species_path = /datum/species/human/northern
	/// Job title whose outfit and skills they wear.
	var/job_title
	var/origin_path
	var/domain_path
	var/god_path
	var/list/traits = list()
	/// How they talk.
	var/speech = ""
	var/backstory = ""
	var/goals = ""
	/// Things they remember (grows from phase 2).
	var/list/memories = list()
	/// name = list(opinion -100..100, note)
	var/list/relationships = list()
	/// Spawn at round start.
	var/autospawn = FALSE
	/// Where to autospawn: an area name, or blank for anywhere sensible.
	var/home = ""
	var/created
	var/updated

/datum/npc_record/New()
	for(var/axis in GLOB.npc_trait_axes)
		traits[axis] = 0

/proc/npc_new_id()
	return "npc_[world.realtime]_[rand(1000, 9999)]"

// --- Saving ------------------------------------------------------------------------

/datum/npc_record/proc/to_list()
	return list(
		"id" = id, "name" = name, "gender" = gender, "age" = age,
		"species" = "[species_path]", "job" = job_title,
		"origin" = origin_path ? "[origin_path]" : null,
		"domain" = domain_path ? "[domain_path]" : null,
		"god" = god_path ? "[god_path]" : null,
		"traits" = traits, "speech" = speech, "backstory" = backstory, "goals" = goals,
		"memories" = memories, "relationships" = relationships,
		"autospawn" = autospawn, "home" = home, "created" = created, "updated" = updated,
	)

/datum/npc_record/proc/from_list(list/L)
	id = L["id"]
	name = L["name"] || name
	gender = L["gender"] || gender
	age = L["age"] || age
	species_path = text2path("[L["species"]]") || species_path
	job_title = L["job"]
	origin_path = text2path("[L["origin"]]")
	domain_path = text2path("[L["domain"]]")
	god_path = text2path("[L["god"]]")
	var/list/saved_traits = L["traits"]
	for(var/axis in GLOB.npc_trait_axes)
		traits[axis] = clamp(text2num("[saved_traits?[axis]]") || 0, -100, 100)
	speech = L["speech"] || ""
	backstory = L["backstory"] || ""
	goals = L["goals"] || ""
	memories = islist(L["memories"]) ? L["memories"] : list()
	relationships = islist(L["relationships"]) ? L["relationships"] : list()
	autospawn = !!L["autospawn"]
	home = L["home"] || ""
	created = L["created"]
	updated = L["updated"]

/datum/npc_record/proc/save()
	if(!id)
		id = npc_new_id()
	if(!created)
		created = time2text(world.realtime, "YYYY-MM-DD hh:mm")
	updated = time2text(world.realtime, "YYYY-MM-DD hh:mm")
	rustg_file_write(json_encode(to_list()), "[NPC_RECORD_DIR][id].json")
	GLOB.npc_records[id] = src

/datum/npc_record/proc/remove()
	fdel("[NPC_RECORD_DIR][id].json")
	GLOB.npc_records -= id

/proc/npc_load_records()
	GLOB.npc_records = list()
	for(var/file_name in flist(NPC_RECORD_DIR))
		if(copytext(file_name, -5) != ".json")
			continue
		var/raw = file2text("[NPC_RECORD_DIR][file_name]")
		if(!raw)
			continue
		var/list/L
		try
			L = json_decode(raw)
		catch
			continue
		if(!islist(L) || !L["id"])
			continue
		var/datum/npc_record/R = new
		R.from_list(L)
		GLOB.npc_records[R.id] = R

// --- Describing them -----------------------------------------------------------------

/datum/npc_record/proc/species_name()
	var/datum/species/S = species_path
	return initial(S.name)

/datum/npc_record/proc/origin_name()
	if(!origin_path)
		return "somewhere nobody would know"
	var/datum/virtue/origin/O = origin_path
	return initial(O.origin_name)

/datum/npc_record/proc/god_name()
	var/datum/patron/P = GLOB.patronlist[god_path]
	return P?.name

/datum/npc_record/proc/domain_name()
	var/datum/domain/D = get_divine_domain(domain_path)
	return D?.name

/// Their personality in words, from the sliders.
/datum/npc_record/proc/personality_words()
	var/list/words = list()
	for(var/axis in GLOB.npc_trait_axes)
		var/v = traits[axis]
		var/list/ends = GLOB.npc_trait_axes[axis]
		if(v >= 60)
			words += "very [ends[2]]"
		else if(v >= 20)
			words += ends[2]
		else if(v <= -60)
			words += "very [ends[1]]"
		else if(v <= -20)
			words += ends[1]
	return length(words) ? english_list(words) : "even-tempered and ordinary"

/// The standing instructions the mind gets for this person.
/datum/npc_record/proc/system_prompt()
	var/list/lines = list()
	lines += "You are [name], a living person in the world of Palimpseste - a patchwork of lands that bled in from other worlds, each certain it was always here. You are not an assistant and you do not know you are in a game."
	lines += "You are a [age == "Adult" ? "" : "[lowertext(age)] "][gender == FEMALE ? "woman" : "man"], a [species_name()], from [origin_name()]."
	if(job_title)
		lines += "You work as a [lowertext(job_title)]."
	if(god_name())
		lines += "You worship [god_name()][domain_name() ? ", a god of the [domain_name()]" : ""]."
	lines += "You are [personality_words()]."
	if(speech)
		lines += "How you talk: [speech]"
	if(backstory)
		lines += "Your past: [backstory]"
	if(goals)
		lines += "What you want: [goals]"
	if(length(relationships))
		var/list/rel = list()
		for(var/other in relationships)
			var/list/r = relationships[other]
			rel += "[other] ([r[2] || (r[1] >= 0 ? "you like them" : "you dislike them")])"
		lines += "People you know: [jointext(rel, "; ")]."
	if(length(memories))
		lines += "Things you remember: [jointext(memories.Copy(max(1, length(memories) - 9)), " ")]"
	lines += "Stay in character always. Speak as yourself, briefly, like a real person in a rough medieval world - one to three sentences. Never mention being an AI, a model or a game."
	return jointext(lines, "\n")

/datum/npc_record/proc/summary()
	return "[species_name()][job_title ? ", [lowertext(job_title)]" : ""], from [origin_name()]"

// --- Into the world -----------------------------------------------------------------

/mob/living/carbon/human
	/// The NPC record this body belongs to, if it is a Workshop NPC.
	var/npc_record_id

/// Jobs whose outfit an NPC can wear: title = job.
/proc/npc_job_choices()
	var/static/list/choices
	if(choices)
		return choices
	choices = list()
	for(var/job_type in subtypesof(/datum/job/roguetown))
		var/datum/job/J = job_type
		if(initial(J.title) && initial(J.outfit))
			choices[initial(J.title)] = job_type
	choices = sortList(choices)
	return choices

/datum/npc_record/proc/spawn_at(turf/T)
	if(!T)
		return null
	despawn()
	var/mob/living/carbon/human/H = new(T)
	H.set_species(species_path)
	H.gender = gender
	H.dna.species.random_character(H)
	H.real_name = name
	H.name = name
	H.age = age
	H.npc_record_id = id
	if(god_path && GLOB.patronlist[god_path])
		H.set_patron(god_path)
	if(domain_path)
		H.divine_domain = get_divine_domain(domain_path)
	var/job_type = job_title ? npc_job_choices()[job_title] : null
	if(job_type)
		var/datum/job/J = job_type
		H.job = job_title
		H.equipOutfit(initial(J.outfit))
	H.update_body()
	H.update_hair()
	H.update_body_parts(TRUE)
	GLOB.npc_spawned[id] = H
	H.npc_brain = new /datum/npc_brain(src, H)
	return H

/datum/npc_record/proc/despawn()
	var/mob/living/carbon/human/H = GLOB.npc_spawned[id]
	GLOB.npc_spawned -= id
	if(H && !QDELETED(H))
		qdel(H)

/datum/npc_record/proc/spawned_mob()
	var/mob/living/carbon/human/H = GLOB.npc_spawned[id]
	return (H && !QDELETED(H)) ? H : null

/// A plausible stranger, for the Workshop's dice button.
/proc/npc_roll_random()
	var/datum/npc_record/R = new
	R.gender = pick(MALE, FEMALE)
	R.species_path = pick(NPC_RACES_TYPES)
	R.name = random_unique_name(R.gender)
	R.age = pick("Adult", "Adult", "Middle-Aged", "Old")
	var/list/origins = subtypesof(/datum/virtue/origin/palimpseste)
	if(length(origins))
		R.origin_path = pick(origins)
	var/list/domains = GLOB.divine_domains.Copy()
	if(length(domains))
		R.domain_path = pick(domains)
		var/datum/domain/D = GLOB.divine_domains[R.domain_path]
		if(length(D.gods))
			R.god_path = pick(D.gods)
	var/list/jobs = npc_job_choices()
	if(length(jobs))
		R.job_title = pick(jobs)
	for(var/axis in GLOB.npc_trait_axes)
		R.traits[axis] = rand(-8, 8) * 10
	R.speech = pick("plain and short", "chatty, full of gossip", "slow and careful", "rough, swears a lot", "polite and formal", "mumbling, avoids eye contact", "loud and cheerful")
	return R
