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
		print('un'..unlocksArray[i])
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
P.booksUnlock = P.tileUnlock:new{name = 'boox', tileIds = {38}, sprite = tiles.mousetrap.sprite}

P.roomUnlock = P.unlock:new{name = 'room', roomIds = {"1"}}
P.beggarPartyUnlock = P.roomUnlock:new{name = 'beggars love you', roomIds = {"beggar_party"}, sprite = tiles.beggar.sprite}

P.winUnlocks = {1, 2}

P[1] = P.boxUnlock
P[2] = P.booksUnlock
P[3] = P.beggarPartyUnlock

return unlocks