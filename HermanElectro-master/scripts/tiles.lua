require('scripts.object')

local P = {}
tiles = P
P.tile = Object:new{name = "fuccboi", sprite = love.graphics.newImage('cavesfloor.png')}
function P.tile:onEnter(player)
	player.x = 1000
end
P.conductiveTile = P.tile:new{name = "conductiveTile", isPowered = false, sprite = love.graphics.newImage('electricfloor.png')}
P.powerSupply = P.tile:new{name = "powerSupply", isPowered = true, sprite = love.graphics.newImage('powersupply.png')}
P.wire = P.tile:new{name = "wire", isPowered = false, sprite = love.graphics.newImage('wires.png')}
P.poweredWire = P.tile:new{name = "poweredWire", isPowered = true, sprite = love.graphics.newImage('poweredwires.png')}
tiles[1] = P.tile
tiles[2] = P.conductiveTile
tiles[3] = P.powerSupply
tiles[4] = P.wire
tiles[5] = P.poweredWire
return tiles