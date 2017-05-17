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
		self.time = keyTimer.base*100
		self.baseTime = keyTimer.base*100
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
	if self.time<=0 then
		self.active = false
		setPlayerLoc()
	end
end

P.moveAnimal = P.basicProcess:new{name = "moveAnimal", direction = 0, active = true, time = nil, disableInput = true,
animal = nil}
function P.moveAnimal:run(dt)
	if self.animal==nil then return end

	if self.time==nil then
		self.time = keyTimer.base*100
		self.baseTime = keyTimer.base*100
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
	if self.time<=0 then
		self.active = false
		self.animal:setLoc()
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
		self.active = false
		self.animal:kill()
		if self.animal:instanceof(animalList.bombBuddy) then
			self.animal:explode()
		end
		updateGameState()
	end
end

function P.bullet:draw()
	local bulletSprite = util.getImage(self.sprite)
	love.graphics.draw(bulletSprite, self.currentLoc.x, self.currentLoc.y, 0, 0.5*scale, 0.5*scale)
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