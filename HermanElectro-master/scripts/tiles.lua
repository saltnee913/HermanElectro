require('scripts.object')
require('scripts.boundaries')
require('scripts.animals')
require('scripts.pushables')
bosses = require('scripts.bosses')
tools = require('scripts.tools')

local P = {}
tiles = P

P.tile = Object:new{yOffset = 0, canElevate = true, enterCheckWin = false, untoolable = false, blueHighlighted = false, attractsAnimals = false, scaresAnimals = false, formerPowered = nil, updatePowerOnEnter = false, text = "", updatePowerOnLeave = false, overlayable = false, overlaying = false, gone = false, lit = false, destroyed = false,
  blocksProjectiles = false, isVisible = true, rotation = 0, powered = false, blocksMovement = false, animationTimer = 0,
  blocksAnimalMovement = false, poweredNeighbors = {0,0,0,0}, blocksVision = false, dirSend = {1,1,1,1}, 
  dirAccept = {0,0,0,0}, canBePowered = false, name = "basicTile", allowsOverlayPickups = true, emitsLight = false, litWhenPowered = false, intensity = 0.5, range = 25,
  sprite = 'Graphics/cavesfloor.png', 
  wireHackOn = 'Graphics3D/wirehackon.png',
  wireHackOff = 'Graphics3D/wirehackoff.png'}
function P.tile:updateAnimation(dt)
	if self.animation ~= nil then
		self.animationTimer = self.animationTimer + dt
		if self.animationTimer > self.animationLength then self.animationTimer = self.animationTimer - self.animationLength end
		self.sprite = self.animation[math.ceil(#self.animation*self.animationTimer/self.animationLength)]
	end
end
function P.tile:lightTest(x,y)
	return false
end
function P.tile:onEnter(player) 
	--self.name = "fuckyou"
end
function P.tile:onEnterPushable(pushable)
	self:onEnter(pushable)
	if self.overlay~=nil then
		self.overlay:onEnterPushable(pushable)
	end
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
function P.tile:sticksPlayer()
	return false
end
function P.tile:pushableAttempt()
	return false
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
function P.tile:onBorderEnter()
end
function P.tile:onReachMid()
end

--guide to elevation:
--if can block movement, make blocksMovement true
--if can only block animal movement, make blocksAnimalMovement true
--obstructsMovement() is for ACTUALLY blocking player movement (in new elevation system)
--obstructsMovementAnimal() is for ACTUALLY blocking animal movement
--map has blocksMovementAnimal() function as well, isPreMove is true there
--pretty confusing, even I am a bit confused
function P.tile:obstructsMovementAnimal(animal, isPreMove)
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
	return false
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
	if self.overlay:instanceof(P.wire) or self.overlay:instanceof(P.andGate) then
		self.canBePowered = self.overlay.canBePowered
		self.dirSend = self.overlay.dirSend
		self.dirAccept = self.overlay.dirAccept
		self.powered = self.overlay.powered
	end
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
function P.tile:getEditorSprite()
	return self.sprite
end

P.invisibleTile = P.tile:new{isVisible = false, name = "invisibleTile"}
local bounds = {}

P.boundedTile = P.tile:new{boundary = boundaries.Boundary}

P.conductiveTile = P.tile:new{charged = false, powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "conductiveTile", sprite = 'Graphics/lightoff.png', poweredSprite = 'Graphics/lighton.png'}
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
  sprite = 'Graphics/Tiles/powerSupply.png', 
  destroyedSprite = 'Graphics/Tiles/powerSupplyDead.png', 
  poweredSprite = 'Graphics/Tiles/powerSupply.png'}
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
function P.powerSupply:usableOnNothing()
	return self.destroyed and not (tool~=nil and tool~=0 and tools[tool]:nothingIsSomething())
end

P.wire = P.conductiveTile:new{overlaying = true, powered = false, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}, canBePowered = true, name = "wire",
destroyedSprite = 'Graphics/Tiles/wireCut.png', 
sprite = 'Graphics/Tiles/wire.png',
poweredSprite = 'Graphics/Tiles/wirePowered.png'}
function P.wire:destroy()
	self.sprite = self.destroyedSprite
	self.powered = false
	self.canBePowered = false
	self.destroyed = true
	dirAccept = {0,0,0,0}
	dirSend = {0,0,0,0}
end
function P.wire:usableOnNothing()
	return self.destroyed and not (tool~=nil and tool~=0 and tools[tool]:nothingIsSomething())
end

P.maskedWire = P.wire:new{name = 'maskedWire', sprite = 'Graphics/maskedWire.png', poweredSprite = 'Graphics/maskedWire.png'}


P.crossWire = P.wire:new{dirSend = {0,0,0,0}, dirAccept = {1,1,1,1}, name = "crossWire", sprite = 'Graphics/crosswires.png', poweredSprite = 'Graphics/crosswires.png'}
function P.crossWire:updateTile(dir)
	self.powered = false
	self.dirSend = {0,0,0,0}
	if self.poweredNeighbors[self:cfr(2)]==1 or self.poweredNeighbors[self:cfr(4)]==1 then
		self.powered = true
		self.dirSend[self:cfr(2)]=1
		self.dirSend[self:cfr(4)]=1
	else
		self.dirSend[self:cfr(2)]=0
		self.dirSend[self:cfr(4)]=0		
	end
	if self.poweredNeighbors[self:cfr(1)]==1 or self.poweredNeighbors[self:cfr(3)]==1 then
		self.powered = true
		self.dirSend[self:cfr(1)]=1
		self.dirSend[self:cfr(3)]=1
	else
		self.dirSend[self:cfr(1)]=0
		self.dirSend[self:cfr(3)]=0		
	end
end

P.horizontalWire = P.wire:new{powered = false, dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, canBePowered = true, name = "horizontalWire",
sprite = 'Graphics/Tiles/horizontalWireUnpowered.png',
destroyedSprite = 'Graphics/Tiles/horizontalWireCut.png',
poweredSprite = 'Graphics/Tiles/horizontalWirePowered.png'}
P.verticalWire = P.wire:new{powered = false, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, canBePowered = true, name = "verticalWire", sprite = 'Graphics/verticalWireUnpowered.png', destroyedSprite = 'Graphics/verticalWireCut.png', poweredSprite = 'Graphics/verticalWirePowered.png'}
P.cornerWire = P.wire:new{dirSend = {0,1,1,0}, dirAccept = {0,1,1,0}, name = "cornerWire",
sprite = 'Graphics/Tiles/cornerWireUnpowered.png',
poweredSprite = 'Graphics/Tiles/cornerWirePowered.png',
destroyedSprite = 'Graphics/Tiles/cornerWireCut.png'}
function P.cornerWire.flipDirection(dir,isVertical)
	if dir == 1 or dir == 3 then
		if isVertical then return 1 else return -1 end
	else
		if isVertical then return (dir == 0 and 3 or -1) else return 1 end
	end
end

P.tWire = P.wire:new{dirSend = {0,1,1,1}, dirAccept = {0,1,1,1}, name = "tWire",
sprite = 'Graphics/Tiles/tWireUnpowered.png',
poweredSprite = 'Graphics/Tiles/tWirePowered.png',
destroyedSprite = 'Graphics/Tiles/tWireCut.png'}
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


P.unbreakableWire = P.wire:new{name = "unbreakableWire", litWhenPowered = false, sprite = 'Graphics/unbreakablewire.png', poweredSprite = 'Graphics/unbreakablewire.png', wireHackOff = 'Graphics3D/unbreakablewirehack.png', wireHackOn = 'Graphics3D/unbreakablewirehack.png'}
function P.unbreakableWire:destroy()
	self.sprite = self.destroyedSprite
	self.canBePowered = false
	self.destroyed = true
	dirAccept = {0,0,0,0}
	dirSend = {0,0,0,0}
	unlocks.unlockUnlockableRef(unlocks.unbreakableElectricFloorUnlock)
end
P.unbreakableHorizontalWire = P.unbreakableWire:new{name = "unbreakableHorizontalWire", dirSend = {0,1,0,1}, dirAccept = {0,1,0,1}, sprite = 'Graphics/unbreakablehorizontalwire.png', poweredSprite = 'Graphics/unbreakablehorizontalwire.png'}
P.unbreakableCornerWire = P.unbreakableWire:new{name = "unbreakableCornerWire", dirSend = {0,1,1,0}, dirAccept = {0,1,1,0}, sprite = 'Graphics/unbreakablecornerwire.png', poweredSprite = 'Graphics/unbreakablecornerwire.png'}
P.unbreakableCornerWire.flipDirection = P.cornerWire.flipDirection

P.unbreakableTWire = P.unbreakableWire:new{name = "unbreakableTWire", dirSend = {0,1,1,1}, dirAccept = {0,1,1,1}, sprite = 'Graphics/unbreakabletwire.png', poweredSprite = 'Graphics/unbreakabletwire.png'}
P.unbreakableTWire.flipDirection = P.tWire.flipDirection
P.unbreakableCrossWire = P.unbreakableWire:new{dirSend = {0,0,0,0}, dirAccept = {1,1,1,1}, name = "unbreakableCrossWire", sprite = 'Graphics/unbreakablecrosswires.png', poweredSprite = 'Graphics/unbreakablecrosswires.png'}
P.unbreakableCrossWire.updateTile = P.crossWire.updateTile
P.unbreakablePowerSupply = P.powerSupply:new{name = "unbreakablePowerSupply", sprite = 'Graphics/unbreakablepowersupply.png', poweredSprite = 'Graphics/unbreakablepowersupply.png'}

P.spikes = P.tile:new{powered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, canBePowered = true, name = "spikes", sprite = 'GraphicsTony/Spikes2.png'}
function P.spikes:willKillPlayer()
	return true
end
P.spikes.willKillAnimal = P.spikes.willKillPlayer

P.conductiveSpikes = P.spikes:new{name = "conductiveSpikes", sprite = 'Graphics/conductivespikes.png', poweredSprite = 'Graphics/conductivespikes.png', canBePowered = true, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}}

P.button = P.tile:new{bricked = false, meated = false, updatePowerOnEnter = true, justPressed = false, down = false, powered = false, dirSend = {1,1,1,1}, 
  dirAccept = {0,0,0,0}, canBePowered = true, name = "button", pressed = false, sprite = 'GraphicsColor/buttonoff.png', 
  poweredSprite = 'GraphicsEli/buttonOff2.png', downSprite = 'Graphics/buttonPressed.png', 
  brickedSprite = 'GraphicsEli/buttonBricked2.png', upSprite = 'Graphics/button.png'}
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
  downSprite = 'GraphicsEli/buttonOn.png',
  sprite = 'GraphicsEli/buttonOff.png', 
  upSprite = 'GraphicsEli/buttonOff.png', 
  brickedSprite = 'GraphicsEli/buttonBricked.png'}
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
  sprite = 'GraphicsEli/buttonOff3.png', 
  upSprite = 'GraphicsEli/buttonOff3.png', 
  downSprite = 'GraphicsEli/buttonOn3.png', 
  brickedSprite = 'GraphicsEli/buttonBricked3.png'}
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
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				self:checkDeadAnimalPresence(i,j)
			end
		end
	end
end
function P.stayButton:checkDeadAnimalPresence(i,j)
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
end
function P.stayButton:postPowerUpdate(i,j)
	if player.character.name == "Orson" and player.character.shifted then return end
	self.down = false
	self.dirAccept = {0,0,0,0}
	self.justPressed = false
	--updateGameState()
	self:updateSprite()
	self:checkDeadAnimalPresence(i,j)
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
sprite = 'Graphics/Tiles/electricFloor.png',
destroyedSprite = 'Graphics/Tiles/electricFloorCut.png',
poweredSprite = 'Graphics/Tiles/electricFloorPowered.png'}
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
function P.electricFloor:usableOnNothing()
	return self.destroyed
