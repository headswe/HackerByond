/datum/command
	var/list/names = list()
	var/datum/os/source
	proc/Run(args)
	var/help_text = "help meh"
/datum/command/New(comp)
	source = comp
/datum/command/dir
	names = list("dir","ls")
/datum/command/dir/Run(args)
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
/datum/command/help
	names = list("help")
/datum/command/help/Run(var/list/args)
	if(args.len == 0)
		var/text = ""
		var/list/done_com = list()
		for(var/A in source.commands)
			var/datum/command/com = source.commands[A]
			if(com in done_com)
				continue
			for(var/name in com.names)
				text += name+" "
			text += "\n"
			done_com += com
		source.Message(text)
	else if(args.len > 0)
		if(source.commands[args[1]])
			var/datum/command/A = source.commands[args[1]]
			if(!A)
				return
			source.Message(A.help_text)