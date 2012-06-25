local textBox = {}

local fields = {}

function textBox.new( xPos, yPos, newLines, newFont, newWidth )
	newText = {}
	newText.x = xPos
	newText.y = yPos
	newText.width = newWidth
	newText.font = newFont
	newText.content = ""
	newText.show = true
	newText.access = false
	newText.colour = {r=0,g=0,b=0}
	newText.activeLine = 1
	newText.cursorPos = 0
	newText.hasChanged = true
	newText.maxLines = newLines
	newText.colours = {}	

	table.insert( fields, newText )
	return( newText )
end

function textBox.clear( text )
	text.content = "" 		-- let garbage collector do the rest
	newText.hasChanged = true
end

function textBox.setColour( text, red, green, blue )
	text.colour = { r=red, g=green, b=blue }
	text.colours = {}		--reset all colours
end

function textBox.setColourStart( text, from, red, green, blue )
	text.colours[from] = {r=red, g=green, b=blue }
	text.hasChanged = true
end

function textBox.getNextColourStart( text, startPos, endPos)
	local result, red, green, blue
	result = #text.content + 1
	for k, col in pairs(text.colours) do
		if k > startPos and k < result and k <= endPos then
			result = k
			red,green,blue = col.r, col.g, col.b
		end
	end
	if result ~= #text.content+1 then
		return result, red, green, blue
	else
		return nil
	end
end

function textBox.width( text, newWidth)
	text.width = newWidth
end

function textBox.remove( textField )
	key = textBox.findKey( textField )

	if key ~= nil then			-- if the text field was found, remove it
		fields[key] = nil
	end
	
	return fields[key]
end

function textBox.show( textField, visibility )
	key = tF.findKey( textField )
	if key ~= nil then
		if visibility then
			textField.show = true
		else
			textField.show = false
		end
	end
end

function textBox.findKey( textField )
	for k, v in pairs( fields ) do
		if v == textField then
			return k
		end
	end
	return nil
end

local cursorBlinkTime = 0

