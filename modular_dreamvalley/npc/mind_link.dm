// The link to the NPC mind: a local llama.cpp server the repo ships and starts
// (tools/dreamvalley/npc_ai/start_npc_ai.bat). The game sends it a conversation
// and gets back what the NPC says or decides. Requests never block the game;
// if the server is not running, every request fails quietly and NPCs carry on
// with ordinary behaviour.

#define NPC_MIND_URL "http://127.0.0.1:8089"
/// How many requests may be in flight at once (matches the server's -np).
#define NPC_MIND_PARALLEL 1
/// A request that takes longer than this is abandoned.
#define NPC_MIND_TIMEOUT (90 SECONDS)

SUBSYSTEM_DEF(npc_mind)
	name = "NPC Mind"
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// Whether the server answered the last health check.
	var/online = FALSE
	var/next_health = 0
	var/datum/http_request/health_request
	/// Waiting to be sent.
	var/list/datum/npc_mind_request/queue = list()
	/// Sent, waiting for an answer.
	var/list/datum/npc_mind_request/active = list()
	/// Numbers for the Workshop.
	var/answered = 0
	var/failed = 0
	var/last_latency = 0

/// One question to the mind.
/datum/npc_mind_request
	var/list/messages
	var/datum/callback/on_done
	var/max_tokens = 256
	var/temperature = 0.8
	/// Ask for a JSON object back instead of free text.
	var/json_mode = FALSE
	var/datum/http_request/http
	var/sent_at = 0

/// Queues a chat for the mind. on_done is invoked with (reply text or null, error text or null).
/// Conversations pass priority = TRUE and jump the queue; background decisions wait.
/datum/controller/subsystem/npc_mind/proc/ask(list/messages, datum/callback/on_done, max_tokens = 256, temperature = 0.8, json_mode = FALSE, priority = FALSE)
	var/datum/npc_mind_request/R = new
	R.messages = messages
	R.on_done = on_done
	R.max_tokens = max_tokens
	R.temperature = temperature
	R.json_mode = json_mode
	if(!online)
		on_done?.Invoke(null, "The NPC mind is not running. Start tools/dreamvalley/npc_ai/start_npc_ai.bat.")
		return null
	if(priority)
		queue.Insert(1, R)
	else
		queue += R
	return R

/datum/controller/subsystem/npc_mind/fire(resumed)
	check_health()
	// Collect answers.
	for(var/datum/npc_mind_request/R as anything in active.Copy())
		if(world.time - R.sent_at > NPC_MIND_TIMEOUT)
			active -= R
			failed++
			R.on_done?.Invoke(null, "The mind took too long to answer.")
			continue
		if(!R.http.is_complete())
			continue
		active -= R
		finish(R)
	// Send what fits.
	while(online && length(queue) && length(active) < NPC_MIND_PARALLEL)
		var/datum/npc_mind_request/R = queue[1]
		queue.Cut(1, 2)
		send(R)

/datum/controller/subsystem/npc_mind/proc/check_health()
	if(health_request)
		if(!health_request.is_complete())
			return
		var/datum/http_response/response = health_request.into_response()
		online = !response.errored && response.status_code == 200
		health_request = null
	if(world.time < next_health)
		return
	next_health = world.time + (online ? 30 SECONDS : 10 SECONDS)
	health_request = new
	health_request.prepare(RUSTG_HTTP_METHOD_GET, "[NPC_MIND_URL]/health")
	health_request.begin_async()

/datum/controller/subsystem/npc_mind/proc/send(datum/npc_mind_request/R)
	var/list/body = list(
		"model" = "npc",
		"messages" = R.messages,
		"max_tokens" = R.max_tokens,
		"temperature" = R.temperature,
	)
	if(R.json_mode)
		body["response_format"] = list("type" = "json_object")
	R.http = new
	R.http.prepare(RUSTG_HTTP_METHOD_POST, "[NPC_MIND_URL]/v1/chat/completions", json_encode(body), list("Content-Type" = "application/json"))
	R.http.begin_async()
	R.sent_at = world.time
	active += R

/datum/controller/subsystem/npc_mind/proc/finish(datum/npc_mind_request/R)
	var/datum/http_response/response = R.http.into_response()
	if(response.errored || response.status_code != 200)
		failed++
		R.on_done?.Invoke(null, response.error || "The mind answered with status [response.status_code].")
		return
	var/text
	try
		var/list/decoded = json_decode(response.body)
		var/list/choice = decoded["choices"][1]
		text = choice["message"]["content"]
	catch
		text = null
	if(!text)
		failed++
		R.on_done?.Invoke(null, "The mind's answer could not be read.")
		return
	answered++
	last_latency = world.time - R.sent_at
	R.on_done?.Invoke(trim(text), null)
