love.graphics.setDefaultFilter( "nearest" )
io.stdout:setvbuf("no")

globalCounter = 0

roomHeight = 12
roomLength = 24
screenScale = 70

fontSize = 12

debug = true
loadTutorial = false
gamePaused = false
releaseBuild = false

gameSpeed = 1
defaultGameSpeed = 1

spotlightList = require('scripts.spotlights')

util = require('scripts.util')
tiles = require('scripts.tiles')
map = require('scripts.map')

boundaries = require('scripts.boundaries') 
--require('scripts.tools')
bosses = require('scripts.bosses')
animalList = require('scripts.animals')
tools = require('scripts.tools')
editor = require('scripts.editor')
characters = require('scripts.characters')
unlocks = require('scripts.unlocks')
tutorial = require('scripts.tutorial')
unlocksScreen = require('scripts.unlocksScreen')
stats = require('scripts.stats')
text = require('scripts.text')
saving = require('scripts.saving')
toolManuel = require('scripts.toolManuel')
processList = require('scripts.process')
graphicsManager = require('scripts.graphics')
menus = require('scripts.menu')
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

local function areItemsSameFormat2(repeatFormat, oldFormat)
	local aInOld = {0,0,0,0,0,0,0}
	for i = 1, #repeatFormat do
		if repeatFormat[i] > 7 then
			return false
		end
		if repeatFormat[i] ~= 0 then
			aInOld[repeatFormat[i]] = aInOld[repeatFormat[i]] + 1
		end
	end
	for i = 1, 7 do
		if aInOld[i] ~= oldFormat[i] then
			return false
		end
	end
	return true
end

