/datum/command
	var/list/names = list()
	var/datum/os/source
	proc/Run(args)
	var/help_text = "help meh"

/datum/command/New(comp)
	source = comp


//List contents of directory//

/datum/command/dir
	names = list("dir","ls")
	help_text = "Lists contents of the current directory."

/datum/command/dir/Run(var/list/args)
	var/count = 1
	var/text
	for(var/datum/dir/D in source.pwd.contents)
		if(count == 3)
			text += " [D.name]\n"
			count = 1
			continue
		else if(count == 1)
			text += "[D.name]"
			count++
		else
			text += " [D.name]"
			count++
	source.Message(text)

//End dir//


//Help command, lists all registered commands//

/datum/command/help
	names = list("help", "man")
	help_text = "help \[CMD\]: Lists all registered commands on the current computer, alternately displays help for command CMD."

/datum/command/help/Run(var/list/args)
	if(args.len == 0)
		var/text = ""
		var/list/done_com = list()
		for(var/A in source.commands)
			var/datum/command/com = source.commands[A]
			if(com in done_com)
				continue
			text += com.names[1] + " "
			text += "\n"
			done_com += com
		source.Message(text)
	else if(args.len > 0)
		if(source.commands[args[1]])
			var/datum/command/A = source.commands[args[1]]
			if(!A)
				return
			source.Message(A.help_text)

//End help//


//aliases, lists all alternate names for a command//

/datum/command/aliases
	names = list("aliases")
	help_text = "help {CMD}: Lists all aliases for command CMD."

/datum/command/aliases/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	if(source.commands[args[1]])
		var/datum/command/A = source.commands[args[1]]
		source.Message("Aliases for command [args[1]]:")
		for(var/n in A.names)
			source.Message("  " + n)
	else
		source.Message("Command [args[1]] not found.")
		return

//End aliases


//mkdir, creates a dir with name derieved from the arguments//

/datum/command/mkdir
	names = list("mkdir")
	help_text = "mkdir {NAME}: Creates a directory in the current directory with name NAME."

/datum/command/mkdir/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
	if(source.FindAny(args[1]))
		source.Message("There is already a directory or file with the same name")
		return
	var/perm = source.pwd.CheckPermissions(src)
	if(perm != RW && perm != W)
		source.Message("No")
		return
	var/datum/dir/D = new(args[1],source.pwd)
	D.holder = source.pwd
	D.owned = source.user
	source.pwd.contents += D

//End mkdir//


//mv, moves file or directory from one point to another//

/datum/command/mv
	names = list("mv","move")
	help_text = "mv {PATH1} {PATH2}: Moves file or directory at PATH1 into PATH2."

/datum/command/mv/Run(var/list/args)
	if(args.len != 2)
		source.Message("Invalid number of arguments.")
		return
		return
	var/datum/dir/X = source.FindAny(args[1])
	var/datum/dir/Y = source.FindDir(args[2])
	if(!X || !Y)
		source.Message("Cannot find file/dir")
		return
	X.holder.contents -= X
	X.holder = Y
	Y.contents += X
	source.Message("Moved [X] into [Y]")
	return

//End mv//


//reboot, re... boots?  Kinda self explanatory//

/datum/command/reboot
	names = list("reboot","restart")
	help_text = "reboot: Reboots the current computer."

/datum/command/reboot/Run(var/list/args)
	source.boot = 0
	for(var/datum/praser/pars in source.process)
		del(pars)
	source.Boot()

//End reboot//


//Config, changes value of first argument in system config to second argument.

/datum/command/cfg
	names = list("cfg","config")
	help_text = "cfg {KEY} {DATA}: Sets KEY in system config to DATA."

/datum/command/cfg/Run(var/list/args)
	if(args[1] == "name" && args.len == 2)
		source.name = args[2]
		source.Message("Changed network name to [args[2]].")

//End config//

//pwd, prints current directory's path//

/datum/command/pwd
	names = list("pwd")
	help_text = "pwd: Prints the path of the current directory."

