local P = {}
unlocksScreen = P

unlocks = require('scripts.unlocks')

P.background = love.graphics.newImage('Graphics/armageddon.png')
P.unlocksDarken = love.graphics.newImage('NewGraphics/unlocksDarken.png')
P.numPerRow = 15
P.opened = false

function P.draw()
	for unlockId = 0, #unlocks-1 do
		local unlock = unlocks[unlockId+1]
		if not unlock.hidden then
			local x = unlockId % P.numPerRow
			local y = (unlockId - x)/P.numPerRow
			local tScale = tiles[1].sprite:getWidth()/math.max(unlock.sprite:getWidth(), unlock.sprite:getHeight())
			local uScale = width/unlocks.frame:getWidth()/P.numPerRow
			local offsetY = (unlocks.frame:getHeight() - unlock.sprite:getHeight()*tScale)/2
			local offsetX = (unlocks.frame:getWidth() - unlock.sprite:getWidth()*tScale)/2
			local realOffsetX = x * width/P.numPerRow
			local realOffsetY = y * width/P.numPerRow
			love.graphics.draw(unlocks.frame, realOffsetX, realOffsetY, 0, uScale, uScale)
			love.graphics.draw(unlock.sprite, realOffsetX+offsetX*uScale, realOffsetY+(offsetY)*uScale, 0, uScale*tScale, uScale*tScale)
			if not unlock.unlocked then
				love.graphics.draw(P.unlocksDarken, realOffsetX, realOffsetY, 0, uScale, uScale)
			end
		end
	end
end

function P.keypressed(key, unicode)
	if key == 'escape' then
		P.close()
	end
end

function P.open()
	P.opened = true
end

function P.close()
	P.opened = false
end

return unlocksScreen