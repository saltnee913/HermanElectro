require('scripts.object')
require('scripts.boundaries')
require('scripts.animals')
require('scripts.pushables')
tools = require('scripts.tools')

local P = {}
tiles = P

P.tile = Object:new{yOffset = 0, blueHighlighted = false, attractsAnimals = false, scaresAnimals = false, formerPowered = nil, updatePowerOnEnter = false, text = "", updatePowerOnLeave = false, overlayable = false, overlaying = false, gone = false, lit = false, destroyed = false,
  blocksProjectiles = false, isVisible = true, rotation = 0, powered = false, blocksMovement = false, 
  blocksAnimalMovement = false, poweredNeighbors = {0,0,0,0}, blocksVision = false, dirSend = {1,1,1,1}, 
  dirAccept = {0,0,0,0}, canBePowered = false, name = "basicTile", emitsLight = false, litWhenPowered = false, intensity = 0.5, range = 25,
  sprite = love.graphics.newImage('Graphics/cavesfloor.png'), 
  poweredSprite = love.graphics.newImage('Graphics/cavesfloor.png'),
  wireHackOn = love.graphics.newImage('Graphics3D/wirehackon.png'),
  wireHackOff = love.graphics.newImage('Graphics3D/wirehackoff.png')}
function P.tile:lightTest(x,y)
	return false
end
function P.tile:onEnter(player) 
	--self.name = "fuckyou"
end
function P.tile:onEnterPushable(pushable)
	self:onEnter(pushable)
end
function P.tile:onLeave(player) 
	--self.name = "fuckme"
end
function P.tile:onLeavePushable(pushable)
	self:onLeave(pushable)
end
function P.tile:onStay(player) 
	--player.x = player.x+1
end
function P.tile:onStayPushable(pushable)
	self:onStay(pushable)
end
function P.tile:onStayAnimal(animal)
end
function P.tile:onEnterAnimal(animal)
end
function P.tile:onLeaveAnimal(animal)
end
function P.tile:onStep(x, y)
end
function P.tile:onEnd(x,y)
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
	return self.yOffset
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
function P.tile:postPowerUpdate(i,j)
end
--guide to elevation:
--if can block movement, make blocksMovement true
--if can only block animal movement, make blocksAnimalMovement true
--obstructsMovement() is for ACTUALLY blocking player movement (in new elevation system)
--obstructsMovementAnimal() is for ACTUALLY blocking animal movement
--map has blocksMovementAnimal() function as well
--pretty confusing, even I am a bit confused
function P.tile:obstructsMovementAnimal(animal)
	if animal.flying then
		return false
	else
		if math.abs(animal.elevation-self:getHeight())<=3 then
			return false
		else
			return true
		end
	end
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
	self.poweredSprite = self.electrifiedPoweredSprite
end
function P.tile:allowVision()
	self.blocksVision = false
end
function P.tile:usableOnNothing()
	return self.destroyed and not (tool~=nil and tools[tool]:nothingIsSomething())
end
function P.tile:updateToOverlay(dir)
	if self.overlay == nil then
		return
	end
	self.overlay.powered = self.powered
	self.overlay.poweredNeighbors = self.poweredNeighbors
	if dir ~= -1 then
		self.overlay:updateTile(dir)
	end
	self.canBePowered = self.overlay.canBePowered
	self.dirSend = self.overlay.dirSend
	self.dirAccept = self.overlay.dirAccept
	self.powered = self.overlay.powered
end
function P.tile:setOverlay(overlay)
	self.overlay = overlay
	self:updateToOverlay(-1)
end
function P.tile:updateTileAndOverlay(dir)
	self:updateToOverlay(dir)
	self:updateTile(dir)
end
function P.tile:absoluteFinalUpdate()
end
function P.tile:realtimeUpdate()
end
function P.tile:obstructsVision()
	if not self.blocksVision then return false
	else return self:getHeight()-3>player.elevation end
end
function P.tile:obstructsMovement()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return false
	else
		return true
	end
end
function P.tile:getHeight()
	if self.destroyed then
		return 0
	else
		return -1*self.yOffset
	end
end
function P.tile.flipDirection(dir,isVertical)
	return 0
end

P.invisibleTile = P.tile:new{isVisible = false, name = "invisibleTile"}
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

P.powerSupply = P.tile:new{powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "powerSupply",
  intensity = 0.0, range = 30,
  sprite = love.graphics.newImage('Graphics/Tiles/powerSupply.png'), 
  destroyedSprite = love.graphics.newImage('Graphics/Tiles/powerSupplyDead.png'), 
  poweredSprite = love.graphics.newImage('Graphics/Tiles/powerSupply.png')}
function P.powerSupply:updateTile(dir)
end
function P.powerSupply:destroy()
	self.sprite = self.destroyedSprite
	self.canBePowered = false
	self.powered = false
	self.destroyed = true
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
end

P.wire = P.conductiveTile:new{overlaying = true, powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "wire",
destroyedSprite = love.graphics.newImage('Graphics/Tiles/wireCut.png'), 
sprite = love.graphics.newImage('Graphics/Tiles/wire.png'),
poweredSprite = love.graphics.newImage('Graphics/Tiles/wirePowered.png')}
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

P.horizontalWire = P.wire:new{powered = false, dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, canBePowered = true, name = "horizontalWire",
sprite = love.graphics.newImage('Graphics/Tiles/horizontalWireUnpowered.png'),
destroyedSprite = love.graphics.newImage('Graphics/Tiles/horizontalWireCut.png'),
poweredSprite = love.graphics.newImage('Graphics/Tiles/horizontalWirePowered.png')}
P.verticalWire = P.wire:new{powered = false, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, canBePowered = true, name = "verticalWire", sprite = love.graphics.newImage('Graphics/verticalWireUnpowered.png'), destroyedSprite = love.graphics.newImage('Graphics/verticalWireCut.png'), poweredSprite = love.graphics.newImage('Graphics/verticalWirePowered.png')}
P.cornerWire = P.wire:new{dirSend = {0,1,1,0}, dirAccept = {0,1,1,0}, name = "cornerWire",
sprite = love.graphics.newImage('Graphics/Tiles/cornerWireUnpowered.png'),
poweredSprite = love.graphics.newImage('Graphics/Tiles/cornerWirePowered.png'),
destroyedSprite = love.graphics.newImage('Graphics/Tiles/cornerWireCut.png')}
function P.cornerWire.flipDirection(dir,isVertical)
	if dir == 1 or dir == 3 then
		if isVertical then return 1 else return -1 end
	else
		if isVertical then return (dir == 0 and 3 or -1) else return 1 end
	end
end

P.tWire = P.wire:new{dirSend = {0,1,1,1}, dirAccept = {0,1,1,1}, name = "tWire",
sprite = love.graphics.newImage('Graphics/Tiles/tWireUnpowered.png'),
poweredSprite = love.graphics.newImage('Graphics/Tiles/tWirePowered.png'),
destroyedSprite = love.graphics.newImage('Graphics/Tiles/tWireCut.png')}
function P.tWire.flipDirection(dir, isVertical)
	if isVertical then
		if dir == 0 then 
			return 2
		elseif dir == 2 then
			return -2 
		end
	else
		if dir == 1 then
			return 2
		elseif dir == 3 then
			return -2
		end
	end
	return 0
end


P.unbreakableWire = P.wire:new{name = "unbreakableWire", litWhenPowered = false, sprite = love.graphics.newImage('Graphics/unbreakablewire.png'), poweredSprite = love.graphics.newImage('Graphics/unbreakablewire.png'), wireHackOff = love.graphics.newImage('Graphics3D/unbreakablewirehack.png'), wireHackOn = love.graphics.newImage('Graphics3D/unbreakablewirehack.png')}
P.unbreakableHorizontalWire = P.unbreakableWire:new{name = "unbreakableHorizontalWire", dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, sprite = love.graphics.newImage('Graphics/unbreakablehorizontalwire.png'), poweredSprite = love.graphics.newImage('Graphics/unbreakablehorizontalwire.png')}
P.unbreakableCornerWire = P.unbreakableWire:new{name = "unbreakableCornerWire", dirSend = {0,1,1,0}, dirAccept = {0,1,1,0}, sprite = love.graphics.newImage('Graphics/unbreakablecornerwire.png'), poweredSprite = love.graphics.newImage('Graphics/unbreakablecornerwire.png')}
P.unbreakableCornerWire.flipDirection = P.cornerWire.flipDirection

P.unbreakableTWire = P.unbreakableWire:new{name = "unbreakableTWire", dirSend = {0,1,1,1}, dirAccept = {0,1,1,1}, sprite = love.graphics.newImage('Graphics/unbreakabletwire.png'), poweredSprite = love.graphics.newImage('Graphics/unbreakabletwire.png')}
P.unbreakableCrossWire = P.unbreakableWire:new{dirSend = {0,0,0,0}, dirAccept = {1,1,1,1}, name = "unbreakableCrossWire", sprite = love.graphics.newImage('Graphics/unbreakablecrosswires.png'), poweredSprite = love.graphics.newImage('Graphics/unbreakablecrosswires.png')}
P.unbreakableCrossWire.updateTile = P.crossWire.updateTile
P.unbreakablePowerSupply = P.powerSupply:new{name = "unbreakablePowerSupply", sprite = love.graphics.newImage('Graphics/unbreakablepowersupply.png'), poweredSprite = love.graphics.newImage('Graphics/unbreakablepowersupply.png')}

P.spikes = P.tile:new{powered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, canBePowered = true, name = "spikes", sprite = love.graphics.newImage('GraphicsTony/Spikes2.png')}
function P.spikes:willKillPlayer()
	return true
end
P.spikes.willKillAnimal = P.spikes.willKillPlayer

P.conductiveSpikes = P.spikes:new{name = "conductiveSpikes", sprite = love.graphics.newImage('Graphics/conductivespikes.png'), poweredSprite = love.graphics.newImage('Graphics/conductivespikes.png'), canBePowered = true, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}}

P.button = P.tile:new{bricked = false, meated = false, updatePowerOnEnter = true, justPressed = false, down = false, powered = false, dirSend = {1,1,1,1}, 
  dirAccept = {0,0,0,0}, canBePowered = true, name = "button", pressed = false, sprite = love.graphics.newImage('GraphicsColor/buttonoff.png'), 
  poweredSprite = love.graphics.newImage('GraphicsEli/buttonOff2.png'), downSprite = love.graphics.newImage('Graphics/buttonPressed.png'), 
  brickedSprite = love.graphics.newImage('GraphicsEli/buttonBricked2.png'), upSprite = love.graphics.newImage('Graphics/button.png')}
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

