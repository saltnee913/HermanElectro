require('scripts.object')
require('scripts.boundaries')

local P = {}
tiles = P
P.tile = Object:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = false, name = "basicTile", sprite = love.graphics.newImage('cavesfloor.png'), poweredSprite = love.graphics.newImage('cavesfloor.png')}
function P.tile:onEnter(player) 
	--self.name = "fuckyou"
end
function P.tile:onLeave(player) 
	--self.name = "fuckme"
end
function P.tile:onStay(player) 
	--player.x = player.x+1
end
local bounds = {}
P.boundedTile = P.tile:new{boundary = boundaries.Boundary}
P.conductiveTile = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "conductiveTile", sprite = love.graphics.newImage('electricfloor.png'), poweredSprite = love.graphics.newImage('spikes.png')}
P.powerSupply = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "powerSupply", sprite = love.graphics.newImage('powersupply.png'), poweredSprite = love.graphics.newImage('powersupply.png')}
P.wire = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "wire", sprite = love.graphics.newImage('wires.png'), poweredSprite = love.graphics.newImage('poweredwires.png')}
P.horizontalWire = P.tile:new{powered = false, dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, canBePowered = true, name = "horizontalWire", sprite = love.graphics.newImage('horizontalWireUnpowered.png'), poweredSprite = love.graphics.newImage('horizontalWirePowered.png')}
P.verticalWire = P.tile:new{powered = false, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, canBePowered = true, name = "verticalWire", sprite = love.graphics.newImage('verticalWireUnpowered.png'), poweredSprite = love.graphics.newImage('verticalWirePowered.png')}
P.spikes = P.tile:new{powered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, canBePowered = true, name = "spikes", sprite = love.graphics.newImage('spikes.png')}

P.button = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = false, name = "button", pressed = false, sprite = love.graphics.newImage('button.png'), poweredSprite = love.graphics.newImage('buttonPressed.png')}
function P.button:onEnter(player)
	if self.powered then
		self.powered = false
	end
	self.canBePowered = not self.canBePowered
	updatePower()
	--self.name = "onbutton"
end

P.stickyButton = P.button:new{}
function P.stickyButton:onEnter(player)
	self.canBePowered = true
	updatePower()
end

P.stayButton = P.button:new{}
P.stayButton.onLeave = P.stayButton.onEnter

P.electricFloor = P.conductiveTile:new{}
function P.electricFloor:onStay(player)
	if self.powered then
		kill()
	end
end

P.poweredFloor = P.conductiveTile:new{}
function P.poweredFloor:onStay(player)
	if not self.powered then
		kill()
	end
end


tiles[1] = P.tile
tiles[2] = P.conductiveTile
tiles[3] = P.powerSupply
tiles[4] = P.wire
tiles[5] = P.horizontalWire
tiles[6] = P.verticalWire
tiles[7] = P.spikes
tiles[8] = P.button
tiles[9] = P.stickyButton
tiles[10] = P.stayButton
tiles[11] = P.electricFloor
tiles[12] = P.poweredFloor
return tiles