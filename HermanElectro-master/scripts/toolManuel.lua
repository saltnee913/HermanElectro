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
	drawHere(image, x + tileX*tileWidth, y + tileY*tileHeight + yOffset, rotation)
end
local function drawGreen(tileX, tileY, x, y, yOffset)
	if yOffset == nil then yOffset = 0 end
	love.graphics.draw(util.getImage(green), (x+tileWidth*tileX)*scale.x, (y+tileHeight*tileY+yOffset)*scale.y, rotation, scale.x, scale.y*(16-yOffset)/16)
end

P.sawScreens = {
	function(x, y, scale)
		drawAtTile(tiles.wall.sprite, 1, 0, x, y, tiles.wall.yOffset)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y, tiles.wall.yOffset)

		drawAtTile(tiles.wall.destroyedSprite, 8, 0, x, y)
		drawAtTile(player.character.sprite, 7, 0, x, y)
	end,
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
	function(x, y, scale)
		drawAtTile(pushableList.box.sprite, 1, 0, x, y)
		drawAtTile(player.character.sprite, 0, 0, x, y)
		drawGreen(1, 0, x, y)

		drawAtTile(player.character.sprite, 7, 0, x, y)
	end
}

P.ladderScreens = {
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
		drawAtTile(player.character.sprite, 9, 4, x, y)
	end
}

P.wireCutterScreens = {
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
	end
}
P.waterScreens = {}
P.spongeScreens = {}
P.brickScreens = {}
P.gunScreens = {}
P.screens = {P.sawScreens, P.ladderScreens, P.wireCutterScreens}--, P.waterScreens, P.spongeScreens, P.brickScreens, P.gunScreens}

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