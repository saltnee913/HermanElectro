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
function P.useToolTile(tileY, tileX)
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
--says if tool works on "nothing" tiles as if they are legitimate
function P.tool:nothingIsSomething()
	return false
end
function P.tool:resetTool()
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
				or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist) and
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
					if ((room[tileToCheck.y][tileToCheck.x] == nil or room[tileToCheck.y][tileToCheck.x]:usableOnNothing(tileToCheck.y, tileToCheck.x)) and (tileToCheck.x>0 and tileToCheck.x<=roomLength) and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
					or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist) and
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
				if (room[tileToCheck.y][tileToCheck.x] == nil and self:usableOnNothing(tileToCheck.y, tileToCheck.x))
				or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist) and
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

P.saw = P.tool:new{name = 'saw', image = love.graphics.newImage('Graphics/Tools/saw.png')}
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

P.ladder = P.tool:new{name = 'ladder', image = love.graphics.newImage('Graphics/Tools/ladder.png')}
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

P.wireCutters = P.tool:new{name = 'wire-cutters', image = love.graphics.newImage('Graphics/Tools/wirecutters.png')}
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
function P.waterBottle:useToolTile(tile)
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
	room[tileY][tileX] = tiles.puddle:new()
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
	if tile:instanceof(tiles.hDoor) then
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
	if tile:instanceof(tiles.glassWall) or tile:instanceof(tiles.hDoor) then
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

P.gun = P.tool:new{name = 'gun', baseRange = 3, image = love.graphics.newImage('Graphics/Tools/gun.png')}
function P.gun:usableOnAnimal(animal)
	return not animal.dead
end
function P.gun:usableOnTile(tile)
	if tile:instanceof(tiles.wall) and not tile:instanceof(tiles.concreteWall) and not tile:instanceof(tiles.glassWall) and not tile.destroyed then
		if tile.blocksVision then
			return true
		end
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
		animal:explode()
	end
	gabeUnlock = false
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
P.superTool = P.tool:new{name = 'superTool', baseRange = 10, quality = P.numQualities, description = 'qwerty'}



P.cuttingTorch = P.superTool:new{name = 'cutting-torch', image = love.graphics.newImage('Graphics/cuttingtorch.png')}
function P.cuttingTorch:usableOnTile(tile)
	return false
end
function P.chooseSupertool(quality)
	unlocks = require('scripts.unlocks')
	unlockedSupertools = unlocks.getUnlockedSupertools()
	if qualities == nil then
		local toolId
		repeat
			toolId = util.random(#tools-tools.numNormalTools,'toolDrop')+tools.numNormalTools
		until(unlockedSupertools[toolId])
		return toolId
	else
		local toolId
		repeat
			toolId = util.random(#tools-tools.numNormalTools,'toolDrop')+tools.numNormalTools
		until(unlockedSupertools[toolId] and tools[toolId].quality == quality)
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

P.shovel = P.superTool:new{name = "shovel", description = "Hole making apparatus.", baseRange = 1,
image = love.graphics.newImage('Graphics/Tools/shovel.png'), quality = 2}
function P.shovel:usableOnNothing()
	return true
end
function P.shovel:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.pit:new()
end

P.electrifier = P.superTool:new{name = 'electrifier', description = "Conductive lotion", baseRange = 1, image = love.graphics.newImage('Graphics/electrifier.png'), quality = 3}
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

P.delectrifier = P.superTool:new{name = 'delectrifier', description = "Block power in tile.", baseRange = 1, image = love.graphics.newImage('Graphics/electrifier2.png'), quality = 3}
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
	if player.character == characters.monk and tile:instanceof(tiles.lamp) then
		for i = 1, 3 do
			player.character.tint[i] = 0
		end
	    myShader:send("tint_r", player.character.tint[1])
	    myShader:send("tint_g", player.character.tint[2])
	    myShader:send("tint_b", player.character.tint[3])
	end
end

P.charger = P.superTool:new{name = 'charger', description = "Energize!", baseRange = 1, image = love.graphics.newImage('Graphics/charger.png'), quality = 4}
function P.charger:usableOnTile(tile)
	if tile.canBePowered and not tile.charged then return true end
	return false
end
function P.charger:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.charged = true
end

P.visionChanger = P.superTool:new{name = 'visionChanger', description = "God's eye view",baseRange = 0, image = love.graphics.newImage('Graphics/visionChanger.png'), quality = 1}
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

P.bomb = P.superTool:new{name = "bomb", description = "3-2-1 BOOM!", baseRange = 1, image = love.graphics.newImage('Graphics/Tools/bomb.png'), quality = 4}
function P.bomb:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	t = tiles.bomb:new()
	t.counter = 3
	room[tileY][tileX] = t
end
function P.bomb:usableOnNothing()
	return true
end

P.flame = P.superTool:new{name = "flame", description = "Share the warmth.", baseRange = 1,
image = love.graphics.newImage('Graphics/Tools/flame.png'), quality = 2}
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

P.unsticker = P.superTool:new{name = "unsticker", description = "An artifact of the good old pre-sponge days.", baseRange = 1, image = love.graphics.newImage('Graphics/unsticker.png'), quality = 1}
function P.unsticker:usableOnTile(tile)
	if tile:instanceof(tiles.stickyButton) and tile.down then return true end
	return false
end
function P.unsticker:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:unstick()
end

P.crowbar = P.superTool:new{name = "crowbar", description = "Door busting power.", baseRange = 1, image = love.graphics.newImage('Graphics/unsticker.png'), quality = 4}
function P.crowbar:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) or tile:instanceof(tiles.hDoor) and not tile.stopped then return true end
	return false
end
function P.crowbar:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.open = true
	tile.stopped = true
end

P.doorstop = P.superTool:new{name = "doorstop", description = "Removed.", baseRange = 1, image = love.graphics.newImage('Graphics/unsticker.png'), quality = 2}
function P.doorstop:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) and (not tile.stopped) and (not tile.blocksMovement) then return true end
	return false
end
function P.doorstop:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.stopped = true
end

P.missile = P.superTool:new{name = "missile", description = "Airstrike supreme",
useWithArrowKeys = false, baseRange = 10,
image = love.graphics.newImage('Graphics/Tools/missile.png'), quality = 4}
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
P.missile.getToolableTiles = P.tool.getToolableTilesBox
P.missile.getToolableAnimals = P.tool.getToolableAnimalsBox
P.missile.useToolAnimal = P.gun.useToolAnimal

P.meat = P.superTool:new{name = "meat", baseRange = 1, image = love.graphics.newImage('Graphics/Tools/meat.png'), quality = 2}
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

P.rottenMeat = P.superTool:new{image = love.graphics.newImage('Graphics/Tools/rottenMeat.png'), quality = 3, baseRange = 1}
P.rottenMeat.usableOnNothing = P.meat.usableOnNothing
function P.rottenMeat:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.rottenMeat:new()
end
function P.rottenMeat:usableOnTile(tile)
	if tile.overlay==nil then
		return true
	end
	return false
end
function P.rottenMeat:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.scaresAnimals = true
	tile.overlay = tiles.rottenMeat
end

