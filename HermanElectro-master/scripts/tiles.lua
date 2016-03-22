require('scripts.object')
require('scripts.boundaries')

local P = {}
tiles = P

P.tile = Object:new{powered = false, poweredNeighbors = {0,0,0,0}, blocksVision = false, dirSend = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = false, name = "basicTile", sprite = love.graphics.newImage('cavesfloor.png'), poweredSprite = love.graphics.newImage('cavesfloor.png')}
function P.tile:onEnter(player) 
	--self.name = "fuckyou"
end
function P.tile:onLeave(player) 
	--self.name = "fuckme"
end
function P.tile:onStay(player) 
	--player.x = player.x+1
end
function P.tile:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	elseif self.name ~= "powerSupply" then
		self.powered = false
	end
end
local bounds = {}

P.boundedTile = P.tile:new{boundary = boundaries.Boundary}
P.conductiveTile = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "conductiveTile", sprite = love.graphics.newImage('electricfloor.png'), poweredSprite = love.graphics.newImage('spikes.png')}

function P.conductiveTile:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	elseif self.name ~= "powerSupply" then
		self.powered = false
	end
end

P.powerSupply = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "powerSupply", sprite = love.graphics.newImage('powersupply.png'), poweredSprite = love.graphics.newImage('powersupply.png')}
function P.powerSupply:updateTile(dir)

end

P.wire = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "wire", sprite = love.graphics.newImage('wires.png'), poweredSprite = love.graphics.newImage('poweredwires.png')}
P.horizontalWire = P.tile:new{powered = false, dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, canBePowered = true, name = "horizontalWire", sprite = love.graphics.newImage('horizontalWireUnpowered.png'), poweredSprite = love.graphics.newImage('horizontalWirePowered.png')}
P.verticalWire = P.tile:new{powered = false, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, canBePowered = true, name = "verticalWire", sprite = love.graphics.newImage('verticalWireUnpowered.png'), poweredSprite = love.graphics.newImage('verticalWirePowered.png')}
P.spikes = P.tile:new{powered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, canBePowered = true, name = "spikes", sprite = love.graphics.newImage('spikes.png')}

P.button = P.tile:new{down = false, powered = false, dirSend = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = true, name = "button", pressed = false, sprite = love.graphics.newImage('button.png'), poweredSprite = love.graphics.newImage('button.png'), downSprite = love.graphics.newImage('buttonPressed.png'), upSprite = love.graphics.newImage('button.png')}

function P.button:updateSprite()
	if self.down then
		self.sprite = self.downSprite
		self.poweredSprite = self.downSprite
	else
		self.sprite = self.upSprite
		self.poweredSprite = self.upSprite
	end
end

function P.button:onEnter(player)
	self.down = not self.down
	if self.dirAccept[1]==1 then
		self.powered = false
		self.dirAccept = {0,0,0,0}
	else
		self.dirAccept = {1,1,1,1}
	end
	updatePower()
	self:updateSprite()
	--self.name = "onbutton"
end


function P.button:updateTile(dir)
	if self.down and self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	else
		self.powered = false
	end
end

P.stickyButton = P.button:new{name = "stickyButton"}
function P.stickyButton:onEnter(player)
	down = true
	self.dirAccept = {1,1,1,1}
	updatePower()
	self:updateSprite()
end

P.stayButton = P.button:new{name = "stayButton"}
P.stayButton.onLeave = P.stayButton.onEnter

P.electricFloor = P.conductiveTile:new{name = "electricfloor"}
function P.electricFloor:onStay(player)
	if self.powered then
		kill()
	end
end

P.poweredFloor = P.conductiveTile:new{name = "poweredFloor"}
function P.poweredFloor:onStay(player)
	if not self.powered then
		kill()
	end
end

P.wall = P.tile:new{canBePowered = false, name = "wall", blocksVision = true, sprite = love.graphics.newImage('electricfloor.png'), poweredSprite = love.graphics.newImage('spikes.png') }
function P.wall:onStay(player)
	player.x = player.prevx
	player.y = player.prevy

end

P.wall.onEnter = P.wall.onStay

P.gate = P.conductiveTile:new{name = "gate", dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, gotten = {0,0,0,0}}
function P.gate:updateTile(dir)
	self.gotten[dir] = 1
end

P.splitGate = P.conductiveTile:new{name = "splitGate", dirSend = {0,0,0,0}, dirAccept = {1,0,0,0}, sprite = love.graphics.newImage('splitgate.png'), poweredSprite = love.graphics.newImage('splitgate.png') }
function P.splitGate:updateTile(dir)
	if dir == 1 then
		self.powered=true
		self.dirSend = {0, 1, 0, 1}
		self.dirAccept = {0, 1, 0, 1}
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
		self.dirAccept = {1,0,0,0}
	end
end

P.notGate = P.conductiveTile:new{name = "notGate", dirSend = {1,0,0,0}, dirAccept = {1,0,1,0}, sprite = love.graphics.newImage('notgate.png'), poweredSprite = love.graphics.newImage('splitgate.png') }
function P.notGate:updateTile(dir)
	if self.poweredNeighbors[3] == 0 then
		self.powered = true
		self.dirSend = {1,0,0,0}
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end

P.andGate = P.powerSupply:new{name = "andGate", dirSend = {0,0,0,0}, dirAccept = {0,1,0,1}, sprite = love.graphics.newImage('andgate.png'), poweredSprite = love.graphics.newImage('andgate.png') }
function P.andGate:updateTile(dir)
	if self.poweredNeighbors[2]==1 and self.poweredNeighbors[4]==1 then
		self.powered = true
		self.dirSend = {1,0,1,0}
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end

P.orGate = P.conductiveTile:new{name = "orGate", dirSend = {0,0,0,0}, dirAccept = {0,1,0,1}, sprite = love.graphics.newImage('orgate.png'), poweredSprite = love.graphics.newImage('orgate.png') }
function P.orGate:updateTile(dir)
	if self.poweredNeighbors[2]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
		self.dirSend = {1,0,0,0}
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end


local function getTileX(posX)
	return (posX-1)*floor.sprite:getWidth()*scale+wallSprite.width
end

local function getTileY(posY)
	return (posY-1)*floor.sprite:getHeight()*scale+wallSprite.height
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
tiles[13] = P.wall
tiles[14] = P.splitGate
tiles[15] = P.andGate
tiles[16] = P.notGate
tiles[17] = P.orGate

return tiles