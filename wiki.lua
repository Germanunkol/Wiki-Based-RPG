local wiki

repeat
	print("Enter a starting Word (q to quit):")
	io.flush()
	wordToSearchFor = io.read()
	
	if wordToSearchFor == "q" or wordToSearchFor == "Q" then return end
	
	fullURL = baseURL .. "/wiki/" .. wordToSearchFor
	print ("Loading URL: " .. fullURL)
	pageSource = http.request(fullURL)
--	print (pageSource)
	
	if string.find(pageSource, "<div id=\"mw%-content%-text\"><div class=\"noarticletext\">") == nil then
	--//upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Disambig-dark.svg/28px-Disambig-dark.svg.png
	
		-- check if there is the disambig symbol on the page. If yes, then there's disambiguations of the name
		local multipleFound = false
		local start, ending = string.find(pageSource, "[D,d]isambig")
		if start then
			if string.find(pageSource, "[^\"]*%.svg%.png", ending) then
				
				print("Multiple Articles found.")
				
				print(string.sub(pageSource, 1, 50))
				local urlTable = urlManipulation.extractURLs(pageSource)
				
				
				
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
					return
				end
				
				if inputStr == "n" or inputStr == "N" then
					multipleFound = true
				else
					fullURL = baseURL .. urlTable[inputNum].url
					print ("You chose: " .. fullURL)
					multipleFound = false
				end
				
			end
		end
		
		if multipleFound == false then
			print("page found")
			foundStartPage = true
		end
	else
		print("No Wikipedia Article found. Try again.")
	end
	
	--print("no article found? : ") print(string.find(pageSource, "<div id=\"mw%-content%-text\"><div class=\"noarticletext\">"))
	--print("multiple articles found? : ") print(string.find(pageSource, "upload%.wikimedia%.org*/*%-Disambig*%.svg%.png"))
	
until foundStartPage or multipleFound


-- main loop:
repeat
	urlManipulation.log(fullURL)
	pageSource = http.request(fullURL)

	local urlTable = urlManipulation.extractURLs(pageSource)


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
		fullURL = baseURL .. urlTable[chosenURLs[inputNum] ].url
	end
until inputStr == "q"

