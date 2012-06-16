local wikiClient = {}

local http = require("socket.http")
local urlManipulation = require("urlManip")

http.TIMEOUT = 10

local WIKI_NOARTICLE = "<div id=\"mw%-content%-text\"><div class=\"noarticletext\">"
local WIKI_STARTOFCONTENTS = "<div id=\"mw%-content%-text\"-"
local WIKI_URL = "http://de.wikipedia.org"
local WIKI_DISAMBIGUATION = "[D,d]isambig[^\"]*%.svg%.png"

local fullURL = "http://de.wikipedia.org/wiki/Penghu"



function wikiClient.newWord()
	repeat
		print("Enter a starting Word (q to quit):")
		io.flush()
		wordToSearchFor = io.read()
	
		if wordToSearchFor == "q" or wordToSearchFor == "Q" then return end
	
		fullURL = WIKI_URL .. "/wiki/" .. wordToSearchFor
		print ("Loading URL: " .. fullURL)
		pageSource = http.request(fullURL)
	--	print (pageSource)
	
		if string.find(pageSource, WIKI_NOARTICLE) == nil then
		--//upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Disambig-dark.svg/28px-Disambig-dark.svg.png
	
			-- check if there is the disambig symbol on the page. If yes, then there's disambiguations of the name
			local multipleFound = false
			local start, ending = string.find(pageSource, WIKI_DISAMBIGUATION)

			if start then
			
				local urlTable = urlManipulation.extractURLs(pageSource, WIKI_STARTOFCONTENTS )
				
				for k, v in pairs(urlTable) do
					print("(" .. k .. ") " .. v.title .. ", " .. v.url)
				end

				repeat
					print("Multiple Entries for '" .. wordToSearchFor .. "' found. Choose one URL ('n' = new word, 'q' = quit):")
					io.flush()
					inputStr = io.read()
					inputNum = tonumber(inputStr)
					if inputNum ~= nil then inputNum = math.floor(inputNum) end	-- round to lower integer
				until inputStr == "n" or inputStr == "N"
						or inputStr == "q" or inputStr == "Q"
						or (inputNum ~= nil and inputNum >= 1 and inputNum <= #urlTable)

				if inputStr == "q" or inputStr == "Q" then
					return nil
				end
			
				if inputStr == "n" or inputStr == "N" then
					multipleFound = true
				else
					fullURL = WIKI_URL .. urlTable[inputNum].url
					print ("You chose: " .. fullURL)
					multipleFound = false
				end
			end
		
			if multipleFound == false then
				print("page found")
				foundStartPage = true
			end
		else
			print("No Wikipedia Article found. Try again.")
		end
		
	until foundStartPage or multipleFound
end


function wikiClient.nextWord()
	-- main loop:
	repeat
		urlManipulation.log(fullURL)
		pageSource = http.request(fullURL)

		local urlTable = urlManipulation.extractURLs(pageSource, WIKI_STARTOFCONTENTS)


		print("Found " .. numberOfFoundLinks .. " wiki-internal urls")
		print("Found " .. numberOfFoundLinks - doublesFound.. " unique wiki-internal urls")
	
		chosenURLs = {}
		math.randomseed(os.time())
		for i = 1,math.min(numberOfChoices, numberOfFoundLinks - doublesFound),1 do
			index = #chosenURLs + 1
			chosenURLs[index] = math.random(numberOfFoundLinks-doublesFound - i)
			for k, v in pairs(chosenURLs) do
				if k ~= i then
					if chosenURLs[index] >= v then chosenURLs[index] = chosenURLs[index] + 1 end
				end
			end
				print("(" .. index .. ") " .. urlTable[chosenURLs[index] ].title .. ", " .. urlTable[chosenURLs[index] ].url)
		end
	
		repeat
			print("Choose URL (or q to exit):")
			io.flush()
			inputStr = io.read()
			inputNum = tonumber(inputStr)
			if inputNum ~= nil then inputNum = math.floor(inputNum) end	-- round to lower integer
		until inputStr == "q" or inputStr == "Q" or (inputNum ~= nil and inputNum >= 1 and inputNum <= numberOfChoices)
	
		if inputStr ~= "q" and inputStr ~= "Q" then
			fullURL = WIKI_URL .. urlTable[chosenURLs[inputNum] ].url
		end
until inputStr == "q"
end

return wikiClient
