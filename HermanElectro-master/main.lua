roomHeight = 12
roomLength = 24
screenScale = 70

debug = true
loadTutorial = false

util = require('scripts.util')
tiles = require('scripts.tiles')
map = require('scripts.map')

boundaries = require('scripts.boundaries')
--require('scripts.tools')
animalList = require('scripts.animals')
tools = require('scripts.tools')
editor = require('scripts.editor')

loadedOnce = false


function love.load()
	typingCallback = nil
	debugText = nil
	tempAdd = 1
	editorMode = false
	editorAdd = 0

	--[[local json = require('scripts.dkjson')
	io.input('RoomData/finalrooms.json')
	local roomsToFix
	local str = io.read('*all')
	local obj, pos, err = json.decode(str, 1, nil)
	if err then
		print('Error:', err)
	else
		roomsToFix = obj.rooms
	end
	local outputPrint = {rooms = {}}
	local outputFixed = outputPrint.rooms
	local keyOrder = {}
	local i=1
	while roomsToFix[i] ~= nil do
		keyOrder[#keyOrder + 1] = roomsToFix[i].id
		outputFixed[roomsToFix[i].id] = {layout = roomsToFix[i].layout, itemsNeeded = roomsToFix[i].itemsNeeded}
		i = i+1
	end
	local state = {indent = true, keyorder = keyOrder}
	print(json.encode(outputPrint, state))
	game.crash()]]

	level = 0
	loadNextLevel()
	--1=saw
	--toolMode = 1
	tool = 0
	for i = 1, #tools do
		tools[i].numHeld = 0
	end
	specialTools = {0,0,0}
	animals = {}
	--width = 16*screenScale
	--height = 9*screenScale
	--wallSprite = {width = 78*screenScale/50, height = 72*screenScale/50, heightForHitbox = 62*screenScale/50}
	wallSprite = {width = 187*width/1920, height = 170*height/1080, heightBottom = 150*height/1080}
	--image = love.graphics.newImage("cake.jpg")
	love.graphics.setNewFont(12)
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(255,255,255)
	if not loadedOnce then
		mouseDown = 0
		f1 = love.graphics.newImage('Graphics/concretewalls.png')
		walls = love.graphics.newImage('Graphics/walls3.png')
		rocks = love.graphics.newImage('Graphics/pen16.png')
		rocksQuad = love.graphics.newQuad(mapy*14*screenScale,mapx*8*screenScale, width, height, rocks:getWidth(), rocks:getHeight())
		black = love.graphics.newImage('Graphics/dark.png')
		green = love.graphics.newImage('Graphics/green.png')
		gray = love.graphics.newImage('Graphics/gray.png')
		floortile = love.graphics.newImage('Graphics/cavesfloor.png')
		doorwaybg = love.graphics.newImage('Graphics/doorwaybackground.png')
		deathscreen = love.graphics.newImage('Graphics/deathscreen.png')
		width2, height2 = love.graphics.getDimensions()
		if width2>height2*16/9 then
			height = height2
			width = height2*16/9
		else
			width = width2
			height = width2*9/16
		end
		loadedOnce = true
	end
	number1 = love.math.random()*-200
	number2 = love.math.random()*-200
	--print(love.graphics.getWidth(f1))
	scale = (width - 2*wallSprite.width)/(20.3 * 16)*5/6
	floor = tiles.tile
	player = { dead = false, tileX = 1, tileY = 6, x = (1-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10, 
		y = (6-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10, prevTileX = 3, prevTileY = 10,
		prevx = (3-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10,
		prevy = (10-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10,
		width = 20, height = 20, speed = 250, sprite = love.graphics.newImage('Graphics/herman_sketch.png'), scale = 0.25 * width/1200}
	if loadTutorial then
		player.enterX = player.tileX
		player.enterY = player.tileY
		player.totalItemsGiven = {0,0,0,0,0,0,0}
		player.totalItemsNeeded = {0,0,0,0,0,0,0}
	end
	function player:getTileLoc()
		return {x = self.x/(floor.sprite:getWidth()*scale), y = self.y/(floor.sprite:getWidth()*scale)}
	end
	enterRoom(-1)
end

function loadNextLevel()
	level = level+1

	local roomsPath = 'RoomData/rooms.json'
	local treasureRoomsPath = 'RoomData/treasurerooms.json'
	local finalRoomsPath = 'RoomData/finalrooms.json'
	if loadTutorial then
		roomsPath = 'RoomData/tut_rooms.json'
	end
	map.loadRooms(roomsPath)
	map.loadTreasureRooms(treasureRoomsPath)
	map.loadFinalRooms(finalRoomsPath)
	if loadTutorial then
		mainMap = map.generateTutorial()
	else
		mainMap = map.generateMap(8, level+2, os.time())
	end
	mapHeight = mainMap.height
	mapx = mainMap.initialX
	mapy = mainMap.initialY
	visibleMap = {}
	for i = 0, mapHeight do
		visibleMap[i] = {}
		for j = 0, mapHeight do
			visibleMap[i][j] = 0
		end
	end

	visibleMap[mapy][mapx] = 1
	room = mainMap[mapy][mapx].room
	prevRoom = room
	litTiles = {}
	for i = 1, roomHeight do
		litTiles[i] = {}
	end
	completedRooms = {}
	for i=0, mapHeight do
		completedRooms[i] = {}
		for j=1, mapHeight do
			if mainMap[i][j]==nil then
				completedRooms[i][j]=-1
			else
				completedRooms[i][j]=0
			end
		end
	end
end

function kill()
	--player.x = 0
	--player.y = 0
	player.dead = true
end

function updateLight()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			litTiles[i][j]=0
		end
	end
	xCorner = player.x+player.width/2
	yCorner = player.y-player.height/2
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if tileLoc2>roomHeight then
		tileLoc2 = roomHeight
	end
	if tileLoc1>roomLength then
		tileLoc1 = roomLength
	end
	if tileLoc1<1 then
		tileLoc1=1
	end
	if tileLoc2<1 then
		tileLoc2=1
	end
	lightTest(tileLoc2, tileLoc1)
	for i=1,roomHeight do
		for j=1,roomLength do
			--checkLight(i,j, tileLoc2, tileLoc1)
		end
	end
end

function checkLight(i, j, x, y)
	vx = i-x
	vy = j-y
	ox = x
	oy = y
	length = math.sqrt(vx*vx+vy*vy)
	vx = vx/(length*2)
	vy = vy/(length*2)
	for inc = 0, length*2 do
		xcoord = math.floor(ox)
		ycoord = math.floor(oy)
		if room[xcoord]~=nil and room[xcoord][ycoord]~=nil and room[xcoord][ycoord].blocksVision and not (xcoord==i and ycoord ==j) then
			return
		end
		ox=ox+vx
		oy=oy+vy
	end
	litTiles[i][j]=1
end

function updatePower()
	powerCount = 0

	for i=1, roomHeight do
		for j=1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				room[i][j].formerPowered = room[i][j].powered
				room[i][j].powered = false
				room[i][j].poweredNeighbors = {0,0,0,0}
			end
		end 
	end
	for i=1, roomHeight do
		for j=1, roomLength do
			--power starts at power sources: powerSupply and notGate
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "powerSupply" and not room[i][j].destroyed then
				room[i][j].powered = true
			end
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "notGate" and not room[i][j].destroyed then
				--room[i][j].powered = true
			end
			if room[i][j]~=nil and room[i][j].charged and not room[i][j].destroyed then
				room[i][j].powered = true
			end
		end
	end
	for i=1, roomHeight do
		for j=1, roomLength do
			--power starts at power sources: powerSupply and notGate
			if room[i]~=nil and room[i][j]~=nil and (room[i][j].charged or room[i][j].name == "powerSupply" or room[i][j].name == "notGate") then
				room[i][j]:updateTile(0)
				powerTest(i,j,0)
			end
		end
	end

	--fixing weird not-gate bug
	for k = 1, 10 do
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil and not (room[i][j].name == "powerSupply" or room[i][j].name == "notGate") and not room[i][j].charged then
					room[i][j].poweredNeighbors = {0,0,0,0}
					room[i][j].powered = false
					room[i][j]:updateTile(0)
				end
			end
		end
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil then
					if (room[i][j].name == "powerSupply" or room[i][j].name == "notGate" or room[i][j].charged) and room[i][j].powered then
						powerTestSpecial(i,j,0)
					end
				end
			end
		end
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "notGate" then
					local offset = room[i][j]:getCorrectedOffset(3)
					if room[i+offset.y]~=nil and room[i+offset.y][j+offset.x]~=nil and room[i+offset.y][j+offset.x].powered==false then
						room[i][j].poweredNeighbors[room[i][j]:cfr(3)]=0
						room[i][j]:updateTile(0)
					elseif room[i+offset.y]~=nil and room[i+offset.y][j+offset.x]~=nil
					  and room[i+offset.y][j+offset.x].powered==true
					  and room[i+offset.y][j+offset.x].dirSend[room[i][j]:cfr(1)]==1 then
						room[i][j].poweredNeighbors[room[i][j]:cfr(3)]=1
						room[i][j]:updateTile(0)
					end
				end
			end
		end
	end
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				room[i][j]:postPowerUpdate()
			end
		end
	end
	--if room[player.tileY][player.tileX]~=nil then
		--t = room[player.tileY][player.tileX]
		--if t.name == "electricfloor" and t.powered then
		--	kill()
		--elseif t.name == "poweredFloor" and not t.powered then
		--	kill()
		--end
	--end
end

function lightTest(x, y)
	--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left
	if room[x] == nil or litTiles[x][y] == 1 then
		return
	end

	litTiles[x][y] = 1


	if x>1 then
		if room[x-1][y]~=nil and room[x-1][y].blocksVision then
			litTiles[x-1][y] = 1
		else
			lightTest(x-1,y,3)
		end
	end


	if x<roomHeight then
		if room[x+1][y]~=nil and room[x+1][y].blocksVision then
			litTiles[x+1][y] = 1
		else
			lightTest(x+1,y,1)
		end
	end

	if y>1 then
		if room[x][y-1]~=nil and room[x][y-1].blocksVision then
			litTiles[x][y-1] = 1
		else
			lightTest(x, y-1,2)
		end
	end

	if y<roomLength then
		if room[x][y+1]~=nil and room[x][y+1].blocksVision then
			litTiles[x][y+1] = 1
		else
			lightTest(x, y+1,4)
		end
	end
end

function powerTest(x, y, lastDir)
	powerCount = powerCount+1
	if powerCount>1000 then
		kill()
		return
	end
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

function powerTestSpecial(x, y, lastDir)
--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left
	if room[x] == nil or room[x][y] == nil then
		return
	end

	if x>1 and room[x-1][y] ~=nil and room[x-1][y].name~="notGate" and canBePowered(x-1,y,3) and lastDir~=1 then
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
			powerTestSpecial(x-1,y,3)
		end
	end


	if x<roomHeight and room[x+1][y] ~=nil and room[x+1][y].name~="notGate" and canBePowered(x+1,y,1) and lastDir~=3 then
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
			powerTestSpecial(x+1,y,1)
		end
	end

	if y>1 and room[x][y-1] ~=nil and room[x][y-1].name~="notGate" and canBePowered(x,y-1,2) and lastDir~=4 then
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
			powerTestSpecial(x, y-1, 2)
		end
	end

	if y<roomLength and room[x][y+1] ~=nil and room[x][y+1].name~="notGate" and canBePowered(x,y+1,4) and lastDir~=2 then
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
			powerTestSpecial(x, y+1, 4)
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
	love.graphics.setBackgroundColor(0,0,0)
	--love.graphics.translate(width2/2-16*screenScale/2, height2/2-9*screenScale/2)
	love.graphics.translate((width2-width)/2, (height2-height)/2)
	love.graphics.draw(rocks, rocksQuad, 0, 0)
	--love.graphics.draw(rocks, -mapx * width, -mapy * height, 0, 1, 1)
	for i = 1, roomLength do
		for j = 1, roomHeight do
			if (room[j] ~= nil and room[j][i] ~= nil and room[j][i].isVisible) or (room[j]~=nil and room[j][i]==nil) then
				local rot = 0
				local tempi = i
				local tempj = j
				if j <= table.getn(room) or i <= table.getn(room[0]) then
					if litTiles[j][i] == 0 then
						toDraw = black
					elseif room[j][i]~=nil and room[j][i].powered == false then
						toDraw = room[j][i].sprite
						rot = room[j][i].rotation
					elseif room[j][i]~=nil then
						toDraw = room[j][i].poweredSprite
						rot = room[j][i].rotation
					--else
						--toDraw = floortile
					end
					if rot == 1 or rot == 2 then
						tempi = tempi + 1
					end
					if rot == 2 or rot == 3 then
						tempj = tempj + 1
					end
				end
				if (room[j][i]~=nil --[[and room[j][i].name~="pitbull" and room[j][i].name~="cat" and room[j][i].name~="pup"]]) or litTiles[j][i]==0 then
					love.graphics.draw(toDraw, (tempi-1)*floor.sprite:getWidth()*scale+wallSprite.width, (tempj-1)*floor.sprite:getHeight()*scale+wallSprite.height, rot * math.pi / 2, scale, scale)
				end
			end
		end
	end
	if tools.toolableAnimals~=nil then
		for dir = 1, 5 do
			if tools.toolableAnimals[dir]~=nil then
				for i = 1, #(tools.toolableAnimals[dir]) do
					local tx = tools.toolableAnimals[dir][i].tileX
					local ty = tools.toolableAnimals[dir][i].tileY
					if dir == 1 or tools.toolableAnimals[1][1] == nil or not (tx == tools.toolableAnimals[1][1].tileX and ty == tools.toolableAnimals[1][1].tileY) then
						love.graphics.draw(green, (tx-1)*floor.sprite:getWidth()*scale+wallSprite.width, (ty-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
					end
				end
			end
		end
	end
	if tools.toolableTiles~=nil then
		for dir = 1, 5 do
			for i = 1, #(tools.toolableTiles[dir]) do
				local tx = tools.toolableTiles[dir][i].x
				local ty = tools.toolableTiles[dir][i].y
				if dir == 1 or tools.toolableTiles[1][1] == nil or not (tx == tools.toolableTiles[1][1].x and ty == tools.toolableTiles[1][1].y) then
					love.graphics.draw(green, (tx-1)*floor.sprite:getWidth()*scale+wallSprite.width, (ty-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
				end
			end
		end
	end
	
	if mapy<=0 or mainMap[mapy-1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy-1][mapx]==0) then
		love.graphics.draw(doorwaybg, width/2-150, 0, 0, scale, scale*0.42)
	end
	if mapx>=mapHeight or mainMap[mapy][mapx+1]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx+1]==0) then
		love.graphics.draw(doorwaybg, width-wallSprite.width-9, height/2-150, 0, scale*0.42, scale)
	end
	if mapy>=mapHeight or mainMap[mapy+1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy+1][mapx]==0) then
		love.graphics.draw(doorwaybg, width/2-150, height-scale*0.42*doorwaybg:getHeight()+11, 0, scale, scale*0.36)
	end		
	if mapx<=0 or mainMap[mapy][mapx-1]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx-1]==0) then
		love.graphics.draw(doorwaybg, 2, height/2-150, 0, scale*0.45, scale)
	end
	love.graphics.draw(walls, 0, 0, 0, width/walls:getWidth(), height/walls:getHeight())
	for i = 1, 100 do
		if animals[i]~=nil then
		end
		if animals[i]~=nil and litTiles[animals[i].tileY][animals[i].tileX]==1 then
			love.graphics.draw(animals[i].sprite, animals[i].x, animals[i].y, 0, scale, scale)
		end
	end
	love.graphics.draw(player.sprite, player.x-player.sprite:getWidth()*player.scale/2, player.y-player.sprite:getHeight()*player.scale, 0, player.scale, player.scale)
	love.graphics.print(player:getTileLoc().x .. ":" .. player:getTileLoc().y, 0, 0);
	for i = 0, mapHeight do
		for j = 0, mapHeight do
			if visibleMap[i][j] == 1 then
				if mainMap[i][j]==nil then
					love.graphics.setColor(0, 0, 0)
				else
					currentid = tostring(mainMap[i][j].roomid)
					if (i == mapy and j == mapx) then
						love.graphics.setColor(0,255,0)
					elseif completedRooms[i][j]==1 then
						love.graphics.setColor(255,255,255)
						if map.getRoomType(currentid)=="treasure" then
							love.graphics.setColor(250, 250, 0)
						elseif map.getRoomType(currentid)=="final" then
							love.graphics.setColor(200, 0, 200)
						end
					else
						love.graphics.setColor(100,100,100)
					end
				end
				love.graphics.rectangle("fill", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			else
				--love.graphics.setColor(255,255,255)
				--love.graphics.rectangle("line", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			end
		end
	end
	for i = 0, 6 do
		love.graphics.setColor(255,255,255)
		if tool == i+1 then
			love.graphics.setColor(50, 200, 50)
		end
		love.graphics.rectangle("fill", i*width/18, 0, width/18, width/18)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line", i*width/18, 0, width/18, width/18)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(tools[i+1].image, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		if tools[i+1].numHeld==0 then
			love.graphics.draw(gray, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		end
		love.graphics.setColor(0,0,0)
		love.graphics.print(tools[i+1].numHeld, i*width/18+3, 0)
	end
	for i = 0, 2 do
		love.graphics.setColor(255,255,255)
		if tool == specialTools[i+1] and tool~=0 then
			love.graphics.setColor(50, 200, 50)
		end
		love.graphics.rectangle("fill", (i+13)*width/18, 0, width/18, width/18)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line", (i+13)*width/18, 0, width/18, width/18)
		love.graphics.setColor(255,255,255)
		if specialTools~=nil and specialTools[i+1]~=0 then
			love.graphics.draw(tools[specialTools[i+1]].image, (i+13)*width/18, 0, 0, (width/18)/32, (width/18)/32)
		end
		if specialTools[i+1]==0 then
			love.graphics.draw(gray, (i+13)*width/18, 0, 0, (width/18)/32, (width/18)/32)
		end
		love.graphics.setColor(0,0,0)
		if specialTools[i+1]~=0 then
			love.graphics.print(tools[specialTools[i+1]].numHeld, (i+13)*width/18+3, 0)
		end
	end
	love.graphics.setColor(255,255,255)
	if player.dead then
		love.graphics.draw(deathscreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
	end
	if not editorMode then
		botText = "e to toggle editor mode"
	else
		botText = "e to toggle editor mode, r to clear screen, p to print matrix of room, click to select/place tiles below"
	end
	barLength = 200
	if editorMode then
		editor.draw()
	end
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 5, height-width/30-20, barLength, 15)
	love.graphics.setColor(255,255,255)
	love.graphics.print(botText, 10, height-width/30-20)
	if debugText ~= nil then
		love.graphics.setColor(0,255,0,255)
		love.graphics.print(debugText, 0, 100)
		love.graphics.setColor(255,255,255,255)
	end
end

function log(text)
	debugText = text
end

function adjacent(xloc, yloc)
	xCorner = player.x
	yCorner = player.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if math.abs(tileLoc1-xloc)+math.abs(tileLoc2-yloc)<=1 then
		return true
	end

	xCorner = player.x+player.width
	yCorner = player.y-player.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if math.abs(tileLoc1-xloc)+math.abs(tileLoc2-yloc)<=1 then
		return true
	end
	

	xCorner = player.x
	yCorner = player.y-player.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if math.abs(tileLoc1-xloc)+math.abs(tileLoc2-yloc)<=1 then
		return true
	end

	xCorner = player.x+player.width
	yCorner = player.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if math.abs(tileLoc1-xloc)+math.abs(tileLoc2-yloc)<=1 then
		return true
	end
	return false
end

function hackEnterRoom(roomid, y, x)
	if y == nil then y = mapy end
	if x == nil then x = mapx end
	local loadedRoom = map.createRoom(roomid)
	if loadedRoom == nil then
		return false
	end
	mainMap[y][x] = {roomid = roomid, room = loadedRoom, 
		isFinal = mainMap[y][x].isFinal, isInitial = mainMap[y][x].isInitial,
		isCompleted = mainMap[y][x].isCompleted}
	if y == mapy and x == mapx then
		room = mainMap[y][x].room
	end
	animalCounter = 1
	animals = {}
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name~=nil and (room[i][j].animal~=nil) then
				animalToSpawn = room[i][j].animal
				if not animalToSpawn.dead then
					animals[animalCounter] = animalToSpawn
					animals[animalCounter].y = (i-1)*floor.sprite:getWidth()*scale+wallSprite.height
					animals[animalCounter].x = (j-1)*floor.sprite:getHeight()*scale+wallSprite.width
					animals[animalCounter].tileX = j
					animals[animalCounter].tileY = i
					animalCounter=animalCounter+1
				end
			end
		end
	end
	updateGameState()
	return true
end

function enterRoom(dir)
	prevMapX = mapx
	prevMapY = mapy
	if dir == 0 then
		if mapy>0 and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy-1][mapx]==0) then
			if mainMap[mapy-1][mapx]~=nil then
				mapy = mapy-1
				room = mainMap[mapy][mapx].room
				--player.y = height-wallSprite.heightBottom-5
				player.y = (roomHeight-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
				player.tileY = roomHeight
				player.prevy = player.y
				player.prevTileY = player.tileY
				player.prevx = player.x
				player.prevTileX = player.tileX
			end
		end
	elseif dir == 1 then
		if mapx<mapHeight and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx+1]==0)then
			if mainMap[mapy][mapx+1]~=nil then
				mapx = mapx+1
				room = mainMap[mapy][mapx].room
				--player.x = wallSprite.width+5
				player.x = (1-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10
				player.tileX = 1
				player.prevx = player.x
				player.prevTileX = player.tileX
			end
		end
	elseif dir == 2 then
		if mapy<mapHeight and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy+1][mapx]==0) then
			if mainMap[mapy+1][mapx]~=nil then
				mapy = mapy+1
				room = mainMap[mapy][mapx].room
				--player.y = wallSprite.height+player.height+5
				player.y = (1-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
				player.tileY = 1
				player.prevy = player.y
				player.prevTileY = player.tileY
			end
		end
	elseif dir == 3 then
		if mapx>0 and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx-1]==0) then
			if mainMap[mapy][mapx-1]~=nil then
				mapx = mapx-1
				room = mainMap[mapy][mapx].room
				--player.x = width-wallSprite.width-player.width-5
				player.x = (roomLength-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10
				player.tileX = roomLength
				player.prevx = player.x
				player.prevTileX = player.tileX
			end
		end
	end
	currentid = tostring(mainMap[mapy][mapx].roomid)
	if map.getRoomType(currentid)=="treasure" or map.getRoomType(currentid)=="final" then completedRooms[mapy][mapx] = 1 end
	if loadTutorial then
		player.enterX = player.tileX
		player.enterY = player.tileY
	end

	rocksQuad = love.graphics.newQuad(mapy*14*screenScale,mapx*8*screenScale, width, height, rocks:getWidth(), rocks:getHeight())
	if (prevMapX~=mapx or prevMapY~=mapy) or dir == -1 then
		animalCounter = 1
		animals = {}
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil and room[i][j].name~=nil and (room[i][j].animal~=nil) then
					animalToSpawn = room[i][j].animal
					if not animalToSpawn.dead then
						animals[animalCounter] = animalToSpawn
						animals[animalCounter].y = (i-1)*floor.sprite:getWidth()*scale+wallSprite.height
						animals[animalCounter].x = (j-1)*floor.sprite:getHeight()*scale+wallSprite.width
						animals[animalCounter].tileX = j
						animals[animalCounter].tileY = i
						animalCounter=animalCounter+1
					end
				end
			end
		end
	end
	visibleMap[mapy][mapx] = 1
	updateGameState()
	
end

oldTilesOn = {}

function checkBoundaries()
--tile locations: (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, starts at (0,0)
--hitbox: bottom left (player.x, player.y), height player.height, width player.width
	tilesOn = {}
	tileLocs = {}
	xCorner = player.x
	yCorner = player.y
	--xCorner = player.x+player.width/2
	--yCorner = player.y-player.height/2
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
	--tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*floor.sprite:getWidth()))
	--tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*floor.sprite:getHeight()))
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
	for i = 1, 1 do
		local t = tilesOn[i]
		for j = 1, i-1 do
			if tilesOn[i] == tilesOn[j] then
				tilesOn[i] = nil
				t = nil
			end
		end
		if t ~= nil then
			local isOnStay  = false
			for j = 1, 1 do
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
	if tilesOn[1]~=nil then
		--print(tilesOn[1].name..tilesOn[2]..tilesOn[3]..tilesOn[4])
	end
