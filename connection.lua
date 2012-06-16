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


function connection.runServer(tcpServer)
	
	local newClient, err = tcpServer:accept()
	
	if newClient ~= nil then
		print("new client connected")
		local clientNumber = 0
		for i=1, maxPlayers, 1 do
			if connectedClients[i] == nil then
				connectedClients[i] = {client = newClient}
				connectedClients[i].clientNumber = i
				clientNumber = i
				break
			end
		end
		
		if clientNumber <= maxPlayers and clientNumber ~= 0 then
			newClient:send("CLIENTNUMBER" .. clientNumber .. "\n")
		else
			newClient:send("SERVERFULL\n")
			connectedClients[clientNumber] = nil
			newClient:close()
		end
	end
	
	for k, cl in pairs(connectedClients) do
		local msg, err = cl.client:receive()
	
		if msg ~= nil then
			print("received: " .. msg)
			if msg:find( "NAME:" ) == 1 then
				cl.playerName = msg:sub( 6, #msg )
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

local clientNumber = nil			--client's clientnumber

function connection.initClient(address, port)

	local tcpClient, err = socket.connect(address, port)
	
	if tcpClient == nil then
		print(err)
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
