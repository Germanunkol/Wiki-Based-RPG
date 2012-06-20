-- connection of server/client

local connection = {}

connectedClients = {}

local socket = require("socket")

local maxPlayers = 0

function connection.initServer(host, port, maxConnections)

	local tcpServer = socket.bind(host, 3456, maxConnections)
	maxPlayers = maxConnections
	if tcpServer == nil then
		print(err)
	else
		print("server: " .. tcpServer:getsockname())
	end
	
	tcpServer:settimeout(0)
	
	return tcpServer
end


-- Send playernames, stats etc:
local function synchronizeClients( newClient )
	for k, cl in pairs( connectedClients ) do
		cl.client:send("NEWPLAYER:" .. newClient.playerName .. "\n")
		if	cl ~= newClient then
			newClient.client:send("NEWPLAYER:" .. cl.playerName .. "\n")
		end
	end
end

function handleNewClient( newClient )
	print("new client connected")
	local clientNumber = 0
	for i=1, maxPlayers, 1 do
		if connectedClients[i] == nil then
			connectedClients[i] = { client = newClient }
			connectedClients[i].clientNumber = i
			clientNumber = i
			break
		end
	end
	
	if clientNumber <= maxPlayers and clientNumber ~= 0 then
		newClient:send("CLIENTNUMBER:" .. clientNumber .. "\n")
	else
		newClient:send("SERVERFULL:\n")
		connectedClients[clientNumber] = nil
		newClient:close()
		newClient = nil
	end
	if newClient then
		statusMsg.new( "New player!" )
	end
end

function connection.runServer(tcpServer)		--handle all messages that come from the clients
	local newClient, err = tcpServer:accept()
	
	if newClient ~= nil then
		handleNewClient( newClient )
	end
	
	for k, cl in pairs(connectedClients) do
		cl.client:settimeout(0)
		local msg, err = cl.client:receive()
		if msg ~= nil then
			print("received: " .. msg)
			if msg:find( "NAME:" ) == 1 then
				cl.playerName = msg:sub( 6, #msg )
				local nameTaken = false
				for k2, cl2 in pairs( connectedClients) do
					if cl2 ~= cl and cl2.playerName == cl.playerName then
						nameTaken = true
					end
				end
				
				if nameTaken then
					cl.client:send( "ERROR:NAMETAKEN\n" )
					connectedClients[cl.clientNumber] = nil
					cl.client:close()
				else
					synchronizeClients( cl )
				end
				
				print("end received: " .. msg)
			end
		else
			print("error: " .. err)
			if err == "closed" then
				connectedClients[k] = nil			-- if connection was closed, remove from table
				return
			end
		end
	end
end

function connection.runClient( client )				--handle all messages that come from the server
	msg = client:receive()

	if msg then
		print("received: " .. msg)
		
		if msg:find("ERROR:") == 1 then
			if msg:find( "ERROR:SERVERFULL" ) == 1 then
				print( "ERROR: Server is full!" )
				statusMsg.new( "Server is full!" )
				menu.initMainMenu()
				return
			elseif msg:find( "ERROR:NAMETAKEN" ) == 1 then
				print( "Name alread exists!" )
				statusMsg.new( "Name alread exists!" )
				menu.initMainMenu()
				return
			end
		else
		
			local start, ending = msg:find( "CLIENTNUMBER:" )
			if start == 1 then
				connection.setClientNumber( msg:sub(ending+1, #msg) )
			end
			
			local start, ending = msg:find( "NEWPLAYER:" )
			if start == 1 then
				table.insert( connectedClients, {playerName=msg:sub(ending+1, #msg)} )
			end
			
			local start, ending = msg:find( "GAMESTART:" )
			if start == 1 then
				lobby.deactivate()
				statusMsg.new( "Game started." )
			end
		end
	end
end

local clientNumber = nil			--client's clientnumber

function connection.initClient(address, port)

		print("starting 5")
	if #ipStr == 0 then ipStr = "localhost" end
	local tcpClient, err = socket.connect(address, port)
	
		print("starting 6")
	if tcpClient == nil then
		print(err)
		statusMsg.new( err .. "!")
		menu.initMainMenu()
	else
		tcpClient:settimeout(0)
	end
		
	return tcpClient
end

function connection.getClientNumber()
	return clientNumber
end

function connection.setClientNumber(num)
	if type(num) == "string" then
		num = tonumber(num)
	end
	clientNumber = num
end

return connection
