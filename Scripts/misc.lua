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
		statusMsg.new("Cannot change Avatar while you're \"ready\".")
		return
	end
	avatar[ID] = avatar[ID] + 1
	if avatar[ID] == 3 then
		avatar[ID] = 0
	end
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
