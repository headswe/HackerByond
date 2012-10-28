

/datum/os/proc/Boot()
	Message("Booting...")
	sleep(10)
	Message("Starting eth0 interface..")
	Message("IP:[src.ip]")
	src.boot = 1
	Message("Boot Complete")
	Message("Thank you for using ThinkThank")
	Message("Type help for help")
/datum/os/proc/command(input_string,mob/user,silent=0)
	if(!silent)
		Message(">>> "+input_string)
	if(cmdoverride)
		input = input_string
		return
	if(!boot)
		return
	input_string = lowertext(input_string)
	var/list/args_list = list()
	var/last = 1
	var/cmd
	for(var/X=1,X < 10,X++)
		var/pos = findtext(input_string," ",1,0)
		if(pos)
			last = pos
			if(X == 1)
				cmd = copytext(input_string,1,last)
			else
				var/YX = copytext(input_string,1,last)
				args_list += YX
			input_string = copytext(input_string,last+1,0)
		else
			if(last != 1)
				args_list += input_string
			else
				cmd = input_string
			break
	world << "Debug:[cmd]"
	if(src.commands[cmd])
		var/datum/command/cmd_obj = src.commands[cmd]
		cmd_obj.Run(args_list)
		return
	else
		Message("Command not reconigzed")
/datum/os/proc/GetUser(var/N)
	for(var/datum/user/U in users)
		if(U.name == N)
			return U
	return 0
