local button = {}

local buttons = {}

function button.clear()
	for k, v in pairs(buttons) do
		if v.label ~= "Help" then
			buttons[k] = nil
		end
	end
end

function button.add( newX, newY, newWidth, newHeight, newLabel, functionOff, functionHover, newEvent, newArgument )
	local newButton = {}
	newButton.x = newX
	newButton.y = newY
	newButton.label = newLabel
	newButton.centered = isCentered
	newButton.w = newWidth
	newButton.h = newHeight
	newButton.drawNormal = functionOff
	newButton.drawHover = functionHover
	newButton.event = newEvent
	newButton.argument = newArgument 	-- passed to event
	table.insert( buttons, newButton )
end


function button.debug()
print("debugging buttons: ")
	for key, button in pairs( buttons ) do
		print(button)
		print(button.label)
		print(button.x)
		print(button.y)
	end
end


local function mouseOver( theButton )		--check if the mouse is over the (rectangular) button
	local x, y = love.mouse.getPosition()
	if x > theButton.x and x < theButton.x + theButton.w and y > theButton.y and y < theButton.y + theButton.h then
		return true
	end
	return false
end


function button.show()
	love.graphics.setFont( buttonFont )
	love.graphics.setLine( 3, "smooth" )
	for key, button in pairs( buttons ) do
		if mouseOver( button ) and button.drawHover then
			button.drawHover( button )
		elseif button.drawNormal then
			button.drawNormal( button )
		end
	end
end


function button.handleClick()
	for key, button in pairs( buttons ) do
		if mouseOver( button ) then
			if button.event then
				button.event( button.argument )
			end
			return
		end
	end
end

return button
