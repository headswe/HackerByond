obj/device/router
	name = "router"
	icon = 'player.dmi'
	var/datum/os/system
	var/list/nodes = list()
	var/list/removedNode = list()
obj/device/router/New()
	system = new(src)
	system.Boot()
	..()
obj/device/router/OnMobUse(mob/M)
	M.SetActiveSystem(src.system)
