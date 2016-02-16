require('scripts.object')

local P = {}
tiles = P
P.tile = Object:new{dirSEnd = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = false, name = "fuccboi", sprite = love.graphics.newImage('cavesfloor.png'), poweredSprite = love.graphics.newImage('cavesfloor.png')}
function P.tile:onEnter(player)
	player.x = 1000
end
P.conductiveTile = P.tile:new{dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "conductiveTile", sprite = love.graphics.newImage('electricfloor.png'), poweredSprite = love.graphics.newImage('electricfloor.png')}
P.powerSupply = P.tile:new{dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "powerSupply", sprite = love.graphics.newImage('powersupply.png'), poweredSprite = love.graphics.newImage('powersupply.png')}
P.wire = P.tile:new{dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "wire", sprite = love.graphics.newImage('wires.png'), poweredSprite = love.graphics.newImage('poweredwires.png')}
P.horizontalWire = P.tile:new{dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, canBePowered = true, name = "horizontalWire", sprite = love.graphics.newImage('horizontalWireUnpowered.png'), poweredSprite = love.graphics.newImage('horizontalWirePowered.png')}
P.verticalWire = P.tile:new{dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, canBePowered = true, name = "verticalWire", sprite = love.graphics.newImage('verticalWireUnpowered.png'), poweredSprite = love.graphics.newImage('verticalWirePowered.png')}
P.spikes = P.tile:new{dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, canBePowered = true, name = "spikes", sprite = love.graphics.newImage('spikes.png')}
tiles[1] = P.tile
tiles[2] = P.conductiveTile
tiles[3] = P.powerSupply
tiles[4] = P.wire
tiles[5] = P.horizontalWire
tiles[6] = P.verticalWire
tiles[7] = P.spikes
return tiles