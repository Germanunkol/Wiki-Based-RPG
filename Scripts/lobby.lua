local lobby = {}

local active
local choosingFirstWord = false

local avatarPicX = 70
local avatarPicY = 410

function attemptGameStart()

	for k, cl in pairs( connectedClients ) do
		if cl.ready ~= true then
			rand = math.random(7)
			if rand == 1 then statusMsg.new( "Some heroes have not packed their lunchbags yet." )
			elseif rand == 2 then statusMsg.new( "Still waiting for the heroes to dress..." )
			elseif rand == 3 then statusMsg.new( "SOMEONE is still not ready!" )
			elseif rand == 4 then statusMsg.new( "Waiting for the heroes to draw their little avatar-thingies..." )
			elseif rand == 5 then statusMsg.new( "*Sigh*... nope. Someone's not ready yet." )
			else statusMsg.new( "Someone's still getting ready..." )
			end
			
			return
		end
	end

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
		game.init()
	end
end

local found, multiple, urlTable

function lobby.inputFirstWord()
	wikiClient.inputWikiWord( love.graphics.getWidth()/2, 400, love.graphics.getWidth()/2-20, love.graphics.getHeight()/2-110, lobby.firstWordSet, "What will the story be about?" )
end

function lobby.inputDescriptionWord()
	wikiClient.inputWikiWord( love.graphics.getWidth()/2, 400, love.graphics.getWidth()/2-20, love.graphics.getHeight()/2-110, lobby.descriptionWordSet, "Enter a word to describe your character:" )
	setAvatarButtons()
end

local chosenURLs = nil
local descriptionHeaderBox = nil
local descriptionInputBox = nil
descriptionWord = nil




function sendReady()
	if clientReady then
		clientReady = false
		client:send("READY:false\n")
	else
		clientReady = true
		client:send("READY:true\n")
	end
	
	buttons.clear()
	setAvatarButtons()
	if clientReady then 
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Ready [x]", drawButton, highlightButton , sendReady )
		connection.sendAvatar()
	else 
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Ready [ ]", drawButton, highlightButton , sendReady )
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Change description", drawButton, highlightButton , lobby.inputDescriptionWord )
	end
end

function lobby.descriptionAdded()
	if descriptionInputBox then
		if textBox.getContent( descriptionInputBox ):lower():find( descriptionWord:lower(), 1, true ) then
			client:send( "CHARDESCRIPTION:" .. textBox.getContent( descriptionInputBox ) .. "\n")
			descriptionHeaderBox = nil
			descriptionInputBox = nil
			buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Change description", drawButton, highlightButton , lobby.inputDescriptionWord )
			buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Ready [ ]", drawButton, highlightButton , sendReady )
		else
			if descriptionWord then statusMsg.new( "You must use " .. descriptionWord .. " in your description!" ) end
			textBox.setAccess( descriptionInputBox, true, true )
			textBox.moveCursorToEnd( descriptionInputBox )
		end
	end
end

function lobby.chooseDescriptionWord( index )
	print("clicked")
	buttons.clear()
	setAvatarButtons()
	if chosenURLs then
	print("chosenURLS")
		descriptionWord = chosenURLs[index].title
		print(descriptionWord)
		if #descriptionWord > 0 then
	print("descriptionWord")
			if descriptionHeaderBox == nil then
				descriptionHeaderBox = textBox.new( avatarPicX+AVATAR_PIXELS_X*AVATAR_PIXELS_WIDTH+10, 400 + 3, 2, fontInputHeader, love.graphics.getWidth() )
			end
			textBox.setContent( descriptionHeaderBox, "Tell us something about your character. Use " .. descriptionWord .. "." )
			if descriptionInputBox == nil then
				descriptionInputBox = textBox.new( avatarPicX+AVATAR_PIXELS_X*AVATAR_PIXELS_WIDTH+15, 400 + 23, 6, fontInput, love.graphics.getWidth()/2-20 )
				textBox.setColour( descriptionInputBox, colTextInput.r, colTextInput.g, colTextInput.b )
			end
			local rand = math.random(4)
			if rand == 1 then textBox.setContent( descriptionInputBox, plName .. " likes " )
			elseif rand == 2 then textBox.setContent( descriptionInputBox, plName .. " has " )
			else
				textBox.setContent( descriptionInputBox, plName .. " is " )
			end
			textBox.setAccess( descriptionInputBox, true, true )
			table.insert( nextFrameEvent, {func = textBox.moveCursorToEnd, arg = descriptionInputBox, frames = 2 } )
			textBox.setReturnEvent( descriptionInputBox, lobby.descriptionAdded )
		else
			buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Describe character", drawButton, highlightButton , lobby.inputDescriptionWord )
		end
	end
end