P.corpseGrabber = P.superTool:new{name = "corpseGrabber", description = "Removed.", baseRange = 1, image = love.graphics.newImage('Graphics/corpseGrabber.png'), quality = 3}
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

P.woodGrabber = P.superTool:new{name = "woodGrabber", description = "Removed.", baseRange = 1, image = love.graphics.newImage('Graphics/woodGrabber.png'), quality = 3}
function P.woodGrabber:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and tile.destroyed
end
function P.woodGrabber:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	P.ladder.numHeld = P.ladder.numHeld+2
	room[tileY][tileX] = nil
end

P.pitbullChanger = P.superTool:new{name = "pitbullChanger", description = "Vegan gun",baseRange = 3, image = love.graphics.newImage('Graphics/pitbullChanger.png'), quality = 2}
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

P.rotater = P.superTool:new{name = "rotater", description = "Turnt", baseRange = 1, image = love.graphics.newImage('Graphics/rotatetool.png'), quality = 4}
function P.rotater:usableOnTile(tile)
	return true
end
function P.rotater:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	tile:rotate(1)
end

P.trap = P.superTool:new{name = "trap", description = "Removed?", baseRange = 1, image = love.graphics.newImage('Graphics/trap.png'), quality = 2}
function P.trap:usableOnNothing()
	return true
end
function P.trap:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.mousetrap:new()
end

P.boxCutter = P.superTool:new{name = "boxCutter", description = "There's a present inside!", baseRange = 1, image = love.graphics.newImage('Graphics/boxcutter.png'), quality = 3}
function P.boxCutter:usableOnPushable(pushable)
	return true
end
function P.boxCutter:useToolPushable(pushable)
	self.numHeld = self.numHeld - 1
	pushable.destroyed = true
	P.giveRandomTools(1)
end

P.broom = P.superTool:new{name = "broom", description = "Gone with the wind.",image = love.graphics.newImage('Graphics/broom.png'), quality = 1}
function P.broom:usableOnTile(tile)
	return tile:instanceof(tiles.slime) or tile:instanceof(tiles.conductiveSlime)
end
function P.broom:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX]=nil
end

P.magnet = P.superTool:new{name = "magnet", description = "Pull vs Push", baseRange = 5,
image = love.graphics.newImage('Graphics/Tools/boxMagnet.png'), quality = 1}
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

P.spring = P.superTool:new{name = "spring", description = "Up, up in the air I go.", useWithArrowKeys = false, baseRange = 4, image = love.graphics.newImage('Graphics/spring.png'), quality = 3}
function P.spring:usableOnTile(tile)
	if tile:getHeight()>0 then
		return true
	end
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
end
P.spring.getToolableTiles = P.tool.getToolableTilesBox

P.glue = P.superTool:new{name = "Glue", description = "Trap an animal.", image = love.graphics.newImage('Graphics/Tools/glue.png'), quality = 2}
function P.glue:usableOnNothing()
	return true
end
function P.glue:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.glue:new()
end

P.endFinder = P.superTool:new{name = "endFinder", description = "Removed.",baseRange = 0, image = love.graphics.newImage('Graphics/endfinder.png'), quality = 1}
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

--[[P.lamp = P.superTool:new{name = "lamp", description = "The light of power.", baseRange = 3, image = love.graphics.newImage('Graphics/lamp.png'), quality = 3}
function P.lamp:usableOnNothing()
	return true
end
function P.lamp:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.lamp:new()
end]]

P.boxSpawner = P.superTool:new{name = "boxSpawner", description = "Pushable #0", baseRange = 1, image = love.graphics.newImage('Graphics/box.png'), quality = 2}
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

P.playerBoxSpawner = P.boxSpawner:new{name = "playerBoxSpawner", image = love.graphics.newImage('Graphics/playerBox.png'), quality = 2}
function P.playerBoxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[3]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end
function P.playerBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[3]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end

P.bombBoxSpawner = P.boxSpawner:new{name = "bombBoxSpawner", image = love.graphics.newImage('Graphics/bombBox.png'), quality = 3}
function P.bombBoxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[8]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end
function P.bombBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[8]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end

P.jackInTheBoxSpawner = P.boxSpawner:new{name = "jackInTheBoxSpawner", image = love.graphics.newImage('Graphics/jackinthebox.png'), quality = 2}
function P.jackInTheBoxSpawner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[10]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end
function P.jackInTheBoxSpawner:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[10]:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end

P.lamp = P.boxSpawner:new{name = "lamp", baseRange = 1, image = love.graphics.newImage('Graphics/lamp.png'), quality = 3}
function P.lamp:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList.lamp:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
end
function P.lamp:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList[7]:new()
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


P.gateBreaker = P.superTool:new{name = "gateBreaker", description = "Fuck logic.", baseRange = 1, image = love.graphics.newImage('Graphics/shovel.png'), quality = 3}
function P.gateBreaker:usableOnTile(tile)
	return (tile:instanceof(tiles.gate) or tile:instanceof(tiles.notGate)) and not tile.destroyed
end
function P.gateBreaker:useToolTile(tile)
	self.numHeld = self.numHeld-1
	tile:destroy()
end

P.conductiveBoxSpawner = P.boxSpawner:new{name = "conductiveBoxSpawner", description = "", image = love.graphics.newImage('Graphics/conductiveBox.png'), quality = 3}
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

P.boomboxSpawner = P.boxSpawner:new{name = "boomboxSpawner", description = "Rock n' Roll", image = love.graphics.newImage('Graphics/boombox.png'), quality = 2}
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

P.superWireCutters = P.wireCutters:new{name = "superWireCutters", description = "Sharper wire cutters.", image = love.graphics.newImage('Graphics/wirecutters.png'), quality = 2}
function P.superWireCutters:usableOnNonOverlay(tile)
	return not tile.destroyed and (tile:instanceof(tiles.wire)
	or tile:instanceof(tiles.conductiveGlass) or tile:instanceof(tiles.reinforcedConductiveGlass) or tile:instanceof(tiles.electricFloor))
end
function P.superWireCutters:usableOnTile(tile)
	return self:usableOnNonOverlay(tile) or (tile.overlay~=nil and self:usableOnNonOverlay(tile.overlay))
end

P.laser = P.superTool:new{name = "laser", description = "Piercing shot", baseRange = 100, image = love.graphics.newImage('Graphics/laser.png'), quality = 2}
function P.laser:usableOnTile()
	return true
end
P.laser.usableOnNothing = P.laser.usableOnTile
local function killDogs(tileY, tileX)
	if tileX == player.tileX then
		for i = 1, #animals do
			if animals[i].tileX == player.tileX then
				if (tileY > player.tileY and animals[i].tileY > player.tileY) or
				  (tileY < player.tileY and animals[i].tileY < player.tileY) then 
					animals[i]:kill()
				end
			end
		end
	else
		for i = 1, #animals do
			if animals[i].tileY == player.tileY then
				if (tileX >= player.tileX and animals[i].tileX >= player.tileX) or
				  (tileX < player.tileX and animals[i].tileX < player.tileX) then
					animals[i]:kill()
				end
			end
		end
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

P.icegun = P.superTool:new{name = "Freeze ray", description = "Piercing Permafrost", baseRange = 100, image = love.graphics.newImage('Graphics/icegun.png'), quality = 2}
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
					end
				end
			end
		end
	end
