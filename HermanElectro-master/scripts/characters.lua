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

P[1] = P.herman
P[2] = P.felix
P[3] = P.most

return characters