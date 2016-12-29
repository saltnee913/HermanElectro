love.graphics.setDefaultFilter( "nearest" )

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
characters = require('scripts.characters')
unlocks = require('scripts.unlocks')
tutorial = require('scripts.tutorial')
toolManuel = require('scripts.toolManuel')
unlocksScreen = require('scripts.unlocksScreen')
stats = require('scripts.stats')
loadedOnce = false

saveDir = 'SaveData'

local function addTo(toAdd, array)
	for i = 1, 7 do
		toAdd[i] = toAdd[i] + array[i]
	end
end

local function areItemsSame(a,b)
	local la = #a
	local lb = #b
	if la ~= lb then return false end
	for i = 1, #a do
		if a[i] ~= b[i] then return false end
	end
	return true
end

local function doItemsNeededCalcs()
	local itemsNeededs = util.readJSON(saveDir..'/'..map.itemsNeededFile)
	local arr = {}
	for i = 1, #itemsNeededs do
		local room = itemsNeededs[i][1]
		local character = itemsNeededs[i][2]
		if arr[character] == nil then arr[character] = {} end
		ar = arr[character]
			local items = {}
			for j = 3, #itemsNeededs do
				items[#items+1] = itemsNeededs[i][j]
			end
			if ar[room] == nil then
				ar[room] = {}
			end
			local new = true
			for j = 1, #ar[room] do
				if areItemsSame(ar[room][j],items) then
					new = false
				end
			end
			if new then
				ar[room][#ar[room]+1] = items
			end
		
	end
	local state = {indent = true}
	util.writeJSON('test.json', arr, state)
	game.crash()
end

function love.load()
	--doItemsNeededCalcs()
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
	 ls[4] = {}
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
	gameTime = {timeLeft = 260, toolTime = 0, roomTime = 15, levelTime = 200, donateTime = 20, goesDownInCompleted = false}

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
	stats.load()

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
	forcePowerUpdateNext = false
	myShader = love.graphics.newShader[[
		extern bool shaderTriggered;
		extern number tint_r;
		extern number tint_g;
		extern number tint_b;
		extern number floorTint_r;
		extern number floorTint_g;
		extern number floorTint_b;
		extern number player_x;
		extern number player_y;
		extern vec4 lamps[100];
		extern number player_range = 300;
		extern number bonus_range = 0;
		extern bool b_and_w = false;
		extern vec4 spotlights[3];

		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		  	vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
		  	if (!shaderTriggered) return pixel;
			number xdist = player_x-screen_coords[0];
			number ydist = player_y-screen_coords[1];
			number playerDist = sqrt(xdist*xdist+ydist*ydist)/(player_range+bonus_range);
			if (playerDist<2)
				playerDist = 1+playerDist*playerDist/4;
			if (playerDist<0)
			  	playerDist = 1;
			number divVal = 100000;
			if (playerDist<divVal)
			  	divVal = playerDist;
			number totaltint_r = tint_r/divVal;
			number totaltint_g = tint_g/divVal;
			number totaltint_b = tint_b/divVal;

			//spotlights
			for (int i=0;i<3;i=i+1) {
				if (spotlights[i][0]>=0) {
					number lampxdist = spotlights[i][0]-screen_coords[0];
					number lampydist = spotlights[i][1]-screen_coords[1];
					number totalLampDist = sqrt(lampxdist*lampxdist+lampydist*lampydist);
					if (totalLampDist<spotlights[i][3]) {
					totaltint_r = 1;
					totaltint_g = 1;
					totaltint_b = 0;
					}
				}
            }

			//lamps
			for (int i=0;i<10;i=i+1) {
				if (lamps[i][0]>=0) {
					number lampxdist = lamps[i][0]-screen_coords[0];
					number lampydist = lamps[i][1]-screen_coords[1];
					number totalLampDist = sqrt(lampxdist*lampxdist+lampydist*lampydist)/lamps[i][3];
					totaltint_r = totaltint_r+lamps[i][2]/totalLampDist;
					totaltint_g = totaltint_g+lamps[i][2]/totalLampDist;
					totaltint_b = totaltint_b+lamps[i][2]/totalLampDist;
				}
            }

            if(totaltint_r>1) totaltint_r=1;
            if(totaltint_g>1) totaltint_g=1;
            if(totaltint_b>1) totaltint_b=1;

    		pixel.r = pixel.r*totaltint_r*(1-(floorTint_g+floorTint_b));
            pixel.g = pixel.g*totaltint_g*(1-(floorTint_r+floorTint_b));
            pixel.b = pixel.b*totaltint_b*(1-(floorTint_r+floorTint_g));
            
            if (b_and_w) {
        		float avg = (pixel.r+pixel.g+pixel.b)/3;
        		pixel.r = avg;
        		pixel.g = avg;
        		pixel.b = avg;
            }

			return pixel;
		}
  	]]
	if not loadedOnce then
		love.graphics.setBackgroundColor(0,0,0)
		floorIndex = -1
		--started = false
		shaderTriggered = true
		mushroomMode = false
		globalTint = {0,0,0}
		globalTintRising = {1,1,1}
		charSelect = false
		selectedBox = {x = 0, y = 0}
		regularLength = 24
		regularHeight = 12
		toolTime = 0
		f1 = love.graphics.newImage('Graphics/concretewalls.png')
		walls = love.graphics.newImage('Graphics/walls3.png')
		--black = love.graphics.newImage('Graphics/dark.png')
		black = love.graphics.newImage('GraphicsColor/smoke.png')
		green = love.graphics.newImage('Graphics/green.png')
		gray = love.graphics.newImage('Graphics/gray.png')
		toolWrapper = love.graphics.newImage('GraphicsEli/marble1.png')
		titlescreenCounter = 0
		--floortile = love.graphics.newImage('Graphics/floortile.png')
		--floortile = love.graphics.newImage('Graphics/floortilemost.png')
		--floortile = love.graphics.newImage('Graphics/floortilenew.png')
		--floortile = love.graphics.newImage('KenGraphics/darkrock.png')
		--floortile = love.graphics.newImage('KenGraphics/darkrock.png')
		--floortile2 = love.graphics.newImage('KenGraphics/darkrock.png')
		--floortile3 = love.graphics.newImage('KenGraphics/darkrock.png')
		--[[floortile  = love.graphics.newImage('GraphicsEli/marble1.png')
		floortile2 = love.graphics.newImage('GraphicsEli/marble2.png')
		floortile3 = love.graphics.newImage('GraphicsEli/marble3.png')]]
		--[[floortile = love.graphics.newImage('KenGraphics/grass.png')
		floortile2 = love.graphics.newImage('KenGraphics/grass.png')
		floortile3 = love.graphics.newImage('KenGraphics/grass.png')]]
		--[[floortile = love.graphics.newImage('GraphicsColor/greenfloor.png')
		floortile2 = love.graphics.newImage('GraphicsColor/greenfloor2.png')
		floortile3 = love.graphics.newImage('GraphicsColor/greenfloor3.png')]]
		floortile = love.graphics.newImage('GraphicsBrush/grass1.png')
		floortile2 = love.graphics.newImage('GraphicsBrush/grass2.png')
		floortile3 = love.graphics.newImage('GraphicsBrush/grass3.png')
		grassfloortile = love.graphics.newImage('KenGraphics/grass.png')
		space = love.graphics.newImage('GraphicsColor/space.png')
		dungeonFloor = love.graphics.newImage('GraphicsEli/gold1.png')

		flowerrock1 = love.graphics.newImage('GraphicsBrush/flowerrocks1.png')
		flowerrock2 = love.graphics.newImage('GraphicsBrush/flowerrocks2.png')
		flowerrock3 = love.graphics.newImage('GraphicsBrush/flowerrocks3.png')

		grassrock1 = love.graphics.newImage('GraphicsBrush/grassrocks1.png')
		grassrock2 = love.graphics.newImage('GraphicsBrush/grassrocks2.png')
		grassrock3 = love.graphics.newImage('GraphicsBrush/grassrocks3.png')

		floortiles = {}		
		floortiles[5] = {love.graphics.newImage('GraphicsEli/blueLines1.png'),love.graphics.newImage('GraphicsEli/blueLines2.png'),love.graphics.newImage('GraphicsEli/blueLines3.png')}
		floortiles[4] = {love.graphics.newImage('GraphicsEli/blueFloorBack.png'),love.graphics.newImage('GraphicsEli/blueFloorBack2.png'),love.graphics.newImage('GraphicsEli/blueFloorBack3.png')}
		floortiles[3] = {love.graphics.newImage('GraphicsBrush/purplefloor1.png'),love.graphics.newImage('GraphicsBrush/purplefloor2.png'),love.graphics.newImage('GraphicsBrush/purplefloor3.png')}
		floortiles[2] = {love.graphics.newImage('GraphicsColor/greenfloor.png'),love.graphics.newImage('GraphicsColor/greenfloor2.png'),love.graphics.newImage('GraphicsColor/greenfloor3.png')}
		floortiles[1] = {floortile,floortile2, floortile3}
		--floortiles[1] = {grassrock1, grassrock2, grassrock3}	
		floortiles[6] = floortiles[4]

		secondaryTiles = {}
		--secondaryTiles[1] = {flowerrock1, flowerrock2, flowerrock3}
		secondaryTiles[1] = {grassrock1, grassrock2, grassrock3}
		secondaryTiles[2] = {flowerrock1, flowerrock2, flowerrock3}
		secondaryTiles[3] = {flowerrock1, flowerrock2, flowerrock3}
		secondaryTiles[4] = {flowerrock1, flowerrock2, flowerrock3}
		secondaryTiles[5] = {flowerrock1, flowerrock2, flowerrock3}
		secondaryTiles[6] = {flowerrock1, flowerrock2, flowerrock3}


		invisibleTile = love.graphics.newImage('Graphics/cavesfloor.png')
		whitetile = love.graphics.newImage('Graphics/whitetile.png')
		doorwaybg = love.graphics.newImage('Graphics/doorwaybackground.png')
		deathscreen = love.graphics.newImage('NewGraphics/Newdeathscreen.png')
		winscreen = love.graphics.newImage('NewGraphics/NewWinScreen.png')
		pausescreen = love.graphics.newImage('NewGraphics/NewPauseScreen2.png')
		bottomwall = love.graphics.newImage('Graphics3D/bottomwall.png')
		--topwall = love.graphics.newImage('Graphics/cave6_b.png')
		topwall = love.graphics.newImage('Graphics3D/topwall.png')
		cornerwall = love.graphics.newImage('Graphics/toprightcorner.png')
		startscreen = love.graphics.newImage('NewGraphics/startscreen3.png')
		titlescreen = love.graphics.newImage('Graphics/titlescreen.png')
		luckImage = love.graphics.newImage('Graphics/luck.png')

		--music = love.audio.newSource('Audio/hermantheme.mp3')
		--music = love.audio.newSource('Audio/bones.mp3')

		songStart = love.audio.newSource('Audio/einstein.mp3')
		song1 = love.audio.newSource('Audio/opening.mp3')
		song2 = love.audio.newSource('Audio/floe.mp3')
		song3 = love.audio.newSource('Audio/island.mp3')
		song4 = love.audio.newSource('Audio/rubric.mp3')
		song5 = love.audio.newSource('Audio/facades.mp3')
		song6 = love.audio.newSource('Audio/closing.mp3')
		songTut = love.audio.newSource('Audio/newthemeidk.mp3')

		music = {songStart, song1, song2, song3, song4, song5, song6}
		tutMusicIndex = #music+1
		music.volume = 1
		music[tutMusicIndex] = songTut
		for i = 1, #music do
			music[i]:setLooping(true)
		end
		function music:muted()
			return self.volume == 0
		end

		playMusic(1)

		--[[music = love.audio.newSource('Audio/newthemeidk.mp3')
		music:play()]]


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
		player = { 	keysHeld = 0, dead = false, elevation = 0, safeFromAnimals = false, bonusRange = 0, active = true, waitCounter = 0, tileX = 10, tileY = 6, x = (1-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10, 
			y = (6-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10, prevTileX = 3, prevTileY 	= 10,
			prevx = (3-1)*scale*floor.sprite:getWidth()+wallSprite.width+floor.sprite:getWidth()/2*scale-10,
			prevy = (10-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10,
			width = 20, height = 20, speed = 250, luckTimer = 0,
			character = characters[1], regularMapLoc = {x = 0, y = 0}, returnFloorIndex = 0, attributes = {flying = false, fear = false, tall = false, extendedRange = {range = 0, toolUses = -1}, sockStep = -1}}
	else
		player.dead = false
		player.tileX = 1
		player.tileY = 6
	end

	map.clearBlacklist()

	if loadTutorial then
		player.enterX = player.tileX
		player.enterY = player.tileY
		player.totalItemsGiven = {0,0,0,0,0,0,0}
		player.totalItemsNeeded = {0,0,0,0,0,0,0}
	end
	function player:getTileLoc()
		return {x = self.x/(floor.sprite:getWidth()*scale), y = self.y/(floor.sprite:getWidth()*scale)}
	end
	loadRandoms()
	--loadOpeningWorld()
end

function playMusic(index)
	music.currentIndex = index
	for i = 1, #music do
		music[i]:stop()
	end
	if (index>0) then
		music[index]:setVolume(music.volume)
		music[index]:play()
	end
end

function setMusicVolume(volume)
	music.volume = volume
	music[music.currentIndex]:setVolume(volume)
end

function goToMainMenu()
	started = false
	playMusic(1)
end

function loadRandoms()
	local seed
	if seedOverride == nil then
		seed = os.time()
	else
		seed = tonumber(seedOverride)
	end
	if seed == nil then seed = os.time() end
	util.newRandom('mapGen', seed)
	util.newRandom('toolDrop', seed*3)
	util.newRandom('misc', seed*5)
end

function goDownFloor()
	if map.loadedMaps[floorIndex+1] == nil then
		loadNextLevel()
	else
		local mapToLoad = map.loadedMaps[floorIndex+1]
		floorIndex = floorIndex+1
		mainMap = mapToLoad.map
		mapHeight = mapToLoad.mapHeight
		roomHeight = mapToLoad.roomHeight
		roomLength = mapToLoad.roomLength
		completedRooms = mapToLoad.completedRooms
		visibleMap = mapToLoad.visibleMap
		prepareFloor()
		playMusic(floorIndex)
	end
end

function goUpFloor()
	if floorIndex == 2 then
		goToMainMenu()
	else
		local mapToLoad = map.loadedMaps[floorIndex-1]
		floorIndex = floorIndex - 1
		map.setRoomSetValues(floorIndex)
		mainMap = mapToLoad.map
		mapHeight = mapToLoad.mapHeight
		roomHeight = mapToLoad.roomHeight
		roomLength = mapToLoad.roomLength
		completedRooms = mapToLoad.completedRooms
		visibleMap = mapToLoad.visibleMap
		prepareFloor()
		playMusic(floorIndex)
	end
end
function goToFloor(floorNum)
	floorIndex = floorNum
	local mapToLoad = map.loadedMaps[floorIndex]
	mainMap = mapToLoad.map
	mapHeight = mapToLoad.mapHeight
	roomHeight = mapToLoad.roomHeight
	roomLength = mapToLoad.roomLength
	completedRooms = mapToLoad.completedRooms
	visibleMap = mapToLoad.visibleMap
	map.setRoomSetValues(floorIndex)
	prepareFloor()
	playMusic(floorIndex)
	currentid = tostring(mainMap[mapy][mapx].roomid)
	if map.getFieldForRoom(currentid, 'autowin') then
		completedRooms[mapy][mapx] = 1
		unlockDoors()
	end
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
		player.totalItemsGiven =  {0,0,0,0,0,0,0}
		player.totalItemsNeeded = {0,0,0,0,0,0,0}
		if floorIndex==1 then
			loadLevel('RoomData/tut_map.json')
		elseif floorIndex==2 then
			loadLevel('RoomData/tut_map_tools.json')
		else
			loadLevel('RoomData/tut_map_2.json')
		end
		floorIndex = floorIndex + 1
	else
		if floorIndex > #map.floorOrder then
			floorIndex = 1
		end
		loadLevel(map.floorOrder[floorIndex])
		floorIndex = floorIndex+1
		playMusic(floorIndex)
	end
	--hack to make it not happen on the first floor
	if floorIndex ~= 2 then
		player.character:onFloorEnter()
	end
	if unlocks.floorUnlocks[floorIndex-1] ~= nil then
		unlocks.unlockUnlockableRef(unlocks.floorUnlocks[floorIndex-1])
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

function loadOpeningWorld()
	floorIndex = -1
	loadRandoms()
	loadLevel('RoomData/openingworld.json')
	roomHeight = room.height
	roomLength = room.length
	player.tileX = math.floor(roomLength/2)
	player.tileY = roomHeight-3
	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	updateLight()
	started = true
	player.character:onBegin()
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
	playMusic(tutMusicIndex)
	started = true
end

function startDebug()
	loadRandoms()
	loadTutorial = false
	map.floorOrder = {'RoomData/debugFloor.json', 'RoomData/exitDungeonsMap.json'}
	love.load()
	tools.resetTools()
	charSelect = true
end

function loadFirstLevel()
	floorIndex = 1
	map.loadedMaps = {}
	loadLevel(map.floorOrder[#map.floorOrder])
	endMap = mainMap
	loadNextLevel(true)
	createAnimals()
	createPushables()
end

function prepareFloor()
	animals = {}
	pushables = {}
	mapx = mainMap.initialX
	mapy = mainMap.initialY
	room = mainMap[mapy][mapx].room
	prevRoom = room
	litTiles = {}
	for i = 1, roomHeight do
		litTiles[i] = {}
	end
end

function loadLevel(floorPath)
	map.loadFloor(floorPath)
	mainMap = map.generateMap()
	mapHeight = mainMap.height
	mapx = mainMap.initialX
	mapy = mainMap.initialY
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

	regularMap = mainMap

	prepareFloor()
	visibleMap = {}
	for i = 0, mapHeight do
		visibleMap[i] = {}
		for j = 0, mapHeight do
			visibleMap[i][j] = 0
		end
	end

	visibleMap[mapy][mapx] = 1
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
	roomHeight = room.height
	roomLength = room.length
	if floorIndex>=-1 then
		shaderTriggered = true
		map.loadedMaps[#map.loadedMaps+1] = {map = mainMap, mapHeight = mapHeight, 
	  		roomHeight = roomHeight, roomLength = roomLength, completedRooms = completedRooms, visibleMap = visibleMap}
	end
end

function kill()
	if editorMode then return end
	if validSpace() and completedRooms[mapy][mapx]>0 then
		unlocks.unlockUnlockableRef(unlocks.portalUnlock)
	end
	player.dead = true
	for i = 1, #tools do
		if not tools[i]:checkDeath() then
			player.dead = false
			--[[for i = 1, tools.numNormalTools do
				tools[i].numHeld = 0
			end]]
			for i = 1, roomHeight do
				for j = 1, roomLength do
					if room[i][j]~=nil then
						if not room[i][j]:instanceof(tiles.endTile) and not room[i][j]:instanceof(tiles.tunnel) then
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
			stats.losses[player.character.name] = stats.losses[player.character.name]-1
			onToolUse(i)
			return
		end
	end
	unlockedChars = characters.getUnlockedCharacters()
	stats.losses[player.character.name] = stats.losses[player.character.name]+1
	stats.writeStats()
	if not loadTutorial then --hacky hack fix
		completedRooms[mapy][mapx] = 0 --to stop itemsNeeded tracking, it's a hack!
	end
end

function win()
	if not won then
		for i = 1, #unlocks.winUnlocks do
			if unlocks.winUnlocks[i].unlocked == false then
				unlocks.unlockUnlockableRef(unlocks.winUnlocks[i])
				break
			end
		end
		for i = 1, #player.character.winUnlocks do
			local unlock = player.character.winUnlocks[i]
			if unlock.unlocked == false then
				unlocks.unlockUnlockableRef(unlock)
				break
			end
		end
		if gameTime.timeLeft > gameTime.levelTime * floorIndex then
			unlocks.unlockUnlockableRef(unlocks.erikUnlock)
		end
		if player.character.speedUnlock ~= nil and gameTime.timeLeft > player.character.speedUnlockTime then
			unlocks.unlockUnlockableRef(player.character.speedUnlock)
		end
		won = true
		stats.wins[player.character.name] = stats.wins[player.character.name]+1
		stats.writeStats()
	end
	unlockedChars = characters.getUnlockedCharacters()
end

maxLamps = 100

function updateLamps(tileY, tileX)
	if not started then return end

	spotlightsSend = {}
	if spotlights~=nil and player.character.name=="Albert" then
		for i = 1, #spotlights do
			spotlightsSend[#spotlightsSend+1] = {spotlights[i].x, spotlights[i].y, spotlights[i].intensity, spotlights[i].range}		
		end
	end
	local spotIndex = #spotlightsSend
	while spotIndex<3 do
		spotlightsSend[#spotlightsSend+1] = {-1,-1,-1,0}
		spotIndex = spotIndex+1
	end
	myShader:send("spotlights", unpack(spotlightsSend))

	local lampHolder = {}
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and (room[i][j].emitsLight or (room[i][j].litWhenPowered and room[i][j].powered)) and #lampHolder<maxLamps then
				lampHolder[#lampHolder+1] = {j,i,room[i][j].intensity,room[i][j].range}
			end
		end
	end

	for i = 1, #pushables do
		if pushables[i]:instanceof(pushableList.lamp) and #lampHolder<maxLamps then
			lampHolder[#lampHolder+1] = {pushables[i].tileX, pushables[i].tileY, pushables[i].intensity, pushables[i].range}
		end
	end
	local index = #lampHolder
	while index<maxLamps do
		lampHolder[#lampHolder+1] = {-1,-1,-1,-1}
		index = index+1
	end

	--fix coordinates (tile locs --> coordinates)
	for i = 1, #lampHolder do
		if lampHolder[i][1]>=0 then
			lampHolder[i][1] = (lampHolder[i][1]-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
			lampHolder[i][2] = (lampHolder[i][2]-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
			lampHolder[i][1] = lampHolder[i][1]+(width2-width)/2+getTranslation().x*floor.sprite:getWidth()*scale
			lampHolder[i][2] = lampHolder[i][2]+(height2-height)/2+getTranslation().y*floor.sprite:getHeight()*scale
		end
	end

	myShader:send("lamps", unpack(lampHolder))
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
	player.character:onPostUpdateLight()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j].lit then
				lightTest(i, j)
			end
		end
	end

	for i = 1, #pushables do
		if pushables[i]:instanceof(pushableList.lamp) and not pushables[i].destroyed then
			lightTest(pushables[i].tileY, pushables[i].tileX)
		end
	end
	
	--[[for i=1,roomHeight do
		for j=1,roomLength do
			checkLight(i,j, tileLoc2, tileLoc1)
		end
	end]]
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
		if room[xcoord]~=nil and room[xcoord][ycoord]~=nil and room[xcoord][ycoord].blocksVision and
			-1*room[xcoord][ycoord]:getYOffset()>player.elevation and not (xcoord==i and ycoord ==j) then
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
		for i = 1, #pushables do
			pushables[i].powered = false
		end
		for i = 1, #animals do
			animals[i].powered = false
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
					for j = 1, #animals do
						if animals[j].conductive and animals[j].powered then
							if pushables[i].tileY == animals[j].tileY and math.abs(pushables[i].tileX-animals[j].tileX)==1
							or pushables[i].tileX == animals[j].tileX and math.abs(pushables[j].tileY-animals[i].tileY)==1 then
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
							powerTestPushable(pY, pX, 0)
						end
						pushables[i].powered = true
					end
				end
			end
			for i = 1, #animals do
				if animals[i].conductive then
					local conductPower = false
					local pX = animals[i].tileX
					local pY = animals[i].tileY
					if (room[pY-1]~=nil and room[pY-1][pX]~=nil and room[pY-1][pX].powered and room[pY-1][pX].dirSend[3]==1) or
					(room[pY+1]~=nil and room[pY+1][pX]~=nil and room[pY+1][pX].powered and room[pY+1][pX].dirSend[1]==1) or
					(room[pY][pX-1]~=nil and room[pY][pX-1].powered and room[pY][pX-1].dirSend[2]==1) or
					(room[pY][pX+1]~=nil and room[pY][pX+1].powered and room[pY][pX+1].dirSend[4]==1) then
						conductPower = true
					end
					for j = 1, #pushables do
						if pushables[j].powered and not pushables[j].destroyed then
							if animals[i].tileY == pushables[j].tileY and math.abs(animals[i].tileX-pushables[j].tileX)==1
							or animals[i].tileX == pushables[j].tileX and math.abs(pushables[j].tileY-animals[i].tileY)==1 then
								conductPower = true
							end
						end
					end
					for j = 1, #animals do
						if animals[j].conductive and animals[j].powered then
							if animals[i].tileY == animals[j].tileY and math.abs(animals[i].tileX-animals[j].tileX)==1
							or animals[i].tileX == animals[j].tileX and math.abs(animals[j].tileY-animals[i].tileY)==1 then
								conductPower = true
							end
						end
					end
					if conductPower then
						powerTestPushable(pY, pX, 0)
						animals[i].powered = true
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

	for i = 1, 0 do
		for i = 1, 5 do
			for i = 1, #pushables do
				if pushables[i].conductive and not pushables[i].destroyed then
					local conductPower = false
					pushables[i].powered = false
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
							powerTest(pY, px, 0)
						end
						pushables[i].powered = true
					end
				end
			end
		end
		--[[for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]~=nil and room[i][j].charged then room[i][j].powered=true end
				if room[i]~=nil and room[i][j]~=nil and not (room[i][j]:instanceof(tiles.powerSupply) or room[i][j]:instanceof(tiles.notGate)) and not room[i][j].charged then
					room[i][j].poweredNeighbors = {0,0,0,0}
					room[i][j].powered = false
					room[i][j]:updateTileAndOverlay(0)
				end
			end
		end]]
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i]~=nil and room[i][j]~=nil then
					if (room[i][j]:instanceof(tiles.powerSupply) or room[i][j]:instanceof(tiles.notGate) or room[i][j].charged) and room[i][j].powered then
						powerTestSpecial(i,j,0)
					end
				end
			end
		end
	end

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				
				for k = 1, #pushables do
					if pushables[k].powered then
						if pushables[k].tileY==i and pushables[k].tileX==j+1 and room[i][j].dirAccept[2]==1 then
							room[i][j].poweredNeighbors[2]=1
						end
						if pushables[k].tileY==i and pushables[k].tileX==j-1 and room[i][j].dirAccept[4]==1 then
							room[i][j].poweredNeighbors[4]=1
						end
						if pushables[k].tileY==i+1 and pushables[k].tileX==j and room[i][j].dirAccept[1]==1 then
							room[i][j].poweredNeighbors[1]=1
						end
						if pushables[k].tileY==i-1 and pushables[k].tileX==j and room[i][j].dirAccept[3]==1 then
							room[i][j].poweredNeighbors[3]=1
						end
					end
				end

				room[i][j]:postPowerUpdate(i,j)
				room[i][j]:updateTileAndOverlay()
				room[i][j]:updateSprite()
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
	for i = 1, #pushables do
		if pushables[i]:instanceof(pushableList.conductiveBox) then
			if pushables[i].powered then
				pushables[i].poweredLastUpdate = true
			else
				pushables[i].poweredLastUpdate = false
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
	if room[x] == nil or (litTiles[x][y] == 1) then
		return
	end

	litTiles[x][y] = 1


	if room[x][y] ~= nil and room[x][y]:obstructsVision() then
		return
	end

	if x>1 then
		lightTest(x-1,y)
	end


	if x<roomHeight then
		lightTest(x+1,y)
	end

	if y>1 then
		lightTest(x, y-1)
	end

	if y<roomLength then
		lightTest(x, y+1)
	end
	player.character.specialLightTest(x,y)
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

	if x>1 and room[x-1][y]~=nil and not room[x-1][y]:instanceof(tiles.notGate) and canBePowered(x-1,y,3) and lastDir~=1 then
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


	if x<roomHeight and room[x+1][y]~=nil and not room[x+1][y]:instanceof(tiles.notGate) and canBePowered(x+1,y,1) and lastDir~=3 then
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

	if y>1 and room[x][y-1]~=nil and not room[x][y-1]:instanceof(tiles.notGate) and canBePowered(x,y-1,2) and lastDir~=4 then
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

	if y<roomLength and room[x][y+1]~=nil and not room[x][y+1]:instanceof(tiles.notGate) and canBePowered(x,y+1,4) and lastDir~=2 then
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
	myShader:send("shaderTriggered", shaderTriggered)
	love.graphics.setBackgroundColor(0,0,0)
	if titlescreenCounter>0 then
		local sHeight = titlescreen:getHeight()
		local sWidth = titlescreen:getWidth()
		if sHeight/sWidth>height/width then
			love.graphics.draw(titlescreen, width/2-(height/titlescreen:getHeight())*sWidth/2, 0, 0, height/titlescreen:getHeight(), height/titlescreen:getHeight())
		else
			love.graphics.draw(titlescreen, 0, height/2-(width/titlescreen:getWidth())*sHeight/2, 0, width/titlescreen:getWidth(), width/titlescreen:getWidth())
		end
		return
	end
	if started then
		--love.graphics.draw(space, 0, 0, 0, width/space:getWidth(), height/space:getHeight())
	end
	if not started and not charSelect and not unlocksScreen.opened then
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
			love.graphics.print("Wins: "..stats.wins[charsToDraw[i].name], width/5*column-width/10-10, height/3*(row-1)+height/6-60)
			love.graphics.print("Losses: "..stats.losses[charsToDraw[i].name], width/5*column-width/10-10, height/3*(row-1)+height/6-40)
		end

		return
	elseif unlocksScreen.opened then
		unlocksScreen.draw()
		return
	end

	--love.graphics.translate(width2/2-16*screenScale/2, height2/2-9*screenScale/2)
	love.graphics.translate((width2-width)/2, (height2-height)/2)
	local bigRoomTranslation = getTranslation()
	love.graphics.translate(bigRoomTranslation.x*floor.sprite:getWidth()*scale, bigRoomTranslation.y*floor.sprite:getHeight()*scale)
	--love.graphics.draw(rocks, rocksQuad, 0, 0)
	--love.graphics.draw(rocks, -mapx * width, -mapy * height, 0, 1, 1)
	local toDrawFloor = nil
	love.graphics.setShader(myShader)
	for i = 1, roomLength do
		for j = 1, roomHeight do
			if floorIndex==-1 or floorIndex<=1 then
				toDrawFloor = grassfloortile
			else
				if (i*i*i+j*j)%3==0 then
					toDrawFloor = floortiles[floorIndex-1][1]
				elseif (i*i*i+j*j)%3==1 then
					toDrawFloor = floortiles[floorIndex-1][2]
				else
					toDrawFloor = floortiles[floorIndex-1][3]
				end
				if (room[j][i]==nil) then
					if (i*i+j*j*j-1)%27==0 then
						toDrawFloor = secondaryTiles[floorIndex-1][1]
					elseif (i*i+j*j*j-1)%29==1 then
						toDrawFloor = secondaryTiles[floorIndex-1][2]
					elseif (i*i+j*j*j-1)%31==2 then
						toDrawFloor = secondaryTiles[floorIndex-1][3]
					end
				end
			end
			fto = map.getFieldForRoom(mainMap[mapy][mapx].roomid, "floorTileOverride")
			if (fto~=nil) then
				if fto=="dungeon" then
					toDrawFloor = dungeonFloor
				end
			end


			love.graphics.draw(toDrawFloor, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (j-1)*floor.sprite:getHeight()*scale+wallSprite.height,
			0, scale*16/toDrawFloor:getWidth(), scale*16/toDrawFloor:getWidth())
		end
	end
	if floorIndex>1 then
		toDrawFloor = floortiles[floorIndex-1][1]
	end

	if validSpace() and mapx<#completedRooms[mapy] and ((completedRooms[mapy][mapx]>0 and mainMap[mapy][mapx+1]~=nil) or
	completedRooms[mapy][mapx+1]>0) then
		love.graphics.draw(toDrawFloor, (roomLength+1)*floor.sprite:getWidth()*scale+wallSprite.width, (math.floor(roomHeight/2))*floor.sprite:getHeight()*scale+wallSprite.height, math.pi/2, scale, scale)
		love.graphics.draw(toDrawFloor, (roomLength+1)*floor.sprite:getWidth()*scale+wallSprite.width, (math.floor(roomHeight/2)-1)*floor.sprite:getHeight()*scale+wallSprite.height, math.pi/2, scale, scale)	
	end
	if validSpace() and mapx>1 and ((completedRooms[mapy][mapx]>0 and mainMap[mapy][mapx-1]~=nil) or
	completedRooms[mapy][mapx-1]>0) then
		love.graphics.draw(toDrawFloor, (0)*floor.sprite:getWidth()*scale+wallSprite.width, (math.floor(roomHeight/2))*floor.sprite:getHeight()*scale+wallSprite.height, math.pi/2, scale, scale)
		love.graphics.draw(toDrawFloor, (0)*floor.sprite:getWidth()*scale+wallSprite.width, (math.floor(roomHeight/2)-1)*floor.sprite:getHeight()*scale+wallSprite.height, math.pi/2, scale, scale)	
	end
	if validSpace() and mapy>1 and ((completedRooms[mapy][mapx]>0 and mainMap[mapy-1][mapx]~=nil) or
	completedRooms[mapy-1][mapx]>0) then
		love.graphics.draw(toDrawFloor, (math.floor(roomLength/2)-1)*floor.sprite:getWidth()*scale+wallSprite.width, (-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
		love.graphics.draw(toDrawFloor, (math.floor(roomLength/2))*floor.sprite:getWidth()*scale+wallSprite.width, (-1)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())		
	end
	if validSpace() and mapy<#completedRooms and ((completedRooms[mapy][mapx]>0 and mainMap[mapy+1][mapx]~=nil) or
	completedRooms[mapy+1][mapx]>0) then
		love.graphics.draw(toDrawFloor, (math.floor(roomLength/2)-1)*floor.sprite:getWidth()*scale+wallSprite.width, (roomHeight)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
		love.graphics.draw(toDrawFloor, (math.floor(roomLength/2))*floor.sprite:getWidth()*scale+wallSprite.width, (roomHeight)*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())		
	end	
	love.graphics.setShader()
	--[[for i = 1, roomLength do
		if not (i==math.floor(roomLength/2) or i==math.floor(roomLength/2)+1) then
			love.graphics.draw(topwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(-1)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
		else
			if mapy<=0 or mainMap[mapy-1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy-1][mapx]==0) then
				love.graphics.draw(topwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(-1)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
			end	
		end
	end]]

	love.graphics.setShader(myShader)
	for j = 1, roomHeight do
		for i = 1, roomLength do
			if (room[j][i]~=nil or litTiles[j][i]==0) and not (litTiles[j][i]==1 and room[j][i]:instanceof(tiles.invisibleTile)) then
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
				if litTiles[j][i]==1 and room[j][i]~=nil and (not room[j][i].isVisible) and (not room[j][i]:instanceof(tiles.invisibleTile)) then
					toDraw = invisibleTile
				end
				if (room[j][i]~=nil --[[and room[j][i].name~="pitbull" and room[j][i].name~="cat" and room[j][i].name~="pup"]]) or litTiles[j][i]==0 then
					local addY = 0
					if room[j][i]~=nil and litTiles[j][i]~=0 then
						addY = room[j][i]:getYOffset()
					end
					if litTiles[j][i]==0 then addY = tiles.halfWall:getYOffset() end
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
						  rot2 * math.pi / 2, scale*16/toDraw2:getWidth(), scale*16/toDraw2:getWidth())
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
					if room[j][i]~=nil and litTiles[j][i]==1 and room[j][i]:getInfoText()~=nil then
						love.graphics.setColor(0,0,0)
						love.graphics.setShader()
						love.graphics.print(room[j][i]:getInfoText(), (tempi-1)*floor.sprite:getWidth()*scale+wallSprite.width, (tempj-1)*floor.sprite:getHeight()*scale+wallSprite.height);
						love.graphics.setShader(myShader)			
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
			if pushables[i]~=nil and not pushables[i].destroyed and litTiles[pushables[i].tileY][pushables[i].tileX]==1 and pushables[i].tileY==j and pushables[i].visible then
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

		if player.tileY == j then
			player.x = (player.tileX-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
			player.y = (player.tileY-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
			love.graphics.draw(player.character.sprite, math.floor(player.x-player.character.sprite:getWidth()*player.character.scale/2), math.floor(player.y-player.character.sprite:getHeight()*player.character.scale-player.elevation*scale), 0, player.character.scale, player.character.scale)
			love.graphics.setShader()
			love.graphics.print(player.character:getInfoText(), math.floor(player.x-player.character.sprite:getWidth()*player.character.scale/2), math.floor(player.y-player.character.sprite:getHeight()*player.character.scale));
			love.graphics.setShader(myShader)
		end

		if player.character.name == "Giovanni" and player.character.shiftPos.x>0 then
			if player.character.shiftPos.y == j then
				local playerx = (player.character.shiftPos.x-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
				local playery = (player.character.shiftPos.y-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
				love.graphics.draw(player.character.sprite2, playerx-player.character.sprite:getWidth()*player.character.scale/2, playery-player.character.sprite:getHeight()*player.character.scale, 0, player.character.scale, player.character.scale)
			end
		end
		--love.graphics.draw(walls, 0, 0, 0, width/walls:getWidth(), height/walls:getHeight())
	end
	love.graphics.setShader()

	--[[for i = 1, roomLength do
		if not (i==math.floor(roomLength/2) or i==math.floor(roomLength/2)+1) then
			love.graphics.draw(bottomwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(roomHeight)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale, scale)
		else
			if mapy>=mapHeight or mainMap[mapy+1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy+1][mapx]==0) then
				love.graphics.draw(bottomwall, (i-1)*floor.sprite:getWidth()*scale+wallSprite.width, (yOffset+(roomHeight)*floor.sprite:getHeight())*scale+wallSprite.height, 0, scale, scale)
			end		
		end
	end]]
	--[[for i = 1, roomHeight do
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
	end]]
	--[[for i = 1, 4 do
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
	end]]

	if tools.toolDisplayTimer.timeLeft > 0 or player.luckTimer>0 then
		if player.luckTimer<tools.toolDisplayTimer.timeLeft then
			local toolWidth = tools[1].image:getWidth()
			local toolScale = player.character.sprite:getWidth() * player.character.scale/toolWidth
			for i = 1, #tools.toolsShown do
				love.graphics.draw(tools[tools.toolsShown[i]].image, (i-math.ceil(#tools.toolsShown)/2-1)*toolScale*toolWidth+player.x, player.y - player.character.sprite:getHeight()*player.character.scale - tools[1].image:getHeight()*toolScale, 0, toolScale, toolScale)
			end
		else
			luckWidth = luckImage:getWidth()
			luckScale = player.character.sprite:getWidth() * player.character.scale/luckWidth
			love.graphics.draw(luckImage, -0.5*luckScale*luckWidth+player.x, player.y - player.character.sprite:getHeight()*player.character.scale - luckImage:getHeight()*luckScale, 0, luckScale, luckScale)
		end
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
			love.graphics.draw(toolWrapper, i*width/18, 0, 0, (width/18)/16, (width/18)/16)
			if tool == i+1 then
				love.graphics.setColor(50, 200, 50)
				love.graphics.rectangle("fill", i*width/18, 0, width/18, width/18)
			end
			--love.graphics.rectangle("fill", i*width/18, 0, width/18, width/18)
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
			love.graphics.draw(toolWrapper, (i+13)*width/18, 0, 0, (width/18)/16, (width/18)/16)
			if tool == specialTools[i+1] and tool~=0 then
				love.graphics.setColor(50, 200, 50)
				love.graphics.rectangle("fill", (i+13)*width/18, 0, width/18, width/18)
			end
			--love.graphics.rectangle("fill", (i+13)*width/18, 0, width/18, width/18)
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
				love.graphics.print((i+8)%10, (i+13)*width/18+7, (width/18)-20)
				love.graphics.circle("line", (i+13)*width/18+10, (width/18)-15, 9, 50)
			end
		end
	end
	love.graphics.setColor(255,255,255)

	if messageInfo.text~=nil then
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle("fill", width/2-200, 100, 400, 100)
		love.graphics.setColor(0,0,0,255)
		love.graphics.print(messageInfo.text, width/2-180, 110)
		love.graphics.setColor(255,255,255,255)
	end
	
	if player.dead then
		love.graphics.draw(deathscreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
	end
	if won then
		love.graphics.draw(winscreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
	end
	if gamePaused then
		if toolManuel.opened then
			toolManuel.draw()
		else
			--love.graphics.draw(pausescreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
			love.graphics.draw(pausescreen, 0, 0, 0, width/pausescreen:getWidth(), height/pausescreen:getHeight())
		end
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
	createAnimals()
	createPushables()
	updateGameState(false)
	return true
end

function createAnimals()
	animalCounter = 1
	if room.animals~=nil then animals = room.animals return end
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

function resetPlayerAttributesRoom()
	player.attributes.flying = false
	player.attributes.fear = false
	player.attributes.tall = false
	player.attributes.sockStep = -1
	player.attributes.extendedRange = {range = 0, toolUses = 0}
end

function resetPlayerAttributesTool()
	player.attributes.extendedRange.toolUses = player.attributes.extendedRange.toolUses-1
	if player.attributes.extendedRange.toolUses<0 then
		player.attributes.extendedRange.range = 0
	end
end

function resetPlayerAttributesStep()
	if player.attributes.sockStep>=0 then
		player.attributes.sockStep = player.attributes.sockStep-1
		if player.attributes.sockStep<0 then
			forcePowerUpdateNext = true
		end
	end
end

function enterRoom(dir)
	if not validSpace() then return end
	log("")
	resetTranslation()
	resetPlayerAttributesRoom()
	--set pushables of prev. room to pushables array, saving for next entry
	room.pushables = pushables
	room.animals = animals

	local plusOne = true

	if player.tileY == math.floor(roomHeight/2) then plusOne = false
	elseif player.tileX == math.floor(roomLength/2) then plusOne = false end

	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	prevMapX = mapx
	prevMapY = mapy
	prevRoom = room

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

	--check if box blocking doorway
	for i = 1, #pushables do
		if not pushables[i].destroyed and pushables[i].tileY == player.tileY and pushables[i].tileX == player.tileX then
			room = prevRoom
			player.tileX = player.prevTileX
			player.tileY = player.prevTileY
			mapx = prevMapX
			mapy = prevMapY
			createAnimals()
			createPushables()
			break
		end
	end

	if room.tint==nil then room.tint = {1,1,1} end

	player.prevTileY = player.tileY
	player.prevTileX = player.tileX

	player.character:onRoomEnter()

	visibleMap[mapy][mapx] = 1
	keyTimer.timeLeft = keyTimer.suicideDelay
	updateGameState(false)
	tutorial.enterRoom()

	player.x = (player.tileX-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
	player.y = (player.tileY-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
    myShader:send("player_x", player.x+getTranslation().x*floor.sprite:getWidth()*scale+(width2-width)/2)
    myShader:send("player_y", player.y+getTranslation().y*floor.sprite:getWidth()*scale+(height2-height)/2)
end

oldTilesOn = {}

function enterMove()
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

	if room[player.tileY][player.tileX]~=nil then
		if player.prevTileY == player.tileY and player.prevTileX == player.tileX then
			room[player.tileY][player.tileX]:onStay(player)
		else
			player.character:preTileEnter(room[player.tileY][player.tileX])
			room[player.tileY][player.tileX]:onEnter(player)
		end
	end

	if not (player.prevTileY == player.tileY and player.prevTileX == player.tileX) then
		if room~=nil and room[player.prevTileY][player.prevTileX]~=nil then
			room[player.prevTileY][player.prevTileX]:onLeave(player)
		end
		player.character:onTileLeave()
	end
end

function validSpace()
	return mapy<=mapHeight and mapx<=mapHeight and mapy>0 and mapx>0
end

keyTimer = {base = .05, timeLeft = .05, suicideDelay = .5}
function love.update(dt)
	if player~=nil and player.character~=nil then
		player.character:update(dt)
	end
	if (titlescreenCounter>0) then
		titlescreenCounter = titlescreenCounter-dt
	end
	if gamePaused then
		return
	end
	if loadTutorial then
		tutorial.update(dt)
	end
	--key press
	keyTimer.timeLeft = keyTimer.timeLeft - dt
	tools.updateTimer(dt)
	if player.luckTimer>0 then
		player.luckTimer = player.luckTimer-dt
	end
	unlocks.updateTimer(dt)
	if room~=nil and room[player.tileY] ~= nil and room[player.tileY][player.tileX] ~= nil and room[player.tileY][player.tileX].updateTime ~= nil then
		room[player.tileY][player.tileX]:updateTime(dt)
	end

	--game timer
	if started and validSpace() and (completedRooms[mapy][mapx]~=1 or gameTime.goesDownInCompleted) then
		gameTime.timeLeft = gameTime.timeLeft-dt
	end
	if gameTime.timeLeft<=0 and not loadTutorial then
		kill()
	end

	updateLamps()

	if mushroomMode then
		if globalTint[1]<0 then
			globalTintRising[1] = 1
		elseif globalTint[1]>0.3 then
			globalTintRising[1] = -1
		end
		if globalTint[2]<0 then
			globalTintRising[2] = 1
		elseif globalTint[2]>0.3 then
			globalTintRising[2] = -1
		end
		if globalTint[3]<0 then
			globalTintRising[3] = 1
		elseif globalTint[3]>0.3 then
			globalTintRising[3] = -1
		end

		for i = 1, 3 do
			globalTint[i] = globalTint[i]+dt/4*globalTintRising[i]
		end
		myShader:send("tint_r", globalTint[1])
		myShader:send("tint_g", globalTint[2])
		myShader:send("tint_b", globalTint[3])
	end

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room~=nil and room[i][j]~=nil then
				room[i][j]:realtimeUpdate()
			end
		end
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
			if charNum > #charsToSelect then
				charNum = #charsToSelect
			end
			player.character = charsToSelect[charNum]
			loadFirstLevel()
			player.character:onBegin()
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

	if key=="k" then
		if not music:muted() then
			setMusicVolume(0)
		else
			setMusicVolume(1)
		end
	end

	if not unlocksScreen.opened and not started then
		if charSelect then return end
		if key=="s" then
			if titlescreenCounter>0 then
				titlescreenCounter = -1
			else
				startGame()
			end
			return
		elseif key == "t" then
			startTutorial()
			return
		elseif key=="e" then
			startDebug()
			return
		elseif key=="tab" then
			enteringSeed = true
		elseif key=="u" then
			unlocksScreen.open()
		end
		return
	elseif unlocksScreen.opened then
		unlocksScreen.keypressed(key, unicode)
		return
	end

	if toolManuel.opened then
		toolManuel.keypressed(key, unicode)
	elseif gamePaused then
		if key=="escape" then
			gamePaused = false
		elseif key=="m" then
			goToMainMenu()
		elseif key=="t" then
			toolManuel.open()
		end
		return
	end
	if won then
		if key=="m" then
			goToMainMenu()
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
		if floorIndex == -1 then
			--started = false
			--charSelect = true
			--player.tileY = 1
			--player.tileX = 1
		end
		gameTime.timeLeft = gameTime.timeLeft+20000
	end


	--k ability: open doors with k on supertools
	--[[if key=="k" then
		if tool>tools.numNormalTools then
			tools[tool].numHeld = tools[tool].numHeld-1
			unlockDoors()
		end
	end]]

	if editorMode then
		editor.keypressed(key, unicode)
		mainMap.cheated = true--kind of hacky
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
	if player.character:onKeyPressedChar(key) then
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
    if (key == "w" or key == "a" or key == "s" or key == "d") then
    	if not playerMoved() then
			player.character:onFailedMove(key)
		else
    		resetPlayerAttributesStep()
		end
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
		if usedTool then
			onToolUse(tool)
		end
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
    	if forcePowerUpdateNext and playerMoved() then
    		noPowerUpdate = false
    		forcePowerUpdateNext = false
    	end
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
    	updateGameState(noPowerUpdate, false)
	    if playerMoved() or waitTurn then
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
				if (ani:instanceof(animalList.conductiveSnail) or ani:instanceof(animalList.conductiveDog))
					and (ani.tileX~=ani.prevTileX or ani.tileY~=ani.prevTileY) then
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
		for i = 1, #pushables do
			pushables[i].prevTileX = pushables[i].tileX
			pushables[i].prevTileY = pushables[i].tileY
		end
		if playerMoved() then
			player.character:postMove()
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

	player.x = (player.tileX-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
	player.y = (player.tileY-1)*scale*floor.sprite:getHeight()+wallSprite.height+floor.sprite:getHeight()/2*scale+10
    myShader:send("player_x", player.x+getTranslation().x*floor.sprite:getWidth()*scale+(width2-width)/2)
    myShader:send("player_y", player.y+getTranslation().y*floor.sprite:getWidth()*scale+(height2-height)/2)

    for i = 1, roomHeight do
    	for j = 1, roomLength do
    		if room[i][j]~=nil then
    			room[i][j]:absoluteFinalUpdate()
    		end
    	end
    end

    player.character:absoluteFinalUpdate()
end

function playerMoved()
	return player.tileX~=player.prevTileX or player.tileY~=player.prevTileY
end

function updateElevation()
	if room[player.tileY][player.tileX]==nil then
		player.elevation = 0
	else
		player.elevation = room[player.tileY][player.tileX]:getHeight()
	end
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
					room[animals[i].prevTileY][animals[i].prevTileX] = animals[i]:onNullLeave()
				elseif room[animals[i].prevTileY][animals[i].prevTileX]:instanceof(tiles.wall) and
				room[animals[i].prevTileY][animals[i].prevTileX].destroyed then
					room[animals[i].prevTileY][animals[i].prevTileX] = animals[i]:onNullLeave()
				end
			else
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
		if t:willKillPlayer() and not player.attributes.flying then
			kill()
		end
	end
	for i = 1, #animals do
		if animals[i]:willKillPlayer(player) and not player.safeFromAnimals then
			kill()
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
	if not clickActivated and not (tools.useToolTile(tileLocY, tileLocX)) then
		tool = 0
	elseif not clickActivated then
		if tool<=tools.numNormalTools then
			gameTime.timeLeft = gameTime.timeLeft+gameTime.toolTime
		end
		onToolUse(tool)
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

function updateGameState(noPowerUpdate, noLightUpdate)
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
	if not noPowerUpdate and player.attributes.sockStep<0 then updatePower() end
	if not noLightUpdate then
		updateLight()
	end
	updateTools()
	updateElevation()
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

	if tools.waterBottle.numHeld>=10 then
		unlocks.unlockUnlockableRef(unlocks.fishUnlock)
	end

end

function stepTrigger()
	player.character:immediatePostMove()
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
	for i = 1, #pushables do
		pushables[i]:onStep()
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
							--[[for i = 1, tools.numNormalTools do
								if listOfItemsNeeded[listChoose][i] ~= 0 then
									done = true
								end
							end]]
							local hasEndTile = map.getFieldForRoom(mainMap[y][x].roomid, "hasEndTile")
							if hasEndTile then
								done = true
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
			--[[for i = 1, toolMin+1 do
				local slot = util.random(tools.numNormalTools, 'toolDrop')
				tools[slot].numHeld = tools[slot].numHeld+1
			end]]
			--tools.giveSupertools(1)
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
	player.character:onRoomCompletion()
end

function onToolUse(tool)
	resetPlayerAttributesTool()
	player.character:onToolUse(tool)
	if mainMap[mapy][mapx].toolsUsed == nil then
		mainMap[mapy][mapx].toolsUsed = {}
	end
	mainMap[mapy][mapx].toolsUsed[#mainMap[mapy][mapx].toolsUsed+1] = tool
end