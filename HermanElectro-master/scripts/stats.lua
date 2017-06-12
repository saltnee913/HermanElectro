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
P.tempStatsData = {} --stats for each run

P.roomUnlockTriggers = {}
P.roomUnlockTriggers["wiresCut"] = {[3] = unlocks.unbreakableWires}
P.roomUnlockTriggers["treasureTilesReached"] = {[5] = unlocks.foresightUnlock}

--these unlock whenever you reach total stats
P.statUnlockTriggers = {}
P.statUnlockTriggers["boxesSawed"] = {[11] = unlocks.playerBoxUnlock}
P.statUnlockTriggers["totalLosses"] = {[3] = unlocks.frederickUnlock}
P.statUnlockTriggers["totalWins"] = {[3] = unlocks.dungeonUnlock}
P.statUnlockTriggers["greenBeggarsShot"] = {[10] = unlocks.luckyPennyUnlock}
P.statUnlockTriggers["stickyButtonsSponged"] = {[30] = unlocks.superStickyButtonUnlock}
P.statUnlockTriggers["stayButtonsBricked"] = {[30] = unlocks.unbrickableStayButtonUnlock}
P.statUnlockTriggers["animalsBricked"] = {[10] = unlocks.animalTrainerUnlock}
P.statUnlockTriggers["pitsLaddered"] = {[30] = unlocks.brownPitUnlock}
--P.statUnlockTriggers["glassWallsBricked"] = {[30] = unlocks.reinforcedGlassUnlock}

P.statUnlockTriggers["conductiveSnailKilled"] = {[1] = unlocks.lennyUnlock}
P.statUnlockTriggers["glueSnailKilled"] = {[3] = unlocks.glueUnlock}
P.statUnlockTriggers["pitbullKilled"] = {[30] = unlocks.meatUnlock}
P.statUnlockTriggers["bombBuddyKilled"] = {[3] = unlocks.explosiveMeatUnlock}
P.statUnlockTriggers["ratKilled"] = {[1] = unlocks.rottenMeatUnlock}
P.statUnlockTriggers["catKilled"] = {[1] = unlocks.nineLivesUnlock}

