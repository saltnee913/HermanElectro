require('scripts.object')
require('scripts.tiles')
local util = require('scripts.util')
local json = require('scripts.dkjson')

local P = {}
map = P

--Temporary variable, we have to do this a better way later
P.floorOrder = {'RoomData/floor1.json', 'RoomData/floor2.json', 'RoomData/floor3.json', 'RoomData/floor4.json', 'RoomData/floor5.json'}

local MapInfo = Object:new{floor = 1, height = 0, numRooms = 0}

function P.loadFloor(inFloorFile)
	local floorData = util.readJSON(inFloorFile)
	P.floorInfo = {rooms = {}, roomsArray = {}}
	for k, v in pairs(floorData.data) do
		P.floorInfo[k] = v
	end
	local loadRooms = floorData.loadRooms
	toolMin = loadRooms.rooms.requirements.toolRange[1]
	toolMax = loadRooms.rooms.requirements.toolRange[2]
	for k, v in pairs(loadRooms) do
		local roomsData, roomsArray = util.readJSON(v.filePath, true)
		P.floorInfo.rooms[k] = roomsData.rooms
		P.filterRoomSet(P.floorInfo.rooms[k], v.requirements)
		for i = 1, #roomsArray do
			if P.floorInfo.rooms[k][roomsArray[i]] ~= nil then
				P.floorInfo.roomsArray[#(P.floorInfo.roomsArray)+1] = roomsArray[i]
			end
		end
		local amt = 0
		for k1, v1 in pairs(P.floorInfo.rooms[k]) do
			if roomsData.superFields ~= nil then
				for k2, v2 in pairs(roomsData.superFields) do
					if v1[k2] == nil then v1[k2] = v2 end
				end
			end
			amt = amt + 1
		end
		print(k..': '..amt)
	end
end

function P.getNextRoom(roomid)
	local roomsArray = P.floorInfo.roomsArray
	for i = 1, #roomsArray-1 do
		if roomsArray[i] == roomid then
			return roomsArray[i+1]
		end
	end
	return roomid
end
function P.getPrevRoom(roomid)
	local roomsArray = P.floorInfo.roomsArray
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

function P.blocksMovement(tileY, tileX)
	return room[tileY] ~= nil and room[tileY][tileX] ~= nil and room[tileY][tileX].blocksMovement
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
		local works = true
		local sum = 0
		for i = 1, #roomData.itemsNeeded do
			for j = 1, #roomData.itemsNeeded[i] do
				sum = sum+roomData.itemsNeeded[i][j]
			end
		end
		local avg = sum/#roomData.itemsNeeded
		if avg<value[1] or avg>value[2] then works = false end
		if sum==0 then works = true end
		if works then return true end
		return false
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
	local roomToLoad = arr[inRoom].layout
	roomToLoad = (roomToLoad ~= nil) and roomToLoad 
		or arr[inRoom].layouts[math.floor(math.random()*#(arr[inRoom].layouts))+1]
	local loadedRoom = {}
	loadedRoom.height = #roomToLoad
	loadedRoom.length = #roomToLoad[1]
	for i = 1, #roomToLoad do
		loadedRoom[i] = {}
		for j = 1, #(roomToLoad[i]) do
			local ind = math.floor(roomToLoad[i][j])
			if roomToLoad[i][j] == nil or ind == 0 then
				loadedRoom[i][j] = nil
			elseif tiles[ind].animal ~= nil then
				loadedRoom[i][j] = tiles[ind]:new()
				loadedRoom[i][j].animal = tiles[ind].animal:new()
			else
				loadedRoom[i][j] = tiles[ind]:new()
			end
			local rot = math.floor(10*(roomToLoad[i][j]-ind+0.01))
			if rot~=nil and rot ~= 0 and loadedRoom[i][j]~=nil then
				loadedRoom[i][j]:rotate(rot)
			end
		end
	end
	if(loadedRoom==nil) then print("ellie fucked up, and jmoney is fucking hype") end
	return loadedRoom
end

function P.getFieldForRoom(inRoom, inField)
	for k, v in pairs(P.floorInfo.rooms) do
		if v[inRoom] ~= nil then
			return v[inRoom][inField]
		end
	end
	log('invalid room id')
	return nil
end

function P.isRoomType(inRoom, roomType)
	return P.floorInfo.rooms[roomType][inRoom] ~= nil
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
		print(p)
	end
end

function P.generateMap(seed)
	math.randomseed(seed)
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
	local blacklist = {startRoomID}
	local randomRoomArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms, blacklist)
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
		local choice = available[math.floor(math.random()*a)]
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
		if i == numRooms-2 then
			arr = P.floorInfo.rooms.treasureRooms
			roomid = util.chooseRandomKey(arr)
			loadedRoom = P.createRoom(roomid, arr)
			treasureX = choice.y
			treasureY = choice.x
		elseif i == numRooms-1 then
			arr = P.floorInfo.rooms.finalRooms
			roomid = util.chooseRandomKey(arr)
			loadedRoom = P.createRoom(roomid, arr)
		elseif i == numRooms-3 then
			arr = P.floorInfo.rooms.donationRooms
			roomid = util.chooseRandomKey(arr)
			loadedRoom = P.createRoom(roomid, arr)
			donationX = choice.y
			donationY = choice.x
		end
		newmap[choice.x][choice.y] = {roomid = roomid, room = P.createRoom(roomid, arr), isFinal = false, isInitial = false}
	end
	--printMap(newmap)
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
	local blacklist = {startRoomID}
	local randomRoomArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms, blacklist)
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
		local choice = available[math.floor(math.random()*a)]
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
			roomid = util.chooseRandomKey(arr)
			loadedRoom = P.createRoom(roomid, arr)
		elseif i>numRooms-5 then
			arr = P.floorInfo.rooms.treasureRooms
			roomid = util.chooseRandomKey(arr)
			loadedRoom = P.createRoom(roomid, arr)
			treasureX = choice.y
			treasureY = choice.x
		elseif i>numRooms-10 then
			arr = P.floorInfo.rooms.donationRooms
			roomid = util.chooseRandomKey(arr)
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
	--[[local newmap = MapInfo:new{height = #P.rooms, numRooms = #P.rooms}
	newmap[0] = {}
	newmap[newmap.height+1] = {}
	for i = 1, newmap.height do
		newmap[i] = {}
		newmap[i][math.floor(newmap.height/2)] = {roomid = i, room = P.createRoom(i), isFinal = false, isInitial = false, isCompleted = false}
	end
	newmap[1][math.floor(newmap.height/2)].isInitial = true
	newmap.initialY = 1
	newmap.initialX = math.floor(newmap.height/2)
	newmap[1][math.floor(newmap.height/2)].isCompleted = false
	newmap[newmap.height][math.floor(newmap.height/2)].isFinal = true
	print(newmap[1][math.floor(newmap.height/2)].roomid)
	printMap(newmap)
	return newmap]]
end

function P.generateMapFromJSON()
	local newmap = P.floorInfo.map
	newmap.height = #newmap
	newmap.numRooms = 0
	for i = 1, newmap.height do
		for j = 1, newmap.height do
			if newmap[i] ~= nil and newmap[i][j] ~= nil and newmap[i][j] ~= 0 then
				newmap.numRooms = newmap.numRooms + 1
				newmap[i][j] = {roomid = newmap[i][j], room = P.createRoom(newmap[i][j], P.floorInfo.rooms.rooms), isFinal = false, isInitial = false, isCompleted = false}
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
	newmap[0] = {}
	printMap(newmap)
	return newmap
end

return map