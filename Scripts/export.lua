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
		
		print("Exporter started. Writing to .html file.")

		file = love.filesystem.newFile( fileName )
		if file:open( 'w' ) then
		
			--define the two indentation styles, one for player actions, one for chat:
			file:write("<STYLE TYPE=\"text/css\">\n<!--\n.story\n\t{\n\tfont-style:italic\n\t}\n-->\n</STYLE>\n")
			file:write("<STYLE TYPE=\"text/css\">\n<!--\n.player\n\t{\n\tpadding-left: 10pt;\n\t}\n-->\n</STYLE>\n")
			file:write("<STYLE TYPE=\"text/css\">\n<!--\n.chat\n\t{\n\tpadding-left: 40pt;\n\tfont-size:80%;\n\t}\n-->\n</STYLE>\n\n\n")
			
			--write heading:
			file:write("<h2>" .. "Room" .. "</h2>")
			file:write("<font color=\"grey\">(A story influenced by " .. wikiClient.getWikiURL() .. " and a fair bit of randomness)\n<br />(Bold words were dictated by the wiki)</font><br />")
			
			
			local stringToWrite = text.content .. "\n"
			
			local s, e
			for k, v in pairs( text.highlightWords ) do
				s, e = stringToWrite:upper():find( v.w:upper(), 1, true)
				while s do
					stringToWrite = safeSub(stringToWrite,1, s-1) .. "<b>" .. safeSub(stringToWrite, s,e) .. "</b>" .. safeSub(stringToWrite, e+1, #stringToWrite)
					s, e = stringToWrite:upper():find( v.w:upper(), e+7, true)
				end
			end
			
			local lines = {}
			local pos = 1
			s, e = stringFind(stringToWrite, "\n", 1 )
			while s do
				lines[#lines+1] = safeSub(stringToWrite, pos, s-1)
				pos = s + 1
				s, e = stringFind(stringToWrite, "\n", e+1 )
			end
			--printTable(lines)
			
			local lineType = {}
			
			for k, line in pairs(lines) do
				if safeSub( line, 1, strLen(STORYTELLER_STR .. ":") ) == STORYTELLER_STR .. ":" then
					lineType[k] = "story"
					if DEBUG then print("story line: ".. line) end
					lines[k] = safeSub( line, strLen(STORYTELLER_STR .. ":")+2, strLen(line) )	-- remove the beginning of the line
					
				elseif safeSub( line, 1, 6 ) == "&CHAT:" then
					lineType[k] = "chat"
					if DEBUG then print("chat line: ".. line) end
					lines[k] = safeSub( line, 7, strLen(line) )			-- remove the beginning of the line
					--line = "<p CLASS=\"chat\">\t" .. line .. "</p>"			-- add the html tags
				else
					lineType[k] = "player"
					if DEBUG then print("neither: " .. line) end
					--line = "<p CLASS=\"player\">\t" .. line .. "</p>\n"
				end
			end
			
			for k, line in pairs(lines) do			-- add the html tags
				if lineType[k] == "story" then
					if lineType[k-1] ~= "story" then
						line = "<p CLASS=\"story\">\n\t" .. line
					else
						line = "</br>\n\t" .. line
					end
					if lineType[k+1] ~= "story" then
						line = line.. "\n</p>\n"
					end
				end
				
				if lineType[k] == "chat" then
					if lineType[k-1] ~= "chat" then
						line = "<p CLASS=\"chat\">\n\t" .. line
					else
						line = "</br>\n\t" .. line
					end
					if lineType[k+1] ~= "chat" then
						line = line .. "\n</p>\n"
					end
				end
				
				if lineType[k] == "player" then
					if lineType[k-1] ~= "player" then
						line = "<p CLASS=\"player\">\n\t" .. line
					else
						line = "</br>\n\t" .. line
					end
					if lineType[k+1] ~= "player" then
						line = line .. "\n</p>\n"
					end
				end
				file:write(line)
			end 
--[[
			stringToWrite = stringToWrite:gsub( "\n" .. STORYTELLER_STR .. ":([^\n]*)", "\n</p><i>%1</i><p CLASS=\"indent\">" )
			
			stringToWrite = stringToWrite:gsub( "\n&CHAT:([^\n]*)", "\n<p CLASS=\"indentchat\"><font color=\"grey\"><i>%1</i></font></p>" )
			
			s,e = stringToWrite:find("\n", 1, true)
			while s do
				if safeSub(stringToWrite,  s-#"</i><p CLASS=\"indent\">", s-1 ) ~= "</i><p CLASS=\"indent\">" then
					stringToWrite = safeSub(stringToWrite, 1, s-1) .. "<br />" .. safeSub(stringToWrite, s, #stringToWrite)
				end
				--if DEBUG then print(safeSub(stringToWrite, e+6, #stringToWrite)) end
				s,e = stringToWrite:find("\n", e+7, true)
			end
			
			-- make .html file look better:
			stringToWrite = stringToWrite:gsub( "(<p CLASS=\"indent\">)", "\n%1" )
			stringToWrite = stringToWrite:gsub( "(</p>)", "\n%1\n" )

			file:write(stringToWrite)]]--
			file:close()
			print(fileName .. " " .. FILE_WRITTEN_TO_LOCATION_STR .. " " .. love.filesystem.getSaveDirectory() )
			statusMsg.new( "Exported to: " .. love.filesystem.getSaveDirectory() );
		else
			statusMsg.new( ERROR_FILE_OPEN_STR );
			print( "Error opening " .. filName .. "!" );
		end
	else
		print( "Text empty" )
	end
end


--[[ --old
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
		
		file = love.filesystem.newFile( curTime.year .."-".. curTime.month .."-".. curTime.day .. "_" .. curTime.hour .."-".. curTime.min .."-".. curTime.sec ..".txt")
		if file:open( 'w' ) then
			file:write(text.content)
			file:close()
		end

		file = love.filesystem.newFile( fileName )
		if file:open( 'w' ) then
		
			--define the two indentation styles, one for player actions, one for chat:
			file:write("<STYLE TYPE=\"text/css\">\n<!--\n.indent\n   {\n   padding-left: 10pt;\n   }\n-->\n</STYLE>\n")
			file:write("<STYLE TYPE=\"text/css\">\n<!--\n.indentchat\n   {\n   padding-left: 40pt;\n   font-size:80%;\n   }\n-->\n</STYLE>\n\n\n")
			
			--write heading:
			file:write("<h2>" .. startingWord .. "</h2>")
			file:write("<font color=\"grey\">(A story influenced by " .. wikiClient.getWikiURL() .. " and a fair bit of randomness)\n<br />(Bold words were dictated by the wiki)</font><br />")
			
			
			local stringToWrite = "\n" .. text.content
			
			local s, e
			for k, v in pairs( text.highlightWords ) do
				s, e = stringToWrite:upper():find( v.w:upper(), 1, true)
				while s do
					stringToWrite = safeSub(stringToWrite,1, s-1) .. "<b>" .. safeSub(stringToWrite, s,e) .. "</b>" .. safeSub(stringToWrite, e+1, #stringToWrite)
					s, e = stringToWrite:upper():find( v.w:upper(), e+7, true)
				end
			end
			
			local lines = {}
			local pos = 0
			s, e = stringFind(stringToWrite, "\n", 1)
			while s do
				lines[#lines+1] = safeSub(stringToWrite, pos, s)
				pos = pos + s
				s, e = stringFind(stringToWrite, "\n", e)
			end
			printTable(lines)

			stringToWrite = stringToWrite:gsub( "\n" .. STORYTELLER_STR .. ":([^\n]*)", "\n</p><i>%1</i><p CLASS=\"indent\">" )
			
			stringToWrite = stringToWrite:gsub( "\n&CHAT:([^\n]*)", "\n<p CLASS=\"indentchat\"><font color=\"grey\"><i>%1</i></font></p>" )
			
			s,e = stringToWrite:find("\n", 1, true)
			while s do
				if safeSub(stringToWrite,  s-#"</i><p CLASS=\"indent\">", s-1 ) ~= "</i><p CLASS=\"indent\">" then
					stringToWrite = safeSub(stringToWrite, 1, s-1) .. "<br />" .. safeSub(stringToWrite, s, #stringToWrite)
				end
				if DEBUG then print(safeSub(stringToWrite, e+6, #stringToWrite)) end
				s,e = stringToWrite:find("\n", e+7, true)
			end
			
			-- make .html file look better:
			stringToWrite = stringToWrite:gsub( "(<p CLASS=\"indent\">)", "\n%1" )
			stringToWrite = stringToWrite:gsub( "(</p>)", "\n%1\n" )

			file:write(stringToWrite)
			file:close()
			print(fileName .. " " .. FILE_WRITTEN_TO_LOCATION_STR .. " " .. love.filesystem.getSaveDirectory() )
			statusMsg.new( "Exported to: " .. love.filesystem.getSaveDirectory() );
		else
			statusMsg.new( ERROR_FILE_OPEN_STR );
			print( "Error opening " .. filName .. "!" );
		end
	else
		print( "Text empty" )
	end
end
]]--

return export
