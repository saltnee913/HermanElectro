require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
spotlightsList = P


P.spotlight  = Object:new{name = "spotlight", tileX = 0, tileY = 0, dir = 1, baseUpdateTime = 300, updateTime = 300,
sprite = love.graphics.newImage('Graphics/white.png')}
P.fastSpotlight = P.spotlight:new{name = "fastSpotlight", baseUpdateTime = 150, updateTime = 150,
sprite = love.graphics.newImage('Graphics/purple.png')}
P.slowSpotlight = P.spotlight:new{name = "slowSpotlight", baseUpdateTime = 450, updateTime = 450,
sprite = love.graphics.newImage('Graphics/yellow.png')}
function P.spotlight:update(dt)
	--directions same as for dirEnter: 0 up, 1 right, 2 down, 3 left
	self.updateTime = self.updateTime-dt*1000
	if self.updateTime>0 then return
	else self.updateTime = self.baseUpdateTime end
	if self.dir==0 then
		if self.tileY>1 then
			self.tileY = self.tileY-1
		else
			self.dir=2
			self.tileY = self.tileY+1
		end
	elseif self.dir==1 then
		if self.tileX<roomLength then
			self.tileX = self.tileX+1
		else
			self.dir=3
			self.tileX = self.tileX-1
		end
	elseif self.dir==2 then
		if self.tileY<roomHeight then
			self.tileY = self.tileY+1
		else
			self.dir=0
			self.tileY = self.tileY-1
		end
	elseif self.dir==3 then
		if self.tileX>1 then
			self.tileX = self.tileX-1
		else
			self.dir=1
			self.tileX = self.tileX+1
		end
	end
end

spotlightsList[1] = P.spotlight
spotlightsList[2] = P.fastSpotlight
spotlightsList[3] = P.slowSpotlight

return spotlightsList