local menu = {}

local buttonWidth = 200
local buttonHeight = 35

local helpString = "Help file not found."			--default, if readme.me is not found

local function exitProgramm()
	love.event.quit()
end

local function drawButton( theButton )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
	love.graphics.setColor( 170, 180, 180, 255)
	love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
	love.graphics.setColor( 255, 255, 255 , 255)
	love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2)
end


local function highlightButton( theButton )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
	love.graphics.setColor( 180, 180, 180, 255)
	love.graphics.rectangle( "fill", theButton.x + 2, theButton.y + 2, theButton.w-4, theButton.h-4)
	love.graphics.setColor( 255, 255, 255 , 255)
	love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2 )
end

local function displayHelp( theButton )
	love.graphics.setColor( 0, 0, 0 , 255)
	width = love.graphics.getWidth()
	height = theButton.y+theButton.h - 10
	love.graphics.rectangle( "fill", theButton.x, 10, width-20, height )
	love.graphics.setColor( 180, 180, 180, 255)
	love.graphics.rectangle( "fill", theButton.x+1, 11, width-22, height-2)
	love.graphics.setColor( 255, 255, 255 , 255)
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

local function clientStart()
	buttons.clear()
	startClient()
	print("client options started")
end

function menu.initMainMenu()
	
	buttons.clear()
	
	local readmeFile = io.open("README.md", "r")
	if readmeFile then
		helpString = readmeFile:read("*all")
	end
	--love.graphics.setBackgroundColor(150,160,200)
	love.graphics.setBackgroundColor( 255, 255, 255 )
	
	buttons.add( love.graphics.getWidth()/2 - buttonWidth/2, 200, buttonWidth, buttonHeight, "Start Server", drawButton, highlightButton, serverStart)
	buttons.add( love.graphics.getWidth()/2 - buttonWidth/2, 200 + buttonHeight + 10, buttonWidth, buttonHeight, "Start Client", drawButton, highlightButton, clientStart )
	buttons.add( love.graphics.getWidth()/2 - buttonWidth/2, 200 + buttonHeight*2 + 20, buttonWidth, buttonHeight, "Quit", drawButton, highlightButton, exitProgramm )
	buttons.add( love.graphics.getWidth()-100, love.graphics.getHeight()-40, 90, 25, "Credits", drawButton, highlightButton)
	buttons.add( 10, love.graphics.getHeight()-40, 110, 25, "Help", drawButton, displayHelp )
end


function menu.showMainMenu()
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle("fill", love.graphics.getWidth()/2-buttonWidth/2-20, 170, buttonWidth + 40, love.graphics.getHeight())
	love.graphics.setColor( 255,255,255 , 200)
	love.graphics.rectangle("fill", love.graphics.getWidth()/2-buttonWidth/2-19, 171, buttonWidth + 38, love.graphics.getHeight())
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 100)
	love.graphics.setColor( 255,255,255 , 200)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 98)
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.setFont( fontMainHeader )
	love.graphics.print( "WB-RPG", 70, 70 )
	buttons.show()
end

function menu.showChat()

end

function menu.handleClick()
	buttons.handleClick()
end



return menu
