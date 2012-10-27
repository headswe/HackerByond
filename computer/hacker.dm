

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
//	input_string = sanitize(input_string)
	if(cmdoverride)
		input = input_string
	//	world << "CMD OVERRIDE"
		return
	if(!boot)
		return
	input_string = lowertext(input_string)
	var/list/args_list = list()
//	world << "calling [input_string]"
	var/C1 = 0
	var/last = 1
	var/cmd
	for(var/X,X < 10,X++)
		//world << "input_string:[input_string]"
		var/Y = findtext(input_string," ",1,0)
		if(Y)
			last = Y
			C1++
			if(C1 == 1)
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
	if(src.commands[cmd])
		var/datum/command/cmd_obj = src.commands[cmd]
		cmd_obj.Run(args_list)
		world << "RAN SUPER NEW COMMANDS"
		return
	if(cmd == "cd")
		if(args_list.len == 0)
			Message("No argument passed")
			return
		var/path = args_list[1]
		cd(path)
		return
	else if(cmd == "copy")
		if(args_list.len == 0)
			Message("No argument passed")
			return
		var/path = args_list[1]
		Copy(path)
		return
	else if(cmd == "reboot")
		reboot()
	else if(cmd == "config")
		if(args_list.len <= 2)
			Message("Not enough argument passed")
			return
		config(args_list[1],args_list[2])
	else if(cmd == "paste")
		Paste()
		return
	else if(cmd == "run")
		if(args_list.len == 0)
			Message("No argument passed")
			return
		var/path = args_list[1]
		Run(path)
		return
	else if(cmd == "prase" || cmd == "parse")
		if(args_list.len == 0)
			Message("No argument passed")
			return
		var/path = args_list[1]
		Prase(path)
	else if(cmd == "connect")
		if(args_list.len <= 0)
			Message("No argument passed")
			return
		if(args_list.len >= 3)
			Connect(args_list[1],args_list[2],args_list[3])
		else if(args_list.len == 2)
			Message("You need either 3 or 1 arg")
			return
		else
			Connect(args_list[1])
		return
	else if(cmd == "mkdir")
		if(args_list.len == 0)
			Message("No argument passed")
			return
		var/path = args_list[1]
		MkDir(path)
		return
	else if(cmd == "dir" || cmd == "ls")
		Dir()
		return
	else if(cmd == "mv")
		if(args_list.len == 0)
			Message("No arguments passed")
			return
		var/path1 = args_list[1]
		var/path2 = args_list[2]
		Mv(path1,path2)
		return
	else if(cmd == "pack")
		if(args_list.len == 0)
			Message("No arguments passed")
			return
		var/info = args_list[1]
		var/too = args_list[2]
		new /datum/packet (info,too,src.ip)
	else if(cmd == "compile")
		if(args_list.len < 1 )
			Message("No arguments passed")
			return
		Compile(args_list[1])
		return
	else if(cmd == "user")
		if(args_list.len < 1 )
			Message("No arguments passed")
			return
		var/command2 = args_list[1]
		if(command2 == "add" && args_list.len >= 3)
			UserAdd(args_list[2],args_list[3])
			return
		else if(command2 == "modify" && args_list.len >= 4)
			UserModify(args_list[2],args_list[3],args_list[4])
			return
		else if(command2 == "remove" && args_list.len >= 1)
			UserRemove(args_list[2])
			return
		else if(command2 == "list" && args_list.len >= 1)
			ListUsers()
			return
		else
			Message("No arguments passed")
			return
	else if(cmd == "ipconfig")
		IpConfig()
	else if(cmd == "disconnect")
		if(connected)
			if(istype(connected,/datum/os/server))
				connected:clients -= src
			Message("You have disconnected from [connected.ip]")
			if(src.connected.owner)
				src.connected.owner << "[src.ip] has disconnected."
			src.connected = null
			src.connectedas = null
			src.pwd = src.root
		return

	else if(cmd == "chmod")
		if(args_list.len == 0)
			Message("No argument passed")
			return
		if(args_list.len < 3)
			Message("Too few arguments")
			Message("example:chmod rw root downloads")
			return
		Chmod(args_list[1],args_list[2],args_list[3])
	else if(cmd == "pwd")
		Pwd()
		return
	else if(cmd == "passwd")
		if(args_list.len < 1)
			Message("No argument passed")
			return
		Passwd(args_list[1])
		return
	else if(cmd == "make")
		if(args_list.len == 0)
			Message("No argument passed")
			return
		Make(args_list[1])
		return
	else if(cmd == "cat")
		if(args_list.len == 0)
			Message("no argument passed")
			return
		cat(args_list[1])
	else if(cmd == "testpraser")
		if(args_list.len == 0)
			Message("no argument passed")
			return
		testpraser(args_list[1])
	else if(cmd == "hurrdurr")
		for(var/A in src.process)
			world << "One task"
	else if(cmd == "vi")
		if(args_list.len == 0)
			Message("no argument passed")
			return
		vi(args_list[1],user)
	else if(cmd == "read")
		if(args_list.len == 0)
			Message("no argument passed")
			return
		read(args_list[1])
	else if(cmd == "chown")
		if(args_list.len == 0)
			Message("no argument passed")
			return
		if(args_list.len <= 1)
			var/path = args_list[1]
			var/datum/dir/D = FindAny(path)
			Message(D.owned.name)
	else if(cmd == "rm")
		if(args_list.len == 0)
			Message("no argument passed")
			return
		rm(args_list[1])
	else if(cmd == "help")
		Message(helptext)
	else if(cmd == "ftp")
		if(args_list.len == 0)
			Message("no argument passed")
			return
		FTP(args_list[1])
	else if(cmd == "bg")
		//world << "BG"
		if(args_list.len == 0)
			Message("no argument passed")
			return
		if(args_list[1] == "list")
			BGLIST()
			return
		BG(args_list[1])
	else if(cmd == "kill")
		//world << "BG"
		if(args_list.len == 0)
			Message("no argument passed")
			return
		Kill(args_list[1])
	/*else if(cmd == "remote")
		if(args_list.len < 2)
			Message("not enough arguments, Usage: remote ip message \[args\]")
		else if(args_list.len == 2)
			Remote(args_list[1],args_list[2], list() )
		else
			Remote(args_list[1],args_list[2],args_list.Copy(3,args_list.len+1) )*/
//	else if(add
	else
		Message("Command not reconigzed")


/datum/os/proc/GetUser(var/N)
	for(var/datum/user/U in users)
		if(U.name == N)
			return U
	return 0
