local wikiClient = {}

local http = require("socket.http")
local urlManipulation = require("Scripts/urlManip")

http.TIMEOUT = 10

-- this is the base URL of the wiki. To start out, you can try "http://de.wikipedia.org" or "http://fr.wikipedia.org":
WIKI_URL = "http://en.wikipedia.org"

-- if this line is found on the source page, then there is no wiki site for the word you're looking for:
local WIKI_NOARTICLE = "<div id=\"mw%-content%-text\"><div class=\"noarticletext\">"

-- if this line is found, then the page has been deleted.
local WIKI_DELETEDPAGE = "<div id=\"mw%-content%-text\"><div class=\"mw%-warning%-with%-logexcerpt\">"

-- this is what the text body starts with. The game will only look for links starting after this line, because other links might be links that have nothing to do with the content. We don't want those.
local WIKI_STARTOFCONTENTS = "<div id=\"mw%-content%-text\"-"

-- if there's more than one page to a given word, then this disambiguation is found in the page source somewhere:
local WIKI_DISAMBIGUATION = "[D,d]isambig[^\"]*%.svg%.png"

-- manually add names of pages you don't want displayed. This is a comma-seperated list.
WIKI_BLACKLIST = {"view the content page"}

-- the number of wiki words that the game will choose from the page:
local numberOfChoices = 5






local fullURL = ""

local urlTable = nil

local previousWikiWords = {}		-- stores all words a player chooses, so that jokers can revert back to one of them.

function wikiClient.testConnection()
	pageSource = http.request(WIKI_URL)
	if pageSource == nil then
		table.insert( nextFrameEvent, {func = statusMsg.new, frames = 2, arg = ERROR_WIKI_CONNECTION_LONG_STR } )
		return false
	else
		testingConnection = false
		return true
	end
end

function wikiClient.getWikiURL()
	return WIKI_URL
end

function wikiClient.newWord( wordToSearchFor )	
	fullURL = WIKI_URL .. "/wiki/" .. wordToSearchFor
	print ("Loading URL: " .. fullURL)
	pageSource = http.request(fullURL)
	print("length page source 1: " .. strLen(pageSource))
	--print("start: " .. safeSub( pageSource, 1, 10))
	print("end: " .. safeSub( pageSource, strLen(pageSource)-10, strLen(pageSource)))
	urlTable = nil
	local foundStartPage, multipleFound = false, false

	if pageSource == nil then
		statusMsg.new( ERROR_WIKI_CONNECTION_STR )
		return nil
	end
	if string.find(pageSource, WIKI_NOARTICLE) == nil and string.find(pageSource, WIKI_DELETEDPAGE) == nil then
	--//upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Disambig-dark.svg/28px-Disambig-dark.svg.png

		-- check if there is the disambig symbol on the page. If yes, then there's disambiguations of the name
		local start, ending = string.find( pageSource, WIKI_DISAMBIGUATION )
		if start then
			urlTable = urlManipulation.extractURLs( pageSource, WIKI_STARTOFCONTENTS )
			
			--[[for k, v in pairs(urlTable) do
				print("(" .. k .. ") " .. v.title .. ", " .. v.url)
			end]]--

			print("Multiple Entries for '" .. wordToSearchFor .. "' found.")
			multipleFound = true
		end
		foundStartPage = true
	else
		print("No Wikipedia Article found. Try again.")
	end
	return foundStartPage, multipleFound, urlTable
end

function wikiClient.nextWord()		-- choose a few random links from the wiki source page of the current word
	urlManipulation.log(fullURL)
	pageSource = http.request(fullURL)

	if pageSource == nil then
		statusMsg.new( ERROR_WIKI_CONNECTION_STR )
		return nil
	end
	local urlTable, numberOfFoundLinks, doublesFound = urlManipulation.extractURLs(pageSource, WIKI_STARTOFCONTENTS)

	print("Found " .. numberOfFoundLinks .. " wiki-internal urls")
	print("Found " .. numberOfFoundLinks - doublesFound.. " unique wiki-internal urls")

	local chosenURLIndecies = {}
	local chosenURLs = {}
	math.randomseed(os.time())
	for i = 1,math.min(numberOfChoices, numberOfFoundLinks - doublesFound-1),1 do
		index = #chosenURLIndecies + 1
		chosenURLIndecies[index] = math.random(numberOfFoundLinks-doublesFound - i)	--randomly choose url in table.
		for k, v in pairs(chosenURLIndecies) do			--remove doubles?
			if k ~= i then
				if chosenURLIndecies[index] >= v then chosenURLIndecies[index] = chosenURLIndecies[index] + 1 end
			end
		end
		--print("(" .. index .. ") " .. urlTable[chosenURLIndecies[index] ].title .. ", " .. urlTable[chosenURLIndecies[index] ].url)
		table.insert( chosenURLs, { title = urlTable[chosenURLIndecies[index] ].title, url=urlTable[chosenURLIndecies[index] ].url } )
	end
	
	return chosenURLs
	--fullURL = WIKI_URL .. urlTable[chosenURLs[inputNum] ].url
end

function wikiClient.getNumOfPreviousWords()
	return #previousWikiWords
