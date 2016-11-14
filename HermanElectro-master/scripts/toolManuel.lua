local P = {}
toolManuel = P

P.opened = false

P.mainScreen = love.graphics.newImage('NewGraphics/MenuTemplateA.png')
P.manuelTint = love.graphics.newImage('NewGraphics/manuelTint.png')
P.screens = {love.graphics.newImage('NewGraphics/SawTutA.png'), love.graphics.newImage('NewGraphics/LadderTutA.png')}
P.currentScreen = 1

function P.draw()
	local screen = P.screens[P.currentScreen]
	local scale = {x = width/P.mainScreen:getWidth(), y = height/P.mainScreen:getHeight()}
	love.graphics.draw(P.mainScreen, 0, 0, 0, scale.x, scale.y)
	love.graphics.draw(screen, 22*scale.x, 64*scale.y, 0, scale.x, scale.y)
	love.graphics.draw(P.manuelTint, (40*P.currentScreen-18)*scale.x, (5)*scale.y, 0, scale.x, scale.y)
end

function P.keypressed(key, unicode)
	if key == 'right' or key == 'd' then
		P.currentScreen = P.currentScreen + 1
	elseif key == 'left' or key == 'a' then
		P.currentScreen = P.currentScreen - 1
	elseif key == 'escape' then
		P.close()
	end
	if P.currentScreen < 1 then
		P.currentScreen = #P.screens
	elseif P.currentScreen > #P.screens then
		P.currentScreen = 1
	end
end

function P.open()
	P.opened = true
	P.currentScreen = 1
end

function P.close()
	P.opened = false
end

return toolManuel