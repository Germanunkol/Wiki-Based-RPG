local themes = {}

local availableThemes = {}
local currentTheme = nil

IMAGE_TOP_RIGHT = nil
IMAGE_TOP_LEFT = nil
IMAGE_TOP_CENTER = nil
IMAGE_RIGHT = nil
IMAGE_LEFT = nil
IMAGE_BOTTOM_RIGHT = nil
IMAGE_BOTTOM_LEFT = nil
IMAGE_BOTTOM_CENTER = nil
IMAGE_INVENTORY = nil
IMAGE_GAME = nil
IMAGE_CHAT = nil

function themes.init( path )
	print("Looking for available themes: ")
	availableThemes = {}
	local folderContent = love.filesystem.getDirectoryItems(path)
	for k, themeName in pairs( folderContent ) do
		if love.filesystem.isDirectory( path .. "/" .. themeName ) then
			print("\tFound Theme: " .. themeName)
			local themeContent = love.filesystem.getDirectoryItems( path .. "/" .. themeName )
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
	if theme == currentTheme then
		print("Theme already set!")
	else

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
				
				--automatically load and place the theme's images. pcall makes sure the game doesn't crash if it can't load the file.
			
				ok, IMAGE_TOP_RIGHT = pcall(love.graphics.newImage,  "Themes/" .. theme .. "/Top_Right.png" )
				if not ok then IMAGE_TOP_RIGHT = nil end
				ok, IMAGE_TOP_LEFT = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Top_Left.png" )
				if not ok then IMAGE_TOP_LEFT = nil end
				ok, IMAGE_TOP_CENTER = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Top_Center.png" )
				if not ok then IMAGE_TOP_CENTER = nil end
				ok, IMAGE_RIGHT = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Right.png" )
				if not ok then IMAGE_RIGHT = nil end
				ok, IMAGE_LEFT = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Left.png" )
				if not ok then IMAGE_LEFT = nil end
				ok, IMAGE_BOTTOM_RIGHT = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Bottom_Right.png" )
				if not ok then IMAGE_BOTTOM_RIGHT = nil end
				ok, IMAGE_BOTTOM_LEFT = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Bottom_Left.png" )
				if not ok then IMAGE_BOTTOM_LEFT = nil end
				ok, IMAGE_BOTTOM_CENTER = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Bottom_Center.png" )
				if not ok then IMAGE_BOTTOM_CENTER = nil end
				ok, IMAGE_INVENTORY = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Inventory.png" )
				if not ok then IMAGE_INVENTORY = nil end
				ok, IMAGE_GAME = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Game.png" )
				if not ok then IMAGE_GAME = nil end
				ok, IMAGE_CHAT = pcall(love.graphics.newImage, "Themes/" .. theme .. "/Chat.png" )
				if not ok then IMAGE_CHAT = nil end
				
				if IMAGE_TOP_CENTER then
					IMAGE_TOP_CENTER_X = (love.graphics.getWidth() - IMAGE_TOP_CENTER:getWidth())/2
				end
				if IMAGE_TOP_RIGHT then
					IMAGE_TOP_RIGHT_X = love.graphics.getWidth() - IMAGE_TOP_RIGHT:getWidth()
				end
				if IMAGE_RIGHT then
					IMAGE_RIGHT_X = love.graphics.getWidth() - IMAGE_RIGHT:getWidth()
					IMAGE_RIGHT_Y = (love.graphics.getHeight() - IMAGE_RIGHT:getHeight())/2
				end
				if IMAGE_LEFT then
					IMAGE_LEFT_Y = (love.graphics.getHeight() - IMAGE_LEFT:getHeight())/2
				end
				if IMAGE_BOTTOM_RIGHT then
					IMAGE_BOTTOM_RIGHT_X = love.graphics.getWidth() - IMAGE_BOTTOM_RIGHT:getWidth()
					IMAGE_BOTTOM_RIGHT_Y = love.graphics.getHeight() - IMAGE_BOTTOM_RIGHT:getHeight()
				end
				if IMAGE_BOTTOM_CENTER then
					IMAGE_BOTTOM_CENTER_X = (love.graphics.getWidth() - IMAGE_BOTTOM_CENTER:getWidth())/2
					IMAGE_BOTTOM_CENTER_Y = love.graphics.getHeight() -IMAGE_ BOTTOM_CENTER:getHeight()
				end
				if IMAGE_BOTTOM_LEFT then
					IMAGE_BOTTOM_LEFT_Y = love.graphics.getHeight() - IMAGE_BOTTOM_LEFT:getHeight()
				end				
				
				currentTheme = theme
				return true
			end
		end
		print("Error: Theme not found!")
		return nil
	end
