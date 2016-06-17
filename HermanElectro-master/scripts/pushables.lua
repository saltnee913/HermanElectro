require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
pushableList = P

P.pushable = Object:new{name = "pushable", tileX = 0, tileY = 0, destroyed = false, sprite = love.graphics.newImage('Graphics/box.png')}
P.box = P.pushable:new{name = "box", sprite = love.graphics.newImage('Graphics/box.png')}

pushableList[1] = P.pushable
pushableList[2] = P.box

return pushableList