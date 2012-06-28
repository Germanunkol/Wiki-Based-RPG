local game = {}

local active = false

local REPLYTIME = 90

local gameAreaX = 0
local gameAreaY = 0
local gameAreaWidth = 0
local gameAreaHeight = 0

local chatAreaX = 0
local chatAreaY = 0
local chatAreaWidth = 0
local chatAreaHeight = 0

local gameInputAreaX = 0
local gameInputAreaY = 0
local gameInputAreaWdith = 0
local gameInputAreaHeight = 0

local gameInputBox = nil
local gameStatusBox = nil
local gameTextBox = nil

local waitForPlayerActions = false
local waitForPlayerActionsTimer = 0
local playersHaveReplied = 0

local curGameWord = ""

local inventoryFieldHeader

local function scrollGameBox()
	local linesFittingOnScreen
	if textBox.getAccess( gameInputBox ) then
		linesFittingOnScreen = math.floor( (gameAreaHeight - gameInputAreaHeight)/textBox.getFont( gameTextBox ):getHeight() )
	else
		linesFittingOnScreen = math.floor( gameAreaHeight/textBox.getFont( gameTextBox ):getHeight() )
	end
	textBox.setVisibleLines( gameTextBox, textBox.numLines( gameTextBox )-linesFittingOnScreen, linesFittingOnScreen )
end

local chosenURLs

function chooseNextWord( index )
	if chosenURLs then
		nextWordChosen = true
		curGameWord = chosenURLs[index].title
		statusMsg.new( "Chose: \"" .. curGameWord .."\"")
		wikiClient.setNewURL( chosenURLs[index].url )
		buttons.clear()
		buttons.add( gameAreaX, gameAreaY, gameAreaWidth, gameAreaHeight, "", nil, nil, gameAreaClicked )
		buttons.add( chatAreaX, chatAreaY, chatAreaWidth, chatAreaHeight, "", nil, nil, chatAreaClicked )
		textBox.setContent( inventoryFieldHeader, "" )
		if waitForPlayerActions == false then 
			textBox.setContent( gameStatusBox, "Continue the story. Use \"" .. curGameWord .. "\" in your text.")
			if chat.getActive() == false then
				textBox.setAccess( gameInputBox, true, true )
			end
		end
		chosenURLs = nil
	end
end

function game.serverChooseNextWord()

	chosenURLs = wikiClient.nextWord()
	statusMsg.new("How should the story continue?")
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
				buttons.add( chatAreaX, chatAreaY+chatAreaHeight+30+i*(buttonHeight-2), chatAreaWidth, buttonHeight/2+10, titleStr, drawButton, highlightButton, chooseNextWord, k )
			end
			i = i+1
		end
		
	else
		print("ERROR: Uhm... no urls found...?")
	end
end

function game.inputEscape()
	scrollGameBox()
end

function game.sendStory()
	local str = textBox.getContent( gameInputBox )
	if #str > 0 then
		playersHaveReplied = 0
		connection.serverBroadcast( "STORY:" .. str .. "\n")
		game.receiveStory( str )
		textBox.setContent( gameInputBox, "" )
		textBox.setContent( gameStatusBox, "Waiting for heroes to reply..." )
		textBox.setColour( gameStatusBox, 0, 0, 0 )
		waitForPlayerActions = true
		waitForPlayerActionsTimer = 0
		nextWordChosen = false
		table.insert( nextFrameEvent, {func = game.serverChooseNextWord, frames = 2 } )
	else
		textBox.setAccess( gameInputBox, true )
		statusMsg.new("Write something first!")
	end
	scrollGameBox()
end

function game.sendAction( )
	local str = textBox.getContent( gameInputBox )
	if #str > 0 then
		client:send( "ACTION:" .. str .. "\n")
		--game.receiveAction( plName .. ": " .. str )
		textBox.setContent( gameInputBox, "" )
		textBox.setContent( gameStatusBox, "Waiting for story..." )
		textBox.setColour( gameStatusBox, 0, 0, 0 )
		waitForPlayerActions = false
	else
		textBox.setAccess( gameInputBox, true )
		statusMsg.new("Write something first!")	
	end
	scrollGameBox()
end

function game.receiveAction( msg )
	if gameTextBox then
		if server then
			playersHaveReplied = playersHaveReplied + 1
		end
		--textBox.setColourStart( gameTextBox, #textBox.getContent( gameTextBox ) + 1, colAction.r, colAction.g, colAction.b )

		textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) +1, colAction.r, colAction.g, colAction.b )
		textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) ..  msg .. "\n")
	end
	scrollGameBox()
end

