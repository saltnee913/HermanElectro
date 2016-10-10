roomHeight = 12
roomLength = 24
screenScale = 70

debug = true
loadTutorial = false
gamePaused = false

util = require('scripts.util')
tiles = require('scripts.tiles')
map = require('scripts.map')

boundaries = require('scripts.boundaries') 
--require('scripts.tools')
animalList = require('scripts.animals')
tools = require('scripts.tools')
editor = require('scripts.editor')
unlocks = require('scripts.unlocks')
characters = require('scripts.characters')
tutorial = require('scripts.tutorial')

loadedOnce = false

saveDir = 'SaveData'

local function addTo(toAdd, array)
	for i = 1, 7 do
		toAdd[i] = toAdd[i] + array[i]
	end
end

function love.load()
	--[[local json = require('scripts.dkjson')
	local itemsNeededs = {}
	local ls = {}
	ls[1] = {}
	ls[1][1] = {0,0,0,0,0,3,0}
	 ls[2] = {}
	ls[2][1] = {0,1,0,0,0,0,0}
	ls[2][2] = {0,0,0,1,0,0,0}
	ls[2][3] = {1,0,0,0,0,0,0}
	ls[2][4] = {0,0,1,0,0,0,0}
	ls[2][5] = {0,0,0,0,1,0,0}
	 ls[3] = {}
	ls[3][1] = {0,0,0,0,0,0,1}
	ls[3][2] = {0,0,0,0,0,1,0}
	ls[3][3] = {1,1,0,0,0,0,0}
	 ls[4] = {}sas
	ls[4][1] = {0,1,0,0,0,1,0}
	ls[4][2] = {0,1,2,0,0,0,0}
	ls[4][3] = {0,1,1,1,0,0,0}
	 ls[5] = {}
	ls[5][1] = {0,0,1,0,0,0,0}
	ls[5][2] = {0,0,0,1,0,0,0}
	 ls[6] = {}
	ls[6][1] = {0,7,0,0,0,0,0}
	ls[6][2] = {0,4,0,0,0,1,0}
	for i1 = 1, 1 do
		for i2 = 1, 5 do
			for i3 = 1, 3 do
				for i4 = 1, 3 do
					for i5 = 1, 2 do
						for i6 = 1, 2 do
							local toAdd = {0,0,0,0,0,0,0}
							addTo(toAdd, ls[1][i1])
							addTo(toAdd, ls[2][i2])
							addTo(toAdd, ls[3][i3])
							addTo(toAdd, ls[4][i4])
							addTo(toAdd, ls[5][i5])
							addTo(toAdd, ls[6][i6])
							itemsNeededs[#itemsNeededs+1] = toAdd
						end
					end
				end
			end
		end
	end
	for i = 1, #itemsNeededs do
		for j = 1, #itemsNeededs do
			if i ~= j and itemsNeededs[j] ~= nil and itemsNeededs[i] ~= nil then
				local bad = true
				for k = 1, 7 do
					if itemsNeededs[i][k] > itemsNeededs[j][k] then
						bad = false
					end
				end
				if bad then itemsNeededs[i] = nil end
			end
		end
	end
	local state = {indent = true}
	print(json.encode(itemsNeededs, state))
	game.crash()]]

	gamePaused = false
	gameTime = {timeLeft = 260, toolTime = 0, roomTime = 15, levelTime = 200, donateTime = 20}

	enteringSeed = false
	seedOverride = nil
	typingCallback = nil
	mouseDown = false
	debugText = nil
	tempAdd = 1
	editorMode = false
	editorAdd = 0

	donations = 0

	roomHeight = 12
	roomLength = 24

	floorDonations = 0
	recDonations = 26

	won = false

	unlocks.load()

	--[[local json = require('scripts.dkjson')
	local roomsToFix, roomsArray = util.readJSON('RoomData/tut_rooms.json', true)
	local outputPrint = {rooms = {}, superFields = roomsToFix.superFields}
	for k, v in pairs(roomsToFix.rooms) do
		local layouts = v.layouts and v.layouts or {v.layout}
		for l = 1, #layouts do
			local layout = layouts[l]
			for i = 1, #layout do
				for j = 1, #layout[i] do
					
					local rot = layout[i][j]-math.floor(layout[i][j])
					local val = layout[i][j]
					if math.floor(layout[i][j]) == 40 then
						val = {31, 82}
					elseif math.floor(layout[i][j]) == 48 then
						val = {31, 83.1}
					elseif math.floor(layout[i][j]) == 54 then
						val = {31, 85.3}
					elseif math.floor(layout[i][j]) == 55 then
						val = {31, 84.3}
					elseif math.floor(layout[i][j]) == 79 then
						val = {24, 4}
					elseif math.floor(layout[i][j]) == 80 then
						val = {64, 4}
					end
					if type(val) ~= 'number' then
						val[2] = val[2] + rot
						if val[2] > math.floor(val[2]) + 0.3 then
							val[2] = val[2] - 0.4
						end
					end
					layout[i][j] = val
				end
			end
		end
	end
	local state = {indent = true, keyorder = roomsArray}
	print(json.encode(roomsToFix, state))
	game.crash()]]

	--1=saw
	--toolMode = 1

	tool = 0
	for i = 1, #tools do
		tools[i].numHeld = 0
	end
	specialTools = {0,0,0}
	animals = {}
	animalCounter = 1
	pushables = {}
	messageInfo = {x = 0, y = 0, text = nil}
	--width = 16*screenScale
	--height = 9*screenScale
	--wallSprite = {width = 78*screenScale/50, height = 72*screenScale/50, heightForHitbox = 62*screenScale/50}
	wallSprite = {width = 187*width/1920, height = 170*height/1080, heightBottom = 150*height/1080}
	--image = love.graphics.newImage("cake.jpg")
	love.graphics.setNewFont(12)
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(255,255,255)
	if not loadedOnce then
		started = false
		charSelect = false
		selectedBox = {x = 0, y = 0}
		yOffset = -6
		regularLength = 24
		regularHeight = 12
		toolTime = 0
		f1 = love.graphics.newImage('Graphics/concretewalls.png')
		walls = love.graphics.newImage('Graphics/walls3.png')
		black = love.graphics.newImage('Graphics/dark.png')
		green = love.graphics.newImage('Graphics/green.png')
		gray = love.graphics.newImage('Graphics/gray.png')
		--floortile = love.graphics.newImage('Graphics/floortile.png')
		floortile = love.graphics.newImage('Graphics/floortilemost.png')
		doorwaybg = love.graphics.newImage('Graphics/doorwaybackground.png')
		deathscreen = love.graphics.newImage('NewGraphics/Newdeathscreen.png')
		winscreen = love.graphics.newImage('NewGraphics/NewWinScreen.png')
		pausescreen = love.graphics.newImage('NewGraphics/NewPauseScreen.png')
		bottomwall = love.graphics.newImage('Graphics3D/bottomwall.png')
		--topwall = love.graphics.newImage('Graphics/cave6_b.png')
		topwall = love.graphics.newImage('Graphics3D/topwall.png')
		cornerwall = love.graphics.newImage('Graphics/toprightcorner.png')
		startscreen = love.graphics.newImage('NewGraphics/startscreen2.png')

		music = love.audio.newSource('Audio/hermantheme.mp3')
		--music:play()

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
	--print(love.graphics.getWidth(f1))
	scale = (width - 2*wallSprite.width)/(20.3 * 16)*5/6
	floor = tiles.tile
	if player == nil then
		player = { dead = false, safeFromAnimals = false, active = true, flying = false, waitCounter = 0, tileX = 1, tileY = 6, x = (1-1)*scale*floor.sprite:getWidth()+wallSprite.width+	floor.sprite:getWidth()/2*scale-10, 
			y = (6-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10, prevTileX = 3, prevTileY 	= 10,
			prevx = (3-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10,
			prevy = (10-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10,
			width = 20, height = 20, speed = 250,
			character = characters[1]}
	else
		player.dead = false
		player.tileX = 1
		player.tileY = 6
	end

	if loadTutorial then
		player.enterX = player.tileX
		player.enterY = player.tileY
		player.totalItemsGiven = {0,0,0,0,0,0,0}
		player.totalItemsNeeded = {0,0,0,0,0,0,0}
	end
	function player:getTileLoc()
		return {x = self.x/(floor.sprite:getWidth()*scale), y = self.y/(floor.sprite:getWidth()*scale)}
	end
end

function loadRandoms()
	local seed
	if seedOverride == nil then
		seed = os.time()
	else
		seed = tonumber(seedOverride)
	end
	util.newRandom('mapGen', seed)
	util.newRandom('toolDrop', seed*3)
	util.newRandom('misc', seed*5)
end

function loadNextLevel(dontChangeTime)
	if dontChangeTime == nil then dontChangeTime = false end
	--hacky way of getting info, but for now, it works
	toolMax = floorIndex
 	toolMin = floorIndex-1
 	floorDonations = 0
 	if not dontChangeTime then
 		gameTime.timeLeft = gameTime.timeLeft+gameTime.levelTime
 	end
	if loadTutorial then
		loadLevel('RoomData/tut_map.json')
	else
		if floorIndex > #map.floorOrder then
			floorIndex = 1
		end
		loadLevel(map.floorOrder[floorIndex])
		floorIndex = floorIndex + 1
	end
	--hack to make it not happen on the first floor
	if floorIndex ~= 2 then
		player.character:onFloorEnter()
	end
end

function startGame()
	loadRandoms()
	loadTutorial = false
	map.floorOrder = map.defaultFloorOrder
	love.load()
	tools.resetTools()
	--started = true
	charSelect = true
end

function startTutorial()
	tutorial.load()
	loadRandoms()
	loadTutorial = true
	map.floorOrder = {'RoomData/tut_map.json'}
	player.enterX = player.tileX
	player.enterY = player.tileY
	player.totalItemsGiven = {0,0,0,0,0,0,0}
	player.totalItemsNeeded = {0,0,0,0,0,0,0}
	loadFirstLevel()
	love.load()
	tools.resetTools()
	player.character = characters.herman
	player.character:onBegin()
	started = true
end

function startDebug()
	loadRandoms()
	loadTutorial = false
	map.floorOrder = {'RoomData/debugFloor.json'}
	love.load()
	tools.resetTools()
	charSelect = true
end

function loadFirstLevel()
	floorIndex = 1
	loadNextLevel(true)
	createAnimals()
	createPushables()
end

function loadLevel(floorPath)
	animals = {}
	pushables = {}
	map.loadFloor(floorPath)
	mainMap = map.generateMap()
	mapHeight = mainMap.height
	mapx = mainMap.initialX
	mapy = mainMap.initialY
	visibleMap = {}
	for i = 1, mapHeight do
		for j = 1, mapHeight do
			if mainMap[i][j]~=nil then
				for i2 = 1, mainMap[i][j].room.height do
					for j2 = 1, mainMap[i][j].room.length do
						if mainMap[i][j].room[i2][j2]~=nil and mainMap[i][j].room[i2][j2].name == tiles.boxTile.name then
							local rand = util.random('mapGen')
							if rand<donations/100 or player.character.name==characters.tim.name then
								mainMap[i][j].room[i2][j2] = tiles.giftBoxTile:new()
							end
						end
					end
				end
			end
		end
	end
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
	if editorMode then return end
	player.dead = true
end

function win()
	if not won then
		for i = 1, #unlocks.winUnlocks do
			if unlocks[unlocks.winUnlocks[i]].unlocked == false then
				unlocks.unlockUnlockable(unlocks.winUnlocks[i])
				break
			end
		end
		for i = 1, #player.character.winUnlocks do
			local unlock = player.character.winUnlocks[i]
			if unlocks[unlock].unlocked == false then
				unlocks.unlockUnlockable(unlock)
				break
			end
		end
		if gameTime.timeLeft > gameTime.levelTime * floorIndex then
			unlocks.unlockUnlockableRef(unlocks.erikUnlock)
		end
		won = true
	end
end

function updateLight()
	litTiles = {}
	for i = 1, roomHeight do
		litTiles[i]={}
	end
	for i = 1, roomHeight do
		for j = 1, roomLength do
			litTiles[i][j]=0
		end
	end
	lightTest(player.tileY, player.tileX)
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j].lit then
				lightTest(i, j)
			end
		end
	end
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
	player.character:onPreUpdatePower()
	powerCount = 0

	for i = 1, #pushables do
		pushables[i].powered = false
	end

	for i=1, roomHeight do
		for j=1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				room[i][j].powered = false
				room[i][j].poweredNeighbors = {0,0,0,0}
				if room[i][j].overlay ~= nil then
					room[i][j].powered = true
					room[i][j].poweredNeighbors = {0,0,0,0}
				end
			end
		end 
	end

	for i=1, roomHeight do
		for j=1, roomLength do
			--power starts at power sources: powerSupply and notGate
			if room[i]~=nil and room[i][j]~=nil and room[i][j]:instanceof(tiles.powerSupply) and not room[i][j].destroyed then
				room[i][j].powered = true
			end
			if room[i]~=nil and room[i][j]~=nil and room[i][j]:instanceof(tiles.notGate) and not room[i][j].destroyed then
				--room[i][j].powered = true
			end
			if room[i] ~= nil and room[i][j]~=nil and room[i][j].charged and not room[i][j].destroyed then
				room[i][j].powered = true
			end
		end
	end
	for i=1, roomHeight do
		for j=1, roomLength do
			--power starts at power sources: powerSupply and notGate
			if room[i]~=nil and room[i][j]~=nil and (room[i][j].charged or room[i][j]:instanceof(tiles.powerSupply) or room[i][j]:instanceof(tiles.notGate)) then
				room[i][j]:updateTileAndOverlay(0)
				powerTest(i,j,0)
			end
		end
	end

	--fixing weird not-gate bug
	for k = 1, 4 do
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]~=nil and room[i][j].charged then room[i][j].powered=true end
				if room[i]~=nil and room[i][j]~=nil and not (room[i][j]:instanceof(tiles.powerSupply) or room[i][j]:instanceof(tiles.notGate)) and not room[i][j].charged then
					room[i][j].poweredNeighbors = {0,0,0,0}
					room[i][j].powered = false
					room[i][j]:updateTileAndOverlay(0)
				end
			end
		end
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil then
					if (room[i][j]:instanceof(tiles.powerSupply) or room[i][j]:instanceof(tiles.notGate) or room[i][j].charged) and room[i][j].powered then
						powerTestSpecial(i,j,0)
					end
				end
			end
		end
		for i = 1, 5 do
			for i = 1, #pushables do
				if pushables[i].conductive and not pushables[i].destroyed then
					local conductPower = false
					local pX = pushables[i].tileX
					local pY = pushables[i].tileY
					if (room[pY-1]~=nil and room[pY-1][pX]~=nil and room[pY-1][pX].powered and room[pY-1][pX].dirSend[3]==1) or
					(room[pY+1]~=nil and room[pY+1][pX]~=nil and room[pY+1][pX].powered and room[pY+1][pX].dirSend[1]==1) or
					(room[pY][pX-1]~=nil and room[pY][pX-1].powered and room[pY][pX-1].dirSend[2]==1) or
					(room[pY][pX+1]~=nil and room[pY][pX+1].powered and room[pY][pX+1].dirSend[4]==1) then
						conductPower = true
					end
					for j = 1, #pushables do
						if pushables[j].powered and not pushables[j].destroyed then
							if pushables[i].tileY == pushables[j].tileY and math.abs(pushables[i].tileX-pushables[j].tileX)==1
							or pushables[i].tileX == pushables[j].tileX and math.abs(pushables[j].tileY-pushables[i].tileY)==1 then
								conductPower = true
							end
						end
					end
					if conductPower then
						if pushables[i]:instanceof(pushableList.bombBox) and k==3 then
							if not pushables[i].destroyed then
								pushables[i]:destroy(pY, pX)
							end
						else
							if pushables[i]:instanceof(pushableList.jackInTheBox) then
								for i = 1, #animals do
									animals[i].waitCounter = 1
								end
							end
							powerTestPushable(pY, pX, 0)
						end
						pushables[i].powered = true
					end
				end
			end
		end
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil and room[i][j]:instanceof(tiles.notGate) then
					local offset = room[i][j]:getCorrectedOffset(3)
					if room[i+offset.y]~=nil and room[i+offset.y][j+offset.x]~=nil and room[i+offset.y][j+offset.x].powered==false then
						room[i][j].poweredNeighbors[room[i][j]:cfr(3)]=0
						room[i][j]:updateTileAndOverlay(0)
					elseif room[i+offset.y]~=nil and room[i+offset.y][j+offset.x]~=nil
					 and room[i+offset.y][j+offset.x].powered==true
					 and room[i+offset.y][j+offset.x].dirSend[room[i][j]:cfr(1)]==1 then
						room[i][j].poweredNeighbors[room[i][j]:cfr(3)]=1
						room[i][j]:updateTileAndOverlay(0)
					end
				end
			end
		end
	end

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				room[i][j]:postPowerUpdate(i,j)
			end
		end
	end

	for i=1, roomHeight do
		for j=1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				room[i][j].formerPowered = room[i][j].powered
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
	player.character:onPostUpdatePower()
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
	if powerCount>3000 then
		kill()
		return
	end
	--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left
	if room[x] == nil or room[x][y] == nil then
		return
	end

	if x>1 and room[x-1][y]~=nil and canBePowered(x-1,y,3) and lastDir~=1 then
		formerPowered = room[x-1][y].powered
		formerSend = room[x-1][y].dirSend
		formerAccept = room[x-1][y].dirAccept
		--powered[x-1][y] = 1
		if room[x][y].dirSend[1]==1 and room[x][y].powered then
			room[x-1][y].poweredNeighbors[3] = 1
		else
			room[x-1][y].poweredNeighbors[3] = 0
		end
		room[x-1][y]:updateTileAndOverlay(3)
		if room[x-1][y].powered ~= formerPowered or room[x-1][y].dirSend ~= formerSend or room[x-1][y].dirAccept ~= formerAccept then
			powerTest(x-1,y,3)
		end
	end


	if x<roomHeight and room[x+1][y]~=nil and canBePowered(x+1,y,1) and lastDir~=3 then
		--powered[x+1][y] = 1
		formerPowered = room[x+1][y].powered
		formerSend = room[x+1][y].dirSend
		formerAccept = room[x+1][y].dirAccept
		if room[x][y].dirSend[3]==1 and room[x][y].powered then
			room[x+1][y].poweredNeighbors[1] = 1
		else
			room[x+1][y].poweredNeighbors[1] = 0
		end
		room[x+1][y]:updateTileAndOverlay(1)
		if room[x+1][y].powered ~= formerPowered or room[x+1][y].dirSend ~= formerSend or room[x+1][y].dirAccept ~= formerAccept then
			powerTest(x+1,y,1)
		end
	end

	if y>1 and room[x][y-1]~=nil and canBePowered(x,y-1,2) and lastDir~=4 then
		formerPowered = room[x][y-1].powered
		formerSend = room[x][y-1].dirSend
		formerAccept = room[x][y-1].dirAccept
		--powered[x][y-1] = 1
		if room[x][y].dirSend[4]==1 and room[x][y].powered then
			room[x][y-1].poweredNeighbors[2] = 1
		else
			room[x][y-1].poweredNeighbors[2] = 0
		end
		room[x][y-1]:updateTileAndOverlay(2)
		if room[x][y-1].powered ~= formerPowered or room[x][y-1].dirSend ~= formerSend or room[x][y-1].dirAccept ~= formerAccept then
			powerTest(x, y-1, 2)
		end
	end

	if y<roomLength and room[x][y+1]~=nil and canBePowered(x,y+1,4) and lastDir~=2 then
		formerPowered = room[x][y+1].powered
		formerSend = room[x][y+1].dirSend
		formerAccept = room[x][y+1].dirAccept
		--powered[x][y+1] = 1
		if room[x][y].dirSend[2]==1 and room[x][y].powered then
			room[x][y+1].poweredNeighbors[4] = 1
		else
			room[x][y+1].poweredNeighbors[4] = 0
		end
		room[x][y+1]:updateTileAndOverlay(4)
		if room[x][y+1].powered ~= formerPowered or room[x][y+1].dirSend ~= formerSend or room[x][y+1].dirAccept ~= formerAccept then
			powerTest(x, y+1, 4)
		end
	end
end

function powerTestPushable(x, y, lastDir)
	powerCount = powerCount+1
	if powerCount>3000 then
		kill()
		return
	end
	--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left

	if x>1 and room[x-1][y]~=nil and canBePowered(x-1,y,3) then
		formerPowered = room[x-1][y].powered
		formerSend = room[x-1][y].dirSend
		formerAccept = room[x-1][y].dirAccept
		--powered[x-1][y] = 1
		room[x-1][y].poweredNeighbors[3] = 1
		room[x-1][y]:updateTileAndOverlay(3)
		if room[x-1][y].powered ~= formerPowered or room[x-1][y].dirSend ~= formerSend or room[x-1][y].dirAccept ~= formerAccept then
			powerTestSpecial(x-1,y,3)
		end
	end


	if x<roomHeight and room[x+1][y]~=nil and canBePowered(x+1,y,1) then
		--powered[x+1][y] = 1
		formerPowered = room[x+1][y].powered
		formerSend = room[x+1][y].dirSend
		formerAccept = room[x+1][y].dirAccept
		room[x+1][y].poweredNeighbors[1] = 1
		room[x+1][y]:updateTileAndOverlay(1)
		if room[x+1][y].powered ~= formerPowered or room[x+1][y].dirSend ~= formerSend or room[x+1][y].dirAccept ~= formerAccept then
			powerTestSpecial(x+1,y,1)
		end
	end

	if y>1 and room[x][y-1]~=nil and canBePowered(x,y-1,2) then
		formerPowered = room[x][y-1].powered
		formerSend = room[x][y-1].dirSend
		formerAccept = room[x][y-1].dirAccept
		--powered[x][y-1] = 1
		room[x][y-1].poweredNeighbors[2] = 1
		room[x][y-1]:updateTileAndOverlay(2)
		if room[x][y-1].powered ~= formerPowered or room[x][y-1].dirSend ~= formerSend or room[x][y-1].dirAccept ~= formerAccept then
			powerTestSpecial(x, y-1, 2)
		end
	end

	if y<roomLength and room[x][y+1]~=nil and canBePowered(x,y+1,4) then
		formerPowered = room[x][y+1].powered
		formerSend = room[x][y+1].dirSend
		formerAccept = room[x][y+1].dirAccept
		--powered[x][y+1] = 1
		room[x][y+1].poweredNeighbors[4] = 1
		room[x][y+1]:updateTileAndOverlay(4)
		if room[x][y+1].powered ~= formerPowered or room[x][y+1].dirSend ~= formerSend or room[x][y+1].dirAccept ~= formerAccept then
			powerTestSpecial(x, y+1, 4)
		end
	end
end

function powerTestSpecial(x, y, lastDir)
--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left
	if room[x] == nil or room[x][y] == nil then
		return
	end

	if x>1 and room[x-1][y]~=nil and room[x-1][y].name~="notGate" and canBePowered(x-1,y,3) and lastDir~=1 then
		formerPowered = room[x-1][y].powered
		formerSend = room[x-1][y].dirSend
		formerAccept = room[x-1][y].dirAccept
		--powered[x-1][y] = 1
		if room[x][y].dirSend[1]==1 and room[x][y].powered then
			room[x-1][y].poweredNeighbors[3] = 1
		else
			room[x-1][y].poweredNeighbors[3] = 0
		end
		room[x-1][y]:updateTileAndOverlay(3)
		if room[x-1][y].powered ~= formerPowered or room[x-1][y].dirSend ~= formerSend or room[x-1][y].dirAccept ~= formerAccept then
			powerTestSpecial(x-1,y,3)
		end
	end


	if x<roomHeight and room[x+1][y]~=nil and room[x+1][y].name~="notGate" and canBePowered(x+1,y,1) and lastDir~=3 then
		--powered[x+1][y] = 1
		formerPowered = room[x+1][y].powered
		formerSend = room[x+1][y].dirSend
		formerAccept = room[x+1][y].dirAccept
		if room[x][y].dirSend[3]==1 and room[x][y].powered then
			room[x+1][y].poweredNeighbors[1] = 1
		else
			room[x+1][y].poweredNeighbors[1] = 0
		end
		room[x+1][y]:updateTileAndOverlay(1)
		if room[x+1][y].powered ~= formerPowered or room[x+1][y].dirSend ~= formerSend or room[x+1][y].dirAccept ~= formerAccept then
			powerTestSpecial(x+1,y,1)
		end
	end

	if y>1 and room[x][y-1]~=nil and room[x][y-1].name~="notGate" and canBePowered(x,y-1,2) and lastDir~=4 then
		formerPowered = room[x][y-1].powered
		formerSend = room[x][y-1].dirSend
		formerAccept = room[x][y-1].dirAccept
		--powered[x][y-1] = 1
		if room[x][y].dirSend[4]==1 and room[x][y].powered then
			room[x][y-1].poweredNeighbors[2] = 1
		else
			room[x][y-1].poweredNeighbors[2] = 0
		end
		room[x][y-1]:updateTileAndOverlay(2)
		if room[x][y-1].powered ~= formerPowered or room[x][y-1].dirSend ~= formerSend or room[x][y-1].dirAccept ~= formerAccept then
			powerTestSpecial(x, y-1, 2)
		end
	end

	if y<roomLength and room[x][y+1]~=nil and room[x][y+1].name~="notGate" and canBePowered(x,y+1,4) and lastDir~=2 then
		formerPowered = room[x][y+1].powered
		formerSend = room[x][y+1].dirSend
		formerAccept = room[x][y+1].dirAccept
		--powered[x][y+1] = 1
		if room[x][y].dirSend[2]==1 and room[x][y].powered then
			room[x][y+1].poweredNeighbors[4] = 1
		else
			room[x][y+1].poweredNeighbors[4] = 0
		end
		room[x][y+1]:updateTileAndOverlay(4)
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
	if not started and not charSelect then
		love.graphics.draw(startscreen, 0, 0, 0, width/startscreen:getWidth(), height/startscreen:getHeight())
		if seedOverride ~= nil then
			love.graphics.setColor(0,255,0,255)
			love.graphics.print(seedOverride, 0, 100)
			love.graphics.setColor(255,255,255,255)
		end
		return
	elseif charSelect then
		love.graphics.setColor(150, 200, 0)
		love.graphics.rectangle("fill", selectedBox.x*width/5, selectedBox.y*height/3, width/5, height/3)
		love.graphics.setColor(255, 255, 255)
		for i = 1, 2 do
			love.graphics.line(0, height/3*i, width, height/3*i)
		end
		for i = 1, 4 do
			love.graphics.line(width/5*i, 0, width/5*i, height)
		end

		local charsToDraw = characters.getUnlockedCharacters()
		for i = 1, #charsToDraw do
			local row = math.floor((i+4)/5)
			local column = i%5
			if column==0 then column=5 end
			love.graphics.draw(charsToDraw[i].sprite, width/5*column-width/10-10, height/3*(row-1)+height/6+20, 0, charsToDraw[i].scale, charsToDraw[i].scale)
			love.graphics.print(charsToDraw[i].name, width/5*column-width/10-10, height/3*(row-1)+height/6-100)
			love.graphics.print(charsToDraw[i].description, width/5*column-width/10-10, height/3*(row-1)+height/6-80)
		end

		return
	end

	--love.graphics.translate(width2/2-16*screenScale/2, height2/2-9*screenScale/2)
	love.graphics.translate((width2-width)/2, (height2-height)/2)
	local bigRoomTranslation = getTranslation()
	love.graphics.translate(bigRoomTranslation.x*floor.sprite:getWidth()*scale, bigRoomTranslation.y*floor.sprite:getHeight()*scale)
	--love.graphics.draw(rocks, rocksQuad, 0, 0)
	--love.graphics.draw(rocks, -mapx * width, -mapy * height, 0, 1, 1)


	for i = 1, roomLength do
		for j = 1, roomHeight do
			love.graphics.draw(floortile, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height,
			0, scale*16/floortile:getWidth(), scale*16/floortile:getWidth())
		end
	end

	for i = 1, roomLength do
		if not (i==math.floor(roomLength/2) or i==math.floor(roomLength/2)+1) then
			love.graphics.draw(topwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(-1)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
		else
			if mapy<=0 or mainMap[mapy-1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy-1][mapx]==0) then
				love.graphics.draw(topwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(-1)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
			end	
		end
	end

	for j = 1, roomHeight do
		for i = 1, roomLength do
			if (room[j][i]~=nil and room[j][i].isVisible) or litTiles[j][i]==0 then
				if room[j][i]~=nil then room[j][i]:updateSprite() end
				local rot = 0
				local tempi = i
				local tempj = j
				if j <= table.getn(room) or i <= table.getn(room[0]) then
					if litTiles[j][i] == 0 then
						toDraw = black
					elseif room[j][i]~=nil and (room[j][i].powered == false or not room[j][i].canBePowered) then
						toDraw = room[j][i].sprite
						rot = room[j][i].rotation
					elseif room[j][i]~=nil then
						toDraw = room[j][i].poweredSprite
						rot = room[j][i].rotation
					--else
						--toDraw = floortile
					end
					if room[j][i]~=nil and room[j][i]:getYOffset()~=0 then rot = 0 end
					if rot == 1 or rot == 2 then
						tempi = tempi + 1
					end
					if rot == 2 or rot == 3 then
						tempj = tempj + 1
					end
				end
				if (room[j][i]~=nil --[[and room[j][i].name~="pitbull" and room[j][i].name~="cat" and room[j][i].name~="pup"]]) or litTiles[j][i]==0 then
					local addY = 0
					if room[j][i]~=nil and litTiles[j][i]~=0 then
						addY = room[j][i]:getYOffset()
					end
					love.graphics.draw(toDraw, (tempi-1)*floor.sprite:getWidth()*scale+wallSprite.width, (addY+(tempj-1)*floor.sprite:getWidth())*scale+wallSprite.height,
					  rot * math.pi / 2, scale*16/toDraw:getWidth(), scale*16/toDraw:getWidth())
					if litTiles[j][i]~=0 and room[j][i].overlay ~= nil then
						local overlay = room[j][i].overlay
						local toDraw2 = overlay.powered and overlay.poweredSprite or overlay.sprite
						local rot2 = overlay.rotation
						local tempi2 = i
						local tempj2 = j
						local addY2 = overlay:getYOffset() + addY
						--if addY2~=0 then rot2 = 0 end
						if rot2 == 1 or rot2 == 2 then
							tempi2 = tempi2 + 1
						end
						if rot2 == 2 or rot2 == 3 then
							tempj2 = tempj2 + 1
						end
						love.graphics.draw(toDraw2, (tempi2-1)*floor.sprite:getWidth()*scale+wallSprite.width, (addY2+(tempj2-1)*floor.sprite:getWidth())*scale+wallSprite.height,
						  rot2 * math.pi / 2, scale*16/toDraw:getWidth(), scale*16/toDraw:getWidth())
						if room[j][i].dirSend[3] == 1 or room[j][i].dirAccept[3] == 1 or (overlay.dirWireHack ~= nil and overlay.dirWireHack[3] == 1) then
							local toDraw3
							if room[j][i].powered and (room[j][i].dirSend[3] == 1 or room[j][i].dirAccept[3] == 1) then
								toDraw3 = room[j][i].overlay.wireHackOn
							else
								toDraw3 = room[j][i].overlay.wireHackOff
							end
							love.graphics.draw(toDraw3, (tempi-1)*floor.sprite:getWidth()*scale+wallSprite.width, (addY+(tempj)*floor.sprite:getWidth())*scale+wallSprite.height,
							  0, scale*16/toDraw3:getWidth(), -1*addY/toDraw3:getHeight()*(scale*16/toDraw3:getWidth()))
						end
					end
					if room[j][i]~=nil and room[j][i]:getInfoText()~=nil then
						love.graphics.setColor(0,0,0)
						love.graphics.print(room[j][i]:getInfoText(), (tempi-1)*floor.sprite:getWidth()*scale+wallSprite.width, (tempj-1)*floor.sprite:getHeight()*scale+wallSprite.height);
						love.graphics.setColor(255,255,255)
					end
				end
			end
		end
		for i = 1, #animals do
			if animals[i]~=nil and litTiles[animals[i].tileY][animals[i].tileX]==1 and not animals[i].pickedUp and animals[i].tileY==j then
				animals[i].x = (animals[i].tileX-1)*floor.sprite:getHeight()*scale+wallSprite.width
		    	animals[i].y = (animals[i].tileY-1)*floor.sprite:getWidth()*scale+wallSprite.height
				love.graphics.draw(animals[i].sprite, animals[i].x, animals[i].y, 0, scale, scale)
			end
		end

		for i = 1, #pushables do
			if pushables[i]~=nil and not pushables[i].destroyed and litTiles[pushables[i].tileY][pushables[i].tileX]==1 and pushables[i].tileY==j then
		    	pushablex = (pushables[i].tileX-1)*floor.sprite:getHeight()*scale+wallSprite.width
		    	pushabley = (pushables[i].tileY-1)*floor.sprite:getWidth()*scale+wallSprite.height
		    	if pushables[i].conductive and pushables[i].powered then toDraw = pushables[i].poweredSprite
		    	else toDraw = pushables[i].sprite end
				love.graphics.draw(toDraw, pushablex, pushabley, 0, scale, scale)
			end
		end
		if tools.toolableAnimals~=nil then
			for dir = 1, 5 do
				if tools.toolableAnimals[dir]~=nil then
					for i = 1, #(tools.toolableAnimals[dir]) do
						local tx = tools.toolableAnimals[dir][i].tileX
						local ty = tools.toolableAnimals[dir][i].tileY
						if ty==j then
							if dir == 1 or tools.toolableAnimals[1][1] == nil or not (tx == tools.toolableAnimals[1][1].tileX and ty == tools.toolableAnimals[1][1].tileY) then
								love.graphics.draw(green, (tx-1)*floor.sprite:getWidth()*scale+wallSprite.width, (ty-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
							end
						end
					end
				end
			end
		end
		if tools.toolablePushables~=nil then
			for dir = 1, 5 do
				if tools.toolablePushables[dir]~=nil then
					for i = 1, #(tools.toolablePushables[dir]) do
						local tx = tools.toolablePushables[dir][i].tileX
						local ty = tools.toolablePushables[dir][i].tileY
						if ty==j then
							if dir == 1 or tools.toolablePushables[1][1] == nil or not (tx == tools.toolablePushables[1][1].tileX and ty == tools.toolablePushables[1][1].tileY) then
								love.graphics.draw(green, (tx-1)*floor.sprite:getWidth()*scale+wallSprite.width, (ty-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
							end
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
					if ty==j then
						local addY = 0
						local yScale = scale
						if room[ty][tx]~=nil and litTiles[ty][tx]~=0 then
							addY = room[ty][tx]:getYOffset()
							yScale = scale*(16-addY)/16
						else addY=0 end
						if dir == 1 or tools.toolableTiles[1][1] == nil or not (tx == tools.toolableTiles[1][1].x and ty == tools.toolableTiles[1][1].y) then
							love.graphics.draw(green, (tx-1)*floor.sprite:getWidth()*scale+wallSprite.width, (addY+(ty-1)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale, yScale)
						end
					end
				end
			end
		end
		--love.graphics.draw(walls, 0, 0, 0, width/walls:getWidth(), height/walls:getHeight())
	end

	for i = 1, roomLength do
		if not (i==math.floor(roomLength/2) or i==math.floor(roomLength/2)+1) then
			love.graphics.draw(bottomwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(roomHeight)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale, scale)
		else
			if mapy>=mapHeight or mainMap[mapy+1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy+1][mapx]==0) then
				love.graphics.draw(bottomwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(roomHeight)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale, scale)
			end		
		end
	end
	for i = 1, roomHeight do
		if not (i==math.floor(roomHeight/2) or i==math.floor(roomHeight/2)+1) then		
			love.graphics.draw(bottomwall, (0)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(i-1)*floor.sprite:getHeight())*scale+wallSprite.height, math.pi/2, scale, scale)
			love.graphics.draw(bottomwall, (roomLength)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(i)*floor.sprite:getHeight())*scale+wallSprite.height, -1*math.pi/2, scale, scale)
		else
			if mapx>=mapHeight or mainMap[mapy][mapx+1]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx+1]==0) then
				love.graphics.draw(bottomwall, (roomLength)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(i)*floor.sprite:getHeight())*scale+wallSprite.height, -1*math.pi/2, scale, scale)
			end
			if mapx<=0 or mainMap[mapy][mapx-1]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx-1]==0) then
				love.graphics.draw(bottomwall, (0)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(i-1)*floor.sprite:getHeight())*scale+wallSprite.height, math.pi/2, scale, scale)
			end
		end
	end
	for i = 1, 4 do
		local cornerX, cornerY
		if i == 1 then
			cornerX = 0
			cornerY = 1
		elseif i == 2 then
			cornerX = roomLength+1
			cornerY = 0
		elseif i == 3 then
			cornerX = roomLength+2
			cornerY = roomHeight+1
		elseif i == 4 then
			cornerX = 1
			cornerY = roomHeight+2
		end
		love.graphics.draw(cornerwall, (cornerX-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(cornerY-1)*floor.sprite:getHeight())*scale+wallSprite.height, (i-2)*math.pi/2, scale, scale)
	end

	player.x = (player.tileX-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
	player.y = (player.tileY-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
	love.graphics.draw(player.character.sprite, player.x-player.character.sprite:getWidth()*player.character.scale/2, player.y-player.character.sprite:getHeight()*player.character.scale, 0, player.character.scale, player.character.scale)

	if tools.toolDisplayTimer.timeLeft > 0 then
		local toolWidth = tools[1].image:getWidth()
		local toolScale = player.character.sprite:getWidth() * player.character.scale/toolWidth
		for i = 1, #tools.toolsShown do
			love.graphics.draw(tools[tools.toolsShown[i]].image, (i-math.ceil(#tools.toolsShown)/2-1)*toolScale*toolWidth+player.x, player.y - player.character.sprite:getHeight()*player.character.scale - tools[1].image:getHeight()*toolScale, 0, toolScale, toolScale)
		end
	end

	if player.character.name == "Giovanni" and player.character.shiftPos.x>0 then
		local playerx = (player.character.shiftPos.x-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
		local playery = (player.character.shiftPos.y-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
		love.graphics.draw(player.character.sprite2, playerx-player.character.sprite:getWidth()*player.character.scale/2, playery-player.character.sprite:getHeight()*player.character.scale, 0, player.character.scale, player.character.scale)
	end

	--everything after this will be drawn regardless of bigRoomTranslation (i.e., translation is undone in following line)
	love.graphics.translate(-1*bigRoomTranslation.x*floor.sprite:getWidth()*scale, -1*bigRoomTranslation.y*floor.sprite:getHeight()*scale)

	if not loadTutorial then
		love.graphics.print(math.floor(gameTime.timeLeft), width/2-10, 20);
	end
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
						if map.getFieldForRoom(currentid, 'minimapColor') ~= nil then
							love.graphics.setColor(map.getFieldForRoom(currentid, 'minimapColor'))
						end
					else
						love.graphics.setColor(100,100,100)
					end
				end
				local minimapScale = 8/mapHeight
				love.graphics.rectangle("fill", width - minimapScale*18*(mapHeight-j+1), minimapScale*9*i, minimapScale*18, minimapScale*9 )
				if player.character.name == "Francisco" and
				i==player.character.nextRoom.yLoc and j==player.character.nextRoom.xLoc then
					love.graphics.setColor(255, 0, 0)
					love.graphics.rectangle("fill", width - minimapScale*18*(mapHeight-j+1), minimapScale*9*i, minimapScale*9, minimapScale*4 )
				end
			else
				--love.graphics.setColor(255,255,255)
				--love.graphics.rectangle("line", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			end
		end
	end
	if not editorMode then
		for i = 0, 6 do
			love.graphics.setColor(255,255,255)
			if tool == i+1 then
				love.graphics.setColor(50, 200, 50)
			end
			love.graphics.rectangle("fill", i*width/18, 0, width/18, width/18)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", i*width/18, 0, width/18, width/18)
			love.graphics.setColor(255,255,255)
			local image = tools[i+1].image
			love.graphics.draw(image, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
			if tools[i+1].numHeld==0 then
				love.graphics.draw(gray, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
			end
			love.graphics.setColor(0,0,0)
			love.graphics.print(tools[i+1].numHeld, i*width/18+3, 0)
			love.graphics.print(i+1, i*width/18+7, (width/18)-20)
			love.graphics.circle("line", i*width/18+10, (width/18)-15, 9, 50)
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
				love.graphics.print(i+8, (i+13)*width/18+7, (width/18)-20)
				love.graphics.circle("line", (i+13)*width/18+10, (width/18)-15, 9, 50)
			end
		end
	end
	love.graphics.setColor(255,255,255)
	if player.dead then
		love.graphics.draw(deathscreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
	end
	if won then
		love.graphics.draw(winscreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
	end
	if gamePaused then
		--love.graphics.draw(pausescreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
		love.graphics.draw(pausescreen, 0, 0, 0, width/pausescreen:getWidth(), height/pausescreen:getHeight())
	end

	if messageInfo.text~=nil then
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle("fill", width/2-200, 100, 400, 100)
		love.graphics.setColor(0,0,0,255)
		love.graphics.print(messageInfo.text, width/2-180, 110)
		love.graphics.setColor(255,255,255,255)
	end

	--Display unlock screen
	if unlocks.unlocksDisplay.timeLeft > 0 then
		local unlock = unlocks[unlocks.unlocksDisplay.unlockToShow]
		local tScale = tiles[1].sprite:getWidth()/math.max(unlock.sprite:getWidth(), unlock.sprite:getHeight())
		local uScale = width/500
		local offsetY = (unlocks.frame:getHeight() - unlock.sprite:getHeight()*tScale)/2
		local offsetX = (unlocks.frame:getWidth() - unlock.sprite:getWidth()*tScale)/2
		love.graphics.draw(unlocks.frame, 0, height-unlocks.frame:getHeight()*uScale, 0, uScale, uScale)
		love.graphics.draw(unlock.sprite, offsetX*uScale, height-(unlock.sprite:getHeight()*tScale+offsetY)*uScale, 0, uScale*tScale, uScale*tScale)
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
	if loadTutorial then
		tutorial.draw()
	end
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 5, height-2.5*width/30, barLength, 15)
	love.graphics.setColor(255,255,255)
	love.graphics.print(botText, 10, height-2.5*width/30)
	if debugText ~= nil then
		love.graphics.setColor(0,255,0,255)
		love.graphics.print(debugText, 0, 100)
		love.graphics.setColor(255,255,255,255)
	end
end

translation = {x = 0, y = 0}
function getTranslation()
	--[[translation.x = translation.x*-1
	translation.y = translation.y*-1	
	if roomLength>regularLength then
		--those 3s are hacky af
		if player.tileX < translation.x - 2 then
			translation.x = translation.x - regularLength
		elseif player.tileX > translation.x + regularLength + 3 then
			translation.x = translation.x + regularLength
		end
		if translation.x > roomLength - regularLength then
			translation.x = roomLength-regularLength
		elseif translation.x < 0 then
			translation.x = 0
		end
	elseif roomLength<regularLength then
		local lengthDiff = regularLength-roomLength
		translation.x = -1*math.floor(lengthDiff/2)
	end
	if roomHeight>regularHeight then
		if player.tileY < translation.y - 2 then
			translation.y = translation.y - regularHeight
		elseif player.tileY > translation.y + regularHeight + 3 then
			translation.y = translation.y + regularHeight
		end
		if translation.y > roomHeight - regularHeight then
			translation.y = roomHeight-regularHeight
		elseif translation.y < 0 then
			translation.y = 0
		end
	elseif roomHeight<regularHeight then
		local heightDiff = regularHeight-roomHeight
		translation.y = -1*math.floor(heightDiff/2)
	end		
	translation.x = translation.x*-1
	translation.y = translation.y*-1	
	return translation]]
	translation = {x = 0, y = 0}
	if roomLength>regularLength then
		translation.x = player.tileX-1-regularLength/2
		if translation.x > roomLength - regularLength then translation.x = roomLength - regularLength end
		if translation.x < 0 then translation.x = 0 end
	elseif roomLength<regularLength then
		local lengthDiff = regularLength-roomLength
		translation.x = -1*math.floor(lengthDiff/2)
	end
	if roomHeight>regularHeight then
		translation.y = player.tileY-1-regularHeight/2
		if translation.y > roomHeight - regularHeight then translation.y = roomHeight - regularHeight end
		if translation.y < 0 then translation.y = 0 end
	elseif roomHeight<regularHeight then
		local heightDiff = regularHeight-roomHeight
		translation.y = -1*math.floor(heightDiff/2)
	end
	translation.x = translation.x*-1
	translation.y = translation.y*-1
	return translation
end

function resetTranslation()
	translation = {x = 0, y = 0}
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
	resetTranslation()
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
	roomHeight = room.height
	roomLength = room.length
	if player.tileX>roomLength then player.tileX = roomLength end
	if player.tileY>roomHeight then player.tileY = roomHeight end
	updateGameState(false)
	createAnimals()
	createPushables()
	return true
end

function createAnimals()
	animalCounter = 1
	--if room.animals~=nil then animals = room.animals return end
	animals = {}
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name~=nil and (room[i][j].animal~=nil) then
				animalToSpawn = room[i][j].animal
				if not animalToSpawn.dead then
					animals[animalCounter] = animalToSpawn
					if not animalToSpawn.loaded then
						animalToSpawn.triggered = false
						animalToSpawn.y = (i-1)*floor.sprite:getWidth()*scale+wallSprite.height
						animalToSpawn.x = (j-1)*floor.sprite:getHeight()*scale+wallSprite.width
						animalToSpawn.tileX = j
						animalToSpawn.tileY = i
						animalToSpawn.prevTileX = j
						animalToSpawn.prevTileY = i
						animalToSpawn.loaded = true
					end
					animalCounter=animalCounter+1
					--room[i][j] = nil
				end
			end
		end
	end
end

function createPushables()
	if room.pushables~=nil then pushables = room.pushables return end
	pushables = {}
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name~=nil and room[i][j].pushable~=nil then
				pushableToSpawn = pushableList[room[i][j].listIndex]:new()
				--pushableToSpawn = room[i][j].pushable
				if not pushableToSpawn.destroyed then
					index = #pushables+1
					pushables[index] = pushableToSpawn
					pushables[index].tileY = i
					pushables[index].tileX = j
					pushables[index].prevTileX = pushables[index].tileX
					pushables[index].prevTileY = pushables[index].tileY
				end
			end
		end
	end
end

function enterRoom(dir)
	log("")
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
	if dir == 0 then
		if mapy>0 and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy-1][mapx]==0) then
			if mainMap[mapy-1][mapx]~=nil then
				mapy = mapy-1
				room = mainMap[mapy][mapx].room
				roomHeight = room.height
				roomLength = room.length
				--player.y = height-wallSprite.heightBottom-5
				player.tileY = roomHeight
				if plusOne then player.tileX = math.floor(roomLength/2)+1
				else player.tileX = math.floor(roomLength/2) end
				player.prevTileY = player.tileY
				player.prevTileX = player.tileX
			end
		end
	elseif dir == 1 then
		if mapx<mapHeight and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx+1]==0)then
			if mainMap[mapy][mapx+1]~=nil then
				mapx = mapx+1
				room = mainMap[mapy][mapx].room
				roomHeight = room.height
				roomLength = room.length
				--player.x = wallSprite.width+5
				player.tileX = 1
				if plusOne then player.tileY = math.floor(roomHeight/2)+1
				else player.tileY = math.floor(roomHeight/2) end
				player.prevTileX = player.tileX
				player.prevTileY = player.tileY
			end
		end
	elseif dir == 2 then
		if mapy<mapHeight and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy+1][mapx]==0) then
			if mainMap[mapy+1][mapx]~=nil then
				mapy = mapy+1
				room = mainMap[mapy][mapx].room
				roomHeight = room.height
				roomLength = room.length
				--player.y = wallSprite.height+player.height+5
				if plusOne then player.tileX = math.floor(roomLength/2)+1
				else player.tileX = math.floor(roomLength/2) end
				player.tileY = 1
				player.prevTileY = player.tileY
				player.prevTileX = player.tileX
			end
		end
	elseif dir == 3 then
		if mapx>0 and not (completedRooms[mapy][mapx]==0 and completedRooms[mapy][mapx-1]==0) then
			if mainMap[mapy][mapx-1]~=nil then
				mapx = mapx-1
				room = mainMap[mapy][mapx].room
				roomHeight = room.height
				roomLength = room.length
				--player.x = width-wallSprite.width-player.width-5
				player.tileX = roomLength
				if plusOne then player.tileY = math.floor(roomHeight/2)+1
				else player.tileY = math.floor(roomHeight/2) end
				player.prevTileX = player.tileX
				player.prevTileY = player.tileY
			end
		end
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
	updateGameState(false)
	tutorial.enterRoom()
end

oldTilesOn = {}

function enterMove()
	if room[player.tileY][player.tileX]~=nil then
		if player.prevTileY == player.tileY and player.prevTileX == player.tileX then
			room[player.tileY][player.tileX]:onStay(player)
		else
			player.character:preTileEnter(room[player.tileY][player.tileX])
			room[player.tileY][player.tileX]:onEnter(player)
		end
	end

	if not (player.prevTileY == player.tileY and player.prevTileX == player.tileX) then
		for i = 1, #pushables do
			if pushables[i].tileX == player.tileX and pushables[i].tileY == player.tileY then
				if not pushables[i]:playerCanMove() or not pushables[i]:move(player) then
					player.tileX = player.prevTileX
					player.tileY = player.prevTileY
				end
			end
		end
	end

	if not (player.prevTileY == player.tileY and player.prevTileX == player.tileX) then
		if room~=nil and room[player.prevTileY][player.prevTileX]~=nil then
			room[player.prevTileY][player.prevTileX]:onLeave(player)
		end
		player.character.onTileLeave()
	end
end

keyTimer = {base = .05, timeLeft = .05, suicideDelay = .5}
function love.update(dt)
	if gamePaused then
		return
	end
	if loadTutorial then
		tutorial.update(dt)
	end
	--key press
	keyTimer.timeLeft = keyTimer.timeLeft - dt
	tools.updateTimer(dt)
	unlocks.updateTimer(dt)
	if room~=nil and room[player.tileY] ~= nil and room[player.tileY][player.tileX] ~= nil and room[player.tileY][player.tileX].updateTime ~= nil then
		room[player.tileY][player.tileX]:updateTime(dt)
	end

	--game timer
	if started and completedRooms[mapy][mapx]~=1 then
		gameTime.timeLeft = gameTime.timeLeft-dt
	end
	if gameTime.timeLeft<=0 and not loadTutorial then
		kill()
	end
end

function love.textinput(text)
	editor.textinput(text)
	seedEnter(text)
end

function seedEnter(text)
	if enteringSeed then
		if seedOverride == nil then
			seedOverride = ''
		end
		if tonumber(text) ~= nil then
			seedOverride = seedOverride..text
		end
	end
end

function love.keypressed(key, unicode)
	if enteringSeed then
		if key == 'backspace' and seedOverride ~= nil then
			seedOverride = seedOverride:sub(1, -2)
		end
		if key == 'tab' or key == 'return' then
			enteringSeed = false
		end
		return
	end
	if charSelect then
		local charsToSelect = characters.getUnlockedCharacters()
		if key == "return" then
			--enter in selected character
			charSelect = false
			started = true
			local charNum = 1
			charNum = charNum+5*selectedBox.y
			charNum = charNum+selectedBox.x
			if charNum > #characters then
				charNum = #characters
			end
			player.character = charsToSelect[charNum]
			player.character:onBegin()
			loadFirstLevel()
		elseif key == "up" then
			if selectedBox.y>0 then
				selectedBox.y = selectedBox.y-1
			end
		elseif key == "down" then
			if selectedBox.y<2 then
				selectedBox.y = selectedBox.y+1
			end
		elseif key == "left" then
			if selectedBox.x>0 then
				selectedBox.x = selectedBox.x-1
			end
		elseif key == "right" then
			if selectedBox.x<4 then
				selectedBox.x = selectedBox.x+1
			end
		end
	end

	if not started then
		if charSelect then return end
		if key=="s" then
			startGame()
			return
		elseif key == "t" then
			startTutorial()
			return
		elseif key=="e" then
			startDebug()
			return
		elseif key=="tab" then
			enteringSeed = true
		end
		return
	end

	if gamePaused then
		if key=="escape" then
			gamePaused = false
		elseif key=="m" then
			started = false
		end
		return
	end
	if won then
		if key=="m" then
			started = false
		end
	end

	if editor.stealInput then
		editor.inputSteal(key, unicode)
		return
	end
	if key=="escape" then
		gamePaused = true
	end
	if key=="e" then
		editorMode = not editorMode
		gameTime.timeLeft = gameTime.timeLeft+20000
	end
	--[[if key=='t' then
		if toolMode == 1 then
			toolMode = 2
		else
			toolMode = 1
		end
	end]]

	--k ability: open doors with k on supertools
	--[[if key=="k" then
		if tool>tools.numNormalTools then
			tools[tool].numHeld = tools[tool].numHeld-1
			unlockDoors()
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
				for i = 1,tools.numNormalTools do
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
				loadFirstLevel()
				player.character:onBegin()
			end
		end
	end
	love.keyboard.setKeyRepeat(true)
    -- ignore non-printable characters (see http://www.ascii-code.com/)
    if player.dead and (key == "w" or key == "a" or key == "s" or key == "d") then
    	return
    end

	if keyTimer.timeLeft > 0 then
		return
	end
	keyTimer.timeLeft = keyTimer.base
	waitTurn = false

	if player.character:onKeyPressed(key) then
		updateGameState(false)
	end
   	if player.waitCounter<=0 then
		player.prevx = player.x
		player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
		if not map.blocksMovement(player.tileY, player.tileX) then
	    	if key == "w" then
	    		if player.tileY>1 then
	    			player.tileY = player.tileY-1
	    			player.y = player.y-floor.sprite:getHeight()*scale
				elseif player.tileY==1 and (player.tileX==math.floor(roomLength/2) or player.tileX==math.floor(roomLength/2)+1) then
					enterRoom(0)
				end
	    	elseif key == "s" then
	    		if player.tileY<roomHeight then
	    			player.tileY = player.tileY+1
	    			player.y = player.y+floor.sprite:getHeight()*scale
				elseif player.tileY == roomHeight and (player.tileX==math.floor(roomLength/2) or player.tileX==math.floor(roomLength/2)+1) then
					enterRoom(2)
	    		end
	    	elseif key == "a" then
	    		if player.tileX>1 then
	    			player.tileX = player.tileX-1
	    			player.x = player.x-floor.sprite:getHeight()*scale
				elseif player.tileX == 1 and (player.tileY==math.floor(roomHeight/2) or player.tileY==math.floor(roomHeight/2)+1) then
					enterRoom(3)
	    		end
	    	elseif key == "d" then
	    		if player.tileX<roomLength then
	    			player.tileX = player.tileX+1
	    			player.x = player.x+floor.sprite:getHeight()*scale
	    		elseif player.tileX == roomLength and (player.tileY==math.floor(roomHeight/2) or player.tileY==math.floor(roomHeight/2)+1) then
					enterRoom(1)
				end
			end
		end
	end
	if (key == "w" or key == "a" or key == "s" or key == "d") and player.waitCounter>0 then
		player.prevx = player.x
		player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
		waitTurn = true
    	player.waitCounter = player.waitCounter-1
    end
	if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" then
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
    if dirUse~=0 and tool>0 then
    	tools.updateToolableTiles(tool)
    end
    if dirUse ~= 0 and tool ~= 0 and tools[tool].useWithArrowKeys then
    	local usedTool = tools.useToolDir(tool, dirUse)
		--[[if usedTool and tool>tools.numNormalTools then
			gameTime = gameTime-100
		end]]
		if usedTool then player.character:onToolUse() end
		if usedTool and tool<=tools.numNormalTools then
			gameTime.timeLeft = gameTime.timeLeft+gameTime.toolTime
		end
		updateGameState(false)
		checkAllDeath()
	end
	noPowerUpdate = not player.character.forcePowerUpdate
    if (key=="w" or key=="a" or key=="s" or key=="d") then
    	for i = 1, roomHeight do
    		for j = 1, roomLength do
    			--what is the point of this?
    			if room[i][j]~=nil and room[i][j].name == "button" then
    				room[i][j].justPressed = false
    			end
    		end
    	end
    	enterMove()
    	if room[player.tileY][player.tileX]~=nil then
    		if room[player.tileY][player.tileX].updatePowerOnEnter then
    			noPowerUpdate = false
    		end
    	end
    	if room[player.prevTileY][player.prevTileX]~=nil then
    		if room[player.prevTileY][player.prevTileX].updatePowerOnLeave then
    			noPowerUpdate = false
    		end
    	end
		for i = 1, #pushables do
		 	if room[pushables[i].tileY][pushables[i].tileX]~=nil then
		 		if room[pushables[i].tileY][pushables[i].tileX].updatePowerOnEnter then
		 			noPowerUpdate = false
		 		end
		 	end
		 	if pushables[i].conductive and (pushables[i].tileY~=pushables[i].prevTileY or pushables[i].tileX~=pushables[i].prevTileX) then
		 		noPowerUpdate = false
		 	end
		 	if pushables[i].prevTileY~=nil and pushables[i].prevTileX~=nil and 
		 	room[pushables[i].prevTileY]~=nil and room[pushables[i].prevTileY][pushables[i].prevTileX]~=nil then
		 		if room[pushables[i].prevTileY][pushables[i].prevTileX].updatePowerOnLeave then
		 			noPowerUpdate = false
		 		end
		 	end
	    end
    	updateGameState(noPowerUpdate)
	    if player.tileY~=player.prevTileY or player.tileX~=player.prevTileX or waitTurn then
	    	stepTrigger()
	    	for k = 1, #animals do
				local ani = animals[k]
				if not map.blocksMovement(ani.tileY, ani.tileX) then
					local movex = ani.tileX
					local movey = ani.tileY
					if player.active then
						movex = player.tileX
						movey = player.tileY
					end
					local animalDist = math.abs(movey-ani.tileY)+math.abs(movex-ani.tileX)
					for i = 1, roomHeight do
						for j = 1, roomLength do
							if room[i][j]~=nil and room[i][j]:instanceof(tiles.meat) then
								if math.abs(i-ani.tileY)+math.abs(j-ani.tileX)<animalDist then
									animalDist = math.abs(i-ani.tileY)+math.abs(j-ani.tileX)
									movex = j
									movey = i
								end
							end
						end
					end
					for i = 1, #pushables do
						if pushables[i]:instanceof(pushableList.boombox) then
						    if math.abs(pushables[i].tileY-ani.tileY)+math.abs(pushables[i].tileX-ani.tileX)<animalDist then
								animalDist = math.abs(pushables[i].tileY-ani.tileY)+math.abs(pushables[i].tileX-ani.tileX)
								movex = pushables[i].tileX
								movey = pushables[i].tileY
							end
						end
					end
					ani:move(movex, movey, room, litTiles[ani.tileY][ani.tileX]==1)
				end
				if room[ani.tileY][ani.tileX]~=nil then
					if room[ani.tileY][ani.tileX].updatePowerOnEnter then
						noPowerUpdate = false
					end
				end
				if room[ani.prevTileY][ani.prevTileX]~=nil then
					if room[ani.prevTileY][ani.prevTileX].updatePowerOnLeave then
						noPowerUpdate = false
					end
				end
				if ani:instanceof(animalList.conductiveSnail) and (ani.tileX~=ani.prevTileX or ani.tileY~=ani.prevTileY) then
					noPowerUpdate = false
				end
			end   	
	    	postAnimalMovement()
			for i = 1, #pushables do
		    	if room[pushables[i].tileY][pushables[i].tileX]~=nil then
		    		if room[pushables[i].tileY][pushables[i].tileX].updatePowerOnEnter then
		    			noPowerUpdate = false
		    		end
		    	end
		    	if pushables[i].conductive and (pushables[i].tileY~=pushables[i].prevTileY or pushables[i].tileX~=pushables[i].prevTileX) then
		    		noPowerUpdate = false
		    	end
		    	if pushables[i].prevTileY~=nil and pushables[i].prevTileX~=nil and 
		    	room[pushables[i].prevTileY]~=nil and room[pushables[i].prevTileY][pushables[i].prevTileX]~=nil then
		    		if room[pushables[i].prevTileY][pushables[i].prevTileX].updatePowerOnLeave then
		    			noPowerUpdate = false
		    		end
		    	end
		    	if pushables[i].conductive and (pushables[i].tileX~=pushables[i].prevTileX or pushables[i].tileY~=pushables[i].prevTileY) then
		    		noPowerUpdate = false
		    	end
	    	end
		end
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
    updateGameState(noPowerUpdate)
    resetTileStates()
    checkAllDeath()
end

function postAnimalMovement()
	resolveConflicts()
	for i = 1, #animals do
		animals[i].x = (animals[i].tileX-1)*floor.sprite:getHeight()*scale+wallSprite.width
		animals[i].y = (animals[i].tileY-1)*floor.sprite:getWidth()*scale+wallSprite.height
		if animals[i]:hasMoved() and not animals[i].dead then
			if room[animals[i].prevTileY]~=nil and room[animals[i].prevTileY][animals[i].prevTileX]~=nil then
				room[animals[i].prevTileY][animals[i].prevTileX]:onLeaveAnimal(animals[i])
				if room[animals[i].prevTileY][animals[i].prevTileX]:instanceof(tiles.wire) and
				room[animals[i].prevTileY][animals[i].prevTileX].destroyed then
					if animals[i]:onNullLeave()~=nil then
					room[animals[i].prevTileY][animals[i].prevTileX] = animals[i]:onNullLeave()
					end
				end
			elseif animals[i]:onNullLeave()~=nil then
				room[animals[i].prevTileY][animals[i].prevTileX] = animals[i]:onNullLeave()
			end
		end
	end
	resetAnimals()
	for i = 1, #animals do
		if animals[i]:hasMoved() and not animals[i].dead then
			if room[animals[i].tileY][animals[i].tileX]~=nil then
				room[animals[i].tileY][animals[i].tileX]:onEnterAnimal(animals[i])
			end
		elseif room[animals[i].tileY][animals[i].tileX]~=nil then
			room[animals[i].tileY][animals[i].tileX]:onStayAnimal(animals[i])
		end
	end
end

function resetAnimals()
	for i = 1, #animals do
		if animals[i].waitCounter>0 then
			animals[i].waitCounter = animals[i].waitCounter-1
		end
	end
end

function resolveConflicts()
	local firstRun = true
	conflicts = true
	while conflicts do
		for i = 1, #animals do
			for j = 1, i-1 do
				if (not animals[i].dead) and (not animals[j].dead) and animals[i].tileX == animals[j].tileX and animals[i].tileY == animals[j].tileY then
					if animals[i].tileX~=animals[i].prevTileX then
						animals[i].tileX = animals[i].prevTileX
					elseif animals[i].tileY~=animals[i].prevTileY then
						animals[i].tileY = animals[i].prevTileY
					elseif animals[j].tileX~=animals[j].prevTileX then
						animals[j].tileX = animals[j].prevTileX
					elseif animals[j].tileY~=animals[j].prevTileY then
						animals[j].tileY = animals[j].prevTileY
					end
				end
			end
		end

		--code below semi-fixes animal "bouncing" -- kind of hacky
		if firstRun then
			for i = 1, #animals do
				if animals[i].tileX==animals[i].prevTileX and animals[i].tileY==animals[i].prevTileY then
					tryMove = true
					if animals[i].dead or not animals[i].triggered then
						tryMove = false
					end
					if animals[i].waitCounter>0 then
						tryMove = false
					end
					if not animals[i]:instanceof(animalList.cat) and player.tileX-animals[i].tileX==0 and player.tileY-animals[i].tileY==0 then
						tryMove = false
					end
					if tryMove and litTiles[animals[i].tileY][animals[i].tileX]~=0 then
						local movex = animals[i].tileX
						local movey = animals[i].tileY
						if player.active then
							movex = player.tileX
				    		movey = player.tileY
				    	end
			    		local animalDist = math.abs(movey-animals[i].tileY)+math.abs(movex-animals[i].tileX)
			    		for j = 1, roomHeight do
			    			for k = 1, roomLength do
			    				if room[j][k]~=nil and room[j][k]:instanceof(tiles.meat) then
			    					if math.abs(j-animals[i].tileY)+math.abs(k-animals[i].tileX)<animalDist then
			    						animalDist = math.abs(j-animals[i].tileY)+math.abs(k-animals[i].tileX)
			    						movex = k
			    						movey = j
			    					end
			    				end
			    			end
			    		end
			    		for j = 1, #pushables do
			    			if pushables[j]:instanceof(pushableList.boombox) then
							    if math.abs(pushables[j].tileY-animals[i].tileY)+math.abs(pushables[j].tileX-animals[i].tileX)<animalDist then
									animalDist = math.abs(pushables[j].tileY-animals[i].tileY)+math.abs(pushables[j].tileX-animals[i].tileX)
									movex = pushables[j].tileX
									movey = pushables[j].tileY
								end
			    			end
			    		end
						animals[i]:secondaryMove(movex, movey)
					end
				end
			end
		end

		conflicts = false
		for i = 1, #animals do
			for j = 1, i-1 do
				if (not animals[i].dead) and (not animals[j].dead) and animals[i].tileX == animals[j].tileX and animals[i].tileY == animals[j].tileY then
					conflicts = true
					firstRun = false
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
		if t:willKillPlayer() and not player.flying then
			kill()
		end
	end
	for i = 1, #animals do
		if animals[i]:willKillPlayer(player) and not player.safeFromAnimals then
			kill()
		end
	end
	if player.dead then
		for i = 1, #tools do
			if not tools[i]:checkDeath() then
				player.dead = false
				for i = 1, tools.numNormalTools do
					tools[i].numHeld = 0
				end
				for i = 1, roomHeight do
					for j = 1, roomLength do
						if room[i][j]~=nil then
							if not room[i][j]:instanceof(tiles.endTile) then
								room[i][j]=tiles.invisibleTile:new()
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
				updateGameState(false)
				log("Revived!")
				break
			end
		end
	end
end

function love.mousepressed(x, y, button, istouch)
	mouseDown = true

	if charSelect then
		selectedBox.y = math.floor(y/(height/3))
		selectedBox.x = math.floor(x/(width/5))
		return
	end

	if gamePaused then
		return
	end

	if not started then
		return
	end

	local bigRoomTranslation = getTranslation()
	tileLocX = math.ceil((mouseX-wallSprite.width)/(scale*floor.sprite:getWidth()))-bigRoomTranslation.x
	tileLocY = math.ceil((mouseY-wallSprite.height)/(scale*floor.sprite:getHeight()))-bigRoomTranslation.y
	if room[tileLocY+1] ~= nil and room[tileLocY+1][tileLocX] ~= nil then
		tileLocY = math.ceil((mouseY-wallSprite.height-room[tileLocY+1][tileLocX]:getYOffset()*scale)/(scale*floor.sprite:getHeight()))-bigRoomTranslation.y
	end

	if editorMode then
		editor.mousepressed(x, y, button, istouch)
	end
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
	end

	tools.updateToolableTiles(tool)

	local currentTool = 0
	if not clickActivated and not (tools.useToolTile(tool, tileLocY, tileLocX)) then
		tool = 0
	elseif not clickActivated then
		if tool<=tools.numNormalTools then
			gameTime.timeLeft = gameTime.timeLeft+gameTime.toolTime
			player.character:onToolUse()
		end
	end
	
	updateGameState(false)
	checkAllDeath()
end

function love.mousereleased(x, y, button, istouch)
	mouseDown = false
	if gamePaused then
		return
	end
end

function love.mousemoved(x, y, dx, dy)
	if gamePaused then
		return
	end
	--mouseX = x-width2/2+16*screenScale/2
	--mouseY = y-height2/2+9*screenScale/2
	mouseX = x-(width2-width)/2
	mouseY = y-(height2-height)/2
	local bigRoomTranslation = getTranslation()
	tileLocX = math.ceil((mouseX-wallSprite.width)/(scale*floor.sprite:getWidth()))-bigRoomTranslation.x
	tileLocY = math.ceil((mouseY-wallSprite.height)/(scale*floor.sprite:getHeight()))-bigRoomTranslation.y
	if room ~= nil and room[tileLocY+1] ~= nil and room[tileLocY+1][tileLocX] ~= nil then
		tileLocY = math.ceil((mouseY-wallSprite.height-room[tileLocY+1][tileLocX]:getYOffset()*scale)/(scale*floor.sprite:getHeight()))-bigRoomTranslation.y
	end
	if editorMode then
		editor.mousemoved(x, y, dx, dy)
	end
end

function updateGameState(noPowerUpdate)
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				if room[i][j].onLoad ~= nil and room[i][j].loaded == nil then
					room[i][j]:onLoad()
					room[i][j].loaded = true
				end
			end
		end
	end
	checkWin()

	if not noPowerUpdate then updatePower() end
	updateLight()
	updateTools()
	if tool ~= 0 and tool ~= nil and tools[tool].numHeld == 0 then tool = 0 end
	tools.updateToolableTiles(tool)
	--checkAllDeath()
end

function resetTileStates()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				room[i][j]:resetState()
				if room[i][j].onLoad ~= nil and room[i][j].loaded == nil then
					room[i][j]:onLoad()
					room[i][j].loaded = true
				end
			end
		end
	end
end

function accelerate()
	for i = 1, #pushables do
		if pushables[i].canBeAccelerated then
			if room[pushables[i].tileY][pushables[i].tileX]~=nil and room[pushables[i].tileY][pushables[i].tileX]:instanceof(	tiles.accelerator) then
				local potentialY = pushables[i].tileY+room[pushables[i].tileY][pushables[i].tileX]:yAccel()
				local potentialX = pushables[i].tileX+room[pushables[i].tileY][pushables[i].tileX]:xAccel()
				if potentialY>0 and potentialY<=roomHeight and potentialX>0 and potentialX<=roomLength then
					local canAccelerate = true
					if room[potentialY][potentialX]~=nil and room[potentialY][potentialX].blocksMovement then canAccelerate = false 	end
					for i = 1, #pushables do
						if pushables[i].tileY == potentialY and pushables[i].tileX == potentialX then canAccelerate = false end
					end
					for i = 1, #animals do
						if animals[i].tileY == potentialY and animals[i].tileX == potentialX then canAccelerate = false end
					end
					if player.tileY == potentialY and player.tileX == potentialX then canAccelerate = false end
					if canAccelerate then
						pushables[i].prevTileX = pushables[i].tileX
						pushables[i].prevTileY = pushables[i].tileY
						pushables[i].tileY = potentialY
						pushables[i].tileX = potentialX
						pushables[i]:moveNoMover()
					end
				end
			end
			pushables[i].canBeAccelerated = false
		end
	end
end

function resetPushables()
	for i = 1, #pushables do
		pushables[i].canBeAccelerated = true
		--pushables[i].powered = false
	end
end

function checkWin()
	if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX]:instanceof(tiles.endTile) then room[player.tileY][player.tileX]:onEnter() end
end
function checkAllDeath()
	checkDeath()
	for i = 1, #animals do
		animals[i]:checkDeath()
	end
	for i = 1, #pushables do
		pushables[i]:checkDestruction()
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
				room[i][j]:onStep(i, j)
				if room[i][j].gone then
					room[i][j]:onEnd(i, j)
					room[i][j] = nil
				end
			end
		end
	end
	for times = 1, 5 do
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]~=nil then
					if room[i][j].gone then
						room[i][j]:onEnd(i, j)
						room[i][j] = nil
					end
				end
			end
		end
	end
	--new acceleration tiles
    for i = 1, 4 do
    	accelerate()
    end
    resetPushables()
end

function unlockDoors()
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
end

function dropTools()
	local dropOverride = map.getFieldForRoom(mainMap[mapy][mapx].roomid, 'itemsGivenOverride')
	if loadTutorial then
		local toolsToDisplay = {0,0,0,0,0,0,0}
		for i = 1, tools.numNormalTools do
			player.totalItemsGiven[i] = player.totalItemsGiven[i] + map.getItemsGiven(mainMap[mapy][mapx].roomid)[1][i]
			player.totalItemsNeeded[i] = player.totalItemsNeeded[i] + map.getItemsNeeded(mainMap[mapy][mapx].roomid)[1][i]
			toolsToDisplay[i] = player.totalItemsGiven[i] - player.totalItemsNeeded[i] - tools[i].numHeld
			tools[i].numHeld = player.totalItemsGiven[i] - player.totalItemsNeeded[i]
			if tools[i].numHeld < 0 then tools[i].numHeld = 0 end
		end
		tools.displayToolsByArray(toolsToDisplay)
	elseif dropOverride == nil then
		local checkedRooms = {}
		for i = 0, mapHeight do
			checkedRooms[i] = {}
		end
		local amtChecked = 0
		local done = false
		while (not done) do
			y = util.random(mapHeight, 'toolDrop')
			x = util.random(mapHeight, 'toolDrop')
			if checkedRooms[y][x] == nil then
				checkedRooms[y][x] = 1
				if completedRooms[y]~=nil and completedRooms[y][x]~=nil and completedRooms[y][x] == 0 then
					local dirEnter = map.getFieldForRoom(mainMap[y][x].roomid, "dirEnter")
					if ((dirEnter[1] == 1 and completedRooms[y-1]~=nil and completedRooms[y-1][x] ~=nil and completedRooms[y-1][x] == 1) or
					(dirEnter[3] == 1 and completedRooms[y+1]~=nil and completedRooms[y+1][x] ~=nil and completedRooms[y+1][x] ==1) or
					(dirEnter[4] == 1 and completedRooms[y][x-1]~=nil and completedRooms[y][x-1]==1) or
					(dirEnter[2] == 1 and completedRooms[y][x+1]~=nil and completedRooms[y][x+1]==1)) then
						local id = tostring(mainMap[y][x].roomid)
						if dropOverride == nil then
							listOfItemsNeeded = map.getItemsNeeded(mainMap[y][x].roomid)
							numLists = 0
							for j = 1, 10 do
								if listOfItemsNeeded[j]~=nil then
									numLists = numLists+1
								end
							end
							listChoose = util.random(numLists, 'toolDrop')
							for i = 1, tools.numNormalTools do
								if listOfItemsNeeded[listChoose][i] ~= 0 then
									done = true
								end
							end
							if done then
								tools.giveToolsByArray(listOfItemsNeeded[listChoose])
								if player.character.name == "Francisco" then
									player.character.nextRoom = {yLoc = y, xLoc = x}
								end
							end
						end
					end
				end
				amtChecked = amtChecked + 1
				if amtChecked == mapHeight*mapHeight then
					if player.character.name == "Francisco" then
						player.character.nextRoom = {yLoc = -1, xLoc = -1}
					end
					break
				end
			end
		end
		if not done then
			for i = 1, toolMin+1 do
				local slot = util.random(tools.numNormalTools, 'toolDrop')
				tools[slot].numHeld = tools[slot].numHeld+1
			end
		end
	else
		tools.giveToolsByArray(dropOverride)
	end
end

function beatRoom(noDrops)
	if noDrops == nil then noDrops = false end
	gameTime.timeLeft = gameTime.timeLeft+gameTime.roomTime
	unlockDoors()
	if not noDrops then
		dropTools()
	end
end