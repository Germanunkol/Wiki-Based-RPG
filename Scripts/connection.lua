-- connection of server/client

local connection = {}

connectedClients = {}

local maxPlayers = 0
local numOfPlayers = 0

function connection.initServer(host, port, maxConnections)
	local tcpServer = socket.bind(host, port)
	maxPlayers = maxConnections
	if tcpServer == nil then
		print(err)
	else
		local addr, p = tcpServer:getsockname()
		print("Server initialized @: " .. addr .. ":" .. p)
	end
	
	if tcpServer then
		tcpServer:settimeout(0)
	end
	
	return tcpServer
end

-- Send playernames, stats etc:
local function synchronizeClients( newClient )
	numOfPlayers = 0
	for k, cl in pairs( connectedClients ) do
		cl.client:send("NEWPLAYER:" .. newClient.clientNumber .. newClient.playerName .. "\n")
		if	cl ~= newClient then
			newClient.client:send("NEWPLAYER:" .. cl.clientNumber .. cl.playerName .. "\n")
			if cl.description then	-- if I have a character description already, send it along.
				newClient.client:send("CHARDESCRIPTION:" .. cl.clientNumber .. cl.description .. "\n")
			end
			if cl.ready then	-- if I have a character description already, send it along.
				newClient.client:send("READY:" .. cl.clientNumber .. "true" .. "\n")
			else
				newClient.client:send("READY:" .. cl.clientNumber .. "false" .. "\n")
			end
			if cl.avatar then
				local str = ""
				for i=0,AVATAR_PIXELS_X*AVATAR_PIXELS_Y-1,1 do
					str = str .. cl.avatar[i]
				end
				newClient.client:send("AVATAR:" .. cl.clientNumber .. str .. "\n")
			end
		end
		numOfPlayers = numOfPlayers + 1
	end
end

function handleNewClient( newClient )
	print("new client connected")
	local clientNumber = 0
	for i=1, maxPlayers, 1 do
		if connectedClients[i] == nil then
			connectedClients[i] = { client = newClient, playerName = "", inventory = {} }
			connectedClients[i].clientNumber = i
			clientNumber = i
			break
		end
	end
	
	if game.active() then
		newClient:send("ERROR:NOTINLOBBY:\n")
		connectedClients[clientNumber] = nil
		newClient:close()
		newClient = nil
	else
		if clientNumber <= maxPlayers and clientNumber ~= 0 then
			newClient:send("CLIENTNUMBER:" .. clientNumber .. "\n")
			if startingWord then 
				newClient:send("CURWORD:" .. startingWord .. "\n")
			end
			if themes.getCurrentTheme() then
				newClient:send("THEME:" .. themes.getCurrentTheme() .. "\n")
			end
			
			local toSend = "ABILITIES:"
			for k, v in pairs(abilities) do
				toSend = toSend .. v .. ","
			end
			newClient:send(toSend .. "\n")
		else
			newClient:send("ERROR:SERVERFULL\n")
			connectedClients[clientNumber] = nil
			newClient:close()
			newClient = nil
		end
	end
	if newClient then
		statusMsg.new( NEW_PLAYER_CONNECTED_STR )
	end
end

function connection.serverBroadcast( msg )
	numOfPlayers = 0
	for k, cl in pairs( connectedClients ) do
		cl.client:send(msg .. "\n")
		numOfPlayers = numOfPlayers + 1
	end
end

function connection.getPlayers()
	return numOfPlayers
end

