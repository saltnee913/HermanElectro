require('scripts.boundaries')

player = boundaries:new{x = 400, y = 400, width = 20, height = 20, isPlayer = true,
	speed = 250, sprite = love.graphics.newImage('herman_sketch.png'), roomid = 0, scale = 0.3, }

function player:switchRooms(dir)

end