end

function wikiClient.randomPreviousWords()		-- give the player old words to go back to.

	for i = #previousWikiWords, 2, -1 do -- shuffle
		local r = math.random(i) -- select a random number between 1 and i
		previousWikiWords[i], previousWikiWords[r] = previousWikiWords[r], previousWikiWords[i] -- swap the randomly selected item to position i
	end
	local chosenURLs = {}
	local i = 1
	for k, word in pairs( previousWikiWords ) do
		if i > 5 then break end
		table.insert( chosenURLs, { title = word.title, url=word.url } )
	end
	
	return chosenURLs
	--fullURL = WIKI_URL .. urlTable[chosenURLs[inputNum] ].url
end

function wikiClient.setNewWord( newWord )
	fullURL = WIKI_URL .. newWord.url
	table.insert( previousWikiWords, newWord )		-- remember, so player can jump back to an old word (using a joker)
	print("URL chosen: " .. fullURL)
end



-- let server choose a word:

local firstWordActive = false

local firstWordInputBox
local firstWordHeaderBox
local multipleFoundHeaderBox
local x,y,h,w,returnEvent


function chooseWord( k )

	textBox.remove( firstWordInputBox )
	firstWordInputBox = nil
	textBox.remove( firstWordHeaderBox )
	firstWordHeaderBox = nil		
	buttons.clear()
	
	firstWordActive = false
	
	wikiClient.setNewWord( urlTable[k] )
	
	if returnEvent then
		returnEvent( urlTable[k].title )
	end
end


function wikiClient.firstWordSet()
	--only allow letters, digits and spaces:
	if textBox.getContent( firstWordInputBox ):match( "[%d%a%s]+" ) == textBox.getContent( firstWordInputBox ) then
		found, multiple, urlTable = wikiClient.newWord( textBox.getContent( firstWordInputBox ) )
		if multiple == true then
			statusMsg.new( ERROR_MULTIPLE_ARTICLES_STR )
			textBox.setContent( firstWordHeaderBox, CHOOSE_ARTICLE_STR )
			local fieldWidth = w-20
			local i = 0
			local j
			local titleStr = 0
			for k, v in pairs( urlTable ) do
				if i < 6 then
					titleStr = ""
					for char in v.title:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
						titleStr = titleStr .. char
						if stringWidth( titleStr,buttonFont ) >= fieldWidth-30 then
							 break
						end
					end
					if titleStr ~= v.title then
						titleStr = titleStr .. "..."
					end
					buttons.add( x+10, y + 25 + i*(buttonHeight-10), fieldWidth, buttonHeight/2+5, titleStr, drawButton, highlightButton , chooseWord, k )
				end
				i = i+1
			end
			textBox.remove( firstWordInputBox )
			firstWordInputBox = nil

			--textBox.setAccess( firstWordInputBox, true )
			return
		elseif found == nil or found == false then
			statusMsg.new( ERROR_NO_WIKI_ARTICLE_STR )
			textBox.setAccess( firstWordInputBox, true )
			return
		end

		local word = textBox.getContent( firstWordInputBox )
			
		textBox.remove( firstWordInputBox )
		firstWordInputBox = nil
		textBox.remove( firstWordHeaderBox )
		firstWordHeaderBox = nil		
		buttons.clear()
		statusMsg.new( NEW_WORD_SET_STR )
	
		firstWordActive = false
	
		if returnEvent then
			returnEvent( word )
		end
		
	else
		textBox.setAccess( firstWordInputBox, true )
		statusMsg.new( ERROR_INVALID_CHARACTER_STR )
	end
end

function wikiClient.startFirstWordSet()
	statusMsg.new( LOOKING_UP_WORD_STR )	
	table.insert( nextFrameEvent, {func = wikiClient.firstWordSet, frames = 2 } ) --make sure message is drawn before calling the event
end

function wikiClient.inputWikiWord( xPos, yPos, width, height, event, title)
	x, y, w, h, returnEvent = xPos, yPos, width, height, event
	if firstWordActive == true then
		textBox.remove( firstWordInputBox )
		firstWordInputBox = nil
		textBox.remove( firstWordHeaderBox )
		firstWordHeaderBox = nil
	end
	firstWordActive = true
	buttons.clear()
	if firstWordHeaderBox == nil then
		firstWordHeaderBox = textBox.new( x+10, y + 3, 2, fontInputHeader, w )
	end
	textBox.setContent( firstWordHeaderBox, title )
	if firstWordInputBox == nil then
		firstWordInputBox = textBox.new( x+15, y + 23, 1, fontInput, 200 )
		textBox.setColour( firstWordInputBox, colTextInput.r, colTextInput.g, colTextInput.b )
	end
	textBox.setAccess( firstWordInputBox, true, true )
	textBox.setReturnEvent( firstWordInputBox, wikiClient.startFirstWordSet )
end

function wikiClient.displayFirstWordChoosing()
	--love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
	--love.graphics.rectangle("fill", x, y, w, h)	
	textBox.display( firstWordInputBox )
	textBox.display( firstWordHeaderBox )
end

function wikiClient.getFirstWordActive()
	return firstWordActive
end

return wikiClient
