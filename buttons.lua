local button = {}

local buttons = {}

function button.clear()
	for k, v in pairs(buttons) do
		if v.label ~= "Help" then
			buttons[k] = nil
		end
	end
end

function button.add(newX, newY, newWidth, newHeight, newLabel, functionOff, functionHover, newEvent)
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
	table.insert( buttons, newButton )
end



local function mouseOver( theButton )		--check if the mouse is over the (rectangular) button
	x, y = love.mouse.getPosition()
	if x > theButton.x and x < theButton.x + theButton.w and y > theButton.y and y < theButton.y + theButton.h then
		return true
	end
	return false
end


function button.show()
	love.graphics.setFont( buttonFont )
	love.graphics.setLine( 3, "smooth" )
	for key, button in pairs( buttons ) do
		if mouseOver( button ) then
			button.drawHover( button )
		else
			button.drawNormal( button )
		end
	end
end


function button.handleClick()
	for key, button in pairs( buttons ) do
		if mouseOver( button ) then
			if button.event then
				button.event()
			end
			return
		end
	end
end

return button
