local P = {}
bosses = P

P.boss = Object:new{name = 'boss', x = 0, y = 0, oldX = 0, oldY = 0, tileX = {}, tileY = {}, sprite = 'Graphics/Bosses/BossBobUnpowered.png', dirMoving = 0, speed = 2}

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
	love.graphics.draw(util.getImage(self.sprite), self.x, self.y, 0, scale, scale)
end

function P.boss:superUpdate(dt)
	self:updateMovement(dt)
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

function P.boss:onMoved(offset)
	self.oldX = self.oldX + offset.x*scale*tileWidth
	self.oldY = self.oldY + offset.y*scale*tileHeight
	local oldBottom = self:getBottomTileY()
	for i = 1, #self.tileY do
		self.tileY[i] = self.tileY[i] + offset.y
	end
	for i = 1, #self.tileX do
		self.tileX[i] = self.tileX[i] + offset.x
	end
	log(player.tileY..'/'..self:getBottomTileY()..'/'..oldBottom)
	self.dirMoving = self:chooseMovement()
end

function P.boss:chooseMovement()
	return 3
end

function P.boss:getBottomTileY()
	if self.y > self.oldY then
		return self.tileY[#self.tileY] + 1
	else
		return self.tileY[#self.tileY]
	end
end

return bosses