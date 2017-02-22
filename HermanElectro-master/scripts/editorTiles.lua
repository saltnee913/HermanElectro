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

P.animalTiles[#P.animalTiles+1] = tiles.pitbullTile
P.animalTiles[#P.animalTiles+1] = tiles.catTile
P.animalTiles[#P.animalTiles+1] = tiles.glueSnailTile
P.animalTiles[#P.animalTiles+1] = tiles.bombBuddyTile
P.animalTiles[#P.animalTiles+1] = tiles.ratTile

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
P.basicTiles[#P.basicTiles+1] = tiles.cornerWire
P.basicTiles[#P.basicTiles+1] = tiles.button
P.basicTiles[#P.basicTiles+1] = tiles.stayButton
P.basicTiles[#P.basicTiles+1] = tiles.stickyButton
P.basicTiles[#P.basicTiles+1] = tiles.puddle

P.advancedTiles[#P.advancedTiles+1] = tiles.spikes
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
P.advancedTiles[#P.advancedTiles+1] = tiles.unbreakableCornerWire
P.advancedTiles[#P.advancedTiles+1] = tiles.dustyGlassWall
P.advancedTiles[#P.advancedTiles+1] = tiles.fog
P.advancedTiles[#P.advancedTiles+1] = tiles.accelerator
P.advancedTiles[#P.advancedTiles+1] = tiles.poweredAccelerator
P.advancedTiles[#P.advancedTiles+1] = tiles.infestedWood

return P