local function doItemsNeededCalcs()
	local itemsNeededs = util.readJSON(saveDir..'/'..map.itemsNeededFile)
	local arr = {}
	local rooms = util.readJSON('RoomData/rooms.json').rooms
	for i = 1, #itemsNeededs do
		local room = itemsNeededs[i][1]
		local character = itemsNeededs[i][2]
		if arr[character] == nil then arr[character] = {} end
		ar = arr[character]
			local items = {}
			for j = 3, #itemsNeededs do
				items[#items+1] = itemsNeededs[i][j]
			end
			local new = true
			if rooms[room] ~= nil then
				if ar[room] == nil then
					ar[room] = {}
				end
				for j = 1, #ar[room] do
					if areItemsSame(ar[room][j],items) then
						new = false
					end
				end
				local isRepeat = false
				for k = 1, #rooms[room].itemsNeeded do
					isRepeat = isRepeat or areItemsSameFormat2(items, rooms[room].itemsNeeded[k])
				end
				new = new and not isRepeat
			else
				new = false
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
	gamePaused = false
	gameTime = {timeLeft = 260, toolTime = 0, roomTime = 30, levelTime = 120, donateTime = 20, goesDownInCompleted = false, totalTime = 0}

	enteringSeed = false
	seedOverride = nil
	typingCallback = nil
	mouseDown = false
	lastMoveKey = "w"
	debugText = nil
	tempAdd = 1
	editorMode = false
	editorAdd = 0
	globalPowerBlock = false
	globalDeathBlock = false

	pauseMenu = menus.pauseMenu:new()

	roomHeight = 12
	roomLength = 24

	donations = 100

	won = false

	unlocks.load()
	stats.load()

	tool = 0
	for i = 1, #tools do
		tools[i].numHeld = 0
	end

	animals = {}
	spotlights = {}
	pushables = {}
	bossList = {}
	processes = {}
	messageInfo = {x = 0, y = 0, text = nil}
	gabeUnlock = true
	--width = 16*screenScale
	--height = 9*screenScale
	--wallSprite = {width = 78*screenScale/50, height = 72*screenScale/50, heightForHitbox = 62*screenScale/50}

	wallSprite = {width = 187*width/1920, height = 170*height/1080, heightBottom = 150*height/1080}
	--image = love.graphics.newImage("cake.jpg")
	love.graphics.setNewFont(fontSize)
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(255,255,255)
	forcePowerUpdateNext = false

	graphicsManager.createShader()

	if not loadedOnce then
		fontFile = 'Resources/upheavtt.ttf'
		textBackground = love.graphics.newImage('Graphics/textBackground.png')

		--cursor = love.mouse.newCursor('Graphics/herman_small.png', 0, 0)
		--love.mouse.setCursor(cursor)

		tileUnit = 16
		love.graphics.setBackgroundColor(0,0,0)
		floorIndex = -1
		stairsLocs = {}
		--1 is opening world, 2-end-1 are floors, end is dungeon
		for i = 1, #map.defaultFloorOrder+1 do
			stairsLocs[i] = {map = {x = 0, y = 0}, coords = {x = 0, y = 0}}
		end

		--started = false
		shaderTriggered = true
		mushroomMode = false

		--should move much of stuff below to separate graphics class

		floorTransition = false
		floorTransitionInfo = {floor = 0, override = "", moved = false}

		gameTransition = false
		gameTransitionInfo = {type = "", moved = false}

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
		green = 'Graphics/green.png'
		blue = love.graphics.newImage('Graphics/blue.png')
		gray = love.graphics.newImage('Graphics/gray.png')
		white = love.graphics.newImage('Graphics/white.png')
		toolWrapper = love.graphics.newImage('GraphicsEli/marble1.png')
		titlescreenCounter = 5

		dungeonFloor = love.graphics.newImage('GraphicsEli/gold1.png')

		floortiles = {}
		floortiles[5] = {love.graphics.newImage('GraphicsEli/blueLines1.png'),love.graphics.newImage('GraphicsEli/blueLines2.png'),love.graphics.newImage('GraphicsEli/blueLines3.png')}
		floortiles[4] = {love.graphics.newImage('GraphicsEli/blueFloorBack.png'),love.graphics.newImage('GraphicsEli/blueFloorBack2.png'),love.graphics.newImage('GraphicsEli/blueFloorBack3.png')}
		floortiles[3] = {love.graphics.newImage('GraphicsBrush/purplefloor1.png'),love.graphics.newImage('GraphicsBrush/purplefloor2.png'),love.graphics.newImage('GraphicsBrush/purplefloor3.png')}
		floortiles[2] = {love.graphics.newImage('GraphicsColor/greenfloor.png'),love.graphics.newImage('GraphicsColor/greenfloor2.png'),love.graphics.newImage('GraphicsColor/greenfloor3.png')}
		--floortiles[1] = {floortile,floortile2, floortile3}
		--floortiles[1] = {grassrock1, grassrock2, grassrock3}
		floortiles[1] = {love.graphics.newImage('Graphics/woodfloortest.png'),love.graphics.newImage('Graphics/woodfloortest.png'),love.graphics.newImage('Graphics/woodfloortest.png')}
		floortiles[6] = floortiles[4]
		floortiles[7] = floortiles[4]
		floortiles[8] = floortiles[4]

		floors = {}
		floors[1] = love.graphics.newImage('Graphics/Floors/f1.png')
		floors[2] = love.graphics.newImage('Graphics/Floors/F2.png')
		floors[3] = love.graphics.newImage('Graphics/Floors/F3.png')
		--floors[6] = love.graphics.newImage('Graphics/Floors/f6.png')

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

		width2, height2 = love.window.getDesktopDimensions( 1 )
		if width2>height2*16/9 then
			height = height2
			width = height2*16/9
		else
			width = width2
			height = width2*9/16
		end
		flags = {fullscreen = true, centered = true}
		love.window.setMode(width, height, flags)
	end
	--print(love.graphics.getWidth(f1))
	scale = (width - 2*wallSprite.width)/(20.3 * 16)*5/6
	floor = tiles.tile
	tileHeight = util.getImage(floor.sprite):getHeight()
	tileWidth = util.getImage(floor.sprite):getWidth()

	local setChar = characters[1]
	if player~=nil and player.character~=nil then
		setChar = player.character
	end

	player = { 	baseLuckBonus = 1, dirFacing = 1, dungeonKeysHeld = 0, finalKeysHeld = 0, range = 300, biscuitHeld = false, clonePos = {x = 0, y = 0, z = 0}, dead = false, elevation = 0, moveMode = 0, speed = 50*scale, safeFromAnimals = false, bonusRange = 0, active = true, waitCounter = 0, tileX = 10, tileY = 6, x = (1-1)*scale*tileWidth+wallSprite.width+tileWidth/2*scale-10, 
			y = (6-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10, prevTileX = 3, prevTileY 	= 10,
			prevx = (3-1)*scale*tileWidth+wallSprite.width+tileWidth/2*scale-10,
			prevy = (10-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10,
			width = 20, height = 20, speed = 250, luckTimer = 0, regularMapLoc = {x = 0, y = 0}, nonHeavenMapLoc = {x = 0, y = 0}, supersHeld = {total = 0}, returnFloorInfo = {floorIndex = 0, tileX = 0, tileY = 0}, attributes = {superRammy = false, timeFrozen = false, invincibleCounter = 0, shieldCounter = 0, lucky = false, gifted = false, permaMap = false, xrayVision = false, upgradedToolUse = false, fast = {fast = false, fastStep = false}, flying = false, fear = false, shelled = false, tall = false, extendedRange = 0, sockStep = false, invisible = false, clockFrozen = false}}
	player.character = setChar

	specialTools = {}
	for i = 1, player.character.superSlots do
		specialTools[i] = 0
	end

	map.clearBlacklist()

	if loadTutorial then
		player.enterX = player.tileX
		player.enterY = player.tileY
		player.totalItemsGiven = {0,0,0,0,0,0,0}
		player.totalItemsNeeded = {0,0,0,0,0,0,0}
	end
	function player:getTileLoc()
		return {x = self.x/(tileWidth*scale), y = self.y/(tileWidth*scale)}
	end
	if not loadedOnce then
		loadOpeningWorld()
	end

	loadedOnce = true
end

function playMusic(index)
	music.currentIndex = index
	for i = 1, #music do
		music[i]:stop()
	end
	if (index>0 and music[index]~=nil) then
		music[index]:setVolume(music.volume)
		music[index]:play()
	end
end

function setMusicVolume(volume)
	music.volume = volume
	music[music.currentIndex]:setVolume(volume)
end

function goToMainMenu()
	if not unlocks.tutorialBeatenUnlock.unlocked then
		gamePaused = false
		return
	end

	if room[player.tileY][player.tileX]~=nil then
		room[player.tileY][player.tileX]:onLeave(player)
	end

	if saving.isPlayingBack() and not gamePaused then
		return
	elseif not saving.isPlayingBack() then
		saving.endRecording()
	end
	saving.endPlayback()
	--started = false
	editorMode = false
	myShader:send("b_and_w", 0)
	loadOpeningWorld()
	resetPlayer()
	gamePaused = false
	won = false
	player.dead = false
	updateGameState()
	updateCursor()
	playMusic(1)
end

function emptyTools()
	for i = 1, #tools do
		tools[i].numHeld = 0
		tools[i]:resetTool()
	end
	updateTools()
end

function resetPlayer()
	emptyTools()
	player.attributes.flying = false
	player.attributes.fear = false
	player.attributes.sockStep = false
	player.attributes.shelled = false
	player.attributes.invisible = false
	player.attributes.fast = {fast = false, fastStep = false}
	player.attributes.extendedRange = 0
	player.supersHeld = {total = 0}
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
	util.newRandom('boss', seed*7)
	return seed
end

function preFloorChange()
	saveElements()

	if floorIndex==4 then
		unlocks.unlockUnlockableRef(unlocks.mainGameUnlock)
		unlocks.unlockUnlockableRef(unlocks.editorUnlock)
	end
end

function goDownFloor()
	preFloorChange()

	stairsLocs[floorIndex] = {map = {x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
	if map.loadedMaps[floorIndex+1] == nil then
		loadNextLevel()
	else
		local mapToLoad = map.loadedMaps[floorIndex+1]
		floorIndex = floorIndex + 1
		map.floorInfo = mapToLoad.floorInfo
		mainMap = mapToLoad.map
		mapHeight = mapToLoad.mapHeight

		mapx = stairsLocs[floorIndex].map.x
		mapy = stairsLocs[floorIndex].map.y
		room = mainMap[mapy][mapx].room
		player.tileX = stairsLocs[floorIndex].coords.x
		player.tileY = stairsLocs[floorIndex].coords.y

		roomHeight = mapToLoad.roomHeight
		roomLength = mapToLoad.roomLength
		completedRooms = mapToLoad.completedRooms
		visibleMap = mapToLoad.visibleMap

		animals = {}
		pushables = {}
		prevRoom = room
		litTiles = {}
		for i = 1, roomHeight do
			litTiles[i] = {}
		end
	end
	postFloorChange()
end

function goUpFloor()
	preFloorChange()

	stairsLocs[floorIndex] = {map = {x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
	if floorIndex == 2 then
		goToMainMenu()
	else
		local mapToLoad = map.loadedMaps[floorIndex-1]
		floorIndex = floorIndex - 1
		map.floorInfo = mapToLoad.floorInfo
		mainMap = mapToLoad.map
		mapHeight = mapToLoad.mapHeight

		mapx = stairsLocs[floorIndex].map.x
		mapy = stairsLocs[floorIndex].map.y
		room = mainMap[mapy][mapx].room
		player.tileX = stairsLocs[floorIndex].coords.x
		player.tileY = stairsLocs[floorIndex].coords.y

		roomHeight = mapToLoad.roomHeight
		roomLength = mapToLoad.roomLength
		completedRooms = mapToLoad.completedRooms
		visibleMap = mapToLoad.visibleMap
		createElements()
		prevRoom = room
		litTiles = {}
		for i = 1, roomHeight do
			litTiles[i] = {}
		end
		if not loadTutorial then
			playMusic(floorIndex)
		end
	end
	postFloorChange()
end
function goToFloor(floorNum)
	preFloorChange()
	local stairsLocsIndex = floorIndex
	if floorIndex==1 then
		stairsLocsIndex = #stairsLocs
	end
	stairsLocs[stairsLocsIndex] = {map = {x = mapx, y = mapy}, coords = {x = player.tileX, y = player.tileY}}
	floorIndex = floorNum
	local mapToLoad = map.loadedMaps[floorIndex]
	mainMap = mapToLoad.map
	mapHeight = mapToLoad.mapHeight
	roomHeight = mapToLoad.roomHeight
	roomLength = mapToLoad.roomLength
	completedRooms = mapToLoad.completedRooms
	visibleMap = mapToLoad.visibleMap
	map.floorInfo = mapToLoad.floorInfo
	prepareFloor()
	if not loadTutorial then
		playMusic(floorIndex)
	end
	currentid = tostring(mainMap[mapy][mapx].roomid)
	if map.getFieldForRoom(currentid, 'autowin') then
		completedRooms[mapy][mapx] = 1
		unlockDoors()
	end
	createElements()
	postFloorChange()
end

function postFloorChange()
	spotlights = {}

	if player.attributes.xrayVision then
		for i = 1, mapHeight do
			for j = 1, mapHeight do
				if mainMap[i][j]~=nil then
					local xrayId = mainMap[i][j].roomid
					if map.getFieldForRoom(xrayId, 'hidden')~=nil and map.getFieldForRoom(xrayId, 'hidden') then
						visibleMap[i][j] = 1
					end
				end
			end
		end
	end

	if player.attributes.permaMap then
		--tools.map.useToolNothing(self)
	end

	completedRooms[mapy][mapx] = 1
	currentid = tostring(mainMap[mapy][mapx].roomid)
	if map.getFieldForRoom(currentid, 'autowin') then
		completedRooms[mapy][mapx] = 1
		unlockDoors()
	end

	setPlayerLoc()

    updateGameState()

    if floorIndex==7 then
		stats.incrementStat(player.character.name..'ReachFloor6')    	
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
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j]:instanceof(tiles.upTunnel) then
				player.tileY = i
				player.tileX = j

				setPlayerLoc()
			end
		end
	end
	--hack to make it not happen on the first floor
	if floorIndex ~= 2 then
		player.character:onFloorEnter()
	end
	if unlocks.floorUnlocks[floorIndex-1] ~= nil then
		unlocks.unlockUnlockableRef(unlocks.floorUnlocks[floorIndex-1])
	end
	updateGameState()
end

function startGame()
	stats.resetTempStats()
	local seed = loadRandoms()
	if not saving.isPlayingBack() then
		stats.incrementStat('runNumber')
	end
	saving.createNewRecording(seed)
	loadTutorial = false
	map.floorOrder = map.defaultFloorOrder
	love.load()
	loadFirstLevel()
	tools.resetTools()
	--resetPlayer()
	player.character:onBegin()
	resetTintValues()
end

function startDaily()
	stats.resetTempStats()

	local date = os.date("*t")
	local month = date.month
	local day = date.day
	local year = date.year

	seedOverride = math.pow(7,month)+math.pow(3,day)+math.pow(2,year%100)

	local seed = loadRandoms()
	if not saving.isPlayingBack() then
		stats.incrementStat('runNumber')
	end
	saving.createNewRecording(seed)
	loadTutorial = false
	map.floorOrder = map.defaultFloorOrder
	love.load()
	loadFirstLevel()
	tools.resetTools()
	--resetPlayer()
	player.character = characters.random
	player.character:onBegin()
	resetTintValues()
end

function loadOpeningWorld()
	floorIndex = -1
	loadRandoms()
	loadLevel('RoomData/openingworld.json')

	if stairsLocs[1].map.x~=0 then
		mapx = stairsLocs[1].map.x
		mapy = stairsLocs[1].map.y
		room = mainMap[mapy][mapx].room
		player.tileX = stairsLocs[1].coords.x
		player.tileY = stairsLocs[1].coords.y

		if unlocks.tutorialBeatenUnlock.unlocked then
			unlockDoorsOpeningWorld()	
		end
	else
		--getting initial room, depending on if tutorial has been beaten or not
		for i = 1, mapHeight do
			for j = 1, mapHeight do
				if mainMap[i][j]~=nil and mainMap[i][j].roomid~=nil then
					local testStartRoomID = mainMap[i][j].roomid
					if unlocks.tutorialBeatenUnlock.unlocked then
						if map.getFieldForRoom(testStartRoomID, "isInitial") and
						map.getFieldForRoom(testStartRoomID, "isInitialAfterTut")~=nil and map.getFieldForRoom(testStartRoomID, "isInitialAfterTut") then
							mapy = i
							mapx = j

							--reveal map
							unlockDoorsOpeningWorld()
						end
					else
						if map.getFieldForRoom(testStartRoomID, "isInitial") and
						map.getFieldForRoom(testStartRoomID, "isInitialBeforeTut")~=nil and map.getFieldForRoom(testStartRoomID, "isInitialBeforeTut") then
							mapy = i
							mapx = j
						end
					end
				end
			end
		end

		--set room
		room = mainMap[mapy][mapx].room
		roomLength = room.length
		roomHeight = room.height

		--default coordinates
		player.tileX = math.floor(roomLength/2)
		player.tileY = roomHeight-3

		if not unlocks.tutorialBeatenUnlock.unlocked then
			player.tileY = math.floor(roomHeight/2)
			player.tileX = 3
		end
	end

	player.prevTileX = player.tileX
	player.prevTileY = player.tileY

	--tutorial hacky stuff
	player.totalItemsGiven = {0,0,0,0,0,0,0}
	player.totalItemsNeeded = {0,0,0,0,0,0,0}
	player.enterY = player.tileY
	player.enterX = player.tileX

	roomHeight = room.height
	roomLength = room.length
	updateLight()
	started = true

	setPlayerLoc()
	
	--player.character:onBegin()
	myShader:send("tint_r", player.character.tint[1])
    myShader:send("tint_g", player.character.tint[2])
    myShader:send("tint_b", player.character.tint[3])

	--remove supers
	emptyTools()

	postRoomEnter()
	--unlockDoors()
	updateGameState()
end

function startTutorial()
	stats.resetTempStats()
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
	stats.resetTempStats()
	loadRandoms()
	loadTutorial = false
	map.floorOrder = {'RoomData/debugFloor.json', 'RoomData/exitDungeonsMap.json'}
	love.load()
	loadFirstLevel()
	tools.resetTools()
	player.character:onBegin()
	resetTintValues()
	gameTime.timeLeft = 20000
end

function startEditor()
	stats.resetTempStats()
	loadRandoms()
	loadTutorial = false
	map.floorOrder = {'RoomData/editorFloor.json'}
	love.load()
	loadFirstLevel()
	map.loadCustomRooms(saveDir..'/customRooms.json')
	tools.resetTools()
	player.character:onBegin()
	editorMode = true
	resetTintValues()
end

function resetTintValues()
	myShader:send("tint_r", 1)
	myShader:send("tint_g", 1)
	myShader:send("tint_b", 1)
end

function loadFirstLevel()
	emptyTools()
	floorIndex = 1
	map.loadedMaps = {}
	loadLevel(map.floorOrder[#map.floorOrder])
	endMap = mainMap
	loadNextLevel(true)
	if map.getFieldForRoom(mainMap[mapy][mapx].roomid, 'autowin') then
		completedRooms[mapy][mapx] = 1
		unlockDoors()
	end
	createElements()
	updateGameState()
	player.character:onStartGame()
end

function prepareFloor()
	animals = {}
	pushables = {}
	spotlights = {}
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
							local rand = util.random(100, 'mapGen')
							if rand<=1+getLuckBonus() then
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
	if floorIndex>-1 then
		shaderTriggered = true
		map.loadedMaps[#map.loadedMaps+1] = {map = mainMap, mapHeight = mapHeight, floorInfo = map.floorInfo,
	  		roomHeight = roomHeight, roomLength = roomLength, completedRooms = completedRooms, visibleMap = visibleMap}
	end
end

function kill(deathSource)
	if player.dead then return end
	if editorMode or globalDeathBlock or player.attributes.invincibleCounter>0 then return end
	--[[if validSpace() and completedRooms[mapy][mapx]>0 then
		unlocks.unlockUnlockableRef(unlocks.portalUnlock)
	end]]
	player.dead = true
	for i = 1, #specialTools do
		if tools[specialTools[i]]~=nil and tools[specialTools[i]].numHeld>0 and not tools[specialTools[i]]:checkDeath(deathSource) then
			player.dead = false
			onToolUse(specialTools[i])
			return
		end
	end
	if not loadTutorial and floorIndex>=0 then --hacky hack fix
		completedRooms[mapy][mapx] = 0 --to stop itemsNeeded tracking, it's a hack!
	end
	stats.incrementStat(player.character.name..'Losses')
	stats.incrementStat('totalLosses')

	if player.dead then
    	local fadeProcess = processList.fadeProcess:new()
		processes[#processes+1] = fadeProcess
	end

	saving.endRecording()
end

function win()
	if not won then
		if loadTutorial then
			unlocks.unlockUnlockableRef(unlocks.franciscoUnlock, true)
		end
		if gameTime.totalTime < 900 then
			unlocks.unlockUnlockableRef(unlocks.erikUnlock)
		end
		--if gabeUnlock then
		--[[if player.attributes.flying then
			unlocks.unlockUnlockableRef(unlocks.gabeUnlock)
		end]]
		
		won = true
		if player.dungeonKeysHeld >= 3 then
			stats.incrementStat(player.character.name..'DungeonWins')
			stats.incrementStat('totalDungeonWins')
		end

		if floorIndex>=8 then
			stats.incrementStat(player.character.name..'WinsPlus')
		end

		stats.incrementStat(player.character.name..'Wins')
		stats.incrementStat('totalWins')
		--[[if player.character.name=="Herman" then
			unlocks.unlockUnlockableRef(unlocks.boxesUnlock, true)
		end]]

		if stats.tempStatsData['toolsUsed']~=nil and stats.tempStatsData['toolsUsed']==52 then
			unlocks.unlockUnlockableRef(unlocks.cardUnlock)
		end
	end
end

maxLamps = 100

function updateLamps(tileY, tileX)
	if not started then return end

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
			lampHolder[i][1] = (lampHolder[i][1]-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
			lampHolder[i][2] = (lampHolder[i][2]-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
			lampHolder[i][1] = lampHolder[i][1]+(width2-width)/2+getTranslation().x*tileWidth*scale
			lampHolder[i][2] = lampHolder[i][2]+(height2-height)/2+getTranslation().y*tileHeight*scale
		end
	end

	myShader:send("lamps", unpack(lampHolder))
end

function updateLight()
	if editor.visionHack then
		litTiles = {}
		for i = 1, roomHeight do
			litTiles[i]={}
		end
		for i = 1, roomHeight do
			for j = 1, roomLength do
				litTiles[i][j]=1
			end
		end
		player.character:onPostUpdateLight()
		return
	end
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
	if player.attributes.timeFrozen or player.attributes.sockStep then return end
	player.character:onPreUpdatePower()
	for i = 1, #bossList do
		bossList[i]:onPreUpdatePower()
	end
	powerCount = 0

	for i = 1, #pushables do
		pushables[i].powered = false
	end

	for i=1, roomHeight do
		for j=1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				room[i][j].powered = false
				room[i][j].poweredNeighbors = {0,0,0,0}
				if room[i][j].overlay ~= nil and room[i][j].overlay.canBePowered then
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

	for i = 1, #pushables do
		if pushables[i].charged then
			pushables[i].powered = false
			powerTestPushable(pushables[i].tileY, pushables[i].tileX, 0)
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
			if not pushables[i].charged then
				pushables[i].powered = false
			end
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
					if pushables[i].charged then conductPower = true end
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
				if animals[i].conductive and not animals[i].dead then
					local conductPower = false
					local pX = animals[i].tileX
					local pY = animals[i].tileY

					if animals[i].charged then conductPower = true end

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
					if pushables[i].charged then conductPower = true end
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
							powerTest(pY, pX, 0)
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

					if animals[i].charged then conductPower = true end

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
						if pushables[k].tileY==i+1 and pushables[k].tileX==j and room[i][j].dirAccept[3]==1 then
							room[i][j].poweredNeighbors[3]=1
						end
						if pushables[k].tileY==i-1 and pushables[k].tileX==j and room[i][j].dirAccept[1]==1 then
							room[i][j].poweredNeighbors[1]=1
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
	for i = 1, #bossList do
		bossList[i]:onPostUpdatePower()
	end
	player.character:onPostUpdatePower()
end

function lightTest(x, y)
	--x refers to y-direction and vice versa
	--1 for up, 2 for right, 3 for down, 4 for left
	if room[x] == nil or (litTiles[x][y] == 1) then
		return
	end

	litTiles[x][y] = 1

	if room[x][y] ~= nil and room[x][y]:lightTest(x,y) then
		return
	end

	if room[x][y] ~= nil and room[x][y]:obstructsVision() and (player.tileY ~= x or player.tileX ~= y) then
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
	player.character:specialLightTest(x,y)
end

function powerTest(x, y, lastDir)
	powerCount = powerCount+1
	if powerCount>3000 then
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

	--power tile directly below
	if room[x][y]~=nil then
		formerPowered = room[x][y].powered
		formerSend = room[x][y].dirSend
		formerAccept = room[x][y].dirAccept
		--powered[x-1][y] = 1
		room[x][y].poweredNeighbors = {1,1,1,1}
		room[x][y]:updateTileAndOverlay(0)
		if room[x][y].powered ~= formerPowered or room[x][y].dirSend ~= formerSend or room[x][y].dirAccept ~= formerAccept then
			powerTestSpecial(x,y,0)
		end
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

	if x>1 and room[x-1][y]~=nil and (not room[x-1][y]:instanceof(tiles.notGate)) and canBePowered(x-1,y,3) and lastDir~=1 then
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


	if x<roomHeight and room[x+1][y]~=nil and (not room[x+1][y]:instanceof(tiles.notGate)) and canBePowered(x+1,y,1) and lastDir~=3 then
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

	if y>1 and room[x][y-1]~=nil and (not room[x][y-1]:instanceof(tiles.notGate)) and canBePowered(x,y-1,2) and lastDir~=4 then
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

	if y<roomLength and room[x][y+1]~=nil and (not room[x][y+1]:instanceof(tiles.notGate)) and canBePowered(x,y+1,4) and lastDir~=2 then
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
	graphicsManager.draw()
end

translation = {x = 0, y = 0}
function getTranslation()
	--xInteger, yInteger ignore actual coords mid-animation
	local translation = {x = 0, y = 0, xInteger = 0, yInteger = 0}
	local prevTranslation = {x = 0, y = 0}
	local tileLoc = tileToCoordsPlayer(player.tileY, player.tileX)

	if roomLength>regularLength then
		translation.x = player.tileX-1-regularLength/2
		prevTranslation.x = player.prevTileX-1-regularLength/2
		if translation.x > roomLength - regularLength then translation.x = roomLength - regularLength
		elseif translation.x < 0 then translation.x = 0 end
		if prevTranslation.x > roomLength - regularLength then prevTranslation.x = roomLength - regularLength
		elseif prevTranslation.x < 0 then prevTranslation.x = 0 end
		translation.xInteger = translation.x
		if (translation.x~=prevTranslation.x) then
			--mid-movement translation
			translation.x = translation.x-(tileLoc.x-player.x)/(tileUnit*scale)
		end
	elseif roomLength<regularLength then
		local lengthDiff = regularLength-roomLength
		translation.x = -1*math.floor(lengthDiff/2)
		translation.xInteger = translation.x
	end
	if roomHeight>regularHeight then
		translation.y = player.tileY-1-regularHeight/2
		prevTranslation.y = player.prevTileY-1-regularHeight/2
		if translation.y > roomHeight - regularHeight then translation.y = roomHeight - regularHeight
		elseif translation.y < 0 then translation.y = 0 end
		if prevTranslation.y > roomHeight - regularHeight then prevTranslation.y = roomHeight - regularHeight
		elseif prevTranslation.y < 0 then prevTranslation.y = 0 end
		translation.yInteger = translation.y
		if (translation.y~=prevTranslation.y) then
			--mid-movement translation
			translation.y = translation.y-(tileLoc.y-player.y)/(tileUnit*scale)
		end
	elseif roomHeight<regularHeight then
		local heightDiff = regularHeight-roomHeight
		translation.y = -1*math.floor(heightDiff/2)
		translation.yInteger = translation.y
	end
	translation.x = translation.x*-1
	translation.y = translation.y*-1
	translation.xInteger = translation.xInteger*-1
	translation.yInteger = translation.yInteger*-1
	return translation
end

function resetTranslation()
	translation = {x = 0, y = 0}
end

function log(text)
	debugText = text
	if text ~= nil and text ~= "" then
		--print('LOG: '..debugText)
	end
end

function adjacent(xloc, yloc)
	xCorner = player.x
	yCorner = player.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*tileWidth))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*tileHeight))
	if math.abs(tileLoc1-xloc)+math.abs(tileLoc2-yloc)<=1 then
		return true
	end

	xCorner = player.x+player.width
	yCorner = player.y-player.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*tileWidth))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*tileHeight))
	if math.abs(tileLoc1-xloc)+math.abs(tileLoc2-yloc)<=1 then
		return true
	end
	

	xCorner = player.x
	yCorner = player.y-player.height
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*tileWidth))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*tileHeight))
	if math.abs(tileLoc1-xloc)+math.abs(tileLoc2-yloc)<=1 then
		return true
	end

	xCorner = player.x+player.width
	yCorner = player.y
	tileLoc1 = math.ceil((xCorner-wallSprite.width)/(scale*tileWidth))
	tileLoc2 = math.ceil((yCorner-wallSprite.height)/(scale*tileHeight))
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
	createElements()
	updateGameState(false)
	return true
