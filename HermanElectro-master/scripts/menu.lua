require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
menuList = P

P.menu = Object:new{background = 'Graphics/menuBackground.png', width = 100*scale, height = 150*scale}
function P.menu:draw()
	local startx = width/2-self.width/2
	local starty = height/2-self.height/2
	
	local bgSprite = util.getImage(self.background)
	local xScale = self.width/bgSprite:getWidth()
	local yScale = self.width/bgSprite:getHeight()

	love.graphics.draw(bgSprite, startx, starty, 0, xScale, yScale)
end

P.pauseMenu = P.menu:new{}


menuList[1] = P.menu
menuList[2] = P.pauseMenu

return menuList