function connection.receiveDiscription( descr )
	local ID = tonumber( descr:sub(1,1) )
	for k, cl in pairs(connectedClients) do
		if cl.clientNumber == ID then
			cl.description = safeSub(descr, 2, #descr)
			return
		end
	end
end

function connection.receiveAvatar( str )
	for k, cl in pairs(connectedClients) do
		if cl.clientNumber == tonumber(str:sub(1, 1)) then
			str = safeSub(str, 2, #str )
			cl.avatar = {}
			for i=0,AVATAR_PIXELS_X*AVATAR_PIXELS_Y-1,1 do
				cl.avatar[i] = tonumber( safeSub(str, i+1,i+1) )
			end
			return
		end
	end
end

function connection.sendAvatar()
	local str = ""
	for i=0,AVATAR_PIXELS_X*AVATAR_PIXELS_Y-1,1 do
		str = str .. avatar[i]
	end
	client:send("AVATAR:" .. str .. "\n")
end

function connection.sendStatistics()
	local str = ""
	for i=1,#setStatistics,1 do
		str = str .. setStatistics[i] .. ","
	end
	if DEBUG then print("sending stats: " .. str) end
	client:send("STATS:" .. str .. "\n")
end

function receiveStats( cl, str )
	local s,e = str:find(",")
	local num, prev, i = 0, 1, 1
	cl.statistics = {}
	while s do
		num = tonumber( safeSub(str,prev, s-1) )
		if not num then break end
		cl.statistics[i] = num
		prev = e+1
		s,e = str:find( ",", e+1 )
		i = i+1
		if DEBUG then print( "stat received: " .. num ) end
	end
end

function connection.inventoryAdd( playerID, object )
	for k, cl in pairs( connectedClients ) do
		if cl.clientNumber == tonumber(playerID) then
			if #cl.inventory >= INVENTORY_CAPACITY then return end
			for a, v in pairs(cl.inventory) do
				if v == object then return end
			end
			table.insert( cl.inventory, object )
			game.receiveStory( cl.playerName .. " " .. RECEIVED_STR .. " " .. object, true )
			
			textBox.highlightText( gameTextBox, object, colHighlightWikiWord.r, colHighlightWikiWord.g, colHighlightWikiWord.b )
		end
	end
	if server then
		connection.serverBroadcast("INVADD:" .. playerID .. object)
	end
end


function connection.sendAbilities()			-- put all abilities into a string and send it to all players.
	
	toSend = ""

	for k, v in pairs(abilities) do
		toSend = toSend .. v .. ","
	end
	print(toSend)
	connection.serverBroadcast( "ABILITIES:" .. toSend )
end

function connection.inventoryRemove( playerID, object )
	
	if server then
		connection.serverBroadcast("INVREMOVE:" .. playerID .. object)
	end
	
	if playerID then
		for k, cl in pairs( connectedClients ) do
			if cl.clientNumber == playerID then
				for a, v in pairs(cl.inventory) do
					if v == object then
						cl.inventory[a] = nil		-- remove the object from the player's inventory.
						break
					end
				end
			end
		end
	end
end

local start, ending

function connection.runServer( tcpServer )		-- handle all messages that come from the clients
	local newClient, err = tcpServer:accept()
	
	if newClient ~= nil then
		print("someone's trying to join")
		newClient:settimeout(0)
		handleNewClient( newClient )
	end
	
	for k, cl in pairs(connectedClients) do
		local msg, err = cl.client:receive()
		if msg ~= nil then
			if DEBUG then print("received: " .. msg) end
			if msg:find( "NAME:" ) == 1 then
				local nameTaken = false
				cl.playerName = safeSub(msg, 6, #msg )
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
				
			else
			
				start, ending = msg:find( "CHARDESCRIPTION:" )
				if start == 1 then
					connection.receiveDiscription( cl.clientNumber .. safeSub(msg, ending+1, #msg) )
					connection.serverBroadcast("CHARDESCRIPTION:" .. cl.clientNumber .. safeSub(msg, ending+1, #msg))
				end
				
				start, ending = msg:find( "READY:true" )
				if start == 1 then
					cl.ready = true
					connection.serverBroadcast("READY:" .. cl.clientNumber .. "true")
				end
				
				start, ending = msg:find( "READY:false" )
				if start == 1 then
					cl.ready = false
					connection.serverBroadcast("READY:" .. cl.clientNumber .. "false")
				end
				
				start, ending = msg:find( "AVATAR:" )
				if start == 1 then
					connection.receiveAvatar( cl.clientNumber .. safeSub(msg, ending+1, #msg ) )
					connection.serverBroadcast("AVATAR:" .. cl.clientNumber .. safeSub(msg, ending+1, #msg ) )
				end

				start, ending = msg:find( "STATS:" )
				if start == 1 then
					receiveStats( cl,  safeSub(msg, ending+1, #msg ) )
					connection.serverBroadcast("STATS:" .. cl.clientNumber .. ":" .. safeSub(msg, ending+1, #msg ) )
				end

				start, ending = msg:find( "ACTION:do" )
				if start == 1 then
					game.receiveAction( cl.playerName .. safeSub(msg, ending+1, #msg), "do", cl.clientNumber)
					connection.serverBroadcast( "ACTION:do" .. cl.playerName .. safeSub(msg, ending+1, #msg) )
				end
				start, ending = msg:find( "ACTION:say" )
				if start == 1 then
					game.receiveAction( cl.playerName .. ": \"" .. safeSub(msg, ending+1, #msg) .. "\"", "say", cl.clientNumber )
					connection.serverBroadcast( "ACTION:say" .. cl.playerName .. ": \"" .. safeSub(msg, ending+1, #msg) .. "\"")
				end
				start, ending = msg:find( "ACTION:use" )
				if start == 1 then
					game.receiveAction( cl.playerName .. " uses " .. safeSub(msg, ending+1, #msg), "use", cl.clientNumber )
					connection.serverBroadcast( "ACTION:use" .. cl.playerName .. " uses " .. safeSub(msg, ending+1, #msg) )
				end
				start, ending = msg:find( "ACTION:skip" )
				if start == 1 then
					game.receiveAction( "", "skip", cl.clientNumber )
					--connection.serverBroadcast( "ACTION:skip" .. cl.playerName .. ": " .. msg:sub(ending+1, #msg) )
				end
				
				start, ending = msg:find( "INVREMOVE:" )
				if start == 1 then
					connection.inventoryRemove( tonumber(safeSub(msg, ending+1, ending+1)), safeSub(msg, ending+2, #msg) )
					return
				end
				
				start, ending = msg:find( "CHAT:" )
				if start == 1 then
					chat.receive( cl.playerName.. ": " .. safeSub(msg, ending+1, #msg) )
					connection.serverBroadcast("CHAT:" .. cl.playerName.. ": " .. safeSub(msg, ending+1, #msg))
				end
			end
		else
			if err ~= "timeout" then
				print("error: " .. err)
				if err == "closed" then
					local clientName = cl.playerName
					connectedClients[k] = nil			-- if connection was closed, remove from table
					connection.serverBroadcast("CLIENTLEFT:".. clientName)
					if game.active() then
						game.receiveServerMessage( clientName .. " " .. PLAYER_LEFT_STR )
					end
					return
				end
			end
		end
	end
end

function connection.receiveAbilities( str )
	abilities = {}
	local s = str:find(",")
	local last = 0
	while s do
		lobby.addAbility( safeSub(str, last+1, s-1) )
		last = s
		s = str:find(",", s+1)
	end
	connection.sendStatistics()
end

function connection.runClient( cl )				--handle all messages that come from the server
	msg = cl:receive()

	if msg then
		if DEBUG then print("received: " .. msg) end
		
		if msg:find("ERROR:") == 1 then
			if msg:find( "ERROR:SERVERFULL" ) == 1 then
				client = nil
				print( "ERROR: Server is full!" )
				statusMsg.new( ERROR_SERVER_FULL_STR )
				menu.initMainMenu()
				return
			elseif msg:find( "ERROR:NAMETAKEN" ) == 1 then
				client = nil
				print( "ERROR: Name alread exists!" )
				statusMsg.new( ERROR_DUPLICATE_PLAYERNAME_STR )
				menu.initMainMenu()
				return
			elseif msg:find( "ERROR:NOTINLOBBY" ) == 1 then
				client = nil
				print( "ERROR: Server's game has already started!" )
				statusMsg.new( ERROR_GAME_ALREADY_STARTED_STR )
				menu.initMainMenu()
				return
			end
		else
		
			start, ending = msg:find( "CLIENTNUMBER:" )
			if start == 1 then
				connection.setClientNumber( safeSub(msg, ending+1, #msg) )
				return
			end
			
			start, ending = msg:find( "NEWPLAYER:" )
			if start == 1 then
				table.insert( connectedClients, {playerName=safeSub(msg, ending+2, #msg), clientNumber=tonumber(safeSub(msg, ending+1, ending+1) ), inventory={} } )
				return
			end
			
			start, ending = msg:find( "CHARDESCRIPTION:" )
			if start == 1 then
				connection.receiveDiscription( safeSub(msg, ending+1, #msg) )
			end
			
			start, ending = msg:find( "THEME:" )
			if start == 1 then
				themes.set( safeSub(msg, ending+1, #msg) )
			end
			
			start, ending = msg:find( "READY:" )
			if start == 1 then
				for k, cl in pairs(connectedClients) do
					if cl.clientNumber == tonumber(safeSub(msg, ending+1, ending+1)) then
						if safeSub(msg, ending+2, #msg):find("true") then
							cl.ready = true
						else
							cl.ready = false
						end
						return
					end
				end
				return
			end
			
			start, ending = msg:find( "AVATAR:" )
			if start == 1 then
				connection.receiveAvatar( safeSub(msg, ending+1, #msg) )
			end
			
			start, ending = msg:find( "STATS:" )
			if start == 1 then
				-- first digit it playerNumber:
				for k, c in pairs( connectedClients ) do
					if c.clientNumber == tonumber(safeSub(msg, ending+1, ending+1 )) then
						cl = c
						break
					end
				end
				if cl then
					receiveStats( cl,  safeSub(msg,  ending+3, #msg ) )
				end
			end
			
			start, ending = msg:find( "CURWORD:" )
			if start == 1 then
				game.clientReceiveNewWord( safeSub(msg, ending+1, #msg) )
				return
			end
			
			start, ending = msg:find( "ABILITIES:" )
			if start == 1 then
				connection.receiveAbilities( safeSub(msg, ending+1, #msg) )
			end
			
			start, ending = msg:find( "GAMESTART:" )
			if start == 1 then
				lobby.deactivate()
				game.init()
				return
			end
			
			start, ending = msg:find( "NEWPLAYERTURNS:" )
			if start == 1 then
				displayNextPlayerTurns(safeSub(msg, ending+1, #msg))
				return
			end
			
			start, ending = msg:find( "STORY:" )
			if start == 1 then
				game.receiveStory( safeSub(msg, ending+1, #msg) )
				return
			end
			
			start, ending = msg:find( "YOURTURN:" )
			if start == 1 then
				game.startMyTurn()
				return
			end
			
			start, ending = msg:find( "ACTION:do" )
			if start == 1 then
				game.receiveAction( safeSub(msg, ending+1, #msg), "do" )
				return
			end
			start, ending = msg:find( "ACTION:say" )
			if start == 1 then
				game.receiveAction( safeSub(msg, ending+1, #msg), "say" )
				return
			end
			start, ending = msg:find( "ACTION:use" )
			if start == 1 then
				game.receiveAction( safeSub(msg, ending+1, #msg), "use" )
				return
			end
			
			start, ending = msg:find( "INVADD:" )
			if start == 1 then
				connection.inventoryAdd( safeSub(msg, ending+1, ending+1), safeSub(msg, ending+2, #msg) )
				return
			end
			
			start, ending = msg:find( "INVREMOVE:" )
			if start == 1 then
				connection.inventoryRemove( tonumber(safeSub(msg, ending+1, ending+1)), safeSub(msg, ending+2, #msg) )
				return
			end
			
			start, ending = msg:find( "CHAT:" )
			if start == 1 then
				chat.receive( safeSub(msg, ending+1, #msg) )
				return
			end
			
			start, ending = msg:find( "TXT:" )
			if start == 1 then
				game.receiveStory( msg:sub(ending+1, #msg), true )
				return
			end
			
			start, ending = msg:find( "SERVERSHUTDOWN:" )
			if start == 1 then
				if game.active() then
					game.receiveServerMessage( SERVER_CLOSED_GAME_STR )
				else
					cl:close()
					lobby.deactivate()
					menu.initMainMenu()
					statusMsg.new( SERVER_CLOSED_GAME_STR )
				end
				return
			end
			
			start, ending = msg:find( "CLIENTLEFT:" )
			if start == 1 then
				game.receiveServerMessage( safeSub(msg, ending+1, #msg) .. PLAYER_LEFT_STR )
				for k, v in pairs(connectedClients) do
					if v.playerName == safeSub(msg, ending+1, #msg) then
						connectedClients[k] = nil
						break
					end
				end
				return
			end
			
		end
	end
end

local clientNumber = nil			--client's clientnumber

function connection.initClient( address, port )

	if #address == 0 then address = "localhost" end
	local tcpClient, err = socket.connect(address, port)

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