P.stickyButton = P.button:new{name = "stickyButton", 
  downSprite = love.graphics.newImage('GraphicsEli/buttonOn.png'),
  sprite = love.graphics.newImage('GraphicsEli/buttonOff.png'), 
  upSprite = love.graphics.newImage('GraphicsEli/buttonOff.png'), 
  brickedSprite = love.graphics.newImage('GraphicsEli/buttonBricked.png')}
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

P.stayButton = P.button:new{name = "stayButton", updatePowerOnLeave = true, 
  sprite = love.graphics.newImage('GraphicsEli/buttonOff3.png'), 
  upSprite = love.graphics.newImage('GraphicsEli/buttonOff3.png'), 
  downSprite = love.graphics.newImage('GraphicsEli/buttonOn3.png'), 
  brickedSprite = love.graphics.newImage('GraphicsEli/buttonBricked3.png')}
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
function P.stayButton:postPowerUpdate(i,j)
	if player.character.name == "Orson" and player.character.shifted then return end
	self.down = false
	self.dirAccept = {0,0,0,0}
	self.justPressed = false
	--updateGameState()
	self:updateSprite()
	for k = 1, #animals do
		if animals[k].dead and not animals[k].pickedUp then
			if animals[k].tileX == j and animals[k].tileY == i then
				self.down = true
				self.dirAccept = {1,1,1,1}
				--updateGameState()
				self:updateSprite()
			end
		end
	end
	for k = 1, #animals do
		if not animals[k].dead then
			if animals[k].tileX == j and animals[k].tileY == i then
				self.down = true
				self.dirAccept = {1,1,1,1}
				--updateGameState()
				self:updateSprite()
			end
		end
	end
	for k = 1, #pushables do
		if pushables[k].tileX == j and pushables[k].tileY == i then
			self.down = true
			self.dirAccept = {1,1,1,1}
			--updateGameState()
			self:updateSprite()
		end
	end
	if self.bricked or (player.tileY == i and player.tileX == j) then
		self.down = true
		self.dirAccept = {1,1,1,1}
		--updateGameState()
		self:updateSprite()
	end
end
P.stayButton.onEnterAnimal = P.stayButton.onEnter
P.stayButton.onLeaveAnimal = P.stayButton.onLeave
--P.stayButton.onLeave = P.stayButton.onEnter

P.electricFloor = P.conductiveTile:new{name = "electricfloor",
sprite = love.graphics.newImage('Graphics/Tiles/electricFloor.png'),
destroyedSprite = love.graphics.newImage('Graphics/Tiles/electricFloorCut.png'),
poweredSprite = love.graphics.newImage('Graphics/Tiles/electricFloorPowered.png')}
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
sprite = love.graphics.newImage('GraphicsBrush/trapdoor.png'), poweredSprite = love.graphics.newImage('GraphicsBrush/trapdoorclosed.png')}
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

P.wall = P.tile:new{overlayable = true, hidesDungeon = false, yOffset = -6, electrified = false, onFire = false, blocksProjectiles = true, blocksMovement = true, canBePowered = false, name = "wall", blocksVision = true,
destroyedSprite = love.graphics.newImage('Graphics/Tiles/woodWallSawed.png'), sprite = love.graphics.newImage('Graphics/Tiles/woodWall.png'), sawable = true}
function P.wall:onEnter(player)	
	if math.abs(player.elevation-self:getHeight())>3 then
		--player.x = player.prevx
		--player.y = player.prevy
		player.tileX = player.prevTileX
		player.tileY = player.prevTileY
		--player.prevx = player.x
		--player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
	else
		player.elevation = self:getHeight()
	end
end
P.wall.onStay = P.wall.onEnter
function P.wall:onEnterPushable(pushable)
	--[[if not self.destroyed then
		pushable.tileX = pushable.prevTileX
		pushable.tileY = pushable.prevTileY
	end]]
end
function P.wall:obstructsMovement()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return false
	elseif player.character.name==characters.rammy.name and self.name == tiles.wall.name then
		return false
	end
	return true
end
P.wall.onStayPushable = P.wall.onEnterPushable

function P.wall:onEnterAnimal(animal)
	--[[if not self.destroyed and not animal.flying then
		animal.x = animal.prevx
		animal.y = animal.prevy
		animal.tileX = animal.prevTileX
		animal.tileY = animal.prevTileY
		animal.prevx = animal.x
		animal.prevy = animal.y
		animal.prevTileX = animal.tileX
		animal.prevTileY = animal.tileY
	else
		animal.elevation = self:getHeight()
	end]]
	animal.elevation = self:getHeight()
end
P.wall.onStayAnimal = P.wall.onEnterAnimal
function P.wall:destroy()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
	self.canBePowered = false
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
	self.overlay = nil
	self.yOffset = 0
end
function P.wall:onLeave()
	updateElevation()
	if math.abs(player.elevation-self:getHeight())>3 then
		--player.x = player.prevx
		--player.y = player.prevy
		player.tileX = player.prevTileX
		player.tileY = player.prevTileY
		--player.prevx = player.x
		--player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
	else
		updateElevation()
	end
end
--this function should never actually run...it's here just in case
function P.wall:onLeaveAnimal(animal)
	--[[updateElevation()
	if math.abs(animal.elevation-self:getHeight())>3 then
		--player.x = player.prevx
		--player.y = player.prevy
		animal.tileX = animal.prevTileX
		animal.tileY = animal.prevTileY
		--player.prevx = player.x
		--player.prevy = player.y
		animal.prevTileX = animal.tileX
		animal.prevTileY = animal.tileY
	else
		updateElevation()
	end]]
end
function P.wall:rotate(times)
end
function P.wall:getYOffset()
	if self.destroyed then return 0
	else return self.yOffset end
end

P.metalWall = P.wall:new{dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}, canBePowered = true, name = "metalwall", blocksVision = true,
destroyedSprite = love.graphics.newImage('Graphics/Tiles/metalWallSawed.png'), sprite = love.graphics.newImage('Graphics/Tiles/metalWall.png'), poweredSprite = love.graphics.newImage('Graphics/Tiles/metalWallPowered.png') }
P.metalWall.updateTile = P.conductiveTile.updateTile

P.maskedMetalWall = P.metalWall:new{name = "maskedMetalWall", sprite = love.graphics.newImage('Graphics/maskedMetalWall.png'), poweredSprite = love.graphics.newImage('Graphics/maskedMetalWall.png')}

P.glassWall = P.wall:new{sawable = false, canBePowered = false, dirAccept = {0,0,0,0}, dirSend = {0,0,0,0}, bricked = false, name = "glasswall", blocksVision = false, electrifiedSprite = love.graphics.newImage('Graphics/glasswallelectrified.png'), destroyedSprite = love.graphics.newImage('Graphics/glassbroken.png'), sprite = love.graphics.newImage('GraphicsColor/glass.png'), poweredSprite = love.graphics.newImage('Graphics3D/glass.png'), electrifiedPoweredSprite = love.graphics.newImage('Graphics/glasswallpowered.png'), sawable = false }

P.gate = P.conductiveTile:new{overlaying = true, name = "gate", dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, dirWireHack = {0,0,0,0}, gotten = {0,0,0,0}}
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
function P.gate:rotate(times)
	self.rotation = self.rotation + times
	if self.rotation >= 4 then
		self.rotation = self.rotation - 4
	end
	for i=1,times do
		self.dirSend = shiftArray(self.dirSend)
		self.dirAccept = shiftArray(self.dirAccept)
		self.dirWireHack = shiftArray(self.dirWireHack)
	end
end
function P.gate:destroy()
	self.canBePowered = false
	self.destroyed = true
	self.charged = false
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

P.notGate = P.powerSupply:new{overlaying = false, name = "notGate", dirSend = {1,0,0,0}, dirAccept = {1,1,1,1},
sprite = love.graphics.newImage('Graphics/Tiles/notGateDead.png'),
poweredSprite = love.graphics.newImage('Graphics/Tiles/notGate.png'),
destroyedSprite = love.graphics.newImage('Graphics/Tiles/notGateDestroyed.png')}
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
	self.sprite = self.destroyedSprite
end
P.notGate.flipDirection = P.tWire.flipDirection

P.ambiguousNotGate = P.notGate:new{name = "ambiguousNotGate", litWhenPowered = false, sprite = love.graphics.newImage('Graphics/notgateambiguous.png'), poweredSprite = love.graphics.newImage('Graphics/notgateambiguous.png')}

P.andGate = P.gate:new{name = "andGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, dirWireHack = {1,0,0,0}, sprite = love.graphics.newImage('GraphicsColor/andgate2.png'), poweredSprite = love.graphics.newImage('GraphicsColor/andgatepowered2.png'), 
  off = love.graphics.newImage('GraphicsColor/andgate2.png'),
  leftOn = love.graphics.newImage('GraphicsColor/andgateleft2.png'), 
  rightOn = love.graphics.newImage('GraphicsColor/andgateright2.png') }
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
		if self.poweredNeighbors[self:cfr(2)]==1 then
			self.sprite = self.rightOn
		elseif self.poweredNeighbors[self:cfr(4)]==1 then
			self.sprite = self.leftOn
		else
			self.sprite = self.off
		end
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
P.andGate.flipDirection = P.tWire.flipDirection

P.ambiguousAndGate = P.andGate:new{name = "ambiguousAndGate", litWhenPowered = false, sprite = love.graphics.newImage('Graphics/andgateambiguous.png')}
P.ambiguousAndGate.poweredSprite = P.ambiguousAndGate.sprite
P.ambiguousAndGate.off = P.ambiguousAndGate.sprite
P.ambiguousAndGate.leftOn = P.ambiguousAndGate.sprite
P.ambiguousAndGate.rightOn = P.ambiguousAndGate.sprite

P.orGate = P.gate:new{name = "orGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, dirWireHack = {1,0,0,0}, sprite = love.graphics.newImage('Graphics/orgate.png'), poweredSprite = love.graphics.newImage('Graphics/orgate.png'),
  leftOn = love.graphics.newImage('Graphics/orgateleft.png'), 
  rightOn = love.graphics.newImage('Graphics/orgateright.png'), 
  bothOn = love.graphics.newImage('Graphics/orgateon.png') }
