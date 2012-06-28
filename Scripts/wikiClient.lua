local wikiClient = {}

local http = require("socket.http")
local urlManipulation = require("Scripts/urlManip")

http.TIMEOUT = 10

local WIKI_NOARTICLE = "<div id=\"mw%-content%-text\"><div class=\"noarticletext\">"
local WIKI_DELETEDPAGE = "<div id=\"mw%-content%-text\"><div class=\"mw%-warning%-with%-logexcerpt\">"
local WIKI_STARTOFCONTENTS = "<div id=\"mw%-content%-text\"-"
local WIKI_URL = "http://en.wikipedia.org"
local WIKI_DISAMBIGUATION = "[D,d]isambig[^\"]*%.svg%.png"
local numberOfChoices = 5

local fullURL = ""

local urlTable = nil

function wikiClient.testConnection()
	pageSource = http.request(WIKI_URL)
	if pageSource == nil then
		table.insert( nextFrameEvent, {func = statusMsg.new, frames = 2, arg = "Could not connect to wiki. Is your internet connection on?" } )
		return false
	else
		testingConnection = false
		return true
	end
end

function wikiClient.newWord( wordToSearchFor )	
	fullURL = WIKI_URL .. "/wiki/" .. wordToSearchFor
	print ("Loading URL: " .. fullURL)
	pageSource = http.request(fullURL)
	urlTable = nil
	local foundStartPage, multipleFound = false, false

	if pageSource == nil then
		statusMsg.new("Error connecting. Please retry.")
		return nil
	end
	if string.find(pageSource, WIKI_NOARTICLE) == nil and string.find(pageSource, WIKI_DELETEDPAGE) == nil then
	--//upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Disambig-dark.svg/28px-Disambig-dark.svg.png

		-- check if there is the disambig symbol on the page. If yes, then there's disambiguations of the name
		local start, ending = string.find( pageSource, WIKI_DISAMBIGUATION )
		if start then
			urlTable = urlManipulation.extractURLs( pageSource, WIKI_STARTOFCONTENTS )
			
			for k, v in pairs(urlTable) do
				print("(" .. k .. ") " .. v.title .. ", " .. v.url)
			end

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

	local urlTable, numberOfFoundLinks, doublesFound = urlManipulation.extractURLs(pageSource, WIKI_STARTOFCONTENTS)

	print("Found " .. numberOfFoundLinks .. " wiki-internal urls")
	print("Found " .. numberOfFoundLinks - doublesFound.. " unique wiki-internal urls")

	chosenURLIndecies = {}
	chosenURLs = {}
	math.randomseed(os.time())
	for i = 1,math.min(numberOfChoices, numberOfFoundLinks - doublesFound),1 do
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

function wikiClient.setNewURL( newURL )
	fullURL = WIKI_URL .. newURL
	print("Next url: " .. fullURL)
end

return wikiClient