function lobby.descriptionWordSet()		--ask player to write something about himself.
	chosenURLs = wikiClient.nextWord()
	print ("test")
	if chosenURLs then
	
		local displayAreaX = love.graphics.getWidth()/2
		local displayAreaY = 400
		local displayAreaWidth = love.graphics.getWidth()/2
		
		setAvatarButtons()
		local i = 0
		local j
		local titleStr = 0
		
		for k, v in pairs( chosenURLs ) do							-- show all possible Words that server can choose as buttons.
			print(k .. ": " .. v.title .. " @ " .. v.url)
			if i < 5 then
				titleStr = ""
				for char in v.title:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- make sure button title isn't larger than button
					titleStr = titleStr .. char
					if buttonFont:getWidth( titleStr ) >= displayAreaWidth-30 then
						 break
					end
				end
				if titleStr ~= v.title then
					titleStr = titleStr .. "..."
				end
				buttons.add( displayAreaX, displayAreaY+35+i*(buttonHeight-5), displayAreaWidth, buttonHeight/2+10, titleStr, drawButton, highlightButton, lobby.chooseDescriptionWord, k )
			end
			i = i+1
		end
	else
		print("ERROR: Uhm... no urls found...?")
	end
end

function lobby.firstWordSet( word )
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

	buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Change first Word", drawButton, highlightButton , lobby.inputFirstWord )
	buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Start Game", drawButton, highlightButton , attemptGameStart )
	
	statusMsg.new( "Start word set." )
end

function setAvatarButtons()
	for i=0,AVATAR_PIXELS_X-1,1 do
		for j=0,AVATAR_PIXELS_Y-1,1 do
			--print(i, j, characterPicX + i*CHAR_PIXELS_WIDTH,  characterPicY + j*CHAR_PIXELS_HEIGHT)
			buttons.add( avatarPicX + i*AVATAR_PIXELS_WIDTH, avatarPicY + j*AVATAR_PIXELS_HEIGHT, AVATAR_PIXELS_WIDTH, AVATAR_PIXELS_HEIGHT, i*AVATAR_PIXELS_X+j, drawPixel, highlightPixel , switchPixel, i*AVATAR_PIXELS_X+j )
		end
	end
end

function lobby.init()
	active = true
	
	
	if server then
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Choose first Word", drawButton, highlightButton , lobby.inputFirstWord )
	else
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, "Describe character", drawButton, highlightButton , lobby.inputDescriptionWord )
		
		setAvatarButtons()
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, "Ready [ ]", drawButton, highlightButton , sendReady )
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

local curY = 0

function lobby.showPlayers()

	-- print headers:
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.g, 255)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 48)
	
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b )
	love.graphics.setFont( fontHeader )
	love.graphics.print( "Heroes:", 70, 65 )
	
	
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.g, 255)
	love.graphics.rectangle("fill", 0, 360, love.graphics.getWidth(), 38)
	
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b )
	love.graphics.setFont( fontInputHeader )
	love.graphics.print( "Options:", 70, 370 )
	
	
	if descriptionHeaderBox then
		textBox.display( descriptionHeaderBox )
	end
	if descriptionInputBox then
		textBox.display( descriptionInputBox )
	end
	
	if startingWord then
		love.graphics.setFont( buttonFont )
		love.graphics.setColor( 0,0,0 )
		love.graphics.print( "A story of ", (love.graphics.getWidth() - fontHeader:getWidth(startingWord))/2-buttonFont:getWidth("A story of ") , 24 )
		love.graphics.setFont( fontHeader )
		love.graphics.setColor( colWikiWord.r,colWikiWord.g,colWikiWord.b )
		love.graphics.print( startingWord, (love.graphics.getWidth() - fontHeader:getWidth(startingWord))/2, 20 )
	end
	
	
	for k, cl in pairs( connectedClients ) do
		curY = 120 + 50*(cl.clientNumber-1)
		
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", 0, curY-9 , love.graphics.getWidth(), 33)
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.setFont( mainFont )
		love.graphics.print(cl.playerName, 200, curY )
		if cl.ready then
			love.graphics.print("[x]", 170, curY )
		else
			love.graphics.print("[ ]", 170, curY )
		end
		if cl.description then
			love.graphics.setColor( 60, 60, 60 , 255)
			love.graphics.print( "-  " .. cl.description, 220+mainFont:getWidth(cl.playerName), curY )
		end
		if cl.avatar then
			--love.graphics.setColor( colCharB.r,colCharB.g,colCharB.b )
			--love.graphics.rectangle("fill", 30, curY -7, 3*AVATAR_PIXELS_X, 3*AVATAR_PIXELS_Y)
			for i=0,AVATAR_PIXELS_X-1,1 do
				for j=0,AVATAR_PIXELS_Y-1,1 do
					if cl.avatar[i*AVATAR_PIXELS_Y+j] == 1 then
						love.graphics.setColor( colCharM.r,colCharM.g,colCharM.b )
						love.graphics.rectangle("fill", 20+i*3, curY -7 + j*3, 3, 3)
					elseif cl.avatar[i*AVATAR_PIXELS_Y+j] == 2 then
						love.graphics.setColor( colCharD.r,colCharD.g,colCharD.b )
						love.graphics.rectangle("fill", 20+i*3, curY -7 + j*3, 3, 3)
					end
				end			
			end
		end
	end
end


return lobby
