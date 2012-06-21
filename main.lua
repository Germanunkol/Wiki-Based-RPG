local connection = require("connection")

lobby = require("lobby")

local wikiClient = require("wikiClient")

textBox = require("textBox")
plname = ""
ipStr = ""

require("misc")
statusMsg = require("statusMsg")

menu = require("menu")

buttons = require("buttons")
mainFont = love.graphics.newFont( "AveriaSans-Regular.ttf", 18 )
buttonFont = love.graphics.newFont( "AveriaSans-Bold.ttf", 18 )
fontHeader = love.graphics.newFont( "AveriaSans-Bold.ttf", 25 )
fontInputHeader = love.graphics.newFont( "AveriaSans-Bold.ttf", 20 )
fontInput = love.graphics.newFont( "AveriaSans-Regular.ttf", 16 )
fontStatus = love.graphics.newFont( "AveriaSans-Bold.ttf", 16 )
fontMainHeader = love.graphics.newFont( "AveriaSans-Bold.ttf",40 )

colMainBg = { r=230, g=205, b=174 }
colBg = { r=149, g=124, b=101 }
colLobby = { r=241, g=229, b=209 }

plName = ""

PORT = 3456

local inputStr = ""
local wordToSearchFor = ""
local inputNum = 0

local numberOfChoices = 5

local foundStartPage = false

local pageSource = ""

server = nil		-- server object. When not nil, then connection is established.
client = nil		-- client object. When not nil, then connection is established.

function love.load(arg)
	menu.initMainMenu(buttons)
	love.keyboard.setKeyRepeat( 0.3, 0.03 )	
	--wikiClient.newWord()

	tb = textBox.new(10, 220, 5, fontInput, 200)
	textBox.setAccess( tb, true )
	textBox.setColour( tb, 30, 0, 0, 128 )
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
	-- This is needed to make sure client connection does not disable status messages, which would otherwise not show
	-- (especially the "attempting to connect" message)
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
	end
	statusMsg.display()
	textBox.display()
	buttons.show()
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

function startGame()
	statusMsg.new("Game starting.")
	print("game Started")
end

function love.quit()
	if server then
		print( "closing server" )
		server:close()
	end
end
