local tiles = {}
Object = {}
function Object:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
Tile = Object:new{name = "fuccboi", sprite = love.graphics.newImage('cavesfloor.png')}
function Tile:onEnter(player)
	player.x = 1000
end
ConductiveTile = Tile:new{isPowered = false, sprite = love.graphics.newImage('electricfloor.png')}
tiles.Tile = Tile
tiles.ConductiveTile = ConductiveTile