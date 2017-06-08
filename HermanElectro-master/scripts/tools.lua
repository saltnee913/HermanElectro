local P = {}
tools = P

P.toolDisplayTimer = {base = 1.5, timeLeft = 0}
P.toolsShown = {}


function P.updateTimer(dt)
	P.toolDisplayTimer.timeLeft = P.toolDisplayTimer.timeLeft - dt
end

--displays tools above player, takes input as [1,1,6,6,5,5] = 2 saw, 2 brick, 2 sponge
function P.displayTools(toolArray)
	if P.toolDisplayTimer.timeLeft<=0 then
		P.toolsShown = {}
	end
	P.toolDisplayTimer.timeLeft = P.toolDisplayTimer.base
	for i = 1, #toolArray do
		P.toolsShown[#P.toolsShown+1] = toolArray[i]
	end

	for i = 1, #P.toolsShown do
		if P.toolsShown[i] ~= nil and P.toolsShown[i]>tools.numNormalTools then
			text.setToolDisplay(tools[P.toolsShown[i]])
		end
	end
end

--same as displayTools but takes input as [0,0,1,0,0,1,2] = 1 wire-cutters, 1 brick, 2 gun (same format as itemsNeeded)
function P.displayToolsByArray(toolArray)
	local revisedToolArray = {}
	for i = 1, P.numNormalTools do
		for toolNum = 1, toolArray[i] do
			revisedToolArray[#revisedToolArray+1] = i
		end
	end
	P.displayTools(revisedToolArray)
end

function P.areSupersFull()
	local superCount = 0
	for i = tools.numNormalTools+1, #tools do
		if tools[i].numHeld > 0 then
			superCount = superCount + 1
		end
	end
	return (superCount >= 3)
end

function P.giveTools(toolArray)
	local toolsToDisp = {}
	for i = 1, #toolArray do
		if toolArray[i] <= tools.numNormalTools or tools[toolArray[i]].numHeld ~= 0 or not tools.areSupersFull() then
			tools[toolArray[i]]:giveOne()
			toolsToDisp[#toolsToDisp+1] = toolArray[i]

			if toolArray[i] > tools.numNormalTools and player.supersHeld[toolArray[i]] ~= true then
				player.supersHeld.total = player.supersHeld.total + 1
				if player.supersHeld.total >= 10 then
					unlocks.unlockUnlockableRef(unlocks.scientistUnlock)
				end
				player.supersHeld[toolArray[i]] = true
			end
		end
	end

	if tools.portalPlacer.numHeld>1 then
		unlocks.unlockUnlockableRef(unlocks.portalPlacerDoubleUnlock)
	end
	if tools.opPotion.numHeld>1 then
		unlocks.unlockUnlockableRef(unlocks.ironManUnlock)
	end

	--[[if tools.revive.numHeld>=9 then
		unlocks.unlockUnlockableRef(unlocks.suicideKingUnlock)
	end]]
	P.displayTools(toolsToDisp)
	updateTools()
end

--for basics only
function P.giveToolsByArray(toolArray)
	--check for tools that prevent tool drops
	if tools.demonHoof.numHeld>0 or tools.demonFeather.numHeld>0 then
		return
	end

	--passive ability of discountTag
	for k = 1, tools.discountTag.numHeld+1 do
		for i = 1, P.numNormalTools do
			tools[i].numHeld = tools[i].numHeld + toolArray[i]
		end
	end
	P.displayToolsByArray(toolArray)
	updateTools()
end

function P.giveToolsByReference(toolArray)
	local toolsToGive = {}
	for i = 1, #tools do
		for j = 1, #toolArray do
			if toolArray[j].name==tools[i].name then
				toolsToGive[#toolsToGive+1] = i
			end
		end
	end
	P.giveTools(toolsToGive)
end

function P.dropTool(toolReference, tileY, tileX)
	unlocks = require('scripts.unlocks')
	unlockedSupertools = unlocks.getUnlockedSupertools()
	if not unlockedSupertools[toolReference.toolid] or toolReference.isDisabled then
		return false
	end
	if room[tileY][tileX]==nil or room[tileY][tileX]:usableOnNothing() then
		room[tileY][tileX] = tiles.supertoolTile:new()
		room[tileY][tileX].tool = toolReference
		room[tileY][tileX]:updateSprite()
	else
		room[tileY][tileX].overlay = tiles.supertoolTile:new()
		room[tileY][tileX].overlay.tool = toolReference
		room[tileY][tileX].overlay:updateSprite()
	end
	return true
end

function P.giveRandomTools(numTools,numSupers,qualities)
	if numSupers == nil then numSupers = 0 end
	local toolsToGive = {}
	for i = 1, numTools do
		slot = P.chooseNormalTool()
		toolsToGive[#toolsToGive+1] = slot
	end
	local supersToGive = P.getSupertools(numSupers,qualities)
	for i = 1, numSupers do
		toolsToGive[#toolsToGive+1] = supersToGive[i]
	end
	P.giveTools(toolsToGive)
end

function P.chooseNormalTool()
	return util.random(tools.numNormalTools,'toolDrop')
end

function P.updateToolableTiles(toolid)
	if toolid ~= 0 then
		P.toolableAnimals = tools[toolid]:getToolableAnimals()
		P.toolableTiles = tools[toolid]:getToolableTiles()
		P.toolablePushables = tools[toolid]:getToolablePushables()
	else
		P.toolableAnimals = nil
		P.toolableTiles = nil
		P.toolablePushables = nil
	end
end

function P.addUseStat(toolid)
	if tools[toolid]~=nil then
		stats.incrementStat(tools[toolid].name..'Uses')
	end
end

--prioritizes animals, matters if we want a tool to work on both animals and tiles
function P.useToolDir(toolid, dir)
	if P.toolablePushables~=nil and P.toolablePushables[dir][1]~=nil and tools[toolid]~=nil then
		tools[toolid]:useToolPushable(P.toolablePushables[dir][1])
	end
	if P.toolableAnimals ~= nil and P.toolableAnimals[dir][1] ~= nil and tools[toolid]~=nil then
		tools[toolid]:useToolAnimal(P.toolableAnimals[dir][1])
		P.addUseStat(toolid)
		return true
	end
	if P.toolableTiles ~= nil and P.toolableTiles[dir][1] ~= nil then
		if room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x] == nil
			or room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x]:usableOnNothing(P.toolableTiles[dir][1].y,P.toolableTiles[dir][1].x) then
			tools[toolid]:useToolNothing(P.toolableTiles[dir][1].y, P.toolableTiles[dir][1].x)
		else
			--sometimes next line has  error "attempt to index a nil value"
			if tools[toolid]~=nil and room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x]~=nil then
				tools[toolid]:useToolTile(room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x], P.toolableTiles[dir][1].y, P.toolableTiles[dir][1].x)
			end
		end
		P.addUseStat(toolid)
		return true
	end
	return false
end

function P.useToolLoc(mouseY, mouseX, tileY, tileX)
	if tools.useToolAnimal(mouseY, mouseX) then
		return true
	elseif tools.useToolPushable(mouseY, mouseX, tileY, tileX) then
		return true
	else
		return tools.useToolTile(tileY, tileX)
	end
end
function P.useToolTile(tileY, tileX)
	if P.toolableTiles ~= nil then
		for dir = 1, 5 do
			for i = 1, #(P.toolableTiles[dir]) do
				if P.toolableTiles[dir][i].y == tileY and P.toolableTiles[dir][i].x == tileX then
					if room[tileY][tileX] == nil or room[tileY][tileX]:usableOnNothing(tileY, tileX) then
						tools[tool]:useToolNothing(tileY, tileX)
					else
						tools[tool]:useToolTile(room[tileY][tileX], tileY, tileX)
					end
					P.addUseStat(tool)
					return true
				end
			end
		end
	end
	return false
end
function P.useToolAnimal(mouseY, mouseX)
	if P.toolableAnimals ~= nil then
		for dir = 1, 5 do
			for i = 1, #(P.toolableAnimals[dir]) do
				local animal = P.toolableAnimals[dir][i]
				local animalScale = animal.scale
				local drawx = animal:getDrawX()
				local drawy = animal:getDrawY()
				if mouseX>=drawx and mouseX<=drawx+util.getImage(animal.sprite):getWidth()*animalScale
				and mouseY>=drawy and mouseY<=drawy+util.getImage(animal.sprite):getHeight()*animalScale then
					tools[tool]:useToolAnimal(P.toolableAnimals[dir][i])
					P.addUseStat(tool)
					return true
				end
			end
		end
	end
	return false
end
function P.useToolPushable(mouseY, mouseX, tileY, tileX)
	if P.toolablePushables ~= nil then
		for dir = 1, 5 do
			for i = 1, #(P.toolablePushables[dir]) do
				if P.toolablePushables[dir][i].tileY == tileY and P.toolablePushables[dir][i].tileX == tileX then
					tools[tool]:useToolPushable(P.toolablePushables[dir][i])
					P.addUseStat(tool)
					return true
				end
			end
		end
	end
	return false
end

P.tool = Object:new{name = 'test', useWithArrowKeys = true, numHeld = 0, baseRange = 1, image='Graphics/saw.png'}
function P.tool:usableOnTile()
	return false
end
function P.tool:usableOnAnimal()
	return false
end
function P.tool:usableOnPushable()
	return false
end
function P.tool:usableOnNothing()
	return false
end
function P.tool:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:destroy()
end
function P.tool:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	animal:kill()
end
function P.tool:useToolPushable(pushable)
end
function P.tool:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
end
function P.tool:checkDeath()
	return true
end
--says if tool works on "nothing" tiles as if they are legitimate
function P.tool:nothingIsSomething()
	return false
end
function P.tool:resetTool()
end
function P.tool:getLastTool()
	return {tools[P.lastToolUsed]}
end
function P.tool:giveOne()
	self.numHeld = self.numHeld+1
end
function P.tool:getTileImage()
	return self.image
end
function P.tool:getDisplayImage()
	return self.image
end

--returns a table of tables of coordinates by direction
function P.tool:getToolableTiles()
	local usableTiles = {}
	for dir = 1, 5 do
		usableTiles[dir] = {}
		local offset
		if dir == 5 then
			offset = {y = 0, x = 0}
		else
			offset = util.getOffsetByDir(dir)
		end
		if dir==5 and self.range==0 then
			local tileToCheck = {y = player.tileY, x = player.tileX}
			if room[tileToCheck.y]~=nil then
				if ((room[tileToCheck.y][tileToCheck.x] == nil or room[tileToCheck.y][tileToCheck.x]:usableOnNothing(tileToCheck.y, tileToCheck.x)) and player.elevation<=0 and (tileToCheck.x>0 and tileToCheck.x<=roomLength) and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
				or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], tileToCheck.y, tileToCheck.x) and
				player.elevation<=math.abs(room[tileToCheck.y][tileToCheck.x]:getHeight())) then
					if litTiles[tileToCheck.y][tileToCheck.x]~=0 then
						usableTiles[5][#(usableTiles[5])+1] = tileToCheck
					end
				end
			end
		else
			for dist = 1, self.range+player.attributes.extendedRange do
				local tileToCheck = {y = player.tileY + offset.y*dist, x = player.tileX + offset.x*dist}
				if room[tileToCheck.y]~=nil then
					if dir==5 and dist>1 then break end
					if ((room[tileToCheck.y][tileToCheck.x] == nil or room[tileToCheck.y][tileToCheck.x]:usableOnNothing(tileToCheck.y, tileToCheck.x)) and player.elevation<=0 and (tileToCheck.x>0 and tileToCheck.x<=roomLength) and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
					or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], tileToCheck.y, tileToCheck.x) and
					player.elevation<=math.abs(room[tileToCheck.y][tileToCheck.x]:getHeight())) then
						if litTiles[tileToCheck.y][tileToCheck.x]~=0 then
							usableTiles[dir][#(usableTiles[dir])+1] = tileToCheck
						end
					end
					if room[tileToCheck.y][tileToCheck.x] ~= nil and room[tileToCheck.y][tileToCheck.x].blocksProjectiles and not player.attributes.tall then
						break
					end
				end
			end
		end
	end
	return usableTiles
end

--for tools that can be used in more than four basic directions
function P.tool:getToolableTilesBox()
	local usableTiles = {{},{},{},{},{}}
	dir = 1
	for i=-1*(self.range+player.attributes.extendedRange), self.range+player.attributes.extendedRange do
		for j = -1*(self.range+player.attributes.extendedRange), self.range+player.attributes.extendedRange do
			local offset = {x = i, y = j}
			local tileToCheck = {y = player.tileY + offset.y, x = player.tileX + offset.x}
			if tileToCheck.x<=0 or tileToCheck.x>roomLength then break end
			if room[tileToCheck.y]~=nil then
				local dist = offset.y+offset.x
				if ((room[tileToCheck.y][tileToCheck.x] == nil or room[tileToCheck.y][tileToCheck.x]:usableOnNothing(tileToCheck.y, tileToCheck.x)) and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
				or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], tileToCheck.y, tileToCheck.x) and
				player.elevation<=room[tileToCheck.y][tileToCheck.x]:getHeight()) then
					if math.abs(tileToCheck.y-player.tileY)+math.abs(tileToCheck.x-player.tileX)<=self.range then
						if litTiles[tileToCheck.y][tileToCheck.x]~=0 then
							usableTiles[dir][#(usableTiles[dir])+1] = tileToCheck
						end
					end
				end
			end
		end
	end
	return usableTiles
end

--returns a table of tables of the animals themselves by direction
function P.tool:getToolableAnimals()
	local usableAnimals = {}
	local closestAnimals = {{dist = 1000}, {dist = 1000}, {dist = 1000}, {dist = 1000}, {dist = 1000}}
	for animalIndex = 1, #animals do
		local animal = animals[animalIndex]
		--[[if animal.tileY == player.tileY and animal.tileX == player.tileX and self:usableOnAnimal(animal) then
			usableAnimals[1] = {animal}
			for i = 2, 4 do usableAnimals[i] = usableAnimals[1] end
			return usableAnimals
		end]]
		if self:usableOnAnimal(animal) and player.elevation==animal.elevation then
			if animal.tileX == player.tileX and animal.tileY == player.tileY then
				closestAnimals[5] = {dist = 0, ani = animal}
			else
				if animal.tileX == player.tileX then
					if player.tileY > animal.tileY then
						if player.tileY-animal.tileY < closestAnimals[1].dist then
							closestAnimals[1] = {dist = player.tileY - animal.tileY, ani = animal}
						end
					else
						if animal.tileY-player.tileY < closestAnimals[3].dist then
							closestAnimals[3] = {dist = animal.tileY - player.tileY, ani = animal}
						end
					end
				elseif animal.tileY == player.tileY then
					if player.tileX > animal.tileX then
						if player.tileX - animal.tileX < closestAnimals[4].dist then
							closestAnimals[4] = {dist = player.tileX - animal.tileX, ani = animal}
						end
					else
						if animal.tileX - player.tileX < closestAnimals[2].dist then
							closestAnimals[2] = {dist = animal.tileX - player.tileX, ani = animal}
						end
					end
				end
			end
		end
	end
	for dir = 1, 5 do
		usableAnimals[dir] = {}
		if closestAnimals[dir].dist <= self.range+player.attributes.extendedRange then
			local offset
			if dir == 5 then
				offset = {y = 0, x = 0}
			else
				offset = util.getOffsetByDir(dir)
			end
			local isBlocked = false
			for dist = 1, closestAnimals[dir].dist do
				if room[player.tileY + offset.y*dist] ~= nil then
					local tile = room[player.tileY + offset.y*dist][player.tileX + offset.x*dist]
					if tile~=nil and tile:getHeight()>player.elevation and tile.blocksProjectiles  and not player.attributes.tall then
						isBlocked = true
						break
					end
				end
			end
			if not isBlocked and litTiles[closestAnimals[dir].ani.tileY][closestAnimals[dir].ani.tileX]~=0 then
				usableAnimals[dir][#(usableAnimals[dir]) + 1] = closestAnimals[dir].ani
			end
		end
	end
	return usableAnimals
end

--for tools that can be used in more than four basic directions
function P.tool:getToolableAnimalsBox()
	local usableAnimals = {{},{},{},{},{}}
	for animalIndex = 1, #animals do
		if player.elevation == animals[animalIndex].elevation and not animals[animalIndex].dead and math.abs(animals[animalIndex].tileY - player.tileY)+math.abs(animals[animalIndex].tileX - player.tileX)<=self.range+player.attributes.extendedRange then
			if litTiles[animals[animalIndex].tileY][animals[animalIndex].tileX]~=0 then
				usableAnimals[1][#usableAnimals[1]+1] = animals[animalIndex]
			end
		end
	end
	return usableAnimals
end

function P.tool:getToolablePushables()
	if player.elevation~=0 then return {{},{},{},{},{}} end
	local usablePushables = {}
	local closestPushables = {{dist = 1000}, {dist = 1000}, {dist = 1000}, {dist = 1000}, {dist = 1000}}
	for pushableIndex = 1, #pushables do
		local pushable = pushables[pushableIndex]
		--[[if pushable.tileY == player.tileY and pushable.tileX == player.tileX and self:usableOnpushable(pushable) then
			usablepushables[1] = {pushable}
			for i = 2, 4 do usablepushables[i] = usablepushables[1] end
			return usablepushables
		end]]
		if self:usableOnPushable(pushable) then
			if pushable.tileX == player.tileX and pushable.tileY == player.tileY then
				closestPushables[5] = {dist = 0, ani = pushable}
			else
				if pushable.tileX == player.tileX then
					if player.tileY > pushable.tileY then
						if player.tileY-pushable.tileY < closestPushables[1].dist then
							closestPushables[1] = {dist = player.tileY - pushable.tileY, ani = pushable}
						end
					else
						if pushable.tileY-player.tileY < closestPushables[3].dist then
							closestPushables[3] = {dist = pushable.tileY - player.tileY, ani = pushable}
						end
					end
				elseif pushable.tileY == player.tileY then
					if player.tileX > pushable.tileX then
						if player.tileX - pushable.tileX < closestPushables[4].dist then
							closestPushables[4] = {dist = player.tileX - pushable.tileX, ani = pushable}
						end
					else
						if pushable.tileX - player.tileX < closestPushables[2].dist then
							closestPushables[2] = {dist = pushable.tileX - player.tileX, ani = pushable}
						end
					end
				end
			end
		end
	end
	for dir = 1, 5 do
		usablePushables[dir] = {}
		if closestPushables[dir].dist <= self.range+player.attributes.extendedRange then
			local offset
			if dir == 5 then
				offset = {y = 0, x = 0}
			else
				offset = util.getOffsetByDir(dir)
			end
			local isBlocked = false
			for dist = 1, closestPushables[dir].dist do
				if room[player.tileY + offset.y*dist] ~= nil then
					local tile = room[player.tileY + offset.y*dist][player.tileX + offset.x*dist]
					if tile~=nil and tile.blocksProjectiles  and not player.character.tall then
						isBlocked = true
						break
					end
				end
			end
			if not isBlocked and litTiles[closestPushables[dir].ani.tileY][closestPushables[dir].ani.tileX]~=0 then
				usablePushables[dir][#(usablePushables[dir]) + 1] = closestPushables[dir].ani
			end
		end
	end
	return usablePushables
end

--for tools that can be used in more than four basic directions
function P.tool:getToolablePushablesBox()
	if player.elevation~=0 then return {{},{},{},{},{}} end
	for pushableIndex = 1, #pushables do
		if not pushables[pushableIndex].dead and math.abs(pushables[pushableIndex].tileY - player.tileY)+math.abs(pushables[pushableIndex].tileX - player.tileX)<=self.range+player.attributes.extendedRange then
			if litTiles[pushables[pushableIndex].tileY][pushables[pushableIndex].tileX]~=0 then
				usablePushables[1][#usablePushables[1]+1] = pushables[pushableIndex]
			end
		end
	end
	return usablePushables
end

P.saw = P.tool:new{name = 'saw', image = 'Graphics/Tools/saw.png'}
function P.saw:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and not tile.destroyed and tile.sawable
end
function P.saw:usableOnPushable(pushable)
	return not pushable.destroyed and pushable.sawable
end
function P.saw:useToolPushable(pushable)
	self.numHeld = self.numHeld - 1
	stats.incrementStat("boxesSawed")
	pushable:destroy()
end

P.ladder = P.tool:new{name = 'ladder', image = 'Graphics/Tools/ladder.png'}
function P.ladder:usableOnTile(tile)
	if not tile.laddered then
		if tile:instanceof(tiles.breakablePit) and tile.strength == 0 then
			return true
		elseif tile:instanceof(tiles.poweredFloor) or tile:instanceof(tiles.pit) then
			return true
		end
	end
	return false
end
function P.ladder:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:ladder()
	stats.incrementStat("pitsLaddered")
end
function P.ladder:usableOnNothing()
	return true
end
function P.ladder:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	room[tileY][tileX] = tiles.ladder:new()
end

P.wireCutters = P.tool:new{name = 'wire-cutters', image = 'Graphics/Tools/wireCutters.png'}
function P.wireCutters:usableOnNonOverlay(tile)
	return not tile.destroyed and ((tile:instanceof(tiles.wire) and not tile:instanceof(tiles.unbreakableWire))
	or tile:instanceof(tiles.conductiveGlass) or tile:instanceof(tiles.reinforcedConductiveGlass) or (tile:instanceof(tiles.electricFloor) and not tile:instanceof(tiles.unbreakableElectricFloor)))
end
function P.wireCutters:usableOnTile(tile)
	return self:usableOnNonOverlay(tile) or (tile.overlay~=nil and self:usableOnNonOverlay(tile.overlay))
end
function P.wireCutters:usableOnPushable(pushable)
	return pushable.conductive and not pushable:instanceof(pushableList.jackInTheBox)
end

function P.wireCutters:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.conductiveGlass) or tile:instanceof(tiles.reinforcedConductiveGlass) then tile.canBePowered = false
	elseif (tile.overlay~=nil and self:usableOnNonOverlay(tile.overlay)) then
		tile.overlay:destroy()
		if tile.overlay:instanceof(tiles.crossWire) then
			unlocks.unlockUnlockableRef(unlocks.cornerRotaterUnlock)
		end
	else
		tile:destroy()
		if tile:instanceof(tiles.crossWire) then
			unlocks.unlockUnlockableRef(unlocks.cornerRotaterUnlock)
		end
	end
	if tile:instanceof(tiles.wire) then
		stats.incrementStat('wiresCut')
	end

end
function P.wireCutters:useToolPushable(pushable)
	pushable.conductive = false
end

P.waterBottle = P.tool:new{name = 'water-bottle', image = 'Graphics/waterbottle.png'}
function P.waterBottle:usableOnTile(tile)
	if not tile.destroyed and ((tile:instanceof(tiles.powerSupply) and not tile:instanceof(tiles.notGate) and not tile:instanceof(tiles.unbreakablePowerSupply)) or (tile:instanceof(tiles.electricFloor) and not tile:instanceof(tiles.unbreakableElectricFloor)) or tile:instanceof(tiles.untriggeredPowerSupply) or tile:instanceof(tiles.untriggeredPowerSupplyTimer)) then
		return true
	--[[elseif not tile.laddered then
		if tile:instanceof(tiles.breakablePit) and tile.strength == 0 then
			return true
		elseif tile:instanceof(tiles.poweredFloor) or tile:instanceof(tiles.pit) then
			return true
		end]]
	elseif tile:instanceof(tiles.tree) and tile.level<3 then
		return true
	end
	return false
end
function P.waterBottle:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.tree) then
		tile.level = tile.level+1
		tile.sawable = true
		tile:updateSprite()
		return
	end
	if not tile.destroyed then
		tile:destroy()
	--[[elseif not tile.laddered then
		if tile:instanceof(tiles.breakablePit) and tile.strength == 0 then
			tile:ladder()
		elseif tile:instanceof(tiles.poweredFloor) or tile:instanceof(tiles.pit) then
			tile:ladder()
		end]]
	end
end
function P.waterBottle:usableOnNothing()
	return true
end
function P.waterBottle:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	if room[tileY][tileX]~=nil then
		local t = room[tileY][tileX]
		if t:instanceof(tiles.wire) or t:instanceof(tiles.electricFloor) then
			unlocks.unlockUnlockableRef(unlocks.wireExtenderUnlock)
		end
	end
	room[tileY][tileX] = tiles.puddle:new()
end

P.brick = P.tool:new{name = 'brick', baseRange = 3, image = 'Graphics/brick.png'}
function P.brick:usableOnTile(tile, tileY, tileX)
	local dist = math.abs(player.tileY - tileY) + math.abs(player.tileX - tileX)
	if tile.destroyed then return end
	if not tile.bricked and tile:instanceof(tiles.button) and not tile:instanceof(tiles.superStickyButton)
		and not tile:instanceof(tiles.unbrickableStayButton) and dist <= 3 then
		return true
	elseif not tile.destroyed and tile:instanceof(tiles.glassWall) then
		return true
	elseif tile:instanceof(tiles.reinforcedGlass) and tile.cracked then
		return true
	--[[elseif tile:instanceof(tiles.hDoor) then
		return true]]
	elseif tile:instanceof(tiles.mousetrap) and not tile.bricked then
		return true
	end
	return false
end
function P.brick:usableOnPushable(pushable)
	return (not pushable.destroyed) and pushable:instanceof(pushableList.iceBox)
end
function P.brick:useToolPushable(pushable)
	pushable:destroy()
end
function P.brick:usableOnAnimal(animal)
	return not animal.dead
end
function P.brick:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.glassWall) or tile:instanceof(tiles.hDoor) or tile:instanceof(tiles.reinforcedGlass) then
		tile:destroy()
		if tile:instanceof(tiles.glassWall) or tile:instanceof(tiles.reinforcedGlass) then
			stats.incrementStat('glassWallsBricked')
		end
	else
		tile:lockInState(true)
		if tile:instanceof(tiles.stayButton) then
			stats.incrementStat('stayButtonsBricked')
		end
		--unlocks:unlockUnlockableRef(unlocks.stayButtonUnlock)
	end
end
function P.brick:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+1
	stats.incrementStat("animalsBricked")
	--[[if animal.waitCounter>=3 then
		unlocks.unlockUnlockableRef(unlocks.catUnlock)
	end]]
end

P.gun = P.tool:new{name = 'gun', baseRange = 3, image = 'Graphics/Tools/gun.png'}
function P.gun:usableOnAnimal(animal)
	return not animal.dead
end
function P.gun:usableOnTile(tile)
	--[[if tile:instanceof(tiles.wall) and not tile:instanceof(tiles.concreteWall) and not tile:instanceof(tiles.glassWall) and not tile.destroyed then
		if tile.blocksVision then
			return true
		end
	end]]
	if tile:instanceof(tiles.beggar) and tile.alive then
		return true
	end
	return false
end
function P.gun:useToolTile(tile)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.beggar) then
		--unlocks.unlockUnlockableRef(unlocks.beggarPartyUnlock)
		tile:destroy()
	else
		tile:allowVision()
	end
end
function P.gun:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	--[[animal:kill()
	if animal:instanceof(animalList.bombBuddy) then
		animal:explode()
	end
	gabeUnlock = false]]

	local tileY = animal.tileY
	local tileX = animal.tileX

	local bulletProcess = processList.bullet:new()
	bulletProcess.currentLoc = {x = tileToCoords(player.tileY, player.tileX).x+tileUnit/2, y = tileToCoords(player.tileY, player.tileX).y+tileUnit/2}
	bulletProcess.targetLoc = {tileX = tileX, tileY = tileY, x = tileToCoords(tileY, tileX).x, y = tileToCoords(tileY, tileX).y}
	bulletProcess.animal = animal

    if tileY<player.tileY then
		bulletProcess.direction = 0
	elseif tileX>player.tileX  then
		bulletProcess.direction = 1
	elseif tileY>player.tileY then
		bulletProcess.direction = 2
	elseif tileX<player.tileX then
		bulletProcess.direction = 3
	end

	processes[#processes+1] = bulletProcess
end

P.sponge = P.tool:new{name = "sponge", baseRange = 1, image = 'NewGraphics/sponge copy.png'}
function P.sponge:usableOnTile(tile)
	if tile:instanceof(tiles.dustyGlassWall) and tile.blocksVision then
		return true
	elseif tile:instanceof(tiles.puddle) then return true
	elseif (tile:instanceof(tiles.stickyButton) and not tile:instanceof(tiles.superStickyButton)) or (tile:instanceof(tiles.button) and tile.bricked) then return true
	elseif tile:instanceof(tiles.glue) then return true
	elseif tile:instanceof(tiles.slime) or tile:instanceof(tiles.conductiveSlime) then return true end
	return false
end
function P.sponge:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.dustyGlassWall) then
		tile.blocksVision = false
		tile.sprite = tile.cleanSprite
	elseif tile:instanceof(tiles.puddle) then
		--unlocks = require('scripts.unlocks')
		--unlocks.unlockUnlockableRef(unlocks.puddleUnlock)
		room[tileY][tileX] = nil
	elseif tile:instanceof(tiles.button) then
		if tile:instanceof(tiles.stayButton) then
			room[tileY][tileX] = tiles.stayButton:new()
		else
			room[tileY][tileX] = tiles.button:new()
			room[tileY][tileX].bricked = false
		end
		if tile:instanceof(tiles.stickyButton) then
			stats.incrementStat('stickyButtonsSponged')
		end
	else
		room[tileY][tileX] = nil
	end
end

P.felixGun = P.gun:new{name = 'felix gun', numHeld = 0, range = 5, isGun = true}
function P.felixGun:switchEffects()
	local switchEffects = self.switchEffects
	if self.isGun then
		P.felixGun = P.explosiveGun:new{name = self.name, numHeld = self.numHeld, isGun = false, switchEffects = switchEffects}
	else
		P.felixGun = P.gun:new{name = self.name, numHeld = self.numHeld, range = 5, isGun = true, switchEffects = switchEffects}
	end
	for i = 1, #tools do
		if tools[i].name == self.name then
			tools[i] = P.felixGun
		end
	end
end


P.numQualities = 5
P.superTool = P.tool:new{name = 'superTool', baseRange = 10, quality = P.numQualities, description = 'qwerty', defaultDisabled = false, isDisabled = false,
  infiniteUses = false}
function P.superTool:getOtherSupers()
	local toRet = {}
	for i = tools.numNormalTools+1, #tools do
		if tools[i].numHeld > 0 and tools[i].name ~= self.name then
			toRet[#toRet+1] = tools[i]
		end
	end
	return toRet
end


function P.chooseSupertool(quality)
	unlockedSupertools = unlocks.getUnlockedSupertools()
	if quality == nil then
		local toolId
		repeat
			toolId = util.random(#tools-tools.numNormalTools,'toolDrop')+tools.numNormalTools
		until(unlockedSupertools[toolId] and not tools[toolId].isDisabled)
		return toolId
	else
		local toolId
		repeat
			toolId = util.random(#tools-tools.numNormalTools,'toolDrop')+tools.numNormalTools
		until(unlockedSupertools[toolId] and tools[toolId].quality == quality and not tools[toolId].isDisabled)
		return toolId
	end
end

--i know this is a copy of the function but if we called this every time we'd needlessly repeat the first part, bad practice still tho
function P.chooseGoodSupertools()
	local filledSlots = {0,0,0}
	local slot = 1
	for i = tools.numNormalTools + 1, #tools do
		if tools[i].numHeld>0 then
			filledSlots[slot] = i
			slot = slot+1
		end
	end
	for i = 1, 3 do
		if filledSlots[i] == 0 then
			local toCheck = 0
			while (toCheck == filledSlots[1] or toCheck == filledSlots[2] or toCheck == filledSlots[3]) do
				toCheck = P.chooseSupertool()
			end
			filledSlots[i] = toCheck
		end
	end
	return filledSlots
end

function P.getSupertools(numTools,qualities)
	if numTools == nil then numTools = 1 end
	local toolsToGive = {}
	local filledSlots = {0,0,0}
	local slot = 1
	for i = tools.numNormalTools + 1, #tools do
		if tools[i].numHeld>0 then
			filledSlots[slot] = i
			slot = slot+1
		end
	end
	for superToolNumber = 1, numTools do
		local slotToPlace = util.random(3, 'toolDrop')
		if filledSlots[slotToPlace] ~= 0 then
			toolsToGive[#toolsToGive + 1] = filledSlots[slotToPlace]
		else
			local quality = nil
			if qualities ~= nil then quality = qualities[superToolNumber] end
			slot = tools.chooseSupertool(quality)
			filledSlots[slotToPlace] = slot
			toolsToGive[#toolsToGive + 1] = slot
		end
	end
	return toolsToGive
end

function P.giveSupertools(numTools,qualities)
	P.giveRandomTools(0,numTools,qualities)
end


--Shovel: creates a pit, you can also dig up mushrooms to get shrooms
P.shovel = P.superTool:new{name = "Shovel", description = "The world is your sandbox", baseRange = 1, --Dig deep? Plumb the depths?
image = 'Graphics/Tools/shovel.png', quality = 2}
function P.shovel:usableOnNothing()
	return true
end
function P.shovel:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.pit:new()
end
function P.shovel:usableOnTile(tile)
	return tile:instanceof(tiles.mushroom)
end
function P.shovel:useToolTile(tile)
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==tile then
				room[i][j] = tiles.supertoolTile:new()
				room[i][j].tool = tools.shrooms
			end
		end
	end
end


--Electrifier: Makes a tile conductive
P.electrifier = P.superTool:new{name = 'Electrifier', description = "Forming connections", baseRange = 1, image = 'Graphics/conduit.png', quality = 3}
function P.electrifier:usableOnTile(tile)--No longer called moisten, old desc: let the love flow
	if not tile.destroyed and tile:instanceof(tiles.wall) and not tile:instanceof(tiles.metalWall) and not tile.electrified then
		return true
	end
	return false
end
function P.electrifier:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:electrify()
end


--Delectrifier: makes a tile no longer conductive
P.delectrifier = P.superTool:new{name = 'Delectrifier', description = "A clean breakup", baseRange = 1, image = 'Graphics/electrifier2.png', quality = 4}
--You didn't have to cut me off?//		Was insulate, Low energy precendent
function P.delectrifier:usableOnTile(tile)
	if tile.canBePowered then return true end
	return false
end
function P.delectrifier:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.canBePowered = false
	if tile:instanceof(tiles.powerSupply) or tile:instanceof(tiles.notGate) or tile:instanceof(tiles.wire) then tile:destroy() end
	if tile.overlay ~= nil then
		tile.overlay.canBePowered = false
		if tile.overlay:instanceof(tiles.powerSupply) or tile.overlay:instanceof(tiles.notGate) or tile.overlay:instanceof(tiles.wire) then tile.overlay:destroy() end
	end
	--[[if player.character == characters.monk and tile:instanceof(tiles.lamp) then
		for i = 1, 3 do
			player.character.tint[i] = 0
		end
	    myShader:send("tint_r", player.character.tint[1])
	    myShader:send("tint_g", player.character.tint[2])
	    myShader:send("tint_b", player.character.tint[3])
	end]]
end


--Charger: makes a conductive tile into a power supply
P.charger = P.superTool:new{name = 'Battery Pack', description = "Empowerment", baseRange = 1, image = 'Graphics/powerizer.png', quality = 4}
function P.charger:usableOnTile(tile) --Was desc Power to the people aslo considered empower, empowering
	--if not tile.destroyed and not tile.charged and 
	if tile.canBePowered and not tile.charged then return true end
	return false
end
function P.charger:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.charged = true
end


--Lets you see everywhere in the current room
P.visionChanger = P.superTool:new{name = 'Flashlight', description = "Dispel the dark", baseRange = 0, image = 'Graphics/visionChanger.png', quality = 1}
function P.visionChanger:usableOnTile(tile)--Was "Dispel the phantoms"
	return true
end
P.visionChanger.usableOnNothing = P.visionChanger.usableOnTile
function P.visionChanger:useToolTile(tile)
	local prevLitTiles = {}
	for i = 1, roomHeight do
		prevLitTiles[i] = {}
		for j = 1, roomLength do
			prevLitTiles[i][j] = litTiles[i][j]
		end
	end

	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				room[i][j]:allowVision()
				litTiles[i][j]=1
			end
		end
	end

	for i = 1, #animals do
		if litTiles[animals[i].tileY][animals[i].tileX]==1 and
		prevLitTiles[animals[i].tileY][animals[i].tileX]~=1 and not animals[i].triggered then
			unlocks.unlockUnlockableRef(unlocks.ratUnlock)
		end
	end
end
P.visionChanger.useToolNothing = P.visionChanger.useToolTile

P.bomb = P.superTool:new{name = "Bomb", description = "3-2-1 BOOM!", baseRange = 1, image = 'Graphics/Tools/bomb.png', quality = 4}
--alternate description: "The convict's bread and butter"
function P.bomb:useToolNothing(tileY, tileX) --Used to be 3-2-1 BOOM! was also "brute force" Considered chemical trivia or thrill text
	self.numHeld = self.numHeld - 1 --ANFO
	t = tiles.bomb:new()
	t.counter = 3
	room[tileY][tileX] = t
end
function P.bomb:usableOnNothing()
	return true
end

P.flame = P.superTool:new{name = "Match", description = "Watch the world burn", baseRange = 1,
image = 'Graphics/Tools/flame.png', quality = 2} --Was desc: share the warmth
function P.flame:usableOnTile(tile)
	--flame cannot burn metal walls
	if tile:instanceof(tiles.wall) and tile.sawable and not tile:instanceof(tiles.metalWall) and not tile.destroyed then
		return true
	end
	return false
end
function P.flame:usableOnPushable(pushable)
	return pushable:instanceof(pushableList.iceBox)
end
function P.flame:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.onFire = true
	self:updateFire()
end
function P.flame:useToolPushable(pushable)
	pushable:destroy()
	if room[pushable.tileY][pushable.tileX]==nil or room[pushable.tileY][pushable.tileX]:usableOnNothing() then
		room[pushable.tileY][pushable.tileX] = tiles.puddle:new()
	end
end
function P.flame:updateFire()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.wall) and room[i][j].onFire then
				self:burn(i,j)
			end
		end
	end
end
function P.flame:burn(x,y)
	--flame movement note: flames can travel across corners of wooden walls [for example, flame
	--can travel from (1,1) to (2,2)]

	room[x][y]:destroy()
	for i = -1, 1 do
		for j = -1, 1 do
			if room[x+i]~=nil and room[x+i][y+j]~=nil and tools.flame:usableOnTile(room[x+i][y+j]) and not room[x+i][y+j].onFire then
				room[x+i][y+j].onFire = true
				self:burn(x+i, y+j)
			end
		end
	end
end

P.crowbar = P.superTool:new{name = "Crowbar", description = "A breakout star", baseRange = 1, image = 'Graphics/unsticker.png', quality = 4}
function P.crowbar:usableOnTile(tile) --Tool for a prying heart
	if tile:instanceof(tiles.vPoweredDoor) or tile:instanceof(tiles.hDoor) and not tile.stopped then return true end
	return false
end
function P.crowbar:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.open = true
	tile.stopped = true
end

P.doorstop = P.superTool:new{name = "doorstop", description = "Removed.", baseRange = 1, image = 'Graphics/unsticker.png', quality = 1}
function P.doorstop:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) and (not tile.stopped) and (not tile.blocksMovement) then return true end
	return false
end
function P.doorstop:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.stopped = true
end


--Missile: destroys a single chosen tile within a radius
P.missile = P.superTool:new{name = "Missile", description = "Targeted destruction",
useWithArrowKeys = false, baseRange = 10, -- Was "The hand of MF doom"
image = 'Graphics/Tools/missile.png', quality = 4}
function P.missile:usableOnTile(tile)
	return not tile.destroyed and (tile:instanceof(tiles.wire) or tile:instanceof(tiles.electricFloor) or tile:instanceof(tiles.wall)) or tile:instanceof(tiles.powerSupply) and not tile.destroyed
end
function P.missile:usableOnNothing()
	return true
end
function P.missile:usableOnAnimal(animal)
	return not animal.dead
end
function P.missile:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.dungeonEnter:new()
end
function P.missile:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	local missileProcess = processList.missile:new()
	missileProcess.x = tileToCoords(tileY, tileX).x
	missileProcess.targetY = tileToCoords(tileY-0.5, tileX).y
	missileProcess.y = missileProcess.targetY-tileUnit*6*scale

    missileProcess.tile = tile

	processes[#processes+1] = missileProcess
end
P.missile.getToolableTiles = P.tool.getToolableTilesBox
P.missile.getToolableAnimals = P.tool.getToolableAnimalsBox
P.missile.useToolAnimal = P.gun.useToolAnimal

P.meat = P.superTool:new{name = "Meat", description = "Raw temptation", baseRange = 1,
image = 'Graphics/Tools/meat.png', quality = -1}
function P.meat:usableOnNothing()
	return true
end
function P.meat:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.meat:new()
end
function P.meat:usableOnTile(tile)
	if tile.overlay==nil then
		return true
	end
	return false
end
function P.meat:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.attractsAnimals = true
	tile.overlay = tiles.meat
end


P.rottenMeat = P.superTool:new{name = "Rotten Meat", description = "It stinks",
image = 'Graphics/Tools/rottenMeat.png', quality = -1, baseRange = 1}
P.rottenMeat.usableOnNothing = P.meat.usableOnNothing
function P.rottenMeat:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.rottenMeat:new()
end
P.rottenMeat.usableOnTile = P.meat.usableOnTile
function P.rottenMeat:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.scaresAnimals = true
	tile.overlay = tiles.rottenMeat
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

P.woodGrabber = P.superTool:new{name = "woodGrabber", description = "Removed.", baseRange = 1, image = 'Graphics/woodGrabber.png', quality = 3}
function P.woodGrabber:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and tile.destroyed
end
function P.woodGrabber:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	P.ladder.numHeld = P.ladder.numHeld+2
	room[tileY][tileX] = nil
end

P.pitbullChanger = P.superTool:new{name = "Giovanni's Wand", description = "Turn foes into friends",baseRange = 3, image = 'Graphics/pitbullChanger.png', quality = 1}
function P.pitbullChanger:usableOnAnimal(animal)
	return not animal.dead and animal:instanceof(animalList.pitbull)
end
function P.pitbullChanger:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	for i = 1, #animals do
		if animal.tileX == animals[i].tileX and animal.tileY == animals[i].tileY then
			animals[i] = animalList.pup:new()
			animals[i].tileX = animal.tileX
			animals[i].tileY = animal.tileY
			animals[i].prevTileX = animal.prevTileX
			animals[i].prevTileY = animal.prevTileY
			animals[i].x = animal.x
			animals[i].prevx = animal.prevx
			animals[i].y = animal.y
			animals[i].prevy = animal.y
		end
	end
end

P.rotater = P.superTool:new{name = "Rotater", description = "Perpendicular", baseRange = 1, image = 'Graphics/rotatetool.png', quality = 4}
function P.rotater:usableOnTile(tile) --Was Turnt
	return true
end
function P.rotater:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	tile:rotate(1)
end

P.trap = P.superTool:new{name = "Trap", description = "*Snap*", baseRange = 1, image = 'Graphics/trap.png', quality = 1}
function P.trap:usableOnNothing()
	return true
end
function P.trap:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.mousetrap:new()
end

--Change?
P.boxCutter = P.superTool:new{name = "Box Cutter", description = "Time to find out what's inside", baseRange = 1, image = 'Graphics/boxcutter.png', quality = 3}
function P.boxCutter:usableOnPushable(pushable)--Was desc "There's a present inside!"
	return true
end
function P.boxCutter:useToolPushable(pushable)
	self.numHeld = self.numHeld - 1
	pushable.destroyed = true
	P.giveRandomTools(1)
end

P.broom = P.superTool:new{name = "Broom", description = "Gone with the wind.",image = 'Graphics/broom.png', quality = 1}
function P.broom:usableOnTile(tile)
	return tile:instanceof(tiles.slime) or tile:instanceof(tiles.conductiveSlime)
end
function P.broom:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX]=nil
end

P.magnet = P.superTool:new{name = "Magnet", description = "F = q * vector v cross vector B", baseRange = 5,
image = 'Graphics/Tools/boxMagnet.png', quality = 1} --Was Pull vs Push
function P.magnet:usableOnPushable(pushable)
	return math.abs(player.tileX-pushable.tileX)+math.abs(player.tileY-pushable.tileY)>1
end
function P.magnet:useToolPushable(pushable)
	self.numHeld = self.numHeld-1
	local pushX = pushable.tileX
	local pushY = pushable.tileY
	mover = {tileX = pushX, tileY = pushY, prevTileX = pushX, prevTileY = pushY}

	if pushX>player.tileX then mover.prevTileX = pushX+1
	elseif pushX~=player.tileX then mover.prevTileX = pushX-1
	elseif pushY>player.tileY then mover.prevTileY = pushY+1
	else mover.prevTileY = pushY-1 end

	pushable:move(mover)
end

P.spring = P.superTool:new{name = "Spring", description = "Up, up in the air I go", useWithArrowKeys = false, baseRange = 4, image = 'Graphics/spring.png', quality = 3}
function P.spring:usableOnTile(tile)
	if tile.untoolable then return false
	elseif tile:getHeight()>0 and (not tile.canElevate) then return false end
	for i = 1, #pushables do
		if pushables[i].tileX == tile.tileX and pushables[i].tileY == tile.tileY then return false end
	end
	return true
end
function P.spring:usableOnNothing()
	return true
end
function P.spring:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	updateElevation()
	room[tileY][tileX]:onEnter(player)
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
	setPlayerLoc()
end
function P.spring:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	updateElevation()
	setPlayerLoc()
end
P.spring.getToolableTiles = P.tool.getToolableTilesBox

P.glue = P.superTool:new{name = "Glue", description = "Almost strong enough to hold your life together", image = 'Graphics/Tools/glue.png', baseRange = 3, quality = 2}
function P.glue:usableOnNothing() --Sticktion? was desc: Stay boy, stay!
	return true
end
function P.glue:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.glue:new()
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

--[[P.lamp = P.superTool:new{name = "lamp", description = "The light of power.", baseRange = 3, image = 'Graphics/lamp.png', quality = 3}
function P.lamp:usableOnNothing()
	return true
end
function P.lamp:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.lamp:new()
end]]

P.boxSpawner = P.superTool:new{name = "Box", description = "Still likes to be pushed around", baseRange = 1, image = 'Graphics/box.png', quality = 2}
function P.boxSpawner:usableOnNothing(tileY, tileX) --Was desc: Likes to be pushed around
	if tileY==player.tileY and tileX==player.tileX then return false end
	for i = 1, #animals do
		if animals[i].tileY==tileY and animals[i].tileX==tileX then return false end
	end
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then return false end
	end
	return true
end
function P.boxSpawner:usableOnTile(tile)
	local tileX = 0
	local tileY = 0
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==tile then
				tileX = j
				tileY = i
			end
		end
	end
	if tileY==player.tileY and tileX==player.tileX then return false end
	for i = 1, #animals do
		if animals[i].tileY==tileY and animals[i].tileX==tileX then return false end
	end
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then return false end
	end
	return not tile.blocksMovement
end
function P.boxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[2]:new()
	if player.character.name == "Tim" then toSpawn = pushableList.giftBox:new() end
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.boxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[2]:new()
	if player.character.name == "Tim" then toSpawn = pushableList.giftBox:new() end
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

P.playerBoxSpawner = P.boxSpawner:new{name = "Player Box", description = "Special treatment", image = 'Graphics/playerBox.png', quality = 2}
function P.playerBoxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[3]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.playerBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[3]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

P.bombBoxSpawner = P.boxSpawner:new{name = "Bomb Box", description  = "Perfect for those seeking a bigger package", image = 'Graphics/bombBox.png', quality = 3}
function P.bombBoxSpawner:useToolTile(tile, tileY, tileX) -- desc?: It's fantastic 		Needs new desc
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[8]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.bombBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[8]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

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

P.lamp = P.boxSpawner:new{name = "Lamp", description  = "A star in a jar", baseRange = 1, image = 'Graphics/lamp.png', quality = 4}
function P.lamp:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList.lamp:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.lamp:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[7]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

P.ramSpawner = P.boxSpawner:new{name = "Battering Ram", description  = "Knock down that wall", image = 'Graphics/batteringram.png', quality = 2}
function P.ramSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[7]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.ramSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[7]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

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


--L.A.S.E.R.: kills all dogs in a line
P.laser = P.superTool:new{name = "L.A.S.E.R.", description = "The damage multiplier", baseRange = 100, image = 'Graphics/laser.png', quality = 1}
function P.laser:usableOnTile() --Was desc: Piercing shot
	return true
end
P.laser.usableOnNothing = P.laser.usableOnTile
local function killDogs(tileY, tileX)
	local dogsKilled = 0
	if tileX == player.tileX then
		for i = 1, #animals do
			if animals[i].tileX == player.tileX then
				if (tileY > player.tileY and animals[i].tileY > player.tileY) or
				  (tileY < player.tileY and animals[i].tileY < player.tileY) then
				  	if not animals[i].dead then
				  		dogsKilled = dogsKilled+1
				  	end
					animals[i]:kill()
				end
			end
		end
	else
		for i = 1, #animals do
			if animals[i].tileY == player.tileY then
				if (tileX >= player.tileX and animals[i].tileX >= player.tileX) or
				  (tileX < player.tileX and animals[i].tileX < player.tileX) then
					if not animals[i].dead then
				  		dogsKilled = dogsKilled+1
				  	end
					animals[i]:kill()
				end
			end
		end
	end

	if dogsKilled>=3 then
		unlocks.unlockUnlockableRef(unlocks.superLaserUnlock)
	end
end
function P.laser:useToolTile(tile, tileY, tileX)
	killDogs(tileY, tileX)
	self.numHeld = self.numHeld-1
end
function P.laser:useToolNothing(tileY, tileX)
	killDogs(tileY, tileX)
	self.numHeld = self.numHeld-1
end




P.icegun = P.superTool:new{name = "The Stop Light", description = "It may never turn green", baseRange = 5,
image = 'Graphics/icegun.png', quality = 2}	--Was Freeze Ray: Piercing permafrost
function P.icegun:usableOnTile()
	return true
end
P.icegun.usableOnNothing = P.icegun.usableOnTile
local function iceDogs(tileY, tileX)
	if tileX == player.tileX then
		for i = 1, #animals do
			if animals[i].tileX == player.tileX then
				if (tileY > player.tileY and animals[i].tileY > player.tileY) or
				  (tileY < player.tileY and animals[i].tileY < player.tileY) then 
					if not animals[i].dead then
						animals[i].frozen = true
						local freezeChance = util.random(3, 'misc')
						if freezeChance == 1 then
							animals[i]:kill()
							local toSpawn = pushableList.iceBox:new()
							toSpawn.tileY = animals[i].tileY
							toSpawn.tileX = animals[i].tileX
							pushables[#pushables+1] = toSpawn
						end
					end
				end
			end
		end
	else
		for i = 1, #animals do
			if animals[i].tileY == player.tileY then
				if (tileX >= player.tileX and animals[i].tileX >= player.tileX) or
				  (tileX < player.tileX and animals[i].tileX < player.tileX) then
					if not animals[i].dead then
						animals[i].frozen = true
						local freezeChance = util.random(3, 'misc')
						if freezeChance == 1 then
							animals[i]:kill()
							local toSpawn = pushableList.iceBox:new()
							toSpawn.tileY = animals[i].tileY
							toSpawn.tileX = animals[i].tileX
							pushables[#pushables+1] = toSpawn
						end
					end
				end
			end
		end
	end
end

function P.icegun:useToolTile(tile, tileY, tileX)
	--iceDogs(tileY, tileX)
	self.numHeld = self.numHeld-1
end
function P.icegun:useToolNothing(tileY, tileX)
	iceDogs(tileY, tileX)
	self.numHeld = self.numHeld-1
end

--should superLaser kill animals? can't decide
P.superLaser = P.laser:new{name = "Super L.A.S.E.R", description = "Basic lasers are for losers", baseRange = 100, image = 'Graphics/laser.png', quality = 4}
function P.superLaser:usableOnTile()
	return true
end
P.superLaser.usableOnNothing = P.superLaser.usableOnTile
local function killBlocks(tileY, tileX)
	if tileY == player.tileY then
		for i = 1, roomLength do
			if room[tileY][i]~=nil then
				if (tileX >= player.tileX and i >= player.tileX) or
				  (tileX < player.tileX and i < player.tileX) then
					room[tileY][i]:destroy()
				end
			end
		end
		for i = 1, #animals do
			if animals[i].tileY == tileY then
				animals[i]:kill()
			end
		end
		for i = 1, #pushables do
			if pushables[i].tileY == tileY then
				pushables[i]:destroy()
			end
		end
	elseif tileX == player.tileX then
		for i = 1, roomHeight do
			if room[i][tileX]~=nil then
				if (tileY > player.tileY and i > player.tileY) or
				  (tileY < player.tileY and i < player.tileY) then
					room[i][tileX]:destroy()
				end
			end
		end
		for i = 1, #animals do
			if animals[i].tileX == tileX then
				animals[i]:kill()
			end
		end
		for i = 1, #pushables do
			if pushables[i].tileX == tileX then
				pushables[i]:destroy()
			end
		end

	end
end
function P.superLaser:useToolTile(tile, tileY, tileX)
	killDogs(tileY, tileX)
	killBlocks(tileY, tileX)
	self.numHeld = self.numHeld-1
	if tileY == player.tileY then
		for i = 1, roomLength do
			if room[tileY][i]~=nil then
				room[tileY][i]:destroy()
			end
		end
		for i = 1, #animals do
			if animals[i].tileY == tileY then
				animals[i]:kill()
			end
		end
		for i = 1, #pushables do
			if pushables[i].tileY == tileY then
				pushables[i]:destroy()
			end
		end
	elseif tileX == player.tileX then
		for i = 1, roomHeight do
			if room[i][tileX]~=nil then
				room[i][tileX]:destroy()
			end
		end
		for i = 1, #animals do
			if animals[i].tileX == tileX then
				animals[i]:kill()
			end
		end
		for i = 1, #pushables do
			if pushables[i].tileX == tileX then
				pushables[i]:destroy()
			end
		end
	end
end
function P.superLaser:useToolNothing(tileY, tileX)
	self:useToolTile(nil, tileY, tileX)
end


--Gas: kills all animals in the room
P.gas = P.superTool:new{name = "Poison Gas", description = "Chemical Warfare", baseRange = 0, image = 'Graphics/gas.png', quality = 2}
function P.gas:usableOnNothing() -- Keep Desc / Flavor?
	return true
end
P.gas.usableOnTile = P.gas.usableOnNothing
P.gas.usableOnAnimal = P.gas.usableOnNothing

function P.gas:useToolTile()
	for i = 1, #animals do
		animals[i]:kill()
	end
	self.numHeld = self.numHeld-1
end
P.gas.useToolNothing = P.gas.useToolTile
P.gas.useToolAnimal = P.gas.useToolTile


P.armageddon = P.superTool:new{name = "Master of Matter", description = "So very empty...", baseRange = 0, image = 'Graphics/armageddon.png', quality = 4}
function P.armageddon:usableOnTile()
	return true
end
P.armageddon.usableOnNothing = P.armageddon.usableOnTile

function P.armageddon:useToolTile()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				room[i][j]:destroy()
			end
		end
	end
	for i = 1, #pushables do
		pushables[i].destroyed = true
	end
	for i = 1, #animals do
		animals[i]:kill()
	end
	self.numHeld = self.numHeld-1
end
P.armageddon.useToolNothing = P.armageddon.useToolTile


P.toolReroller = P.superTool:new{name = "Tool Reroller", description = "The right tools for the job", baseRange = 0, image = 'Graphics/toolreroller.png', quality = 2}
function P.toolReroller:usableOnNothing() -- was desc You can't always have the right tools for the job
	return true
end
function P.toolReroller:useToolNothing()
	local inventorySize = 0
	for i = 1, P.numNormalTools do
		inventorySize = inventorySize+tools[i].numHeld
		tools[i].numHeld = 0
	end
	--gain one extra basic tool from use (but all tools are rerolled)
	inventorySize = inventorySize+1
	P.giveRandomTools(inventorySize)
	self.numHeld = self.numHeld-1
end

P.roomReroller = P.superTool:new{name = "Contents Randomizer", description = "How things should have been", baseRange = 0, image = 'Graphics/roomreroller.png', quality = 5}
function P.roomReroller:usableOnNothing()
	return true
end
function P.roomReroller:getTilesWhitelist()
	return {tiles.wire, tiles.cornerWire, tiles.horizontalWire, tiles.metalWall, tiles.concreteWall, tiles.wall, tiles.glassWall,
	tiles.electricFloor, tiles.poweredFloor, tiles.pit, tiles.notGate, tiles.andGate, tiles.ladder, tiles.puddle, tiles.button, tiles.stayButton,
	tiles.stickyButton, tiles.powerSupply}
end
function P.roomReroller:getTreasureTiles()
	return {tiles.treasureTile, tiles.treasureTile2, tiles.treasureTile3, tiles.treasureTile4}
end
P.roomReroller.usableOnTile = P.roomReroller.usableOnNothing

function P.roomReroller:useToolNothing()
	self.numHeld = self.numHeld-1

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and not room[i][j]:instanceof(tiles.endTile) then
				local whitelist = self:getTilesWhitelist()
				local treasureOrRegular = util.random(40, 'misc')
				local tileArr = self:getTilesWhitelist()
				if treasureOrRegular==1 then
					tileArr = self:getTreasureTiles()
				end
				local whichTile = util.random(#tileArr, 'misc')
				room[i][j] = tileArr[whichTile]:new()
			end
		end
	end
	for i = 1, #animals do
		animals[i]:kill()
	end
	for i = 1, #pushables do
		pushables[i].destroyed = true
	end
	room[player.tileY][player.tileX]=nil
end
P.roomReroller.useToolTile = P.roomReroller.useToolNothing


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

P.toolIncrementer = P.superTool:new{name = "Toolbox", description = "The essentials", baseRange = 0, image = 'Graphics/toolincrementer.png', quality = 5}
function P.toolIncrementer:usableOnNothing() --"Seven", description = "+'1-1-1-1-1-1-1'", 
	return true
end
function P.toolIncrementer:useToolNothing()
	for i = 1, P.numNormalTools do
		tools[i].numHeld = tools[i].numHeld+1
	end
	self.numHeld = self.numHeld-1
end


--Wings: using these lets you fly over all ground obstacles
P.wings = P.superTool:new{name = "Wings", description = "Float free", baseRange = 0, image = 'Graphics/wings.png', quality = 4}
function P.wings:usableOnNothing()--His feet never touched the ground. was desc: Ungrounded
	return true
end
P.wings.usableOnTile = P.roomReroller.usableOnNothing

function P.wings:useToolNothing()
	--[[if player.attributes.flying then
		unlocks.unlockUnlockableRef(unlocks.gabeUnlock)
	end]]
	player.attributes.flying = true
	self.numHeld = self.numHeld-1
end
P.wings.useToolTile = P.wings.useToolNothing

P.swapper = P.superTool:new{name = "Swapper", description = "Lets trade places", useWithArrowKeys = false, baseRange = 100, image = 'Graphics/swapper.png', quality = 1}
function P.swapper:usableOnAnimal()
	return true
end
function P.swapper:usableOnPushable()
	return true
end
function P.swapper:useToolAnimal(animal)
	local tempx = animal.tileX
	local tempy = animal.tileY
	animal.tileX = player.tileX
	animal.tileY = player.tileY
	player.tileX = tempx
	player.tileY = tempy
	self.numHeld = self.numHeld-1
end
function P.swapper:useToolPushable(pushable)
	local tempx = pushable.tileX
	local tempy = pushable.tileY
	pushable.tileX = player.tileX
	pushable.tileY = player.tileY
	player.tileX = tempx
	player.tileY = tempy
	self.numHeld = self.numHeld-1
end
P.swapper.getToolableAnimals = P.swapper.getToolableAnimalsBox


P.bucketOfWater = P.superTool:new{name = "Bucket Of Water", description = "Bottomless", baseRange = 1,
image = 'Graphics/Tools/bucketOfWater.png', quality = 1}
function P.bucketOfWater:usableOnNothing()
	return true
end
function P.bucketOfWater:usableOnTile(tile, tileY, tileX)
	return P.waterBottle.usableOnTile(self, tile, tileY, tileX)
end
function P.bucketOfWater:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	self:spreadWater(tileY, tileX)
end
function P.bucketOfWater:useToolTile(tile, tileY, tileX)
	P.waterBottle.useToolTile(self, tile, tileY, tileX)
end
function P.bucketOfWater:spreadWater(tileY, tileX)
	room[tileY][tileX] = tiles.puddle:new()
	if tileY>1 then
		if room[tileY-1][tileX]==nil then
			self:spreadWater(tileY-1, tileX)
		end
	end
	if tileY<roomHeight then
		if room[tileY+1][tileX]==nil then
			self:spreadWater(tileY+1, tileX)
		end
	end
	if tileX>1 then
		if room[tileY][tileX-1]==nil then
			self:spreadWater(tileY, tileX-1)
		end
	end
	if tileX<roomLength then
		if room[tileY][tileX+1]==nil then
			self:spreadWater(tileY, tileX+1)
		end
	end
end

P.teleporter = P.superTool:new{name = "Teleporter", description = "Who knows where you'll wind up...", baseRange = 0, image = 'Graphics/teleporter.png', quality = 1}
function P.teleporter:usableOnNothing()
	return true
end
P.teleporter.usableOnTile = P.teleporter.usableOnNothing
function P.teleporter:useToolNothing()
	self.numHeld = self.numHeld-1

	local teleported = false
	while not teleported do
		local xval = util.random(mapHeight, 'misc')
		local yval = util.random(mapHeight, 'misc')
		if mainMap[yval][xval]~=nil then
			teleported = true

			resetTranslation()
			resetPlayerAttributesRoom()
			player.character:onRoomEnter()
			--set pushables of prev. room to pushables array, saving for next entry
			room.pushables = pushables
			room.animals = animals

			prevMapX = mapx
			prevMapY = mapy
			prevRoom = room

			room = mainMap[yval][xval].room
			mapx = xval
			mapy = yval

			if mainMap[yval][xval].dirEnter==nil then
				mainMap[yval][xval].dirEnter = {1,1,1,1}
			end

			if mainMap[yval][xval].dirEnter[1]==1 then
				player.tileX = math.floor(roomLength/2)
				player.tileY = 1
			elseif mainMap[yval][xval].dirEnter[2]==1 then
				player.tileY = math.floor(roomHeight/2)
				room.tileX = roomLength
			elseif mainMap[yval][xval].dirEnter[3]==1 then
				player.tileX = math.floor(roomLength/2)
				player.tileY = roomHeight
			else
				player.tileY = math.floor(roomHeight/2)
				room.tileX = 1
			end

			currentid = tostring(mainMap[mapy][mapx].roomid)
			if map.getFieldForRoom(currentid, 'autowin') then
				completedRooms[mapy][mapx] = 1
				unlockDoors()
			end
			if map.getFieldForRoom(currentid, 'hidden') then
				unlocks.unlockUnlockableRef(unlocks.secretTeleporterUnlock)
			end
			if loadTutorial then
				player.enterX = player.tileX
				player.enterY = player.tileY
			end

			if (prevMapX~=mapx or prevMapY~=mapy) or dir == -1 then
				createElements()
			end
			visibleMap[mapy][mapx] = 1
			keyTimer.timeLeft = keyTimer.suicideDelay
			updateGameState()
		end
	end
	setPlayerLoc()
end
P.teleporter.useToolTile = P.teleporter.useToolNothing

P.revive = P.superTool:new{name = "Revive", description = "Not dead yet.", baseRange = 0, image = 'Graphics/revive.png', destroyOnRevive = true, quality = 5}
function P.revive:checkDeath()
	self.numHeld = self.numHeld-1

	--[[for i = 1, tools.numNormalTools do
		tools[i].numHeld = 0
	end]]
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				if room[i][j]:instanceof(tiles.poweredEnd) then
					room[i][j]=tiles.endTile:new()
				elseif not room[i][j]:instanceof(tiles.endTile) and not room[i][j]:instanceof(tiles.tunnel) then
					room[i][j]=nil
				end
			end
		end
	end

	for i = 1, #animals do
		animals[i]:kill()
	end
	for j = 1, #pushables do
		pushables[j]:destroy()
	end
	for i = 1, #bossList do
		bossList[i]:kill()
	end
	spotlights = {}
	updateGameState(false)
	log("Revived!")
	if player.character:instanceof(characters.herman) then
		stats.incrementStat("hermanRevivesUsed")
	end

	return false
end


--Explosive Gun: gun, but more range and explodes the tile it hits
P.explosiveGun = P.gun:new{name = "The Bombastic Bullet", description = "Ballistic blast", baseRange = 5, image = 'Graphics/supergun.png', quality = 2}
function P.explosiveGun:useToolTile(tile, tileY, tileX)--Destruction at a distance  --- Terrible
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.beggar) then
		--unlocks.unlockUnlockableRef(unlocks.beggarPartyUnlock)
		tile:destroy()
	else
		tile:allowVision()
	end
	room[tileY][tileX] = tiles.bomb:new()
	room[tileY][tileX]:onEnd(tileY, tileX)
	room[tileY][tileX]:explode(tileY, tileX)
	room[tileY][tileX] = nil
end
function P.explosiveGun:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	animal:kill()
	local pY = animal.tileY
	local pX = animal.tileX
	room[pY][pX] = tiles.bomb:new()
	room[pY][pX]:onEnd(pY, pX)
	room[pY][pX]:explode(pY, pX)
	room[pY][pX] = nil
end

P.map = P.superTool:new{name = "The Map", description = "Prudent planning", baseRange = 0, image = 'Graphics/Tools/map.png', quality = 1}
function P.map:usableOnNothing() --Was desc You'll find a way , There might still be a way..., Prudent planning
	return true
end
P.map.usableOnTile = P.map.usableOnNothing
function P.map:useToolNothing(tileY, tileX)
	for i = 1, mapHeight do
		for j = 1, mapHeight do
			if mainMap[i][j]==nil then
				visibleMap[i][j]=1
			else
				if map.getFieldForRoom(mainMap[i][j].roomid, 'hidden')~=nil and map.getFieldForRoom(mainMap[i][j].roomid, 'hidden') and
				not (visibleMap[i][j]>=0.5) then
					visibleMap[i][j]=0.5
				elseif map.getFieldForRoom(mainMap[i][j].roomid, 'locked')~=nil and map.getFieldForRoom(mainMap[i][j].roomid, 'locked') and
				not (visibleMap[i][j]>=0.5) then
					visibleMap[i][j]=0.5
				else
					visibleMap[i][j]=1
				end
				if map.getFieldForRoom(mainMap[i][j].roomid, 'autowin') and completedRooms[i][j]<1 then
					completedRooms[i][j]=0.5
				end
			end
		end
	end
	self.numHeld = self.numHeld-1
end
P.map.useToolTile = P.map.useToolNothing

P.buttonFlipper = P.superTool:new{name = "Button Master", description = "Flip off, flip on", baseRange = 0, image = 'Graphics/buttonflipper.png', quality = 3}
function P.buttonFlipper:usableOnNothing()--Button Pusher, Button Master: Does more than push, "Click... click-click-click-click",
	return true
end
P.buttonFlipper.usableOnTile = P.buttonFlipper.usableOnNothing
function P.buttonFlipper:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.button) and not room[i][j]:instanceof(tiles.stayButton) then
				if room[i][j]:instanceof(tiles.stickyButton) then
					if room[i][j].down then room[i][j]:unstick()
					else room[i][j]:onEnter() end
				else room[i][j]:onEnter() end
			elseif room[i][j]~=nil and room[i][j]:instanceof(tiles.stayButton) then
				if room[i][j].down then room[i][j]:onLeave()
				else room[i][j]:onEnter() end
			end
		end
	end
end
P.buttonFlipper.useToolTile = P.buttonFlipper.useToolNothing

P.wireBreaker = P.superTool:new{name = "The Wireless Revolution", description = "Go wireless", baseRange = 0, image = 'Graphics/wirebreaker.png', quality = 2}
function P.wireBreaker:usableOnNothing()--Snap... snap-snap-snap-snap, Ultimate disconnect
	return true
end
P.wireBreaker.usableOnTile = P.wireBreaker.usableOnNothing
function P.wireBreaker:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.wire) and not room[i][j]:instanceof(tiles.unbreakableWire) then
				room[i][j]:destroy()
			elseif room[i][j]~=nil and room[i][j].overlay~=nil and room[i][j].overlay:instanceof(tiles.wire)
			and not room[i][j].overlay:instanceof(tiles.unbreakableWire) then
				room[i][j].overlay:destroy()
			end
		end
	end
end
P.wireBreaker.useToolTile = P.wireBreaker.useToolNothing

P.powerBreaker = P.superTool:new{name = "EMP", description = "Great for fighting robots", baseRange = 0, image = 'Graphics/powerbreaker.png', quality = 3}
function P.powerBreaker:usableOnNothing() --Was Power Breaker: Powerless
	return true
end
P.powerBreaker.usableOnTile = P.powerBreaker.usableOnNothing
function P.powerBreaker:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.powerSupply) then
				room[i][j]:destroy()
			end
		end
	end
end
P.powerBreaker.useToolTile = P.powerBreaker.useToolNothing


--Gabe Maker: turns you into gabe and takes away all your basics
P.gabeMaker = P.superTool:new{name = "Gabriel's Locket", description = "Now I lay me down to sleep", baseRange = 0, image = 'Graphics/gabeSmall.png', quality = 5}
function P.gabeMaker:usableOnNothing()
	return true
end
P.gabeMaker.usableOnTile = P.gabeMaker.usableOnNothing
function P.gabeMaker:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	characters.gabe.realChar = player.character
	player.character = characters.gabe
	player.character:onBegin()
end
P.gabeMaker.useToolTile = P.gabeMaker.useToolNothing

P.roomUnlocker = P.superTool:new{name = "The Magic Word", description = "Gatecrashing", baseRange = 0, image = 'Graphics/doorkey.png', quality = 2}
function P.roomUnlocker:usableOnNothing()
	return true
end
P.roomUnlocker.usableOnTile = P.roomUnlocker.usableOnNothing
function P.roomUnlocker:useToolNothing()
	self.numHeld = self.numHeld-1
	unlockDoorsPlus()
end
P.roomUnlocker.useToolTile = P.roomUnlocker.useToolNothing


--Axe: gun + saw
P.axe = P.superTool:new{name = "Axe", description = "Throw it or swing it.", baseRange = 5,
image = 'Graphics/Tools/axe.png', quality = 2}
P.axe.usableOnTile = P.saw.usableOnTile
P.axe.usableOnAnimal = P.gun.usableOnAnimal
P.axe.useToolAnimal = P.gun.useToolAnimal
P.axe.useToolTile = P.saw.useToolTile


--Lube: sponge + water bottle
P.lube = P.superTool:new{name = "Lube", description = "Wuba lubba dub dub", baseRange = 1, image = 'Graphics/lube.png', quality = 1}
function P.lube:usableOnTile(tile)
	if tile:instanceof(tiles.dustyGlassWall) and tile.blocksVision then return true
	elseif tile:instanceof(tiles.puddle) then return true
	elseif (tile:instanceof(tiles.stickyButton) and not tile:instanceof(tiles.superStickyButton)) or (tile:instanceof(tiles.button) and tile.bricked) then return true end
	if not tile.destroyed and ((tile:instanceof(tiles.powerSupply) and not tile:instanceof(tiles.notGate)) or (tile:instanceof(tiles.electricFloor) and not tile:instanceof(tiles.unbreakableElectricFloor)) or tile:instanceof(tiles.untriggeredPowerSupply)) then
		return true
	end
	return false
end
function P.lube:usableOnNothing()
	return true
end
P.lube.useToolNothing = P.waterBottle.useToolNothing
function P.lube:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.dustyGlassWall) then
		tile.blocksVision = false
		tile.sprite = tile.cleanSprite
	elseif tile:instanceof(tiles.stickyButton) or tile:instanceof(tiles.button) then
		room[tileY][tileX] = tiles.button:new()
		room[tileY][tileX].bricked = false
	elseif tile:instanceof(tiles.puddle) then
		room[tileY][tileX] = nil
	elseif not tile.destroyed then
		tile:destroy()
	end
end


--Knife: gun + wire-cutters
P.knife = P.superTool:new{name = "Knife", description = "They can't stop you", baseRange = 5,
image = 'Graphics/Tools/knife.png', quality = 2}
P.knife.usableOnAnimal = P.gun.usableOnAnimal
P.knife.usableOnTile = P.wireCutters.usableOnTile
P.knife.useToolAnimal = P.gun.useToolAnimal
P.knife.useToolTile = P.wireCutters.useToolTile
P.knife.usableOnNonOverlay = P.wireCutters.usableOnNonOverlay
P.knife.usableOnPushable = P.wireCutters.usableOnPushable
P.knife.useToolPushable = P.wireCutters.useToolPushable

P.snowball = P.superTool:new{name = "Snowball(Removed)", description = "Throwable", baseRange = 5, image = 'Graphics/snowball.png', quality = 1}
function P.snowball:usableOnAnimal(animal)
	return not animal.dead
end
function P.snowball:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+1
end

P.superSnowball = P.snowball:new{name = "Snowball", description = "So very cold",image = 'Graphics/supersnowball.png', quality = 1}
function P.superSnowball:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.frozen = true
end

P.snowballGlobal = P.snowball:new{name = "Mask", description = "The demon in the mask", image = 'Graphics/Tools/mask.png', baseRange = 0, quality = 2}
--"Even these empathetic dogs can't tell you're afraid"
function P.snowballGlobal:usableOnNothing()
	return true
end
function P.snowballGlobal:usableOnTile()
	return true
end
function P.snowballGlobal:useToolNothing()
	self.numHeld = self.numHeld-1
	for i = 1, #animals do
		animals[i].frozen = true
	end
end
P.snowballGlobal.useToolTile = P.snowballGlobal.useToolNothing

P.portalPlacer = P.superTool:new{name = "Portal Gun", description = "Thinking with portals is more fun", image = 'Graphics/entrancePortal.png', baseRange = 1, quality = 1}
function P.portalPlacer:usableOnNothing()
	return true
end
function P.portalPlacer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.entrancePortal:new()
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


--Screwdriver: destroys spikes
P.screwdriver = P.superTool:new{name = "Screwdriver", description = "Remove those spikey plates", image = 'Graphics/screwdriver.png', baseRange = 1, quality = 2}
function P.screwdriver:usableOnTile(tile)
	return tile:instanceof(tiles.spikes)
end
function P.screwdriver:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	room[tileY][tileX] = nil
end

--The World Wide Web
P.laptop = P.superTool:new{name = "Laptop", description = "The world is at your fingertips", image = 'Graphics/laptop.png', baseRange = 0, quality = 1}
function P.laptop:usableOnNothing()
	return true
end
function P.laptop:useToolNothing()
	self.numHeld = self.numHeld-1
	local roomid = mainMap[mapy][mapx].roomid
	local toPrint = 'Room ID:'..roomid..', Items Needed:'
	local itemsForRoom = map.getItemsNeeded(roomid)
	if itemsForRoom~=nil then
		for i=1,#itemsForRoom do
			for toolIndex=1,tools.numNormalTools do
				if itemsForRoom[i][toolIndex]~=0 then toPrint = toPrint..' '..itemsForRoom[i][toolIndex]..' '..tools[toolIndex].name end
			end
			if i~=#itemsForRoom then toPrint = toPrint..' or ' end
		end
	end
	log(toPrint)
end
P.laptop.usableOnTile = P.laptop.usableOnNothing
P.laptop.useToolTile = P.laptop.useToolNothing

P.donationCracker = P.superTool:new{name = "DonationCracker", image = 'Graphics/donationcracker.png', baseRange = 1, quality = 5}
function P.donationCracker:usableOnTile(tile)
	return tile:instanceof(tiles.donationMachine)
end
function P.donationCracker:useToolTile()
	self.numHeld = self.numHeld-1
	tools.giveRandomTools(math.floor(donations*1.5))
	donations = 0
end

P.wireExtender = P.superTool:new{name = "Extension Cord", description = "Longer is better", image = 'Graphics/wireextender.png', quality = 1, baseRange = 1}
function P.wireExtender:usableOnTile(tile)
	return tile:instanceof(tiles.wire)
	or (tile.overlay~=nil and tile.overlay:instanceof(tiles.wire))
end
function P.wireExtender:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.wire) then
		if room[tileY][tileX]:instanceof(tiles.unbreakableWire) then
			room[tileY][tileX] = tiles.unbreakableWire:new()
		elseif tile:instanceof(tiles.crossWire) then
			--do nothing
		else
			room[tileY][tileX] = tiles.wire:new()
		end
	else
		if room[tileY][tileX].overlay:instanceof(tiles.unbreakableWire) then
			room[tileY][tileX].overlay = tiles.unbreakableWire:new()
		elseif tile.overlay:instanceof(tiles.crossWire) then
			--do nothing
		else
			room[tileY][tileX].overlay = tiles.wire:new()
		end
	end

end

P.coin = P.superTool:new{name = "Coin", description = "One way to pay", image = 'Graphics/Tools/coin.png', range = 1, quality = 1}
--Don't pretend things are free --  Nothing is free, One way to pay was Every millionaire starts somewhere
function P.coin:usableOnTile(tile)
	if tile:instanceof(tiles.toolTaxTile) and not tile.destroyed then
		return true
	elseif tile:instanceof(tiles.puddle) then
		return true
	end
	return false
end
function P.coin:useToolTile(tile)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.puddle) then
		player.baseLuckBonus = player.baseLuckBonus+3.5
	else
		tile:destroy()
	end
