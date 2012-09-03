local themes = {}

local availableThemes = {}
local currentTheme = nil


function themes.init( path )
	print("Looking for available themes: ")
	availableThemes = {}
	local folderContent = love.filesystem.enumerate(path)
	for k, themeName in pairs( folderContent ) do
		if love.filesystem.isDirectory( path .. "/" .. themeName ) then
			print("\tFound Theme: " .. themeName)
			local themeContent = love.filesystem.enumerate( path .. "/" .. themeName )
			for j, file in pairs( themeContent ) do
				if file == "ThemeSettings.txt" then
					print("\t\t(Theme looks valid.)")
					table.insert( availableThemes, themeName ) 
				end
			end
		end
	end
end

function themes.set( theme )
	print("Loading theme settings for: " .. theme)
	for k, t in pairs(availableThemes) do
		if theme == t then
		
			-- execute the settings file:
			local ok, chunk
			ok, chunk = pcall( love.filesystem.load, "Themes/" .. theme .. "/ThemeSettings.txt" ) -- load the chunk safely
			if not ok then
				print("Error loading '" .. theme .. "/ThemeSettings.txt': " .. tostring(chunk))
			else
				ok, result = pcall(chunk) -- execute the chunk safely
				if not ok then -- will be false if there is an error
					print("Error in '" .. theme .. "/ThemeSettings.txt': " .. tostring(chunk))
				end
			end
			
			if ok then
				print("Theme loading successful.")
			else
				print("Failed to load theme. Maybe try another one?")
				return nil
			end
			
			love.graphics.setBackgroundColor( colMainBg.r, colMainBg.g, colMainBg.b )
			currentTheme = theme
			return true
		end
	end
	print("Error: Theme not found!")
	return nil
end

function themes.getList()
	return availableThemes
end

function themes.getCurrentTheme()
	return currentTheme
end

return themes
