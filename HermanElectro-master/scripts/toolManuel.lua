local P = {}
toolManuel = P

P.opened = false

P.mainScreen = 'NewGraphics/MenuTemplateA.png'
P.manuelTint = 'NewGraphics/manuelTint.png'
P.tabBG = 'NewGraphics/manuelTabBG.png'
P.tabBGSelected = 'NewGraphics/manuelTabSelectedBG.png'

local scale = {x = width/util.getImage(P.mainScreen):getWidth(), y = height/util.getImage(P.mainScreen):getHeight()}
local function drawHere(image, x, y, rotation)
	if rotation == nil then rotation = 0 end
	love.graphics.draw(util.getImage(image), x*scale.x, y*scale.y, rotation, scale.x, scale.y)
end
local function drawAtTile(image, tileX, tileY, x, y, yOffset, rotation)
	if yOffset == nil then yOffset = 0 end
	if rotation ~= nil then
		if rotation == 1 or rotation == 2 then
			tileX = tileX + 1
		end
		if rotation == 2 or rotation == 3 then
			tileY = tileY + 1
		end
		rotation = rotation*math.pi/2
	end
	drawHere(image, x + tileX*tileWidth, y + tileY*tileHeight + yOffset, rotation)
end
local function drawGreen(tileX, tileY, x, y, yOffset)
	if yOffset == nil then yOffset = 0 end
	love.graphics.draw(util.getImage(green), (x+tileWidth*tileX)*scale.x, (y+tileHeight*tileY+yOffset)*scale.y, rotation, scale.x, scale.y*(16-yOffset)/16)
end

P.sawScreens = {
	--destroying walls
	function(x, y, scale)
		drawAtTile(tiles.wall.sprite, 1, 0, x, y, tiles.wall.yOffset)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y, tiles.wall.yOffset)

		drawAtTile(tiles.wall.destroyedSprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)
	end,

	--destroying metal walls
	function(x, y, scale)
		drawAtTile(tiles.metalWall.sprite, 1, 0, x, y, tiles.metalWall.yOffset)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y, tiles.metalWall.yOffset)

		drawAtTile(tiles.metalWall.destroyedSprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)


		drawAtTile(tiles.powerSupply.sprite, 1, 4, x, y)
		drawAtTile(tiles.metalWall.poweredSprite, 1, 5, x, y, tiles.metalWall.yOffset)
		drawAtTile(tiles.verticalWire.poweredSprite, 1, 6, x, y)
		drawAtTile(player.character.sprite, 0, 5, x, y)
		drawGreen(1, 5, x, y, tiles.metalWall.yOffset)

		drawAtTile(tiles.powerSupply.sprite, 8, 4, x, y)
		drawAtTile(tiles.metalWall.destroyedSprite, 8, 5, x, y)
		drawAtTile(tiles.verticalWire.sprite, 8, 6, x, y)
		drawAtTile(player.character.sprite, 7, 5, x, y)
	end,

	--destroying boxes
	function(x, y, scale)
		drawAtTile(pushableList.box.sprite, 1, 0, x, y)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(player.character.sprite, 7, 0, x, y)
	end
}

P.ladderScreens = {
	--laddering pits
	function(x, y, scale)
		drawAtTile(tiles.pit.sprite, 1, 0, x, y)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(tiles.pit.destroyedSprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)


		drawAtTile(tiles.poweredFloor.sprite, 1, 4, x, y)
		drawAtTile(player.character.sprite, 0, 4, x, y)
		drawGreen(1, 4, x, y)

		drawAtTile(tiles.poweredFloor.destroyedSprite, 8, 4, x, y)
		drawAtTile(player.character.sprite, 7, 4, x, y)
	end,

	--blocking animals
	function(x, y, scale)
		drawAtTile(animalList.pitbull.sprite, 3, 0, x, y)
		drawAtTile(player.character.sprite, 1, 0, x, y)
		drawGreen(2, 0, x, y)

		drawAtTile(tiles.ladder.sprite, 9, 0, x, y)
		drawAtTile(animalList.pitbull.sprite, 10, 0, x, y)
		drawAtTile(player.character.sprite, 8, 0, x, y)

		drawAtTile(tiles.ladder.sprite, 2, 4, x, y)
		drawAtTile(animalList.pitbull.sprite, 3, 4, x, y)
		drawAtTile(player.character.sprite, 0, 4, x, y)

		drawAtTile(tiles.ladder.sprite, 9, 4, x, y)
		drawAtTile(animalList.pitbull.sprite, 10, 4, x, y)
		drawAtTile(player.character.sprite, 8, 4, x, y)
	end
}