end

P.emptyBucket = P.superTool:new{name = "Empty Bucket", description = "Fill her up!", puddleTile = nil,
image = 'Graphics/Tools/emptyBucket.png',
imageEmpty = 'Graphics/Tools/emptyBucket.png',
waterImage = 'Graphics/Tools/bucketOfWater.png',
gasImage = 'Graphics/Tools/bucketOfGas.png',
lemonadeImage = 'Graphics/Tools/bucketOfLemonade.png',
full = false, baseRange = 1, quality = 2}
function P.emptyBucket:usableOnTile(tile)
	if self.full then return P.bucketOfWater:usableOnTile(tile) end
	if not self.full then return tile:instanceof(tiles.puddle) end
end

function P.emptyBucket:updateSprite()
	if not self.full then
		self.image = self.imageEmpty
	elseif self.puddleTile:instanceof(tiles.gasPuddle) then
		self.image = self.gasImage
	elseif self.puddleTile:instanceof(tiles.lemonade) then
		self.image = self.lemonadeImage
	else
		self.image = self.waterImage
	end
end
function P.emptyBucket:usableOnNothing()
	return self.full
end
function P.emptyBucket:useToolTile(tile, tileY, tileX)
	if not self.full then
		self.image = self.imageFull
		self.full = true
		self.puddleTile = room[tileY][tileX]
		room[tileY][tileX] = nil
	else
		P.bucketOfWater.useToolTile(self, tile, tileY, tileX)
		self.full = false
	end
	self:updateSprite()
