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
	if P.toolableAnimals ~= nil and P.toolableAnimals[dir][1] ~= nil then
		tools[toolid]:useToolAnimal(P.toolableAnimals[dir][1])
		return true
	end
	if P.toolableTiles ~= nil and P.toolableTiles[dir][1] ~= nil then
		tools[toolid]:useToolTile(room[P.toolableTiles[dir][1].y][P.toolableTiles[dir][1].x])
		return true
	end
	return false
end

--prioritizes animals
function P.useToolTile(toolid, tileY, tileX)
	if P.toolableAnimals ~= nil then
		for dir = 1, 4 do
			for i = 1, #(P.toolableAnimals[dir]) do
				if P.toolableAnimals[dir][i].tileY == tileY and P.toolableAnimals[dir][i].tileX == tileX then
					tools[tool]:useToolAnimal(P.toolableAnimals[dir][i])
					return true
				end
			end
		end
	end
	if P.toolableTiles ~= nil then
		for dir = 1, 4 do
			for i = 1, #(P.toolableTiles[dir]) do
				if P.toolableTiles[dir][i].y == tileY and P.toolableTiles[dir][i].x == tileX then
					tools[tool]:useToolTile(room[tileY][tileX])
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
function P.tool:useToolTile(tile)
	log(tile.tileY)
	self.numHeld = self.numHeld - 1
	tile:destroy()
end
function P.tool:useToolAnimal(animal)
	self.numHeld = self.numHeld - 1
	animal:kill()
end

--returns a table of tables of coordinates by direction
function P.tool:getToolableTiles()
	local usableTiles = {}
	for dir = 1, 4 do
		usableTiles[dir] = {}
		local offset = util.getOffsetByDir(dir)
		for dist = 0, self.range do
			local tileToCheck = {y = player.tileY + offset.y*dist, x = player.tileX + offset.x*dist}
			if room[tileToCheck.y]~=nil and room[tileToCheck.y][tileToCheck.x] ~= nil then
				if self:usableOnTile(room[tileToCheck.y][tileToCheck.x], dist) then
					usableTiles[dir][#(usableTiles[dir])+1] = tileToCheck
				end
				if room[tileToCheck.y][tileToCheck.x].blocksProjectiles == true then
					break
				end
			end
		end
	end
	return usableTiles
end

--returns a table of tables of the animals themselves by direction
function P.tool:getToolableAnimals()
	local usableAnimals = {}
	local closestAnimals = {{dist = 1000}, {dist = 1000}, {dist = 1000}, {dist = 1000}}
	for animalIndex = 1, #animals do
		local animal = animals[animalIndex]
		if animal.tileY == player.tileY and animal.tileX == player.tileX and self:usableOnAnimal(animal) then
			usableAnimals[1] = {animal}
			for i = 2, 4 do usableAnimals[i] = usableAnimals[1] end
			return usableAnimals
		end
		if self:usableOnAnimal(animal) then
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
	for dir = 1, 4 do
		usableAnimals[dir] = {}
		if closestAnimals[dir].dist <= self.range then
			local offset = util.getOffsetByDir(dir)
			local isBlocked = false
			for dist = 0, closestAnimals[dir].dist do
				if room[player.tileY + offset.y*dist] ~= nil then
					local tile = room[player.tileY + offset.y*dist][player.tileX + offset.x*dist]
					if tile~=nil and tile.blocksProjectiles == true then
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
P.cuttingTorch = P.tool:new{name = 'cutting-torch', image = love.graphics.newImage('Graphics/cuttingtorch.png')}
function P.cuttingTorch:usableOnTile(tile)
	return false
end
P.brick = P.tool:new{name = 'brick', range = 3, image = love.graphics.newImage('Graphics/brick.png')}
function P.brick:usableOnTile(tile, dist)
	if not tile.bricked and tile:instanceof(tiles.button) and dist <= 1 then
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

P.specialToolA = P.tool:new{image = love.graphics.newImage('Graphics/saw.png')}
P.specialToolB = P.tool:new{image = love.graphics.newImage('Graphics/gun.png')}
P.specialToolC = P.tool:new{image = love.graphics.newImage('Graphics/cuttingtorch.png')}
P.specialToolD = P.tool:new{image = love.graphics.newImage('Graphics/brick.png')}
P.specialToolE = P.tool:new{image = love.graphics.newImage('Graphics/waterbottle.png')}

P.numNormalTools = 7

P[1] = P.saw
P[2] = P.ladder
P[3] = P.wireCutters
P[4] = P.waterBottle
P[5] = P.cuttingTorch
P[6] = P.brick
P[7] = P.gun
P[8] = P.electrifier
P[9] = P.visionChanger
P[10] = P.bomb
P[11] = P.specialToolD
P[12] = P.specialToolE

return tools