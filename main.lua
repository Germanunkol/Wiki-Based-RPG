local connection = require("connection")

local lobby = require("lobby")

local wikiClient = require("wikiClient")

textBox = require("textBox")
plname = ""

require("misc")

local menu = require("menu")

buttons = require("buttons")
fontHeader = love.graphics.newFont( 25 )
fontInputHeader = love.graphics.newFont( 20 )
fontInput = love.graphics.newFont( 16 )
fontMainHeader = love.graphics.newFont( 35 )

plName = ""

local inputStr = ""
local wordToSearchFor = ""
local inputNum = 0

local numberOfChoices = 5

local foundStartPage = false

local pageSource = ""

local server
local client

mainFont = love.graphics.newFont( 14 )
buttonFont = love.graphics.newFont( 14 )

function love.load(arg)
	menu.initMainMenu(buttons)
	love.keyboard.setKeyRepeat( 0.2, 0.03 )

	--[[if arg[2] == "-server" then
		server = connection.initServer("localhost", 3456, 1)
	else
		client = connection.initClient("localhost", 3456)
	end]]--
	
	local tB = textBox.new( 15, 30, 3, mainFont, 272 )
	textBox.setText( tB, "test thisisalongerwordthancanbePlaced" )
	--textBox.setAccess( tB, true )
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
			connection.runServer(server)
	elseif client then
		if os.time() - lastSent > 2 and connection.getClientNumber() ~= nil then
			--local sendStr = "test-" .. connection.getClientNumber().. " " .. math.random(99)
	
			--client:send(sendStr .. "\n")
			--print("sending: " .. sendStr)
			lastSent = os.time()
		end
		
		msg = client:receive()
	
		if msg then
			print("received: " .. msg)
			if msg:find("CLIENTNUMBER") == 1 then
				local start, ending = msg:find("CLIENTNUMBER")
				connection.setClientNumber(msg:sub(ending+1, #msg))
			elseif msg:find("SERVERFULL") == 1 then
				print("ERROR: Server is full!")
				return
			end
		end
	end
	
end

function love.draw()
	if not server and not client then
		menu.showMainMenu()
	elseif lobby.active() then
		lobby.showPlayers()
	end
	textBox.display(dt)
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
	client = connection.initClient("localhost", 3456)
	if client then
		client:send("NAME:" .. plName .. "\n")
		lobby.init( buttons )
	end
end

