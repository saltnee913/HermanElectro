local util = require('scripts.util')
local tiles = require('scripts.tiles')
local pushables = require('scripts.pushables')
local tools = require('scripts.tools')
require('scripts.object')

local P = {}
unlocks = P

P.unlocksFile = 'unlocks.json'

local unlockDisplay = Object:new{timeLeft = 3, unlockToShow = 1, nextUnlock = nil}
P.unlocksDisplay = nil
P.frame = 'Graphics/unlocksframe.png'

function P.updateTimer(dt)
	local unlockDisplayer = P.unlocksDisplay
	if unlockDisplayer == nil then return end
	if unlockDisplayer.timeLeft < 0 then
		P.unlocksDisplay = unlockDisplayer.nextUnlock
	end
	while(unlockDisplayer ~= nil) do
		unlockDisplayer.timeLeft = unlockDisplayer.timeLeft - dt
		unlockDisplayer = unlockDisplayer.nextUnlock
	end
end 

local function readUnlocks()
	if saving.isPlayingBack() then return end
	if not love.filesystem.exists(saveDir..'/'..P.unlocksFile) then return end
	local unlocksArray = util.readJSON(saveDir..'/'..P.unlocksFile, false)
	if unlocksArray == nil then return end
	for i = 1, #unlocksArray do
		P[unlocksArray[i]].unlocked = true
	end
end

