local util = require('scripts.util')
local tiles = require('scripts.tiles')
local pushables = require('scripts.pushables')
require('scripts.object')

local P = {}
unlocks = P

P.unlocksFile = 'unlocks.json'

P.unlocksDisplay = {base = 3, timeLeft = 0, unlockToShow = 1}
P.frame = love.graphics.newImage('Graphics/unlocksframe.png')

function P.updateTimer(dt)
	P.unlocksDisplay.timeLeft = P.unlocksDisplay.timeLeft - dt
end 

local function readUnlocks()
	if not love.filesystem.exists(saveDir..'/'..P.unlocksFile) then return end
	local unlocksArray = util.readJSON(saveDir..'/'..P.unlocksFile, false)
	if unlocksArray == nil then return end
	for i = 1, #unlocksArray do
		P[unlocksArray[i]].unlocked = true
	end
end

local function writeUnlocks()
	local unlocksArray = {}
	for i = 1, #P do
		if P[i].unlocked then
			unlocksArray[#unlocksArray + 1] = i
		end
	end
	util.writeJSON(P.unlocksFile, unlocksArray)
end

function P.displayUnlock(unlockId)
	P.unlocksDisplay.timeLeft = P.unlocksDisplay.base
	P.unlocksDisplay.unlockToShow = unlockId
end

function P.unlockUnlockable(unlockId)
	if P[unlockId].unlocked == false then
		P.displayUnlock(unlockId)
		P[unlockId].unlocked = true
		writeUnlocks()
		--need to check if we unlocked any supertools so that they can drop
		if P[unlockId].toolIds ~= nil then
			updateUnlockedSupertools()
		end
	end
end

function P.unlockUnlockableRef(unlock)
	if unlock.unlocked == false then
		for i = 1, #unlocks do
			if unlocks[i] == unlock then
				P.unlockUnlockable(i)
			end
		end
	end
end

function P.load()
	readUnlocks()
end

--helper code for supertool unlocks
local unlockedSupertools = nil
function P.updateUnlockedSupertools()
	unlockedSupertools = {}
	for i = 1, #tools do
		unlockedSupertools[i] = true
	end
	local unlock
	for i = 1, #unlocks do
		unlock = unlocks[i]
		if unlock.toolIds ~= nil and unlock.unlocked == false then
			for k = 1, #unlock.toolIds do
				unlockedSupertools[unlock.toolIds[k]] = false
			end
		end
	end
end
function P.getUnlockedSupertools()
	if unlockedSupertools == nil then
		P.updateUnlockedSupertools()
	end
	return unlockedSupertools
end



P.unlock = Object:new{name = 'generic', unlocked = false, sprite = tiles.fog.sprite}




P.charUnlock = P.unlock:new{name = 'character', charIds = {1}}
--P.felixUnlock = P.charUnlock:new{name = 'felix the sharpshooter', charIds = {2}, sprite = love.graphics.newImage('Graphics/felix.png')}
P.erikUnlock = P.charUnlock:new{name = 'erik knighton', charIds = {4}, sprite = tiles.beggar.sprite}
P.rammyUnlock = P.charUnlock:new{name = 'rammy the ram', charIds = {6}, sprite = love.graphics.newImage('Graphics/ram.png')}
P.frederickUnlock = P.charUnlock:new{name = 'frederick the frog', charIds = {8}, sprite = love.graphics.newImage('Graphics/frederick.png')}
P.batteryUnlock = P.charUnlock:new{name = 'bob the battery', charIds = {9}, sprite = love.graphics.newImage('Graphics/powersupply.png')}
--P.carlaUnlock
P.wizardUnlock = P.charUnlock:new{name = 'giovanni the sorceror', charIds = {11}, sprite = love.graphics.newImage('Graphics/giovannighost.png')}
--P.gabeUnlock = P.charUnlock:new{name = 'gabe the angel', charIds = {5}, sprite = love.graphics.newImage('Graphics/gabe.png')}
P.orsonUnlock = P.charUnlock:new{name = 'orson the mastermind', charIds = {14}, sprite = love.graphics.newImage('Graphics/orson.png')}
P.lennyUnlock = P.charUnlock:new{name = 'lenny the ghost snail', charIds = {15}, sprite = love.graphics.newImage('Graphics/lenny.png')}
P.fishUnlock = P.charUnlock:new{name = 'fish fish', charIds = {16}, sprite = love.graphics.newImage('Graphics/fish.png')}


P.tileUnlock = P.unlock:new{name = 'tile', tileIds = {1}, sprite = tiles.tile.sprite}
P.boxesUnlock = P.tileUnlock:new{name = 'box', tileIds = {66,69,70,74,75,76,87,89,90}, sprite = pushables.box.sprite}
P.acceleratorUnlock = P.tileUnlock:new{name = 'accelerator', tileIds = {86,88}, sprite = tiles.unpoweredAccelerator.sprite}
P.portalUnlock = P.tileUnlock:new{name = 'portals', tileIds = {56,57}, sprite = tiles.entrancePortal.sprite}
P.unbreakableWires = P.tileUnlock:new{name = 'unbreakable wires', tileIds = {40,82,83,84,85}, sprite = tiles.unbreakableWire.sprite}
P.rotatersUnlock = P.tileUnlock:new{name = 'rotaters', tileIds = {27,116}, sprite = tiles.cornerRotater.sprite}
P.ambiguousGates = P.tileUnlock:new{name = 'ambiguous gates', tileIds = {54,55}, sprite = tiles.ambiguousAndGate.sprite}
P.unbreakableEfloorUnlock = P.tileUnlock:new{name = 'ambiguous efloors', tileIds = {114}, sprite = tiles.unbreakableElectricFloor.sprite}
P.untoolableButtons = P.tileUnlock:new{name = 'untoolable buttons', tileIds = {115,120}, sprite = tiles.unbrickableStayButton.sprite}
P.mousetrapUnlock = P.tileUnlock:new{name = 'mousetraps', tileIds = {38,52}, sprite = tiles.mousetrap.sprite}
P.breakablePitUnlock = P.tileUnlock:new{name = 'watch where you step', tileIds = {33}, sprite = tiles.breakablePit.sprite}
P.catUnlock = P.tileUnlock:new{name = 'meow', tileIds = {23}, sprite = animalList.cat.sprite}
P.spikesUnlock = P.tileUnlock:new{name = 'pointy', tileIds = {28}, sprite = tiles.spikes.sprite}
P.poweredEndUnlock = P.tileUnlock:new{name = 'powered end tiles', tileIds = {37}, sprite = tiles.poweredEnd.sprite}
P.snailsUnlock = P.tileUnlock:new{name = 'snails!', tileIds = {43,45}, sprite = animals.snail.sprite}
P.conductiveSnailsUnlock = P.tileUnlock:new{name = 'powered snails!', tileIds = {61,62}, sprite = animals.conductiveSnail.sprite}
P.untriggeredPowerUnlock = P.tileUnlock:new{name = 'untriggered power supplies', tileIds = {63}, sprite = tiles.untriggeredPowerSupply.sprite}
P.conditionalBoxes = P.tileUnlock:new{name = 'player only and dog only boxes', tileIds = {69,70}, sprite = pushables.playerBox.sprite}
P.conductiveBoxes = P.tileUnlock:new{name = 'conductive boxes', tileIds = {74}, sprite = pushables.conductiveBox.sprite}
P.boomboxUnlock = P.tileUnlock:new{name = 'boots and cats', tileIds = {75}, sprite = pushables.boombox.sprite}
P.ramUnlock = P.tileUnlock:new{name = 'battering ram', tileIds = {76}, sprite = pushables.batteringRam.sprite}
P.jackInTheBoxUnlock = P.tileUnlock:new{name = 'jack in the box', tileIds = {90}, sprite = pushables.jackInTheBox.sprite}
P.dirtyGlassUnlock = P.tileUnlock:new{name = 'who leaves all this dust here', tileIds = {72}, sprite = tiles.dustyGlassWall.sprite}
P.fogUnlock = P.tileUnlock:new{name = "i can't see a thing", tileIds = {81,117}, sprite = tiles.fog.sprite}
P.directionGatesUnlock = P.tileUnlock:new{name = "erik's shitty direction gates", tileIds = {67,68}, sprite = tiles.motionGate.sprite}


P.toolUnlock = P.unlock:new{name = 'tool', toolIds = {}, sprite = tools.saw.sprite}
P.missileUnlock = P.unlock:new{name = 'missile', toolIds = {16}, sprite = tools.missile.sprite}
P.toolDoublerUnlock = P.unlock:new{name = 'tool doubler', toolIds = {42}, sprite = tools.toolDoubler.sprite}
P.reviveUnlock = P.unlock:new{name = 'revived!', toolIds = {49}, sprite = tools.revive.sprite}
P.gabeUnlock = P.unlock:new{name = 'gabe the angel', toolIds = {54}, sprite = love.graphics.newImage('Graphics/gabe.png')}


P.roomUnlock = P.unlock:new{name = 'room', roomIds = {"1"}}
P.beggarPartyUnlock = P.roomUnlock:new{name = 'beggars love you', roomIds = {"beggar_party"}, sprite = tiles.beggar.sprite}


--multi unlocks
P.bombsUnlock = P.unlock:new{name = 'boom!', tileIds = {39,44,65,87}, toolIds = {10}, sprite = tools.bomb.image}
P.puddleUnlock = P.tileUnlock:new{name = 'oops you spilled something', tileIds = {71}, toolIds = {46}, sprite = tiles.puddle.sprite}


P.winUnlocks = {P.boxesUnlock, P.rammyUnlock, P.bombsUnlock, P.unbreakableWires, P.ambiguousGates, P.unbreakableMisc}

--characters
P[#P+1] = P.erikUnlock --done
P[#P+1] = P.rammyUnlock --done
P[#P+1] = P.frederickUnlock
P[#P+1] = P.batteryUnlock
P[#P+1] = P.wizardUnlock
P[#P+1] = P.orsonUnlock --done
P[#P+1] = P.lennyUnlock --done
P[#P+1] = P.fishUnlock --done, but badly

--tiles
P[#P+1] = P.boxesUnlock --done
P[#P+1] = P.acceleratorUnlock
P[#P+1] = P.portalUnlock --done
P[#P+1] = P.unbreakableWires --done
P[#P+1] = P.rotatersUnlock --done
P[#P+1] = P.ambiguousGates --done
P[#P+1] = P.unbreakableEfloorUnlock --done
P[#P+1] = P.untoolableButtons
P[#P+1] = P.mousetrapUnlock
P[#P+1] = P.breakablePitUnlock
P[#P+1] = P.catUnlock
P[#P+1] = P.spikesUnlock
P[#P+1] = P.poweredEndUnlock --done
P[#P+1] = P.snailsUnlock
P[#P+1] = P.conductiveSnailsUnlock
P[#P+1] = P.untriggeredPowerUnlock
P[#P+1] = P.conditionalBoxes --done
P[#P+1] = P.conductiveBoxes --done
P[#P+1] = P.boomboxUnlock
P[#P+1] = P.ramUnlock --done
P[#P+1] = P.jackInTheBoxUnlock
P[#P+1] = P.dirtyGlassUnlock
P[#P+1] = P.fogUnlock --done
P[#P+1] = P.directionGatesUnlock

--tools
P[#P+1] = P.missileUnlock --done
P[#P+1] = P.toolDoublerUnlock --done
P[#P+1] = P.reviveUnlock --done
P[#P+1] = P.gabeUnlock --done

--rooms
P[#P+1] = P.beggarPartyUnlock --done

--multi unlocks
P[#P+1] = P.bombsUnlock --done
P[#P+1] = P.puddleUnlock --done

return unlocks