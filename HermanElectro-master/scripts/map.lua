require('scripts.object')
require('scripts.tiles')

local P = {}
map = P

P.rooms = {}

local MapInfo = Object:new{height = 0, numRooms = 0}

function P.loadRooms()

	--super hacky, will do json later
	
	for roomNum = 0, 20 do
		P.rooms[roomNum] = {}
		for i = 0, 10 do
			P.rooms[roomNum][i] = {}
			for j = 0, 20 do
				P.rooms[roomNum][i][j] = nil
			end
		end
		P.rooms[roomNum][0][roomNum] = tiles.conductiveTile
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
	newmap[height/2][height/2] = {roomid = 0, isFinal = false, isInitial = false}
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
		local roomNum = i+1 -- for testing purposes
		newmap[choice.x][choice.y] = {roomid = roomNum, isFinal = false, isInitial = false}
	end
	printMap(newmap)
	return newmap
end

return map