local function writeUnlocks()
	if saving.isPlayingBack() then return end
	local unlocksArray = {}
	for i = 1, #P do
		if P[i].unlocked then
			unlocksArray[#unlocksArray + 1] = i
		end
	end
	util.writeJSON(P.unlocksFile, unlocksArray)
end

function P.displayUnlock(unlockId)
	local newUnlockDisplay = unlockDisplay:new{unlockToShow = unlockId}
	if P.unlocksDisplay == nil then
		P.unlocksDisplay = newUnlockDisplay
	else
		local topUnlock = P.unlocksDisplay
		while(topUnlock.nextUnlock ~= nil) do
			topUnlock = topUnlock.nextUnlock
		end
		topUnlock.nextUnlock = newUnlockDisplay
	end
end

function P.unlockUnlockable(unlockId, bypassTut)
	if P[unlockId].unlocked == false and ((bypassTut == true) or not loadTutorial) then
		P.displayUnlock(unlockId)
		P[unlockId].unlocked = true
		writeUnlocks()
		--need to check if we unlocked any supertools so that they can drop
		if P[unlockId].toolIds ~= nil then
			P.updateUnlockedSupertools()
		end
	end
end

function P.lockUnlockable(unlockId)
		P[unlockId].unlocked = false
		writeUnlocks()
		--need to check if we locked any supertools so that they don't drop
		if P[unlockId].toolIds ~= nil then
			P.updateUnlockedSupertools()
		end	
end

function P.unlockUnlockableRef(unlock, bypassTut)
	if unlock.unlocked == false then
		for i = 1, #unlocks do
			if unlocks[i] == unlock then
				P.unlockUnlockable(i, bypassTut)
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
				if unlockedSupertools[unlock.toolIds[k].toolid] ~= nil then
					unlockedSupertools[unlock.toolIds[k].toolid] = false
				end
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
function P.isDungeonUnlocked()
	return P[P.dungeonUnlockId].unlocked
end

--[[ideas:
	unlock for standing on bombbuddy
	unlock for destroying tiletaxtile
	use Ed's ability on a lamp
]]

P.unlock = Object:new{name = 'generic', unlocked = false, sprite = tiles.fog.sprite}


P.charUnlock = P.unlock:new{name = 'character', charIds = {"Herman"}}
P.felixUnlock = P.charUnlock:new{name = 'felix the sharpshooter', charIds = {"Felix"}, sprite = 'Graphics/felix.png'}
P.frederickUnlock = P.charUnlock:new{name = 'frederick the frog', charIds = {"Frederick"}, sprite = 'Graphics/Characters/Frederick.png'}
P.franciscoUnlock = P.charUnlock:new{name = 'francisco the cartographer', charIds = {"Francisco"}, sprite = 'Graphics/Characters/Francisco.png'}
P.rammyUnlock = P.charUnlock:new{name = 'rammy the ram', charIds = {"Rammy"}, sprite = 'Graphics/ram.png'}
P.aureliusUnlock = P.charUnlock:new{name = 'aurelius the golden', charIds = {"Aurelius"}, sprite = 'Graphics/Characters/Aurelius.png'}
P.lennyUnlock = P.charUnlock:new{name = 'lenny the ghost snail', charIds = {"Lenny"}, sprite = 'Graphics/lenny.png'}
P.wizardUnlock = P.charUnlock:new{name = 'giovanni the sorceror', charIds = {"Giovanni"}, sprite = 'Graphics/giovannighost.png'}
P.xavierUnlock = P.charUnlock:new{name = 'xavier the sock ninja', charIds = {"Xavier"}, sprite = 'Graphics/Characters/Eli.png'}
P.batteryUnlock = P.charUnlock:new{name = 'bob the battery', charIds = {"Bob"}, sprite = 'Graphics/Characters/Bob.png'}
P.erikUnlock = P.charUnlock:new{name = 'erik the quick', charIds = {"Erik"}, sprite = 'Graphics/Characters/Erik.png'}
P.fishUnlock = P.charUnlock:new{name = 'fish fish', charIds = {"Fish"}, sprite = 'Graphics/Characters/Fish.png'}
P.scientistUnlock = P.charUnlock:new{name = 'science bitch', charIds = {"Marie"}, sprite = 'Graphics/Characters/Scienceman.png'}


P.tileUnlock = P.unlock:new{name = 'tile', tileIds = {1}, sprite = tiles.tile.sprite}
P.lockedTiles = P.tileUnlock:new{name = 'permanentlyLockedTiles', tileIds = {50}}
P.boxesUnlock = P.tileUnlock:new{name = 'box', tileIds = {66,69,70,74,75,76,87,89,90}, sprite = pushables.box.sprite}
P.acceleratorUnlock = P.tileUnlock:new{name = 'accelerator', tileIds = {88}, sprite = tiles.unpoweredAccelerator.sprite}
P.poweredAccelUnlock = P.tileUnlock:new{name = 'Powered Acceleration', tileIds = {86}, sprite = tiles.accelerator.sprite}
P.portalsUnlock = P.tileUnlock:new{name = 'Portals', tileIds = {56,57}, sprite = tiles.entrancePortal.sprite}

P.unbreakableWires = P.tileUnlock:new{name = 'unbreakable wires', tileIds = {40,82,83,84,85}, sprite = tiles.unbreakableWire.sprite}
P.rotatersUnlock = P.tileUnlock:new{name = 'rotaters', tileIds = {27,116}, sprite = tiles.cornerRotater.sprite}
P.ambiguousGates = P.tileUnlock:new{name = 'ambiguous gates', tileIds = {54,55}, sprite = tiles.ambiguousAndGate.sprite}
P.unbreakableEfloorUnlock = P.tileUnlock:new{name = 'ambiguous efloors', tileIds = {114}, sprite = tiles.unbreakableElectricFloor.sprite}
P.untoolableButtons = P.tileUnlock:new{name = 'untoolable buttons', tileIds = {115,120}, sprite = tiles.unbrickableStayButton.sprite}
P.mousetrapUnlock = P.tileUnlock:new{name = 'mousetraps', tileIds = {38,52}, sprite = tiles.mousetrap.sprite}
P.breakablePitUnlock = P.tileUnlock:new{name = 'watch where you step', tileIds = {33}, sprite = tiles.breakablePit.sprite}
P.catUnlock = P.tileUnlock:new{name = 'meow', tileIds = {23}, sprite = animalList.cat.sprite}
P.ratUnlock = P.tileUnlock:new{name = 'eek', tileIds = {196}, sprite = animalList.rat.sprite}
P.spikesUnlock = P.tileUnlock:new{name = 'pointy', tileIds = {28}, sprite = tiles.spikes.sprite}
P.poweredEndUnlock = P.tileUnlock:new{name = 'powered end tiles', tileIds = {37}, sprite = tiles.poweredEnd.sprite}
--^@Orson Unlocks
P.snailsUnlock = P.tileUnlock:new{name = 'snails!', tileIds = {43,45}, sprite = animalList.snail.sprite}
P.conductiveSnailsUnlock = P.tileUnlock:new{name = 'powered snails!', tileIds = {61,62}, sprite = animalList.conductiveSnail.sprite}
P.glueSnailUnlock = P.tileUnlock:new{name = 'glue snails!', tileIds = {121}, sprite = animalList.glueSnail.sprite}
P.bombBuddyUnlock = P.tileUnlock:new{name = "bomb buddy :)", tileIds = {122}, sprite = animalList.bombBuddy.sprite}
P.termiteUnlock = P.tileUnlock:new{name = "bomb buddy :)", tileIds = {199}, sprite = animalList.termite.sprite}

P.untriggeredPowerUnlock = P.tileUnlock:new{name = 'untriggered power supplies', tileIds = {63}, sprite = tiles.untriggeredPowerSupply.sprite}


P.conditionalBoxes = P.tileUnlock:new{name = 'player only and dog only boxes', tileIds = {69,70}, sprite = pushables.playerBox.sprite}
P.conductiveBoxes = P.tileUnlock:new{name = 'conductive boxes', tileIds = {74}, sprite = pushables.conductiveBox.sprite}
P.boomboxUnlock = P.tileUnlock:new{name = 'boots and cats', tileIds = {75}, sprite = pushables.boombox.sprite}
P.ramUnlock = P.tileUnlock:new{name = 'battering ram', tileIds = {76}, sprite = pushables.batteringRam.sprite}
P.jackInTheBoxUnlock = P.tileUnlock:new{name = 'jack in the box', tileIds = {90}, sprite = pushables.jackInTheBox.sprite}
P.iceBoxUnlock = P.tileUnlock:new{name = 'Chill', tileIds = {197}, sprite = pushables.iceBox.sprite}


P.dirtyGlassUnlock = P.tileUnlock:new{name = 'who leaves all this dust here', tileIds = {72}, sprite = tiles.dustyGlassWall.sprite}
P.fogUnlock = P.tileUnlock:new{name = "i can't see a thing", tileIds = {81,117}, sprite = tiles.fog.sprite}
P.directionGatesUnlock = P.tileUnlock:new{name = "erik's shitty direction gates", tileIds = {67,68}, sprite = tiles.motionGate.sprite}
--P.stickyButtonUnlock = P.tileUnlock:new{name = "sticky buttons", tileIds = {9}, sprite = tiles.stickyButton.sprite}
--P.stayButtonUnlock = P.tileUnlock:new{name = "stay buttons", tileIds = {10}, sprite = tiles.stayButton.sprite}
P.doorUnlock = P.tileUnlock:new{name = "door unlock", tileIds = {18}, sprite = tiles.hDoor.sprite}
--we spelled rotator wrong
P.cornerRotaterUnlock = P.tileUnlock:new{name = "corner rotators", tileIds = {116}, sprite = tiles.cornerRotater.sprite}

--unlocks to prevent tiles from appearing
P.lockedTiles = P.tileUnlock:new{name = 'permanentlyLockedTiles', tileIds = {103,104,105,106,107,108,109,110,111,112,113},hidden = true}

P.toolUnlock = P.unlock:new{name = 'tool', toolIds = {}, sprite = tools.saw.image}
P.glueUnlock = P.unlock:new{name = 'glue', toolIds = {tools.glue}, sprite = tools.glue.image}
P.trapUnlock = P.unlock:new{name = 'trap queen', toolIds = {tools.trap}, sprite = tools.trap.image}
P.missileUnlock = P.unlock:new{name = 'missile', toolIds = {tools.missile}, sprite = tools.missile.image}
P.toolDoublerUnlock = P.unlock:new{name = 'tool doubler', toolIds = {tools.toolDoubler}, sprite = tools.toolDoubler.image}
--P.reviveUnlock = P.unlock:new{name = 'revived!', toolIds = {tools.revive}, sprite = tools.revive.image}
P.gabeUnlock = P.unlock:new{name = 'gabe the angel', toolIds = {tools.gabeMaker}, sprite = 'Graphics/gabe.png'}
P.buttonFlipperUnlock = P.unlock:new{name = 'button flipper', toolIds = {tools.buttonFlipper}, sprite = tools.buttonFlipper.image}
P.superGunUnlock = P.unlock:new{name = "super gun!", toolIds = {tools.superGun}, sprite = tools.superGun.image}
P.suicideKingUnlock = P.unlock:new{name = "use with caution", toolIds = {tools.suicideKing}, sprite = tools.suicideKing.image}
P.screwdriverUnlock = P.unlock:new{name = "screwdriver", toolIds = {tools.screwdriver}, sprite = tools.screwdriver.image}
P.toolIncrementerUnlock = P.unlock:new{name = "toolbox", toolIds = {tools.toolIncrementer}, sprite = tools.toolIncrementer.image}
P.toolRerollerUnlock = P.unlock:new{name = "Tool Reroller", toolIds = {tools.toolReroller}, sprite = tools.toolReroller.image}
P.superToolUnlock = P.unlock:new{name = "Super Supertools", toolIds = {tools.superSaw, tools.longLadder,
tools.superWireCutters, tools.superWaterBottle, tools.superSponge, tools.superBrick, tools.superGun},
sprite = tools.superSaw.image}
P.laptopUnlock = P.unlock:new{name = "Laptop", toolIds = {tools.laptop}, sprite = tools.laptop.image}
P.superLaserUnlock = P.unlock:new{name = "Super Laser", toolIds = {tools.superLaser}, sprite = tools.superLaser.image}

P.roomUnlock = P.unlock:new{name = 'room', roomIds = {"1"}}
P.beggarPartyUnlock = P.roomUnlock:new{name = 'beggars love you', roomIds = {"beggar_party"}, sprite = tiles.beggar.sprite}


--multi unlocks
P.bombsUnlock = P.unlock:new{name = 'boom!', tileIds = {39,44,65,87}, toolIds = {tools.bomb}, sprite = tools.bomb.image}
P.puddleUnlock = P.tileUnlock:new{name = 'oops you spilled something', tileIds = {71}, toolIds = {tools.bucketOfWater}, sprite = tiles.puddle.sprite}
P.portalUnlock = P.tileUnlock:new{name = 'portals', tileIds = {56,57}, toolIds = {tools.portalPlacer}, sprite = tiles.entrancePortal.sprite}

P.dungeonUnlock = P.unlock:new{name = 'dungeon', sprite = tiles.endDungeonEnter.sprite}


--P.winUnlocks = {P.rammyUnlock, P.bombsUnlock, P.ambiguousGates, P.unbreakableEfloorUnlock}
P.winUnlocks = {nil, nil, nil, nil}
--P.floorUnlocks = {P.doorUnlock, P.catUnlock, P.boxesUnlock, P.unbreakableWires, P.mousetrapUnlock, P.wizardUnlock}
P.floorUnlocks = {nil,P.doorUnlock,nil,nil,nil,nil}

--characters
P[#P+1] = P.felixUnlock --done
P[#P+1] = P.frederickUnlock --done
P[#P+1] = P.franciscoUnlock --done
P[#P+1] = P.rammyUnlock
P[#P+1] = P.aureliusUnlock 
P[#P+1] = P.lennyUnlock
P[#P+1] = P.wizardUnlock
P[#P+1] = P.xavierUnlock
P[#P+1] = P.batteryUnlock
P[#P+1] = P.erikUnlock
P[#P+1] = P.fishUnlock
P[#P+1] = P.scientistUnlock

--tiles
P[#P+1] = P.boxesUnlock --done
P[#P+1] = P.acceleratorUnlock
P[#P+1] = P.unbreakableWires --done
P[#P+1] = P.rotatersUnlock
P[#P+1] = P.ambiguousGates --done
P[#P+1] = P.unbreakableEfloorUnlock --done
P[#P+1] = P.untoolableButtons
P[#P+1] = P.mousetrapUnlock --done
P[#P+1] = P.breakablePitUnlock --done
P[#P+1] = P.cornerRotaterUnlock
P[#P+1] = P.portalsUnlock
P[#P+1] = P.poweredAccelUnlock

P[#P+1] = P.catUnlock --done
P[#P+1] = P.ratUnlock
P[#P+1] = P.termiteUnlock

P[#P+1] = P.spikesUnlock
P[#P+1] = P.poweredEndUnlock --done
P[#P+1] = P.snailsUnlock --done
P[#P+1] = P.conductiveSnailsUnlock --done
P[#P+1] = P.glueSnailUnlock --done
P[#P+1] = P.bombBuddyUnlock --done
P[#P+1] = P.untriggeredPowerUnlock
P[#P+1] = P.conditionalBoxes --done
P[#P+1] = P.conductiveBoxes --done
P[#P+1] = P.boomboxUnlock
P[#P+1] = P.iceBoxUnlock
P[#P+1] = P.ramUnlock --done
P[#P+1] = P.jackInTheBoxUnlock
P[#P+1] = P.dirtyGlassUnlock
P[#P+1] = P.fogUnlock --done
P[#P+1] = P.directionGatesUnlock
P[#P+1] = P.doorUnlock --done
--P[#P+1] = P.stickyButtonUnlock
--P[#P+1] = P.stayButtonUnlock

--tools
P[#P+1] = P.missileUnlock --done
P[#P+1] = P.toolDoublerUnlock --done
--P[#P+1] = P.reviveUnlock --done
P[#P+1] = P.gabeUnlock --done
P[#P+1] = P.buttonFlipperUnlock --done
P[#P+1] = P.superGunUnlock
P[#P+1] = P.suicideKingUnlock --done
P[#P+1] = P.screwdriverUnlock
P[#P+1] = P.glueUnlock
P[#P+1] = P.trapUnlock
P[#P+1] = P.superToolUnlock
P[#P+1] = P.toolIncrementerUnlock
P[#P+1] = P.toolRerollerUnlock
P[#P+1] = P.laptopUnlock
P[#P+1] = P.superLaserUnlock
--P[#P+1] = P.doorstopUnlock
 




--rooms
P[#P+1] = P.beggarPartyUnlock --done

--multi unlocks
P[#P+1] = P.bombsUnlock --done
P[#P+1] = P.puddleUnlock --done
P[#P+1] = P.portalUnlock --done

P[#P+1] = P.dungeonUnlock
P.dungeonUnlockId = #P

P[#P+1] = P.lockedTiles

return unlocks


--HARDCORE

--WIN+ VVVV
--NoTreasure: 
--NoTreasureRooms: 
--NoEndTreasure: 
--NoBeggar: 
--NoTrippleEntryOnUnbeaten: Mindful  --Maybe add an easier version of this aswell, or two consecutive floor blocks 
	--NoTrippleEntryOnUbeaten(F4-6) (Win required?)
	--NoTrippleEntryOnUbeaten(F1-3) (Win required?)
--NoTax: ShopRoller +Aurellius: LuckyPenny(?)
--NoRegress: Tunneler(?)



--OnGet
--10x Saw: Blaze(?)
--10x Water: Fish(?) PowerBreaker(?)
--10x Ladder: Wings
--10x Gun: BigBadBeam
--10x Clipper: WireToButton(?) Wirebreaker(?)
--10x Sponge: Crowbar(?) Supersponge(?)
--10x Brick: 

--OnGet
	--Spread(1): +7(?) ToolRoller(?) 
--Spread(2): +7(?) ToolRoller(?) SuperBasics(?)
--Spread(3): +7(?) ToolRoller(?) SuperBasics(?)
	--Spread(4)? 

--OnBeat
--F1: Tile
--F2: Tile
--F3: Tile
--F4: Tile
--F5: Tile
--F6: FDungeon
--FDungeons: Erik(?)

--KillAll
--GreenBeggars: 
--RedBeggars:
--BlueBeggars:

--Winstreak
--2:
--3:
--??4??

--CHARSPECIFICS

--DungeonWIN+
--Erik: Knight(?) Glitch(?) MentalBlock(?)
--Fish: FishingPole(?) (Weak) Cup(?)

--F6WIN+
--Aurellius: Deflation(?) LuckyPenny(?)


--Some characters such as Frederick may have reduced access to acheives
--Most acheives should not requisite




--TaxTiles
--5: 
--10+Win:
--15+Win:


--160 Total Unlocks