end

function P.icegun:useToolTile(tile, tileY, tileX)
	iceDogs(tileY, tileX)
	self.numHeld = self.numHeld-1
end
function P.icegun:useToolNothing(tileY, tileX)
	iceDogs(tileY, tileX)
	self.numHeld = self.numHeld-1
end

--should superLaser kill animals? can't decide
P.superLaser = P.laser:new{name = "superLaser", description = "The Big Bad Beam", baseRange = 100, image = love.graphics.newImage('Graphics/laser.png'), quality = 4}
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


P.gas = P.superTool:new{name = "gas", description = "Make your room a tomb.", baseRange = 0, image = love.graphics.newImage('Graphics/gas.png'), quality = 3}
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


P.armageddon = P.superTool:new{name = "armageddon", description = "So very empty.", baseRange = 0, image = love.graphics.newImage('Graphics/armageddon.png'), quality = 4}
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


P.toolReroller = P.superTool:new{name = "toolReroller", description = "A shuffle and a draw.", baseRange = 0, image = love.graphics.newImage('Graphics/toolreroller.png'), quality = 2}
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

P.roomReroller = P.superTool:new{name = "roomReroller", description = "Tile transformation", baseRange = 0, image = love.graphics.newImage('Graphics/roomreroller.png'), quality = 5}
function P.roomReroller:usableOnNothing()
	return true
end
function P.roomReroller:getTilesWhitelist()
	return {tiles.wire, tiles.cornerWire, tiles.horizontalWire, tiles.metalWall, tiles.concreteWall, tiles.wall, tiles.glassWall,
	tiles.electricFloor, tiles.poweredFloor, tiles.pit, tiles.notGate, tiles.andGate, tiles.ladder, tiles.puddle, tiles.button, tiles.stayButton,
	tiles.stickyButton}
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


P.toolDoubler = P.superTool:new{name = "toolDoubler", description = "Double your tools!", baseRange = 0, image = love.graphics.newImage('Graphics/tooldoubler.png'), quality = 5}
function P.toolDoubler:usableOnNothing()
	return true
end
function P.toolDoubler:useToolNothing()
	for i = 1, P.numNormalTools do
		tools[i].numHeld = tools[i].numHeld*2
	end
	self.numHeld = self.numHeld-1
end

P.toolIncrementer = P.superTool:new{name = "toolIncrementer", description = "+'1-1-1-1-1-1-1'", baseRange = 0, image = love.graphics.newImage('Graphics/toolincrementer.png'), quality = 5}
function P.toolIncrementer:usableOnNothing()
	return true
end
function P.toolIncrementer:useToolNothing()
	for i = 1, P.numNormalTools do
		tools[i].numHeld = tools[i].numHeld+1
	end
	self.numHeld = self.numHeld-1
end

P.wings = P.superTool:new{name = "wings", description = "His feet never touched the ground.", baseRange = 0, image = love.graphics.newImage('Graphics/wings.png'), quality = 4}
function P.wings:usableOnNothing()
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

P.swapper = P.superTool:new{name = "swapper", description = "Lets trade places.", useWithArrowKeys = false, baseRange = 100, image = love.graphics.newImage('Graphics/swapper.png'), quality = 1}
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


P.bucketOfWater = P.superTool:new{name = "bucketOfWater", description = "Bottomless bucket", baseRange = 1,
image = love.graphics.newImage('Graphics/Tools/bucketOfWater.png'), quality = 1}
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

P.teleporter = P.superTool:new{name = "teleporter", description = "Who knows where you'll wind up", baseRange = 0, image = love.graphics.newImage('Graphics/teleporter.png'), quality = 1}
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
				createAnimals()
				createPushables()
			end
			visibleMap[mapy][mapx] = 1
			keyTimer.timeLeft = keyTimer.suicideDelay
			updateGameState()
		end
	end
end

P.revive = P.superTool:new{name = "revive", description = "Not yet.", baseRange = 0, image = love.graphics.newImage('Graphics/revive.png'), quality = 5}
function P.revive:checkDeath()
	if self.numHeld > 0 then
		self.numHeld = self.numHeld-1
		return false
	end
	return true
end

P.explosiveGun = P.gun:new{name = "explosiveGun", description = "Boom Boom", baseRange = 5, image = love.graphics.newImage('Graphics/superGun.png'), quality = 2}
function P.explosiveGun:useToolTile(tile, tileY, tileX)
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

P.map = P.superTool:new{name = "map", description = "You'll find a way", baseRange = 0, image = love.graphics.newImage('Graphics/Tools/map.png'), quality = 1}
function P.map:usableOnNothing()
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

P.buttonFlipper = P.superTool:new{name = "buttonFlipper", "Click... click-click-click-click", baseRange = 0, image = love.graphics.newImage('Graphics/buttonflipper.png'), quality = 2}
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

P.wireBreaker = P.superTool:new{name = "wireBreaker", description = "Snap... snap-snap-snap-snap", baseRange = 0, image = love.graphics.newImage('Graphics/wirebreaker.png'), quality = 2}
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

P.powerBreaker = P.superTool:new{name = "powerBreaker", description = "Powerless", baseRange = 0, image = love.graphics.newImage('Graphics/powerbreaker.png'), quality = 2}
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

P.gabeMaker = P.superTool:new{name = "gabeMaker", description = "Gabriel", baseRange = 0, image = love.graphics.newImage('Graphics/gabeSmall.png'), quality = 5}
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

P.roomUnlocker = P.superTool:new{name = "Room Unlocker", description = "Gatecrashing", baseRange = 0, image = love.graphics.newImage('Graphics/roomunlocker.png'), quality = 2}
function P.roomUnlocker:usableOnNothing()
	return true
end
P.roomUnlocker.usableOnTile = P.roomUnlocker.usableOnNothing
function P.roomUnlocker:useToolNothing()
	self.numHeld = self.numHeld-1
	unlockDoorsPlus()
end
P.roomUnlocker.useToolTile = P.roomUnlocker.useToolNothing

P.axe = P.superTool:new{name = "Axe", description = "Throw it or swing it.", baseRange = 5,
image = love.graphics.newImage('Graphics/Tools/axe.png'), quality = 2}
P.axe.usableOnTile = P.saw.usableOnTile
P.axe.usableOnAnimal = P.gun.usableOnAnimal
P.axe.useToolAnimal = P.gun.useToolAnimal
P.axe.useToolTile = P.saw.useToolTile

P.lube = P.superTool:new{name = "lube", description = "Wuba lubba dub dub", baseRange = 1, image = love.graphics.newImage('Graphics/lube.png'), quality = 2}
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

P.knife = P.superTool:new{name = "knife", description = "Take the plunge and cut your ties.", baseRange = 5,
image = love.graphics.newImage('Graphics/Tools/knife.png'), quality = 2}
P.knife.usableOnAnimal = P.gun.usableOnAnimal
P.knife.usableOnTile = P.wireCutters.usableOnTile
P.knife.useToolAnimal = P.gun.useToolAnimal
P.knife.useToolTile = P.wireCutters.useToolTile
P.knife.usableOnNonOverlay = P.wireCutters.usableOnNonOverlay
P.knife.usableOnPushable = P.wireCutters.usableOnPushable
P.knife.useToolPushable = P.wireCutters.useToolPushable

