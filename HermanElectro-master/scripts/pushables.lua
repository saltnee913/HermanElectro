require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
pushableList = P

P.pushable = Object:new{name = "pushable", prevTileX = 0, prevTileY = 0, tileX = 0, tileY = 0, destroyed = false, sprite = love.graphics.newImage('Graphics/box.png')}
function P.pushable:move(player)
	self.prevTileX = self.tileX
	self.prevTileY = self.tileY
	if player.tileX~=player.prevTileX then
		self.tileX = self.tileX+(player.tileX-player.prevTileX)
	else
		self.tileY = self.tileY+(player.tileY-player.prevTileY)
	end
	if room[self.tileY]==nil or self.tileX>roomLength or self.tileX<1 then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
		return false
	end

	local sameSpotCounter = 0
	for i = 1, #pushables do
		if pushables[i].tileX == self.tileX and pushables[i].tileY==self.tileY and not pushables[i].destroyed then
			sameSpotCounter = sameSpotCounter+1
		end
	end
	if sameSpotCounter>=2 then
		self.tileX = self.prevTileX
		self.tileY = self.prevTileY
		return false
	end

	for i = 1, #animals do
		if animals[i].tileX == self.tileX and animals[i].tileY == self.tileY then
			self.tileX = self.prevTileX
			self.tileY = self.prevTileY
			return false
		end
	end

	if room[self.tileY][self.tileX]~=nil and not room[self.tileY][self.tileX]:instanceof(tiles.endTile) then
		room[self.tileY][self.tileX]:onEnter(self)
	end

	if not (self.prevTileY == self.tileY and self.prevTileX == self.tileX) then
		if room[self.prevTileY][self.prevTileX]~=nil then
			room[self.prevTileY][self.prevTileX]:onLeave(self)
		end
		if room[self.tileY][self.tileX]~=nil and room[self.tileY][self.tileX]:willDestroyPushable() then
			self.destroyed = true
			room[self.tileY][self.tileX]:destroyPushable()
		end
		return true
	elseif room[self.tileY][self.tileY]~=nil then
		room[self.tileY][self.tileX]:onStay(self)
	end
	return false
end

P.box = P.pushable:new{name = "box", sprite = love.graphics.newImage('Graphics/box.png')}

pushableList[1] = P.pushable
pushableList[2] = P.box

return pushableList