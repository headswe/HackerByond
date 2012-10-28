// =
// = The Unified(-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Generic Cable Coil Class

/obj/item/CableCoil
	icon_state     = "whitecoil3"
	icon           = 'Coils.dmi'


	var/CoilColour = "generic"
	var/BaseName   = "Generic"
	var/ShortDesc  = "A piece of Generic Cable"
	var/LongDesc   = "A long piece of Generic Cable"
	var/CoilDesc   = "A Spool of Generic Cable"
	var/MaxAmount  = 30
	var/Amount     = 30
	var/CableType  = /obj/cabling
	var/CanLayDiagonally = 1

/obj/item/CableCoil/New(var/Location, var/Length)
	if(!Length)
		Length = MaxAmount
	Amount = Length
	icon_state     = "[CoilColour]coil"
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	UpdateIcon()
	name = "[BaseName] Cable"
	..(Location)

/obj/item/CableCoil/proc/UpdateIcon()
	if(Amount == 1)
		icon_state = "[CoilColour]coil1"
	else if(Amount == 2)
		icon_state = "[CoilColour]coil2"

	else
		icon_state = "[CoilColour]coil3"


/obj/item/CableCoil/examine()

	if (Amount == 1)
		usr << ShortDesc
	else if(Amount == 2)
		usr << LongDesc
	else
		usr << CoilDesc
		usr << "There are [Amount] usable lengths on the spool"



/obj/item/CableCoil/proc/UseCable(var/used)
	if(Amount < used)
		return 0
	else if (Amount == used)
		del src
		return 1
	else
		Amount -= used
		UpdateIcon()
		return 1

/obj/item/CableCoil/proc/LayOnTurf(turf/floor/Target, mob/user)

	if(!isturf(user.loc))
		return

	if(get_dist(Target,user) > 1)
		user << "You can't lay cable at a place that far away."
		return

	if(!Target.intact)
		user << "You can't lay cable there unless the floor tiles are removed."
		return

	else
		var/NewDirection

		if(user.loc == Target)
			NewDirection = user.dir
		else
			NewDirection = get_dir(Target, user)

		if(!CanLayDiagonally && (NewDirection & NewDirection - 1))
			user << "This type of cable cannot be laid diagonally."
			return

		var/obj/cabling/Cable = new CableType(null)

		for(var/obj/cabling/ExistingCable in Target)
			if((ExistingCable.Direction1 == NewDirection || ExistingCable.Direction2 == NewDirection) && ExistingCable.EquivalentCableType == Cable.EquivalentCableType)
				user << "There's already a cable at that position."
				del Cable
				return

		del Cable

		var/obj/cabling/NewCable = new CableType(Target)
		NewCable.Direction1 = 0
		NewCable.Direction2 = NewDirection
		NewCable.UpdateIcon()
		UseCable(1)

/obj/item/CableCoil/proc/JoinCable(obj/cabling/Cable, mob/user)


	var/turf/UserLocation = user.loc

	if(!isturf(UserLocation))
		return
	var/turf/CableLocation = Cable.loc

	if(!isturf(CableLocation) || CableLocation.intact)
		return
	if(get_dist(Cable, user) > 1)
		user << "You can't lay cable at a place that far away."
		return

	if(UserLocation == CableLocation)
		return

	var/DirectionToUser = get_dir(Cable, user)

	if(!CanLayDiagonally && (DirectionToUser & DirectionToUser - 1))
		user << "This type of cable cannot be laid diagonally."
		return

	if(Cable.Direction1 == DirectionToUser || Cable.Direction2 == DirectionToUser)
		if(UserLocation.intact)
			user << "You can't lay cable there unless the floor tiles are removed."
			return

		var/DirectionToCable = reverse_dir_3d(DirectionToUser)

		for(var/obj/cabling/UnifiedCable in UserLocation)
			if((UnifiedCable.Direction1 == DirectionToCable || UnifiedCable.Direction2 == DirectionToCable) && UnifiedCable.EquivalentCableType == Cable.EquivalentCableType)
				user << "There's already a [Cable.name] at that position."
				return

		var/obj/cabling/NewCable = new CableType(CableLocation, 0, DirectionToCable)
		NewCable.UserTouched(user)
		NewCable.UpdateIcon()
		UseCable(1)

	else if(Cable.Direction1 == 0)
		var/NewDirection1 = Cable.Direction2
		var/NewDirection2 = DirectionToUser

		if(NewDirection1 > NewDirection2)
			NewDirection1 = DirectionToUser
			NewDirection2 = Cable.Direction2

		for(var/obj/cabling/ExistingCable in CableLocation)
			if(ExistingCable == Cable || ExistingCable.EquivalentCableType != Cable.EquivalentCableType)
				continue
			if((ExistingCable.Direction1 == NewDirection1 && ExistingCable.Direction2 == NewDirection2) || (ExistingCable.Direction1 == NewDirection2 && ExistingCable.Direction2 == NewDirection1) )	// make sure no cable matches either direction
				user << "There's already a [Cable.name] at that position."
				return

		var/obj/cabling/NewCable = new CableType(CableLocation, NewDirection1, NewDirection2)
		NewCable.UserTouched(user)
		NewCable.UpdateIcon()

		del Cable

		UseCable(1)

	return

