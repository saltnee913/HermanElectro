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
		local isLocked = (characters[i].disabled == true)
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

P.character = Object:new{name = "Name", scale = 0, sprite = love.graphics.newImage('Graphics/herman_sketchanother.png'),
  description = "description", startingTools = {0,0,0,0,0,0,0}, scale = 0.25 * width/1200, forcePowerUpdate = false, winUnlocks = {}, tint = {0,0,0},
  speedUnlockTime = 1000, speedUnlock = nil}
function P.character:onBegin()
	self.tint = {0,0,0}
    myShader:send("tint_r", self.tint[1])
    myShader:send("tint_g", self.tint[2])
    myShader:send("tint_b", self.tint[3])
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
function P.character:postMove()
end
function P.character:onTileLeave()
end
function P.character:onPostUpdatePower()
end
function P.character:onPostUpdateLight()
end
function P.character:getInfoText()
	return ""
end
function P.character:onRoomCompletion()
end
function P.character:onFailedMove()
end

P.herman = P.character:new{name = "Herman", description = "The Electrician", winUnlocks = {unlocks.reviveUnlock}, scale = 0.3}
function P.herman:onCharLoad()
	if loadTutorial then return end
	tools.giveToolsByReference({tools.revive,tools.revive})
end

P.felix = P.character:new{name = "Felix", description = "The Sharpshooter", winUnlocks = {unlocks.missileUnlock}, speedUnlocks = {unlocks.superGunUnlock}, sprite = love.graphics.newImage('Graphics/felix.png'), startingTools = {0,0,0,0,0,0,1}}
function P.felix:onCharLoad()
	tools[7] = tools.felixGun
	if not tools.felixGun.isGun then
		tools.felixGun:switchEffects()
	end
	tools.giveToolsByReference({tools.bomb})
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
  sprite = love.graphics.newImage('GraphicsTony/Ben.png'), scale = 0.7 * width/1200, disabled = true}
function P.most:onCharLoad()
	if map.floorOrder == map.defaultFloorOrder then
		map.floorOrder = {'RoomData/bigfloor.json', 'RoomData/floor6.json'}
	end
end

local erikSprite = love.graphics.newImage('Graphics/beggar.png')
P.erik = P.character:new{name = "Erik", description = "The Quick",
  sprite = erikSprite, scale = scale*16/erikSprite:getWidth(), tint = {0.4,0.4,0.4}}

function P.erik:onCharLoad()
	gameTime.timeLeft = 60
	gameTime.roomTime = 10
	gameTime.levelTime = 0
	map.floorOrder = {'RoomData/floor1_erik.json', 'RoomData/floor2_erik.json', 'RoomData/floor3_erik.json', 'RoomData/floor6.json'}
end

P.gabe = P.character:new{name = "Gabe", description = "The Angel",
	sprite = love.graphics.newImage('Graphics/gabe.png'), realChar = nil, reset = false, disabled = true}
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

P.rammy = P.character:new{name = "Rammy", description = "The Ram", winUnlocks = {unlocks.ramUnlock},
	sprite = love.graphics.newImage('Graphics/ram.png')}

function P.rammy:preTileEnter(tile)
	if tile.name == tiles.wall.name and not tile.destroyed then
		tile:destroy()
	end
end

P.rick = P.character:new{name = "Rick", description = "The Gambler", sprite = love.graphics.newImage('Graphics/rick.png'), disabled = true}
function P.rick:onCharLoad()
	tools.giveToolsByReference({tools.toolReroller,tools.toolReroller,tools.toolReroller,tools.roomReroller})
end
function P.rick:onFloorEnter()
	for i = 1, tools.numNormalTools do
		if tools[i].numHeld>0 then
			tools[i].numHeld=0
		end
	end
end

--alternative name: "Froggy, the Fresh"
P.frederick = P.character:new{name = "Frederick", description = "The Frog", sprite = love.graphics.newImage('Graphics/frederick.png'), disabled = false}
function P.frederick:onCharLoad()
	tools.giveToolsByReference({tools.spring,tools.spring,tools.spring,tools.spring,tools.visionChanger,tools.visionChanger})
