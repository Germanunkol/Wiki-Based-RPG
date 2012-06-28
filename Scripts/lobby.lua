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

local firstWordInputBox
local firstWordHeaderBox
local multipleFoundHeaderBox

local found, multiple, urlTable

function chooseWord( k )
	
	startingWord = urlTable[k].title
	connection.serverBroadcast("STARTWORD:" .. startingWord .. "\n")
	
	choosingFirstWord = false
	textBox.remove( firstWordInputBox )
	firstWordInputBox = nil
	textBox.remove( firstWordHeaderBox )
	firstWordHeaderBox = nil		
	buttons.clear()
	buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Start Game", drawButton, highlightButton , attemptGameStart )
	statusMsg.new( "Starting word set." )
end

function firstWordSet()
	if textBox.getContent( firstWordInputBox ):match( "[%d%a%s]+" ) == textBox.getContent( firstWordInputBox ) then
		found, multiple, urlTable = wikiClient.newWord( textBox.getContent( firstWordInputBox ) )
		if multiple == true then
			statusMsg.new( "Multiple articles found. Choose one." )
			textBox.setContent( firstWordHeaderBox, "Did you mean..." )
			local fieldWidth = love.graphics.getWidth()/2-70
			local i = 0
			local j
			local titleStr = 0
			for k, v in pairs( urlTable ) do
				if i < 7 then
					titleStr = ""
					for char in v.title:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
						titleStr = titleStr .. char
						if buttonFont:getWidth( titleStr ) >= fieldWidth-30 then
							 break
						end
					end
					if titleStr ~= v.title then
						titleStr = titleStr .. "..."
					end
					buttons.add( love.graphics.getWidth()/2+20, 140 + i*(buttonHeight-2), fieldWidth, buttonHeight/2+10, titleStr, drawButton, highlightButton , chooseWord, k )
				end
				i = i+1
			end
			textBox.remove( firstWordInputBox )
			firstWordInputBox = nil

			--textBox.setAccess( firstWordInputBox, true )
			return
		elseif found == nil or found == false then
			statusMsg.new( "No wiki article found. Try another word or connect to the internet." )
			textBox.setAccess( firstWordInputBox, true )
			return
		end

		startingWord = textBox.getContent( firstWordInputBox )
		connection.serverBroadcast("STARTWORD:" .. startingWord .. "\n")
		statusMsg.new( "Starting word set." )
		
		choosingFirstWord = false
		textBox.remove( firstWordInputBox )
		firstWordInputBox = nil
		textBox.remove( firstWordHeaderBox )
		firstWordHeaderBox = nil		

		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Start Game", drawButton, highlightButton , attemptGameStart )
	else
		textBox.setAccess( firstWordInputBox, true )
		statusMsg.new( "Only numbers, spaces and letters allowed!" )
	end
end

function startFirstWordSet()
	statusMsg.new( "Looking up word..." )	
	table.insert( nextFrameEvent, {func = firstWordSet, frames = 2 } ) --make sure message is drawn before calling the event
end

function inputFirstWord()
	if choosingFirstWord == true then
		textBox.remove( firstWordInputBox )
		firstWordInputBox = nil
		textBox.remove( firstWordHeaderBox )
		firstWordHeaderBox = nil
		buttons.clear()
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Choose first Word", drawButton, highlightButton , inputFirstWord )
	end
	choosingFirstWord = true

	if firstWordHeaderBox == nil then
		firstWordHeaderBox = textBox.new( love.graphics.getWidth()/2+20, 110, 2, fontInputHeader, 300 )
	end
	textBox.setContent( firstWordHeaderBox, "What will the story be about?" )
	if firstWordInputBox == nil then
		firstWordInputBox = textBox.new( love.graphics.getWidth()/2+25, 130, 1, fontInput, 200 )
		textBox.setColour( firstWordInputBox, colTextInput.r, colTextInput.g, colTextInput.b )
	end
	textBox.setAccess( firstWordInputBox, true )
	textBox.setReturnEvent( firstWordInputBox, startFirstWordSet )
end

function lobby.init()
	active = true

	if server then
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Choose first Word", drawButton, highlightButton , inputFirstWord )
	end
end

function lobby.deactivate()
	active = false
end

function lobby.active()
	return active
end

function lobby.showPlayers()
	love.graphics.setColor( colBg.r, colBg.g, colBg.g, 255)
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
	
	
	for k, v in pairs( connectedClients ) do
		--love.graphics.setColor( 0, 0, 0 , 255)
		--love.graphics.rectangle("fill", 0, 110 + 50*(k-1), love.graphics.getWidth(), 35)
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", 0, 111 + 50*(k-1), love.graphics.getWidth(), 33)
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.setFont( mainFont )
		love.graphics.print( v.playerName, 70, 120  + 50*(k-1) )
	end

	if choosingFirstWord then
		--love.graphics.setColor( 0, 0, 0 , 255)
		--love.graphics.rectangle("fill", love.graphics.getWidth()/2, 100, love.graphics.getWidth()/2-30, love.graphics.getHeight()/2)
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", love.graphics.getWidth()/2+1, 100, love.graphics.getWidth()/2-32, love.graphics.getHeight()/2-1)	
		textBox.display( firstWordInputBox )
		textBox.display( firstWordHeaderBox )
	end
end

function lobby.isWordInputVisible()
	return choosingFirstWord
end

return lobby