end

function themes.getList()
	return availableThemes
end

function themes.getCurrentTheme()
	return currentTheme
end

function themes.drawBackgroundImages()
	love.graphics.setColor( 255,255,255,255 )
	if IMAGE_TOP_RIGHT then
		love.graphics.draw( IMAGE_TOP_RIGHT, IMAGE_TOP_RIGHT_X, 0 )
	end
	if IMAGE_TOP_LEFT then
		love.graphics.draw( IMAGE_TOP_LEFT, 0, 0 )
	end
	if IMAGE_TOP_CENTER then
		love.graphics.draw( IMAGE_TOP_CENTER, IMAGE_TOP_CENTER_X, 0 )
	end
	if IMAGE_RIGHT then
		love.graphics.draw( IMAGE_RIGHT, IMAGE_RIGHT_X, IMAGE_RIGHT_Y )
	end
	if IMAGE_LEFT then
		love.graphics.draw( IMAGE_LEFT, 0, IMAGE_LEFT_Y )
	end
	if IMAGE_BOTTOM_RIGHT then
		love.graphics.draw( IMAGE_BOTTOM_RIGHT, IMAGE_BOTTOM_RIGHT_X, IMAGE_BOTTOM_RIGHT_Y )
	end
	if IMAGE_BOTTOM_LEFT then
		love.graphics.draw( IMAGE_BOTTOM_LEFT, 0, IMAGE_BOTTOM_LEFT_Y )
	end
	if IMAGE_BOTTOM_CENTER then
		love.graphics.draw( IMAGE_BOTTOM_CENTER, IMAGE_BOTTOM_CENTER_X, IMAGE_BOTTOM_CENTER_Y )
	end
end

function themes.setOtherImagesPositions()
	if IMAGE_GAME then
		IMAGE_GAME_X = gameAreaX + (gameAreaWidth - IMAGE_GAME:getWidth())/2
		IMAGE_GAME_Y = gameAreaY + (gameAreaHeight - IMAGE_GAME:getHeight())/2
	end
	if IMAGE_CHAT then
		IMAGE_CHAT_X = chatAreaX + (chatAreaWidth - IMAGE_CHAT:getWidth())/2
		IMAGE_CHAT_Y = chatAreaY + (chatAreaHeight - IMAGE_CHAT:getHeight())/2
	end
	if IMAGE_INVENTORY then
		IMAGE_INVENTORY_X = chatAreaX + (chatAreaWidth - IMAGE_INVENTORY:getWidth())/2
		IMAGE_INVENTORY_Y = chatAreaY + chatAreaHeight + love.graphics.getHeight()/4 - IMAGE_INVENTORY:getHeight()/2
	end
end

function themes.drawOtherImages()
	if IMAGE_GAME then
		love.graphics.draw( IMAGE_GAME, IMAGE_GAME_X, IMAGE_GAME_Y )
	end
	if IMAGE_INVENTORY then
		love.graphics.draw( IMAGE_INVENTORY, IMAGE_INVENTORY_X, IMAGE_INVENTORY_Y )
	end
	if IMAGE_CHAT then
		love.graphics.draw( IMAGE_GAMCHATE, IMAGE_CHAT_X, IMAGE_CHAT_Y )
	end
end

return themes
