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
  description = "description", startingTools = {0,0,0,0,0,0,0}, scale = 0.25 * width/1200, forcePowerUpdate = false}
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
function P.character:onRoomEnter()
end
function P.character:onFloorEnter()
end
function P.character:onPreUpdatePower()

end
function P.character:onPostUpdatePower()
	
end
function P.character:onKeyPressed()
	return false
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

P.rammy = P.character:new{name = "Rammy", description = "The Ram",
	sprite = love.graphics.newImage('Graphics/ram.png')}

P.rick = P.character:new{name = "Rick", description = "The Gambler", sprite = love.graphics.newImage('Graphics/rick.png')}
function P.rick:onCharLoad()
	tools.toolReroller.numHeld = 3
end
function P.rick:onFloorEnter()
	for i = 1, #tools do
		if tools[i].numHeld>0 then
			tools[i].numHeld=0
		end
	end
end

--alternative name: "Froggy, the Fresh"
P.frederick = P.character:new{name = "Frederick", description = "The Frog", sprite = love.graphics.newImage('Graphics/frederick.png')}
function P.frederick:onCharLoad()
	tools.spring.numHeld = 4
end
function P.frederick:onFloorEnter()
	tools.spring.numHeld = tools.spring.numHeld+2
end

P.battery = P.character:new{name = "Bob", description = "The Battery", sprite = love.graphics.newImage('Graphics/powersupplydead.png'),
  onSprite = love.graphics.newImage('Graphics/powersupply.png'), offSprite = love.graphics.newImage('Graphics/powersupplydead.png'), 
  scale = scale, storedTile = nil, forcePowerUpdate = false, powered = false}
function P.battery:onKeyPressed(key)
	--log(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		if self.powered then
			self.powered = false
			self.sprite = self.offSprite
			self.forcePowerUpdate = false
		else
			self.powered = true
			self.sprite = self.onSprite
			self.forcePowerUpdate = true
		end
		return true
	end
	return false
end
function P.battery:onPreUpdatePower()
	if self.powered then
		if room[player.tileY][player.tileX] ~= nil then
			self.storedTile = room[player.tileY][player.tileX]:new()
			self.storedTile.powered = true
		else
			self.storedTile = nil
		end
		room[player.tileY][player.tileX] = tiles.powerSupply:new()
	end
end
function P.battery:onPostUpdatePower()
	if self.powered then
		room[player.tileY][player.tileX] = self.storedTile
	end
end

P[1] = P.herman
P[2] = P.felix
P[3] = P.most
P[4] = P.erik
P[5] = P.gabe
P[6] = P.rammy
P[7] = P.rick
P[8] = P.frederick
P[9] = P.battery

return characters