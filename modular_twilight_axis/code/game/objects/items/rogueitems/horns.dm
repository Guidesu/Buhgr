/obj/item/signal_horna
	name = "signal horn"
	desc = "Used to muster troops and sound the alarm."
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "signal_horn"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	var/last_horn


	grid_height = 32
	grid_width = 64

/obj/item/signal_horna/attack_self(mob/living/user)
	. = ..()
	if(world.time < last_horn + 30 SECONDS)
		to_chat(user, "My lungs need rest before I can blow the [src.name] again!")
		return
	user.visible_message("<span class='warning'>[capitalize(user.name)] is about to blow the [src.name]!</span>")
	if(do_after(user, 15))
		last_horn = world.time
		sound_horn(user)

/obj/item/signal_horna/proc/sound_horn(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/signalhorn.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/signalhorn.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the blare of a signal horn somewhere[disttext][dirtext]!</span>")

/datum/intent/rally
	name = "Muster call"
	desc = "On a single blast of the horn, all under command must report for formation."
	icon_state = "inrally"
	no_attack = TRUE
	candodge = TRUE
	canparry = TRUE

/datum/intent/alert
	name = "Alarm"
	desc = "On a double blast of the horn, all under command must arrive armed as soon as possible."
	icon_state = "inalert"
	no_attack = TRUE
	candodge = TRUE
	canparry = TRUE

/datum/intent/alarm
	name = "Full alarm"
	desc = "On a triple blast of the horn, all under command must drop everything and come to the rescue."
	icon_state = "inalarm"
	no_attack = TRUE
	candodge = TRUE
	canparry = TRUE

/obj/item/signal_hornn/red
	name = "sergeant's horn"
	desc = "Used to muster troops and sound the alarm."
	possible_item_intents = list(/datum/intent/rally, /datum/intent/alert, /datum/intent/alarm)
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "signal_horn_red"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	var/last_horn


	grid_height = 32
	grid_width = 64

/obj/item/signal_hornn/red/attack_self(mob/living/user)
	. = ..()
	if(world.time < last_horn + 30 SECONDS)
		to_chat(user, "My lungs need rest before I can blow the [src.name] again!")
		return
	user.visible_message("<span class='warning'>[capitalize(user.name)] is about to blow the [src.name]!</span>")
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/rally)
		last_horn = world.time
		sound_horn_rally_red(user)
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/alert)
		last_horn = world.time
		sound_horn_alert_red(user)
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/alarm)
		last_horn = world.time
		sound_horn_alarm_red(user)

/obj/item/signal_hornn/red/proc/sound_horn_rally_red(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the guard horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/rallyRetinue.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/rallyRetinue.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the guard horn calling a muster somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/red/proc/sound_horn_alert_red(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the guard horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/AlertRetinue.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/AlertRetinue.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the guard horn sounding the alarm somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/red/proc/sound_horn_alarm_red(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the guard horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/FullAlertRetinue.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/FullAlertRetinue.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the guard horn sounding the full alarm somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/blue
	name = "town guard horn"
	desc = "Used to muster troops and sound the alarm."
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "signal_horn_blue"
	possible_item_intents = list(/datum/intent/rally, /datum/intent/alert, /datum/intent/alarm)
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	var/last_horn


	grid_height = 32
	grid_width = 64

/obj/item/signal_hornn/blue/attack_self(mob/living/user)
	. = ..()
	if(world.time < last_horn + 30 SECONDS)
		to_chat(user, "My lungs need rest before I can blow the [src.name] again!")
		return
	user.visible_message("<span class='warning'>[capitalize(user.name)] is about to blow the [src.name]!</span>")
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/rally)
		last_horn = world.time
		sound_horn_rally_blue(user)
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/alert)
		last_horn = world.time
		sound_horn_alert_blue(user)
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/alarm)
		last_horn = world.time
		sound_horn_alarm_blue(user)