end
function P.frederick:onFloorEnter()
	tools.giveToolsByReference({tools.spring,tools.spring,tools.visionChanger})
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

P.nadia = P.character:new{name = "Nadia", description = "The Naturalist", sprite = love.graphics.newImage('Graphics/nadia.png'), disabled = true}
function P.nadia:onCharLoad()
	tools.giveToolsByReference({tools.meat})
	player.safeFromAnimals = true
end

P.chell = P.character:new{name = "Chell", description = "New Carla", sprite = love.graphics.newImage('Graphics/carlaperson.png')}
function P.chell:onFailedMove(key)
	if key=="w" then
		if player.tileY==1 and (room[roomHeight][player.tileX]==nil or not room[roomHeight][player.tileX].blocksMovement) then
			player.tileY = roomHeight
		end
	elseif key=="a" then
		if player.tileX==1 and (room[player.tileY][roomLength]==nil or not room[player.tileY][roomLength].blocksMovement) then
			player.tileX = roomLength
		end
	elseif key=="s" then
		if player.tileY==roomHeight and (room[1][player.tileX]==nil or not room[1][player.tileX].blocksMovement) then
			player.tileY = 1
		end
	elseif key=="d" then
		if player.tileX==roomLength and (room[player.tileY][1]==nil or not room[player.tileY][1].blocksMovement) then
			player.tileX = 1
		end
	end
end

P.crate = P.character:new{name = "Carla", roomTrigger = false, description = "The Crate", isCrate = false, 
  winUnlocks = {unlocks.conditionalBoxes}, speedUnlock = unlocks.conductiveBoxes,
  sprite = love.graphics.newImage('Graphics/carlaperson.png'),
  humanSprite = love.graphics.newImage('Graphics/carlaperson.png'), crateSprite = love.graphics.newImage('Graphics/carlabox.png'), disabled = true}
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
	tools.giveToolsByReference({tools.pitbullChanger,tools.pitbullChanger})
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
			updateGameState(false)
		end
	end
end

P.francisco = P.character:new{name = "Francisco", description = "The Cartographer", nextRoom = {yLoc = -1, xLoc = -1}, sprite = love.graphics.newImage('Graphics/francisco.png')}
function P.francisco:onCharLoad()
	tools.giveToolsByReference({tools.map})
end
function P.francisco:onFloorEnter()
	tools.giveToolsByReference({tools.map})
end

P.random = P.character:new{name = "Random", description = "", sprite = love.graphics.newImage('Graphics/random.png')}
function P.random:onBegin()
	local charsToSelect = characters.getUnlockedCharacters()
	local charSlot = util.random(#charsToSelect-1, 'misc')
	player.character = charsToSelect[charSlot]:new()
	player.character:onBegin()
end

P.tim = P.character:new{name = "Tim", description = "The Box Summoner", sprite = love.graphics.newImage('Graphics/tim.png'), disabled = true}
function P.tim:onCharLoad()
	tools.giveToolsByReference({tools.ramSpawner,tools.boxSpawner,tools.boomboxSpawner})
end

P.orson = P.character:new{name = "Orson", shifted = false, description = "The Mastermind", 
  winUnlocks = {unlocks.buttonFlipperUnlock}, speedUnlock = {unlocks.poweredEndUnlock}, sprite = love.graphics.newImage('Graphics/orson.png')}
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
	tools.giveToolsByReference({tools.wings,tools.broom,tools.broom})
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

P.fish = P.character:new{name = "Fish", description = "Fish", 
  winUnlocks = {unlocks.toolDoublerUnlock}, speedUnlockTime = 1600, speedUnlock = unlocks.fogUnlock,
  life = 100, sprite = love.graphics.newImage('Graphics/fish.png'), tint = {0,0,0.4}}
function P.fish:postMove()
	self.life = self.life-1
	if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX]:instanceof(tiles.puddle) then
		self.life = 100
	end
	if self.life<=0 then
		kill()
	end
