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
	if P[unlockId].hidden then
		return
	end
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
	if P[unlockId].unlocked == false and ((bypassTut == true) or stats.doStatsSave()) then
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
					--fk u
					unlockedSupertools[unlock.toolIds[k].toolid] = false
				end
			end
		end
	end
end
function P.getUnlockedSupertools()
	P.updateUnlockedSupertools()
	return unlockedSupertools
end
function P.isDungeonUnlocked()
	return P[P.dungeonUnlockId].unlocked
end
function P.isEditorUnlocked()
	return P[P.editorUnlockId].unlocked
end

--[[ideas:
	unlock for standing on bombbuddy
	unlock for destroying tiletaxtile
	use Ed's ability on a lamp
]]

P.unlock = Object:new{name = 'generic', unlocked = false, sprite = tiles.fog.sprite}

P.tutorialBeatenUnlock = P.unlock:new{name = "tutorialBeaten", hidden = true}
P.mainGameUnlock = P.unlock:new{name = "mainGame", hidden = true}

P.charUnlock = P.unlock:new{name = 'Herman Electrogue', charIds = {"Herman"}, desc = ''}
P.felixUnlock = P.charUnlock:new{name = 'Fantastic Mr. Felix', desc = 'Bombastic', charIds = {"Natasha"}, sprite = 'Graphics/felix.png', }
P.frederickUnlock = P.charUnlock:new{name = "Voltair's Frog", desc = 'Jumpstart', charIds = {"Frederick"}, sprite = 'Graphics/Characters/Frederick.png'}
P.franciscoUnlock = P.charUnlock:new{name = 'Francisco the Cartographer', desc = 'A first-rate frontier fellow', charIds = {"Francisco"}, sprite = 'Graphics/Characters/Francisco.png'}
P.rammyUnlock = P.charUnlock:new{name = 'Ramesses II Electric Boogaloo', desc ='Form of the ram', charIds = {"Rammy"}, sprite = 'Graphics/ram.png'}
P.aureliusUnlock = P.charUnlock:new{name = "	", desc = '	', charIds = {"Aurelius"}, sprite = 'Graphics/Characters/Aurelius.png'}
P.lennyUnlock = P.charUnlock:new{name = 'Love for Lenny', desc = 'The Sticky Spector', charIds = {"Lenny"}, sprite = 'Graphics/Characters/Lenny.png'}
P.wizardUnlock = P.charUnlock:new{name = 'The Good Wizard Giovanni', desc= "Power would corrupt him if he weren't such a homie.", charIds = {"Giovanni"}, sprite = 'Graphics/giovannighost.png'}
P.xavierUnlock = P.charUnlock:new{name = '	', desc ='	', charIds = {"Gru"}, sprite = 'Graphics/Characters/Eli.png'}
P.batteryUnlock = P.charUnlock:new{name = "	", desc ='	', charIds = {"Bob"}, sprite = 'Graphics/Characters/Bob.png'}
P.erikUnlock = P.charUnlock:new{name = '	', desc='	', charIds = {"Erik"}, sprite = 'Graphics/Characters/Erik.png'}
P.fishUnlock = P.charUnlock:new{name = 'Fish of the fish farm', desc='Bad at climbing trees.', charIds = {"Fish"}, sprite = 'Graphics/Characters/Fish.png'}
P.scientistUnlock = P.charUnlock:new{name = 'science bitch', desc = '	', charIds = {"Marie"}, sprite = 'Graphics/Characters/Scienceman.png'}
P.dragonUnlock = P.charUnlock:new{name = "Andy", desc='The Dragon', charIds = {"Dragon"}, sprite = 'Graphics/Characters/Arachne.png'}
P.fourierUnlock = P.charUnlock:new{name = 'Fourier', desc='2+2=4', charIds = {"Fourier"}, sprite = 'Graphics/Characters/Tony.png'}
P.edenUnlock = P.charUnlock:new{name = 'Eden', desc = 'The Zany', charIds = {"Eden"}, sprite = 'Graphics/Characters/Zach.png'}

