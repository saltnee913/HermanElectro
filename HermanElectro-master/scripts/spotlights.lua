require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
spotlightsList = P


P.spotlight  = Object:new{name = "spotlight", x = 0.0, y = 0.0, dir = 1, speed = 0.1, active = true,
sprite = love.graphics.newImage('Graphics/whitespot.png')}
P.fastSpotlight = P.spotlight:new{name = "fastSpotlight", speed = 0.2,
sprite = love.graphics.newImage('Graphics/purplespot.png')}
P.slowSpotlight = P.spotlight:new{name = "slowSpotlight", speed = 0.05,
sprite = love.graphics.newImage('Graphics/yellowspot.png')}

function P.spotlight:update(dt)
	--directions same as for dirEnter: 0 up, 1 right, 2 down, 3 left
	local dirToGo = {x = 0, y = 0}
	if self.dir==0 then dirToGo.y = -1
	elseif self.dir==1 then dirToGo.x = 1
	elseif self.dir==2 then dirToGo.y = 1
	elseif self.dir==3 then dirToGo.x = -1 end
	self.x = self.x+dirToGo.x*self.speed*dt*1000
	self.y = self.y+dirToGo.y*self.speed*dt*1000

	return self:checkBounds()
end

function P.spotlight:onPlayer()
	if not self.active then return end

	local sx = self.x+tileUnit/2*scale
	local sy = self.y+tileUnit/2*scale
	local playerx = tileToCoords(player.tileY, player.tileX).x+tileUnit/2*scale
	local playery = tileToCoords(player.tileY, player.tileX).y+tileUnit/2*scale
	local playery2 = tileToCoords(player.tileY-1, player.tileX).y+tileUnit/2*scale --for tall players
	local radius = tileUnit/2*scale
	local spotDist = math.sqrt((sx-playerx)*(sx-playerx)+(sy-playery)*(sy-playery))
	local spotDist2 = math.sqrt((sx-playerx)*(sx-playerx)+(sy-playery2)*(sy-playery2))
	if spotDist<radius --[[or (player.character.tallSprite and spotDist2 < radius)]] then
		log('on')
		return true
	end
	log('off')
	return false
end

function P.spotlight:checkBounds()
	if self.y<tileToCoords(1,1).y then self.dir=2
	elseif self.y>tileToCoords(roomHeight, 1).y then self.dir=0
	elseif self.x<tileToCoords(1,1).x then self.dir=1
	elseif self.x>tileToCoords(1, roomLength).x then self.dir=3 end
	return true
end

spotlightsList[1] = P.spotlight
spotlightsList[2] = P.fastSpotlight
spotlightsList[3] = P.slowSpotlight

return spotlightsList