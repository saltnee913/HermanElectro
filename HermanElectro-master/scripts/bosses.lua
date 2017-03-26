local P = {}
bosses = P

P.boss = Object:new{name = 'boss', x = 0, y = 0, oldX = 0, oldY = 0, tileX = {}, tileY = {}, 
  sprite = 'Graphics/Bosses/BossBobUnpowered.png', deadSprite = 'Graphics/Bosses/BossBobUnpowered.png',
  dirMoving = 0, speed = 2, dead = false}

function P.boss:load(tileY, tileX)
	self.tileY[1] = tileY
	self.tileX[1] = tileX
	self.tileY[2] = tileY
	self.tileX[2] = tileX+1
	self.tileY[3] = tileY+1
	self.tileX[3] = tileX
	self.tileY[4] = tileY+1
	self.tileX[4] = tileX+1
	local coords = tileToCoords(tileY, tileX)
	self.x = coords.x
	self.y = coords.y
	self.oldX = self.x
	self.oldY = self.y
end

function P.boss:drawBoss()
	if self.dead then
		love.graphics.draw(util.getImage(self.deadSprite), self.x, self.y, 0, scale, scale)
	else
		love.graphics.draw(util.getImage(self.sprite), self.x, self.y, 0, scale, scale)
	end
end

function P.boss:kill()
	self.dead = true
end

function P.boss:willKillPlayer(player)
	for i = 1, #self.tileX do
		if player.tileX == self.tileX[i] and player.tileY == self.tileY[i] then
			return true
		end
	end
	return false
end
P.boss.willKillAnimal = P.boss.willKillPlayer

function P.boss:update(dt)

end

function P.boss:superUpdate(dt)
	if self.dead then return end
	self:updateMovement(dt)
	self:update(dt)
end

function P.boss:updateMovement(dt)
	if self.dirMoving == 0 then
		self.dirMoving = self:chooseMovement()
		return
	end
	local offset = util.getOffsetByDir(self.dirMoving)
	self.x = self.x + offset.x*dt*scale*tileWidth*self.speed
	self.y = self.y + offset.y*dt*scale*tileHeight*self.speed
	if math.abs(self.y - self.oldY) >= scale*tileHeight then
		self:onMoved(offset)
	elseif math.abs(self.x - self.oldX) >= scale*tileWidth then
		self:onMoved(offset)
	end
end

function P.boss:doOnMoved()

end

function P.boss:onMoved(offset)
	self.oldX = self.oldX + offset.x*scale*tileWidth
	self.oldY = self.oldY + offset.y*scale*tileHeight
	for i = 1, #self.tileY do
		self.tileY[i] = self.tileY[i] + offset.y
	end
	for i = 1, #self.tileX do
		self.tileX[i] = self.tileX[i] + offset.x
	end
	self.dirMoving = self:chooseMovement()
	self:doOnMoved()
end

function P.boss:isSomethingToSide(dir)
	local offset = util.getOffsetByDir(dir)
	for i = 1, #self.tileX do
		local newX = self.tileX[i] + offset.x
		local newY = self.tileY[i] + offset.y
		if newX < 1 then
			return true
		elseif newX > roomLength then
			return true
		elseif newY < 1 then
			return true
		elseif newY > roomHeight then
			return true
		else
			if room[newY][newX] ~= nil and room[newY][newX].blocksMovement then
				return true
			end
		end
	end
	return false
end
function P.boss:chooseMovement()
	return 4
end

function P.boss:getBottomTileY()
	if self.y > self.oldY then
		return self.tileY[#self.tileY] + 1
	else
		return self.tileY[#self.tileY]
	end
end

function P.boss:onPreUpdatePower()
end
function P.boss:onPostUpdatePower()
end

P.bobBoss = P.boss:new{name = 'battery acid', 
  sprite = 'Graphics/Bosses/BossBobUnpowered.png', poweredSprite = 'Graphics/Bosses/BossBobPowered.png', unpoweredSprite = 'Graphics/Bosses/BossBobUnpowered.png',
  deadSprite = 'Graphics/Bosses/BossBobUnpowered.png',
  speed = 1.5, powered = false, 
  poweredTime = 3, unPoweredTime = 3, timeToSwitch = 0}

function P.bobBoss:kill()
	self.dead = true
	self.powered = false
end

function P.bobBoss:willKillPlayer(player)
	for i = 1, #self.tileX do
		if player.tileX == self.tileX[i] and player.tileY == self.tileY[i] then
			return self.powered
		end
	end
	return false
end
P.bobBoss.willKillAnimal = P.bobBoss.willKillPlayer

function P.bobBoss:chooseMovement()
	if self.dirMoving ~= 0 and not self:isSomethingToSide(self.dirMoving) then
		return self.dirMoving
	else
		for i = 1, 4 do
			if i ~= self.dirMoving+2 and i ~= self.dirMoving-2 and not self:isSomethingToSide(i) then
				return i
			end
		end
		if not self:isSomethingToSide(self.dirMoving+2) then
			if self.dirMoving+2 > 4 then
				return self.dirMoving-2
			else
				return self.dirMoving+2
			end
		end
		return 0
	end
end

function P.bobBoss:doOnMoved()
	updateGameState()
	checkAllDeath()
end

function P.bobBoss:setPowered(inPowered)
	self.powered = inPowered
	if self.powered then
		self.sprite = self.poweredSprite
	else
		self.sprite = self.unpoweredSprite
	end
	updateGameState()
	checkAllDeath()
end

function P.bobBoss:update(dt)
	self.timeToSwitch = self.timeToSwitch + dt
	if self.powered and self.timeToSwitch > self.poweredTime then
		self:setPowered(false)
		self.timeToSwitch = self.timeToSwitch - self.poweredTime
	elseif not self.powered and self.timeToSwitch > self.unPoweredTime then
		self:setPowered(true)
		self.timeToSwitch = self.timeToSwitch - self.unPoweredTime
	end
end

function P.bobBoss:onPreUpdatePower()
	if self.powered then
		self.storedTiles = {}
		for i = 1, #self.tileX do
			local tileX = self.tileX[i]
			local tileY = self.tileY[i]
			if room[tileY][tileX] ~= nil then
				self.storedTiles[i] = room[tileY][tileX]:new()
				self.storedTiles[i].powered = true
			else
				self.storedTiles[i] = nil
			end
			room[tileY][tileX] = tiles.powerSupply:new()
		end
	end
end

function P.bobBoss:onPostUpdatePower()
	if self.powered then
		for i = 1, #self.tileX do
			local tileX = self.tileX[i]
			local tileY = self.tileY[i]
			room[tileY][tileX] = self.storedTiles[i]
		end
	end
end

return bosses