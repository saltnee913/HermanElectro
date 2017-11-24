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

function P.getSupertoolTypesHeld()
	local numSup = 0
	for i = tools.numNormalTools+1, #tools do
		if tools[i].numHeld>0 then
			numSup = numSup+1
		end
	end
	return numSup
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

function P.writeJSON(filePath, data, state, directory)
	local usedSaveDir = saveDir
	if directory ~= nil then
		usedSaveDir = saveDir..'/'..directory
	end
	local str = json.encode(data, state)
	if not love.filesystem.exists(usedSaveDir) then
		love.filesystem.createDirectory(usedSaveDir)
	end
	love.filesystem.write(usedSaveDir..'/'..filePath, str)
end
function P.writeJSONCustom(filePath, roomToAdd)
	if not love.filesystem.exists(saveDir..'/'..filePath) then
		local str = "{\"rooms\": {\n"
		str = str..roomToAdd.."\n}}"
		
		if not love.filesystem.exists(saveDir) then
			love.filesystem.createDirectory(saveDir)
		end

		love.filesystem.write(saveDir..'/'..filePath, str)
	else
		local str = love.filesystem.read(saveDir..'/'..filePath)
		str = str:sub(1,#str-4)
		str = str..",\n"
		str = str..roomToAdd
		str = str.."\n}}"
		love.filesystem.write(saveDir..'/'..filePath, str)
	end
end

function P.roomToString(newRoom)
	local ret = '"'..newRoom.roomid..'":\n'

	--layout
	ret = ret.."{\n[\n"
	for i = 1, #newRoom.layout do
		ret = ret.."["
		for j = 1, #newRoom.layout[i] do
			if type(newRoom.layout[i][j])~='number' then
				ret = ret.."["
				for k = 1, #newRoom.layout[i][j] do
					ret = ret..newRoom.layout[i][j][k]
					if not k==#newRoom.layout[i][j] then
						ret = ret..","
					end
				end
				ret = ret.."]"
			else
				ret = ret..newRoom.layout[i][j]
				if not j==#newRoom.layout[i] then
					ret = ret..","
				end
			end
		end
		ret = ret.."],"
	end
	ret = ret.."],"

	ret = ret.."}"

	return ret
end

function P.deepContains(arr, value, floor)
	if type(arr) == 'table' then
		for i = 1, #arr do
			if(P.deepContains(arr[i], value, floor)) then
				return true
			end
		end
		return false
	elseif floor ~= nil and arr ~= nil and value ~= nil and type(arr) == 'number' then
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
		love.math.setRandomSeed(P.randoms[random].seed)
		for i = 1, P.randoms[random].times do
			love.math.random()
		end
		P.randoms[random].times = P.randoms[random].times + 1
		return love.math.random()
	end
end

P.images = {}

function P.getImage(imageSource)
	if P.images[imageSource] == nil then
		P.images[imageSource] = love.graphics.newImage(imageSource)
	end
	return P.images[imageSource]
end

function P.createHarmlessExplosion(y, x, range)
	if range==nil then range = 1 end

	for i = -1*range, range do
		for j = -1*range, range do
			if room[y+i]~=nil and room[y+i][x+j]~=nil then
				room[y+i][x+j]:destroy()
				if room[y+i][x+j]:instanceof(tiles.bomb) then
					--unlocks.unlockUnlockableRef(unlocks.bombBuddyUnlock)
				end
			end
			for k = 1, #animals do
				if not animals[k].dead and animals[k].tileY==y+i and animals[k].tileX==x+j then
					animals[k]:kill()
					if animals[k]:instanceof(animalList.bombBuddy) then
						animals[k]:explode()
					end
				end
			end
			for k = 1, #pushables do
				if pushables[k].tileY==y+i and pushables[k].tileX==x+j and (not pushables[k].destroyed) then
					pushables[k]:destroy()
				end
			end
		end
	end
	updatePower()
end

function P.createHarmfulExplosion(y, x, range)
	if range==nil then range = 1 end

	--kill player
	if player.tileY<=y+range and player.tileX<=x+range and player.tileY>=y-range and player.tileX>=x-range then
		kill("explosion")
	end

	--all other explosion stuff
	util.createHarmlessExplosion(y,x,range)
end

return util