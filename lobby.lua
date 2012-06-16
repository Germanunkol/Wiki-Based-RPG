local lobby = {}

local active


function lobby.init()
	active = true
end

function lobby.active()
	return active
end

function lobby.showPlayers()
	love.graphics.setColor( 0, 0, 0 , 255)
	love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), 50)
	love.graphics.setColor( 255,255,255 , 200)
	love.graphics.rectangle("fill", 0, 51, love.graphics.getWidth(), 48)
	love.graphics.setColor( 0, 0, 0 , 255)
	
	love.graphics.setFont( fontHeader )
	love.graphics.print( "Players:", 70, 70 )
	
	for k, v in pairs( connectedClients ) do
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.rectangle("fill", 0, 110 + 50*k, love.graphics.getWidth(), 35)
		love.graphics.setColor( 255,255,255 , 220)
		love.graphics.rectangle("fill", 0, 111 + 50*k, love.graphics.getWidth(), 33)
		love.graphics.setColor( 0, 0, 0 , 255)
		love.graphics.setFont( mainFont )
		love.graphics.print( v.playerName, 70, 120  + 50*k )
	end
	
	buttons.show()
end

--function 





return lobby
