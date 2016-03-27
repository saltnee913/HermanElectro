require('scripts.object')
require('scripts.tiles')
local json = require('scripts.dkjson')

local P = {}
map = P

P.rooms = {}
P.itemsNeeded = {}

local MapInfo = Object:new{height = 0, numRooms = 0}

local function createRoom(inRoom)
	print(inRoom)
	local roomToLoad = P.rooms[inRoom]
	local loadedRoom = {}
	for i = 1, #roomToLoad do
		loadedRoom[i] = {}
		for j = 1, #(roomToLoad[i]) do
			if roomToLoad[i][j] == nil or roomToLoad[i][j] == 0 then
				loadedRoom[i][j] = nil
			else
				loadedRoom[i][j] = tiles[roomToLoad[i][j]]:new()
			end
		end
	end
	if(loadedRoom==nil) then print("ellie fucked up") end
	return loadedRoom
end

function P.loadRooms()

	--super hacky, will do json later
	io.input('rooms.json')
	local str = io.read('*all')
	local obj, pos, err = json.decode(str, 1, nil)
	if err then
		print('Error:', err)
	else
		P.rooms = obj.rooms
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
	newmap[height/2][height/2] = {roomid = 1, room = createRoom(1), isFinal = false, isInitial = false}
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
						available[a] = {x=j,y=k}
						a=a+1
					end
				end
			end
		end

		numRooms=0
		local choice = available[math.floor(math.random()*a)]
		--roomNum = math.floor(math.random()*table.getn(rooms)) -- what we will actually do, with some editing
		local roomNum = i+2 -- for testing purposes
		newmap[choice.x][choice.y] = {roomid = roomNum, room = createRoom(roomNum), isFinal = false, isInitial = false}
	end
	printMap(newmap)
	return newmap
end

return map