

P.unsticker = P.superTool:new{name = "Funsticker", description = "An artifact of the good old pre-sponge days.", baseRange = 1, image = 'Graphics/unsticker.png', quality = 1}
function P.unsticker:usableOnTile(tile)
	if tile:instanceof(tiles.stickyButton) and tile.down then return true end
	return false
end
function P.unsticker:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:unstick()
end

P.woodGrabber = P.superTool:new{name = "woodGrabber", description = "Removed.", baseRange = 1, image = 'Graphics/woodGrabber.png', quality = 3}
function P.woodGrabber:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and tile.destroyed
end
function P.woodGrabber:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	P.ladder.numHeld = P.ladder.numHeld+2
	room[tileY][tileX] = nil
end

P.corpseGrabber = P.superTool:new{name = "corpseGrabber", description = "Removed.", baseRange = 1, image = 'Graphics/corpseGrabber.png', quality = 3}
function P.corpseGrabber:usableOnAnimal(animal)
	return animal.dead and not animal.pickedUp
end
function P.corpseGrabber:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.pickedUp = true
	tools.giveToolsByReference({tools.sponge, tools.sponge, tools.sponge})
	local counter = 0
	for i = P.numNormalTools+1, #tools do
		if tools[i].numHeld>0 then
			counter = counter+1
		end
	end
	if counter>3 then self.numHeld = 0 end
end

P.broom = P.superTool:new{name = "Broom", description = "Gone with the wind.",image = 'Graphics/broom.png', quality = 1}
function P.broom:usableOnTile(tile)
	return tile:instanceof(tiles.slime) or tile:instanceof(tiles.conductiveSlime)
end
function P.broom:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX]=nil
end

P.endFinder = P.superTool:new{name = "End Finder", description = "Removed.",baseRange = 0, image = 'Graphics/endfinder.png', quality = 1}
function P.endFinder:usableOnNothing()
	return true
end
function P.endFinder:usableOnTile()
	return true
end
function P.endFinder:useToolTile()
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.endTile) then
				room[i][j].lit = true
			end
		end
	end
end
P.endFinder.useToolNothing = P.endFinder.useToolTile

--Removed
P.gateBreaker = P.superTool:new{name = "Gate Breaker", description = "Fuck logic.", baseRange = 1, image = 'Graphics/shovel.png', quality = 3}
function P.gateBreaker:usableOnTile(tile)
	return (tile:instanceof(tiles.gate) or tile:instanceof(tiles.notGate)) and not tile.destroyed
end
function P.gateBreaker:useToolTile(tile)
	self.numHeld = self.numHeld-1
	tile:destroy()
end
--Removed
P.conductiveBoxSpawner = P.boxSpawner:new{name = "Conductive Box Spawner", description = "", image = 'Graphics/conductiveBox.png', quality = 1}
function P.conductiveBoxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[5]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.conductiveBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[5]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

--Removed
P.boomboxSpawner = P.boxSpawner:new{name = "BoomboxSpawner", description = "Rock n' Roll", image = 'Graphics/boombox.png', quality = 1}
function P.boomboxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[6]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.boomboxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[6]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end


P.toolDoubler = P.superTool:new{name = "X2", description = "Xtweem-ly removed", baseRange = 0, image = 'Graphics/tooldoubler.png', quality = 5}
function P.toolDoubler:usableOnNothing()
	return true
end
function P.toolDoubler:useToolNothing()
	for i = 1, P.numNormalTools do
		tools[i].numHeld = tools[i].numHeld*2
	end
	self.numHeld = self.numHeld-1
end

P.suicideKing = P.superTool:new{name = "Suicide King", description = "Die", image = 'Graphics/suicideking.png', baseRange = 0, quality = 1}
function P.suicideKing:usableOnNothing()
	return true
end
function P.suicideKing:useToolNothing()
	self.numHeld = self.numHeld-1
	P.giveSupertools(3)
end
P.suicideKing.usableOnTile = P.suicideKing.usableOnNothing
P.suicideKing.useToolTile = P.suicideKing.useToolNothing

P.mask = P.superTool:new{name = "Mask(Fear effect, removed)", description = "The demon in the mask",
image = 'Graphics/Tools/mask.png', baseRange = 0, quality = 1}
function P.mask:usableOnTile(tile)
	return true
