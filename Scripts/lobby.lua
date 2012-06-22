local lobby = {}

local active
local choosingFirstWord = false

function attemptGameStart()
	buttons.clear()		-- remove game start button
	active = false
	game.init()


	--[[local numClients = 0
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
		game.init()
	end]]--
end

local firstWordInputBox
local firstWordHeaderBox
local multipleFoundHeaderBox

function firstWordSet()
	print( "match: " .. textBox.getContent( firstWordInputBox ):match( "[%d%a%s]+" ) )
	if textBox.getContent( firstWordInputBox ):match( "[%d%a%s]+" ) == textBox.getContent( firstWordInputBox ) then
		statusMsg.new( "Looking up word..." )
		local found, multiple, urlTable = wikiClient.newWord( textBox.getContent( firstWordInputBox ) )
		if multiple == true then
			statusMsg.new( "Multiple articles found" )
			textBox.setContent( firstWordHeaderBox, "Did you mean..." )

			local i = 0
			local j
			local titleStr = 0
			for k, v in pairs( urlTable ) do
				if i < 7 then
					titleStr = ""
					j = 0
					print("full: " .. #v.title, 20, 20)
					while buttonFont:getWidth( titleStr ) < buttonWidth-20 and #titleStr < #v.title do
						print(titleStr.. " " .. buttonFont:getWidth( titleStr ))
						titleStr = v.title:sub( 1, j )
						j = j+1
					end
					if #titleStr < #v.title then
						titleStr = titleStr .. "..."
					end
					buttons.add( love.graphics.getWidth()/2+20, 130 + i*(buttonHeight+2), buttonWidth, buttonHeight/2+10, titleStr, drawButton, highlightButton , nil )
				end
				i = i+1
			end
			textBox.remove( firstWordInputBox )
			firstWordInputBox = nil

			--textBox.setAccess( firstWordInputBox, true )
			return
		elseif found == false then
			statusMsg.new( "No wiki article found. Try something else." )
			textBox.setAccess( firstWordInputBox, true )
			return
		end

		startingWord = textBox.getContent( firstWordInputBox )

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

function inputFirstWord()
	if choosingFirstWord == false then
		choosingFirstWord = true

		if firstWordHeaderBox == nil then
			firstWordHeaderBox = textBox.new( love.graphics.getWidth()/2+20, 110, 2, fontInputHeader, 300 )
		end
		textBox.setContent( firstWordHeaderBox, "Where will you story start?" )
		if firstWordInputBox == nil then
			firstWordInputBox = textBox.new( love.graphics.getWidth()/2+25, 130, 1, fontInput, 200 )
		end
		textBox.setAccess( firstWordInputBox, true )
		textBox.setReturnEvent( firstWordInputBox, firstWordSet )
	end
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
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 50)
	love.graphics.setColor( colBg.r, colBg.g, colBg.g, 255)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 48)
	
	love.graphics.setColor( colLobby.r,colLobby.g,colLobby.b )
	love.graphics.setFont( fontHeader )
	love.graphics.print( "Players:", 70, 65 )
	if startingWord then
		love.graphics.setColor( colBg.r, colBg.g, colBg.g, 255)
		love.graphics.print( startingWord, (love.graphics.getWidth() - fontHeader:getWidth(startingWord))/2, 20 )
	end
	
	for k, v in pairs( connectedClients ) do
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.rectangle("fill", 0, 110 + 50*(k-1), love.graphics.getWidth(), 35)
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", 0, 111 + 50*(k-1), love.graphics.getWidth(), 33)
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.setFont( mainFont )
		love.graphics.print( v.playerName, 70, 120  + 50*(k-1) )
	end

	if choosingFirstWord then
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.rectangle("fill", love.graphics.getWidth()/2, 100, love.graphics.getWidth()/2-30, love.graphics.getHeight()/2)
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", love.graphics.getWidth()/2+1, 100, love.graphics.getWidth()/2-32, love.graphics.getHeight()/2-1)
	end
end

function lobby.isWordInputVisible()
	return choosingFirstWord
end

return lobby
