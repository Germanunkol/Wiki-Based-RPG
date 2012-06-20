local lobby = {}

local active

function attemptGameStart()
	local numClients = 0
	for k, cl in pairs( connectedClients ) do
		numClients = numClients + 1
		
		cl.client:send( "GAMESTART:\n" )
	end
	print("clients found: " .. numClients)
	if numClients == 0 then
		statusMsg.new( "Need at least one player!" )
	else
		buttons.clear()		-- remove game start button
		active = false
		startGame()
	end
end

function lobby.init()
	active = true

	if server then
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Start Game", drawButton, highlightButton , attemptGameStart )
	end
end

function lobby.deactivate()
	active = false
end

function lobby.active()
	return active
end

function lobby.showPlayers()
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 50)
	love.graphics.setColor( colBg.r, colBg.g, colBg.g, 255)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 48)
	
	love.graphics.setColor( colLobby.r,colLobby.g,colLobby.b )
	love.graphics.setFont( fontHeader )
	love.graphics.print( "Players:", 70, 65 )
	
	for k, v in pairs( connectedClients ) do
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.rectangle("fill", 0, 110 + 50*(k-1), love.graphics.getWidth(), 35)
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", 0, 111 + 50*(k-1), love.graphics.getWidth(), 33)
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.setFont( mainFont )
		love.graphics.print( v.playerName, 70, 120  + 50*(k-1) )
	end
	
	buttons.show()
end

--function 





return lobby
