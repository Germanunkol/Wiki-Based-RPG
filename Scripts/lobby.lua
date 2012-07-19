local lobby = {}

local active
local choosingFirstWord = false

function attemptGameStart()

	local numClients = 0
	for k, cl in pairs( connectedClients ) do
		numClients = numClients + 1
		
		cl.client:send( "GAMESTART:\n" )
	end
	print("clients found: " .. numClients)
	--if numClients == 0 then
		statusMsg.new( "Need at least one player!" )
	--else
		buttons.clear()		-- remove game start button
		active = false
		game.init()
	--end
end

local found, multiple, urlTable

function lobby.inputFirstWord()
	wikiClient.inputFirstWord( love.graphics.getWidth()/2+1, 100, love.graphics.getWidth()/2-32, love.graphics.getHeight()/2-1, lobby.newWordSet, "What will the story be about?" )
end

function lobby.newWordSet( word )
	startingWord = word
	local start, ending = startingWord:find( "%(.*%)" )
	if start then
	--print("found: " .. curGameWord:sub(start, ending))
		startingWord = startingWord:sub( 1, start-1 ) .. startingWord:sub( ending+1, #curGameWord )
		while startingWord:sub( #startingWord, #startingWord )  == " " do		--don't allow trailing spaces
			startingWord = startingWord:sub( 1, #startingWord-1 )
		end
		if #startingWord == 0 then
			startingWord = word
		end
	end
	
	connection.serverBroadcast("CURWORD:" .. startingWord .. "\n")

	buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Choose first Word", drawButton, highlightButton , lobby.inputFirstWord )
	buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Start Game", drawButton, highlightButton , attemptGameStart )
	
	statusMsg.new( "Start word set." )
end

function lobby.init()
	active = true

	if server then
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Choose first Word", drawButton, highlightButton , lobby.inputFirstWord )
	end

	local helpFile = io.open( "Help/lobby.txt", "r" )
	if not helpFile then
		helpFile = io.open( "Help\\lobby.txt", "r" )
	end
	if helpFile then
		helpString = helpFile:read( "*all" )
		helpFile:close()
	end

end

function lobby.deactivate()
	active = false
end

function lobby.active()
	return active
end

function lobby.showPlayers()
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.g, 255)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 48)
	
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b )
	love.graphics.setFont( fontHeader )
	love.graphics.print( "Heroes:", 70, 65 )
	
	
	if startingWord then
		love.graphics.setFont( buttonFont )
		love.graphics.setColor( 0,0,0 )
		love.graphics.print( "A story of ", (love.graphics.getWidth() - fontHeader:getWidth(startingWord))/2-buttonFont:getWidth("A story of ") , 24 )
		love.graphics.setFont( fontHeader )
		love.graphics.setColor( colWikiWord.r,colWikiWord.g,colWikiWord.b )
		love.graphics.print( startingWord, (love.graphics.getWidth() - fontHeader:getWidth(startingWord))/2, 20 )
	end
	
	
	for k, cl in pairs( connectedClients ) do
		--love.graphics.setColor( 0, 0, 0 , 255)
		--love.graphics.rectangle("fill", 0, 110 + 50*(k-1), love.graphics.getWidth(), 35)
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", 0, 111 + 50*(cl.clientNumber-1), love.graphics.getWidth(), 33)
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.setFont( mainFont )
		love.graphics.print( cl.playerName, 70, 120  + 50*(cl.clientNumber-1) )
	end
end


return lobby
