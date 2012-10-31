obj/wall
	density = 1
	opacity = 1
	icon = 'wall.dmi'
	icon_state = "wall"

	 // TODO: IMPLEMENT
turf
	icon = 'floor.dmi'
	icon_state = ""
	var/intact = 0
turf/floor

obj/proc/hide() // TODO: IMPLEMENT
obj
	var/level = 1
	var/anchored = 0
	var/list/NetworkNumber = list( )
	var/list/Networks = list( )
	proc/OnMobUse()
obj/verb/examine()
var/list/AllNetworks = list( )
var/list/LANnet = list()
var/list/cardinal = list(NORTH,EAST,WEST,SOUTH)

/obj/cabling/Network
	icon = 'power_cond.dmi'

	name = "Cat 5 TP Cable"

	ConnectableTypes = list( /obj/device )
	NetworkControllerType = /datum/UnifiedNetworkController/Network
	DropCablePieceType = /obj/item/CableCoil/Network
	EquivalentCableType = /obj/cabling/Network
/obj/item/CableCoil/Network
	icon_state     = "whitecoil3"
	icon           = 'Coils.dmi'


	CoilColour = "generic"
	BaseName   = "TP"
	ShortDesc  = "A piece of TP Cable"
	LongDesc   = "A long piece of TP Cable"
	CoilDesc   = "A Spool of TP Cable"
	MaxAmount  = 30
	Amount     = 30
	CableType  = /obj/cabling/Network
	CanLayDiagonally = 0

mob/verb/dispNetWork()
	var/i = 0
	for(var/datum/UnifiedNetworkController/Network/B in LANnet)
		world << i++
		world << B.router
		for(var/obj/A in B.Network.Nodes)
			world << A

world/New()
	MasterProcess()
proc/MasterProcess()
	set background = 1
	for(var/name in AllNetworks)
		for(var/datum/UnifiedNetwork/net in AllNetworks[name])
			net.Controller.Process()
	sleep(1)
	spawn() MasterProcess()

proc/string2ip(var/ip)
	var/list/subs = dd_text2list(ip,".")
	var/datum/ip/A = new(subs[1],subs[2],subs[3],subs[4],null)
	return A


proc/GetAdress(var/obj/device/A)
	var/datum/UnifiedNetwork/net = A.Networks[/obj/cabling/Network]
	var/datum/UnifiedNetworkController/Network/con = net.Controller
	if(istype(A,/obj/device/router))
		if(A:system)
			A:system.this_ip = MakeAdress(A)
			world.log << "THIS IS A ROUTER!!!!!!!!!!!!!!!!!!"
			return
	if(!con.router || !con.router.system || !A)
		world << "NO ROUTER OR ROUTER SYSTEM OR NO A"
		return
	if(istype(A,/obj/device/computer))
		if(A:system)
			A:system.this_ip = con.router.system.this_ip.GetNewIP()
			con.router.nodes[A:system:this_ip:String()] = A:system
		return // TODO: WHAT DO I INTEND?
proc/MakeAdress(var/obj/device/router/R)
	if(R)
		var/x1 = rand(1,255)
		var/x2  = rand(1,255)
		// TODO: ADD CHECKS SO THAT NOT ONE IP GET THE SAME X1/X2
		var/datum/ip/IP = new /datum/ip(x1,x2,1,1,R)
		world.log << IP.String()
		return IP