function P.orGate:updateTile(dir)
	if self.charged then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
		return
	end
	if self.poweredNeighbors[self:cfr(2)]==1 or self.poweredNeighbors[self:cfr(4)]==1 then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
		if self.poweredNeighbors[self:cfr(2)]==1 and self.poweredNeighbors[self:cfr(4)]==1 then
			self.poweredSprite = self.bothOn
		elseif self.poweredNeighbors[self:cfr(2)]==1 then
			self.poweredSprite = self.rightOn
		else
			self.poweredSprite = self.leftOn
		end
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
P.orGate.flipDirection = P.tWire.flipDirection

P.xorGate = P.gate:new{name = "xorGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, dirWireHack = {1,0,0,0}, sprite = love.graphics.newImage('Graphics/xorgate.png'), poweredSprite = love.graphics.newImage('Graphics/xorgate.png')}
function P.xorGate:updateTile(dir)
	if self.charged then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
		return
	end
	local sideOne = self.poweredNeighbors[self:cfr(2)]==1
	local sideTwo = self.poweredNeighbors[self:cfr(4)]==1
	if (sideOne and not sideTwo) or (sideTwo and not sideOne) then
		self.powered = true
		self.dirSend = shiftArray({1,0,0,0}, self.rotation)
		if self.poweredNeighbors[self:cfr(2)]==1 and self.poweredNeighbors[self:cfr(4)]==1 then
			self.poweredSprite = self.bothOn
		elseif self.poweredNeighbors[self:cfr(2)]==1 then
			self.poweredSprite = self.rightOn
		else
			self.poweredSprite = self.leftOn
		end
	else
		self.powered = false
		self.dirSend = {0,0,0,0}
	end
end
P.xorGate.flipDirection = P.tWire.flipDirection

local function getTileX(posX)
	return (posX-1)*floor.sprite:getWidth()*scale+wallSprite.width
end

local function getTileY(posY)
	return (posY-1)*floor.sprite:getHeight()*scale+wallSprite.height
end

P.hDoor = P.tile:new{name = "hDoor", stopped = false, blocksVision = true, blocksMovement = true, blocksProjectiles = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
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
function P.hDoor:getHeight()
	return 6
end
P.hDoor.destroy = P.hDoor.onEnter
function P.hDoor:getHeight()
	if not self.blocksMovement then
		return 0 
	else
		return 6
	end
end
function P.hDoor:lightTest(x,y)
	if not self.blocksMovement then
		return false
	end
	if self.rotation % 2 == 1 then

		if x>1 then
			lightTest(x-1,y)
		end
	
	
		if x<roomHeight then
			lightTest(x+1,y)
		end
	else
		if y>1 then
			lightTest(x, y-1)
		end

		if y<roomLength then
			lightTest(x, y+1)
		end
	end
end
function P.hDoor:obstructsMovement()
	if math.abs(player.elevation)<3 then return false
	else return true end
end
function P.hDoor:obstructsMovementAnimal()
	return true
end

P.vDoor= P.tile:new{name = "hDoor", blocksVision = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
function P.vDoor:onEnter(player)
	self.sprite = self.openSprite
	self.blocksVision = false
	
end

P.vPoweredDoor = P.tile:new{name = "vPoweredDoor", stopped = false, yOffset = -6, blocksMovement = false, blocksVision = false, canBePowered = true, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, sprite = love.graphics.newImage('Graphics3D/powereddooropen.png'), closedSprite = love.graphics.newImage('GraphicsColor/powereddoor.png'), openSprite = love.graphics.newImage('GraphicsColor/powereddooropen.png'), poweredSprite = love.graphics.newImage('Graphics3D/powereddoor.png'),
closedSprite2 = love.graphics.newImage('GraphicsColor/powereddoor2.png'), openSprite2 = love.graphics.newImage('GraphicsColor/powereddooropen2.png')}
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
		self.powered = false
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
function P.vPoweredDoor:getHeight()
	if not self.blocksMovement then
		return 0 
	else
		return 6
	end
end
function P.vPoweredDoor:lightTest(x,y)
	if not self.blocksMovement then
		return false
	end
	if self.rotation % 2 == 0 then

		if x>1 then
			lightTest(x-1,y)
		end
	
	
		if x<roomHeight then
			lightTest(x+1,y)
		end
	else
		if y>1 then
			lightTest(x, y-1)
		end

		if y<roomLength then
			lightTest(x, y+1)
		end
	end
end
function P.vPoweredDoor:willDestroyPushable()
	return self.powered
end

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

P.endTile = P.tile:new{name = "endTile", canBePowered = false, dirAccept = {0,0,0,0},
sprite = love.graphics.newImage('Graphics/Tiles/endTile.png'), done = false}
function P.endTile:onEnter(player)
	if map.floorInfo.finalFloor == true then
		if roomHeight>12 and not editorMode then
			win()
			return
		end
	elseif validSpace() and mainMap[mapy][mapx].roomid == "final_2" then
		win()
		unlocks.unlockUnlockableRef(unlocks.stickyButtonUnlock)
	end
	if self.done then return end
	beatRoom()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.poweredEnd = P.endTile:new{name = "poweredEnd", canBePowered = true, dirAccept = {1,1,1,1},
sprite = love.graphics.newImage('Graphics/Tiles/poweredEndOff.png'), poweredSprite = love.graphics.newImage('Graphics/Tiles/endTile.png')}
function P.poweredEnd:onEnter(player)
	if self.done or not self.powered then return end
	beatRoom()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.pitbullTile = P.tile:new{name = "pitbull", animal = animalList[2], sprite = love.graphics.newImage('Graphics/animalstartingtile.png'), listIndex = 2}
function P.pitbullTile:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.animal = o.animal
	return o
end
function P.pitbullTile:usableOnNothing()
	return true
end
P.pupTile = P.pitbullTile:new{name = "pup", animal = animalList[3], listIndex = 3}
P.catTile = P.pitbullTile:new{name = "cat", animal = animalList[4], listIndex = 4}

P.vDoor= P.hDoor:new{name = "vDoor", sprite = love.graphics.newImage('Graphics3D/door.png'), closedSprite = love.graphics.newImage('Graphics/door.png'), openSprite = love.graphics.newImage('Graphics/doorsopen.png')}
P.vDoor.onEnter = P.hDoor.onEnter

P.sign = P.tile:new{text = "", name = "sign", sprite = love.graphics.newImage('KenGraphics/sign.png')}
function P.sign:onEnter(player)
	messageInfo.text = self.text
end
function P.sign:onLeave(player)
	messageInfo.text = nil
end

P.rotater = P.button:new{name = "rotater", canBePowered = true, dirAccept = {1,0,1,0}, dirSend = {1,0,1,0}, sprite = love.graphics.newImage('Graphics/rotater.png'), poweredSprite = love.graphics.newImage('Graphics/rotater.png')}
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
P.rotater.flipDirection = P.tWire.flipDirection

P.cornerRotater = P.rotater:new{name = "cornerRotater", dirSend = {1,1,0,0}, dirAccept = {1,1,0,0}, poweredSprite = love.graphics.newImage('Graphics/cornerrotater.png'), sprite = love.graphics.newImage('Graphics/cornerrotater.png')}
function P.cornerRotater.flipDirection(dir, isVertical)
	if dir == 0 or dir == 2 then
		return isVertical and 1 or (dir == 2 and -1 or 3)
	else
		return isVertical and -1 or 1
	end
	return 0
end

P.concreteWall = P.wall:new{sawable = false, name = "concreteWall",
sprite = love.graphics.newImage('GraphicsColor/concretewall3.png'), destroyedSprite = love.graphics.newImage('Graphics/concretewallbroken.png'), sawable = false}
function P.wall:onLoad()
	local dungeonChance = util.random(100, 'misc')
	if dungeonChance==1 then
		self.hidesDungeon = true
	end
end
function P.concreteWall:destroy()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
	self.canBePowered = false
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
	self.overlay = nil
	self.yOffset = 0
	if not self.hidesDungeon then
		local bonusDungeonChance = util.random(100, 'misc')
		if bonusDungeonChance<getLuckBonus() then
			self.hidesDungeon = true
		end
	end
	if self.hidesDungeon then
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]==self then
					room[i][j] = tiles.dungeonEnter:new()
				end
			end
		end
	end
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

P.tunnel = P.tile:new{name = "tunnel", toolsNeeded = -1, toolsEntered = 0, sprite = love.graphics.newImage('KenGraphics/stairs.png')}
function P.tunnel:onEnter(player)
	--[[if self.toolsNeeded==0 then loadNextLevel() return end
	local noNormalTools = true
	for i = 1, tools.numNormalTools do
		if tools[i].numHeld>0 then noNormalTools = false end
	end
	if noNormalTools then loadNextLevel() end
	if tool==0 or tool>7 then return end
	tools[tool].numHeld = tools[tool].numHeld - 1
	self.toolsNeeded = self.toolsNeeded-1
	self.toolsEntered = self.toolsEntered+1
	--donations = donations+math.ceil((7-(floorIndex))/2)
	floorDonations = floorDonations+1]]
	goDownFloor()
end

P.upTunnel = P.tunnel:new{name = "upTunnel", sprite = love.graphics.newImage('KenGraphics/stairsUp.png')}
function P.upTunnel:onEnter(player)
	goUpFloor()
end
--[[function P.tunnel:getInfoText()
	return self.toolsNeeded
end
function P.tunnel:postPowerUpdate()
	if toolMax==nil then toolMax = 0 end
	self.toolsNeeded = toolMax-self.toolsEntered
	if self.toolsNeeded<0 then self.toolsNeeded = 0 end
end]]

P.pit = P.tile:new{name = "pit", laddered = false, sprite = love.graphics.newImage('GraphicsBrush/pituncovered.png'), destroyedSprite = love.graphics.newImage('Graphics/ladderedPit.png')}
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

P.breakablePit = P.pit:new{strength = 2, name = "breakablePit", sprite = love.graphics.newImage('GraphicsBrush/pitcovered.png'), halfBrokenSprite = love.graphics.newImage('GraphicsBrush/pithalfcovered.png'), brokenSprite = love.graphics.newImage('GraphicsBrush/pituncovered.png')}
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
P.breakablePit.onEnterAnimal = P.breakablePit.onEnter
function P.breakablePit:willKillPlayer()
	return not self.laddered and self.strength == 0
end
P.breakablePit.willKillAnimal = P.breakablePit.willKillPlayer
P.breakablePit.willDestroyPushable = P.breakablePit.willKillPlayer

P.treasureTile = P.tile:new{name = "treasureTile", sprite = love.graphics.newImage('Graphics/Tiles/treasureTile1.png'),
  done = false}
function P.treasureTile:onEnter()
	if self.done then return end
	self:giveReward()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end
function P.treasureTile:giveReward()
	local timesCounter = 0
	local probBasic = 400
	local probBasic2 = 100
	local probSuper = 100
	local basicCount = 0
	local superCount = 0
	local rand = util.random(1000,'toolDrop')
	--[[if rand<probBasic then
		basicCount = basicCount+1
	end
	rand = util.random(1000,'toolDrop')
	if rand<probBasic2 then
		basicCount = basicCount+1
	end
	rand = util.random(1000,'toolDrop')
	if rand<probSuper then
		superCount = superCount+1
	end
	if basicCount==0 and superCount==0 then donations = donations+5
	else tools.giveRandomTools(basicCount,superCount,self.treasureWeights) end]]
	if rand<100-donations then
		donations = donations+100
	elseif rand<800-donations then
		tools.giveRandomTools(1)
	elseif rand<900-donations then
		tools.giveRandomTools(2)
	else
		local quality
		if rand<910 then
			quality = 1
		elseif rand<950 then
			quality = 2
		elseif rand<985 then
			quality = 3
		elseif rand<999 then
			quality = 4
		else
			quality = 5
		end
		tools.giveRandomTools(1,1,{quality})
	end
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
	return not self.safe
end
function P.mousetrap:postPowerUpdate()
	if self.bricked then return end
	if self.formerPowered~=nil and self.formerPowered~=self.powered and self.safe then
		self.safe = false
		self:updateSprite()
	end
end
function P.mousetrap:absoluteFinalUpdate()
	if self.triggered then
		self.safe = true
		self.triggered = false
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

P.bomb = P.tile:new{name = "bomb", triggered = true, counter = 3, sprite = love.graphics.newImage('Graphics/Tiles/bomb3.png'), sprite2 = love.graphics.newImage('Graphics/Tiles/bomb2.png'), sprite1 = love.graphics.newImage('Graphics/Tiles/bomb1.png')}
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
function P.bomb:onEnd(x, y)
	self:explode(x,y)
end
function P.bomb:destroy()
	self.gone = true
end
function P.bomb:explode(x,y)
	if not editorMode and math.abs(player.tileY-x)<2 and math.abs(player.tileX-y)<2 then 
		kill()
		if self.name == P.bomb.name then
			unlocks = require('scripts.unlocks')
			unlocks.unlockUnlockableRef(unlocks.frederickUnlock)
		end
	end
	for i = -1, 1 do
		for j = -1, 1 do
			if room[x+i]~=nil and room[x+i][y+j]~=nil then
				room[x+i][y+j]:destroy()
				if room[x+i][y+j]:instanceof(tiles.bomb) then
					unlocks.unlockUnlockableRef(unlocks.bombBuddyUnlock)
				end
			end
		end
	end
	for k = 1, #animals do
		if not animals[k].dead and math.abs(animals[k].tileY-x)<2 and math.abs(animals[k].tileX-y)<2 then
			animals[k]:kill()
			if animals[k]:instanceof(animalList.bombBuddy) then
				animals[k]:explode()
			end
		end
	end
	for k = 1, #pushables do
		if math.abs(pushables[k].tileY-x)<2 and math.abs(pushables[k].tileX-y)<2 and not pushables[k].destroyed then
			pushables[k]:destroy()
			if pushables[k]:instanceof(pushableList.bombBox) then
				unlocks.unlockUnlockableRef(unlocks.bombBuddyUnlock)
			end
		end
	end
	updatePower()
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
P.capacitor.flipDirection = P.tWire.flipDirection

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
P.inductor.flipDirection = P.tWire.flipDirection

P.slime = P.tile:new{name = "slime", sprite = love.graphics.newImage('Graphics/slime.png')}
function P.slime:onEnter(player)
	if player.character.name == characters.lenny.name then return end
	player.waitCounter = player.waitCounter+1
end
function P.slime:onEnterAnimal(animal)
	if animal:instanceof(animalList.snail) then return end
	if animal.waitCounter<=0 then
		animal.waitCounter = animal.waitCounter+1
	end
end

P.unactivatedBomb = P.bomb:new{name = "unactivatedBomb", counter = 4, triggered = false,
sprite = love.graphics.newImage('Graphics/Tiles/bombUntriggered.png'),
sprite3 = love.graphics.newImage('Graphics/Tiles/bomb3.png'),
sprite2 = love.graphics.newImage('Graphics/Tiles/bomb2.png'),
sprite1 = love.graphics.newImage('Graphics/Tiles/bomb1.png')}
function P.unactivatedBomb:onStep(x, y)
	if self.triggered then
		self.counter = self.counter-1
		if self.counter == 3 then
			self.sprite = self.sprite3
		elseif self.counter == 2 then
			self.sprite = self.sprite2
		elseif self.counter == 1 then
			self.sprite = self.sprite1
		elseif self.counter == 0 then
			self.gone = true
		end
		self.poweredSprite = self.sprite
	end
end
function P.unactivatedBomb:onEnter(player)
	self.triggered = true
end
function P.unactivatedBomb:onEnterAnimal(animal)
	self.triggered = true
end

P.snailTile = P.pitbullTile:new{name = "snail", animal = animalList[5], listIndex = 5}

P.doghouse = P.pitbullTile:new{name = "doghouse", sprite = love.graphics.newImage('Graphics/doghouse.png')}
function P.doghouse:onStep(x, y)
	if player.tileX == y and player.tileY == x then return end
	for i = 1, #animals do
		if animals[i].tileY == x and animals[i].tileX == y then return end
	end
	animals[animalCounter] = animalList[2]
	animals[animalCounter].y = y*floor.sprite:getWidth()*scale+wallSprite.height
	animals[animalCounter].x = x*floor.sprite:getHeight()*scale+wallSprite.width
	animals[animalCounter].tileX = y
	animals[animalCounter].tileY = x
	animalCounter=animalCounter+1
end

P.batTile = P.pitbullTile:new{name = "bat", animal = animalList[6], listIndex = 6}

P.meat = P.tile:new{name = "meat", sprite = love.graphics.newImage('Graphics/Tiles/meat.png'), attractsAnimals = true}

P.rottenMeat = P.tile:new{name = "rottenMeat", sprite = love.graphics.newImage('Graphics/rottenmeat.png'), scaresAnimals = true}

P.beggar = P.tile:new{name = "beggar", alive = true, counter = 0, sprite = love.graphics.newImage('Graphics/beggar.png'), deadSprite = love.graphics.newImage('Graphics/beggardead.png')}
function P.beggar:onEnter(player)
	--[[if tool==0 or tool>7 then return end
	if not self.alive then return end
	tools[tool].numHeld = tools[tool].numHeld - 1
	self.counter = self.counter+1
	probabilityOfPayout = self.counter/4+donations*2/100
	randomNum = util.random('toolDrop')
	if randomNum<probabilityOfPayout then
		self.counter = 0
		self:providePayment()
		local killBeggar = util.random('toolDrop')
		if killBeggar<0.5 then
			self:destroy()
		end
	end]]
end
function P.beggar:getInfoText()
	--return self.counter
end
function P.beggar:destroy()
	self.sprite = self.deadSprite
	self.alive = false
	local paysOut = util.random('toolDrop')
	if paysOut<0.5 and not player.character.name==characters.felix.name then return end
	self:providePayment()
end
function P.beggar:providePayment()
	local paymentType = util.random('toolDrop')
	if paymentType<0.33 then P.redBeggar:providePayment()
	elseif paymentType<0.66 then P.blueBeggar:providePayment()
	else P.greenBeggar:providePayment() end
end

P.redBeggar = P.beggar:new{name = "redBeggar", sprite = love.graphics.newImage('Graphics/redbeggar.png'), deadSprite = love.graphics.newImage('Graphics/redbeggardead.png')}
function P.redBeggar:providePayment()
	local greenTools = util.random('toolDrop')
	local ttg = 0
	if greenTools<0.5 then ttg = 1
	elseif greenTools<0.95 then ttg = 2
	else ttg = 3 end
	tools.giveRandomTools(ttg)
end

P.greenBeggar = P.beggar:new{name = "greenBeggar", sprite = love.graphics.newImage('Graphics/greenbeggar.png'), deadSprite = love.graphics.newImage('Graphics/greenbeggardead.png')}
function P.greenBeggar:providePayment()
	local luckyCoin = util.random(100, 'toolDrop')
	local ttg = tools.coin
	if luckyCoin<getLuckBonus() then
		ttg = tools.luckyPenny
	end

	if util.getSupertoolTypesHeld()<3 or ttg.numHeld>0 then
		tools.giveToolsByReference({ttg})
	else
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]==self then
					room[i][j] = tiles.supertoolTile:new()
					room[i][j].tool = ttg
				end
			end
		end
	end
end

P.blueBeggar = P.beggar:new{name = "blueBeggar", sprite = love.graphics.newImage('Graphics/bluebeggar.png'), deadSprite = love.graphics.newImage('Graphics/bluebeggardead.png')}
function P.blueBeggar:providePayment()
	local quality = util.random('toolDrop')
	if quality < 0.075 then
		quality = 1
	elseif quality < 0.6 then
		quality = 2
	elseif quality < 0.885 then
		quality = 3
	elseif quality < 0.985 then
		quality = 4
	else
		quality = 5
	end
	tools.giveSupertools(1, {quality})
end

P.whiteBeggar = P.beggar:new{name = "whiteBeggar", sprite = love.graphics.newImage('Graphics/whitebeggar.png')}
function P.whiteBeggar:providePayment()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				room[i][j] = tiles.tunnel:new()
				return
			end
		end
	end
end

P.blackBeggar = P.beggar:new{name = "blackBeggar", sprite = love.graphics.newImage('Graphics/blackbeggar.png')}
function P.blackBeggar:providePayment()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				room[i][j] = tiles.dungeonEnter:new()
				return
			end
		end
	end
end

P.goldBeggar = P.beggar:new{name = "goldBeggar", sprite = love.graphics.newImage('Graphics/goldbeggar.png')}
function P.goldBeggar:providePayment()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				room[i][j] = tiles.endTile:new()
				return
			end
		end
	end
end

P.ladder = P.tile:new{name = "ladder", sprite = love.graphics.newImage('Graphics/laddertile.png'), blocksAnimalMovement = true}
function P.ladder:obstructsMovementAnimal(animal)
	return true
end

P.mousetrapOff = P.mousetrap:new{name = "mousetrapOff", safe = true, sprite = love.graphics.newImage('Graphics/mousetrapsafe.png')}

P.donationMachine = P.tile:new{name = "donationMachine", sprite = love.graphics.newImage('Graphics/donationmachine.png')}
function P.donationMachine:getInfoText()
	return donations
end
function P.donationMachine:onEnter(player)
	if tool==0 then return end
	tools[tool].numHeld = tools[tool].numHeld - 1
	local mult = 1
	if tool > tools.numNormalTools then
		mult = 1
		unlocks = require('scripts.unlocks')
		unlocks.unlockUnlockableRef(unlocks.snailsUnlock)
	end
	donations = donations+mult*math.ceil((10-(floorIndex))/2)
	floorDonations = floorDonations+1
	gameTime.timeLeft = gameTime.timeLeft+mult*gameTime.donateTime
end
function P.donationMachine:destroy()
	if donations>0 then
		donations = donations-1
		local toolsToGive = util.random(3, 'toolDrop')
		tools.giveRandomTools(toolsToGive)
	end
end

P.entrancePortal = P.tile:new{name = "entrancePortal", sprite = love.graphics.newImage('Graphics/Tiles/entrancePortal.png')}
function P.entrancePortal:onEnter(player)
	for i = 1, roomHeight do
		shouldBreak = false
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.exitPortal) then
				local movePlayer = true
				for k = 1, #pushables do
					if pushables[k].tileX == j and pushables[k].tileY == i then
						movePlayer = false
					end
				end
				if movePlayer then
					player.tileX = j
					player.tileY = i
				end
				shouldBreak = true
				break
			end
		end
		if shouldBreak then break end
	end
