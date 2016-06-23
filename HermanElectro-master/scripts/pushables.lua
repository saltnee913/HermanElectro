require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
pushableList = P

P.pushable = Object:new{name = "pushable", prevTileX = 0, prevTileY = 0, tileX = 0, tileY = 0, destroyed = false, sprite = love.graphics.newImage('Graphics/box.png')}
function P.pushable:move(mover)
	if self.destroyed then
		return true
	end
	self.prevTileX = self.tileX
	self.prevTileY = self.tileY
	if mover.tileX~=mover.prevTileX then
		self.tileX = self.tileX+(mover.tileX-mover.prevTileX)
	else
		self.tileY = self.tileY+(mover.tileY-mover.prevTileY)
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

	if player.tileX == self.tileX and player.tileY == self.tileY then
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
function P.pushable:animalCanMove()
	return true
end
function P.pushable:playerCanMove()
	return true
end

P.box = P.pushable:new{name = "box", sprite = love.graphics.newImage('Graphics/box.png')}

P.playerBox = P.box:new{name = "playerBox", sprite = love.graphics.newImage('Graphics/playerBox.png')}
function P.playerBox:animalCanMove()
	return false
end

P.animalBox = P.box:new{name = "animalBox"}
function P.animalBox:playerCanMove()
	return false
end

pushableList[1] = P.pushable
pushableList[2] = P.box
pushableList[3] = P.playerBox
pushableList[4] = P.animalBox

return pushableList