end
function P.fish:onCharLoad()
	tools.giveToolsByReference({tools.waterBottle, tools.waterBottle, tools.waterBottle, tools.bucketOfWater, tools.bucketOfWater, tools.bucketOfWater, tools.bucketOfWater, tools.bucketOfWater})
	self.life = 100
end
function P.fish:onFloorEnter()
	tools.giveToolsByReference({tools.waterBottle, tools.waterBottle, tools.waterBottle, tools.bucketOfWater, tools.bucketOfWater, tools.bucketOfWater, tools.bucketOfWater, tools.bucketOfWater})
end
function P.fish:getInfoText()
	return self.life
end
function P.fish:onToolUse()
	if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX]:instanceof(tiles.puddle) then
		self.life = 100
	end
	if self.life<=0 then
		kill()
	end
end

P.monk = P.character:new{name = "Monte", description = "The Blind Monk", sprite = love.graphics.newImage('Graphics/monk.png')}
function P.monk:onCharLoad()
	--[[for i = 1, 3 do
		self.tint[i] = 0.46
	end
	myShader:send("tint_r", self.tint[1])
    myShader:send("tint_g", self.tint[2])
    myShader:send("tint_b", self.tint[3])]]
	--tools.giveToolsByReference({tools.lamp, tools.lamp, tools.lamp, tools.lamp, tools.lamp, tools.lamp, tools.delectrifier})
end
function P.monk:onFloorEnter()
	--[[for i = 1, 3 do
		self.tint[i] = 0
	end
	myShader:send("tint_r", self.tint[1])
    myShader:send("tint_g", self.tint[2])
    myShader:send("tint_b", self.tint[3])]]
	--tools.giveToolsByReference({tools.lamp, tools.lamp, tools.lamp, tools.lamp, tools.lamp, tools.lamp, tools.delectrifier})
end
function P.monk:postMove()
	if completedRooms[mapy][mapx]==1 then
		self.tint = {0,0,0}
		room.tint = {0,0,0}
	else
		for i = 1, 3 do
			if self.tint[i]==0 then
				self.tint[i]=0.01
			end
			self.tint[i] = self.tint[i]+(1-self.tint[i])/30
			if self.tint[i]>0.4 then self.tint[i] = 0.4 end
		end
		room.tint = self.tint
	end
	myShader:send("tint_r", self.tint[1])
	myShader:send("tint_g", self.tint[2])
	myShader:send("tint_b", self.tint[3])
end
function P.monk:onRoomEnter()
	self.tint = room.tint
	myShader:send("tint_r", self.tint[1])
	myShader:send("tint_g", self.tint[2])
	myShader:send("tint_b", self.tint[3])
end
function P.monk:onRoomCompletion()
	self.tint = {0,0,0}
	room.tint = {0,0,0}
	while (tools.lamp.numHeld<3) do
		tools.giveToolsByReference({tools.lamp})
	end
end

P.random2 = P.character:new{name = "Random2", allowedCharacters = {1,2,6,8,9,11,12,14}, description = "**RanDOm**", sprite = love.graphics.newImage('Graphics/random.png'), disabled = true}
function P.random2:onRoomEnter()
	local charNum = util.random(#self.allowedCharacters, 'misc')
	if room.character==nil then
		player.character = characters[charNum]
		player.character.onRoomEnter = self.onRoomEnter
		player.character.allowedCharacters = self.allowedCharacters
		room.character = player.character
	else
		player.character = room.character
	end
end
function P.random2:postMove()
	if room.character==nil then
		room.character = player.character
	end
end

P.harriet = P.character:new{name = "Harriet", description = "Herman in drag", sprite = love.graphics.newImage('Graphics/nadia.png')}

P[1] = P.herman
P[2] = P.felix
P[3] = P.most
P[4] = P.erik
P[5] = P.gabe
P[6] = P.rammy
P[7] = P.rick
P[8] = P.frederick
P[9] = P.battery
P[10] = P.chell
P[11] = P.giovanni
P[12] = P.francisco
P[13] = P.tim
P[14] = P.orson
P[15] = P.lenny
P[16] = P.fish
P[17] = P.monk
P[18] = P.harriet
P[19] = P.crate

P[#P+1] = P.random
P[#P+1] = P.random2

return characters