end
function P.emptyBucket:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	self.full = false
	self.image = self.imageEmpty
	self:spreadSubstance(self.puddleTile, tileY, tileX)
	self:updateSprite()
end
function P.emptyBucket:spreadSubstance(tile, tileY, tileX)
	room[tileY][tileX] = tile:new()
	if tileY>1 then
		if room[tileY-1][tileX]==nil then
			self:spreadSubstance(tile, tileY-1, tileX)
		end
	end
	if tileY<roomHeight then
		if room[tileY+1][tileX]==nil then
			self:spreadSubstance(tile, tileY+1, tileX)
		end
	end
	if tileX>1 then
		if room[tileY][tileX-1]==nil then
			self:spreadSubstance(tile, tileY, tileX-1)
		end
	end
	if tileX<roomLength then
		if room[tileY][tileX+1]==nil then
			self:spreadSubstance(tile, tileY, tileX+1)
		end
	end
end

P.emptyCup = P.emptyBucket:new{name = "Empty Cup", description = "It's less than half full", image = 'Graphics/Tools/emptyCup.png',
imageFull = 'Graphics/Tools/emptyCupWater.png',
imageEmpty = 'Graphics/Tools/emptyCup.png',
quality = 2}
function P.emptyCup:usableOnNothing()
	return self.full
