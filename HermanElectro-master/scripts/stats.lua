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
P.statsData = {}
P.tempStatsData = {}
P.runNumber = 0

function P.resetTempStats()
	P.tempStatsData = {}
end

function P.incrementStat(stat)
	if P.tempStatsData[stat] == nil then
		P.tempStatsData[stat] = 1
	else
		P.tempStatsData[stat] = P.tempStatsData[stat]+1
	end
	if saving.isPlayingBack() then return end
	if P.statsData[stat] == nil then
		P.statsData[stat] = 1
	else
		P.statsData[stat] = P.statsData[stat]+1
	end
	P.writeStats()
end

function P.getStat(stat)
	if P.statsData[stat] == nil then
		return 0
	else
		return P.statsData[stat]
	end
end

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
	if statsInfo[4] ~= nil then
		P.statsData = statsInfo[4]
	end
end

function P.writeStats()
	local statsInfo = {P.wins, P.losses, P.runNumber, P.statsData}
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