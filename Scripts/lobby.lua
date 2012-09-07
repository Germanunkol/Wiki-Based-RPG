local lobby = {}

local active
local choosingFirstWord = false

local avatarPicX = 70
local avatarPicY = 410

local addedDescription = false

function attemptGameStart()

	for k, cl in pairs( connectedClients ) do
		if cl.ready ~= true then
			local rand = math.random( #PLAYERS_NOT_READY_LINES )
			
			if PLAYERS_NOT_READY_LINES[rand] then
				statusMsg.new( PLAYERS_NOT_READY_LINES[rand] )
			else
				statusMsg.new( "Still waiting for Heroes..." )
			end
			
			return
		end
	end

	local numClients = 0
	for k, cl in pairs( connectedClients ) do
		numClients = numClients + 1
		
		cl.client:send( "GAMESTART:\n" )
	end
	if numClients == 0 and not DEBUG then
		statusMsg.new( ERROR_MINIMUM_ONE_PLAYER_STR )
	else
		buttons.clear()		-- remove game start button
		active = false
		game.init()
	end
end

local found, multiple, urlTable

function lobby.inputFirstWord()
	wikiClient.inputWikiWord( love.graphics.getWidth()/2, 400, love.graphics.getWidth()/2-20, love.graphics.getHeight()/2-110, lobby.firstWordSet, ENTER_FIRST_WORD_STR )
end

function lobby.inputDescriptionWord()
	wikiClient.inputWikiWord( love.graphics.getWidth()/2, 400, love.graphics.getWidth()/2-20, love.graphics.getHeight()/2-110, lobby.descriptionWordSet, ENTER_DESCRIPTION_WORD_STR )
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
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, READY_BUTTON_STR .. " [x]", drawButton, highlightButton , sendReady )
		connection.sendAvatar()
		connection.sendStatistics()		
	else 
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, READY_BUTTON_STR .. " [ ]", drawButton, highlightButton , sendReady )
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, CHANGE_DESCRIPTION_BUTTON_STR, drawButton, highlightButton , lobby.inputDescriptionWord )
		setAbilityStatButtons()
	end
end

function lobby.descriptionAdded()
	if descriptionInputBox then
		if textBox.getContent( descriptionInputBox ):lower():find( descriptionWord:lower(), 1, true ) then
			client:send( "CHARDESCRIPTION:" .. textBox.getContent( descriptionInputBox ) .. "\n")
			descriptionHeaderBox = nil
			descriptionInputBox = nil
			addedDescription = true
			setClientButtons()
		else
			if descriptionWord then statusMsg.new( MUST_USE_WORD_STR1 " " .. descriptionWord .. " " .. MUST_USE_WORD_STR2 ) end
			textBox.setAccess( descriptionInputBox, true, true )
			textBox.moveCursorToEnd( descriptionInputBox )
		end
	end
end

function lobby.chooseDescriptionWord( index )
	buttons.clear()
	setAvatarButtons()
	if chosenURLs then
		descriptionWord = chosenURLs[index].title
		if #descriptionWord > 0 then
			if descriptionHeaderBox == nil then
				descriptionHeaderBox = textBox.new( avatarPicX+AVATAR_PIXELS_X*AVATAR_PIXELS_WIDTH+10, 400 + 3, 2, fontInputHeader, love.graphics.getWidth() )
			end
			textBox.setContent( descriptionHeaderBox, USE_DESCRIPTION_WORD .. " " .. descriptionWord )
			textBox.setColour( descriptionHeaderBox, colText.r, colText.g, colText.b )
			if descriptionInputBox == nil then
				descriptionInputBox = textBox.new( avatarPicX+AVATAR_PIXELS_X*AVATAR_PIXELS_WIDTH+15, 400 + 23, 6, fontInput, love.graphics.getWidth()/2-20 )
				textBox.setColour( descriptionInputBox, colTextInput.r, colTextInput.g, colTextInput.b )
			end

			local rand = math.random(#LOBBY_VERBS)
			if LOBBY_VERBS[rand] then
				textBox.setContent( descriptionInputBox, plName .. " " .. LOBBY_VERBS[rand] .. " " )
			else
				textBox.setContent( descriptionInputBox, plName )
			end
			textBox.setAccess( descriptionInputBox, true, true )
			table.insert( nextFrameEvent, {func = textBox.moveCursorToEnd, arg = descriptionInputBox, frames = 2 } )
			textBox.setReturnEvent( descriptionInputBox, lobby.descriptionAdded )
		else
			buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, DESCRIBE_CHARACTER_BUTTON_STR, drawButton, highlightButton , lobby.inputDescriptionWord )
		end
	end