end
function P.emptyCup:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.puddle:new()
	self.image = self.imageEmpty
	self.full = false
end
function P.emptyCup:usableOnTile(tile)
	if self.full then return P.waterBottle.usableOnTile(self, tile) end
	if not self.full then return tile:instanceof(tiles.puddle) end
end

function P.emptyCup:useToolTile(tile, tileY, tileX)
	if not self.full then
		self.image = self.imageFull
		self.full = true
		room[tileY][tileX] = nil
	else
		P.waterBottle.useToolTile(self, tile, tileY, tileX)
		self.image = self.imageEmpty
		self.full = false
	end
end

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


--Growth Hormones: Let's you use tools over walls, needs art
P.growthHormones = P.superTool:new{name = "Growth Hormones", description = "Growing up", image = 'Graphics/growthHormones.png', baseRange = 0, quality = 2}
function P.growthHormones:usableOnTile(tile) --Might need a different name
	return true
end
P.growthHormones.usableOnNothing = P.growthHormones.usableOnTile
function P.growthHormones:useToolTile(tile)
	self.numHeld = self.numHeld-1
	if not player.attributes.tall then
		player.attributes.tall = true
	else
		self.description = "Time for some gains"
		tools.gun.numHeld = tools.gun.numHeld+1
	end
end
P.growthHormones.useToolNothing = P.growthHormones.useToolTile


--ThruCover Ammo: gives three thrucover guns on pickup, these can shoot through walls
P.thruCover = P.gun:new{name= "ThruCover Ammo", description = "Tactical Strike", image = 'Graphics/gun.png', quality = 3}
function P.thruCover:giveOne()
	self.numHeld =self.numHeld + 2
end
function P.thruCover:getToolableAnimals()
	local bool = 0
	if not player.attributes.tall then
		player.attributes.tall = true
		bool = 1
	end
		
	local toolableAnimals = P.gun:getToolableAnimals()
	
	if bool then
		player.attributes.tall = false
	end
	return toolableAnimals
end
function P.thruCover:getToolableTiles()
	local bool = 0
	if not player.attributes.tall then
		player.attributes.tall = true
		bool = 1
	end
		
	local toolableTiles= P.gun:getToolableTiles()
	
	if bool then
		player.attributes.tall = false
	end
	return toolableTiles
end


--IceyShot: Gives three ice guns which turn animals to iceboxes
P.iceyShot = P.gun:new{name= "IceyShot", description = "Super Cool", image = 'Graphics/icegun.png', quality = 3}
function P.iceyShot:giveOne()
	self.numHeld =self.numHeld + 3
end
function P.iceyShot:useToolAnimal(animal)
	self.numHeld = self.numHeld -1

	local tileY = animal.tileY
	local tileX = animal.tileX

	local bulletProcess = processList.iceBullet:new()
	bulletProcess.currentLoc = {x = tileToCoords(player.tileY, player.tileX).x+tileUnit/2, y = tileToCoords(player.tileY, player.tileX).y+tileUnit/2}
	bulletProcess.targetLoc = {tileX = tileX, tileY = tileY, x = tileToCoords(tileY, tileX).x, y = tileToCoords(tileY, tileX).y}
	bulletProcess.animal = animal

    if tileY<player.tileY then
		bulletProcess.direction = 0
	elseif tileX>player.tileX  then
		bulletProcess.direction = 1
	elseif tileY>player.tileY then
		bulletProcess.direction = 2
	elseif tileX<player.tileX then
		bulletProcess.direction = 3
	end

	processes[#processes+1] = bulletProcess
	--room[y][x] = pushables.iceBox:new()
	--table.insert(pushables, P.iceBox:new())
	--pushables[#pushables].tileY = y
	--pushables[#pushables].tileX = x
end
--[[function P.iceyShot:getToolableAnimals()
	local bool = 0
	if not player.attributes.tall then
		player.attributes.tall = true
		bool = 1
	end
		
	local toolableAnimals = P.gun:getToolableAnimals()
	
	if bool then
		player.attributes.tall = false
	end
	return toolableAnimals
end]]

--gumball



P.powderMix = P.superTool:new{name = "Tasty Powder", description = "Add to water", quality = -1, baseRange = 1}
function P.powderMix:usableOnTile(tile)
	return false
end --PowderMixes change the behaviors of puddles

------ 


P.robotArm = P.superTool:new{name = "Robotic Arm", description = "Reach for the stars", image = 'Graphics/robotArm.png', quality = 2, baseRange = 0}
function P.robotArm:usableOnTile(tile)
	return true
end 
P.robotArm.usableOnNothing = P.robotArm.usableOnTile
function P.robotArm:useToolTile(tile)
	self.numHeld = self.numHeld-1
	player.attributes.extendedRange = player.attributes.extendedRange+1
end
P.robotArm.useToolNothing = P.robotArm.useToolTile

P.sock = P.superTool:new{name = "Sock", description = "Shhhhh", image = 'Graphics/Tools/sock.png', quality = 1, baseRange = 0}
function P.sock:usableOnTile(tile)
	return true
end
P.sock.usableOnNothing = P.sock.usableOnTile
function P.sock:useToolTile(tile)
	self.numHeld = self.numHeld-1
	player.attributes.sockStep = true
	forcePowerUpdateNext = false
end
P.sock.useToolNothing = P.sock.useToolTile

P.gasPourer = P.superTool:new{name = "Gasoline Can", description = "Crude but powerful", image = 'Graphics/gaspourer.png', quality = 3, baseRange = 1}
function P.gasPourer:usableOnNothing()
	return true
end
function P.gasPourer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.gasPuddle:new()
	unlocks.unlockUnlockableRef(unlocks.gasPourerXtremeUnlock)
end

P.gasPourerXtreme = P.gasPourer:new{name = "Gasoline Pump", description = "Warning: Highly Flammable", image = 'Graphics/gaspourerxtreme.png', quality = 4, baseRange = 1}
function P.gasPourerXtreme:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.gasPuddle:new()
end
function P.gasPourerXtreme:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	self:spreadGas(tileY, tileX)
end
function P.gasPourerXtreme:spreadGas(tileY, tileX)
	room[tileY][tileX] = tiles.gasPuddle:new()
	if tileY>1 then
		if room[tileY-1][tileX]==nil then
			self:spreadGas(tileY-1, tileX)
		end
	end
	if tileY<roomHeight then
		if room[tileY+1][tileX]==nil then
			self:spreadGas(tileY+1, tileX)
		end
	end
	if tileX>1 then
		if room[tileY][tileX-1]==nil then
			self:spreadGas(tileY, tileX-1)
		end
	end
	if tileX<roomLength then
		if room[tileY][tileX+1]==nil then
			self:spreadGas(tileY, tileX+1)
		end
	end
end

P.buttonPlacer = P.superTool:new{name = "Button Placer", description = "", image = 'Graphics/buttonplacer.png', baseRange = 1, quality = 2}
function P.buttonPlacer:usableOnNothing()
	return true
end
function P.buttonPlacer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.button:new()
end

P.wireToButton = P.superTool:new{name = "Wire to Button", description = "Some things need an off switch", image = 'Graphics/wiretobutton.png', baseRange = 1, quality = 2}
function P.wireToButton:usableOnTile(tile)
	return tile:instanceof(tiles.wire)
end
function P.wireToButton:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.button:new()
end


--Foresight: let's you see what's in treasure tiles
P.foresight = P.superTool:new{name = "Crystal Ball", description = "See the future", image = 'Graphics/foresight.png', baseRange = 0, quality = 1}
function P.foresight:usableOnTile(tile)
	return true
end
P.foresight.usableOnNothing = P.foresight.usableOnTile
function P.foresight:useToolTile(tile)
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.treasureTile) then
				local supOrBas = util.random(5, 'toolDrop')
				if (supOrBas<5) then
					room[i][j] = tiles.toolTile:new()
					room[i][j]:randomize()
				else
					room[i][j] = tiles.supertoolTile:new()
				end
			end
		end
	end
	self.numHeld = self.numHeld-1
end
P.foresight.useToolNothing = P.foresight.useToolTile

P.tileDisplacer = P.superTool:new{name = "Tile Displacer", description = "Ctrl-X, Ctrl-V", heldTile = nil, image = 'Graphics/tiledisplacer2.png', baseImage = 'Graphics/tiledisplacer2.png', baseRange = 3, quality = 4}
function P.tileDisplacer:usableOnTile(tile)
	return self.heldTile==nil and not tile.untoolable
end
function P.tileDisplacer:usableOnNothing()
	return self.heldTile~=nil
end
function P.tileDisplacer:useToolTile(tile, tileY, tileX)
	self.image = tile.sprite
	self.heldTile = tile
	room[tileY][tileX] = nil
end
function P.tileDisplacer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = self.heldTile
	self.heldTile=nil
	self.image = self.baseImage
end
function P.tileDisplacer:nothingIsSomething()
	return true
end

P.tileSwapper = P.superTool:new{name = "Tile Swapper", description = "Swap them", toSwapCoords = nil, image = 'Graphics/tileswapper.png', baseImage = 'Graphics/tileswapper.png', baseRange = 3, quality = 4}
function P.tileSwapper:usableOnTile(tile)
	return not tile.untoolable
end
function P.tileSwapper:useToolTile(tile, tileY, tileX)
	if self.toSwapCoords==nil then
		self.toSwapCoords = {y = tileY, x = tileX}
		self.image = room[tileY][tileX].sprite
	else
		self.numHeld = self.numHeld-1
		local saveTile = room[tileY][tileX]
		room[tileY][tileX] = room[self.toSwapCoords.y][self.toSwapCoords.x]
		room[self.toSwapCoords.y][self.toSwapCoords.x] = saveTile
		self.toSwapCoords = nil
		self.image = self.baseImage
	end
end
function P.tileSwapper:nothingIsSomething()
	return true
end
function P.tileSwapper:resetTool()
	self.image = self.baseImage
	self.toSwapCoords = nil
end

P.tileCloner = P.superTool:new{name = "Tile Cloner", description = "Ctrl-C, Ctrl-V", heldTile = nil, image = 'Graphics/tilecloner3.png', baseImage = 'Graphics/tilecloner3.png', baseRange = 3, quality = 4}
function P.tileCloner:usableOnTile(tile)
	return self.heldTile==nil
end
function P.tileCloner:usableOnNothing()
	return self.heldTile~=nil
end
function P.tileCloner:useToolTile(tile, tileY, tileX)
	self.image = tile.sprite
	self.heldTile = tile
end
function P.tileCloner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = self.heldTile
	self.heldTile = nil
	self.image = self.baseImage
end
function P.tileCloner:nothingIsSomething()
	return true
end

P.shopReroller = P.superTool:new{name = "Shop Reroller", baseRange = 0, description = "Re-roll rquirements and items.", image = 'Graphics/shopreroller.png', quality = 2}
function P.shopReroller:usableOnTile(tile)
	return true
end
P.shopReroller.usableOnNothing = P.shopReroller.usableOnTile
function P.shopReroller:useToolTile(tile)
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				if room[i][j]:instanceof(tiles.supertoolTile) then
					local stQual = room[i][j].superQuality
					room[i][j] = tiles.supertoolTile:new()
					room[i][j].superQuality = stQual
				elseif room[i][j]:instanceof(tiles.toolTile) then
					room[i][j] = tiles.toolTile:new()
				end
			end
		end
	end
end
P.shopReroller.useToolNothing = P.shopReroller.useToolTile

P.ghostStep = P.superTool:new{name = "Ghost Step", description ="You should tap that!", image = 'Graphics/ghoststep.png', baseRange = 4, quality = 4}
function P.ghostStep:usableOnTile()
	return true
end
function P.ghostStep:useToolTile(tile)
	local stayCoords = {x = player.tileX, y = player.tileY}
	self.numHeld = self.numHeld-1
	tile:onEnter(player)
	player.tileX = stayCoords.x
	player.tileY = stayCoords.y
	updateGameState()
end

P.stoolPlacer = P.superTool:new{name = "Stool Placer", description = "Wanna get high?", image = 'GraphicsColor/halfwall.png', baseRange = 1, quality = 2}
function P.stoolPlacer:usableOnNothing()
	return true
end
function P.stoolPlacer:useToolNothing(tileY, tileX)
	room[tileY][tileX] = tiles.halfWall:new()
	self.numHeld = self.numHeld-1
end

P.lemonadeCup = P.superTool:new{name = "Lemonade Cup", description = "A summer afternoon delight",
image = 'Graphics/Tools/lemonadeCup.png', baseRange = 1, quality = 1}
function P.lemonadeCup:usableOnNothing()
	return true
end
function P.lemonadeCup:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.lemonade:new()
end

P.lemonParty = P.superTool:new{name = "Lemon Party", description = "A summer afternoon gone wrong",
image = 'Graphics/Tools/lemonadePitcher.png', baseRange = 1, quality = 2}
function P.lemonParty:usableOnNothing()
	return true
end
function P.lemonParty:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	self:spreadLemonade(tileY, tileX)
end
function P.lemonParty:spreadLemonade(tileY, tileX)
	room[tileY][tileX] = tiles.lemonade:new()
	if tileY>1 then
		if room[tileY-1][tileX]==nil then
			self:spreadLemonade(tileY-1, tileX)
		end
	end
	if tileY<roomHeight then
		if room[tileY+1][tileX]==nil then
			self:spreadLemonade(tileY+1, tileX)
		end
	end
	if tileX>1 then
		if room[tileY][tileX-1]==nil then
			self:spreadLemonade(tileY, tileX-1)
		end
	end
	if tileX<roomLength then
		if room[tileY][tileX+1]==nil then
			self:spreadLemonade(tileY, tileX+1)
		end
	end
end

P.inflation = P.superTool:new{name = "Deflation", description = "The more you have, the more you get", image = 'Graphics/inflation.png', baseRange = 0, quality = 3}
function P.inflation:usableOnNothing()
	return true
end
P.inflation.usableOnTile = P.inflation.usableOnNothing
function P.inflation:useToolNothing()
	self.numHeld = self.numHeld-1
	tools.coin.numHeld = math.ceil(tools.coin.numHeld*1.5)
end
P.inflation.useToolTile = P.inflation.useToolNothing

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

P.greed = P.superTool:new{name = "Greed", description = "Your greed is your demise", image = 'GraphicsBrush/endtile.png', baseRange = 0, quality = 1}
function P.greed:usableOnNothing()
	return true
end
P.greed.usableOnTile = P.greed.usableOnNothing
function P.greed:useToolNothing()
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.endTile) then
				player.prevTileX = player.tileX
				player.prevTileY = player.tileY
				room[i][j] = nil
				player.tileX = j
				player.tileY = i
				room[player.prevTileY][player.prevTileX] = tiles.endTile:new()
				return
			end
		end
	end
end
P.greed.useToolTile = P.greed.useToolNothing

P.towel = P.superTool:new{name = "Primer", description = "Get that blue paint off!", image = 'Graphics/towel.png', quality = 4}
function P.towel:usableOnTile(tile)
	if tile.destroyed then return false end
	if tile:instanceof(tiles.superStickyButton) then return true
	elseif tile:instanceof(tiles.unbreakableElectricFloor) then return true
	elseif tile:instanceof(tiles.unbrickableStayButton) then return true
	elseif tile:instanceof(tiles.unbreakablePowerSupply) then return true
	elseif tile:instanceof(tiles.unbreakableWire) then return true
	else return false end
end
function P.towel:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.superStickyButton) then
		local isDown = room[tileY][tileX].down
		room[tileY][tileX] = tiles.stickyButton:new()
		room[tileY][tileX].down = isDown
	elseif tile:instanceof(tiles.unbreakableElectricFloor) then
		room[tileY][tileX] = tiles.electricFloor:new()
	elseif tile:instanceof(tiles.unbrickableStayButton) then
		room[tileY][tileX] = tiles.stayButton:new()
	elseif tile:instanceof(tiles.unbreakablePowerSupply) then
		room[tileY][tileX] = tiles.powerSupply:new()
	elseif tile:instanceof(tiles.unbreakableWire) then
		local rot = room[tileY][tileX].rotation
		if tile:instanceof(tiles.unbreakableCrossWire) then
			room[tileY][tileX] = tiles.crossWire:new()
		elseif tile:instanceof(tiles.unbreakableHorizontalWire) then
			room[tileY][tileX] = tiles.horizontalWire:new()
		elseif tile:instanceof(tiles.unbreakableTWire) then
			room[tileY][tileX] = tiles.tWire:new()
		elseif tile:instanceof(tiles.unbreakableCornerWire) then
			room[tileY][tileX] = tiles.cornerWire:new()
		elseif tile:instanceof(tiles.unbreakableWire) then
			room[tileY][tileX] = tiles.wire:new()
		end
		room[tileY][tileX].rotation = rot
	else return false end