P.snowball = P.superTool:new{name = "snowball", description = "Throwable", baseRange = 5, image = love.graphics.newImage('Graphics/snowball.png'), quality = 1}
function P.snowball:usableOnAnimal(animal)
	return not animal.dead
end
function P.snowball:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+1
end

P.superSnowball = P.snowball:new{name = "superSnowball", description = "So very cold",image = love.graphics.newImage('Graphics/supersnowball.png'), quality = 2}
function P.superSnowball:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.frozen = true
end

P.snowballGlobal = P.snowball:new{name = "snowballGlobal", description = "Iceage", image = love.graphics.newImage('Graphics/snowballglobal.png'), baseRange = 0, quality = 3}

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

P.superBrick = P.brick:new{name = "superBrick", description = "Brick the unbrickable", mage = love.graphics.newImage('Graphics/superbrick.png'), baseRange = 5, quality = 2}
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
end

P.superWaterBottle = P.waterBottle:new{name = "superWaterBottle", description = "Break the unbreakable", image = love.graphics.newImage('Graphics/superwaterbottle.png'), baseRange = 3, quality = 2}
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

P.portalPlacer = P.superTool:new{name = "portalPlacer", description = "Thinking with portals is more fun", image = love.graphics.newImage('Graphics/entrancePortal.png'), baseRange = 1, quality = 1}
function P.portalPlacer:usableOnNothing()
	return true
end
function P.portalPlacer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.entrancePortal:new()
end

P.suicideKing = P.superTool:new{name = "suicideKing", description = "Die", image = love.graphics.newImage('Graphics/suicideking.png'), baseRange = 0, quality = 1}
function P.suicideKing:usableOnNothing()
	return true
end
function P.suicideKing:useToolNothing()
	self.numHeld = self.numHeld-1
	P.giveSupertools(3)
end
P.suicideKing.usableOnTile = P.suicideKing.usableOnNothing
P.suicideKing.useToolTile = P.suicideKing.useToolNothing

P.screwdriver = P.superTool:new{name = "screwdriver", description = "Spikey plates", image = love.graphics.newImage('Graphics/screwdriver.png'), baseRange = 1, quality = 2}
function P.screwdriver:usableOnTile(tile)
	return tile:instanceof(tiles.spikes)
end
function P.screwdriver:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	room[tileY][tileX] = nil
end

P.laptop = P.superTool:new{name = "laptop", description = "Google", image = love.graphics.newImage('Graphics/laptop.png'), baseRange = 0, quality = 1}
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

P.donationCracker = P.superTool:new{name = "donationCracker", image = love.graphics.newImage('Graphics/donationcracker.png'), baseRange = 1, quality = 5}
function P.donationCracker:usableOnTile(tile)
	return tile:instanceof(tiles.donationMachine)
end
function P.donationCracker:useToolTile()
	self.numHeld = self.numHeld-1
	tools.giveRandomTools(math.floor(donations*1.5))
	donations = 0
end

P.wireExtender = P.superTool:new{name = "wireExtender", description = "Longer is better", image = love.graphics.newImage('Graphics/wireextender.png'), quality = 1}
function P.wireExtender:usableOnTile(tile)
	return tile:instanceof(tiles.wire)
end
function P.wireExtender:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.wire:new()
end

P.coin = P.superTool:new{name = "coin", description = "All costs must be payed", image = love.graphics.newImage('Graphics/Tools/coin.png'), range = 1, quality = 2}
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

P.emptyBucket = P.superTool:new{name = "emptyBucket", description = "Fill her up!", puddleTile = nil,
image = love.graphics.newImage('Graphics/Tools/emptyBucket.png'),
imageEmpty = love.graphics.newImage('Graphics/Tools/emptyBucket.png'),
waterImage = love.graphics.newImage('Graphics/Tools/bucketOfWater.png'),
gasImage = love.graphics.newImage('Graphics/Tools/bucketOfGas.png'),
lemonadeImage = love.graphics.newImage('Graphics/Tools/bucketOfLemonade.png'),
full = false, baseRange = 1, quality = 2}
function P.emptyBucket:usableOnTile(tile)
	if self.full then return P.bucketOfWater:usableOnTile(tile) end
	if not self.full then return tile:instanceof(tiles.puddle) end
end

function P.emptyBucket:updateSprite()
	if not self.full then
		self.sprite = self.imageEmpty
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
		--P.bucketOfWater:useToolTile(tile, tileY, tileX)
		--above may cause problem by impacting wrong numHeld
		--probably doesn't matter because, unless changed, buckets only work on nothing
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

