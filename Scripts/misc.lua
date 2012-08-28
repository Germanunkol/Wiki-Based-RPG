function sleep(seconds)
  local start = os.time()
  repeat until os.time() > start + seconds
end

function drawButton( theButton )
	love.graphics.setColor( colLobby.r,colLobby.g,colLobby.b , 100)
	--love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
	--love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 150)
	love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b, 255)
	love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2)
end

function highlightButton( theButton )
	--love.graphics.setColor( 0, 0, 0 , 255)
	--love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.b, 100)
	love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b, 255)
	love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2 )
end

function drawPixel( theButton )
	if avatar[theButton.label] == 0 then		-- the button's label stores the button ID
		love.graphics.setColor( colCharB.r, colCharB.g, colCharB.b, 255)
	elseif avatar[theButton.label] == 1 then		-- the button's label stores the button ID
		love.graphics.setColor( colCharM.r, colCharM.g, colCharM.b, 255)
	else
		love.graphics.setColor( colCharD.r, colCharD.g, colCharD.b, 255)
	end
	love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
end

function highlightPixel( theButton )
	if client and clientReady == true then
		drawPixel( theButton )
		return
	end
	love.graphics.setColor( 0,0,0, 255)
	love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h)
	if avatar[theButton.label] == 0 then		-- the button's label stores the button ID
		love.graphics.setColor( colCharB.r, colCharB.g, colCharB.b, 255)
	elseif avatar[theButton.label] == 1 then		-- the button's label stores the button ID
		love.graphics.setColor( colCharM.r, colCharM.g, colCharM.b, 255)
	else
		love.graphics.setColor( colCharD.r, colCharD.g, colCharD.b, 255)
	end
	love.graphics.rectangle( "fill", theButton.x+2, theButton.y+2, theButton.w-4, theButton.h-4)
end

function switchPixel( ID )
	if client and clientReady == true then
		statusMsg.new( ERROR_AVATAR_CANNOT_CHANGE_STR )
		return
	end
	avatar[ID] = avatar[ID] + 1
	if avatar[ID] == 3 then
		avatar[ID] = 0
	end
end

function statPixel( theButton )
	if statistics[theButton.label] == 1 then		-- the button's label stores the button ID
		love.graphics.setColor( colCharM.r, colCharM.g, colCharM.b, 255)
	else
		love.graphics.setColor( colCharB.r, colCharB.g, colCharB.b, 255)
	end
	love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
end

function changeStat( ID )
	if client and clientReady == true then
		statusMsg.new("Cannot change statistics while you're \"ready\".")
		return
	end
	print("setStatistics")
	printTable(setStatistics)
	statPointsUsed = 0
	local numAbilities = 0
	local line = (ID - 1 - (ID-1) % 5)/5
	-- per ability, there is a set number of points that are added to the total number of available stat points. (MAX_STATPOINTS_PER_ABILITY)
	--
	for k, v in pairs(abilities) do
		print(k, v, line)
		if setStatistics[k] and k ~= line then
			statPointsUsed = statPointsUsed + setStatistics[k]
		end
		numAbilities = numAbilities + 1
	end
	
	local before = ID % 5
	local after = 5 - ID % 5
	
	if before == 0 then
		before = 5
		after = 0
	end
	
	if statPointsUsed + before > MAX_STATPOINTS_PER_ABILITY*numAbilities then
		return
	end
	
	local i = 0
	while i < before do
		statistics[ID-i] = 1
		i = i + 1
	end
	
	i = 1
	while i < after + 1 do
		statistics[ID+i] = 0
		i = i + 1
	end
	
	setStatistics[line] = before
end

function statHighlightPixel( theButton )
	if client and clientReady == true then
		drawPixel( theButton )
		return
	end
	love.graphics.setColor( 0,0,0, 255)
	love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h)
	if statistics[theButton.label] == 0 then		-- the button's label stores the button ID
		love.graphics.setColor( colCharB.r, colCharB.g, colCharB.b, 255)
	elseif statistics[theButton.label] == 1 then		-- the button's label stores the button ID
		love.graphics.setColor( colCharM.r, colCharM.g, colCharM.b, 255)
	else
		love.graphics.setColor( colCharD.r, colCharD.g, colCharD.b, 255)
	end
	love.graphics.rectangle( "fill", theButton.x+2, theButton.y+2, theButton.w-4, theButton.h-4)
end


function getClientColour( ID )
	if ID == 1 then
		return 255,0,0
	elseif ID == 2 then
		return 255,255,0
	elseif ID == 3 then
		return 0,0,255
	elseif ID == 4 then
		return 0,255,255
	end
	return 0,0,0		-- fallback
end

function printTable( t, tabs )
	tabs = tabs or 0
	for k, v in pairs(t) do
		str = ""
		for i=0,tabs,1 do str = str .. " " end
		if type(v) == "table" then
			print(str .. k)
			printTable( v, tabs + 1)
		else
			if type(v) == "string" or type(v) == "number" then
				print(str .. k .. " " ..  v)
			else
				print(str .. k)
			end
		end
	end
end

function strLen( str )
	local i, len = str:gsub("([%z\1-\127\194-\244])", "")
	return len
end

function safeSub(str, from, to)
	local i = 1
	tmpStr = ""
	if to == 0 then return("") end
	for char in str:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- make sure button title isn't larger than button
		if i >= from then 
			tmpStr = tmpStr .. char
		end
		if i == to then break end
		i = i + 1
	end
	return tmpStr
end

--function stringWidth( str, font )
	--[[local tmpStr = ""
	for char in str:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- make sure button title isn't larger than button
		tmpStr = tmpStr .. char
	end]]--
	--return( font:getWidth( str ) )
--end

function stringFind( str, pattern, start )
	start = start or 1
	local i = 1
	local a,b,firstChar = pattern:find("([%z\1-\127\194-\244][\128-\191]*)")
	local length = strLen( pattern )
	local testStr = ""
	--print("firstChar: " .. firstChar)
	for char in str:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- make sure button title isn't larger than button
		if i >= start then
			--print("i has passed start: " .. i)
			--print("char: " .. char)
			if char == firstChar then
				--print("current char is first char:" .. i)
				testStr = safeSub( str, i, i + length-1 )
				--print("testStr" .. testStr, pattern)
				if testStr == pattern then
					return i, i + length - 1
				end
			end
		end
		i = i+1
	end
	return nil
end
