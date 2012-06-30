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
	newText.hasChanged = true
	newText.maxLines = newLines
	newText.showOnlyPart = nil
	newText.colours = {}
	newText.lines = {}
	newText.cursorBlinkTime = 0
	newText.highlights = {}
	newText.highlightWords = {}
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
	if text.showOnlyPart and text.showStartLine then
		print("showing lines from " .. text.showStartLine .. " to " .. text.showOnlyPart )
	end
end

function textBox.scrollUp( text )
	if text then
		print("up " .. text.showStartLine-2)
		textBox.setVisibleLines( text, text.showStartLine-2, text.showOnlyPart )
	end
end

function textBox.scrollDown( text )
	if text then
		print("down " .. text.showStartLine)
		if text.showStartLine < #text.lines then
			textBox.setVisibleLines( text, text.showStartLine, text.showOnlyPart )
		end
	end
end

function textBox.setLineColour( text, line, red, green, blue)
	text.colours[line] = { r=red, g=green, b=blue }
end
--[[
local function splitIntoLines( text )		-- will calculate line breaks for the text
	text.lines = {}
	local partialStr = ""
	for char in text.content:gfind("([%z\1-\127\194-\244][\128-\191]*)") do		-- go through entire text
		if text.font:getWidth( partialStr .. char ) >= text.width or char == "\n" then
			text.lines[#text.lines+1] = partialStr
			partialStr = ""
		end
		if char ~= "\n" then
			partialStr = partialStr .. char
		end
	end
	if text.font:getWidth( partialStr .. char ) > text.width then 
		string.gfind(partialStr, ".* [^ ]*")
	end
	if partialStr ~= "" then
		text.lines[#text.lines+1] = partialStr
	end
	if text.lines[1] == nil then
		text.lines[1] = ""
	end
	text.hasChanged = false
end]]--


local function splitIntoLines( text )		-- will calculate line breaks for the text
	text.lines = {}
	local partialStr = ""
	
					print("length: " .. #text.content)
	local i = 1
	local lineNum, start, ending
	while i <= #text.content do
		start, ending,char = text.content:find("([%z\1-\127\194-\244][\128-\191]*)", i)
		if start then
			if text.font:getWidth( partialStr .. char ) >= text.width or char == "\n" then
				if char ~= "\n" then
					start, ending = partialStr:find( ".* " )		-- look for spaces.
					if start then		--if spaces found, cut the string there.
						i = i - (#partialStr - ending)-1
						partialStr = partialStr:sub( start, ending )
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
		i = i + #char
	end

	if partialStr ~= "" then
		text.lines[#text.lines+1] = partialStr
	end
	if text.lines[1] == nil then
		text.lines[1] = ""
	end
	text.hasChanged = false
end


function textBox.highlightText( text, word, red, green, blue )
	if #word > 0 then
		print("highlighting: " .. word)
		for k, v in pairs( text.highlightWords ) do
			if v.w == word then 
				v.r, v.g, v.b = red, green, blue
				return
			end
		end
		table.insert( text.highlightWords, { w=word, r=red, g=green, b=blue } )
	else
		text.highlightWords = {}
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
	end
end

function textBox.highlightClearAll( text )
	text.highlightWords = {}
end


function calculateHighlights( text )			-- calculate where things should be highlighted
	text.highlights = {}
	for key, highLWord in pairs(text.highlightWords) do
		local start, ending, xPos, yPos, width, height
		width = text.font:getWidth( highLWord.w )
		height = text.font:getHeight()
		local lowerCaseLine
		for i = 1, #text.lines,1 do
			yPos = text.font:getHeight()*(i-1)
			if text.lines[i] then
				lowerCaseLine = string.lower( text.lines[i] )
				start, ending = lowerCaseLine:find( string.lower(highLWord.w) )	-- Find the position of the text to highlight
				while start do
					xPos = text.font:getWidth( text.lines[i]:sub(1, start-1) )
					table.insert( text.highlights, { line=i, x=xPos, y=yPos, w=width, h=height, r=highLWord.r, g=highLWord.g, b=highLWord.b} )
					start, ending = lowerCaseLine:find( string.lower(highLWord.w), start+1 )	--find pos of next word.
				end
			end
		end
	end
end


local function correctCursorPos( text )
	if text.cursorPos < 0 then
		if text.cursorLine > 1 then
			text.cursorLine = text.cursorLine - 1
			text.cursorPos = #text.lines[text.cursorLine] - 1		--move to the end of previous line
		else
			text.cursorPos = 0
		end
	elseif text.lines[text.cursorLine] then
		if text.cursorPos > #text.lines[text.cursorLine] then
			if text.lines[text.cursorLine+1] then
				text.cursorPos = text.cursorPos-#text.lines[text.cursorLine]
				text.cursorLine = text.cursorLine + 1
				
			else
				text.cursorPos = #text.lines[text.cursorLine]
			end
		end
	else
		while text.lines[text.cursorLine] == nil do
			text.cursorLine = text.cursorLine - 1
		end
		if text.lines[text.cursorLine] then
			text.cursorPos = #text.lines[text.cursorLine]
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
		if #text.highlightWords > 0 then
			calculateHighlights( text )
		end
	end
	
	love.graphics.setFont( text.font )
	love.graphics.setColor( text.colour.r, text.colour.g, text.colour.b )
	
	if text.showOnlyPart == nil then
		for k, highL in pairs( text.highlights ) do		-- go through all highlights and show them as rectangles in the background.
			love.graphics.setColor( highL.r, highL.g, highL.b )
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
			love.graphics.print("|", text.x + text.font:getWidth(text.lines[text.cursorLine]:sub(1, text.cursorPos))-1, text.y + (text.cursorLine-1)*text.font:getHeight())
		end
	else	-- this is called if part of the text is hidden because there are more lines than can be displayed (scrollable text)
		for k, highL in pairs( text.highlights ) do		-- go through all highlights and show them as rectangles in the background.
			if highL.line >= text.showStartLine and highL.line <= text.showOnlyPart+text.showStartLine then
				love.graphics.setColor( highL.r, highL.g, highL.b )
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
						absCursorPos = absCursorPos + #v.lines[i]
					end
					absCursorPos = absCursorPos + v.cursorPos
					v.content = v.content:sub(1, absCursorPos) .. string.char(unicode) .. v.content:sub(absCursorPos+1, #v.content)
					v.cursorPos = v.cursorPos + 1
				end
			elseif unicode == 8 then
				absCursorPos = 0
				for i = 1,v.cursorLine-1,1 do
					absCursorPos = absCursorPos + #v.lines[i]
				end
				absCursorPos = absCursorPos + v.cursorPos
				if #v.content:sub(1, absCursorPos) > 0 then
					v.content = v.content:sub(1, absCursorPos-1) .. v.content:sub(absCursorPos+1, #v.content)
					v.cursorPos = v.cursorPos-1
					v.cursorBlinkTime = 0
				end
			elseif key == "left" then
				v.cursorPos = v.cursorPos - 1
				v.cursorBlinkTime = 0
			elseif key == "right" then
				v.cursorPos = v.cursorPos + 1
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
					absCursorPos = absCursorPos + #v.lines[i]
				end
				absCursorPos = absCursorPos + v.cursorPos
				v.cursorBlinkTime = 0
				if #v.content > 0 then
					v.content = v.content:sub(1, absCursorPos) .. v.content:sub(absCursorPos+2, #v.content)
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
				if curGameWord and #curGameWord > 0 then
					if (v.font:getWidth(v.lines[#v.lines] .. curGameWord) < v.width or #v.lines < v.maxLines) and #v.lines <= v.maxLines then
						absCursorPos = 0
						for i = 1,v.cursorLine-1,1 do
							absCursorPos = absCursorPos + #v.lines[i]
						end
						absCursorPos = absCursorPos + v.cursorPos
						v.content = v.content:sub(1, absCursorPos) .. curGameWord .. v.content:sub(absCursorPos+1, #v.content)
						v.cursorPos = v.cursorPos + #curGameWord
					end
				end
			end
			--splitIntoLines( v )
			--correctCursorPos( v )
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

function textBox.setAccess( text, input, resetCursor )
	text.access = input
	if resetCursor then
		text.cursorPos = 0
		text.cursorLine = 1
	end
end

function textBox.getAccess( text )
	return text.access
end

function textBox.setContent( textField, line )
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