end
P.mask.usableOnNothing = P.mask.usableOnTile
function P.mask:useToolTile(tile)
	self.numHeld = self.numHeld-1
	player.attributes.fear = true
end
P.mask.useToolNothing = P.mask.useToolTile

P.buttonPlacer = P.superTool:new{name = "Button Placer", description = "", image = 'Graphics/buttonplacer.png', baseRange = 1, quality = 2}
function P.buttonPlacer:usableOnNothing()
	return true
end
function P.buttonPlacer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.button:new()
end

P.wallDungeonDetector = P.superTool:new{name = "Wall-to-English Translator", description="", image = 'Graphics/wtetranslator.png', description = "If these walls could talk....", baseRange = 0, quality = 2}
function P.wallDungeonDetector:usableOnNothing()
	return true
end
P.wallDungeonDetector.usableOnTile = P.wallDungeonDetector.usableOnNothing
function P.wallDungeonDetector:useToolNothing()
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.wall) and room[i][j].hidesDungeon then
				room[i][j].blueHighlighted = true
			end
		end
	end
end
P.wallDungeonDetector.useToolTile = P.wallDungeonDetector.useToolNothing

P.jackInTheBoxSpawner = P.boxSpawner:new{name = "Jack In The Box", description  = "REMOVED",image = 'Graphics/jackinthebox.png', quality = 2}
function P.jackInTheBoxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[10]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.jackInTheBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[10]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

P.coffee = P.superTool:new{name = "Coffee", description = "Caffeine rush",
image = 'Graphics/Tools/coffee.png', quality = 2, baseRange = 0}
function P.coffee:usableOnNothing()
	return true
end
P.coffee.usableOnTile = P.coffee.usableOnNothing
function P.coffee:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.fast = {fast = true, fastStep = false}
end
P.coffee.useToolTile = P.coffee.useToolNothing

P.tilePusher = P.superTool:new{name = "Daily Supplements", description = "Artificial strength", --[[or "Truly repulsive"]]image = 'Graphics/shovel.png', baseRange = 3, quality = 3}
function P.tilePusher:usableOnTile(tile, tileY, tileX)
	local useLoc = {x = 0, y = 0}
	if player.tileX==tileX then
		if player.tileY>tileY then
			useLoc = {x = tileX, y = tileY-1}
		else
			useLoc = {x = tileX, y = tileY+1}
		end
	else
		if player.tileX>tileX then
			useLoc = {x = tileX-1, y = tileY}
		else
			useLoc = {x = tileX+1, y = tileY}
		end
	end
	if room[useLoc.y]==nil then return false
	elseif useLoc.x>roomLength or useLoc.x<1 then return false
	elseif room[useLoc.y][useLoc.x]~=nil and room[useLoc.y][useLoc.x].blocksMovement then return false end
	for i = 1, #animals do
		if animals[i].tileX == useLoc.x and animals[i].tileY == useLoc.y then
			return false
		end
	end
	for i = 1, #pushables do
		if pushables[i].tileX == useLoc.x and pushables[i].tileY == useLoc.y then
			return false
		end
	end
	return true
end
function P.tilePusher:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	local useLoc = {x = 0, y = 0}
	if player.tileX==tileX then
		if player.tileY>tileY then
			useLoc = {x = tileX, y = tileY-1}
		else
			useLoc = {x = tileX, y = tileY+1}
		end
	else
		if player.tileX>tileX then
			useLoc = {x = tileX-1, y = tileY}
		else
			useLoc = {x = tileX+1, y = tileY}
		end
	end
	room[useLoc.y][useLoc.x] = tile
	room[tileY][tileX] = nil
end

P.spinningSword = P.superTool:new{name = "Spinning Sword", description = "Turnt", image = 'Graphics/spinningsword.png', quality = 1, baseRange = 1}
P.spinningSword.getToolableTiles = P.tool.getToolableTilesBox
function P.spinningSword:usableOnNothing()
	return true
