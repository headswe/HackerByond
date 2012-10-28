obj/device
	proc/OnMobUse(mob)
obj/device/Computer
	name = "Computer"
	icon = 'player.dmi'
	icon_state = ""
	var/datum/os/system = new()
obj/device/Computer/New()
	..()
	system.Boot()
obj/device/Computer/OnMobUse(mob/M)
	M.SetActiveSystem(src.system)
obj/device/Click(location,control,params)
	world << "MELLOW"
	if(usr in range(1,src))
		OnMobUse(usr)
obj/item


