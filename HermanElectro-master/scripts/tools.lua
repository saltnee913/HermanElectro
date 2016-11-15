local P = {}
tools = P

P.toolDisplayTimer = {base = 1.5, timeLeft = 0}
P.toolsShown = {}


function P.updateTimer(dt)
	P.toolDisplayTimer.timeLeft = P.toolDisplayTimer.timeLeft - dt
end

--displays tools above player, takes input as [1,1,6,6,5,5] = 2 saw, 2 brick, 2 sponge
function P.displayTools(toolArray)
	P.toolDisplayTimer.timeLeft = P.toolDisplayTimer.base
	P.toolsShown = toolArray
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
			tools[toolArray[i]].numHeld = tools[toolArray[i]].numHeld + 1
			toolsToDisp[#toolsToDisp+1] = toolArray[i]
		end
	end
	if tools.revive.numHeld>=9 then
		unlocks.unlockUnlockableRef(unlocks.suicideKingUnlock)
	end
	P.displayTools(toolsToDisp)
	updateTools()
end

function P.giveToolsByArray(toolArray)
	for i = 1, P.numNormalTools do
		tools[i].numHeld = tools[i].numHeld + toolArray[i]
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

function P.giveRandomTools(numTools,numSupers)
	if numSupers == nil then numSupers = 0 end
	local toolsToGive = {}
	for i = 1, numTools do
		slot = P.chooseNormalTool()
		toolsToGive[#toolsToGive+1] = slot
	end
	local supersToGive = P.getSupertools(numSupers)
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

--prioritizes animals, matters if we want a tool to work on both animals and tiles
function P.useToolDir(toolid, dir)
	if P.toolablePushables~=nil and P.toolablePushables[dir][1]~=nil and tools[toolid]~=nil then
		tools[toolid]:useToolPushable(P.toolablePushables[dir][1])
	end
	if P.toolableAnimals ~= nil and P.toolableAnimals[dir][1] ~= nil and tools[toolid]~=nil then
		tools[toolid]:useToolAnimal(P.toolableAnimals[dir][1])
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
		return true
	end
	return false
end

--prioritizes animals
function P.useToolTile(toolid, tileY, tileX)
	if P.toolableAnimals ~= nil then
		for dir = 1, 5 do
			for i = 1, #(P.toolableAnimals[dir]) do
				if P.toolableAnimals[dir][i].tileY == tileY and P.toolableAnimals[dir][i].tileX == tileX then
					tools[tool]:useToolAnimal(P.toolableAnimals[dir][i])
					return true
				end
			end
		end
	end
	if P.toolablePushables ~= nil then
		for dir = 1, 5 do
			for i = 1, #(P.toolablePushables[dir]) do
				if P.toolablePushables[dir][i].tileY == tileY and P.toolablePushables[dir][i].tileX == tileX then
					tools[tool]:useToolPushable(P.toolablePushables[dir][i])
					return true
				end
			end
		end
	end
	if P.toolableTiles ~= nil then
		for dir = 1, 5 do
			for i = 1, #(P.toolableTiles[dir]) do
				if P.toolableTiles[dir][i].y == tileY and P.toolableTiles[dir][i].x == tileX then
					if room[tileY][tileX] == nil or room[tileY][tileX]:usableOnNothing(tileY, tileX) then
						tools[tool]:useToolNothing(tileY, tileX)
					else
						tools[tool]:useToolTile(room[tileY][tileX], tileY, tileX)
					end
					return true
				end
			end
		end
	end
	return false
end

P.tool = Object:new{name = 'test', useWithArrowKeys = true, numHeld = 0, baseRange = 1, image=love.graphics.newImage('Graphics/saw.png')}
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
				if ((room[tileToCheck.y][tileToCheck.x] == nil or room[tileToCheck.y][tileToCheck.x]:usableOnNothing(tileToCheck.y, tileToCheck.x)) and (tileToCheck.x>0 and tileToCheck.x<=roomLength) and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
				or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist)) then
					if litTiles[tileToCheck.y][tileToCheck.x]~=0 then
						usableTiles[5][#(usableTiles[5])+1] = tileToCheck
					end
				end
			end
		else
			for dist = 1, self.range do
				local tileToCheck = {y = player.tileY + offset.y*dist, x = player.tileX + offset.x*dist}
				if room[tileToCheck.y]~=nil then
					if dir==5 and dist>1 then break end
					if ((room[tileToCheck.y][tileToCheck.x] == nil or room[tileToCheck.y][tileToCheck.x]:usableOnNothing(tileToCheck.y, tileToCheck.x)) and (tileToCheck.x>0 and tileToCheck.x<=roomLength) and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
					or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist)) then
						if litTiles[tileToCheck.y][tileToCheck.x]~=0 then
							usableTiles[dir][#(usableTiles[dir])+1] = tileToCheck
						end
					end
					if room[tileToCheck.y][tileToCheck.x] ~= nil and room[tileToCheck.y][tileToCheck.x].blocksProjectiles then
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
	for i=-1*self.range, self.range do
		for j = -1*self.range, self.range do
			local offset = {x = i, y = j}
			local tileToCheck = {y = player.tileY + offset.y, x = player.tileX + offset.x}
			if tileToCheck.x<=0 or tileToCheck.x>roomLength then break end
			if room[tileToCheck.y]~=nil then
				if (room[tileToCheck.y][tileToCheck.x] == nil and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
				or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist)) then
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
		if self:usableOnAnimal(animal) then
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
		if closestAnimals[dir].dist <= self.range then
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
					if tile~=nil and tile.blocksProjectiles then
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
		if not animals[animalIndex].dead and math.abs(animals[animalIndex].tileY - player.tileY)+math.abs(animals[animalIndex].tileX - player.tileX)<=self.range then
			if litTiles[animals[animalIndex].tileY][animals[animalIndex].tileX]~=0 then
				usableAnimals[1][#usableAnimals[1]+1] = animals[animalIndex]
			end
		end
	end
	return usableAnimals
end

function P.tool:getToolablePushables()
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
		if closestPushables[dir].dist <= self.range then
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
					if tile~=nil and tile.blocksProjectiles then
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
	local usablePushables = {{},{},{},{},{}}
	for pushableIndex = 1, #pushables do
		if not pushables[pushableIndex].dead and math.abs(pushables[pushableIndex].tileY - player.tileY)+math.abs(pushables[pushableIndex].tileX - player.tileX)<=self.range then
			if litTiles[pushables[pushableIndex].tileY][pushables[pushableIndex].tileX]~=0 then
				usablePushables[1][#usablePushables[1]+1] = pushables[pushableIndex]
			end
		end
	end
	return usablePushables
end

P.saw = P.tool:new{name = 'saw', image = love.graphics.newImage('Graphics/saw.png')}
function P.saw:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and not tile.destroyed and tile.sawable
end
function P.saw:usableOnPushable(pushable)
	return not pushable.destroyed and pushable.sawable
end
function P.saw:useToolPushable(pushable)
	self.numHeld = self.numHeld - 1
	pushable:destroy()
end

P.ladder = P.tool:new{name = 'ladder', image = love.graphics.newImage('Graphics/ladder.png')}
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
end
function P.ladder:usableOnNothing()
	return true
end
function P.ladder:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	room[tileY][tileX] = tiles.ladder:new()
end

P.wireCutters = P.tool:new{name = 'wire-cutters', image = love.graphics.newImage('Graphics/wirecutters.png')}
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
	else tile:destroy() end
end
function P.wireCutters:useToolPushable(pushable)
	pushable.conductive = false
end

P.waterBottle = P.tool:new{name = 'water-bottle', image = love.graphics.newImage('Graphics/waterbottle.png')}
function P.waterBottle:usableOnTile(tile)
	if not tile.destroyed and ((tile:instanceof(tiles.powerSupply) and not tile:instanceof(tiles.notGate)) or (tile:instanceof(tiles.electricFloor) and not tile:instanceof(tiles.unbreakableElectricFloor)) or tile:instanceof(tiles.untriggeredPowerSupply)) then
		return true
	--[[elseif not tile.laddered then
		if tile:instanceof(tiles.breakablePit) and tile.strength == 0 then
			return true
		elseif tile:instanceof(tiles.poweredFloor) or tile:instanceof(tiles.pit) then
			return true
		end]]
	end
	return false
end
function P.waterBottle:useToolTile(tile)
	self.numHeld = self.numHeld-1
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
	room[tileY][tileX] = tiles.puddle:new()
end

P.cuttingTorch = P.tool:new{name = 'cutting-torch', image = love.graphics.newImage('Graphics/cuttingtorch.png')}
function P.cuttingTorch:usableOnTile(tile)
	return false
end

P.brick = P.tool:new{name = 'brick', baseRange = 3, image = love.graphics.newImage('Graphics/brick.png')}
function P.brick:usableOnTile(tile, dist)
	if not tile.bricked and tile:instanceof(tiles.button) and not tile:instanceof(tiles.superStickyButton)
		and not tile:instanceof(tiles.unbrickableStayButton) and dist <= 3 then
		return true
	end
	if not tile.destroyed and tile:instanceof(tiles.glassWall) then
		return true
	end
	if tile:instanceof(tiles.mousetrap) and not tile.bricked then
		return true
	end
	return false
end
function P.brick:usableOnAnimal(animal)
	return not animal.dead
end
function P.brick:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.glassWall) then
		tile:destroy()
	else
		tile:lockInState(true)
		unlocks:unlockUnlockableRef(unlocks.stayButtonUnlock)
	end
end
function P.brick:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+1
	if animal.waitCounter>=3 then
		unlocks.unlockUnlockableRef(unlocks.catUnlock)
	end
end

P.gun = P.tool:new{name = 'gun', baseRange = 3, image = love.graphics.newImage('NewGraphics/gun copy.png')}
function P.gun:usableOnAnimal(animal)
	return not animal.dead
end
function P.gun:usableOnTile(tile)
	if tile:instanceof(tiles.wall) and not tile:instanceof(tiles.concreteWall) and not tile:instanceof(tiles.glassWall) and not tile.destroyed then
		return true
	elseif tile:instanceof(tiles.beggar) and tile.alive then
		return true
	end
	return false
end
function P.gun:useToolTile(tile)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.beggar) then
		unlocks.unlockUnlockableRef(unlocks.beggarPartyUnlock)
		tile:destroy()
	else
		tile:allowVision()
	end
end
function P.gun:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	animal:kill()
	if animal:instanceof(animalList.bombBuddy) then
		local tileY = animal.tileY
		local tileX = animal.tileX
		room[tileY][tileX] = tiles.bomb:new()
		room[tileY][tileX]:onEnd(tileY, tileX)
		room[tileY][tileX]:explode(tileY, tileX)
		room[tileY][tileX] = nil
	end
end

P.felixGun = P.gun:new{name = 'felix gun', numHeld = 0, range = 5, isGun = true}
function P.felixGun:switchEffects()
	local switchEffects = self.switchEffects
	if self.isGun then
		P.felixGun = P.superGun:new{name = self.name, numHeld = self.numHeld, isGun = false, switchEffects = switchEffects}
	else
		P.felixGun = P.gun:new{name = self.name, numHeld = self.numHeld, range = 5, isGun = true, switchEffects = switchEffects}
	end
	for i = 1, #tools do
		if tools[i].name == self.name then
			tools[i] = P.felixGun
		end
	end
end


P.superTool = P.tool:new{name = 'superTool', baseRange = 10, rarity = 1}

function P.chooseSupertool()
	unlocks = require('scripts.unlocks')
	unlockedSupertools = unlocks.getUnlockedSupertools()
	local toolId
	repeat
		toolId = util.random(#tools-tools.numNormalTools,'toolDrop')+tools.numNormalTools
	until(unlockedSupertools[toolId])
	return toolId
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

function P.getSupertools(numTools)
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
		local goodSlot = false
		while (not goodSlot) do
			slot = tools.chooseSupertool()
			if filledSlots[3]==0 then
				goodSlot = true
			end
			for i = 1, 3 do
				if filledSlots[i]==slot then
					goodSlot = true
				end
			end
		end
		toolsToGive[#toolsToGive + 1] = slot
	end
	return toolsToGive
end

function P.giveSupertools(numTools)
	P.giveTools(P.getSupertools(numTools))
end

P.shovel = P.superTool:new{name = "shovel", baseRange = 1, image = love.graphics.newImage('Graphics/shovel.png')}
function P.shovel:usableOnNothing()
	return true
end
function P.shovel:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.pit:new()
end

P.electrifier = P.superTool:new{name = 'electrifier', baseRange = 1, image = love.graphics.newImage('Graphics/electrifier.png')}
function P.electrifier:usableOnTile(tile)
	if not tile.destroyed and tile:instanceof(tiles.wall) and not tile:instanceof(tiles.metalWall) and not tile.electrified then
		return true
	end
	return false
end
function P.electrifier:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:electrify()
end

P.delectrifier = P.superTool:new{name = 'delectrifier', baseRange = 1, image = love.graphics.newImage('Graphics/electrifier2.png')}
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
end

P.charger = P.superTool:new{name = 'charger', baseRange = 1, image = love.graphics.newImage('Graphics/charger.png')}
function P.charger:usableOnTile(tile)
	if tile.canBePowered and not tile.charged then return true end
	return false
end
function P.charger:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.charged = true
end

P.visionChanger = P.superTool:new{name = 'visionChanger', baseRange = 0, image = love.graphics.newImage('Graphics/visionChanger.png')}
function P.visionChanger:usableOnTile(tile)
	return true
end
P.visionChanger.usableOnNothing = P.visionChanger.usableOnTile
function P.visionChanger:useToolTile(tile)
	self.numHeld = self.numHeld-1
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				room[i][j]:allowVision()
				litTiles[i][j]=1
			end
		end
	end
end
P.visionChanger.useToolNothing = P.visionChanger.useToolTile

P.bomb = P.superTool:new{name = "bomb", baseRange = 1, image = love.graphics.newImage('Graphics/bomb.png')}
function P.bomb:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	t = tiles.bomb:new()
	t.counter = 3
	room[tileY][tileX] = t
end
function P.bomb:usableOnNothing()
	return true
end

P.flame = P.superTool:new{name = "flame", baseRange = 1, image = love.graphics.newImage('Graphics/flame.png')}
function P.flame:usableOnTile(tile)
	--flame cannot burn metal walls
	if tile:instanceof(tiles.wall) and tile.sawable and not tile:instanceof(tiles.metalWall) and not tile.destroyed then
		return true
	end
	return false
end
function P.flame:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.onFire = true
	self:updateFire()
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

P.unsticker = P.superTool:new{name = "unsticker", baseRange = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.unsticker:usableOnTile(tile)
	if tile:instanceof(tiles.stickyButton) and tile.down then return true end
	return false
end
function P.unsticker:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:unstick()
end

P.crowbar = P.superTool:new{name = "crowbar", baseRange = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.crowbar:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) or tile:instanceof(tiles.hDoor) and not tile.stopped then return true end
	return false
end
function P.crowbar:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.open = true
	tile.stopped = true
end

P.doorstop = P.superTool:new{name = "doorstop", baseRange = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.doorstop:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) and (not tile.stopped) and (not tile.blocksMovement) then return true end
	return false
end
function P.doorstop:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.stopped = true
end

P.missile = P.superTool:new{name = "missile", useWithArrowKeys = false, baseRange = 10, image = love.graphics.newImage('Graphics/missile.png')}
function P.missile:usableOnTile(tile)
	return not tile.destroyed and (tile:instanceof(tiles.wire) or tile:instanceof(tiles.electricFloor) or tile:instanceof(tiles.wall)) or tile:instanceof(tiles.powerSupply) and not tile.destroyed
end
function P.missile:usableOnAnimal(animal)
	return not animal.dead
end
P.missile.getToolableTiles = P.tool.getToolableTilesBox
P.missile.getToolableAnimals = P.tool.getToolableAnimalsBox

P.meat = P.tool:new{name = "meat", baseRange = 1, image = love.graphics.newImage('Graphics/meat.png')}
function P.meat:usableOnNothing()
	return true
end
function P.meat:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.meat:new()
end
function P.meat:usableOnTile(tile)
	if not tile.bricked and tile:instanceof(tiles.button) then
		return true
	end
	return false
end
function P.meat:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:lockInState(true)
end

P.corpseGrabber = P.superTool:new{name = "corpseGrabber", baseRange = 1, image = love.graphics.newImage('Graphics/corpseGrabber.png')}
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

P.woodGrabber = P.superTool:new{name = "woodGrabber", baseRange = 1, image = love.graphics.newImage('Graphics/woodGrabber.png')}
function P.woodGrabber:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and tile.destroyed
end
function P.woodGrabber:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	P.ladder.numHeld = P.ladder.numHeld+2
	room[tileY][tileX] = nil
end

P.pitbullChanger = P.tool:new{name = "pitbullChanger", baseRange = 3, image = love.graphics.newImage('Graphics/pitbullChanger.png')}
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

P.sponge = P.tool:new{name = "sponge", baseRange = 1, image = love.graphics.newImage('NewGraphics/sponge copy.png')}
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
		unlocks = require('scripts.unlocks')
		unlocks.unlockUnlockableRef(unlocks.puddleUnlock)
		room[tileY][tileX] = nil
	elseif tile:instanceof(tiles.stickyButton) or tile:instanceof(tiles.button) then
		if tile:instanceof(tiles.stayButton) then
			room[tileY][tileX] = tiles.stayButton:new()
		else
			room[tileY][tileX] = tiles.button:new()
			room[tileY][tileX].bricked = false
		end
	else
		room[tileY][tileX] = nil
	end
end

P.rotater = P.tool:new{name = "rotater", baseRange = 1, image = love.graphics.newImage('Graphics/rotatetool.png')}
function P.rotater:usableOnTile(tile)
	return true
end
function P.rotater:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	tile:rotate(1)
end

P.trap = P.tool:new{name = "trap", baseRange = 1, image = love.graphics.newImage('Graphics/trap.png')}
function P.trap:usableOnNothing()
	return true
end
function P.trap:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.trap:new()
end

P.boxCutter = P.tool:new{name = "boxCutter", baseRange = 1, image = love.graphics.newImage('Graphics/boxcutter.png')}
function P.boxCutter:usableOnPushable(pushable)
	return true
end
function P.boxCutter:useToolPushable(pushable)
	self.numHeld = self.numHeld - 1
	pushable.destroyed = true
	P.giveRandomTools(3)
end

P.broom = P.tool:new{name = "broom", image = love.graphics.newImage('Graphics/broom.png')}
function P.broom:usableOnTile(tile)
	return tile:instanceof(tiles.slime) or tile:instanceof(tiles.conductiveSlime)
end
function P.broom:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX]=nil
end

P.magnet = P.tool:new{name = "magnet", baseRange = 5, image = love.graphics.newImage('Graphics/magnet.png')}
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

P.spring = P.tool:new{name = "spring", useWithArrowKeys = false, baseRange = 4, image = love.graphics.newImage('Graphics/spring.png')}
function P.spring:usableOnTile(tile)
	for i = 1, #pushables do
		if pushables[i].tileX == tile.tileX and pushables[i].tileY == tile.tileY then return false end
	end
	return not tile.blocksMovement
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
	room[tileY][tileX]:onEnter(player)
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
end
function P.spring:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
end
P.spring.getToolableTiles = P.tool.getToolableTilesBox

P.glue = P.tool:new{name = "glue", image = love.graphics.newImage('Graphics/glue.png')}
function P.glue:usableOnNothing()
	return true
end
function P.glue:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.glue:new()
end

P.endFinder = P.tool:new{name = "endFinder", baseRange = 0, image = love.graphics.newImage('Graphics/endfinder.png')}
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

P.lamp = P.tool:new{name = "lamp", baseRange = 3, image = love.graphics.newImage('Graphics/lamp.png')}
function P.lamp:usableOnNothing()
	return true
end
function P.lamp:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.lamp:new()
end

P.boxSpawner = P.tool:new{name = "boxSpawner", baseRange = 1, image = love.graphics.newImage('Graphics/box.png')}
function P.boxSpawner:usableOnNothing(tileY, tileX)
	if tileY==player.tileY and tileX==player.tileX then return false end
	for i = 1, #animals do
		if animals[i].tileY==tileY and animals[i].tileX==tileX then return false end
	end
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then return false end
	end
	return true
end
function P.boxSpawner:usableOnTile(tile, tileY, tileX)
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
	pushables[#pushables+1] = toSpawn
end
function P.boxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[2]:new()
	if player.character.name == "Tim" then toSpawn = pushableList.giftBox:new() end
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end

P.ramSpawner = P.boxSpawner:new{name = "ramSpawner", image = love.graphics.newImage('Graphics/batteringram.png')}
function P.ramSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[7]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end
function P.ramSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[7]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end


P.gateBreaker = P.tool:new{name = "gateBreaker", baseRange = 1, image = love.graphics.newImage('Graphics/shovel.png')}
function P.gateBreaker:usableOnTile(tile)
	return tile:instanceof(tiles.gate)
end
function P.gateBreaker:useToolTile(tile)
	self.numHeld = self.numHeld-1
	tile.destroyed = true
	tile.canBePowered = false
end

P.conductiveBoxSpawner = P.boxSpawner:new{name = "conductiveBoxSpawner", image = love.graphics.newImage('Graphics/conductiveBox.png')}
function P.conductiveBoxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[5]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end
function P.conductiveBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[5]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end

P.boomboxSpawner = P.boxSpawner:new{name = "boomboxSpawner", image = love.graphics.newImage('Graphics/boombox.png')}
function P.boomboxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[6]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end
function P.boomboxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[6]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end

P.superWireCutters = P.wireCutters:new{name = "superWireCutters", image = love.graphics.newImage('Graphics/wirecutters.png')}
function P.superWireCutters:usableOnNonOverlay(tile)
	return not tile.destroyed and (tile:instanceof(tiles.wire)
	or tile:instanceof(tiles.conductiveGlass) or tile:instanceof(tiles.reinforcedConductiveGlass) or tile:instanceof(tiles.electricFloor))
end
function P.superWireCutters:usableOnTile(tile)
	return self:usableOnNonOverlay(tile) or (tile.overlay~=nil and self:usableOnNonOverlay(tile.overlay))
end


P.laser = P.tool:new{name = "laser", baseRange = 100, image = love.graphics.newImage('Graphics/laser.png')}
function P.laser:usableOnAnimal(animal)
	return not animal.dead
end
function P.laser:useToolAnimal(animal)
	if animal.tileX == player.tileX then
		for i = 1, #animals do
			if animals[i].tileX == player.tileX then
				animals[i]:kill()
			end
		end
	else
		for i = 1, #animals do
			if animals[i].tileY == player.tileY then
				animals[i]:kill()
			end
		end
	end
	self.numHeld = self.numHeld-1
end

--should superLaser kill animals? can't decide
P.superLaser = P.laser:new{name = "superLaser", baseRange = 100, image = love.graphics.newImage('Graphics/laser.png')}
function P.superLaser:usableOnTile()
	return true
end
function P.superLaser:useToolTile(tile, tileY, tileX)
	if tileY == player.tileY then
		for i = 1, roomLength do
			if room[tileY][i]~=nil then
				room[tileY][i]:destroy()
			end
		end
	elseif tileX == player.tileX then
		for i = 1, roomHeight do
			if room[i][tileX]~=nil then
				room[i][tileX]:destroy()
			end
		end
	end
	self.numHeld = self.numHeld-1
end


P.gas = P.tool:new{name = "gas", baseRange = 0, image = love.graphics.newImage('Graphics/gas.png')}
function P.gas:usableOnNothing()
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


P.armageddon = P.tool:new{name = "armageddon", baseRange = 0, image = love.graphics.newImage('Graphics/armageddon.png')}
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


P.toolReroller = P.tool:new{name = "toolReroller", baseRange = 0, image = love.graphics.newImage('Graphics/toolreroller.png')}
function P.toolReroller:usableOnNothing()
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

P.roomReroller = P.tool:new{name = "roomReroller", baseRange = 0, image = love.graphics.newImage('Graphics/roomreroller.png')}
function P.roomReroller:usableOnNothing()
	return true
end
function P.roomReroller:getTilesWhitelist()
	return {3,4,5,6,7,8,9,10,11,12,13,15,16,18,20,24,25,31,33,34,38,43,50,56,57,71,72}
end
function P.roomReroller:getTreasureTiles()
	return {34,58,59,60}
end
P.roomReroller.usableOnTile = P.roomReroller.usableOnNothing

function P.roomReroller:useToolNothing()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and not room[i][j]:instanceof(tiles.endTile) then
				local whitelist = self:getTilesWhitelist()
				local slot = util.random(#whitelist, 'misc')
				local tilesNum = whitelist[slot]
				local treasureTiles = self:getTreasureTiles()
				if whitelist[slot]==treasureTiles[1] or whitelist[slot]==treasureTiles[2] then
					local treasureTileChooser = util.random(#treasureTiles, 'misc')
					for i = 1, 4 do
						if treasureTileChooser<=i then
							tilesNum = treasureTiles[i]
							break
						end
					end
				end
				room[i][j] = tiles[tilesNum]:new()
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
	self.numHeld = self.numHeld-1
end
P.roomReroller.useToolTile = P.roomReroller.useToolNothing


P.toolDoubler = P.tool:new{name = "toolDoubler", baseRange = 0, image = love.graphics.newImage('Graphics/tooldoubler.png')}
function P.toolDoubler:usableOnNothing()
	return true
end
function P.toolDoubler:useToolNothing()
	for i = 1, P.numNormalTools do
		tools[i].numHeld = tools[i].numHeld*2
	end
	self.numHeld = self.numHeld-1
end

P.toolIncrementer = P.tool:new{name = "toolIncrementer", baseRange = 0, image = love.graphics.newImage('Graphics/toolincrementer.png')}
function P.toolIncrementer:usableOnNothing()
	return true
end
function P.toolIncrementer:useToolNothing()
	for i = 1, P.numNormalTools do
		tools[i].numHeld = tools[i].numHeld+1
	end
	self.numHeld = self.numHeld-1
end

P.wings = P.tool:new{name = "wings", baseRange = 0, image = love.graphics.newImage('Graphics/wings.png')}
function P.wings:usableOnNothing()
	return true
end
P.wings.usableOnTile = P.roomReroller.usableOnNothing

function P.wings:useToolNothing()
	if player.flying then
		unlocks.unlockUnlockableRef(unlocks.gabeUnlock)
	end
	player.flying = true
	self.numHeld = self.numHeld-1
end
P.wings.useToolTile = P.wings.useToolNothing

P.swapper = P.tool:new{name = "swapper", useWithArrowKeys = false, baseRange = 100, image = love.graphics.newImage('Graphics/swapper.png')}
function P.swapper:usableOnAnimal()
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
P.swapper.getToolableAnimals = P.swapper.getToolableAnimalsBox


P.bucketOfWater = P.tool:new{name = "bucketOfWater", baseRange = 1, image = love.graphics.newImage('Graphics/bucketofwater.png')}
function P.bucketOfWater:usableOnNothing()
	return true
end
function P.bucketOfWater:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	self:spreadWater(tileY, tileX)
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
P.teleporter = P.tool:new{name = "teleporter", baseRange = 0, image = love.graphics.newImage('Graphics/teleporter.png')}
function P.teleporter:usableOnNothing()
	return true
end
function P.teleporter:useToolNothing()
	self.numHeld = self.numHeld-1

	local teleported = false
	while not teleported do
		local xval = util.random(mapHeight, 'misc')
		local yval = util.random(mapHeight, 'misc')
		if mainMap[yval][xval]~=nil then
			teleported = true

			resetTranslation()
			player.flying = false
			player.character:onRoomEnter()
			--set pushables of prev. room to pushables array, saving for next entry
			room.pushables = pushables
			room.animals = animals

			local plusOne = true

			if player.tileY == math.floor(roomHeight/2) then plusOne = false
			elseif player.tileX == math.floor(roomLength/2) then plusOne = false end

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
			if map.getFieldForRoom(currentid, 'autowin') then completedRooms[mapy][mapx] = 1 end
			if loadTutorial then
				player.enterX = player.tileX
				player.enterY = player.tileY
			end

			if (prevMapX~=mapx or prevMapY~=mapy) or dir == -1 then
				createAnimals()
				createPushables()
			end
			visibleMap[mapy][mapx] = 1
			keyTimer.timeLeft = keyTimer.suicideDelay
			updateGameState()
		end
	end
end

P.revive = P.tool:new{name = "revive", baseRange = 0, image = love.graphics.newImage('Graphics/revive.png')}
function P.revive:checkDeath()
	if self.numHeld > 0 then
		self.numHeld = self.numHeld-1
		return false
	end
	return true
end

P.superGun = P.gun:new{name = "superGun", baseRange = 5, image = love.graphics.newImage('Graphics/supergun.png')}
function P.superGun:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	if tile:instanceof(tiles.beggar) then
		unlocks.unlockUnlockableRef(unlocks.beggarPartyUnlock)
		tile:destroy()
	else
		tile:allowVision()
	end
	room[tileY][tileX] = tiles.bomb:new()
	room[tileY][tileX]:onEnd(tileY, tileX)
	room[tileY][tileX]:explode(tileY, tileX)
	room[tileY][tileX] = nil
end
function P.superGun:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	animal:kill()
	local pY = animal.tileY
	local pX = animal.tileX
	room[pY][pX] = tiles.bomb:new()
	room[pY][pX]:onEnd(pY, pX)
	room[pY][pX]:explode(pY, pX)
	room[pY][pX] = nil
end

P.map = P.tool:new{name = "map", baseRange = 0, image = love.graphics.newImage('Graphics/map.png')}
function P.map:usableOnNothing()
	return true
end
function P.map:useToolNothing(tileY, tileX)
	for i = 1, mapHeight do
		for j = 1, mapHeight do
			visibleMap[i][j]=1
		end
	end
	self.numHeld = self.numHeld-1
end

P.buttonFlipper = P.tool:new{name = "buttonFlipper", baseRange = 0, image = love.graphics.newImage('Graphics/buttonflipper.png')}
function P.buttonFlipper:usableOnNothing()
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

P.wireBreaker = P.tool:new{name = "wireBreaker", baseRange = 0, image = love.graphics.newImage('Graphics/wirebreaker.png')}
function P.wireBreaker:usableOnNothing()
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

P.powerBreaker = P.tool:new{name = "powerBreaker", baseRange = 0, image = love.graphics.newImage('Graphics/powerbreaker.png')}
function P.powerBreaker:usableOnNothing()
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

P.gabeMaker = P.superTool:new{name = "gabeMaker", baseRange = 0, image = love.graphics.newImage('Graphics/gabeSmall.png')}
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

P.roomUnlocker = P.superTool:new{name = "roomUnlocker", baseRange = 0, image = love.graphics.newImage('Graphics/roomunlocker.png')}
function P.roomUnlocker:usableOnNothing()
	return true
end
P.roomUnlocker.usableOnTile = P.roomUnlocker.usableOnNothing
function P.roomUnlocker:useToolNothing()
	self.numHeld = self.numHeld-1
	unlockDoors()
end
P.roomUnlocker.useToolTile = P.roomUnlocker.useToolNothing

P.axe = P.superTool:new{name = "axe", baseRange = 5, image = love.graphics.newImage('Graphics/axe.png')}
P.axe.usableOnTile = P.saw.usableOnTile
P.axe.usableOnAnimal = P.gun.usableOnAnimal
P.axe.useToolAnimal = P.gun.useToolAnimal
P.axe.useToolTile = P.saw.useToolTile

P.lube = P.superTool:new{name = "lube", baseRange = 1, image = love.graphics.newImage('Graphics/lube.png')}
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
	elseif not tile.destroyed then
		tile:destroy()
	end
end

P.knife = P.superTool:new{name = "knife", baseRange = 5, image = love.graphics.newImage('Graphics/knife.png')}
P.knife.usableOnAnimal = P.gun.usableOnAnimal
P.knife.usableOnTile = P.wireCutters.usableOnTile
P.knife.useToolAnimal = P.gun.useToolAnimal
P.knife.useToolTile = P.wireCutters.useToolTile
P.knife.usableOnNonOverlay = P.wireCutters.usableOnNonOverlay
P.knife.usableOnPushable = P.wireCutters.usableOnPushable
P.knife.useToolPushable = P.wireCutters.useToolPushable

P.snowball = P.superTool:new{name = "snowball", baseRange = 5, image = love.graphics.newImage('Graphics/snowball.png')}
function P.snowball:usableOnAnimal(animal)
	return not animal.dead
end
function P.snowball:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+1
end

P.superSnowball = P.snowball:new{name = "superSnowball", image = love.graphics.newImage('Graphics/supersnowball.png')}
function P.superSnowball:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.frozen = true
end

P.snowballGlobal = P.snowball:new{name = "snowballGlobal", image = love.graphics.newImage('Graphics/snowballGlobal.png'), baseRange = 0}
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

P.superBrick = P.brick:new{name = "superBrick", image = love.graphics.newImage('Graphics/superbrick.png'), baseRange = 5}
function P.superBrick:usableOnTile(tile)
	if not tile.bricked and tile:instanceof(tiles.button) then
		return true
	end
	if not tile.destroyed and tile:instanceof(tiles.glassWall) then
		return true
	end
	if tile:instanceof(tiles.mousetrap) and not tile.bricked then
		return true
	end
	return false
end
function P.superBrick:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.glassWall) then
		tile:destroy()
	else
		tile:lockInState(true)
	end
end
function P.superBrick:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+2
end

P.superWaterBottle = P.waterBottle:new{name = "superWaterBottle", image = love.graphics.newImage('Graphics/superwaterbottle.png'), baseRange = 3}
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
	room[tileY][tileX] = tiles.puddle:new()
end

P.portalPlacer = P.superTool:new{name = "portalPlacer", image = love.graphics.newImage('Graphics/entranceportal.png'), baseRange = 1}
function P.portalPlacer:usableOnNothing()
	return true
end
function P.portalPlacer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.entrancePortal:new()
end

P.suicideKing = P.superTool:new{name = "suicideKing", image = love.graphics.newImage('Graphics/suicideking.png'), baseRange = 0}
function P.suicideKing:usableOnNothing()
	return true
end
function P.suicideKing:useToolNothing()
	self.numHeld = self.numHeld-1
	P.giveSupertools(3)
end
P.suicideKing.usableOnTile = P.suicideKing.usableOnNothing
P.suicideKing.useToolTile = P.suicideKing.useToolNothing

P.screwdriver = P.superTool:new{name = "screwdriver", image = love.graphics.newImage('Graphics/screwdriver.png'), baseRange = 1}
function P.screwdriver:usableOnTile(tile)
	return tile:instanceof(tiles.spikes)
end
function P.screwdriver:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	room[tileY][tileX] = nil
end

P.laptop = P.superTool:new{name = "laptop", image = love.graphics.newImage('Graphics/laptop.png'), baseRange = 0}
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



P.numNormalTools = 7

--tools not included in list: trap (identical to glue in purpose)
--some tools are weak, but necessary for balance

function P.resetTools()
	P[1] = P.saw
	P[2] = P.ladder
	P[3] = P.wireCutters
	P[4] = P.waterBottle
	P[5] = P.sponge
	P[6] = P.brick
	P[7] = P.gun
	for i = 1, #tools do
		tools[i].range = tools[i].baseRange
	end
end

P.resetTools()

P[8] = P.crowbar
P[9] = P.visionChanger
P[10] = P.bomb
P[11] = P.electrifier
P[12] = P.delectrifier
P[13] = P.unsticker
P[14] = P.doorstop
P[15] = P.charger
P[16] = P.missile
P[17] = P.shovel
P[18] = P.woodGrabber
P[19] = P.corpseGrabber
P[20] = P.pitbullChanger
P[21] = P.meat
P[22] = P.rotater
P[23] = P.teleporter
P[24] = P.boxCutter
P[25] = P.broom
P[26] = P.magnet
P[27] = P.spring
P[28] = P.glue
P[29] = P.endFinder
P[30] = P.map
P[31] = P.ramSpawner
P[32] = P.gateBreaker
P[33] = P.conductiveBoxSpawner
P[34] = P.superWireCutters
P[35] = P.boxSpawner
P[36] = P.boomboxSpawner
P[37] = P.laser
P[38] = P.gas
P[39] = P.superLaser
P[40] = P.armageddon
P[41] = P.toolIncrementer
P[42] = P.toolDoubler
P[43] = P.roomReroller
P[44] = P.wings
P[45] = P.swapper
P[46] = P.bucketOfWater
P[47] = P.flame
P[48] = P.toolReroller
P[49] = P.revive
P[50] = P.superGun
P[51] = P.buttonFlipper
P[52] = P.wireBreaker
P[53] = P.powerBreaker
P[54] = P.gabeMaker
P[55] = P.roomUnlocker
P[56] = P.axe
P[57] = P.lube
P[58] = P.snowball
P[59] = P.superSnowball
P[60] = P.snowballGlobal
P[61] = P.superBrick
P[62] = P.portalPlacer
P[63] = P.suicideKing
P[64] = P.screwdriver
P[65] = P.laptop

return tools