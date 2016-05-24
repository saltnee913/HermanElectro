require('scripts.object')
require('scripts.boundaries')
require('scripts.animals')

local P = {}
tiles = P

P.tile = Object:new{isVisible = true, rotation = 0, powered = false, blocksMovement = false, poweredNeighbors = {0,0,0,0}, blocksVision = false, dirSend = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = false, name = "basicTile", sprite = love.graphics.newImage('Graphics/cavesfloor.png'), poweredSprite = love.graphics.newImage('Graphics/cavesfloor.png')}
function P.tile:onEnter(player) 
	--self.name = "fuckyou"
end
function P.tile:onLeave(player) 
	--self.name = "fuckme"
end
function P.tile:onStay(player) 
	--player.x = player.x+1
end
function P.tile:useTool(tool)
	return false
end
function P.tile:onEnterAnimal(animal)
end
function P.tile:onLeaveAnimal(animal)
end
function P.tile:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	elseif self.name ~= "powerSupply" then
		self.powered = false
	end
end
function P.tile:getOffsetsByDir(dir)
	dir = dir + self.rotation
	while (dir > 4) do dir = dir - 4 end
	if dir == 1 then return {y = -1, x = 0}
	elseif dir == 2 then return {y = 0, x = 1}
	elseif dir == 3 then return {y = 1, x = 0}
	else return {y = 0, x = -1} end
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
P.invisibleTile = P.tile:new{isVisible = false}
local bounds = {}

P.boundedTile = P.tile:new{boundary = boundaries.Boundary}
P.conductiveTile = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "conductiveTile", sprite = love.graphics.newImage('Graphics/electricfloor.png'), poweredSprite = love.graphics.newImage('Graphics/spikes.png')}

