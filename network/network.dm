var/datum/www/www = new()
datum/www/
	var/list/nodes = list()
/datum/ip
	var/sub_1 = 0
	var/sub_2 = 0
	var/sub_3 = 0
	var/sub_4 = 0
	var/source = null
	var/count = 1
/datum/ip/New(x,y,z,k,source)
	sub_1 = x
	sub_2 = y
	sub_3 = z
	sub_4 = k
	src.source = source
/datum/ip/proc/GetNewIP()
	if(sub_4 < 255)
		var/datum/ip/K = new /datum/ip(sub_1,sub_2,sub_3,sub_4+count,src.source)
		if(istype(source,/obj/device/router))
			count++
			world << count
		return K
/datum/ip/proc/String()
	return "[sub_1].[sub_2].[sub_3].[sub_4]"
/datum/www/proc/GetAdress(var/datum/os/X)
	if(!istype(X.holder,/obj/device/router))
		var/datum/UnifiedNetwork/A = X.holder.Networks[/obj/cabling/Network]
		var/obj/device/router/R = FindRouter(A)
		if(!R)
			world << "NO ROUTER"
			return
		else
			X.this_ip = R.system.this_ip.GetNewIP()
			return
	var/x1 = rand(1,255)
	var/x2  = rand(1,255)
	X.this_ip = new /datum/ip(x1,x2,1,1,X.holder)
	X.network = 1
/datum/www/proc/FindRouter(var/datum/UnifiedNetwork/A)
	for(var/atom/B in A.Nodes)
		if(istype(B,/obj/device/router))
			return B
/datum/www/proc/GetAdressv2(var/T)
	var/ip
	spawn() while(1)
		var/x1 = rand(1,256)
		var/x2  = rand(1,256)
		var/x3 = rand(1,256)
		var/x4 = rand(1,256)
		ip = "[x1].[x2].[x3].[x4]"
		var/A = nodes[ip]
		if(!A)
			break
	nodes[ip] = T
	return ip
/datum/www/proc/RegisterDomain(var/datum/os/X,path)
	if(!X.this_ip)
		return 0
	var/F = nodes[path]
	if(F)
		return
	nodes[path] = X
	X.hostnames += path
/datum/www/proc/ConnectTo(var/ip,var/datum/os/client)
	if(nodes[ip])
		client.Message("Connecting to [ip]")
		sleep(30)
		var/datum/os/server = nodes[ip]
		if(server.CanConnect(client))
			client.Message("Connection etablished..")
			server.OnConnect(client)
		else
			client.Message("Connection refused")
	else
		client.Message("Connection attempt failed..")
		return
/datum/www/proc/ConnectTo_s(var/ip,var/datum/os/client,user,pass)
	if(nodes[ip])
		client.Message("Connecting to [ip]")
		sleep(30)
		var/datum/os/server = nodes[ip]
		if(server.CanConnect(client,user,pass))
			client.Message("Connection etablished..")
			server.OnConnect(client)
		else
			client.Message("Connection refused")
	else
		client.Message("Connection attempt failed..")
		return
/datum/os/proc/CanConnect(var/datum/os/client)
		client.connected = src
		Message("Alert: user connected from [client.this_ip.String()]")
		return 1
/datum/packet
	var/info = "PING"
	var/where
	var/from
	var/list/extrainfo
/datum/packet/New(infos,wheres,froms,list)
	if(!infos || !wheres)
		del(src)
		return 0
	info = infos
	where = wheres
	from = froms
	if(list)
		extrainfo = list
//	world << "TO:[where],INFO:[info],[from]"
	src.send()
/datum/packet/proc/send()
	var/datum/os/rec = www.nodes[where]
	if(!rec)
		return
	rec.PacketReceived(src)
datum/os/proc/PacketReceived(var/datum/packet/P)
	if(!P)
		return
	if(P.info == "ping")
		new /datum/packet ("pong",P.from,src.this_ip)
		Message("Pinged by [P.from]")
		return
	else if(P.info == "pong")
		Message("Pong received from [P.from]")
		return
	for(var/datum/dir/file/program/X in src.tasks)
		if(!X.is_script)
			X.ForwardPacket(P)
	for(var/datum/praser/V in src.process)
		if(V.func["onPacketRecieve"])
			world << " got a packet"
			var/datum/func/F = V.func["onPacketRecieve"]
			var/list/args2 = list()
			args2 += P.info
			args2 += P.from
			args2 += P.extrainfo
			F.Run(src,args2)
	//	else
	//		world << "fuck you"
