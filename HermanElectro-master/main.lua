roomHeight = 10
roomLength = 20

debug = true

require('scripts.tiles')
require('scripts.map')

wallSprite = {width = 78, height = 72, heightForHitbox = 62}
require('scripts.boundaries')
require('scripts.tools')


mapx=4
mapy=4
function love.load()
	black = love.graphics.newImage('electricfloor.png')
	mapHeight = 8
	map.loadRooms()
	mainMap = map.generateMap(mapHeight, 20, os.time())
	room = mainMap[mapy][mapx].room
	litTiles = {}
	for i = 1, roomHeight do
		litTiles[i] = {}
	end
	width, height = love.graphics.getDimensions()
	player = { x = 400, y = 400, prevx = 400, prevy = 400, width = 20, height = 20, speed = 250, sprite = love.graphics.newImage('herman_sketch.png'), scale = 0.3 }
	--image = love.graphics.newImage("cake.jpg")
	love.graphics.setNewFont(12)
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(255,255,255)
	f1 = love.graphics.newImage('concretewalls.png')
	walls = love.graphics.newImage('walls2.png')
	rocks = love.graphics.newImage('pen15.png')
	number1 = love.math.random()*-200
	number2 = love.math.random()*-200
	--print(love.graphics.getWidth(f1))
	scale = (width - 2*wallSprite.width)/(20 * 16)
	floor = tiles.tile
	function player:getTileLoc()
		return {x = self.x/(floor.sprite:getWidth()*scale), y = self.y/(floor.sprite:getWidth()*scale)}
	end
	updatePower()
end

function kill()
	player.x = 0
	player.y = 0
end

function updateLight()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			litTiles[i][j]=0
		end
	end
	xCorner = player.x
	yCorner = player.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	lightTest(tileLoc2, tileLoc1)
end

function updatePower()
	for i=1, roomHeight do
		for j=1, roomLength do
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name ~= "powerSupply" then
				room[i][j].powered = false
				room[i][j].poweredNeighbors = {0,0,0,0}
				if room[i][j].name == "notGate" then
					room[i][j].dirSend = {1,0,0,0}
				end
				room[i][j]:updateTile()
			end
		end 
	end
	for i=1, roomHeight do
		for j=1, roomLength do
			--power starts at power sources: powerSupply and notGate
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "powerSupply" then
				room[i][j].powered = true
			end
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "notGate" then
				room[i][j].powered = true
			end
		end
	end
	for i=1, roomHeight do
		for j=1, roomLength do
			--power starts at power sources: powerSupply and notGate
			if room[i]~=nil and room[i][j]~=nil and (room[i][j].name == "powerSupply" or room[i][j].name == "notGate") then
				room[i][j]:updateTile(0)
				powerTest(i,j,0)
			end
		end
	end
end

function lightTest(x, y)
	--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left
	if room[x] == nil or litTiles[x][y] == 1 then
		return
	end

	litTiles[x][y] = 1


	if x>1 then
		if room[x-1][y]==nil or room[x-1][y].blocksVision == false then
			lightTest(x-1,y,3)
		end
	end


	if x<roomHeight then
		if room[x+1][y]==nil or room[x+1][y].blocksVision == false then
			lightTest(x+1,y,1)
		end
	end

	if y>1 then
		if room[x][y-1]==nil or room[x][y-1].blocksVision == false then
			lightTest(x,y-1,2)
		end
	end

	if y<roomLength then
		if room[x][y+1]==nil or room[x][y+1].blocksVision == false then
			lightTest(x,y+1,4)
		end
	end
end

