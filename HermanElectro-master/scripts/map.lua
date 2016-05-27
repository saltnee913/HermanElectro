require('scripts.object')
require('scripts.tiles')
local json = require('scripts.dkjson')

local P = {}
map = P

P.rooms = {}
P.treasureRooms = {}
P.finalRooms = {}

local MapInfo = Object:new{floor = 1, height = 0, numRooms = 0}
function P.createRoom(inRoom, arr)
	local roomToLoad = arr[inRoom].layout
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

function P.getItemsNeeded(inRoom)
	return P.rooms[inRoom].itemsNeeded
end
function P.getItemsGiven(inRoom)
	return P.rooms[inRoom].itemsGiven
end

function P.loadRooms(roomPath)
	--super hacky, will do json later
	io.input(roomPath)
	local str = io.read('*all')
	local obj, pos, err = json.decode(str, 1, nil)
	if err then
		print('Error:', err)
	else
		P.rooms = obj.rooms
	end
end

function P.loadTreasureRooms(roomPath)
	--super hacky, will do json later
	io.input(roomPath)
	local str = io.read('*all')
	local obj, pos, err = json.decode(str, 1, nil)
	if err then
		print('Error:', err)
	else
		P.treasureRooms = obj.rooms
	end
end

function P.loadFinalRooms(roomPath)
	--super hacky, will do json later
	io.input(roomPath)
	local str = io.read('*all')
	local obj, pos, err = json.decode(str, 1, nil)
	if err then
		print('Error:', err)
	else
		P.finalRooms = obj.rooms
	end
end

local function printMap(inMap)
	for i = 0, inMap.height do
		local p = ''
		for j = 0, inMap.height do
			if inMap[i][j] == nil then
				p = p .. '-  '
			else
				p = p .. inMap[i][j].roomid .. ' '
				if(inMap[i][j].roomid < 10) then
					p = p .. ' '
				end
			end
		end
		print(p)
	end
end

function P.generateMap(height, numRooms, seed)
	math.randomseed(seed)
	local newmap = MapInfo:new{height = height, numRooms = numRooms}
	for i = 0, height+1 do
		newmap[i] = {}
	end
	newmap[height/2][height/2] = {roomid = 1, room = P.createRoom(1, P.rooms), isFinal = false, isInitial = true, isCompleted = false}
	newmap.initialY = height/2
	newmap.initialX = height/2
	treasureX = 0
	treasureY = 0
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
		local roomNum = i+2 -- for testing purposes
		arr = P.rooms
		if i == numRooms-2 then
			arr = P.treasureRooms
			roomNum = 1
			treasureX = choice.y
			treasureY = choice.x
		elseif i == numRooms-1 then
			roomNum = 1
			arr = P.finalRooms
		end
		newmap[choice.x][choice.y] = {roomid = roomNum, room = P.createRoom(roomNum, arr), isFinal = false, isInitial = false}
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

function P.generateMapFromJSON(mapFile)
	local newmap
	io.input(mapFile)
	local str = io.read('*all')
	local obj, pos, err = json.decode(str, 1, nil)
	if err then
		print('Error:', err)
	else
		newmap = obj.map
	end
	newmap.height = #newmap
	newmap.numRooms = 0
	for i = 1, newmap.height do
		for j = 1, newmap.height do
			if newmap[i] ~= nil and newmap[i][j] ~= nil and newmap[i][j] ~= 0 then
				newmap.numRooms = newmap.numRooms + 1
				newmap[i][j] = {roomid = newmap[i][j], room = P.createRoom(newmap[i][j], P.rooms), isFinal = false, isInitial = false, isCompleted = false}
				if newmap[i][j].roomid == 1 then
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