/obj/item/signal_hornn/blue/proc/sound_horn_rally_blue(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the watch horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/rallyWatchmen.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/rallyWatchmen.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the watch horn calling a muster somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/blue/proc/sound_horn_alert_blue(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the watch horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/AlertWatchmen.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/AlertWatchmen.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the watch horn sounding the alarm somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/blue/proc/sound_horn_alarm_blue(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the watch horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/FullAlertWatchmen.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/FullAlertWatchmen.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the watch horn sounding the full alarm somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/green
	name = "vanguard's horn"
	desc = "Used to muster troops and sound the alarm."
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "signal_horn_green"
	possible_item_intents = list(/datum/intent/rally, /datum/intent/alert, /datum/intent/alarm)
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	var/last_horn


	grid_height = 32
	grid_width = 64

/obj/item/signal_hornn/green/attack_self(mob/living/user)
	. = ..()
	if(world.time < last_horn + 30 SECONDS)
		to_chat(user, "My lungs need rest before I can blow the [src.name] again!")
		return
	user.visible_message("<span class='warning'>[capitalize(user.name)] is about to blow the [src.name]!</span>")
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/rally)
		last_horn = world.time
		sound_horn_rally_green(user)
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/alert)
		last_horn = world.time
		sound_horn_alert_green(user)
	if(do_after(user, 15) && user.used_intent.type == /datum/intent/alarm)
		last_horn = world.time
		sound_horn_alarm_green(user)

/obj/item/signal_hornn/green/proc/sound_horn_rally_green(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the vanguard horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/rallyVanguard.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/rallyVanguard.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the vanguard horn calling a muster somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/green/proc/sound_horn_alert_green(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the vanguard horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/AlertVanguard.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/AlertVanguard.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the vanguard horn sounding the alarm somewhere[disttext][dirtext]!</span>")

/obj/item/signal_hornn/green/proc/sound_horn_alarm_green(mob/living/user)
	user.visible_message("<span class='warning'>[capitalize(user.name)] blows the vanguard horn!</span>")
	playsound(src, 'modular_twilight_axis/sound/items/horn/FullAlertVanguard.ogg', 100, TRUE)
	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the"
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = ", but I can't tell where it came from"
		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " very close"
			if(20 to 40)
				disttext = " close"
			if(40 to 80)
				disttext = ""
			if(80 to 160)
				disttext = " far away"
			else
				disttext = " very far away"

		//sound played for other players
		player.playsound_local(get_turf(player), 'modular_twilight_axis/sound/items/horn/FullAlertVanguard.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, "<span class='warning'>I hear the vanguard horn sounding the full alarm somewhere[disttext][dirtext]!</span>")

#define WARDEN_AMBUSH_MIN 2
#define WARDEN_AMBUSH_MAX 9

/obj/item/signal_horn/vanguard_battle
	name = "vanguard battle horn"
	desc = "A horn used by the Vanguard bog patrols. Blowing it attracts the attention of various creechurs and rapscallions, enabling the Vanguard to clear them out."

/obj/item/signal_horn/vanguard_battle/sound_horn(mob/living/user)
	user.visible_message(span_userdanger("[user] blows the horn!"))
	playsound(src, 'sound/items/horn/bogguardhorn.ogg', 100, TRUE)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/turf/origin_turf = get_turf(src)

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7 || distance > 21) // two screens away
			continue
		var/dirtext = " to the "
		var/direction = get_dir(player, origin_turf)
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = "although I cannot make out an exact direction"

		player.playsound_local(get_turf(player), 'sound/items/horn/bogguardhorn.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, span_warning("I hear the Vanguard battle horn somewhere [dirtext]"))

	var/random_ambushes = 4 + rand(0,2) // 4 - 6 ambushes
	var/did_ambush = FALSE
	for(var/i = 0, i < random_ambushes, i++)
		var/silent = (i != 0)
		var/success = user.consider_ambush(TRUE, TRUE, min_dist = WARDEN_AMBUSH_MIN, max_dist = WARDEN_AMBUSH_MAX, silent = silent)
		if(success)
			did_ambush = TRUE
	return did_ambush

#undef WARDEN_AMBUSH_MIN
#undef WARDEN_AMBUSH_MAX