function powerTest(x, y, lastDir)
	--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left
	if room[x] == nil or room[x][y] == nil then
		return
	end


	if x>1 and room[x-1][y] ~=nil and canBePowered(x-1,y,3) and lastDir~=1 then
		formerPowered = room[x-1][y].powered
		formerSend = room[x-1][y].dirSend
		formerAccept = room[x-1][y].dirAccept
		--powered[x-1][y] = 1
		if room[x][y].dirSend[1]==1 and room[x][y].powered then
			room[x-1][y].poweredNeighbors[3] = 1
		else
			room[x-1][y].poweredNeighbors[3] = 0
		end
		room[x-1][y]:updateTile(3)
		if room[x-1][y].powered ~= formerPowered or room[x-1][y].dirSend ~= formerSend or room[x-1][y].dirAccept ~= formerAccept then
			powerTest(x-1,y,3)
		end
	end


	if x<roomHeight and room[x+1][y] ~=nil and canBePowered(x+1,y,1) and lastDir~=3 then
		--powered[x+1][y] = 1
		formerPowered = room[x+1][y].powered
		formerSend = room[x+1][y].dirSend
		formerAccept = room[x+1][y].dirAccept
		if room[x][y].dirSend[3]==1 and room[x][y].powered then
			room[x+1][y].poweredNeighbors[1] = 1
		else
			room[x+1][y].poweredNeighbors[1] = 0
		end
		room[x+1][y]:updateTile(1)
		if room[x+1][y].powered ~= formerPowered or room[x+1][y].dirSend ~= formerSend or room[x+1][y].dirAccept ~= formerAccept then
			powerTest(x+1,y,1)
		end
	end

	if y>1 and room[x][y-1] ~=nil and canBePowered(x,y-1,2) and lastDir~=4 then
		formerPowered = room[x][y-1].powered
		formerSend = room[x][y-1].dirSend
		formerAccept = room[x][y-1].dirAccept
		--powered[x][y-1] = 1
		if room[x][y].dirSend[4]==1 and room[x][y].powered then
			room[x][y-1].poweredNeighbors[2] = 1
		else
			room[x][y-1].poweredNeighbors[2] = 0
		end
		room[x][y-1]:updateTile(2)
		if room[x][y-1].powered ~= formerPowered or room[x][y-1].dirSend ~= formerSend or room[x][y-1].dirAccept ~= formerAccept then
			powerTest(x, y-1, 2)
		end
	end

	if y<roomLength and room[x][y+1] ~=nil and canBePowered(x,y+1,4) and lastDir~=2 then
		formerPowered = room[x][y+1].powered
		formerSend = room[x][y+1].dirSend
		formerAccept = room[x][y+1].dirAccept
		--powered[x][y+1] = 1
		if room[x][y].dirSend[2]==1 and room[x][y].powered then
			room[x][y+1].poweredNeighbors[4] = 1
		else
			room[x][y+1].poweredNeighbors[4] = 0
		end
		room[x][y+1]:updateTile(4)
		if room[x][y+1].powered ~= formerPowered or room[x][y+1].dirSend ~= formerSend or room[x][y+1].dirAccept ~= formerAccept then
			powerTest(x, y+1, 4)
		end
	end
end

--this function can be modified with a direction variable as argument,
--customized for each tile to allow for directional current movement
function canBePowered(x,y,dir)
	if room[x][y]~=nil and room[x][y].canBePowered and room[x][y].dirAccept[dir]==1 then
		return true
	end
	return false
end