end
function P.entrancePortal:onEnterAnimal(animal)
	for i = 1, roomHeight do
		shouldBreak = false
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.exitPortal) then
				local moveAnimal = true
				for k = 1, #pushables do
					if pushables[k].tileX == j and pushables[k].tileY == i then
						moveAnimal = false
					end
				end
				for k = 1, #animals do
					if animals[k].tileX == j and animals[k].tileY == i and not animals[k].dead then
						moveAnimal = false
					end
				end
				if moveAnimal then
					animal.tileX = j
					animal.tileY = i
				end
				shouldBreak = true
				break
			end
		end
		if shouldBreak then break end
	end
end
P.entrancePortal.onStay = P.entrancePortal.onEnter
P.entrancePortal.onStayAnimal = P.entrancePortal.onEnterAnimal

P.exitPortal = P.tile:new{name = "exitPortal", sprite = love.graphics.newImage('Graphics/exitPortal.png')}

P.entrancePortal2 = P.entrancePortal:new{name = "entrancePortal2", sprite = love.graphics.newImage('Graphics/entranceportal2.png')}
function P.entrancePortal2:onEnter(player)
	for i = 1, roomHeight do
		shouldBreak = false
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.exitPortal2) then
				local movePlayer = true
				for k = 1, #pushables do
					if pushables[k].tileX == j and pushables[k].tileY == i then
						movePlayer = false
					end
				end
				if movePlayer then
					player.tileX = j
					player.tileY = i
				end
				shouldBreak = true
				break
			end
		end
		if shouldBreak then break end
	end
