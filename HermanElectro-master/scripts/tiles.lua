require('scripts.object')
require('scripts.boundaries')
require('scripts.animals')
require('scripts.pushables')
tools = require('scripts.tools')

local P = {}
tiles = P

P.tile = Object:new{formerPowered = nil, gone = false, lit = false, destroyed = false, blocksProjectiles = false, isVisible = true, rotation = 0, powered = false, blocksMovement = false, blocksAnimalMovement = false, poweredNeighbors = {0,0,0,0}, blocksVision = false, dirSend = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = false, name = "basicTile", sprite = love.graphics.newImage('Graphics/cavesfloor.png'), poweredSprite = love.graphics.newImage('Graphics/cavesfloor.png')}
function P.tile:onEnter(player) 
	--self.name = "fuckyou"
end
function P.tile:onLeave(player) 
	--self.name = "fuckme"
end
function P.tile:onStay(player) 
	--player.x = player.x+1
end
function P.tile:onStayAnimal(animal)
end
function P.tile:onEnterAnimal(animal)
end
function P.tile:onLeaveAnimal(animal)
end
function P.tile:onStep(x, y)
end
function P.tile:onEnd(map, x, y)
	return map
end
function P.tile:resetState()
end
function P.tile:destroy()
	self.destroyed = true
end
function P.tile:getInfoText()
	return nil
end
function P.tile:lockInState(state)
end
function P.tile:getYOffset()
	return 0
end
function P.tile:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	elseif self.name ~= "powerSupply" then
		self.powered = false
	end
end
function P.tile:updateSprite()
end
function P.tile:postPowerUpdate()
end
function P.tile:blocksMovementAnimal(animal)
	return not animal.flying and (self.blocksMovement or self.blocksAnimalMovement)
end
function P.tile:getCorrectedOffset(dir)
	dir = dir + self.rotation
	return util.getOffsetByDir(dir)
end
local function shiftArray(arr, times)
	if times == 0 then return arr end
	if(times == nil) then times = 1 end
	return shiftArray({arr[4], arr[1], arr[2], arr[3]}, times-1)
end
function P.tile:rotate(times)
	self.rotation = self.rotation + times
	if self.rotation >= 4 then
		self.rotation = self.rotation - 4
	end
	for i=1,times do
		self.dirSend = shiftArray(self.dirSend)
		self.dirAccept = shiftArray(self.dirAccept)
	end
end
function P.tile:willKillPlayer()
	return false
end
function P.tile:willDestroyPushable()
	return false
end
function P.tile:destroyPushable()
end
P.tile.willKillAnimal = P.tile.willKillPlayer
function P.tile:electrify()
	self.canBePowered = true
	self.dirSend = {1,1,1,1}
	self.dirAccept = {1,1,1,1}
	self.electrified = true
	self.sprite = self.electrifiedSprite
end
function P.tile:allowVision()
	self.blocksVision = false
end
function P.tile:usableOnNothing()
	return self.destroyed
end

P.invisibleTile = P.tile:new{isVisible = false}
local bounds = {}

P.boundedTile = P.tile:new{boundary = boundaries.Boundary}

P.conductiveTile = P.tile:new{charged = false, powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "conductiveTile", sprite = love.graphics.newImage('Graphics/lightoff.png'), poweredSprite = love.graphics.newImage('Graphics/lighton.png')}
function P.conductiveTile:updateTile(dir)
	if self.charged then
		self.powered = true
		return
	end
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	elseif self.name ~= "powerSupply" then
		self.powered = false
	end
end
function P.conductiveTile:destroy()
	self.destroyed = true
	self.charged = false
end

P.powerSupply = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "powerSupply", sprite = love.graphics.newImage('GraphicsTony/Power.png'), destroyedSprite = love.graphics.newImage('Graphics/powersupplydead.png'), poweredSprite = love.graphics.newImage('GraphicsTony/Power.png')}
function P.powerSupply:updateTile(dir)
end
function P.powerSupply:destroy()
	self.sprite = self.destroyedSprite
	self.canBePowered = false
	self.powered = false
	self.destroyed = true
	dirAccept = {0,0,0,0}
	dirSend = {0,0,0,0}
end

P.wire = P.conductiveTile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, destroyedSprite = love.graphics.newImage('Graphics/wirescut.png'), canBePowered = true, name = "wire", sprite = love.graphics.newImage('Graphics/wires.png'), poweredSprite = love.graphics.newImage('Graphics/poweredwires.png')}
function P.wire:destroy()
	self.sprite = self.destroyedSprite
	self.canBePowered = false
	self.destroyed = true
	dirAccept = {0,0,0,0}
	dirSend = {0,0,0,0}
end

P.maskedWire = P.wire:new{name = 'maskedWire', sprite = love.graphics.newImage('Graphics/maskedWire.png'), poweredSprite = love.graphics.newImage('Graphics/maskedWire.png')}


P.crossWire = P.wire:new{dirSend = {0,0,0,0}, dirAccept = {1,1,1,1}, name = "crossWire", sprite = love.graphics.newImage('Graphics/crosswires.png'), poweredSprite = love.graphics.newImage('Graphics/crosswires.png')}
function P.crossWire:updateTile(dir)
	self.powered = false
	self.dirSend = {0,0,0,0}
	if self.poweredNeighbors[self:cfr(2)]==1 or self.poweredNeighbors[self:cfr(4)]==1 then
		self.powered = true
		self.dirSend[self:cfr(2)]=1
		self.dirSend[self:cfr(4)]=1
	end
	if self.poweredNeighbors[self:cfr(1)]==1 or self.poweredNeighbors[self:cfr(3)]==1 then
		self.powered = true
		self.dirSend[self:cfr(1)]=1
		self.dirSend[self:cfr(3)]=1
	end
end

P.horizontalWire = P.wire:new{powered = false, dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, canBePowered = true, name = "horizontalWire", sprite = love.graphics.newImage('Graphics/horizontalWireUnpowered.png'), destroyedSprite = love.graphics.newImage('Graphics/horizontalWireCut.png'), poweredSprite = love.graphics.newImage('Graphics/horizontalWirePowered.png')}
P.verticalWire = P.wire:new{powered = false, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, canBePowered = true, name = "verticalWire", sprite = love.graphics.newImage('Graphics/verticalWireUnpowered.png'), destroyedSprite = love.graphics.newImage('Graphics/verticalWireCut.png'), poweredSprite = love.graphics.newImage('Graphics/verticalWirePowered.png')}
P.cornerWire = P.wire:new{dirSend = {0,1,1,0}, dirAccept = {0,1,1,0}, name = "cornerWire", sprite = love.graphics.newImage('Graphics/cornerWireUnpowered.png'), poweredSprite = love.graphics.newImage('Graphics/cornerWirePowered.png')}
P.tWire = P.wire:new{dirSend = {0,1,1,1}, dirAccept = {0,1,1,1}, name = "tWire", sprite = love.graphics.newImage('Graphics/tWireUnpowered.png'), poweredSprite = love.graphics.newImage('Graphics/tWirePowered.png')}

