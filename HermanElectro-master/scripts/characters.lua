require('scripts.object')

local P = {}
characters = P

P.character = Object:new{name = "Name", sprite = love.graphics.newImage('Graphics/herman_sketch.png'),
  description = "description", startingTools = {0,0,0,0,0,0,0}, scale = 0.25 * width/1200}
function P.character:onBegin()
	self:setStartingTools()
	self:onCharLoad()
end
function P.character:setStartingTools()
	for i = 1, tools.numNormalTools do
		tools[i].numHeld = self.startingTools[i]
	end
end
function P.character:onCharLoad()

end

P.herman = P.character:new{name = "Herman", description = "The Electrician"}

P.felix = P.character:new{name = "Felix", description = "The Sharpshooter", sprite = love.graphics.newImage('Graphics/felix.png'), startingTools = {0,0,0,0,0,0,1}}
function P.felix:onCharLoad()
	tools.gun.range = 5
end

P.most = P.character:new{name = "Ben", description = "The Explorer",
  sprite = love.graphics.newImage('GraphicsTony/Ben.png'), scale = 0.7 * width/1200}
function P.most:onCharLoad()
	if map.floorOrder == map.defaultFloorOrder then
		map.floorOrder = {'RoomData/bigfloor.json', 'RoomData/floor6.json'}
	end
end

local erikSprite = love.graphics.newImage('Graphics/beggar.png')
P.erik = P.character:new{name = "Erik", description = "The Quick",
  sprite = erikSprite, scale = scale*16/erikSprite:getWidth()}
function P.erik:onCharLoad()
	gameTime.timeLeft = 60
	gameTime.roomTime = 10
	gameTime.levelTime = 0
	map.floorOrder = {'RoomData/floor1_erik.json', 'RoomData/floor2_erik.json', 'RoomData/floor3_erik.json', 'RoomData/floor6.json'}
end

P[1] = P.herman
P[2] = P.felix
P[3] = P.most
P[4] = P.erik

return characters