local json = require('scripts.dkjson')

local P = {}
util = P

function P.printTable(tab)
	local state = {indent = true, keyorder = keyOrder}
	print(json.encode(tab, state))
end

function P.chooseWeightedRandom(arr, random)
	local sum = 0
	for i = 1, #arr do
		sum = sum + arr[i]
	end
	local choice = (util.random(random)*sum)
	for i = 1, #arr do
		choice = choice - arr[i]
		if choice <= 0 then
			return i
		end
	end
	return -1
end

function P.chooseRandomElement(arr, random)
	return arr[util.random(#arr, random)]
end

function P.getOffsetByDir(dir)
	while (dir > 4) do dir = dir - 4 end
	if dir == 1 then return {y = -1, x = 0}
	elseif dir == 2 then return {y = 0, x = 1}
	elseif dir == 3 then return {y = 1, x = 0}
	else return {y = 0, x = -1} end
end

--you must seed first!
function P.chooseRandomKey(arr, random)
	return P.createRandomKeyArray(arr, random)[1]
end

--you must seed first!
function P.createRandomKeyArray(arr, random, blacklist)
	local keyArray = P.createIndexArray(arr, blacklist)
	table.sort(keyArray)
	return P.shuffle(keyArray, random)
end

--this is the ultra hacky part, we should remove it later
function P.createIndexArray(arr, blacklist)
	if blacklist == nil then
		blacklist = {}
	end
	local keyArray = {}
	for k in pairs(arr) do
		if blacklist == nil or not P.deepContains(blacklist, k) then
			keyArray[#keyArray+1] = k
		end
	end
	return keyArray
end

--shuffles array, you must seed first!
function P.shuffle(arr,random)
	local shuffledArr = {}
	for i = 1, #arr do
		local index = util.random(#arr, random)
		while(shuffledArr[index]~=nil) do
			index = util.random(#arr, random)
		end
		shuffledArr[index] = arr[i]
	end
	return shuffledArr
end

function P.readJSON(filePath, askForRooms)
	local str = love.filesystem.read(filePath)
	local obj, pos, err, roomsArray = json.decode(str, 1, nil, askForRooms and 'rooms' or nil)
	if err then
		print('Error:', err)
		return nil
	else
		return obj, roomsArray
	end
end

function P.writeJSON(filePath, data)
	local str = json.encode(data)
	if not love.filesystem.exists(saveDir) then
		love.filesystem.createDirectory(saveDir)
	end
	print(str)
	love.filesystem.write(saveDir..'/'..filePath, str)
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

P.randoms = {}

function P.newRandom(random, randSeed)
	P.randoms[random] = {seed = randSeed, times = 2}
end

function P.random(maxVal, random)
	if random ~= nil then
		return math.floor(P.random(random)*maxVal)+1
	else
		random = maxVal
		print(random)
		love.math.setRandomSeed(P.randoms[random].seed)
		for i = 1, P.randoms[random].times do
			love.math.random()
		end
		P.randoms[random].times = P.randoms[random].times + 1
		return love.math.random()
	end
end

return util