P.spikes = P.tile:new{powered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, canBePowered = true, name = "spikes", sprite = love.graphics.newImage('GraphicsTony/Spikes2.png')}
function P.spikes:willKillPlayer()
	return true
end
P.spikes.willKillAnimal = P.spikes.willKillPlayer

P.button = P.tile:new{bricked = false, justPressed = false, down = false, powered = false, dirSend = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = true, name = "button", pressed = false, sprite = love.graphics.newImage('Graphics/button.png'), poweredSprite = love.graphics.newImage('Graphics/button.png'), downSprite = love.graphics.newImage('Graphics/buttonPressed.png'), brickedSprite = love.graphics.newImage('Graphics/brickedButton.png'), upSprite = love.graphics.newImage('Graphics/button.png')}
function P.button:resetState()
	self.justPressed = false
end
function P.button:updateSprite()
	if self.bricked then
		self.sprite = self.brickedSprite
		self.poweredSprite = self.brickedSprite
	elseif self.down then
		self.sprite = self.downSprite
		self.poweredSprite = self.downSprite
	else
		self.sprite = self.upSprite
		self.poweredSprite = self.upSprite
	end
end
function P.button:onEnter(player)
	--justPressed prevents flickering button next to wall
	if self.bricked then
		return
	end
	if not self.justPressed then
		self.justPressed = true
		self.down = not self.down
		if self.dirAccept[1]==1 then
			self.powered = false
			self.dirAccept = {0,0,0,0}
		else
			self.dirAccept = {1,1,1,1}
		end
		--updateGameState()
		self:updateSprite()
		--self.name = "onbutton"
	end
end
function P.button:lockInState(state)
	self.bricked = state
	self.down = state
	self.dirAccept = state and {1,1,1,1} or {0,0,0,0}
	self.dirSend = state and {1,1,1,1} or {0,0,0,0}
	self.canBePowered = state
	--updateGameState()
	self:updateSprite()
end
function P.button:onLeave(player)
	self.justPressed = false
end
function P.button:onEnterAnimal(animal)
	if self.bricked then
		return
	end
	if not animal.flying and not self.justPressed then
		self.justPressed = true
		self.down = not self.down
		if self.dirAccept[1]==1 then
			self.powered = false
			self.dirAccept = {0,0,0,0}
		else
			self.dirAccept = {1,1,1,1}
		end
		--updateGameState()
		self:updateSprite()
		--self.name = "onbutton"
	end
end
P.button.onLeaveAnimal = P.button.onLeave

function P.button:updateTile(dir)
	if self.down and (self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1) then
		self.powered = true
	else
		self.powered = false
	end
end

P.stickyButton = P.button:new{name = "stickyButton", downSprite = love.graphics.newImage('Graphics/stickyButtonPressed.png'), sprite = love.graphics.newImage('Graphics/stickyButton.png'), upSprite = love.graphics.newImage('Graphics/stickyButton.png')}
function P.stickyButton:onEnter(player)
	self.justPressed = true
	self.down = true
	self.dirAccept = {1,1,1,1}
	--updateGameState()
	self:updateSprite()
end
function P.stickyButton:onLeave(player)
end
function P.stickyButton:unstick()
	self.justPressed = false
	self.down = false
	self.dirAccept = {0,0,0,0}
	--updateGameState()
	self:updateSprite()
end
P.stickyButton.onEnterAnimal = P.stickyButton.onEnter
P.stickyButton.onLeaveAnimal = P.stickyButton.onLeave

P.stayButton = P.button:new{name = "stayButton", sprite = love.graphics.newImage('Graphics/staybutton.png'), upSprite = love.graphics.newImage('Graphics/staybutton.png')}
function P.stayButton:onEnter(player)
	self.justPressed = true
	if self.bricked then return end
	self.down = true
	self.dirAccept = {1,1,1,1}
	--updateGameState()
	self:updateSprite()
end
function P.stayButton:onLeave(player)
	if self.bricked then return end
	if not self.justPressed then
		self.down = false
		self.dirAccept = {0,0,0,0}
		--updateGameState()
		self:updateSprite()
	end
	self.justPressed = false
end
P.stayButton.onEnterAnimal = P.stayButton.onEnter
P.stayButton.onLeaveAnimal = P.stayButton.onLeave
--P.stayButton.onLeave = P.stayButton.onEnter

P.electricFloor = P.conductiveTile:new{name = "electricfloor", sprite = love.graphics.newImage('GraphicsTony/EFloor0.png'),--[[sprite = love.graphics.newImage('Graphics/electricfloor.png'),]] destroyedSprite = love.graphics.newImage('Graphics/electricfloorcut.png'), --[[poweredSprite = love.graphics.newImage('Graphics/electricfloorpowered.png')]]
poweredSprite = love.graphics.newImage('GraphicsTony/EFloor1.png')}
function P.electricFloor:destroy()
	self.sprite = self.destroyedSprite
	self.canBePowered = false
	self.destroyed = true
	dirAccept = {0,0,0,0}
	dirSend = {0,0,0,0}
end
function P.electricFloor:willKillPlayer()
	return not self.destroyed and self.powered
end
P.electricFloor.willKillAnimal = P.electricFloor.willKillPlayer

P.poweredFloor = P.conductiveTile:new{name = "poweredFloor", laddered = false, destroyedSprite = love.graphics.newImage('Graphics/trapdoorwithladder.png'), destroyedPoweredSprite = love.graphics.newImage('Graphics/trapdoorclosedwithladder.png'), --[[sprite = love.graphics.newImage('Graphics/trapdoor.png'), poweredSprite = love.graphics.newImage('Graphics/trapdoorclosed.png')]]
sprite = love.graphics.newImage('GraphicsTony/Pit5.png'), poweredSprite = love.graphics.newImage('GraphicsTony/Pit0.png')}
function P.poweredFloor:ladder()
	self.sprite = self.destroyedSprite
	self.poweredSprite = self.destroyedPoweredSprite
	self.laddered = true
end
function P.poweredFloor:willKillPlayer()
	return not self.powered and not self.laddered
end
function P.poweredFloor:destroyPushable()
	self:ladder()
end
P.poweredFloor.willKillAnimal = P.poweredFloor.willKillPlayer
P.poweredFloor.willDestroyPushable = P.poweredFloor.willKillPlayer

