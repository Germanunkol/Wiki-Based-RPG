local textBox = {}

local fields = {}

function textBox.new( xPos, yPos, newLines, newFont, newWidth )
	newText = {}
	newText.x = xPos
	newText.y = yPos
	newText.width = newWidth
	newText.font = newFont
	newText.content = ""
	newText.show = false
	newText.access = false
	newText.colour = {0,0,0}
	newText.activeLine = 1
	newText.cursorPos = 0
	newText.maxLines = newLines
	
	table.insert( fields, newText )
	return( newText )
end

function textBox.clear( text )
	text.content = "" 		-- let garbage collector do the rest
end

function textBox.setColour( text, red, green, blue )
	text.colour = { red, green, blue }
end

function textBox.width( text, newWidth)
	text.width = newWidth
end

function textBox.remove( textField )
	key = tF.findKey( textField )
	if key ~= nil then			-- if the text field was found, remove it
		fields.key = nil
	end
end

function textBox.show( textField, visibility )
	key = tF.findKey( textField )
	if key ~= nil then			-- if the text field was found, remove it
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

local function multiline( str, width, font )
	local strings = {}
	local runner = 0
	local partialStr = ""
	local i = 0
	repeat
		if font:getWidth( str:sub(runner, #str) ) > width then
			partialStr = ""
			i = 0
			while font:getWidth( partialStr ) < width do			-- will be a tiny bit longer than width...
				
				i = i + 1
			end
			if partialStr:find(" ") ~= nil then
				while partialStr[#partialStr] ~= " " do
					i = i - 1
					partialStr = str:sub( runner, runner + i )
				end
			end
			runner = runner + i
			table.insert( strings, partialStr )
		else
			table.insert( strings, str:sub(runner, #str) )
			runner = #string
		end
	
	until runner == #string
	
	return strings
end

function textBox.display(dt)
	cursorBlinkTime = cursorBlinkTime + dt
	local tbl
	local linePos
	if cursorBlinkTime > 1 then cursorBlinkTime = 0 end
	for k, v in pairs( fields ) do
		linePos = v.cursorPos
		
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.setFont( v.font )

		tbl = multiline( v.content, v.width, v.font)
		v.lines = tbl
		for k, line in pairs(tbl) do
			if linePos > #line then
				linePos = linePos - #line
			elseif cursorBlinkTime < .5 then
					love.graphics.print("|", v.x + v.font:getWidth(line:sub(1, linePos))-1, v.y + (k-1)*v.font:getHeight(""))
			end
			love.graphics.print( line, v.x, v.y + (k-1)*v.font:getHeight(""))
		end
	end
end

function textBox.input( key, unicode )
	print (unicode)
	print (key)
	for k, v in pairs( fields ) do
		if v.access == true and v.content then
			if unicode > 31 and unicode < 127 then
				print("max: " .. v.maxLines)
				print("last" .. v.lines[#v.lines])
				print("cur" .. #v.lines)
				if (v.font:getWidth(v.lines[#v.lines]) < v.width or #v.lines < v.maxLines) and #v.lines <= v.maxLines then
					v.content = v.content:sub(1, v.cursorPos) .. string.char(unicode) .. v.content:sub(v.cursorPos+1, #v.content)
					v.cursorPos = v.cursorPos + 1
				end
			elseif unicode == 8 then
				if #v.content > 0 then
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
			end
		end
	end
end


function textBox.setAccess( text, input )
	text.access = input
end

function textBox.addLine( textField, line )
	textField.content = line
end

return textBox