end
keyTimer = {base = .05, timeLeft = .05}
function love.update(dt)
	keyTimer.timeLeft = keyTimer.timeLeft - dt
end

function love.textinput(text)
	editor.textinput(text)
end

function love.keypressed(key, unicode)
	if editor.stealInput then
		editor.inputSteal(key, unicode)
		return
	end
	if key=="e" then
		editorMode = not editorMode
	end
	--[[if key=='t' then
		if toolMode == 1 then
			toolMode = 2
		else
			toolMode = 1
		end
	end]]
	if editorMode then
		editor.keypressed(key, unicode)
	else
		if key == 'r' then
			if loadTutorial then
				player.dead = false
				player.y = (player.enterY-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
				player.tileY = player.enterY
				player.x = (player.enterX-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10
				player.tileX = player.enterX
				player.prevy = player.y
				player.prevTileY = player.enterY
				player.prevx = player.x
				player.prevTileX = player.enterX
				for i = 1,#tools do
					if (completedRooms[mapy][mapx] == 1) then
						player.totalItemsGiven[i] = player.totalItemsGiven[i] - map.getItemsGiven(mainMap[mapy][mapx].roomid)[1][i]
						player.totalItemsNeeded[i] = player.totalItemsNeeded[i] - map.getItemsNeeded(mainMap[mapy][mapx].roomid)[1][i]
					end
					tools[i].numHeld = player.totalItemsGiven[i] - player.totalItemsNeeded[i]
					if tools[i].numHeld < 0 then tools[i].numHeld = 0 end
				end
				completedRooms[mapy][mapx] = 0
				for i = 0, mainMap.height do
					for j = 0, mainMap.height do
						if completedRooms[i][j] == 0 then
							hackEnterRoom(mainMap[i][j].roomid, i, j)
						end
					end
				end
			else
				love.load()
			end
		end
	end
	beforePressX = player.x
	beforePressY = player.y
	love.keyboard.setKeyRepeat(true)
    -- ignore non-printable characters (see http://www.ascii-code.com/)
    if player.dead and (key == "w" or key == "a" or key == "s" or key == "d") then
    	return
    end

	if keyTimer.timeLeft > 0 then
		return
	end
	keyTimer.timeLeft = keyTimer.base
    -- ignore non-printable characters (see http://www.ascii-code.com/)
    if key == "w" then
    	if player.tileY>1 then
    		player.prevx = player.x
    		player.prevy = player.y
    		player.prevTileX = player.tileX
    		player.prevTileY = player.tileY
    		player.tileY = player.tileY-1
    		player.y = player.y-floor.sprite:getHeight()*scale
		elseif player.tileY==1 and player.x+player.width/2 < width/2+40 and player.x+player.width/2 > width/2-110 then
			enterRoom(0)
		end
    elseif key == "s" then
    	if player.tileY<roomHeight then
    		player.prevx = player.x
    		player.prevy = player.y
    		player.prevTileX = player.tileX
    		player.prevTileY = player.tileY
    		player.tileY = player.tileY+1
    		player.y = player.y+floor.sprite:getHeight()*scale
		elseif player.tileY == roomHeight and player.x < width/2+40 and player.x > width/2-110 then
			enterRoom(2)
    	end
    elseif key == "a" then
    	if player.tileX>1 then
    		player.prevx = player.x
    		player.prevy = player.y
    		player.prevTileX = player.tileX
    		player.prevTileY = player.tileY
    		player.tileX = player.tileX-1
    		player.x = player.x-floor.sprite:getHeight()*scale
		elseif player.tileX == 1 and player.y < height/2+50 and player.y > height/2-20 then
			enterRoom(3)
    	end
    elseif key == "d" then
    	if player.tileX<roomLength then
    		player.prevx = player.x
    		player.prevy = player.y
    		player.prevTileX = player.tileX
    		player.prevTileY = player.tileY
    		player.tileX = player.tileX+1
    		player.x = player.x+floor.sprite:getHeight()*scale
    	elseif player.tileX == roomLength and player.y < height/2+50 and player.y > height/2-20 then
				enterRoom(1)
		end
	elseif key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" then
		numPressed = tonumber(key)
		if numPressed == 0 then numPressed = 10 end
		if tools[numPressed].numHeld>0 and numPressed<=tools.numNormalTools then
			tool = numPressed
		elseif numPressed>tools.numNormalTools then
			tool = specialTools[numPressed-7]
		end
		tools.updateToolableTiles(tool)
    end
    local tileLocXDelta = 0
    local tileLocYDelta = 0
    local dirUse = 0
    if key == 'up' then dirUse = 1
    elseif key == 'right' then dirUse = 2
    elseif key == 'down' then dirUse = 3
    elseif key == 'left' then dirUse = 4
    elseif key == "space" then dirUse = 5 end
    if dirUse ~= 0 then
		log((tools.useToolDir(tool, dirUse) and 'true' or 'false')..' '..tool..' '..dirUse)
		updateGameState()
	end
    if (key=="w" or key=="a" or key=="s" or key=="d") then
    	for i = 1, roomHeight do
    		for j = 1, roomLength do
    			if room[i][j]~=nil and room[i][j].name == "button" then
    				room[i][j].justPressed = false
    			end
    		end
    	end
    	checkBoundaries()
	    if beforePressY~=player.y or beforePressX~=player.x then
	   		stepTrigger()
	    	updateGameState()
	    	for i = 1, animalCounter-1 do
	    		if animals[i].name == "pitbull" and not animals[i].dead and (litTiles[animals[i].tileY][animals[i].tileX]==1 or animals[i].triggered) then
	    			--animalMove(i)
	    			animals[i]:move(player.tileX, player.tileY, room)
	    		end
	    	end
	    	  for i = 1, animalCounter-1 do
	    		if animals[i].name == "pup"  and not animals[i].dead and (litTiles[animals[i].tileY][animals[i].tileX]==1 or animals[i].triggered) then
	    			--animalMove(i)
	    			animals[i]:move(player.tileX, player.tileY, room)
	    		end
	    	end
	    	for i = 1, animalCounter-1 do
	    		if animals[i].name == "cat"  and not animals[i].dead and (litTiles[animals[i].tileY][animals[i].tileX]==1 or animals[i].triggered) then
	    			--animalMove(i)
	    			animals[i]:move(player.tileX, player.tileY, room)
	    		end
	    	end
	    	resolveConflicts()
	    	for i = 1, animalCounter-1 do
	    		animals[i].x = (animals[i].tileX-1)*floor.sprite:getHeight()*scale+wallSprite.width
	    		animals[i].y = (animals[i].tileY-1)*floor.sprite:getWidth()*scale+wallSprite.height
	    		if animals[i]:hasMoved() and not animals[i].dead then
					if room[animals[i].tileY][animals[i].tileX]~=nil then
						room[animals[i].tileY][animals[i].tileX]:onEnterAnimal(animals[i])
					end
					if room[animals[i].prevTileY]~=nil and room[animals[i].prevTileY][animals[i].prevTileX]~=nil then
						room[animals[i].prevTileY][animals[i].prevTileX]:onLeaveAnimal(animals[i])
					end
				end
			end
		end
    end
    checkDeath()
    for i = 1, animalCounter-1 do
    	if litTiles[animals[i].tileY][animals[i].tileX]==1 then
    		animals[i].triggered = true
    	end
    	animals[i]:checkDeath(room)
    end
    --Debug console stuff
    if key=='p' then
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
    elseif key == 'c' then
    	log(nil)
    end
    if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].name == "tunnel" then
    	loadNextLevel()
    end
end

function animalMove(i)
	animalDir = ""
	diffx = player.tileX-animals[i].tileX
	diffy = player.tileY-animals[i].tileY
	if math.abs(diffx)>math.abs(diffy) then
		if player.tileX>animals[i].tileX then
			if room[animals[i].tileY][animals[i].tileX+1]~=nil and room[animals[i].tileY][animals[i].tileX+1].blocksMovement then
				animalDir = "y"
			end
		else
			if room[animals[i].tileY][animals[i].tileX-1]~=nil and room[animals[i].tileY][animals[i].tileX-1].blocksMovement then
				animalDir = "y"
			end
		end
	else
		if player.tileY>animals[i].tileY then
			if room[animals[i].tileY+1][animals[i].tileX]~=nil and room[animals[i].tileY+1][animals[i].tileX].blocksMovement then
				animalDir = "x"
			end
		else
			if room[animals[i].tileY-1][animals[i].tileX]~=nil and room[animals[i].tileY-1][animals[i].tileX].blocksMovement then
				animalDir = "x"
			end
		end
	end
	if (player.prevx~=player.x or player.prevy~=player.y) and not animals[i].dead then
		animals[i]:move(player.tileX, player.tileY, animalDir)
		if animals[i]:hasMoved() then
			if room[animals[i].tileY][animals[i].tileX]~=nil then
				room[animals[i].tileY][animals[i].tileX]:onEnterAnimal(animals[i])
			end
			if room[animals[i].prevTileY][animals[i].prevTileX]~=nil then
				room[animals[i].prevTileY][animals[i].prevTileX]:onLeaveAnimal(animals[i])
			end
		end
	end
end

function resolveConflicts()
	conflicts = true
	while conflicts do
		for i = 1, animalCounter-1 do
			for j = 1, i-1 do
				if (not animals[i].dead) and (not animals[j].dead) and animals[i].tileX == animals[j].tileX and animals[i].tileY == animals[j].tileY then
					if animals[i].tileX~=animals[i].prevTileX then
						animals[i].tileX = animals[i].prevTileX
						animals[i].x = animals[i].prevx
					elseif animals[i].tileY~=animals[i].prevTileY then
						animals[i].tileY = animals[i].prevTileY
						animals[i].y = animals[i].prevy
					elseif animals[j].tileX~=animals[j].prevTileX then
						animals[j].tileX = animals[j].prevTileX
						animals[j].x = animals[j].prevx
					elseif animals[j].tileY~=animals[j].prevTileY then
						animals[j].tileY = animals[j].prevTileY
						animals[j].y = animals[j].prevy
					end
				end
			end
		end

		conflicts = false
		for i = 1, animalCounter-1 do
			for j = 1, i-1 do
				if (not animals[i].dead) and (not animals[j].dead) and animals[i].tileX == animals[j].tileX and animals[i].tileY == animals[j].tileY then
					conflicts = true
				end
			end
		end
	end
end

function checkDeath()
	if editorMode then
		return
	end
	if room[player.tileY][player.tileX]~=nil then
		t = room[player.tileY][player.tileX]
		if t:willKillPlayer() then
			kill()
		end
	end
	for i = 1, animalCounter-1 do
		if player.tileX == animals[i].tileX and player.tileY == animals[i].tileY and animals[i].name == "pitbull" and not animals[i].dead then
			kill()
		end
	end
end

--change to update(dt) for non-tile movement
function love.updateOld(dt)
	if not player.dead then
		if love.keyboard.isDown("w") then 
			if player.y == wallSprite.height+player.height*player.scale and player.x+player.width/2 < width/2+40 and player.x+player.width/2 > width/2-110 then
				enterRoom(0)
			end
			player.y = player.y - player.speed * dt
		end
		if love.keyboard.isDown("s") then 
			if player.y == height - wallSprite.heightBottom and player.x < width/2+40 and player.x > width/2-110 then
				enterRoom(2)
			end
			player.y = player.y + player.speed * dt
		end
		if player.y < wallSprite.height+player.height*player.scale then
			player.y = wallSprite.height+player.height*player.scale
		end
		if player.y > height-wallSprite.heightBottom then
			player.y = height-wallSprite.heightBottom
		end
		checkBoundaries()
		if player.prevy~=player.y then
			
			for i = 1, 100 do
				if animals[i]~=nil then
					animals[i]:move(player.x, player.y, dt)
				else
					break
				end
			end
		end
		player.prevy = player.y
		if love.keyboard.isDown("a") then 
			if player.x == wallSprite.width and player.y < height/2+50 and player.y > height/2-20 then
				enterRoom(3)
			end
			player.x = player.x - player.speed * dt
			
		end
		if love.keyboard.isDown("d") then 
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
		if player.x~=player.prevx then
			
			for i = 1, 100 do
				if animals[i]~=nil then
					animals[i]:move(player.x, player.y, dt)
				else
					break
				end
			end
		end
		player.prevx = player.x
	end
	for i = 1, 100 do
		if animals[i]~=nil then
			animals[i].update()
		else
			break
		end
	end
end


function love.mousepressed(x, y, button, istouch)
	if editorMode then
		editor.mousepressed(x, y, button, istouch)
	end
	mouseDown = mouseDown+1
	--mouseX = x-width2/2+16*screenScale/2
	--mouseY = y-height2/2+9*screenScale/2
	mouseX = x-(width2-width)/2
	mouseY = y-(height2-height)/2

	clickActivated = false
	if mouseY<width/18 and mouseY>0 then
		inventoryX = math.floor(mouseX/(width/18))
		--print(inventoryX)
		if inventoryX>-1 and inventoryX<tools.numNormalTools then
			clickActivated = true
			if tool==inventoryX+1 then
				tool=0
			elseif tools[inventoryX+1].numHeld>0 then
				tool=inventoryX+1
			end
		elseif inventoryX>=13 and inventoryX<=15 then
			clickActivated = true
			if specialTools[inventoryX-12]~=0 then
				tool = specialTools[inventoryX-12]
			else tool = 0
			end
		end
		log(tool)
		tools.updateToolableTiles(tool)
	end

	tileLocX = math.ceil((mouseX-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLocY = math.ceil((mouseY-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if not clickActivated and not tools.useToolTile(tool, tileLocY, tileLocX) then
		tool = 0
	end
	
	updateGameState()
end

function love.mousereleased(x, y, button, istouch)
	mouseDown = mouseDown-1
end

function love.mousemoved(x, y, dx, dy)
	--mouseX = x-width2/2+16*screenScale/2
	--mouseY = y-height2/2+9*screenScale/2
	mouseX = x-(width2-width)/2
	mouseY = y-(height2-height)/2
	tileLocX = math.ceil((mouseX-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLocY = math.ceil((mouseY-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if editorMode then
		editor.mousemoved(x, y, dx, dy)
	end
end


function updateGameState()
	updatePower()
	updateLight()
	updateTools()
	tools.updateToolableTiles(tool)
	if tool ~= 0 and tool ~= nil and tools[tool].numHeld == 0 then tool = 0 end
end

function updateFire()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.wall) and room[i][j].onFire then
				burn(i,j)
			end
		end
	end
end

function burn(x,y)
	room[x][y]:destroy()
	for i = -1, 1 do
		for j = -1, 1 do
			if room[x+i]~=nil and room[x+i][y+j]~=nil and tools.flame:usableOnTile(room[x+i][y+j]) and not room[x+i][y+j].onFire then
				room[x+i][y+j].onFire = true
				burn(x+i, y+j)
			end
		end
	end
end

function updateTools()
	for i = 1, 3 do
		if specialTools[i]~=0 and tools[specialTools[i]].numHeld==0 then
			specialTools[3]=0
			for j = i, 2 do
				specialTools[j] = specialTools[j+1]
				specialTools[j+1]=0
			end
		end
	end
	for i = tools.numNormalTools+1, #tools do
		if tools[i].numHeld>0 and not (specialTools[1]==i or specialTools[2]==i or specialTools[3]==i) then
			if specialTools[1]==0 then specialTools[1] = i
			elseif specialTools[2]==0 then specialTools[2] = i
			else specialTools[3] = i end
		end
	end
end

function stepTrigger()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				room[i][j]:onStep()
				if room[i][j].gone then
					room = room[i][j]:onEnd(room, i, j)
					if room[i][j]:instanceof(tiles.bomb) then
						if math.abs(i-player.tileY)+math.abs(j-player.tileX)<3 then kill() end
						for k = 1, animalCounter-1 do
							if math.abs(i-animals[k].tileY)+math.abs(j-animals[k].tileX)<3 then animals[k]:kill() end
						end
					end
					room[i][j] = nil
				end
			end
		end
	end
end

function beatRoom()
	completedRooms[mapy][mapx] = 1
	if mapy>0 then
		visibleMap[mapy-1][mapx] = 1
	end
	if mapy<mapHeight then
		visibleMap[mapy+1][mapx] = 1
	end
	if mapx>0 then
		visibleMap[mapy][mapx-1] = 1
	end
	if mapx<mapHeight then
		visibleMap[mapy][mapx+1] = 1
	end
	local dropOverride = map.getFieldForRoom(mainMap[mapy][mapx].roomid, 'itemsGivenOverride')
	if loadTutorial then
		for i = 1, #tools do
			player.totalItemsGiven[i] = player.totalItemsGiven[i] + map.getItemsGiven(mainMap[mapy][mapx].roomid)[1][i]
			player.totalItemsNeeded[i] = player.totalItemsNeeded[i] + map.getItemsNeeded(mainMap[mapy][mapx].roomid)[1][i]
			tools[i].numHeld = player.totalItemsGiven[i] - player.totalItemsNeeded[i]
			if tools[i].numHeld < 0 then tools[i].numHeld = 0 end
		end
	elseif dropOverride == nil then
		local checkedRooms = {}
		for i = 0, mapHeight do
			checkedRooms[i] = {}
		end
		local amtChecked = 0
		local done = false
		while (not done) do
			y = math.floor(math.random()*(mapHeight+1))
			x = math.floor(math.random()*(mapHeight+1))
			if checkedRooms[y][x] == nil then
				checkedRooms[y][x] = 1
				if completedRooms[y]~=nil and completedRooms[y][x]~=nil and completedRooms[y][x] == 0 then
					if ((completedRooms[y-1]~=nil and completedRooms[y-1][x] ~=nil and completedRooms[y-1][x] == 1) or
					(completedRooms[y+1]~=nil and completedRooms[y+1][x] ~=nil and completedRooms[y+1][x] ==1) or
					(completedRooms[y][x-1]~=nil and completedRooms[y][x-1]==1) or
					(completedRooms[y][x+1]~=nil and completedRooms[y][x+1]==1)) then
						local id = tostring(mainMap[y][x].roomid)
						if dropOverride == nil then
							listOfItemsNeeded = map.getItemsNeeded(mainMap[y][x].roomid)
							numLists = 0
							for j = 1, 10 do
								if listOfItemsNeeded[j]~=nil then
									numLists = numLists+1
								end
							end
							listChoose = math.random(numLists)
							for i=1,tools.numNormalTools do
								--print(listChoose)
								--tools[i].numHeld = tools[i].numHeld+itemsNeeded[mainMap[x][y].roomid][i]
								tools[i].numHeld = tools[i].numHeld+listOfItemsNeeded[listChoose][i]
								if listOfItemsNeeded[listChoose][i]>0 then
									done = true
								end
							end
						end
					end
				end
				amtChecked = amtChecked + 1
				if amtChecked == (mapHeight + 1)*(mapHeight + 1) then
					break
				end
			end
		end
	else
		for i=1,tools.numNormalTools do
			tools[i].numHeld = tools[i].numHeld + dropOverride[i]
		end
	end
end