P.wall = P.tile:new{electrified = false, onFire = false, blocksProjectiles = true, blocksMovement = true, canBePowered = false, name = "wall", blocksVision = true, electrifiedSprite = love.graphics.newImage('Graphics/woodwallelectrified.png'), destroyedSprite = love.graphics.newImage('Graphics/woodwallbroken.png'), sprite = love.graphics.newImage('Graphics3D/woodwall.png'), poweredSprite = love.graphics.newImage('Graphics/woodwallpowered.png'), sawable = true}
function P.wall:onEnter(player)	
	if not self.destroyed then
		--player.x = player.prevx
		--player.y = player.prevy
		player.tileX = player.prevTileX
		player.tileY = player.prevTileY
		--player.prevx = player.x
		--player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
	end
end
P.wall.onStay = P.wall.onEnter
function P.wall:onEnterAnimal(animal)
	if not self.destroyed and not animal.flying then
		animal.x = animal.prevx
		animal.y = animal.prevy
		animal.tileX = animal.prevTileX
		animal.tileY = animal.prevTileY
		animal.prevx = animal.x
		animal.prevy = animal.y
		animal.prevTileX = animal.tileX
		animal.prevTileY = animal.tileY
	end
end
P.wall.onStayAnimal = P.wall.onEnterAnimal
function P.wall:getYOffset()
	if self.destroyed then return 0 end
	return yOffset
end
function P.wall:destroy()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
end
function P.wall:rotate(times)
end

P.metalWall = P.wall:new{dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}, canBePowered = true, name = "metalwall", blocksVision = true, destroyedSprite = love.graphics.newImage('Graphics/metalwallbroken.png'), sprite = love.graphics.newImage('Graphics3D/metalwall.png'), poweredSprite = love.graphics.newImage('Graphics3D/metalwallpowered.png') }
P.metalWall.updateTile = P.conductiveTile.updateTile
function P.metalWall:destroy()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.charged = false
	self.canBePowered = false
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
	self.blocksMovement = false
end

P.maskedMetalWall = P.metalWall:new{sprite = love.graphics.newImage('Graphics/maskedMetalWall.png'), poweredSprite = love.graphics.newImage('Graphics/maskedMetalWall.png')}

P.glassWall = P.wall:new{sawable = false, canBePowered = false, dirAccept = {0,0,0,0}, dirSend = {0,0,0,0}, bricked = false, name = "glasswall", blocksVision = false, electrifiedSprite = love.graphics.newImage('Graphics/glasswallelectrified.png'), destroyedSprite = love.graphics.newImage('Graphics/glassbroken.png'), sprite = love.graphics.newImage('Graphics3D/glass.png'), poweredSprite = love.graphics.newImage('Graphics/glasswallpowered.png'), sawable = false }
P.glassWall.getYOffset = P.wall.getYOffset
function P.glassWall:destroy()
	self.blocksProjectiles = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
	self.blocksVision = false
end

P.gate = P.conductiveTile:new{name = "gate", dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, gotten = {0,0,0,0}}
function P.gate:updateTile(dir)
	self.gotten[dir] = 1
end
function P.tile:correctForRotation(dir)
	local temp = dir + self.rotation
	while(temp > 4) do
		temp = temp - 4
	end
	--if temp ~= dir then print(temp..';'..dir) end
	return temp
end
P.tile.cfr = P.gate.correctForRotation

