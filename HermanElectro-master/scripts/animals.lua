require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
animalList = P

width2, height2 = love.graphics.getDimensions()
if width2>height2*16/9 then
	height = height2
	width = height2*16/9
else
	width = width2
	height = width2*9/16
end
wallSprite = {width = 187*width/1920, height = 170*height/1080, heightBottom = 150*height/1080}
scale = (width - 2*wallSprite.width)/(20.3 * 16)*5/6
--floor = tiles.tile

--speed same as player (250)
P.animal = Object:new{elevation = 0, scale = scale, yOffset = 0, frozen = false, trained = false, conductive = false, pickedUp = false, canDropTool = false, willDropTool = false, flying = false, triggered = false, waitCounter = 1, dead = false, name = "animal", tileX, tileY, prevx, prevy, prevTileX, prevTileY, x, y, speed = 250, width = 16*scale, height = 16*scale, sprite = 'Graphics/pitbull.png', deadSprite = 'Graphics/pitbulldead.png', tilesOn = {}, oldTilesOn = {}}
function P.animal:move(playerx, playery, room, isLit)
	if player.attributes.shelled or player.attributes.invisible then
		return
	elseif player.attributes.fear then
		self:afraidPrimaryMove(playerx, playery, room, isLit)
		return
	elseif room[playery][playerx]~=nil and room[playery][playerx].scaresAnimals then
		self:afraidPrimaryMove(playerx, playery, room, isLit)
		return
	end
	if self.dead or (not isLit and not self.triggered) or self.frozen then
		return
	end
	self.triggered = true
	self.prevTileX = self.tileX
	self.prevTileY = self.tileY
	if self.waitCounter>0 then
		return
	end
	
	if playerx-self.tileX==0 and playery-self.tileY==0 then
		return
	end

	if not self:primaryMove(playerx, playery) then
		self:secondaryMove(playerx, playery)
	end
end
function P.animal:moveOverride(movex, movey)
	return {x = movex, y = movey}
end
function P.animal:primaryMove(playerx, playery)
	local diffx = math.abs(playerx - self.tileX)
	local diffy = math.abs(playery - self.tileY)

	if diffx>diffy then
		if playerx>self.tileX then
			self.tileX = self.tileX+1
		else
			self.tileX = self.tileX-1
		end
	else
		if playery>self.tileY then
			self.tileY = self.tileY+1
		else
			self.tileY = self.tileY-1
		end
	end
	if room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:obstructsMovementAnimal(self) then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return false
	elseif room[self.tileY][self.tileX]==nil and math.abs(self.elevation)>3 then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return false		
	end
	if not self:pushableCheck() then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
		return false
	end
	return true
end
function P.animal:pushableCheck()
	if not (self.prevTileY == self.tileY and self.prevTileX == self.tileX) then
		for i = 1, #pushables do
			if pushables[i].tileX == self.tileX and pushables[i].tileY == self.tileY then
				if not pushables[i]:animalCanMove() or not pushables[i]:move(self) then
					return false
				end
			end
		end
	end
	return true
end

function P.animal:secondaryMove(playerx, playery)
	if player.character.name == "Leonard" and player.character.scaryMode == true then
		self:afraidSecondaryMove(playerx, playery)
		return
	end
	local diffx = math.abs(playerx - self.tileX)
	local diffy = math.abs(playery - self.tileY)

	if diffy>=diffx and not (self.tileX==playerx) then
		if playerx>self.tileX then
			self.tileX = self.tileX+1
		else
			self.tileX = self.tileX-1
		end
	elseif (self.tileY~=playery) then
		if playery>self.tileY then
			self.tileY = self.tileY+1
		else
			self.tileY = self.tileY-1
		end
	end

	if room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:obstructsMovementAnimal(self) then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return false
	elseif room[self.tileY][self.tileX]==nil and math.abs(self.elevation)>3 then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return false		
	end

	if not self:pushableCheck() then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
		return false
	end

	return true
end

function P.animal:checkDeath()
	if room[self.tileY]~=nil and room[self.tileY][self.tileX]~=nil then
		t = room[self.tileY][self.tileX]
		if self.dead == false and t:willKillAnimal() then
			self:kill()
			if t:instanceof(tiles.vPoweredDoor) then
				unlocks.unlockUnlockableRef(unlocks.doorUnlock)
			end
			if room[self.tileY][self.tileX]:instanceof(tiles.pit) or room[self.tileY][self.tileX]:instanceof(tiles.poweredFloor) then
				local animalsInPit = 0
				for i = 1, #animals do
					if animals[i].tileY == self.tileY and animals[i].tileX == self.tileX then
						animalsInPit = animalsInPit+1
					end
				end
				if animalsInPit>=2 then
					unlocks.unlockUnlockableRef(unlocks.breakablePitUnlock)
				end
			end
		end
	end
	for i = 1, #animals do
		if animals[i].trained and not animals[i].dead and animals[i]~=self and
		animals[i].tileX==self.tileX and animals[i].tileY==self.tileY then
			self:kill()
		end
	end
