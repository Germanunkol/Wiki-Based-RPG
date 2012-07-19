local game = {}

local active = false

--local REPLYTIME = 180

local NUMBER_OF_JOKERS = 3

local gameAreaX = 0
local gameAreaY = 0
local gameAreaWidth = 0
local gameAreaHeight = 0

local chatAreaX = 0
local chatAreaY = 0
local chatAreaWidth = 0
local chatAreaHeight = 0

local nextPlayerAreaX = 0
local nextPlayerAreaY = 0
local nextPlayerAreaWidth = 0
local nextPlayerAreaHeight = 0

local gameInputAreaX = 0
local gameInputAreaY = 0
local gameInputAreaWdith = 0
local gameInputAreaHeight = 0

local gameInputBox = nil
local gameStatusBox = nil
local gameTextBox = nil

local inventoryFieldHeader

local waitForPlayerActions = false
local allPlayersHaveReacted = false
local playersHaveRepliedTable = {}

playerTurns1 = {}
playerTurns2 = {}
playerTurns3 = {}
playerTurns4 = {}

playerTurnsStrings = {}

local fullNumberOfTurns = 1
local currentPlayer = ""

function addPlayerTurns()
	playerTurns1 = playerTurns2
	playerTurns2 = playerTurns3
	playerTurns3 = playerTurns4
	playerTurns4 = {}
	for k, v in pairs(connectedClients) do
		table.insert( playerTurns4, { ID = v.clientNumber, name = v.playerName } )
	end
	playerTurns4[0] = {ID = 0, name = "Server"}
	for i = #playerTurns4, 2, -1 do -- shuffle
		local r = math.random(i) -- select a random number between 1 and i
		playerTurns4[i], playerTurns4[r] = playerTurns4[r], playerTurns4[i] -- swap the randomly selected item to position i
	end

	sendNextPlayerTurns()
end

function sendNextPlayerTurns()
	local str = ""
	local j = fullNumberOfTurns
	for i=0,#playerTurns1,1 do 
		if playerTurns1[i] then str = str .. j .. ":" .. playerTurns1[i].name .. "," .. playerTurns1[i].ID ..";" end
		j = j+1
	end
	for i=0,#playerTurns2,1 do 
		if playerTurns2[i] then str = str .. j .. ":" .. playerTurns2[i].name .. "," .. playerTurns2[i].ID ..";" end
		j = j+1
	end
	for i=0,#playerTurns3,1 do 
		if playerTurns3[i] then str = str .. j .. ":" .. playerTurns3[i].name .. "," .. playerTurns3[i].ID ..";" end
		j = j+1
	end
	for i=0,#playerTurns4,1 do 
		if playerTurns4[i] then str = str .. j .. ":" .. playerTurns4[i].name .. "," .. playerTurns4[i].ID ..";" end
		j = j+1
	end
	connection.serverBroadcast("NEWPLAYERTURNS:" .. str )
	displayNextPlayerTurns( str )
end

