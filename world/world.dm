obj/wall
	density = 1
	opacity = 1
	icon = 'wall.dmi'
	icon_state = "wall"

	 // TODO: IMPLEMENT
turf
	icon = 'floor.dmi'
	icon_state = ""
	var/intact = 1
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
