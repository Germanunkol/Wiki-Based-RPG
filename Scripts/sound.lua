local sound = {}

local notificationSound = nil

function sound.init()
	if love.filesystem.isFile("Sound/Notification.wav") then
		notificationSound = love.audio.newSource("Sound/Notification.wav", "static")
	else
		notificationSound = love.audio.newSource("Sound\\Notification.wav", "static")
	end
end

function sound.playNotification()
	if notificationSound then love.audio.play( notificationSound ) end
end

return sound