function removePlayerTurn()
	for i=0,#playerTurns1,1 do
		playerTurns1[i] = playerTurns1[i+1]		-- move all upcoming players up one:
	end
	printTable(playerTurns1)
	--playerTurns1[#playerTurns1] = nil
	-- send to other players, but only if the round isn't over yet. If it's over, then the addNewPlayerTurns function will send the data.:
	if playerTurns1[0] then sendNextPlayerTurns() end
end

function displayNextPlayerTurns( str )
	if nextPlayerAreaWidth <= 0 then return end
	playerTurnsStrings = {}
	local s,e = str:find(";", 1, true)
	local player, name
	i = 1
	while s do
		player = str:sub(1,e)
		name = player:sub(1, player:find(",", 1, true) - 1)
		while fontStatus:getWidth(name) > nextPlayerAreaWidth - 10 do
			name = name:sub(1, #name-1)
		end
		playerTurnsStrings[i] = {str=name, ID = tonumber(player:sub( player:find(",", 1, true)+1, #player-1)) }
		i = i+1
		str = str:sub(e+1, #str)
		s,e = str:find(";", 1, true)
	end
	currentPlayer = ""
	if playerTurnsStrings[1] and playerTurnsStrings[1].str and playerTurnsStrings[1].str:find(":", 1, true) then
		currentPlayer = playerTurnsStrings[1].str:sub( playerTurnsStrings[1].str:find(":", 1, true) +1, #playerTurnsStrings[1].str)
	end
	if client then 
		textBox.setContent( gameStatusBox, "Waiting for " .. currentPlayer )
	end
	--printTable(playerTurnsStrings)
end

function game.sendNextTurn()
	removePlayerTurn()
	if playerTurns1[0] then
		for k, cl in pairs( connectedClients ) do
			if cl.playerName == playerTurns1[0].name then
				cl.client:send( "YOURTURN:\n" )
				return true
			end
		end
	end
	return false
end

function game.startMyTurn()
	if client then
		waitForPlayerActions = true
		if chat.getActive() == false then
			textBox.setAccess( gameInputBox, true )
		end
		sound.playNotification()
		textBox.setContent( gameStatusBox, "Your Turn! What would you like to do?" )
		textBox.setReturnEvent( gameInputBox, game.sendAction )
	end
end

local function scrollGameBox()
	local linesFittingOnScreen
	if textBox.getAccess( gameInputBox ) then
		linesFittingOnScreen = math.floor( (gameAreaHeight - gameInputAreaHeight)/textBox.getFont( gameTextBox ):getHeight() ) - 1
	else
		linesFittingOnScreen = math.floor( gameAreaHeight/textBox.getFont( gameTextBox ):getHeight() ) - 1
	end
	textBox.setVisibleLines( gameTextBox, textBox.numLines( gameTextBox )-linesFittingOnScreen, linesFittingOnScreen )
end

local chosenURLs

function chooseNextWord( index )
	if chosenURLs then
		nextWordChosen = true
		
		-- change colour of last curGameWord:
		textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWord.r, colHighlightWikiWord.g, colHighlightWikiWord.b )
		curGameWord = chosenURLs[index].title
		local start, ending = curGameWord:find( "%(.*%)" )
		if start then
		--print("found: " .. curGameWord:sub(start, ending))
			curGameWord = curGameWord:sub( 1, start-1 ) .. curGameWord:sub( ending+1, #curGameWord )
			while curGameWord:sub( #curGameWord, #curGameWord )  == " " do		--don't allow trailing spaces
				curGameWord = curGameWord:sub( 1, #curGameWord-1 )
			end
			if #curGameWord == 0 then
				curGameWord = chosenURLs[index].title
			end
		end
		
		statusMsg.new( "Chose: \"" .. curGameWord .."\"")
		
		textBox.highlightClearAll( gameInputBox )
		textBox.highlightText( gameInputBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
		textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
		
		wikiClient.setNewWord( chosenURLs[index] )
		
		buttons.clear()
		if server then game.setJokerButtons() end
		game.setButtons()
		textBox.setContent( inventoryFieldHeader, "" )
		if waitForPlayerActions == false then 
			textBox.setContent( gameStatusBox, "Continue the story. Use \"" .. curGameWord .. "\" in your text.")
			if chat.getActive() == false then
				textBox.setAccess( gameInputBox, true, true )
				scrollGameBox()
			end
		end
		chosenURLs = nil
	end
end

function game.serverChooseNextWord()

	chosenURLs = wikiClient.nextWord()
	textBox.setContent( inventoryFieldHeader, "Choose your path..." )
	if chosenURLs then
		local i = 0
		local j
		local titleStr = 0
		
		for k, v in pairs( chosenURLs ) do							-- show all possible Words that server can choose as buttons.
			print(k .. ": " .. v.title .. " @ " .. v.url)
			if i < 5 then
				titleStr = ""
				for char in v.title:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- make sure button title isn't larger than button
					titleStr = titleStr .. char
					if buttonFont:getWidth( titleStr ) >= chatAreaWidth-30 then
						 break
					end
				end
				if titleStr ~= v.title then
					titleStr = titleStr .. "..."
				end
				buttons.add( chatAreaX, chatAreaY+chatAreaHeight+35+i*(buttonHeight-5), chatAreaWidth, buttonHeight/2+10, titleStr, drawButton, highlightButton, chooseNextWord, k )
			end
			i = i+1
		end
	else
		print("ERROR: Uhm... no urls found...?")
	end
end

function game.clientReceiveNewWord( word )
	if startingWord == nil or not game.active() then
		startingWord = word
	else
		--change colour of previous words:
		if gameTextBox then
			textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWord.r, colHighlightWikiWord.g, colHighlightWikiWord.b)
		end
	end
	curGameWord = word
	if gameTextBox then
		textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
	end
end

function game.useJoker()

	if wikiClient.getNumOfPreviousWords() < 3 then
		statusMsg.new("Need to have played at least 4 Words!")
		return
	end

	NUMBER_OF_JOKERS = NUMBER_OF_JOKERS-1
	
	game.setJokerButtons()
	
	connection.serverBroadcast("CHAT:[Server used joker]")
	chat.receive( "[Server used joker]" )
	
	chat.setAccess( false )
	textBox.setAccess( gameInputBox, false )
	scrollGameBox()
	
	-- wikiClient.inputFirstWord( chatAreaX, chatAreaY+chatAreaHeight+10, chatAreaWidth, gameAreaHeight - chatAreaHeight-20, game.newWordSet, "Choose new direction:")
	chosenURLs = wikiClient.randomPreviousWords()
	
	if chosenURLs then
	
		nextWordChosen = false
	
		local i = 0
		local j
		local titleStr = 0
		
		for k, v in pairs( chosenURLs ) do							-- show all possible Words that server can choose as buttons.
			print(k .. ": " .. v.title .. " @ " .. v.url)
			if i < 5 then
				titleStr = ""
				for char in v.title:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- make sure button title isn't larger than button
					titleStr = titleStr .. char
					if buttonFont:getWidth( titleStr ) >= chatAreaWidth-30 then
						 break
					end
				end
				if titleStr ~= v.title then
					titleStr = titleStr .. "..."
				end
				buttons.add( chatAreaX, chatAreaY+chatAreaHeight+35+i*(buttonHeight-5), chatAreaWidth, buttonHeight/2+10, titleStr, drawButton, highlightButton, chooseNextWord, k )
			end
			i = i+1
		end
	else
		print("ERROR: Uhm... no urls found...?")
	end
	
end

function game.setJokerButtons()
	buttons.clear()
	for i = 1,NUMBER_OF_JOKERS,1 do
		buttons.add( chatAreaX+25*(i-1), gameAreaY + gameAreaHeight-25, 25,25, tostring(i), drawButton, highlightButton, game.useJoker )
	end
	
	game.setButtons()
end

function game.newWordSet( word )
	nextWordChosen = true
		
	-- change colour of last curGameWord:
	textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWord.r, colHighlightWikiWord.g, colHighlightWikiWord.b )
	curGameWord = word
	local start, ending = curGameWord:find( "%(.*%)" )
	if start then
	--print("found: " .. curGameWord:sub(start, ending))
		curGameWord = curGameWord:sub( 1, start-1 ) .. curGameWord:sub( ending+1, #curGameWord )
		while curGameWord:sub( #curGameWord, #curGameWord )  == " " do		--don't allow trailing spaces
			curGameWord = curGameWord:sub( 1, #curGameWord-1 )
		end
		if #curGameWord == 0 then
			curGameWord = chosenURLs[index].title
		end
	end
	
	connection.serverBroadcast("CURWORD:" .. curGameWord .. "\n")
	
	textBox.highlightClearAll( gameInputBox )
	textBox.highlightText( gameInputBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
	textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
	
	buttons.clear()
	if server then game.setJokerButtons() end
	game.setButtons()
	textBox.setContent( inventoryFieldHeader, "" )
	if waitForPlayerActions == false then 
		textBox.setContent( gameStatusBox, "Continue the story. Use \"" .. curGameWord .. "\" in your text.")
		if chat.getActive() == false then
			textBox.setAccess( gameInputBox, true, true )
			scrollGameBox()
		end
	end
	
	statusMsg.new( "New word set." )
end

function game.inputEscape()
	scrollGameBox()
end

function game.sendStory()
	local str = textBox.getContent( gameInputBox )
	if #str > 0 then
		if str:upper():find( curGameWord:upper(), 1, true ) then
			playersHaveRepliedTable = {}
			
			fullNumberOfTurns = fullNumberOfTurns + 1
				
			connection.serverBroadcast("CURWORD:" .. curGameWord .. "\n")		--send the current wiki word along, so that it can be highlighted on the players' side.
			connection.serverBroadcast( "STORY:" .. str .. "\n")
			if game.sendNextTurn() then
				allPlayersHaveReacted = false
			else
				allPlayersHaveReacted = true
			end
			game.receiveStory( str )
			textBox.setContent( gameInputBox, "" )
			textBox.setContent( gameStatusBox, "Waiting for heroes to reply..." )
			textBox.setColour( gameStatusBox, 0, 0, 0 )
			waitForPlayerActions = true
			nextWordChosen = false
			statusMsg.new("Loading...")
			table.insert( nextFrameEvent, {func = game.serverChooseNextWord, frames = 2 } )
			table.insert( nextFrameEvent, {func = statusMsg.new, frames = 3, arg = "How should the story continue?" } )
			textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
		else
			textBox.setAccess( gameInputBox, true )
			scrollGameBox()
			statusMsg.new("You must use '" .. curGameWord .. "' in your Text!")
		end
	else
		textBox.setAccess( gameInputBox, true )
		scrollGameBox()
		statusMsg.new("Write something first!")
	end
	scrollGameBox()
end

function minimum( posStart1, posStart2, posEnd1, posEnd2 )
	if posStart1 and posStart2 then
		if posStart1 < posStart2 then
			return posStart1, posEnd1
		else
			return posStart2, posEnd2
		end
	elseif posStart1 then
		return posStart1, posEnd1
	elseif posStart2 then
		return posStart2, posEnd2
	else
		return nil, nil
	end
end


local actionStrings = {}

function insertAction( newStr )
	if newStr:find("/do") == 1 then
		actionStrings[#actionStrings+1] = { typ="do", str=newStr:sub(4, #newStr) }
	elseif newStr:find("/say") == 1 then
		if newStr:sub(5,5) == " " then
			actionStrings[#actionStrings+1] = { typ="say", str=newStr:sub(6, #newStr) }	--remove first character if it's a space
		else
			actionStrings[#actionStrings+1] = { typ="say", str=newStr:sub(5, #newStr) }
		end
	elseif newStr:find("/use") == 1 then
		actionStrings[#actionStrings+1] = { typ="use", str=newStr:sub(5, #newStr) }
	elseif newStr:find("/skip") then
		actionStrings[#actionStrings+1] = { typ="skip", str = "" }
	else
		actionStrings[#actionStrings+1] = { typ="say", str=newStr }		--if no command is found, use the whole string as a say command
	end
end

function game.sendAction( )
	local str = textBox.getContent( gameInputBox )
	if #str > 0 then

		actionStrings = {}		--reset previously sent actions
		if str:lower() == string.lower("/skip") then
			insertAction( "/skip" )
		else
			--the following code splits the string at the different commands (/do, /say and later /use)
			local posStart1, posEnd1 = str:find( "/say" )
			local posStart2, posEnd2 = str:find( "/do" )
			local posStart, posEnd, posStartNew, posEndNew
			posStart, posEnd = minimum( posStart1, posStart2, posEnd1, posEnd2 )
			if posStart == nil then
				insertAction( "/say " .. str )		-- if no command was used, assume /say.
			elseif posStart ~= 1 then
				insertAction( "/say " .. str:sub(1, posStart-1) )		-- if it doesn't start with a command, /say the beginning.
			end
			while posStart do
				posStart1, posEnd1 = str:find( "/say", posStart+1 )
				posStart2, posEnd2 = str:find( "/do", posStart+1 )
				posStartNew, posEndNew = minimum( posStart1, posStart2, posEnd1, posEnd2 )
				if posStartNew then
					--print(str:sub(posStart, posStartNew-1))
					insertAction( str:sub(posStart, posStartNew-1) )
				else
					insertAction( str:sub(posStart, #str) )
				end
				posStart, posEnd = posStartNew, posEndNew
			end
		end
		for key, string in ipairs(actionStrings) do
			client:send( "ACTION:" .. string.typ .. string.str .. "\n")
		end

		textBox.setContent( gameInputBox, "" )
		textBox.setContent( gameStatusBox, "Waiting for other players..." )
		textBox.setColour( gameStatusBox, 0, 0, 0 )
		waitForPlayerActions = false
	else
		textBox.setAccess( gameInputBox, true )
		scrollGameBox()
		statusMsg.new("Write something first!")	
	end
	scrollGameBox()
end

function game.receiveAction( msg, typ, clientID)
	if gameTextBox then
		if server then
			if playersHaveRepliedTable[clientID] == nil then
				playersHaveRepliedTable[clientID] = true
				-- if I have gotten no message from this player so far...
				fullNumberOfTurns = fullNumberOfTurns + 1
				if not game.sendNextTurn() then allPlayersHaveReacted = true end		-- if this was the last player in the list, continue the story.
			end
		end

		if typ == "do" then
			textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) +1, colAction.r, colAction.g, colAction.b )
		elseif typ == "say" then
			textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) +1, colSpeech.r, colSpeech.g, colSpeech.b )
		elseif typ == "use" then
			textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) +1, colUse.r, colUse.g, colUse.b )
		elseif typ == "skip" then
			print( "Player " .. clientID .. " has skipped their turn." )
		end

		if not typ == "skip" then
			-- if all that was sent was a "skip" command, don't write anything to the game window.
			textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) ..  msg .. "\n" )
		end
		
	end
	table.insert( nextFrameEvent, {func = scrollGameBox, frames = 2 } )
end

function game.receiveStory( msg )
	if gameTextBox then
		--textBox.setColourStart( gameTextBox, #textBox.getContent( gameTextBox ) + 1, colStory.r, colStory.g, colStory.b )
		textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) + 1, colStory.r, colStory.g, colStory.b )
		textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) .. "Story: " .. msg .. "\n")
	end
	table.insert( nextFrameEvent, {func = scrollGameBox, frames = 2 } )
end

function game.show()
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.b )
	love.graphics.rectangle( "fill",gameAreaX, gameAreaY, gameAreaWidth, gameAreaHeight)
	love.graphics.rectangle( "fill",chatAreaX, chatAreaY, chatAreaWidth, chatAreaHeight)
	love.graphics.rectangle( "fill",nextPlayerAreaX, nextPlayerAreaY, nextPlayerAreaWidth, nextPlayerAreaHeight)
	love.graphics.setColor( colMainBg.r, colMainBg.g, colMainBg.b )
	love.graphics.rectangle( "fill",gameAreaX+2, gameAreaY+2, gameAreaWidth-4, gameAreaHeight-4)
	love.graphics.rectangle( "fill",chatAreaX+2, chatAreaY+2, chatAreaWidth-4, chatAreaHeight-4)
	love.graphics.rectangle( "fill",nextPlayerAreaX+2, nextPlayerAreaY+2, nextPlayerAreaWidth-4, nextPlayerAreaHeight-4)
	
	
	-- display the list of players in the order in which they will be playing:
	love.graphics.setFont( fontStatus )
	if playerTurnsStrings[1] and playerTurnsStrings[1].ID and playerTurnsStrings[1].ID ~= 0 then
		local r,g,b = getClientColour(playerTurnsStrings[1].ID)
		love.graphics.setColor( r,g,b , 35 )
		love.graphics.rectangle( "fill",nextPlayerAreaX+4, nextPlayerAreaY+4, nextPlayerAreaWidth-8, fontStatus:getHeight())
		love.graphics.print( playerTurnsStrings[1].ID, nextPlayerAreaX+5, nextPlayerAreaY+5 + (1-1)*fontStatus:getHeight())
	end
	love.graphics.setColor( 0,0,0 )
	for i=1,#playerTurnsStrings,1 do
		love.graphics.print( playerTurnsStrings[i].str, nextPlayerAreaX+5, nextPlayerAreaY+5 + (i-1)*fontStatus:getHeight())
		if (i+1)*fontStatus:getHeight() > nextPlayerAreaHeight then
			break
		end
	end
	
	if textBox.getAccess( gameInputBox ) then
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b )
		love.graphics.rectangle( "fill",gameInputAreaX, gameInputAreaY, gameInputAreaWdith, gameInputAreaHeight)
	end
	
	if textBox.getAccess( gameInputBox ) then
		textBox.display( gameInputBox )
	end
	textBox.display( gameTextBox )
	textBox.display( gameStatusBox )
	
	chat.show()
	textBox.display( inventoryFieldHeader )
	
	if server and waitForPlayerActions then
		textBox.setContent( gameStatusBox, "Waiting for " .. currentPlayer )
		if allPlayersHaveReacted then
			if chat.getActive() == false and nextWordChosen == true then
				textBox.setAccess( gameInputBox, true )
			end
			scrollGameBox()
			if nextWordChosen == true then
				textBox.setContent( gameStatusBox, "Continue the story. Use \"" .. curGameWord .. "\" in your text." )
			else
				textBox.setContent( gameStatusBox, "Choose a word..." )
			end
			textBox.setColour( gameStatusBox, 0, 0, 0 )
			waitForPlayerActions = false
			sound.playNotification()
			addPlayerTurns()
		end
	elseif client and waitForPlayerActions then
		textBox.setContent( gameStatusBox, "Your turn! What would you like to do?" )
		--[[if waitForPlayerActionsTimer >= REPLYTIME then
			textBox.setAccess( gameInputBox, false )
			scrollGameBox()
			textBox.setContent( gameStatusBox, "You did nothing. Waiting for story..." )
			waitForPlayerActions = false
		end]]--
	end
end

function gameAreaClicked()
	if wikiClient.getFirstWordActive() or textBox.getAccess( gameInputBox ) then return end
	if server then
		if waitForPlayerActions then
			statusMsg.new( "Give the heroes some time to reply!" )
		elseif nextWordChosen == false then
			statusMsg.new( "Choose next word first!" )
		else
			chat.setAccess( false )
			textBox.setAccess( gameInputBox, true )
			scrollGameBox()
		end
	elseif client then
		if waitForPlayerActions then
			chat.setAccess( false )
			textBox.setAccess( gameInputBox, true )
			scrollGameBox()
		else
			statusMsg.new( "It's not your turn!" )
		end
	end
end

function chatAreaClicked()
	if wikiClient.getFirstWordActive() or chat.getActive() then return end
	chat.setAccess( true )
	textBox.setAccess( gameInputBox, false )
	scrollGameBox()
end

function game.init()
	statusMsg.new("Game starting.")
	
	sound.playNotification()
	
	active = true
	print("Game started")
	gameAreaX = 150
	gameAreaY = 40
	gameAreaWidth = love.graphics.getWidth() * 0.6 - gameAreaX
	gameAreaHeight = love.graphics.getHeight() - 50 - gameAreaY
	chatAreaX = gameAreaX + gameAreaWidth + 10
	chatAreaY =  40 --love.graphics.getHeight() / 2
	chatAreaWidth = love.graphics.getWidth() - chatAreaX - 10
	chatAreaHeight = love.graphics.getHeight() / 2 - 10
	
	nextPlayerAreaX = 10
	nextPlayerAreaY = gameAreaY
	
	nextPlayerAreaWidth = gameAreaX - nextPlayerAreaX - 10
	nextPlayerAreaHeight = love.graphics.getHeight()/2-50
	
	
	gameInputAreaX = gameAreaX + 10
	gameInputAreaY = gameAreaHeight * 0.7 + gameAreaY
	gameInputAreaWdith = gameAreaWidth - 20
	gameInputAreaHeight = gameAreaHeight * 0.3 - 10
	gameInputBox = textBox.new( gameInputAreaX + 5, gameInputAreaY + 2, math.floor(gameInputAreaHeight/fontInput:getHeight()) , fontInput, gameInputAreaWdith - 15)
	gameTextBox = textBox.new( gameAreaX + 5, gameAreaY + 5, math.floor(gameAreaHeight/fontInput:getHeight()) , fontInput, gameAreaWidth - 15)
	textBox.setEscapeEvent( gameInputBox, game.inputEscape )		--called when "escape" is pressed during input
	
	textBox.highlightText( gameTextBox, startingWord, colHighlightWikiWordNew.r,colHighlightWikiWordNew.g,colHighlightWikiWordNew.b )
	
	local r,g,b
	for key, cl in pairs( connectedClients ) do
		r,g,b = getClientColour( cl.clientNumber )
		textBox.highlightTextName( gameTextBox, cl.playerName, r,g,b , 35 )
	end

	inventoryFieldHeader = textBox.new( chatAreaX+2, chatAreaY+chatAreaHeight+8, 1, fontInputHeader, 300 )
	--textBox.setMaxVisibleLines( gameInputBox, math.floor(gameInputAreaHeight/fontInput:getHeight()) )
	buttons.clear()
	game.setButtons()
	
	gameStatusBox = textBox.new( gameAreaX + 5, 12, 2 , fontInputHeader, love.graphics.getWidth() - gameAreaX*2)
	
	chat.init( chatAreaX+10, chatAreaY+10, math.floor(chatAreaHeight/fontChat:getHeight()) - 1, fontChat, chatAreaWidth-20 )
	
	if server then
		addPlayerTurns()		-- must be called twice, because 2 rounds should be displayed.
		addPlayerTurns()
		addPlayerTurns()
		addPlayerTurns()
		game.setJokerButtons()
		curGameWord = startingWord		-- the current game's word will be the word the server chose as start word
		textBox.setContent( gameStatusBox, "Start the story. Use \"" .. startingWord .. "\" in your text." )
		textBox.setColourStart( gameStatusBox, #"Start the story. Use \""+1 , colWikiWord.r, colWikiWord.g, colWikiWord.b )
		textBox.setColourStart( gameStatusBox, #"Start the story. Use \"" + #startingWord + 1 , 0,0,0 )
		textBox.setAccess( gameInputBox, true, true )
		scrollGameBox()
		textBox.setReturnEvent( gameInputBox, game.sendStory )
		textBox.highlightText( gameInputBox, curGameWord, colHighlightWikiWord.r, colHighlightWikiWord.g, colHighlightWikiWord.b )
	else
		textBox.setContent( inventoryFieldHeader, "Inventory" )
		textBox.setContent( gameStatusBox, "Waiting for server to beginn story..." )
	end

	local helpFile = io.open( "Help/game.txt", "r" )
	if not helpFile then
		helpFile = io.open( "Help\\game.txt", "r" )
	end
	if helpFile then
		helpString = helpFile:read( "*all" )
		helpFile:close()
	end

end

function game.setButtons()
	buttons.add( gameAreaX, gameAreaY, gameAreaWidth, gameAreaHeight, "", nil, nil, gameAreaClicked )
	buttons.add( chatAreaX, chatAreaY, chatAreaWidth, chatAreaHeight, "", nil, nil, chatAreaClicked )
	buttons.add( gameAreaX+gameAreaWidth-100, gameAreaY + gameAreaHeight, 50, 20, "Up", drawButton, highlightButton, textBox.scrollUp, gameTextBox )
	buttons.add( gameAreaX+gameAreaWidth-50, gameAreaY + gameAreaHeight, 50, 20, "Down", drawButton, highlightButton, textBox.scrollDown, gameTextBox )
	buttons.add( chatAreaX+chatAreaWidth-100, chatAreaY - 20, 50, 20, "Up", drawButton, highlightButton, textBox.scrollUp, chatBox )
	buttons.add( chatAreaX+chatAreaWidth-50, chatAreaY - 20, 50, 20, "Down", drawButton, highlightButton, textBox.scrollDown, chatBox )
	buttons.add( love.graphics.getWidth()-100, love.graphics.getHeight()-40, 90, 25, "Export", drawButton, highlightButton, export.toHtmlFile, gameTextBox )
end

function game.receiveServerMessage( msg )
	if gameTextBox then
		textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) + 1, colServerMsg.r, colServerMsg.g, colServerMsg.b )
		textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) .."[" .. msg .. "]\n")
	end
end

function game.active()
	return active
end

return game
