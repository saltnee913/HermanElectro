local P = {}
tools = P

function P.updateToolableTiles(toolid)
	if toolid ~= 0 then
		P.toolableAnimals = tools[toolid]:getToolableAnimals()
		P.toolableTiles = tools[toolid]:getToolableTiles()
		P.toolablePushables = tools[toolid]:getToolablePushables()
	else
		P.toolableAnimals = nil
		P.toolableTiles = nil
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

P.tool = Object:new{name = 'test', numHeld = 0, range = 1, image=love.graphics.newImage('Graphics/saw.png')}
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
			if tileToCheck.x<=0 or i>roomLength then break end
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
function P.wireCutters:usableOnTile(tile)
	return not tile.destroyed and (tile:instanceof(tiles.wire) or tile:instanceof(tiles.conductiveGlass) or tile:instanceof(tiles.reinforcedConductiveGlass) or tile:instanceof(tiles.electricFloor))
end
function P.wireCutters:useToolTile(tile)
	if tile:instanceof(tiles.conductiveGlass) or tile:instanceof(tiles.reinforcedConductiveGlass) then tile.canBePowered = false
	else tile:destroy() end
	self.numHeld = self.numHeld-1
end

P.waterBottle = P.tool:new{name = 'water-bottle', image = love.graphics.newImage('Graphics/waterbottle.png')}
function P.waterBottle:usableOnTile(tile)
	if not tile.destroyed and (tile:instanceof(tiles.powerSupply) or tile:instanceof(tiles.electricFloor) or tile:instanceof(tiles.untriggeredPowerSupply)) then
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

P.brick = P.tool:new{name = 'brick', range = 3, image = love.graphics.newImage('Graphics/brick.png')}
function P.brick:usableOnTile(tile, dist)
	if not tile.bricked and tile:instanceof(tiles.button) and dist <= 3 then
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
	return not animal.dead and animal.waitCounter==0
end
function P.brick:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.glassWall) then
		tile:destroy()
	else
		tile:lockInState(true)
	end
end
function P.brick:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.waitCounter = animal.waitCounter+1
end

P.gun = P.tool:new{name = 'gun', range = 3, image = love.graphics.newImage('NewGraphics/gun copy.png')}
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
		tile:destroy()
	else
		tile:allowVision()
	end
end


P.superTool = P.tool:new{name = 'superTool', range = 10, rarity = 1}