local function multiline( text, width, font )
	local str = text.content
	local lines = {}
	local colouredStrings = {}
	local runner = 0
	local partialStr = ""
	local i = 0
	local posOfLastSpace
	local lineRunner
	local beginningOfLine
	local lineID = 0
	local newRed, newGreen, newBlue = text.colour.r, text.colour.g, text.colour.b
	local curRed, curGreen, curBlue = text.colour.r, text.colour.g, text.colour.b
	local xOffset = 0
	repeat
		local strings = {}
		beginningOfLine = runner
		lineID = lineID + 1
		--strings = {full=""}
		table.insert( lines, strings )		-- each line holds multiple, coloured strings, plus one called "full" with the full line.
		if font:getWidth( str:sub(runner, #str) ) > width then
			partialStr = ""
			i = 0
			for char in str:gfind("([%z\1-\127\194-\244][\128-\191]*)", runner) do
				partialStr = partialStr .. char
				if font:getWidth( partialStr ) >= width or char == "\n" then
					 break
				end
				i = i + 1
			end
			
			posOfLastSpace = partialStr:match(".*() ")
			if posOfLastSpace ~= nil then
				partialStr = str:sub( runner, runner + posOfLastSpace)
				runner = runner + posOfLastSpace		-- +1 to get rid of space
			else
				runner = runner + i
			end
			strings.full = partialStr

			--table.insert( colouredStrings, { s=partialStr, x=0, r=math.random(255), g=128, b= 128 }
			--table.insert( colouredStrings,  )
		else
			strings.full = str:sub(runner, #str)
			--table.insert( lines, { full= })
			--table.insert( colouredStrings, { s=str:sub(runner, #str), x=0, r=math.random(255), g=128, b= 128 })
			runner = #str + 1
		end

		lineRunner = 0
		strID = 0
		xOffset = 0
		while lineRunner <= #strings.full do		-- go through the entire new line
			start, newRed, newGreen, newBlue = textBox.getNextColourStart( text, beginningOfLine+lineRunner,beginningOfLine+#strings.full )
			if start then
				strings[strID] = {s=strings.full:sub(lineRunner, start-1-beginningOfLine), r=curRed, g=curGreen,b=curBlue, x=xOffset }
				lineRunner = start-beginningOfLine
				xOffset = xOffset + font:getWidth(strings[strID].s)
			else
				--print("#strings.full@ " ..  #strings.full)
				strings[strID] = {s=strings.full:sub(lineRunner, #strings.full), r=curRed, g=curGreen,b=curBlue,x=xOffset}
				lineRunner = #strings.full + 1
			end
			if start then curRed,curGreen,curBlue = newRed,newGreen,newBlue end
			strID = strID + 1
		end
		--[[
		print("printing strings:")
		for k, v in pairs(strings) do
			if k == "full" then print(k .. ": " .. v)
			else print(k .. ": " .. v.s)
			end
		end]]--
	until runner > #str
	
	return lines
end

function textBox.display()
	cursorBlinkTime = cursorBlinkTime + love.timer.getDelta()
	local linePos
	if cursorBlinkTime > 1 then cursorBlinkTime = 0 end
	for key, v in pairs( fields ) do
		linePos = v.cursorPos
		
		love.graphics.setColor( v.colour.r, v.colour.g, v.colour.b )
		love.graphics.setFont( v.font )

		if v.hasChanged then
			v.lines = multiline( v, v.width, v.font)
			v.hasChanged = false
		end
		for k, line in pairs(v.lines) do
			if v.access then
				if linePos > #line.full then
					linePos = linePos - #line.full
				elseif cursorBlinkTime < .5 then
					love.graphics.print("|", v.x + v.font:getWidth(line.full:sub(1, linePos))-1, v.y + (k-1)*v.font:getHeight())
				end
			end
			--love.graphics.print( line.full, v.x, v.y + (k-1)*v.font:getHeight())
		end
		for k, line in pairs( v.lines ) do
			for id, linePart in pairs( line ) do
				if id ~= "full" then
					love.graphics.setColor( linePart.r, linePart.g, linePart.b, 255 )
					love.graphics.print( linePart.s, v.x + linePart.x, v.y + (k-1)*v.font:getHeight())
				else
--					print( linePart)
				end
			end
		end
	end
end

function textBox.input( key, unicode )
	for k, v in pairs( fields ) do
		if v.access == true and v.content then			
			v.hasChanged = true
			if unicode > 31 and unicode < 127 then
				if (v.font:getWidth(v.lines[#v.lines].full .. string.char(unicode)) < v.width or #v.lines < v.maxLines) and #v.lines <= v.maxLines then
					v.content = v.content:sub(1, v.cursorPos) .. string.char(unicode) .. v.content:sub(v.cursorPos+1, #v.content)
					v.cursorPos = v.cursorPos + 1
				end
			elseif unicode == 8 then
				if #v.content:sub(1, v.cursorPos) > 0 then
					v.content = v.content:sub(1, v.cursorPos-1) .. v.content:sub(v.cursorPos+1, #v.content)
					v.cursorPos = v.cursorPos-1
					cursorBlinkTime = 0
				end
			elseif key == "left" then
				v.cursorPos = math.max(v.cursorPos - 1, 0)
				cursorBlinkTime = 0
			elseif key == "right" then
				v.cursorPos = math.min(v.cursorPos + 1, #v.content)
				cursorBlinkTime = 0
			elseif key == "end" then
				v.cursorPos = #v.content
				cursorBlinkTime = 0
			elseif key == "home" then
				v.cursorPos = 0
				cursorBlinkTime = 0
			elseif key == "delete" then
				cursorBlinkTime = 0
				if #v.content > 0 then
					v.content = v.content:sub(1, v.cursorPos) .. v.content:sub(v.cursorPos+2, #v.content)
				end
			elseif key == "return" then
				v.access = false
				if v.returnEvent then
					v.returnEvent()
					break			-- only allow one textBox to be terminated per Enter-Key-Pressed.
				end
			end
		end
	end
end

function textBox.setReturnEvent( text, event )
	text.returnEvent = event
end

function textBox.getContent( text )
	return text.content
end

function textBox.setAccess( text, input, resetCursor )
	text.access = input
	if resetCursor then
		text.cursorPos = 0
	end
end

function textBox.setContent( textField, line )
	textField.content = line
	textField.hasChanged = true
end

return textBox