end
function P.animal:hasMoved()
	return self.prevTileX ~= self.tileX or self.prevTileY ~= self.tileY
end
function P.animal:onNullLeave(tileY, tileX)
	return room[tileY][tileX]
end
function P.animal:kill()
	self.dead = true
	self.sprite = self.deadSprite
	if self.canDropTool and not self.willDropTool then
		local bonusDropChance = util.random(35, 'toolDrop')
		if bonusDropChance<=getLuckBonus() then
			self.willDropTool = true
		end
	end
	if self.willDropTool then
		if(room[self.tileY][self.tileX]==nil or room[self.tileY][self.tileX].destroyed
		or room[self.tileY][self.tileX]:usableOnNothing() or room[self.tileY][self.tileX].overlay==nil) then
			self:dropTool()
		end
	end
end
function P.animal:update()
	--checkBoundaries()
end
function P.animal:willKillPlayer(player)
	return false
end
function P.animal:explode()
end
function P.animal:afraidPrimaryMove(playerx, playery, room, isLit)
	local diffCatx = math.abs(playerx - self.tileX)
	local diffCaty = math.abs(playery - self.tileY)

	if self.dead or (not isLit and not self.triggered) or self.frozen then
		return
	end
	self.triggered = true

	self.prevTileX = self.tileX
	self.prevTileY = self.tileY

	if self.waitCounter>0 then
		return
	end



	local setOfMoves = {}
	local currDist = math.abs(self.tileX-playerx)+math.abs(self.tileY-playery)
	setOfMoves[1] = {dist = math.abs(self.tileX+1-playerx)+math.abs(self.tileY-playery), diffx = 1, diffy = 0}
	setOfMoves[2] = {dist = math.abs(self.tileX-1-playerx)+math.abs(self.tileY-playery), diffx = -1, diffy = 0}
	setOfMoves[3] = {dist = math.abs(self.tileX-playerx)+math.abs(self.tileY+1-playery), diffx = 0, diffy = 1}
	setOfMoves[4] = {dist = math.abs(self.tileX-playerx)+math.abs(self.tileY-1-playery), diffx = 0, diffy = -1}

	for i = 1, 4 do
		for j = i, 4 do
			if i~=j and setOfMoves[j].dist>setOfMoves[i].dist then
				local temp = setOfMoves[i]
				setOfMoves[i] = setOfMoves[j]
				setOfMoves[j] = temp
			--new AI beginning
			elseif i~=j and setOfMoves[j].dist == setOfMoves[i].dist then
				if diffCatx>diffCaty and math.abs(setOfMoves[j].diffy)>math.abs(setOfMoves[i].diffy) then
					local temp = setOfMoves[i]
					setOfMoves[i] = setOfMoves[j]
					setOfMoves[j] = temp
				elseif diffCaty>diffCatx and math.abs(setOfMoves[j].diffx)>math.abs(setOfMoves[i].diffx) then
					local temp = setOfMoves[i]
					setOfMoves[i] = setOfMoves[j]
					setOfMoves[j] = temp
				end
			end
			--new AI end
		end
	end

	for i = 1, 4 do
		if setOfMoves[i].dist>currDist then
			self:tryMove(setOfMoves[i].diffx, setOfMoves[i].diffy)
			if self:hasMoved() then
				return
			end
		end
	end
end
function P.animal:tryMove(diffx, diffy)
	self.tileX = self.tileX+diffx
	self.tileY = self.tileY+diffy

	if room[self.tileY]==nil or self.tileX>roomLength or self.tileX<=0 or
	(room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:obstructsMovementAnimal(self)) or
	(room[self.tileY][self.tileX]==nil and math.abs(self.elevation)>3) then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return
	end

	if not self:pushableCheck() then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
	end

	local sameSpotCounter = 0
	for i = 1, #animals do
		if animals[i].tileX == self.tileX and animals[i].tileY == self.tileY then
			sameSpotCounter = sameSpotCounter+1
		end
	end
	if sameSpotCounter>1 then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
	end
end

