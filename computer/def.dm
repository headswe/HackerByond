var/global/const/R = 1
var/global/const/W = 2
var/global/const/RW = 3
mob
	var/datum/os/comp
	var/obj/console_device
mob/verb/cmd(msg as text)
	set hidden = 1
	src.current.command(msg,src)
/datum/os/
	var/name = "ThinkThank" // Name?
	var/datum/dir/pwd	// Current location in the directory tree
	var/datum/dir/root = new("root") // Root directory
	var/datum/dir/dldir // Download dir to put files from remote host //TODO:ALLOW SPECFICY INSTEAD
	var/list/commands = list() // Contains a named list of all commands
	var/datum/os/connected // OS that were connecting too.
	var/list/mob_users = list()
	var/force_stop = 0 // Set to one to force stop all proceses...
	var/list/users // Current users.
	var/cmdoverride = 0 // When a process is has taken control of input
	var/input = null // Last input while under override
	var/network = 0 // If we have networking
	var/list/clients = list() // Clients connected??(No clue)
	var/list/copy = list() // Copy buffer
	var/auth = 1 // Authed???
	var/boot = 0 // Booted?
	var/datum/ip/this_ip = null // IP
	var/obj/device/holder
	var/list/packets = list() // packets
	var/list/process = list() // current process
	var/datum/user/connectedas // what users you are connected as
	var/list/hostnames = list()
	var/datum/user/user = new("root","password")
	var/list/tasks = list()
	var/list/ip_list = list()
	var/list/config = list("webserver" = 0,motd = "Welcome to the server")
/datum/os/Del()
	for(var/datum/praser/P in process)
		del(P)
	for(var/mob/A in mob_users)
		mob_users -= A
	..()
/datum/os/New(obj/device/A)
	pwd = root
	holder = A
	var/datum/dir/X = new("downloads",src.pwd)
	var/datum/dir/file/program/test/T = new("testapp",src.pwd)
	pwd.contents += T
	T.holder = pwd
	T.owned = user
	T.permissions[user.name] = RW
	pwd.contents += X
	X.holder = pwd
	dldir = X
	www.GetAdress(src)
	users += user
	X.permissions[user.name] = RW
	root.permissions[user.name] = RW
	X.owned = user

	for(var/com_type in typesof (/datum/command))
		var/datum/command/com = new com_type(src)
		for(var/name in com.names)
			src.commands[name] = com
/datum/os/proc/GetInput()
	set background=1
	src.cmdoverride = 1
	while(!src.input)
		sleep(1)
	var/xy = src.input
	src.input = null
	src.cmdoverride = 0
	return xy
/datum/os/proc/receive_message(message)
	Message(message)
/datum/dir/proc/CheckPermissions(var/datum/os/client)
	if(!client.connected)
		var/Y = src.permissions[client.user.name]
		if(!Y)
			return 0
		else
			return Y
	else
		var/Y = src.permissions[client.connectedas.name]
		if(!Y)
			return 0
		else
			return Y

/datum/os/proc/Message(var/msg)
	for(var/mob/A in src.mob_users)
		A.client << output(msg, "console.text")