end

function lobby.descriptionWordSet()		--ask player to write something about himself.
	chosenURLs = wikiClient.nextWord()
	if chosenURLs then
	
		local displayAreaX = love.graphics.getWidth()/2
		local displayAreaY = 400
		local displayAreaWidth = love.graphics.getWidth()/2
		
		setAvatarButtons()
		local i = 0
		local j
		local titleStr = 0
		
		for k, v in pairs( chosenURLs ) do							-- show all possible Words that server can choose as buttons.
			if DEBUG then print(k .. ": " .. v.title .. " @ " .. v.url) end
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
	--local start, ending = stringFind(startingWord, " (" )
	--if start then
	--print("found: " .. curGameWord:sub(start, ending))
		--startingWord = safeSub(startingWord, 1, start-1 ) .. safeSub(startingWord, ending+1, #curGameWord )	--old
		--startingWord = safeSub(startingWord, 1, start-1 )
		startingWord = string.gsub(startingWord, " %(.*%)", "" )
		if #startingWord == 0 then
			startingWord = word
		end
	--end
	print(startingWord)
	connection.serverBroadcast("CURWORD:" .. startingWord .. "\n")
	setServerButtons()
	statusMsg.new( CHOSEN_FIRST_WORD_STR )
end

function setAvatarButtons()
	for i=0,AVATAR_PIXELS_X-1,1 do
		for j=0,AVATAR_PIXELS_Y-1,1 do
			buttons.add( avatarPicX + i*AVATAR_PIXELS_WIDTH, avatarPicY + j*AVATAR_PIXELS_HEIGHT, AVATAR_PIXELS_WIDTH, AVATAR_PIXELS_HEIGHT, i*AVATAR_PIXELS_X+j, drawPixel, highlightPixel , switchPixel, i*AVATAR_PIXELS_X+j )
		end
	end
end


function setAbilityStatButtons()
	local maxWidth = 0
	for k, v in pairs(abilities) do
		if maxWidth < buttonFont:getWidth(v) then maxWidth = buttonFont:getWidth(v) end
	end
	for i=1,MAX_ABILITIES,1 do
		if abilities[i] ~= nil then
			for j=1,5,1 do
				buttons.add( love.graphics.getWidth()/3 + maxWidth + AVATAR_PIXELS_WIDTH*j,  413 + (i-1)*buttonFont:getHeight() , AVATAR_PIXELS_WIDTH, AVATAR_PIXELS_HEIGHT, i*5+j, statPixel, stathighlightPixel , changeStat, i*5+j )
			end
		end
	end
	if server then connection.sendAbilities() end
end

local abilityHeaderBox = nil
local abilityInputBox = nil


function lobby.addAbility( str )
	for i=1,MAX_ABILITIES,1 do
		if abilities[i] == nil then
			abilities[i] = str
			statistics[i*5+1] = 1
			setStatistics[i] = 1
			break
		end
	end
	if server then connection.sendAbilities()
	else setClientButtons() end
end

function removeAbility( ID )
	abilities[ID] = nil
	connection.sendAbilities()
	
	buttons.clear()
	setServerButtons()
end

function addAbilityRemoveButtons()
	local i = 0
	for k, v in pairs(abilities) do
		buttons.add( love.graphics.getWidth()/3-25, 407 + i*buttonFont:getHeight(), 20, 27, "x", drawButton, highlightButton , removeAbility, k )
		i = i+1
	end
end

local function chooseTheme(str)
	if themes.set(str) then
		connection.serverBroadcast( "THEME:" .. str )
	else
		statusMsg.new(ERROR_COULD_NOT_SET_THEME_STR)
	end
	buttons.clear()
	setServerButtons()
end

local function listThemes()
	buttons.clear()
	local titleStr, i = "", 0
	for k, t in pairs(themes.getList()) do
		titleStr = ""
		for char in t:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
			titleStr = titleStr .. char
			if buttonFont:getWidth( titleStr ) >= love.graphics.getWidth()/2-70 then
				 break
			end
		end
		if titleStr ~= t then
			titleStr = titleStr .. "..."
		end
		buttons.add( love.graphics.getWidth()/2+10, 400 + 25 + i*(buttonHeight-10), love.graphics.getWidth()/2-40, buttonHeight/2+5, titleStr, drawButton, highlightButton , chooseTheme, t )
		i = i + 1
	end
end

function setServerButtons()
	addAbilityRemoveButtons()
	
	if startingWord == nil then
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-15, buttonWidth, buttonHeight, CHOOSE_PATH_BUTTON_STR, drawButton, highlightButton, lobby.inputFirstWord )
		--buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight*2-10, buttonWidth, buttonHeight, "Add Ability", drawButton, highlightButton, lobby.inputAbility )
	else
		--buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight*2-10, buttonWidth, buttonHeight, "Add Ability", drawButton, highlightButton, lobby.inputAbility )
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-15, buttonWidth, buttonHeight, CHANGE_FIRST_WORD_BUTTON_STR, drawButton, highlightButton, lobby.inputFirstWord )
		buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, BEGIN_JOURNEY_BUTTON_STR, drawButton, highlightButton, attemptGameStart )
	end
	buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10-buttonHeight-5, buttonWidth, buttonHeight, MODIFY_THEME_BUTTON_STR, drawButton, highlightButton, listThemes )
