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
P.animal = Object:new{pickedUp = false, flying = false, triggered = false, waitCounter = 0, dead = false, name = "animal", tileX, tileY, prevx, prevy, prevTileX, prevTileY, x, y, speed = 250, width = 16*scale, height = 16*scale, sprite = love.graphics.newImage('Graphics/pitbull.png'), deadSprite = love.graphics.newImage('Graphics/pitbulldead.png'), tilesOn = {}, oldTilesOn = {}}
function P.animal:move(playerx, playery, room, isLit)
	if self.dead or (not isLit and not self.triggered) then
		return
	end
	self.triggered = true
	if self.waitCounter>0 then
		self.waitCounter = self.waitCounter - 1
		return
	end
	if playerx-self.tileX==0 and playery-self.tileY==0 then
		return
	end

	self.prevTileX = self.tileX
	self.prevTileY = self.tileY

	if not self:primaryMove() then
		self:secondaryMove()
	end

	if not (self.prevTileY == self.tileY and self.prevTileX == self.tileX) then
		for i = 1, #pushables do
			if pushables[i].tileX == self.tileX and pushables[i].tileY == self.tileY then
				if not pushables[i]:move(self) then
					self.tileX = self.prevTileX
					self.tileY = self.prevTileY
				end
			end
		end
	end
end
function P.animal:primaryMove()
	local diffx = math.abs(player.tileX - self.tileX)
	local diffy = math.abs(player.tileY - self.tileY)

	if diffx>diffy then
		if player.tileX>self.tileX then
			self.tileX = self.tileX+1
		else
			self.tileX = self.tileX-1
		end
	else
		if player.tileY>self.tileY then
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
	return true
end

function P.animal:secondaryMove()
	local diffx = math.abs(player.tileX - self.tileX)
	local diffy = math.abs(player.tileY - self.tileY)

	if diffy>diffx then
		if player.tileX>self.tileX then
			self.tileX = self.tileX+1
		else
			self.tileX = self.tileX-1
		end
	else
		if player.tileY>self.tileY then
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
	return true
end

function P.animal:checkDeath()
	if room[self.tileY][self.tileX]~=nil then
		t = room[self.tileY][self.tileX]
		if self.dead == false and t:willKillAnimal() then
			self:kill()
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

P.pup = P.animal:new{name = "pup", sprite = love.graphics.newImage('Graphics/pup.png'), deadSprite = love.graphics.newImage('Graphics/pupdead.png')}

P.snail = P.animal:new{name = "snail", sprite = love.graphics.newImage('Graphics/snail.png'), deadSprite = love.graphics.newImage('Graphics/pupdead.png')}
function P.snail:onNullLeave()
	return tiles.slime:new()
end

P.conductiveSnail = P.snail:new{name = "conductiveSnail", sprite = love.graphics.newImage('Graphics/conductivesnail.png')}
function P.conductiveSnail:onNullLeave()
	return tiles.conductiveSlime:new()
end

P.bat = P.animal:new{flying = true, name = "bat", sprite = love.graphics.newImage('Graphics/bat.png'), deadSprite = love.graphics.newImage('Graphics/pupdead.png')}
function P.bat:checkDeath()
end
P.bat.willKillPlayer = P.pitbull.willKillPlayer

P.cat = P.animal:new{name = "cat", sprite = love.graphics.newImage('Graphics/cat.png'), deadSprite = love.graphics.newImage('Graphics/catdead.png')}
function P.cat:move(playerx, playery, room, isLit)
	if self.dead or (not isLit and not self.triggered) then
		return
	end
	self.triggered = true
	if self.waitCounter>0 then
		self.waitCounter = self.waitCounter - 1
		return
	end

	self.prevTileX = self.tileX
	self.prevTileY = self.tileY

	local setOfMoves = {}
	local currDist = math.abs(self.tileX-player.tileX)+math.abs(self.tileY-player.tileY)
	setOfMoves[1] = {dist = math.abs(self.tileX+1-player.tileX)+math.abs(self.tileY-player.tileY), diffx = 1, diffy = 0}
	setOfMoves[2] = {dist = math.abs(self.tileX-1-player.tileX)+math.abs(self.tileY-player.tileY), diffx = -1, diffy = 0}
	setOfMoves[3] = {dist = math.abs(self.tileX-player.tileX)+math.abs(self.tileY+1-player.tileY), diffx = 0, diffy = 1}
	setOfMoves[4] = {dist = math.abs(self.tileX-player.tileX)+math.abs(self.tileY-1-player.tileY), diffx = 0, diffy = -1}

	for i = 1, 4 do
		for j = i, 4 do
			if i~=j and setOfMoves[j].dist>setOfMoves[i].dist then
				local temp = setOfMoves[i]
				setOfMoves[i] = setOfMoves[j]
				setOfMoves[j] = temp
			end
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

	if not (self.prevTileY == self.tileY and self.prevTileX == self.tileX) then
		for i = 1, #pushables do
			if pushables[i].tileX == self.tileX and pushables[i].tileY == self.tileY then
				if not pushables[i]:move(self) then
					self.tileX = self.prevTileX
					self.tileY = self.prevTileY
				end
			end
		end
	end
end


animalList[1] = P.animal
animalList[2] = P.pitbull
animalList[3] = P.pup
animalList[4] = P.cat
animalList[5] = P.snail
animalList[6] = P.bat
animalList[7] = P.conductiveSnail

return animalList