end

P.playerCloner  = P.superTool:new{name = "Self-Help Manual", description = "Unleash a new you", cloneExists = false, baseRange = 0, image = 'Graphics/playercloner1.2.png',
imageNoClone = 'Graphics/playercloner1.2.png', imageClone = 'Graphics/playercloner2.2.png', quality = 3}
function P.playerCloner:usableOnNothing()
	return true
end
function P.playerCloner:usableOnTile(tile)
	return true
end

function P.playerCloner:useToolNothing()
	if not self.cloneExists then
		self.cloneExists = true
		player.clonePos = {x = player.tileX, y = player.tileY, z = player.elevation}
		self.image = self.imageClone
	else
		self.numHeld = self.numHeld-1
		self.cloneExists = false
		player.tileX = player.clonePos.x
		player.tileY = player.clonePos.y
		player.elevation = player.clonePos.z
		player.clonePos = {x = 0, y = 0, z = 0}
		self.image = self.imageNoClone
	end
end
P.playerCloner.useToolTile = P.playerCloner.useToolNothing


--Salt: kills a snail, if thrown backwards the snail drops something
P.salt = P.superTool:new{name = "Salt", description = "The deadliest weapon...don't spill!",
image = 'Graphics/Tools/salt.png', baseRange = 2, quality = 1}
function P.salt:usableOnAnimal(animal)
	return animal:instanceof(animalList.snail)
end
function P.salt:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal:kill()
	local threwBehind = false
	if player.character.dirFacing=="right" then
		if animal.tileX<player.tileX then
			threwBehind = true
		end
	elseif player.character.dirFacing=="down" then
		if animal.tileY<player.tileY then
			threwBehind = true
		end
	elseif player.character.dirFacing=="left" then
		if animal.tileX>player.tileX then
			threwBehind = true
		end
	elseif player.character.dirFacing=="up" then
		if animal.tileY>player.tileY then
			threwBehind = true
		end
	end
	if threwBehind then
		animal:dropTool()
	end
end

--
P.shell = P.superTool:new{name = "Shell", description = "Curl up and hide", image = 'Graphics/shell.png', baseRange = 0, quality = -1}
function P.shell:usableOnNothing() -- I don't like this description
	return true
end
P.shell.usableOnTile = P.shell.usableOnNothing
function P.shell:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.shelled = true
end
P.shell.useToolTile = P.shell.useToolNothing

P.glitch = P.superTool:new{name = "Glitch", description = "...what just happened?", image = 'Graphics/glitch.png', baseRange = 1, quality = 3}
function P.glitch:usableOnNothing()
	return true
end
function P.glitch:usableOnTile(tile, tileY, tileX)
	if tile:getHeight()>0 and (not tile.canElevate) then return false end
	return true
end
function P.glitch:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	globalPowerBlock = true
	setPlayerLoc()
end
function P.glitch:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	globalDeathBlock = true
	globalPowerBlock = true
	setPlayerLoc()
end

P.bouncer = P.superTool:new{name = "Bouncer", description = "This club is for attractive people only.", image = 'Graphics/bouncer.png', baseRange = 1, quality = 1}
function P.bouncer:usableOnTile(tile, tileY, tileX)
	if tile.blocksMovement and tile:obstructsMovement() then return true end
end

function P.bouncer:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	player.prevTileY = player.tileY
	player.prevTileX = player.tileX

	local tpLoc = {x = player.tileX, y = player.tileY}
	local lastLoc = {x = player.tileX, y = player.tileY}

	for dist = 1, 3 do
		if tileY>player.tileY then
			if room[player.tileY-dist]~=nil and not (room[player.tileY-dist][player.tileX]~=nil and
			room[player.tileY-dist][player.tileX]:obstructsVision()) then
				tpLoc.y = player.tileY-dist
			end
		elseif tileY<player.tileY then
			if room[player.tileY+dist]~=nil and not (room[player.tileY+dist][player.tileX]~=nil and
			room[player.tileY+dist][player.tileX]:obstructsVision()) then
				tpLoc.y = player.tileY+dist
			end
		elseif tileX>player.tileX then
			if player.tileX-dist>0 and not (room[player.tileY][player.tileX-dist]~=nil and
			room[player.tileY][player.tileX-dist]:obstructsVision()) then
				tpLoc.x = player.tileX-dist
			end
		elseif tileX<player.tileX then
			if player.tileX+dist<=roomLength and not (room[player.tileY][player.tileX+dist]~=nil and
			room[player.tileY][player.tileX+dist]:obstructsVision()) then
				tpLoc.x = player.tileX+dist
			end
		end
		for i = 1, #pushables do
			if pushables[i].tileY==tpLoc.y and pushables[i].tileX==tpLoc.x then
				tpLoc = {x = lastLoc.x, y = lastLoc.y}
			end
		end
		if tpLoc.x==lastLoc.x and tpLoc.y==lastLoc.y then break end
		lastLoc = {x = tpLoc.x, y = tpLoc.y}
	end
	player.tileY = tpLoc.y
	player.tileX = tpLoc.x
	if room[player.tileY][player.tileX]~=nil then
		room[player.tileY][player.tileX]:onEnter(player)
	end
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
	setPlayerLoc()
end

P.shift = P.superTool:new{name = "Shift", description = "Now slide to the left", image = 'Graphics/shift.png', baseRange = 1, quality = 1}
function P.shift:usableOnNothing()
	return true
end
function P.shift:usableOnTile(tile)
	return not tile:obstructsMovement()
end
function P.shift:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	setPlayerLoc()
end
function P.shift:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	room[player.tileY][player.tileX]:onEnter()
	setPlayerLoc()
end

P.block = P.superTool:new{name = "Wall Builder", description = "Your default defense mechanism", image = 'Graphics/woodwall.png', baseRange = 1, quality = 2}
function P.block:usableOnNothing()
	return true
end
function P.block:usableOnTile(tile)
	return false
end
function P.block:useToolNothing(tileLocY, tileLocX)
	self.numHeld = self.numHeld-1
	room[tileLocY][tileLocX] = tiles.wall:new()
end

P.tileMagnet = P.superTool:new{name = "Super Magnet", description = "It pulls its weight.", image = 'Graphics/tilemagnet.png', quality = 4, baseRange = 4}
function P.tileMagnet:usableOnTile(tile, tileY, tileX) --- I don't like this description 
	--[[local tileX = 0
	local tileY = 0
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==tile then
				tileX = j
				tileY = i
			end
		end
	end
	if dist==1 then
		return false
	else
		local useLoc = {x = 0, y = 0}
		if player.tileX==tileX then
			if player.tileY>tileY then
				useLoc = {x = tileX, y = tileY+1}
			else
				useLoc = {x = tileX, y = tileY-1}
			end
		else
			if player.tileX>tileX then
				useLoc = {x = tileX+1, y = tileY}
			else
				useLoc = {x = tileX-1, y = tileY}
			end
		end
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
	end]]
	local dist = math.abs(player.tileY - tileY) + math.abs(player.tileX - tileX)
	if dist==1 and room[player.tileY][player.tileX]~=nil then return false
	elseif tile.untoolable then return false end
	return true
end
function P.tileMagnet:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	local useLoc = {x = 0, y = 0}
	if player.tileX==tileX then
		if player.tileY>tileY then
			useLoc = {x = tileX, y = tileY+1}
		else
			useLoc = {x = tileX, y = tileY-1}
		end
	else
		if player.tileX>tileX then
			useLoc = {x = tileX+1, y = tileY}
		else
			useLoc = {x = tileX-1, y = tileY}
		end
	end
	room[useLoc.y][useLoc.x] = tile
	room[tileY][tileX] = nil
end

P.pickaxe = P.superTool:new{name = "Pickaxe", description = "Get cracking!", baseRange = 1, image = 'Graphics/pickaxe.png', quality = 3}
function P.pickaxe:usableOnTile(tile)
	if tile.untoolable then return false end
	if tile:instanceof(tiles.wall) then return true end
	return false
end
function P.pickaxe:usableOnPushable()
	return true
end
function P.pickaxe:usableOnNothing()
	return true
end
function P.pickaxe:useToolNothing(tileY, tileX)
	P.shovel.useToolNothing(self, tileY, tileX)
end
function P.pickaxe:useToolTile(tile)
	self.numHeld = self.numHeld-1
	if tile.sawable then
		tile:destroy()
	elseif tile:instanceof(tiles.reinforcedGlass) then
			tile.cracked = true
	elseif tile:instanceof(tiles.glassWall) then
		tile:destroy()
	else
		tile.sawable = true
	end
end
function P.pickaxe:useToolPushable(pushable)
	self.numHeld = self.numHeld-1
	pushable:destroy()
end

P.luckyPenny = P.coin:new{name = "Lucky Penny", description = "May all your wishes come true", quality = 2, image = 'Graphics/Tools/luckyPenny.png'}
function P.luckyPenny:useToolTile(tile)
	if tile:instanceof(tiles.puddle) then
		self.numHeld = self.numHeld-1
		player.baseLuckBonus = player.baseLuckBonus+3.5
	else
		local willLose = util.random(2,'toolDrop')

		if willLose==2 then
			local changeLose = util.random(50, 'toolDrop')
			if changeLose<getLuckBonus() then
				willLose = 1
			end
			if willLose==2 then
				self.numHeld = self.numHeld-1
			end
		end
		if tile:instanceof(tiles.toolTaxTile) then
			if tile.tool==tools.brick then
				unlocks.unlockUnlockableRef(unlocks.luckyBrickUnlock)
			elseif tile.tool==tools.saw then
				unlocks.unlockUnlockableRef(unlocks.luckySawUnlock)
			end
		end
		tile:destroy()
	end
end

P.helmet = P.superTool:new{name = "Knight's Helmet", description = "You're feeling slanted", quality = 3, image = 'Graphics/helmet.png', baseRange = 2}
P.helmet.getToolableTiles = P.tool.getToolableTilesBox
function P.helmet:usableOnTile(tile, tileY, tileX)
	if tile:obstructsMovement() then return false
	else return tileY~=player.tileY and tileX~=player.tileX end
end
function P.helmet:usableOnNothing(tileY, tileX)
	return tileY~=player.tileY and tileX~=player.tileX
end
function P.helmet:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	setPlayerLoc()
end
function P.helmet:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	room[player.tileY][player.tileX]:onEnter(player)
	setPlayerLoc()
end


--Stealth Bomber: Teleports you forward and bombs the tiles in between
P.stealthBomber = P.superTool:new{name = "Stealth Bomber", description = "Drop 'n' Go", image = 'Graphics/stealthbomber.png', baseRange = 2, quality = 4}
P.stealthBomber.getToolableTiles = P.tool.getToolableTilesBox
function P.stealthBomber:usableOnNothing(tileY, tileX)
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then
			return false
		end
	end
	return math.abs(tileY-player.tileY)+math.abs(tileX-player.tileX)>1 and (tileY==player.tileY or tileX==player.tileX)
end
function P.stealthBomber:usableOnTile(tile, tileY, tileX)
	local dist = math.abs(player.tileY - tileY) + math.abs(player.tileX - tileX)
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then
			return false
		end
	end
	return dist>1 and (tileY==player.tileY or tileX==player.tileX)
end
function P.stealthBomber:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY

	if room[(player.tileY+player.prevTileY)/2][(player.tileX+player.prevTileX)/2]~= nil then
		room[(player.tileY+player.prevTileY)/2][(player.tileX+player.prevTileX)/2]:destroy()
	end

	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
	updateElevation()
	setPlayerLoc()
end
function P.stealthBomber:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY

	if room[(player.tileY+player.prevTileY)/2][(player.tileX+player.prevTileX)/2]~= nil then
		room[(player.tileY+player.prevTileY)/2][(player.tileX+player.prevTileX)/2]:destroy()
	end

	updateElevation()
	room[tileY][tileX]:onEnter(player)
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
	setPlayerLoc()
end


--Seeds: creates seeds which grow into a tree when watered
P.seeds = P.superTool:new{name = "Seeds", description = "Go forth and sow your wild oats", baseRange = 1, quality = 2,
image = 'Graphics/Tools/seeds.png'}
function P.seeds:usableOnNothing()
	return true
end
function P.seeds:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.tree:new()
end

P.supertoolDoubler = P.superTool:new{name = "Supertool Doubler", description = "Power, multiplied", baseRange = 0, quality = 4, image = 'Graphics/supertooldoubler.png'}
function P.supertoolDoubler:usableOnNothing()
	return true
end
function P.supertoolDoubler:usableOnTile()
	return true
end
function P.supertoolDoubler:useToolNothing()
	self.numHeld = self.numHeld-1

	for i = tools.numNormalTools+1, #tools do
		if tools[i]~=self and tools[i].numHeld>0 then
			tools[i].numHeld = tools[i].numHeld*2
		end
	end
end
P.supertoolDoubler.useToolTile = P.supertoolDoubler.useToolNothing

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

P.boxDisplacer = P.superTool:new{name = "Box Displacer", description = "Cheaper than FedEx", heldBox = nil, image = 'Graphics/boxdisplacer2.png', baseImage = 'Graphics/boxdisplacer2.png', baseRange = 3, quality = 3}
function P.boxDisplacer:usableOnPushable(pushable)
	return (not pushable.destroyed) and self.heldBox==nil
end
function P.boxDisplacer:usableOnNothing()
	return self.heldBox~=nil
end
function P.boxDisplacer:usableOnTile(tile)
	return tile:getHeight()==0 and (not tile:obstructsVision()) and self.heldBox~=nil
end
function P.boxDisplacer:useToolPushable(pushable)
	self.heldBox = pushable
	for i = 1, #pushables do
		if pushables[i]==pushable then
			table.remove(pushables, i)
			return
		end
	end
	self.image = self.heldBox.sprite
