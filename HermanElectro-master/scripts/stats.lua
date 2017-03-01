require('scripts.object')
require('scripts.tiles')
local util = require('scripts.util')
local json = require('scripts.dkjson')
local unlocks = require('scripts.unlocks')

local P = {}
stats = P


P.statsFile = 'stats.json'
P.wins = {}
P.losses = {}
P.runNumber = 0

function P.readStats()
	if not love.filesystem.exists(saveDir..'/'..P.statsFile) then return end
	local statsInfo = util.readJSON(saveDir..'/'..P.statsFile, false)
	if statsInfo == nil then
		local unlockedChars = characters.getUnlockedCharacters()
		for i = 1, #unlockedChars do
			P.wins[unlockedChars[i].name] = 0
			P.losses[unlockedChars[i].name] = 0
		end
		return
	end
	P.wins = statsInfo[1]
	P.losses = statsInfo[2]
	P.runNumber = statsInfo[3]
end

function P.writeStats()
	local statsInfo = {P.wins, P.losses, P.runNumber}
	local unlockedChars = characters.getUnlockedCharacters()
	for i = 1, #unlockedChars do
		if P.wins[unlockedChars[i].name]==nil then
			P.wins[unlockedChars[i].name] = 0
			P.losses[unlockedChars[i].name] = 0			
		end
	end
	util.writeJSON(P.statsFile, statsInfo)
end

function P.load()
	P.readStats()
	P.writeStats()
end

return stats