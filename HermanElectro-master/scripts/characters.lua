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
  description = "description", startingTools = {0,0,0,0,0,0,0}, scale = 0.25 * width/1200, forcePowerUpdate = false, winUnlocks = {}}
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
function P.character:onToolUse()
end
function P.character:preTileEnter(tile)
end
function P.character:onTileLeave()
end

P.herman = P.character:new{name = "Herman", description = "The Electrician"}
function P.herman:onCharLoad()
	if loadTutorial then return end
	tools.revive.numHeld = 2
end

P.felix = P.character:new{name = "Felix", description = "The Sharpshooter", sprite = love.graphics.newImage('Graphics/felix.png'), startingTools = {0,0,0,0,0,0,1}}
function P.felix:onCharLoad()
	tools[7] = tools.felixGun
	if not tools.felixGun.isGun then
		tools.felixGun:switchEffects()
	end
	tools.felixGun.numHeld = 1
	tools.bomb.numHeld = 1
end
function P.felix:onKeyPressed(key)
	--log(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		tools.felixGun:switchEffects()
		tools.updateToolableTiles(tool)
		return true
	end
	return false
end
function P.felix:onFloorEnter()
	tools.giveTools({7,7})
end

P.most = P.character:new{name = "Ben", description = "The Explorer",
  sprite = love.graphics.newImage('GraphicsTony/Ben.png'), scale = 0.7 * width/1200, winUnlocks = {7}}
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
	sprite = love.graphics.newImage('Graphics/gabe.png'), realChar = nil, reset = false}
function P.gabe:onCharLoad()
	if not self.reset then
		player.flying = true
		self.reset = true
	elseif self.realChar ~= nil then
		player.character = self.realChar
		player.character:onBegin()
		self.realChar = nil
		self.reset = false
	end
end
function P.gabe:onRoomEnter()
	player.flying = true
end

P.rammy = P.character:new{name = "Rammy", description = "The Ram",
	sprite = love.graphics.newImage('Graphics/ram.png')}
function P.rammy:preTileEnter(tile)
	if tile.name == tiles.wall.name and not tile.destroyed then
		tile:destroy()
	end
end

P.rick = P.character:new{name = "Rick", description = "The Gambler", sprite = love.graphics.newImage('Graphics/rick.png')}
function P.rick:onCharLoad()
	tools.toolReroller.numHeld = 3
	tools.roomReroller.numHeld = 1
end
function P.rick:onFloorEnter()
	for i = 1, tools.numNormalTools do
		if tools[i].numHeld>0 then
			tools[i].numHeld=0
		end
	end
end

--alternative name: "Froggy, the Fresh"
P.frederick = P.character:new{name = "Frederick", description = "The Frog", sprite = love.graphics.newImage('Graphics/frederick.png')}
function P.frederick:onCharLoad()
	tools.spring.numHeld = 4
	tools.visionChanger.numHeld = 2
end
function P.frederick:onFloorEnter()
	tools.giveTools({27,9})
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

P.nadia = P.character:new{name = "Nadia", description = "The Naturalist", sprite = love.graphics.newImage('Graphics/nadia.png')}
function P.nadia:onCharLoad()
	tools.meat.numHeld = 3
	player.safeFromAnimals = true
end

P.crate = P.character:new{name = "Carla", roomTrigger = false, description = "The Crate", isCrate = false, sprite = love.graphics.newImage('Graphics/carlaperson.png'),
  humanSprite = love.graphics.newImage('Graphics/carlaperson.png'), crateSprite = love.graphics.newImage('Graphics/carlabox.png')}
function P.crate:setCrate(isCrate)
	self.sprite = isCrate and self.crateSprite or self.humanSprite
	player.active = not isCrate
	self.isCrate = isCrate
