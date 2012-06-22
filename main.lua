local connection = require("Scripts/connection")

lobby = require("Scripts/lobby")

wikiClient = require("Scripts/wikiClient")

textBox = require("Scripts/textBox")
plname = ""
ipStr = ""

require("Scripts/misc")
statusMsg = require("Scripts/statusMsg")

menu = require("Scripts/menu")

buttons = require("Scripts/buttons")

game = require("Scripts/game")
--[[
mainFont = love.graphics.newFont( "Fonts/AveriaSans-Regular.ttf", 18 )
buttonFont = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 18 )
fontHeader = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 25 )
fontInputHeader = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 20 )
fontInput = love.graphics.newFont( "Fonts/AveriaSans-Regular.ttf", 16 )
fontStatus = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 16 )
fontMainHeader = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf",40 )
]]--

mainFont = love.graphics.newFont( 18 )
buttonFont = love.graphics.newFont( 18 )
fontHeader = love.graphics.newFont( 25 )
fontInputHeader = love.graphics.newFont( 20 )
fontInput = love.graphics.newFont( 16 )
fontStatus = love.graphics.newFont( 16 )
fontMainHeader = love.graphics.newFont( 40 )

colMainBg = { r=230, g=205, b=174 }
colBg = { r=149, g=124, b=101 }
colLobby = { r=241, g=229, b=209 }
colTextInput = { r=255, g=249, b=229 }

plName = ""

PORT = 3456


local pageSource = ""

server = nil		-- server object. When not nil, then connection is established.
client = nil		-- client object. When not nil, then connection is established.


function love.load(arg)
	menu.initMainMenu(buttons)
	love.keyboard.setKeyRepeat( 0.3, 0.03 )	
	--wikiClient.newWord()
	--wikiClient.nextWord()
	titleStr = ""
	fullTitle = "schrödinger"
	buttonFont:getWidth( fullTitle )
	j = 0
	while buttonFont:getWidth( titleStr ) < buttonWidth-20 and #titleStr < #fullTitle do
		print(titleStr.. " " .. buttonFont:getWidth( titleStr ))
		titleStr = fullTitle:sub( 1, j )
		print("new: " .. titleStr)
		j = j+1
	end
	--tb = textBox.new( 10, 10, 5, fontInput, 25)
	--textBox.setAccess ( tb , true )
end

local lastSent = os.time()
local msg

nextFrameEvent = {}			-- these functions will be called after the next draw call.

function love.update()
	if server then
		connection.runServer( server )
	elseif client then
		connection.runClient( client )
	end
	-- go through list of functions in nextFrameEvent and if they have waited the set amount of frames, call them.
	-- This is needed to make sure client connection does not disable status messages, which would otherwise not show (especially the "attempting to connect" message)
	for k, v in pairs( nextFrameEvent ) do	
		v.frames = v.frames - 1
		if v.frames <= 0 then
			v.func()
			nextFrameEvent[k] = nil
		end
	end
end

function love.draw()
	if not server and not client then
		menu.showMainMenu()
	elseif lobby.active() then
		lobby.showPlayers()
	elseif game.active() then
		game.show()
	end
	textBox.display()
	buttons.show()
	statusMsg.display()
end

function love.keypressed(key, unicode)
	textBox.input( key, unicode )
end

function love.mousepressed()
	menu.handleClick()
end


function startServer()
	server = connection.initServer( "localhost", PORT, 10 )
	if server then
		lobby.init( buttons )
	end
end

function startClient()
	client = connection.initClient( "localhost", PORT)
	if client then
		client:send("NAME:" .. plName .. "\n")
		statusMsg.new("Connected to server.")
		lobby.init( buttons )
	end
end


function love.quit()
	if server then
		print( "closing server" )
		server:close()
	end
end
