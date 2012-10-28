/datum/UnifiedNetworkController/Network
	var/base_ip
	AttachNode(var/obj/Node)
		if(Node.type == /obj/device/router)
			if(!base_ip)
				var/obj/device/router/R = Node
				base_ip = R.system.this_ip
		return

	DetachNode(var/obj/Node)
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