end
P.spinningSword.usableOnTile = P.spinningSword.usableOnNothing
function P.spinningSword:useToolNothing()
	self.numHeld = self.numHeld-1

	local xdiff = {-1, 0, 1}
	local ydiff = {-1, 0, 1}
	for i = 1, 3 do
		for j = 1, 3 do
			local xloc = player.tileX+xdiff[i]
			local yloc = player.tileY+ydiff[j]
			if room[yloc]~=nil and room[yloc][xloc]~=nil then
				room[yloc][xloc]:destroy()
			end
		end
	end
	self.numHeld = self.numHeld-1
end
P.spinningSword.useToolTile = P.spinningSword.useToolNothing

--[[
UPGRADES:
saw --> superSaw (can cut concrete)
ladder --> superLadder (need to make)
wireCutters --> superWireCutters (can cut blue)
waterBottle --> superWaterBottle (can wet blue)
sponge --> superSponge (can sponge blue)
brick --> superBrick (can break unbreakable glass and brick blue)
gun --> superGun (radial range, need to make)
]]
P.tempUpgrade = P.superTool:new{name = "Temp Upgrade", description = "", image = 'Graphics/tempupgrade.png',
baseRange = 0, quality = 3}
function P.tempUpgrade:usableOnNothing()
	return true
end
P.tempUpgrade.usableOnTile = P.tempUpgrade.usableOnNothing
function P.tempUpgrade:useToolNothing()
	self.numHeld = self.numHeld-1

	player.attributes.upgradedToolUse = true
	tools.toolDisplayTimer.timeLeft = 0

	tools[1] = tools.superSaw
	tools.superSaw.numHeld = tools.saw.numHeld+tools.superSaw.numHeld
	tools[2] = tools.superLadder
	tools.superLadder.numHeld = tools.ladder.numHeld+tools.superLadder.numHeld
	tools[3] = tools.superWireCutters
	tools.superWireCutters.numHeld = tools.wireCutters.numHeld+tools.superWireCutters.numHeld
	tools[4] = tools.superWaterBottle
	tools.superWaterBottle.numHeld = tools.waterBottle.numHeld+tools.superWaterBottle.numHeld
	tools[5] = tools.superSponge
	tools.superSponge.numHeld = tools.sponge.numHeld+tools.superSponge.numHeld
	tools[6] = tools.superBrick
	tools.superBrick.numHeld = tools.brick.numHeld+tools.superBrick.numHeld
	tools[7] = tools.superGun
	tools.superGun.numHeld = tools.gun.numHeld+tools.superGun.numHeld

	local counter = tools.numNormalTools+1
	while counter<=#tools do
		for k = 1, 7 do
			if tools[counter]==tools[k] then
				table.remove(tools, counter)
				counter = counter-1
				break
			end
		end
		counter = counter+1
	end

	if tools.tempUpgrade.numHeld>0 then
		for i = 1, #tools do
			if tools[i]==tools.tempUpgrade then tool = i end
		end
	else tool = 0
	end

	specialTools = {}
	for i = 1, player.character.superSlots do
		specialTools[i] = 0
	end
	updateTools()
end
P.tempUpgrade.useToolTile = P.tempUpgrade.useToolNothing
function P.tempUpgrade:resetTools()
	P[1] = P.saw
	P[2] = P.ladder
	P[3] = P.wireCutters
	P[4] = P.waterBottle
	P[5] = P.sponge
	P[6] = P.brick
	P[7] = P.gun

	P:addTool(P.superSaw)
	tools.superSaw.numHeld = 0
	P:addTool(P.superLadder)
	tools.superLadder.numHeld = 0
	P:addTool(P.superWireCutters)
	tools.superWireCutters.numHeld = 0
	P:addTool(P.superWaterBottle)
	tools.superWaterBottle.numHeld = 0
	P:addTool(P.superSponge)
	tools.superSponge.numHeld = 0
	P:addTool(P.superBrick)
	tools.superBrick.numHeld = 0
	P:addTool(P.superGun)
	tools.superGun.numHeld = 0

end

P.permaUpgrade = P.superTool:new{name = "Perma Upgrade", description = "", image = 'Graphics/permaupgrade.png',
baseRange = 0, quality = 5}
function P.permaUpgrade:usableOnNothing()
	return true