P.tileUnlock = P.unlock:new{name = 'tile', tileIds = {1}, sprite = tiles.tile.sprite}
P.lockedTiles = P.tileUnlock:new{name = 'permanentlyLockedTiles', tileIds = {50}}
P.boxesUnlock = P.tileUnlock:new{name = 'box', tileIds = {66,69,70,74,75,76,87,89,90}, sprite = pushables.box.sprite}
P.acceleratorUnlock = P.tileUnlock:new{name = 'The Accelerator', tileIds = {88}, sprite = tiles.unpoweredAccelerator.sprite}
P.poweredAccelUnlock = P.tileUnlock:new{name = 'Powered Acceleration', tileIds = {86}, sprite = tiles.accelerator.sprite}
P.portalsUnlock = P.tileUnlock:new{name = 'Thinking With Portals', tileIds = {56,57}, sprite = tiles.entrancePortal.sprite}

P.unbreakableWires = P.tileUnlock:new{name = 'Hardwired', tileIds = {40,82,83,84,85}, sprite = tiles.unbreakableWire.sprite}
P.rotatersUnlock = P.tileUnlock:new{name = 'The Rotator', tileIds = {27,116}, sprite = tiles.cornerRotater.sprite}
P.ambiguousGates = P.tileUnlock:new{name = 'ambiguous gates', tileIds = {54,55}, sprite = tiles.ambiguousAndGate.sprite}
P.unbreakableEfloorUnlock = P.tileUnlock:new{name = 'ambiguous efloors', tileIds = {114}, sprite = tiles.unbreakableElectricFloor.sprite}
P.untoolableButtons = P.tileUnlock:new{name = 'untoolable buttons', tileIds = {115,120}, sprite = tiles.unbrickableStayButton.sprite}
P.mousetrapUnlock = P.tileUnlock:new{name = 'The Mousetrap', tileIds = {38,52}, sprite = tiles.mousetrap.sprite}
P.breakablePitUnlock = P.tileUnlock:new{name = 'watch where you step', tileIds = {33}, sprite = tiles.breakablePit.sprite}
P.spikesUnlock = P.tileUnlock:new{name = 'pointy', tileIds = {28}, sprite = tiles.spikes.sprite}
P.poweredEndUnlock = P.tileUnlock:new{name = 'Ends, electric', tileIds = {37}, sprite = tiles.poweredEnd.sprite}
P.unbreakableElectricFloorUnlock = P.tileUnlock:new{name = 'unbreakable electric floor', tileIds = {114}, sprite = tiles.unbreakableElectricFloor.sprite}
--^@Orson Unlocks
P.snailsUnlock = P.tileUnlock:new{name = 'Gastropods!', tileIds = {43,45}, sprite = animalList.snail.sprite}
P.conductiveSnailsUnlock = P.tileUnlock:new{name = 'Conductive Cream"', tileIds = {61,62}, sprite = animalList.conductiveSnail.sprite}
P.glueSnailUnlock = P.tileUnlock:new{name = 'Sticky Snails', tileIds = {121}, sprite = animalList.glueSnail.sprite}
P.bombBuddyUnlock = P.tileUnlock:new{name = "Mr. Bomb Buddy :)", tileIds = {122}, sprite = animalList.bombBuddy.sprite}
P.termiteUnlock = P.tileUnlock:new{name = "Eek! Termites!", tileIds = {199}, sprite = animalList.termite.sprite}
P.catUnlock = P.tileUnlock:new{name = "Purr", desc = '', tileIds = {23}, sprite = animalList.cat.sprite}
--P.glueSnailUnlock = P.tileUnlock:new{name = "glue", tileIds = {121}, sprite = animalList.glueSnail.sprite}
--P.conductiveSnailUnlock = P.tileUnlock:new{name = "Conductive Cream", tileIds = {62}, sprite = animalList.conductiveSnail.sprite}
P.ratUnlock = P.tileUnlock:new{name = 'Between the walls', tileIds = {196}, sprite = animalList.rat.sprite}
P.reinforcedGlassUnlock = P.tileUnlock:new{name = 'Reinforcements', tileIds = {64}, sprite = tiles.reinforcedGlass.sprite}
P.brownPitUnlock = P.tileUnlock:new{name ='Fallible Flooring', tileIds = {33}, sprite = tiles.breakablePit.sprite}


