require('scripts.object')
require('scripts.tiles')
local util = require('scripts.util')
local json = require('scripts.dkjson')

local P = {}
map = P

local MapInfo = Object:new{floor = 1, height = 0, numRooms = 0}

function P.loadFloor(inFloorFile)
	local floorData = util.readJSON(inFloorFile)
	P.floorInfo = {rooms = {}}
	for k, v in pairs(floorData.data) do
		P.floorInfo[k] = v
	end
	local loadRooms = floorData.loadRooms
	for k, v in pairs(loadRooms) do
		local roomsData = util.readJSON(v.filePath)
		P.floorInfo.rooms[k] = roomsData.rooms
		P.filterRoomSet(P.floorInfo.rooms[k], v.requirements)
		for k1, v1 in pairs(P.floorInfo.rooms[k]) do
			if roomsData.superFields ~= nil then
				for k2, v2 in pairs(roomsData.superFields) do
					if v1[k2] == nil then v1[k2] = v2 end
				end
			end
		end
	end
end

function P.filterRoomSet(arr, requirements)
	for k, v in pairs(arr) do
		if not P.roomMeetsRequirements(v) then
			arr[k] = nil
		end
	end
end

function P.roomMeetsRequirements(roomData, requirements)
	return true
end

function P.createRoom(inRoom, arr)
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

function P.generateMapStandard()
	local height = P.floorInfo.height
	local numRooms = P.floorInfo.numRooms
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end
	local startRoomId = '1'
	newmap[math.floor(height/2)][math.floor(height/2)] = {roomid = startRoomId, room = P.createRoom(startRoomId, P.floorInfo.rooms.rooms), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = math.floor(height/2)
	newmap.initialX = math.floor(height/2)
	treasureX = 0
	treasureY = 0
	local randomRoomArray = util.createRandomKeyArray(P.floorInfo.rooms.rooms)
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
							or (j == treasureY and k+1 == treasureX) or (j == treasureY and k-1 == treasureX) then
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
		local roomid = randomRoomArray[i+2]
		if i == numRooms-2 then
			arr = P.floorInfo.rooms.treasureRooms
			roomid = util.chooseRandomKey(arr)
			treasureX = choice.y
			treasureY = choice.x
		elseif i == numRooms-1 then
			arr = P.floorInfo.rooms.finalRooms
			roomid = util.chooseRandomKey(arr)
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