end
function P.entrancePortal2:onEnterAnimal(animal)
	for i = 1, roomHeight do
		shouldBreak = false
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.exitPortal2) then
				local moveAnimal = true
				for k = 1, #pushables do
					if pushables[k].tileX == j and pushables[k].tileY == i then
						moveAnimal = false
					end
				end
				for k = 1, #animals do
					if animals[k].tileX == j and animals[k].tileY == i and not animals[k].dead then
						moveAnimal = false
					end
				end
				if moveAnimal then
					animal.tileX = j
					animal.tileY = i
				end
				shouldBreak = true
				break
			end
		end
		if shouldBreak then break end
	end
end
P.entrancePortal2.onStay = P.entrancePortal2.onEnter
P.entrancePortal2.onStayAnimal = P.entrancePortal2.onEnterAnimal

P.exitPortal2 = P.tile:new{name = "exitPortal2", sprite = love.graphics.newImage('Graphics/exitportal2.png')}

P.treasureTile2 = P.treasureTile:new{name = "treasureTile2", sprite = love.graphics.newImage('Graphics/Tiles/treasureTile2.png')}

function P.treasureTile2:onEnter()
	if self.done then return end
	self:giveReward()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end
function P.treasureTile2:giveReward()
	local reward = util.random(1000,'toolDrop')
	if reward<775 then
		tools.giveRandomTools(1)
	else
		local quality
		if reward<888 then
			quality = 2
		else
			quality = 3
		end
		tools.giveRandomTools(1,1,{quality})
	end
end

P.treasureTile3 = P.treasureTile:new{name = "treasureTile3", sprite = love.graphics.newImage('Graphics/Tiles/treasureTile3.png')}

P.treasureTile4 = P.treasureTile:new{name = "treasureTile4", sprite = love.graphics.newImage('Graphics/Tiles/treasureTile4.png')}

P.conductiveSlime = P.conductiveTile:new{name = "conductiveSlime", sprite = love.graphics.newImage('Graphics/conductiveslime.png'), poweredSprite = love.graphics.newImage('Graphics/conductiveslimepowered.png')}
P.conductiveSlime.onEnter = P.slime.onEnter
P.conductiveSlime.onEnterAnimal = P.slime.onEnterAnimal
function P.conductiveSlime:willKillPlayer()
	return self.powered
end
P.conductiveSlime.willKillAnimal = P.conductiveSlime.willKillPlayer

P.conductiveSnailTile = P.pitbullTile:new{name = "conductiveSnail", animal = animalList[7], listIndex = 7}

P.glueSnailTile = P.pitbullTile:new{name = "glueSnail", animal = animalList[8], listIndex = 8}

P.bombBuddyTile = P.pitbullTile:new{name = "bombBuddyTile", animal = animalList[9], listIndex = 9}

P.conductiveDogTile = P.pitbullTile:new{name = "conductiveDogTile", animal = animalList[10], listIndex = 10}

P.wifeTile = P.pitbullTile:new{name = "wifeTile", animal = animalList[11], listIndex = 11}

P.sonTile = P.pitbullTile:new{name = "sonTile", animal = animalList[12], listIndex = 12}

P.daughterTile = P.pitbullTile:new{name = "daughterTile", animal = animalList[13], listIndex = 13}

