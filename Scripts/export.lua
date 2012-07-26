-- Exports the story to a file.

local export = {}

function export.init()
	love.filesystem.setIdentity("WikiBasedRPG")
end
--[[
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
			print( fileName .. " written to: " .. love.filesystem.getSaveDirectory() )
		else
			statusMsg.new( "Error opening file!" );
			print( "Error opening " .. filName .. "!" );
		end
	else
		print( "Text empty" )
	end
end
]]--

function export.toHtmlFile( text )				-- this function assumes that the game starts with a piece of the story, (i.e. server starts, not the players) !
	if text and text.content then
		local curTime = os.date("*t")
		local fileName
		if curTime then
			fileName = curTime.year .."-".. curTime.month .."-".. curTime.day .. "_" .. curTime.hour .."-".. curTime.min .."-".. curTime.sec .. ".html"
		else
			math.randomseed(os.time())
			fileName = math.random(99999)
		end
		
		print("Exporter started. Writing to .html file.")

		file = love.filesystem.newFile( fileName )
		if file:open( 'w' ) then
			file:write("<STYLE TYPE=\"text/css\">\n<!--\n.indent\n   {\n   padding-left: 10pt;\n   }\n-->\n</STYLE>\n")
			file:write("<h2>" .. startingWord .. "</h2>")
			file:write("<font color=\"grey\">(A story influenced by " .. wikiClient.getWikiURL() .. " and a fair bit of randomness)\n<br />(Bold words were dictated by the wiki)</font><br />")
			local stringToWrite = "\n" .. text.content
			
			local s, e
			for k, v in pairs( text.highlightWords ) do
				s, e = stringToWrite:upper():find( v.w:upper(), 1, true)
				while s do
					stringToWrite = stringToWrite:sub(1, s-1) .. "<b>" .. stringToWrite:sub(s,e) .. "</b>" .. stringToWrite:sub(e+1, #stringToWrite)
					s, e = stringToWrite:upper():find( v.w:upper(), e+7, true)
				end
			end


			stringToWrite = stringToWrite:gsub( "\nStory:([^\n]*)", "\n</p><i>%1</i><p CLASS=\"indent\">" )
			
			s,e = stringToWrite:find("\n", 1, true)
			while s do
				if stringToWrite:sub( s-#"</i><p CLASS=\"indent\">", s-1 ) ~= "</i><p CLASS=\"indent\">" then
					stringToWrite = stringToWrite:sub(1, s-1) .. "<br />" .. stringToWrite:sub(s, #stringToWrite)
				end
				print(stringToWrite:sub(e+6, #stringToWrite))
				s,e = stringToWrite:find("\n", e+7, true)
			end
			
			-- make .html file look better:
			stringToWrite = stringToWrite:gsub( "(<p CLASS=\"indent\">)", "\n%1" )
			stringToWrite = stringToWrite:gsub( "(</p>)", "\n%1\n" )

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