end
P.permaUpgrade.usableOnTile = P.permaUpgrade.usableOnNothing
function P.permaUpgrade:useToolNothing()
	self.numHeld = self.numHeld-1

	tools.toolDisplayTimer.timeLeft = 0

	tools[1] = tools.superSaw
	tools.superSaw.numHeld = tools.saw.numHeld+tools.superSaw.numHeld
	tools[2] = tools.superLadder
	tools.superLadder.numHeld = tools.ladder.numHeld+tools.superLadder.numHeld
	tools[3] = tools.superWireCutters
	tools.superWireCutters.numHeld = tools.wireCutters.numHeld+tools.superWireCutters.numHeld
	tools[4] = tools.superWaterBottle
	tools.superWaterBottle.numHeld = tools.waterBottle.numHeld+tools.superWaterBottle.numHeld
	tools[5] = tools.superSponge
	tools.superSponge.numHeld = tools.sponge.numHeld+tools.superSponge.numHeld
	tools[6] = tools.superBrick
	tools.superBrick.numHeld = tools.brick.numHeld+tools.superBrick.numHeld
	tools[7] = tools.superGun
	tools.superGun.numHeld = tools.gun.numHeld+tools.superGun.numHeld

	local counter = tools.numNormalTools+1
	while counter<=#tools do
		for k = 1, 7 do
			if tools[counter]==tools[k] then
				table.remove(tools, counter)
				counter = counter-1
				break
			end
		end
		counter = counter+1
	end

	if tools.permaUpgrade.numHeld>0 then
		for i = 1, #tools do
			if tools[i]==tools.permaUpgrade then tool = i end
		end
	else tool = 0
	end

	specialTools = {}
	for i = 1, player.character.superSlots do
		specialTools[i] = 0
	end
	updateTools()
end
P.permaUpgrade.useToolTile = P.permaUpgrade.useToolNothing

P.ironWoman = P.superTool:new{name = "Iron Woman", description = "Closer....", image = 'Graphics/ironman.png',
baseRange = 3, quality = 4}
P.ironWoman.usableOnTile = P.tileMagnet.usableOnTile
function P.ironWoman:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	if player.tileY==tileY then
		if player.tileX<tileX then
			for i = tileX, roomLength do
				if room[tileY][i]~=nil then
					room[tileY][i-1] = room[tileY][i]
					room[tileY][i] = nil
				end
			end
		elseif player.tileX>tileX then
			for i = tileX, 1, -1 do
				if room[tileY][i]~=nil then
					room[tileY][i+1] = room[tileY][i]
					room[tileY][i] = nil
				end
			end
		end
	elseif player.tileX==tileX then
		if player.tileY<tileY then
			for i = tileY, roomHeight do
				if room[i][tileX]~=nil then
					room[i-1][tileX] = room[i][tileX]
					room[i][tileX] = nil
				end
			end
		elseif player.tileY>tileY then
			for i = tileY, 1, -1 do
				if room[i][tileX]~=nil then
					room[i+1][tileX] = room[i][tileX]
					room[i][tileX] = nil
				end
			end
		end
	end
end

P.santasHat = P.superTool:new{name = "Santa's Hat", description = "Gifts lay in store",
image = 'Graphics/giftBox.png',
baseRange = 0, quality = 3}
function P.santasHat:usableOnNothing()
	return true
end
P.santasHat.usableOnTile = P.santasHat.usableOnNothing
function P.santasHat:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.gifted = true
	for i = 1, #pushables do
		if pushables[i].name == "box" then
			local tileX = pushables[i].tileX
			local tileY = pushables[i].tileY
			pushables[i] = pushableList.giftBox:new()
			pushables[i].tileX = tileX
			pushables[i].tileY = tileY
		end
	end
end
P.santasHat.useToolTile = P.santasHat.useToolNothing

P.luckyCharm = P.superTool:new{name = "Medallion of Destruction", description = "With destruction comes fortune",
image = 'Graphics/luckyCharm.png',
baseRange = 0, quality = 4}
function P.luckyCharm:usableOnNothing()
	return true
end
P.luckyCharm.usableOnTile = P.luckyCharm.usableOnNothing
function P.luckyCharm:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.lucky = true
end
P.luckyCharm.useToolTile = P.luckyCharm.useToolNothing