P.emptyCup = P.emptyBucket:new{name = "emptyCup", image = love.graphics.newImage('Graphics/Tools/emptyCup.png'),
imageFull = love.graphics.newImage('Graphics/Tools/emptyCupWater.png'),
imageEmpty = love.graphics.newImage('Graphics/Tools/emptyCup.png'),
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
	if self.full then return P.waterBottle:usableOnTile(tile) end
	if not self.full then return tile:instanceof(tiles.puddle) end
end

function P.emptyCup:useToolTile(tile, tileY, tileX)
	if not self.full then
		self.image = self.imageFull
		self.full = true
		room[tileY][tileX] = nil
	else
		self.numHeld = self.numHeld-1
		P.waterBottle:useToolTile(tile, tileY, tileX)
		self.image = self.imageEmpty
		self.full = false
	end
end

P.mask = P.superTool:new{name = "mask", description = "The demon in the mask",
image = love.graphics.newImage('Graphics/Tools/mask.png'), baseRange = 0, quality = 1}
function P.mask:usableOnTile(tile)
	return true
end
P.mask.usableOnNothing = P.mask.usableOnTile
function P.mask:useToolTile(tile)
	self.numHeld = self.numHeld-1
	player.attributes.fear = true
end
P.mask.useToolNothing = P.mask.useToolTile

P.growthHormones = P.superTool:new{name = "growthHormones", description = "Growing up", image = love.graphics.newImage('Graphics/growthHormones.png'), baseRange = 0, quality = 1}
function P.growthHormones:usableOnTile(tile)
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

P.robotArm = P.superTool:new{name = "robotArm", description = "Reach for the stars", image = love.graphics.newImage('Graphics/robotArm.png'), quality = 1, baseRange = 0}
function P.robotArm:usableOnTile(tile)
	return true
end
P.robotArm.usableOnNothing = P.robotArm.usableOnTile
function P.robotArm:useToolTile(tile)
	self.numHeld = self.numHeld-1
	player.attributes.extendedRange = player.attributes.extendedRange+3
end
P.robotArm.useToolNothing = P.robotArm.useToolTile

P.sock = P.superTool:new{name = "Sneak", description = "Update blocker", image = love.graphics.newImage('Graphics/Tools/sock.png'), quality = 1, baseRange = 0}
function P.sock:usableOnTile(tile)
	return true
end
P.sock.usableOnNothing = P.sock.usableOnTile
function P.sock:useToolTile(tile)
	self.numHeld = self.numHeld-1
	player.attributes.sockStep = 1
	forcePowerUpdateNext = false
end
P.sock.useToolNothing = P.sock.useToolTile

P.gasPourer = P.superTool:new{name = "gasPourer", description = "Sentient cloud", image = love.graphics.newImage('Graphics/gaspourer.png'), quality = 4, baseRange = 1}
function P.gasPourer:usableOnNothing()
	return true
end
function P.gasPourer:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.gasPuddle:new()
end

P.gasPourerXtreme = P.gasPourer:new{name = "gasPourerXtreme", description = "Explosive landfill", image = love.graphics.newImage('Graphics/gaspourerxtreme.png'), quality = 4, baseRange = 1}
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

P.buttonPlacer = P.superTool:new{name = "buttonPlacer", description = "", image = love.graphics.newImage('Graphics/buttonplacer.png'), baseRange = 1, quality = 2}
function P.buttonPlacer:usableOnNothing()
	return true
end
function P.buttonPlacer:useToolNothing(tileY, tileX)
	room[tileY][tileX] = tiles.button:new()
end

P.wireToButton = P.superTool:new{name = "wireToButton", description = "Some things need an off switch", image = love.graphics.newImage('Graphics/wiretobutton.png'), baseRange = 1, quality = 3}
function P.wireToButton:usableOnTile(tile)
	return tile:instanceof(tiles.wire)
end
function P.wireToButton:useToolTile(tile, tileY, tileX)
	room[tileY][tileX] = tiles.button:new()
end

P.foresight = P.superTool:new{name = "foresight", description = "", image = love.graphics.newImage('Graphics/foresight.png'), baseRange = 0, quality = 1}
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
				else
					room[i][j] = tiles.supertoolTile:new()
				end
			end
		end
	end
end
P.foresight.useToolNothing = P.foresight.useToolTile

P.tileDisplacer = P.superTool:new{name = "tileDisplacer", description = "", heldTile = nil, image = love.graphics.newImage('Graphics/tiledisplacer.png'), baseImage = love.graphics.newImage('Graphics/tiledisplacer.png'), baseRange = 3, quality = 4}
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

P.tileSwapper = P.superTool:new{name = "tileSwapper", description = "", toSwapCoords = nil, image = love.graphics.newImage('Graphics/tileswapper.png'), baseImage = love.graphics.newImage('Graphics/tileswapper.png'), baseRange = 3, quality = 5}
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

P.tileCloner = P.superTool:new{name = "tileCloner", description = "Gain a copy.", heldTile = nil, image = love.graphics.newImage('Graphics/tilecloner.png'), baseImage = love.graphics.newImage('Graphics/tilecloner.png'), baseRange = 3, quality = 4}
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

P.shopReroller = P.superTool:new{name = "shopReroller", description = "Re-roll rquirements and items.", image = love.graphics.newImage('Graphics/shopreroller.png'), quality = 2}
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
					room[i][j] = tiles.supertoolTile:new()
				elseif room[i][j]:instanceof(tiles.toolTile) then
					room[i][j] = tiles.toolTile:new()
				end
			end
		end
	end
end
P.shopReroller.useToolNothing = P.shopReroller.useToolTile

P.ghostStep = P.superTool:new{name = "ghostStep", description ="You should tap that!", image = love.graphics.newImage('Graphics/ghoststep.png'), baseRange = 4, quality = 4}
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

P.stoolPlacer = P.superTool:new{name = "stoolPlacer", description = "Wanna get high?", image = love.graphics.newImage('GraphicsColor/halfwall.png'), baseRange = 1, quality = 3}
function P.stoolPlacer:usableOnNothing()
	return true
end
function P.stoolPlacer:useToolNothing(tileY, tileX)
	room[tileY][tileX] = tiles.halfWall:new()
end

P.lemonadeCup = P.superTool:new{name = "lemonadeCup", description = "Dainty cup",
image = love.graphics.newImage('Graphics/Tools/lemonadeCup.png'), baseRange = 1, quality = 1}
function P.lemonadeCup:usableOnNothing()
	return true
end
function P.lemonadeCup:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.lemonade:new()
end

P.lemonParty = P.superTool:new{name = "lemonParty", description = "Ben Most is a stupid piece of toast.",
image = love.graphics.newImage('Graphics/Tools/lemonadePitcher.png'), baseRange = 1, quality = 2}
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

P.inflation = P.superTool:new{name = "inflation", description = "Double Your Dough", image = love.graphics.newImage('Graphics/inflation.png'), baseRange = 0, quality = 2}
function P.inflation:usableOnNothing()
	return true
end
P.inflation.usableOnTile = P.inflation.usableOnNothing
function P.inflation:useToolNothing()
	self.numHeld = self.numHeld-1
	tools.coin.numHeld = tools.coin.numHeld*2
end
P.inflation.useToolTile = P.inflation.useToolNothing

P.wallDungeonDetector = P.superTool:new{name = "Wall-to-English Translator", image = love.graphics.newImage('Graphics/wtetranslator.png'), description = "If these walls could talk....", baseRange = 0, quality = 2}
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

P.greed = P.superTool:new{name = "Greed", description = "Your greed is your demise", image = love.graphics.newImage('GraphicsBrush/endtile.png'), baseRange = 0, quality = 1}
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

P.towel = P.superTool:new{name = "Primer", description = "Get that blue paint off!", image = love.graphics.newImage('Graphics/towel.png'), quality = 4}
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

P.playerCloner  = P.superTool:new{name = "Clone Spawner", description = "Make a new you", cloneExists = false, baseRange = 0, image = love.graphics.newImage('Graphics/playercloner.png'),
imageNoClone = love.graphics.newImage('Graphics/playercloner.png'), imageClone = love.graphics.newImage('Graphics/playercloner2.png'), quality = 3}
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

P.salt = P.superTool:new{name = "Salt", description = "The deadliest weapon...don't spill!",
image = love.graphics.newImage('Graphics/Tools/salt.png'), baseRange = 2, quality = 1}
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

P.shell = P.superTool:new{name = "Shell", description = "Curl up and hide", image = love.graphics.newImage('Graphics/shell.png'), baseRange = 0, quality = 2}
function P.shell:usableOnNothing()
	return true
end
P.shell.usableOnTile = P.shell.usableOnNothing
function P.shell:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.shelled = true
end
P.shell.useToolTile = P.shell.useToolNothing

P.glitch = P.superTool:new{name = "Glitch", description = "...what just happened?", image = love.graphics.newImage('Graphics/glitch.png'), baseRange = 1, quality = 3}
function P.glitch:usableOnNothing()
	return true
end
P.glitch.usableOnTile = P.glitch.usableOnNothing
function P.glitch:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	globalPowerBlock = true
end
function P.glitch:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	globalDeathBlock = true
	globalPowerBlock = true
end

P.bouncer = P.superTool:new{name = "Bouncer", description = "This club is for attractive people only", image = love.graphics.newImage('Graphics/bouncer.png'), baseRange = 1, quality = 1}
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
end

P.shift = P.superTool:new{name = "Shift", description = "Now slide to the left", image = love.graphics.newImage('Graphics/shift.png'), baseRange = 1, quality = 1}
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
end
function P.shift:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	room[player.tileY][player.tileX]:onEnter()
end

P.block = P.superTool:new{name = "Mental block", description = "Poof", image = love.graphics.newImage('Graphics/woodwall.png'), baseRange = 1, quality = 3}
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

P.tileMagnet = P.superTool:new{name = "Super Magnet", description = "It pulls its weight", image = love.graphics.newImage('Graphics/tilemagnet.png'), quality = 3, baseRange = 4}
function P.tileMagnet:usableOnTile(tile, dist)
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
	if dist==1 and room[player.tileY][player.tileX]~=nil then return false
	elseif tile.untoolable then return false end
	return true
end
function P.tileMagnet:useToolTile(tile, tileY, tileX)
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

P.pickaxe = P.superTool:new{name = "Pickaxe", description = "Get cracking", baseRange = 1, image = love.graphics.newImage('Graphics/pickaxe.png'), quality = 3}
function P.pickaxe:usableOnTile(tile)
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
	self.numHeld = self.numHeld-1
	P.shovel:useToolNothing(tileY, tileX)
end
function P.pickaxe:useToolTile(tile)
	self.numHeld = self.numHeld-1
	if tile.sawable then
		tile:destroy()
	else tile.sawable = true end
end
function P.pickaxe:useToolPushable(pushable)
	self.numHeld = self.numHeld-1
	pushable:destroy()
end

P.luckyPenny = P.coin:new{name = "Lucky Penny", description = "May all your wishes come true", quality = 3, image = love.graphics.newImage('Graphics/Tools/luckyPenny.png')}

P.helmet = P.superTool:new{name = "Knight's Helmet", description = "You're feeling slanted", quality = 3, image = love.graphics.newImage('Graphics/helmet.png'), baseRange = 2}
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
end
function P.helmet:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY
	room[player.tileY][player.tileX]:onEnter(player)
end

P.stealthBomber = P.superTool:new{name = "Stealth Bomber", description = "Drop 'n' Go", image = love.graphics.newImage('Graphics/stealthbomber.png'), baseRange = 2, quality = 3}
P.stealthBomber.getToolableTiles = P.tool.getToolableTilesBox
function P.stealthBomber:usableOnNothing(tileY, tileX)
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then
			return false
		end
	end
	return math.abs(tileY-player.tileY)+math.abs(tileX-player.tileX)>1 and (tileY==player.tileY or tileX==player.tileX)
end
function P.stealthBomber:usableOnTile(tile, dist)
	local tileY=0
	local tileX=0
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]==tile then
				tileX = j
				tileY = i
			end
		end
	end
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
end
function P.stealthBomber:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	player.tileX = tileX
	player.tileY = tileY

	if room[(player.tileY+player.prevTileY)/2][(player.tileX+player.prevTileX)/2]~= nil then
		room[(player.tileY+player.prevTileY)/2][(player.tileX+player.prevTileYX)/2]:destroy()
	end

	updateElevation()
	room[tileY][tileX]:onEnter(player)
	if room[player.prevTileY][player.prevTileX]~=nil then
		room[player.prevTileY][player.prevTileX]:onLeave(player)
	end
