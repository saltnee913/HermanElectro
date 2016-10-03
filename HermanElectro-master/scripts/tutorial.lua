local P = {}
tutorial = P

local clickAnimation = {baseTime = 10, timeLeft = 0, baseDelay = 20, delayLeft = 0}
local minimapAnimation = {baseDelay = 15, delayLeft = 0, enabled = false, opacity = 0}

function P.load()
	
end

function P.draw()

	if clickAnimation.timeLeft ~= 0 then

	end
	if minimapAnimation.enabled and minimapAnimation.delayLeft < 0 then
		local opacityCalc = 2.5*((minimapAnimation.opacity % 2) - 1)
		local value = math.exp(-0.5*opacityCalc*opacityCalc)/(2.5066)
		love.graphics.setColor(255, 255, 255, value*500)
		love.graphics.draw(player.character.sprite, width*0.91, height*0.05, 45, 0.2, 0.2)
		love.graphics.setColor(255, 255, 255, 255)
	end

end

function P.update(dt)
	minimapAnimation.opacity = minimapAnimation.opacity + dt
	minimapAnimation.delayLeft = minimapAnimation.delayLeft - dt
	clickAnimation.delayLeft = clickAnimation.delayLeft - dt
	if clickAnimation.delayLeft < 0 then
		clickAnimation.timeLeft = clickAnimation.timeLeft - dt
	end
end

function P.enterRoom()
	minimapAnimation.delayLeft = minimapAnimation.baseDelay
	local roomid = mainMap[mapy][mapx].roomid
	if roomid == 'tut_3_walls' and tools.saw.numHeld ~= 0 then
		clickAnimation.delayLeft = clickAnimation.baseDelay
		clickAnimation.timeLeft = clickAnimation.baseTime
	end
	local itemsNeeded = map.getItemsNeeded(mainMap[mapy][mapx].roomid)[1]
	minimapAnimation.enabled = false
	for i = 1, tools.numNormalTools do
		if itemsNeeded[i] > tools[i].numHeld then
			minimapAnimation.enabled = true
		end
	end
end

return tutorial