P.trader = P.superTool:new{name = "Trader", description = "",
image = 'Graphics/trader.png', quality = 4, baseRange = 0}
function P.trader:usableOnNothing()
	return true
end
P.trader.usableOnTile = P.trader.usableOnNothing
function P.trader:useToolNothing()
	self.numHeld = self.numHeld-1
	tools.giveRandomTools(tools.coin.numHeld*2)
	tools.coin.numHeld = 0
end
P.trader.useToolTile = P.trader.useToolNothing

P.tileFlipper = P.superTool:new{name = "Tile Flipper", description = "", quality = -1, baseRange = 2,
image = 'Graphics/tileFlipper.png'}
function P.tileFlipper:usableOnTile()
	return true
end
function P.tileFlipper:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	local isVert = false
	if player.tileX==tileX then
		isVert = true
	end

	local tileRot = tile.rotation
	tileRot = tile.flipDirection(tileRot,isVert)
	while tileRot<0 do tileRot = tileRot+4 end
	tile:rotate(tileRot)
	if tile.overlay~=nil then
		local overRot = tile.overlay.rotation
		overRot = room[tileY][tileX].overlay.flipDirection(overRot, isVert)
		while overRot<0 do overRot = overRot+4 end
		tile.overlay:rotate(overRot)
	end
end

P.investmentBonus = P.superTool:new{name = "Investment Bonus", description = "A light purse is a heavy curse",
image = 'Graphics/shovel.png', baseRange = 0, quality = 2}
function P.investmentBonus:usableOnNothing()
	return true
end
function P.investmentBonus:useToolNothing()
	self.numHeld = self.numHeld-1
end
P.investmentBonus.usableOnTile = P.investmentBonus.usableOnNothing
P.investmentBonus.useToolTile = P.investmentBonus.useToolNothing

P.completionBonus = P.superTool:new{name = "Completion Bonus", description = "",
image = 'Graphics/shovel.png', baseRange = 0, quality = 3}
function P.completionBonus:usableOnNothing()
	return true
end
function P.completionBonus:useToolNothing()
	self.numHeld = self.numHeld-1
end
P.completionBonus.usableOnTile = P.completionBonus.usableOnNothing
P.completionBonus.useToolTile = P.completionBonus.useToolNothing

P.roomCompletionBonus = P.superTool:new{name = "Room Completion Bonus", description = "",
image = 'Graphics/shovel.png', baseRange = 0, quality = 5}
function P.roomCompletionBonus:usableOnNothing()
	return true
end
function P.roomCompletionBonus:useToolNothing()
	self.numHeld = self.numHeld-1
end
P.roomCompletionBonus.usableOnTile = P.roomCompletionBonus.usableOnNothing
P.roomCompletionBonus.useToolTile = P.roomCompletionBonus.useToolNothing




--P:addTool(P.woodGrabber)
--P:addTool(P.corpseGrabber)
--P:addTool(P.broom)
--P:addTool(P.endFinder)
--P:addTool(P.gateBreaker) --Keep
--P:addTool(P.gateBreaker)
--P:addTool(P.conductiveBoxSpawner)
--P:addTool(P.boomboxSpawner)
--P:addTool(P.toolDoubler)
--P:addTool(P.snowball)
--P:addTool(P.suicideKing) EXPLAIN THIS SHIT
--P:addTool(P.mask)
--P:addTool(P.buttonPlacer)
--P:addTool(P.wallDungeonDetector)--Keep
--P:addTool(P.wallDungeonDetector)
--P:addTool(P.jackInTheBoxSpawner)
--P:addTool(P.coffee) --No idea what this does
--P:addTool(P.tilePusher)
--P:addTool(P.spinningSword)
--P:addTool(P.superLadder)
--P:addTool(P.tempUpgrade)
--P:addTool(P.permaUpgrade)
--P:addTool(P.ironWoman)
--P:addTool(P.santasHat)
--P:addTool(P.luckyCharm)
--P:addTool(P.tileFlipper)
--P:addTool(P.investmentBonus)
--P:addTool(P.completionBonus)
--P:addTool(P.roomCompletionBonus)