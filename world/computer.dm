obj/device
obj/device/Computer
	name = "Computer"
	icon = 'player.dmi'
	icon_state = ""
	var/datum/os/system
obj/device/Computer/New()
	..()
	system = new(src)
	system.Boot()
obj/device/Computer/OnMobUse(mob/M)
	M.SetActiveSystem(src.system)
obj/device/Click(location,control,params)
	world << "MELLOW"
	if(usr in range(1,src))
		OnMobUse(usr)
obj/item


/proc/reverse_dir_3d(dir)
	var/ndir = (dir&NORTH)?SOUTH : 0
	ndir |= (dir&SOUTH)?NORTH : 0
	ndir |= (dir&EAST)?WEST : 0
	ndir |= (dir&WEST)?EAST : 0
	ndir |= (dir&UP)?DOWN : 0
	ndir |= (dir&DOWN)?UP : 0
	return ndir