end

function createElements()
	createAnimals()
	createPushables()
	createSpotlights()
	createBosses()
end

function tileToCoords(tileY, tileX)
	local ret = {x = 0, y = 0}
	ret.x = tileToCoordsX(tileX)
	ret.y = tileToCoordsY(tileY)
	return ret
end

function tileToCoordsY(tileY)
	return (tileY-1)*scale*tileUnit+wallSprite.height
end

function tileToCoordsX(tileX)
	return (tileX-1)*scale*tileUnit+wallSprite.width
end

function coordsToTile(y,x)
	local ret = {x = 0, y = 0}
	ret.x = coordsToTileX(x)
	ret.y = coordsToTileY(y)
	return ret
end

function coordsToTileY(y)
	return math.floor((y-wallSprite.height)/(scale*tileHeight)+1)
end

function coordsToTileX(x)
	return math.floor((x-wallSprite.width)/(scale*tileHeight)+1)
end

function createSpotlights()
	spotlights = {}
	if room.spotlights~=nil then spotlights = room.spotlights return end
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil and room[i][j].spotlight ~= nil then
				local spotlightToAdd = room[i][j].spotlight:new()
				spotlightToAdd.y = tileToCoords(i,j).y
				spotlightToAdd.x = tileToCoords(i,j).x
				spotlightToAdd.dir = room[i][j].rotation
				spotlights[#spotlights+1] = spotlightToAdd
			end
		end
	end
end

function createAnimals()
	if room.animals~=nil then animals = room.animals return end
	animals = {}
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name~=nil and (room[i][j].animal~=nil) then
				animalToSpawn = room[i][j].animal
				if not animalToSpawn.dead then
					animals[#animals+1] = animalToSpawn
					if not animalToSpawn.loaded then
						animalToSpawn.tileX = j
						animalToSpawn.tileY = i
						animalToSpawn.prevTileX = j
						animalToSpawn.prevTileY = i
						animalToSpawn:setLoc()
						local willDropChance = util.random(150,'toolDrop')
						if willDropChance==1 and animalToSpawn.canDropTool then
							animalToSpawn.willDropTool = true
						end
						animalToSpawn.loaded = true
					end
				end
			end
		end
	end
end

function createBosses()
	if room.bosses~=nil then bossList = room.bosses return end
	bossList = {}
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil and room[i][j].name~=nil and (room[i][j].boss~=nil) then
				bossToSpawn = room[i][j].boss:new()
				bossToSpawn:load(i,j)
				bossList[#bossList+1] = bossToSpawn
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
					pushables[#pushables].y = (i-1)*tileWidth*scale+wallSprite.height
					pushables[#pushables].x = (j-1)*tileHeight*scale+wallSprite.width
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
	player.attributes.sockStep = false
	player.attributes.shelled = false
	player.attributes.invisible = false
	player.attributes.fast = {fast = false, fastStep = false}
	player.attributes.timeFrozen = false
	player.attributes.superRammy = false
	player.attributes.clockFrozen = false

	
	

	if tools.demonFeather.numHeld>0 then
		player.attributes.flying = true
	end
	if tools.demonHoof.numHeld>0 then
		player.attributes.superRammy = true
	end

	turnOffMushroomMode()
end

function resetPlayerAttributesTool()
	if player.attributes.upgradedToolUse and tool>0 and tool<=tools.numNormalTools then
		player.attributes.upgradedToolUse = false
		tools.tempUpgrade:resetTools()
	end

	tools.lastToolUsed = tool
end

function resetPlayerAttributesStep()
end

function updateAttributesRealtime(dt)
	if player.attributes.invincibleCounter>0 then
		player.attributes.invincibleCounter = math.max(player.attributes.invincibleCounter-dt,0)
		if player.attributes.invincibleCounter==0 then
			if tools.shrooms.active then
				tools.shrooms.numHeld = tools.shrooms.numHeld-1
				updateTools()
				tools.shrooms.active = false
				tools.shrooms:updateSprite()
				turnOffMushroomMode()

			end
			if tools.shroomRevive.active then
				tools.shroomRevive.numHeld = tools.shroomRevive.numHeld-1
				updateTools()
				tools.shroomRevive.active = false
				tools.shroomRevive:updateSprite()
				turnOffMushroomMode()

			end
		end
	end
end

function beginFloorSequence(nextFloor, floorOverride)
	floorTransition = true
	floorTransitionInfo = {floor = nextFloor, override = floorOverride, moved = false}
end

function beginGameSequence(type)
	gameTransition = true
	gameTransitionInfo = {gameType = type}
end

function turnOffMushroomMode()
	mushroomMode = false
	myShader:send("createShadows", true)
	globalTint = {1,1,1}
	myShader:send("tint_r", globalTint[1])
	myShader:send("tint_g", globalTint[2])
	myShader:send("tint_b", globalTint[3])
end

function turnOnMushroomMode()
	mushroomMode = true
	globalTint = {0.5,0.75,1}
	myShader:send("createShadows", false)
end

function getLuckBonus()
	local luckBonus = player.baseLuckBonus
	luckBonus = luckBonus+3.5*tools.luckyPenny.numHeld
	luckBonus = luckBonus+5*tools.luckyCharm.numHeld
	return luckBonus
end

function saveElements()
	room.pushables = pushables
	room.animals = animals
	room.spotlights = spotlights
	room.bosses = bossList
end

function enterRoom(dir)
	if not tools.shrooms.active then
		turnOffMushroomMode()
	end

	if not validSpace() then return end
	log("")

	local plusOne = true

	if player.tileY == math.floor(roomHeight/2) then plusOne = false
	elseif player.tileX == math.floor(roomLength/2) then plusOne = false end

	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
	local prevMapX = mapx
	local prevMapY = mapy
	local prevRoom = room

	local mapChange = util.getOffsetByDir(dir+1)
	if not map.isDoorOpen(mapy, mapx, dir+1) then
		return
	end

	--tutorial stuff below
	--marks room as fully beaten, so you can't, for example, die in dog room after reaching end tile
	--and still beat it
	if loadTutorial or floorIndex==-1 then
		if completedRooms[mapy][mapx]==1 and
		(mainMap[mapy][mapx].leftCompleted==nil or not mainMap[mapy][mapx].leftCompleted) then
			if map.getItemsGiven(mainMap[mapy][mapx].roomid)~=nil then
				for i = 1, tools.numNormalTools do
					player.totalItemsGiven[i] = player.totalItemsGiven[i] + map.getItemsGiven(mainMap[mapy][mapx].roomid)[1][i]
					player.totalItemsNeeded[i] = player.totalItemsNeeded[i] + map.getItemsNeeded(mainMap[mapy][mapx].roomid)[1][i]
				end
			end
			mainMap[mapy][mapx].leftCompleted = true
		end
	end

	resetTranslation()
	resetPlayerAttributesRoom()

	--set pushables of prev. room to pushables array, saving for next entry
	saveElements()

	mapy = mapy+mapChange.y
	mapx = mapx+mapChange.x
	room = mainMap[mapy][mapx].room
	roomHeight = room.height
	roomLength = room.length
	--player.y = height-wallSprite.heightBottom-5
	player.tileY = roomHeight
	if plusOne then player.tileX = math.floor(roomLength/2)+1
	else player.tileX = math.floor(roomLength/2) end

	if dir==0 then
		player.tileY = roomHeight
		if plusOne then player.tileX = math.floor(roomLength/2)+1
		else player.tileX = math.floor(roomLength/2) end
	elseif dir==1 then
		player.tileX = 1
		if plusOne then player.tileY = math.floor(roomHeight/2)+1
		else player.tileY = math.floor(roomHeight/2) end
	elseif dir==2 then
		player.tileY = 1
		if plusOne then player.tileX = math.floor(roomLength/2)+1
		else player.tileX = math.floor(roomLength/2) end
	elseif dir==3 then
		player.tileX = roomLength
		if plusOne then player.tileY = math.floor(roomHeight/2)+1
		else player.tileY = math.floor(roomHeight/2) end
	end

	if (prevMapX~=mapx or prevMapY~=mapy) or dir == -1 then
		createElements()
	end
	--check if box blocking doorway
	for i = 1, #pushables do
		if not pushables[i].destroyed and pushables[i].tileY == player.tileY and pushables[i].tileX == player.tileX then
			room = prevRoom
			player.tileX = player.prevTileX
			player.tileY = player.prevTileY
			mapx = prevMapX
			mapy = prevMapY
			createElements()
			break
		end
	end

	currentid = tostring(mainMap[mapy][mapx].roomid)
	if map.getFieldForRoom(currentid, 'autowin') then
		completedRooms[mapy][mapx] = 1
		unlockDoors()
	end
	if loadTutorial or floorIndex == -1 then
		player.enterX = player.tileX
		player.enterY = player.tileY
	end

	--check tutorial beaten
	if map.getFieldForRoom(currentid, "isInitial") and
	map.getFieldForRoom(currentid, "isInitialAfterTut")~=nil and map.getFieldForRoom(currentid, "isInitialAfterTut") then
		unlocks.unlockUnlockableRef(unlocks.tutorialBeatenUnlock, true)
	end

	if room.tint==nil then room.tint = {1,1,1} end

	player.prevTileY = player.tileY
	player.prevTileX = player.tileX

	player.character:onRoomEnter()

	visibleMap[mapy][mapx] = 1
	keyTimer.timeLeft = keyTimer.suicideDelay
	updateGameState(false)
	--tutorial.enterRoom()
	--^^not sure why that was there...?

	postRoomEnter()

	setPlayerLoc()
	checkCurrentTile()
end

function setPlayerLoc()
	--player.x is middle of body
	--player.y is bottom of feet
	--coords mark where "hitbox" is, not where drawing actually starts
	local coords = tileToCoordsPlayer(player.tileY, player.tileX)
	player.x = coords.x
	player.y = coords.y

    myShader:send("player_x", player.x+getTranslation().x*tileUnit*scale+(width2-width)/2)
    myShader:send("player_y", player.y+getTranslation().y*tileUnit*scale+(height2-height)/2)
end

function tileToCoordsPlayer(tileY, tileX)
	local ret = {x = 0, y = 0}
	ret.x = tileToCoordsXPlayer(tileX)
	ret.y = tileToCoordsYPlayer(tileY)
	return ret
end

function tileToCoordsYPlayer(tileY)
	--bottom of feet not actually halfway on tile
	--looks better this way b/c feet have very slight depth
	return (tileY-1)*scale*tileUnit+wallSprite.height+scale*(2/3*tileUnit)
end

function tileToCoordsXPlayer(tileX)
	return (tileX-1)*scale*tileUnit+wallSprite.width+scale*tileUnit/2
end

function postRoomEnter()
	if tools.tileSwapper.numHeld>0 then
		tools.tileSwapper.toSwapCoords = nil
		tools.tileSwapper.image = tools.tileSwapper.baseImage
	end
	if tools.playerCloner.cloneExists then
		tools.playerCloner.cloneExists = false
		player.clonePos = {x = 0, y = 0, z = 0}
		tools.playerCloner.image = tools.playerCloner.imageNoClone
	end
	if player.character.shiftPos~=nil then
		player.character:resetClone()
	end

	if player.attributes.gifted then
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

	player.character:postMove()

	--shut off player move animations
	for i = 1, #processes do
		if processes[i]:instanceof(processList.movePlayer) then
			processes[i].active = false
		end
	end
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
			if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].overlay~=nil and
			room[player.tileY][player.tileX].allowsOverlayPickups then
				room[player.tileY][player.tileX].overlay:onStay(player)
			end
		else
			player.character:preTileEnter(room[player.tileY][player.tileX])
			preTileEnter(room[player.tileY][player.tileX])
			room[player.tileY][player.tileX]:onEnter(player)
			if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].overlay~=nil and
			room[player.tileY][player.tileX].allowsOverlayPickups then
				room[player.tileY][player.tileX].overlay:onEnter(player)
			end
		end
	end
	if not (player.prevTileY == player.tileY and player.prevTileX == player.tileX) then
		if room~=nil and not player.justTeleported and room[player.prevTileY][player.prevTileX]~=nil then
			room[player.prevTileY][player.prevTileX]:onLeave(player)
			if room[player.prevTileY][player.prevTileX]~=nil and room[player.prevTileY][player.prevTileX].overlay~=nil then
				room[player.prevTileY][player.prevTileX].overlay:onLeave(player)
			end
		end
		player.character:onTileLeave()
	end
end

function preTileEnter(tile)
	if player.attributes.superRammy then
		if tile:instanceof(tiles.wall) and not tile.destroyed and player.elevation<tile:getHeight()-3 then
			tile:destroy()
		end
	end
end

function validSpace()
	return mapy<=mapHeight and mapx<=mapHeight and mapy>0 and mapx>0
end

keyTimer = {base = .14, timeLeft = .14, suicideDelay = .65}
function love.update(dt)
	dt = gameSpeed*dt

	globalCounter = globalCounter+dt

	if gamePaused then
		return
	end

	saving.sendNextInputFromRecording()
	if player~=nil and player.character~=nil then
		player.character:update(dt)
	end
	updateAttributesRealtime(dt)

	local allProcesses = processes
	processes = {}
	for i = 1, #allProcesses do
		if allProcesses[i].active then
			processes[#processes+1] = allProcesses[i]
		end
	end
	for i = 1, #processes do
		processes[i]:run(dt)
	end

	--smooth motion
	if love.keyboard.isDown("w") and lastMoveKey=="w" then
		love.keypressed("w")
	elseif love.keyboard.isDown("a") and lastMoveKey=="a" then
		love.keypressed("a")
	elseif love.keyboard.isDown("s") and lastMoveKey=="s" then
		love.keypressed("s")
	elseif love.keyboard.isDown("d") and lastMoveKey=="d" then
		love.keypressed("d")
	end

	--sprint hax
	if love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") then
		gameSpeed = defaultGameSpeed * 1.7
	else
		gameSpeed = defaultGameSpeed
	end

	if (titlescreenCounter>0) then
		titlescreenCounter = titlescreenCounter-dt
		if globalTint[1]<1 then
			for i = 1, 3 do
				globalTint[i] = globalTint[i]+dt/3
				myShader:send("tint_r", globalTint[1])
				myShader:send("tint_g", globalTint[2])
				myShader:send("tint_b", globalTint[3])
			end
		end
	end
	if loadTutorial then
		tutorial.update(dt)
	end

	if (love.keyboard.isDown("w") or love.keyboard.isDown("a") or
	love.keyboard.isDown("s") or love.keyboard.isDown("d")) and player.moveMode==1 then
		processMove(lastMoveKey, dt)
	end

	text.updateTextTimers(dt)

	--[[to check for removed spotlights
	local slLen = #spotlights
	for i = 1, slLen do
		if spotlights[i]~=nil and not spotlights[i]:update(dt) then
			table.remove(spotlights, i)
			i = i-1
			slLen = slLen-1
		end
	end]]

	if #spotlights>0 or player.attributes.shieldCounter>0 then checkDeathSpotlights(dt) end

	if not player.attributes.timeFrozen then
		for i = 1, #spotlights do
			spotlights[i]:update(dt)
		end
		for i = 1, #animals do
			animals[i]:update(dt)
		end

		--game timer
		if not player.attributes.clockFrozen then
			if started and validSpace() and (completedRooms[mapy][mapx]~=1 or gameTime.goesDownInCompleted)
			and (not (floorTransition and not floorTransitionInfo.moved)) then
			gameTime.timeLeft = gameTime.timeLeft-dt
			end
		end
	end

	for i = 1, #bossList do
		bossList[i]:superUpdate(dt)
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
	if gameTime.timeLeft<=0 and not loadTutorial and floorIndex ~= -1 then
		kill()
	end
	gameTime.totalTime = gameTime.totalTime+dt

	updateLamps()

	if mushroomMode then
		if globalTint[1]<0.4 then
			globalTintRising[1] = 1
		elseif globalTint[1]>0.8 then
			globalTintRising[1] = -1
		end
		if globalTint[2]<0.4 then
			globalTintRising[2] = 1
		elseif globalTint[2]>0.8 then
			globalTintRising[2] = -1
		end
		if globalTint[3]<0.4 then
			globalTintRising[3] = 1
		elseif globalTint[3]>0.8 then
			globalTintRising[3] = -1
		end

		for i = 1, 3 do
			globalTint[i] = globalTint[i]+dt/2*globalTintRising[i]
		end
		myShader:send("tint_r", globalTint[1])
		myShader:send("tint_g", globalTint[2])
		myShader:send("tint_b", globalTint[3])
	end

	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room~=nil and room[i][j]~=nil then
				room[i][j]:realtimeUpdate(dt, i, j)
				if room[i][j]~=nil then
					room[i][j]:updateAnimation(dt)
				end
			end
		end
	end
	player.character:updateAnimation(dt)

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

function isToolSelectKey(key)
	if key=="1" or key=="2" or key=="3" or key=="4" or key=="5" or key=="6" or key=="7" or
	key=="8" or key=="9" or key=="0" then
		return true
	elseif key=="-" and player.character.superSlots>3 then
		return true
	end

	return false
end

function love.keypressed(key, unicode, isRepeat, isPlayback)

	if key=="w" or key=="a" or key=="s" or key=="d" then
		 lastMoveKey = key
	end

	if (floorTransition and not floorTransitionInfo.moved) or 
		(gameTransition and not gameTransitionInfo.moved) then
		return
	end

	if titlescreenCounter>0 then
		titlescreenCounter = 0
		globalTint = {1,1,1}
		myShader:send("tint_r", globalTint[1])
		myShader:send("tint_g", globalTint[2])
		myShader:send("tint_b", globalTint[3])
		return
	end

	if toolManuel.opened then
		toolManuel.keypressed(key, unicode)
		return
	elseif gamePaused then
		if key=="escape" then
			gamePaused = false
		elseif key=="m" then
			stairsLocs[1] = {map = {x = 0, y = 0}, coords = {x = 0, y = 0}}
			goToMainMenu()
		elseif key=="t" then
			toolManuel.open()
		elseif key=="q" then
			--love.event.quit()
		end
		return
	end

	if editor.stealInput then
		editor.inputSteal(key, unicode)
		return
	end
	
	if key=="escape" then
		gamePaused = true
		return
	end
	if saving.isPlayingBack() and not isPlayback then
		return
	end
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

	if won then
		if key=="m" then
			stairsLocs[1] = {map = {x = 0, y = 0}, coords = {x = 0, y = 0}}
			goToMainMenu()
		end
	end

	if key=="e" and not releaseBuild then
		editorMode = not editorMode
		if floorIndex == -1 then
			--started = false
			--charSelect = true
			--player.tileY = 1
			--player.tileX = 1
		end
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
			restartGame()
		end
	end
	love.keyboard.setKeyRepeat(true)
    -- ignore non-printable characters (see http://www.ascii-code.com/)

	if player.character:onKeyPressed(key) then
		updateGameState(false)
	end

	for i = 1, #processes do
		if processes[i].disableInput and processes[i].active then
			return
		end
	end

    if player.dead and (key == "w" or key == "a" or key == "s" or key == "d") then
    	return
    end

	if keyTimer.timeLeft > 0 then
		return
	end
	keyTimer.timeLeft = keyTimer.base

	saving.recordKeyPressed(key, unicode, isRepeat)

	waitTurn = false
   	
	if key=="w" or key=="a" or key=="s" or key=="d" then
		if not processMove(key) then return
		end
	end

	if isToolSelectKey(key) then
		numPressed = nil
		if key=="-" then numPressed = 11
		else numPressed = tonumber(key) end
		if numPressed == 0 then numPressed = 10 end

		if numPressed<=tools.numNormalTools and tools[numPressed].numHeld>0 then
			if tool==numPressed then
				tool = 0
			else
				tool = numPressed
			end
		elseif numPressed>tools.numNormalTools then
			if tool == specialTools[numPressed-7] then
				tool = 0
			else
				tool = specialTools[numPressed-7]
			end
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
    if (key=="w" or key=="a" or key=="s" or key=="d") and player.moveMode==0 then
    	processTurn()
    	if playerMoved() then
	    	local moveProcess = processList.movePlayer:new()
		    if key=="w" then
				moveProcess.direction = 0
			elseif key=="a"  then
				moveProcess.direction = 3
			elseif key=="s" then
				moveProcess.direction = 2
			elseif key=="d" then
				moveProcess.direction = 1
			end
			processes[#processes+1] = moveProcess
		end
    end
    --setPlayerLoc()
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
    	if not editorMode then editor.keypressed(key, unicode) end
    elseif key == 'c' then
    	log(nil)
    end
    updateGameState(noPowerUpdate)
    resetTileStates()
    checkAllDeath()
    tools.updateToolableTiles(tool)

    if player.moveMode==0 then
		--setPlayerLoc()
	end


    for i = 1, roomHeight do
    	for j = 1, roomLength do
    		if room[i][j]~=nil then
    			room[i][j]:absoluteFinalUpdate()
    		end
    	end
    end
    player.character:absoluteFinalUpdate()
    postKeypressReset()
end

function restartGame()
	messageInfo.text = nil
	if loadTutorial or floorIndex == -1 then
		player.dead = false
		player.y = (player.enterY-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
		player.tileY = player.enterY
		player.x = (player.enterX-1)*scale*tileWidth+wallSprite.width+tileWidth/2*scale-10
		player.tileX = player.enterX
		player.prevy = player.y
		player.prevTileY = player.enterY
		player.prevx = player.x
		player.prevTileX = player.enterX
		for i = 1, tools.numNormalTools do
			tools[i].numHeld = player.totalItemsGiven[i] - player.totalItemsNeeded[i]
			if tools[i].numHeld < 0 then tools[i].numHeld = 0 end
		end
		tools.toolsShown = {}


		for i = 0, mainMap.height do
			for j = 0, mainMap.height do
				if mainMap[i][j]~=nil and (completedRooms[i][j]~=1 or 
				not (mainMap[i][j].leftCompleted~=nil and mainMap[i][j].leftCompleted)) then
					hackEnterRoom(mainMap[i][j].roomid, i, j)
				end
			end
		end
		if completedRooms[mapy][mapx]~=1 or 
		not (mainMap[mapy][mapx].leftCompleted~=nil and mainMap[mapy][mapx].leftCompleted) then		
 			hackEnterRoom(mainMap[mapy][mapx].roomid, mapy, mapx)		
 		end

 		if completedRooms[mapy][mapx]==1 and
 		(mainMap[mapy][mapx].leftCompleted==nil or not mainMap[mapy][mapx].leftCompleted) then
 			completedRooms[mapy][mapx] = 0
 		end
		
		setPlayerLoc()
		myShader:send("b_and_w", 0)
	else
		if floorIndex>=5 then
			unlocks.unlockUnlockableRef(unlocks.roomRerollerUnlock)
		end
		startGame()
	end
end

function processTurn()
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
    	if stepTrigger() then
    		noPowerUpdate = false
    	end
    	for k = 1, #animals do
			local ani = animals[k]
			if not map.blocksMovementAnimal(ani) and not ani.dead then
				local movex = ani.tileX
				local movey = ani.tileY
				if player.active then
					movex = player.tileX
					movey = player.tileY
				end
				local animalDist = math.abs(movey-ani.tileY)+math.abs(movex-ani.tileX)
				for i = 1, roomHeight do
					for j = 1, roomLength do
						if room[i][j]~=nil and (room[i][j].attractsAnimals or room[i][j].scaresAnimals) then
							if math.abs(i-ani.tileY)+math.abs(j-ani.tileX)<animalDist then
								animalDist = math.abs(i-ani.tileY)+math.abs(j-ani.tileX)
								movex = j
								movey = i
							end
						end
					end
				end
				for i = 1, #pushables do
					if pushables[i]:instanceof(pushableList.boombox) and not pushables[i].destroyed then
					    if math.abs(pushables[i].tileY-ani.tileY)+math.abs(pushables[i].tileX-ani.tileX)<animalDist then
							animalDist = math.abs(pushables[i].tileY-ani.tileY)+math.abs(pushables[i].tileX-ani.tileX)
							movex = pushables[i].tileX
							movey = pushables[i].tileY
						end
					end
				end
				if ani.trained then
					movex = ani.tileX
					movey = ani.tileY
					for l = 1, #animals do
						if not animals[l].dead then
							if movex==ani.tileX and movey==ani.tileY then
								if animals[l]~=ani then
									movex = animals[l].tileX
									movey = animals[l].tileY
								else
									local currDist = math.abs(movex-ani.tileX)+math.abs(movey-ani.tileY)
									local testDist = math.abs(movex-animals[l].tileX)+math.abs(movey-animals[l].tileY)
									if testDist<currDist then
										movex = animals[l].tileX
										movey = animals[l].tileY
									end								
								end
							end
						end
					end
				end

				local moveCoords = ani:moveOverride(movex, movey)
				movex = moveCoords.x
				movey = moveCoords.y
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
			if pushables[i].prevTileY~=pushables[i].tileY or pushables[i].prevTileX~=pushables[i].tileX then
				local moveProcess = processList.movePushable:new()
				moveProcess.pushable = pushables[i]
			    if pushables[i].tileY<pushables[i].prevTileY then
					moveProcess.direction = 0
				elseif pushables[i].tileX<pushables[i].prevTileX  then
					moveProcess.direction = 3
				elseif pushables[i].tileY>pushables[i].prevTileY then
					moveProcess.direction = 2
				elseif pushables[i].tileX>pushables[i].prevTileX then
					moveProcess.direction = 1
				end
				processes[#processes+1] = moveProcess
			end
	    	if room[pushables[i].tileY][pushables[i].tileX]~=nil then
	    		if room[pushables[i].tileY][pushables[i].tileX].updatePowerOnEnter then
	    			noPowerUpdate = false
	    		end
	    	end
	    	if pushables[i].prevTileY~=nil and pushables[i].prevTileX~=nil and 
	    	room[pushables[i].prevTileY]~=nil and room[pushables[i].prevTileY][pushables[i].prevTileX]~=nil then
	    		if room[pushables[i].prevTileY][pushables[i].prevTileX].updatePowerOnLeave then
	    			noPowerUpdate = false
	    		end
	    	end
	    	if (pushables[i].conductive or pushables[i].forcePower) and (pushables[i].tileX~=pushables[i].prevTileX or pushables[i].tileY~=pushables[i].prevTileY) then
	    		noPowerUpdate = false
	    	end
    	end
    	for i = 1, #animals do
    		if animals[i].conductive then
    			noPowerUpdate = false
    		end
    	end
	end
	for i = 1, #pushables do
		pushables[i].prevTileX = pushables[i].tileX
		pushables[i].prevTileY = pushables[i].tileY
		pushables[i].justPushed = false
	end
	if playerMoved() then
		player.character:postMove()
	end
end

function processMove(key, dt)
	if player.waitCounter<=0 and not (room[player.tileY][player.tileX]~=nil and
	room[player.tileY][player.tileX]:sticksPlayer()) then
		player.prevx = player.x
		player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
		if not map.blocksMovement(player.tileY, player.tileX) then
	    	if key == "w" then
	    		if player.tileY>1 then
	    			player.tileY = player.tileY-1
	    			--player.y = player.y-tileHeight*scale
				elseif player.tileY==1 and (player.tileX==math.floor(roomLength/2) or player.tileX==math.floor(roomLength/2)+1) then
					enterRoom(0)
				end
	    	elseif key == "s" then
	    		if player.tileY<roomHeight then
	    			player.tileY = player.tileY+1
	    			--player.y = player.y+tileHeight*scale
				elseif player.tileY == roomHeight and (player.tileX==math.floor(roomLength/2) or player.tileX==math.floor(roomLength/2)+1) then
					enterRoom(2)
	    		end
	    	elseif key == "a" then
	    		if player.tileX>1 then
	    			player.tileX = player.tileX-1
	    			--player.x = player.x-tileHeight*scale
				elseif player.tileX == 1 and (player.tileY==math.floor(roomHeight/2) or player.tileY==math.floor(roomHeight/2)+1) then
					enterRoom(3)
	    		end
	    	elseif key == "d" then
	    		if player.tileX<roomLength then
	    			player.tileX = player.tileX+1
	    			--player.x = player.x+tileHeight*scale
	    		elseif player.tileX == roomLength and (player.tileY==math.floor(roomHeight/2) or player.tileY==math.floor(roomHeight/2)+1) then
					enterRoom(1)
				end
			end
			if room[player.tileY][player.tileX]==nil and math.abs(player.elevation)>3 then
				player.tileX = player.prevTileX
				player.tileY = player.prevTileY
			elseif room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX]:obstructsMovement() and not player.character:bypassObstructsMovement(room[player.tileY][player.tileX]) then
				player.tileX = player.prevTileX
				player.tileY = player.prevTileY
			else
				for i = 1, #animals do
					--checks for NPCs or animals that block the player
					if animals[i]:blocksPlayer() and animals[i].tileX==player.tileX and animals[i].tileY==player.tileY then
						player.tileX = player.prevTileX
						player.tileY = player.prevTileY
					end
				end
			end
		end
	else
		player.prevx = player.x
		player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
	end

	if player.waitCounter>0 then
		player.prevx = player.x
		player.prevy = player.y
		player.prevTileX = player.tileX
		player.prevTileY = player.tileY
		waitTurn = true
    	player.waitCounter = player.waitCounter-1
    end

	if not playerMoved() then
		player.character:onFailedMove(key)
	else
		resetPlayerAttributesStep()
	end
	return playerMoved()
end

function postKeypressReset()
	globalPowerBlock = false
	globalDeathBlock = false
	player.justTeleported = false
	if player.attributes.fast.fast then
		player.attributes.fast.fastStep = not player.attributes.fast.fastStep
	end

	updateCursor()
end

function playerMoved()
	if player.attributes.fast.fastStep then return false end
	return player.tileX~=player.prevTileX or player.tileY~=player.prevTileY
end

function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function updateElevation()
	if room[player.tileY][player.tileX]==nil then
		player.elevation = 0
	elseif room[player.tileY][player.tileX].canElevate then
		player.elevation = room[player.tileY][player.tileX]:getHeight()
	end

	for i = 1, #animals do
		if room[animals[i].tileY][animals[i].tileX]==nil then
			animals[i].elevation = 0
		elseif room[animals[i].tileY][animals[i].tileX].canElevate then
			animals[i].elevation = room[animals[i].tileY][animals[i].tileX]:getHeight()
		end	
	end

	for i = 1, #pushables do
		if room[pushables[i].tileY][pushables[i].tileX]==nil then
			pushables[i].elevation = 0
		else
			pushables[i].elevation = room[pushables[i].tileY][pushables[i].tileX]:getHeight()
		end	
	end
end

function postAnimalMovement()
	resolveConflicts()

	for i = 1, #animals do
		if animals[i]:hasMoved() and not animals[i].dead and not animals[i].frozen and
		animals[i].movesInTurn then
			local moveProcess = processList.moveAnimal:new()
			moveProcess.animal = animals[i]
		    if animals[i].tileY<animals[i].prevTileY then
				moveProcess.direction = 0
			elseif animals[i].tileX<animals[i].prevTileX  then
				moveProcess.direction = 3
			elseif animals[i].tileY>animals[i].prevTileY then
				moveProcess.direction = 2
			elseif animals[i].tileX>animals[i].prevTileX then
				moveProcess.direction = 1
			end
			processes[#processes+1] = moveProcess
		end
	end

	for i = 1, #animals do
		if animals[i]:hasMoved() and not animals[i].dead then
			if room[animals[i].prevTileY]~=nil and room[animals[i].prevTileY][animals[i].prevTileX]~=nil then
				room[animals[i].prevTileY][animals[i].prevTileX]:onLeaveAnimal(animals[i])
				if (not animals[i].dead) and room[animals[i].prevTileY][animals[i].prevTileX]~=nil
				and room[animals[i].prevTileY][animals[i].prevTileX].overlay~=nil then
					room[animals[i].prevTileY][animals[i].prevTileX].overlay:onLeaveAnimal(animals[i])
				end
				if room[animals[i].prevTileY][animals[i].prevTileX]:usableOnNothing() then
					room[animals[i].prevTileY][animals[i].prevTileX] = animals[i]:onNullLeave(animals[i].prevTileY, animals[i].prevTileX)
				end
			else
				room[animals[i].prevTileY][animals[i].prevTileX] = animals[i]:onNullLeave(animals[i].prevTileY, animals[i].prevTileX)
			end
		end
	end
	resetAnimals()
	for i = 1, #animals do
		if animals[i]:hasMoved() and not animals[i].dead then
			if room[animals[i].tileY][animals[i].tileX]~=nil then
				room[animals[i].tileY][animals[i].tileX]:onEnterAnimal(animals[i])
				if (not animals[i].dead) and room[animals[i].tileY][animals[i].tileX]~=nil
				and room[animals[i].tileY][animals[i].tileX].overlay~=nil then
					room[animals[i].tileY][animals[i].tileX].overlay:onEnterAnimal(animals[i])
				end
			end
		elseif room[animals[i].tileY][animals[i].tileX]~=nil then
			room[animals[i].tileY][animals[i].tileX]:onStayAnimal(animals[i])
			if (not animals[i].dead) and room[animals[i].tileY][animals[i].tileX]~=nil
			and room[animals[i].tileY][animals[i].tileX].overlay~=nil then
				room[animals[i].tileY][animals[i].tileX].overlay:onStayAnimal(animals[i])
			end
		end
	end

	for i = 1, #animals do
		for j = 1, #pushables do
			if (not pushables[j].destroyed) and animals[i].tileX == pushables[j].tileX and animals[i].tileY == pushables[j].tileY then
				animals[i]:kill()
			end
		end
	end
end

function resetAnimals()
	for i = 1, #animals do
		if animals[i].waitCounter>0 and animals[i].triggered then
			animals[i].waitCounter = animals[i].waitCounter-1
		end
	end
end

function resolveConflicts()
	local firstRun = true
	local conflicts = true
	while conflicts do
		for i = 1, #animals do
			for j = 1, i-1 do
				if (not animals[i].dead) and (not animals[j].dead) and animals[i].tileX == animals[j].tileX and animals[i].tileY == animals[j].tileY then
					if animals[i].trained then
						animals[j]:kill()
					elseif animals[j].trained then
						animals[i]:kill()
					else
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
		end

		--code below semi-fixes animal "bouncing" -- kind of hacky
		if firstRun then
			for i = 1, #animals do
				if animals[i].tileX==animals[i].prevTileX and animals[i].tileY==animals[i].prevTileY
				and animals[i].movesInTurn then
					animals[i]:checkDeath()
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
			    				if room[j][k]~=nil and room[j][k].attractsAnimals then
			    					if math.abs(j-animals[i].tileY)+math.abs(k-animals[i].tileX)<animalDist then
			    						animalDist = math.abs(j-animals[i].tileY)+math.abs(k-animals[i].tileX)
			    						movex = k
			    						movey = j
			    					end
			    				end
			    			end
			    		end
			    		for j = 1, #pushables do
			    			if pushables[j]:instanceof(pushableList.boombox) and not pushables[j].destroyed then
							    if math.abs(pushables[j].tileY-animals[i].tileY)+math.abs(pushables[j].tileX-animals[i].tileX)<animalDist then
									animalDist = math.abs(pushables[j].tileY-animals[i].tileY)+math.abs(pushables[j].tileX-animals[i].tileX)
									movex = pushables[j].tileX
									movey = pushables[j].tileY
								end
			    			end
			    		end
				    	if animals[i].trained then
							movex = animals[i].tileX
							movey = animals[i].tileY
							for l = 1, #animals do
								if not animals[l].dead then
									if movex==animals[i].tileX and movey==animals[i].tileY then
										if animals[l]~=animals[i] then
											movex = animals[l].tileX
											movey = animals[l].tileY
										end
									else
										local currDist = math.abs(movex-animals[i].tileX)+math.abs(movey-animals[i].tileY)
										local testDist = math.abs(movex-animals[l].tileX)+math.abs(movey-animals[l].tileY)
										if testDist<currDist then
											movex = animals[l].tileX
											movey = animals[l].tileY									
										end
									end
								end
							end
						end
						
						moveCoords = animals[i]:moveOverride(movex, movey)
						movex = moveCoords.x
						movey = moveCoords.y

						animals[i]:secondaryMove(movex, movey)
					end
				end
			end
		end

		conflicts = false
		for i = 1, #animals do
			for j = 1, i-1 do
				if (not animals[i].dead) and (not animals[j].dead) and animals[i].tileX == animals[j].tileX and animals[i].tileY == animals[j].tileY then
					if animals[i].trained then
						animals[j]:kill()
					elseif animals[j].trained then
						animals[i]:kill()
					else
						conflicts = true
						firstRun = false
					end
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
		if t:willKillPlayer() --[[and t:getHeight()<6]] and not (t:getHeight()<6 and player.attributes.flying) then
			kill()
		end
	end
	checkDeathSpotlights(0)
	for i = 1, #animals do
		if animals[i]:willKillPlayer(player) and not player.safeFromAnimals and not animals[i].trained then
			kill()
		end
	end
	for i = 1, #bossList do
		if bossList[i]:willKillPlayer(player) then
			kill()
		end
	end
end

function checkDeathSpotlights(dt)
	if player.attributes.invisible then return end

	if player.attributes.shieldCounter>0 then
		player.attributes.shieldCounter = player.attributes.shieldCounter-dt
		if player.attributes.shieldCounter<=0 and tools.shield.numHeld>0 then
			player.attributes.shieldCounter = 0
			if tools.shield.active then
				tools.shield.numHeld = tools.shield.numHeld-1
				updateTools()
				tools.shield.active = false
				tools.shield:updateSprite()
			end
		end
		return
	end

	for i = 1, #spotlights do
		if spotlights[i]~=nil and spotlights[i].active and spotlights[i]:onPlayer() then
			kill('spotlight')
		end
	end
end

function love.mousepressed(x, y, button, istouch, isPlayback)
	if saving.isPlayingBack() and not isPlayback then
		return
	end
	mouseDown = true

	if gamePaused then
		return
	end

	if not started then
		return
	end
	saving.recordMouseInput(x, y, button, istouch, false)

	mouseX = x
	mouseY = y

	local bigRoomTranslation = getTranslation()
	tileLocX = math.ceil((mouseX-wallSprite.width)/(scale*tileUnit))-bigRoomTranslation.xInteger
	tileLocY = math.ceil((mouseY-wallSprite.height)/(scale*tileUnit))-bigRoomTranslation.yInteger
	if room[tileLocY+1] ~= nil and room[tileLocY+1][tileLocX] ~= nil then
		tileLocY = math.ceil((mouseY-wallSprite.height-room[tileLocY+1][tileLocX]:getYOffset()*scale)/(scale*tileUnit))-bigRoomTranslation.yInteger
	end

	if editorMode then
		editor.mousepressed(x, y, button, istouch)
	end
	--mouseX = x-width2/2+16*screenScale/2
	--mouseY = y-height2/2+9*screenScale/2
	
	--mouseX = x-(width2-width)/2
	--mouseY = y-(height2-height)/2

	local bigRoomTranslation = getTranslation()
	mouseTranslated = {x = mouseX-bigRoomTranslation.x*scale*tileUnit, y = mouseY-bigRoomTranslation.y*scale*tileUnit}

	local clickActivated = false
	if mouseY<width/18 and mouseY>0 then
		inventoryX = math.floor(mouseX/(width/18))
		if inventoryX>=tools.numNormalTools and player.character.superSlots>3 then
			inventoryX = inventoryX+(player.character.superSlots-3)
		end
		--print(inventoryX)
		if inventoryX>-1 and inventoryX<tools.numNormalTools then
			clickActivated = true
			if tool==inventoryX+1 then
				tool=0
			elseif tools[inventoryX+1].numHeld>0 then
				tool=inventoryX+1
			end
		elseif inventoryX>=13 and inventoryX<=13+(player.character.superSlots-1) then
			clickActivated = true
			if specialTools[inventoryX-12]~=0 and tool~=specialTools[inventoryX-12] then
				tool = specialTools[inventoryX-12]
			else tool = 0
			end
		end
	end

	tools.updateToolableTiles(tool)

	local currentTool = 0
	if not clickActivated and not (tools.useToolLoc(mouseTranslated.y, mouseTranslated.x, tileLocY, tileLocX)) then
		tool = 0
	elseif not clickActivated then
		if tool<=tools.numNormalTools then
			gameTime.timeLeft = gameTime.timeLeft+gameTime.toolTime
		end
		onToolUse(tool)
	end

	updateCursor()
	
	updateGameState(false)
	checkAllDeath()
end

function love.mousereleased(x, y, button, istouch, isPlayback)
	if saving.isPlayingBack() and not isPlayback then
		return
	end
	mouseDown = false
	saving.recordMouseInput(x, y, button, istouch, true)
	if gamePaused then
		return
	end
end

function love.mousemoved(x, y, dx, dy, isTouch, isPlayback)
	if saving.isPlayingBack() and not isPlayback then
		return
	end
	saving.recordMouseMoved(x, y, dx, dy, isTouch)
	if gamePaused then
		return
	end
	--mouseX = x-width2/2+16*screenScale/2
	--mouseY = y-height2/2+9*screenScale/2
	--mouseX = x-(width2-width)/2
	--mouseY = y-(height2-height)/2
	mouseX = x
	mouseY = y
	local bigRoomTranslation = getTranslation()
	mouseTranslated = {x = mouseX-bigRoomTranslation.x*scale*tileUnit, y = mouseY-bigRoomTranslation.y*scale*tileUnit}


	local bigRoomTranslation = getTranslation()
	tileLocX = math.ceil((mouseX-wallSprite.width)/(scale*tileWidth))-bigRoomTranslation.xInteger
	tileLocY = math.ceil((mouseY-wallSprite.height)/(scale*tileHeight))-bigRoomTranslation.yInteger
	if room ~= nil and room[tileLocY+1] ~= nil and room[tileLocY+1][tileLocX] ~= nil then
		tileLocY = math.ceil((mouseY-wallSprite.height-room[tileLocY+1][tileLocX]:getYOffset()*scale)/(scale*tileHeight))-bigRoomTranslation.yInteger
	end
	if editorMode then
		editor.mousemoved(x, y, dx, dy)
	end
end

function updateGameState(noPowerUpdate, noLightUpdate)
	updateElevation()
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i]~=nil and room[i][j]~=nil then
				if room[i][j].onLoad ~= nil and room[i][j].loaded == nil then
					room[i][j]:onLoad()
					room[i][j].loaded = true
				end
				if room[i][j].overlay~=nil and room[i][j].overlay.onLoad ~= nil and room[i][j].overlay.loaded == nil then
					room[i][j].overlay:onLoad()
					room[i][j].overlay.loaded = true
				end
			end
		end
	end
	checkCurrentTile()
	if not noPowerUpdate and not globalPowerBlock and not player.attributes.sockStep then updatePower() end
	if not noLightUpdate then
		updateLight()
	end
	updateTools()
	if tool ~= 0 and tool ~= nil and tools[tool].numHeld == 0 then tool = 0 end
	updateElevation()
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
						if (not pushables[i].destroyed) and pushables[i].tileY == potentialY and pushables[i].tileX == potentialX then canAccelerate = false end
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

function checkCurrentTile()
	checkPickups()
	checkWin()
end

function checkPickups()
	if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].tool~=nil
	and room[player.tileY][player.tileX].isVisible then
		room[player.tileY][player.tileX]:onEnter(player)
	end
end

function checkWin()
	if room[player.tileY][player.tileX]~=nil and room[player.tileY][player.tileX].enterCheckWin then
		room[player.tileY][player.tileX]:onEnter(player)
	end
end

function checkAllDeath()
	for i = 1, #pushables do
		pushables[i]:checkDestruction()
	end
	for i = 1, #animals do
		animals[i]:checkDeath()
	end
	checkDeath()
end

function updateTools()
	local maxSpread = tools[1].numHeld
	local balancedBasics = true
	for i = 1, tools.numNormalTools do
		if tools[i].numHeld<maxSpread then
			maxSpread = tools[i].numHeld
		end
		if tools[i].numHeld~=maxSpread then
			balancedBasics = false
		end
	end

	if maxSpread>0 and balancedBasics then
		unlocks.unlockUnlockableRef(unlocks.toolIncrementerUnlock)
	end
	if maxSpread>=2 then
		unlocks.unlockUnlockableRef(unlocks.toolRerollerUnlock)
	end
	if maxSpread>=3 then
		unlocks.unlockUnlockableRef(unlocks.superToolUnlock)
	end

	local unlockDoubler = true
	for i = 1, player.character.superSlots do
		if specialTools[i]==0 or tools[specialTools[i]].numHeld<2 then
			unlockDoubler = false
		end
	end
	if unlockDoubler then unlocks.unlockUnlockableRef(unlocks.supertoolDoublerUnlock) end

	for i = 1, player.character.superSlots do
		if specialTools[i]~=0 and tools[specialTools[i]].numHeld==0 then
			specialTools[player.character.superSlots]=0
			for j = i, player.character.superSlots-1 do
				specialTools[j] = specialTools[j+1]
				specialTools[j+1]=0
			end
		end
	end
	for i = tools.numNormalTools+1, #tools do
		if tools[i].numHeld>0 then
			local needToAdd = true
			for j = 1, player.character.superSlots do
				if specialTools[j]==i then
					needToAdd = false
				end
			end

			if needToAdd then
				for j = 1, player.character.superSlots do
					if specialTools[j]==0 then
						specialTools[j] = i
						break
					end
				end
			end
		end
	end

	--[[if tools.waterBottle.numHeld>=10 then
		unlocks.unlockUnlockableRef(unlocks.fishUnlock)
	end]]

	player.character:onUpdateTools()
	for i = 1, #tools do
		if tools[i].numHeld<0 then
			tools[i].numHeld = 0
		end
	end
end

function updateCursor()
	local cursor

	--code below sets cursor to tile being added in editorMode
	--removed because it was annoying and sprites were too small
	--[[if editorMode and editorAdd>0 and editorAdd<#tiles then
		cursor = love.mouse.newCursor(tiles[editorAdd]:getEditorSprite(), 0, 0)
		love.mouse.setCursor(cursor)]]

	if tool==0 then
		--cursor = love.mouse.newCursor('Graphics/herman_small.png', 0, 0)
		love.mouse.setCursor()
	else
		cursor = love.mouse.newCursor(tools[tool].image, 0, 0)
		love.mouse.setCursor(cursor)
	end
end

function stepTrigger()
	player.character:immediatePostMove()
	local updatePowerAfter = false
	for i = 1, roomHeight do
		for j = 1, roomLength do
			if room[i][j]~=nil then
				room[i][j]:onStep(i, j)
				if room[i][j].gone then
					if room[i][j].canBePowered then updatePowerAfter = true end
					room[i][j]:onEnd(i, j)
					room[i][j] = nil
				elseif room[i][j].overlay~=nil and room[i][j].overlay.gone then
					if room[i][j].canBePowered then updatePowerAfter = true end
					room[i][j].overlay:onEnd(i, j)
					room[i][j].overlay = nil				
				end
			end
		end
	end
	for times = 1, 5 do
		for i = 1, roomHeight do
			for j = 1, roomLength do
				if room[i][j]~=nil then
					if room[i][j].gone then
						if room[i][j].canBePowered then updatePowerAfter = true end
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

    if updatePowerAfter then
		return true
	else
		return false
	end
end

--unlocks all rooms besides hidden rooms (secret rooms and special dungeons)
function unlockDoors(openLocked)

	if player.attributes.xrayVision or floorIndex == -1 then
		unlockDoorsPlus()
		if floorIndex == -1 then
			map.setVisibleMapTutorial()
		end
		return
	end

	completedRooms[mapy][mapx] = 1
	local testRooms = {{-1,0}, {1,0}, {0,-1}, {0,1}}
	for k = 1, #testRooms do
		local i = testRooms[k][1]
		local j = testRooms[k][2]
		local canUnlock = false
		if mapy+i>=0 and mapy+i<mapHeight+1 and mapx+j>=0 and mapx+j<mapHeight+1 then
			canUnlock = true
			if mainMap[mapy+i][mapx+j]~=nil then
				local potentialId = mainMap[mapy+i][mapx+j].roomid
				if map.getFieldForRoom(potentialId, "hidden")~=nil and map.getFieldForRoom(potentialId, "hidden") then
					canUnlock = false
				elseif not openLocked and map.getFieldForRoom(potentialId, "locked")~=nil and map.getFieldForRoom(potentialId, "locked") then
					canUnlock = false
				end
			end
			if canUnlock then
				visibleMap[mapy+i][mapx+j] = 1
			end
		end
	end
end

function unlockAllDoors()
	for i = 1, mapHeight do
		for j = 1, mapHeight do
			if mainMap[i][j]~=nil then
				completedRooms[i][j] = 1
				visibleMap[i][j] = 1
			end
		end
	end
end

function unlockDoorsOpeningWorld()
	if unlocks.tutorialBeatenUnlock.unlocked and unlocks.dragonUnlock.unlocked then
		unlockAllDoors()
	elseif unlocks.tutorialBeatenUnlock.unlocked then
		for i = 1, mapHeight do
			for j = 1, mapHeight do
				if mainMap[i][j]~=nil and (map.getFieldForRoom(mainMap[i][j].roomid, "hidden")==nil or not map.getFieldForRoom(mainMap[i][j].roomid, "hidden")) then
					completedRooms[i][j] = 1
					visibleMap[i][j] = 1
				end
			end
		end
	--else return
	end
end


--unlocks secret rooms as well
function unlockDoorsPlus(openLocked)
	completedRooms[mapy][mapx] = 1
	local testRooms = {{-1,0}, {1,0}, {0,-1}, {0,1}}
	for k = 1, #testRooms do
		local i = testRooms[k][1]
		local j = testRooms[k][2]
		if mapy+i>=0 and mapy+i<mapHeight+1 and mapx+j>=0 and mapx+j<mapHeight+1 then
			if mapy+i>=0 and mapy+i<mapHeight+1 and mapx+j>=0 and mapx+j<mapHeight+1 then
				canUnlock = true
				if mainMap[mapy+i][mapx+j]~=nil then
					local potentialId = mainMap[mapy+i][mapx+j].roomid
					if not openLocked and map.getFieldForRoom(potentialId, "locked")~=nil and map.getFieldForRoom(potentialId, "locked") then
						canUnlock = false
					end
				end
				if canUnlock then
					visibleMap[mapy+i][mapx+j] = 1
				end
			end
		end
	end
end

function dropTools()
	--supertool-based drops
	local basicsHeld = 0
	for i = 1, tools.numNormalTools do
		basicsHeld = basicsHeld+tools[i].numHeld
	end
	if basicsHeld<=1 then
		tools.giveRandomTools(tools.investmentBonus.numHeld*2)
	end
	tools.giveRandomTools(tools.roomCompletionBonus.numHeld)

	local dropOverride = map.getFieldForRoom(mainMap[mapy][mapx].roomid, 'itemsGivenOverride')
	if loadTutorial or (floorIndex == -1 and map.getItemsGiven(mainMap[mapy][mapx].roomid) ~= nil) then
		local toolsToDisplay = {0,0,0,0,0,0,0}
		local futureTotalItemsGiven = {0,0,0,0,0,0,0}
		local futureTotalItemsNeeded ={0,0,0,0,0,0,0}
		for i = 1, tools.numNormalTools do
			futureTotalItemsGiven[i] = player.totalItemsGiven[i] + map.getItemsGiven(mainMap[mapy][mapx].roomid)[1][i]
			futureTotalItemsNeeded[i] = player.totalItemsNeeded[i] + map.getItemsNeeded(mainMap[mapy][mapx].roomid)[1][i]
			toolsToDisplay[i] = futureTotalItemsGiven[i] - futureTotalItemsNeeded[i] - tools[i].numHeld
			tools[i].numHeld = futureTotalItemsGiven[i] - futureTotalItemsNeeded[i]
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
							local listOfItemsNeeded = map.getItemsNeeded(mainMap[y][x].roomid)
							local listChoose = util.random(#listOfItemsNeeded, 'toolDrop')
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
			giveToolsFullClear()
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

function giveToolsFullClear()
	--[[if floorIndex ~= -1 then
		--bonusTool decides whether or not one more tool will drop from floor
		local bonusTool = util.random(2, 'toolDrop')
		bonusTool = bonusTool-1
		bonusTool = bonusTool+tools.completionBonus.numHeld*2
		tools.giveRandomTools(math.floor((toolMax+toolMin)/2)+bonusTool)
	end]]
	if toolMax==nil or toolMin==nil then
		toolMax = 1
		toolMin = 1
	end
	local totalDropNum = math.floor((toolMax+toolMin)/2)
	local bonusTool = util.random(2, 'toolDrop')-1
	totalDropNum = totalDropNum+bonusTool

	for i = 1, mapHeight do
		for j = 1, mapHeight do
			if mainMap[i][j]~=nil and map.getFieldForRoom(mainMap[i][j].roomid, 'isFinal')~=nil and
			map.getFieldForRoom(mainMap[i][j].roomid, 'isFinal')~=nil then
				local listOfItemsNeeded = map.getItemsNeeded(mainMap[i][j].roomid)
				local listChoose = util.random(#listOfItemsNeeded, 'toolDrop')
				tools.giveToolsByArray(listOfItemsNeeded[listChoose])
				for i = 1, tools.numNormalTools do
					totalDropNum = totalDropNum-listOfItemsNeeded[listChoose][i]
				end
			end
		end
	end

	tools.giveRandomTools(totalDropNum)	
end

function beatRoom(noDrops)
	saving.saveRecording()
	spotlights = {}
	if noDrops == nil then noDrops = false end

--if floorIndex>6 then noDrops = true end
	gameTime.timeLeft = gameTime.timeLeft+gameTime.roomTime
	unlockDoors()
	if not noDrops then
		dropTools()
	end
	player.character:onRoomCompletion()

	if floorIndex == -1 then
		map.setVisibleMapTutorial()
	end

	for i = 1, #animals do
		if animals[i]:instanceof(animalList.robotGuard) then
			animals[i]:kill()
		end
	end
end

function onTeleport()
	turnOffMushroomMode()
	player.justTeleported = true
	setPlayerLoc()
	for i = 1, #animals do
		animals[i]:setLoc()
	end
	for j = 1, #pushables do
		pushables[j]:setLoc()
	end

	player.character:onRoomEnter()

	for i = 1, #processes do
		if processes[i]:instanceof(processList.movePlayer) then
			processes[i].active = false
		end
	end

	player.prevTileX = player.tileX
	player.prevTileY = player.tileY
end

function onToolUse(currentTool)
	resetPlayerAttributesTool()
	player.character:onToolUse(currentTool)
	if mainMap[mapy][mapx].toolsUsed == nil then
		mainMap[mapy][mapx].toolsUsed = {}
	end
	mainMap[mapy][mapx].toolsUsed[#mainMap[mapy][mapx].toolsUsed+1] = currentTool

	--deck of cards trigger
	if tools.card.numHeld>0 then
		tools.card:playCard()
	end
 	
 	if tools.superRange.active > 0 and not currentTool == tools.superRange then
		player.attributes.extendedRange = player.attributes.extendedRange - tools.superRange.active
		tools.superRange.active = 0
	end
	if tools.preservatives.numHeld> 0 and currentTool ~= nil and tools[currentTool]:instanceof(tools.superTool) then
		tools.preservatives:preserve(currentTool)
	end

	if tools.superRange.numHeld>0 then
		tools.superRange:update()
	end
	if tools.chargedShield.numHeld>0 then
		tools.chargedShield.charge = tools.chargedShield.charge + 1
	end

	stats.incrementStat('toolsUsed')

	--unlocks
	local unlockBlank = false
	local sameTool = 0
	local basicsUsed = {}
	for i = 1, tools.numNormalTools do
		basicsUsed[i] = 0
	end
	for i = 1, #mainMap[mapy][mapx].toolsUsed do
		if mainMap[mapy][mapx].toolsUsed[i]==currentTool then
			sameTool = sameTool+1
		end
		if mainMap[mapy][mapx].toolsUsed[i]>tools.numNormalTools and mainMap[mapy][mapx].toolsUsed[i]~=currentTool then
			unlockBlank = true
		end
		if mainMap[mapy][mapx].toolsUsed[i]<=tools.numNormalTools and mainMap[mapy][mapx].toolsUsed[i]>0 then
			basicsUsed[mainMap[mapy][mapx].toolsUsed[i]] = basicsUsed[mainMap[mapy][mapx].toolsUsed[i]]+1
		end
	end

	if sameTool>=2 then
		--doesn't work yet b/c what about two-stage tools
		unlocks.unlockUnlockableRef(unlocks.mindfulToolUnlock)
	end
	if unlockBlank then
		unlocks.unlockUnlockableRef(unlocks.blankToolUnlock)
	end
	if basicsUsed[1]>0 and basicsUsed[7]>0 then
		unlocks.unlockUnlockableRef(unlocks.axeUnlock)
	end
	if basicsUsed[4]>0 and basicsUsed[5]>0 then
		unlocks.unlockUnlockableRef(unlocks.lubeUnlock)
	end
	if basicsUsed[3]>0 and basicsUsed[7]>0 then 
		unlocks.unlockUnlockableRef(unlocks.knifeUnlock)
	end

	if basicsUsed[1]>0 and basicsUsed[2]>0 and basicsUsed[3]>0 and basicsUsed[4]>0 and basicsUsed[6]>0 then
		unlocks.unlockUnlockableRef(unlocks.recycleBinUnlock)
	end



	if tools[tool]~=nil and tools[tool].numHeld<=0 then
		tool = 0
	end


	updateTools()
	checkAllDeath()
	--setPlayerLoc()

end