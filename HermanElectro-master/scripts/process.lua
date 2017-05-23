local util = require('scripts.util')

local P = {}
process = P

P.basicProcess = Object:new{name = 'test', active = true, time = nil, disableInput = true}
function P.basicProcess:run()
end
function P.basicProcess:draw()
end

P.movePlayer = P.basicProcess:new{name = "movePlayer", direction = 0, active = true, time = nil, disableInput = true}
function P.movePlayer:run(dt)
	if self.time==nil then
		self.baseTime = keyTimer.base*100
		self.time = self.baseTime
	end
	local moveLength = scale*tileHeight/self.baseTime*math.min(self.time, dt*100)
	if self.direction == 0 then
		player.y = player.y-moveLength
	elseif self.direction == 1 then
		player.x = player.x+moveLength
	elseif self.direction == 2 then
		player.y = player.y+moveLength
	elseif self.direction == 3 then
		player.x = player.x-moveLength
	end
	myShader:send("player_x", player.x+getTranslation().x*tileWidth*scale+(width2-width)/2)
    myShader:send("player_y", player.y+getTranslation().y*tileWidth*scale+(height2-height)/2)

	self.time = self.time-dt*100
	if self.time<=self.baseTime/2 then
		self:switchTiles()
	end
	if self.time<=0 then
		self.active = false
		setPlayerLoc()
	end
end
function P.movePlayer:switchTiles()
	if room[player.tileY][player.tileX]~=nil then
		if player.prevTileY == player.tileY and player.prevTileX == player.tileX then
			room[player.tileY][player.tileX]:onStay(player)
			if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].overlay~=nil then
				room[player.tileY][player.tileX].overlay:onStay(player)
			end
		else
			player.character:preTileEnter(room[player.tileY][player.tileX])
			preTileEnter(room[player.tileY][player.tileX])
			room[player.tileY][player.tileX]:onEnter(player)
			if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].overlay~=nil then
				room[player.tileY][player.tileX].overlay:onEnter(player)
			end
		end
	end
	if not (player.prevTileY == player.tileY and player.prevTileX == player.tileX) then
		if room~=nil and not player.justTeleported and room[player.prevTileY][player.prevTileX]~=nil then
			room[player.prevTileY][player.prevTileX]:onLeave(player)
			if room[player.prevTileY][player.prevTileX]~=nil and room[player.prevTileY][player.prevTileX].overlay~=nil then
				room[player.prevTileY][player.prevTileX].overlay:onLeave(player)
			end
		end
		player.character:onTileLeave()
	end
end

P.moveAnimal = P.basicProcess:new{name = "moveAnimal", direction = 0, active = true, time = nil, disableInput = true,
animal = nil}
function P.moveAnimal:run(dt)
	if self.animal==nil then return end

	if self.time==nil then
		self.baseTime = keyTimer.base*100
		self.time = self.baseTime
	end
	local moveLength = scale*tileHeight/self.baseTime*math.min(self.time, dt*100)
	if self.direction == 0 then
		self.animal.y = self.animal.y-moveLength
	elseif self.direction == 1 then
		self.animal.x = self.animal.x+moveLength
	elseif self.direction == 2 then
		self.animal.y = self.animal.y+moveLength
	elseif self.direction == 3 then
		self.animal.x = self.animal.x-moveLength
	end

	self.time = self.time-dt*100

	if self.time<=self.baseTime/2 then
		self:switchTiles()
	end

	if self.time<=0 then
		self.active = false
		self.animal:setLoc()
	end
end
function P.moveAnimal:switchTiles()
	--onEnter stuff
	if room[self.animal.tileY][self.animal.tileX]~=nil then
		room[self.animal.tileY][self.animal.tileX]:onEnterAnimal(self.animal)
		if room[self.animal.tileY][self.animal.tileX]~=nil
		and room[self.animal.tileY][self.animal.tileX].overlay~=nil then
			room[self.animal.tileY][self.animal.tileX].overlay:onEnterAnimal(self.animal)
		end
	end

	--onLeave stuff
	if room[self.animal.prevTileY]~=nil and room[self.animal.prevTileY][self.animal.prevTileX]~=nil then
		room[self.animal.prevTileY][self.animal.prevTileX]:onLeaveAnimal(self.animal)
		if (not self.animal.dead) and room[self.animal.prevTileY][self.animal.prevTileX]~=nil
		and room[self.animal.prevTileY][self.animal.prevTileX].overlay~=nil then
			room[self.animal.prevTileY][self.animal.prevTileX].overlay:onLeaveAnimal(self.animal)
		end
		if room[self.animal.prevTileY][self.animal.prevTileX]:usableOnNothing() then
			room[self.animal.prevTileY][self.animal.prevTileX] = self.animal:onNullLeave(self.animal.prevTileY, self.animal.prevTileX)
		end
	else
		room[self.animal.prevTileY][self.animal.prevTileX] = self.animal:onNullLeave(self.animal.prevTileY, self.animal.prevTileX)
	end
end