end
function P.crate:onKeyPressed(key)
	--log(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		if not self.isCrate and not self.roomTrigger then
			P.crate:setCrate(true)
			return true
		else
			P.crate:setCrate(false)
			return true
		end
	end
	return false
end
function P.crate:onRoomEnter()
	self.roomTrigger = false
end
function P.crate:onToolUse()
	player.active = true
	self.roomTrigger = true
end
function P.crate:preTileEnter(tile)
	if self.isCrate then
		if room[player.tileY][player.tileX]:instanceof(tiles.pit) or room[player.tileY][player.tileX]:instanceof(tiles.poweredFloor) then
			room[player.tileY][player.tileX]:ladder()
			P.crate:setCrate(false)
			self.roomTrigger = true
		end
	end
end

P.giovanni = P.character:new{name = "Giovanni", description = "The Sorcerer", shiftPos = {x = -1, y = -1}, sprite = love.graphics.newImage('Graphics/giovanni.png'), sprite2 = love.graphics.newImage('Graphics/giovannighost.png')}
function P.giovanni:onKeyPressed(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		if self.shiftPos.x==-1 then
			self.shiftPos.x = player.tileX
			self.shiftPos.y = player.tileY
			log("Clone spawned!")
		else
			player.tileX = self.shiftPos.x
			player.tileY = self.shiftPos.y
			self.shiftPos = {x = -1, y = -1}
			log("Returned to clone!")
		end
	end
end
function P.giovanni:onCharLoad()
	tools.pitbullChanger.numHeld = 2
	self.shiftPos = {x = -1, y = -1}
end
function P.giovanni:onRoomEnter()
	self.shiftPos = {x = -1, y = -1}
end
P.giovanni.onFloorEnter = P.giovanni.onRoomEnter
function P.giovanni:onKeyPressed(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		if self.shiftPos.x==-1 then
			self.shiftPos.x = player.tileX
			self.shiftPos.y = player.tileY
			log("Clone spawned!")
		else
			player.tileX = self.shiftPos.x
			player.tileY = self.shiftPos.y
			self.shiftPos = {x = -1, y = -1}
			log("Returned to clone!")
		end
	end
end

P.francisco = P.character:new{name = "Francisco", description = "The Cartographer", nextRoom = {yLoc = -1, xLoc = -1}, sprite = love.graphics.newImage('Graphics/francisco.png')}
function P.francisco:onCharLoad()
	tools.giveTools({30})
end
function P.francisco:onFloorEnter()
	tools.giveTools({30})
end

P.random = P.character:new{name = "Random", description = "", sprite = love.graphics.newImage('Graphics/random.png')}
function P.random:onBegin()
	local charsToSelect = characters.getUnlockedCharacters()
	local charSlot = util.random(#charsToSelect-1, 'misc')
	player.character = charsToSelect[charSlot]:new()
	player.character:onBegin()
end

P.tim = P.character:new{name = "Tim", description = "The Box Summoner", sprite = love.graphics.newImage('Graphics/tim.png')}
function P.tim:onCharLoad()
	tools.giveTools({35,36,31})
end

P.orson = P.character:new{name = "Orson", shifted = false, description = "The Mastermind", sprite = love.graphics.newImage('Graphics/orson.png')}
function P.orson:onCharLoad()
	tools.brick.range = 100
end
function P.orson:onPostUpdatePower()
	self.shifted = false
end
function P.orson:onKeyPressed(key)
	self.shifted = true
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]~=nil and room[i][j]:instanceof(tiles.button) and not room[i][j]:instanceof(tiles.stayButton) then
					if room[i][j]:instanceof(tiles.stickyButton) then
						if room[i][j].down then room[i][j]:unstick()
						else room[i][j]:onEnter() end
					else room[i][j]:onEnter() end
				elseif room[i][j]~=nil and room[i][j]:instanceof(tiles.stayButton) then
					if room[i][j].down then room[i][j]:onLeave()
					else room[i][j]:onEnter() end
				end
			end
		end
		return true
	end
	return false
end

P.lenny = P.character:new{name = "Lenny", description = "The Ghost Snail", slime = false, sprite = love.graphics.newImage('Graphics/lenny.png')}
function P.lenny:onCharLoad()
	tools.giveToolsByReference({tools.wings,tools.broom,tools.broom})
end
function P.lenny:onFloorEnter()
	tools.wings.numHeld = tools.wings.numHeld+1
	tools.broom.numHeld = tools.broom.numHeld+1
end
function P.lenny:onKeyPressed(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		slime = not slime
		return true
	end
	return false
end
function P.lenny:onTileLeave()
	if slime then
		if room[player.prevTileY][player.prevTileX]==nil or
			(room[player.prevTileY][player.prevTileX]:instanceof(tiles.wire) and room[player.prevTileY][player.prevTileX].destroyed) then
			room[player.prevTileY][player.prevTileX]=tiles.conductiveSlime:new()
			updateGameState(false)
		end
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
P[10] = P.crate
P[11] = P.giovanni
P[12] = P.francisco
P[13] = P.tim
P[14] = P.orson
P[15] = P.lenny
P[16] = P.random

return characters