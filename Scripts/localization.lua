-- This Script handles the various languages.
-- DO NOT CHANGE THE LANGUAGES IN THIS FILE!
-- If you want to translate the game, simply:
--		a) Go to the Languages/ subfolder, copy and paste the English.txt, rename it to your Language (example: "Chinese.txt")
--		b) Open the new File and translate all the Strings (for an example, check out German.txt)
--		c) Create a flag image (maximum 50*35) for your language and put it into the /Images/Flags subfolder.
--			You can get nice, Public domain flags at: http://www.pdclipart.org/thumbnails.php?album=41
--		d) Start the game and test it out!
--		e) If it works, please send me the Flag and the Translated file, so I can include it in the official releases
SPECIAL_CHARACTERS = {}
PLAYERS_NOT_READY_LINES = {}
LOBBY_VERBS = {}

-- Fallback Strings:
WIKI_URL = [[http://en.wikipedia.org]]

WELCOME_STR = [[Welcome!]]

ATTEMPT_WIKI_CONNECT_STR = [[Loading. Attempting to connect to wiki...]]
STORYTELLER_STR = [[Storyteller]]
HEROES_STR = [[Heroes]]
ATTEMPT_CLIENT_CONNECT_STR = [[Attempting to connect...]]
CONNECTION_SUCCESS_STR = [[Connected to server.]]

START_SERVER_BUTTON_STR = [[Start Server]]
START_CLIENT_BUTTON_STR = [[Start Client]]
QUIT_BUTTON_STR = [[Quit]]
CREDITS_BUTTON_STR = [[Credits]]
HELP_BUTTON_STR = [[Help]]

GAME_TITLE_STR = [[the Wiki-Based Role Playing Game]]


SERVER_CLOSED_GAME_STR = [[Server closed game.]]

-- menu:
ENTER_PLAYERNAME_STR = [[Enter playername:]]
ENTER_IP_STR = [[Enter server's IP:]]


-- menu error messages
ERROR_INVALID_PLAYERNAME_STR = [[Invalid playername!]]
ERROR_INVALID_IP_STR = [[Invalid IP!]]
ERROR_ABORTED_STR = [[Aborted.]]
ERROR_SERVER_FULL_STR = [[Server is full!]]
ERROR_DUPLICATE_PLAYERNAME_STR = [[Name alread exists!]]
ERROR_GAME_ALREADY_STARTED_STR = [[Can't join: Game has already started!]]

-- lobby:
OPTIONS_STR = [[Options:]]
A_STORY_ABOUT_STR = [[A story of ]]
NEW_PLAYER_CONNECTED_STR = [[New player!]]
PLAYER_LEFT_STR = [[has left the game.]]
BEGIN_JOURNEY_BUTTON_STR = [[Begin journey]]
MODIFY_THEME_BUTTON_STR = [[Change theme]]

CHOOSE_PATH_BUTTON_STR = [[Choose path]]
CHANGE_FIRST_WORD_BUTTON_STR = [[Change first word]]
DESCRIBE_CHARACTER_BUTTON_STR = [[Describe character]]
CHANGE_DESCRIPTION_BUTTON_STR = [[Change description]]
READY_BUTTON_STR = [[Ready]]

CHOSEN_FIRST_WORD_STR = [[Start word set.]]

ENTER_DESCRIPTION_WORD_STR = [[Enter a word to describe your character:]]
ENTER_FIRST_WORD_STR = [[What will the story be about?]]

USE_DESCRIPTION_WORD = [[Tell us something about your character. Use the word:]]

-- lobby Error messages:
ERROR_AVATAR_CANNOT_CHANGE_STR = [[Cannot change avatar while you're "ready".]]
ERROR_NO_COMMAS_ALLOWED = [[No Commas allowed!]]
ERROR_MINIMUM_ONE_PLAYER_STR = [[Need at least one player!]]
ERROR_COULD_NOT_SET_THEME_STR = [[Error: Failed to set new theme.]]

-- players aren't ready messages: Invent something funny! You can add as many lines as you'd like (indices go from 1 to ... ? ):
PLAYERS_NOT_READY_LINES[1] = [[Some heroes have not packed their lunchbags yet.]]
PLAYERS_NOT_READY_LINES[2] = [[Still waiting for the heroes to dress...]]
PLAYERS_NOT_READY_LINES[3] = [[SOMEONE is still not ready!]]
PLAYERS_NOT_READY_LINES[4] = [[Waiting for the heroes to draw their little avatar-thingies...]]
PLAYERS_NOT_READY_LINES[5] = [[*Sigh*... nope. Someone's not ready yet.]]
PLAYERS_NOT_READY_LINES[6] = [[Heroes are taking their time...]]
PLAYERS_NOT_READY_LINES[7] = [[A hero is still busy kissing his mum good-bye...]]

-- these verbes are given as examples for the player's description:
LOBBY_VERBS[1] = [[has]]
LOBBY_VERBS[2] = [[likes]]
LOBBY_VERBS[3] = [[demands]]
LOBBY_VERBS[4] = [[uses]]
LOBBY_VERBS[5] = [[owns]]
LOBBY_VERBS[6] = [[despises]]
LOBBY_VERBS[7] = [[hates]]
LOBBY_VERBS[8] = [[knows about]]
LOBBY_VERBS[9] = [[dislikes]]
LOBBY_VERBS[10] = [[likes to]]
LOBBY_VERBS[11] = [[has been known to]]

-- in game:
GAME_STARTING_STR = [[Game starting.]]
WAITING_FOR_SERVER_BEGINNING_STR = [[Waiting for storyteller to beginn story...]]

RECEIVED_STR = [[received]]
USING_WORD1_STR = [[uses]]		-- result: "CLIENTNAME uses ITEM on ARGUMENT"
USING_WORD2_STR = [[on]]

WAITING_FOR_STR = [[Waiting for]]
YOUR_TURN_STR = [[Your Turn! What would you like to do?]]

CHOOSE_A_WORD_STR = [[Choose a word...]]
CHOOSE_WHAT_TO_DO_WITH_WORD_STR = [[What would you like to do?]]
USE_WORD_FOR_STORY_STR =  [[Use for story]]
GIVE_WORD_TO_PLAYER_STR = [[Give to]]
CHOSE_WORD_STR = [[Chose:]]
WORD_GIVEN_TO_STR = [[Word will be given to: ]]
CLIENT_STILL_CHOOSING_WORD_STR = [[Waiting for player to choose next word...]]
CLIENT_GETS_TO_CHOOSE_WORD_STR = [[Next word will be chosen by:]]

CHOSE_STR = [[chooses]]		-- result: "(PLAYERNAME chooses WORD for storyteller)"
FOR_STORYTELLER_STR = [[for storyteller.]]

SERVER_USED_JOKER_STR = [[(Server used joker)]]

START_STORY_USE_WORD_STR1 = [[Start the story. Use]]  -- result: "Start the story. Use (the current wiki word) in your text."
START_STORY_USE_WORD_STR2 = [[in your text.]]

CONTINUE_STORY_USE_WORD_STR1 = [[Continue the story. Use]]  -- result: "Continue the story. Use (the current wiki word) in your text."
CONTINUE_STORY_USE_WORD_STR2 = [[in your text.]]

MUST_USE_WORD_STR1 = [[You must use]]		-- result: "You must use (the current wiki word) in your text!"
MUST_USE_WORD_STR2 = [[in your text!]]

WAITING_FOR_HEROES_STR = [[Waiting for heroes to reply...]]
HOW_SHOULD_STORY_CONTINUE_STR = [[How should the story continue?]]

LOADING_STR = [[Loading...]]

INVENTORY_STR = [[Inventory]]

-- in game errors:
ERROR_AT_LEAST_4_WORDS_FOR_JOKER_STR = [[Need to have played at least 4 Words!]]
ERROR_CLIENT_NOT_FOUND_STR = [[Client not found. Can't give object to client.]]
ERROR_NO_EMPTY_TEXT_STR = [[Write something first!]]
ERROR_DOES_NOT_EXIST_STR = [[This object does not exist in your inventory!]]
ERROR_CHOOSE_NEXT_WORD_BEFORE_CONTINUING_STR = [[Choose next word first!]]
ERROR_NOT_YOUR_TURN_STR = [[It's not your turn!]]
ERROR_NOT_YOUR_TURN_TO_CHOOSE_WORD_STR = [[It's not your turn to choose a word!]]		-- shown when a server clicks on a joker button while a client is choosing a word for him/her.
ERROR_NO_LINKS_FOUND_Str = [[No links found. Using wiki main page.]]

-- exporter:
EXPORT_STR = [[Export]]
FILE_WRITTEN_TO_LOCATION_STR = [[written to:]]
ERROR_FILE_OPEN_STR = [[Error opening file!]]

-- wiki
NEW_WORD_SET_STR = [[New word set.]]
LOOKING_UP_WORD_STR = [[Looking up word...]]

-- wiki errors:
ERROR_WIKI_CONNECTION_STR = [[Error connecting to wiki.]]
ERROR_WIKI_CONNECTION_LONG_STR = [[Could not connect to wiki. Is your internet connection on?]]
ERROR_NO_WIKI_ARTICLE_STR = [[No wiki article found. Try another word or connect to the internet.]]
ERROR_INVALID_CHARACTER_STR =  [[Only numbers, spaces and letters allowed!]]
ERROR_MULTIPLE_ARTICLES_STR = [[Multiple articles found. Choose one.]]
CHOOSE_ARTICLE_STR = [[Did you mean...]]


-- Special characters. (remove the "--" at the beginning of the lines to make the lines work. Check Deutsch.txt for examples.
--SPECIAL_CHARACTERS[228] = "ä"
--SPECIAL_CHARACTERS[196] = "Ä"
--SPECIAL_CHARACTERS[246] = "ö"
--SPECIAL_CHARACTERS[214] = "Ö"
--SPECIAL_CHARACTERS[252] = "ü"
--SPECIAL_CHARACTERS[220] = "Ü"
--SPECIAL_CHARACTERS[223] = "ß"



-- this help text will be displayed on the main screen:
HELP_MAIN = [[
Choose "Server" to start a game.
You'll be the storywriter. Make sure to open/forward the port 8080 on your router if you're playing over the net! You can also change the port in "main.lua" in the game folder or .zip or .love.

Choose "Client" to join a server.
You need to know the server's IP to join, and you'll only be able to join while the server is in the lobby. As soon as the server has started the game, no more joining is possible.
]]


-- this is the help text displayed inside the Lobby:
HELP_LOBBY = [[
Wait for all players to join.

Server:
Choose a first word. This word will be the one where the story beginns (or what the story is about).
If you're unsure, you can try "Room", "Chest", "Monster", or "Dungeon". Or anything else, really. (Try "Apple pie"! I dare you!) If there's no Wiki-Entry found for the word, it'll tell you so.

Clients:
Create your Avatar. Also, choose something that describes your character.
If you don't like the words the wiki chooses for you, you can click "Change Description" as soon as you're done entering a description, to try again.
Press tab to automatically fill in the Word chosen by the wiki while typing.
When you're done, press "Ready".
]]


-- this help text will be displayed once players have started a game:
HELP_GAME = [[
Server:
If you are the server, you are to write the awesome story which the heroes will play through. Write a piece of the story (you must use the current Wiki-Word), then press enter. Then the clients have time to reply with actions.
In the meantime, you choose a new follow-up word which the Wiki has provided for you. Once the players are done answering, you continue the story. Again, you MUST use the word you picked in your story. You must also incorporate the actions that the heroes have done.
You have three jokers. If the words given to you absolutely don't fit with your story, click on the "1","2" or "3" buttons to go back to a previous word and choose a new path from there on.
You can also choose to give put words directly into the clients' inventories. To do so, click the word, then click on "Give to ...". I recommend mentioning this in your text, so people aren't confused. For example, type: "Luke Skywalker finds a lightsabre in the chest."

Hero:
If you're one of the heroes, wait for the server to write the story. Once the story is sent to you, you reply by doing or saying something (or both! You're a multi-talent-hero!)
You can and should use commands in your text. Available commands are:
/do	TEXT		(Write some action your character does)
/say TEXT		(Will be written as speech. Quotation marks are automatically added. /say is the default if you don't use any command.)
/use ID TEXT	(If there's something in your inventory, the number next to it is the ID. If the first object in your inventory is "1) key" then "/use 1 door" will produce: "Germanunkol uses key on door".)
/skip			(skip your turn)
For example, if the storyteller writes about a chest, you could type: "/do opens the chest. /say Let's see what's in here! /use 1 chest's lock".

Press Tab to automatically insert the current Wiki word while typing.

I recommend always sticking to the same tense (ideally the tense in which the storyteller started the story).
]]




-- code:

local localization = {}

local availableLanguages = {}

function copyFile(path, filename)
	if love.filesystem.exists(path .. filename) then
		love.filesystem.mkdir("Languages")
		
		content = love.filesystem.read( path ..  filename )
		love.filesystem.write( "Languages/" .. filename, content)
	end
end

-- Load the folder and search for translation files in there. For each file found, check if there's a flag file.
-- If so, save the language and flag into the availableLanguages table.
function localization.init( )
	
	print("Looking for available languages:")
	if love.filesystem.exists("Languages/Languages.txt") then
		for lang in love.filesystem.lines( "Languages/Languages.txt" ) do
			path = "Languages/" .. lang
			if love.filesystem.exists( path .. ".txt" ) then
				print("\tFound Language:" , lang)
				if love.filesystem.exists( path .. ".png" ) then
					print("\t\tFound flag for " .. lang)
					
					availableLanguages[path] = love.graphics.newImage( path .. ".png" )
				else
					print("\t\t-> could not find flag for " .. lang .. "!")
				end
			end
		end
	else
		print("\tFallback:")
		if love.filesystem.exists("DefaultLanguages/Languages.txt") then
			for lang in love.filesystem.lines( "DefaultLanguages/Languages.txt" ) do
				path = "DefaultLanguages/" .. lang
				if love.filesystem.exists( path .. ".txt" ) then
					print("\tFound Language:" , lang .. " (fallback)")
					if love.filesystem.exists( path .. ".png" ) then
						print("\t\tFound flag for " .. lang)
					
						availableLanguages[path] = love.graphics.newImage( path .. ".png" )
						copyFile( "DefaultLanguages/", lang .. ".txt")
						copyFile( "DefaultLanguages/", lang .. ".png")
					else
						print("\t\t-> could not find flag for " .. lang .. "!")
					end
				end
			end
			copyFile("DefaultLanguages/", "Languages.txt")
		else
			error("\n\n !! No languages found! Aborting... Maybe reinstall the game?")
			love.event.quit()
		end
	end



	--[[
	local foundLanguage = false
	dir = "/home/micha/.local/share/love/WikiBasedRPG"
	print("a", dir .. "/" , love.filesystem.mkdir(dir))
	print("a", dir .. "/" , love.filesystem.isDirectory(love.filesystem.getSaveDirectory() ))
	print("a", dir .. "/" , love.filesystem.exists(love.filesystem.getSaveDirectory() ))
	files = love.filesystem.enumerate( dir )
	for k, file in pairs(files) do
		print(file)
		s,e = file:find(".*txt")
		if s and e then
			if e-s+1 == #file then
				print("Found Language: " .. safeSub(file, 1, strLen(file)-4))
				if love.filesystem.exists( safeSub(file, 1, strLen(file)-4) .. ".png" ) then
					print("\tFound flag: " .. safeSub(file, 1, strLen(file)-4) .. ".png" )
					availableLanguages[safeSub(file, 1, strLen(file)-4)] = love.graphics.newImage( safeSub(file, 1, strLen(file)-4) .. ".png" )
					
					foundLanguage = true
				else
					print("\tNo flag found for Language")
				end
			end
		end
	end
	
	print("b")
	if not foundLanguage then
		files = love.filesystem.enumerate( fallbackPath )
		for k, file in pairs(files) do
			s,e = file:find(".*txt")
			if s and e then
				if e-s+1 == #file then
					print("Found Language (fallback): " .. fallbackPath .. safeSub(file, 1, strLen(file)-4))
					if love.filesystem.exists( fallbackPath .. safeSub(file, 1, strLen(file)-4) .. ".png" ) then
						print("\tFound flag (fallback): " .. fallbackPath .. safeSub(file, 1, strLen(file)-4) .. ".png" )
						availableLanguages[safeSub(file, 1, strLen(file)-4)] = love.graphics.newImage(  fallbackPath .. safeSub(file, 1, strLen(file)-4) .. ".png" )
					
						foundLanguage = true
					
						if not love.filesystem.exists( love.filesystem.getSaveDirectory( ) .. safeSub(file, 1, strLen(file)-4) .. ".png" ) then
							flag = love.image.newImageData( fallbackPath .. safeSub(file, 1, strLen(file)-4) .. ".png" )
							
							
							language = love.filesystem.read( fallbackPath .. file)
							love.filesystem.write( safeSub(file, 1, strLen(file)-4) .. ".txt", language)
							print(" -> extracted " .. file .. " to " .. love.filesystem.getSaveDirectory( ))
							language = nil
							
							flag:encode( safeSub(file, 1, strLen(file)-4) .. ".png" )
							print(" -> extracted " .. safeSub(file, 1, strLen(file)-4) .. ".png to " .. love.filesystem.getSaveDirectory( ))
						end
					
					
					else
						print("\tNo flag found for Language")
					end
				end
			end
		end
	
	
		
	end
	
	if not foundLanguage then
		print("ERROR: no languages found!")
		love.event.quit()
	end
	--]]
	--[[dir = io.popen("ls Languages", "r")
	
	for file in dir:lines() do
		s,e = file:find(".*txt")
		if s and e then
			if e-s+1 == #file then
				print("Found Language: " .. safeSub(file, 1, strLen(file)-4))
				flag = io.open( "Languages/Flags/" .. safeSub(file, 1, strLen(file)-4) .. ".png" )
				if flag then
					print("\tFound flag: " .. "Languages/Flags/" .. safeSub(file, 1, strLen(file)-4) .. ".png" )
					availableLanguages[safeSub(file, 1, strLen(file)-4)] = love.graphics.newImage( "Languages/Flags/" .. safeSub(file, 1, strLen(file)-4) .. ".png" )
				else
					print("\tNo flag found for Language")
				end
			end
		end
	end]]--
end

function localization.display()		-- show all flags and languages found, so the player can choose one.
	local i, j = 1,1
	local x, y
	love.graphics.setFont( mainFont )
	for lang, flag in pairs(availableLanguages) do
		_,__,langname = lang:find("/(.*)")
		if not langname then
			langname = lang
		end
		x = i*love.graphics.getWidth()/5 - 50
		y = j*love.graphics.getHeight()/7 - love.graphics.getHeight()/20
		love.graphics.setColor( 0,0,0, 100)
		love.graphics.draw( flag, x+5, y+7)
		love.graphics.setColor( colText.r,colText.g,colText.b, 255)
		love.graphics.print( langname, x - mainFont:getWidth(langname)/2 + flag:getWidth()/2, y-25 )
		love.graphics.setColor( 255,255,255, 255)
		love.graphics.draw( flag, x, y)
		i = i + 1
		if i == 5 then
			i = 1
			j = j + 1
		end
	end
end

function languageChosen( lang )
	PLAYERS_NOT_READY_LINES = {}
	LOBBY_VERBS = {}
	SPECIAL_CHARACTERS = {}

	local ok, chunk
	ok, chunk = pcall( love.filesystem.load, "Languages/" .. lang .. ".txt" ) -- load the chunk safely
	if not ok then
		print("Error loading '" .. lang .. ".txt': " .. tostring(chunk))
	else
		ok, result = pcall(chunk) -- execute the chunk safely
		if not ok then -- will be false if there is an error
			print("Error in '" .. lang .. ".txt': " .. tostring(chunk))
		end
	end
	statusMsg.new( WELCOME_STR )
end

function localization.clicked()
	local i, j = 1,1
	local x, y
	local mouseX, mouseY = love.mouse.getPosition()
	for lang, flag in pairs(availableLanguages) do
		x = i*love.graphics.getWidth()/5 - 50
		y = j*love.graphics.getHeight()/7 - love.graphics.getHeight()/20
		if mouseX > x and mouseX < x + flag:getWidth() then
			if mouseY > y and mouseY < y + flag:getHeight() then
				languageChosen( lang )
				return lang
			end
		end
		i = i + 1
		if i == 5 then
			i = 1
			j = j + 1
		end
	end
	return nil
end

return localization
