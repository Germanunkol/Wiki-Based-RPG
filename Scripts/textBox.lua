local textBox = {}

local fields = {}

function textBox.new( xPos, yPos, newLines, newFont, newWidth )
	newText = {}
	newText.x = xPos
	newText.y = yPos
	newText.width = newWidth
	newText.font = newFont
	newText.show = true
	newText.access = false
	newText.colour = {r=0,g=0,b=0}
	newText.activeLine = 1
	newText.cursorPos = 1
	newText.cursorLine = 1
	newText.cursorXPos = 0
	newText.hasChanged = true
	newText.maxLines = newLines
	newText.showOnlyPart = nil
	newText.colours = {}
	newText.lines = {}
	newText.cursorBlinkTime = 0
	newText.highlights = {}
	newText.highlightWords = {}
	newText.highlightNames = {}
	newText.showStartLine = 1

	table.insert( fields, newText )
	textBox.setContent( newText, "" )
	return( newText )
end

-- after the following function is called, only "num" lines from text will be displayed, starting at "from".
-- mutually inclusive with input access! do not use when there will be keyboard access to the textbox.
function textBox.setVisibleLines( text, from, num )
	text.showStartLine = math.max(from+1, 1)
	text.showOnlyPart = num
end

function textBox.scrollUp( text )
	if text then
		textBox.setVisibleLines( text, text.showStartLine-2, text.showOnlyPart )
	end
end

function textBox.scrollDown( text )
	if text then
		if text.showStartLine < #text.lines then
			textBox.setVisibleLines( text, text.showStartLine, text.showOnlyPart )
		end
	end
end

function textBox.setLineColour( text, line, red, green, blue)
	text.colours[line] = { r=red, g=green, b=blue }
end

