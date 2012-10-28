obj/device/router
	name = "router"
	var/datum/os/system = new()
obj/device/router/New()
	..()
	system.Boot()