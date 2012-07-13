-- Exports the story to a file.

local export = {}

function export.init()
	love.filesystem.setIdentity("WikiBasedRPG")
end

function export.toTextFile( text )
	if text and text.content then
		local curTime = os.date("*t")
		local fileName
		if curTime then
			fileName = curTime.year .."-".. curTime.month .."-".. curTime.day .. "_" .. curTime.hour .."-".. curTime.min .."-".. curTime.sec .. ".txt"
		else
			math.randomseed(os.time())
			fileName = math.random(99999)
		end
		file = love.filesystem.newFile( fileName )
		if file:open( 'w' ) then
			file:write(startingWord .. "\n\n")
			local stringToWrite = text.content
			file:write(stringToWrite)
			file:close()
			print(fileName .. " written to: " .. love.filesystem.getSaveDirectory() )
		else
			statusMsg.new( "Error opening file!" );
			print( "Error opening " .. filName .. "!" );
		end
	else
		print( "Text empty" )
	end
end

function export.toHtmlFile( text )
	if text and text.content then
		local curTime = os.date("*t")
		local fileName
		if curTime then
			fileName = curTime.year .."-".. curTime.month .."-".. curTime.day .. "_" .. curTime.hour .."-".. curTime.min .."-".. curTime.sec .. ".html"
		else
			math.randomseed(os.time())
			fileName = math.random(99999)
		end

		file = love.filesystem.newFile( fileName )
		if file:open( 'w' ) then
			file:write("<h2>" .. startingWord .. "</h2>")
			file:write("<font color=\"grey\">(A story influenced by Randomness and " .. wikiClient.getWikiURL() .. ")</font><br /><br />")
			local stringToWrite = "\n" .. text.content
			stringToWrite = stringToWrite:gsub( "\nStory:([^\n]*)", "\n<br /><b><i>%1</i></b>" )
			stringToWrite = stringToWrite:gsub( "\n([^<br />])", "\n<br />&emsp;%1" )
			file:write(stringToWrite)
			file:close()
			print(fileName .. " written to: " .. love.filesystem.getSaveDirectory() )
		else
			statusMsg.new( "Error opening file!" );
			print( "Error opening " .. filName .. "!" );
		end
	else
		print( "Text empty" )
	end
end


return export