function P.conductiveTile:updateTile(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	elseif self.name ~= "powerSupply" then
		self.powered = false
	end
end

P.powerSupply = P.tile:new{powered = false, wet = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "powerSupply", sprite = love.graphics.newImage('Graphics/powersupply.png'), destroyedSprite = love.graphics.newImage('Graphics/powersupplydead.png'), poweredSprite = love.graphics.newImage('Graphics/powersupply.png')}
function P.powerSupply:updateTile(dir)
end
function P.powerSupply:useTool(tool)
	if tool==4 and not self.wet then
		self.sprite = self.destroyedSprite
		self.canBePowered = false
		self.powered = false
		self.wet = true
		dirAccept = {0,0,0,0}
		dirSend = {0,0,0,0}
		return true
	end
	return false
end

P.wire = P.tile:new{cut = false, powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, destroyedSprite = love.graphics.newImage('Graphics/wirescut.png'), canBePowered = true, name = "wire", sprite = love.graphics.newImage('Graphics/wires.png'), poweredSprite = love.graphics.newImage('Graphics/poweredwires.png')}
function P.wire:useTool(tool)
	if tool==3 and not self.cut then
		self.sprite = self.destroyedSprite
		self.canBePowered = false
		self.cut = true
		dirAccept = {0,0,0,0}
		dirSend = {0,0,0,0}
		return true
	end
	return false
end

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

P.spikes = P.tile:new{powered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, canBePowered = true, name = "spikes", sprite = love.graphics.newImage('Graphics/spikes.png')}

P.button = P.tile:new{bricked = false, justPressed = false, down = false, powered = false, dirSend = {1,1,1,1}, dirAccept = {0,0,0,0}, canBePowered = true, name = "button", pressed = false, sprite = love.graphics.newImage('Graphics/button.png'), poweredSprite = love.graphics.newImage('Graphics/button.png'), downSprite = love.graphics.newImage('Graphics/buttonPressed.png'), brickedSprite = love.graphics.newImage('Graphics/brickedButton.png'), upSprite = love.graphics.newImage('Graphics/button.png')}
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
		updatePower()
		self:updateSprite()
		--self.name = "onbutton"
	end
end
function P.button:useTool(tool)
	if tool == 6 then
		self.bricked = true
		self.down = true
		self.dirAccept = {1,1,1,1}
		self.dirSend = {1,1,1,1}
		self.canBePowered = true
		updatePower()
		self:updateSprite()
		return true
	end
	return false
end
function P.button:onLeave(player)
	self.justPressed = false
end
P.button.onEnterAnimal = P.button.onEnter
P.button.onLeaveAnimal = P.button.onLeave

function P.button:updateTile(dir)
	if self.down and (self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1) then
		self.powered = true
	else
		self.powered = false
	end
end

P.stickyButton = P.button:new{name = "stickyButton", downSprite = love.graphics.newImage('Graphics/stickyButtonPressed.png'), sprite = love.graphics.newImage('Graphics/stickyButton.png')}
function P.stickyButton:onEnter(player)
	--if not self.justPressed then
		self.justPressed = true
		self.down = true
		self.dirAccept = {1,1,1,1}
		updatePower()
		self:updateSprite()
	--end
end
function P.stickyButton:onLeave(player)
end
P.stickyButton.onEnterAnimal = P.stickyButton.onEnter
P.stickyButton.onLeaveAnimal = P.stickyButton.onLeave

P.stayButton = P.button:new{name = "stayButton"}
function P.stayButton:onEnter(player)
	self.down = true
	self.dirAccept = {1,1,1,1}
	updatePower()
	self:updateSprite()
end
function P.stayButton:onLeave(player)
	self.down = false
	self.dirAccept = {0,0,0,0}
	updatePower()
	self:updateSprite()
end
P.stayButton.onEnterAnimal = P.stayButton.onEnter
P.stayButton.onLeaveAnimal = P.stayButton.onLeave
--P.stayButton.onLeave = P.stayButton.onEnter

P.electricFloor = P.conductiveTile:new{name = "electricfloor", cut = false, sprite = love.graphics.newImage('Graphics/electricfloor.png'), destroyedSprite = love.graphics.newImage('Graphics/electricfloorcut.png'), poweredSprite = love.graphics.newImage('Graphics/electricfloorpowered.png')}
function P.electricFloor:onEnter(player)
	if self.powered and not self.cut then
		--kill()
	end
end
function P.electricFloor:onEnterAnimal(animal)
	if self.powered and not self.cut then
		animal:kill()
	end
end
function P.electricFloor:useTool(tool)
	if (tool==3 or tool==4) and not self.cut then
		self.sprite = self.destroyedSprite
		self.canBePowered = false
		self.cut = true
		dirAccept = {0,0,0,0}
		dirSend = {0,0,0,0}
		return true
	end
	return false
end

P.poweredFloor = P.conductiveTile:new{name = "poweredFloor", ladder = false, destroyedSprite = love.graphics.newImage('Graphics/trapdoorwithladder.png'), destroyedPoweredSprite = love.graphics.newImage('Graphics/trapdoorclosedwithladder.png'), sprite = love.graphics.newImage('Graphics/trapdoor.png'), poweredSprite = love.graphics.newImage('Graphics/trapdoorclosed.png')}
function P.poweredFloor:onEnter(player)
	if not self.powered and not self.ladder then
		--kill()
	end
end
function P.poweredFloor:onEnterAnimal(animal)
	if not self.powered and not self.ladder then
		animal:kill()
	end
end
function P.poweredFloor:useTool(tool)
	if tool==2 and not self.ladder then
		self.sprite = self.destroyedSprite
		self.poweredSprite = self.destroyedPoweredSprite
		self.ladder= true
		return true
	end
	return false
end

P.wall = P.tile:new{blocksMovement = true, sawed = false, canBePowered = false, name = "wall", blocksVision = true, destroyedSprite = love.graphics.newImage('Graphics/woodwallbroken.png'), sprite = love.graphics.newImage('Graphics/woodwall.png'), poweredSprite = love.graphics.newImage('Graphics/woodwall.png') }
function P.wall:onEnter(player)	
	if not self.sawed then
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
P.wall.onStay = P.wall.onEnter
P.wall.onEnterAnimal = P.wall.onEnter
function P.wall:useTool(tool)
	if tool==1 and not self.sawed then
		self.blocksVision = false
		self.sprite = self.destroyedSprite
		self.sawed = true
		self.blocksMovement = false
		return true
	end
	return false
end

P.metalWall = P.wall:new{dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}, sawed = false, canBePowered = true, name = "metalwall", blocksVision = true, destroyedSprite = love.graphics.newImage('Graphics/metalwallbroken.png'), sprite = love.graphics.newImage('Graphics/metalwall.png'), poweredSprite = love.graphics.newImage('Graphics/metalwallpowered.png') }
function P.metalWall:useTool(tool)
	if tool==5 and not self.sawed then
		self.blocksVision = false
		self.sprite = self.destroyedSprite
		self.sawed = true
		self.canBePowered = false
		self.dirAccept = {0,0,0,0}
		self.dirSend = {0,0,0,0}
		self.blocksMovement = false
		return true
	end
	return false
