local statusMsg = {}

local curStatusMsg = ""

local statusMsgTimer = 0

function statusMsg.new( msg )
	statusMsgTimer = 0
	curStatusMsg = msg
end

function statusMsg.display()
	statusMsgTimer = statusMsgTimer + love.timer.getDelta()
	if statusMsgTimer < 10 then
		love.graphics.setFont( fontStatus )
		love.graphics.setColor( 0, 0, 0, 255*(10-statusMsgTimer)/10)
		love.graphics.print( curStatusMsg, (love.graphics.getWidth()-fontStatus:getWidth( curStatusMsg))/2, love.graphics.getHeight()-30 )
	end
end

return( statusMsg )
