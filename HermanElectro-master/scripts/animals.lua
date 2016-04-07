require('scripts.object')
require('scripts.tiles')
floor = tiles.tile

local P = {}
animalList = P

playerheight = 20
playerwidth = 20
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
floor = tiles.tile

--speed same as player (250)
P.animal = Object:new{tileX, tileY, x, y, speed = 250, width = 16*scale, height = 16*scale, sprite = love.graphics.newImage('Graphics/pitbull.png'), tilesOn = {}, oldTilesOn = {}}
function P.animal:move(playerx, playery)
	diffx = playerx-self.tileX
	diffy = playery-self.tileY
	if math.abs(diffx)>math.abs(diffy) then
		if playerx>self.tileX then
			self.x = self.x+floor.sprite:getHeight()*scale
			self.tileX = self.tileX+1
		else
			self.x = self.x-floor.sprite:getHeight()*scale
			self.tileX = self.tileX-1
		end
	else
		if playery>self.tileY then
			self.y = self.y+floor.sprite:getHeight()*scale
			self.tileY = self.tileY+1
		else
			self.y = self.y-floor.sprite:getHeight()*scale
			self.tileY = self.tileY-1
		end
	end
end
function P.animal:moveOld(playerx, playery, dt)
	diffx = playerx+playerwidth/2 - (self.x+floor.sprite:getWidth()/2*scale)
	diffy = playery-playerheight/2 - (self.y+floor.sprite:getHeight()/2*scale)
	--ang = math.atan2(diffy, diffx)
	--self.y = self.y+math.sin(ang)*self.speed*dt
	--self.x = self.x+math.cos(ang)*self.speed*dt
	if math.abs(diffx)>math.abs(diffy) then
		if self.x>playerx then
			self.x = self.x-self.speed*dt
		else
			self.x = self.x+self.speed*dt
		end
	else
		if self.y>playery then
			self.y = self.y-self.speed*dt
		else
			self.y = self.y+self.speed*dt
		end
	end
end
function P.animal:update()
	checkBoundaries()
end
function P.animal:checkBoundaries()
--tile locations: (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, starts at (0,0)
--hitbox: bottom left (player.x, player.y), height player.height, width player.width
	tilesOn = {}
	tileLocs = {}
	xCorner = self.x
	yCorner = self.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~=nil then
		tilesOn[1] = room[tileLoc2][tileLoc1]
		tileLocs[1] = {x=tileLoc1, y=tileLoc2}
	end

	xCorner = self.x+self.width
	yCorner = self.y+self.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~= nil then
		tilesOn[2] = room[tileLoc2][tileLoc1]
		tileLocs[2] = {x=tileLoc1, y=tileLoc2}
	end
	

	xCorner = self.x
	yCorner = self.y+self.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~= nil then
		tilesOn[3] = room[tileLoc2][tileLoc1]
		tileLocs[3] = {x=tileLoc1, y=tileLoc2}
	end

	xCorner = self.x+self.width
	yCorner = self.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~= nil then
		tilesOn[4] = room[tileLoc2][tileLoc1]
		tileLocs[4] = {x=tileLoc1, y=tileLoc2}
	end

	for j = 1, 4 do
		local isOnNow = false
		for i = 1, 4 do
			if tilesOn[i] == oldTilesOn[j] then
				isOnNow = true
			end
		end
		if oldTilesOn[j] ~= nil and not isOnNow then
			oldTilesOn[j]:onLeave(player)
		end
	end
	for i = 1, 4 do
		local t = tilesOn[i]
		for j = 1, i-1 do
			if tilesOn[i] == tilesOn[j] then
				tilesOn[i] = nil
				t = nil
			end
		end
		if t ~= nil then
			local isOnStay  = false
			for j = 1, 4 do
				if oldTilesOn[j] == t then
					isOnStay = true
				end
			end
			if isOnStay then
				t:onStay(self, tileLocs[i])
			else
				t:onEnter(self, tileLocs[i])
			end
		end

	end
	for i = 1, 4 do
		oldTilesOn[i] = tilesOn[i]
	end
end

P.pitbull = P.animal:new{}


animalList[1] = P.animal
animalList[2] = P.pitbull

return animalList