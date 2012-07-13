local menu = {}

buttonWidth = 200
buttonHeight = 35

helpString = "Help file not found."			--default, if readme.me is not found

local plNameHeader = nil
local plNameInputBox = nil
local ipHeader = nil
local ipInputBox = nil
local logoIMG = nil

local	headerPos = 335

local function exitProgramm()
	love.event.quit()
end



local function displayHelp( theButton )
	--love.graphics.setColor( 0, 0, 0 , 255)
	width = love.graphics.getWidth()
	height = theButton.y+theButton.h - 10
	--love.graphics.rectangle( "fill", theButton.x, 10, width-20, height )
	love.graphics.setColor( colBorder.r,colBorder.g,colBorder.b , 255)
	love.graphics.rectangle( "fill", theButton.x+1, 11, width-22, height-2)
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g)
	love.graphics.rectangle( "fill",  theButton.x+3, 13, width-26, height-6)
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.printf( helpString, 20, 20, width-40, "left")

	highlightButton ( theButton )	-- also display button
end


local function serverStart()
	buttons.clear()
	startServer()
	print("server options started")
end

function clientFinishedInput()
	if ipInputBox then ipStr = textBox.getContent( ipInputBox ) end
	-- if IP is either empty (will get replaced with "localhost") or a valid IP string, then continue
	local start, ending = ipStr:find("%d?%d?%d%.%d?%d?%d%.%d?%d?%d%.%d?%d?%d");
	if #ipStr == 0 or ipStr == "localhost" or ( start == 1 and ending == #ipStr ) then
		buttons.clear()
		plNameInputBox = textBox.remove( plNameInputBox )		-- textBox.remove returns nil upon success.
		plNameHeader = textBox.remove( plNameHeader )
		ipHeader = textBox.remove( ipHeader )
		ipInputBox = textBox.remove( ipInputBox )
		statusMsg.new("attempting to connect...")
		table.insert( nextFrameEvent, { func = startClient, frames = 2 } )
	else
		textBox.setAccess( ipInputBox, true )
		statusMsg.new( "Invalid IP!" )
	end
end

function abortClientConnecting()
	buttons.clear()
	plNameInputBox = textBox.remove( plNameInputBox )		-- textBox.remove returns nil upon success.
	plNameHeader = textBox.remove( plNameHeader )
	ipHeader = textBox.remove( ipHeader )
	ipInputBox = textBox.remove( ipInputBox )
	statusMsg.new("Aborted.")
	menu.initMainMenu()
end

local function clientInitIpInput()
	print ("new playername: " .. textBox.getContent( plNameInputBox ) )
	if plNameInputBox then plName = textBox.getContent( plNameInputBox ) end
	if #plName > 1 and plName["1"] ~= " " then
		if plNameInputBox then
			textBox.setAccess( plNameInputBox, false )
		end
		
		ipHeader = textBox.new( love.graphics.getWidth()/2-buttonWidth/2-10, headerPos+120, 1, fontInputHeader, 200)
		textBox.setContent( ipHeader, "Enter server's IP:" )
		ipInputBox = textBox.new( love.graphics.getWidth()/2-buttonWidth/2-5, headerPos+140, 1, fontInput, 200)
		textBox.setColour( ipInputBox, colTextInput.r, colTextInput.g, colTextInput.b )
		textBox.setContent( ipInputBox, ipStr )		-- if there's something already in ip string, then place that text in the input box.
		textBox.moveCursorToEnd( ipInputBox )
		textBox.setAccess( ipInputBox, true, nil, true )
		textBox.setReturnEvent( ipInputBox, clientFinishedInput )
		textBox.setEscapeEvent( ipInputBox, abortClientConnecting )
	else
		if plNameInputBox then textBox.setAccess( plNameInputBox, true ) end
		statusMsg.new( "Invalid playername!" )
	end
end


local function clientInitPlayernameInput()
	buttons.clear()
	plNameHeader = textBox.new( love.graphics.getWidth()/2-buttonWidth/2-10, headerPos+70, 1, fontInputHeader, 200)
	textBox.setContent( plNameHeader, "Enter Playername:" )
	plNameInputBox = textBox.new( love.graphics.getWidth()/2-buttonWidth/2-5, headerPos+90, 1, fontInput, 200)
	textBox.setColour( plNameInputBox, colTextInput.r, colTextInput.g, colTextInput.b )
	
	
	textBox.setContent( plNameInputBox, plName )		-- if player name was already set, place it in the box.
	textBox.moveCursorToEnd( plNameInputBox )
	textBox.setAccess( plNameInputBox, true, nil, true )
	textBox.setReturnEvent( plNameInputBox, clientInitIpInput )
	textBox.setEscapeEvent( plNameInputBox, abortClientConnecting )
end


function menu.initMainMenu()
	
	buttons.clear()

	logoIMG = love.graphics.newImage( "Images/LogoColourSmall.png" )
	
	local helpFile = io.open( "Help/main.txt", "r" )
	if helpFile then
		helpString = helpFile:read( "*all" )
		helpFile:close()
	end
	--love.graphics.setBackgroundColor(150,160,200)
	love.graphics.setBackgroundColor( colMainBg.r, colMainBg.g, colMainBg.b )
	imgScale = 1
	headerPos = 335

	buttons.add( love.graphics.getWidth()/2 - buttonWidth/2, 420, buttonWidth, buttonHeight, "Start Server", drawButton, highlightButton, serverStart)
	buttons.add( love.graphics.getWidth()/2 - buttonWidth/2, 420 + buttonHeight + 10, buttonWidth, buttonHeight, "Start Client", drawButton, highlightButton, clientInitPlayernameInput )
	buttons.add( love.graphics.getWidth()/2 - buttonWidth/2, 420 + buttonHeight*2 + 20, buttonWidth, buttonHeight, "Quit", drawButton, highlightButton, exitProgramm )
	buttons.add( love.graphics.getWidth()-100, love.graphics.getHeight()-40, 90, 25, "Credits", drawButton, highlightButton)
	buttons.add( 10, love.graphics.getHeight()-40, 110, 25, "Help", drawButton, displayHelp )
end


function menu.showMainMenu()
		--love.graphics.line(0, 120, love.graphics.getWidth(), 120)
		
	--love.graphics.setColor( 0, 0, 0 , 255)
	--love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 50)
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.g, 255)
	love.graphics.rectangle("fill", 0, headerPos, love.graphics.getWidth(), 48)
	
	love.graphics.setFont( fontMainHeader )
	love.graphics.setColor( colLobby.r,colLobby.g,colLobby.b )
	love.graphics.print( "WB-RPG", 30, headerPos+1 )
	love.graphics.setFont( mainFont )
	love.graphics.print( "the Wiki-Based Role Playing Game", 190, headerPos+15 )
	
	love.graphics.draw( logoIMG, (love.graphics.getWidth()-logoIMG:getWidth()*imgScale)/2, 20, 0, imgScale, imgScale )

	textBox.display( plNameHeader )
	textBox.display( plNameInputBox )
	textBox.display( ipHeader )
	textBox.display( ipInputBox )
end



return menu