P.untriggeredPowerUnlock = P.tileUnlock:new{name = 'The Sleepy Supply', tileIds = {63}, sprite = tiles.untriggeredPowerSupply.sprite}


P.boxUnlock = P.tileUnlock:new{name = 'boxes', tileIds = {66,69,70,74,75,76,90,197}, sprite = pushables.box.sprite}
P.playerBoxUnlock = P.tileUnlock:new{name = 'player only boxes', tileIds = {69}, sprite = pushables.playerBox.sprite}
P.animalBoxUnlock = P.tileUnlock:new{name = 'animal only boxes', tileIds = {70}, sprite = pushables.animalBox.sprite}
P.conductiveBoxes = P.tileUnlock:new{name = 'conductive boxes', tileIds = {74}, sprite = pushables.conductiveBox.sprite}
P.boomboxUnlock = P.tileUnlock:new{name = 'boots and cats', tileIds = {75}, sprite = pushables.boombox.sprite}
P.ramUnlock = P.tileUnlock:new{name = 'Battering Ram', tileIds = {76}, sprite = pushables.batteringRam.sprite}
P.jackInTheBoxUnlock = P.tileUnlock:new{name = 'jack in the box', tileIds = {90}, sprite = pushables.jackInTheBox.sprite}
P.iceBoxUnlock = P.tileUnlock:new{name = 'Chill', tileIds = {197}, sprite = pushables.iceBox.sprite}
P.bombBoxUnlock = P.tileUnlock:new{name = "Boom! Box", tileIds = {87}, sprite = pushables.bombBox.sprite}

P.dirtyGlassUnlock = P.tileUnlock:new{name = 'who leaves all this dust here', tileIds = {72}, sprite = tiles.dustyGlassWall.sprite}
P.fogUnlock = P.tileUnlock:new{name = "Mists of Mystery", tileIds = {81,117}, sprite = tiles.fog.sprite}
P.directionGatesUnlock = P.tileUnlock:new{name = "erik's shitty direction gates", tileIds = {67,68}, sprite = tiles.motionGate.sprite}
--P.stickyButtonUnlock = P.tileUnlock:new{name = "sticky buttons", tileIds = {9}, sprite = tiles.stickyButton.sprite}
--P.stayButtonUnlock = P.tileUnlock:new{name = "stay buttons", tileIds = {10}, sprite = tiles.stayButton.sprite}
P.doorUnlock = P.tileUnlock:new{name = "door unlock", tileIds = {18}, sprite = tiles.hDoor.sprite}
--we spelled rotator wrong
P.cornerRotaterUnlock = P.tileUnlock:new{name = "corner rotators", tileIds = {116}, sprite = tiles.cornerRotater.sprite}
P.infestedWoodUnlock = P.tileUnlock:new{name = "Infested....", tileIds = {199}, sprite = tiles.infestedWood.sprite}
P.superStickyButtonUnlock = P.tileUnlock:new{name = "Stickier", tileIds = {115}, sprite = tiles.superStickyButton.sprite}
P.unbrickableStayButtonUnlock = P.tileUnlock:new{name = "Stay-er", tileIds = {120}, sprite = tiles.unbrickableStayButton.sprite}


--unlocks to prevent tiles from appearing
P.lockedTiles = P.tileUnlock:new{name = 'permanentlyLockedTiles', tileIds = {103,104,105,106,107,108,109,110,111,112,113},hidden = true}