function P.chooseSupertool()
	return math.floor(math.random()*(#tools-tools.numNormalTools))+tools.numNormalTools+1
end

P.shovel = P.superTool:new{name = "shovel", range = 1, image = love.graphics.newImage('Graphics/shovel.png')}
function P.shovel:usableOnNothing()
	return true
end
function P.shovel:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.pit:new()
end

P.electrifier = P.superTool:new{name = 'electrifier', range = 1, image = love.graphics.newImage('Graphics/electrifier.png')}
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

P.delectrifier = P.superTool:new{name = 'delectrifier', range = 1, image = love.graphics.newImage('Graphics/electrifier2.png')}
function P.delectrifier:usableOnTile(tile)
	if tile.canBePowered then return true end
	return false
end
function P.delectrifier:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.canBePowered = false
	if tile:instanceof(tiles.powerSupply) or tile:instanceof(tiles.notGate) or tile:instanceof(tiles.wire) then tile:destroy() end
end

P.charger = P.superTool:new{name = 'charger', range = 1, image = love.graphics.newImage('Graphics/charger.png')}
function P.charger:usableOnTile(tile)
	if tile.canBePowered and not tile.charged then return true end
	return false
end
function P.charger:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.charged = true
end

P.visionChanger = P.superTool:new{name = 'visionChanger', range = 1, image = love.graphics.newImage('Graphics/visionChanger.png')}
function P.visionChanger:usableOnTile(tile)
	if tile.blocksVision then
		return true
	end
	return false
end
function P.visionChanger:useToolTile(tile)
	self.numHeld = self.numHeld-1
	tile:allowVision()
end

P.bomb = P.superTool:new{name = "bomb", range = 1, image = love.graphics.newImage('Graphics/bomb.png')}
function P.bomb:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	t = tiles.bomb:new()
	t.counter = 3
	room[tileY][tileX] = t
end
function P.bomb:usableOnNothing()
	return true
end

P.flame = P.superTool:new{name = "flame", range = 1, image = love.graphics.newImage('Graphics/flame.png')}
function P.flame:usableOnTile(tile)
	if tile:instanceof(tiles.wall) and tile.sawable and not tile:instanceof(tiles.metalWall) and not tile.destroyed then
		return true
	end
	return false
end
function P.flame:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.onFire = true
	updateFire()
end

P.unsticker = P.superTool:new{name = "unsticker", range = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.unsticker:usableOnTile(tile)
	if tile:instanceof(tiles.stickyButton) and tile.down then return true end
	return false
end
function P.unsticker:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:unstick()
end

P.crowbar = P.superTool:new{name = "crowbar", range = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.crowbar:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) or tile:instanceof(tiles.hDoor) and not tile.stopped then return true end
	return false
end
function P.crowbar:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.open = true
	tile.stopped = true
end

P.doorstop = P.superTool:new{name = "doorstop", range = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.doorstop:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) and (not tile.stopped) and (not tile.blocksMovement) then return true end
	return false
end
function P.doorstop:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.stopped = true
end

P.missile = P.superTool:new{name = "missile", range = 10, image = love.graphics.newImage('Graphics/missile.png')}
function P.missile:usableOnTile(tile)
	return not tile.destroyed and (tile:instanceof(tiles.wire) or tile:instanceof(tiles.electricFloor) or tile:instanceof(tiles.wall)) or tile:instanceof(tiles.powerSupply) and not tile.destroyed
end
function P.missile:usableOnAnimal(animal)
	return not animal.dead
end
P.missile.getToolableTiles = P.tool.getToolableTilesBox
P.missile.getToolableAnimals = P.tool.getToolableAnimalsBox

P.meat = P.tool:new{name = "meat", range = 1, image = love.graphics.newImage('Graphics/meat.png')}
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

P.corpseGrabber = P.superTool:new{name = "corpseGrabber", range = 1, image = love.graphics.newImage('Graphics/corpseGrabber.png')}
function P.corpseGrabber:usableOnAnimal(animal)
	return animal.dead and not animal.pickedUp
end
function P.corpseGrabber:useToolAnimal(animal)
	self.numHeld = self.numHeld-1
	animal.pickedUp = true
	P.meat.numHeld = P.meat.numHeld+3
end

P.woodGrabber = P.superTool:new{name = "woodGrabber", range = 1, image = love.graphics.newImage('Graphics/woodGrabber.png')}
function P.woodGrabber:usableOnTile(tile)
	return tile:instanceof(tiles.wall) and tile.destroyed
end
function P.woodGrabber:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	P.ladder.numHeld = P.ladder.numHeld+2
	room[tileY][tileX] = nil
end

P.pitbullChanger = P.tool:new{name = "pitbullChanger", range = 3, image = love.graphics.newImage('Graphics/pitbullChanger.png')}
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

P.sponge = P.tool:new{name = "sponge", range = 1, image = love.graphics.newImage('NewGraphics/sponge copy.png')}
function P.sponge:usableOnTile(tile)
	if tile:instanceof(tiles.dustyGlassWall) and tile.blocksVision then
		return true
	elseif tile:instanceof(tiles.puddle) then return true
	elseif tile:instanceof(tiles.stickyButton) then return true end
	return false
end
function P.sponge:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.dustyGlassWall) then
		tile.blocksVision = false
		tile.sprite = tile.cleanSprite
	elseif tile:instanceof(tiles.puddle) then
		room[tileY][tileX] = nil
	elseif tile:instanceof(tiles.stickyButton) then
		local down = tile.down
		room[tileY][tileX] = tiles.button:new()
	end
end

P.rotater = P.tool:new{name = "rotater", range = 1, image = love.graphics.newImage('Graphics/rotatetool.png')}
function P.rotater:usableOnTile(tile)
	return true
end
function P.rotater:useToolTile(tile, tileY, tileX)
	self.numHeld = self.numHeld-1
	tile:rotate(1)
end

P.trap = P.tool:new{name = "trap", range = 1, image = love.graphics.newImage('Graphics/trap.png')}
function P.trap:usableOnNothing()
	return true
end
function P.trap:useToolNothing(tileY, tileX)
	room[tileY][tileX] = tiles.trap:new()
end

P.boxCutter = P.tool:new{name = "boxCutter", range = 1, image = love.graphics.newImage('Graphics/boxcutter.png')}
function P.boxCutter:usableOnPushable(pushable)
	return true
end
function P.boxCutter:useToolPushable(pushable)
	self.numHeld = self.numHeld - 1
	pushable.destroyed = true
	for i = 1, 3 do
		local slot = math.floor(math.random()*tools.numNormalTools)+1
		tools[slot].numHeld = tools[slot].numHeld+1
	end
end

P.broom = P.tool:new{name = "broom", image = love.graphics.newImage('Graphics/pitbullChanger.png')}
function P.broom:usableOnTile(tile)
	return tile:instanceof(tiles.slime) or tile:instanceof(tiles.conductiveSlime)
end
function P.broom:useToolTile(tile, tileY, tileX)
	room[tileY][tileX]=nil
end

P.magnet = P.tool:new{name = "magnet", range = 5, image = love.graphics.newImage('Graphics/magnet.png')}
function P.magnet:usableOnPushable(pushable)
	return math.abs(player.tileX-pushable.tileX)+math.abs(player.tileY-pushable.tileY)>1
end
function P.magnet:useToolPushable(pushable)
	local pushX = pushable.tileX
	local pushY = pushable.tileY
	mover = {tileX = pushX, tileY = pushY, prevTileX = pushX, prevTileY = pushY}

	if pushX>player.tileX then mover.prevTileX = pushX+1
	elseif pushX~=player.tileX then mover.prevTileX = pushX-1
	elseif pushY>player.tileY then mover.prevTileY = pushY+1
	else mover.prevTileY = pushY-1 end

	pushable:move(mover)
end

P.spring = P.tool:new{name = "spring", range = 4, image = love.graphics.newImage('Graphics/spring.png')}
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

P.endFinder = P.tool:new{name = "endFinder", range = 0, image = love.graphics.newImage('Graphics/endfinder.png')}
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

P.lamp = P.tool:new{name = "lamp", range = 1, image = love.graphics.newImage('Graphics/lamp.png')}
function P.lamp:usableOnNothing()
	return true
end
function P.lamp:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld-1
	room[tileY][tileX] = tiles.lamp:new()
end

P.ramSpawner = P.tool:new{name = "ramSpawner", range = 1, image = love.graphics.newImage('Graphics/batteringram.png')}
function P.ramSpawner:usableOnNothing(tileY, tileX)
	if tileY==player.tileY and tileX==player.tileX then return false end
	for i = 1, #animals do
		if animals[i].tileY==tileY and animals[i].tileX==tileX then return false end
	end
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then return false end
	end
	return true
end
function P.ramSpawner:usableOnTile(tile, tileY, tileX)
	if tileY==player.tileY and tileX==player.tileX then return false end
	for i = 1, #animals do
		if animals[i].tileY==tileY and animals[i].tileX==tileX then return false end
	end
	for i = 1, #pushables do
		if pushables[i].tileY==tileY and pushables[i].tileX==tileX then return false end
	end
	return not tile.blocksMovement
end
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


P.gateBreaker = P.tool:new{name = "gateBreaker", range = 1, image = love.graphics.newImage('Graphics/shovel.png')}
function P.gateBreaker:usableOnTile(tile)
	return tile:instanceof(tiles.gate)
end
function P.gateBreaker:useToolTile(tile)
	tile.destroyed = true
	tile.canBePowered = false
end
P.numNormalTools = 7

P[1] = P.saw
P[2] = P.ladder
P[3] = P.wireCutters
P[4] = P.waterBottle
P[5] = P.sponge
P[6] = P.brick
P[7] = P.gun
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
P[23] = P.trap
P[24] = P.boxCutter
P[25] = P.broom
P[26] = P.magnet
P[27] = P.spring
P[28] = P.glue
P[29] = P.endFinder
P[30] = P.lamp
P[31] = P.ramSpawner
P[32] = P.gateBreaker

return tools