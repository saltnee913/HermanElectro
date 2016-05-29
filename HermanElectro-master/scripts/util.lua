local P = {}
util = P

function P.getOffsetByDir(dir)
	while (dir > 4) do dir = dir - 4 end
	if dir == 1 then return {y = -1, x = 0}
	elseif dir == 2 then return {y = 0, x = 1}
	elseif dir == 3 then return {y = 1, x = 0}
	else return {y = 0, x = -1} end
end

return util