/datum/command/pwd/Run(var/list/args)
	var/list/dirs = list()
	if(!source.connected)
		var/datum/dir/cur = source.pwd
		for(var/x,x<=10,x++)
			dirs += cur
			if(cur.holder)
				cur = cur.holder
			else
				break
		var/string
		for(var/x=dirs.len,x>0,x--)
			var/datum/dir/dir2 = dirs[x]
			if(!string)
				string = "/[dir2.name]"
			else
				string = "[string]/[dir2.name]"
		source.Message(string)
		return
	else
		var/datum/dir/cur = source.pwd
		for(var/x,x<=10,x++)
			dirs += cur
			if(cur.holder)
				cur = cur.holder
			else
				break
		var/string
		for(var/x=dirs.len,x>0,x--)
			var/datum/dir/dir2 = dirs[x]
			if(!string)
				string = "/[dir2.name]"
			else
				string = "[string]/[dir2.name]"
		source.Message(string)
		return

//End pwd//


//run, executes program specified by args

/datum/command/run
	names = list("run","exec")
	help_text = "run {PATH}: Runs the program at PATH."

/datum/command/run/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/N = args[1]
	if(findtext(N,"/",1,0)) // ITS A PATH
		var/datum/dir/start
		var/done = 1
		var/list/D = list()
		if(findtext(N,"/",1,2))
			start = source.root
			N = copytext(N,2,0)
		else
			start = source.pwd
		while(done)
			var/loc1 = findtext(N,"/",1,0)
			if(!loc1)
				var/Y = copytext(N,1,0)
				D += Y
				done = 0
				break
			var/X = copytext(N,1,loc1)
			N = copytext(N,loc1+1,0)
			D += X
		for(var/A in D)
			source.pwd = start
			start = source.FindDir(A)
			if(!start)
				args[1] = A
				break
		source.pwd = start
	var/datum/dir/file/program/P = source.FindProg(args[1])
	if(!P)
		if(source.FindDir(args[1]))
			source.Message("[args[1]] is a directory")
			return
		if(source.FindFile(args[1]))
			source.Message("[args[1]] is a text file")
			return
		source.Message("Cannot find file [args[1]]")
		return
	else
		P.Run(source)

//End run//


//cd, change director, god help you if you don't know what this is//

/datum/command/cd
	names = list("cd")
	help_text = "cd {PATH}: Switches to the directory at PATH."

/datum/command/cd/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	if(args[1] == ".." && source.pwd.holder)
		source.pwd = source.pwd.holder
	else if(findtext(args[1],"/",1,0)) // ITS A PATH
		var/datum/dir/start
		var/done = 1
		var/list/D = list()
		if(findtext(args[1],"/",1,2))
			start = source.root
			args[1] = copytext(args[1],2,0)
		else
			start = source.pwd
		while(done)
			var/loc1 = findtext(args[1],"/",1,0)
			if(!loc1)
				var/Y = copytext(args[1],1,0)
				D += Y
				done = 0
				break
			var/X = copytext(args[1],1,loc1)
			args[1] = copytext(args[1],loc1+1,0)
			D += X
		for(var/A in D)
			source.pwd = start
			start = source.FindDir(A)
			source.Message("Moved into [start.name]")
		source.pwd = start
	else
		var/datum/dir/X = source.FindDir(args[1])
		if(X)
			source.pwd = X
			source.Message("Moved into [source.pwd.name]")
			return
		else
			source.Message("Either not a directory or it dosen't exist")

//End cd//


//parsehtml, parses HTML I guess?//

/datum/command/html
	names = list("html","parsehtml")
	help_text = "html {FILE}: Parses the HTML file at FILE."