P.toolUnlock = P.unlock:new{name = 'tool', toolIds = {}, sprite = tools.saw.image}
P.glueUnlock = P.unlock:new{name = 'glue', toolIds = {tools.glue}, sprite = tools.glue.image}
P.trapUnlock = P.unlock:new{name = 'Trap Queen', toolIds = {tools.trap}, sprite = tools.trap.image}
P.missileUnlock = P.unlock:new{name = 'missile', toolIds = {tools.missile}, sprite = tools.missile.image}
P.toolDoublerUnlock = P.unlock:new{name = 'tool doubler', toolIds = {tools.toolDoubler}, sprite = tools.toolDoubler.image}
--P.reviveUnlock = P.unlock:new{name = 'revived!', toolIds = {tools.revive}, sprite = tools.revive.image}
P.gabeUnlock = P.unlock:new{name = 'gabe the angel', toolIds = {tools.gabeMaker}, sprite = 'Graphics/gabe.png'}
P.buttonFlipperUnlock = P.unlock:new{name = 'button flipper', toolIds = {tools.buttonFlipper}, sprite = tools.buttonFlipper.image}
P.superGunUnlock = P.unlock:new{name = "super gun!", toolIds = {tools.superGun}, sprite = tools.superGun.image}
--P.suicideKingUnlock = P.unlock:new{name = "use with caution", toolIds = {tools.suicideKing}, sprite = tools.suicideKing.image}
P.screwdriverUnlock = P.unlock:new{name = "screwdriver", toolIds = {tools.screwdriver}, sprite = tools.screwdriver.image}
P.toolIncrementerUnlock = P.unlock:new{name = "A Toolbox", toolIds = {tools.toolIncrementer}, sprite = tools.toolIncrementer.image}
P.toolRerollerUnlock = P.unlock:new{name = "Tool Reroller", toolIds = {tools.toolReroller}, sprite = tools.toolReroller.image}
P.superToolUnlock = P.unlock:new{name = "Super Supertools", toolIds = {tools.superSaw, tools.superLadder,
tools.superWireCutters, tools.superWaterBottle, tools.superSponge, tools.superBrick, tools.superGun},
sprite = tools.superSaw.image}
P.laptopUnlock = P.unlock:new{name = "New Hardware", toolIds = {tools.laptop}, sprite = tools.laptop.image}
P.superLaserUnlock = P.unlock:new{name = "The Big Bad Beam", toolIds = {tools.superLaser}, sprite = tools.superLaser.image}
--P.laptopUnlock = P.unlock:new{name = 'laptop', toolIds = {tools.laptop}, sprite = tools.laptop.image}
P.roomRerollerUnlock = P.unlock:new{name = 'roomReroller', toolIds = {tools.roomReroller}, sprite = tools.roomReroller.image}
P.wireExtenderUnlock = P.unlock:new{name = 'wireExtender', toolIds = {tools.wireExtender}, sprite = tools.wireExtender.image}
P.doorstopUnlock = P.unlock:new{name = 'doorstop', toolIds = {tools.doorstop}, sprite = tools.doorstop.image}
P.gasPourerUnlock = P.unlock:new{name = 'gasPourer', toolIds = {tools.gasPourer}, sprite = tools.gasPourer.image}
P.gasPourerXtremeUnlock = P.unlock:new{name = 'gasPourerXtreme', toolIds = {tools.gasPourerXtreme}, sprite = tools.gasPourerXtreme.image}
P.secretTeleporterUnlock = P.unlock:new{name = 'Spirited Away', toolIds = {tools.secretTeleporter}, sprite = tools.secretTeleporter.image}
P.tunnelerUnlock = P.unlock:new{name = 'tunneler', toolIds = {tools.tunneler}, sprite = tools.tunneler.image}
P.pickaxeUnlock = P.unlock:new{name = 'pickaxe', toolIds = {tools.pickaxe}, sprite = tools.pickaxe.image}
P.luckySawUnlock = P.unlock:new{name = 'luckySaw', toolIds = {tools.luckySaw}, sprite = tools.luckySaw.image}
P.luckyBrickUnlock = P.unlock:new{name = 'luckyBrick', toolIds = {tools.luckyBrick}, sprite = tools.luckyBrick.image}
P.supertoolDoublerUnlock = P.unlock:new{name = 'supertoolDoubler', toolIds = {tools.supertoolDoubler}, sprite = tools.supertoolDoubler.image}
P.lemonPartyUnlock = P.unlock:new{name = 'Lemon Party! Woohoo!', toolIds = {tools.lemonParty}, sprite = tools.lemonParty.image}
P.pitbullChangerUnlock = P.unlock:new{name = 'You found your wand!', toolIds = {tools.pitbullChanger}, sprite = tools.pitbullChanger.image}
P.inflationUnlock = P.unlock:new{name = 'Deflation: not just for balloons', toolIds = {tools.inflation}, sprite = tools.inflation.image}
P.tileSwapperUnlock = P.unlock:new{name = 'Tile Swapper', toolIds = {tools.tileSwapper}, sprite = tools.tileSwapper.image}
P.stopwatchUnlock = P.unlock:new{name = 'Stopwatch', toolIds = {tools.stopwatch}, sprite = tools.stopwatch.image}
P.robotArmUnlock = P.unlock:new{name = 'Robotic Arm', toolIds = {tools.robotArm}, sprite = tools.robotArm.image}
P.wingsUnlock = P.unlock:new{name = 'Wings', toolIds = {tools.wings}, sprite = tools.wings.image}
P.growthHormonesUnlock = P.unlock:new{name = 'Growth Hormones', toolIds = {tools.growthHormones}, sprite = tools.growthHormones.image}
P.portalPlacerUnlock = P.unlock:new{name = 'Portal Placer', toolIds = {tools.portalPlacer}, sprite = tools.portalPlacer.image}
P.portalPlacerDoubleUnlock = P.unlock:new{name = 'Portal Placer Double', toolIds = {tools.portalPlacerDouble}, sprite = tools.portalPlacerDouble.image}
P.heartTransplantUnlock = P.unlock:new{name = 'Organ Donor', toolIds = {tools.heartTransplant}, sprite = tools.heartTransplant.image}
P.bucketOfWaterUnlock = P.unlock:new{name = 'Bucket of Water', toolIds = {tools.bucketOfWater}, sprite = tools.bucketOfWater.image}
P.axeUnlock = P.unlock:new{name = 'axe', toolIds = {tools.axe}, sprite = tools.axe.image}
P.lubeUnlock = P.unlock:new{name = 'lube', toolIds = {tools.lube}, sprite = tools.lube.image}
P.knifeUnlock = P.unlock:new{name = 'knife', toolIds = {tools.knife}, sprite = tools.knife.image}
P.seedsUnlock = P.unlock:new{name = 'seeds', toolIds = {tools.seeds}, sprite = tools.seeds.image}
P.fishingPoleUnlock = P.unlock:new{name = 'fishingPole', toolIds = {tools.fishingPole}, sprite = tools.fishingPole.image}
P.amnesiaPillUnlock = P.unlock:new{name = 'amnesiaPill', toolIds = {tools.amnesiaPill}, sprite = tools.amnesiaPill.image}
P.blankToolUnlock = P.unlock:new{name = 'blankTool', toolIds = {tools.blankTool}, sprite = tools.blankTool.image}
P.mindfulToolUnlock = P.unlock:new{name = 'mindfulTool', toolIds = {tools.mindfulTool}, sprite = tools.mindfulTool.image}
P.teleporterUnlock = P.unlock:new{name = 'teleporter', toolIds = {tools.teleporter}, sprite = tools.teleporter.image}
P.rotaterUnlock = P.unlock:new{name = 'rotater', toolIds = {tools.rotater}, sprite = tools.rotater.image}
P.boxCutterUnlock = P.unlock:new{name = 'boxCutter', toolIds = {tools.boxCutter}, sprite = tools.boxCutter.image}
P.laserUnlock = P.unlock:new{name = 'Boson breakthrough', toolIds = {tools.laser}, sprite = tools.laser.image}
P.ironManUnlock = P.unlock:new{name = 'ironMan', toolIds = {tools.ironMan}, sprite = tools.ironMan.image}
P.traderUnlock = P.unlock:new{name = 'trader', toolIds = {tools.trader}, sprite = tools.trader.image}
P.cardUnlock = P.unlock:new{name = "Cards", toolIds = {tools.card, tools.deckOfCards}, sprite = tools.card.image}
P.luckyPennyUnlock = P.unlock:new{name = "Lucky Penny", toolIds = {tools.luckyPenny}, sprite = tools.luckyPenny.image}
P.stealthBomberUnlock = P.unlock:new{name = "Stealth Bomber", toolIds = {tools.stealthBomber}, sprite = tools.stealthBomber.image}
P.meatUnlock = P.unlock:new{name = "Mmmm meaty", toolIds = {tools.meat}, sprite = tools.meat.image}
P.rottenMeatUnlock = P.unlock:new{name = "Mmmm rotten and meaty", toolIds = {tools.rottenMeat}, sprite = tools.rottenMeat.image}
P.explosiveMeatUnlock = P.unlock:new{name = "Mmmm explosive and meaty", toolIds = {tools.explosiveMeat}, sprite = tools.explosiveMeat.image}
P.nineLivesUnlock = P.unlock:new{name = "Mmmm more lives", toolIds = {tools.nineLives}, sprite = tools.nineLives.image}
P.foresightUnlock = P.unlock:new{name = "Foreskin", toolIds = {tools.foresight}, sprite = tools.foresight.image}
P.animalTrainerUnlock = P.unlock:new{name = "Train", toolIds = {tools.animalTrainer}, sprite = tools.animalTrainer.image}
P.animalEnslaverUnlock = P.unlock:new{name = "Enslave", toolIds = {tools.animalEnslaver}, sprite = tools.animalEnslaver.image}
P.armageddonUnlock = P.unlock:new{name = "Vanish", toolIds = {tools.armageddon}, sprite = tools.armageddon.image}
P.recycleBinUnlock = P.unlock:new{name = "Recycle!", toolIds = {tools.recycleBin}, sprite = tools.recycleBin.image}
P.sockUnlock = P.unlock:new{name = "Sock", toolIds = {tools.sock}, sprite = tools.sock.image}
P.xrayVisionUnlock = P.unlock:new{name = "X-Ray Vision", toolIds = {tools.xrayVision}, sprite = tools.xrayVision.image}
P.swapperUnlock = P.unlock:new{name = "Swapper no swapping", toolIds = {tools.swapper}, sprite = tools.swapper.image}