P.movePushable = P.basicProcess:new{name = "movePushable", direction = 0, active = true, time = nil, disableInput = true,
pushable = nil}
function P.movePushable:run(dt)
	if self.pushable==nil then return end

	if self.time==nil then
		self.time = keyTimer.base*100
		self.baseTime = keyTimer.base*100
	end
	local moveLength = scale*tileHeight/self.baseTime*math.min(self.time, dt*100)
	if self.direction == 0 then
		self.pushable.y = self.pushable.y-moveLength
	elseif self.direction == 1 then
		self.pushable.x = self.pushable.x+moveLength
	elseif self.direction == 2 then
		self.pushable.y = self.pushable.y+moveLength
	elseif self.direction == 3 then
		self.pushable.x = self.pushable.x-moveLength
	end

	self.time = self.time-dt*100
	if self.time<=0 then
		self.active = false
		self.pushable:setLoc()
	end
end

P.grenadeThrow = P.basicProcess:new{name = "grenadeThrow", direction = 0, active = true, time = nil, disableInput = true,
currentLoc = {x = nil, y = nil}, targetLoc = {x = nil, y = nil, tileX = nil, tileY = nil},
sprite = 'Graphics/grenade.png', speed = 10}
function P.grenadeThrow:run(dt)
	local moveLength = scale*tileHeight*dt*self.speed
	local pastTarget = false

	if self.direction == 0 then
		self.currentLoc.y = self.currentLoc.y-moveLength
		if self.currentLoc.y<self.targetLoc.y then pastTarget = true end
	elseif self.direction == 1 then
		self.currentLoc.x = self.currentLoc.x+moveLength
		if self.currentLoc.x>self.targetLoc.x then pastTarget = true end
	elseif self.direction == 2 then
		self.currentLoc.y = self.currentLoc.y+moveLength
		if self.currentLoc.y>self.targetLoc.y then pastTarget = true end
	elseif self.direction == 3 then
		self.currentLoc.x = self.currentLoc.x-moveLength
		if self.currentLoc.x<self.targetLoc.x then pastTarget = true end
	end

	if pastTarget then
		self.active = false
		util.createHarmlessExplosion(self.targetLoc.tileY, self.targetLoc.tileX, 1)
		updateGameState()
	end
end

function P.grenadeThrow:draw()
	local grenadeSprite = util.getImage(self.sprite)
	love.graphics.draw(grenadeSprite, self.currentLoc.x, self.currentLoc.y, 0, 0.5*scale, 0.5*scale)
end

P.bullet = P.basicProcess:new{name = "bullet", direction = 0, active = true, time = nil, disableInput = true,
currentLoc = {x = nil, y = nil}, targetLoc = {x = nil, y = nil, tileX = nil, tileY = nil},
sprite = 'Graphics/bullet.png', speed = 8, animal = nil}
function P.bullet:run(dt)
	local moveLength = scale*tileHeight*dt*self.speed
	local pastTarget = false

	if self.direction == 0 then
		self.currentLoc.y = self.currentLoc.y-moveLength
		if self.currentLoc.y<self.targetLoc.y then pastTarget = true end
	elseif self.direction == 1 then
		self.currentLoc.x = self.currentLoc.x+moveLength
		if self.currentLoc.x>self.targetLoc.x then pastTarget = true end
	elseif self.direction == 2 then
		self.currentLoc.y = self.currentLoc.y+moveLength
		if self.currentLoc.y>self.targetLoc.y then pastTarget = true end
	elseif self.direction == 3 then
		self.currentLoc.x = self.currentLoc.x-moveLength
		if self.currentLoc.x<self.targetLoc.x then pastTarget = true end
	end

	if pastTarget then
		self:onEnd()
	end
end
function P.bullet:draw()
	local bulletSprite = util.getImage(self.sprite)
	love.graphics.draw(bulletSprite, self.currentLoc.x, self.currentLoc.y, 0, 0.5*scale, 0.5*scale)
end
function P.bullet:onEnd()
	self.active = false
	self.animal:kill()
	if self.animal:instanceof(animalList.bombBuddy) then
		self.animal:explode()
	end
	updateGameState()
end

P.iceBullet = P.bullet:new{name = "iceBullet", sprite = 'Graphics/iceBullet.png'}
function P.iceBullet:onEnd()
	self.active = false
	local toAdd = pushableList.iceBox:new()
	toAdd.tileX = self.animal.tileX
	toAdd.prevTileX = self.animal.tileX
	toAdd.tileY = self.animal.tileY
	toAdd.prevTileY = self.animal.tileY
	toAdd:setLoc()
	self.animal:kill()
	pushables[#pushables+1] = toAdd
end

P.missile = P.basicProcess:new{name = "missile", active = true, time = nil, disableInput = true,
sprite = 'Graphics/Tools/missile.png', speed = 8, x = nil, y = nil, targetY = nil, tile = nil}
function P.missile:run(dt)
	if self.targetY==nil or self.y == nil then return end

	local moveLength = scale*tileHeight*dt*self.speed
	self.y = self.y+moveLength
	if self.y>self.targetY then
		self.active = false
		updateGameState()
		if self.tile~=nil then
			self.tile:destroy()
		end
	end
end

function P.missile:draw()
	local missileSprite = util.getImage(self.sprite)
	love.graphics.draw(missileSprite, self.x, self.y, 0, 0.5*scale, 0.5*scale)
end


process[1] = P.movePlayer
process[2] = P.moveAnimal
process[3] = P.movePushable
process[4] = P.grenadeThrow
process[5] = P.bullet
process[6] = P.missile
return process