end
function P.boxDisplacer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	table.insert(pushables, self.heldBox)
	pushables[#pushables].tileY = tileY
	pushables[#pushables].tileX = tileX
	self.heldBox = nil
	self.image = self.baseImage
end
function P.boxDisplacer:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	table.insert(pushables, self.heldBox)
	pushables[#pushables].tileY = tileY
	pushables[#pushables].tileX = tileX
	self.heldBox = nil
	self.image = self.baseImage
end

P.boxCloner = P.superTool:new{name = "Box Cloner", description = "Gain a copy.", heldBox = nil, image = 'Graphics/boxcloner2.png', baseImage = 'Graphics/boxcloner2.png', baseRange = 3, quality = 4}
function P.boxCloner:usableOnPushable(pushable)
	return (not pushable.destroyed) and self.heldBox==nil
end
function P.boxCloner:usableOnNothing()
	return self.heldBox~=nil
end
function P.boxCloner:usableOnTile(tile)
	return tile:getHeight()==0 and (not tile:obstructsVision()) and self.heldBox~=nil
end
function P.boxCloner:useToolPushable(pushable)
	self.heldBox = pushable
	self.image = pushable.sprite
end
function P.boxCloner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local boxAdd = deepCopy(self.heldBox)
	boxAdd:setLoc()
	table.insert(pushables, boxAdd)
	pushables[#pushables].tileY = tileY
	pushables[#pushables].tileX = tileX
	self.heldBox = nil
	self.image = self.baseImage
end
function P.boxCloner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local boxAdd = deepCopy(self.heldBox)
	boxAdd:setLoc()
	table.insert(pushables, boxAdd)
	pushables[#pushables].tileY = tileY
	pushables[#pushables].tileX = tileX
	self.heldBox = nil
	self.image = self.baseImage
end

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

P.portalPlacerDouble = P.superTool:new{name = "Portal Placer 2", stage = 1, description = "Now with new colors!", image = 'Graphics/entranceportal2.png',
baseImage = 'Graphics/entranceportal2.png', secondImage = 'Graphics/exitportal2.png', baseRange = 1, quality = 2}
function P.portalPlacerDouble:usableOnNothing()
	return true
end
function P.portalPlacerDouble:useToolNothing(tileY, tileX)
	if self.stage == 1 then
		room[tileY][tileX] = tiles.entrancePortal2:new()
		self.image = self.secondImage
		self.stage = 2
	else
		self.numHeld = self.numHeld-1
		room[tileY][tileX] = tiles.exitPortal2:new()
		self.image = self.baseImage
		self.stage = 1
	end
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


--Steroids: Moves all tiles in the row
P.ironMan = P.superTool:new{name = "Steroids", description = "Do you even lift?", image = 'Graphics/ironman.png',
baseRange = 1, quality = 4}
function P.ironMan:usableOnTile(tile)
	local tileY
	local tileX
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==tile then
				tileY = i
				tileX = j
			end
		end
	end
	if player.tileX==tileX and player.tileY==tileY then return false end
	if player.tileY==tileY then
		if player.tileX<tileX then
			if room[tileY][roomLength]~=nil then return false end
		elseif player.tileX>tileX then
			if room[tileY][1]~=nil then return false end
		end
	elseif player.tileX==tileX then
		if player.tileY<tileY then
			if room[roomHeight][tileX]~=nil then return false end
		elseif player.tileY>tileY then
			if room[1][tileX]~=nil then return false end
		end
	end
	return true
end
function P.ironMan:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	if player.tileY==tileY then
		if player.tileX<tileX then
			for i = roomLength, tileX+1, -1 do
				if room[tileY][i-1]~=nil then
					room[tileY][i] = room[tileY][i-1]
					room[tileY][i-1] = nil
				end
			end
		elseif player.tileX>tileX then
			for i = 1, tileX-1 do
				if room[tileY][i+1]~=nil then
					room[tileY][i] = room[tileY][i+1]
					room[tileY][i+1] = nil
				end
			end
		end
	elseif player.tileX==tileX then
		if player.tileY<tileY then
			for i = roomHeight, tileY+1, -1 do
				if room[i-1][tileX]~=nil then
					room[i][tileX] = room[i-1][tileX]
					room[i-1][tileX] = nil
				end
			end
		elseif player.tileY>tileY then
			for i = 1, tileY-1 do
				if room[i+1][tileX]~=nil then
					room[i][tileX] = room[i+1][tileX]
					room[i+1][tileX] = nil
				end
			end
		end
	end
end

P.supertoolReroller = P.superTool:new{name = "Supertool Reroller", description = "You're rolling with the big boys now", 
image = 'Graphics/supertoolreroller.png', baseRange = 0, quality = 3}
function P.supertoolReroller:usableOnNothing()
	return true
end
P.supertoolReroller.usableOnTile = P.supertoolReroller.usableOnNothing
function P.supertoolReroller:useToolNothing()
	self.numHeld = self.numHeld-1

	local toolCount = 0
	for i = tools.numNormalTools+1, #tools do
		toolCount = toolCount+tools[i].numHeld
		tools[i].numHeld = 0
	end
	tools.giveRandomTools(0, toolCount+1)
end
P.supertoolReroller.useToolTile = P.supertoolReroller.useToolNothing

P.tunneler = P.superTool:new{name = "Tunneler", description = "Someone get me out of here!", image = 'KenGraphics/stairs.png',
baseRange = 1, quality = 4} --was desc Someone get me out of here!"
function P.tunneler:usableOnNothing()
	return true
end
function P.tunneler:useToolNothing(tileY, tileX)
	room[tileY][tileX] = tiles.tunnel:new()
	self.numHeld = self.numHeld - 1
end


--Super Saw: cuts down concrete
P.superSaw = P.superTool:new{name = "Super Saw", description = "I came, I sawed, I conquered", image = 'Graphics/saw.png',
baseRange = 1, quality = -1}
function P.superSaw:usableOnPushable()
	return true
end
function P.superSaw:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and tile:getHeight()>0 and not tile:instanceof(tiles.reinforcedGlass) and not tile:instanceof(tiles.glassWall)
end
function P.superSaw:useToolPushable(pushable)
	pushable:destroy()
end


--Super Ladder: spreads ladders
P.superLadder = P.superTool:new{name = "Super Ladder", description = "OH MY GOD, IT'S SPREADING", image = 'Graphics/ladder.png',
baseRange = 1, quality = -1}
P.superLadder.usableOnNothing = P.ladder.usableOnNothing
P.superLadder.useToolNothing = P.ladder.useToolNothing
P.superLadder.usableOnTile = P.ladder.usableOnTile
function P.superLadder:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	self:spreadLadders(tileY, tileX)
end
function P.superLadder:spreadLadders(tileY, tileX)
	room[tileY][tileX]:ladder()
	if tileY>1 then
		if room[tileY-1][tileX]~=nil and self:usableOnTile(room[tileY-1][tileX]) then
			self:spreadLadders(tileY-1, tileX)
		end
	end
	if tileY<roomHeight then
		if room[tileY+1][tileX]~=nil and self:usableOnTile(room[tileY+1][tileX]) then
			self:spreadLadders(tileY+1, tileX)
		end
	end
	if tileX>1 then
		if room[tileY][tileX-1]~=nil and self:usableOnTile(room[tileY][tileX-1]) then
			self:spreadLadders(tileY, tileX-1)
		end
	end
	if tileX<roomLength then
		if room[tileY][tileX+1]~=nil and self:usableOnTile(room[tileY][tileX+1]) then
			self:spreadLadders(tileY, tileX+1)
		end
	end
end


--Super Wire-cutters: can cut blue wires
P.superWireCutters = P.wireCutters:new{name = "Super Wire-cutters", description = "They can't stop you", -- Anything more ... you know
image = 'Graphics/wirecutters.png', quality = -1}-- was "Super Wire Cutters" ... Stone Splitters sounds cool but misleading.. Arkham's razor, Laser razor, Incsors: Something to chew on
function P.superWireCutters:usableOnNonOverlay(tile) -- "A cut above"
	return not tile.destroyed and (tile:instanceof(tiles.wire)
	or tile:instanceof(tiles.conductiveGlass) or tile:instanceof(tiles.reinforcedConductiveGlass) or tile:instanceof(tiles.electricFloor))
end
function P.superWireCutters:usableOnTile(tile)
	return self:usableOnNonOverlay(tile) or (tile.overlay~=nil and self:usableOnNonOverlay(tile.overlay))
end


--Super Water Bottle: works on unbreakable efloors
P.superWaterBottle = P.waterBottle:new{name = "Super Waterbottle", description = "Break the unbreakable",
image = 'Graphics/superwaterbottle.png', baseRange = 3, quality = -1}
function P.superWaterBottle:usableOnTile(tile)
	if not tile.destroyed and ((tile:instanceof(tiles.powerSupply) and not tile:instanceof(tiles.notGate)) or (tile:instanceof(tiles.electricFloor)) or tile:instanceof(tiles.untriggeredPowerSupply)) then
		return true
	end
	return false
end
function P.superWaterBottle:useToolTile(tile)
	self.numHeld = self.numHeld-1
	if not tile.destroyed then
		tile:destroy()
	end
end
function P.superWaterBottle:usableOnNothing()
	return true
end
function P.superWaterBottle:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	if room[tileY][tileX]~=nil then
		local t = room[tileY][tileX]
		if t:instanceof(tiles.wire) or t:instanceof(tiles.electricFloor) then
			unlocks.unlockUnlockableRef(unlocks.wireExtenderUnlock)
		end
	end
	room[tileY][tileX] = tiles.puddle:new()
end


--Super Sponge: spreads sponge effect
P.superSponge = P.superTool:new{name = "Super Sponge", description = "Clean everything", image = 'NewGraphics/sponge copy.png',
baseRange = 1, quality = -1}
function P.superSponge:usableOnTile(tile)
	if tile:instanceof(tiles.dustyGlassWall) and tile.blocksVision then
		return true
	elseif tile:instanceof(tiles.puddle) then return true
	elseif tile:instanceof(tiles.stickyButton) or (tile:instanceof(tiles.button) and tile.bricked) then return true
	elseif tile:instanceof(tiles.glue) then return true
	elseif tile:instanceof(tiles.slime) or tile:instanceof(tiles.conductiveSlime) then return true end
	return false
end
function P.superSponge:useToolTile(tile, tileY, tileX)
	tools.sponge:useToolTile(tile, tileY, tileX)
	if tile:instanceof(tiles.puddle) then
		self:spreadSponge(tileY, tileX)
	end
end
function P.superSponge:spreadSponge(tileY, tileX)
	room[tileY][tileX] = nil
	if tileY>1 then
		if room[tileY-1][tileX]~=nil and room[tileY-1][tileX]:instanceof(tiles.puddle) then
			self:spreadSponge(tileY-1, tileX)
		end
	end
	if tileY<roomHeight then
		if room[tileY+1][tileX]~=nil and room[tile+-1][tileX]:instanceof(tiles.puddle) then
			self:spreadSponge(tileY+1, tileX)
		end
	end
	if tileX>1 then
		if room[tileY][tileX-1]~=nil and room[tileY][tileX-1]:instanceof(tiles.puddle) then
			self:spreadSponge(tileY, tileX-1)
		end
	end
	if tileX<roomLength then
		if room[tileY][tileX+1]~=nil and room[tileY][tileX+1]:instanceof(tiles.puddle) then
			self:spreadSponge(tileY, tileX+1)
		end
	end
end


--Super Brick: can break reinforced glass and double stuns animals
P.superBrick = P.brick:new{name = "Super Brick", description = "Brick the unbrickable",
image = 'Graphics/superbrick.png', baseRange = 5, quality = -1}
function P.superBrick:usableOnTile(tile)
	if not tile.bricked and tile:instanceof(tiles.button) then
		return true
	end
	if not tile.destroyed and (tile:instanceof(tiles.glassWall) or tile:instanceof(tiles.reinforcedGlass)) then
		return true
	end
	if tile:instanceof(tiles.mousetrap) and not tile.bricked then
		return true
	end
	return false
end
function P.superBrick:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.glassWall) or tile:instanceof(tiles.reinforcedGlass) then
		tile:destroy()
	else
		tile:lockInState(true)
	end
end
function P.superBrick:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+2
	stats.incrementStat("animalsBricked")
end


--Super Gun: gun, but radial and works on concrete
P.superGun = P.superTool:new{name = "Super Gun", description = "", baseRange = 5,
image = 'Graphics/supergun.png', quality = -1}
P.superGun.getToolableTiles = P.tool.getToolableTilesBox
P.superGun.getToolableAnimals = P.tool.getToolableAnimalsBox
function P.superGun:usableOnTile(tile)
	if tile:instanceof(tiles.wall) and not tile:instanceof(tiles.glassWall) and not tile.destroyed then
		if tile.blocksVision then
			return true
		end
	elseif tile:instanceof(tiles.beggar) and tile.alive then
		return true
	end
	return false
end
P.superGun.usableOnAnimal = P.gun.usableOnAnimal
function P.superGun:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.beggar) then
		--unlocks.unlockUnlockableRef(unlocks.beggarPartyUnlock)
		tile:destroy()
	else
		tile:allowVision()
	end
end
function P.superGun:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	animal:kill()
end

P.woodenRain = P.superTool:new{name = "Wooden Rain", description = "It's raining wood", image = 'Graphics/ladder.png',
baseRange = 0, quality = 2}
function P.woodenRain:usableOnNothing()
	return true
end
P.woodenRain.usableOnTile = P.woodenRain.usableOnNothing
function P.woodenRain:useToolNothing()
self.numHeld = self.numHeld - 1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			local isValid = true
			if room[i][j]~=nil and not room[i][j]:usableOnNothing() then isValid = false
			else
				if player.tileY==i and player.tileX==j then isValid = false end
				for k = 1, #animals do
					if animals[k].tileY==i and animals[k].tileX ==j then isValid = false end
				end
				for k = 1, #pushables do
					if pushables[k].tileY==i and pushables[k].tileX ==j then isValid = false end
				end
			end
			if isValid then
				
				room[i][j] = tiles.ladder:new()
			end
		end
	end
end
P.woodenRain.useToolTile = P.woodenRain.useToolNothing

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

	specialTools = {0,0,0}
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

	specialTools = {0,0,0}
	updateTools()
end
P.permaUpgrade.useToolTile = P.permaUpgrade.useToolNothing

P.christmasSurprise = P.boxSpawner:new{name = "Christmas Surprise", description = "What's in the box?",
image = 'Graphics/Tools/santaHat.png',
baseRange = 1, quality = 3}
function P.christmasSurprise:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList.giftBox:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
	tools.saw.numHeld = tools.saw.numHeld+1
	for i = 1, #pushables do
		if pushables[i].name == "box" then
			local giftY = pushables[i].tileY
			local giftX = pushables[i].tileX
			pushables[i] = pushableList.giftBox:new()
			pushables[i].tileY = giftY
			pushables[i].tileX = giftX	
			pushables[i]:setLoc()
		end
	end
end
function P.christmasSurprise:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList.giftBox:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
	toSpawn:setLoc()
	tools.saw.numHeld = tools.saw.numHeld+1
	for i = 1, #pushables do
		if pushables[i].name == "box" then
			local giftY = pushables[i].tileY
			local giftX = pushables[i].tileX
			pushables[i] = pushableList.giftBox:new()
			pushables[i].tileY = giftY
			pushables[i].tileX = giftX
			pushables[i]:setLoc()
		end
	end
end

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

--selects walls from: glass, reinforcedGlass, concrete, metal, wood, tallWall, halfWall, toolTaxTile, dustyGlassWall
P.wallReroller = P.superTool:new{name = "Wall Reroller", description = "", image = 'Graphics/wallreroller.png',
baseRange = 0, quality = 4}
function P.wallReroller:usableOnNothing()
	return true
end
P.wallReroller.usableOnTile = P.wallReroller.usableOnNothing
function P.wallReroller:useToolNothing()
	self.numHeld = self.numHeld-1

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.wall) and not room[i][j]:instanceof(tiles.tree) then
				local newWall = util.random(9,'mapGen')
				if newWall==1 then
					room[i][j] = tiles.wall:new()
				elseif newWall==2 then
					room[i][j] = tiles.metalWall:new()
				elseif newWall==3 then
					room[i][j] = tiles.glassWall:new()
				elseif newWall==4 then
					room[i][j] = tiles.reinforcedGlass:new()
				elseif newWall==5 then
					room[i][j] = tiles.concreteWall:new()
				elseif newWall==6 then
					room[i][j] = tiles.tallWall:new()
				elseif newWall==7 then
					room[i][j] = tiles.halfWall:new()
				elseif newWall==8 then
					room[i][j] = tiles.toolTaxTile:new()
				elseif newWall==9 then
					room[i][j] = tiles.dustyGlassWall:new()
				end
			end
		end
	end
end
P.wallReroller.useToolTile = P.wallReroller.useToolNothing

--selects beggars from: red, green, blue, black, white, gold
P.beggarReroller = P.superTool:new{name = "Beggar Reroller", description = "Changing hats", image = 'Graphics/beggar.png',
baseRange = 0, quality = 1}
function P.beggarReroller:usableOnNothing()
	return true
end
P.beggarReroller.usableOnTile = P.beggarReroller.usableOnNothing
function P.beggarReroller:useToolNothing()
	self.numHeld = self.numHeld-1

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.beggar) then
				local newBeggar = util.random(6,'mapGen')
				if newBeggar==1 then
					room[i][j] = tiles.redBeggar:new()
				elseif newBeggar==2 then
					room[i][j] = tiles.greenBeggar:new()
				elseif newBeggar==3 then
					room[i][j] = tiles.blueBeggar:new()
				elseif newBeggar==4 then
					room[i][j] = tiles.goldBeggar:new()
				elseif newBeggar==5 then
					room[i][j] = tiles.whiteBeggar:new()
				elseif newBeggar==6 then
					room[i][j] = tiles.blackBeggar:new()
				end
			end
		end
	end
end
P.beggarReroller.useToolTile = P.beggarReroller.useToolNothing

-- Seymour 
P.xrayVision = P.superTool:new{name = "X-Ray Vision", description = "The bright side of Chernoybl",
image = 'Graphics/Tools/xrayVision.png',
baseRange = 0, quality = 4}
function P.xrayVision:usableOnNothing()
	return true
end
P.xrayVision.usableOnTile = P.xrayVision.usableOnNothing
function P.xrayVision:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.xrayVision = true
	for i = 1, mapHeight do
		for j = 1, mapHeight do
			if mainMap[i][j]~=nil then
				local xrayId = mainMap[i][j].roomid
				if map.getFieldForRoom(xrayId, 'hidden')~=nil and map.getFieldForRoom(xrayId, 'hidden') then
					visibleMap[i][j] = 1
					completedRooms[i][j] = 1
				end
			end
		end
	end
end
P.xrayVision.useToolTile = P.xrayVision.useToolNothing

P.secretTeleporter = P.superTool:new{name = "Secret Teleporter", description = "Let me show you something.", image = 'Graphics/secretteleporter.png',
baseRange = 0, quality = 2}
function P.secretTeleporter:usableOnNothing()
	return true
end
P.secretTeleporter.usableOnTile = P.secretTeleporter.usableOnNothing
function P.secretTeleporter:useToolNothing()
	self.numHeld = self.numHeld-1
	local xval = -1
	local yval = -1
	for i = 1, mapHeight do
		for j = 1, mapHeight do
			if mainMap[i][j]~=nil and map.isRoomType(mainMap[i][j].roomid, 'secretRooms') then
				xval = j
				yval = i
			end
		end
	end
	if xval>=0 and yval>=0 then
		resetTranslation()
		resetPlayerAttributesRoom()
		player.character:onRoomEnter()
		--set pushables of prev. room to pushables array, saving for next entry
		room.pushables = pushables
		room.animals = animals
		
		prevMapX = mapx
		prevMapY = mapy
		prevRoom = room

		room = mainMap[yval][xval].room
		mapx = xval
		mapy = yval

		if mainMap[yval][xval].dirEnter==nil then
			mainMap[yval][xval].dirEnter = {1,1,1,1}
		end

		if mainMap[yval][xval].dirEnter[1]==1 then
			player.tileX = math.floor(roomLength/2)
			player.tileY = 1
		elseif mainMap[yval][xval].dirEnter[2]==1 then
			player.tileY = math.floor(roomHeight/2)
			room.tileX = roomLength
		elseif mainMap[yval][xval].dirEnter[3]==1 then
			player.tileX = math.floor(roomLength/2)
			player.tileY = roomHeight
		else
			player.tileY = math.floor(roomHeight/2)
			room.tileX = 1
		end

		currentid = tostring(mainMap[mapy][mapx].roomid)
		if map.getFieldForRoom(currentid, 'autowin') then
			completedRooms[mapy][mapx] = 1
			unlockDoors()
		end
		if loadTutorial then
			player.enterX = player.tileX
			player.enterY = player.tileY
		end

		if (prevMapX~=mapx or prevMapY~=mapy) or dir == -1 then
			createElements()
		end
		visibleMap[mapy][mapx] = 1
		keyTimer.timeLeft = keyTimer.suicideDelay
		updateGameState()
	end
	setPlayerLoc()
end
P.secretTeleporter.useToolTile = P.secretTeleporter.useToolNothing

P.buttonReroller = P.superTool:new{name = "Button Reroller", description = "Rolled", image = 'Graphics/button.png',
baseRange = 0, quality = 1}
function P.buttonReroller:usableOnNothing()
	return true
end
P.buttonReroller.usableOnTile = P.buttonReroller.usableOnNothing
function P.buttonReroller:getButtonsList()
	return {tiles.button, tiles.stayButton, tiles.stickyButton}
end
function P.buttonReroller:useToolNothing()
	self.numHeld = self.numHeld-1

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.button) then
				local tilesArr = self:getButtonsList()
				local whichTile = util.random(#tilesArr,'mapGen')
				room[i][j] = tilesArr[whichTile]:new()
			end
		end
	end
end
P.buttonReroller.useToolTile = P.buttonReroller.useToolNothing

P.compass = P.superTool:new{name = "The Compass", description = "When your heart can't guide you, use this", image = 'Graphics/compass.png',
baseRange = 0, quality = 3}
function P.compass:usableOnNothing()
	return true
end
P.compass.usableOnTile = P.compass.usableOnNothing
function P.compass:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.permaMap = true
	tools.map.useToolNothing(self)
end
P.compass.useToolTile = P.compass.useToolNothing

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

P.luckySaw = P.superTool:new{name = "Lucky Saw", description = "Knock on wood",
image = 'Graphics/saw.png',
baseRange = 1, quality = 2}
function P.luckySaw:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and not tile.destroyed and tile.sawable
end
function P.luckySaw:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	tile:destroy()
	room[tileY][tileX] = tiles.toolTile:new()
	room[tileY][tileX]:absoluteFinalUpdate()
end
function P.saw:usableOnPushable(pushable)
	return not pushable.destroyed and pushable.sawable
end
function P.saw:useToolPushable(pushable)
	self.numHeld = self.numHeld - 1
	stats.incrementStat("boxesSawed")
	pushable:destroy()
end

P.luckyBrick = P.superTool:new{name = "Lucky Brick", description = "Knock on...glass?",
image = 'Graphics/brick.png',
baseRange = 3, quality = 2}
P.luckyBrick.usableOnTile = P.brick.usableOnTile
function P.luckyBrick:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.glassWall) or tile:instanceof(tiles.hDoor) or tile:instanceof(tiles.reinforcedGlass) then
		tile:destroy()
		room[tileY][tileX] = tiles.toolTile:new()
		room[tileY][tileX]:absoluteFinalUpdate()
	else
		tile:lockInState(true)
	end
end

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

P.animalReroller = P.superTool:new{name = "Animal Reroller", description = "What could go wrong?", image = 'Graphics/toolreroller.png',
baseRange = 0, quality = 1}
function P.animalReroller:usableOnNothing()
	return true
end
P.animalReroller.usableOnTile = P.animalReroller.usableOnNothing
function P.animalReroller:useToolNothing()
	self.numHeld = self.numHeld-1

	arList = self:getAnimalList()
	for i = 1, #animals do
		local aniChoice = util.random(#arList, 'misc')
		local newAni = arList[aniChoice]:new()
		newAni.tileX = animals[i].tileX
		newAni.tileY = animals[i].tileY
		animals[i] = newAni
	end
end
P.animalReroller.useToolTile = P.animalReroller.useToolNothing
function P.animalReroller:getAnimalList()
	return {animalList.pitbull, animalList.pup, animalList.cat, animalList.bombBuddy,
			animalList.snail, animalList.glueSnail, animalList.conductiveSnail, animalList.conductiveDog}
end

P.boxReroller = P.superTool:new{name = "Box Reroller", description = "",
image = 'Graphics/roomreroller.png',
baseRange = 0, quality = 1}
function P.boxReroller:usableOnNothing()
	return true
end
P.boxReroller.usableOnTile = P.boxReroller.usableOnNothing
function P.boxReroller:useToolNothing()
	self.numHeld = self.numHeld-1

	brList = self:getBoxList()
	for i = 1, #pushables do
		local pushChoice = util.random(#brList, 'misc')
		local newPush = brList[pushChoice]:new()
		newPush.tileX = pushables[i].tileX
		newPush.tileY = pushables[i].tileY
		pushables[i] = newPush
	end
end
P.boxReroller.useToolTile = P.boxReroller.useToolNothing
function P.boxReroller:getBoxList()
	return {pushableList.box, pushableList.conductiveBox, pushableList.lamp,
			pushableList.batteringRam, pushableList.giftBox, pushableList.boombox,
			pushableList.jackInTheBox, pushableList.playerBox, pushableList.animalBox,
			pushableList.bombBox}
end

P.animalTrainer = P.superTool:new{name = "Animal Trainer", image = 'Graphics/whip.png',
quality = 1, baseRange = 3}
function P.animalTrainer:usableOnAnimal()
	return true
end
function P.animalTrainer:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.trained = true
end

P.animalEnslaver = P.superTool:new{name = "Creature Command", description = "They'll let you take control", heldAnimal = nil, image = 'Graphics/whip.png',
baseImage = 'Graphics/whip.png',
quality = 2, baseRange = 3}
function P.animalEnslaver:usableOnAnimal()
	return self.heldAnimal == nil
end
function P.animalEnslaver:useToolAnimal(animal)
	animal.trained = true
	self.heldAnimal = animal
	for i = 1, #animals do
		if animals[i]==animal then
			table.remove(animals, i)
		end
	end
	self:updateSprite()
end
function P.animalEnslaver:usableOnNothing()
	if self.heldAnimal==nil then return false end
	return self.heldAnimal~=nil
end
function P.animalEnslaver:usableOnTile(tile)
	if self.heldAnimal==nil then return false end
	self.heldAnimal.elevation = player.elevation
	if tile:obstructsMovementAnimal(animal) then return false end
	return true
end
function P.animalEnslaver:updateSprite()
	if self.heldAnimal==nil then
		self.image = self.baseImage
	else
		self.image = self.heldAnimal.sprite
	end
end
function P.animalEnslaver:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1

	self.heldAnimal.tileX = tileX
	self.heldAnimal.tileY = tileY
	self.heldAnimal.prevTileX = self.heldAnimal.tileX
	self.heldAnimal.prevTileY = self.heldAnimal.tileY
	self.heldAnimal:setLoc()
	animals[#animals+1] = self.heldAnimal
	self.heldAnimal = nil
	self:updateSprite()
end
function P.animalEnslaver:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	self.heldAnimal.tileX = tileX
	self.heldAnimal.tileY = tileY
	self.heldAnimal:setLoc()
	animals[#animals+1] = self.heldAnimal
	self.heldAnimal = nil
	self:updateSprite()
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

P.fishingPole = P.superTool:new{name = "Fishing Pole", description = "Find the treasures that lie beneath", quality = 2, baseRange = 5,
image = 'Graphics/Tools/boxMagnet.png'}
function P.fishingPole:usableOnTile(tile)
	return tile:instanceof(tiles.puddle)
end
function P.fishingPole:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = nil
	tools.giveRandomTools(1)
end

P.blankTool = P.superTool:new{name = "Blank Tool", description = "Just as good", quality = 3, 
  image = 'Graphics/Tools/blankTool.png'}--Um, the desc here does not work...
for k, v in pairs(P.tool) do
	if string.find(k, 'getToolable') then
		P.blankTool[k] = function(self)
			local otherTools = self:getOtherSupers()

			if #otherTools == 0 then
				return {{},{},{},{},{}}
			elseif #otherTools == 1 then
				return otherTools[1][k](otherTools[1])
			else
				local toRet = {{},{},{},{},{}}
				local tilesA = otherTools[1][k](otherTools[1])
				local tilesB = otherTools[2][k](otherTools[2])
				for dir = 1, 5 do
					for i = 1, #tilesA[dir] do
						toRet[dir][i] = tilesA[dir][i]
					end
					for i = 1, #tilesB[dir] do
						local shouldSkip = false
						for j = 1, #tilesA[dir] do
							if tilesB[dir][i] == tilesA[dir][j] then
								shouldSkip = true
							end
						end
						if not shouldSkip then
							toRet[dir][#toRet[dir]+1] = tilesB[dir][i]
						end
					end
				end
				return toRet
			end
		end
	elseif string.match(k, 'useTool') then
		P.blankTool[k] = function(self,a,b,c,d,e,f,g) --the a,b,c,d,e is a hack because for some reason ... doesn't work
			self.numHeld = self.numHeld - 1
			local otherTools = self:getOtherSupers()
			for i = 1, #otherTools do
				otherTools[i][k](otherTools[i],a,b,c,d,e,f,g)
				otherTools[i].numHeld = otherTools[i].numHeld+1
			end
		end
	end
end

P.mindfulTool = P.superTool:new{name = "Mindful Tool", description = "Revisit the past", quality = 3, 
  image = 'Graphics/Tools/mindfulTool.png', lastTool = tools.saw}--Needs a new desc was (dumb): "Never forget where you came from." I tried "Repeat the past", still needs work
for k, v in pairs(P.tool) do
	if string.find(k, 'getToolable') then
		P.mindfulTool[k] = function(self)
			local otherTools = self:getLastTool()
			if #otherTools == 0 then
				return {{},{},{},{},{}}
			elseif #otherTools == 1 then
				return otherTools[1][k](otherTools[1])
			else
				local toRet = {{},{},{},{},{}}
				local tilesA = otherTools[1][k](otherTools[1])
				local tilesB = otherTools[2][k](otherTools[2])
				for dir = 1, 5 do
					for i = 1, #tilesA[dir] do
						toRet[dir][i] = tilesA[dir][i]
					end
					for i = 1, #tilesB[dir] do
						local shouldSkip = false
						for j = 1, #tilesA[dir] do
							if tilesB[dir][i] == tilesA[dir][j] then
								shouldSkip = true
							end
						end
						if not shouldSkip then
							toRet[dir][#toRet[dir]+1] = tilesB[dir][i]
						end
					end
				end
				return toRet
			end
		end
	elseif string.match(k, 'useTool') then
		P.mindfulTool[k] = function(self,a,b,c,d,e,f,g) --the a,b,c,d,e is a hack because for some reason ... doesn't work
			self.numHeld = self.numHeld - 1
			local otherTools = self:getLastTool()
			self.lastTool = otherTools[#otherTools]
			for i = 1, #otherTools do
				otherTools[i][k](otherTools[i],a,b,c,d,e,f,g)
				otherTools[i].numHeld = otherTools[i].numHeld+1
			end
			tools.lastToolUsed = tools.blankTool
		end
	end
end
function P.mindfulTool:getLastTool()
	local lastToolList = P.tool:getLastTool()
	if #lastToolList==1 then
		--edge cases
		if lastToolList[1].name == tools.mindfulTool.name then
			lastToolList[1] = self.lastTool
		end
		if lastToolList[1].name == tools.blankTool.name then
			lastToolList = {}
			for i = tools.numNormalTools+1, #tools do
				if tools[i].numHeld>0 and (tools[i].name~=tools.blankTool.name) and (tools[i].name ~= self.name) then
					lastToolList[#lastToolList+1] = tools[i]
				end
			end
		end
	end
	return lastToolList
end


--Explosive Meat: attracts dogs then explodes
P.explosiveMeat = P.superTool:new{name = "Explosive Meat", description = "It has a little kick to it", baseRange = 1,
image = 'Graphics/Tools/explosiveMeat.png', quality = -1}
P.explosiveMeat.usableOnNothing = P.meat.usableOnNothing
function P.explosiveMeat:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.explosiveMeat:new()
end
P.explosiveMeat.usableOnTile = P.meat.usableOnTile
function P.explosiveMeat:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.attractsAnimals = true
	tile.overlay = tiles.explosiveMeat
end

P.grenade = P.superTool:new{name = "Grenade", description = "Boom bitches", baseRange = 5,
  image = 'Graphics/grenade.png', quality = 4}
function P.grenade:usableOnTile()
	return true
end
function P.grenade:usableOnNothing()
	return true
end
function P.grenade:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	--util.createHarmlessExplosion(tileY, tileX, 1)
	local grenadeProcess = processList.grenadeThrow:new()
	grenadeProcess.currentLoc = {x = tileToCoords(player.tileY, player.tileX).x, y = tileToCoords(player.tileY, player.tileX).y}
	grenadeProcess.targetLoc = {tileX = tileX, tileY = tileY, x = tileToCoords(tileY, tileX).x, y = tileToCoords(tileY, tileX).y}

    if tileY<player.tileY then
		grenadeProcess.direction = 0
	elseif tileX>player.tileX  then
		grenadeProcess.direction = 1
	elseif tileY>player.tileY then
		grenadeProcess.direction = 2
	elseif tileX<player.tileX then
		grenadeProcess.direction = 3
	end

	processes[#processes+1] = grenadeProcess
end
function P.grenade:useToolNothing(tileY, tileX)
	self:useToolTile(nil, tileY, tileX)
end

--[[ideas:
--animal reroller
-box reroller
--animal trainer: grab animal/sprites, then release as scared beast that can destroy all tiles it enters
--More coin based tools

]]
--POTIONS
P.opPotion = P.superTool:new{name = "Crazy Serum", description = "Too good.", baseRange = 0,
  image = 'Graphics/Tools/opPotion.png', quality = 5, defaultDisabled = true}
function P.opPotion:usableOnNothing()
	return true
end
P.opPotion.usableOnTile = P.opPotion.usableOnNothing
function P.opPotion:useToolTile()
	self.numHeld = self.numHeld - 1
	player.character:transform()
end
P.opPotion.useToolNothing = P.opPotion.useToolTile

P.bombPotion = P.superTool:new{name = "Bomb Potion", description = "Extremely flammable", baseRange = 3,
  image = 'Graphics/grenade.png', quality = 4, defaultDisabled = true}
function P.bombPotion:usableOnTile()
	return true
end
function P.bombPotion:usableOnNothing()
	return true
end
function P.bombPotion:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	util.createHarmlessExplosion(tileY, tileX, 0)
end
function P.bombPotion:useToolNothing(tileY, tileX)
	self:useToolTile(nil, tileY, tileX)
end

P.electricPotion = P.superTool:new{name = "Electric Potion", description = "Tesla would be proud",
  image = 'Graphics/Tools/electricPotion.png', quality = 3, baseRange = 0, defaultDisabled = true}
function P.electricPotion:usableOnNothing()
	return true
end
P.electricPotion.usableOnTile = P.electricPotion.usableOnNothing
function P.electricPotion:useToolTile()
	self.numHeld = self.numHeld - 1
	player.character:electrify()
end
P.electricPotion.useToolNothing = P.electricPotion.useToolTile

P.teleportPotion = P.superTool:new{name = "Teleport Potion", decription = "Where did I go?", baseRange = 3,
  image = 'Graphics/Tools/teleportPotion.png', quality = 2, defaultDisabled = true}
function P.teleportPotion:usableOnTile(tile, tileY, tileX)
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then
			return false
		end
	end
	local dist = math.abs(player.tileY - tileY) + math.abs(player.tileX - tileX)
	return math.abs(dist) == self.range
end
function P.teleportPotion:usableOnNothing(tileY, tileX)
	return self:usableOnTile(nil, tileY, tileX)
end
function P.teleportPotion:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	if room[tileY][tileX] ~= nil then
		room[tileY][tileX]:onLeave(player)
	end
	if tile ~= nil then
		room[tileY][tileX]:onEnter(player)
	end
	setPlayerLoc()
end
function P.teleportPotion:useToolNothing(tileY, tileX)
	self:useToolTile(nil, tileY, tileX)
end

P.shittyPotion = P.superTool:new{name = "Shitty Potion", description = "Wait, where'd I go?",
  image = 'Graphics/Tools/shitPotion.png', quality = 1, baseRange = 0, defaultDisabled = true}
function P.shittyPotion:usableOnTile()
	return true
end
P.shittyPotion.usableOnNothing = P.shittyPotion.usableOnTile
function P.shittyPotion:useToolTile()
	self.numHeld = self.numHeld - 1
	player.attributes.invisible = true
end
P.shittyPotion.useToolNothing = P.shittyPotion.useToolTile

P.recycleBin = P.boxSpawner:new{name = "Recycle Bin", description = "Saving the Earth, one tool at a time", image = 'Graphics/recyclebin.png', quality = 3}
function P.recycleBin:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[14]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.recycleBin:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[14]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

P.iceBox = P.boxSpawner:new{name = "Ice Box", description = "Brrrrrrrrrr", image = 'Graphics/icebox.png', quality = 3}
function P.iceBox:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[13]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end
function P.iceBox:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[13]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	toSpawn:setLoc()
	pushables[#pushables+1] = toSpawn
end

P.nineLives = P.superTool:new{name = "Cat's Paw", description = "", lifeCount = 9, quality = -1, image = 'Graphics/catpaw9.png',
imageSet = {'Graphics/catpaw1.png', 'Graphics/catpaw2.png', 'Graphics/catpaw3.png', 'Graphics/catpaw4.png',
'Graphics/catpaw5.png', 'Graphics/catpaw6.png', 'Graphics/catpaw7.png', 'Graphics/catpaw8.png', 'Graphics/catpaw9.png'}}
function P.nineLives:checkDeath()
	self.lifeCount = self.lifeCount-1
	if self.lifeCount==0 then
		self.numHeld = self.numHeld-1
		self.lifeCount = 9
		self:updateSprite()
	end
	room[player.tileY][player.tileX] = nil
	for i = 1, #animals do
		if animals[i].tileY==player.tileY and animals[i].tileX==player.tileX then
			animals[i]:kill()
		end
	end

	for i = 1, #spotlights do
		if spotlights[i]:onPlayer() then
			spotlights[i].active = false
		end
	end

	self:updateSprite()
	return false
end
function P.nineLives:updateSprite()
	self.image = self.imageSet[self.lifeCount]
end

--1 is diamond, 2 is heart, 3 is spade, 4 is club, 5 is joker
P.card = P.superTool:new{name = "Card", description = "Expanding the deck", quality = 3,
image = 'Graphics/deckofcards.png', baseImage = 'Graphics/card.png',
cardOrder = {},
spriteOrder = {'Graphics/diamondcard.png', 'Graphics/heartcard.png', 'Graphics/spadecard.png', 'Graphics/clubcard.png', 'Graphics/jokercard.png'}}
function P.card:giveOne()
	self:draw(1)
end
function P.card:updateSprite()
	local nextCard = self.cardOrder[#self.cardOrder]
	if nextCard==nil then
		self.image = self.baseImage
	else
		self.image = self.spriteOrder[nextCard]
	end
end
function P.card:playCard()
	local card = self.cardOrder[#self.cardOrder]
	if card==1 then
		if tool~=nil then
			tools.giveToolsByReference({tools[tool]})
		end
	elseif card==2 then
		tools.giveRandomTools(1)
	elseif card==3 then
		unlockDoorsPlus()
	elseif card==4 then
		tools.giveToolsByReference({tools.card, tools.card})
	else
		if tools[tool]~=nil then
			tools.giveToolsByReference({tools[tool]})
		end
		tools.giveRandomTools(1)
		unlockDoorsPlus()
		tools.giveToolsByReference({tools.card, tools.card})
	end
	self.numHeld = self.numHeld-1
	self.cardOrder[#self.cardOrder] = nil
	self:updateSprite()
end
function P.card:draw(cardsToGive)
	self.numHeld = self.numHeld+cardsToGive

	for i = 1, cardsToGive do
		local whichCard = util.random(54,'toolDrop')
		if whichCard<=13 then
			whichCard = 1
		elseif whichCard<=26 then
			whichCard = 2
		elseif whichCard<=39 then
			whichCard = 3
		elseif whichCard<=52 then
			whichCard = 4
		else
			whichCard = 5
		end
		self.cardOrder[#self.cardOrder+1] = whichCard
	end
	self:updateSprite()
end
function P.card:getTileImage()
	return self.baseImage
end
function P.card:getDisplayImage()
	return self.baseImage
end

P.deckOfCards = P.superTool:new{name = "Deck of Cards", description = "One hand at a time", image = 'Graphics/deckofcards.png', quality = 5}
function P.deckOfCards:giveOne()
	tools.card:draw(7)
end

P.amnesiaPill = P.superTool:new{name = "Herman's Amnesia Pill", description = "Goes great with roofies!", quality = 5, baseRange = 0,
image = 'Graphics/amnesiapill.png'}	-- Groundhog's Day? 
function P.amnesiaPill:usableOnNothing()
	--on floors 1-6
	return floorIndex>=2 and floorIndex<=7
end
P.amnesiaPill.usableOnTile = P.amnesiaPill.usableOnNothing
function P.amnesiaPill:useToolNothing()
	self.numHeld = self.numHeld-1
	local maintainStairsLocs = stairsLocs[floorIndex-1]
	map.loadedMaps[floorIndex]=nil
	floorIndex = floorIndex-1
	goDownFloor()
	stairsLocs[floorIndex-1] = maintainStairsLocs
end
P.amnesiaPill.useToolTile = P.amnesiaPill.useToolNothing

P.heartTransplant = P.superTool:new{name = "Heart Transplant", description = "Another shot at life", quality = 3,
image = 'Graphics/heart.png'}
function P.heartTransplant:checkDeath()
	self.numHeld = self.numHeld-1
	room[player.tileY][player.tileX] = nil
	for i = 1, #animals do
		if animals[i].tileY==player.tileY and animals[i].tileX==player.tileX then
			animals[i]:kill()
		end
	end

	for i = 1, #spotlights do
		if spotlights[i]:onPlayer() then
			spotlights[i].active = false
		end
	end

	return false
end

P.shield = P.superTool:new{name = "Holy Shield", description = "Aura of protection", quality = -1, image = 'Graphics/shield.png',
baseImage = 'Graphics/shield.png', activeImage = 'Graphics/shieldactive.png', active = false, baseRange = 0}
function P.shield:usableOnNothing()
	return not self.active
end
P.shield.usableOnTile = P.shield.usableOnNothing
function P.shield:useToolNothing()
	player.attributes.shieldCounter = player.attributes.shieldCounter+30
	self.active = true
	self:updateSprite()
end
P.shield.useToolTile = P.shield.useToolNothing
function P.shield:updateSprite()
	if self.active then
		self.image = self.activeImage
	else
		self.image = self.baseImage
	end
end

P.reactiveShield = P.superTool:new{name = "Mirror", description = "Don't get caught", quality = -1, image = 'Graphics/shield.png', baseRange = 0}
function P.reactiveShield:checkDeath(deathSource)
	if deathSource == 'spotlight' then
		self.numHeld = self.numHeld-1
		player.attributes.shieldCounter = player.attributes.shieldCounter+3
		return false
	end
	return true
end

P.shrooms = P.superTool:new{name = "Mushroom Conconction", description = "Get weird", quality = 3,
image = 'KenGraphics/mushroom.png', baseRange = 0, baseImage = 'KenGraphics/mushroom.png', activeImage = 'Graphics/shieldactive.png', active = false}
function P.shrooms:usableOnNothing()
	return not self.active
end
P.shrooms.usableOnTile = P.shield.usableOnNothing
function P.shrooms:useToolNothing()
	player.attributes.invincibleCounter = player.attributes.invincibleCounter+10
	self.active = true
	turnOnMushroomMode()
	self:updateSprite()
end
P.shrooms.useToolTile = P.shrooms.useToolNothing
function P.shrooms:updateSprite()
	if self.active then
		self.image = self.activeImage
	else
		self.image = self.baseImage
	end
end


--Ammo Pack: gives three guns on pickup
P.ammoPack = P.superTool:new{name = "Ammo Pack", description = "Get back on your feet", quality = 3,
image = 'Graphics/Tools/gun.png'} --Reset, reload, recover, 	get reloaded 	or Hoodlum's Hookup: Pack some heat Still lAAAAAMe
function P.ammoPack:giveOne()
	tools.gun.numHeld = tools.gun.numHeld+3
end

P.stopwatch = P.superTool:new{name = "Stopwatch", description = "Master of time", quality = 2, baseRange = 0,
image = 'Graphics/Tools/stopwatch.png'}
function P.stopwatch:usableOnNothing()
	return true
end
P.stopwatch.usableOnTile = P.stopwatch.usableOnNothing
function P.stopwatch:useToolNothing()
	gameTime.timeLeft = gameTime.timeLeft + 10
	self.numHeld = self.numHeld-1
	player.attributes.clockFrozen = true 
	--player.attributes.timeFrozen = true
end
P.stopwatch.useToolTile = P.stopwatch.useToolNothing

P.fireBreath = P.superTool:new{name = "asdf", description = "Reset, reload, recover", quality = 4,
image = 'Graphics/Tools/fireBreath.png', defaultDisabled = true, baseRange = 3}
function P.fireBreath:usableOnTile(tile, tileY, tileX)
	local dist = math.abs(player.tileY-tileY)+math.abs(player.tileX-tileX)

	return (P.saw:usableOnTile(tile, tileY, tileX) and dist<=P.saw.baseRange) or
	(P.ladder:usableOnTile(tile, tileY, tileX) and dist<=P.ladder.baseRange) or 
	(P.gun:usableOnTile(tile, tileY, tileX) and dist<=P.gun.baseRange)
end
function P.fireBreath:usableOnPushable(pushable)
	local dist = math.abs(player.tileY-pushable.tileY)+math.abs(player.tileX-pushable.tileX)

	return (P.saw:usableOnPushable(pushable) and dist<=P.saw.baseRange) or
	(P.ladder:usableOnPushable(pushable) and dist<=P.ladder.baseRange) or 
	(P.gun:usableOnPushable(pushable) and dist<=P.gun.baseRange)
end
function P.fireBreath:usableOnNothing(tileY, tileX)
	return math.abs(player.tileY-tileY)+math.abs(player.tileX-tileX)<=1
end
function P.fireBreath:usableOnAnimal(animal)
	return P.gun.usableOnAnimal(self, animal)
end
function P.fireBreath:useToolTile(tile, tileY, tileX)
	if P.saw:usableOnTile(tile, tileY, tileX) then
		P.saw.useToolTile(self, tile, tileY, tileX)
	elseif P.ladder:usableOnTile(tile, tileY, tileX) then
		P.ladder.useToolTile(self, tile, tileY, tileX)
	elseif P.gun:usableOnTile(tile, tileY, tileX) then
		P.gun.useToolTile(self, tile, tileY, tileX)
	end
end
function P.fireBreath:useToolPushable(pushable)
	P.saw.useToolPushable(self, pushable)
end
function P.fireBreath:useToolNothing(tileY, tileX)
	P.ladder.useToolNothing(self, tileY, tileX)
end
function P.fireBreath:useToolAnimal(animal)
	P.gun.useToolAnimal(self, animal)
end

P.claw = P.superTool:new{name = "qwer", description = "Reset, reload, recover", quality = 5,
image = 'Graphics/Tools/claw.png', defaultDisabled = true}
function P.claw:usableOnTile(tile, tileY, tileX)
	local dist = math.abs(player.tileY-tileY)+math.abs(player.tileX-tileX)

	return (P.wireCutters:usableOnTile(tile, tileY, tileX) and dist<=P.wireCutters.baseRange) or
	(P.waterBottle:usableOnTile(tile, tileY, tileX) and dist<=P.waterBottle.baseRange) or 
	(P.sponge:usableOnTile(tile, tileY, tileX) and dist<=P.sponge.baseRange) or
	(P.brick:usableOnTile(tile, tileY, tileX) and dist<=P.brick.baseRange)
end
function P.claw:usableOnNonOverlay(tile)
	return not tile.destroyed and ((tile:instanceof(tiles.wire) and not tile:instanceof(tiles.unbreakableWire)) or (tile:instanceof(tiles.electricFloor) and not tile:instanceof(tiles.unbreakableElectricFloor)))
end
function P.claw:usableOnPushable(pushable)
	local dist = math.abs(player.tileY-pushable.tileY)+math.abs(player.tileX-pushable.tileX)

	return (P.wireCutters:usableOnPushable(pushable) and dist<=P.wireCutters.baseRange) or
	(P.waterBottle:usableOnPushable(pushable) and dist<=P.waterBottle.baseRange) or 
	(P.sponge:usableOnPushable(pushable) and dist<=P.sponge.baseRange) or
	(P.brick:usableOnPushable(pushable) and dist<=P.brick.baseRange)
end
function P.claw:usableOnNothing(tileY, tileX)
	return math.abs(player.tileY-tileY)+math.abs(player.tileX-tileX)<=1
end
function P.claw:usableOnAnimal(animal)
	local dist = math.abs(player.tileY-animal.tileY)+math.abs(player.tileX-animal.tileX)

	return dist<P.brick.baseRange
end
function P.claw:useToolTile(tile, tileY, tileX)
	if P.wireCutters:usableOnTile(tile, tileY, tileX) then
		P.wireCutters.useToolTile(self, tile, tileY, tileX)
	elseif P.waterBottle:usableOnTile(tile, tileY, tileX) then
		P.waterBottle.useToolTile(self, tile, tileY, tileX)
	elseif P.sponge:usableOnTile(tile, tileY, tileX) then
		P.sponge.useToolTile(self, tile, tileY, tileX)
	elseif P.brick:usableOnTile(tile, tileY, tileX) then
		P.brick.useToolTile(self, tile, tileY, tileX)
	end
end
function P.claw:useToolPushable(pushable)
	if P.wireCutters:usableOnPushable(pushable) then
		P.wireCutters.useToolPushable(self, pushable)
	elseif P.waterBottle:usableOnPushable(pushable) then
		P.waterBottle.useToolPushable(self, pushable)
	elseif P.sponge:usableOnPushable(pushable) then
		P.sponge.useToolPushable(self, pushable)
	elseif P.brick:usableOnPushable(pushable) then
		P.brick.useToolPushable(self, pushable)
	end
end
function P.claw:useToolNothing(tileY, tileX)
	P.waterBottle.useToolNothing(self, tileY, tileX)
end
function P.claw:useToolAnimal(animal)
	P.brick.useToolAnimal(self, animal)
end

P.wing = P.superTool:new{name = "tttt", description = "Reset, reload, recover", useWithArrowKeys = false, quality = 2,
image = 'Graphics/Tools/wing.png', defaultDisabled = true, baseRange = 2}
function P.wing:usableOnTile(tile)
	if tile.untoolable then return false end
	for i = 1, #pushables do
		if pushables[i].tileX == tile.tileX and pushables[i].tileY == tile.tileY then return false end
	end
	return true
end
function P.wing:usableOnNothing()
	return true
end
function P.wing:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	updateElevation()
	room[tileY][tileX]:onEnter(player)
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
end
function P.wing:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	updateElevation()
end

P.dragonEgg = P.superTool:new{name = "Dragon Egg", desciption = "asdwerwa", quality = 3, baseRange = 1,
image = 'Graphics/Tools/dragonEgg.png', defaultDisabled = true}
function P.dragonEgg:usableOnNothing()
	return true
end
function P.dragonEgg:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1

	local addAnimal = animalList.babyDragon:new()
	addAnimal.tileX = tileX
	addAnimal.tileY = tileY
	addAnimal.prevTileX = tileX
	addAnimal.prevTileY = tileY
	animals[#animals+1] = addAnimal
end

P.dragonFriend = P.superTool:new{name = "Dragon Egg 2", desciption = "asdwerwa", quality = 3, baseRange = 2,
image = 'Graphics/Tools/dragonEgg2.png', defaultDisabled = true}
function P.dragonFriend:usableOnNothing()
	return true
end
function P.dragonFriend:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1

	local addAnimal = animalList.dragonFriend:new()
	addAnimal.tileX = tileX
	addAnimal.tileY = tileY
	addAnimal.prevTileX = tileX
	addAnimal.prevTileY = tileY
	animals[#animals+1] = addAnimal
end

P.demonHoof = P.superTool:new{name = "Demon Hoof", baseRange = 1, description = "Strength in sin", quality = 5}
function P.demonHoof:giveOne()
	self.numHeld = self.numHeld+1
	player.attributes.superRammy = true
end
function P.demonHoof:usableOnTile(tile)
	return true
end
function P.demonHoof:useToolTile(tile)
	self.numHeld = self.numHeld-1
	tile:destroy()
end

P.demonFeather = P.superTool:new{name = "Demon Feather", baseRange = 1, description = "Flight of the faithless", quality = 5}
function P.demonFeather:giveOne()
	self.numHeld = self.numHeld+1
	player.attributes.flying = true
end
function P.demonFeather:usableOnTile(tile)
	return true
end
function P.demonFeather:useToolTile(tile)
	self.numHeld = self.numHeld-1
	tile:destroy()
end

P.discountTag = P.superTool:new{name = "Discount Tag", baseRange = 0, description = "Greed brings rewards", quality = 5}
function P.discountTag:usableOnNothing()
	return true
end
function P.discountTag:usableOnTile(tile)
	return true
end
function P.discountTag:useToolNothing()
end
P.discountTag.useToolTile = P.discountTag.useToolNothing

P.diagonal = P.superTool:new{name = "Diagonal", baseRange = 2, defaultDisabled = true, infiniteUses = true}
P.diagonal.getToolableTiles = P.tool.getToolableTilesBox
function P.diagonal:usableOnTile(tile, tileY, tileX)
	if tile:obstructsMovement() then return false
	else return tileY~=player.tileY and tileX~=player.tileX end
end
function P.diagonal:usableOnNothing(tileY, tileX)
	return tileY~=player.tileY and tileX~=player.tileX
end
function P.diagonal:useToolNothing(tileY, tileX)
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	setPlayerLoc()
end
function P.diagonal:useToolTile(tile, tileY, tileX)
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	room[player.tileY][player.tileX]:onEnter(player)
	setPlayerLoc()
end

P.megaUnlock = P.superTool:new{name = "Psychic Key", baseRange = 0, description = "When one door closes, they all open", --Ben most are you fucking kidding me
quality = 4, image = 'Graphics/psychickey3.png'}
function P.megaUnlock:usableOnNothing()
	return true
end
P.megaUnlock.usableOnTile = P.megaUnlock.usableOnNothing
function P.megaUnlock:useToolNothing()
	self.numHeld = self.numHeld-1
	
	for i = 1, mapHeight do
		for j = 1, mapHeight do
			if mainMap[i][j]~=nil then
				local xrayId = mainMap[i][j].roomid
				if map.getFieldForRoom(xrayId, 'hidden')==nil or not map.getFieldForRoom(xrayId, 'hidden') then
					visibleMap[i][j] = 1
					completedRooms[i][j] = 1
				end
			end
		end
	end
end
P.megaUnlock.useToolTile = P.megaUnlock.useToolNothing

P.medicine = P.superTool:new{name = "Erik's Medicine", baseRange = 0, description = "Just a little more time....",
quality = 1}
function P.medicine:usableOnNothing()
	return true
end
P.medicine.usableOnTile = P.medicine.usableOnNothing
function P.medicine:useToolNothing()
	self.numHeld = self.numHeld-1
	gameTime.timeLeft = gameTime.timeLeft+100 + gameTime.timeLeft/10
	--should have more functionality as well, so it's not lame
end
P.medicine.useToolTile = P.medicine.useToolNothing

P.eraser = P.superTool:new{name = "Eraser", baseRange = 1, image = 'Graphics/eraser.png', description = "Create the void", quality = 4}
function P.eraser:usableOnTile()
	return true
end
function P.eraser:usableOnNothing()
	return true
end
function P.eraser:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.pit:new()
end
function P.eraser:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.pit:new()
end

P.tpRevive = P.superTool:new{name = "Flashback", description = "Not dead...but afraid", baseRange = 0, image = 'Graphics/tprevive.png', destroyOnRevive = false, quality = 4}
function P.tpRevive:checkDeath()
	self.numHeld = self.numHeld-1

	P.teleporter.useToolNothing(self, tileY, tileX)

	updateGameState(false)
	log("Revived!")

	return false
end

P.rewindRevive = P.superTool:new{name = "Revert", description = "Not dead...yet", baseRange = 0, image = 'Graphics/deathWatch.png', destroyOnRevive = false, quality = 4}
function P.rewindRevive:checkDeath()
	

	saveStairs.onEnter()

	updateGameState(false)
	self.numHeld = self.numHeld-1
	log("Revived!")
 
	return false
end

P.shroomRevive = P.superTool:new{name = "Shroom Transplant", description = "Not dead...but wacked", baseRange = 0, image = 'Graphics/shroomtransplant.png', baseImage = 'KenGraphics/mushroom.png', activeImage = 'KenGraphics/mushroom.png', destroyOnRevive = false, quality = 4}
function P.shroomRevive:checkDeath()
	updateGameState(false)

	player.attributes.invincibleCounter = player.attributes.invincibleCounter+4
	self.active = true
	turnOnMushroomMode()
	self:updateSprite()

	log("Revived!")
 
	return false
end
function P.shroomRevive:updateSprite()
	if self.active then
		self.image = self.activeImage
	else
		self.image = self.baseImage
	end
end

P.treasureThief = P.superTool:new{name = "Treasure Snatching Beam", description = "Steal from anyone", baseRange = 100, image = 'Graphics/treasurethief2.png', quality = 2}
function P.treasureThief:usableOnTile() ---Currently does not always grab the closest
	return true
end
P.treasureThief.usableOnNothing = P.treasureThief.usableOnTile
function P.treasureThief:grab(tileY, tileX)
	local endCoord = 1
	local stepNum = 1
	if tileY == player.tileY then
		if tileX>player.tileX then
			endCoord = roomLength
		else
			stepNum = -1
		end
		for i = player.tileX, endCoord, stepNum do
			if room[tileY][i]~=nil and room[tileY][i]:instanceof(tiles.treasureTile) then
				room[tileY][i]:onEnter()
				room[tileY][i] = nil
				return
			end
		end
	elseif tileX == player.tileX then
		if tileY>player.tileY then
			endCoord = roomHeight
		else
			stepNum = -1
		end
		for i = player.tileY, endCoord, stepNum do
			if room[i][tileX]~=nil and room[i][tileX]:instanceof(tiles.treasureTile) then
				room[i][tileX]:onEnter()
				room[i][tileX] = nil
				return
			end
		end
	end
end
function P.treasureThief:useToolTile(tile, tileY, tileX)
	self:grab(tileY, tileX)
	self.numHeld = self.numHeld-1
end
function P.treasureThief:useToolNothing(tileY, tileX)
	self:grab(tileY, tileX)
	self.numHeld = self.numHeld-1
end

P.roomRestore = P.superTool:new{name = "Room Restorer", description = "Hard Reboot", quality  = 3, image = 'Graphics/doorwatch.png', baseRange = 0}
function P.roomRestore:usableOnTile(tile)
	return true
end
P.roomRestore.usableOnNothing = P.roomRestore.usableOnTile
function P.roomRestore:useToolTile(tile)
	hackEnterRoom(mainMap[mapy][mapx].roomid, mapy, mapx)
	self.numHeld = self.numHeld-1
end
function P.roomRestore:useToolNothing()
	hackEnterRoom(mainMap[mapy][mapx].roomid, mapy, mapx)
	self.numHeld = self.numHeld-1
end




P.gumballs = P.superTool:new{name = "Gumball Machine", description = "Insane Flavors", baseRange = 0, image = 'Graphics/card.png', quality = 5}
function P.gumballs:giveOne()
	tools.gumball.give(8)
end


P.gumball = P.superTool:new{name = "A Brown Gumball", description = "Tastes like shadows", quality = -1, baseRange = 0}
function P.gumball:give(num)
	self.numHeld = self.numHeld+num
end
function P.gumball:usableOnTile(tile)
	return true
end
function P.gumball:useToolTile(tile)
	player.attributes.invisible = true
	--Code to make this temporary
end


P.repair = P.superTool:new{name = "Duct tape", description = "Fix just about anything", baseRange = 1, quality  = 2,
image = 'KenGraphics/mushroom.png'}
function P.repair:usableOnTile(tile)
	if tile.destroyed then
		return true
	end
end
function P.repair:useToolTile(tile, tileY, tileX)
	for i = 1, #tiles do
		if room[tileY][tileX].name==tiles[i].name then
			room[tileY][tileX] = tiles[i]:new()
			break
		end
	end
	room[tileY][tileX] = room[tileY][tileX]:new()
	self.numHeld = self.numHeld-1
end
function P.repair:nothingIsSomething()
	return true
end

P.preservatives = P.superTool:new{name = "Preservatives", description = "Take care of your tools", baseRange = 0, quality = 3}
function P.preservatives:preserve(currentTool)
	if currentTool~=nil then
		tools.giveToolsByReference({tools[currentTool]})
		self.numHeld = self.numHeld-1
	end
end
--Consumed in place of other supers


P.mutantShield = P.superTool:new{name = "Mutant Carapace", description = "Specialist defence", baseRange = 0, quality = 3, image = "KenGraphics/mushroom.png", adaptation = nil, sprite = image}
function P.mutantShield:giveOne()
	if self.numHeld == 0 then
		adaptation = nil
	end
	self.numHeld = self.numHeld + 2
end
function P.mutantShield:checkDeath()
	sprite = room[player.tileY][player.tileX].sprite

	if room[player.tileY][player.tileX] ~= nil and room[player.tileY][player.tileX]:willKillPlayer() then
		if self.adaptation == nil or self.adaptation == room[player.tileY][player.tileX].name then
			self.adaptation = room[player.tileY][player.tileX].name

			room[player.tileY][player.tileX] = nil

			return self:fin(sprite)
		end
	end

	for i = 1, #animals do
		if animals[i].tileY==player.tileY and animals[i].tileX==player.tileXt and animals[i]:willKillPlayer() then
			if self.adaptation == nil or adaptation == animals[i].name then
				self.adaptation = animals[i].name

				animals[i]:kill()

				return self:fin(sprite)
			end
		end
	end

	for i = 1, #spotlights do
		if spotlights[i]:onPlayer() then
			if self.adaptation == nil or  spotlights[i].name == self.adaptation then
				self.adaptation = spotlights[i].name

				spotlights[i].active = false

				return self:fin(sprite)
			end
		end
	end
	return true
	
end
function P.mutantShield:fin(tile)
	self.numHeld = self.numHeld - 1
	self.sprite = sprite
	if self.numHeld == 0 then
		self.adaptation = nil
	end
	return false
end





P.chargedShield = P.superTool:new{name = "Charged Shield", description = "The odds of survival are ever increasing", quality = 3, image = 'Graphics/heart.png', charge = 0, baseRange = 0}
function P.chargedShield:giveOne()
	if self.numHeld >0 then
		self.charge = self.charge + 2 + self.numHeld*2
	else
		self.charge = 0
	end
	self.numHeld = self.numHeld + 1

end
function P.useToolNothing()
	self.numHeld = self.numHeld - 1
	self.charge = self.charge + 10
end
P.chargedShield.useToolTile() = P.chargedShield.useToolNothing()
function P.chargedShield:checkDeath()
	
	while self.charge > 0 do 
		self.charge = self.charge-1
		if util.random(20,'toolDrop') == 1 then
			room[player.tileY][player.tileX] = nil
		for i = 1, #animals do
			if animals[i].tileY==player.tileY and animals[i].tileX==player.tileX then
			animals[i]:kill()
			end
		end

		for i = 1, #spotlights do
			if spotlights[i]:onPlayer() then
			spotlights[i].active = false
			end
		end

		return false
		end
	end 
	self.numHeld = self.numHeld-1
	self.charge = 5
	return true
	
end







----Following are garabage






P.superRange = P.superTool:new{name = "Elastification", description = "Boost the range of your supertools", baseRange = 0, quality = 1, power = 0, active = 0}
function P.superRange:giveOne()
	self.power = 0
	self.numHeld = self.numHeld+1
end
function P.superRange:update()
	self.power = self.power + .10 +self.power/7
	self.baseRange = self.power
end
function P.superRange:usableOnTile(tile)
	return true
end 
P.superRange.usableOnNothing = P.superRange.usableOnTile
function P.superRange:useToolTile(tile)
	self.numHeld = self.numHeld-1
	player.attributes.extendedRange = player.attributes.extendedRange+self.power
	self.active = self.power 
	self.power = 0
end
P.superRange.useToolNothing = P.superRange.useToolTile
--Some kind of passive that interacts with supers





P.sacrificalPact = P.superTool:new{name = "Sacrificial Pact", description = "Make a trade"}
--Two use modes, sacrifice and expend. Sacrifice somehow improves the power



--Concept
P.chargedBeam = P.superTool:new{name = "Charged Beam", description = "It grows in strength", baseRange = 0, quality = 3, charge = 0}
function P.chargedBeam:giveOne()
	if self.numHeld == 0 then
		charge = 0
	end
	self.numHeld = self.numHeld + 1
end
function P.chargedBeam:update()
	charge = charge + 1
	baseRange = 2*charge/3
end
function P.chargedBeam:destroyTiles(tileY, tileX)
	local endCoord = 1
	local stepNum = 1
	if tileY == player.tileY then
		if tileX>player.tileX then
			endCoord = roomLength
		else
			stepNum = -1
		end
		for i = player.tileX, endCoord, stepNum do
			if room[tileY][i]~=nil and room[tileY][i]:instanceof(tiles.treasureTile) then
				room[tileY][i]:onEnter()
				room[tileY][i] = nil
				return
			end
		end
	elseif tileX == player.tileX then
		if tileY>player.tileY then
			endCoord = roomHeight
		else
			stepNum = -1
		end
		for i = player.tileY, endCoord, stepNum do
			if room[i][tileX]~=nil and room[i][tileX]:instanceof(tiles.treasureTile) then
				room[i][tileX]:onEnter()
				room[i][tileX] = nil
				return
			end
		end
	end
end
--Charges up with basic use, consumes all charge on use. 
--Idea: A blast which becomes stronger and bigger and can be launched farther 
--Idea: A beam which becomes more lasting and penetrating and affecting 

P.protonTorpedo = P.superTool:new{name = "Proton Torpedo", description = "Ever more deadly", baseRange = 0, quality = 4, charge = 0}

---Also, potential related tools would charge up each time you use a basic

--Tools to add: Treasure Snatcher, Shroom Transplant, P-Source Reviver / Temp-destroyer, gumball machine
--What about a tool that gives you a basic next game if you die while holding it?
--A T0 that gives you an infinite number of the basic you have the least of
--A trash tier that returns to you the last basic used -- Too strong, doesn't fit a tier
--A repair tool

--Rewind tool is still a cool idea, so is micro-rewind







P.numNormalTools = 7
P.lastToolUsed = 1

function P.resetTools()
	tools[1] = P.saw
	tools[2] = P.ladder
	tools[3] = P.wireCutters
	tools[4] = P.waterBottle
	tools[5] = P.sponge
	tools[6] = P.brick
	tools[7] = P.gun
	for i = 1, #tools do
		tools[i].range = tools[i].baseRange
		if i > tools.numNormalTools then
			tools[i].isDisabled = tools[i].defaultDisabled
		end
	end
end

function P:addTool(tool)
	self[#self+1] = tool
	tool.toolid = #self
end
function P:insertTool(tool, index)
	if index==nil then index = 1 end
	if tools[index]==tool then return end
	for i = #tools, index, -1 do
		tools[i+1] = tools[i]
	end
	tools[index] = tool
end

P.resetTools()

--Ideas: mushroom concoction (rainbow invincible mode), floor unlocker, ammo pack (3 guns)

P:addTool(P.missile) --Missile: Within its reach                    , The hand of God
P:addTool(P.laser) --L.A.S.E.R: Boson Beats
P:addTool(P.explosiveMeat) --

P:addTool(P.stealthBomber) 
P:addTool(P.superGun)
P:addTool(P.explosiveGun) --
P:addTool(P.ammoPack) --Rapid Reload: Get back on your feet		The Hoodlum Hookup: Packing Heat  or  
P:addTool(P.thruCover) --ThruCover: Tactical Strike 	            Should we change this one? Yup
P:addTool(P.iceyShot) --IceyShot: Pretty Cool
--P:addTool(P.icegun) --The Stop Light: It might never turn green




--Themes Drugs
P:addTool(P.visionChanger) --Flashlight: Dispell the dark          , Dispel the phantoms, God's Eye View 
P:addTool(P.gas) -- or Gas: Don't breathe
P:addTool(P.wings) --Float Free or Ugrounded or 
P:addTool(P.ironMan) 
P:addTool(P.seeds)
P:addTool(P.salt) --
P:addTool(P.superWaterBottle)
P:addTool(P.foresight)
P:addTool(P.growthHormones)
P:addTool(P.gabeMaker)
P:addTool(P.flame) --Shouldn't be hard to control or 
P:addTool(P.lemonadeCup)
P:addTool(P.lemonParty)
P:addTool(P.shell)
P:addTool(P.xrayVision)
P:addTool(P.blankTool) -- Keep
P:addTool(P.mindfulTool) --Mindful Tool: Never forget	OR Mindful Tool: Never forget where you came from		This is kinda silly
P:addTool(P.reactiveShield) --
P:addTool(P.shield)
P:addTool(P.shrooms)
P:addTool(P.revive) --		Revive: Not yet,	 Return of the King
P:addTool(P.nineLives)

--Theme Identity/Memes - Social
P:addTool(P.pitbullChanger)
P:addTool(P.trap)--
P:addTool(P.doorstop)
P:addTool(P.charger) -- Electrifier: Empowerment or 
P:addTool(P.recycleBin)
P:addTool(P.animalEnslaver)
P:addTool(P.trader)
P:addTool(P.christmasSurprise)
P:addTool(P.luckyPenny)
P:addTool(P.playerBoxSpawner) --Player Box: Special treatment
P:addTool(P.playerCloner)
P:addTool(P.inflation)--Keep
P:addTool(P.shopReroller)
P:addTool(P.laptop)--Keep
P:addTool(P.snowballGlobal)
P:addTool(P.swapper)
P:addTool(P.heartTransplant)-- Desc"New memories"
P:addTool(P.lube)
P:addTool(P.bombBoxSpawner)-- 
P:addTool(P.beggarReroller) --Strong keep
P:addTool(P.iceBox)-- 
P:addTool(P.armageddon)-- Master of Matter: So very empty...  or  Armageddon, Divine Desctruction



--Theme Choice/Uncertainty


P:addTool(P.ghostStep)--Nice
P:addTool(P.boxCloner)
P:addTool(P.supertoolReroller) -- MUST KEEP
P:addTool(P.wallReroller)
P:addTool(P.animalReroller)
P:addTool(P.toolReroller)
P:addTool(P.boxReroller)

P:addTool(P.teleporter) --Keep
P:addTool(P.coin) --One way to pay or 
P:addTool(P.deckOfCards)
P:addTool(P.card)
P:addTool(P.amnesiaPill)



--Theme Electricity/Connection
P:addTool(P.electrifier) --Conduit: Make connections
P:addTool(P.delectrifier) -- Insulate: Isolate
P:addTool(P.rotater) -- Rotator: Perpendicular
P:addTool(P.buttonFlipper) --Button Master: Flip off, flip on      Does more than push

P:addTool(P.wireBreaker)
P:addTool(P.powerBreaker)
P:addTool(P.portalPlacer)
P:addTool(P.wireExtender) --Extension cord: Longer is better
P:addTool(P.wireToButton)--Nice
P:addTool(P.tileDisplacer)
P:addTool(P.tileSwapper)--Swapper: Let's trade places
P:addTool(P.tileCloner)--Epic
P:addTool(P.tileMagnet)
P:addTool(P.portalPlacerDouble)
P:addTool(P.buttonReroller)


--Themes Prison + Escapep
P:addTool(P.knife) --Knife: They can't stop you
P:addTool(P.crowbar) --Crowbar: It's on the other side  or Tool for a prying heart
P:addTool(P.shovel) --Shovel: Seek treasure 	or dig deep, or plumb the depths
P:addTool(P.map) --The Map: Prudent planning 	or There might still be a way	
P:addTool(P.roomUnlocker) -- The Magic Word:Gate-crashing 
P:addTool(P.tunneler) --Tunneler: 				or Someone get me out of here!
P:addTool(P.lamp) --Lamp: Star in a jar
P:addTool(P.emptyBucket)
P:addTool(P.emptyCup) --Empty Cup: It's less than half full

P:addTool(P.animalTrainer)
P:addTool(P.secretTeleporter)-- :Let me show you something
P:addTool(P.superLadder)
P:addTool(P.pickaxe) --Maybe Change, but defnitely keep
P:addTool(P.towel)
P:addTool(P.compass)


---Theme Tools
P:addTool(P.bomb) -- Bomb: ANFO
P:addTool(P.boxCutter) --Unboxer: Time to find out what's inside
P:addTool(P.magnet) --For one of the magnets: F = Q * vector v cross vector B
P:addTool(P.superWireCutters) --Super Wire-cutters: They can't stop you
P:addTool(P.bucketOfWater)  --Bucket of Water: Fathomless
P:addTool(P.toolIncrementer) -- Seven: One of each
P:addTool(P.superLaser) -- Super L.A.S.E.R.: The Big Bad Beam
P:addTool(P.axe) -- Axes are friendly, maybe this won't be an axe
P:addTool(P.screwdriver) --Keep
P:addTool(P.stoolPlacer)
P:addTool(P.superBrick)
P:addTool(P.superSaw)
P:addTool(P.superSponge)
P:addTool(P.luckySaw)
P:addTool(P.luckyBrick)
P:addTool(P.fishingPole) -- 





--Unique
P:addTool(P.robotArm) --Robotic Arm: Reach for the stars

P:addTool(P.meat)-- Meat: Raw temptation

P:addTool(P.spring) --Spring: Up, up in the air I go

P:addTool(P.glue) --Glue: Hold it together old pal

P:addTool(P.ramSpawner) --Ram: Knock down that wall

P:addTool(P.boxSpawner) --Box: Still likes to be pushed around         or Likes to be pushed around



P:addTool(P.roomReroller)-- Contents Randomizer: What it should have been

P:addTool(P.superSnowball) -- Mask - Hypnotoad


P:addTool(P.sock)
P:addTool(P.gasPourer)
P:addTool(P.gasPourerXtreme)

P:addTool(P.shift) --Lets talk about this one
P:addTool(P.glitch) -- Glitch: ...what just happened?
P:addTool(P.rottenMeat) -- Rotten Meat: What poor people have to eat
--P:addTool(P.bouncer) --lol
P:addTool(P.block) --Mental Block: 			Poof or ...
P:addTool(P.supertoolDoubler) -- Ehhh lets talk

P:addTool(P.boxDisplacer)
P:addTool(P.woodenRain)

P:addTool(P.grenade)



P:addTool(P.opPotion)
P:addTool(P.bombPotion)
P:addTool(P.electricPotion)
P:addTool(P.teleportPotion)
P:addTool(P.shittyPotion)

P:addTool(P.fireBreath)
P:addTool(P.claw)
P:addTool(P.wing)
P:addTool(P.dragonEgg)
P:addTool(P.dragonFriend)

--P:addTool(P.demonFeather)
--P:addTool(P.demonHoof)

--P:addTool(P.discountTag)

P:addTool(P.stopwatch)

P:addTool(P.diagonal)
P:addTool(P.megaUnlock)
P:addTool(P.medicine)

P:addTool(P.eraser)
P:addTool(P.tpRevive)

--P:addTool(P.rewindRevive)
P:addTool(P.treasureThief)
P:addTool(P.shroomRevive)
P:addTool(P.roomRestore)
P:addTool(P.repair)
P:addTool(P.preservatives)
P:addTool(P.mutantShield)
P:addTool(P.superRange)
P:addTool(P.chargedShield)

P.resetTools()

-- Make a tool based cursor

-- Add Erik's brilliant card based SUPER PARADIGM!

--ideas: stopwatch as Erik starting item, freezes time/animals/electricity/spotlights



return tools

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