/datum/command/html/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/datum/dir/file/F = source.FindFile(args[1])
	if(!F)
		return
	var/perm = F.CheckPermissions(source)
	if(perm < W)
		source.Message("You are not authorized to do that.")
		return
	var/list/lines = list()
	var/done = 0
	var/text = F.contents
	var/newtext
	while (done!=1)
		var/X = findtext(text,"\n",1,0)
		if(!X)
			done = 1
			lines += text
		//	// "DONE"
			break
		else
			var/Y = copytext(text,1,X)
			text = copytext(
			text,X+1,0)
			lines += Y
		sleep(1)
	for(var/A in lines)
		var/NA = A
		if(findtext(A,"<href=",1,0))
			var/loc = findtext(A,"=",1,0)
			if(!findtext(A,">",1,0))
				continue
			var/loc1 = findtext(A,"\"",loc,0)
			var/loc2 = findtext(A,"\"",loc1+1,0)
			var/X = copytext(A,loc1+1,loc2)
			if(findtext(A,"name="))
				var/locA = findtext(A,"name=")
				var/locB = findtext(A,"\"",locA,0)
				var/locC = findtext(A,"\"",locB+1,0)
				var/Y = copytext(A,locB+1,locC)
				NA = "<a href=?src=\ref[src];redir=[X]>[Y]</a>!"
			else
				NA = "<a href=?src=\ref[src];redir=[X]>[X]</a>!"
		newtext += NA
	source.Message(newtext)

/datum/os/Topic(href,href_list[],hsrc)
	if(1)
		if(!usr)
			return
		if(href_list["redir"])
			var/datum/os/C = usr.comp
			var/datum/dir/file/X = FindFile(href_list["redir"])
			if(!X)
				return
			C.showhtml(X)

//End parsehtml//


//append, appends text to the end of a file//

/datum/command/append
	names = list("append")
	help_text = "append {FILE}: Appends inputted text to the end of FILE."

/datum/command/append/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/datum/dir/file/X = source.FindFile(args[1])
	if(X)
		var/perm = X.CheckPermissions(src)
		if(perm < R)
			source.Message("You are not authorized to do that.")
			return
		source.Message("Enter the line to append:")
		var/text = source.GetInput()
		text = copytext(text,1,0)
		X.contents += "\n[text]"
	else
		source.Message("Error: No file named [args[1]].")

//End cat//


//vi!  Edits text//

/datum/command/vi
	names = list("vi","vim","nano","pico","ed","emacs","edit")
	help_text = "vi {FILE}: Opens a text editor for file FILE."

/datum/command/vi/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/datum/dir/file/X = source.FindFile(args[1])
	if(X)
		var/perm = X.CheckPermissions(source)
		if(perm < W)
			source.Message("You are not authorized to do that.")
			return
		var/text = X.contents
		X.contents = input(source.user,"VI","VI",text) as message
	else
		if(source.FindDir(args[1]))
			source.Message("[args[1]] is a directory")
			return
		else if(source.FindProg(args[1]))
			source.Message("[args[1]] is a program")
			return
		else
			source.Message("File does not exist")
			return

//End vi//


//cat, reads the contents of a file to the screen//

/datum/command/cat
	names = list("cat","read","type")
	help_text = "cat {FILE}: Prints the contents of file FILE to the screen."

/datum/command/cat/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/datum/dir/file/X = source.FindFile(args[1])
	if(X)
		var/perm = X.CheckPermissions(source)
		if(perm != R && perm != RW )
			source.Message("You are not authorized to do that..")
			return
		source.Message(X.contents)
	else
		source.Message("Error no file named [args[1]].")

//End cat//


//rm, removes file//

/datum/command/rm
	names = list("rm","del","delete")
	help_text = "rm {PATH}: Removes file with path PATH."

