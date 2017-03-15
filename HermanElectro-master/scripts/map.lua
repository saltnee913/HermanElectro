require('scripts.object')
require('scripts.tiles')
local util = require('scripts.util')
local json = require('scripts.dkjson')
local unlocks = require('scripts.unlocks')

local P = {}
map = P

--Temporary variable, we have to do this a better way later
P.defaultFloorOrder = {'RoomData/floor1.json', 'RoomData/floor2.json', 'RoomData/floor3.json', 'RoomData/floor4.json', 'RoomData/floor5.json', 'RoomData/floor6.json', 'RoomData/exitDungeonsMap.json'}
P.floorOrder = P.defaultFloorOrder

local MapInfo = Object:new{floor = 1, height = 0, numRooms = 0}

map.itemsNeededFile = 'itemsNeeded.json'

local blacklist = {}
local setBlacklist = {}
function P:clearBlacklist()
	blacklist = {}
	setBlacklist = {}
end

local function removeSets(arr)
	local sets = {}
	local bad = false
	for i = 1, #arr do
		bad = false
		local set = P.getFieldForRoom(arr[i], 'set')

		--if something isn't in a set, then it is a set by itself
		if set == nil then
			set = arr[i]
		end

		for j = 1, #setBlacklist do
			if setBlacklist[j] == set then
				bad = true
			end
		end
		if not bad then
			if sets[set] == nil then
				sets[set] = {}
			end
			sets[set][#sets[set]+1] = arr[i]
		end
	end
	local newArr = {}
	for k, v in pairs(sets) do
		--choose an element from a set so they don't appear twice a floor
		local setIndex = util.random(#v, 'mapGen')
		newArr[#newArr+1] = v[setIndex]
	end
	return newArr
end


function writeToolsUsed()
	local solutionArray = {}
	if love.filesystem.exists(saveDir..'/'..P.itemsNeededFile) then 
		solutionArray = util.readJSON(saveDir..'/'..P.itemsNeededFile, false)
	end
	for i=0, mapHeight do
		for j=1, mapHeight do
			if completedRooms[i][j]==1 then
				local arrToAdd = {}
				arrToAdd[1] = tostring(mainMap[i][j].roomid)
				arrToAdd[2] = player.character.name
				if mainMap[i][j].toolsUsed ~= nil then
					for k = 1, #mainMap[i][j].toolsUsed do
						arrToAdd[#arrToAdd+1] = mainMap[i][j].toolsUsed[k]
					end
				end
				solutionArray[#solutionArray+1] = arrToAdd
			end
		end
	end
	util.writeJSON(P.itemsNeededFile, solutionArray)
end

function P.setRoomSetValues(fi)
	local inFloorFile = nil
	if fi==1 then
		inFloorFile = P.floorOrder[#P.floorOrder]
	else
		inFloorFile = P.floorOrder[fi]
	end
	local floorData = util.readJSON(inFloorFile)
	P.floorInfo = {rooms = {}, roomsArray = {}}
	for k, v in pairs(floorData.data) do
		P.floorInfo[k] = v
	end
	local loadRooms = floorData.loadRooms
	for k, v in pairs(loadRooms) do
		local roomsData, roomsArray = util.readJSON(v.filePath, true)
		P.floorInfo.rooms[k] = roomsData.rooms
		for k1, v1 in pairs(P.floorInfo.rooms[k]) do
			v1.roomid=k1
			if roomsData.superFields ~= nil then
				for k2, v2 in pairs(roomsData.superFields) do
					if v1[k2] == nil then v1[k2] = v2 end
				end
			end
		end
		P.filterRoomSet(P.floorInfo.rooms[k], v.requirements)
		if P.floorInfo.requireUnlocks == true then
			P.filterRoomSetByUnlocks(P.floorInfo.rooms[k])
		end
		for i = 1, #roomsArray do
			if P.floorInfo.rooms[k][roomsArray[i]] ~= nil then
				P.floorInfo.roomsArray[#(P.floorInfo.roomsArray)+1] = roomsArray[i]
			end
		end
	end
end

function P.loadFloor(inFloorFile)
	if mainMap ~= nil and mainMap.cheated ~= true then
		writeToolsUsed()
	end
	local floorData = util.readJSON(inFloorFile)
	P.floorInfo = {rooms = {}, roomsArray = {}}
	for k, v in pairs(floorData.data) do
		P.floorInfo[k] = v
	end
	local loadRooms = floorData.loadRooms
	for k, v in pairs(loadRooms) do
		local numToolsArray = {0,0,0,0,0,0,0,0,0,0,0,0,0}
		local toolAppearanceArray = {0,0,0,0,0,0,0}
		local tilesArr = {}
		for i = 1, #tiles  do
			tilesArr[i] = {name = tiles[i].name, rooms = 0, nonDumbRooms = 0, total = 0, sets = 0}
		end
		local tilesCheckedArr = {}
		for i = 1, #tiles do
			tilesCheckedArr[i] = 0
		end
		local lastRoomSet = ""
		local seenInSet = {}
		for i = 1, #tiles do
			seenInSet[i] = 0
		end
		local roomsData, roomsArray = util.readJSON(v.filePath, true)
		P.floorInfo.rooms[k] = roomsData.rooms
		local amt = 0
		for k1, v1 in pairs(P.floorInfo.rooms[k]) do
			for i = 1, #tiles do
				tilesCheckedArr[i] = 0
			end
			if not (v1.set~=nil and v1.set==lastRoomSet) then
				for i = 1, #tiles do
					seenInSet[i] = 0
				end
			end
			v1.roomid=k1
			if roomsData.superFields ~= nil then
				for k2, v2 in pairs(roomsData.superFields) do
					if v1[k2] == nil then v1[k2] = v2 end
				end
			end
			local numTools = 0
			if v1.layout~=nil then
				for i = 1, #v1.layout do
					for j = 1, #v1.layout[1] do
						local tileIndex = v1.layout[i][j]
						if tileIndex==nil then
							print(v1.roomid.."   "..i.."   "..j)
						end
						if type(tileIndex) ~= 'number' then
							if type(tileIndex[2])=='number' then
								tileIndex = tileIndex[1]
							elseif type(tileIndex[2])=='string' then
								tileIndex = tileIndex[1]
							end
						end
						tileIndex = math.floor(tileIndex)
						if tileIndex>0 then
							if tilesCheckedArr[tileIndex]==0 then
								tilesCheckedArr[tileIndex]=1
								tilesArr[tileIndex].rooms = tilesArr[tileIndex].rooms+1
								if v1.dumb==nil then
									tilesArr[tileIndex].nonDumbRooms = tilesArr[tileIndex].nonDumbRooms+1
								end
							end
							tilesArr[tileIndex].total = tilesArr[tileIndex].total+1
							if seenInSet[tileIndex]==0 then
								tilesArr[tileIndex].sets = tilesArr[tileIndex].sets+1
								seenInSet[tileIndex]=1
							end
						end
					end
				end
			elseif v1.layouts[1]~=nil then
				for i = 1, #v1.layouts[1] do
					for j = 1, #v1.layouts[1][1] do
						local tileIndex = v1.layouts[1][i][j]
						if type(tileIndex) ~= 'number' then
							if type(tileIndex[2])=='number' then
								tileIndex = tileIndex[1]
							elseif type(tileIndex[2])=='string' then
								tileIndex = tileIndex[1]
							end
						end
						tileIndex = math.floor(tileIndex)
						if tileIndex>0 then
							if tilesCheckedArr[tileIndex]==0 then
								tilesCheckedArr[tileIndex]=1
								tilesArr[tileIndex].rooms = tilesArr[tileIndex].rooms+1
								if v1.dumb==nil then
									tilesArr[tileIndex].nonDumbRooms = tilesArr[tileIndex].nonDumbRooms+1
								end
							end
							tilesArr[tileIndex].total = tilesArr[tileIndex].total+1
							if seenInSet[tileIndex]==0 then
								tilesArr[tileIndex].sets = tilesArr[tileIndex].sets+1
								seenInSet[tileIndex]=1
							end
						end
					end
				end
			end
			if v1.set~=nil then
				lastRoomSet = v1.set
			else
				lastRoomSet = ""
			end
			for i = 1, 7 do
				if #v1.itemsNeeded[1]>1 then
					numTools = numTools + v1.itemsNeeded[1][i]
					for j = 1, #v1.itemsNeeded do
						toolAppearanceArray[i] = toolAppearanceArray[i]+v1.itemsNeeded[j][i]/#v1.itemsNeeded
					end
				else
					numTools = numTools + v1.itemsNeeded[i]
					toolAppearanceArray[i] = toolAppearanceArray[i]+v1.itemsNeeded[i]
				end
			end
			if numTools<=10 then
				numToolsArray[numTools+1] = numToolsArray[numTools+1]+1
			end
			amt = amt + 1
		end
		P.filterRoomSet(P.floorInfo.rooms[k], v.requirements)
		if P.floorInfo.requireUnlocks == true then
			P.filterRoomSetByUnlocks(P.floorInfo.rooms[k])
		end
		for i = 1, #roomsArray do
			if P.floorInfo.rooms[k][roomsArray[i]] ~= nil then
				P.floorInfo.roomsArray[#(P.floorInfo.roomsArray)+1] = roomsArray[i]
			end
		end
		--[[print(k..': '..amt)
		local toPrint = ""
		for i = 0, 10 do
			toPrint = toPrint..i..": "..numToolsArray[i+1]..", "
		end
		print(toPrint)
		--print("Tools:")
		toolWords = {"saws", "ladders", "wireCutters", "waterBottles", "sponges", "bricks", "guns"}
		toPrint = ""
		for i = 1, 7 do
			toPrint = toPrint..toolWords[i]..": "..toolAppearanceArray[i]..", "
		end]]
		--print(toPrint)
		--[[for i = 1, #tilesArr do
			print(tilesArr[i].name..":")
			print("Total appearances: "..tilesArr[i].total)
			print("Rooms appearing in: "..tilesArr[i].rooms)
			print("Non-dumb rooms: "..tilesArr[i].nonDumbRooms)
			print("Sets appearing in: "..tilesArr[i].sets)
			print()
		end]]
	end
	if map.floorInfo.tint == nil then
		map.floorInfo.tint = {0,0,0}
	end
	if map.floorInfo.playerRange == nil then
		map.floorInfo.playerRange = 200
	end
    myShader:send("floorTint_r", map.floorInfo.tint[1])
    myShader:send("floorTint_g", map.floorInfo.tint[2])
    myShader:send("floorTint_b", map.floorInfo.tint[3])
    myShader:send("player_range", map.floorInfo.playerRange)
    map.flipRooms('rooms')
end

function P.loadCustomRooms(fileLoc)
	if not love.filesystem.exists(fileLoc) then return end
	local roomsData, roomsArray = util.readJSON(fileLoc, true)
	P.floorInfo.rooms.customRooms = roomsData.rooms
	for i = 1, #roomsArray do
		P.floorInfo.roomsArray[#(P.floorInfo.roomsArray)+1] = roomsArray[i]
	end

	if map.floorInfo.tint == nil then
		map.floorInfo.tint = {0,0,0}
	end
	if map.floorInfo.playerRange == nil then
		map.floorInfo.playerRange = 200
	end
    myShader:send("floorTint_r", map.floorInfo.tint[1])
    myShader:send("floorTint_g", map.floorInfo.tint[2])
    myShader:send("floorTint_b", map.floorInfo.tint[3])
    myShader:send("player_range", map.floorInfo.playerRange)
    map.flipRooms('rooms')
end

local function flipRoomVertical(roomLayout)
	local toRet = {}
	for i = 1, #roomLayout do
		toRet[i] = {}
		for j = 1, #roomLayout[#roomLayout-i+1] do
			toRet[i][j] = roomLayout[#roomLayout-i+1][j]
			if toRet[i][j] ~= 0 then
				if type(toRet[i][j]) == 'number' then
					local tileInd = math.floor(toRet[i][j])
					local tile = tiles[tileInd]
					local rot = math.floor(10*(toRet[i][j]-tileInd+0.01))
					if tile == nil then toRet[i][j] = 0 else
						toRet[i][j] = toRet[i][j] + tile.flipDirection(rot,true)/10
					end
				else
					local tileInd = math.floor(toRet[i][j][1])
					local tile = tiles[tileInd]
					local rot = math.floor(10*(toRet[i][j][1]-tileInd+0.01))
					toRet[i][j][1] = toRet[i][j][1] + tile.flipDirection(rot,true)/10
					if type(toRet[i][j][2]) == 'number' then
						local overInd = math.floor(toRet[i][j][2])
						local overRot = math.floor(10*(toRet[i][j][2]-overInd+0.01))
						local overTile = tiles[math.floor(overInd)]
						toRet[i][j][2] = toRet[i][j][2] + overTile.flipDirection(overRot,true)/10
					end
				end
			else
				toRet[i][j] = 0
			end
		end
	end
	return toRet
end
local function flipRoomHorizontal(roomLayout)
	local toRet = {}
	for i = 1, #roomLayout do
		toRet[i] = {}
		for j = 1, #roomLayout[i] do
			toRet[i][j] = roomLayout[i][#roomLayout[i]-j+1]
			if toRet[i][j] ~= 0 then
				if type(toRet[i][j]) == 'number' then
					local tileInd = math.floor(toRet[i][j])
					local tile = tiles[tileInd]
					local rot = math.floor(10*(toRet[i][j]-tileInd+0.01))
					if tile == nil then toRet[i][j] = 0 else
						toRet[i][j] = toRet[i][j] + tile.flipDirection(rot,false)/10
					end
				else
					local tileInd = math.floor(toRet[i][j][1])
					local tile = tiles[tileInd]
					local rot = math.floor(10*(toRet[i][j][1]-tileInd+0.01))
					toRet[i][j][1] = toRet[i][j][1] + tile.flipDirection(rot,false)/10
					if type(toRet[i][j][2]) == 'number' then
						local overInd = math.floor(toRet[i][j][2])
						local overRot = math.floor(10*(toRet[i][j][2]-overInd+0.01))
						local overTile = tiles[overInd]
						toRet[i][j][2] = toRet[i][j][2] + overTile.flipDirection(overRot,false)/10
					end
				end
			else
				toRet[i][j] = 0
			end
		end
	end
	return toRet
end

function P.flipRooms()
	for k1, rooms in pairs(P.floorInfo.rooms) do
		if rooms == nil then
			return
		end
		for k2, v in pairs(rooms) do
			if v.flippable then
				local flipVertical = util.random(2,'mapGen') == 1
				local flipHorizontal = util.random(2,'mapGen') == 1
				if v.layout ~= nil then
					if flipVertical then
						v.layout = flipRoomVertical(v.layout)
					end
					if flipHorizontal then
						v.layout = flipRoomHorizontal(v.layout)
					end
				else
					for i = 1, #v.layouts do
						if flipVertical then
							v.layouts[i] = flipRoomVertical(v.layouts[i])
						end
						if flipHorizontal then
							v.layouts[i] = flipRoomHorizontal(v.layouts[i])
						end
					end
				end
				if v.dirEnter ~= nil then
					if flipVertical then
						local dirTemp = v.dirEnter[1]
						v.dirEnter[1] = v.dirEnter[3]
						v.dirEnter[3] = dirTemp
					end
					if flipHorizontal then
						local dirTemp = v.dirEnter[2]
						v.dirEnter[2] = v.dirEnter[3]
						v.dirEnter[4] = dirTemp
					end
				end
			end
		end
	end
end

function P.getNextRoom(roomid)
	local roomsArray = P.floorInfo.roomsArray
	if roomsArray[#roomsArray] == roomid then
		return roomsArray[1]
	end
	for i = 1, #roomsArray-1 do
		if roomsArray[i] == roomid then
			return roomsArray[i+1]
		end
	end
	return roomid
end

function P.getPrevRoom(roomid)
	local roomsArray = P.floorInfo.roomsArray
	if roomsArray[1] == roomid then
		return roomsArray[#roomsArray]
	end
	for i = 2, #roomsArray do
		if roomsArray[i] == roomid then
			return roomsArray[i-1]
		end
	end
	return roomid
end

function P.filterRoomSet(arr, requirements)
	for k, v in pairs(arr) do
		if not P.roomMeetsRequirements(v, requirements) then
			arr[k] = nil
		end
	end
end

local function doesRoomContainTile(roomData, tile)
	layouts = roomData.layouts and roomData.layouts or {roomData.layout}
	return util.deepContains(layouts, tile, true)
end

function P.filterRoomSetByUnlocks(arr)
	for k, v in pairs(arr) do
		for i = 1, #unlocks do
			if unlocks[i].unlocked == false then
				if unlocks[i].tileIds ~= nil then
					for j = 1, #unlocks[i].tileIds do
						if doesRoomContainTile(v, unlocks[i].tileIds[j]) then
							arr[k] = nil
						end
					end
				elseif unlocks[i].roomIds ~= nil then
					for j = 1, #unlocks[i].roomIds do
						if k == unlocks[i].roomIds[j] then
							arr[k] = nil
						end
					end
				end
			end
		end
	end
end

function P.blocksMovement(tileY, tileX)
	return room[tileY] ~= nil and room[tileY][tileX] ~= nil and room[tileY][tileX]:obstructsMovement()
end
function P.blocksMovementAnimal(animal)
	local tileY = animal.tileY
	local tileX = animal.tileX
	if room[tileY] ~= nil and room[tileY][tileX] ~= nil and room[tileY][tileX]:obstructsMovementAnimal(animal) then
		return true
	elseif room[tileY]~=nil and room[tileY][tileX]==nil and math.abs(animal.elevation)>3 then
		return true
	else
		return false
	end
end

local function tilesWhitelistHelper(arr, tiles)
	for i = 1, #arr do
		for j = 1, #(arr[i]) do
			if not util.deepContains(tiles, arr[i][j], true) and arr[i][j] ~= 0 and arr[i][j] ~= nil then
				return false
			end
			
		end
	end
	return true
end

local function requirementsHelper(roomData, key, value)
	if key == 'and' then
		for k, v in pairs(value) do
			if not requirementsHelper(roomData, k, v) then
				return false
			end
		end
		return true
	elseif key == 'or' then
		for k, v in pairs(value) do
			if requirementsHelper(roomData, k, v) then
				return true
			end
		end
		return false
	elseif key == 'not' then
		return not requirementsHelper(roomData, 'and', value)
	elseif key == 'contains' then
		return util.deepContains(roomData[value.table], value.value)
	elseif key == 'equals' then
		return roomData[value.key] == value.value
	elseif key == 'greater' then
		return roomData[value.key] > value.value
	elseif key == 'less' then
		return roomData[value.key] < value.value
	elseif key == 'containsTile' then
		return util.deepContains(roomData.layout, value, true) or util.deepContains(roomData.layouts, value, true)
	elseif key == 'tilesWhitelist' then
		if roomData.layout == nil then
			for i = 1, #roomData.layouts do
				if not tilesWhitelistHelper(roomData.layouts[i], value) then
					return false
				end
			end
			return true
		else
			return tilesWhitelistHelper(roomData.layout, value)
		end
	elseif key == 'toolRange' then
		for i = 1, #roomData.itemsNeeded do
			local sum = 0
			for j = 1, #roomData.itemsNeeded[i] do
				sum = sum+roomData.itemsNeeded[i][j]
			end
			if sum<value[1] or sum>value[2] then return false end
		end
	elseif key == 'hasKey' then
		return roomData[value] ~= nil
	elseif key == 'solvableWithTools' then
		for i = 1, #roomData.itemsNeeded do
			local works = true
			for j = 1, #(roomData.itemsNeeded[i]) do
				if roomData.itemsNeeded[i][j] > value[j] then
					works = false
				end
			end
			if works then return true end
		end
		return false
	end
	return true
end


function P.roomMeetsRequirements(roomData, requirements)
	if requirements == nil then return true end
	return requirementsHelper(roomData, 'and', requirements)
end

function P.createRoom(inRoom, arr)
	if inRoom == nil then inRoom = '1' end
	if arr == nil then
		for k, v in pairs(P.floorInfo.rooms) do
			if v[inRoom] ~= nil then
				arr = v
			end
		end
		if arr == nil then
			return nil
		end
	end
	--if arr[inRoom]==nil then --printinRoom.."isNil") end
	local roomToLoad = arr[inRoom].layout
	roomToLoad = (roomToLoad ~= nil) and roomToLoad 
		or arr[inRoom].layouts[util.random(#arr[inRoom].layouts, 'mapGen')]
	local loadedRoom = {}
	loadedRoom.height = #roomToLoad
	loadedRoom.length = #roomToLoad[1]
	for i = 1, #roomToLoad do
		loadedRoom[i] = {}
		for j = 1, #(roomToLoad[i]) do
			local tileData = roomToLoad[i][j]
			local overlayToPlace = nil
			local tileText = nil
			if type(tileData) ~= 'number' then
				if type(tileData[2])=='number' then
					local overInd = math.floor(tileData[2])
					overlayToPlace = tiles[overInd]:new()
					local overRot = math.floor(10*(tileData[2]-overInd+0.01))
					if overRot~=nil and overRot~=0 then
						overlayToPlace:rotate(overRot)
					end
					tileData = tileData[1]
				elseif type(tileData[2])=='string' then
					tileText = tileData[2]
					tileData = tileData[1]
				end
			end
			local ind = math.floor(tileData)
			if tileData == nil or ind == 0 then
				loadedRoom[i][j] = nil
			elseif tiles[ind].animal ~= nil then
				loadedRoom[i][j] = tiles[ind]:new()
				loadedRoom[i][j].animal = tiles[ind].animal:new()
			else
				loadedRoom[i][j] = tiles[ind]:new()
			end
			local rot = math.floor(10*(tileData-ind+0.01))
			if rot~=nil and rot ~= 0 and loadedRoom[i][j]~=nil then
				loadedRoom[i][j]:rotate(rot)
			end
			if overlayToPlace ~= nil then
				loadedRoom[i][j]:setOverlay(overlayToPlace)
			elseif tileText~=nil then
				loadedRoom[i][j].text = tileText
			end
		end
	end
	--if(loadedRoom==nil) then print"ellie fucked up, and jmoney is fucking hype") end
	return loadedRoom
end

function P.getFieldForRoom(inRoom, inField)
	for k, v in pairs(P.floorInfo.rooms) do
		if v[inRoom] ~= nil then
			return v[inRoom][inField]
		end
	end
	log('invalid room id: '..inRoom)
	game.crash()
	return nil
end

function P.isRoomType(inRoom, roomType)
	return P.floorInfo.rooms[roomType]~=nil and P.floorInfo.rooms[roomType][inRoom] ~= nil
end

function P.getItemsNeeded(inRoom)
	return P.getFieldForRoom(inRoom, 'itemsNeeded')
end
function P.getItemsGiven(inRoom)
	return P.getFieldForRoom(inRoom, 'itemsGiven')
end

function P.loadRooms(roomBuffer, roomPath)
	P[roomBuffer] = util.readJSON(roomPath).rooms
end

local function printMap(inMap)
	for i = 0, inMap.height do
		local p = ''
		for j = 0, inMap.height do
			if inMap[i][j] == nil then
				p = p .. '-  '
			else
				p = p .. inMap[i][j].roomid .. ' '
			end
		end
		--printp)
	end
end

function P.generateMap()
	return P[P.floorInfo.generateFunction]()
end

local function canPlaceRoom(dirEnters, map, mapx, mapy)
	if dirEnters == nil then return true end
	for i = 1, 4 do
		if dirEnters[i] == 1 then
			local offset = util.getOffsetByDir(i)
			if map[mapy + offset.y][mapx + offset.x] ~= nil then
				return true
			end
		end
	end
	return false
end

function P.generateMapStandard()
	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end
	local startRoomID = P.floorInfo.startRoomID
	newmap[math.floor(height/2)][math.floor(height/2)] = {roomid = startRoomID, room = P.createRoom(startRoomID, P.floorInfo.rooms.rooms), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = math.floor(height/2)
	newmap.initialX = math.floor(height/2)
	treasureX = 0
	treasureY = 0
	donationX = 0
	donationY = 0
	blacklist[#blacklist+1] = startRoomID
	local randomRoomArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms, 'mapGen', blacklist)
	local randomRoomArray = removeSets(randomRoomArray)
	local skippedRooms = {}
	local skippedRoomsIndex = 1
	for i = 0, numRooms-1 do
		available = {}
		local a = 0
		for j = 1, height do
			for k = 1, height do
				if newmap[j][k]==nil then
					--numNil = newmap[j+1][k] ~= nil and 1 or 0 + newmap[j-1][k] ~= nil and 1 or 0 + newmap[j][k+1] ~= nil and 1 or 0 + newmap[j][k-1] ~= nil and 1 or 0
					local e = newmap[j+1][k]
					local b = newmap[j-1][k]
					local c = newmap[j][k+1]
					local d = newmap[j][k-1]
					numNil = 0;
					if (e==nil) then
						numNil=numNil+1
					end
					if (b==nil) then
						numNil=numNil+1
					end
					if (c==nil) then
						numNil=numNil+1
					end
					if (d==nil) then
						numNil=numNil+1
					end
					if (numNil == 3) then
						works = true
						if i == numRooms - 1 then
							if (j+1 == treasureY and k == treasureX) or (j-1 == treasureY and k == treasureX)
							or (j == treasureY and k+1 == treasureX) or (j == treasureY and k-1 == treasureX)
							or (j+1 == donationY and k == donationX) or (j-1 == donationY and k == donationX)
							or (j == donationY and k+1 == donationX) or (j == donationY and k-1 == donationX) then
								works = false
							end
						elseif i == numRooms - 2 then
							if (j+1 == donationY and k == donationX) or (j-1 == donationY and k == donationX)
							or (j == donationY and k+1 == donationX) or (j == donationY and k-1 == donationX) then
								works = false
							end
						end
						if works then
							available[a] = {x=j,y=k}
							a=a+1
						end
					end
				end
			end
		end

		--numRooms=0
		local choice = available[util.random(a-1, 'mapGen')]
		--local roomNum = math.floor(math.random()*#(P.rooms)) -- what we will actually do, with some editing
		arr = P.floorInfo.rooms.rooms
		local roomid = randomRoomArray[i+skippedRoomsIndex]
		local loadedRoom = P.createRoom(roomid, arr)
		if skippedRooms[skippedRoomsIndex] ~= nil then
			roomid = skippedRooms[skippedRoomsIndex]
			loadedRoom = P.createRoom(roomid, arr)
			skippedRoomsIndex = skippedRoomsIndex + 1
		end
		local skipped = 1
		while (not canPlaceRoom(arr[roomid].dirEnter, newmap, choice.y, choice.x)) do
			skippedRooms[#skippedRooms+1] = randomRoomArray[i+2+skippedRoomsIndex+skipped-1]
			roomid = randomRoomArray[i+2+skippedRoomsIndex+skipped]
			if roomid == nil then roomid = '1' end
			loadedRoom = P.createRoom(roomid, arr)
			skipped = skipped + 1
		end
		if i == numRooms-2 then
			arr = P.floorInfo.rooms.treasureRooms
			roomid = util.chooseRandomKey(arr, 'mapGen')
			loadedRoom = P.createRoom(roomid, arr)
			treasureX = choice.y
			treasureY = choice.x
		elseif i == numRooms-1 then
			arr = P.floorInfo.rooms.finalRooms
			roomid = util.chooseRandomKey(arr, 'mapGen')
			loadedRoom = P.createRoom(roomid, arr)
		elseif i == numRooms-3 then
			arr = P.floorInfo.rooms.donationRooms
			roomid = util.chooseRandomKey(arr, 'mapGen')
			loadedRoom = P.createRoom(roomid, arr)
			donationX = choice.y
			donationY = choice.x
		end
		local newDirEnter = {1,1,1,1}
		if arr[roomid].dirEnter~=nil then
			newDirEnter = arr[roomid].dirEnter
		end
		blacklist[#blacklist+1] = roomid
		newmap[choice.x][choice.y] = {roomid = roomid, room = P.createRoom(roomid, arr), tint = {0,0,0}, dirEnter = arr[roomid].dirEnter, isFinal = false, isInitial = false}
	end
	--add dungeon room to floor
	arr = P.floorInfo.rooms.dungeons
	roomid = util.chooseRandomKey(arr, 'mapGen')
	newmap[height+1][1] = {roomid = roomid, room = P.createRoom(roomid, arr), tint = {0,0,0}, dirEnter = arr[roomid].dirEnter, isFinal = false, isInitial = false}

	if map.floorInfo.tint == nil then
		map.floorInfo.tint = {0,0,0}
	end
	if map.floorInfo.playerRange == nil then
		map.floorInfo.playerRange = 200
	end
    myShader:send("floorTint_r", map.floorInfo.tint[1])
    myShader:send("floorTint_g", map.floorInfo.tint[2])
    myShader:send("floorTint_b", map.floorInfo.tint[3])
    myShader:send("player_range", map.floorInfo.playerRange)

	--printMap(newmap)
	return newmap
end

function P.getRoomWeight(room, roomArr)
	local weight
	if roomArr == nil then
		weight = P.getFieldForRoom(room, 'weight')
	else
		weight = roomArr[room].weight
	end
	if weight==nil then
		weight = 1
	end
	return weight
end

--a-b does not always equal -(b-a)!!!!!!
local function compareItemsNeeded(a, b)
	local sum = 0
	for i = 1, #a do
		for j = 1, #b do
			--hardcoding is bad
			for index = 1, 7 do
				if a[i][index] > b[j][index] then
					sum = sum + a[i][index] - b[j][index]
				end
			end
		end
	end
	return sum/(#a*#b)
end

local function isRoomAllowed(room, usedRooms, newmap, choice)
	for i = 1, #usedRooms do
		if room.roomid == usedRooms[i] then
			return false
		end
	end
	return canPlaceRoom(room.dirEnter, newmap, choice.x, choice.y)
end

function P.generateMapFinal()
	local randomAccessRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms, 'mapGen')
	local randomDonationRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.donationRooms, 'mapGen')
	local randomFinalRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.finalRooms, 'mapGen')
	local startRoomID = randomAccessRoomsArray[1]

	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end

	local startx = math.floor(height/2)
	local starty = math.floor(height/2)
	newmap[starty][startx] = {roomid = startRoomID, room = P.createRoom(startRoomID), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = starty
	newmap.initialX = startx

	local endRoom = randomFinalRoomsArray[1]
	newmap[starty][startx+1] = {roomid = endRoom, room = P.createRoom(endRoom), isFinal = false, isInitial = false}
	local donationRoom = randomDonationRoomsArray[1]
	newmap[starty+1][startx] = {roomid = donationRoom, room = P.createRoom(donationRoom), isFinal = false, isInitial = false}
	return newmap
end

function P.generateMapEditor()
	local roomsArray = util.createIndexArray(P.floorInfo.rooms.rooms)
	local startRoomID = roomsArray[1]

	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end

	local startx = math.floor(height/2)
	local starty = math.floor(height/2)
	newmap[starty][startx] = {roomid = startRoomID, room = P.createRoom(startRoomID), isFinal = false, isInitial = true, isCompleted = true}
	newmap.initialY = starty
	newmap.initialX = startx

	local designRoom = roomsArray[2]
	newmap[starty-1][startx] = {roomid = designRoom, room = P.createRoom(designRoom), isFinal = false, isInitial = false}
	return newmap
end

local function getRandomRoomArrays(roomArr, random)
	local randomRoomArray = util.createRandomKeyArray(roomArr, random)
	local weightsArray = {}
	for i = 1, #randomRoomArray do
		weightsArray[i] = P.getRoomWeight(randomRoomArray[i], roomArr)
	end
	return randomRoomArray, weightsArray
end

function P.generateMapWeighted()
	--set up variables
	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end
	local roomsArray = P.floorInfo.rooms.rooms
	blacklist[#blacklist+1] = startRoomID
	local randomRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms, 'mapGen', blacklist)
	local randomRoomsArray = removeSets(randomRoomsArray)
	local randomTreasureRoomsArray, treasureRoomWeights = getRandomRoomArrays(P.floorInfo.rooms.treasureRooms, 'mapGen')
	local randomFinalRoomsArray, finalRoomWeights = getRandomRoomArrays(P.floorInfo.rooms.finalRooms, 'mapGen')
	local randomDonationRoomsArray, donationRoomWeights = getRandomRoomArrays(P.floorInfo.rooms.donationRooms, 'mapGen')
	local randomShopsArray, shopWeights = getRandomRoomArrays(P.floorInfo.rooms.shops, 'mapGen')
	--create first room
	local startRoomID = P.floorInfo.startRoomID
	newmap[math.floor(height/2)][math.floor(height/2)] = {roomid = startRoomID, room = P.createRoom(startRoomID, roomsArray), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = math.floor(height/2)
	newmap.initialX = math.floor(height/2)

	local usedRooms = {startRoomID}
	while #usedRooms ~= numRooms do
		--create list of available slots for room
		local available = {}

		for j = 1, height do
			for k = 1, height do
				if newmap[j][k]==nil then
					--numNil = newmap[j+1][k] ~= nil and 1 or 0 + newmap[j-1][k] ~= nil and 1 or 0 + newmap[j][k+1] ~= nil and 1 or 0 + newmap[j][k-1] ~= nil and 1 or 0
					local e = newmap[j+1][k]
					local b = newmap[j-1][k]
					local c = newmap[j][k+1]
					local d = newmap[j][k-1]
					numNil = 0;
					--elseif parts check to see if room exists but is special (e.g., treasure room)
					--special rooms are not in roomsArray, but in the special rooms files
					if (e==nil) then
						numNil=numNil+1
					elseif (roomsArray[e.roomid]==nil) then
						numNil=numNil-1
					end

					if (b==nil) then
						numNil=numNil+1
					elseif (roomsArray[b.roomid]==nil) then
						numNil=numNil-1
					end

					if (c==nil) then
						numNil=numNil+1
					elseif (roomsArray[c.roomid]==nil) then
						numNil=numNil-1
					end

					if (d==nil) then
						numNil=numNil+1
					elseif (roomsArray[d.roomid]==nil) then
						numNil=numNil-1
					end

					if (numNil == 3) then
						available[#available+1] = {y=j,x=k}
					end
				end
			end
		end
		--choose a room slot
		local choice = util.chooseRandomElement(available, 'mapGen')
		if numRooms-#usedRooms == 4 then
			local max = {x = choice.x, y = choice.y}
			for i = 1, #available do
				if math.abs(available[i].x-math.floor(height/2))+math.abs(available[i].y-math.floor(height/2))>
				math.abs(max.x-math.floor(height/2))+math.abs(max.y-math.floor(height/2)) then
					max.x = available[i].x
					max.y = available[i].y
				end
			end
			choice = {x = max.x, y = max.y}
		end
		local roomid

		if numRooms - #usedRooms == 4 then
			roomid = randomFinalRoomsArray[util.chooseWeightedRandom(finalRoomWeights, 'mapGen')]
		elseif numRooms - #usedRooms == 3 then
			roomid = randomTreasureRoomsArray[util.chooseWeightedRandom(treasureRoomWeights, 'mapGen')]
		elseif numRooms - #usedRooms == 2 then
			roomid = randomDonationRoomsArray[util.chooseWeightedRandom(donationRoomWeights, 'mapGen')]
		elseif numRooms - #usedRooms == 1 then
			roomid = randomShopsArray[util.chooseWeightedRandom(shopWeights, 'mapGen')]
		else
			--creates an array of 5 possible choices with weights
			local roomChoices = {}
			local roomWeights = {}
			for i = 1, P.floorInfo.numRoomsToCheck do
				local roomChoiceid = util.chooseRandomElement(randomRoomsArray, 'mapGen')
				local roomChoice = roomsArray[roomChoiceid]
				local infiniteLoopCheck = 0
				while not isRoomAllowed(roomChoice, usedRooms, newmap, choice) do
					infiniteLoopCheck = infiniteLoopCheck + 1
					roomChoiceid = util.chooseRandomElement(randomRoomsArray, 'mapGen')
					roomChoice = roomsArray[roomChoiceid]
					if infiniteLoopCheck > 1000 then
						printMap(newmap)
						roomChoiceid = randomRoomsArray[1]
						roomChoice = roomsArray[roomChoiceid]
						break
					end
				end
				roomChoices[i] = roomChoiceid
				local state = {indent = true, keyorder = keyOrder}
	
				local roomWeight = 1
				local totalRoomsCompared = 0
				for i = 1, height do
					for j = 1, height do
						if newmap[i][j]~=nil then
							totalRoomsCompared = totalRoomsCompared + 1
							local roomToCompare = newmap[i][j]
							roomWeight = roomWeight + compareItemsNeeded(roomChoice.itemsNeeded, P.getItemsNeeded(roomToCompare.roomid))
						end
					end
				end
				--[[for dir = 1, 4 do
					local offset = util.getOffsetByDir(dir)
					if newmap[choice.y+offset.y]~=nil and newmap[choice.y+offset.y][choice.x+offset.x] then
						totalRoomsCompared = totalRoomsCompared + 1
						local roomToCompare = newmap[choice.y+offset.y][choice.x+offset.x]
						roomWeight = roomWeight + compareItemsNeeded(roomChoice.itemsNeeded, roomToCompare.itemsNeeded)
						for dir2 = 1, 4 do
							local offset2 = util.getOffsetByDir(dir2)
							if newmap[roomToCompare.y+offset2.y]~=nil and newmap[roomToCompare.y+offset2.y][roomToCompare.x+offset2.x] then
								totalRoomsCompared = totalRoomsCompared + 1
								local roomToCompare2 = newmap[roomToCompare.y+offset2.y][roomToCompare.x+offset2.x]
								roomWeight = roomWeight + compareItemsNeeded(roomChoice.itemsNeeded, roomToCompare2.itemsNeeded)
							end
						end
					end
				end]]
				roomWeight = roomWeight*P.getRoomWeight(roomChoiceid)
				roomWeights[i] = roomWeight
			end
			roomid = roomChoices[util.chooseWeightedRandom(roomWeights, 'mapGen')]
		end
		blacklist[#blacklist+1] = roomid
		setBlacklist[#setBlacklist+1] = P.getFieldForRoom(roomid, 'set')
		usedRooms[#usedRooms+1] = roomid
		newmap[choice.y][choice.x] = {roomid = roomid, room = P.createRoom(roomid), tint = {0,0,0}, isFinal = false, isInitial = false}
	end
	
	--add secret room to floor
	arr = P.floorInfo.rooms.secretRooms
	local secLocs = {}
	local numNilAdjacent = 1
	local triesCounter = 0
	while #secLocs == 0 and numNilAdjacent<4 do
		for i = 1, height do
			for j = 1, height do
				if room[i][j]==nil then
					local e = newmap[i+1][j]
					local b = newmap[i-1][j]
					local c = newmap[i][j+1]
					local d = newmap[i][j-1]
					numNil = 0;
					if (e==nil) then
						numNil=numNil+1
					end
					if (b==nil) then
						numNil=numNil+1
					end
					if (c==nil) then
						numNil=numNil+1
					end
					if (d==nil) then
						numNil=numNil+1
					end
					if numNil<=numNilAdjacent and newmap[i][j]==nil then
						secLocs[#secLocs+1] = {x = j, y = i}
					end
				end
			end
		end
		numNilAdjacent = numNilAdjacent+1
	end
	if not (#secLocs==0) then
		local whichLoc = util.random(#secLocs, 'misc')
		roomid = util.chooseRandomKey(arr, 'mapGen')
		newmap[secLocs[whichLoc].y][secLocs[whichLoc].x] = {roomid = roomid, room = P.createRoom(roomid, arr), tint = {0,0,0}, dirEnter = arr[roomid].dirEnter, isFinal = false, isInitial = false}
	end
	--add special dungeon room to floor
	--each floor has one special dungeon, which is located at [height+1][1]
	arr = P.floorInfo.rooms.dungeons
	roomid = util.chooseRandomKey(arr, 'mapGen')
	newmap[height+1][1] = {roomid = roomid, room = P.createRoom(roomid, arr), tint = {0,0,0}, dirEnter = arr[roomid].dirEnter, isFinal = false, isInitial = false}
	P.printTileInfo()
	return newmap
end

function P.generateSixthFloor()
	--set up variables
	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end
	local roomsArray = P.floorInfo.rooms.rooms
	blacklist[#blacklist+1] = startRoomID
	local randomRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms, 'mapGen', blacklist)
	local randomRoomsArray = removeSets(randomRoomsArray)
	local randomTreasureRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.treasureRooms, 'mapGen')
	local randomFinalRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.finalRooms, 'mapGen')
	local randomDonationRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.donationRooms, 'mapGen')
	local randomShopsArray = util.createRandomKeyArray(P.floorInfo.rooms.shops, 'mapGen')
	--create first room
	local startRoomID = P.floorInfo.startRoomID
	newmap[math.floor(height/2)][math.floor(height/2)] = {roomid = startRoomID, room = P.createRoom(startRoomID, roomsArray), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = math.floor(height/2)
	newmap.initialX = math.floor(height/2)
	local basicsHeld = {}
	local totalToolsHeld = 0
	for i = 1, tools.numNormalTools do
		basicsHeld[i] = tools[i].numHeld
		totalToolsHeld = totalToolsHeld+tools[i].numHeld
	end
	local usedRooms = {startRoomID}
	while #usedRooms ~= numRooms do
		--create list of available slots for room
		local available = {}

		for j = 1, height do
			for k = 1, height do
				if newmap[j][k]==nil then
					--numNil = newmap[j+1][k] ~= nil and 1 or 0 + newmap[j-1][k] ~= nil and 1 or 0 + newmap[j][k+1] ~= nil and 1 or 0 + newmap[j][k-1] ~= nil and 1 or 0
					local e = newmap[j+1][k]
					local b = newmap[j-1][k]
					local c = newmap[j][k+1]
					local d = newmap[j][k-1]
					numNil = 0;
					--elseif parts check to see if room exists but is special (e.g., treasure room)
					--special rooms are not in roomsArray, but in the special rooms files
					if (e==nil) then
						numNil=numNil+1
					elseif (roomsArray[e.roomid]==nil) then
						numNil=numNil-1
					end

					if (b==nil) then
						numNil=numNil+1
					elseif (roomsArray[b.roomid]==nil) then
						numNil=numNil-1
					end

					if (c==nil) then
						numNil=numNil+1
					elseif (roomsArray[c.roomid]==nil) then
						numNil=numNil-1
					end

					if (d==nil) then
						numNil=numNil+1
					elseif (roomsArray[d.roomid]==nil) then
						numNil=numNil-1
					end

					if (numNil == 3) then
						available[#available+1] = {y=j,x=k}
					end
				end
			end
		end
		--choose a room slot
		local choice = util.chooseRandomElement(available, 'mapGen')
		--if final room
		if numRooms-#usedRooms == 4 then
			local max = {x = choice.x, y = choice.y}
			for i = 1, #available do
				if math.abs(available[i].x-math.floor(height/2))+math.abs(available[i].y-math.floor(height/2))>
				math.abs(max.x-math.floor(height/2))+math.abs(max.y-math.floor(height/2)) then
					max.x = available[i].x
					max.y = available[i].y
				end
			end
			choice = {x = max.x, y = max.y}
		end
		local roomid

		if numRooms - #usedRooms == 1 then
			roomid = util.chooseRandomElement(randomFinalRoomsArray, 'mapGen')
		else
			--creates an array of 5 possible choices with weights
			local roomChoices = {}
			local roomWeights = {}
			local whichINList = {}
			for i = 1, P.floorInfo.numRoomsToCheck do
				local whichIN = 1
				local roomChoiceid = util.chooseRandomElement(randomRoomsArray, 'mapGen')
				local roomChoice = roomsArray[roomChoiceid]
				local infiniteLoopCheck = 0

				local fitsToolsHeld = true
				if totalToolsHeld>0 then
					local inChoices = P.getItemsNeeded(roomChoiceid)
					whichIN = util.random(#inChoices, 'mapGen')
					local currentItemsNeeded = inChoices[whichIN]
					for i = 1, tools.numNormalTools do
						if currentItemsNeeded[i]>basicsHeld[i] then fitsToolsHeld = false end
					end
				end

				while not isRoomAllowed(roomChoice, usedRooms, newmap, choice) or not fitsToolsHeld do
					infiniteLoopCheck = infiniteLoopCheck + 1
					roomChoiceid = util.chooseRandomElement(randomRoomsArray, 'mapGen')
					roomChoice = roomsArray[roomChoiceid]
					fitsToolsHeld = true
					if totalToolsHeld>0 then
						local inChoices = P.getItemsNeeded(roomChoiceid)
						whichIN = util.random(#inChoices, 'mapGen')
						local currentItemsNeeded = inChoices[whichIN]
						for i = 1, tools.numNormalTools do
							if currentItemsNeeded[i]>basicsHeld[i] then fitsToolsHeld = false end
						end
					end
					if infiniteLoopCheck > 1000 then
						printMap(newmap)
						roomChoiceid = randomRoomsArray[1]
						roomChoice = roomsArray[roomChoiceid]
						whichIN = 1
						break
					end
				end
				roomChoices[i] = roomChoiceid
				whichINList[i] = whichIN
				local state = {indent = true, keyorder = keyOrder}
	
				local roomWeight = 0
				local totalRoomsCompared = 0
				for i = 1, height do
					for j = 1, height do
						if newmap[i][j]~=nil then
							totalRoomsCompared = totalRoomsCompared + 1
							local roomToCompare = newmap[i][j]
							roomWeight = roomWeight + compareItemsNeeded(roomChoice.itemsNeeded, P.getItemsNeeded(roomToCompare.roomid))
						end
					end
				end
				--[[for dir = 1, 4 do
					local offset = util.getOffsetByDir(dir)
					if newmap[choice.y+offset.y]~=nil and newmap[choice.y+offset.y][choice.x+offset.x] then
						totalRoomsCompared = totalRoomsCompared + 1
						local roomToCompare = newmap[choice.y+offset.y][choice.x+offset.x]
						roomWeight = roomWeight + compareItemsNeeded(roomChoice.itemsNeeded, roomToCompare.itemsNeeded)
						for dir2 = 1, 4 do
							local offset2 = util.getOffsetByDir(dir2)
							if newmap[roomToCompare.y+offset2.y]~=nil and newmap[roomToCompare.y+offset2.y][roomToCompare.x+offset2.x] then
								totalRoomsCompared = totalRoomsCompared + 1
								local roomToCompare2 = newmap[roomToCompare.y+offset2.y][roomToCompare.x+offset2.x]
								roomWeight = roomWeight + compareItemsNeeded(roomChoice.itemsNeeded, roomToCompare2.itemsNeeded)
							end
						end
					end
				end]]
				roomWeight = roomWeight/totalRoomsCompared + P.getRoomWeight(roomChoiceid)
				roomWeights[i] = roomWeight
			end
			local ultimateChoice = util.chooseWeightedRandom(roomWeights, 'mapGen')
			roomid = roomChoices[ultimateChoice]
			whichIN = whichINList[ultimateChoice]
			local usingItemsNeeded = P.getItemsNeeded(roomid)[whichIN]
			for i = 1, tools.numNormalTools do
				basicsHeld[i] = basicsHeld[i]-usingItemsNeeded[i]
				totalToolsHeld = totalToolsHeld-usingItemsNeeded[i]
			end
		end
		--disabling blacklisting rooms until we have enough rooms
		--blacklist[#blacklist+1] = roomid
		setBlacklist[#setBlacklist+1] = P.getFieldForRoom(roomid, 'set')
		usedRooms[#usedRooms+1] = '1'
		newmap[choice.y][choice.x] = {roomid = roomid, room = P.createRoom(roomid), tint = {0,0,0}, isFinal = false, isInitial = false}
	end
	
	--add secret room to floor
	arr = P.floorInfo.rooms.secretRooms
	local secLocs = {}
	local numNilAdjacent = 1
	local triesCounter = 0
	while #secLocs == 0 and numNilAdjacent<4 do
		for i = 1, height do
			for j = 1, height do
				if room[i][j]==nil then
					local e = newmap[i+1][j]
					local b = newmap[i-1][j]
					local c = newmap[i][j+1]
					local d = newmap[i][j-1]
					numNil = 0;
					if (e==nil) then
						numNil=numNil+1
					end
					if (b==nil) then
						numNil=numNil+1
					end
					if (c==nil) then
						numNil=numNil+1
					end
					if (d==nil) then
						numNil=numNil+1
					end
					if numNil<=numNilAdjacent and newmap[i][j]==nil then
						secLocs[#secLocs+1] = {x = j, y = i}
					end
				end
			end
		end
		numNilAdjacent = numNilAdjacent+1
	end
	if not (#secLocs==0) then
		local whichLoc = util.random(#secLocs, 'misc')
		roomid = util.chooseRandomKey(arr, 'mapGen')
		newmap[secLocs[whichLoc].y][secLocs[whichLoc].x] = {roomid = roomid, room = P.createRoom(roomid, arr), tint = {0,0,0}, dirEnter = arr[roomid].dirEnter, isFinal = false, isInitial = false}
	end
	--add special dungeon room to floor
	--each floor has one special dungeon, which is located at [height+1][1]
	arr = P.floorInfo.rooms.dungeons
	roomid = util.chooseRandomKey(arr, 'mapGen')
	newmap[height+1][1] = {roomid = roomid, room = P.createRoom(roomid, arr), tint = {0,0,0}, dirEnter = arr[roomid].dirEnter, isFinal = false, isInitial = false}
	P.printTileInfo()
	return newmap
end

function P.printTileInfo()
	local tileInfo = {}
	for i = 1, #tiles do
		tileInfo[i] = {name = tiles[i].name, numUsed = 0, roomsUsed = 0}
	end
	local alreadyChecked = {}
	for i = 1, #tiles do
		alreadyChecked[i] = 0
	end
end

--generates end dungeon accessible in starting room of each floor
function P.generateEndDungeon()
	local randomStartRoomsArray = util.createRandomKeyArray(P.floorInfo.rooms.startRooms, 'mapGen')
	local puzzleRooms, puzzleWeights = getRandomRoomArrays(P.floorInfo.rooms.puzzleRooms, 'mapGen')
	local randomFinalRoomsArray, finalRoomWeights = getRandomRoomArrays(P.floorInfo.rooms.finalRooms, 'mapGen')
	local startRoomID = randomStartRoomsArray[1]

	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end

	local startx = math.floor(height/2)
	local starty = math.floor(height/2)
	newmap[starty][startx] = {roomid = startRoomID, room = P.createRoom(startRoomID), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = starty
	newmap.initialX = startx

	if not unlocks.isDungeonUnlocked() then
		return newmap
	end
	puzzleRoom1 = puzzleRooms[util.chooseWeightedRandom(puzzleWeights, 'mapGen')]
	while(map.getFieldForRoom(puzzleRoom1, 'dirEnter')[4]==0) do
		puzzleRoom1 = puzzleRooms[util.chooseWeightedRandom(puzzleWeights, 'mapGen')]
	end
	newmap[starty][startx+1] = {roomid = puzzleRoom1, room = P.createRoom(puzzleRoom1), isFinal = false, isInitial = false}
	puzzleRoom2 = puzzleRooms[util.chooseWeightedRandom(puzzleWeights, 'mapGen')]
	while(puzzleRoom2 == puzzleRoom1 or map.getFieldForRoom(puzzleRoom2, 'dirEnter')[2]==0) do
		puzzleRoom2 = puzzleRooms[util.chooseWeightedRandom(puzzleWeights, 'mapGen')]
	end
	newmap[starty][startx-1] = {roomid = puzzleRoom2, room = P.createRoom(puzzleRoom2), isFinal = false, isInitial = false}
	puzzleRoom3 = puzzleRooms[util.chooseWeightedRandom(puzzleWeights, 'mapGen')]
	while(puzzleRoom3 == puzzleRoom2 or puzzleRoom3 == puzzleRoom1 or map.getFieldForRoom(puzzleRoom3, 'dirEnter')[1]==0) do
		puzzleRoom3 = puzzleRooms[util.chooseWeightedRandom(puzzleWeights, 'mapGen')]
	end
	newmap[starty+1][startx] = {roomid = puzzleRoom3, room = P.createRoom(puzzleRoom3), isFinal = false, isInitial = false}
	local finalRoom = randomFinalRoomsArray[util.chooseWeightedRandom(finalRoomWeights, 'mapGen')]
	newmap[starty-1][startx] = {roomid = finalRoom, room = P.createRoom(finalRoom), isFinal = false, isInitial = false}
	return newmap
end

function P.generateOneFloor()
	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end
	local startRoomID = P.floorInfo.startRoomID
	newmap[math.floor(height/2)][math.floor(height/2)] = {roomid = startRoomID, room = P.createRoom(startRoomID, P.floorInfo.rooms.rooms), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = math.floor(height/2)
	newmap.initialX = math.floor(height/2)
	blacklist[#blacklist+1] = startRoomID
	local randomRoomArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms, 'mapGen', blacklist)
	local skippedRooms = {}
	local skippedRoomsIndex = 1
	for i = 0, numRooms-1 do
		available = {}
		local a = 0
		for j = 1, height do
			for k = 1, height do
				if newmap[j][k]==nil then
					--numNil = newmap[j+1][k] ~= nil and 1 or 0 + newmap[j-1][k] ~= nil and 1 or 0 + newmap[j][k+1] ~= nil and 1 or 0 + newmap[j][k-1] ~= nil and 1 or 0
					local e = newmap[j+1][k]
					local b = newmap[j-1][k]
					local c = newmap[j][k+1]
					local d = newmap[j][k-1]
					numNil = 0;
					if (e==nil) then
						numNil=numNil+1
					elseif P.isRoomType(e.roomid, "treasureRooms") or P.isRoomType(e.roomid, "donationRooms") then
						numNil = numNil-1
					end
					if (b==nil) then
						numNil=numNil+1
					elseif P.isRoomType(b.roomid, "treasureRooms") or P.isRoomType(b.roomid, "donationRooms") then
						numNil = numNil-1
					end
					if (c==nil) then
						numNil=numNil+1
					elseif P.isRoomType(c.roomid, "treasureRooms") or P.isRoomType(c.roomid, "donationRooms") then
						numNil = numNil-1
					end
					if (d==nil) then
						numNil=numNil+1
					elseif P.isRoomType(d.roomid, "treasureRooms") or P.isRoomType(d.roomid, "donationRooms") then
						numNil = numNil-1
					end
					if (numNil == 3) then
						works = true
						--[[if i == numRooms - 1 then
							if (j+1 == treasureY and k == treasureX) or (j-1 == treasureY and k == treasureX)
							or (j == treasureY and k+1 == treasureX) or (j == treasureY and k-1 == treasureX)
							or (j+1 == donationY and k == donationX) or (j-1 == donationY and k == donationX)
							or (j == donationY and k+1 == donationX) or (j == donationY and k-1 == donationX) then
								works = false
							end
						elseif i == numRooms - 2 then
							if (j+1 == donationY and k == donationX) or (j-1 == donationY and k == donationX)
							or (j == donationY and k+1 == donationX) or (j == donationY and k-1 == donationX) then
								works = false
							end
						end]]
						if works then
							available[a] = {x=j,y=k}
							a=a+1
						end
					end
				end
			end
		end

		--numRooms=0
		local choice = available[util.random(a-1, 'mapGen')]
		--local roomNum = math.floor(math.random()*#(P.rooms)) -- what we will actually do, with some editing
		arr = P.floorInfo.rooms.rooms
		local roomid = randomRoomArray[i+skippedRoomsIndex]
		local loadedRoom = P.createRoom(roomid, arr)
		if skippedRooms[skippedRoomsIndex] ~= nil then
			roomid = skippedRooms[skippedRoomsIndex]
			loadedRoom = P.createRoom(roomid, arr)
			skippedRoomsIndex = skippedRoomsIndex + 1
		end
		local skipped = 1
		while(not canPlaceRoom(arr[roomid].dirEnter, newmap, choice.y, choice.x)) do
			skippedRooms[#skippedRooms+1] = randomRoomArray[i+2+skippedRoomsIndex+skipped-1]
			roomid = randomRoomArray[i+2+skippedRoomsIndex+skipped]
			if roomid == nil then roomid = '1' end
			loadedRoom = P.createRoom(roomid, arr)
			skipped = skipped + 1
		end
		if i == numRooms-1 then
			arr = P.floorInfo.rooms.finalRooms
			roomid = util.chooseRandomKey(arr, 'mapGen')
			loadedRoom = P.createRoom(roomid, arr)
		elseif i>numRooms-5 then
			arr = P.floorInfo.rooms.treasureRooms
			roomid = util.chooseRandomKey(arr, 'mapGen')
			loadedRoom = P.createRoom(roomid, arr)
			treasureX = choice.y
			treasureY = choice.x
		elseif i>numRooms-10 then
			arr = P.floorInfo.rooms.donationRooms
			roomid = util.chooseRandomKey(arr, 'mapGen')
			loadedRoom = P.createRoom(roomid, arr)
			donationX = choice.y
			donationY = choice.x
		end
		newmap[choice.x][choice.y] = {roomid = roomid, room = P.createRoom(roomid, arr), isFinal = false, isInitial = false}
	end
	--printMap(newmap)
	return newmap
end

function P.generateTutorial()
	return P.generateMapFromJSON('RoomData/tut_map.json')
end

function P.generateMapFromJSON()
	local newmap = P.floorInfo.map
	newmap.height = #newmap
	newmap.numRooms = 0
	for i = 1, newmap.height do
		for j = 1, newmap.height do
			if newmap[i] ~= nil and newmap[i][j] ~= nil and newmap[i][j] ~= 0 then
				newmap.numRooms = newmap.numRooms + 1
				newmap[i][j] = {roomid = newmap[i][j], room = P.createRoom(newmap[i][j]), isFinal = false, isInitial = false, isCompleted = false}
				if P.getFieldForRoom(newmap[i][j].roomid, "isInitial") == true then
					newmap[i][j].isInitial = true
					newmap.initialX = j
					newmap.initialY = i
				end
			elseif newmap[i] ~= nil and newmap[i][j] == 0 then
				newmap[i][j] = nil
			end
		end
	end
	
	if map.floorInfo.tint == nil then
		map.floorInfo.tint = {0,0,0}
	end
	if map.floorInfo.playerRange == nil then
		map.floorInfo.playerRange = 200
	end
    myShader:send("floorTint_r", map.floorInfo.tint[1])
    myShader:send("floorTint_g", map.floorInfo.tint[2])
    myShader:send("floorTint_b", map.floorInfo.tint[3])
    myShader:send("player_range", map.floorInfo.playerRange)
	newmap[0] = {}
	printMap(newmap)
	return newmap
end

return map