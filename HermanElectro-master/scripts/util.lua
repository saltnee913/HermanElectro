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
function P.createRandomKeyArray(arr)
	local keyArray = P.createIndexArray(arr)
	table.sort(keyArray)
	return P.shuffle(keyArray)
end

--this is the ultra hacky part, we should remove it later
function P.createIndexArray(arr)
	local keyArray = {}
	for k in pairs(arr) do
		keyArray[#keyArray+1] = k
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

return util