end
P.glassWall = P.wall:new{canBePowered = false, dirAccept = {0,0,0,0}, dirSend = {0,0,0,0}, sawed = false, name = "glasswall", blocksVision = false, destroyedSprite = love.graphics.newImage('Graphics/glassbroken.png'), sprite = love.graphics.newImage('Graphics/glass.png'), poweredSprite = love.graphics.newImage('Graphics/metalwallpowered.png') }
function P.glassWall:useTool(tool)
	if tool==6 and not self.sawed then
		self.sprite = self.destroyedSprite
		self.sawed = true
		self.blocksMovement = false
		return true
	end
	return false
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
	if self.poweredNeighbors[self:cfr(3)] == 0 then
	--if self.poweredNeighbors[2] == 0 and self.poweredNeighbors[4] == 0 then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end

P.andGate = P.gate:new{name = "andGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, sprite = love.graphics.newImage('Graphics/andgate.png'), poweredSprite = love.graphics.newImage('Graphics/andgate.png') }
function P.andGate:updateTile(dir)
	if self.poweredNeighbors[self:cfr(2)]==1 and self.poweredNeighbors[self:cfr(4)]==1 then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end

P.orGate = P.gate:new{name = "orGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, sprite = love.graphics.newImage('Graphics/orgate.png'), poweredSprite = love.graphics.newImage('Graphics/orgate.png') }
function P.orGate:updateTile(dir)
	if self.poweredNeighbors[self:cfr(2)]==1 or self.poweredNeighbors[self:cfr(4)]==1 then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
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

P.hDoor= P.tile:new{name = "hDoor", blocksVision = true, blocksMovement = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
function P.hDoor:onEnter(player)
	self.sprite = self.openSprite
	self.blocksVision = false
	self.blocksMovement = false
	updateLight()
end

P.vDoor= P.tile:new{name = "hDoor", blocksVision = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
function P.vDoor:onEnter(player)
	self.sprite = self.openSprite
	self.blocksVision = false
	updateLight()
end

P.vPoweredDoor = P.tile:new{sawed = false, name = "vPoweredDoor", blocksMovement = false, blocksVision = false, canBePowered = true, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, sprite = love.graphics.newImage('Graphics/powereddooropen.png'), closedSprite = love.graphics.newImage('Graphics/powereddoor.png'), openSprite = love.graphics.newImage('Graphics/powereddooropen.png'), poweredSprite = love.graphics.newImage('Graphics/powereddoor.png')}
function P.vPoweredDoor:updateTile(player)
	if self.poweredNeighbors[self:cfr(1)] == 1 or self.poweredNeighbors[self:cfr(3)]==1 then
		self.blocksVision = true
		self.sprite = self.closedSprite
		self.blocksMovement = true
		self.powered = true
	else
		self.blocksVision = false
		self.sprite = self.openSprite
		self.blocksMovement = false
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
	--updateLight()
end

P.endTile = P.tile:new{name = "endTile", canBePowered = false, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/end.png'), done = false}
function P.endTile:onEnter(player)
	if self.done then return end
	completedRooms[mapy][mapx] = 1
	if mapy>0 then
		visibleMap[mapy-1][mapx] = 1
	end
	if mapy<mapHeight then
		visibleMap[mapy+1][mapx] = 1
	end
	if mapx>0 then
		visibleMap[mapy][mapx-1] = 1
	end
	if mapx<mapHeight then
		visibleMap[mapy][mapx+1] = 1
	end
	if loadTutorial then
		for i = 1, #inventory do
			player.totalItemsGiven[i] = player.totalItemsGiven[i] + itemsGiven[mainMap[mapy][mapx].roomid][1][i]
			player.totalItemsNeeded[i] = player.totalItemsNeeded[i] + itemsNeeded[mainMap[mapy][mapx].roomid][1][i]
			inventory[i] = player.totalItemsGiven[i] - player.totalItemsNeeded[i]
			if inventory[i] < 0 then inventory[i] = 0 end
		end
		self.done = true
	else
		local checkedRooms = {}
		for i = 0, mapHeight do
			checkedRooms[i] = {}
		end
		local amtChecked = 0
		while (self.done == false) do
			y = math.floor(math.random()*(mapHeight+1))
			x = math.floor(math.random()*(mapHeight+1))
			if checkedRooms[y][x] == nil then
				checkedRooms[y][x] = 1
				amtChecked = amtChecked + 1
				if amtChecked == (mapHeight + 1)*(mapHeight + 1) then
					break
				end
				if completedRooms[y]~=nil and completedRooms[y][x]~=nil and completedRooms[y][x] == 0 then
					if (completedRooms[y-1]~=nil and completedRooms[y-1][x] ~=nil and completedRooms[y-1][x] == 1) or
						(completedRooms[y+1]~=nil and completedRooms[y+1][x] ~=nil and completedRooms[y+1][x] ==1) or
						(completedRooms[y][x-1]~=nil and completedRooms[y][x-1]==1) or
						(completedRooms[y][x+1]~=nil and completedRooms[y][x+1]==1) then
						listOfItemsNeeded = itemsNeeded[mainMap[y][x].roomid]
						numLists = 0
						for j = 1, 10 do
							if listOfItemsNeeded[j]~=nil then
								numLists = numLists+1
							end
						end
						listChoose = math.random(numLists)
						for i=1,7 do
							--print(listChoose)
							--inventory[i] = inventory[i]+itemsNeeded[mainMap[x][y].roomid][i]
							inventory[i] = inventory[i]+listOfItemsNeeded[listChoose][i]
							self.done = true
						end
					end
				end
			end
		end
	end
	self.isCompleted = true
	self.isVisible = false
end

P.pitbullTile = P.tile:new{name = "pitbull", animal = animalList[2]:new()}
P.pupTile = P.tile:new{name = "pup", animal = animalList[3]:new()}
P.catTile = P.tile:new{name = "cat", animal = animalList[4]:new()}

P.vDoor= P.hDoor:new{name = "vDoor", sprite = love.graphics.newImage('Graphics/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
P.vDoor.onEnter = P.hDoor.onEnter

P.sign = P.tile:new{text = "", name = "sign"}

P.rotater = P.button:new{canBePowered = true, dirAccept = {1,0,1,0}, dirSend = {1,0,1,0}, sprite = love.graphics.newImage('Graphics/rotater.png'), poweredSprite = love.graphics.newImage('Graphics/rotater.png')}
function P.rotater:updateSprite()
end
function P.rotater:onEnter(player)
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
P.rotater.useTool = P.tile.useTool
function P.rotater:onLeave(player)
	self.justPressed = false
end
P.rotater.onEnterAnimal = P.rotater.onEnter
P.rotater.onLeaveAnimal = P.rotater.onLeave

P.concreteWall = P.wall:new{name = "concreteWall", sprite = love.graphics.newImage('Graphics/concreteWall.png')}
P.concreteWall.useTool = P.tile.useTool

P.tunnel = P.tile:new{name = "tunnel"}

P.pit = P.tile:new{name = "pit", sprite = love.graphics.newImage('Graphics/pit.png')}


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

return tiles