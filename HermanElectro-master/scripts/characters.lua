require('scripts.object')
unlocks = require('scripts.unlocks')

local P = {}
characters = P

function P.getUnlockedCharacters()
	local lockedChars = {}
	for i = 1, #unlocks do
		if unlocks[i].charIds ~= nil and not unlocks[i].unlocked then
			for j = 1, #unlocks[i].charIds do
				lockedChars[#lockedChars+1] = unlocks[i].charIds[j]
			end
		end
	end
	local toRet = {}
	for i = 1, #characters do
		local isLocked = false
		for j = 1, #lockedChars do
			if lockedChars[j] == i then
				isLocked = true
			end
		end
		if not isLocked then
			toRet[#toRet+1] = characters[i]
		end
	end
	return toRet
end

P.character = Object:new{name = "Name", sprite = love.graphics.newImage('Graphics/herman_sketch.png'),
  description = "description", startingTools = {0,0,0,0,0,0,0}, scale = 0.25 * width/1200}
function P.character:onBegin()
	self:setStartingTools()
	self:onCharLoad()
end
function P.character:canFly()
	return false
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

P.gabe = P.character:new{name = "Gabe", description = "The Angel",
	sprite = love.graphics.newImage('Graphics/gabe.png')}
function P.gabe:onCharLoad()
	player.flying = true
end
function P.gabe:canFly()
	return true
end

P.rammy = P.character:new{name = "Rammy", description = "The Ram",
	sprite = love.graphics.newImage('Graphics/ram.png')}

P[1] = P.herman
P[2] = P.felix
P[3] = P.most
P[4] = P.erik
P[5] = P.gabe
P[6] = P.rammy

return characters