end

function setClientButtons()
	buttons.clear()
	setAbilityStatButtons()
	
	
	buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15-buttonHeight-10, buttonWidth, buttonHeight, DESCRIBE_CHARACTER_BUTTON_STR, drawButton, highlightButton , lobby.inputDescriptionWord )
		
	setAvatarButtons()
	if DEBUG or addedDescription then
		if clientReady then 
			buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, READY_BUTTON_STR .. " [x]", drawButton, highlightButton , sendReady )
		else 
			buttons.add( love.graphics.getWidth()-buttonWidth-10, love.graphics.getHeight()-buttonHeight-15, buttonWidth, buttonHeight, READY_BUTTON_STR .. " [ ]", drawButton, highlightButton , sendReady )
		end
	end
end

function lobby.abilityEntered()
	local str = textBox.getContent( abilityInputBox )
	
	abilityHeaderBox = nil
	abilityInputBox = nil
	
	if str:find(",") then
		statusMsg.new( ERROR_NO_COMMAS_ALLOWED_STR )
		setServerButtons()
		return
	end
	
	if #str > 0 then
		lobby.addAbility( str )
	end
	
	setServerButtons()
end

function lobby.inputAbility()
	buttons.clear()
	local x, y, w, h = love.graphics.getWidth()/2, 400, love.graphics.getWidth()/2-20, love.graphics.getHeight()/2-110
	
	if abilityHeaderBox == nil then
		abilityHeaderBox = textBox.new( x+10, y + 3, 2, fontInputHeader, w )
	end
			textBox.setColour( abilityHeaderBox, colText.r, colText.g, colText.b )
	textBox.setContent( abilityHeaderBox, "Enter a new Ability:" )
	if abilityInputBox == nil then
		abilityInputBox = textBox.new( x+15, y + 23, 1, fontInput, 200 )
		textBox.setColour( abilityInputBox, colTextInput.r, colTextInput.g, colTextInput.b )
	end
	
	textBox.setAccess( abilityInputBox, true, true )
	textBox.setReturnEvent( abilityInputBox, lobby.abilityEntered )
