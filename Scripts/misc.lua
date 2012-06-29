function sleep(seconds)
  local start = os.time()
  repeat until os.time() > start + seconds
end

function drawButton( theButton )
	love.graphics.setColor( colLobby.r,colLobby.g,colLobby.b , 100)
	--love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
	--love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 150)
	love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
	love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2)
end


function highlightButton( theButton )
	--love.graphics.setColor( 0, 0, 0 , 255)
	--love.graphics.rectangle( "fill", theButton.x, theButton.y, theButton.w, theButton.h )
	love.graphics.setColor( colBorder.r, colBorder.g, colBorder.g, 100)
	love.graphics.rectangle( "fill", theButton.x + 1, theButton.y + 1, theButton.w-2, theButton.h-2)
	love.graphics.setColor( colLobby.r, colLobby.g, colLobby.g, 255)
	love.graphics.rectangle( "fill", theButton.x + 3, theButton.y + 3, theButton.w-6, theButton.h-6 )
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.print( theButton.label, theButton.x + theButton.w/2 - buttonFont:getWidth(theButton.label)/2, theButton.y + (theButton.h - buttonFont:getHeight())/2 )
end
