local P = {}
toolManuel = P

P.opened = false

P.mainScreen = love.graphics.newImage('NewGraphics/MenuTemplateA.png')
P.manuelTint = love.graphics.newImage('NewGraphics/manuelTint.png')
P.tabBG = love.graphics.newImage('NewGraphics/manuelTabBG.png')
P.tabBGSelected = love.graphics.newImage('NewGraphics/manuelTabSelectedBG.png')

P.sawScreens = {love.graphics.newImage('NewGraphics/SawTutA.png')}
P.ladderScreens = {love.graphics.newImage('NewGraphics/LadderTutA.png'), love.graphics.newImage('NewGraphics/LadderTutB.png')}
P.wireCutterScreens = {love.graphics.newImage('NewGraphics/WireTutA.png'), love.graphics.newImage('NewGraphics/WireTutB.png')}
P.waterScreens = {}
P.spongeScreens = {}
P.brickScreens = {}
P.gunScreens = {}
P.screens = {P.sawScreens, P.ladderScreens, P.wireCutterScreens}--, P.waterScreens, P.spongeScreens, P.brickScreens, P.gunScreens}

P.currentScreen = 1
P.screenLevel = 1

function P.draw()
	local screen = P.screens[P.currentScreen][P.screenLevel]
	local scale = {x = width/P.mainScreen:getWidth(), y = height/P.mainScreen:getHeight()}
	love.graphics.draw(P.mainScreen, 0, 0, 0, scale.x, scale.y)
	love.graphics.draw(screen, 22*scale.x, 64*scale.y, 0, scale.x, scale.y)
	love.graphics.draw(P.manuelTint, (40*P.currentScreen-18)*scale.x, (5)*scale.y, 0, scale.x, scale.y)
	for i = 1, #(P.screens[P.currentScreen]) do
		if P.screenLevel == i then
			love.graphics.draw(P.tabBGSelected, 4*scale.x, (40+26*i)*scale.y, 0, scale.x, scale.y)
		else
			love.graphics.draw(P.tabBG, 4*scale.x, (40+26*i)*scale.y, 0, scale.x, scale.y)
		end
	end
end

function P.keypressed(key, unicode)
	if key == 'right' or key == 'd' then
		P.currentScreen = P.currentScreen + 1
		P.screenLevel = 1
	elseif key == 'left' or key == 'a' then
		P.currentScreen = P.currentScreen - 1
		P.screenLevel = 1
	elseif key == 'down' or key == 's' then
		P.screenLevel = P.screenLevel + 1
	elseif key == 'up' or key == 'w' then
		P.screenLevel = P.screenLevel - 1
	elseif key == 'escape' then
		P.close()
	end
	if P.currentScreen < 1 then
		P.currentScreen = #P.screens
	elseif P.currentScreen > #P.screens then
		P.currentScreen = 1
	end
	if P.screenLevel < 1 then
		P.screenLevel = #(P.screens[P.currentScreen])
	elseif P.screenLevel > #(P.screens[P.currentScreen]) then
		P.screenLevel = 1
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