/client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)






	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!param_var_name in O.vars)
			src << "A variable with this name ([param_var_name]) doesn't exist in this atom ([O])"
			return





		variable = param_var_name

		var_value = O.vars[variable]

		if(autodetect_class)
			if(isnull(var_value))
				usr << "Unable to determine variable type."
				class = null
				autodetect_class = null
			else if(isnum(var_value))
				usr << "Variable appears to be <b>NUM</b>."
				class = "num"
				dir = 1

			else if(istext(var_value))
				usr << "Variable appears to be <b>TEXT</b>."
				class = "text"

			else if(isloc(var_value))
				usr << "Variable appears to be <b>REFERENCE</b>."
				class = "reference"

			else if(isicon(var_value))
				usr << "Variable appears to be <b>ICON</b>."
				var_value = "\icon[var_value]"
				class = "icon"

			else if(istype(var_value,/atom) || istype(var_value,/datum))
				usr << "Variable appears to be <b>TYPE</b>."
				class = "type"

			else if(istype(var_value,/list))
				usr << "Variable appears to be <b>LIST</b>."
				class = "list"

			else if(istype(var_value,/client))
				usr << "Variable appears to be <b>CLIENT</b>."
				class = "cancel"

			else
				usr << "Variable appears to be <b>FILE</b>."
				class = "file"

	else

		var/list/names = list()
		for (var/V in O.vars)
			names += V

		//names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)
			return
		var_value = O.vars[variable]


	if(!autodetect_class)

		var/dir
		var/default
		if(isnull(var_value))
			usr << "Unable to determine variable type."

		else if(isnum(var_value))
			usr << "Variable appears to be <b>NUM</b>."
			default = "num"
			dir = 1

		else if(istext(var_value))
			usr << "Variable appears to be <b>TEXT</b>."
			default = "text"

		else if(isloc(var_value))
			usr << "Variable appears to be <b>REFERENCE</b>."
			default = "reference"

		else if(isicon(var_value))
			usr << "Variable appears to be <b>ICON</b>."
			var_value = "\icon[var_value]"
			default = "icon"

		else if(istype(var_value,/atom) || istype(var_value,/datum))
			usr << "Variable appears to be <b>TYPE</b>."
			default = "type"

		else if(istype(var_value,/list))
			usr << "Variable appears to be <b>LIST</b>."
			default = "list"

		else if(istype(var_value,/client))
			usr << "Variable appears to be <b>CLIENT</b>."
			default = "cancel"

		else
			usr << "Variable appears to be <b>FILE</b>."
			default = "file"

		usr << "Variable contains: [var_value]"
		if(dir)
			switch(var_value)
				if(1)
					dir = "NORTH"
				if(2)
					dir = "SOUTH"
				if(4)
					dir = "EAST"
				if(8)
					dir = "WEST"
				if(5)
					dir = "NORTHEAST"
				if(6)
					dir = "SOUTHEAST"
				if(9)
					dir = "NORTHWEST"
				if(10)
					dir = "SOUTHWEST"
				else
					dir = null
			if(dir)
				usr << "If a direction, direction is: [dir]"
		class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
		"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

		if(!class)
			return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name


	switch(class)

		if("list")
			//mod_list(O.vars[variable])
			return

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			var/var_new = input("Enter new text:","Text",O.vars[variable]) as null|text
			if(var_new==null) return
			O.vars[variable] = var_new

		if("num")
			var/var_new =  input("Enter new number:","Num",O.vars[variable]) as null|num
			if(var_new==null) return
			O.vars[variable] = var_new

		if("type")
			var/var_new = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(var_new==null) return
			O.vars[variable] = var_new

		if("reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob|obj|turf|area in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("mob reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("file")
			var/var_new = input("Pick file:","File",O.vars[variable]) as null|file
			if(var_new==null) return
			O.vars[variable] = var_new

		if("icon")
			var/var_new = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(var_new==null) return
			O.vars[variable] = var_new



	world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.vars[variable]]")]"