local function splitIntoLines( text )		-- will calculate line breaks for the text
	text.lines = {}
	local partialStr = ""
	local i = 1
	local lineNum, start, ending
	while i <= #text.content do
		start, ending,char = text.content:find("([%z\1-\127\194-\244][\128-\191]*)", i)
		if start then
			if text.font:getWidth( partialStr .. char ) >= text.width or char == "\n" then
				if char ~= "\n" then
					local startFound = nil
					start, ending = stringFind(partialStr, " ", startNew )		-- look for spaces.
					while start do
						startFound, endingFound = start, ending
						start, ending = stringFind(partialStr, " ", start+1 )		-- look for spaces.
					end
					if startFound then		-- if spaces found, cut the string there.
						
						tmpStr = safeSub( partialStr, startFound, strLen(partialStr))
						i = i - #tmpStr
						--i = i - (strLen(partialStr) - endingFound)-1
						partialStr = safeSub(partialStr, 1, startFound )
						char = ""
					end
				end
				text.lines[#text.lines+1] = partialStr
				partialStr = ""
			end
			if char ~= "\n" then
				partialStr = partialStr .. char
			end
		end
		i = i + math.max( #char, 1)
	end

	if partialStr ~= "" then
		text.lines[#text.lines+1] = partialStr
	end
	if text.lines[1] == nil then
		text.lines[1] = ""
	end
	text.hasChanged = false
end


function textBox.highlightText( text, word, red, green, blue, alpha )
	if #word > 0 then
		for k, v in pairs( text.highlightWords ) do
			if v.w == word then 
				v.r, v.g, v.b, v.a = red, green, blue, alpha or 255
				return
			end
		end
		table.insert( text.highlightWords, { w=word, r=red, g=green, b=blue, a=alpha or 255 } )
	else
		text.highlightWords = {}
	end
end
		-- must differentiate between names and other highlighted words, because only those which are not names will be highlighted in exported files.
function textBox.highlightTextName( text, word, red, green, blue, alpha )
	if #word > 0 then
		for k, v in pairs( text.highlightNames ) do
			if v.w == word then 
				v.r, v.g, v.b, v.a = red, green, blue, alpha or 255
				return
			end
		end
		table.insert( text.highlightNames, { w=word, r=red, g=green, b=blue, a=alpha or 255 } )
	else
		text.highlightNames = {}
	end
end

function textBox.removeHighlight( text, word )
	if #word > 0 then
		for k, v in pairs( text.highlightWords ) do
			if v.w == word then 
				text.highlightWords[k] = nil
				return
			end
		end
		for k, v in pairs( text.highlightNames ) do
			if v.w == word then 
				text.highlightNames[k] = nil
				return
			end
		end
	end
end

function textBox.highlightClearAll( text )
	text.highlightWords = {}
	text.highlightNames = {}
end


function calculateHighlights( text )			-- calculate where things should be highlighted
	text.highlights = {}
	local start, ending, xPos, yPos, width, height
	for key, highLWord in pairs(text.highlightWords) do
		width = text.font:getWidth( highLWord.w )
		height = text.font:getHeight()
		local lowerCaseLine
		for i = 1, #text.lines,1 do
			yPos = text.font:getHeight()*(i-1)
			if text.lines[i] then
				lowerCaseLine = string.lower( text.lines[i] )
				start, ending = stringFind(lowerCaseLine, string.lower(highLWord.w), 1 )	-- Find the position of the text to highlight
				while start do
					xPos = text.font:getWidth( safeSub(text.lines[i], 1, start-1) )
					table.insert( text.highlights, { line=i, x=xPos, y=yPos, w=width, h=height, r=highLWord.r, g=highLWord.g, b=highLWord.b, a=highLWord.a} )
					start, ending = stringFind(lowerCaseLine, string.lower(highLWord.w), start+1 )	--find pos of next word.
				end
			end
		end
	end
	for key, highLWord in pairs(text.highlightNames) do
		width = text.font:getWidth( highLWord.w )
		height = text.font:getHeight()
		local lowerCaseLine
		for i = 1, #text.lines,1 do
			yPos = text.font:getHeight()*(i-1)
			if text.lines[i] then
				lowerCaseLine = string.lower( text.lines[i] )
				start, ending = stringFind(lowerCaseLine, string.lower(highLWord.w), 1 )	-- Find the position of the text to highlight
				while start do
					xPos = text.font:getWidth( safeSub(text.lines[i], 1, start-1) )
					table.insert( text.highlights, { line=i, x=xPos, y=yPos, w=width, h=height, r=highLWord.r, g=highLWord.g, b=highLWord.b, a=highLWord.a} )
					start, ending = stringFind(lowerCaseLine, string.lower(highLWord.w), start+1 )	--find pos of next word.
				end
			end
		end
	end
end


local function correctCursorPos( text )
	if text.cursorPos < 0 then
		if text.cursorLine > 1 then
			text.cursorLine = text.cursorLine - 1
			text.cursorPos = strLen(text.lines[text.cursorLine]) - 1		--move to the end of previous line
		else
			text.cursorPos = 0
		end
	elseif text.lines[text.cursorLine] then
		if text.cursorPos > strLen(text.lines[text.cursorLine]) then
			if text.lines[text.cursorLine+1] then
				text.cursorPos = text.cursorPos-strLen(text.lines[text.cursorLine])
				text.cursorLine = text.cursorLine + 1
				
			else
				text.cursorPos = strLen(text.lines[text.cursorLine])
			end
		end
	else
		while text.lines[text.cursorLine] == nil do
			text.cursorLine = text.cursorLine - 1
		end
		if text.lines[text.cursorLine] then
			text.cursorPos = strLen(text.lines[text.cursorLine])
		end
	end
end

function textBox.display( text )
	if not text then return end
	
	text.cursorBlinkTime = text.cursorBlinkTime + love.timer.getDelta()
	if text.cursorBlinkTime > 1 then text.cursorBlinkTime = 0 end

	if text.hasChanged then
		splitIntoLines( text )
		correctCursorPos( text )
		if #text.highlightWords > 0 or #text.highlightNames > 0 then
			calculateHighlights( text )
		end
	end
	
	love.graphics.setFont( text.font )
	love.graphics.setColor( text.colour.r, text.colour.g, text.colour.b )
	
	if text.showOnlyPart == nil then
		for k, highL in pairs( text.highlights ) do		-- go through all highlights and show them as rectangles in the background.
			love.graphics.setColor( highL.r, highL.g, highL.b, highL.a )
			love.graphics.rectangle( "fill", text.x + highL.x, text.y + highL.y, highL.w, highL.h )
		end
		love.graphics.setColor( text.colour.r, text.colour.g, text.colour.b )
	
		for i = 1,#text.lines,1 do
			if text.colours[i] then
				love.graphics.setColor( text.colours[i].r, text.colours[i].g, text.colours[i].b )
			end
			love.graphics.print( text.lines[i], text.x, text.y + text.font:getHeight()*(i-1) )
		end

	
		if text.access == true and text.cursorBlinkTime < .5 and text.lines[text.cursorLine] then
			--print(safeSub(text.lines[text.cursorLine], 1, text.cursorPos))
			love.graphics.print("|", text.x + text.font:getWidth(safeSub(text.lines[text.cursorLine], 1, text.cursorPos))-1, text.y + (text.cursorLine-1)*text.font:getHeight())
		end
	else	-- this is called if part of the text is hidden because there are more lines than can be displayed (scrollable text)
		for k, highL in pairs( text.highlights ) do		-- go through all highlights and show them as rectangles in the background.
			if highL.line >= text.showStartLine and highL.line <= text.showOnlyPart+text.showStartLine then
				love.graphics.setColor( highL.r, highL.g, highL.b, highL.a )
				love.graphics.rectangle( "fill", text.x + highL.x, text.y + highL.y-(text.showStartLine-1)*highL.h, highL.w, highL.h )
			end
		end
		love.graphics.setColor( text.colour.r, text.colour.g, text.colour.b )
		for i = text.showStartLine,text.showOnlyPart+text.showStartLine,1 do		--display lines between showStartLine and showOnlyPart
			if text.lines[i] then
				if text.colours[i] then
					love.graphics.setColor( text.colours[i].r, text.colours[i].g, text.colours[i].b )
				end
				love.graphics.print( text.lines[i], text.x, text.y + text.font:getHeight()*(i-text.showStartLine) )
			end
		end
	end
	
	--love.graphics.print( text.cursorPos, text.x + 200 , text.y )
	--love.graphics.print( text.cursorLine, text.x + 200 , text.y + text.font:getHeight())
end


local absCursorPos
local inputUsed 		-- true, if input was put into some text box.

function textBox.moveCursorToEnd( text )
	if text.lines[text.cursorLine] then
		text.cursorPos = #text.lines[text.cursorLine]
	end
	text.cursorBlinkTime = 0
end

function textBox.input( key, unicode )
	inputUsed = false
	for k, v in pairs( fields ) do
		if v.access == true and v.content then
			inputUsed = true			
			v.hasChanged = true
			if unicode > 31 and unicode < 127 then
				if (v.font:getWidth(v.lines[#v.lines] .. string.char(unicode)) < v.width or #v.lines < v.maxLines) and #v.lines <= v.maxLines then
					absCursorPos = 0
					for i = 1,v.cursorLine-1,1 do
						absCursorPos = absCursorPos + strLen(v.lines[i])
					end
					absCursorPos = absCursorPos + v.cursorPos
					v.content = safeSub(v.content, 1, absCursorPos) .. string.char(unicode) .. safeSub(v.content, absCursorPos+1, strLen(v.content))
					v.cursorPos = v.cursorPos + 1
				end
			elseif unicode == 8 then			-- backspace
				absCursorPos = 0
				for i = 1,v.cursorLine-1,1 do
					absCursorPos = absCursorPos + strLen(v.lines[i])
				end
				absCursorPos = absCursorPos + v.cursorPos
				if strLen(safeSub(v.content, 1, absCursorPos)) > 0 then
					local front = safeSub(v.content, 1, absCursorPos-1)
					local back = safeSub(v.content, absCursorPos+1, strLen(v.content))
--					v.content = safeSub(v.content, 1, absCursorPos-1) .. safeSub(v.content, absCursorPos+1, #v.content)
					v.content = front .. back
					
					v.cursorPos = v.cursorPos-1
					v.cursorBlinkTime = 0
				end
			elseif key == "left" then
				v.cursorPos = v.cursorPos - 1
				v.cursorBlinkTime = 0
			elseif key == "right" then
				v.cursorPos = v.cursorPos + 1
				v.cursorBlinkTime = 0
			elseif key == "up" then
				if v.cursorLine > 1 then v.cursorLine = v.cursorLine - 1 end
				v.cursorBlinkTime = 0
			elseif key == "down" then
				if v.cursorLine < v.maxLines then v.cursorLine = v.cursorLine + 1 end
				v.cursorBlinkTime = 0
			elseif key == "end" then
				if v.lines[v.cursorLine] then
					v.cursorPos = #v.lines[v.cursorLine]
				end
				v.cursorBlinkTime = 0
			elseif key == "home" then
				v.cursorPos = 0
				v.cursorBlinkTime = 0
			elseif key == "delete" then
				absCursorPos = 0
				for i = 1,v.cursorLine-1,1 do
					absCursorPos = absCursorPos + strLen(v.lines[i])
				end
				absCursorPos = absCursorPos + v.cursorPos
				v.cursorBlinkTime = 0
				if #v.content > 0 then
					v.content = safeSub(v.content, 1, absCursorPos) .. safeSub(v.content, absCursorPos+2, strLen(v.content))
				end
			elseif key == "return" then
				v.access = false
				if v.returnEvent then
					v.returnEvent()
					break			-- only allow one textBox to be terminated per Enter-Key-Pressed.
				end
			elseif key == "escape" then
				if v.escapeEvent then
					v.access = false
					v.escapeEvent()
					break			-- only allow one textBox to be terminated per ESC-Key-Pressed.
				end
			elseif key == "tab" then

				if lobby.active() and descriptionWord and #descriptionWord > 0 then
					if (v.font:getWidth(v.lines[#v.lines] .. curGameWord) < v.width or #v.lines < v.maxLines) and #v.lines <= v.maxLines then
						absCursorPos = 0
						for i = 1,v.cursorLine-1,1 do
							absCursorPos = absCursorPos + strLen(v.lines[i])
						end
						absCursorPos = absCursorPos + v.cursorPos
						v.content = safeSub(v.content, 1, absCursorPos) .. descriptionWord .. safeSub(v.content, absCursorPos+1, strLen(v.content))
						v.cursorPos = v.cursorPos + strLen(descriptionWord)
					end
				elseif curGameWord and #curGameWord > 0 then
					if (v.font:getWidth(v.lines[#v.lines] .. curGameWord) < v.width or #v.lines < v.maxLines) and #v.lines <= v.maxLines then
						absCursorPos = 0
						for i = 1,v.cursorLine-1,1 do
							absCursorPos = absCursorPos + strLen(v.lines[i])
						end
						absCursorPos = absCursorPos + v.cursorPos
						v.content = safeSub(v.content, 1, absCursorPos) .. curGameWord .. safeSub(v.content, absCursorPos+1, strLen(v.content))
						v.cursorPos = v.cursorPos + strLen(curGameWord)
					end
				end
			else
				if SPECIAL_CHARACTERS[unicode] then
					if (v.font:getWidth(v.lines[#v.lines] .. SPECIAL_CHARACTERS[unicode]) < v.width or #v.lines < v.maxLines) and #v.lines <= v.maxLines then
						absCursorPos = 0
						for i = 1,v.cursorLine-1,1 do
							absCursorPos = absCursorPos + strLen(v.lines[i])
						end
						absCursorPos = absCursorPos + v.cursorPos
						v.content = safeSub(v.content, 1, absCursorPos) .. SPECIAL_CHARACTERS[unicode] .. safeSub(v.content, absCursorPos+1, strLen(v.content))
						v.cursorPos = v.cursorPos + 1
					end
				end
			end
			--splitIntoLines( v )
			--correctCursorPos( v )
			print(v.content)
		end
	end
	return inputUsed
end

function textBox.clear( text )
	text.content = "" 		-- let garbage collector do the rest
	newText.hasChanged = true
end

function textBox.setColourStart( text, from, red, green, blue )
	text.colours[from] = {r=red, g=green, b=blue }
	text.hasChanged = true
end
function textBox.setColour( text, red, green, blue )
	text.colour = { r=red, g=green, b=blue }
	text.colours = {}		--reset all colours
end

function textBox.setReturnEvent( text, event )
	text.returnEvent = event
end
function textBox.setEscapeEvent( text, event )
	text.escapeEvent = event
end


function textBox.numLines( text )
	if #text.lines > 1 then
		return #text.lines
	else
		if text.lines[1] ~= "" then
			return 1
		else
			return 0
		end
	end
end

function textBox.setAccess( text, input, resetCursor, endCursor )
	text.access = input
	if resetCursor then
		text.cursorPos = 0
		text.cursorLine = 1
	end
	if endCursor then
		text.cursorPos = #text.content
	end
end

function textBox.getAccess( text )
	return text.access
end

function textBox.handleClick()
	for k, text in pairs( fields ) do
		if text.access == true and text.content then			-- loop through all text boxes that have access enabled (you can type in them)
			local x, y = love.mouse.getPosition()
			print("5")
			if x >= text.x and x <= text.x+text.width and y >= text.y and y <= text.y+text.maxLines*text.font:getHeight() then
			print("6")
				local deltaY, deltaX = y - text.y, x - text.x
				local lineNum = math.floor( deltaY/text.font:getHeight() )
				text.cursorLine = math.max(math.min( lineNum+1, text.maxLines, #text.lines ), 1)
				text.cursorBlinkTime = 0
				text.cursorPos = 0
				local tmpStr = ""
				print("7")
				if text.lines[text.cursorLine] then
					for char in text.lines[text.cursorLine]:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- make sure button title isn't larger than button
					print("8")
						print("char:", char)
						if text.font:getWidth( tmpStr .. char ) - text.font:getWidth( char )/2 <= deltaX then 
							text.cursorPos = text.cursorPos + 1
							tmpStr = tmpStr .. char
						else
							break
						end
					end
					print("9")
				end
				print("10")
			end
		end
		print("line:", text.cursorLine, text.cursorPos)
	end
	print("11")
end

function textBox.setContent( textField, line )
	if textField == exportText then
		print("export field received: '" .. line .. "'")
	end
	textField.content = line
	textField.hasChanged = true
--	splitIntoLines( textField )
	return #textField.lines
end

function textBox.getContent( text )
	return text.content
end

function textBox.getFont( text )
	return text.font
end

function textBox.findKey( textField )
	for k, v in pairs( fields ) do
		if v == textField then
			return k
		end
	end
	return nil
end
function textBox.remove( textField )
	key = textBox.findKey( textField )

	if key ~= nil then			-- if the text field was found, remove it
		fields[key] = nil
	end
	
	return fields[key]
end

return textBox
