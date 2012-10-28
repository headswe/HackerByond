mob
	icon = 'player.dmi'
	var/datum/os/current
mob/proc/SetActiveSystem(var/datum/os/sys)
	if(current)
		current.mob_users -= src
	current = sys
	current.mob_users += src
	winshow(src.client,"console",1)