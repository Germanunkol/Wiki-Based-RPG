
socket = require("socket")
connection = require("Scripts/connection")
export = require("Scripts/export")

lobby = require("Scripts/lobby")
sound = require("Scripts/sound")


wikiClient = require("Scripts/wikiClient")

--THIS PORT MUST BE FORWARDED ON YOUR ROUTER FOR INTERNET PLAY!
PORT = 8080

server = nil		-- server object. When not nil, then connection is established.
client = nil		-- client object. When not nil, then connection is established.

textBox = require("Scripts/textBox")
plName = ""
ipStr = ""
startingWord = nil
curGameWord = ""

require("Scripts/misc")
statusMsg = require("Scripts/statusMsg")
chat = require("Scripts/chat")
menu = require("Scripts/menu")

buttons = require("Scripts/buttons")

game = require("Scripts/game")

notificationSound = nil

mainFont = love.graphics.newFont( "Fonts/AveriaSans-Regular.ttf", 18 )
buttonFont = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 18 )
fontHeader = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 25 )
fontInputHeader = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 20 )
fontInput = love.graphics.newFont( "Fonts/AveriaSans-Regular.ttf", 16 )
fontStatus = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf", 16 )
fontMainHeader = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf",40 )
fontChat = love.graphics.newFont( "Fonts/AveriaSans-Bold.ttf",14 )

colMainBg = { r=230, g=190, b=134 }
colBorder = { r=117, g=66, b=40 }
colLobby = { r=241, g=229, b=209 }
colServerMsg = { r=200,g=120,b=80}
colTextInput = { r=100, g=100, b=100 }
colWikiWord = { r=20, g=64, b=160 }
colStory = { r=100, g=80, b=60 }
colAction = { r=80, g=60, b=40 }		-- for "/do" command
colSpeech = { r=0, g=0, b=0 }		-- for "/say" command
colUse = { r=0, g=0, b=0 }		-- for "/use" command
colHighlightWikiWord = { r=200, g=225, b=170 }
colHighlightWikiWordNew = { r=225, g=250, b=190 }

colCharB = { r=240, g=210, b=150 }
colCharM = { r=135, g=76, b=45 }
colCharD = { r=50, g=20, b=10 }

AVATAR_PIXELS_X = 15
AVATAR_PIXELS_Y = 15
AVATAR_PIXELS_WIDTH = 15
AVATAR_PIXELS_HEIGHT = 15
avatar = {}

clientReady = false

nextFrameEvent = {}			-- these functions will be called after the next draw call.
testingConnection = 0


function love.load( arg )

	success = love.graphics.setMode( 1024, 680, false, false, 0 )
	love.graphics.setCaption( "Wiki-Based RPG" )
	sound.init()
	export.init()
	menu.initMainMenu()
	love.keyboard.setKeyRepeat( 0.3, 0.03 )
	testingConnection = true
	table.insert( nextFrameEvent, {func = wikiClient.testConnection, frames = 2 } )
	
	for i=0,AVATAR_PIXELS_X*AVATAR_PIXELS_Y-1,1 do
		avatar[i] = 0
	end
	
	--wikiClient.newWord()
	--wikiClient.nextWord()
	--tb = textBox.new( 10, 200, 5, fontInput, 75)
	--textBox.setContent( tb, "this\nis some\ntext")
	--startingWord = "TestWord"
	--export.toHtmlFile(tb)
	--textBox.setAccess ( tb , true )
	--textBox.highlightText( tb, "server" )
	--print(string.find("this is a test", ".* "))
end

local lastSent = os.time()
local msg

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
			if v.arg then
				v.func(v.arg)
			else
				v.func()
			end
			nextFrameEvent[k] = nil
		end
	end
end

function love.draw()

	if testingConnection then
		love.graphics.setFont( fontStatus )
		love.graphics.setColor( 0,0,0,255 )
		love.graphics.print( "Loading. Attempting to connect to wiki...", (love.graphics.getWidth()-fontStatus:getWidth("Loading. Attempting to connect to wiki..."))/2, love.graphics.getHeight()-30 )
	else
		if not server and not client then
			menu.showMainMenu()
		elseif lobby.active() then
			lobby.showPlayers()
		elseif game.active() then
			game.show()
		end
		--textBox.display()
		if wikiClient.getFirstWordActive() then
			wikiClient.displayFirstWordChoosing()
		end
		buttons.show()
		statusMsg.display()
	end
	--textBox.display( tb )
end

local inputRead
function love.keypressed(key, unicode)
	inputRead = textBox.input( key, unicode )
	if not inputRead then		--input has not been put into a chat box: use input as command
		if ( string.char(unicode) == "c" or string.char(unicode) == "return" ) and game.active() then
			chatAreaClicked()
		elseif ( string.char(unicode) == "s" or string.char(unicode) == "a" ) and game.active() then
			gameAreaClicked()
		elseif ( string.char(unicode) == "1" or string.char(unicode) == "2"
			or string.char(unicode) == "3" or string.char(unicode) == "4"
			or string.char(unicode) == "5") and game.active() then
			chooseNextWord( tonumber( string.char(unicode) ) )
		end
	end
end

function love.mousepressed()
	buttons.handleClick()
end


function startServer()
	server = connection.initServer( "*", PORT, 4 )
	if server then
		lobby.init( buttons )
	end
end

function startClient()
	client = connection.initClient( ipStr, PORT)
	if client then
		client:send("NAME:" .. plName .. "\n")
		statusMsg.new("Connected to server.")
		lobby.init( buttons )
	end
end


function love.quit()
	if server then
		print( "closing server" )
		connection.serverBroadcast("SERVERSHUTDOWN:")
		server:close()
	end
end