/datum/command/rm/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/datum/dir/current = source.pwd
	var/N = args[1]
	if(findtext(N,"/",1,0)) // ITS A PATH
		var/datum/dir/start
		var/done = 1
		var/list/D = list()
		if(findtext(N,"/",1,2))
			start = source.root
			N = copytext(N,2,0)
		else
			start = source.pwd
		while(!done)
			var/loc1 = findtext(N,"/",1,0)
			if(!loc1)
				var/Y = copytext(N,1,0)
				D += Y
				done = 0
				break
			var/V = copytext(N,1,loc1)
			N = copytext(N,loc1+1,0)
			D += V
		var/count = 0
		for(var/A in D)
			count++
			source.pwd = start
			if(count == D.len)
				N = A
				break
			start = source.FindDir(A)
		source.pwd = start
	if(N == "*")
		for(var/datum/dir/A in source.pwd.contents)
			var/perm = A.CheckPermissions(source)
			if(perm != RW)
				source.Message("You are not authorized to do that.")
				return
			source.Message("Deleted [A.name].")
			del(A)
		source.pwd = current
		return
	var/datum/dir/X = source.FindAny(N)
	if(X)
		var/perm = X.CheckPermissions(source)
		if(perm != RW)
			source.Message("You are not authorized to do that.")
			return
		source.Message("Deleted [X.name].")
		del(X)
		source.pwd = current
		return

//End rm//


//touch, creates a file//

/datum/command/touch
	names = list("touch","create")
	help_text = "touch {PATH}: Creates a file at path PATH."

/datum/command/touch/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/datum/dir/current = source.pwd
	var/N = args[1]
	if(findtext(N,"/",1,0)) // ITS A PATH
		var/datum/dir/start
		var/done = 1
		var/list/D = list()
		if(findtext(N,"/",1,2))
			start = source.root
			N = copytext(N,2,0)
		else
			start = source.pwd
		while(done)
			var/loc1 = findtext(N,"/",1,0)
			if(!loc1)
				var/Y = copytext(N,1,0)
				D += Y
				done = 0
				break
			var/V = copytext(N,1,loc1)
			N = copytext(N,loc1+1,0)
			D += V
		var/count = 0
		for(var/A in D)
			count++
			source.pwd = start
			if(count == D.len)
				N = A
				break
			start = source.FindDir(A)
		source.pwd = start
	if(source.FindAny(N))
		source.Message("There is already a directory/file with the same name.")
		return
	var/datum/dir/file/F = new(N,source.pwd)
	source.pwd = current
	F.owned = source.user
	F.permissions[source.user.name] = RW
	F.holder.contents += F

//End touch//


//ftp: Documentation missing. [FIXME]//

/datum/command/ftp
	names = list("ftp")
	help_text = "ftp {???}: ???"

/datum/command/ftp/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	var/datum/dir/D = source.FindDir(args[1])
	if(!D)
		return
	var/datum/dir/X = new D.type ()
	for(var/A in X.vars)
		X.vars[A] = D.vars[A]
	X.holder = source.root
	X.owned = source.user
	X.permissions[source.user.name] = RW
	X.holder.contents += X

//End ftp//


//ifconfig, prints hostname and IP//

/datum/command/ifconfig
	names = list("ifconfig","ipconfig")
	help_text = "ipconfig: Prints hostname and IP for the current computer."

/datum/command/ifconfig/Run()
	if(source.connected)
		source.Message("IP:[source.connected.ip]")
		if(source.connected.hostnames.len >= 1)
			for(var/A in source.connected.hostnames)
				source.Message("HOSTNAME:[A]")
	else
		source.Message("IP:[source.ip]")
		if(source.hostnames.len >= 1)
			for(var/A in source.hostnames)
				source.Message("HOSTNAME:[A]")

//End ifconfig//


//useradd, adds user//

/datum/command/useradd
	names = list("useradd","adduser","newuser")
	help_text = "useradd {NAME} {PASS}: Creates a user of name NAME with password PASS."

/datum/command/useradd/Run(var/list/args)
	if(args.len != 2)
		source.Message("Invalid number of arguments.")
		return
	var/N = args[1]
	var/P = args[2]
	var/datum/user/X = new(N,P)
	if(!source.connected && source.user.name == "root")
		if(source.GetUser(N))
			del(X)
			source.Message("There is already already an account with this name.")
			return
		source.users += X
		source.Message("Created [X.name]")
	else if(source.connectedas.name == "root")
		if(source.connected.GetUser(N))
			del(X)
			source.Message("There is already already an account with this name.")
			return
		source.connected.users += X
		source.Message("Created [X.name]")
	else
		del(X)

