local util = require('scripts.util')
local tiles = require('scripts.tiles')
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
	end
end

function P.unlockUnlockableRef(unlock)
	for i = 1, #unlocks do
		if unlocks[i] == unlock then
			P.unlockUnlockable(i)
		end
	end
end

function P.load()
	readUnlocks()
end

P.unlock = Object:new{name = 'generic', unlocked = false, sprite = tiles.fog.sprite}

P.tileUnlock = P.unlock:new{name = 'tile', tileIds = {1}, sprite = tiles.tile.sprite}

P.boxUnlock = P.tileUnlock:new{name = 'box', tileIds = {66}, sprite = tiles.boxTile.sprite}
P.acceleratorUnlock = P.tileUnlock:new{name = 'accelerator', tileIds = {86,88}, sprite = tiles.unpoweredAccelerator.sprite}
P.portalUnlock = P.tileUnlock:new{name = 'portals', tileIds = {56,57}, sprite = tiles.entrancePortal.sprite}

P.roomUnlock = P.unlock:new{name = 'room', roomIds = {"1"}}
P.beggarPartyUnlock = P.roomUnlock:new{name = 'beggars love you', roomIds = {"beggar_party"}, sprite = tiles.beggar.sprite}

P.charUnlock = P.unlock:new{name = 'character', charIds = {1}}
P.mostUnlock = P.charUnlock:new{name = 'ben most', charIds = {3}, sprite = love.graphics.newImage('GraphicsTony/Ben.png')}
P.erikUnlock = P.charUnlock:new{name = 'erik knighton', charIds = {4}, sprite = tiles.beggar.sprite}
P.gabeUnlock = P.charUnlock:new{name = 'gabe the angel', charIds = {5}, sprite = love.graphics.newImage('Graphics/gabe.png')}
P.felixUnlock = P.charUnlock:new{name = 'felix the sharpshooter', charIds = {2}, sprite = love.graphics.newImage('Graphics/felix.png')}
P.fishUnlock = P.charUnlock:new{name = 'fish fish', charIds = {16}, sprite = love.graphics.newImage('Graphics/fish.png')}

P.winUnlocks = {1, 2, 4}

P[1] = P.boxUnlock
P[2] = P.acceleratorUnlock
P[3] = P.beggarPartyUnlock
P[4] = P.mostUnlock
P[5] = P.erikUnlock
P[6] = P.gabeUnlock
P[7] = P.felixUnlock
P[8] = P.fishUnlock

return unlocks