P.untriggeredPowerSupply = P.conductiveTile:new{name = "untriggeredPowerSupply", sprite = love.graphics.newImage('Graphics/untriggeredpowersupply.png'), poweredSprite = love.graphics.newImage('Graphics/powersupply.png')}
function P.untriggeredPowerSupply:postPowerUpdate(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.charged = true
	end
end
function P.untriggeredPowerSupply:destroy()
	self.charged = false
	self.dirAccept = {0,0,0,0}
end

P.untriggeredPowerSupplyTimer = P.conductiveTile:new{name = "untriggeredPowerSupplyTimer", readyToTransform = false, dirSend = {0,0,0,0}, canBePowered = true, sprite = love.graphics.newImage('Graphics/untriggeredpowersupplytimer.png'), poweredSprite = love.graphics.newImage('Graphics/powersupply.png')}
function P.untriggeredPowerSupplyTimer:postPowerUpdate(dir)
	if not self.charged and (self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1) then
		self.readyToTransform = true
	end
end
function P.untriggeredPowerSupplyTimer:absoluteFinalUpdate()
	if self.readyToTransform then
		self.charged = true
		self.dirSend = {1,1,1,1}
		forcePowerUpdateNext = true
		self.readyToTransform = false
	end
end
function P.untriggeredPowerSupplyTimer:destroy()
	self.charged = false
	self.dirAccept = {0,0,0,0}
end

P.reinforcedGlass = P.concreteWall:new{name = "reinforcedGlass", blocksVision = false, sprite = love.graphics.newImage('Graphics3D/reinforcedglass.png'), poweredSprite = love.graphics.newImage('Graphics3D/reinforcedglass.png')}

P.powerTriggeredBomb = P.unactivatedBomb:new{name = "powerTriggeredBomb", canBePowered = true, powered = false, dirAccept = {1,1,1,1}, dirSend = {0,0,0,0}}
function P.powerTriggeredBomb:postPowerUpdate()
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		if not self.triggered then
			self.counter = 4
			self.triggered = true
		end
	end
	self.poweredSprite = self.sprite
end
function P.powerTriggeredBomb:onEnter(player)
end
P.powerTriggeredBomb.onEnterAnimal = P.powerTriggeredBomb.onEnter

P.boxTile = P.tile:new{name = "boxTile", pushable = pushableList[2], listIndex = 2, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}
function P.boxTile:usableOnNothing()
	return true
end

P.motionGate = P.conductiveTile:new{name = "gate", updatePowerOnLeave = true, dirSend = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/gate.png'), poweredSprite = love.graphics.newImage('Graphics/gate.png')}
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
P.motionGate.flipDirection = P.tWire.flipDirection

P.motionGate2 = P.motionGate:new{name = "gate2", dirSend = {1,1,1,1}}

P.playerBoxTile = P.boxTile:new{name = "playerBoxTile", pushable = pushableList[3], listIndex = 3}
P.animalBoxTile = P.boxTile:new{name = "animalBoxTile", pushable = pushableList[4], listIndex = 4}

P.puddle = P.conductiveTile:new{name = "puddle", sprite = love.graphics.newImage('Graphics/puddle.png'), poweredSprite = love.graphics.newImage('Graphics/puddlelectrified.png')}
function P.puddle:willKillPlayer()
	return not self.destroyed and self.powered
end
function P.puddle:destroy()
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
	if player.character.name == characters.lenny.name then
		unlocks = require('scripts.unlocks')
		unlocks.unlockUnlockableRef(unlocks.glueSnailUnlock)
	end
end

function P.glue:onStay(player)
	player.waitCounter = player.waitCounter+1
end
function P.glue:onEnterAnimal(animal)
	if animal:instanceof(animalList.snail) then
		unlocks = require('scripts.unlocks')
		unlocks.unlockUnlockableRef(unlocks.glueSnailUnlock)
		return
	end
	if animal.flying then return end
	animal.waitCounter = animal.waitCounter+1
end
P.glue.onStayAnimal = P.glue.onEnterAnimal

P.conductiveBoxTile = P.tile:new{name = "conductiveBoxTile", pushable = pushableList[5], listIndex = 5, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.boomboxTile = P.boxTile:new{name = "boomboxTile", pushable = pushableList[6], listIndex = 6, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.batteringRamTile = P.boxTile:new{name = "batteringRamTile", pushable = pushableList[7], listIndex = 7, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.lamp = P.powerSupply:new{name = "lamp", emitsLight = true, intensity = 0.7, range = 50, sprite = love.graphics.newImage('Graphics/lamp.png'), poweredSprite = love.graphics.newImage('Graphics/lamp.png'), lit = true, destroyedSprite = love.graphics.newImage('Graphics/destroyedlamp.png')}
function P.lamp:destroy()
	self.sprite = self.destroyedSprite
	self.canBePowered = false
	self.powered = false
	self.destroyed = true
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
	self.lit = false
end

P.flickeringLamp = P.lamp:new{name = "flickeringLamp", deltaIntensity = 0, range = 50}
function P.flickeringLamp:realtimeUpdate()
	if (self.deltaIntensity==0) then
		local triggerFlicker = util.random(60, 'misc')
		if triggerFlicker==1 then
			self.deltaIntensity = -0.1;
		end
	else
		self.intensity = self.intensity+self.deltaIntensity;
		if self.intensity<0 then self.deltaIntensity = 0.1
		elseif self.intensity>1 then self.deltaIntensity = 0 end
	end
end

P.conductiveGlass = P.glassWall:new{name = "conductiveGlass", sprite = love.graphics.newImage('Graphics3D/conductiveglass.png'), poweredSprite = love.graphics.newImage('Graphics3D/conductiveglass.png'), canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.reinforcedConductiveGlass = P.reinforcedGlass:new{name = "reinforcedConductiveGlass", sprite = love.graphics.newImage('Graphics3D/reinforcedconductiveglass.png'), poweredSprite = love.graphics.newImage('Graphics3D/reinforcedconductiveglass.png'), canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.fog = P.tile:new{name = "fog", sprite = love.graphics.newImage('Graphics/fog.png'), blocksVision = true}
function P.fog:obstructsVision()
	return player.elevation==0
end
function P.fog:obstructsMovementAnimal(animal)
	if math.abs(animal.elevation)<3 then
		return false
	else
		return true
	end
end
function P.fog:obstructsMovement()
	if math.abs(player.elevation)<3 then
		return false
	else
		return true
	end
end

P.accelerator = P.conductiveTile:new{name = "accelerator", sprite = love.graphics.newImage('Graphics/accelerator.png'), poweredSprite = love.graphics.newImage('Graphics/accelerator.png')}
function P.accelerator:yAccel()
	if not self.powered then return 0 end
	if self.rotation==0 then return -1
	elseif self.rotation==2 then return 1
	else return 0 end
end
function P.accelerator:xAccel()
	if not self.powered then return 0 end
	if self.rotation==1 then return 1
	elseif self.rotation==3 then return -1
	else return 0 end
end
P.accelerator.flipDirection = P.tWire.flipDirection

P.unpoweredAccelerator = P.accelerator:new{name = "unpoweredaccelerator", canBePowered = false, sprite = love.graphics.newImage('Graphics/unpoweredaccelerator.png')}
function P.unpoweredAccelerator:yAccel()
	if self.rotation==0 then return -1
	elseif self.rotation==2 then return 1
	else return 0 end
end
function P.unpoweredAccelerator:xAccel()
	if self.rotation==1 then return 1
	elseif self.rotation==3 then return -1
	else return 0 end
end

P.bombBoxTile = P.boxTile:new{name = "bombBoxTile", pushable = pushableList[8], listIndex = 8, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.giftBoxTile = P.boxTile:new{name = "giftBoxTile", pushable = pushableList[9], listIndex = 9, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.jackInTheBoxTile = P.boxTile:new{name = "jackInTheBoxTile", pushable = pushableList[10], listIndex = 10, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.finalToolsTile = P.tile:new{name = "finalToolsTile", canBePowered = false, dirAccept = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/donationmachine.png'), done = false, toolsToGive = {}, giveRate = 0.75, timeLeft = 0}
function P.finalToolsTile:onEnter(player)
	if self.done then return end
end
function P.finalToolsTile:onLoad()
	beatRoom(true)
	if mainMap[mapy][mapx+1]==nil then return end
	local itemsNeeded = map.getItemsNeeded(mainMap[mapy][mapx+1].roomid)
	local toolsArray = itemsNeeded[util.random(#itemsNeeded,'toolDrop')]
	local toolsNum = 0
	for i = 1, tools.numNormalTools do
		toolsNum = toolsNum + toolsArray[i]
	end
	local superOptions = tools.chooseGoodSupertools()
	for i = 1, donations-toolsNum do
		local random = util.random('toolDrop')
		if random>0.75 then
			self.toolsToGive[#self.toolsToGive+1] = superOptions[util.random(3,'toolDrop')]
		else
			self.toolsToGive[#self.toolsToGive+1] = tools.chooseNormalTool()
		end
	end
	local toolsList = {}
	for i = 1, tools.numNormalTools do
		for j = 1, toolsArray[i] do
			toolsList[#toolsList+1] = i
		end
	end
	toolsList = util.shuffle(toolsList, 'toolDrop')
	for i = 1, donations do
		self.toolsToGive[#self.toolsToGive+1] = toolsList[i]
	end
end
function P.finalToolsTile:updateTime(dt)
	if self.done then
		return
	end
	if #self.toolsToGive == 0 then
		self.done = true
		self.isCompleted = true
		self.isVisible = false
		self.gone = true
		return
	end
	self.timeLeft = self.timeLeft - dt
	if self.timeLeft < 0 then
		self.timeLeft = self.giveRate
		tools.giveTools({self.toolsToGive[#self.toolsToGive]})
		self.toolsToGive[#self.toolsToGive] = nil
	end
end
function P.finalToolsTile:getInfoText()
	return #self.toolsToGive
end

P.grass = P.tile:new{name = "grass", sprite = love.graphics.newImage('KenGraphics/grass.png')}
P.bed = P.tile:new{name = "bed", sprite = love.graphics.newImage('KenGraphics/bed.png')}
P.statuebottom = P.tile:new{name = "statuebottom", sprite = love.graphics.newImage('KenGraphics/statuebottom.png')}
P.statuetop = P.tile:new{name = "statuetop", sprite = love.graphics.newImage('KenGraphics/statuetop.png')}
P.chairfront = P.tile:new{name = "chairfront", sprite = love.graphics.newImage('KenGraphics/chairfront.png')}
P.chairback = P.tile:new{name = "chairback", sprite = love.graphics.newImage('KenGraphics/chairback.png')}
P.carpetmid = P.tile:new{name = "carpetmid", sprite = love.graphics.newImage('KenGraphics/puregreen.png')}
P.carpetedge = P.tile:new{name = "carpetedge", sprite = love.graphics.newImage('KenGraphics/carpetedge.png')}
P.carpetcorner = P.tile:new{name = "carpetcorner", sprite = love.graphics.newImage('KenGraphics/carpetcorner.png')}
P.bookcase = P.tile:new{name = "bookcase", sprite = love.graphics.newImage('KenGraphics/bookcase.png')}
P.pooledge = P.tile:new{name = "pooledge", sprite = love.graphics.newImage('KenGraphics/pooledge.png')}
P.poolcorner = P.tile:new{name = "poolcorner", sprite = love.graphics.newImage('KenGraphics/poolcorner.png')}
P.poolcenter = P.tile:new{name = "poolcenter", sprite = love.graphics.newImage('KenGraphics/poolcenter.png')}

P.invisibleWire = P.wire:new{name = "invisibleWire", isVisible = false}
P.invisibleAndGate = P.wire:new{name = "invisibleAndGate", isVisible = false}
P.invisibleTWire = P.tWire:new{name = "invisibleTWire", isVisible = false}
P.invisibleNotGate = P.notGate:new{name = "invisibleNotGate", isVisible = false}
P.invisiblePowerSupply = P.powerSupply:new{name = "invisiblePowerSupply", isVisible = false}
P.invisibleConcreteWall = P.concreteWall:new{name = "invisibleConcreteWall", isVisible = false}
P.invisibleWoodenWall = P.wall:new{name = "invisibleWoodenWall", isVisible = false}
P.invisiblePoweredFloor = P.poweredFloor:new{name = "invisiblePoweredFloor", isVisible = false}
P.invisibleElectricFloor = P.electricFloor:new{name = "invisibleElectricFloor", isVisible = false}
P.invisibleBoxTile = P.tile:new{name = "invisibleBoxTile", pushable = pushableList[11], listIndex = 11, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}
P.invisibleDecoy = P.tile:new{name = "invisibleDecoy", isVisible = false}

P.superStickyButton = P.stickyButton:new{name = "superStickyButton", sprite = love.graphics.newImage('Graphics/superStickyButton.png'), upSprite = love.graphics.newImage('Graphics/superStickyButton.png')}
P.unbreakableElectricFloor = P.electricFloor:new{name = "unbreakableElectricFloor", litWhenPowered = false, sprite = love.graphics.newImage('Graphics/unbreakableElectricFloor.png'), poweredSprite = love.graphics.newImage('Graphics/unbreakableElectricFloor.png')}
P.unbrickableStayButton = P.stayButton:new{name = "unbrickableStayButton", sprite = love.graphics.newImage('Graphics/unbrickableStayButton.png'), upSprite = love.graphics.newImage('Graphics/unbrickableStayButton.png')}

P.pinkFog = P.fog:new{name = "pinkFog", sprite = love.graphics.newImage('Graphics/pinkfog.png')}

P.endTilePaid = P.tunnel:new{name = "endTilePaid", setTools = false, toolsNeededTotal = 0, sprite = love.graphics.newImage('Graphics/endtilepaid.png')}
function P.endTilePaid:onEnter(player)
end
function P.endTilePaid:onEnter(player)
	if self.toolsNeeded==0 then
		if map.floorInfo.finalFloor == true then
			if roomHeight>12 and not editorMode then
				win()
				return
			end
		end
		if self.done then return end
		beatRoom()
		self.done = true
		self.isCompleted = true
		self.isVisible = false
		self.gone = true
		return
	end
	local noNormalTools = true
	for i = 1, tools.numNormalTools do
		if tools[i].numHeld>0 then noNormalTools = false end
	end
	if noNormalTools then
		beatRoom()
		self.done = true
		self.isCompleted = true
		self.isVisible = false
		self.gone = true
		return
	end
	if tool==0 or tool>7 then return end
	tools[tool].numHeld = tools[tool].numHeld - 1
	self.toolsNeeded = self.toolsNeeded-1
	self.toolsEntered = self.toolsEntered+1
	--donations = donations+math.ceil((7-(floorIndex))/2)
	floorDonations = floorDonations+1
end
function P.endTilePaid:getInfoText()
	return self.toolsNeeded
end
function P.endTilePaid:postPowerUpdate()
	if self.text~=nil and tonumber(self.text)~=nil and not self.setTools then
		self.toolsNeededTotal = tonumber(self.text)
		self.toolsNeeded = self.toolsNeededTotal
		self.setTools = true
	elseif not self.setTools then
		self.toolsNeededTotal = 1
		self.toolsNeeded = self.toolsNeededTotal-self.toolsEntered
		if self.toolsNeeded<0 then self.toolsNeeded = 0 end
	else
		self.toolsNeeded = self.toolsNeededTotal-self.toolsEntered
		if self.toolsNeeded<0 then self.toolsNeeded = 0 end		
	end
end
P.endTilePaid.onStep = P.endTilePaid.postPowerUpdate

P.mushroom = P.tile:new{name = "mushroom", sprite = love.graphics.newImage('KenGraphics/mushroom.png')}
function P.mushroom:onEnter()
	mushroomMode = true
	shaderTriggered = true
	globalTint = {0,0.15,0.3}
end

P.lampTile = P.tile:new{name = "lampTile", pushable = pushableList[12], listIndex = 12, sprite = love.graphics.newImage('Graphics/boxstartingtile.png')}

P.hermanTransform = P.tile:new{name = "hermanTransform", characterIndex = 1}
function P.hermanTransform:onEnter()
	player.character = characters[self.characterIndex]
	myShader:send("player_range", 500)
end
function P.hermanTransform:postPowerUpdate()
	self.sprite = characters[self.characterIndex].sprite
end
P.felixTransform = P.hermanTransform:new{name = "felixTransform", characterIndex = 2}
P.erikTransform = P.hermanTransform:new{name = "erikTransform", characterIndex = 4}
P.rammyTransform = P.hermanTransform:new{name = "rammyTransform", characterIndex = 6}
P.lennyTransform = P.hermanTransform:new{name = "lennyTransform", characterIndex = 15}
P.fishTransform = P.hermanTransform:new{name = "fishTransform", characterIndex = 16}

P.supertoolTile = P.tile:new{name = "supertoolTile", tool = nil, superQuality = 1}
function P.supertoolTile:absoluteFinalUpdate()
	if self.tool==nil then
		local quality = 0
		local toolForTile = nil
		local toolForTileId = 1
		local unlockedSupers = unlocks.getUnlockedSupertools()
		while(quality ~= self.superQuality or not unlockedSupers[toolForTileId]) do
			toolForTileId = util.random(#tools-tools.numNormalTools, 'toolDrop')+tools.numNormalTools
			toolForTile = tools[toolForTileId]
			quality = toolForTile.quality
		end
		self.tool = toolForTile
		self:updateSprite()
	end
end
function P.supertoolTile:updateSprite()
	if self.tool~=nil then
		self.sprite = self.tool.image
	end
end
function P.supertoolTile:onEnter()
	local stTypesHeld = util.getSupertoolTypesHeld()
	if stTypesHeld<3 or self.tool.numHeld>0 then
		tools.giveToolsByReference({self.tool})
		self.isVisible = false
		self.gone = true
	end
end
P.supertoolQ1 = P.supertoolTile:new{name = "supertoolTileQ1", superQuality = 1}
P.supertoolQ2 = P.supertoolTile:new{name = "supertoolTileQ2", superQuality = 2}
P.supertoolQ3 = P.supertoolTile:new{name = "supertoolTileQ3", superQuality = 3}
P.supertoolQ4 = P.supertoolTile:new{name = "supertoolTileQ4", superQuality = 4}
P.supertoolQ5 = P.supertoolTile:new{name = "supertoolTileQ5", superQuality = 5}

P.toolTile = P.tile:new{name = "toolTile", tool = nil, dirSend = {0,0,0,0}}
function P.toolTile:onEnter()
	tools.giveToolsByReference({self.tool})
	self.isVisible = false
	self.gone = true
end
function P.toolTile:absoluteFinalUpdate()
	if self.tool==nil and not self.destroyed then
		local toolForTile = util.random(tools.numNormalTools, 'toolDrop')
		self.tool = tools[toolForTile]
		self:updateSprite()
	end
end
P.toolTile.updateSprite = P.supertoolTile.updateSprite

P.sawTile = P.toolTile:new{name = "sawTile", tool = tools.saw, sprite = tools.saw.image}
P.wireCuttersTile = P.toolTile:new{name = "wirecuttersTile", tool = tools.wireCutters, sprite = tools.wireCutters.image}
P.ladderTile = P.toolTile:new{name = "ladderTile", tool = tools.ladder, sprite = tools.ladder.image}
P.brickTile = P.toolTile:new{name = "brickTile", tool = tools.brick, sprite = tools.brick.image}
P.gunTile = P.toolTile:new{name = "gunTile", tool = tools.gun, sprite = tools.gun.image}
P.spongeTile = P.toolTile:new{name = "spongeTile", tool = tools.sponge, sprite = tools.sponge.image}
P.waterBottleTile = P.toolTile:new{name = "waterBottleTile", tool = tools.waterBottle, sprite = tools.waterBottle.image}


P.toolTaxTile = P.reinforcedGlass:new{name = "toolTaxTile", dirSend = {0,0,0,0}, sprite = love.graphics.newImage('Graphics/tooltaxtile.png'), tool = nil}
P.toolTaxTile.absoluteFinalUpdate = P.toolTile.absoluteFinalUpdate
function P.toolTaxTile:updateSprite()
	if self.tool == tools.wireCutters then
		self.overlay = P.wireCuttersTile
	elseif self.tool == tools.saw then
		self.overlay = P.sawTile
	elseif self.tool == tools.ladder then
		self.overlay = P.ladderTile
	elseif self.tool == tools.gun then
		self.overlay = P.gunTile
	elseif self.tool == tools.sponge then
		self.overlay = P.spongeTile
	elseif self.tool == tools.waterBottle then
		self.overlay = P.waterBottleTile
	elseif self.tool == tools.brick then
		self.overlay = P.brickTile
	end
end
function P.toolTaxTile:onEnter()
	if player.elevation>=self:getHeight()-3 then return end
	if not self.destroyed and self.tool.numHeld>0 then
		self.tool.numHeld = self.tool.numHeld-1
		self:destroy()
	elseif not self.destroyed then
		P.concreteWall:onEnter(player)
	end
end
function P.toolTaxTile:destroy()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
	self.overlay = nil
	self.tool = nil
end
function P.toolTaxTile:obstructsMovement()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return false
	elseif not self.destroyed and self.tool.numHeld>0 then
		return false
	end
	return true
end

P.dungeonEnter = P.tile:new{name = "dungeonEnter"}
function P.dungeonEnter:onEnter()
	player.regularMapLoc = {x = mapx, y = mapy}
	mapx = 1
	mapy = mapHeight+1
	room = mainMap[mapy][mapx].room
	roomHeight = room.height
	roomLength = room.length
	createAnimals()
	createPushables()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.dungeonExit) then
				player.tileY = i
				player.tileX = j
				break
			end
		end
	end
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.justTeleported = true
end
P.dungeonExit = P.tile:new{name = "dungeonExit"}
function P.dungeonExit:onEnter()
	mapx = player.regularMapLoc.x
	mapy = player.regularMapLoc.y
	room = mainMap[mapy][mapx].room
	roomHeight = room.height
	roomLength = room.length
	player.tileX = -1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.dungeonEnter) then
				player.tileY = i
				player.tileX = j
				break
			end
		end
	end

	if player.tileX==-1 then
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]~=nil and room[i][j]:instanceof(tiles.wall) and room[i][j].hidesDungeon then
					room[i][j]:destroy()
					player.tileY = i
					player.tileX = j
					break
				end
			end
		end
	end

	if player.tileX==-1 then
		local dirEnterInfo = map.getFieldForRoom(mainMap[mapy][mapx].roomid, "dirEnter")
		if dirEnterInfo[1]==1 then
			player.tileY = 1
			player.tileX = math.floor(roomLength/2)
		elseif dirEnterInfo[2]==1 then
			player.tileY = math.floor(roomHeight/2)
			player.tileX = roomLength
		elseif dirEnterInfo[3]==1 then
			player.tileY = roomHeight
			player.tileX = math.floor(roomLength/2)
		elseif dirEnterInfo[4]==1 then
			player.tileY = math.floor(roomHeight/2)
			player.tileX = 1
		end
	end

	createAnimals()
	createPushables()
	player.justTeleported = true
end

P.endDungeonEnter = P.tile:new{name = "endDungeonEnter", sprite = love.graphics.newImage('Graphics/eden.png'), disabled = false}
function P.endDungeonEnter:onLoad()
	local unlocks = require('scripts.unlocks')
	self.disabled = not unlocks.isDungeonUnlocked()
	self.isVisible = not self.disabled
end
function P.endDungeonEnter:onEnter()
	if self.disabled then
		return
	end
	player.returnFloorIndex = floorIndex
	goToFloor(1)
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.endDungeonExit) then
				player.tileY = i
				player.tileX = j
				break
			end
		end
	end
end

P.endDungeonExit = P.tile:new{name = "endDungeonExit", sprite = love.graphics.newImage('Graphics/edex.png')}
function P.endDungeonExit:onEnter()
	goToFloor(player.returnFloorIndex)
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.endDungeonEnter) then
				player.tileY = i
				player.tileX = j
				break
			end
		end
	end
end

P.key = P.tile:new{name = "key", sprite = love.graphics.newImage('Graphics/key.png')}
function P.key:onEnter()
	player.keysHeld = player.keysHeld+1
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.keyGate = P.reinforcedGlass:new{name = "keyTile", sprite = love.graphics.newImage('Graphics/keytile.png')}
function P.keyGate:onEnter()
	if player.keysHeld==3 then
		self:open()
	elseif not self.destroyed then
		P.reinforcedGlass:onEnter(player)
	end
end
function P.keyGate:obstructsMovement()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return false
	elseif player.keysHeld>=3 then
		return false
	else
		return true
	end
end
--nothing can destroy the keyGate (including missiles) because of below code
function P.keyGate:destroy()
end
function P.keyGate:open()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
	self.overlay = nil
end

P.gasPuddle = P.puddle:new{name = "gasPuddle", sprite = love.graphics.newImage('Graphics/gaspuddle.png')}
function P.gasPuddle:updateTile(dir)
	if self.charged then
		self.powered = true
		return
	end
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		self.powered = true
	else
		self.powered = false
	end

	if self.powered then
		self:destroy()
	end
end
function P.gasPuddle:onEnd(x, y)
	self:explode(x,y)
end
function P.gasPuddle:destroy()
	self.gone = true
end
function P.gasPuddle:explode(x,y)
	P.bomb:explode(x,y)
end

P.halfWall = P.concreteWall:new{name = "halfWall", sprite = love.graphics.newImage('GraphicsColor/halfwall.png'), yOffset = -3}

P.elevator = P.conductiveTile:new{name = "elevator", blocksVision = true, blocksAnimalMovement = true, yOffset = -3, sprite = love.graphics.newImage('GraphicsColor/elevatordown2.png'), poweredSprite = love.graphics.newImage('GraphicsColor/elevatorup.png')}
function P.elevator:postPowerUpdate()
	if self.powered then
		self.yOffset = -6
	else
		self.yOffset = 0
	end
end
P.elevator.onEnter = P.wall.onEnter
P.elevator.onLeave = P.wall.onLeave

P.elevatedButton = P.button:new{name = "elevatedButton", yOffset = -3, upSprite = love.graphics.newImage('Graphics/buttonupel.png'), downSprite = love.graphics.newImage('Graphics/buttondownel.png')}

P.delevator = P.elevator:new{name = "delevator", blocksAnimalMovement = true, yOffset = 0, sprite = love.graphics.newImage('GraphicsColor/delevatorup.png'), poweredSprite = love.graphics.newImage('GraphicsColor/delevatordown.png')}
function P.delevator:postPowerUpdate()
	if self.powered then self.yOffset = 0
	else self.yOffset = -3 end
end
function P.delevator:getHeight()
	if self.powered then
		return -6
	else
		return 3
	end
end

P.groundDown = P.tile:new{name = "groundDown", sprite = love.graphics.newImage('GraphicsColor/grounddown.png')}
function P.groundDown:getHeight()
	return -3
end

P.tallWall = P.concreteWall:new{name = "tallWall", sprite = love.graphics.newImage('GraphicsColor/tallwall.png'), yOffset = -9}

P.lemonade = P.puddle:new{name = "lemonade", canBePowered = false, sprite = love.graphics.newImage('Graphics/lemonade.png')}
function P.lemonade:willKillAnimal()
	return true
end

P.gameStairs = P.tile:new{name = "gameStairs", sprite = love.graphics.newImage('KenGraphics/gamestairs.png')}
function P.gameStairs:onEnter()
	startGame()
end

P.tutStairs = P.tile:new{name = "tutStairs", sprite = love.graphics.newImage('KenGraphics/tutstairs.png')}
function P.tutStairs:onEnter()
	startTutorial()
end

P.debugStairs = P.tile:new{name = "debugStairs", sprite = love.graphics.newImage('KenGraphics/tutstairs.png')}
function P.debugStairs:onEnter()
	startDebug()
end

P.unlockTile = P.tile:new{name = "unlockTile"}
function P.unlockTile:postPowerUpdate(i, j)
	local unlockNum = (i-1)*roomLength+j
	if unlocks[unlockNum]~=nil then
		self.sprite = unlocks[unlockNum].sprite
		if unlocks[unlockNum].unlocked then
			self.overlay = P.darkOverlay
		else
			self.overlay = nil
		end
	end
end

P.darkOverlay = P.tile:new{name = "darkOverlay", sprite = love.graphics.newImage('NewGraphics/unlocksDarken.png')}

P.playerTile = P.tile:new{name = "playerTransform", character = nil, text = "Herman", isVisible = false}
function P.playerTile:onLoad()
	if self.character==nil then
		local unlockedChars = characters.getUnlockedCharacters()
		for i = 1, #unlockedChars do
			if unlockedChars[i].name == self.text then
				self.character = unlockedChars[i]
			end
		end
		if self.character ~= nil then
			self.sprite = self.character.sprite
			self.isVisible = true
		end
	end
end
function P.playerTile:onEnter()
	if self.character ~= nil then
		player.character = self.character
		myShader:send("player_range", 500)
	end
end

P.tree = P.wall:new{name = "tree", sawable = false, level = 0, sprite = love.graphics.newImage('Graphics/tree0.png'),
spriteList = {love.graphics.newImage('Graphics/tree1.png'), love.graphics.newImage('Graphics/tree2.png'), love.graphics.newImage('Graphics/tree3.png')}}
function P.tree:updateSprite()
	if self.level==1 then
		self.sprite = self.spriteList[1]
	elseif self.level==2 then
		self.sprite = self.spriteList[2]
	elseif self.level==3 then
		self.sprite = self.spriteList[3]
	end
end
function P.tree:getHeight()
	if self.level==0 then
		return 0
	elseif self.level==1 then
		return 3
	elseif self.level==2 then
		return 6
	elseif self.level==3 then
		return 9
	end
end
function P.tree:getYOffset()
	if self.level==0 then
		return 0
	elseif self.level==1 then
		return -3
	elseif self.level==2 then
		return -6
	elseif self.level==3 then
		return -9
	end
end
function P.tree:destroy()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				room[i][j] = tiles.supertoolTile:new()
				room[i][j].tool = tools.seeds
			end
		end
	end
end

P.biscuit = P.tile:new{name = "biscuit", sprite = love.graphics.newImage('Graphics/biscuit.png')}
function P.biscuit:onEnter(player)
	player.biscuitHeld = true
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

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
tiles[40] = P.unbreakableCrossWire
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
tiles[54] = P.ambiguousAndGate
tiles[55] = P.ambiguousNotGate
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
tiles[82] = P.unbreakableWire
tiles[83] = P.unbreakableHorizontalWire
tiles[84] = P.unbreakableTWire
tiles[85] = P.unbreakableCornerWire
tiles[86] = P.accelerator
tiles[87] = P.bombBoxTile
tiles[88] = P.unpoweredAccelerator
tiles[89] = P.giftBoxTile
tiles[90] = P.jackInTheBoxTile
tiles[91] = P.finalToolsTile
tiles[92] = P.xorGate
tiles[93] = P.grass
tiles[94] = P.bed
tiles[95] = P.statuebottom
tiles[96] = P.statuetop
tiles[97] = P.chairfront
tiles[98] = P.chairback
tiles[99] = P.carpetmid
tiles[100] = P.carpetcorner
tiles[101] = P.carpetedge
tiles[102] = P.bookcase
tiles[103] = P.invisibleWire
tiles[104] = P.invisibleAndGate
tiles[105] = P.invisibleTWire
tiles[106] = P.invisibleNotGate
tiles[107] = P.invisiblePowerSupply
tiles[108] = P.invisibleConcreteWall
tiles[109] = P.invisibleWoodenWall
tiles[110] = P.invisiblePoweredFloor
tiles[111] = P.invisibleElectricFloor
tiles[112] = P.invisibleBoxTile
tiles[113] = P.invisibleDecoy
tiles[114] = P.unbreakableElectricFloor
tiles[115] = P.superStickyButton
tiles[116] = P.cornerRotater
tiles[117] = P.pinkFog
tiles[118] = P.endTilePaid
tiles[119] = P.mushroom
tiles[120] = P.unbrickableStayButton
tiles[121] = P.glueSnailTile
tiles[122] = P.bombBuddyTile
tiles[123] = P.conductiveDogTile
tiles[124] = P.untriggeredPowerSupplyTimer
tiles[125] = P.conductiveSpikes
tiles[126] = P.unbreakablePowerSupply
tiles[127] = P.hermanTransform
tiles[128] = P.felixTransform
tiles[129] = P.lennyTransform
tiles[130] = P.rammyTransform
tiles[131] = P.erikTransform
tiles[132] = P.fishTransform
tiles[133] = P.lampTile
tiles[134] = P.flickeringLamp
tiles[135] = P.redBeggar
tiles[136] = P.blueBeggar
tiles[137] = P.greenBeggar
tiles[138] = P.wifeTile
tiles[139] = P.sonTile
tiles[140] = P.daughterTile
tiles[141] = P.supertoolTile
tiles[142] = P.sawTile
tiles[143] = P.ladderTile
tiles[144] = P.wireCuttersTile
tiles[145] = P.waterBottleTile
tiles[146] = P.spongeTile
tiles[147] = P.brickTile
tiles[148] = P.gunTile
tiles[149] = P.toolTile
tiles[150] = P.toolTaxTile
tiles[151] = P.dungeonEnter
tiles[152] = P.dungeonExit
tiles[153] = P.upTunnel
tiles[154] = P.supertoolQ1
tiles[155] = P.supertoolQ2
tiles[156] = P.supertoolQ3
tiles[157] = P.supertoolQ4
tiles[158] = P.supertoolQ5
tiles[159] = P.endDungeonEnter
tiles[160] = P.endDungeonExit
tiles[161] = P.key
tiles[162] = P.keyGate
tiles[163] = P.gasPuddle
tiles[164] = P.halfWall
tiles[165] = P.elevator
tiles[166] = P.elevatedButton
tiles[167] = P.delevator
tiles[168] = P.groundDown
tiles[169] = P.tallWall
tiles[170] = P.gameStairs
tiles[171] = P.tutStairs
tiles[172] = P.unlockTile
tiles[173] = P.darkOverlay
tiles[174] = P.debugStairs
tiles[175] = P.playerTile
tiles[176] = P.lemonade
tiles[177] = P.rottenMeat
tiles[178] = P.tree
tiles[179] = P.biscuit
tiles[180] = P.entrancePortal2
tiles[181] = P.exitPortal2
tiles[182] = P.whiteBeggar
tiles[183] = P.blackBeggar
tiles[184] = P.goldBeggar

return tiles