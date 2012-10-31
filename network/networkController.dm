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
				R.system.this_ip = www.GetAdress(R.system)
				world.log << "Router added [R.system.this_ip.String()]"
				for(var/obj/device/Computer/com in Network.Nodes)
					www.GetAdressFrom(R,com.system)
					world.log << "IP updated for computerz"
		else if(istype(Node,/obj/device/Computer))
			if(router)
				if(!Node:system)
					spawn while(Node:system == null)
						world << "waiting for system"
						sleep(10)
				www.GetAdressFrom(router,Node:system)
				router.nodes[Node:system:this_ip:String()] = Node:system
				world.log << "System device added"
			else
				world.log << "NO router found for NET"
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
		if(!router)
			return
		for(var/obj/device/Computer/C in Network.Nodes)
			if(C.system.this_ip == null)
				www.GetAdressFrom(router,C.system)
				world << "IP updated for computerz"
		return