mob
	icon = 'player.dmi'
	var/datum/os/current
mob/verb/test()
	src.client.verbs += /client/proc/debug_variables
mob/proc/SetActiveSystem(var/datum/os/sys)
	if(current)
		current.mob_users -= src
	current = sys
	current.mob_users += src

	winshow(src.client,"console",1)
	src.client << output(null, "console.text")
	for(var/entry in sys.screen)
		src.client << output(entry, "console.text")

mob/verb/say(msg as text)
	for(var/mob/A in viewers())
		A << "[src.name] said, \"[msg]\""