// =
// = The Unified (-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Generic Cable Class

/obj/cabling
	icon_state = "0-1"
	layer = 2.5
	level = 1
	anchored = 1

	var/Direction1 = 0
	var/Direction2 = 0
	var/list/ConnectableTypes = list( /obj/device )
	var/NetworkControllerType = /datum/UnifiedNetworkController
	var/DropCablePieceType = null
	var/EquivalentCableType = /obj/cabling


/obj/cabling/New(var/Location, var/NewDirection1 = -1, var/NewDirection2 = -1)

	if (!Location)
		return

	..(Location)

	var/Dash = findtext(icon_state, "-")

	Direction1 = text2num( copytext( icon_state, 1, Dash ) )
	Direction2 = text2num( copytext( icon_state, Dash + 1 ) )

	if (NewDirection1 != -1)
		Direction1 = NewDirection1

	if (NewDirection2 != -1)
		Direction2 = NewDirection2

	if(level == 1)
		var/turf/T = src.loc
		hide(T.intact)

	if(1)	//if (ticker) TODO: Fix?
		var/list/P = AllConnections(get_step(Location, Direction1), 1) | AllConnections(get_step(Location, Direction2), 1)

		if(locate(/obj/cabling) in P)
			var/obj/cabling/Cable = locate(/obj/cabling) in P
			var/datum/UnifiedNetwork/NewNetwork = Cable.Networks[Cable.EquivalentCableType]
			NewNetwork.CableBuilt(src, P)
		else
			var/datum/UnifiedNetwork/NewNetwork = CreateUnifiedNetwork(EquivalentCableType)
			NewNetwork.BuildFrom(src, NetworkControllerType)
	return


/obj/cabling/proc/UserTouched(var/mob/User)
		var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
		Network.Controller.CableTouched(src, User)


/obj/cabling/hide(var/intact)
	if(level == 1)
		invisibility = intact ? 101 : 0
	UpdateIcon()


/obj/cabling/proc/UpdateIcon()
	icon_state = "[Direction1]-[Direction2][invisibility?"-f":""]"
	return


/obj/cabling/Del()
	var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
	if (Network)
		Network.CutCable(src)
	..()


/obj/cabling/proc/CableConnections(var/turf/Target, var/IncludeAlreadyConnected = 0)
	var/list/Cables = list()
	var/Direction = get_dir(Target, src)

	for(var/obj/cabling/Cable in Target)
		if ((!IncludeAlreadyConnected || !Cable.NetworkNumber[EquivalentCableType]) && Cable.EquivalentCableType == EquivalentCableType)
			if (Cable.Direction1 == Direction || Cable.Direction2 == Direction)
				Cables += Cable

	Cables -= src

	return Cables


/obj/cabling/proc/AllConnections(var/turf/Target, var/IncludeAlreadyConnected = 0)
	var/list/Connections = list( )
	var/Direction = get_dir(Target, src)

	for(var/obj/cabling/Cable in Target)
		if ((IncludeAlreadyConnected || !Cable.NetworkNumber[EquivalentCableType]) && Cable.EquivalentCableType == EquivalentCableType)
			if (Cable.Direction1 == Direction || Cable.Direction2 == Direction)
				Connections += Cable

	Direction = reverse_dir_3d(Direction)

	for(var/obj/O in Target)
		if (istype(O, /obj/cabling))
			continue
		if ((IncludeAlreadyConnected || !O.NetworkNumber[EquivalentCableType]) && CanConnect(O))
			if (Direction == Direction1 || Direction == Direction2)
				Connections += O

	Connections -= src
	return Connections


/obj/cabling/proc/CanConnect(var/obj/ConnectTo)
	for(var/Type in ConnectableTypes)
		if(istype(ConnectTo, Type))
			return 1
		else
	return 0


/obj/cabling/OnMobUse(var/mob/User)



/obj/cabling/proc/DropCablePieces()
	if (DropCablePieceType)
		new DropCablePieceType(loc, Direction1 ? 2 : 1)



/obj/cabling/proc/ObjectBuilt(var/obj/Object)
	var/Direction = get_dir(src, Object)
	if (Direction1 != Direction && Direction2 != Direction)
		return
	if(CanConnect(Object))
	//	world << "Can Connect, adding"
		var/datum/UnifiedNetwork/Network = Networks[EquivalentCableType]
		Network.AddNode(Object, src)

/obj/New()
	..()
//	if (ticker) TODO: fix,remove,implement?
	if(1)
		for(var/Direction in list(0) | cardinal)
			for (var/obj/cabling/Cable in get_step(src, Direction))
				Cable.ObjectBuilt(src)