function P.animal:afraidSecondaryMove(playerx, playery)
	local diffx = math.abs(playerx - self.tileX)
	local diffy = math.abs(playery - self.tileY)

	if diffy>diffx then
		if playerx>self.tileX then
			self.tileX = self.tileX-1
		else
			self.tileX = self.tileX+1
		end
	else
		if playery>self.tileY then
			self.tileY = self.tileY-1
		else
			self.tileY = self.tileY+1
		end
	end

	if room[self.tileY]==nil or self.tileX<1 or self.tileX>roomLength or
	(room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:obstructsMovementAnimal(self)) or
	(room[self.tileY][self.tileX]==nil and math.abs(self.elevation)>3) then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return false
	end

	if not self:pushableCheck() then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
		return false
	end

	return true
end


P.pitbull = P.animal:new{name = "pitbull", canDropTool = true}
function P.pitbull:willKillPlayer()
	return player.tileX == self.tileX and player.tileY == self.tileY and not self.dead
end
function P.pitbull:dropTool()
	local whichTool = util.random(1, 'toolDrop')
	if whichTool==1 then
		if not tools.dropTool(tools.meat, self.tileY, self.tileX) then
			return
		end
	else
		if not tools.dropTool(tools.rottenMeat, self.tileY, self.tileX) then
			return
		end
	end
end

P.pup = P.animal:new{name = "pup", sprite = 'NewGraphics/pupDesign.png', deadSprite = 'Graphics/pupdead.png', canDropTool = true}
P.pup.dropTool = P.pitbull.dropTool

P.snail = P.animal:new{name = "snail", sprite = 'NewGraphics/snailDesign.png', deadSprite = 'Graphics/pupdead.png', canDropTool = true}
function P.snail:onNullLeave()
	return tiles.slime:new()
end
function P.snail:kill()
	self.dead = true
	self.sprite = self.deadSprite
	if self.canDropTool and not self.willDropTool then
		local bonusDropChance = util.random(100, 'toolDrop')
		if bonusDropChance<=getLuckBonus() then
			self.willDropTool = true
		end
	end
	if self.willDropTool and (room[self.tileY][self.tileX]==nil or room[self.tileY][self.tileX].destroyed
	or room[self.tileY][self.tileX]:instanceof(tiles.pitbullTile)) then
		self:dropTool()
	end
	unlocks = require('scripts.unlocks')
	unlocks.unlockUnlockableRef(unlocks.conductiveSnailsUnlock)
end
function P.snail:dropTool()
	if tools.dropTool(tools.shell, self.tileY, self.tileX) then
		return
	end
end

P.conductiveSnail = P.snail:new{name = "conductiveSnail", sprite = 'NewGraphics/snailCDesign.png'}
function P.conductiveSnail:onNullLeave()
	return tiles.conductiveSlime:new()
end
function P.conductiveSnail:kill()
	self.dead = true
	self.sprite = self.deadSprite
	if self.canDropTool and not self.willDropTool then
		local bonusDropChance = util.random(100, 'toolDrop')
		if bonusDropChance<=getLuckBonus() then
			self.willDropTool = true
		end
	end
	if self.willDropTool and (room[self.tileY][self.tileX]==nil or room[self.tileY][self.tileX].destroyed
	or room[self.tileY][self.tileX]:instanceof(tiles.pitbullTile)) then
		self:dropTool()
	end
	unlocks = require('scripts.unlocks')
	unlocks.unlockUnlockableRef(unlocks.lennyUnlock)
end

P.glueSnail = P.snail:new{name = "glueSnail", sprite = 'Graphics/gluesnail.png'}
function P.glueSnail:onNullLeave()
	return tiles.glue:new()
end
function P.glueSnail:kill()
	self.dead = true
	self.sprite = self.deadSprite
	if self.canDropTool and not self.willDropTool then
		local bonusDropChance = util.random(100, 'toolDrop')
		if bonusDropChance<=getLuckBonus() then
			self.willDropTool = true
		end
	end
	if self.willDropTool and (room[self.tileY][self.tileX]==nil or room[self.tileY][self.tileX].destroyed
	or room[self.tileY][self.tileX]:instanceof(tiles.pitbullTile)) then
		self:dropTool()
	end
end

P.bat = P.animal:new{flying = true, name = "bat", sprite = 'Graphics/bat.png', deadSprite = 'Graphics/pupdead.png'}
function P.bat:checkDeath()
end
P.bat.willKillPlayer = P.pitbull.willKillPlayer

P.cat = P.animal:new{name = "cat", canDropTool = true, sprite = 'NewGraphics/catDesign.png', deadSprite = 'Graphics/catdead.png'}
P.cat.move = P.animal.afraidPrimaryMove
P.cat.secondaryMove = P.animal.afraidSecondaryMove
function P.cat:dropTool()
	tools.dropTool(tools.nineLives, self.tileY, self.tileX)
end