P.wireCutterScreens = {
	--cutting wires
	function(x, y, scale)
		drawAtTile(tiles.verticalWire.sprite, 1, 0, x, y)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(tiles.verticalWire.destroyedSprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)


		drawAtTile(tiles.powerSupply.sprite, 1, 4, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 1, 5, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 1, 6, x, y)
		drawAtTile(player.character.sprite, 0, 5, x, y)
		drawGreen(1, 5, x, y)

		drawAtTile(tiles.powerSupply.sprite, 8, 4, x, y)
		drawAtTile(tiles.verticalWire.destroyedSprite, 8, 5, x, y)
		drawAtTile(tiles.verticalWire.sprite, 8, 6, x, y)
		drawAtTile(player.character.sprite, 7, 5, x, y)
	end,

	--destroying electric floors
	function(x, y, scale)
		drawAtTile(tiles.electricFloor.sprite, 1, 0, x, y)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(tiles.electricFloor.destroyedSprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)


		drawAtTile(tiles.powerSupply.sprite, 1, 4, x, y)
		drawAtTile(tiles.electricFloor.poweredSprite, 1, 5, x, y)
		drawAtTile(tiles.electricFloor.poweredSprite, 1, 6, x, y)
		drawAtTile(player.character.sprite, 0, 5, x, y)
		drawGreen(1, 5, x, y)

		drawAtTile(tiles.powerSupply.sprite, 8, 4, x, y)
		drawAtTile(tiles.electricFloor.destroyedSprite, 8, 5, x, y)
		drawAtTile(tiles.electricFloor.sprite, 8, 6, x, y)
		drawAtTile(player.character.sprite, 7, 5, x, y)
	end
}
P.waterScreens = {
	--destroying power supplies
	function(x, y, scale)
		drawAtTile(tiles.powerSupply.sprite, 1, 0, x, y)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 1, 1, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(tiles.powerSupply.destroyedSprite, 8, 0, x, y)
		drawAtTile(tiles.verticalWire.sprite, 8, 1, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)
	end,

	--destroying electric floors
	function(x, y, scale)
		drawAtTile(tiles.electricFloor.sprite, 1, 0, x, y)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(tiles.electricFloor.destroyedSprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)


		drawAtTile(tiles.powerSupply.sprite, 1, 4, x, y)
		drawAtTile(tiles.electricFloor.poweredSprite, 1, 5, x, y)
		drawAtTile(tiles.electricFloor.poweredSprite, 1, 6, x, y)
		drawAtTile(player.character.sprite, 0, 5, x, y)
		drawGreen(1, 5, x, y)

		drawAtTile(tiles.powerSupply.sprite, 8, 4, x, y)
		drawAtTile(tiles.electricFloor.destroyedSprite, 8, 5, x, y)
		drawAtTile(tiles.electricFloor.sprite, 8, 6, x, y)
		drawAtTile(player.character.sprite, 7, 5, x, y)
	end,

	--making puddles
	function(x, y, scale)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(tiles.puddle.sprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)


		drawAtTile(tiles.powerSupply.sprite, 1, 4, x, y)
		drawAtTile(tiles.verticalWire.sprite, 1, 6, x, y)
		drawAtTile(player.character.sprite, 0, 5, x, y)
		drawGreen(1, 5, x, y)

		drawAtTile(tiles.powerSupply.sprite, 8, 4, x, y)
		drawAtTile(tiles.puddle.poweredSprite, 8, 5, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 8, 6, x, y)
		drawAtTile(player.character.sprite, 7, 5, x, y)
	end
}
P.spongeScreens = {
	--cleaning puddles
	function(x, y, scale)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawAtTile(tiles.puddle.sprite, 1, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(player.character.sprite, 7, 0, x, y)


		drawAtTile(tiles.powerSupply.sprite, 1, 4, x, y)
		drawAtTile(tiles.puddle.poweredSprite, 1, 5, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 1, 6, x, y)
		drawAtTile(player.character.sprite, 0, 5, x, y)
		drawGreen(1, 5, x, y)

		drawAtTile(tiles.powerSupply.sprite, 8, 4, x, y)
		drawAtTile(tiles.verticalWire.sprite, 8, 6, x, y)
		drawAtTile(player.character.sprite, 7, 5, x, y)
	end,

	--unsticking buttons
	function(x, y, scale)
		drawAtTile(player.character.sprite, 0, 1, x, y)
		drawAtTile(tiles.powerSupply.sprite, 1, 0, x, y)
		drawAtTile(tiles.stickyButton.downSprite, 1, 1, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 1, 2, x, y)
		drawGreen(1, 1, x, y)

		drawAtTile(player.character.sprite, 7, 1, x, y)
		drawAtTile(tiles.powerSupply.sprite, 8, 0, x, y)
		drawAtTile(tiles.button.upSprite, 8, 1, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 8, 2, x, y)
	end
}
P.brickScreens = {
	--glass wall
	function(x, y, scale)
		drawAtTile(tiles.glassWall.sprite, 3, 0, x, y, tiles.glassWall.yOffset)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(3, 0, x, y, tiles.glassWall.yOffset)

		drawAtTile(tiles.glassWall.destroyedSprite, 10, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)
	end,

	--bricking buttons
	function(x, y, scale)
		--normal button
		drawAtTile(tiles.button.upSprite, 3, 0, x, y, tiles.mousetrap.yOffset)
		drawAtTile(tiles.powerSupply.sprite, 4, 0, x, y)
		drawAtTile(tiles.verticalWire.sprite, 2, 0, x, y, tiles.verticalWire.yOffset, 1)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(3, 0, x, y, tiles.button.yOffset)

		drawAtTile(tiles.powerSupply.sprite, 11, 0, x, y)
		drawAtTile(tiles.button.brickedSprite, 10, 0, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 9, 0, x, y, tiles.verticalWire.yOffset, 1)
		drawAtTile(player.character.sprite, 7, 0, x, y)

		--stay button
		drawAtTile(tiles.stayButton.upSprite, 3, 2, x, y, tiles.stayButton.yOffset)
		drawAtTile(tiles.powerSupply.sprite, 4, 2, x, y)
		drawAtTile(tiles.verticalWire.sprite, 2, 2, x, y, tiles.verticalWire.yOffset, 1)
		drawAtTile(player.character.sprite, 0, 2, x, y)
		drawGreen(3, 2, x, y, tiles.stayButton.yOffset)

		drawAtTile(tiles.powerSupply.sprite, 11, 2, x, y)
		drawAtTile(tiles.stayButton.brickedSprite, 10, 2, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 9, 2, x, y, tiles.verticalWire.yOffset, 1)
		drawAtTile(player.character.sprite, 7, 2, x, y)

		--sticky button
		drawAtTile(tiles.stickyButton.upSprite, 3, 4, x, y, tiles.stickyButton.yOffset)
		drawAtTile(tiles.powerSupply.sprite, 4, 4, x, y)
		drawAtTile(tiles.verticalWire.sprite, 2, 4, x, y, tiles.verticalWire.yOffset, 1)
		drawAtTile(player.character.sprite, 0, 4, x, y)
		drawGreen(3, 4, x, y, tiles.stickyButton.yOffset)

		drawAtTile(tiles.powerSupply.sprite, 11, 4, x, y)
		drawAtTile(tiles.stickyButton.brickedSprite, 10, 4, x, y)
		drawAtTile(tiles.verticalWire.poweredSprite, 9, 4, x, y, tiles.verticalWire.yOffset, 1)
		drawAtTile(player.character.sprite, 7, 4, x, y)
	end,

	--mousetrap
	function(x, y, scale)
		--deadly mousetrap
		drawAtTile(tiles.mousetrap.deadlySprite, 3, 0, x, y, tiles.mousetrap.yOffset)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(3, 0, x, y, tiles.mousetrap.yOffset)

		drawAtTile(tiles.mousetrap.brickedSprite, 10, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)

		--safe mousetrap
		drawAtTile(tiles.mousetrap.safeSprite, 3, 4, x, y, tiles.mousetrap.yOffset)
		drawAtTile(player.character.sprite, 0, 4, x, y)
		drawGreen(3, 4, x, y, tiles.mousetrap.yOffset)

		drawAtTile(tiles.mousetrap.brickedSprite, 10, 4, x, y)
		drawAtTile(player.character.sprite, 7, 4, x, y)
	end,

	--stunning animals
	function(x, y, scale)
		--guard
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawAtTile(animalList.pitbull.sprite, 2, 0, x, y)
		drawGreen(2, 0, x, y)

		drawAtTile(player.character.sprite, 5, 0, x, y)
		drawAtTile(animalList.pitbull.sprite, 7, 0, x, y)
		drawHere(animalList.waitSprite, x + 7*tileWidth 
			+ util.getImage(animalList.pitbull.sprite):getWidth()/2 - util.getImage(animalList.waitSprite):getWidth()/2, 
			y + 0*tileHeight - util.getImage(animalList.waitSprite):getHeight())

		drawAtTile(player.character.sprite, 11, 0, x, y)
		drawAtTile(animalList.pitbull.sprite, 12, 0, x, y)

		--cat
		drawAtTile(player.character.sprite, 0, 2, x, y)
		drawAtTile(animalList.cat.sprite, 2, 2, x, y)
		drawGreen(2, 2, x, y)

		drawAtTile(player.character.sprite, 5, 2, x, y)
		drawAtTile(animalList.cat.sprite, 7, 2, x, y)
		drawHere(animalList.waitSprite, x + 7*tileWidth 
			+ util.getImage(animalList.cat.sprite):getWidth()/2 - util.getImage(animalList.waitSprite):getWidth()/2, 
			y + 2*tileHeight - util.getImage(animalList.waitSprite):getHeight())

		drawAtTile(player.character.sprite, 11, 2, x, y)
		drawAtTile(animalList.cat.sprite, 12, 2, x, y)

		--snail
		drawAtTile(player.character.sprite, 0, 4, x, y)
		drawAtTile(animalList.glueSnail.sprite, 2, 4, x, y)
		drawGreen(2, 4, x, y)

		drawAtTile(player.character.sprite, 5, 4, x, y)
		drawAtTile(animalList.glueSnail.sprite, 7, 4, x, y)
		drawHere(animalList.waitSprite, x + 7*tileWidth 
			+ util.getImage(animalList.glueSnail.sprite):getWidth()/2 - util.getImage(animalList.waitSprite):getWidth()/2, 
			y + 4*tileHeight - util.getImage(animalList.waitSprite):getHeight())

		drawAtTile(player.character.sprite, 11, 4, x, y)
		drawAtTile(animalList.glueSnail.sprite, 12, 4, x, y)
	end
}
P.gunScreens = {}
P.screens = {P.sawScreens, P.ladderScreens, P.wireCutterScreens, P.waterScreens, P.spongeScreens, P.brickScreens}--, P.gunScreens}

P.currentScreen = 1
P.screenLevel = 1

function P.draw()
	local screen = P.screens[P.currentScreen][P.screenLevel]
	drawHere(P.mainScreen, 0, 0)
	screen(30, 70, scale)
	drawHere(P.manuelTint, 40*P.currentScreen-18, 5)
	for i = 1, #(P.screens[P.currentScreen]) do
		if P.screenLevel == i then
			drawHere(P.tabBGSelected, 4, 40+26*i)
		else
			drawHere(P.tabBG, 4, 40+26*i)
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