mob
mob/New()
	..()
	comp = new()
	comp.owner += src
	comp.Boot()