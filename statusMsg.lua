
local statusMsg = {}

local curStatusMsg = ""

local statusMsgTimer = 0

function statusMsg.new( msg )
	statusMsgTimer = 0
	curStatusMsg = msg
end


function statusMsg.display( dt )
	statusMsgTimer = statusMsgTimer + dt
	if statusMsgTimer < 5 then
		love.graphics.setFont( fontStatus )
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.print( curStatusMsg, (love.graphics.getWidth()-fontStatus:getWidth(curStatusMsg))/2, love.graphics.getHeight()-30 )
	end
end

return( statusMsg )