P.bombBuddy = P.animal:new{name = "bombBuddy", scale = 0.6*scale,
sprite = 'Graphics/bombBuddyFront.png', deadSprite = 'Graphics/catdead.png', canDropTool = true}
function P.bombBuddy:explode()
	room[self.tileY][self.tileX] = tiles.bomb:new()
	room[self.tileY][self.tileX]:onEnd(self.tileY, self.tileX)
	room[self.tileY][self.tileX] = nil
end
function P.bombBuddy:dropTool()
	tools.dropTool(tools.explosiveMeat, self.tileY, self.tileX)
end

P.conductiveDog = P.pup:new{name = "conductiveDog", powered = false, conductive = true, sprite = 'Graphics/conductivedog.png'}

P.wife = P.cat:new{name = "wife", sprite = 'Graphics/wife.png'}
P.son = P.cat:new{name = "son", sprite = 'Graphics/son.png'}
P.daughter = P.cat:new{name = "daughter", sprite = 'Graphics/daughter.png'}

P.ram = P.animal:new{name = "Ram", sprite = 'Graphics/ram.png', scale = 0.1*scale}
P.ram.move = P.animal.afraidPrimaryMove
function P.ram:tryMove(diffx, diffy)
	self.tileX = self.tileX+diffx
	self.tileY = self.tileY+diffy

	if room[self.tileY]==nil or self.tileX>roomLength or self.tileX<=0 or
	(room[self.tileY][self.tileX]==nil and math.abs(self.elevation)>3) then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return
	elseif room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:obstructsMovementAnimal(self) then
		if room[self.tileY][self.tileX]:getHeight()<=self.elevation then
			self.tileY = self.prevTileY
			self.tileX = self.prevTileX
			return
		else
			room[self.tileY][self.tileX]:destroy()
		end
	end

	if not self:pushableCheck() then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
	end

	local sameSpotCounter = 0
	for i = 1, #animals do
		if animals[i].tileX == self.tileX and animals[i].tileY == self.tileY then
			sameSpotCounter = sameSpotCounter+1
		end
	end
	if sameSpotCounter>1 then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
	end
end

function P.ram:afraidSecondaryMove(playerx, playery)
	local diffx = math.abs(playerx - self.tileX)
	local diffy = math.abs(playery - self.tileY)

	if diffy>diffx then
		if playerx>self.tileX then
			self.tileX = self.tileX-1
		else
			self.tileX = self.tileX+1
		end
	else
		if playery>self.tileY then
			self.tileY = self.tileY-1
		else
			self.tileY = self.tileY+1
		end
	end

	if room[self.tileY]==nil or self.tileX<1 or self.tileX>roomLength or
	(room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:obstructsMovementAnimal(self)) or
	(room[self.tileY][self.tileX]==nil and math.abs(self.elevation)>3) then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
		return false
	end

	if not self:pushableCheck() then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
		return false
	end

	return true
end

P.rat = P.animal:new{name = "rat", sprite = 'Graphics/rat.png', triggered = true, canDropTool = true}
function P.rat:dropTool()
	if not tools.dropTool(tools.rottenMeat, self.tileY, self.tileX) then
		return
	end
end

P.termite = P.animal:new{name = "termite", sprite = 'Graphics/termite.png', waitCounter = 0}

P.twinPitbull = P.pitbull:new{name = "twinPitbull", sprite = 'Graphics/twinpitbull.png'}
function P.twinPitbull:moveOverride(movex, movey)
	movex = self.tileX
	movey = self.tileY

	for i = 1, #animals do
		if animals[i]:instanceof(P.twinPitbull) and animals[i]~=self then
			if movex~=self.tileX or movey~=self.tileY then
				local iDist = math.abs(animals[i].tileX-self.tileX)+math.abs(animals[i].tileY-self.tileY)
				local currDist = math.abs(movex-self.tileX)+math.abs(movey-self.tileY)
				if currDist>iDist then
					movex = animals[i].tileX
					movey = animals[i].tileY
				end
			else
				movex = animals[i].tileX
				movey = animals[i].tileY
			end
		end
	end

	return {x = movex, y = movey}
end



animalList[1] = P.animal
animalList[2] = P.pitbull
animalList[3] = P.pup
animalList[4] = P.cat
animalList[5] = P.snail
animalList[6] = P.bat
animalList[7] = P.conductiveSnail
animalList[8] = P.glueSnail
animalList[9] = P.bombBuddy
animalList[10] = P.conductiveDog
animalList[11] = P.wife
animalList[12] = P.son
animalList[13] = P.daughter
animalList[14] = P.ram
animalList[15] = P.rat
animalList[16] = P.termite
animalList[17] = P.twinPitbull

return animalList