function love.draw()
	love.graphics.draw(rocks, -mapx * width, -mapy * height, 0, 1, 1)
	for i = 1, (width-wallSprite.width*2)/(floor.sprite:getWidth()*scale) do
		for j = 1, (height-wallSprite.height*2)/(floor.sprite:getHeight()*scale) do
			if (room[j] ~= nil and room[j][i] ~= nil and room[j][i].name~="basicTile") or (room[j]~=nil and room[j][i]==nil) then
				if j <= table.getn(room) or i <= table.getn(room[0]) then
					if litTiles[j][i] == 0 then
						toDraw = black
					elseif room[j][i]~=nil and room[j][i].powered == false then
						toDraw = room[j][i].sprite
					elseif room[j][i]~=nil then
						toDraw = room[j][i].poweredSprite
					end
				end
				if room[j][i]~=nil or litTiles[j][i]==0 then
					love.graphics.draw(toDraw, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
				end
			end
		end
	end
	love.graphics.draw(walls, 0, 0, 0, width/walls:getWidth(), height/walls:getHeight())
	love.graphics.draw(player.sprite, player.x-player.sprite:getWidth()*player.scale/2, player.y-player.sprite:getHeight()*player.scale, 0, player.scale, player.scale)
	love.graphics.print(player:getTileLoc().x .. ":" .. player:getTileLoc().y, 0, 0);
	if toPrint ~= nil then
		love.graphics.print(toPrint, 0, 10)
	end
	for i = 0, mapHeight do
		for j = 0, mapHeight do
			if mainMap[i][j] == nil then
				love.graphics.setColor(255,255,255)
				love.graphics.rectangle("line", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			else
				if (i == mapy and j == mapx) then
					love.graphics.setColor(0,255,0)
				else
					love.graphics.setColor(255,255,255)
				end
				love.graphics.rectangle("fill", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			end
		end
	end
	for i = 0, 6 do
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle("fill", i*width/18, 0, width/18, width/18)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line", i*width/18, 0, width/18, width/18)
	end
	love.graphics.setColor(255,255,255)
end

function enterRoom(dir)
	if dir== 0 then
		if mapy>0 then
			if mainMap[mapy-1][mapx]~=nil then
				mapy = mapy-1
				room = mainMap[mapy][mapx].room
				player.y = height-wallSprite.heightForHitbox-5
			end
		end
	elseif dir == 1 then
		if mapx<mapHeight then
			if mainMap[mapy][mapx+1]~=nil then
				mapx = mapx+1
				room = mainMap[mapy][mapx].room
				player.x = wallSprite.width+5
			end
		end
	elseif dir == 2 then
		if mapy<mapHeight then
			if mainMap[mapy+1][mapx]~=nil then
				mapy = mapy+1
				room = mainMap[mapy][mapx].room
				player.y = wallSprite.heightForHitbox+player.height+5
			end
		end
	elseif dir == 3 then
		if mapx>0 then
			if mainMap[mapy][mapx-1]~=nil then
				mapx = mapx-1
				room = mainMap[mapy][mapx].room
				player.x = width-wallSprite.width-player.width-5
			end
		end
	end
	updatePower()
	updateLight()
end

oldTilesOn = {}

function checkBoundaries()
--tile locations: (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, starts at (0,0)
--hitbox: bottom left (player.x, player.y), height player.height, width player.width
	toPrint = ""
	tilesOn = {}
	tileLocs = {}
	xCorner = player.x
	yCorner = player.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~= nil then
		tilesOn[1] = room[tileLoc2][tileLoc1]
		tileLocs[1] = {x=tileLoc1, y=tileLoc2}
	end

	xCorner = player.x+player.width
	yCorner = player.y-player.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~= nil then
		tilesOn[2] = room[tileLoc2][tileLoc1]
		tileLocs[2] = {x=tileLoc1, y=tileLoc2}
	end
	

	xCorner = player.x
	yCorner = player.y-player.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~= nil then
		tilesOn[3] = room[tileLoc2][tileLoc1]
		tileLocs[3] = {x=tileLoc1, y=tileLoc2}
	end

	xCorner = player.x+player.width
	yCorner = player.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if room[tileLoc2] ~= nil then
		tilesOn[4] = room[tileLoc2][tileLoc1]
		tileLocs[4] = {x=tileLoc1, y=tileLoc2}
	end

	for j = 1, 4 do
		local isOnNow = false
		for i = 1, 4 do
			if tilesOn[i] == oldTilesOn[j] then
				isOnNow = true
			end
		end
		if oldTilesOn[j] ~= nil and not isOnNow then
			oldTilesOn[j]:onLeave(player)
		end
	end
	for i = 1, 4 do
		local t = tilesOn[i]
		for j = 1, i-1 do
			if tilesOn[i] == tilesOn[j] then
				tilesOn[i] = nil
				t = nil
			end
		end
		if t ~= nil then
			local isOnStay  = false
			for j = 1, 4 do
				if oldTilesOn[j] == t then
					isOnStay = true
				end
			end
			if isOnStay then
				t:onStay(player, tileLocs[i])
			else
				t:onEnter(player, tileLocs[i])
			end
		end

	end
	for i = 1, 4 do
		oldTilesOn[i] = tilesOn[i]
	end
end

function love.update(dt)
	if love.keyboard.isDown("up") then 
		if player.y == wallSprite.heightForHitbox+player.height and player.x < width/2+20 and player.x > width/2-40 then
			enterRoom(0)
		end
		player.y = player.y - player.speed * dt
	end
	if love.keyboard.isDown("down") then 
		if player.y == height - wallSprite.heightForHitbox and player.x < width/2+20 and player.x > width/2-40 then
			enterRoom(2)
		end
		player.y = player.y + player.speed * dt
	end
	if player.y < wallSprite.heightForHitbox+player.height then
		player.y = wallSprite.heightForHitbox+player.height
	end
	if player.y > height-wallSprite.heightForHitbox then
		player.y = height-wallSprite.heightForHitbox
	end
	checkBoundaries()
	player.prevy = player.y
	if love.keyboard.isDown("left") then 
		if player.x == wallSprite.width and player.y < height/2+50 and player.y > height/2-20 then
			enterRoom(3)
		end
		player.x = player.x - player.speed * dt
		
	end
	if love.keyboard.isDown("right") then 
		if player.x == width-wallSprite.width-player.width and player.y < height/2+50 and player.y > height/2-20 then
			enterRoom(1)
		end
		player.x = player.x + player.speed * dt
	end
	if player.x < 0 then
		player.x = 0
	end
	if player.x < wallSprite.width then
		player.x = wallSprite.width
	end
	if player.x > width-wallSprite.width-player.width then
		player.x = width-wallSprite.width-player.width
	end
	checkBoundaries()
	player.prevx = player.x
end