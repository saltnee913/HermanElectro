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
	diffx = playerx-self.tileX
	diffy = playery-self.tileY
	self.prevx = self.x
	self.prevy = self.y
	self.prevTileX = self.tileX
	self.prevTileY = self.tileY
	if self.waitCounter>0 then
		self.waitCounter = self.waitCounter - 1
		return
	end
	if diffx==0 and diffy==0 then
		return
	end
	local unableToMove = false
	if math.abs(diffx)>math.abs(diffy) then
		if playerx>self.tileX then
			if not (room[self.tileY][self.tileX+1]~=nil and room[self.tileY][self.tileX+1]:blocksMovementAnimal()) then
				--self.x = self.x+floor.sprite:getHeight()*scale
				self.tileX = self.tileX+1
			elseif room[self.tileY][self.tileX+1]:blocksMovementAnimal() then
				unableToMove = true
			end
		else
			if not (room[self.tileY][self.tileX-1]~=nil and room[self.tileY][self.tileX-1]:blocksMovementAnimal()) then
				--self.x = self.x-floor.sprite:getHeight()*scale
				self.tileX = self.tileX-1
			elseif room[self.tileY][self.tileX-1]:blocksMovementAnimal() then
				unableToMove = true
			end
		end
	end
	if math.abs(diffx)<=math.abs(diffy) or (unableToMove and math.abs(diffy)>0) then
		if playery>self.tileY then
			if not (room[self.tileY+1][self.tileX]~=nil and room[self.tileY+1][self.tileX]:blocksMovementAnimal()) then
				--self.y = self.y+floor.sprite:getHeight()*scale
				self.tileY = self.tileY+1
				unableToMove = false
			elseif room[self.tileY+1][self.tileX]:blocksMovementAnimal() then
				unableToMove = true
			end
		else
			if not (room[self.tileY-1][self.tileX]~=nil and room[self.tileY-1][self.tileX]:blocksMovementAnimal()) then
				--self.y = self.y-floor.sprite:getHeight()*scale
				self.tileY = self.tileY-1
				unableToMove = false
			elseif room[self.tileY-1][self.tileX]:blocksMovementAnimal() then
				unableToMove = true
			end
		end
	end
	if unableToMove then
		if playerx>self.tileX then
			if not (room[self.tileY][self.tileX+1]~=nil and room[self.tileY][self.tileX+1]:blocksMovementAnimal()) then
				--self.x = self.x+floor.sprite:getHeight()*scale
				self.tileX = self.tileX+1
			end
		elseif playerx<self.tileX then
			if not (room[self.tileY][self.tileX-1]~=nil and room[self.tileY][self.tileX-1]:blocksMovementAnimal()) then
				--self.x = self.x-floor.sprite:getHeight()*scale
				self.tileX = self.tileX-1
			end
		end
	end
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
function P.bat:move(playerx, playery, room, isLit)
	if self.dead or (not isLit and not self.triggered) then
		return
	end
	self.triggered = true
	diffx = playerx-self.tileX
	diffy = playery-self.tileY
	self.prevx = self.x
	self.prevy = self.y
	self.prevTileX = self.tileX
	self.prevTileY = self.tileY
	if diffx==0 and diffy==0 then
		return
	end
	if math.abs(diffx)>math.abs(diffy) then
		if playerx>self.tileX then
			--self.x = self.x+floor.sprite:getHeight()*scale
			self.tileX = self.tileX+1
		else
			--self.x = self.x-floor.sprite:getHeight()*scale
			self.tileX = self.tileX-1
		end
	else
		if playery>self.tileY then
			--self.y = self.y+floor.sprite:getHeight()*scale
			self.tileY = self.tileY+1
		else
			--self.y = self.y-floor.sprite:getHeight()*scale
			self.tileY = self.tileY-1
		end
	end
end
function P.bat:checkDeath()
end
P.bat.willKillPlayer = P.pitbull.willKillPlayer

P.cat = P.animal:new{name = "cat", sprite = love.graphics.newImage('Graphics/cat.png'), deadSprite = love.graphics.newImage('Graphics/catdead.png')}
function P.cat:move(playerx, playery, room, isLit)
	if self.dead or (not isLit and not self.triggered) then
		return
	end
	self.triggered = true
	diffx = playerx-self.tileX
	diffy = playery-self.tileY
	--self.prevx = self.x
	--self.prevy = self.y
	self.prevTileX = self.tileX
	self.prevTileY = self.tileY
	if diffx==0 and diffy==0 then
		return
	end
	if self.waitCounter>0 then
		self.waitCounter = self.waitCounter - 1
		return
	end
	local unableToMove = false
	if math.abs(diffy)>math.abs(diffx) then
		if playerx>=self.tileX then
			if self.tileX>1 and not (room[self.tileY][self.tileX-1]~=nil and room[self.tileY][self.tileX-1]:blocksMovementAnimal()) then
				--self.x = self.x-floor.sprite:getHeight()*scale
				self.tileX = self.tileX-1
				return
			else
				unableToMove = true
			end
		end
		if playerx<=self.tileX then
			if self.tileX<roomLength and not (room[self.tileY][self.tileX+1]~=nil and room[self.tileY][self.tileX+1]:blocksMovementAnimal()) then
				--self.x = self.x+floor.sprite:getHeight()*scale
				self.tileX = self.tileX+1
				return
			else
				unableToMove = true
			end
		end
	end
	if math.abs(diffy)<=math.abs(diffx) or unableToMove then
		if playery>=self.tileY then
			if self.tileY>1 and not (room[self.tileY-1][self.tileX]~=nil and room[self.tileY-1][self.tileX]:blocksMovementAnimal()) then
				--self.y = self.y-floor.sprite:getHeight()*scale
				self.tileY = self.tileY-1
				return
			else
				unableToMove = true
			end
		end
		if playery<=self.tileY then
			if self.tileY<roomHeight and not (room[self.tileY+1][self.tileX]~=nil and room[self.tileY+1][self.tileX]:blocksMovementAnimal()) then
				--self.y = self.y+floor.sprite:getHeight()*scale
				self.tileY = self.tileY+1
				return
			else
				unableToMove = true
			end
		end
	end
	if unableToMove then
		if playerx>=self.tileX then
			if self.tileX>1 and not (room[self.tileY][self.tileX-1]~=nil and room[self.tileY][self.tileX-1]:blocksMovementAnimal()) then
				--self.x = self.x-floor.sprite:getHeight()*scale
				self.tileX = self.tileX-1
				return
			end
		end
		if playerx<=self.tileX then
			if self.tileX<roomLength and not (room[self.tileY][self.tileX+1]~=nil and room[self.tileY][self.tileX+1]:blocksMovementAnimal()) then
				--self.x = self.x+floor.sprite:getHeight()*scale
				self.tileX = self.tileX+1
				return
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