end

function lobby.init()
	active = true
	
	if server then
		setServerButtons()
	else
		setClientButtons()
	end

	-- load the help file for the lobby:
	helpString = HELP_LOBBY

end

function lobby.deactivate()
	active = false
end

function lobby.active()
	return active
end

local curY = 0
local i

function lobby.showPlayers()

	themes.drawBackgroundImages()
	-- print headers:
	
	
	love.graphics.setColor( colShadow.r,colShadow.b, colShadow.r, 220)
	love.graphics.rectangle("fill", 0, 51+4, love.graphics.getWidth(), 48)
	
	love.graphics.rectangle("fill", 0, 360+4, love.graphics.getWidth(), 38)
	
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.b, 255)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 48)
	love.graphics.rectangle("fill", 0, 360, love.graphics.getWidth(), 38)
	
	love.graphics.setColor( colText.r, colText.g, colText.b )
	love.graphics.setFont( fontHeader )
	love.graphics.print( HEROES_STR, 70, 65 )
	
	love.graphics.setColor( colText.r, colText.g, colText.b )
	love.graphics.setFont( fontInputHeader )
	love.graphics.print( OPTIONS_STR, 70, 370 )

	
	if descriptionHeaderBox then
		textBox.display( descriptionHeaderBox )
	end
	if descriptionInputBox then
		textBox.display( descriptionInputBox )
	end
	if abilityHeaderBox then
		textBox.display( abilityHeaderBox )
	end
	if abilityInputBox then
		textBox.display( abilityInputBox )
	end
	
	if startingWord then
		love.graphics.setFont( buttonFont )
		love.graphics.setColor( colText.r, colText.g, colText.b )
		love.graphics.print( A_STORY_ABOUT_STR, (love.graphics.getWidth() - fontHeader:getWidth(startingWord))/2-buttonFont:getWidth( A_STORY_ABOUT_STR ) , 24 )
		love.graphics.setFont( fontHeader )
		love.graphics.setColor( colWikiWord.r,colWikiWord.g,colWikiWord.b )
		love.graphics.print( startingWord, (love.graphics.getWidth() - fontHeader:getWidth(startingWord))/2, 20 )
	end
	
	if not descriptionHeaderBox then
		love.graphics.setColor( colText.r, colText.g, colText.b )
		i = 0
		for k, v in pairs(abilities) do
			love.graphics.setFont( buttonFont )
			love.graphics.print( v, love.graphics.getWidth()/3, 410 + i*buttonFont:getHeight() )
			i = i + 1
		end
	end
	
	for k, cl in pairs( connectedClients ) do
		curY = 120 + 50*(cl.clientNumber-1)
		
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
		love.graphics.rectangle("fill", 5, curY-9 , love.graphics.getWidth()-10, 33)
		love.graphics.setColor( colText.r, colText.g, colText.b , 255)
		love.graphics.setFont( mainFont )
		love.graphics.print(cl.playerName, 200, curY )
		if cl.ready then
			love.graphics.print("[x]", 170, curY )
		else
			love.graphics.print("[ ]", 170, curY )
		end
		if cl.description then
			love.graphics.setColor( colText.r, colText.g, colText.b , 200)
			love.graphics.print( cl.description, 220+mainFont:getWidth(cl.playerName), curY )
		end
		--[[if cl.statistics then
			local x = 0
			for i = 1,#abilities,1 do
				if cl.statistics[i] then
					love.graphics.print( abilities[i] .. ":  " .. cl.statistics[i], 220 + mainFont:getWidth(cl.playerName) + x, curY - 10 )
					x = x + mainFont:getWidth( abilities[i] .. ":  " .. cl.statistics[i] ) + 10
				end
			end
		end]]--
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
