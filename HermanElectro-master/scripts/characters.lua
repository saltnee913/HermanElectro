require('scripts.object')
unlocks = require('scripts.unlocks')

local P = {}
characters = P

function P.getUnlockedCharacters()
	local unlockedChars = {}
	for i = 1, #characters do
		if P.isCharacterUnlocked(characters[i].name) then
			unlockedChars[#unlockedChars+1] = characters[i]
		end
	end
	return unlockedChars
end

function P.getUnlockedCharacter(charName)
	for i = 1, #characters do
		if characters[i].name == charName then
			return P.isCharacterUnlocked(charName) and characters[i] or nil
		end
	end
	return nil
end

function P.isCharacterUnlocked(charName)
	for i = 1, #unlocks do
		unlock = unlocks[i]
		if not unlock.unlocked and unlock.charIds ~= nil then
			for i = 1, #unlock.charIds do
				if unlock.charIds[i] == charName then
					return false
				end
			end
		end
	end
	return true
end

P.character = Object:new{name = "Name", tallSprite = true, dirFacing = "down", scale = 1, sprite = 'Graphics/Characters/Herman.png',
  description = "description", startingTools = {0,0,0,0,0,0,0}, scale = 0.25 * width/1200, randomOption = true, forcePowerUpdate = false, tint = {1,1,1}, winUnlocks = {},
  animationTimer = 0, animationLength = 0, crime = ""}
function P.character:onBegin()
    --[[myShader:send("tint_r", self.tint[1])
    myShader:send("tint_g", self.tint[2])
    myShader:send("tint_b", self.tint[3])]]
	self:setStartingTools()
	self:onCharLoad()
end
function P.character:setStartingTools()
	for i = 1, tools.numNormalTools do
		tools[i].numHeld = self.startingTools[i]
	end
end
function P.character:onStartGame()
end
function P.character:onCharLoad()
end
function P.character:onSelect()
end
function P.character:onRoomEnter()
end
function P.character:onFloorEnter()
end
function P.character:onPreUpdatePower()

end
function P.character:onPostUpdatePower()
end
function P.character:onKeyPressed(key)
	if self.sprites ~= nil then
		if key == 'w' then
			self.dirFacing = "up"
			self.sprite = self.sprites[1]
		end
		if key == 'd' then
			self.dirFacing = "right"
			self.sprite = self.sprites[2]
		end
		if key == 's' then
			self.dirFacing = "down"
			self.sprite = self.sprites[3]
		end
		if key == 'a' then
			self.dirFacing = "left"
			self.sprite = self.sprites[4]
		end
	end
	if key == "d" then player.dirFacing = 1
	elseif key == "a" then player.dirFacing = -1 end
	return self:onKeyPressedChar(key)
end
function P.character:onKeyPressedChar(key)
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
function P.character:onPostUpdateLight()
end
function P.character:getInfoText()
	return ""
end
function P.character:onRoomCompletion()
end
function P.character:onFailedMove()
end
function P.character:specialLightTest(tileY,tileX)
end
function P.character:immediatePostMove()
end
function P.character:update()
end
function P.character:absoluteFinalUpdate()
end
function P.character:bypassObstructsMovement(tile)
	return false
end
function P.character:onUpdateTools()
end
function P.character:updateAnimation(dt)
	if self.animation ~= nil then
		self.animationTimer = self.animationTimer + dt
		if self.animationTimer > self.animationLength then self.animationTimer = self.animationTimer - self.animationLength end
		self.sprite = self.animation[math.ceil(#self.animation*self.animationTimer/self.animationLength)]
	end
end

P.herman = P.character:new{name = "Herman", description = "The Electrician", 
  scale = 1.1*scale, sprites = {'Graphics/Characters/Herman.png', 'Graphics/Characters/Herman.png', 'Graphics/Characters/Herman.png', 'Graphics/Characters/Herman.png'},
  animation = {'Graphics/Characters/Herman.png','Graphics/Characters/Herman.png','Graphics/Characters/Herman.png','Graphics/Characters/Herman.png'},
  animationLength = 1,
  crime = "Life Imprisonment for Attempted Circuit Break"}
function P.herman:onCharLoad()
	if loadTutorial then return end
	tools.giveToolsByReference({tools.revive})
	myShader:send("player_range", 600)
end

P.felix = P.character:new{name = "Felix", description = "The Sharpshooter", sprite = 'Graphics/felix.png', startingTools = {0,0,0,0,0,0,1},
crime = "Ten Years for Pyromanic Episode"}
function P.felix:onCharLoad()
	--tools[7] = tools.felixGun
	--if not tools.felixGun.isGun then
		--tools.felixGun:switchEffects()
	--end
	tools.giveToolsByReference({tools.bomb, tools.gun})
end
function P.felix:onKeyPressedChar(key)
	--log(key)
	--[[if key == 'rshift' or key == 'lshift' or key == 'shift' then
		tools.felixGun:switchEffects()
		tools.updateToolableTiles(tool)
		return true
	end]]
	return false
end
function P.felix:onFloorEnter()
	--tools.giveTools({7,7})
end

P.most = P.character:new{name = "Ben", description = "The Explorer",
  sprite = 'Graphics/Characters/Ben.png', scale = 0.7 * width/1200, disabled = true}
function P.most:onCharLoad()
	if map.floorOrder == map.defaultFloorOrder then
		map.floorOrder = {'RoomData/bigfloor.json', 'RoomData/floor6.json'}
	end
end

local erikSprite = 'Graphics/Characters/Erik.png'
P.erik = P.character:new{name = "Erik", tallSprite = false, description = "The Quick",
  sprite = erikSprite, scale = scale*1.1,
  crime = "Life Imprisonment for Illegal Drug Consumption"}
function P.erik:onCharLoad()
	gameTime.timeLeft = 120
	gameTime.roomTime = 15
	gameTime.levelTime = 0
	gameTime.goesDownInCompleted = true
	tools.giveToolsByReference({tools.stopwatch})
	--map.floorOrder = {'RoomData/floor1_erik.json', 'RoomData/floor2_erik.json', 'RoomData/floor3_erik.json', 'RoomData/floor6.json'}
end
--[[function P.erik:onFailedMove(key)
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
function P.erik:specialLightTest(tileY,tileX)
	if tileX == 1 then
		lightTest(tileY,roomLength)
	end
	if tileX == roomLength then
		lightTest(tileY,1)
	end
	if tileY == 1 then
		lightTest(roomHeight,tileX)
	end
	if tileY == roomHeight then
		lightTest(1,tileX)
	end
end]]

P.gabe = P.character:new{name = "Gabe", tallSprite = false, description = "The Angel",
	sprite = 'Graphics/gabe.png', realChar = nil, randomOption = false, reset = false,
	crime = "Free"}
function P.gabe:onCharLoad()
	if not self.reset then
		player.attributes.flying = true
		self.reset = true
	elseif self.realChar ~= nil and not self.realChar:instanceof(P.gabe) then
		player.character = self.realChar
		player.character:onBegin()
		self.realChar = nil
		self.reset = false
	end
end
function P.gabe:onRoomEnter()
	player.attributes.flying = true
end

P.rammy = P.character:new{name = "Rammy", tallSprite = false, description = "The Ram",
	sprite = 'Graphics/ram.png'}

function P.rammy:preTileEnter(tile)
	if tile.name == tiles.wall.name and not tile.destroyed and player.elevation<tile:getHeight()-3 then
		tile:destroy()
	end
end

--alternative name: "Froggy, the Fresh"
P.frederick = P.character:new{name = "Frederick", tallSprite = false, description = "The Frog",
sprite = 'Graphics/Characters/Frederick.png', scale = 1.1*scale, disabled = false}
function P.frederick:onCharLoad()
	tools.giveToolsByReference({tools.spring,tools.spring,tools.spring,tools.spring,tools.visionChanger,tools.visionChanger})
end
function P.frederick:onFloorEnter()
	--tools.giveToolsByReference({tools.spring})
end

P.battery = P.character:new{name = "Bob", tallSprite = false, description = "The Battery",
sprite = 'Graphics/Characters/Bob.png',
  onSprite = 'Graphics/Characters/BobPowered.png', offSprite = 'Graphics/Characters/Bob.png', 
  scale = scale*1.2, storedTile = nil, forcePowerUpdate = false, powered = false}
function P.battery:onKeyPressedChar(key)
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

P.giovanni = P.character:new{name = "Giovanni", description = "The Sorcerer", shiftPos = {x = -1, y = -1, z = -1},
sprite = 'Graphics/Characters/Giovanni.png', sprite2 = 'Graphics/Characters/GiovanniGhost.png', scale = 1.1*scale}
function P.giovanni:onKeyPressedChar(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		if self.shiftPos.x==-1 then
			self.shiftPos.x = player.tileX
			self.shiftPos.y = player.tileY
			self.shiftPos.z = player.elevation
			log("Clone spawned!")
		else
			player.tileX = self.shiftPos.x
			player.tileY = self.shiftPos.y
			self.shiftPos = {x = -1, y = -1, z = -1}
			log("Returned to clone!")
		end
	end
end
function P.giovanni:onCharLoad()
	self.shiftPos = {x = -1, y = -1, z = -1}
end
function P.giovanni:onRoomEnter()
	self.shiftPos = {x = -1, y = -1, z = -1}
end
P.giovanni.onFloorEnter = P.giovanni.onRoomEnter

P.francisco = P.character:new{name = "Francisco", description = "The Cartographer", nextRoom = {yLoc = -1, xLoc = -1},
sprite = 'Graphics/Characters/Francisco.png', scale = 1.1*scale}
function P.francisco:onCharLoad()
	tools.giveToolsByReference({tools.coin})
end

P.random = P.character:new{name = "Random", description = "", sprite = 'Graphics/Characters/Random.png', scale = 1.1*scale}
function P.random:onBegin()
	local charsToSelect = characters.getUnlockedCharacters()
	local charSlot = 0
	while (charSlot==0 or not charsToSelect[charSlot].randomOption) do
		charSlot = util.random(#charsToSelect-1, 'misc')
	end
	player.character = charsToSelect[charSlot]:new()
	player.character:onBegin()
end

P.orson = P.character:new{name = "Orson", shifted = false, description = "The Mastermind", sprite = 'Graphics/orson.png', disabled = true}
function P.orson:onCharLoad()
	tools.brick.range = 100
end
function P.orson:onPostUpdatePower()
	self.shifted = false
end
function P.orson:onKeyPressedChar(key)
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

P.lenny = P.character:new{name = "Lenny", tallSprite = false, description = "The Ghost Snail", slime = false, sprite = 'Graphics/Characters/Lenny.png', scale = 1.1*scale}
function P.lenny:onKeyPressedChar(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		self.slime = not self.slime
		return true
	end
	return false
end
function P.lenny:onTileLeave()
	if self.slime then
		if room[player.prevTileY][player.prevTileX]==nil
		or (room[player.prevTileY][player.prevTileX]:instanceof(tiles.wire) and room[player.prevTileY][player.prevTileX].destroyed)
		or (room[player.prevTileY][player.prevTileX]:instanceof(tiles.electricFloor) and room[player.prevTileY][player.prevTileX].destroyed)
		or (room[player.prevTileY][player.prevTileX]:instanceof(tiles.wall) and room[player.prevTileY][player.prevTileX].destroyed) then
			room[player.prevTileY][player.prevTileX]=tiles.conductiveSlime:new()
			updateGameState(false)
		end
	end
end
function P.lenny:onStartGame()
	self.slime = false
end

P.fish = P.character:new{name = "Fish", tallSprite = false, description = "Fish", 
  life = 100, sprite = 'Graphics/Characters/Fish.png', tint = {0.9,0.9,1}, scale = 1.1*scale,
	animation = {'Graphics/Characters/Fish.png','Graphics/Characters/Fish.png','Graphics/Characters/Fish.png','Graphics/Characters/FishMouthClosed.png','Graphics/Characters/FishMouthFullyClosed.png','Graphics/Characters/FishMouthClosed.png', 'Graphics/Characters/Fish.png','Graphics/Characters/Fish.png','Graphics/Characters/Fish.png'},
  animationLength = 1,
  crime = "15 Years for Failing to Climb Trees"}
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

P.xavier = P.character:new{name = "Xavier", description = "The Sock Ninja", sockMode = false,
sprite = 'Graphics/Characters/Eli.png', sockSprite = 'Graphics/Characters/EliSock.png',
noSockSprite = 'Graphics/Characters/Eli.png', scale = 1.1*scale}
function P.xavier:onKeyPressedChar(key)
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		self.sockMode = not self.sockMode
		if player.attributes.sockStep then
			self.sockMode = false
		end
		if not self.sockMode then
			player.attributes.sockStep = false
			forcePowerUpdateNext = true
		end
	end
	if self.sockMode then
		player.attributes.sockStep = true
	end
	self:updateSprite()
	return false
end
function P.xavier:absoluteFinalUpdate()
	self:updateSprite()
end
function P.xavier:updateSprite()
	if self.sockMode or player.attributes.sockStep then
		self.sprite = self.sockSprite
	else
		self.sprite = self.noSockSprite
	end
end
function P.xavier:onRoomEnter()
	self.sockMode = false
end

P.aurelius = P.character:new{name = "Aurelius", description = "The Golden",
sprite = 'Graphics/Characters/Aurelius.png', scale = 1.1*scale}
function P.aurelius:onFloorEnter()
	for i = 1, tools.numNormalTools do
		for j = 1, tools[i].numHeld do
			tools.giveToolsByReference{tools.coin}
		end
		tools[i].numHeld = 0
	end
end

P.witch = P.character:new{name = "Nellie", description = "The Witch", humanLoc = {x = 0, y = 0}, catLoc = {x = 0, y = 0},
humanMode = true, sprite = 'Graphics/Characters/Arachne.png',
humanSprite = 'Graphics/Characters/Arachne.png', catSprite = 'Graphics/cat.png', scale = 1.1*scale}
function P.witch:onSelect()
	self.humanLoc = {x = player.tileX, y = player.tileY}
	self.catLoc = {x = player.tileX, y = player.tileY}	
end
function P.witch:onRoomEnter()
	self.humanLoc = {x = player.tileX, y = player.tileY}
	self.catLoc = {x = player.tileX, y = player.tileY}		
end
P.witch.onFloorEnter = P.witch.onRoomEnter
P.witch.onCharLoad = P.witch.onFloorEnter
function P.witch:onKeyPressedChar(key)
	if self.humanMode then
			self.humanLoc = {x = player.tileX, y = player.tileY}
	else
		self.catLoc = {x = player.tileX, y = player.tileY}
	end
	if key == 'rshift' or key == 'lshift' or key == 'shift' then
		self.humanMode = not self.humanMode
		if self.humanMode then
			player.tileX = self.humanLoc.x
			player.tileY = self.humanLoc.y
		else
			player.tileX = self.catLoc.x
			player.tileY = self.catLoc.y
		end
		self:updateSprite()
	end
	return true
end
function P.witch:updateSprite()
	if self.humanMode then
		self.sprite = self.humanSprite
	else
		self.sprite = self.catSprite
	end
end

P.scientist = P.character:new{name = "Marie", description = "The Scientist", 
  sprite = 'Graphics/Characters/Sciencewoman.png', jekyllSprite = 'Graphics/Characters/Sciencewoman.png', hydeSprite = 'Graphics/Characters/MrHyde.png',
  powerSprite = 'Graphics/Characters/ShockedSciencewoman.png', powerHydeSprite = 'Graphics/Characters/ShockedMrHyde.png',
  scale = 1.1*scale, hyde = false, pulsing = false, pulsingTimer = 0, pulsingTime = 2,
  powered = false, storedTile = nil,
  crime = "25 Years for Excessive Experimentation"}
function P.scientist:onCharLoad()
	for i = tools.numNormalTools+1, #tools do
		tools[i].isDisabled = true
	end
	tools[tools.opPotion.toolid].isDisabled = false
	tools[tools.bombPotion.toolid].isDisabled = false
	tools[tools.electricPotion.toolid].isDisabled = false
	tools[tools.teleportPotion.toolid].isDisabled = false
	tools[tools.shittyPotion.toolid].isDisabled = false
	self.pulsing = false
	self.hyde = false
	tools.giveToolsByReference({tools.shittyPotion, tools.teleportPotion, tools.electricPotion})
end
function P.scientist:electrify()
	self.pulsing = true
	self.forcePowerUpdate = true
end
function P.scientist:deelectrify()
	self.pulsing = false
	self.forcePowerUpdate = false
	self.powered = false
	self.sprite = self.hyde and self.hydeSprite or self.jekyllSprite
end
function P.scientist:update(dt)
	if self.pulsing then
		self.pulsingTimer = self.pulsingTimer + dt
		if self.pulsingTimer % self.pulsingTime < self.pulsingTime/2 then
			self.sprite = self.hyde and self.powerHydeSprite or self.powerSprite
			self.powered = true
			updateGameState(false, false)
			checkAllDeath()
		else
			self.sprite = self.hyde and self.hydeSprite or self.jekyllSprite
			self.powered = false
			updateGameState(false, false)
			checkAllDeath()
		end
	end
end
function P.scientist:onPreUpdatePower()
	if self.powered then
		if room[player.tileY][player.tileX] ~= nil then
			self.storedTile = room[player.tileY][player.tileX]
			self.storedTile.powered = true
		else
			self.storedTile = nil
		end
		room[player.tileY][player.tileX] = tiles.powerSupply:new()
	end
end
function P.scientist:onPostUpdatePower()
	if self.powered then
		room[player.tileY][player.tileX] = self.storedTile
	end
end
function P.scientist:transform()
	self.hyde = true
	self.sprite = (self.pulsing and self.powered) and self.powerHydeSprite or self.hydeSprite
	player.attributes.flying = true
	self.forcePowerUpdate = true

end
function P.scientist:transformBack()
	self.hyde = false
	self.sprite = (self.pulsing and self.powered) and self.powerSprite or self.jekyllSprite
	player.attributes.flying = false
	self.forcePowerUpdate = false
end
function P.scientist:preTileEnter(tile)
	if self.hyde then
		tile:destroy()
	end
end
function P.scientist:postMove()
	if self.hyde then
		for i = 1, #animals do
			if animals[i].tileY == player.tileY and animals[i].tileX == player.tileX then
				animals[i]:kill()
			end
		end
		for i = 1, #pushables do
			if pushables[i].tileY == player.tileY and pushables[i].tileX == player.tileX then
				pushables[i]:destroy()
			end
		end
	end
end
function P.scientist:onRoomEnter()
	if self.hyde then
		self:transformBack()
	end
	if self.pulsing then
		self:deelectrify()
	end
end
function P.scientist:bypassObstructsMovement(tile)
	return self.hyde
end

P.dragon = P.character:new{name = "Dragon", description = "The One-Winged Beast", sprite = 'Graphics/Characters/Arachne.png',
	scale = 1.1*scale, canHoldBasics = false, crime = "Solitary Confinement -- DO NOT LET OUT"}
function P.dragon:onCharLoad()
	for i = tools.numNormalTools+1, #tools do
		tools[i].isDisabled = true
	end
	tools[tools.fireBreath.toolid].isDisabled = false
	tools[tools.claw.toolid].isDisabled = false
	tools[tools.wing.toolid].isDisabled = false
	tools[tools.coin.toolid].isDisabled = false
	tools[tools.dragonEgg.toolid].isDisabled = false
	tools[tools.dragonFriend.toolid].isDisabled = false
	tools[tools.roomUnlocker.toolid].isDisabled = false
end
function P.dragon:onUpdateTools()
	--check if any non-acceptable tools
	local isAcceptable = true
	for i = 1, tools.numNormalTools do
		if tools[i].numHeld > 0 then
			isAcceptable = false
		end
	end
	if isAcceptable then return end


	local fireGive = tools.saw.numHeld+tools.ladder.numHeld+tools.gun.numHeld
	local clawGive = tools.wireCutters.numHeld+tools.waterBottle.numHeld+tools.brick.numHeld+tools.sponge.numHeld
	--reset tool display
	tools.toolsShown = {}

	for i = 1, tools.numNormalTools do
		tools[i].numHeld = 0
	end

	for i = 1, fireGive do
		tools.giveToolsByReference({tools.fireBreath})
	end
	for i = 1, clawGive do
		tools.giveToolsByReference({tools.claw})
	end
end

P.knight = P.character:new{name = "Knight", description = "The Helmeted Hero", sprite = 'Graphics/Characters/Arachne.png',
	scale = 1.1*scale, crime = "7 Years for Misplaced Chivalry"}
function P.knight:onCharLoad()
	if loadTutorial then return end
	tools.giveToolsByReference({tools.diagonal})
	myShader:send("player_range", 600)
end

P[#P+1] = P.herman
P[#P+1] = P.francisco
P[#P+1] = P.aurelius
P[#P+1] = P.rammy
P[#P+1] = P.frederick
P[#P+1] = P.lenny
P[#P+1] = P.xavier
P[#P+1] = P.giovanni
P[#P+1] = P.felix
P[#P+1] = P.battery
P[#P+1] = P.erik
P[#P+1] = P.fish
P[#P+1] = P.scientist
P[#P+1] = P.dragon
P[#P+1] = P.knight

P[#P+1] = P.gabe

P[#P+1] = P.random

return characters