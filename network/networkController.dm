/datum/UnifiedNetworkController/Network
	var/obj/device/router/router = null
	AttachNode(var/obj/Node)
		if(Node.type == /obj/device/router)
			if(!router)
				var/obj/device/router/R = Node
				router = R
				if(!R.system.holder)
					R.system.holder = R
					world.log << "Holder was empty"
				GetAdress(R)
				world.log << "Router added [R.system.this_ip.String()]"
		//		for(var/obj/device/computer/com in Network.Nodes)
		//			GetAdress(com)
		//			world.log << "IP updated for computerz"
		else if(istype(Node,/obj/device/computer))
			if(router)
				if(!Node:system)
					spawn while(Node:system == null)
						world << "waiting for system"
						sleep(10)
				GetAdress(Node)
				world.log << "System device added"
			else
				world.log << "NO router found for NET"
		return
	DetachNode(var/obj/Node)
		if(router == Node)
			for(var/obj/device/router/R in Network.Nodes)
				if(R != Node)
					router = R
					router.system.this_ip = Node:system.this_ip
					Node:system.this_ip = null
					return
			return
		else if(istype(Node,/obj/device/computer) && router && Node:system != null)
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
		if(!router)
			return
		for(var/obj/device/computer/C in Network.Nodes)
			if(C.system.this_ip == null)
				GetAdress(C)
				world << "IP updated for computerz"
		return