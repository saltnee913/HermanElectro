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
P.animal = Object:new{frozen = false, pickedUp = false, flying = false, triggered = false, waitCounter = 0, dead = false, name = "animal", tileX, tileY, prevx, prevy, prevTileX, prevTileY, x, y, speed = 250, width = 16*scale, height = 16*scale, sprite = love.graphics.newImage('Graphics/pitbull.png'), deadSprite = love.graphics.newImage('Graphics/pitbulldead.png'), tilesOn = {}, oldTilesOn = {}}
function P.animal:move(playerx, playery, room, isLit)
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

	if room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:blocksMovementAnimal(self) then
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

	if room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:blocksMovementAnimal(self) then
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
end
function P.animal:hasMoved()
	return self.prevTileX ~= self.tileX or self.prevTileY ~= self.tileY
end
function P.animal:onNullLeave()
end
function P.animal:kill()
	self.dead = true
	self.sprite = self.deadSprite
end
function P.animal:update()
	--checkBoundaries()
end
function P.animal:willKillPlayer(player)
	return false
end


P.pitbull = P.animal:new{name = "pitbull"}
function P.pitbull:willKillPlayer()
	return player.tileX == self.tileX and player.tileY == self.tileY and not self.dead
end

P.pup = P.animal:new{name = "pup", sprite = love.graphics.newImage('NewGraphics/pupDesign.png'), deadSprite = love.graphics.newImage('Graphics/pupdead.png')}

P.snail = P.animal:new{name = "snail", sprite = love.graphics.newImage('NewGraphics/snailDesign.png'), deadSprite = love.graphics.newImage('Graphics/pupdead.png')}
function P.snail:onNullLeave()
	return tiles.slime:new()
end
function P.snail:kill()
	self.dead = true
	self.sprite = self.deadSprite
	unlocks = require('scripts.unlocks')
	unlocks.unlockUnlockableRef(unlocks.conductiveSnailsUnlock)
end

P.conductiveSnail = P.snail:new{name = "conductiveSnail", sprite = love.graphics.newImage('NewGraphics/snailCDesign.png')}
function P.conductiveSnail:onNullLeave()
	return tiles.conductiveSlime:new()
end
function P.conductiveSnail:kill()
	self.dead = true
	self.sprite = self.deadSprite
	if room[self.tileY][self.tileX]:instanceof(tiles.conductiveSlime) then
		unlocks = require('scripts.unlocks')
		unlocks.unlockUnlockableRef(unlocks.lennyUnlock)
	end
end

P.glueSnail = P.snail:new{name = "glueSnail", sprite = love.graphics.newImage('Graphics/gluesnail.png')}
function P.glueSnail:onNullLeave()
	return tiles.glue:new()
end
function P.glueSnail:kill()
	self.dead = true
	self.sprite = self.deadSprite
end

P.bat = P.animal:new{flying = true, name = "bat", sprite = love.graphics.newImage('Graphics/bat.png'), deadSprite = love.graphics.newImage('Graphics/pupdead.png')}
function P.bat:checkDeath()
end
P.bat.willKillPlayer = P.pitbull.willKillPlayer

P.cat = P.animal:new{name = "cat", sprite = love.graphics.newImage('NewGraphics/catDesign.png'), deadSprite = love.graphics.newImage('Graphics/catdead.png')}
function P.cat:move(playerx, playery, room, isLit)
	local diffCatx = math.abs(playerx - self.tileX)
	local diffCaty = math.abs(playery - self.tileY)

	if self.dead or (not isLit and not self.triggered) or self.frozen then
		return
	end
	self.triggered = true
	if self.waitCounter>0 then
		self.waitCounter = self.waitCounter - 1
		self.prevTileX = self.tileX
		self.prevTileY = self.tileY
		return
	end

	self.prevTileX = self.tileX
	self.prevTileY = self.tileY

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
			if self.tileX~=self.prevTileX or self.tileY~=self.prevTileY then
				return
			end
		end
	end
end
function P.cat:tryMove(diffx, diffy)
	self.tileX = self.tileX+diffx
	self.tileY = self.tileY+diffy

	if room[self.tileY]==nil or self.tileX>roomLength or self.tileX<=0 or
	(room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:blocksMovementAnimal(self)) then
		self.tileY = self.prevTileY
		self.tileX = self.prevTileX
	end

	if not self:pushableCheck() then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
	end
end

function P.cat:secondaryMove(playerx, playery)
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
	(room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:blocksMovementAnimal(self)) then
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


animalList[1] = P.animal
animalList[2] = P.pitbull
animalList[3] = P.pup
animalList[4] = P.cat
animalList[5] = P.snail
animalList[6] = P.bat
animalList[7] = P.conductiveSnail
animalList[8] = P.glueSnail

return animalList