//End useradd//


//usermod, changes the password of a user//

/datum/command/usermod
	names = list("usermod","moduser","upasswd")
	help_text = "usermod {USER} {OPASS} {NPASS}: Modifies the password of USER, where OPASS is the old password and NPASS is the new password."

/datum/command/usermod/Run(var/list/args)
	if(args.len != 3)
		source.Message("Invalid number of arguments.")
		return
	var/N = args[1]
	var/OP = args[2]
	var/NP = args[3]
	if(!source.connected && source.IsRoot())
		var/datum/user/X = source.GetUser(N)
		if(!X)
			source.Message("No user exists by this name.")
			return
		if(X.password != OP)
			return
		X.password = NP
		source.Message("[N]'s password has been changed.")

//End usermod//


//userdel, deletes users//

/datum/command/userdel
	names = list("userdel","rmuser")
	help_text = "userdel {USER}: Removes USER from the system."

/datum/command/userdel/Run(var/list/args)
	if(args.len != 2)
		source.Message("Invalid number of arguments.")
		return
	var/N = args[1]
	if(!source.connected)
		if(N == "root")
			source.Message("Cannot remove root account")
			return
		for(var/datum/user/A in source.users)
			if(A.name == N)
				del(A)
				source.Message("Deleted user [N].")
				return
	else if(source.connectedas.name == "root")
		for(var/datum/user/A in source.connected.users)
			if(A.name == N)
				del(A)
				source.Message("Deleted user [N].")
				return

//End userdel//


//userlist, lists users//

/datum/command/userlist
	names = list("userlist","lsuser","who")
	help_text = "userlist: Lists all users on the system."

/datum/command/userlist/Run(var/list/args)
	if(!source.connected)
		if(source.user.name != "root")
			return
		for(var/datum/user/A in source.users)
			source.Message(A.name)
	else
		if(source.connectedas.name != "root")
			return
		for(var/datum/user/A in source.connected.users)
			source.Message(A.name)

//End userlist//

//passwd, changes the password of the current user//

/datum/command/passwd
	names = list("passwd")
	help_text = "passwd {PASS}: Sets the password of the current user to PASS."

/datum/command/passwd/Run(var/list/args)
	if(args.len != 1)
		source.Message("Invalid number of arguments.")
		return
	if(!source.connected)
		source.user.password = args[1]
		source.Message("Password changed.")

//End passwd//


//chmod, changes the access rights of a file for a user//

/datum/command/chmod
	names = list("chmod","acl")
	help_text = "chmod {PERM} {USER} {FILE}: Gives USER PERM rights to FILE."

/datum/command/chmod/Run(var/list/args)
	if(args.len != 3)
		source.Message("Invalid number of arguments.")
		return
	var/X = args[1]
	var/UN = args[2]
	var/DN = args[3]
	if(!source.IsRoot())
		source.Message("You need to be root to perform this action.")
		return
	var/datum/dir/D = source.FindAny(DN)
	if(!D)
		source.Message("Can't find a file named [DN].")
		return
	var/Y = source.Right2Num(X)
	D.permissions[UN] = Y
	source.Message("[UN] has been given [X] rights to [DN].")

//End chmod//