end

P.seeds = P.superTool:new{name = "Seeds", description = "Go forth and sow your wild oats", baseRange = 1, quality = 2,
image = love.graphics.newImage('Graphics/Tools/seeds.png')}
function P.seeds:usableOnNothing()
	return true
end
function P.seeds:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.tree:new()
end

P.supertoolDoubler = P.superTool:new{name = "Supertool Doubler", description = "Power, multiplied", baseRange = 0, quality = 3, image = love.graphics.newImage('Graphics/supertooldoubler.png')}
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
image = love.graphics.newImage('Graphics/Tools/coffee.png'), quality = 2, baseRange = 0}
function P.coffee:usableOnNothing()
	return true
end
P.coffee.usableOnTile = P.coffee.usableOnNothing
function P.coffee:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.fast = {fast = true, fastStep = false}
end
P.coffee.useToolTile = P.coffee.useToolNothing

P.boxDisplacer = P.superTool:new{name = "boxDisplacer", description = "", heldBox = nil, image = love.graphics.newImage('Graphics/tiledisplacer.png'), baseImage = love.graphics.newImage('Graphics/tiledisplacer.png'), baseRange = 3, quality = 3}
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

P.boxCloner = P.superTool:new{name = "boxCloner", description = "Gain a copy.", heldBox = nil, image = love.graphics.newImage('Graphics/tilecloner.png'), baseImage = love.graphics.newImage('Graphics/tilecloner.png'), baseRange = 3, quality = 4}
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
	table.insert(pushables, boxAdd)
	pushables[#pushables].tileY = tileY
	pushables[#pushables].tileX = tileX
	self.heldBox = nil
	self.image = self.baseImage
end
function P.boxCloner:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local boxAdd = deepCopy(self.heldBox)
	table.insert(pushables, boxAdd)
	pushables[#pushables].tileY = tileY
	pushables[#pushables].tileX = tileX
	self.heldBox = nil
	self.image = self.baseImage
end

P.tilePusher = P.superTool:new{name = "tilePusher", description = "Pushy, pushy", --[[or "Truly repulsive"]]image = love.graphics.newImage('Graphics/shovel.png'), baseRange = 3, quality = 3}
function P.tilePusher:usableOnTile(tile, dist)
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

P.portalPlacerDouble = P.superTool:new{name = "Portal Placer 2", stage = 1, description = "Now with new colors!", image = love.graphics.newImage('Graphics/entranceportal2.png'),
baseImage = love.graphics.newImage('Graphics/entranceportal2.png'), secondImage = love.graphics.newImage('Graphics/exitportal2.png'), baseRange = 1, quality = 2}
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

P.spinningSword = P.superTool:new{name = "Spinning Sword", description = "Do the helicopter sword", image = love.graphics.newImage('Graphics/spinningsword.png'), quality = 4, baseRange = 1}
P.spinningSword.getToolableTiles = P.tool.getToolableTilesBox
function P.spinningSword:usableOnNothing()
	return true
end
P.spinningSword.usableOnTile = P.spinningSword.usableOnNothing
function P.spinningSword:useToolNothing()
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
end
P.spinningSword.useToolTile = P.spinningSword.useToolNothing

P.ironMan = P.superTool:new{name = "Daily Supplements", description = "Do you even lift?", image = love.graphics.newImage('Graphics/ironman.png'),
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
image = love.graphics.newImage('Graphics/supertoolreroller.png'), baseRange = 0, quality = 3}
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

P.tunneler = P.superTool:new{name = "Tunneler", description = "Someone get me out of here!", image = love.graphics.newImage('KenGraphics/stairs.png'),
baseRange = 1, quality = 2}
function P.tunneler:usableOnNothing()
	return true
end
function P.tunneler:useToolNothing(tileY, tileX)
	room[tileY][tileX] = tiles.tunnel:new()
end

P.longLadder = P.superTool:new{name = "longLadder", description = "", image = love.graphics.newImage('Graphics/ladder.png'),
baseRange = 1, quality = 3}
P.longLadder.usableOnNothing = P.ladder.usableOnNothing
P.longLadder.useToolNothing = P.ladder.useToolNothing
P.longLadder.usableOnTile = P.ladder.usableOnTile
function P.longLadder:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	self:spreadLadders(tileY, tileX)
end
function P.longLadder:spreadLadders(tileY, tileX)
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

P.superSaw = P.superTool:new{name = "Super Saw", description = "", image = love.graphics.newImage('Graphics/saw.png'),
baseRange = 1, quality = 3}
function P.superSaw:usableOnPushable()
	return true
end
function P.superSaw:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and tile:getHeight()>0 and not tile:instanceof(tiles.reinforcedGlass) and not tile:instanceof(tiles.glassWall)
end
function P.superSaw:useToolPushable(pushable)
	pushable:destroy()
end

P.superSponge = P.superTool:new{name = "Super Sponge", description = "", image = love.graphics.newImage('NewGraphics/sponge copy.png'),
baseRange = 1, quality = 2}
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

--gun, but radial and works on concrete
P.superGun = P.superTool:new{name = "superGun", description = "", baseRange = 5, image = love.graphics.newImage('Graphics/superGun.png'), quality = 2}
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
		unlocks.unlockUnlockableRef(unlocks.beggarPartyUnlock)
		tile:destroy()
	else
		tile:allowVision()
	end
end
function P.superGun:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	animal:kill()
end

--same as ladder but more range; used primarily for tool upgrades
P.superLadder = P.superTool:new{name = "superLadder", description = "", image = love.graphics.newImage('Graphics/ladder.png'),
baseRange = 6, quality = 1}
function P.superLadder:usableOnTile(tile)
	if not tile.laddered then
		if tile:instanceof(tiles.breakablePit) and tile.strength == 0 then
			return true
		elseif tile:instanceof(tiles.poweredFloor) or tile:instanceof(tiles.pit) then
			return true
		end
	end
	return false
end
function P.superLadder:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:ladder()
end
function P.superLadder:usableOnNothing()
	return true
end
function P.superLadder:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	room[tileY][tileX] = tiles.ladder:new()
end

P.woodenRain = P.superTool:new{name = "woodenRain", description = "", image = love.graphics.newImage('Graphics/ladder.png'),
baseRange = 0, quality = 2}
function P.woodenRain:usableOnNothing()
	return true
end
P.woodenRain.usableOnTile = P.woodenRain.usableOnNothing
function P.woodenRain:useToolNothing()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			local isValid = true
			if room[i][j]~=nil then isValid = false
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
P.tempUpgrade = P.superTool:new{name = "Temp Upgrade", description = "", image = love.graphics.newImage('Graphics/tempupgrade.png'),
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

P.permaUpgrade = P.superTool:new{name = "permaUpgrade", description = "", image = love.graphics.newImage('Graphics/permaupgrade.png'),
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
image = love.graphics.newImage('Graphics/Tools/santaHat.png'),
baseRange = 1, quality = 3}
function P.christmasSurprise:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList.giftBox:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
	tools.saw.numHeld = tools.saw.numHeld+1
	for i = 1, #pushables do
		if pushables[i].name == "box" then
			local giftY = pushables[i].tileY
			local giftX = pushables[i].tileX
			pushables[i] = pushableList.giftBox:new()
			pushables[i].tileY = giftY
			pushables[i].tileX = giftX	
		end
	end
end
function P.christmasSurprise:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	local toSpawn = pushableList.giftBox:new()
	toSpawn.tileY = tileY
	toSpawn.tileX = tileX
	pushables[#pushables+1] = toSpawn
	tools.saw.numHeld = tools.saw.numHeld+1
	for i = 1, #pushables do
		if pushables[i].name == "box" then
			local giftY = pushables[i].tileY
			local giftX = pushables[i].tileX
			pushables[i] = pushableList.giftBox:new()
			pushables[i].tileY = giftY
			pushables[i].tileX = giftX	
		end
	end
end

P.ironWoman = P.superTool:new{name = "Iron Woman", description = "Closer....", image = love.graphics.newImage('Graphics/ironman.png'),
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
P.wallReroller = P.superTool:new{name = "Wall Reroller", description = "", image = love.graphics.newImage('Graphics/wallreroller.png'),
baseRange = 0, quality = 3}
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
P.beggarReroller = P.superTool:new{name = "Beggar Reroller", description = "Basically just changing hats", image = love.graphics.newImage('Graphics/beggar.png'),
baseRange = 0, quality = 3}
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

P.xrayVision = P.superTool:new{name = "X-Ray Vision", description = "The bright side of Chernoybl",
image = love.graphics.newImage('Graphics/Tools/xrayVision.png'),
baseRange = 0, quality = 3}
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

P.secretTeleporter = P.superTool:new{name = "Secret Teleporter", description = "Find the hole in the wall", image = love.graphics.newImage('Graphics/secretteleporter.png'),
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
			createAnimals()
			createPushables()
		end
		visibleMap[mapy][mapx] = 1
		keyTimer.timeLeft = keyTimer.suicideDelay
		updateGameState()
	end
end
P.secretTeleporter.useToolTile = P.secretTeleporter.useToolNothing

P.buttonReroller = P.superTool:new{name = "Button Reroller", description = "", image = love.graphics.newImage('Graphics/button.png'),
baseRange = 0, quality = 2}
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

P.compass = P.superTool:new{name = "The Compass", description = "May you forever find your path", image = love.graphics.newImage('Graphics/compass.png'),
baseRange = 0, quality = 3}
function P.compass:usableOnNothing()
	return true
end
P.compass.usableOnTile = P.compass.usableOnNothing
function P.compass:useToolNothing()
	self.numHeld = self.numHeld-1
	player.attributes.permaMap = true
	tools.map:useToolNothing()
end
P.compass.useToolTile = P.compass.useToolNothing

P.santasHat = P.superTool:new{name = "Santa's Hat", description = "Gifts lay in store",
image = love.graphics.newImage('Graphics/giftBox.png'),
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
image = love.graphics.newImage('Graphics/saw.png'),
baseRange = 1, quality = 2}
function P.luckySaw:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and not tile.destroyed and tile.sawable
end
function P.luckySaw:useToolTile(tile, tileY, tileX)
	tile:destroy()
	room[tileY][tileX] = tiles.toolTile:new()
	room[tileY][tileX]:absoluteFinalUpdate()
end

P.luckyBrick = P.superTool:new{name = "Lucky Brick", description = "Knock on...glass?",
image = love.graphics.newImage('Graphics/brick.png'),
baseRange = 1, quality = 2}
function P.luckyBrick:usableOnTile(tile)
	return tile:instanceof(tiles.glassWall) and not tile:instanceof(tiles.reinforcedGlass) and not tile.destroyed
end
function P.luckyBrick:useToolTile(tile, tileY, tileX)
	tile:destroy()
	room[tileY][tileX] = tiles.toolTile:new()
	room[tileY][tileX]:absoluteFinalUpdate()
end

P.luckyCharm = P.superTool:new{name = "Medallion of Destruction", description = "With destruction comes fortune",
image = love.graphics.newImage('Graphics/luckyCharm.png'),
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
image = love.graphics.newImage('Graphics/trader.png'), quality = 4, baseRange = 0}
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

P.tileFlipper = P.superTool:new{name = "Tile Flipper", description = "", quality = 3, baseRange = 2,
image = love.graphics.newImage('Graphics/tileFlipper.png')}
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

P.animalReroller = P.superTool:new{name = "Animal Reroller", description = "", image = love.graphics.newImage('Graphics/toolreroller.png'),
baseRange = 0, quality = 2}
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
image = love.graphics.newImage('Graphics/roomreroller.png'),
baseRange = 0, quality = 2}
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

P.animalTrainer = P.superTool:new{name = "Animal Trainer", image = love.graphics.newImage('Graphics/whip.png'),
quality = 1, baseRange = 3}
function P.animalTrainer:usableOnAnimal()
	return true
end
function P.animalTrainer:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.trained = true
end

P.animalEnslaver = P.superTool:new{name = "Animal Enslaver", heldAnimal = nil, image = love.graphics.newImage('Graphics/whip.png'),
baseImage = love.graphics.newImage('Graphics/whip.png'),
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
	animals[#animals+1] = self.heldAnimal
	self.heldAnimal = nil
	self:updateSprite()
end
function P.animalEnslaver:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1

	self.heldAnimal.tileX = tileX
	self.heldAnimal.tileY = tileY
	animals[#animals+1] = self.heldAnimal
	self.heldAnimal = nil
	self:updateSprite()
end

P.numNormalTools = 7

--[[ideas:
--animal reroller
-box reroller
--animal trainer: grab animal/sprites, then release as scared beast that can destroy all tiles it enters
]]

function P.resetTools()
	P:insertTool(P.saw, 1)
	P:insertTool(P.ladder, 2)
	P:insertTool(P.wireCutters, 3)
	P:insertTool(P.waterBottle, 4)
	P:insertTool(P.sponge, 5)
	P:insertTool(P.brick, 6)
	P:insertTool(P.gun, 7)
	for i = 1, #tools do
		tools[i].range = tools[i].baseRange
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

P:addTool(P.crowbar)
P:addTool(P.visionChanger) 
P:addTool(P.bomb)
P:addTool(P.electrifier)
P:addTool(P.delectrifier)
--P:addTool(P.unsticker)
P:addTool(P.doorstop)
P:addTool(P.charger)
P:addTool(P.missile)
P:addTool(P.shovel)
--P:addTool(P.woodGrabber)
--P:addTool(P.corpseGrabber)
P:addTool(P.pitbullChanger)
P:addTool(P.meat)
P:addTool(P.rotater)
P:addTool(P.teleporter)
P:addTool(P.boxCutter)
--P:addTool(P.broom)
P:addTool(P.magnet)
P:addTool(P.spring) --Fix this shit
P:addTool(P.glue)
--P:addTool(P.endFinder)
P:addTool(P.map)
P:addTool(P.ramSpawner)
P:addTool(P.gateBreaker)
P:addTool(P.conductiveBoxSpawner)
P:addTool(P.superWireCutters)
P:addTool(P.boxSpawner)
P:addTool(P.boomboxSpawner)
P:addTool(P.laser)
P:addTool(P.gas)
P:addTool(P.superLaser)
P:addTool(P.armageddon)
P:addTool(P.toolIncrementer)
P:addTool(P.toolDoubler)
P:addTool(P.roomReroller)
P:addTool(P.wings)
P:addTool(P.swapper)
P:addTool(P.bucketOfWater)
P:addTool(P.flame)
P:addTool(P.toolReroller)
P:addTool(P.revive)
P:addTool(P.explosiveGun)
P:addTool(P.buttonFlipper)
P:addTool(P.wireBreaker)
P:addTool(P.powerBreaker)
P:addTool(P.gabeMaker)
P:addTool(P.roomUnlocker)
P:addTool(P.axe) 
P:addTool(P.lube) 
--P:addTool(P.snowball)
P:addTool(P.knife)
P:addTool(P.superSnowball)
P:addTool(P.snowballGlobal)
P:addTool(P.superBrick)
P:addTool(P.portalPlacer)
--P:addTool(P.suicideKing) EXPLAIN THIS SHIT
P:addTool(P.screwdriver)
P:addTool(P.laptop)
P:addTool(P.wireExtender)
P:addTool(P.lamp)
P:addTool(P.coin) 

P:addTool(P.mask)
P:addTool(P.growthHormones)
P:addTool(P.robotArm)
P:addTool(P.sock)
P:addTool(P.trap)
P:addTool(P.emptyCup)
P:addTool(P.gasPourer)
P:addTool(P.gasPourerXtreme)
P:addTool(P.buttonPlacer)
P:addTool(P.wireToButton)
P:addTool(P.foresight)
P:addTool(P.tileDisplacer)
P:addTool(P.tileSwapper)
P:addTool(P.tileCloner)
P:addTool(P.shopReroller)
P:addTool(P.ghostStep)
P:addTool(P.stoolPlacer)
P:addTool(P.lemonadeCup)
P:addTool(P.lemonParty)
P:addTool(P.inflation)
P:addTool(P.emptyBucket)
P:addTool(P.superWaterBottle)
P:addTool(P.wallDungeonDetector)
P:addTool(P.towel)
P:addTool(P.playerCloner)
P:addTool(P.playerBoxSpawner)
P:addTool(P.bombBoxSpawner)
P:addTool(P.jackInTheBoxSpawner)
P:addTool(P.salt)
P:addTool(P.shell)
P:addTool(P.shift) --Lets talk about this one
P:addTool(P.glitch)
P:addTool(P.tileMagnet)
P:addTool(P.rottenMeat)
P:addTool(P.pickaxe)
P:addTool(P.luckyPenny)
P:addTool(P.bouncer)
P:addTool(P.block)
P:addTool(P.stealthBomber)

P:addTool(P.icegun)
P:addTool(P.seeds)
P:addTool(P.supertoolDoubler)
P:addTool(P.coffee)
P:addTool(P.boxDisplacer)
P:addTool(P.boxCloner)
P:addTool(P.tilePusher)
P:addTool(P.portalPlacerDouble)
P:addTool(P.spinningSword)
P:addTool(P.ironMan)
P:addTool(P.supertoolReroller)
P:addTool(P.tunneler)
P:addTool(P.longLadder)
P:addTool(P.superSaw)
P:addTool(P.superSponge)
--P:addTool(P.superLadder)
P:addTool(P.superGun)
P:addTool(P.woodenRain)
--P:addTool(P.tempUpgrade)
--P:addTool(P.permaUpgrade)
P:addTool(P.christmasSurprise)
P:addTool(P.ironWoman)
P:addTool(P.wallReroller)
P:addTool(P.beggarReroller)
P:addTool(P.xrayVision)
P:addTool(P.secretTeleporter)
P:addTool(P.buttonReroller)
P:addTool(P.compass)
--P:addTool(P.santasHat)
P:addTool(P.luckySaw)
P:addTool(P.luckyBrick)
P:addTool(P.luckyCharm)
P:addTool(P.trader)
P:addTool(P.tileFlipper)
P:addTool(P.animalReroller)
P:addTool(P.boxReroller)
P:addTool(P.animalTrainer)
P:addTool(P.animalEnslaver)

P.resetTools()

return tools