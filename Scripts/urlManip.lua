local urlManip = {}

local function splitLink(inputStr)

	local field = {}
	
	for s in string.gmatch(inputStr, "\"[^\"]-\"") do
		s = s:sub(2, #s-1)	--cut "" away
		table.insert(field,s)
	end

	url = field[1]
	title = field[2]
	
	if url:sub(1,1) == "/" and url:sub(2,2) == "/" then
		url = "http:" .. url
	end
	
	--print("url: " .. url)
	--if title then print("title: " .. title) end
	return url, title
end

local function findRelevantArea( inputStr, contentsStartString )
	local beginning = inputStr:find( contentsStartString )
	local ending = #inputStr
	local curPos = 1
	local endFound = false
	
	local subLevelFound = 0

	if beginning == nil then return "" end
	
	local foundNewBeginning, foundNewEnding
	repeat 
		foundNewBeginning = inputStr:find("<div >", curPos)
		if foundNewBeginning ~= nil then
			subLevelFound = subLevelFound + 1
			curPos = subLevelFound
		end
	until foundNewBeginning == nil
	
	curPos = 1
	repeat
		foundNewEnding = inputStr:find("div>", curPos)
		if foundNewEnding ~= nil then
			subLevelFound = subLevelFound - 1
			curPos = subLevelFound
		end
	until subLevelFound == 0 or foundNewEnding == nil
	
	
	return inputStr:sub(beginning, curPos)
end

local function extractAllURLs(inputStr, contentsStartString)
	inputStr = findRelevantArea(inputStr, contentsStartString)
	local links = {}
	for s in string.gmatch(inputStr, "<a href=[^>]->") do
		table.insert(links,{fullStr = s})
	end
	for key, value in pairs(links) do
		value.url, value.title = splitLink(value.fullStr)
	end
	--print("url: " .. url)
	--print("title: " .. title)
	return links
end

function urlManip.extractURLs(inputStr, contentsStartString)
	local urlTable = {}
	local urlTableFull = {}

	urlTableFull = extractAllURLs(inputStr, contentsStartString)

	local numberOfFoundLinks = 0
	local doublesFound = 0

	for key, value in pairs(urlTableFull) do
		if value.url and value.title and not value.url:find(":") and not value.url:find("#") then		-- make only valid links work
			if value.url:find("/wiki/") == 1 and value.url:find("/Wikipedia") == nil then
				numberOfFoundLinks = numberOfFoundLinks + 1
			else
				urlTableFull[key] = nil
			end
		else
			urlTableFull[key] = nil
		end
	end
	
	for key, value in pairs(urlTableFull) do
		for k, v in pairs(urlTableFull) do		-- go through list again
			if k ~= key and value.url == v.url then			-- remove doubles
				urlTableFull[k] = nil
				doublesFound = doublesFound + 1
			end
			for key, value in pairs(WIKI_BLACKLIST) do		--make sure not to pass blacklisted words on.
				if v.title:lower():find(value:lower(), 1, true) then
					urlTableFull[k] = nil
					break				
				end
			end
		end
	end
	
	for k, v in pairs(urlTableFull) do
		table.insert(urlTable, v)
	end
	
	return urlTable, numberOfFoundLinks, doublesFound
end

function urlManip.log(str)
	local file = io.open("urlLog.txt", "a")
	file:write(str .. "\n")
end


-- expose interface to make it usable:
return urlManip
