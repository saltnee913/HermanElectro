require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
pushableList = P

P.pushable = Object:new{name = "pushable", visible = true, sawable = true, canBeAccelerated = true, conductive = false, prevTileX = 0, prevTileY = 0, tileX = 0, tileY = 0, destroyed = false, sprite = love.graphics.newImage('Graphics/box.png')}
function P.pushable:onStep()
end
function P.pushable:destroy()
	self.destroyed = true
end
function P.pushable:move(mover)
	if self.destroyed then
		return true
	end
	self.prevTileX = self.tileX
	self.prevTileY = self.tileY
		print(player.prevTileX.."   "..player.prevTileY.."   "..player.tileX.."   "..player.tileY)
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
	if room[self.tileY][self.tileX]~=nil and not room[self.tileY][self.tileX]:instanceof(tiles.endTile) and 
		(self.prevTileX~=self.tileX or self.prevTileY~=self.tileY) then
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
		self.canBeAccelerated = false
		return true
	elseif room[self.tileY][self.tileX]~=nil then
		room[self.tileY][self.tileX]:onStay(self)
	end
	
	return false
end
function P.pushable:moveNoMover()
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

	if room[self.tileY][self.tileX]~=nil and not room[self.tileY][self.tileX]:instanceof(tiles.endTile) and 
		(self.prevTileX~=self.tileX or self.prevTileY~=self.tileY) then
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
	elseif room[self.tileY][self.tileX]~=nil then
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
function P.pushable:checkDestruction()
	if room[self.tileY][self.tileX]~=nil then
		t = room[self.tileY][self.tileX]
		if self.destroyed == false and t.blocksMovement then
			self.destroyed = true
			room[self.tileY][self.tileX]:destroyPushable()
		end
	end
end

P.box = P.pushable:new{name = "box", sprite = love.graphics.newImage('Graphics/box.png')}

P.playerBox = P.box:new{name = "playerBox", sprite = love.graphics.newImage('Graphics/playerBox.png'), sawable = true}
function P.playerBox:animalCanMove()
	return self.destroyed
end

P.animalBox = P.box:new{name = "animalBox", sprite = love.graphics.newImage('Graphics/animalBox.png'), sawable = false}
function P.animalBox:playerCanMove()
	return self.destroyed
end

P.conductiveBox = P.box:new{name = "conductiveBox", powered = false, poweredLastUpdate = false, sprite = love.graphics.newImage('Graphics/conductiveBox.png'), poweredSprite = love.graphics.newImage('Graphics/conductiveboxpowered.png'), conductive = true}

P.boombox = P.box:new{name = "boombox", sprite = love.graphics.newImage('Graphics/boombox.png'), sawable = false}

P.batteringRam = P.box:new{name = "batteringRam", sprite = love.graphics.newImage('Graphics/batteringram.png')}
function P.batteringRam:move(mover)
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

	if room[self.tileY][self.tileX]~=nil and not room[self.tileY][self.tileX]:instanceof(tiles.endTile) then
		local tile = room[self.tileY][self.tileX]
		if tile.sawable or tile:instanceof(tiles.glassWall) then tile:destroy() end
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
	elseif room[self.tileY][self.tileX]~=nil then
		room[self.tileY][self.tileX]:onStay(self)
	end

	--[[below code allows batteringRam to kill player or animals if pushed on them
	if player.tileX == self.tileX and player.tileY == self.tileY then
		kill()
	end

	for i = 1, #animals do
		if animals[i].tileX == self.tileX and animals[i].tileY == self.tileY and not animal.flying then
			animals[i]:kill()
		end
	end
	]]
	
	return false
end

function P.batteringRam:moveNoMover()
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

	if room[self.tileY][self.tileX]~=nil and not room[self.tileY][self.tileX]:instanceof(tiles.endTile) then
		local tile = room[self.tileY][self.tileX]
		if tile.sawable or tile:instanceof(tiles.glassWall) then tile:destroy() end
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
	elseif room[self.tileY][self.tileX]~=nil then
		room[self.tileY][self.tileX]:onStay(self)
	end

	--[[below code allows batteringRam to kill player or animals if pushed on them
	if player.tileX == self.tileX and player.tileY == self.tileY then
		kill()
	end

	for i = 1, #animals do
		if animals[i].tileX == self.tileX and animals[i].tileY == self.tileY and not animal.flying then
			animals[i]:kill()
		end
	end
	]]
	
	return false
end

P.bombBox = P.conductiveBox:new{name = "bombBox", sprite = love.graphics.newImage('Graphics/bombBox.png')}
function P.bombBox:destroy()
	self.destroyed = true
	y = self.tileX
	x = self.tileY
	if not editorMode and math.abs(player.tileY-x)<2 and math.abs(player.tileX-y)<2 then kill() end
	for i = -1, 1 do
		for j = -1, 1 do
			if room[x+i]~=nil and room[x+i][y+j]~=nil then room[x+i][y+j]:destroy() end
		end
	end
	for k = 1, #animals do
		if math.abs(animals[k].tileY-x)<2 and math.abs(animals[k].tileX-y)<2 then animals[k]:kill() end
	end
	for k = 1, #pushables do
		if math.abs(pushables[k].tileY-x)<2 and math.abs(pushables[k].tileX-y)<2 and not pushables[k].destroyed then
			pushables[k]:destroy()
		end
	end
end

P.giftBox = P.box:new{name = "giftBox", sprite = love.graphics.newImage('Graphics/giftbox.png')}
function P.giftBox:destroy()
	tools.giveSupertools(1)
	self.destroyed = true
end

P.jackInTheBox = P.conductiveBox:new{name = "jackInTheBox", sprite = love.graphics.newImage('Graphics/jackinthebox.png'),
  poweredSprite = love.graphics.newImage('Graphics/jackintheboxpowered.png'), sawable = false}
function P.jackInTheBox:onStep()
	if self.poweredLastUpdate then
		for i = 1, #animals do
			animals[i].waitCounter = 1
		end
	end
end

P.invisibleBox = P.box:new{visible = false}

pushableList[1] = P.pushable
pushableList[2] = P.box
pushableList[3] = P.playerBox
pushableList[4] = P.animalBox
pushableList[5] = P.conductiveBox
pushableList[6] = P.boombox
pushableList[7] = P.batteringRam
pushableList[8] = P.bombBox
pushableList[9] = P.giftBox
pushableList[10] = P.jackInTheBox
pushableList[11] = P.invisibleBox

return pushableList