/*datum/os/proc/Copy(Y)
	if(Y == "*")
		for(var/datum/dir/X in pwd.contents)
			copy += X
			src.owner << "Added [X.name] into the clipboard."
		return
	var/datum/dir/X = FindAny(Y)
	if(X)
		copy += X
		src.owner << "Added [X.name] into the clipboard."

datum/os/proc/Paste()
	if(copy.len <= 0)
		src.owner << "Nothing to paste.."
		return
	var/pasted = 0
	var/notpasted = 0
	var/total = copy.len
	for(var/datum/dir/A in copy)
		if(FindAny(A.name))
			Message("[A.name] already exists..")
			notpasted++
			continue
		if(A.type == /datum/dir)
			var/datum/dir/D = new(A.name,src.pwd)
			for(var/datum/dir/AX in A.contents)
				CopyFile(AX,D)
			D.permissions.Copy(A.permissions,1,0)
			src.pwd.contents += D
			pasted++
		else if(A.type == /datum/dir/file)
			var/datum/dir/file/D = new(A.name,src.pwd)
			D.contents = A.contents
			D.permissions.Copy(A.permissions,1,0)
			src.pwd.contents += D
			pasted++
		else if(istype(A,/datum/dir/file/program))
			var/datum/dir/X = new A.type (A.name,src.pwd)
			X.permissions.Copy(A.permissions,1,0)
			src.pwd.contents += X
			pasted++
	copy = list()
	Message("[pasted]/[total] were pasted, [notpasted] already existed..")
datum/os/proc/CopyFile(var/datum/dir/A,var/datum/dir/B)
	if(A)
		if(A.type == /datum/dir)
			var/datum/dir/D = new(A.name,src.pwd)
			for(var/datum/dir/AX in A.contents)
				CopyFile(AX,D)
			D.permissions.Copy(A.permissions,1,0)
			D.holder = B
			B.contents += D
		else if(A.type == /datum/dir/file)
			var/datum/dir/file/D = new(A.name,src.pwd)
			D.contents = A.contents
			D.permissions.Copy(A.permissions,1,0)
			D.holder = B
			B.contents += D
		else if(istype(A,/datum/dir/file/program))
			var/datum/dir/X = new A.type (A.name,src.pwd)
			X.permissions.Copy(A.permissions,1,0)
			X.holder = B
			B.contents += X
datum/os/proc/Connect(ip,user,pass)
	if(user && pass)
		www.ConnectTo_s(ip,src,user,pass)
	else
		www.ConnectTo(ip,src)

datum/os/proc/BG(path)
	var/datum/dir/file/program/X = FindProg(path)
	if(!X)
		Message("Cannot find file")
		return
	if(connected)
		connected.tasks += X
	else
		tasks += X
	Message("[path] is now being run in the background")
datum/os/proc/Kill(path)
	if(connected)
		for(var/datum/dir/file/program/X in connected.tasks)
			if(X.name == path)
				X.Stop(connected)
				connected.tasks -= X
				Message("Killed [path]")
				return
	else
		for(var/datum/dir/file/program/X in src.tasks)
			if(X.name == path)
				X.Stop(src)
				src.tasks -= X
				Message("Killed [path]")
				return
datum/os/proc/BGLIST()
	if(connected)
		if(connected.tasks.len <= 0)
			return
		for(var/datum/dir/file/program/X in connected.tasks)
			Message(X.name)
	else
		if(tasks.len <= 0)
			return
		for(var/datum/dir/file/program/X in src.tasks)
			src.owner << X.name
datum/os/proc/process()
	for(var/datum/dir/file/program/X in src.tasks)
		if(!X.running)
			X.Run(src)

/*datum/os/proc/Remote(var/address,var/command,var/list/args)
	var/datum/function/F = new
	F.name = command
	var/run = 1
	var/count = 0
	while(run)
		count++
		if(count > args.len)
			break
		var/K = args[count]
		if(findtext(K,"{",1,0))
			//world << "Found a '"
			for(var/A in args)
				if(K == A)
					continue
				if(findtext(A,"}",1,0))
					//world << "Found the other"
					var/Z = K + A
					Z = copytext(Z,1,0)
					var/x = findtext(Z,"{",1,0)
					var/y = findtext(Z,"}",x+1,0)
					K = copytext(Z,x+1,y)
					//world << "breaking"
					break
		//world << "[count]:[K]"
		switch(count)
			if(1)
				F.arg1 = K
			if(2)
				F.arg2 = K
			if(3)
				F.arg3 = K
			if(4)
				F.arg4 = K
			if(5)
				F.arg5 = K
	if(address == "localhost")
		src.device:receive_packet(src.device,F)
		return

	address = address)
	if(address == -1)
		Message("Invalid IP supplied.")
		return
	Message(send_packet(src.device,address, F))*/*/