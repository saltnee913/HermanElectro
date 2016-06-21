local json = require('scripts.dkjson')

local P = {}
util = P

function P.getOffsetByDir(dir)
	while (dir > 4) do dir = dir - 4 end
	if dir == 1 then return {y = -1, x = 0}
	elseif dir == 2 then return {y = 0, x = 1}
	elseif dir == 3 then return {y = 1, x = 0}
	else return {y = 0, x = -1} end
end

--you must seed first!
function P.chooseRandomKey(arr)
	return P.createRandomKeyArray(arr)[1]
end

--you must seed first!
function P.createRandomKeyArray(arr, blacklist)
	local keyArray = P.createIndexArray(arr, blacklist)
	table.sort(keyArray)
	return P.shuffle(keyArray)
end

--this is the ultra hacky part, we should remove it later
function P.createIndexArray(arr, blacklist)
	local keyArray = {}
	for k in pairs(arr) do
		if blacklist == nil or not P.deepContains(blacklist, k) then
			keyArray[#keyArray+1] = k
		end
	end
	return keyArray
end

--shuffles array, you must seed first!
function P.shuffle(arr)
	local shuffledArr = {}
	for i = 1, #arr do
		local index = math.floor(math.random()*#arr)+1
		while(shuffledArr[index]~=nil) do
			index = math.floor(math.random()*#arr)+1
		end
		shuffledArr[index] = arr[i]
	end
	return shuffledArr
end

function P.readJSON(filePath, askForRooms)
	io.input(filePath)
	local str = io.read('*all')
	local obj, pos, err, roomsArray = json.decode(str, 1, nil, askForRooms and 'rooms' or nil)
	if err then
		print('Error:', err)
		return nil
	else
		return obj, roomsArray
	end
end

function P.deepContains(arr, value, floor)
	if type(arr) == 'table' then
		for i = 1, #arr do
			if(P.deepContains(arr[i], value, floor)) then
				return true
			end
		end
		return false
	elseif floor ~= nil and arr ~= nil and value ~= nil then
		return math.floor(arr) == math.floor(value)
	else
		return arr == value
	end
end

return util