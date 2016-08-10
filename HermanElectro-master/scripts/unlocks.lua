local util = require('scripts.util')
require('scripts.object')

local P = {}
unlocks = P

P.unlocksFile = 'unlocks.json'

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

function P.unlockUnlockable(unlockId)
	if P[unlockId].unlocked == false then
		P[unlockId].unlocked = true
		writeUnlocks()
	end
end

function P.load()
	readUnlocks()
end

P.unlock = Object:new{name = 'generic', unlocked = false}

P.tileUnlock = P.unlock:new{name = 'tile', tileIds = {1}}
P.boxUnlock = P.tileUnlock:new{name = 'box', tileIds = {66}}
P.booksUnlock = P.tileUnlock:new{name = 'boox', tileIds = {38}}

P.winUnlocks = {1, 2}

P[1] = P.boxUnlock
P[2] = P.booksUnlock

return unlocks