end

P.poweredFloor = P.conductiveTile:new{name = "poweredFloor", laddered = false, destroyedSprite = 'Graphics/trapdoorwithladder.png', destroyedPoweredSprite = 'Graphics/trapdoorclosedwithladder.png', --[[sprite = 'Graphics/trapdoor.png', poweredSprite = 'Graphics/trapdoorclosed.png']]
sprite = 'GraphicsBrush/trapdoor.png', poweredSprite = 'GraphicsBrush/trapdoorclosed.png'}
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
destroyedSprite = 'Graphics/Tiles/woodWallSawed.png', sprite = 'Graphics/Tiles/woodWall.png', sawable = true}
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
function P.wall:usableOnNothing()
	return self.destroyed and not (tool~=nil and tool~=0 and tools[tool]:nothingIsSomething())
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
	elseif player.attributes.superRammy then
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
	if player.attributes.lucky then
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]==self then
					room[i][j] = tiles.toolTile:new()
					room[i][j]:absoluteFinalUpdate()
				end
			end
		end
	end
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
destroyedSprite = 'Graphics/Tiles/metalWallSawed.png', sprite = 'Graphics/Tiles/metalWall.png', poweredSprite = 'Graphics/Tiles/metalWallPowered.png' }
P.metalWall.updateTile = P.conductiveTile.updateTile

P.maskedMetalWall = P.metalWall:new{name = "maskedMetalWall", sprite = 'Graphics/maskedMetalWall.png', poweredSprite = 'Graphics/maskedMetalWall.png'}

P.glassWall = P.wall:new{sawable = false, canBePowered = false, dirAccept = {0,0,0,0}, dirSend = {0,0,0,0}, bricked = false, name = "glasswall", blocksVision = false, electrifiedSprite = 'Graphics/glasswallelectrified.png', destroyedSprite = 'Graphics/glassbroken.png', sprite = 'GraphicsColor/glass.png', poweredSprite = 'Graphics3D/glass.png', electrifiedPoweredSprite = 'Graphics/glasswallpowered.png', sawable = false }

P.gate = P.conductiveTile:new{overlaying = true, name = "gate", dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, dirWireHack = {0,0,0,0}, gotten = {0,0,0,0}}
function P.gate:updateTile(dir)
	self.gotten[dir] = 1
end
function P.gate:correctForRotation(dir)
	local tempRot = dir + self.rotation
	while(tempRot > 4) do
		tempRot = tempRot - 4
	end
	--if temp ~= dir then print(temp..';'..dir) end
	return tempRot
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

P.splitGate = P.gate:new{name = "splitGate", dirSend = {1,0,0,0}, dirAccept = {1,0,0,0}, sprite = 'Graphics/splitgate.png', poweredSprite = 'Graphics/splitgate.png' }
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
sprite = 'Graphics/Tiles/notGateDead.png',
poweredSprite = 'Graphics/Tiles/notGate.png',
destroyedSprite = 'Graphics/Tiles/notGateDestroyed.png'}
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

P.ambiguousNotGate = P.notGate:new{name = "ambiguousNotGate", litWhenPowered = false, sprite = 'Graphics/notgateambiguous.png', poweredSprite = 'Graphics/notgateambiguous.png'}

P.andGate = P.gate:new{name = "andGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, dirWireHack = {1,0,0,0}, sprite = 'GraphicsColor/andgate2.png', poweredSprite = 'GraphicsColor/andgatepowered2.png', 
  off = 'GraphicsColor/andgate2.png',
  leftOn = 'GraphicsColor/andgateleft2.png', 
  rightOn = 'GraphicsColor/andgateright2.png' }
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

P.ambiguousAndGate = P.andGate:new{name = "ambiguousAndGate", litWhenPowered = false, sprite = 'Graphics/andgateambiguous.png'}
P.ambiguousAndGate.poweredSprite = P.ambiguousAndGate.sprite
P.ambiguousAndGate.off = P.ambiguousAndGate.sprite
P.ambiguousAndGate.leftOn = P.ambiguousAndGate.sprite
P.ambiguousAndGate.rightOn = P.ambiguousAndGate.sprite

P.orGate = P.gate:new{name = "orGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, dirWireHack = {1,0,0,0}, sprite = 'Graphics/orgate.png', poweredSprite = 'Graphics/orgate.png',
  leftOn = 'Graphics/orgateleft.png', 
  rightOn = 'Graphics/orgateright.png', 
  bothOn = 'Graphics/orgateon.png' }
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

P.xorGate = P.gate:new{name = "xorGate", dirSend = {1,0,0,0}, dirAccept = {0,1,0,1}, dirWireHack = {1,0,0,0}, sprite = 'Graphics/xorgate.png', poweredSprite = 'Graphics/xorgate.png'}
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

P.hDoor = P.tile:new{name = "hDoor", canElevate = false, stopped = false, blocksVision = true, blocksMovement = true, blocksProjectiles = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = 'Graphics/door.png', closedSprite = 'Graphics/door.png', openSprite = 'Graphics/doorsopen.png'}
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
	self.blocksProjectiles = false
end
function P.hDoor:pushableAttempt(pushable)
	if not self.blocksMovement then return true end

	self.sprite = self.openSprite
	self.blocksVision = false
	self.blocksMovement = false
	self.blocksProjectiles = false

	return true
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
	if math.abs(player.elevation)<=3 then return false
	else return true end
end
function P.hDoor:obstructsMovementAnimal()
	return self.blocksMovement
end

P.vDoor= P.tile:new{name = "hDoor", blocksVision = true, canBePowered = false, dirSend = {0,0,0,0}, dirAccept = {0,0,0,0}, sprite = 'Graphics/door.png', closedSprite = 'Graphics/door.png', openSprite = 'Graphics/doorsopen.png'}
function P.vDoor:onEnter(player)
	self.sprite = self.openSprite
	self.blocksVision = false
	
end

P.vPoweredDoor = P.tile:new{name = "vPoweredDoor", canElevate = false, stopped = false, yOffset = -6, blocksMovement = false, blocksVision = false, canBePowered = true, dirSend = {1,0,1,0}, dirAccept = {1,0,1,0}, sprite = 'Graphics3D/powereddooropen.png', closedSprite = 'GraphicsColor/powereddoor.png', openSprite = 'GraphicsColor/powereddooropen.png', poweredSprite = 'Graphics3D/powereddoor.png',
closedSprite2 = 'GraphicsColor/powereddoor2.png', openSprite2 = 'GraphicsColor/powereddooropen2.png'}
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
function P.vPoweredDoor:willKillPlayer()
	return self.blocksMovement and player.elevation<6
end
function P.vPoweredDoor:destroy()
	self.stopped = true
	self.open = true
	self:updateTile(player)
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
  sprite = 'Graphics/Tiles/endTile.png', done = false, enterCheckWin = true}
function P.endTile:onEnter(player)
	if map.floorInfo.finalFloor == true then
		--[[if roomHeight>12 and not editorMode then
			win()
			return
		end]]
	elseif validSpace() and mainMap[mapy][mapx].roomid == "final_2" then
		win()
		--unlocks.unlockUnlockableRef(unlocks.stickyButtonUnlock)
	end
	if self.done then return end

	local noDrops = false
	--if floorIndex==7 then noDrops = true end
	beatRoom(noDrops)
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.poweredEnd = P.endTile:new{name = "poweredEnd", canBePowered = true, dirAccept = {1,1,1,1},
sprite = 'Graphics/Tiles/poweredEndOff.png', poweredSprite = 'Graphics/Tiles/endTile.png'}
function P.poweredEnd:onEnter(player)
	if self.done or not self.powered then return end
	beatRoom()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

function P.poweredEnd:postPowerUpdate()
	if room[player.tileY][player.tileX] == self then
		self:onEnter(player)
	end
end

P.pitbullTile = P.tile:new{name = "pitbull", animal = animalList[2], sprite = 'Graphics/animalstartingtile.png', listIndex = 2, isVisible = false}
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
function P.pitbullTile:getEditorSprite()
	return self.animal.sprite
end
P.pupTile = P.pitbullTile:new{name = "pup", animal = animalList[3], listIndex = 3}
P.catTile = P.pitbullTile:new{name = "cat", animal = animalList[4], listIndex = 4}
P.ramTile = P.pitbullTile:new{name = "ram", animal = animalList[14], listIndex = 14}
P.twinPitbullTile = P.pitbullTile:new{name = "twinPitbull", animal = animalList[17], listIndex = 17}
P.testChargedBossTile = P.pitbullTile:new{name = "testChargedBoss", animal = animalList[18], listIndex = 18}
P.robotGuardTile = P.pitbullTile:new{name = "robotGuardTile", animal = animalList[22], listIndex = 22}
P.shopkeeperTile = P.pitbullTile:new{name = "shopkeeperTile", animal = animalList[23], listIndex = 23}
P.baseBossTile = P.pitbullTile:new{name = "baseBossTile", animal = animalList[24], listIndex = 24}