P.splitGate = P.gate:new{name = "splitGate", dirSend = {1,0,0,0}, dirAccept = {1,0,0,0}, sprite = love.graphics.newImage('Graphics/splitgate.png'), poweredSprite = love.graphics.newImage('Graphics/splitgate.png') }
function P.splitGate:updateTile(dir)
	if dir == self:cfr(1) then
		self.powered=true
		self.dirSend = shiftArray({0,1,0,1}, self.rotation)
		self.dirAccept = shiftArray({0,1,0,1}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
		self.dirAccept = shiftArray({1,0,0,0}, self.rotation)
	end
end

P.notGate = P.gate:new{name = "notGate", dirSend = {1,0,0,0}, dirAccept = {1,1,1,1}, sprite = love.graphics.newImage('Graphics/notgateoff.png'), poweredSprite = love.graphics.newImage('Graphics/notgate.png') }
function P.notGate:updateTile(dir)
	if self.destroyed then
		self.powered = false
		return
	end
	if self.poweredNeighbors[self:cfr(3)] == 0 then
	--if self.poweredNeighbors[2] == 0 and self.poweredNeighbors[4] == 0 then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
function P.notGate:destroy()
	self.destroyed = true
	self.powered = false
end

P.andGate = P.gate:new{name = "andGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, sprite = love.graphics.newImage('Graphics/andgate.png'), poweredSprite = love.graphics.newImage('Graphics/andgate.png') }
function P.andGate:updateTile(dir)
	if self.charged then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
		return
	end
	if self.poweredNeighbors[self:cfr(2)]==1 and self.poweredNeighbors[self:cfr(4)]==1 then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
P.andGate.destroy = P.conductiveTile.destroy

P.orGate = P.gate:new{name = "orGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, sprite = love.graphics.newImage('Graphics/orgate.png'), poweredSprite = love.graphics.newImage('Graphics/orgate.png') }
function P.orGate:updateTile(dir)
	if self.charged then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
		return
	end
	if self.poweredNeighbors[self:cfr(2)]==1 or self.poweredNeighbors[self:cfr(4)]==1 then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
P.orGate.destroy = P.conductiveTile.destroy


local function getTileX(posX)
	return (posX-1)*floor.sprite:getWidth()*scale+wallSprite.width
end

local function getTileY(posY)
	return (posY-1)*floor.sprite:getHeight()*scale+wallSprite.height
end

P.hDoor= P.tile:new{name = "hDoor", stopped = false, blocksVision = true, blocksMovement = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
function P.hDoor:updateTile(player)
	if self.stopped then
		self.sprite = self.openSprite
		self.blocksVision = false
		self.blocksMovement = false
	end
end
function P.hDoor:onEnter(player)
	self.sprite = self.openSprite
	self.blocksVision = false
	self.blocksMovement = false	
end

P.vDoor= P.tile:new{name = "hDoor", blocksVision = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
function P.vDoor:onEnter(player)
	self.sprite = self.openSprite
	self.blocksVision = false
	
end

P.vPoweredDoor = P.tile:new{name = "vPoweredDoor", stopped = false, blocksMovement = false, blocksVision = false, canBePowered = true, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, sprite = love.graphics.newImage('Graphics3D/powereddooropen.png'), closedSprite = love.graphics.newImage('Graphics3D/powereddoor.png'), openSprite = love.graphics.newImage('Graphics3D/powereddooropen.png'), poweredSprite = love.graphics.newImage('Graphics3D/powereddoor.png'),
closedSprite2 = love.graphics.newImage('Graphics3D/powereddoor2.png'), openSprite2 = love.graphics.newImage('Graphics3D/powereddooropen2.png')}
function P.vPoweredDoor:updateTile(player)
	if self.stopped then
		self.blocksVision = false
		self.sprite = self.openSprite
		self.blocksMovement = false
		self.blocksProjectiles = false
		self.canBePowered = false
		return
	end
	if self.poweredNeighbors[self:cfr(1)] == 1 or self.poweredNeighbors[self:cfr(3)]==1 then
		self.blocksVision = true
		self.sprite = self.closedSprite
		self.blocksMovement = true
		self.blocksProjectiles = true
		self.powered = true
	else
		self.blocksVision = false
		self.blocksProjectiles = false
		self.blocksMovement = false
		self.sprite = self.openSprite
	end
end
function P.vPoweredDoor:onEnter(player)
	if self.blocksMovement then
		player.x = player.prevx
		player.y = player.prevy
		player.tileX = player.prevTileX
		player.tileY = player.prevTileY
		player.prevx = player.x
		player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
	end
end
P.vPoweredDoor.onStay = P.vPoweredDoor.onEnter
function P.vPoweredDoor:willKillPlayer(player)
	return t.blocksMovement
end
function P.vPoweredDoor:destroy()
	self.stopped = true
	self.open = true
end
function P.vPoweredDoor:getYOffset()
	return yOffset
end
function P.vPoweredDoor:rotate(times)
	self.rotation = self.rotation + times
	if self.rotation >= 4 then
		self.rotation = self.rotation - 4
	end
	for i=1,times do
		self.dirSend = shiftArray(self.dirSend)
		self.dirAccept = shiftArray(self.dirAccept)
	end
	self:updateSprite()
end
function P.vPoweredDoor:updateSprite()
	if self.rotation == 0 or self.rotation == 2 then
		self.sprite = self.openSprite
		self.poweredSprite = self.closedSprite
	else
		self.sprite = self.openSprite2
		self.poweredSprite = self.closedSprite2
	end
end
P.vPoweredDoor.willKillAnimal = P.vPoweredDoor.willKillPlayer

P.hPoweredDoor = P.vPoweredDoor:new{name = "hPoweredDoor", dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}}
function P.hPoweredDoor:updateTile(player)
	if self.poweredNeighbors[2] == 1 or self.poweredNeighbors[4]==1 then
		self.blocksVision = true
		self.sprite = self.closedSprite
		self.blocksMovement = true
	else
		self.blocksVision = false
		self.sprite = self.openSprite
		self.blocksMovement = false
	end
end

function P.hDoor:onLeave(player)
	--self.sprite = self.closedSprite
	--self.blocksVision = true
	--
end

P.endTile = P.tile:new{name = "endTile", canBePowered = false, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/end.png'), done = false}
function P.endTile:onEnter(player)
	if self.done then return end
	beatRoom()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.poweredEnd = P.endTile:new{name = "poweredEnd", canBePowered = true, dirAccept = {1,1,1,1}, sprite = love.graphics.newImage('Graphics/endOff.png'), poweredSprite = love.graphics.newImage('Graphics/end.png')}
function P.poweredEnd:onEnter(player)
	if self.done or not self.powered then return end
	beatRoom()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.pitbullTile = P.tile:new{name = "pitbull", animal = animalList[2]:new(), sprite = love.graphics.newImage('Graphics/animalstartingtile.png'), listIndex = 2}
P.pupTile = P.pitbullTile:new{name = "pup", animal = animalList[3]:new(), listIndex = 3}
P.catTile = P.pitbullTile:new{name = "cat", animal = animalList[4]:new(), listIndex = 4}

P.vDoor= P.hDoor:new{name = "vDoor", sprite = love.graphics.newImage('Graphics3D/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
P.vDoor.onEnter = P.hDoor.onEnter

P.sign = P.tile:new{text = "", name = "sign"}

P.rotater = P.button:new{canBePowered = true, dirAccept = {1,0,1,0}, dirSend = {1,0,1,0}, sprite = love.graphics.newImage('Graphics/rotater.png'), poweredSprite = love.graphics.newImage('Graphics/rotater.png')}
function P.rotater:updateSprite()
end
function P.rotater:onEnter(player)
	if self.bricked then return end
	if not self.justPressed then
		self:rotate(1)
		self.justPressed = true
	end
end
function P.rotater:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	else
		self.powered = false
	end
end
function P.rotater:onLeave(player)
	self.justPressed = false
end
function P.rotater:lockInState(state)
	self:rotate(1)
	self.bricked = true
end
P.rotater.onEnterAnimal = P.rotater.onEnter
P.rotater.onLeaveAnimal = P.rotater.onLeave

P.concreteWall = P.wall:new{sawable = false, name = "concreteWall", sprite = love.graphics.newImage('Graphics3D/concretewall.png'), poweredSprite = love.graphics.newImage('Graphics/concretewallpowered.png'), electrifiedSprite = love.graphics.newImage('Graphics/concretewallelectrified.png'), destroyedSprite = love.graphics.newImage('Graphics/concretewallbroken.png'), sawable = false}
function P.concreteWall:destroy()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
end

P.concreteWallConductive = P.concreteWall:new{name = "concreteWallConductive", sprite = love.graphics.newImage('Graphics3D/concretewallconductive.png'), poweredSprite = love.graphics.newImage('Graphics3D/concretewallconductive.png'), canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.concreteWallConductiveDirected = P.concreteWallConductive:new{name = "concreteWallConductiveDirected", sprite = love.graphics.newImage('Graphics3D/concretewallconductivedirected0.png'), poweredSprite = love.graphics.newImage('Graphics3D/concretewallconductivedirected0.png'),
canBePowered = true, dirAccept = {1,0,1,0}, dirSend = {1,0,1,0}, sprite0 = love.graphics.newImage('Graphics3D/concretewallconductivedirected0.png'), sprite1 = love.graphics.newImage('Graphics3D/concretewallconductivedirected1.png')}
function P.concreteWallConductiveDirected:rotate(times)
	self.rotation = self.rotation + times
	if self.rotation >= 4 then
		self.rotation = self.rotation - 4
	end
	for i=1,times do
		self.dirSend = shiftArray(self.dirSend)
		self.dirAccept = shiftArray(self.dirAccept)
	end
	self:updateSprite()
end

function P.concreteWallConductiveDirected:updateSprite()
	if self.destroyed then return end
	if self.rotation==0 then self.sprite = self.sprite0
	elseif self.rotation==1 then self.sprite = self.sprite1
	elseif self.rotation==2 then self.sprite = self.sprite0
	elseif self.rotation==3 then self.sprite = self.sprite1 end
	self.poweredSprite = self.sprite
end

P.concreteWallConductiveCorner = P.concreteWallConductive:new{name = "concreteWallConductiveCorner", sprite = love.graphics.newImage('Graphics3D/concretewallconductivecorner0.png'), poweredSprite = love.graphics.newImage('Graphics/concretewallconductivecorner.png'), canBePowered = true, dirAccept = {1,1,0,0}, dirSend = {1,1,0,0},
sprite0 = love.graphics.newImage('Graphics3D/concretewallconductivecorner0.png'), sprite1 = love.graphics.newImage('Graphics3D/concretewallconductivecorner1.png'), sprite2 = love.graphics.newImage('Graphics3D/concretewallconductivecorner2.png'), sprite3 = love.graphics.newImage('Graphics3D/concretewallconductivecorner3.png')}
P.concreteWallConductiveCorner.rotate = P.concreteWallConductiveDirected.rotate
function P.concreteWallConductiveCorner:updateSprite()
	if self.destroyed then return end
	if self.rotation==0 then self.sprite = self.sprite0
	elseif self.rotation==1 then self.sprite = self.sprite1
	elseif self.rotation==2 then self.sprite = self.sprite2
	elseif self.rotation==3 then self.sprite = self.sprite3 end
	self.poweredSprite = self.sprite
end

P.concreteWallConductiveT = P.concreteWallConductive:new{name = "concreteWallConductiveT", sprite = love.graphics.newImage('Graphics3D/concretewallconductivet0.png'), poweredSprite = love.graphics.newImage('Graphics/concretewallconductivet.png'), canBePowered = true, dirAccept = {1,1,1,0}, dirSend = {1,1,1,0},
sprite0 = love.graphics.newImage('Graphics3D/concretewallconductivet0.png'), sprite1 = love.graphics.newImage('Graphics3D/concretewallconductivet1.png'), sprite2 = love.graphics.newImage('Graphics3D/concretewallconductivet2.png'), sprite3 = love.graphics.newImage('Graphics3D/concretewallconductivet3.png')}
P.concreteWallConductiveT.rotate = P.concreteWallConductiveDirected.rotate
P.concreteWallConductiveT.updateSprite = P.concreteWallConductiveCorner.updateSprite

P.tunnel = P.tile:new{name = "tunnel"}
function P.tunnel:onEnter(player)
	local needToRemove = toolMax
	while needToRemove>0 do
		local noNormalTools = true
		for i = 1, tools.numNormalTools do
			if tools[i].numHeld>0 then noNormalTools = false end
		end
		if noNormalTools then break end

		local slot = math.floor(math.random()*tools.numNormalTools)+1
		if tools[slot].numHeld>0 then
			tools[slot].numHeld = tools[slot].numHeld-1
			needToRemove = needToRemove-1
		end
	end
	loadNextLevel()
end
function P.tunnel:getInfoText()
	return toolMax
end

P.pit = P.tile:new{name = "pit", laddered = false, sprite = love.graphics.newImage('Graphics/pit.png'), destroyedSprite = love.graphics.newImage('Graphics/ladderedPit.png')}
function P.pit:ladder()
	self.sprite = self.destroyedSprite
	self.laddered = true
end
function P.pit:willKillPlayer()
	return not self.laddered
end
function P.pit:destroyPushable()
	self.sprite = self.destroyedSprite
	self.laddered = true
end
P.pit.willKillAnimal = P.pit.willKillPlayer
P.pit.willDestroyPushable = P.pit.willKillPlayer

P.breakablePit = P.pit:new{strength = 2, name = "breakablePit", sprite = love.graphics.newImage('Graphics/pitcovered.png'), halfBrokenSprite = love.graphics.newImage('Graphics/pithalfcovered.png'), brokenSprite = love.graphics.newImage('Graphics/pit.png')}
function P.breakablePit:onEnter(player)
	if self.strength>0 then
		self.strength = self.strength - 1
	end
	if self.strength == 1 then
		self.sprite = self.halfBrokenSprite
	elseif self.strength == 0 and not self.laddered then
		self.sprite = self.brokenSprite
	else
		self.sprite = self.destroyedSprite
	end
end
function P.breakablePit:onEnterAnimal(animal)
	self:onEnter()
	if self.strength <= 0 then
		animal:kill()
	end
end
function P.breakablePit:willKillPlayer()
	return not self.laddered and self.strength == 0
end
P.breakablePit.willKillAnimal = P.breakablePit.willKillPlayer
P.breakablePit.willDestroyPushable = P.breakablePit.willKillPlayer

P.treasureTile = P.tile:new{name = "treasureTile", sprite = love.graphics.newImage('Graphics/treasuretile.png'), done = false}
function P.treasureTile:onEnter()
	if self.done then return end
	reward =  math.floor(math.random()*1000)
	--[[if self.name == "treasureTile2" then
		reward = reward + 200
		if reward > 1010 then
			reward = 500
		end
	end]]

	if reward<333-donations*25 then

		--do nothing
	elseif reward<850-donations*12 then
		--give one tool
		slot = math.floor(math.random()*tools.numNormalTools)+1
		tools[slot].numHeld = tools[slot].numHeld+1
	elseif reward<950-donations*6 then
		--give two tools
		for i = 1, 2 do
			slot = math.floor(math.random()*tools.numNormalTools)+1
			tools[slot].numHeld = tools[slot].numHeld+1
		end
	elseif reward<980-donations*3 then
		--give three tools
		for i = 1, 3 do
			slot = math.floor(math.random()*tools.numNormalTools)+1
			tools[slot].numHeld = tools[slot].numHeld+1
		end
	elseif reward<990-donations then
		--give one special tool
		filledSlots = {0,0,0}
		slot = 1
		for i = tools.numNormalTools + 1, #tools do
			if tools[i].numHeld>0 then
				filledSlots[slot] = i
				slot = slot+1
			end
		end
		goodSlot = false
		while (not goodSlot) do
			slot = tools.chooseSupertool()
			if filledSlots[3]==0 then
				goodSlot = true
			end
			for i = 1, 3 do
				if filledSlots[i]==slot then
					goodSlot = true
				end
			end
		end
		tools[slot].numHeld = tools[slot].numHeld+1
	else
		--give two special tools
		for j = 1, 2 do
			filledSlots = {0,0,0}
			slot = 1
			for i = tools.numNormalTools + 1, #tools do
				if tools[i].numHeld>0 then
					filledSlots[slot] = i
					slot = slot+1
				end
			end
			goodSlot = false
			while (not goodSlot) do
				slot = tools.chooseSupertool()
				if filledSlots[3]==0 then
					goodSlot = true
				end
				for i = 1, 3 do
					if filledSlots[i]==slot then
						goodSlot = true
					end
				end
			end
			tools[slot].numHeld = tools[slot].numHeld+1
		end
	end
	self.done = true
	self.isCompleted = true
	self.isVisible = false
end

P.mousetrap = P.conductiveTile:new{name = "mousetrap", bricked = false, formerPowered = nil, triggered = false, safe = false, sprite = love.graphics.newImage('Graphics/mousetrap.png'), safeSprite = love.graphics.newImage('Graphics/mousetrapsafe.png'), deadlySprite = love.graphics.newImage('Graphics/mousetrap.png'), brickedSprite = love.graphics.newImage('Graphics/mousetrapbricked.png')}
function P.mousetrap:onEnter()
	if self.bricked then return end
	if not self.safe then
		self.triggered = true
		self:updateSprite()
	end
end
P.mousetrap.onEnterAnimal = P.mousetrap.onEnter
function P.mousetrap:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	else
		self.powered = false
	end
	self:updateSprite()
end
function P.mousetrap:updateSprite()
	if self.bricked then self.sprite = self.brickedSprite
	elseif self.safe then self.sprite = self.safeSprite
	else self.sprite = self.deadlySprite end
	self.poweredSprite = self.sprite
end
function P.mousetrap:willKillPlayer()
	if self.triggered then
		self.triggered = false
		self.safe = true
		self:updateSprite()
		return true
	end
	return false
end
function P.mousetrap:postPowerUpdate()
	if self.bricked then return end
	if self.formerPowered~=nil and self.formerPowered~=self.powered and self.safe then
		self.safe = false
		self:updateSprite()
	end
end
P.mousetrap.willKillAnimal = P.mousetrap.willKillPlayer
function P.mousetrap:lockInState(state)
	self.bricked = true
	self.safe = true
	self.triggered = false
	self:updateSprite()
end

P.bomb = P.tile:new{name = "bomb", triggered = true, counter = 3, sprite = love.graphics.newImage('Graphics/bomb3.png'), sprite2 = love.graphics.newImage('Graphics/bomb2.png'), sprite1 = love.graphics.newImage('Graphics/bomb1.png')}
function P.bomb:onStep(x, y)
	if not self.triggered then return end
	self.counter = self.counter-1
	if self.counter == 2 then
		self.sprite = self.sprite2
	elseif self.counter == 1 then
		self.sprite = self.sprite1
	elseif self.counter == 0 then
		self.gone = true
	end
end
function P.bomb:onEnd(map, x, y)
	for i = -1, 1 do
		for j = -1, 1 do
			if map[x+i]~=nil and map[x+i][y+j]~=nil then map[x+i][y+j]:destroy() end
		end
	end
	return map
end

P.capacitor = P.conductiveTile:new{name = "capacitor", counter = 3, maxCounter = 3, dirAccept = {1,0,1,0}, sprite = love.graphics.newImage('Graphics/capacitor.png'), poweredSprite = love.graphics.newImage('Graphics/capacitor.png')}
function P.capacitor:updateTile(dir)
	if self.charged then
		self.powered = true
		self.dirSend = shiftArray({1,0,1,0}, self.rotation)
		return
	end
	if self.counter>0 then
		self.powered = true
		self.dirSend = shiftArray({1,0,1,0}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
function P.capacitor:onStep(x, y)
	if not (self.poweredNeighbors[1]==0 and self.poweredNeighbors[2]==0 and self.poweredNeighbors[3]==0 and self.poweredNeighbors[4]==0) then
		if self.counter>0 then
			self.counter = self.counter - 1
		end
	elseif self.counter<self.maxCounter then
		self.counter = self.counter+1
	end
end
function P.capacitor:getInfoText()
	return self.counter
end

P.inductor = P.conductiveTile:new{name = "inductor", counter = 3, maxCounter = 3, dirAccept = {1,0,1,0}, sprite = love.graphics.newImage('Graphics/inductor.png'), poweredSprite = love.graphics.newImage('Graphics/inductor.png')}
function P.inductor:updateTile(dir)	if self.charged then
		self.powered = true
		self.dirSend = shiftArray({1,0,1,0}, self.rotation)
		return
	end
	if self.counter == 0 then
		self.powered = true
		self.dirSend = shiftArray({1,0,1,0}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
P.inductor.onStep = P.capacitor.onStep
P.inductor.getInfoText = P.capacitor.getInfoText

P.slime = P.tile:new{name = "slime", sprite = love.graphics.newImage('Graphics/slime.png')}
function P.slime:onEnter(player)
	player.waitCounter = player.waitCounter+1
end
function P.slime:onEnterAnimal(animal)
	if animal:instanceof(animalList.snail) then return end
	if animal.waitCounter<=0 then
		animal.waitCounter = animal.waitCounter+1
	end
end

P.unactivatedBomb = P.bomb:new{name = "unactivatedBomb", counter = 4, triggered = false, sprite = love.graphics.newImage('Graphics/bomb3.png'), sprite2 = love.graphics.newImage('Graphics/bomb2.png'), sprite1 = love.graphics.newImage('Graphics/bomb1.png')}
function P.unactivatedBomb:onStep(x, y)
	if self.triggered then
		self.counter = self.counter-1
		if self.counter == 2 then
			self.sprite = self.sprite2
		elseif self.counter == 1 then
			self.sprite = self.sprite1
		elseif self.counter == 0 then
			self.gone = true
		end
		self.poweredSprite = self.sprite
	end
end
function P.unactivatedBomb:onEnd(map, x, y)
	for i = -1, 1 do
		for j = -1, 1 do
			if map[x+i]~=nil and map[x+i][y+j]~=nil then map[x+i][y+j]:destroy() end
		end
	end
	return map
end
function P.unactivatedBomb:onEnter(player)
	self.triggered = true
end
function P.unactivatedBomb:onEnterAnimal(animal)
	self.triggered = true
end

P.snailTile = P.pitbullTile:new{name = "snail", animal = animalList[5]:new(), listIndex = 5}

P.doghouse = P.pitbullTile:new{name = "doghouse", sprite = love.graphics.newImage('Graphics/doghouse.png')}
function P.doghouse:onStep(x, y)
	if player.tileX == y and player.tileY == x then return end
	for i = 1, #animals do
		if animals[i].tileY == x and animals[i].tileX == y then return end
	end
	animals[animalCounter] = animalList[2]:new()
	animals[animalCounter].y = y*floor.sprite:getWidth()*scale+wallSprite.height
	animals[animalCounter].x = x*floor.sprite:getHeight()*scale+wallSprite.width
	animals[animalCounter].tileX = y
	animals[animalCounter].tileY = x
	animalCounter=animalCounter+1
end

P.batTile = P.pitbullTile:new{name = "bat", animal = animalList[6]:new(), listIndex = 6}

P.meat = P.tile:new{name = "meat", sprite = love.graphics.newImage('Graphics/meat.png')}

P.beggar = P.tile:new{name = "beggar", alive = true, counter = 0, sprite = love.graphics.newImage('Graphics/beggar.png'), deadSprite = love.graphics.newImage('Graphics/beggardead.png')}
function P.beggar:onEnter(player)
	if tool==0 or tool>7 then return end
	if not self.alive then return end
	tools[tool].numHeld = tools[tool].numHeld - 1
	self.counter = self.counter+1
	probabilityOfPayout = math.atan(self.counter)*1/math.pi
	randomNum = math.random()
	if randomNum<probabilityOfPayout then
		self.counter = 0
		filledSlots = {0,0,0}
		slot = 1
		for i = tools.numNormalTools + 1, #tools do
			if tools[i].numHeld>0 then
				filledSlots[slot] = i
				slot = slot+1
			end
		end
		goodSlot = false
		while (not goodSlot) do
			slot = tools.chooseSupertool()
			if filledSlots[3]==0 then
				goodSlot = true
			end
			for i = 1, 3 do
				if filledSlots[i]==slot then
					goodSlot = true
				end
			end
		end
		tools[slot].numHeld = tools[slot].numHeld+1
		local killBeggar = math.random()
		if killBeggar<0.5 then self:destroy() end
	end
end
function P.beggar:destroy()
	self.sprite = self.deadSprite
	self.alive = false
	local paysOut = math.random()
	if paysOut<0.5 then return end
	filledSlots = {0,0,0}
	slot = 1
	for i = tools.numNormalTools + 1, #tools do
		if tools[i].numHeld>0 then
			filledSlots[slot] = i
			slot = slot+1
		end
	end
	goodSlot = false
	while (not goodSlot) do
		slot = math.floor(math.random()*5)+8
		if filledSlots[3]==0 then
			goodSlot = true
		end
		for i = 1, 3 do
			if filledSlots[i]==slot then
				goodSlot = true
			end
		end
	end
	tools[slot].numHeld = tools[slot].numHeld+1
end

P.ladder = P.tile:new{name = "ladder", sprite = love.graphics.newImage('Graphics/laddertile.png'), blocksAnimalMovement = true}

P.mousetrapOff = P.mousetrap:new{safe = true, sprite = love.graphics.newImage('Graphics/mousetrapsafe.png')}

P.donationMachine = P.tile:new{name = "donationMachine", sprite = love.graphics.newImage('Graphics/donationmachine.png')}
function P.donationMachine:getInfoText()
	return donations
end
function P.donationMachine:onEnter(player)
	if tool==0 or tool>7 then return end
	tools[tool].numHeld = tools[tool].numHeld - 1
	donations = donations+1
	gameTime = gameTime+20
end

P.entrancePortal = P.tile:new{name = "entrancePortal", sprite = love.graphics.newImage('Graphics/entrancePortal.png')}
function P.entrancePortal:onEnter(player)
	for i = 1, roomHeight do
		shouldBreak = false
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.exitPortal) then
				player.tileX = j
				player.tileY = i
				shouldBreak = true
				break
			end
		end
		if shouldBreak then break end
	end
end
P.entrancePortal.onEnterAnimal = P.entrancePortal.onEnter

P.exitPortal = P.tile:new{name = "exitPortal", sprite = love.graphics.newImage('Graphics/exitPortal.png')}

P.treasureTile2 = P.treasureTile:new{name = "treasureTile2", sprite = love.graphics.newImage('Graphics/treasuretile2.png')}

P.treasureTile3 = P.treasureTile:new{name = "treasureTile3", sprite = love.graphics.newImage('Graphics/treasuretile3.png')}

P.treasureTile4 = P.treasureTile:new{name = "treasureTile4", sprite = love.graphics.newImage('Graphics/treasuretile4.png')}

P.conductiveSlime = P.conductiveTile:new{name = "conductiveSlime", sprite = love.graphics.newImage('Graphics/conductiveslime.png'), poweredSprite = love.graphics.newImage('Graphics/conductiveslimepowered.png')}
P.conductiveSlime.onEnter = P.slime.onEnter
P.conductiveSlime.onEnterAnimal = P.slime.onEnterAnimal
function P.conductiveSlime:willKillPlayer()
	return self.powered
end
P.conductiveSlime.willKillAnimal = P.conductiveSlime.willKillPlayer

P.conductiveSnailTile = P.pitbullTile:new{name = "conductiveSnail", animal = animalList[7]:new(), listIndex = 7}

P.untriggeredPowerSupply = P.conductiveTile:new{name = "untriggeredPowerSupply", sprite = love.graphics.newImage('Graphics/untriggeredpowersupply.png'), poweredSprite = love.graphics.newImage('Graphics/powersupply.png')}
function P.untriggeredPowerSupply:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.charged = true
	end
end
function P.untriggeredPowerSupply:destroy()
	self.charged = false
	self.dirAccept = {0,0,0,0}
end

P.reinforcedGlass = P.concreteWall:new{name = "reinforcedGlass", blocksVision = false, sprite = love.graphics.newImage('Graphics3D/reinforcedglass.png'), poweredSprite = love.graphics.newImage('Graphics3D/reinforcedglass.png')}

P.powerTriggeredBomb = P.unactivatedBomb:new{name = "powerTriggeredBomb", canBePowered = true, powered = false, dirAccept = {1,1,1,1}, dirSend = {0,0,0,0}}
function P.powerTriggeredBomb:postPowerUpdate()
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		if not self.triggered then
			self.counter = 3
			self.triggered = true
		end
	end
	self.poweredSprite = self.sprite
end
function P.powerTriggeredBomb:onEnter(player)
end
P.powerTriggeredBomb.onEnterAnimal = P.powerTriggeredBomb.onEnter

P.boxTile = P.tile:new{name = "boxTile", pushable = pushableList[2]:new(), listIndex = 2, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.motionGate = P.conductiveTile:new{name = "gate", dirSend = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/gate.png'), poweredSprite = love.graphics.newImage('Graphics/gate.png')}
function P.motionGate:onLeave(player)
	if (player.prevTileX<player.tileX and self.rotation == 0) or (player.prevTileX>player.tileX and self.rotation == 2) or
	(player.prevTileY<player.tileY and self.rotation == 1) or (player.prevTileY>player.tileY and self.rotation == 3) then
		self.dirSend = {1,1,1,1}
	elseif (player.prevTileX<player.tileX and self.rotation == 2) or (player.prevTileX>player.tileX and self.rotation == 0) or
	(player.prevTileY<player.tileY and self.rotation == 3) or (player.prevTileY>player.tileY and self.rotation == 1) then
		self.dirSend = {0,0,0,0}
	end
end
P.motionGate.onEnterAnimal = P.gate.onEnter

P.motionGate2 = P.motionGate:new{name = "gate2", dirSend = {1,1,1,1}}

P.playerBoxTile = P.boxTile:new{name = "playerBoxTile", pushable = pushableList[3]:new(), listIndex = 3}
P.animalBoxTile = P.boxTile:new{name = "animalBoxTile", pushable = pushableList[4]:new(), listIndex = 4}

P.puddle = P.conductiveTile:new{name = "puddle", sprite = love.graphics.newImage('Graphics/puddle.png'), poweredSprite = love.graphics.newImage('Graphics/puddlelectrified.png')}
function P.puddle:willKillPlayer()
	return not self.destroyed and self.powered
end
P.puddle.willKillAnimal = P.puddle.willKillPlayer

P.dustyGlassWall = P.glassWall:new{name = "dustyGlassWall", blocksVision = true, sprite = love.graphics.newImage('Graphics3D/dustyglass.png'), cleanSprite = love.graphics.newImage('Graphics/glass.png')}

P.trap = P.tile:new{name = "trap", triggered = false, sprite = love.graphics.newImage('Graphics/trap.png')}
function P.trap:onEnter(player)
	if self.triggered then return end
	self.triggered = true
	kill()
end
function P.trap:onEnterAnimal(animal)
	if self.triggered or animal.flying then return end
	self.triggered = true
	animal:kill()
end

P.glue = P.tile:new{name = "glue", sprite = love.graphics.newImage('Graphics/glue.png')}
function P.glue:onEnter(player)
	player.waitCounter = player.waitCounter+1
end

function P.glue:onStay(player)
	player.waitCounter = player.waitCounter+1
end
function P.glue:onEnterAnimal(animal)
	if animal.flying then return end
	animal.waitCounter = animal.waitCounter+1
end
P.glue.onStayAnimal = P.glue.onEnterAnimal

P.conductiveBoxTile = P.tile:new{name = "conductiveBoxTile", pushable = pushableList[5]:new(), listIndex = 5, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.boomboxTile = P.tile:new{name = "boomboxTile", pushable = pushableList[6]:new(), listIndex = 6, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.batteringRamTile = P.tile:new{name = "batteringRamTile", pushable = pushableList[7]:new(), listIndex = 7, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.lamp = P.tile:new{name = "lamp", sprite = love.graphics.newImage('Graphics/lamp.png'), lit = true}

P.conductiveGlass = P.glassWall:new{name = "conductiveGlass", sprite = love.graphics.newImage('Graphics3D/conductiveglass.png'), poweredSprite = love.graphics.newImage('Graphics3D/conductiveglass.png'), canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.reinforcedConductiveGlass = P.reinforcedGlass:new{name = "reinforcedConductiveGlass", sprite = love.graphics.newImage('Graphics3D/reinforcedconductiveglass.png'), poweredSprite = love.graphics.newImage('Graphics3D/reinforcedconductiveglass.png'), canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.fog = P.tile:new{name = "fog", sprite = love.graphics.newImage('Graphics/fog.png'), blocksVision = true}

tiles[1] = P.invisibleTile
tiles[2] = P.conductiveTile
tiles[3] = P.powerSupply
tiles[4] = P.wire
tiles[5] = P.horizontalWire
tiles[6] = P.cornerWire
tiles[7] = P.tWire
tiles[8] = P.button
tiles[9] = P.stickyButton
tiles[10] = P.stayButton
tiles[11] = P.electricFloor
tiles[12] = P.poweredFloor
tiles[13] = P.wall
tiles[14] = P.splitGate
tiles[15] = P.andGate
tiles[16] = P.notGate
tiles[17] = P.orGate
tiles[18] = P.hDoor
tiles[19] = P.endTile
tiles[20] = P.metalWall
tiles[21] = P.pitbullTile
tiles[22] = P.pupTile
tiles[23] = P.catTile
tiles[24] = P.glassWall
tiles[25] = P.vPoweredDoor
tiles[26] = P.sign
tiles[27] = P.rotater
tiles[28] = P.spikes
tiles[29] = P.crossWire
tiles[30] = P.tunnel
tiles[31] = P.concreteWall
tiles[32] = P.pit
tiles[33] = P.breakablePit
tiles[34] = P.treasureTile
tiles[35] = P.maskedWire
tiles[36] = P.maskedMetalWall
tiles[37] = P.poweredEnd
tiles[38] = P.mousetrap
tiles[39] = P.bomb
tiles[40] = P.concreteWallConductive
tiles[41] = P.capacitor
tiles[42] = P.inductor
tiles[43] = P.slime
tiles[44] = P.unactivatedBomb
tiles[45] = P.snailTile
tiles[46] = P.doghouse
tiles[47] = P.batTile
tiles[48] = P.concreteWallConductiveDirected
tiles[49] = P.meat
tiles[50] = P.beggar
tiles[51] = P.ladder
tiles[52] = P.mousetrapOff
tiles[53] = P.donationMachine
tiles[54] = P.concreteWallConductiveCorner
tiles[55] = P.concreteWallConductiveT
tiles[56] = P.entrancePortal
tiles[57] = P.exitPortal
tiles[58] = P.treasureTile2
tiles[59] = P.treasureTile3
tiles[60] = P.treasureTile4
tiles[61] = P.conductiveSlime
tiles[62] = P.conductiveSnailTile
tiles[63] = P.untriggeredPowerSupply
tiles[64] = P.reinforcedGlass
tiles[65] = P.powerTriggeredBomb
tiles[66] = P.boxTile
tiles[67] = P.motionGate
tiles[68] = P.motionGate2
tiles[69] = P.playerBoxTile
tiles[70] = P.animalBoxTile
tiles[71] = P.puddle
tiles[72] = P.dustyGlassWall
tiles[73] = P.trap
tiles[74] = P.conductiveBoxTile
tiles[75] = P.boomboxTile
tiles[76] = P.batteringRamTile
tiles[77] = P.lamp
tiles[78] = P.glue
tiles[79] = P.conductiveGlass
tiles[80] = P.reinforcedConductiveGlass
tiles[81] = P.fog

return tiles