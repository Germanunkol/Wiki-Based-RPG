local game = {}

local active = false

--local REPLYTIME = 180

local NUMBER_OF_JOKERS = 3
INVENTORY_CAPACITY = 5

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
gameTextBox = nil

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
	playerTurns4[0] = {ID = 0, name = STORYTELLER_STR}
	for i = #playerTurns4, 2, -1 do -- shuffle
		local r = math.random(#playerTurns4) -- select a random number between 1 and i
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
	--playerTurns1[#playerTurns1] = nil
	-- send to other players, but only if the round isn't over yet. If it's over, then the addNewPlayerTurns function will send the data.:
	if playerTurns1[0] then sendNextPlayerTurns() end
end

function displayNextPlayerTurns( str )
	if nextPlayerAreaWidth <= 0 then return end
	playerTurnsStrings = {}
	local s,e = stringFind(str,";", 1)
	local player, name
	i = 1
	while s do
		player = safeSub(str,1,e)
	--	print("player: " .. player)
		name = safeSub(player, 1, stringFind(player, ",", 1) - 1)
	--	print("name: " .. name)
		while fontStatus:getWidth(name) > nextPlayerAreaWidth - 10 do
			name = safeSub(name, 1, strLen(name)-1)
			--print("n: " .. name)
		end
		playerTurnsStrings[i] = {str=name, ID = tonumber(safeSub(player,stringFind(player,",", 1)+1, strLen(player)-1)) }
		if playerTurnsStrings[i] == nil then print("error: " .. i)
		else
		end
		i = i+1
		str = safeSub(str,e+1, strLen(str))
		s,e = stringFind(str,";", 1)
	end
	currentPlayer = ""
	if playerTurnsStrings[1] and playerTurnsStrings[1].str and stringFind(playerTurnsStrings[1].str, ":", 1) then
		currentPlayer = safeSub(playerTurnsStrings[1].str, stringFind(playerTurnsStrings[1].str, ":", 1) +1, strLen(playerTurnsStrings[1].str))
	end
	if client then 
		textBox.setContent( gameStatusBox, WAITING_FOR_STR .. " " .. currentPlayer )
	end
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
		textBox.setContent( gameStatusBox, YOUR_TURN_STR)
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
		-- nextWordChosen = true
		
		-- change colour of last curGameWord:
		textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWord.r, colHighlightWikiWord.g, colHighlightWikiWord.b )
		curGameWord = chosenURLs[index].title
		--local start, ending = stringFind(curGameWord, " (" )
		--if start then
		--print("found: " .. curGameWord:sub(start, ending))
			--curGameWord = safeSub(curGameWord, 1, start-1 ) .. safeSub(curGameWord, ending+1, #curGameWord ) --old
			--curGameWord = safeSub(curGameWord, 1, start-1 )
			curGameWord = string.gsub(curGameWord, " %(.*%)", "")
			if #curGameWord == 0 then
				curGameWord = chosenURLs[index].title
			end
		--end
		
		statusMsg.new( CHOSE_WORD_STR .. " \"" .. curGameWord .."\"")
		
		textBox.setContent( inventoryFieldHeader, CHOOSE_WHAT_TO_DO_WITH_WORD_STR )
		
		textBox.highlightClearAll( gameInputBox )
		textBox.highlightText( gameInputBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
		textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
		
		wikiClient.setNewWord( chosenURLs[index] )
		
		buttons.clear()
		buttons.add( chatAreaX+10, chatAreaY+chatAreaHeight + 30, chatAreaWidth, buttonHeight/2+5, USE_WORD_FOR_STORY_STR, drawButton, highlightButton , game.useWord )
	
		local i = 1
		for k, cl in pairs( connectedClients ) do
			if i < 5 then
				titleStr = GIVE_WORD_TO_PLAYER_STR .. " "
				for char in cl.playerName:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
					titleStr = titleStr .. char
					if buttonFont:getWidth( titleStr ) >= chatAreaWidth-30 then
						 break
					end
				end
				if titleStr ~= cl.playerName then
					titleStr = titleStr .. "..."
				end
				buttons.add( chatAreaX+10, chatAreaY+chatAreaHeight + 35 + i*(buttonHeight-10), chatAreaWidth, buttonHeight/2+5, titleStr, drawButton, highlightButton , game.giveCurWordToClient, k )
			end
			i = i+1
		end
	end
end


function game.serverChooseNextWord()

	chosenURLs = wikiClient.nextWord()
	game.chooseWord()
end

function game.chooseWord()
	textBox.setContent( inventoryFieldHeader, CHOOSE_A_WORD_STR )
	if chosenURLs then
		local i = 0
		local j
		local titleStr = 0
		buttons.clear()
		
		for k, v in pairs( chosenURLs ) do							-- show all possible Words that server can choose as buttons.
			if DEBUG then print(k .. ": " .. v.title .. " @ " .. v.url) end
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
		statusMsg.new( ERROR_AT_LEAST_4_WORDS_FOR_JOKER_STR )
		return
	end

	NUMBER_OF_JOKERS = NUMBER_OF_JOKERS-1
	
	game.setJokerButtons()
	
	connection.serverBroadcast("CHAT:" .. SERVER_USED_JOKER_STR)
	chat.receive( SERVER_USED_JOKER_STR )
	
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
			if DEBUG then print(k .. ": " .. v.title .. " @ " .. v.url) end
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

function game.giveCurWordToClient( k )
	if connectedClients[k] then
		game.addToInventory( connectedClients[k].clientNumber, curGameWord )
		statusMsg.new( WORD_GIVEN_TO_STR .. " " .. connectedClients[k].playerName )
	else
		print("Error: Client not found. Can't give object to client.")
		statusMsg.new( ERROR_CLIENT_NOT_FOUND_STR )
	end
	game.chooseWord()
end

function game.useWord()
	chosenURLs = nil
	game.wordChoosingEnded()
end


function game.wordChoosingEnded()
	nextWordChosen = true
	buttons.clear()
	if server then game.setJokerButtons() end
	game.setButtons()	
	textBox.setContent( inventoryFieldHeader, "" )
	if waitForPlayerActions == false then 
		textBox.setContent( gameStatusBox, CONTINUE_STORY_USE_WORD_STR1 .. " \"" .. curGameWord .. "\" " .. CONTINUE_STORY_USE_WORD_STR2 )
		if chat.getActive() == false then
			textBox.setAccess( gameInputBox, true, true )
			scrollGameBox()
		end
	end
end


--[[
function game.newWordSet( word )

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
	
	statusMsg.new( "New word set." )
	
	
	buttons.add( chatAreaX+10, chatAreaY+chatAreaHeight + 25, chatAreaWidth, buttonHeight/2+5, "Don't give away", drawButton, highlightButton , game.wordChoosingEnded )
	
	local i = 1
	for k, cl in pairs( connectedClients ) do
		if i < 5 then
			titleStr = "Give to "
			for char in cl.playerName:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
				titleStr = titleStr .. char
				if buttonFont:getWidth( titleStr ) >= chatAreaWidth-30 then
					 break
				end
			end
			if titleStr ~= cl.playerName then
				titleStr = titleStr .. "..."
			end
			buttons.add( chatAreaX+10, chatAreaY+chatAreaHeight + 25 + i*(buttonHeight-10), chatAreaWidth, buttonHeight/2+5, titleStr, drawButton, highlightButton , game.giveCurWordToClient, k )
		end
		i = i+1
	end
	
end
]]--

function game.inputEscape()
	scrollGameBox()
end

local inventoryAddCue = {}

function game.addToInventory( playerID, object )
	table.insert( inventoryAddCue, { ID = playerID, item = object } )
end

local firstStoryPartSent = false

function game.sendStory()
	local str = textBox.getContent( gameInputBox )
	if #str > 0 then
		if str:upper():find( curGameWord:upper(), 1, true ) then
			playersHaveRepliedTable = {}
			
			fullNumberOfTurns = fullNumberOfTurns + 1
			
			connection.serverBroadcast("CURWORD:" .. curGameWord .. "\n")		-- send the current wiki word along, so that it can be highlighted on the players' side.
			connection.serverBroadcast( "STORY:" .. str .. "\n")
			
			game.receiveStory( str )
			
			if game.sendNextTurn() then
				allPlayersHaveReacted = false
			else
				allPlayersHaveReacted = true
			end
			
			
			if firstStoryPartSent == false then
				firstStoryPartSent = true
				for k, cl in pairs(connectedClients) do
					if cl.description then
				 		connection.serverBroadcast( "TXT:" .. cl.description .. "\n")
				 		game.receiveStory(cl.description, true)
					end
				end
			end
			
			for k, v in pairs(inventoryAddCue) do
				connection.inventoryAdd( v.ID, v.item )
				inventoryAddCue[k] = nil
			end
			
			
			textBox.setContent( gameInputBox, "" )
			textBox.setContent( gameStatusBox, WAITING_FOR_HEROES_STR )
			textBox.setColour( gameStatusBox, 0, 0, 0 )
			waitForPlayerActions = true
			nextWordChosen = false
			statusMsg.new( LOADING_STR )
			table.insert( nextFrameEvent, {func = game.serverChooseNextWord, frames = 2 } )
			table.insert( nextFrameEvent, {func = statusMsg.new, frames = 3, arg = HOW_SHOULD_STORY_CONTINUE_STR } )
			textBox.highlightText( gameTextBox, curGameWord, colHighlightWikiWordNew.r, colHighlightWikiWordNew.g, colHighlightWikiWordNew.b)
		else
			textBox.setAccess( gameInputBox, true )
			scrollGameBox()
			statusMsg.new( MUST_USE_WORD_STR1 .. " '" .. curGameWord .. "' " .. MUST_USE_WORD_STR2)
		end
	else
		textBox.setAccess( gameInputBox, true )
		scrollGameBox()
		statusMsg.new( ERROR_NO_EMPTY_TEXT_STR )
	end
	scrollGameBox()
end

function srt( a, b )
	if a.s and b.s then
		return (a.s < b.s)
	elseif a.s then
		return true
	end
	return false
end

function minimum( posStart1, posStart2, posStart3, posEnd1, posEnd2, posEnd3 )
	local tbl = {}
	table.insert( tbl, {s=posStart1, e=posEnd1} )
	table.insert( tbl, {s=posStart2, e=posEnd2} )
	table.insert( tbl, {s=posStart3, e=posEnd3} )
	
	table.sort( tbl, srt )
	
	return tbl[1].s, tbl[1].e
end


local actionStrings = {}

function insertAction( newStr )
	if newStr:find("/do") == 1 then
		actionStrings[#actionStrings+1] = { typ="do", str=safeSub(newStr, 4, #newStr) }
	elseif newStr:find("/say") == 1 then
		if safeSub(newStr, 5,5) == " " then
			actionStrings[#actionStrings+1] = { typ="say", str=safeSub(newStr, 6, #newStr) }	--remove first character if it's a space
		else
			actionStrings[#actionStrings+1] = { typ="say", str=safeSub(newStr, 5, #newStr) }
		end
	elseif newStr:find("/use") == 1 then
		local inventoryID = tonumber(safeSub(newStr, 6, 6))
		local found = false
		if inventoryID and inventoryID > 0 and inventoryID <= INVENTORY_CAPACITY then
			for k, cl in pairs(connectedClients) do
				if cl.playerName == plName then
					if cl.inventory[inventoryID] ~= nil then
						actionStrings[#actionStrings+1] = { typ="use", str=cl.inventory[inventoryID] .. " on " .. safeSub(newStr, 8, #newStr) }
						client:send("INVREMOVE:" .. cl.clientNumber .. cl.inventory[inventoryID] .. "\n")
						found = true
					end
				end
				break
			end
		end
		if found == false then
			statusMsg.new( ERROR_DOES_NOT_EXIST_STR )
			actionStrings[#actionStrings+1] = { typ="skip", str = "" }		--needed! otherwise server won't know that client has attempted to reply, if only a wrong /use action was sent.
		end
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
			local posStart3, posEnd3 = str:find( "/use" )
			local posStart, posEnd, posStartNew, posEndNew
			posStart, posEnd = minimum( posStart1, posStart2, posStart3, posEnd1, posEnd2, posEnd3 )
			if posStart == nil then
				insertAction( "/say " .. str )		-- if no command was used, assume /say.
			elseif posStart ~= 1 then
				insertAction( "/say " .. safeSub(str,1, posStart-1) )		-- if it doesn't start with a command, /say the beginning.
			end
			while posStart do
				posStart1, posEnd1 = str:find( "/say", posStart+1 )
				posStart2, posEnd2 = str:find( "/do", posStart+1 )
				posStart3, posEnd3 = str:find( "/use", posStart+1 )
				posStartNew, posEndNew = minimum( posStart1, posStart2, posStart3, posEnd1, posEnd2, posEnd3 )
				if posStartNew then
					insertAction( safeSub(str, posStart, posStartNew-1) )
				else
					insertAction( safeSub(str, posStart, #str) )
				end
				posStart, posEnd = posStartNew, posEndNew
			end
		end
		for key, string in ipairs(actionStrings) do
			client:send( "ACTION:" .. string.typ .. string.str .. "\n")
		end

		textBox.setContent( gameInputBox, "" )
		textBox.setContent( gameStatusBox, WAITING_FOR_HEROES_STR )
		textBox.setColour( gameStatusBox, 0, 0, 0 )
		waitForPlayerActions = false
	else
		textBox.setAccess( gameInputBox, true )
		scrollGameBox()
		statusMsg.new( ERROR_NO_EMPTY_TEXT_STR )	
	end
	scrollGameBox()
end

function game.receiveAction( msg, typ, clientID )
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

		if typ ~= "skip" then
			-- if all that was sent was a "skip" command, don't write anything to the game window.
			textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) ..  msg .. "\n" )
		end
		
	end
	table.insert( nextFrameEvent, {func = scrollGameBox, frames = 2 } )
end

function game.receiveStory( msg, noPrefix )
	if gameTextBox then
		--textBox.setColourStart( gameTextBox, #textBox.getContent( gameTextBox ) + 1, colStory.r, colStory.g, colStory.b )
		textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) + 1, colStory.r, colStory.g, colStory.b )
		if noPrefix then
			textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) .. msg .. "\n")
		else
			textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) .. STORYTELLER_STR .. ": " .. msg .. "\n")
		end		
	end
	if client then
		buttons.clear()
		game.setButtons()
	end
	table.insert( nextFrameEvent, {func = scrollGameBox, frames = 2 } )
end

function game.show()		-- called once every frame
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
		love.graphics.rectangle( "fill",nextPlayerAreaX+4, nextPlayerAreaY+4, nextPlayerAreaWidth-8, fontStatus:getHeight() )
		love.graphics.print( playerTurnsStrings[1].ID, nextPlayerAreaX+5, nextPlayerAreaY+5 + (1-1)*fontStatus:getHeight() )
	end
	love.graphics.setColor( 0,0,0,255 )
	for i=1,#playerTurnsStrings,1 do
		love.graphics.print( playerTurnsStrings[i].str, nextPlayerAreaX+5, nextPlayerAreaY+5 + (i-1)*fontStatus:getHeight() )
		if (i+1)*fontStatus:getHeight() > nextPlayerAreaHeight then
			break
		end
	end
	
	if textBox.getAccess( gameInputBox ) then
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b )
		love.graphics.rectangle( "fill",gameInputAreaX, gameInputAreaY, gameInputAreaWdith, gameInputAreaHeight)
		textBox.display( gameInputBox )
	end

	textBox.display( gameTextBox )
	textBox.display( gameStatusBox )
	
	chat.show()
	textBox.display( inventoryFieldHeader )
	
	if currentPlayer and currentPlayer ~= server then		-- display avatar of the player who's currently playing
		for k, cl in pairs(connectedClients) do
			if cl.playerName == currentPlayer then
				if cl.avatar then
					for i=0,AVATAR_PIXELS_X-1,1 do
						for j=0,AVATAR_PIXELS_Y-1,1 do
							if cl.avatar[i*AVATAR_PIXELS_Y+j] == 1 then
								love.graphics.setColor( colCharM.r,colCharM.g,colCharM.b )
								love.graphics.rectangle("fill", nextPlayerAreaX + i*8, nextPlayerAreaY-117 + j*8, 8, 8)
							elseif cl.avatar[i*AVATAR_PIXELS_Y+j] == 2 then
								love.graphics.setColor( colCharD.r,colCharD.g,colCharD.b )
								love.graphics.rectangle("fill", nextPlayerAreaX + i*8, nextPlayerAreaY-117 + j*8, 8, 8)
							end
						end			
					end
				end
				break
			end
		end
	end
	
	if client then
		for k, cl in pairs(connectedClients) do
			if cl.playerName == plName then
				love.graphics.setFont( fontStatus )
				for a, item in pairs(cl.inventory) do
					love.graphics.print(a .. ": " .. item, chatAreaX+5, chatAreaY+chatAreaHeight+12 + fontStatus:getHeight()*a )
				end
				break
			end
		end
	end
	
	if server and waitForPlayerActions then
		if textBox.getContent( gameStatusBox ) ~= WAITING_FOR_STR .. " " .. currentPlayer then textBox.setContent( gameStatusBox, WAITING_FOR_STR .. " " .. currentPlayer ) end
		if allPlayersHaveReacted then
			if chat.getActive() == false and nextWordChosen == true then
				textBox.setAccess( gameInputBox, true )
			end
			scrollGameBox()
			if nextWordChosen == true then
				textBox.setContent( gameStatusBox, CONTINUE_STORY_USE_WORD_STR1 .. " \"" .. curGameWord .. "\" " .. CONTINUE_STORY_USE_WORD_STR2 )
			else
				textBox.setContent( gameStatusBox, CHOOSE_A_WORD_STR )
			end
			textBox.setColour( gameStatusBox, 0, 0, 0 )
			waitForPlayerActions = false
			sound.playNotification()
			addPlayerTurns()
		end
	elseif client and waitForPlayerActions then
		if textBox.getContent( gameStatusBox ) ~=  YOUR_TURN_STR then textBox.setContent( gameStatusBox, YOUR_TURN_STR ) end
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
			statusMsg.new( WAITING_FOR_HEROES_STR )
		elseif nextWordChosen == false then
			statusMsg.new( ERROR_CHOOSE_NEXT_WORD_BEFORE_CONTINUING_STR )
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
			statusMsg.new( ERROR_NOT_YOUR_TURN_STR )
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
	statusMsg.new( GAME_STARTING_STR )
	
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
	nextPlayerAreaY = gameAreaY + 100
	
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
		addPlayerTurns()		-- must be called 4 times, because 4 rounds should be displayed.
		addPlayerTurns()
		addPlayerTurns()
		addPlayerTurns()
		game.setJokerButtons()
		curGameWord = startingWord		-- the current game's word will be the word the server chose as start word
		
		textBox.setContent( gameStatusBox, START_STORY_USE_WORD_STR1 .. " \"" .. curGameWord .. "\" " .. START_STORY_USE_WORD_STR2 )
		textBox.setColourStart( gameStatusBox, #START_STORY_USE_WORD_STR1+4 , colWikiWord.r, colWikiWord.g, colWikiWord.b )
		textBox.setColourStart( gameStatusBox, #START_STORY_USE_WORD_STR1 + #startingWord + 4 , 0,0,0 )
		textBox.setAccess( gameInputBox, true, true )
		scrollGameBox()
		textBox.setReturnEvent( gameInputBox, game.sendStory )
		textBox.highlightText( gameInputBox, curGameWord, colHighlightWikiWord.r, colHighlightWikiWord.g, colHighlightWikiWord.b )
	else
		textBox.setContent( inventoryFieldHeader, INVENTORY_STR )
		textBox.setContent( gameStatusBox, WAITING_FOR_SERVER_BEGINNING_STR )
	end

	helpString = HELP_GAME

end

function game.setButtons()
	buttons.add( gameAreaX, gameAreaY, gameAreaWidth, gameAreaHeight, "", nil, nil, gameAreaClicked )
	buttons.add( chatAreaX, chatAreaY, chatAreaWidth, chatAreaHeight, "", nil, nil, chatAreaClicked )
	buttons.add( gameAreaX+gameAreaWidth-100, gameAreaY + gameAreaHeight, 50, 20, "Up", drawButton, highlightButton, textBox.scrollUp, gameTextBox )
	buttons.add( gameAreaX+gameAreaWidth-50, gameAreaY + gameAreaHeight, 50, 20, "Down", drawButton, highlightButton, textBox.scrollDown, gameTextBox )
	buttons.add( chatAreaX+chatAreaWidth-100, chatAreaY - 20, 50, 20, "Up", drawButton, highlightButton, textBox.scrollUp, chatBox )
	buttons.add( chatAreaX+chatAreaWidth-50, chatAreaY - 20, 50, 20, "Down", drawButton, highlightButton, textBox.scrollDown, chatBox )
	buttons.add( love.graphics.getWidth()-100, love.graphics.getHeight()-40, 90, 25, EXPORT_STR, drawButton, highlightButton, export.toHtmlFile, gameTextBox )
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
