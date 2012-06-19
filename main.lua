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
end

local lastSent = os.time()
local msg

local backspaceTimer = 0
local timeSinceLastCall = 0
local dt
function love.update()
	dt = socket.gettime() - timeSinceLastCall
	timeSinceLastCall = socket.gettime()
	
	if server then
		connection.runServer( server )
	elseif client then
		connection.runClient( client )
	end
	
end

function love.draw()
	if not server and not client then
		menu.showMainMenu()
	elseif lobby.active() then
		lobby.showPlayers()
	end
	statusMsg.display( dt )
	textBox.display( dt )
	buttons.show()
end

function love.keypressed(key, unicode)
	textBox.input( key, unicode )
end

function love.mousepressed()
	menu.handleClick()
end


function startServer()
	server = connection.initServer("localhost", 3456, 10)
	if server then
		lobby.init( buttons )
	end
end


function startClient()
	statusMsg.new("starting up client...")
	client = connection.initClient( ipStr, 3456)
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

