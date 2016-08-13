require('scripts.object')

local P = {}
characters = P

P.character = Object:new{name = "Name", sprite = love.graphics.newImage('Graphics/herman_sketch.png'), description = "description", startingTools = {0,0,0,0,0,0,0}}
function P.character:onBegin()
	for i = 1, 7 do
		tools[i].numHeld = self.startingTools[i]
	end
end

P.herman = P.character:new{name = "Herman", description = "The Electrician"}

P.felix = P.character:new{name = "Felix", description = "The Sharpshooter", sprite = love.graphics.newImage('Graphics/felix.png'), startingTools = {0,0,0,0,0,0,1}}
function P.felix:onBegin()
	for i = 1, 7 do
		tools[i].numHeld = self.startingTools[i]
	end

	tools.gun.range = 5
end

P[1] = P.herman
P[2] = P.felix

return characters