P.roomUnlock = P.unlock:new{name = 'room', roomIds = {"1"}}
P.beggarPartyUnlock = P.roomUnlock:new{name = 'Charity Event', roomIds = {"beggar_party"}, sprite = tiles.beggar.sprite}


--multi unlocks
P.bombsUnlock = P.unlock:new{name = 'Blow It Up', tileIds = {39,44,65,87}, toolIds = {tools.bomb}, sprite = tools.bomb.image}
P.puddleUnlock = P.tileUnlock:new{name = 'Oops, you spilled something', tileIds = {71}, toolIds = {tools.bucketOfWater}, sprite = tiles.puddle.sprite}
P.portalUnlock = P.tileUnlock:new{name = 'portals', tileIds = {56,57}, toolIds = {tools.portalPlacer}, sprite = tiles.entrancePortal.sprite}

P.dungeonUnlock = P.unlock:new{name = 'Dungeon', desc="", sprite = tiles.endDungeonEnter.sprite}
P.editorUnlock = P.unlock:new{name = 'Editor', desc="Editor Mode", sprite = tiles.editorStairs.sprite}


--P.floorUnlocks = {P.doorUnlock, P.catUnlock, P.boxesUnlock, P.unbreakableWires, P.mousetrapUnlock, P.wizardUnlock}
P.floorUnlocks = {nil,P.doorUnlock,nil,nil,P.fogUnlock,nil}

