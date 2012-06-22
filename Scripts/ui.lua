local ui = {}


function ui.init()

end

local buttons = {}

local buttonWidth = 200
local buttonHeight = 35
local buttonFont = love.graphics.newFont( 14 )

local helpString = "Help file not found."			--default, if readme.me is not found

local function addButton(newX, newY, newWidth, newHeight, newLabel, functionOff, functionHover, newEvent)
	local newButton = {}
	newButton.x = newX
	newButton.y = newY
	newButton.label = newLabel
	newButton.centered = isCentered
	newButton.w = newWidth
	newButton.h = newHeight
	newButton.drawNormal = functionOff
	newButton.drawHover = functionHover
	newButton.event = newEvent
	table.insert( buttons, newButton )
end


local function exitProgramm()
	love.event.quit()
end

local function drawButton( theButton )
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
		love.graphics.setColor( 180, 180, 180, 255)
		love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
		love.graphics.setColor( 255, 255, 255 , 255)
		love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2)
end


local function highlightButton( theButton )
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
		love.graphics.setColor( 255, 255, 255 , 255)
		love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2 )
end

local function displayHelp( theButton )
love.graphics.setColor( 0, 0, 0 , 255)
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	love.graphics.rectangle( "fill", 10, 10, width-20, height-20 )
	love.graphics.setColor( 180, 180, 180, 255)
	love.graphics.rectangle( "fill", 11, 11, width-22, height-22)
	love.graphics.setColor( 255, 255, 255 , 255)
	love.graphics.rectangle( "fill",  13, 13, width-26, height-26)
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.printf( helpString, 20, 20, width-40, "left")

		-- also display button:
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
	love.graphics.setColor( 255, 255, 255 , 255)
	love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2 )
end

function ui.initMainMenu()
	
	local readmeFile = io.open("README.md", "r")
	if readmeFile then
		helpString = readmeFile:read("*all")
	end
	

	--love.graphics.setBackgroundColor(150,160,200)
	love.graphics.setBackgroundColor( 255, 255, 255 )
	
	addButton( love.graphics.getWidth()/2 - buttonWidth/2, 200, buttonWidth, buttonHeight, "Start Server", drawButton, highlightButton, serverOptions)
	addButton( love.graphics.getWidth()/2 - buttonWidth/2, 200 + buttonHeight + 10, buttonWidth, buttonHeight, "Start Client", drawButton, highlightButton )
	addButton( love.graphics.getWidth()/2 - buttonWidth/2, 200 + buttonHeight*2 + 20, buttonWidth, buttonHeight, "Quit", drawButton, highlightButton, exitProgramm )
	addButton( 10, love.graphics.getHeight()-40, 110, 25, "Help", drawButton, displayHelp )
	addButton( love.graphics.getWidth()-100, love.graphics.getHeight()-40, 90, 25, "Credits", drawButton, highlightButton)
end

local function mouseOver( theButton )		--check if the mouse is over the (rectangular) button
	x, y = love.mouse.getPosition()
	if x > theButton.x and x < theButton.x + theButton.w and y > theButton.y and y < theButton.y + theButton.h then
		return true
	end

	return false
end

local function handleButtons()
	love.graphics.setFont( buttonFont )
	love.graphics.setLine( 3, "smooth" )
	for key, button in pairs( buttons ) do
		if mouseOver( button ) then
			button.drawHover( button )
		else
			button.drawNormal( button )
		end
	end
end

function ui.handleClick()
	for key, button in pairs( buttons ) do
		if mouseOver( button ) then
			if button.event then
				button.event()
			end
			return
		end
	end
end

function ui.showMainMenu()
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle("fill", love.graphics.getWidth()/2-buttonWidth/2-20, 170, buttonWidth + 40, love.graphics.getHeight())
	love.graphics.setColor( 255,255,255 , 200)
	love.graphics.rectangle("fill", love.graphics.getWidth()/2-buttonWidth/2-19, 171, buttonWidth + 38, love.graphics.getHeight())
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 100)
	love.graphics.setColor( 255,255,255 , 200)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 98)
	handleButtons()
end


function ui.showChat()

end

function ui.showLobby()

end

function local.

function ui.serverOptions()
	clearButtons
end


return ui
