local chat = {}

chatBox = nil
chatInputBox = nil

local active = false
local x,y,f,w,h,hInput

function chat.setAccess( activate )
	if activate then
		textBox.setAccess( chatInputBox, true )
		active = true
	else
		active = false
		textBox.setAccess( chatInputBox, false )
	end
	scrollChat()
end

function chat.getActive()
	return active
end

function scrollChat()
	local linesFittingOnScreen
	if active then
		linesFittingOnScreen = math.floor( (h-hInput)/textBox.getFont( chatBox ):getHeight() )
	else
		linesFittingOnScreen = math.floor( h/textBox.getFont( chatBox ):getHeight() - 1 )
	end
	textBox.setVisibleLines( chatBox, textBox.numLines( chatBox )-linesFittingOnScreen, linesFittingOnScreen )
	print(textBox.numLines( chatBox )-linesFittingOnScreen, linesFittingOnScreen)
end

function chat.receive( msg )
	if chatInputBox then
		textBox.setContent( chatBox, textBox.getContent( chatBox ) .. msg .. "\n")
		
		table.insert( nextFrameEvent, {func = scrollChat, frames = 2} )		
	end
end


function chat.send()
	active = false
	if #textBox.getContent( chatInputBox ) > 0 then
		if client then
			client:send( "CHAT:" .. textBox.getContent( chatInputBox ) .. "\n" )
		elseif server then
			connection.serverBroadcast("CHAT:Server: " .. textBox.getContent( chatInputBox ) )
			chat.receive( "Server: " .. textBox.getContent( chatInputBox ) )
		end
		textBox.setContent( chatInputBox, "" )
	end
end

function chat.escape()
	active = false
	-- textBox.setContent( chatInputBox, "" )
	scrollChat()
end

function chat.init( xPos, yPos, lines, font, width)
	if chatBox then
		textBox.remove( chatBox )
	end
	x, y, f, w, h = xPos, yPos, font, width, font:getHeight()*lines
	hInput = math.floor( h/3 )
	chatBox = textBox.new( xPos, yPos, lines, font, width )
	chatInputBox = textBox.new( xPos, yPos + 2*hInput, math.floor(hInput/font:getHeight()), font, width )
	textBox.setReturnEvent( chatInputBox, chat.send )
	textBox.setEscapeEvent( chatInputBox, chat.escape )
end

function chat.show()
	textBox.display( chatBox )
	if active then
		love.graphics.setColor( colLobby.r, colLobby.g, colLobby.b )
		love.graphics.rectangle( "fill",x, y + 2*hInput, w, hInput-5)
		textBox.display( chatInputBox )
	end
end

return chat