--characters
P[#P+1] = P.felixUnlock --done
P[#P+1] = P.frederickUnlock --done
P.frederickUnlock.unlocked = true
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
P[#P+1] = P.dragonUnlock
P[#P+1] = P.fourierUnlock
P[#P+1] = P.edenUnlock

--tiles
P[#P+1] = P.boxesUnlock --done
P[#P+1] = P.bombBoxUnlock

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
P[#P+1] = P.unbreakableElectricFloorUnlock
P[#P+1] = P.brownPitUnlock

P[#P+1] = P.catUnlock --done
P[#P+1] = P.ratUnlock
P[#P+1] = P.termiteUnlock
P[#P+1] = P.glueSnailUnlock
P[#P+1] = P.conductiveSnailUnlock

P[#P+1] = P.spikesUnlock
P[#P+1] = P.poweredEndUnlock --done
P[#P+1] = P.snailsUnlock --done
P[#P+1] = P.conductiveSnailsUnlock --done
P[#P+1] = P.glueSnailUnlock --done
P[#P+1] = P.bombBuddyUnlock --done
P[#P+1] = P.untriggeredPowerUnlock
P[#P+1] = P.playerBoxUnlock --done
P[#P+1] = P.animalBoxUnlock
P[#P+1] = P.conductiveBoxes --done
P[#P+1] = P.boomboxUnlock
P[#P+1] = P.iceBoxUnlock
P[#P+1] = P.ramUnlock --done
P[#P+1] = P.jackInTheBoxUnlock
P[#P+1] = P.dirtyGlassUnlock
P[#P+1] = P.fogUnlock --done
P[#P+1] = P.directionGatesUnlock
P[#P+1] = P.doorUnlock --done
P[#P+1] = P.infestedWoodUnlock
P[#P+1] = P.superStickyButtonUnlock
P[#P+1] = P.unbrickableStayButtonUnlock
--P[#P+1] = P.reinforcedGlassUnlock
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
P[#P+1] = P.laptopUnlock
P[#P+1] = P.roomRerollerUnlock
P[#P+1] = P.wireExtenderUnlock
P[#P+1] = P.doorstopUnlock
P[#P+1] = P.gasPourerUnlock
P[#P+1] = P.gasPourerXtremeUnlock
P[#P+1] = P.secretTeleporterUnlock
P[#P+1] = P.tunnelerUnlock
P[#P+1] = P.pickaxeUnlock
P[#P+1] = P.luckyBrickUnlock
P[#P+1] = P.luckySawUnlock
P[#P+1] = P.supertoolDoublerUnlock
P[#P+1] = P.lemonPartyUnlock
P[#P+1] = P.pitbullChangerUnlock
P[#P+1] = P.inflationUnlock
P[#P+1] = P.tileSwapperUnlock
P[#P+1] = P.stopwatchUnlock
P[#P+1] = P.growthHormonesUnlock
P[#P+1] = P.robotArmUnlock
P[#P+1] = P.wingsUnlock
P[#P+1] = P.portalPlacerUnlock
P[#P+1] = P.portalPlacerDoubleUnlock
P[#P+1] = P.heartTransplantUnlock
P[#P+1] = P.bucketOfWaterUnlock
P[#P+1] = P.axeUnlock
P[#P+1] = P.lubeUnlock
P[#P+1] = P.knifeUnlock
P[#P+1] = P.seedsUnlock
P[#P+1] = P.fishingPoleUnlock
P[#P+1] = P.amnesiaPillUnlock
P[#P+1] = P.blankToolUnlock
P[#P+1] = P.mindfulToolUnlock
P[#P+1] = P.rotaterUnlock
P[#P+1] = P.teleporterUnlock
P[#P+1] = P.boxCutterUnlock
P[#P+1] = P.unlock
P[#P+1] = P.ironManUnlock
P[#P+1] = P.cardUnlock
P[#P+1] = P.luckyPennyUnlock
P[#P+1] = P.stealthBomberUnlock
P[#P+1] = P.meatUnlock
P[#P+1] = P.rottenMeatUnlock
P[#P+1] = P.explosiveMeatUnlock
P[#P+1] = P.nineLivesUnlock
P[#P+1] = P.foresightUnlock
P[#P+1] = P.animalTrainerUnlock
P[#P+1] = P.animalEnslaverUnlock
P[#P+1] = P.armageddonUnlock
P[#P+1] = P.recycleBinUnlock
P[#P+1] = P.sockUnlock
P[#P+1] = P.xrayVisionUnlock
P[#P+1] = P.swapperUnlock

--rooms
P[#P+1] = P.beggarPartyUnlock --done

--multi unlocks
P[#P+1] = P.bombsUnlock --done
--P[#P+1] = P.puddleUnlock --done
P[#P+1] = P.portalUnlock --done

P[#P+1] = P.dungeonUnlock
P.dungeonUnlockId = #P
P[#P+1] = P.editorUnlock
P.editorUnlockId = #P
P[#P+1] = P.tutorialBeatenUnlock
P[#P+1] = P.mainGameUnlock

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




