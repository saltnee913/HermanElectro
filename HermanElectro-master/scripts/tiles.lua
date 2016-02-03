require('scripts.object')

local P = {}
tiles = P
P.tile = Object:new{name = "fuccboi", sprite = love.graphics.newImage('cavesfloor.png')}
function P.tile:onEnter(player)
	player.x = 1000
end
P.conductiveTile = P.tile:new{isPowered = false, sprite = love.graphics.newImage('electricfloor.png')}
tiles[1] = P.tile
tiles[2] = P.conductiveTile
return tiles