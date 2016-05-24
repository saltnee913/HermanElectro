
roomHeight = 12
roomLength = 24
screenScale = 70

debug = true
loadTutorial = false

require('scripts.tiles')
require('scripts.map')

require('scripts.boundaries')
--require('scripts.tools')
require('scripts.animals')

loadedOnce = false


function love.load()
	debugText = nil
	tempAdd = 1
	editorMode = false
	roomHack = 0
	editorAdd = 0
	local json = require('scripts.dkjson')
	local itemsNeededPath = 'RoomData/itemsNeeded.json'
	if loadTutorial then
		itemsNeededPath = 'RoomData/tut_itemsNeeded.json'
		io.input('RoomData/tut_itemsGiven.json')
		local str = io.read('*all')
		local obj, pos, err = json.decode(str, 1, nil)
		if err then
			print('Error:', err)
		else
			itemsGiven = obj.itemsGiven
		end
	end
	io.input(itemsNeededPath)
	local str = io.read('*all')
	local obj, pos, err = json.decode(str, 1, nil)
	if err then
		print('Error:', err)
	else
		itemsNeeded = obj.itemsNeeded
	end
	local roomsPath = 'RoomData/rooms.json'
	if loadTutorial then
		roomsPath = 'RoomData/tut_rooms.json'
	end
	map.loadRooms(roomsPath)
	if loadTutorial then
		mainMap = map.generateTutorial()
	else
		mainMap = map.generateMap(8, 20, os.time())
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
	--1=saw
	inventory = {0,0,0,0,0,0,0}
	tool = 0
	animals = {}
	--width = 16*screenScale
	--height = 9*screenScale
	width2, height2 = love.graphics.getDimensions()
	if width2>height2*16/9 then
		height = height2
		width = height2*16/9
	else
		width = width2
		height = width2*9/16
	end
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
		saw = love.graphics.newImage('Graphics/saw.png')
		ladder = love.graphics.newImage('Graphics/ladder.png')
		wirecutters = love.graphics.newImage('Graphics/wirecutters.png')
		waterbottle = love.graphics.newImage('Graphics/waterbottle.png')
		deathscreen = love.graphics.newImage('Graphics/deathscreen.png')
		cuttingtorch = love.graphics.newImage('Graphics/cuttingtorch.png')
		brick = love.graphics.newImage('Graphics/brick.png')
		gun = love.graphics.newImage('Graphics/gun.png')
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
		player.totalItemsGiven = {0,0,0,0,0,0,0}
		player.totalItemsNeeded = {0,0,0,0,0,0,0}
	end
	function player:getTileLoc()
		return {x = self.x/(floor.sprite:getWidth()*scale), y = self.y/(floor.sprite:getWidth()*scale)}
	end
	enterRoom(-1)
	loadedOnce = true
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
	for i=1, roomHeight do
		for j=1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				room[i][j].powered = false
				room[i][j].poweredNeighbors = {0,0,0,0}
			end
		end 
	end
	for i=1, roomHeight do
		for j=1, roomLength do
			--power starts at power sources: powerSupply and notGate
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "powerSupply" and not room[i][j].wet then
				room[i][j].powered = true
			end
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "notGate" then
				--room[i][j].powered = true
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

	--fixing weird not-gate bug
	for k = 1, 10 do
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil and not (room[i][j].name == "powerSupply" or room[i][j].name == "notGate") then
					room[i][j].poweredNeighbors = {0,0,0,0}
					room[i][j].powered = false
					room[i][j]:updateTile(0)
				end
			end
		end
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil then
					if (room[i][j].name == "powerSupply" or room[i][j].name == "notGate") and room[i][j].powered then
						powerTestSpecial(i,j,0)
					end
				end
			end
		end
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil and room[i][j].name == "notGate" then
					local offset = room[i][j]:getOffsetsByDir(3)
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
	for i = 1, (width-wallSprite.width*2)/(floor.sprite:getWidth()*scale)+1 do
		for j = 1, (height-wallSprite.height*2)/(floor.sprite:getHeight()*scale)+1 do
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
				if (room[j][i]~=nil and room[j][i].name~="pitbull" and room[j][i].name~="cat" and room[j][i].name~="pup") or litTiles[j][i]==0 then
					love.graphics.draw(toDraw, (tempi-1)*floor.sprite:getWidth()*scale+wallSprite.width, (tempj-1)*floor.sprite:getHeight()*scale+wallSprite.height, rot * math.pi / 2, scale, scale)
				end
				if tool~="" then
					if tool~=7 then
						if room[j][i]~=nil and adjacent(i,j) then
							if tool==1 then
								if room[j][i].name == "wall" and not room[j][i].sawed then
									love.graphics.draw(green, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
								end
							elseif tool==2 then
								if room[j][i].name == "poweredFloor" and not room[j][i].ladder then
									love.graphics.draw(green, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
								end
							elseif tool==3 then
								if (room[j][i].name == "electricfloor" or room[j][i].name == "horizontalWire" or room[j][i].name == "verticalWire" or room[j][i].name == "wire") and not room[j][i].cut then
									love.graphics.draw(green, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
								end
							elseif tool==4 then
								if (room[j][i].name == "powerSupply" and not room[j][i].wet) or (room[j][i].name == "electricfloor" and not room[j][i].cut) then
									love.graphics.draw(green, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
								end
							elseif tool==5 then
								if room[j][i].name == "metalwall" and not room[j][i].sawed then
									love.graphics.draw(green, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
								end
							elseif tool==6 then
								if (room[j][i].name == "glasswall" and not room[j][i].sawed) or (room[j][i].name == "button" and not room[j][i].bricked) then
									love.graphics.draw(green, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
								end
							end
						end

					else
						if (j == player.tileY and math.abs(i-player.tileX)<=3) or (i == player.tileX and math.abs(j-player.tileY)<=3) then
							for k = 1, animalCounter-1 do
								if animals[k].tileY == j and animals[k].tileX == i then
									love.graphics.draw(green, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
									break
								end
							end
						end
					end
				end
			end
		end
	end
	if mapy>0 then
		if mainMap[mapy-1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy-1][mapx]==0) then
			love.graphics.draw(doorwaybg, width/2-150, 0, 0, scale, scale*0.42)
		end
	end
	if mapx<mapHeight then
		if mainMap[mapy][mapx+1]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx+1]==0) then
			love.graphics.draw(doorwaybg, width-wallSprite.width-9, height/2-150, 0, scale*0.42, scale)
		end
	end
	if mapy<mapHeight then
		if mainMap[mapy+1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy+1][mapx]==0) then
			love.graphics.draw(doorwaybg, width/2-150, height-scale*0.42*doorwaybg:getHeight()+11, 0, scale, scale*0.36)
		end
	end
	if mapx>0 then
		if mainMap[mapy][mapx-1]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx-1]==0) then
			love.graphics.draw(doorwaybg, 2, height/2-150, 0, scale*0.45, scale)
		end
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
				if mainMap[i][j] == nil then
					--love.graphics.setColor(255,255,255)
					--love.graphics.rectangle("line", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
				end
				--else
					if mainMap[i][j]==nil then
						love.graphics.setColor(0, 0, 0)
					elseif (i == mapy and j == mapx) then
						love.graphics.setColor(0,255,0)
					elseif completedRooms[i][j]==1 then
						love.graphics.setColor(255,255,255)
					else
						love.graphics.setColor(100,100,100)
					end
					love.graphics.rectangle("fill", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
				--end
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
		if i==0 then
			love.graphics.draw(saw, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		elseif i==1 then
			love.graphics.draw(ladder, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		elseif i==2 then
			love.graphics.draw(wirecutters, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		elseif i==3 then
			love.graphics.draw(waterbottle, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		elseif i==4 then
			love.graphics.draw(cuttingtorch, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		elseif i == 5 then
			love.graphics.draw(brick, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		elseif i == 6 then
			love.graphics.draw(gun, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		end
		if inventory[i+1]==0 then
			love.graphics.draw(gray, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
		end
		love.graphics.setColor(0,0,0)
		love.graphics.print(inventory[i+1], i*width/18+3, 0)
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
		barLength = 660
		love.graphics.setColor(255,255,255)
		for i = 1, 45 do
			if tiles[i]~=nil then
				toDraw = tiles[i].sprite
				--love.graphics.rectangle("fill", (i-1)*width/25, height-width/25, width/25, width/25)
				--sprite width: floor.sprite:getWidth()
				love.graphics.draw(toDraw, (i-1)*width/45, height-width/45, 0, (width/45)/(floor.sprite:getWidth()), (width/45)/(floor.sprite:getWidth()))
				if editorAdd == i then
					love.graphics.draw(green, (i-1)*width/45, height-width/45, 0, (width/45)/(floor.sprite:getWidth()), (width/45)/(floor.sprite:getWidth()))
				end
			end
		end
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
	mainMap[y][x] = {roomid = roomid, room = map.createRoom(roomid), 
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
	updatePower()
	updateLight()
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
	updatePower()
	updateLight()
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

function love.keypressed(key, unicode)
	if key=="e" then
		editorMode = not editorMode
	end
	if editorMode and key=="p" then
		print("[")
		for i = 1, roomHeight do
			prt = "["
			for j =1, roomLength do
				if room[i][j]~=nil then
					for k = 1, 100 do
						if tiles[k]~=nil and room[i][j]~=nil and tiles[k].name == room[i][j].name then
							addk = k
							if k == 1 then
								addk=0
							end
							prt = prt..addk
							if(room[i][j].rotation ~= 0) then
								prt = prt..'.'..room[i][j].rotation
							end
							break
						end
					end
				else
					prt = prt..0
				end
				if j ~= roomLength then
					prt = prt..","
				end
			end
			prt = prt.."]"
			print(prt)
		end
		print("]")
	end
	if editorMode and roomHack < 1 and key=='h' then
		roomHack = mainMap[mapy][mapx].roomid
		log('Room Hack: '..roomHack)
	elseif roomHack >= 1 and key=='h' then
		hackEnterRoom(roomHack)
		roomHack = 0
		log()
	end
	if roomHack >= 1 and key =='right' then
		roomHack = roomHack + 1
		log('Room Hack: '..roomHack)
	elseif roomHack >= 2 and key == 'left' then
		roomHack = roomHack - 1
		log('Room Hack: '..roomHack)
	end
	beforePressX = player.x
	beforePressY = player.y
	love.keyboard.setKeyRepeat(true)
    -- ignore non-printable characters (see http://www.ascii-code.com/)
    if player.dead and (key == "w" or key == "a" or key == "s" or key == "d") then
    	return
    end

    if key == "r" then
    	if editorMode then
    		--player.dead = false
    		for i = 1, roomHeight do
    			for j = 1, roomLength do
    				room[i][j] = nil
    			end
    		end
    		animals = {}
    		animalCounter = 1
    	elseif loadTutorial then
    		player.dead = false
			player.y = (1-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
			player.tileY = 1
			player.x = (roomLength/2-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10
			player.tileX = roomLength/2
			player.prevy = player.y
			player.prevTileY = player.tileY
			player.prevx = player.x
			player.prevTileX = player.tileX
			for i = 1,7 do
				if (completedRooms[mapy][mapx] == 1) then
					player.totalItemsGiven[i] = player.totalItemsGiven[i] - itemsGiven[mainMap[mapy][mapx].roomid][1][i]
					player.totalItemsNeeded[i] = player.totalItemsNeeded[i] - itemsNeeded[mainMap[mapy][mapx].roomid][1][i]
				end
				inventory[i] = player.totalItemsGiven[i] - player.totalItemsNeeded[i]
				if inventory[i] < 0 then inventory[i] = 0 end
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
    elseif key == "z" and editorMode and prevRoom~=nil then
    	room = prevRoom
    	animals = prevAnimals
    	animalCounter = 1
    	for i = 1, 100 do
    		if animals[i]~=nil then
    			animalCounter = animalCounter+1
    		end
    	end
    	--print(room[1][1].name)
	elseif key == "f" and editorMode then
		for i = 1, 7 do
			inventory[i] = inventory[i]+1
		end
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
	elseif key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" then
		numPressed = tonumber(key)
		if inventory[numPressed]>0 then
			tool = numPressed
		end
    end
    local useTool = false
    local tileLocXDelta = 0
    local tileLocYDelta = 0
    if key == 'up' then tileLocYDelta = -1
    elseif key == 'down' then tileLocYDelta = 1
    elseif key == 'left' then tileLocXDelta = -1
    elseif key == 'right' then tileLocXDelta = 1 end
    if tileLocXDelta ~= 0 or tileLocYDelta ~= 0 or key == 'space' then
    	useTool = true
    end
    if useTool then
    	local tileLocX = player.tileX + tileLocXDelta
    	local tileLocY = player.tileY + tileLocYDelta
		if tool==7 then
			for mult = 0, 3 do
				tileLocX = player.tileX + tileLocXDelta*mult
				local killedAnimal = false
				for i = 1, animalCounter-1 do
					if animals[i].tileX == tileLocX and animals[i].tileY == tileLocY and not animals[i].dead then
						animals[i]:kill()
						inventory[tool] = inventory[tool]-1
						if inventory[tool] == 0 then
							tool = 0
						end
						killedAnimal = true
					end
				end
				if killedAnimal then break end
			end
		elseif tool~=0 and room[tileLocY]~=nil and room[tileLocY][tileLocX]~=nil and adjacent(tileLocX, tileLocY) then
			if room[tileLocY][tileLocX]:useTool(tool) then
				clickActivated = true
				inventory[tool] = inventory[tool]-1
				if inventory[tool]==0 then
					tool = 0
				end
			end
		end
		updateLight()
		updatePower()
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
	    	updateLight()
	    	updatePower()
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
    	local itemsForRoom = itemsNeeded[roomid]
    	if itemsForRoom~=nil then
    		for i=1,#itemsForRoom do
    			if itemsForRoom[i][1]~=0 then toPrint = toPrint..' '..itemsForRoom[i][1]..' saw' end
    			if itemsForRoom[i][2]~=0 then toPrint = toPrint..' '..itemsForRoom[i][2]..' ladder' end
    			if itemsForRoom[i][3]~=0 then toPrint = toPrint..' '..itemsForRoom[i][3]..' wire-cutters' end
    			if itemsForRoom[i][4]~=0 then toPrint = toPrint..' '..itemsForRoom[i][4]..' water-bottle' end
    			if itemsForRoom[i][5]~=0 then toPrint = toPrint..' '..itemsForRoom[i][5]..' cutting-torch' end
    			if itemsForRoom[i][6]~=0 then toPrint = toPrint..' '..itemsForRoom[i][6]..' brick' end
    			if itemsForRoom[i][7]~=0 then toPrint = toPrint..' '..itemsForRoom[i][7]..' gun' end
    			if i~=#itemsForRoom then toPrint = toPrint..' or ' end
    		end
    	end
    	log(toPrint)
    elseif key == 'c' then
    	log(nil)
    end
    if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].name == "tunnel" then
    	love.load()
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
				if (not animals[i]==dead) and (not animals[j]==dead) and animals[i].tileX == animals[j].tileX and animals[i].tileY == animals[j].tileY then
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
		if t.name == "electricfloor" and t.powered and not t.cut then
			kill()
		elseif t.name == "poweredFloor" and not t.powered and not t.ladder then
			kill()
		elseif t.name == "pit" then
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
			updateLight()
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
			updateLight()
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
		prevRoom = {}
		for i = 1, roomHeight do
			prevRoom[i] = {}
			for j = 1, roomLength do
				prevRoom[i][j] = room[i][j]
			end
		end
		prevAnimals = {}
		for i = 1, animalCounter - 1 do
			prevAnimals[i] = animals[i]
		end
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
		if inventoryX>-1 and inventoryX<7 then
			clickActivated = true
			if tool==inventoryX+1 then
				tool=0
			elseif inventory[inventoryX+1]>0 then
				tool=inventoryX+1
			end
		end
	end

	tileLocX = math.ceil((mouseX-wallSprite.width)/(scale*floor.sprite:getWidth()))
	tileLocY = math.ceil((mouseY-wallSprite.height)/(scale*floor.sprite:getHeight()))
	if tool==7 then
		if (tileLocX == player.tileX and math.abs(tileLocY-player.tileY)<=3) or (tileLocY == player.tileY and math.abs(tileLocX-player.tileX)<=3) then
			for i = 1, animalCounter-1 do
				if animals[i].tileX == tileLocX and animals[i].tileY == tileLocY and not animals[i].dead then
					animals[i]:kill()
					inventory[tool] = inventory[tool]-1
					if inventory[tool] == 0 then
						tool = 0
					end
					break
				end
			end
		end
	elseif tool~=0 and room[tileLocY]~=nil and room[tileLocY][tileLocX]~=nil and adjacent(tileLocX, tileLocY) then
		if room[tileLocY][tileLocX]:useTool(tool) then
			clickActivated = true
			inventory[tool] = inventory[tool]-1
			if inventory[tool]==0 then
				tool = 0
			end
		end
	end
	if not clickActivated then
		tool = 0
	end
	if button == 'l' or button == 1 then
		tempAdd = editorAdd
	elseif button == 'r' or button == 2 then
		tempAdd = 1
	end
	if editorMode then
		if mouseY>height-width/45 then
			editorAdd = math.floor(mouseX/(width/45))+1
		elseif tempAdd>0 and tileLocX>=1 and tileLocX<=24 and tileLocY>=1 and tileLocY<=12 then
			if(room[tileLocY][tileLocX] ~= nil and room[tileLocY][tileLocX].name == tiles[tempAdd].name) then
				room[tileLocY][tileLocX]:rotate(1)
			else
				room[tileLocY][tileLocX] = tiles[tempAdd]:new()
			end
			for i = 1, animalCounter-1 do
				if animals[i]~=nil and animals[i].tileX == tileLocX and animals[i].tileY == tileLocY then
					animals[i] = nil
					for j = i+1, animalCounter do
						animals[j-1] = animals[j]
					end
					animalCounter = animalCounter-1
				end
			end
			if tempAdd == 21 or tempAdd == 22 or tempAdd == 23 then
				animalToSpawn = room[tileLocY][tileLocX].animal
				if not animalToSpawn.dead then
					animals[animalCounter] = animalList[tempAdd-19]:new()
					animals[animalCounter].y = (tileLocY-1)*floor.sprite:getWidth()*scale+wallSprite.height
					animals[animalCounter].x = (tileLocX-1)*floor.sprite:getHeight()*scale+wallSprite.width
					animals[animalCounter].tileX = tileLocX
					animals[animalCounter].tileY = tileLocY
					animalCounter = animalCounter+1
				end
			end
			updateLight()
			updatePower()
		end
	end
	updateLight()
	updatePower()
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
	if editorMode and mouseDown>0 then
		if tempAdd>0 and tileLocX>=1 and tileLocX<=24 and tileLocY>=1 and tileLocY<=12 then
			room[tileLocY][tileLocX] = tiles[tempAdd]:new()
			updateLight()
			updatePower()
		end
	end
end
