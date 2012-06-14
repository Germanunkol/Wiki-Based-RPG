local textBox = {}

local fields = {}

function textBox.new( xPos, yPos, newLines, newFont, newWidth )
	newField = {}
	newField.x = xPos
	newField.y = yPos
	newField.width = newWidth
	newField.lines = newLines
	newField.font = newFont
	newField.text = {}
	newField.show = false
	newField.access = false
	
	table.insert( fields, newField )
	return( newField )
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

function textBox.display()
	for k, v in pairs( fields ) do
		for index, line in pairs( v.text ) do
			love.graphics.setFont( v.font )
			love.graphics.setColor( 0, 0, 0 )
			love.graphics.print( line, v.x, v.y + v.font:getHeight()*(index - 1) )
		end
	end
end

function textBox.addLine( textField, line )
	if textField.lines > #textField.text then
		table.insert( textField.text, line )
		print( line)
	end
end

return textBox
