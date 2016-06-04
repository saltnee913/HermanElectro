local P = {}
tools = P

function P.updateToolableTiles(toolid)
	if toolid ~= 0 then
		P.toolableAnimals = tools[toolid]:getToolableAnimals()
		P.toolableTiles = tools[toolid]:getToolableTiles()
	else
		P.toolableAnimals = nil
		P.toolableTiles = nil
	end
end

--prioritizes animals, matters if we want a tool to work on both animals and tiles
function P.useToolDir(toolid, dir)
	if P.toolableAnimals ~= nil and P.toolableAnimals[dir][1] ~= nil and tools[toolid]~=nil then
		tools[toolid]:useToolAnimal(P.toolableAnimals[dir][1])
		return true
	end
	if P.toolableTiles ~= nil and P.toolableTiles[dir][1] ~= nil then
		if room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x] == nil then
			tools[toolid]:useToolNothing(P.toolableTiles[dir][1].y, P.toolableTiles[dir][1].x)
		else
			--sometimes next line has  error "attempt to index a nil value"
			if tools[toolid]~=nil and room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x]~=nil then
				tools[toolid]:useToolTile(room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x])
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
	if P.toolableTiles ~= nil then
		for dir = 1, 5 do
			for i = 1, #(P.toolableTiles[dir]) do
				if P.toolableTiles[dir][i].y == tileY and P.toolableTiles[dir][i].x == tileX then
					if room[tileY][tileX] == nil then
						tools[tool]:useToolNothing(tileY, tileX)
					else
						tools[tool]:useToolTile(room[tileY][tileX])
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
function P.tool:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
end

--returns a table of tables of coordinates by direction
function P.tool:getToolableTiles()
	local usableTiles = {}
	for dir = 1, 5 do
		usableTiles[dir] = {}
		local offset = util.getOffsetByDir(dir)
		for dist = 1, self.range do
			local tileToCheck = {y = player.tileY + offset.y*dist, x = player.tileX + offset.x*dist}
			if room[tileToCheck.y]~=nil then
				if (room[tileToCheck.y][tileToCheck.x] == nil and self:usableOnNothing())
					or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist)) then
					usableTiles[dir][#(usableTiles[dir])+1] = tileToCheck
				end
				if room[tileToCheck.y][tileToCheck.x] ~= nil and room[tileToCheck.y][tileToCheck.x].blocksProjectiles then
					break
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
			if room[tileToCheck.y]~=nil then
				if (room[tileToCheck.y][tileToCheck.x] == nil and self:usableOnNothing())
				or (room[tileToCheck.y][tileToCheck.x] ~= nil and self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist)) then
					if math.abs(tileToCheck.y-player.tileY)+math.abs(tileToCheck.x-player.tileX)<=self.range then
						usableTiles[dir][#(usableTiles[dir])+1] = tileToCheck
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
		if not animal.dead then
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
	end
	for dir = 1, 5 do
		usableAnimals[dir] = {}
		if closestAnimals[dir].dist <= self.range then
			local offset = util.getOffsetByDir(dir)
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
			if not isBlocked then
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
			usableAnimals[1][#usableAnimals[1]+1] = animals[animalIndex]
		end
	end
	return usableAnimals
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
P.wireCutters = P.tool:new{name = 'wire-cutters', image = love.graphics.newImage('Graphics/wirecutters.png')}
function P.wireCutters:usableOnTile(tile)
	return not tile.destroyed and (tile:instanceof(tiles.wire) or tile:instanceof(tiles.electricFloor))
end
P.waterBottle = P.tool:new{name = 'water-bottle', image = love.graphics.newImage('Graphics/waterbottle.png')}
function P.waterBottle:usableOnTile(tile)
	return not tile.destroyed and (tile:instanceof(tiles.powerSupply) or tile:instanceof(tiles.electricFloor))
end
function P.waterBottle:usableOnNothing()
	return true
end
function P.waterBottle:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	room[tileY][tileX] = tiles.electricFloor:new()
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
	return false
end
function P.brick:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	if tile:instanceof(tiles.glassWall) then
		tile:destroy()
	else
		tile:lockInState(true)
	end
end
P.gun = P.tool:new{name = 'gun', range = 3, image = love.graphics.newImage('Graphics/gun.png')}
function P.gun:usableOnAnimal(animal)
	return not animal.dead
end

P.electrifier = P.tool:new{name = 'electrifier', range = 1, image = love.graphics.newImage('Graphics/electrifier.png')}
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

P.delectrifier = P.tool:new{name = 'delectrifier', range = 1, image = love.graphics.newImage('Graphics/electrifier2.png')}
function P.delectrifier:usableOnTile(tile)
	if tile.canBePowered then return true end
	return false
end
function P.delectrifier:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.canBePowered = false
	if tile:instanceof(tiles.powerSupply) or tile:instanceof(tiles.notGate) or tile:instanceof(tiles.wire) then tile:destroy() end
end

P.charger = P.tool:new{name = 'charger', range = 1, image = love.graphics.newImage('Graphics/charger.png')}
function P.charger:usableOnTile(tile)
	if tile.canBePowered and not tile.charged then return true end
	return false
end
function P.charger:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.charged = true
end

P.visionChanger = P.tool:new{name = 'visionChanger', range = 1, image = love.graphics.newImage('Graphics/visionChanger.png')}
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

P.bomb = P.tool:new{name = "bomb", range = 1, image = love.graphics.newImage('Graphics/bomb.png')}
function P.bomb:useToolNothing(tileY, tileX)
	self.numHeld = self.numHeld - 1
	t = tiles.bomb:new()
	t.counter = 3
	room[tileY][tileX] = t
end
function P.bomb:usableOnNothing()
	return true
end

P.flame = P.tool:new{name = "flame", range = 1, image = love.graphics.newImage('Graphics/flame.png')}
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

P.unsticker = P.tool:new{name = "unsticker", range = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.unsticker:usableOnTile(tile)
	if tile:instanceof(tiles.stickyButton) and tile.down then return true end
	return false
end
function P.unsticker:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile:unstick()
end

P.crowbar = P.tool:new{name = "crowbar", range = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.crowbar:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) or tile:instanceof(tiles.hDoor) and not tile.stopped then return true end
	return false
end
function P.crowbar:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.open = true
	tile.stopped = true
end

P.doorstop = P.tool:new{name = "doorstop", range = 1, image = love.graphics.newImage('Graphics/unsticker.png')}
function P.doorstop:usableOnTile(tile)
	if tile:instanceof(tiles.vPoweredDoor) and (not tile.stopped) and (not tile.blocksMovement) then return true end
	return false
end
function P.doorstop:useToolTile(tile)
	self.numHeld = self.numHeld - 1
	tile.stopped = true
end

P.missile = P.tool:new{name = "missile", range = 10, image = love.graphics.newImage('Graphics/missile.png')}
function P.missile:usableOnTile(tile)
	return (tile:instanceof(tiles.wire) or tile:instanceof(tiles.electricFloor) or tile:instanceof(tiles.wall)) or tile:instanceof(tiles.powerSupply) and not tile.destroyed
end
function P.missile:usableOnAnimal(animal)
	return not animal.dead
end
P.missile.getToolableTiles = P.tool.getToolableTilesBox
P.missile.getToolableAnimals = P.tool.getToolableAnimalsBox

P.numNormalTools = 7

P[1] = P.saw
P[2] = P.ladder
P[3] = P.wireCutters
P[4] = P.waterBottle
P[5] = P.missile
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


return tools