P.characterNPCTile = P.pitbullTile:new{name = "character", animal = animalList[25], listIndex = 25}
function P.characterNPCTile:onLoad()
	local charsToSelect = characters
	local charSlot = 0
	while (charSlot==0 or not charsToSelect[charSlot].randomOption) do
		charSlot = util.random(#charsToSelect-1, 'misc')
	end
	self.animal.name = charsToSelect[charSlot].name
	self.animal:updateNPC()
end

P.spotlightTile = P.tile:new{name = "spotlight", spotlight = spotlightList.spotlight,
baseTime = 3600, currTime = 0,
sprite = 'Graphics/spotlightTile.png'}
function P.spotlightTile:realtimeUpdate(dt, y, x)
	--[[if self.destroyed then return end
	self.currTime = self.currTime+dt*1000
	if self.currTime>self.baseTime then
		self.currTime = 0

		local thisTile = room[y][x]
		local spotlightToAdd = thisTile.spotlight:new()
		spotlightToAdd.x = tileToCoords(y,x).x
		spotlightToAdd.y = tileToCoords(y,x).y
		spotlightToAdd.dir = thisTile.rotation
		spotlights[#spotlights+1] = spotlightToAdd
	end]]
end

P.fastSpotlightTile = P.spotlightTile:new{name = "fastSpotlight", spotlight = spotlightList.fastSpotlight,
  baseTime = 1800, sprite = 'Graphics/fastSpotlightTile.png'}
P.slowSpotlightTile = P.spotlightTile:new{name = "slowSpotlight", spotlight = spotlightList.slowSpotlight, baseTime = 7200,
  sprite = 'Graphics/slowSpotlightTile.png'}

P.vDoor= P.hDoor:new{name = "vDoor", sprite = 'Graphics3D/door.png', closedSprite = 'Graphics/door.png', openSprite = 'Graphics/doorsopen.png'}
P.vDoor.onEnter = P.hDoor.onEnter

P.sign = P.tile:new{text = "", name = "sign", sprite = 'KenGraphics/sign.png'}
function P.sign:onEnter(player)
	messageInfo.text = self.text
end
function P.sign:onLeave()
	if room[player.tileY][player.tileX]==nil or room[player.tileY][player.tileX].text==nil then
		messageInfo.text = nil
	end
end

P.rotater = P.button:new{name = "rotater", canBePowered = true, dirAccept = {1,0,1,0}, dirSend = {1,0,1,0}, sprite = 'Graphics/rotater.png', poweredSprite = 'Graphics/rotater.png'}
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

P.cornerRotater = P.rotater:new{name = "cornerRotater", dirSend = {1,1,0,0}, dirAccept = {1,1,0,0}, poweredSprite = 'Graphics/cornerrotater.png', sprite = 'Graphics/cornerrotater.png'}
function P.cornerRotater.flipDirection(dir, isVertical)
	if dir == 0 or dir == 2 then
		return isVertical and 1 or (dir == 2 and -1 or 3)
	else
		return isVertical and -1 or 1
	end
	return 0
end

P.concreteWall = P.wall:new{sawable = false, name = "concreteWall",
sprite = 'GraphicsColor/concretewall3.png', destroyedSprite = 'Graphics/concretewallbroken.png', sawable = false}

P.concreteWallConductive = P.concreteWall:new{name = "concreteWallConductive", sprite = 'Graphics3D/concretewallconductive.png', poweredSprite = 'Graphics3D/concretewallconductive.png', canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.concreteWallConductiveDirected = P.concreteWallConductive:new{name = "concreteWallConductiveDirected", sprite = 'Graphics3D/concretewallconductivedirected0.png', poweredSprite = 'Graphics3D/concretewallconductivedirected0.png',
canBePowered = true, dirAccept = {1,0,1,0}, dirSend = {1,0,1,0}, sprite0 = 'Graphics3D/concretewallconductivedirected0.png', sprite1 = 'Graphics3D/concretewallconductivedirected1.png'}
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

P.concreteWallConductiveCorner = P.concreteWallConductive:new{name = "concreteWallConductiveCorner", sprite = 'Graphics3D/concretewallconductivecorner0.png', poweredSprite = 'Graphics/concretewallconductivecorner.png', canBePowered = true, dirAccept = {1,1,0,0}, dirSend = {1,1,0,0},
sprite0 = 'Graphics3D/concretewallconductivecorner0.png', sprite1 = 'Graphics3D/concretewallconductivecorner1.png', sprite2 = 'Graphics3D/concretewallconductivecorner2.png', sprite3 = 'Graphics3D/concretewallconductivecorner3.png'}
P.concreteWallConductiveCorner.rotate = P.concreteWallConductiveDirected.rotate
function P.concreteWallConductiveCorner:updateSprite()
	if self.destroyed then return end
	if self.rotation==0 then self.sprite = self.sprite0
	elseif self.rotation==1 then self.sprite = self.sprite1
	elseif self.rotation==2 then self.sprite = self.sprite2
	elseif self.rotation==3 then self.sprite = self.sprite3 end
	self.poweredSprite = self.sprite
end

P.concreteWallConductiveT = P.concreteWallConductive:new{name = "concreteWallConductiveT", sprite = 'Graphics3D/concretewallconductivet0.png', poweredSprite = 'Graphics/concretewallconductivet.png', canBePowered = true, dirAccept = {1,1,1,0}, dirSend = {1,1,1,0},
sprite0 = 'Graphics3D/concretewallconductivet0.png', sprite1 = 'Graphics3D/concretewallconductivet1.png', sprite2 = 'Graphics3D/concretewallconductivet2.png', sprite3 = 'Graphics3D/concretewallconductivet3.png'}
P.concreteWallConductiveT.rotate = P.concreteWallConductiveDirected.rotate
P.concreteWallConductiveT.updateSprite = P.concreteWallConductiveCorner.updateSprite

P.tunnel = P.tile:new{name = "tunnel", toolsNeeded = -1, toolsEntered = 0, sprite = 'KenGraphics/stairs.png'}
function P.tunnel:onEnter(player)
end
function P.tunnel:onReachMid()
	if floorIndex>=9 then
		return
		--should do something cool, can add later
	end
	if floorIndex<2 then
		return
	end
	--goDownFloor()
	--beginFloorSequence(0, "down")
	local animationProcess = processList.floorTransitionProcess:new()
	animationProcess.override = "down"
	processes[#processes+1] = animationProcess
end

P.upTunnel = P.tunnel:new{name = "upTunnel", sprite = 'KenGraphics/stairsUp.png'}
function P.upTunnel:onEnter(player)
end
function P.upTunnel:onReachMid()
	--goUpFloor()
	if floorIndex ~= 2 or not saving.isPlayingBack() then
		local animationProcess = processList.floorTransitionProcess:new()
		animationProcess.override = "up"
		processes[#processes+1] = animationProcess
	end
end
function P.upTunnel:onLeave(player)
	if floorIndex>7 then
		self.done = true
		self.isCompleted = true
		self.isVisible = false
		self.gone = true	
	end
end
--[[function P.tunnel:getInfoText()
	return self.toolsNeeded
end
function P.tunnel:postPowerUpdate()
	if toolMax==nil then toolMax = 0 end
	self.toolsNeeded = toolMax-self.toolsEntered
	if self.toolsNeeded<0 then self.toolsNeeded = 0 end
end]]

P.pit = P.tile:new{name = "pit", laddered = false, sprite = 'GraphicsBrush/pituncovered.png', destroyedSprite = 'Graphics/ladderedPit.png'}
function P.pit:ladder()
	self.sprite = self.destroyedSprite
	self.laddered = true
end
function P.pit:willKillPlayer()
	return not self.laddered
end
function P.pit:destroyPushable()
	self:ladder()
end
P.pit.willKillAnimal = P.pit.willKillPlayer
P.pit.willDestroyPushable = P.pit.willKillPlayer

P.breakablePit = P.pit:new{strength = 2, name = "breakablePit", sprite = 'GraphicsBrush/pitcovered.png', halfBrokenSprite = 'GraphicsBrush/pithalfcovered.png', brokenSprite = 'GraphicsBrush/pituncovered.png'}
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

P.treasureTile = P.tile:new{name = "treasureTile", sprite = 'Graphics/Tiles/treasureTile1.png',
  done = false}
function P.treasureTile:onEnter()
	if self.done then return end
	self:giveReward()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
	stats.incrementStat('treasureTilesReached')
	gameTime.timeLeft = gameTime.timeLeft+5
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

P.mousetrap = P.conductiveTile:new{name = "mousetrap", bricked = false, formerPowered = nil, triggered = false, safe = false, sprite = 'Graphics/mousetrap.png', safeSprite = 'Graphics/mousetrapsafe.png', deadlySprite = 'Graphics/mousetrap.png', brickedSprite = 'Graphics/mousetrapbricked.png'}
function P.mousetrap:onEnter()
	--make sure not box
	if room[player.tileY][player.tileX]==self then
		unlocks.unlockUnlockableRef(unlocks.trapUnlock)
	end

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
function P.mousetrap:destroy()
	--needs to be diff. from bricking the mosutrap later; for now, same
	self:lockInState(true)
end

P.bomb = P.tile:new{name = "bomb", triggered = true, counter = 3, sprite = 'Graphics/Tiles/bomb3.png', sprite2 = 'Graphics/Tiles/bomb2.png', sprite1 = 'Graphics/Tiles/bomb1.png'}
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
	--x is actually y-coord and y is actually x, kinda dumb but whatever
	if not editorMode and math.abs(player.tileY-x)<2 and math.abs(player.tileX-y)<2 then 
		kill()
	end
	util.createHarmfulExplosion(x,y)
end

P.capacitor = P.conductiveTile:new{name = "capacitor", counter = 3, maxCounter = 3, dirAccept = {1,0,1,0}, sprite = 'Graphics/capacitor.png', poweredSprite = 'Graphics/capacitor.png'}
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

P.inductor = P.conductiveTile:new{name = "inductor", counter = 3, maxCounter = 3, dirAccept = {1,0,1,0}, sprite = 'Graphics/inductor.png', poweredSprite = 'Graphics/inductor.png'}
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

P.slime = P.tile:new{name = "slime", sprite = 'Graphics/slime.png'}
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
sprite = 'Graphics/Tiles/bombUntriggered.png',
sprite3 = 'Graphics/Tiles/bomb3.png',
sprite2 = 'Graphics/Tiles/bomb2.png',
sprite1 = 'Graphics/Tiles/bomb1.png'}
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
function P.unactivatedBomb:updateSprite()
	if self.counter == 3 then
		self.sprite = self.sprite3
	elseif self.counter == 2 then
		self.sprite = self.sprite2
	elseif self.counter == 1 then
		self.sprite = self.sprite1
	end
end
function P.unactivatedBomb:onEnter(player)
	self.triggered = true
end
function P.unactivatedBomb:onEnterAnimal(animal)
	self.triggered = true
end

P.snailTile = P.pitbullTile:new{name = "snail", animal = animalList[5], listIndex = 5}

P.doghouse = P.pitbullTile:new{name = "doghouse", sprite = 'Graphics/doghouse.png'}
function P.doghouse:onStep(x, y)
	if player.tileX == y and player.tileY == x then return end
	for i = 1, #animals do
		if animals[i].tileY == x and animals[i].tileX == y then return end
	end
	local insertPitbullIndex = #animalCounter+1
	animals[insertPitbullIndex] = animalList.pitbull:new()
	animals[insertPitbullIndex].y = y*floor.sprite:getWidth()*scale+wallSprite.height
	animals[insertPitbullIndex].x = x*floor.sprite:getHeight()*scale+wallSprite.width
	animals[insertPitbullIndex].tileX = y
	animals[insertPitbullIndex].tileY = x
end

P.batTile = P.pitbullTile:new{name = "bat", animal = animalList[6], listIndex = 6}

P.meat = P.tile:new{name = "meat", sprite = 'Graphics/Tiles/meat.png', attractsAnimals = true}
P.rottenMeat = P.tile:new{name = "rottenMeat", sprite = 'Graphics/Tiles/rottenMeat.png', scaresAnimals = true}

P.explosiveMeat = P.tile:new{name = "explosiveMeat", sprite = 'Graphics/Tiles/explosiveMeat.png', attractsAnimal = true}
function P.explosiveMeat:onEnterAnimal()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self or (room[i][j]~=nil and room[i][j].overlay~=nil and room[i][j].overlay==self) then
				self:explode(i,j)
				room[i][j] = nil
			end
		end
	end
end
P.explosiveMeat.explode = P.bomb.explode

P.beggar = P.tile:new{name = "beggar", alive = true, counter = 0, sprite = 'GraphicsEli/whiteOrb1.png', deadSprite = 'Graphics/beggardead.png', 
  animation = {'GraphicsEli/whiteOrb1.png', 'GraphicsEli/whiteOrb2.png', 'GraphicsEli/whiteOrb3.png', 'GraphicsEli/whiteOrb4.png', 'GraphicsEli/whiteOrb3.png', 'GraphicsEli/whiteOrb2.png'}, animationLength = 1}
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
	if self.alive then
		stats.incrementStat("beggarsShot")
		self.animation = {self.sprite}
		self.alive = false
		local paysOut = util.random('toolDrop')
		if paysOut<0.5 and not player.character.name==characters.felix.name then return end
		self:providePayment()
	end
end
function P.beggar:providePayment()
	local paymentType = util.random('toolDrop')
	if paymentType<0.33 then P.redBeggar:providePayment()
	elseif paymentType<0.66 then P.blueBeggar:providePayment()
	else P.greenBeggar:providePayment() end
end
function P.beggar:onLoad()
	if not (self.name==tiles.beggar.name) then return end
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				local whichBeggar = util.random(3, 'misc')
				if whichBeggar==1 then
					room[i][j] = tiles.redBeggar:new()
				elseif whichBeggar==2 then
					room[i][j] = tiles.blueBeggar:new()
				else
					room[i][j] = tiles.greenBeggar:new()
				end
			end
		end
	end
end

P.redBeggar = P.beggar:new{name = "redBeggar", sprite = 'GraphicsEli/redOrb1.png', deadSprite = 'Graphics/redbeggardead.png', 
  animation = {'GraphicsEli/redOrb1.png', 'GraphicsEli/redOrb2.png', 'GraphicsEli/redOrb3.png', 'GraphicsEli/redOrb4.png', 'GraphicsEli/redOrb3.png', 'GraphicsEli/redOrb2.png'}, animationLength = 1}
function P.redBeggar:providePayment()
	local redTools = util.random('toolDrop')
	redTools = redTools+getLuckBonus()/100
	local ttg = 0
	if redTools<0.50 then ttg = 1
	elseif redTools<0.935 then ttg = 2
	elseif redTools<0.975 then ttg = 3 end
	
	if ttg>0 then
		tools.giveRandomTools(ttg)
		return
	end

	local superToGive = util.random(7, 'toolDrop')
	local superDrop = self:getSuperDrops()[superToGive]
	unlockedSupertools = unlocks.getUnlockedSupertools()
	if not unlockedSupertools[superToGive] or superDrop.isDisabled then
		tools.giveRandomTools(2)
		return
	end

	if util.getSupertoolTypesHeld()<player.character.superSlots or superDrop.numHeld>0 then
		tools.giveToolsByReference({superDrop})
	else
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]==self then
					room[i][j]=nil
					tools.dropTool(superDrop, i, j)
				end
			end
		end
	end
end
function P.redBeggar:getSuperDrops()
	return {tools.superSaw, tools.superLadder, tools.superWaterBottle, tools.superWireCutters, tools.superSponge,
	tools.superGun, tools.superBrick}
end

P.greenBeggar = P.beggar:new{name = "greenBeggar", sprite = 'GraphicsEli/greenOrb1.png', deadSprite = 'Graphics/greenbeggardead.png', 
  animation = {'GraphicsEli/greenOrb1.png', 'GraphicsEli/greenOrb2.png', 'GraphicsEli/greenOrb3.png', 'GraphicsEli/greenOrb4.png', 'GraphicsEli/greenOrb3.png', 'GraphicsEli/greenOrb2.png'}, animationLength = 1}
function P.greenBeggar:providePayment()
	local luckyCoin = util.random(100, 'toolDrop')
	local ttg = tools.coin
	if luckyCoin<=getLuckBonus() then
		ttg = tools.luckyPenny
	end

	unlockedSupertools = unlocks.getUnlockedSupertools()
	if not unlockedSupertools[tools.luckyPenny.toolid] or tools.luckyPenny.isDisabled then
		ttg = tools.coin
	end

	if util.getSupertoolTypesHeld()<player.character.superSlots or ttg.numHeld>0 then
		tools.giveToolsByReference({ttg})
		local giveAnother = util.random(2, 'toolDrop')-1
		if giveAnother>0 then
			tools.giveToolsByReference({ttg})
		end
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

	stats.incrementStat('greenBeggarsShot')
end

P.blueBeggar = P.beggar:new{name = "blueBeggar", sprite = 'GraphicsEli/blueOrb1.png', deadSprite = 'Graphics/bluebeggardead.png', 
  animation = {'GraphicsEli/blueOrb1.png', 'GraphicsEli/blueOrb2.png', 'GraphicsEli/blueOrb3.png', 'GraphicsEli/blueOrb4.png', 'GraphicsEli/blueOrb3.png', 'GraphicsEli/blueOrb2.png'}, animationLength = 1}
function P.blueBeggar:providePayment()
	local quality = util.random('toolDrop')
	quality = quality+getLuckBonus()/100
	if quality < 0.2 then
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

P.whiteBeggar = P.beggar:new{name = "whiteBeggar"}
function P.whiteBeggar:providePayment()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				room[i][j] = tiles.tunnel:new()
				unlocks.unlockUnlockableRef(unlocks.tunnelerUnlock)
				return
			end
		end
	end
end

P.blackBeggar = P.beggar:new{name = "blackBeggar"}
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

P.goldBeggar = P.beggar:new{name = "goldBeggar"}
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

P.ladder = P.tile:new{name = "ladder", sprite = 'Graphics/laddertile.png', blocksAnimalMovement = true}
function P.ladder:obstructsMovementAnimal(animal, isPreMove)
	if isPreMove then
		return self ~= room[animal.tileY][animal.tileX]
	else
		return self ~= room[animal.prevTileY][animal.prevTileX]
	end
end

P.mousetrapOff = P.mousetrap:new{name = "mousetrapOff", safe = true, sprite = 'Graphics/mousetrapsafe.png'}

P.donationMachine = P.tile:new{name = "donationMachine", sprite = 'Graphics/donationmachine.png'}
function P.donationMachine:getInfoText()
	return donations
end
function P.donationMachine:onEnter(player)
	if tool==0 then return end
	tools[tool].numHeld = tools[tool].numHeld - 1
	local mult = 1
	if tool > tools.numNormalTools then
		mult = 1
		--unlocks = require('scripts.unlocks')
		--unlocks.unlockUnlockableRef(unlocks.snailsUnlock)
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

P.entrancePortal = P.tile:new{name = "entrancePortal", sprite = 'Graphics/Tiles/entrancePortal.png', timesEntered = 0}
function P.entrancePortal:onEnter(player)
	self.timesEntered = self.timesEntered+1
	if self.timesEntered>=3 then
		unlocks.unlockUnlockableRef(unlocks.portalPlacerUnlock)
	end

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
					animal.prevTileX = animal.tileX
					animal.prevTileY = animal.tileY
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

P.exitPortal = P.tile:new{name = "exitPortal", sprite = 'Graphics/exitPortal.png'}

P.entrancePortal2 = P.entrancePortal:new{name = "entrancePortal2", sprite = 'Graphics/entranceportal2.png'}
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

P.exitPortal2 = P.tile:new{name = "exitPortal2", sprite = 'Graphics/exitportal2.png'}

P.treasureTile2 = P.treasureTile:new{name = "treasureTile2", sprite = 'Graphics/Tiles/treasureTile2.png'}

function P.treasureTile2:onEnter()
	if self.done then return end
	self:giveReward()
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
	gameTime.timeLeft = gameTime.timeLeft+5
end
function P.treasureTile2:giveReward()
	if player.character.giveTreasureRewardOverride ~= nil then
		player.character:giveTreasureRewardOverride(self)
		return
	end
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

P.treasureTile3 = P.treasureTile:new{name = "treasureTile3", sprite = 'Graphics/Tiles/treasureTile3.png'}

P.treasureTile4 = P.treasureTile:new{name = "treasureTile4", sprite = 'Graphics/Tiles/treasureTile4.png'}

P.conductiveSlime = P.conductiveTile:new{name = "conductiveSlime", sprite = 'Graphics/conductiveslime.png', poweredSprite = 'Graphics/conductiveslimepowered.png'}
--P.conductiveSlime.onEnter = P.slime.onEnter
--P.conductiveSlime.onEnterAnimal = P.slime.onEnterAnimal
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

P.untriggeredPowerSupply = P.conductiveTile:new{name = "untriggeredPowerSupply",
sprite = 'Graphics/Tiles/untriggeredPowerSupply.png'}
function P.untriggeredPowerSupply:postPowerUpdate(dir)
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]==self then
					room[i][j] = tiles.powerSupply:new()
				end
			end
		end
	end
end
function P.untriggeredPowerSupply:destroy()
	self.charged = false
	self.dirAccept = {0,0,0,0}
end

P.untriggeredPowerSupplyTimer = P.conductiveTile:new{name = "untriggeredPowerSupplyTimer", readyToTransform = false, dirSend = {0,0,0,0}, canBePowered = true, sprite = 'Graphics/untriggeredpowersupplytimer.png', poweredSprite = 'Graphics/powersupply.png'}
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

P.reinforcedGlass = P.concreteWall:new{name = "reinforcedGlass", cracked = false, blocksVision = false, sprite = 'Graphics3D/reinforcedglass.png', poweredSprite = 'Graphics3D/reinforcedglass.png'}

P.powerTriggeredBomb = P.unactivatedBomb:new{name = "powerTriggeredBomb", canBePowered = true, powered = false, dirAccept = {1,1,1,1}, dirSend = {0,0,0,0}}
function P.powerTriggeredBomb:absoluteFinalUpdate()
	if self.poweredNeighbors[1]==1 or self.poweredNeighbors[2]==1 or self.poweredNeighbors[3]==1 or self.poweredNeighbors[4]==1 then
		if not self.triggered then
			self.counter = 3
			self.triggered = true
			self:updateSprite()
		end
	end
	self.poweredSprite = self.sprite
end
function P.powerTriggeredBomb:onEnter(player)
end
P.powerTriggeredBomb.onEnterAnimal = P.powerTriggeredBomb.onEnter

P.boxTile = P.tile:new{name = "boxTile", pushable = pushableList[2], listIndex = 2,
sprite = 'Graphics/boxstartingtile.png', isVisible = false}
function P.boxTile:usableOnNothing()
	return true
end
function P.boxTile:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.pushable = o.pushable
	return o
end
function P.boxTile:getEditorSprite()
	return self.pushable.sprite
end

P.motionGate = P.conductiveTile:new{name = "gate", updatePowerOnLeave = true, dirSend = {0,0,0,0}, sprite = 'Graphics/gate.png', poweredSprite = 'Graphics/gate.png'}
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

P.puddle = P.conductiveTile:new{name = "puddle", frozen = false, sprite = 'Graphics/puddle.png',
poweredSprite = 'Graphics/puddlelectrified.png', frozenSprite = 'Graphics/puddlefrozen.png'}
function P.puddle:willKillPlayer()
	return not self.destroyed and self.powered
end
function P.puddle:destroy()
end
function P.puddle:freeze()
	self.canBePowered = false
	self.frozen = true
	self.sprite = self.frozenSprite
end
P.puddle.willKillAnimal = P.puddle.willKillPlayer

P.dustyGlassWall = P.glassWall:new{name = "dustyGlassWall", blocksVision = true, sprite = 'Graphics3D/dustyglass.png', cleanSprite = 'Graphics/glass.png'}

P.web = P.tile:new{name = "web", triggered = false, sprite = 'Graphics/trap.png', triggered = false}
function P.web:onEnter(player)
	if self.triggered and not self.destroyed then
		tools.giveRandomTools(1)
		self:destroy()
		self.isVisible = false
		for i = 1, #animals do
			if animals[i].tileY == player.tileY and animals[i].tileX == player.tileX then
				animals[i].pickedUp = true
			end
		end
	end
end
function P.web:onEnterAnimal(animal)
	if not self.triggered then
		animal:kill()
		self.triggered = true
	end
end

P.glue = P.tile:new{name = "glue", sprite = 'Graphics/glue.png'}
function P.glue:onEnter(player)
	if player.attributes.flying then return end
	--player.waitCounter = player.waitCounter+1
	if player.character.name == characters.lenny.name then
		--unlocks = require('scripts.unlocks')
		--unlocks.unlockUnlockableRef(unlocks.glueSnailUnlock)
	end
end
function P.glue:sticksPlayer()
	return true
end
function P.glue:onStay(player)
	--player.waitCounter = player.waitCounter+1
end
function P.glue:onEnterAnimal(animal)
	--[[if animal:instanceof(animalList.snail) then
		unlocks = require('scripts.unlocks')
		unlocks.unlockUnlockableRef(unlocks.glueSnailUnlock)
		return
	end]]
	if animal:instanceof(animalList.glueSnail) then return end
	if animal.flying then return end
	animal.waitCounter = animal.waitCounter+1
end
P.glue.onStayAnimal = P.glue.onEnterAnimal

P.conductiveBoxTile = P.boxTile:new{name = "conductiveBoxTile", pushable = pushableList[5], listIndex = 5}

P.boomboxTile = P.boxTile:new{name = "boomboxTile", pushable = pushableList[6], listIndex = 6}

P.batteringRamTile = P.boxTile:new{name = "batteringRamTile", pushable = pushableList[7], listIndex = 7}

P.lamp = P.powerSupply:new{name = "lamp", emitsLight = true, intensity = 0.7, range = 50, sprite = 'Graphics/lamp.png', poweredSprite = 'Graphics/lamp.png', lit = true, destroyedSprite = 'Graphics/destroyedlamp.png'}
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

P.conductiveGlass = P.glassWall:new{name = "conductiveGlass", sprite = 'Graphics3D/conductiveglass.png', poweredSprite = 'Graphics3D/conductiveglass.png', canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.reinforcedConductiveGlass = P.reinforcedGlass:new{name = "reinforcedConductiveGlass", sprite = 'Graphics3D/reinforcedconductiveglass.png', poweredSprite = 'Graphics3D/reinforcedconductiveglass.png', canBePowered = true, dirAccept = {1,1,1,1}, dirSend = {1,1,1,1}}

P.fog = P.tile:new{name = "fog", sprite = 'Graphics/fog.png', blocksVision = true}
function P.fog:obstructsVision()
	if not self.blocksVision then return false end
	return true
end
function P.fog:obstructsMovementAnimal(animal)
	if math.abs(animal.elevation)<=3 then
		return false
	else
		return true
	end
end
function P.fog:obstructsMovement()
	if math.abs(player.elevation)<=3 then
		return false
	else
		return true
	end
end

P.accelerator = P.conductiveTile:new{name = "accelerator", sprite = 'Graphics/accelerator.png', poweredSprite = 'Graphics/accelerator.png'}
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

P.unpoweredAccelerator = P.accelerator:new{name = "unpoweredaccelerator", canBePowered = false, sprite = 'Graphics/unpoweredaccelerator.png'}
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
function P.unpoweredAccelerator:onEnter(enterer)
	for i = 1, #pushables do
		if pushables[i].tileX==enterer.tileX and pushables[i].tileY==enterer.tileY then
			unlocks.unlockUnlockableRef(unlocks.poweredAccelUnlock)
		end
	end
end

P.bombBoxTile = P.boxTile:new{name = "bombBoxTile", pushable = pushableList[8], listIndex = 8}

P.giftBoxTile = P.boxTile:new{name = "giftBoxTile", pushable = pushableList[9], listIndex = 9}

P.jackInTheBoxTile = P.boxTile:new{name = "jackInTheBoxTile", pushable = pushableList[10], listIndex = 10}

P.finalToolsTile = P.tile:new{name = "finalToolsTile", canBePowered = false, dirAccept = {0,0,0,0}, sprite = 'Graphics/donationmachine.png', done = false, toolsToGive = {}, giveRate = 0.75, timeLeft = 0}
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

P.grass = P.tile:new{name = "grass", sprite = 'KenGraphics/grass.png'}
P.bed = P.concreteWall:new{name = "bed", sprite = 'KenGraphics/bed.png'}
P.statuebottom = P.tile:new{name = "statuebottom", sprite = 'KenGraphics/statuebottom.png'}
P.statuetop = P.tile:new{name = "statuetop", sprite = 'KenGraphics/statuetop.png'}
P.chairfront = P.tile:new{name = "chairfront", sprite = 'KenGraphics/chairfront.png'}
P.chairback = P.tile:new{name = "chairback", sprite = 'KenGraphics/chairback.png'}
P.carpetmid = P.tile:new{name = "carpetmid", sprite = 'KenGraphics/puregreen.png'}
P.carpetedge = P.tile:new{name = "carpetedge", sprite = 'KenGraphics/carpetedge.png'}
P.carpetcorner = P.tile:new{name = "carpetcorner", sprite = 'KenGraphics/carpetcorner.png'}
P.bookcase = P.tile:new{name = "bookcase", sprite = 'KenGraphics/bookcase.png'}
P.pooledge = P.tile:new{name = "pooledge", sprite = 'KenGraphics/pooledge.png'}
P.poolcorner = P.tile:new{name = "poolcorner", sprite = 'KenGraphics/poolcorner.png'}
P.poolcenter = P.tile:new{name = "poolcenter", sprite = 'KenGraphics/poolcenter.png'}

P.invisibleWire = P.wire:new{name = "invisibleWire", isVisible = false}
P.invisibleAndGate = P.wire:new{name = "invisibleAndGate", isVisible = false}
P.invisibleTWire = P.tWire:new{name = "invisibleTWire", isVisible = false}
P.invisibleNotGate = P.notGate:new{name = "invisibleNotGate", isVisible = false}
P.invisiblePowerSupply = P.powerSupply:new{name = "invisiblePowerSupply", isVisible = false}
P.invisibleConcreteWall = P.concreteWall:new{name = "invisibleConcreteWall", isVisible = false}
P.invisibleWoodenWall = P.wall:new{name = "invisibleWoodenWall", isVisible = false}
P.invisiblePoweredFloor = P.poweredFloor:new{name = "invisiblePoweredFloor", isVisible = false}
P.invisibleElectricFloor = P.electricFloor:new{name = "invisibleElectricFloor", isVisible = false}
P.invisibleBoxTile = P.tile:new{name = "invisibleBoxTile", pushable = pushableList[11], listIndex = 11}
P.invisibleDecoy = P.tile:new{name = "invisibleDecoy", isVisible = false}

P.superStickyButton = P.stickyButton:new{name = "superStickyButton", sprite = 'Graphics/superStickyButton.png', upSprite = 'Graphics/superStickyButton.png'}
P.unbreakableElectricFloor = P.electricFloor:new{name = "unbreakableElectricFloor", litWhenPowered = false, sprite = 'Graphics/unbreakableElectricFloor.png', poweredSprite = 'Graphics/unbreakableElectricFloor.png'}
P.unbrickableStayButton = P.stayButton:new{name = "unbrickableStayButton", sprite = 'Graphics/unbrickableStayButton.png', upSprite = 'Graphics/unbrickableStayButton.png'}

P.pinkFog = P.fog:new{name = "pinkFog", sprite = 'Graphics/pinkfog.png'}

P.endTilePaid = P.tunnel:new{name = "endTilePaid", setTools = false, toolsNeededTotal = 0, sprite = 'Graphics/endtilepaid.png'}
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

P.mushroom = P.tile:new{name = "mushroom", sprite = 'KenGraphics/mushroom.png'}
function P.mushroom:onEnter()
	if not mushroomMode then
		turnOnMushroomMode()
	end
	local isHeaven = map.getFieldForRoom(mainMap[mapy][mapx].roomid, "heaven")
	if isHeaven~=nil and isHeaven then
		unlocks.unlockUnlockableRef(unlocks.gabeUnlock)
	end

	if floorIndex == -1 then
		unlocks.unlockUnlockableRef(unlocks.dragonUnlock, true)
	end
end

P.lampTile = P.boxTile:new{name = "lampTile", pushable = pushableList[12], listIndex = 12}

P.hermanTransform = P.tile:new{name = "hermanTransform", characterIndex = 1}
function P.hermanTransform:onEnter()
	player.character = characters[self.characterIndex]
	player.character:onSelect()
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
function P.supertoolTile:onLoad()
	if self.tool==nil then
		for i = 1, #tools do
			if tools[i].name == self.text then
				self.tool = tools[i]
				break
			end
		end
		if self.tool ~= nil then
			self:updateSprite()
		else
			self:selectTool()
		end
	end
end
function P.supertoolTile:absoluteFinalUpdate()
	if self.tool==nil then
		self:selectTool()
	end
end
function P.supertoolTile:selectTool()
	self.tool = tools[tools.chooseSupertool(self.superQuality)]
	self:updateSprite()
end
function P.supertoolTile:updateSprite()
	if self.tool~=nil then
		self.sprite = self.tool:getTileImage()
		self.poweredSprite = self.sprite
	end
end
function P.supertoolTile:onEnter(entered)
	if not (player.tileX==entered.tileX and player.tileY==entered.tileY) then return end
	local stTypesHeld = util.getSupertoolTypesHeld()
	if stTypesHeld<player.character.superSlots or self.tool.numHeld>0 then
		tools.giveToolsByReference({self.tool})
		if self.tool==tools.axe then
			unlocks.unlockUnlockableRef(unlocks.pickaxeUnlock)
		end
		self.isVisible = false
		self.gone = true
	end
end
function P.supertoolTile:getInfoText()
	if self.tool~=nil then
		return self.tool.name
	else return nil end
end
P.supertoolQ1 = P.supertoolTile:new{name = "supertoolTileQ1", superQuality = 1}
P.supertoolQ2 = P.supertoolTile:new{name = "supertoolTileQ2", superQuality = 2}
P.supertoolQ3 = P.supertoolTile:new{name = "supertoolTileQ3", superQuality = 3}
P.supertoolQ4 = P.supertoolTile:new{name = "supertoolTileQ4", superQuality = 4}
P.supertoolQ5 = P.supertoolTile:new{name = "supertoolTileQ5", superQuality = 5}
P.supertoolQInf = P.supertoolTile:new{name = "supertoolTileQInf", superQuality = -1}

P.dungeonSuper = P.supertoolTile:new{name = "dungeonSuper"}
function P.dungeonSuper:selectTool()
	local toolOptions = {tools.tunneler, tools.roomUnlocker, tools.map}
	self.tool = toolOptions[util.random(#toolOptions, 'toolDrop')]
	self:updateSprite()
end

P.toolTile = P.tile:new{name = "toolTile", tool = nil, toolId = -1, dirSend = {0,0,0,0}}
function P.toolTile:onEnter(entered)
	if not (player.tileX==entered.tileX and player.tileY==entered.tileY) then return end
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
function P.toolTile:onLoad()
	if self.tool == nil then
		if self.toolId == -1 then
			self:randomize()
		end
		self.tool = tools[self.toolId]
	end
end
function P.toolTile:randomize()
	local whichBasic = util.random(tools.numNormalTools, 'toolDrop')
	self.toolId = whichBasic
	self.tool = tools[self.toolId]
end
P.toolTile.updateSprite = P.supertoolTile.updateSprite

P.sawTile = P.toolTile:new{name = "sawTile", toolId = 1, sprite = tools.saw.image}
P.wireCuttersTile = P.toolTile:new{name = "wirecuttersTile", toolId = 3, sprite = tools.wireCutters.image}
P.ladderTile = P.toolTile:new{name = "ladderTile", toolId = 2, sprite = tools.ladder.image}
P.brickTile = P.toolTile:new{name = "brickTile", toolId = 6, sprite = tools.brick.image}
P.gunTile = P.toolTile:new{name = "gunTile", toolId = 7, sprite = tools.gun.image}
P.spongeTile = P.toolTile:new{name = "spongeTile", toolId = 5, sprite = tools.sponge.image}
P.waterBottleTile = P.toolTile:new{name = "waterBottleTile", toolId = 4, sprite = tools.waterBottle.image}


P.toolTaxTile = P.reinforcedGlass:new{name = "toolTaxTile", allowsOverlayPickups = false, dirSend = {0,0,0,0}, sprite = 'Graphics/tooltaxtile.png', tool = nil}
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
	elseif self.tool~=nil then
		local overlayTool = tiles.supertoolTile:new()
		overlayTool.tool = self.tool
		overlayTool:updateSprite()
		self.overlay = overlayTool
	end
end
function P.toolTaxTile:onEnter()
	if player.elevation>=self:getHeight()-3 then return end
	if (not self.destroyed) and self:canBeDestroyed() then
		if self.tool.numHeld>0 then self.tool.numHeld = self.tool.numHeld-1
		elseif tools.coin.numHeld>0 then tools.coin:useToolTile(self)
		elseif tools.luckyPenny.numHeld>0 then tools.luckyPenny:useToolTile(self) end
		self:destroy()
	elseif not self.destroyed then
		P.concreteWall:onEnter(player)
	end
end
function P.toolTaxTile:canBeDestroyed()
	if self.tool.numHeld>0 then return true
	elseif tools.coin.numHeld>0 then return true
	elseif tools.luckyPenny.numHeld>0 then return true end
	return false
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
	elseif (not self.destroyed) and self:canBeDestroyed() then
		return false
	end
	return true
end
function P.toolTaxTile:onLoad()
	if self.tool == nil then
		self:randomize()
		self:updateSprite()
	end
end
function P.toolTaxTile:randomize()
	if player.character.name~="Dragon" then
		local whichBasic = util.random(tools.numNormalTools, 'toolDrop')
		self.toolId = whichBasic
		self.tool = tools[self.toolId]
	else
		local whichBasic = util.random(2, 'toolDrop')
		if whichBasic==1 then
			self.tool = tools.claw
		else
			self.tool = tools.fireBreath
		end
	end
end

P.dungeonEnter = P.tile:new{name = "dungeonEnter"}
function P.dungeonEnter:onEnter()
	--unlocks.unlockUnlockableRef(unlocks.rammyUnlock, true)
	player.regularMapLoc = {x = mapx, y = mapy}
	mapx = 1
	mapy = mapHeight+1
	room = mainMap[mapy][mapx].room
	resetPlayerAttributesRoom()
	roomHeight = room.height
	roomLength = room.length
	createElements()
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
	onTeleport()
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

	createElements()
	onTeleport()
end

P.heavenEnter = P.tile:new{name = "heavenEnter", text = "You need flight to access this area."}
function P.heavenEnter:onEnter()
	if not player.attributes.flying and player.character.name~="Dragon" then
		messageInfo.text = self.text
		return
	end
	--unlocks.unlockUnlockableRef(unlocks.rammyUnlock, true)
	player.nonHeavenMapLoc = {x = mapx, y = mapy}
	mapx = mapHeight+1
	mapy = mapHeight+1
	room = mainMap[mapy][mapx].room
	roomHeight = room.height
	roomLength = room.length
	createElements()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.heavenExit) then
				player.tileY = i
				player.tileX = j
				break
			end
		end
	end
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	onTeleport()
end
function P.heavenEnter:onLeave()
	if room[player.tileY][player.tileX]==nil or room[player.tileY][player.tileX].text==nil then
		messageInfo.text = nil
	end
end

P.heavenExit = P.tile:new{name = "heavenEnter"}
function P.heavenExit:onEnter()
	mapx = player.nonHeavenMapLoc.x
	mapy = player.nonHeavenMapLoc.y
	room = mainMap[mapy][mapx].room
	roomHeight = room.height
	roomLength = room.length
	player.tileX = -1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.heavenEnter) then
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

	createElements()
	onTeleport()
end

P.endDungeonEnter = P.tile:new{name = "endDungeonEnter", sprite = 'KenGraphics/bed.png', disabled = false, yOffset = -6,
blocksMovement = false}
function P.endDungeonEnter:onLoad()
	local unlocks = require('scripts.unlocks')
	self.disabled = not unlocks.isDungeonUnlocked()
	self.isVisible = not self.disabled
	self.untoolable = self.disabled
end
function P.endDungeonEnter:onEnter()
	if self.disabled then
		return
	end
	local fiReturn = floorIndex
	player.returnFloorInfo = {floorIndex = fiReturn, tileY = player.tileY, tileX = player.tileX}
	goToFloor(1)
	resetPlayerAttributesRoom()
	if stairsLocs[#stairsLocs].coords.x~=0 then
		mapx = stairsLocs[#stairsLocs].map.x
		mapy = stairsLocs[#stairsLocs].map.y
		room = mainMap[mapy][mapx].room
		roomHeight = room.height
		roomLength = room.length
		player.tileX = stairsLocs[#stairsLocs].coords.x
		player.tileY = stairsLocs[#stairsLocs].coords.y
	else
		roomHeight = room.height
		roomLength = room.length
		
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
	onTeleport()
end
function P.endDungeonEnter:getHeight()
	return 0
end

P.endDungeonExit = P.tile:new{name = "endDungeonExit", sprite = 'KenGraphics/bed.png', yOffset = -6, blocksMovement = false}
function P.endDungeonExit:onEnter()
	local futureStairsLocsCoords = {x = player.tileX, y = player.tileY}

	--NEED THESE LINES FIRST -- otherwise goToFloor may try to updateGameState on invalid tile,
	--if big room in dungeon
	player.tileY = player.returnFloorInfo.tileY
	player.prevTileY = player.tileY
	player.tileX = player.returnFloorInfo.tileX
	player.prevTileX = player.tileX

	goToFloor(player.returnFloorInfo.floorIndex)

	stairsLocs[#stairsLocs].coords = futureStairsLocsCoords

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.endDungeonEnter) then
				player.tileY = i
				player.tileX = j
				break
			end
		end
	end
	onTeleport()
end
function P.endDungeonExit:getHeight()
	return 0
end


P.dungeonKey = P.tile:new{name = "dungeonKey", sprite = 'Graphics/key.png', enterCheckWin = true}
function P.dungeonKey:onEnter()
	player.dungeonKeysHeld = player.dungeonKeysHeld+1
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.finalKey = P.tile:new{name = "finalKey", sprite = 'Graphics/finalkey.png', enterCheckWin = true}
function P.finalKey:onEnter(player)
	player.finalKeysHeld = player.finalKeysHeld+1
	spotlights = {}
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.finalKeyPowered = P.finalKey:new{name = "finalKeyPowered", poweredSprite = 'Graphics/finalkey.png',
sprite = 'Graphics/keyunpowered.png',
canBePowered = true, dirSend = {1,1,1,1}, dirAccept = {1,1,1,1}}
function P.finalKeyPowered:onEnter()
	if not self.powered then return end
	player.finalKeysHeld = player.finalKeysHeld+1
	spotlights = {}
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.gameWin = P.tile:new{name = "gameWin", sprite = 'Graphics/blue.png'}
function P.gameWin:onEnter()	
	win()
end

P.dungeonKeyGate = P.reinforcedGlass:new{name = "keyTile", sprite = 'Graphics/keytile.png', untoolable = true}
function P.dungeonKeyGate:onEnter()
	if player.dungeonKeysHeld>=3 then
		self:open()
	elseif not self.destroyed then
		P.reinforcedGlass:onEnter(player)
	end
end
function P.dungeonKeyGate:obstructsMovement()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return false
	elseif player.dungeonKeysHeld>=3 then
		return false
	else
		return true
	end
end
--nothing can destroy the keyGate (including missiles) because of below code
function P.dungeonKeyGate:destroy()
end
function P.dungeonKeyGate:open()
	self.blocksProjectiles = false
	self.blocksVision = false
	self.sprite = self.destroyedSprite
	self.destroyed = true
	self.blocksMovement = false
	self.dirAccept = {0,0,0,0}
	self.dirSend = {0,0,0,0}
	self.overlay = nil
end

P.finalKeyGate = P.dungeonKeyGate:new{name = "finalKeyGate"}
function P.finalKeyGate:onEnter()
	if player.finalKeysHeld>=20 then
		self:open()
	elseif not self.destroyed then
		P.reinforcedGlass:onEnter(player)
	end
end
function P.finalKeyGate:obstructsMovement()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return false
	elseif player.finalKeysHeld>=3 then
		return false
	else
		return true
	end
end

P.gasPuddle = P.puddle:new{name = "gasPuddle", sprite = 'Graphics/gaspuddle.png'}
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
	if not self.gone then
		self.gone = true
		self:explode(x,y)
	end
end
function P.gasPuddle:destroy()
	if not self.gone then
		self.gone = true
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]==self then
					self:explode(i,j)
				end
			end
		end
	end
end
function P.gasPuddle:explode(x,y)
	P.bomb:explode(x,y)
end

P.halfWall = P.concreteWall:new{name = "halfWall", sprite = 'GraphicsColor/halfwall.png', yOffset = -3}

P.elevator = P.conductiveTile:new{name = "elevator", blocksVision = true, blocksAnimalMovement = true, yOffset = -3, sprite = 'GraphicsColor/elevatordown2.png', poweredSprite = 'GraphicsColor/elevatorup.png'}
function P.elevator:postPowerUpdate()
	if self.powered then
		self.yOffset = -6
	else
		self.yOffset = 0
	end
end
function P.elevator:getHeight()
	if self.powered then return 6
	else return 0 end
end
P.elevator.onEnter = P.wall.onEnter
P.elevator.onLeave = P.wall.onLeave

P.elevatedButton = P.button:new{name = "elevatedButton", yOffset = -3, upSprite = 'Graphics/buttonupel.png', downSprite = 'Graphics/buttondownel.png'}

P.delevator = P.elevator:new{name = "delevator", blocksAnimalMovement = true, yOffset = 0, sprite = 'GraphicsColor/delevatorup.png', poweredSprite = 'GraphicsColor/delevatordown.png'}
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

P.groundDown = P.tile:new{name = "groundDown", sprite = 'GraphicsColor/grounddown.png'}
function P.groundDown:getHeight()
	return -3
end

P.tallWall = P.concreteWall:new{name = "tallWall", sprite = 'GraphicsColor/tallwall.png', yOffset = -9}

P.lemonade = P.puddle:new{name = "lemonade", canBePowered = false, sprite = 'Graphics/lemonade.png'}
function P.lemonade:willKillAnimal()
	return true
end

P.gameStairs = P.tile:new{name = "gameStairs", sprite = 'KenGraphics/gamestairs.png'}
function P.gameStairs:onReachMid()
	stairsLocs[1] = {map ={x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
	local animationProcess = processList.gameTransitionProcess:new()
	animationProcess.gameType = "main"
	processes[#processes+1] = animationProcess
end

P.dailyStairs = P.tile:new{name = "dailyStairs", sprite = 'KenGraphics/gamestairs.png'}
function P.dailyStairs:onReachMid()
	stairsLocs[1] = {map ={x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
	local animationProcess = processList.gameTransitionProcess:new()
	animationProcess.gameType = "daily"
	processes[#processes+1] = animationProcess
end

P.tutStairs = P.tile:new{name = "tutStairs", sprite = 'KenGraphics/tutstairs.png'}
function P.tutStairs:onEnter()
	stairsLocs[1] = {map ={x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
	beginGameSequence("tut")
end

P.debugStairs = P.tile:new{name = "debugStairs", sprite = 'KenGraphics/tutstairs.png'}
function P.debugStairs:onLoad()
	self.isVisible = not releaseBuild
end
function P.debugStairs:onReachMid()
	if self.isVisible then
		stairsLocs[1] = {map ={x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
		local animationProcess = processList.gameTransitionProcess:new()
		animationProcess.gameType = "debug"
		processes[#processes+1] = animationProcess
	end
end

P.editorStairs = P.tile:new{name = "editorStairs", sprite = 'KenGraphics/greenstairs.png'}
function P.editorStairs:onEnter()
	stairsLocs[1] = {map ={x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
	local animationProcess = processList.gameTransitionProcess:new()
	animationProcess.gameType = "editor"
	processes[#processes+1] = animationProcess
end

P.saveStairs = P.tile:new{name = "saveStairs", sprite = 'KenGraphics/gamestairs.png', recording = nil}
function P.saveStairs:onLoad()
	self.recording = saving.getSave()
	if self.recording == nil or self.recording.isDead then
		self.isVisible = false
	end
end
function P.saveStairs:onEnter()
	if self.isVisible then
		saving.playRecordingFast(self.recording)
	end
end

P.playbackStairs = P.tile:new{name = "playbackStairs", sprite = 'KenGraphics/gamestairs.png', recording = nil}
function P.playbackStairs:onLoad()
	self.recording = saving.getLatestReplay()
	if self.recording == nil then
		self.isVisible = false
	end
end
function P.playbackStairs:onEnter()
	if self.isVisible then
		saving.playBackRecording(self.recording)
	end
end

P.replayViewer = P.playbackStairs:new{name = "replayStairs"}
function P.replayViewer:onLoad()
	self.recording = saving.getImportedReplay()
	if self.recording == nil then
		self.isVisible = false
	end
end

P.unlockTile = P.tile:new{name = "unlockTile"}
function P.unlockTile:postPowerUpdate(i, j)
	local unlockNum = (i-1)*roomLength+j
	if unlocks[unlockNum]~=nil then
		self.sprite = unlocks[unlockNum].sprite
		if not unlocks[unlockNum].unlocked then
			self.overlay = P.darkOverlay
		else
			self.overlay = nil
		end
	end
end

P.darkOverlay = P.tile:new{name = "darkOverlay", sprite = 'NewGraphics/unlocksDarken.png'}

P.playerTile = P.tile:new{name = "playerTransform", character = nil, text = "Herman", isVisible = false}
function P.playerTile:onLoad()
	if self.character==nil then
		self.character = characters.getUnlockedCharacter(self.text)
		self:updateSprite()
	end
end
function P.playerTile:updateSprite()
	if self.character ~= nil then
		self.sprite = self.character.sprite
		self.isVisible = true
	end
end
function P.playerTile:onEnter(entered)
end
function P.playerTile:onLeave(player)
	messageInfo.text = nil
end
function P.playerTile:getCharInfo()
	if self.character==nil then return end
	local infoText = ""
	infoText = infoText..self.character.name..", "..self.character.description.."\n"
	infoText = infoText..self.character.crime.."\n\n"
	infoText = infoText.."Escapes: "..stats.getStat(self.character.name..'Wins').."\n"
	infoText = infoText.."Failures: "..stats.getStat(self.character.name..'Losses')
	return infoText
end
function P.playerTile:getYOffset()
	return -1*tileUnit/2
end
function P.playerTile:onReachMid()
	if self.character ~= nil then
		player.character = self.character
		player.character:onSelect()
		myShader:send("player_range", 500)
	end
	messageInfo.text = self:getCharInfo()
end

P.creditsChar = P.tile:new{name = "creditsChar", isVisible = false}
function P.creditsChar:onLoad()
	if self.text~=nil and self.dev==nil then
		self:updateSprite()
	end
end
function P.creditsChar:getDev(name)
	if name=="Ben" then
		return 'Graphics/Characters/Ben.png'
	elseif name=="Erik" then
		return 'Graphics/Characters/Erik.png'
	elseif name=="Tony" then
		return 'Graphics/Characters/Tony.png'
	elseif name=="Zach" then
		return 'Graphics/Characters/Zach.png'
	elseif name=="Eli" then
		return 'Graphics/Characters/Eli.png'
	end
end
function P.creditsChar:updateSprite()
	self.sprite = self:getDev(self.text)
	self.isVisible = true
end
function P.creditsChar:getYOffset()
	return -1*tileUnit/2
end

P.creditsBase = P.tile:new{name = "creditsBase", isVisible = false, sprite = 'Graphics/edex.png'}
function P.creditsBase:onLoad()
	if self.text~=nil then
		self:updateSprite()
	end
end
function P.creditsBase:updateSprite()
	self.isVisible = true
	local charOverlay = tiles.creditsChar:new()
	charOverlay.text = self.text
	charOverlay:updateSprite()
	self.overlay = charOverlay
end
function P.creditsBase:onLeave(player)
	messageInfo.text = nil
end
function P.creditsBase:getDevInfo()
	local infoText = ""
	infoText = infoText..self.text..", "..self:getDescription(self.text).."\n"
	infoText = infoText..self:getJob(self.text).."\n\n"
	return infoText
end
function P.creditsBase:getDescription(name)
	if name=="Ben" then return "The Sexy"
	elseif name=="Erik" then return "The Fashionable"
	elseif name=="Eli" then return "The Obese"
	elseif name=="Tony" then return "The Lazy"
	elseif name=="Zach" then return "The Git"
	end
end
function P.creditsBase:getJob(name)
	if name=="Ben" then return "Lead Designer, Developer and Warden"
	elseif name=="Erik" then return "Content Designer and Chef"
	elseif name=="Zach" then return "Online Content Manager and Chief Jester/Magician"
	elseif name=="Tony" then return "Art Director and Janitor"
	elseif name=="Eli" then return "Programmer and Correctional Officer"
	end
end
function P.creditsBase:onReachMid()
	messageInfo.text = self:getDevInfo()
end


P.charTile = P.tile:new{name = "charTile", sprite = 'Graphics/edex.png', character = nil}
function P.charTile:onLoad()
	if self.character==nil then
		self.character = characters.getUnlockedCharacter(self.text)
		self:updateSprite()
	end
end
function P.charTile:updateSprite()
	if self.character ~= nil then
		self.isVisible = true
		local charOverlay = tiles.playerTile:new()
		charOverlay.character = self.character
		charOverlay:updateSprite()
		self.overlay = charOverlay
	end
end
function P.charTile:onEnter(entered)
end
function P.charTile:onLeave(player)
	messageInfo.text = nil
end
function P.charTile:getCharInfo()
	if self.character==nil then return end
	local infoText = ""
	infoText = infoText..self.character.name..", "..self.character.description.."\n"
	infoText = infoText..self.character.crime.."\n\n"
	infoText = infoText.."Escapes: "..stats.getStat(self.character.name..'Wins').."\n"
	infoText = infoText.."Failures: "..stats.getStat(self.character.name..'Losses')
	return infoText
end
function P.charTile:onReachMid()
	if self.character ~= nil then
		player.character = self.character
		player.character:onSelect()
		myShader:send("player_range", 500)
	end
	messageInfo.text = self:getCharInfo()
end

P.tree = P.wall:new{name = "tree", sawable = false, level = 0, sprite = 'Graphics/tree0.png',
spriteList = {'Graphics/tree1.png', 'Graphics/tree2.png', 'Graphics/tree3.png'}}
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

P.biscuit = P.tile:new{name = "biscuit", sprite = 'Graphics/biscuit.png'}
function P.biscuit:onEnter(player)
	player.biscuitHeld = true
	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.atm = P.concreteWall:new{name = "atm", sprite = 'Graphics/tooltaxtile.png', untoolable = true,
map = {}}
function P.atm:onLoad()
	for i = 1, mapHeight do
		self.map[i] = {}
		for j = 1, mapHeight do
			self.map[i][j] = 0
		end
	end
end
function P.atm:obstructsMovement()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return false
	elseif tools.coin.numHeld>0 or tools.luckyPenny.numHeld>0 then
		return false
	end
	return true
end
function P.atm:onEnter()
	if math.abs(player.elevation-self:getHeight())<=3 then
		return
	elseif tools.coin.numHeld>0 or tools.luckyPenny.numHeld>0 then
		if tools.coin.numHeld>0 then
			tools.coin.numHeld = tools.coin.numHeld-1
		elseif tools.luckyPenny.numHeld>0 then
			tools.luckyPenny.numHeld = tools.luckyPenny.numHeld01
		end
		
		local gaveTools = false
		for i = 1, #self.map do
			for j = 1, #self.map[1] do
				if self.map[i][j]==0 and mainMap[i][j]~=nil then
					self.map[i][j]=1
					local itemsNeededList = map.getItemsNeeded(mainMap[i][j].roomid)
					local inlLen = #itemsNeededList
					local whichIN = util.random(inlLen, 'misc')
					local toolsToGive = {}
					for i = 1, tools.numNormalTools do
						print(itemsNeededList[whichIN][i])
						for j = 1, itemsNeededList[whichIN][i] do
							toolsToGive[#toolsToGive+1] = tools[i]
						end
					end
					if #toolsToGive>0 then
						gaveTools = true
						tools.giveToolsByReference(toolsToGive)
						break
					end
				end
				if gaveTools then break end
			end
			if gaveTools then break end
		end
		if not gaveTools then
			tools.giveRandomTools(1)
		end

		player.tileX = player.prevTileX
		player.tileY = player.prevTileY
	end
end

P.ratTile = P.pitbullTile:new{name = "rat", animal = animalList[15], listIndex = 15}
P.mimicTile = P.pitbullTile:new{name = "mimic", animal = animalList[21], listIndex = 21}

P.iceBoxTile = P.boxTile:new{name = "iceBoxTile", pushable = pushableList[13], listIndex = 13}
P.recycleBinTile = P.boxTile:new{name = "recycleBinTile", pushable = pushableList[14], listIndex = 14}

P.infestedWood = P.wall:new{name = "infestedWood", sprite = 'Graphics/infestedwood.png'}
function P.infestedWood:destroy()
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
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==self then
				local animalToAdd = animalList.termite:new()
				animalToAdd.tileX = j
				animalToAdd.tileY = i
				animalToAdd.prevTileX = j
				animalToAdd.prevTileY = i
				animalToAdd:setLoc()
				animals[#animals+1] = animalToAdd
			end
		end
	end
end

P.openDungeon = P.tile:new{name = "openDungeon", untoolable = true}
function P.openDungeon:onEnter()
	if player.dungeonKeysHeld>=3 then
		unlockDoors(true)
	end
end

P.bossTile = P.tile:new{name = 'bossTile', boss = bosses.bobBoss}

P.superChest = P.tile:new{name = "superChest", sprite = 'Graphics/Tiles/superChest.png', supers = {}}
function P.superChest:onEnter()
	if self.done then return
	elseif tools.areSupersFull() then return
	end

	for i = 1, #self.supers do
		tools.giveToolsByReference({self.supers[i]})
	end

	self.done = true
	self.isCompleted = true
	self.isVisible = false
	self.gone = true
end

P.characterWall = P.reinforcedGlass:new{name = "characterWall", isVisible = false, character = nil, text = "Herman", sprite = tiles.reinforcedGlass.sprite}
function P.characterWall:onLoad()
	if self.character==nil then
		self.character = characters.getUnlockedCharacter(self.text)
		if self.character ~= nil then
			local overlayChar = tiles.playerTile:new()
			overlayChar.character = self.character
			overlayChar:updateSprite()
			self.overlay = overlayChar
			self.isVisible = true
		end
	end
end
function P.characterWall:onEnter(entered)
	if not (player.tileX==entered.tileX and player.tileY==entered.tileY) then return end
	if self.character ~= nil then
		player.character = self.character
		player.character:onSelect()
		myShader:send("player_range", 500)
		tiles.concreteWall.onEnter(self, player)
	end
end
function P.characterWall:getCharInfo()
	if self.character==nil then return end
	local infoText = ""
	infoText = infoText..self.character.name..", "..self.character.description.."\n"
	infoText = infoText..self.character.crime.."\n\n"
	infoText = infoText.."Escapes: "..stats.getStat(self.character.name..'Wins').."\n"
	infoText = infoText.."Failures: "..stats.getStat(self.character.name..'Losses')
	return infoText
end
function P.characterWall:obstructsMovement()
	return false
end

P.movingSpike = P.tile:new{name = "movingSpike1", downTime = 100, upTime = 50, currentTime = 0, deadly = false,
sprite = 'GraphicsTony/Spikes0.png', safeSprite = 'GraphicsTony/Spikes0.png', deadlySprite = 'GraphicsTony/Spikes2Blue.png'}
function P.movingSpike:onLoad()
	if self.text~=nil and tonumber(self.text)~=nil then
		self.currentTime = tonumber(self.text)
		while self.currentTime>self.downTime+self.upTime do
			self.currentTime = self.currentTime-(self.downTime+self.upTime)
		end
	end
end
function P.movingSpike:realtimeUpdate(dt, i, j)
	self.currentTime = self.currentTime+dt*100
	if self.currentTime>self.downTime + self.upTime then
		self.currentTime = 0
	end
	self:updateDeadly()
	self:updateSprite()

	local playerTileCoords = coordsToTile(player.y, player.x)
	if playerTileCoords.y==i and playerTileCoords.x==j and self:willKillPlayer() then
		kill()
	end
	for k = 1, #animals do
		if animals[k].tileY==i and animals[k].tileX==j and self:willKillPlayer() then
			animals[k]:kill()
		end
	end
end
function P.movingSpike:updateDeadly()
	if self.currentTime>self.downTime then
		self.deadly = true
	else
		self.deadly = false
	end
end
function P.movingSpike:willKillPlayer()
	if player.attributes.shieldCounter>0 then
		return false
	end
	return self.deadly
end
function P.movingSpike:updateSprite()
	if self.deadly then
		self.sprite = self.deadlySprite
	else
		self.sprite = self.safeSprite
	end
end

P.movingSpikeFast = P.movingSpike:new{name = "movingSpike2", downTime = 66, upTime = 33, safeSprite = 'GraphicsTony/Spikes0.png', deadlySprite = 'GraphicsTony/Spikes2Red.png'}
P.movingSpikeSlow = P.movingSpike:new{name = "movingSpike3", downTime = 133, upTime = 66, safeSprite = 'GraphicsTony/Spikes0.png', deadlySprite = 'GraphicsTony/Spikes2Green.png'}

P.movingSpikeCustom = P.movingSpike:new{name = "movingSpikeCustom", deadlySprite = 'GraphicsTony/Spikes2.png'}
function P.movingSpikeCustom:onLoad()
	P.movingSpike.onLoad(self)
	local roomid = mainMap[mapy][mapx].roomid
	local roomUpTime = map.getFieldForRoom(roomid, "spikeUpTime")
	local roomDownTime = map.getFieldForRoom(roomid, "spikeDownTime")
	self.upTime = roomUpTime ~= nil and roomUpTime or self.upTime
	self.downTime = roomDownTime ~= nil and roomDownTime or self.downTime
end

P.laserBlock = P.tile:new{name = "laserBlock", sprite = 'Graphics/laserBlock.png',
active = true, deadSprite = 'Graphics/deadLaserBlock.png', blastCounter = 0.3,
maxBlastCounter=0.3, triggered = false}
function P.laserBlock:onStep(thisY, thisX)
	if not self.active then return end

	local whichDirPointing = self:cfr(1)
	if player.tileX==thisX then
		if whichDirPointing==1 and thisY>=player.tileY then
			self:trigger()
		elseif whichDirPointing==3 and thisY<=player.tileY then
			self:trigger()
		end
	elseif player.tileY==thisY then
		if whichDirPointing==2 and thisX<=player.tileX then
			self:trigger()
		elseif whichDirPointing==4 and thisX>=player.tileX then
			self:trigger()
		end
	end
end
function P.laserBlock:trigger()
	self.triggered = true
end
function P.laserBlock:realtimeUpdate(dt, thisY, thisX)
	if self.triggered then
		self.blastCounter = self.blastCounter-dt
		if self.blastCounter<=0 then
			self:fire(thisY, thisX)
			self.triggered = false
		end
	end
end
function P.laserBlock:fire(thisY, thisX)
	local whichDirPointing = self:cfr(1)
	local diffx = 0
	local diffy = 0
	if whichDirPointing==1 then diffy=-1
	elseif whichDirPointing==2 then diffx=1
	elseif whichDirPointing==3 then diffy=1
	elseif whichDirPointing==4 then diffx=-1 end

	for i = 1, math.max(roomLength, roomHeight) do
		if 0<thisX+diffx*i and thisX+diffx*i<=roomLength and
		0<thisY+diffy*i and thisY+diffy*i<roomHeight then
			local tileToDestroy = room[thisY+diffy*i][thisX+diffx*i]
			if tileToDestroy~=nil then
				room[thisY+diffy*i][thisX+diffx*i]:destroy()
			end
			for j = 1, #animals do
				if animals[j].tileX==thisX+diffx*i and animals[j].tileY==thisY+diffy*i then
					animals[j]:kill()
					if animals[j]:instanceof(animalList.bombBuddy) then
						animals[j]:explode()
					end
				end
			end
			if player.tileX==thisX+diffx*i and player.tileY==thisY+diffy*i then
				kill('laserBlock')
			end
		else
			break
		end
	end

	self.active = false
	updateGameState()
	self:updateSprite()
end
function P.laserBlock:updateSprite()
	if not self.active then
		self.sprite = self.deadSprite
	end
end

P.notGate = P.powerSupply:new{overlaying = false, name = "notGate", dirSend = {1,0,0,0}, dirAccept = {1,1,1,1},
sprite = 'Graphics/Tiles/notGateDead.png',
poweredSprite = 'Graphics/Tiles/notGate.png',
destroyedSprite = 'Graphics/Tiles/notGateDestroyed.png'}
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
tiles[34] = P.treasureTile --marked
tiles[35] = P.maskedWire
tiles[36] = P.maskedMetalWall
tiles[37] = P.poweredEnd
tiles[38] = P.mousetrap --marked
tiles[39] = P.bomb --marked
tiles[40] = P.unbreakableCrossWire --marked
tiles[41] = P.capacitor
tiles[42] = P.inductor
tiles[43] = P.slime
tiles[44] = P.unactivatedBomb --marked
tiles[45] = P.snailTile --marked
tiles[46] = P.doghouse
tiles[47] = P.batTile
tiles[48] = P.concreteWallConductiveDirected
tiles[49] = P.meat
tiles[50] = P.beggar --marked
tiles[51] = P.ladder --marked
tiles[52] = P.mousetrapOff --marked
tiles[53] = P.donationMachine
tiles[54] = P.ambiguousAndGate
tiles[55] = P.ambiguousNotGate
tiles[56] = P.entrancePortal --marked
tiles[57] = P.exitPortal --marked
tiles[58] = P.treasureTile2 --marked
tiles[59] = P.treasureTile3 --marked
tiles[60] = P.treasureTile4 --marked
tiles[61] = P.conductiveSlime --marked
tiles[62] = P.conductiveSnailTile
tiles[63] = P.untriggeredPowerSupply --marked wtf
tiles[64] = P.reinforcedGlass
tiles[65] = P.powerTriggeredBomb --marked
tiles[66] = P.boxTile
tiles[67] = P.motionGate
tiles[68] = P.motionGate2
tiles[69] = P.playerBoxTile
tiles[70] = P.animalBoxTile
tiles[71] = P.puddle
tiles[72] = P.dustyGlassWall
tiles[73] = P.web
tiles[74] = P.conductiveBoxTile --marked
tiles[75] = P.boomboxTile --marked
tiles[76] = P.batteringRamTile
tiles[77] = P.lamp --marked
tiles[78] = P.glue --marked
tiles[79] = P.conductiveGlass
tiles[80] = P.reinforcedConductiveGlass
tiles[81] = P.fog --marked
tiles[82] = P.unbreakableWire --marked
tiles[83] = P.unbreakableHorizontalWire --marked
tiles[84] = P.unbreakableTWire --marked
tiles[85] = P.unbreakableCornerWire --marked
tiles[86] = P.accelerator --marked
tiles[87] = P.bombBoxTile --marked
tiles[88] = P.unpoweredAccelerator --marked
tiles[89] = P.giftBoxTile --marked
tiles[90] = P.jackInTheBoxTile --marked
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
tiles[114] = P.unbreakableElectricFloor --marked
tiles[115] = P.superStickyButton --marked
tiles[116] = P.cornerRotater --marked
tiles[117] = P.pinkFog
tiles[118] = P.endTilePaid
tiles[119] = P.mushroom --MARKED AF
tiles[120] = P.unbrickableStayButton --marked
tiles[121] = P.glueSnailTile
tiles[122] = P.bombBuddyTile --marked
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
tiles[133] = P.lampTile --marked
tiles[134] = P.flickeringLamp
tiles[135] = P.redBeggar --marked
tiles[136] = P.blueBeggar --marked
tiles[137] = P.greenBeggar --marked
tiles[138] = P.wifeTile
tiles[139] = P.sonTile
tiles[140] = P.daughterTile
tiles[141] = P.supertoolTile
tiles[142] = P.sawTile --marked
tiles[143] = P.ladderTile --marked
tiles[144] = P.wireCuttersTile --marked
tiles[145] = P.waterBottleTile --marked
tiles[146] = P.spongeTile --marked
tiles[147] = P.brickTile --marked
tiles[148] = P.gunTile --marked
tiles[149] = P.toolTile --marked
tiles[150] = P.toolTaxTile --marked
tiles[151] = P.dungeonEnter --marked
tiles[152] = P.dungeonExit --marked
tiles[153] = P.upTunnel --marked
tiles[154] = P.supertoolQ1 --marked
tiles[155] = P.supertoolQ2 --marked
tiles[156] = P.supertoolQ3 --marked
tiles[157] = P.supertoolQ4 --marked
tiles[158] = P.supertoolQ5 --marked
tiles[159] = P.endDungeonEnter --marked
tiles[160] = P.endDungeonExit --marked
tiles[161] = P.dungeonKey --marked
tiles[162] = P.dungeonKeyGate --marked
tiles[163] = P.gasPuddle --marked
tiles[164] = P.halfWall --marked
tiles[165] = P.elevator
tiles[166] = P.elevatedButton
tiles[167] = P.delevator
tiles[168] = P.groundDown
tiles[169] = P.tallWall --marked
tiles[170] = P.gameStairs
tiles[171] = P.tutStairs
tiles[172] = P.unlockTile
tiles[173] = P.darkOverlay
tiles[174] = P.debugStairs
tiles[175] = P.playerTile
tiles[176] = P.lemonade --marked
tiles[177] = P.rottenMeat --marked
tiles[178] = P.tree --marked
tiles[179] = P.biscuit
tiles[180] = P.entrancePortal2
tiles[181] = P.exitPortal2
tiles[182] = P.whiteBeggar
tiles[183] = P.blackBeggar
tiles[184] = P.goldBeggar
tiles[185] = P.gameWin
tiles[186] = P.spotlightTile
tiles[187] = P.fastSpotlightTile
tiles[188] = P.slowSpotlightTile
tiles[189] = P.ramTile
tiles[190] = P.finalKey
tiles[191] = P.finalKeyGate
tiles[192] = P.finalKeyPowered
tiles[193] = P.atm
tiles[194] = P.saveStairs
tiles[195] = P.playbackStairs
tiles[196] = P.ratTile --marked
tiles[197] = P.iceBoxTile --marked
tiles[198] = P.recycleBinTile
tiles[199] = P.infestedWood
tiles[200] = P.editorStairs
tiles[201] = P.replayViewer
tiles[202] = P.openDungeon
tiles[203] = P.testChargedBossTile
tiles[204] = P.bossTile
tiles[205] = P.mimicTile
tiles[206] = P.heavenEnter
tiles[207] = P.heavenExit
tiles[208] = P.superChest
tiles[209] = P.characterWall
tiles[210] = P.charTile
tiles[211] = P.dailyStairs
tiles[212] = P.creditsChar
tiles[213] = P.creditsBase
tiles[214] = P.dungeonSuper
tiles[215] = P.movingSpike
tiles[216] = P.movingSpikeFast
tiles[217] = P.movingSpikeSlow
tiles[218] = P.movingSpikeCustom
tiles[219] = P.robotGuardTile
tiles[220] = P.laserBlock
tiles[221] = P.shopkeeperTile
tiles[222] = P.baseBossTile
tiles[223] = P.supertoolQInf
tiles[224] = P.characterNPCTile

return tiles