P.statUnlockTriggers["HermanWins"] = {[1] = unlocks.boxesUnlock}
P.statUnlockTriggers["HermanDungeonWins"] = {[1] = unlocks.boxesUnlock}
P.statUnlockTriggers["HermanWinsPlus"] = {[1] = unlocks.boxesUnlock}
P.statUnlockTriggers["HermanReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["FelixWins"] = {[1] = unlocks.missileUnlock}
P.statUnlockTriggers["FelixWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["FelixDungeonWins"] = {[1] = unlocks.bombBoxUnlock}
P.statUnlockTriggers["FelixReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["GiovanniWins"] = {[1] = unlocks.pitbullChangerUnlock}
P.statUnlockTriggers["GiovanniWinsPlus"] = {[1] = unlocks.pitbullChangerUnlock}
P.statUnlockTriggers["GiovanniDungeonWins"] = {[1] = unlocks.swapperUnlock}
P.statUnlockTriggers["GiovanniReachFloor6"] = {[1] = unlocks.tileSwapperUnlock}

P.statUnlockTriggers["XavierWins"] = {[1] = unlocks.sockUnlock}
P.statUnlockTriggers["XavierWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["XavierDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["XavierReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["RammyWins"] = {[1] = unlocks.missileUnlock}
P.statUnlockTriggers["RammyWinsPlus"] = {[1] = unlocks.infestedWoodUnlock}
P.statUnlockTriggers["RammyDungeonWins"] = {[1] = unlocks.ramUnlock}
P.statUnlockTriggers["RammyReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["FishWins"] = {[1] = unlocks.bucketOfWaterUnlock}
P.statUnlockTriggers["FishWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["FishDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["FishReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["BobWins"] = {[1] = unlocks.poweredEndUnlock}
P.statUnlockTriggers["BobWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["BobDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["BobReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["GabeWins"] = {[1] = unlocks.missileUnlock}
P.statUnlockTriggers["GabeWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["GabeDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["GabeReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["ErikWins"] = {[1] = unlocks.stopwatchUnlock}
P.statUnlockTriggers["ErikWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["ErikDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["ErikReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["MarieWins"] = {[1] = unlocks.growthHormonesUnlock}
P.statUnlockTriggers["MarieWinsPlus"] = {[1] = unlocks.xrayVisionUnlock}
P.statUnlockTriggers["MarieDungeonWins"] = {[1] = unlocks.robotArmUnlock}
P.statUnlockTriggers["MarieReachFloor6"] = {[1] = unlocks.robotArmUnlock}

P.statUnlockTriggers["FranciscoWins"] = {[1] = unlocks.missileUnlock}
P.statUnlockTriggers["FranciscoWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["FranciscoDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["FranciscoReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["FrederickWins"] = {[1] = unlocks.missileUnlock}
P.statUnlockTriggers["FrederickWinsPlus"] = {[1] = unlocks.stealthBomberUnlock}
P.statUnlockTriggers["FrederickDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["FrederickReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["LennyWins"] = {[1] = unlocks.missileUnlock}
P.statUnlockTriggers["LennyWinsPlus"] = {[1] = unlocks.bombBuddyUnlock}
P.statUnlockTriggers["LennyDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["LennyReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["AureliusWins"] = {[1] = unlocks.missileUnlock}
P.statUnlockTriggers["AureliusWinsPlus"] = {[1] = unlocks.traderUnlock}
P.statUnlockTriggers["AureliusDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["AureliusReachFloor6"] = {[1] = unlocks.boxesUnlock}

P.statUnlockTriggers["GabeWins"] = {[1] = unlocks.wingsUnlock}
P.statUnlockTriggers["GabeWinsPlus"] = {[1] = unlocks.traderUnlock}
P.statUnlockTriggers["GabeDungeonWins"] = {[1] = unlocks.inflationUnlock}
P.statUnlockTriggers["GabeReachFloor6"] = {[1] = unlocks.boxesUnlock}

--these unlock whenever you do this many things in a run
P.tempUnlockTriggers = {}
P.tempUnlockTriggers["beggarsShot"] = {[5] = unlocks.felixUnlock}
P.tempUnlockTriggers["hermanRevivesUsed"] = {[2] = unlocks.heartTransplantUnlock}
P.runNumber = 0

function P.resetTempStats()
	P.tempStatsData = {}
end

function P.doStatsSave()
	--also add that stats don't save if in daily
	return not loadTutorial and floorIndex ~= -1 and not editorMode
end

function P.incrementStat(stat)
	if not P.doStatsSave() then
		return
	end
	
	--room stats data is created here, it's created on the room object itself and thus is different per room
	if room.roomStatsData == nil then
		room.roomStatsData = {}
	end
	if room.roomStatsData[stat] == nil then
		room.roomStatsData[stat] = 1
	else
		room.roomStatsData[stat] = room.roomStatsData[stat]+1
	end
	if P.roomUnlockTriggers[stat]~=nil and P.roomUnlockTriggers[stat][room.roomStatsData[stat]] ~= nil then
		unlocks.unlockUnlockableRef(P.roomUnlockTriggers[stat][room.roomStatsData[stat]])
	end

	if P.tempStatsData[stat] == nil then
		P.tempStatsData[stat] = 1
	else
		P.tempStatsData[stat] = P.tempStatsData[stat]+1
	end
	if P.tempUnlockTriggers[stat]~=nil and P.tempUnlockTriggers[stat][P.tempStatsData[stat]] ~= nil then
		unlocks.unlockUnlockableRef(P.tempUnlockTriggers[stat][P.tempStatsData[stat]])
	end
	
	if P.statsData[stat] == nil then
		P.statsData[stat] = 1
	else
		P.statsData[stat] = P.statsData[stat]+1
	end
	if P.statUnlockTriggers[stat]~=nil and P.statUnlockTriggers[stat][P.statsData[stat]] ~= nil then
		unlocks.unlockUnlockableRef(P.statUnlockTriggers[stat][P.statsData[stat]])
	end
	P.writeStats()
end

function P.getStat(stat)
	local statData = 0
	local tempData = 0
	if P.statsData[stat] ~= nil then
		statData = P.statsData[stat]
	else
		tempData = P.statsData[stat]
	end
	return statData, tempData
end

function P.readStats()
	if not love.filesystem.exists(saveDir..'/'..P.statsFile) then return end
	local statsInfo = util.readJSON(saveDir..'/'..P.statsFile, false)
	if statsInfo ~= nil then
		P.statsData = statsInfo
	end
end

function P.writeStats()
	util.writeJSON(P.statsFile, P.statsData)
end

function P.load()
	P.readStats()
	P.writeStats()
end

return stats