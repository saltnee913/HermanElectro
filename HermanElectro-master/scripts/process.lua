local util = require('scripts.util')

local P = {}
process = P

P.basicProcess = Object:new{name = 'test', active = true, time = nil}
function P.basicProcess:run()
end

P.movePlayer = P.basicProcess:new{name = "movePlayer", direction = 0, active = true, time = nil, disableInput = true}
function P.movePlayer:run(dt)
	if self.time==nil then
		self.time = keyTimer.base*90
		self.baseTime = keyTimer.base*90
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

	self.time = self.time-dt*100
	if self.time<=0 then
		self.active = false
		setPlayerLoc()
	end
end


process[1] = P.movePlayer
return process