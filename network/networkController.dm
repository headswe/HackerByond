/datum/UnifiedNetworkController/Network
	var/obj/device/router/router = null
	AttachNode(var/obj/Node)
		if(Node.type == /obj/device/router)
			if(!router)
				var/obj/device/router/R = Node
				router = R
		else if(istype(Node,/obj/device/Computer))
			if(router)
				www.GetAdressFrom(router,Node:system)
		return

	DetachNode(var/obj/Node)
		if(router == Node)
			// TODO:FIND ANOTHER TO TAKE OVER.
			// OTHERWISE RESET ALL IPS TO NOTHING
			return
		else if(istype(Node,/obj/device/Computer))
			router.nodes[Node:system:this_ip.String()] = null
			router.removedNode += Node:system:this_ip
			Node:system:this_ip = null
		return

	AddCable(var/obj/cabling/Cable)
		return

	RemoveCable(var/obj/cabling/Cable)
		return

	StartSplit(var/datum/UnifiedNetwork/NewNetwork)
		return

	FinishSplit(var/datum/UnifiedNetwork/NewNetwork)
		return

	CableCut(var/obj/cabling/Cable, var/mob/User)
		return

	CableBuilt(var/obj/cabling/Cable, var/mob/User)
		return

	Initialize()
		LANnet += src
		return

	Finalize()
		return

	BeginMerge(var/datum/UnifiedNetwork/TargetNetwork, var/Slave)
		return

	FinishMerge()
		return

	DeviceUsed(var/obj/item/device/Device, var/obj/cabling/Cable, var/mob/User)
		return

	CableTouched(var/obj/cabling/Cable, var/mob/User)
		return

	Process()
		return