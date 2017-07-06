require('scripts.object')
require('scripts.boundaries')
require('scripts.animals')
require('scripts.pushables')
tools = require('scripts.tools')

local P = {}

P.animalTiles = {}
P.boxTiles = {}
P.basicTiles = {}
P.advancedTiles = {}
P.shopTiles = {}
P.lateGameTiles = {}

P.animalTiles[#P.animalTiles+1] = tiles.pitbullTile
P.animalTiles[#P.animalTiles+1] = tiles.catTile
P.animalTiles[#P.animalTiles+1] = tiles.glueSnailTile
P.animalTiles[#P.animalTiles+1] = tiles.bombBuddyTile
P.animalTiles[#P.animalTiles+1] = tiles.ratTile
P.animalTiles[#P.animalTiles+1] = tiles.conductiveSnailTile
P.animalTiles[#P.animalTiles+1] = tiles.testChargedBossTile
P.animalTiles[#P.animalTiles+1] = tiles.mimicTile

P.boxTiles[#P.boxTiles+1] = tiles.boxTile
P.boxTiles[#P.boxTiles+1] = tiles.animalBoxTile
P.boxTiles[#P.boxTiles+1] = tiles.playerBoxTile
P.boxTiles[#P.boxTiles+1] = tiles.jackInTheBoxTile
P.boxTiles[#P.boxTiles+1] = tiles.boomboxTile
P.boxTiles[#P.boxTiles+1] = tiles.iceBoxTile
P.boxTiles[#P.boxTiles+1] = tiles.conductiveBoxTile
P.boxTiles[#P.boxTiles+1] = tiles.bombBoxTile
P.boxTiles[#P.boxTiles+1] = tiles.batteringRamTile
P.boxTiles[#P.boxTiles+1] = tiles.lampTile
P.boxTiles[#P.boxTiles+1] = tiles.accelerator
P.boxTiles[#P.boxTiles+1] = tiles.unpoweredAccelerator

P.basicTiles[#P.basicTiles+1] = tiles.endTile
P.basicTiles[#P.basicTiles+1] = tiles.wall
P.basicTiles[#P.basicTiles+1] = tiles.metalWall
P.basicTiles[#P.basicTiles+1] = tiles.concreteWall
P.basicTiles[#P.basicTiles+1] = tiles.glassWall
P.basicTiles[#P.basicTiles+1] = tiles.reinforcedGlass
P.basicTiles[#P.basicTiles+1] = tiles.electricFloor
P.basicTiles[#P.basicTiles+1] = tiles.poweredFloor
P.basicTiles[#P.basicTiles+1] = tiles.pit
P.basicTiles[#P.basicTiles+1] = tiles.powerSupply
P.basicTiles[#P.basicTiles+1] = tiles.notGate
P.basicTiles[#P.basicTiles+1] = tiles.andGate
P.basicTiles[#P.basicTiles+1] = tiles.wire
P.basicTiles[#P.basicTiles+1] = tiles.horizontalWire
P.basicTiles[#P.basicTiles+1] = tiles.tWire
P.basicTiles[#P.basicTiles+1] = tiles.cornerWire
P.basicTiles[#P.basicTiles+1] = tiles.button
P.basicTiles[#P.basicTiles+1] = tiles.stayButton
P.basicTiles[#P.basicTiles+1] = tiles.stickyButton
P.basicTiles[#P.basicTiles+1] = tiles.puddle
P.basicTiles[#P.basicTiles+1] = tiles.tunnel
P.basicTiles[#P.basicTiles+1] = tiles.upTunnel
P.basicTiles[#P.basicTiles+1] = tiles.vPoweredDoor
P.basicTiles[#P.basicTiles+1] = tiles.sign
P.basicTiles[#P.basicTiles+1] = tiles.hDoor
P.basicTiles[#P.basicTiles+1] = tiles.treasureTile
P.basicTiles[#P.basicTiles+1] = tiles.treasureTile2
P.basicTiles[#P.basicTiles+1] = tiles.treasureTile3
P.basicTiles[#P.basicTiles+1] = tiles.treasureTile4

P.advancedTiles[#P.advancedTiles+1] = tiles.spikes
P.advancedTiles[#P.advancedTiles+1] = tiles.breakablePit
P.advancedTiles[#P.advancedTiles+1] = tiles.entrancePortal
P.advancedTiles[#P.advancedTiles+1] = tiles.exitPortal
P.advancedTiles[#P.advancedTiles+1] = tiles.crossWire
P.advancedTiles[#P.advancedTiles+1] = tiles.unbreakableWire
P.advancedTiles[#P.advancedTiles+1] = tiles.unbreakableHorizontalWire
P.advancedTiles[#P.advancedTiles+1] = tiles.unbreakableTWire
P.advancedTiles[#P.advancedTiles+1] = tiles.unbreakableCornerWire
P.advancedTiles[#P.advancedTiles+1] = tiles.unbreakableElectricFloor
P.advancedTiles[#P.advancedTiles+1] = tiles.superStickyButton
P.advancedTiles[#P.advancedTiles+1] = tiles.unbrickableStayButton
P.advancedTiles[#P.advancedTiles+1] = tiles.dustyGlassWall
P.advancedTiles[#P.advancedTiles+1] = tiles.fog
P.advancedTiles[#P.advancedTiles+1] = tiles.infestedWood
P.advancedTiles[#P.advancedTiles+1] = tiles.redBeggar
P.advancedTiles[#P.advancedTiles+1] = tiles.greenBeggar
P.advancedTiles[#P.advancedTiles+1] = tiles.blueBeggar
P.advancedTiles[#P.advancedTiles+1] = tiles.goldBeggar
P.advancedTiles[#P.advancedTiles+1] = tiles.blackBeggar
P.advancedTiles[#P.advancedTiles+1] = tiles.whiteBeggar
P.advancedTiles[#P.advancedTiles+1] = tiles.elevator
P.advancedTiles[#P.advancedTiles+1] = tiles.delevator
P.advancedTiles[#P.advancedTiles+1] = tiles.halfWall
P.advancedTiles[#P.advancedTiles+1] = tiles.tallWall
P.advancedTiles[#P.advancedTiles+1] = tiles.poweredEnd
P.advancedTiles[#P.advancedTiles+1] = tiles.untriggeredPowerSupply
P.advancedTiles[#P.advancedTiles+1] = tiles.mousetrap
P.advancedTiles[#P.advancedTiles+1] = tiles.mushroom
P.advancedTiles[#P.advancedTiles+1] = tiles.endDungeonEnter
P.advancedTiles[#P.advancedTiles+1] = tiles.powerTriggeredBomb
P.advancedTiles[#P.advancedTiles+1] = tiles.bossTile
P.advancedTiles[#P.advancedTiles+1] = tiles.tree
P.advancedTiles[#P.advancedTiles+1] = tiles.spikes
P.advancedTiles[#P.advancedTiles+1] = tiles.gasPuddle
P.advancedTiles[#P.advancedTiles+1] = tiles.bed
P.advancedTiles[#P.advancedTiles+1] = tiles.characterWall

P.lateGameTiles[#P.lateGameTiles+1] = tiles.movingSpike
P.lateGameTiles[#P.lateGameTiles+1] = tiles.movingSpikeFast
P.lateGameTiles[#P.lateGameTiles+1] = tiles.movingSpikeSlow
P.lateGameTiles[#P.lateGameTiles+1] = tiles.movingSpikeCustom
P.lateGameTiles[#P.lateGameTiles+1] = tiles.dungeonKeyGate
P.lateGameTiles[#P.lateGameTiles+1] = tiles.dungeonSuper
P.lateGameTiles[#P.lateGameTiles+1] = tiles.openDungeon
P.lateGameTiles[#P.lateGameTiles+1] = tiles.dungeonKey
P.lateGameTiles[#P.lateGameTiles+1] = tiles.spotlightTile
P.lateGameTiles[#P.lateGameTiles+1] = tiles.slowSpotlightTile
P.lateGameTiles[#P.lateGameTiles+1] = tiles.fastSpotlightTile
P.lateGameTiles[#P.lateGameTiles+1] = tiles.robotGuardTile
P.lateGameTiles[#P.lateGameTiles+1] = tiles.laserBlock
P.lateGameTiles[#P.lateGameTiles+1] = tiles.baseBossTile

P.shopTiles[#P.shopTiles+1] = tiles.toolTaxTile
P.shopTiles[#P.shopTiles+1] = tiles.toolTile
P.shopTiles[#P.shopTiles+1] = tiles.supertoolQ1
P.shopTiles[#P.shopTiles+1] = tiles.supertoolQ2
P.shopTiles[#P.shopTiles+1] = tiles.supertoolQ3
P.shopTiles[#P.shopTiles+1] = tiles.supertoolQ4
P.shopTiles[#P.shopTiles+1] = tiles.supertoolQ5
P.shopTiles[#P.shopTiles+1] = tiles.sawTile
P.shopTiles[#P.shopTiles+1] = tiles.ladderTile
P.shopTiles[#P.shopTiles+1] = tiles.wireCuttersTile
P.shopTiles[#P.shopTiles+1] = tiles.waterBottleTile
P.shopTiles[#P.shopTiles+1] = tiles.spongeTile
P.shopTiles[#P.shopTiles+1] = tiles.brickTile
P.shopTiles[#P.shopTiles+1] = tiles.gunTile
P.shopTiles[#P.shopTiles+1] = tiles.shopkeeperTile


return P