function game.receiveStory( msg )
	if gameTextBox then
		--textBox.setColourStart( gameTextBox, #textBox.getContent( gameTextBox ) + 1, colStory.r, colStory.g, colStory.b )
		textBox.setLineColour( gameTextBox,  textBox.numLines( gameTextBox ) + 1, colStory.r, colStory.g, colStory.b )
		textBox.setContent( gameTextBox, textBox.getContent( gameTextBox ) .."Story: " .. msg .. "\n")
		if client then
			waitForPlayerActions = true
			waitForPlayerActionsTimer = 0
			if chat.getActive() == false then
				textBox.setAccess( gameInputBox, true )
			end
			textBox.setContent( gameStatusBox, "What would you like to do?" )
			textBox.setReturnEvent( gameInputBox, game.sendAction )
		end
	end
	scrollGameBox()
end

function game.show()
	love.graphics.setColor( colBg.r, colBg.g, colBg.b )
	love.graphics.rectangle( "fill",gameAreaX, gameAreaY, gameAreaWidth, gameAreaHeight)
	love.graphics.rectangle( "fill",chatAreaX, chatAreaY, chatAreaWidth, chatAreaHeight)
	love.graphics.setColor( colMainBg.r, colMainBg.g, colMainBg.b )
	love.graphics.rectangle( "fill",gameAreaX+2, gameAreaY+2, gameAreaWidth-4, gameAreaHeight-4)
	love.graphics.rectangle( "fill",chatAreaX+2, chatAreaY+2, chatAreaWidth-4, chatAreaHeight-4)
	
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
		waitForPlayerActionsTimer = waitForPlayerActionsTimer + love.timer.getDelta()
		textBox.setContent( gameStatusBox, "Waiting for heroes to reply... (" .. math.floor(REPLYTIME-waitForPlayerActionsTimer) .. ")" )
		if waitForPlayerActionsTimer >= REPLYTIME or playersHaveReplied >= connection.getPlayers() then
			if chat.getActive() == false and nextWordChosen == true then
				textBox.setAccess( gameInputBox, true )
			end
			scrollGameBox()
			if nextWordChosen == true then
				textBox.setContent( gameStatusBox, "Continue the story. Use \"" .. curGameWord .. "\" in your text.")
			else
				textBox.setContent( gameStatusBox, "Choose a word...")
			end
			textBox.setColour( gameStatusBox, 0, 0, 0 )
			waitForPlayerActions = false
		end
	elseif client and waitForPlayerActions then
		waitForPlayerActionsTimer = waitForPlayerActionsTimer + love.timer.getDelta()
		textBox.setContent( gameStatusBox, "What would you like to do? (" .. math.floor(REPLYTIME-waitForPlayerActionsTimer) .. ")" )
		if waitForPlayerActionsTimer >= REPLYTIME then
			textBox.setAccess( gameInputBox, false )
			scrollGameBox()
			textBox.setContent( gameStatusBox, "You did nothing. Waiting for story..." )
			waitForPlayerActions = false
		end
	end
end

function gameAreaClicked()
	if server then
		if waitForPlayerActions then
			statusMsg.new( "Give the heroes some time to reply!" )
		elseif nextWordChosen == false then
			statusMsg.new( "Choose next word first!" )
		else
			chat.setAccess( false )
			textBox.setAccess( gameInputBox, true )
		end
	elseif client then
		if waitForPlayerActions then
			chat.setAccess( false )
			textBox.setAccess( gameInputBox, true )
		else
			statusMsg.new( "Story has not yet been written!" )
		end
	end
end

function chatAreaClicked()
	chat.setAccess( true )
	textBox.setAccess( gameInputBox, false )
end

function game.init()
	statusMsg.new("Game starting.")
	active = true
	print("Game started")
	gameAreaX = 10
	gameAreaY = 40
	gameAreaWidth = love.graphics.getWidth() * 0.6 - gameAreaX
	gameAreaHeight = love.graphics.getHeight() - 50 - gameAreaY
	chatAreaX = gameAreaX + gameAreaWidth + 10
	chatAreaY =  40 --love.graphics.getHeight() / 2
	chatAreaWidth = love.graphics.getWidth() - chatAreaX - 10
	chatAreaHeight = love.graphics.getHeight() / 2 - 10
	
	gameInputAreaX = gameAreaX + 10
	gameInputAreaY = gameAreaHeight * 0.7 + gameAreaY
	gameInputAreaWdith = gameAreaWidth - 20
	gameInputAreaHeight = gameAreaHeight * 0.3 - 10
	gameInputBox = textBox.new( gameInputAreaX + 5, gameInputAreaY + 2, math.floor(gameInputAreaHeight/fontInput:getHeight()) , fontInput, gameInputAreaWdith - 15)
	gameTextBox = textBox.new( gameAreaX + 5, gameAreaY + 5, math.floor(gameAreaHeight/fontInput:getHeight()) , fontInput, gameAreaWidth - 15)
	textBox.setEscapeEvent( gameInputBox, game.inputEscape )		--called when "escape" is pressed during input
	
	inventoryFieldHeader = textBox.new( chatAreaX+2, chatAreaY+chatAreaHeight+10, 1, fontInputHeader, 300 )
	--textBox.setMaxVisibleLines( gameInputBox, math.floor(gameInputAreaHeight/fontInput:getHeight()) )
	
	buttons.add( gameAreaX, gameAreaY, gameAreaWidth, gameAreaHeight, "", nil, nil, gameAreaClicked )
	buttons.add( chatAreaX, chatAreaY, chatAreaWidth, chatAreaHeight, "", nil, nil, chatAreaClicked )
	
	gameStatusBox = textBox.new( gameAreaX + 5, 12, 2 , fontInputHeader, love.graphics.getWidth() - gameAreaX*2)
	
	chat.init( chatAreaX+10, chatAreaY+10, math.floor(chatAreaHeight/fontChat:getHeight()), fontChat, chatAreaWidth-20 )
	
	if server then
		curGameWord = startingWord		-- the current game's word will be the word the server chose as start word
		textBox.setContent( gameStatusBox, "Start the story. Use \"" .. startingWord .. "\" in your text." )
		textBox.setColourStart( gameStatusBox, #"Start the story. Use \""+1 , colWikiWord.r, colWikiWord.g, colWikiWord.b )
		textBox.setColourStart( gameStatusBox, #"Start the story. Use \"" + #startingWord + 1 , 0,0,0 )
		textBox.setAccess( gameInputBox, true, true )
		scrollGameBox()
		textBox.setReturnEvent( gameInputBox, game.sendStory )
	else
		textBox.setContent( inventoryFieldHeader, "Inventory" )
		textBox.setContent( gameStatusBox, "Waiting for server to beginn story..." )
	end
end

function game.active()
	return active
end

return game
