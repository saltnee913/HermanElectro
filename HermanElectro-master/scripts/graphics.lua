require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
graphics = P

function P.draw()
	myShader:send("shaderTriggered", shaderTriggered)
	--myShader:send("b_and_w", true)
	love.graphics.setBackgroundColor(0,0,0)
	if titlescreenCounter>0 then
		local sHeight = titlescreen:getHeight()
		local sWidth = titlescreen:getWidth()
		if sHeight/sWidth>height/width then
			love.graphics.draw(titlescreen, width/2-(height/titlescreen:getHeight())*sWidth/2, 0, 0, height/titlescreen:getHeight(), height/titlescreen:getHeight())
		else
			love.graphics.draw(titlescreen, 0, height/2-(width/titlescreen:getWidth())*sHeight/2, 0, width/titlescreen:getWidth(), width/titlescreen:getWidth())
		end
		return
	end

	--love.graphics.translate(width2/2-16*screenScale/2, height2/2-9*screenScale/2)
	--love.graphics.translate((width2-width)/2, (height2-height)/2)
	local bigRoomTranslation = getTranslation()
	love.graphics.translate(bigRoomTranslation.x*tileUnit*scale, bigRoomTranslation.y*tileUnit*scale)
	--love.graphics.draw(rocks, rocksQuad, 0, 0)
	--love.graphics.draw(rocks, -mapx * width, -mapy * height, 0, 1, 1)
	
	love.graphics.setShader(myShader)

	P.drawWallsAndFloor()

	for j = 1, roomHeight do
		for i = 1, roomLength do
			local isBlack=false
			
			if (room[j][i]~=nil or litTiles[j][i]==0) and not (litTiles[j][i]==1 and room[j][i]:instanceof(tiles.invisibleTile)) then
				if room[j][i]~=nil then room[j][i]:updateSprite() end
				local rot = 0
				local tempi = i
				local tempj = j
				if j <= table.getn(room) or i <= table.getn(room[0]) then
					if litTiles[j][i] == 0 then
						toDraw = black
						isBlack = true
					elseif room[j][i]~=nil and (room[j][i].poweredSprite==nil or room[j][i].powered == false or not room[j][i].canBePowered) then
						toDraw = util.getImage(room[j][i].sprite)
						rot = room[j][i].rotation
					elseif room[j][i]~=nil then
						toDraw = util.getImage(room[j][i].poweredSprite)
						rot = room[j][i].rotation
					--else
						--toDraw = floortile
					end
					if room[j][i]~=nil and room[j][i]:getYOffset()~=0 then rot = 0 end
					if rot == 1 or rot == 2 then
						tempi = tempi + 1
					end
					if rot == 2 or rot == 3 then
						tempj = tempj + 1
					end
				end
				if litTiles[j][i]==1 and room[j][i]~=nil and (not room[j][i].isVisible) and (not room[j][i]:instanceof(tiles.invisibleTile)) then
					toDraw = invisibleTile
				end
				if (room[j][i]~=nil and toDraw ~= invisibleTile --[[and room[j][i].name~="pitbull" and room[j][i].name~="cat" and room[j][i].name~="pup"]]) or litTiles[j][i]==0 then
					local addY = 0
					if room[j][i]~=nil and litTiles[j][i]~=0 then
						addY = room[j][i]:getYOffset()
					end
					if litTiles[j][i]==0 then addY = tiles.halfWall:getYOffset() end
					if not isBlack then
						love.graphics.draw(toDraw, (tempi-1)*tileWidth*scale+wallSprite.width, (addY+(tempj-1)*tileWidth)*scale+wallSprite.height,
					  	rot * math.pi / 2, scale*tileUnit/toDraw:getWidth(), scale*tileUnit/toDraw:getWidth())
					end
					if litTiles[j][i]~=0 and room[j][i].overlay ~= nil then
						local overlay = room[j][i].overlay
						local toDraw2 = overlay.powered and overlay.poweredSprite~=nil and util.getImage(overlay.poweredSprite) or util.getImage(overlay.sprite)
						local rot2 = overlay.rotation
						local tempi2 = i
						local tempj2 = j
						local addY2 = overlay:getYOffset() + addY
						--if addY2~=0 then rot2 = 0 end
						if rot2 == 1 or rot2 == 2 then
							tempi2 = tempi2 + 1
						end
						if rot2 == 2 or rot2 == 3 then
							tempj2 = tempj2 + 1
						end
						love.graphics.draw(toDraw2, (tempi2-1)*tileWidth*scale+wallSprite.width, (addY2+(tempj2-1)*tileWidth)*scale+wallSprite.height,
						  rot2 * math.pi / 2, scale*16/toDraw2:getWidth(), scale*16/toDraw2:getWidth())
						if overlay:instanceof(tiles.wire) and (room[j][i].dirSend[3] == 1 or room[j][i].dirAccept[3] == 1 or (overlay.dirWireHack ~= nil and overlay.dirWireHack[3] == 1)) then
							local toDraw3
							if room[j][i].powered and (room[j][i].dirSend[3] == 1 or room[j][i].dirAccept[3] == 1) then
								toDraw3 = util.getImage(room[j][i].overlay.wireHackOn)
							else
								toDraw3 = util.getImage(room[j][i].overlay.wireHackOff)
							end
							love.graphics.draw(toDraw3, (tempi-1)*tileWidth*scale+wallSprite.width, (addY+(tempj)*tileWidth)*scale+wallSprite.height,
							  0, scale*16/toDraw3:getWidth(), -1*addY/toDraw3:getHeight()*(scale*16/toDraw3:getWidth()))
						end
					end
					if room[j][i]~=nil and room[j][i].blueHighlighted then
						local addY = 0
						local yScale = scale
						if room[j][i]~=nil and litTiles[j][i]~=0 then
							addY = room[j][i]:getYOffset()
							yScale = scale*(16-addY)/16
						else addY=0 end
						love.graphics.draw(blue, (i-1)*tileWidth*scale+wallSprite.width, (addY+(j-1)*tileHeight)*scale+wallSprite.height, 0, scale, yScale)
					end
					if room[j][i]~=nil and litTiles[j][i]==1 and room[j][i]:getInfoText()~=nil then
						love.graphics.setColor(0,0,0)
						love.graphics.setShader()
						love.graphics.print(room[j][i]:getInfoText(), (tempi-1)*tileWidth*scale+wallSprite.width, (tempj-1)*tileHeight*scale+wallSprite.height);
						love.graphics.setShader(myShader)			
						love.graphics.setColor(255,255,255)
					end
				end
			end
		end
		for j = 1, roomHeight do
			for i = 1, roomLength do
				local isBlack=false
			
				if (room[j][i]~=nil or litTiles[j][i]==0) and not (litTiles[j][i]==1 and room[j][i]:instanceof(tiles.invisibleTile)) then
					if room[j][i]~=nil then room[j][i]:updateSprite() end
					local rot = 0
					local tempi = i
					local tempj = j
					if j <= table.getn(room) or i <= table.getn(room[0]) then
						if litTiles[j][i] == 0 then
							toDraw = black
							isBlack = true
						elseif room[j][i]~=nil and (room[j][i].powered == false or not room[j][i].canBePowered) then
							toDraw = room[j][i].sprite
							rot = room[j][i].rotation
						elseif room[j][i]~=nil then
							toDraw = room[j][i].poweredSprite
							rot = room[j][i].rotation
						--else
							--toDraw = floortile
						end
						if room[j][i]~=nil and room[j][i]:getYOffset()~=0 then rot = 0 end
						if rot == 1 or rot == 2 then
							tempi = tempi + 1
						end
						if rot == 2 or rot == 3 then
							tempj = tempj + 1
						end
					end
					if litTiles[j][i]==1 and room[j][i]~=nil and (not room[j][i].isVisible) and (not room[j][i]:instanceof(tiles.invisibleTile)) then
						toDraw = invisibleTile
					end
					if (room[j][i]~=nil --[[and room[j][i].name~="pitbull" and room[j][i].nddddddddddwwame~="cat" and room[j][i].name~="pup"]]) or litTiles[j][i]==0 then
						local addY = 0
						if room[j][i]~=nil and litTiles[j][i]~=0 then
							addY = room[j][i]:getYOffset()
						end
						if litTiles[j][i]==0 then addY = tiles.halfWall:getYOffset() end
						if isBlack then
							love.graphics.draw(toDraw, (tempi-1)*tileWidth*scale+wallSprite.width-20, (addY+(tempj-1)*tileWidth)*scale+wallSprite.height-30,
						  	rot * math.pi / 2, scale*24/toDraw:getWidth(), scale*24/toDraw:getWidth())
						end
					end
				end
			end
		end

		for i = 1, #animals do
			if animals[i]~=nil and litTiles[animals[i].tileY][animals[i].tileX]==1 and not animals[i].pickedUp and animals[i].tileY==j then
				graphics.drawAnimal(animals[i])
			end
		end

		for i = 1, #pushables do
			if pushables[i]~=nil and not pushables[i].destroyed and litTiles[pushables[i].tileY][pushables[i].tileX]==1 and pushables[i].tileY==j and pushables[i].visible then
		    	graphics.drawPushable(pushables[i])
			end
		end

		local drawGreen = true
		for i = 1, #processes do
			if processes[i]:instanceof(processList.movePlayer) then
				drawGreen = false
			end
		end
		if love.keyboard.isDown("w") or love.keyboard.isDown("a") or love.keyboard.isDown("s") or love.keyboard.isDown("d") then
			drawGreen = false
		end
		if drawGreen then
			if tools.toolableAnimals~=nil then
				for dir = 1, 5 do
					if tools.toolableAnimals[dir]~=nil then
						for i = 1, #(tools.toolableAnimals[dir]) do
							local ty = tools.toolableAnimals[dir][i].tileY
							if ty==j then
								if dir == 1 or tools.toolableAnimals[1][1] == nil or not (tx == tools.toolableAnimals[1][1].tileX and ty == tools.toolableAnimals[1][1].tileY) then
									local animalScale = tools.toolableAnimals[dir][i].scale
									love.graphics.draw(util.getImage(green), tools.toolableAnimals[dir][i]:getDrawX(), tools.toolableAnimals[dir][i]:getDrawY(), 0, animalScale, animalScale)
								end
							end
						end
					end
				end
			end
			if tools.toolablePushables~=nil then
				for dir = 1, 5 do
					if tools.toolablePushables[dir]~=nil then
						for i = 1, #(tools.toolablePushables[dir]) do
							local tx = tools.toolablePushables[dir][i].tileX
							local ty = tools.toolablePushables[dir][i].tileY
							if ty==j then
								if dir == 1 or tools.toolablePushables[1][1] == nil or not (tx == tools.toolablePushables[1][1].tileX and ty == tools.toolablePushables[1][1].tileY) then
									love.graphics.draw(util.getImage(green), (tx-1)*tileWidth*scale+wallSprite.width, (ty-1)*tileHeight*scale+wallSprite.height, 0, scale, scale)
								end
							end
						end
					end
				end
			end
			if tools.toolableTiles~=nil then
				for dir = 1, 5 do
					for i = 1, #(tools.toolableTiles[dir]) do
						local tx = tools.toolableTiles[dir][i].x
						local ty = tools.toolableTiles[dir][i].y
						if ty==j then
							local addY = 0
							local yScale = scale
							if room[ty][tx]~=nil and litTiles[ty][tx]~=0 then
								addY = room[ty][tx]:getYOffset()
								yScale = scale*(16-addY)/16
							else addY=0 end
							if dir == 1 or tools.toolableTiles[1][1] == nil or not (tx == tools.toolableTiles[1][1].x and ty == tools.toolableTiles[1][1].y) then
								love.graphics.draw(util.getImage(green), (tx-1)*tileWidth*scale+wallSprite.width, (addY+(ty-1)*tileHeight)*scale+wallSprite.height, 0, scale, yScale)
							end
						end
					end
				end
			end
		end

		if player.tileY == j and not player.attributes.invisible then
			graphics.drawPlayer()
		end

		--draw clone stuff
		if player.character.name == "Nellie"
		or (player.character.name == "Giovanni" and player.character.shiftPos.x>0)
		or player.clonePos.x>0 then
			if player.clonePos.x>0 then
				if player.clonePos.y == j then
					local charSprite = util.getImage(player.character.sprite)
					local playerx = (player.clonePos.x-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
					local playery = (player.clonePos.y-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
					love.graphics.draw(charSprite, playerx-charSprite:getWidth()*player.character.scale/2, playery-charSprite:getHeight()*player.character.scale-player.clonePos.z*scale, 0, player.character.scale, player.character.scale)
				end
			elseif player.character.shiftPos~=nil and player.character.shiftPos.y == j then
				local charSprite2 = util.getImage(player.character.sprite2)
				local playerx = (player.character.shiftPos.x-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
				local playery = (player.character.shiftPos.y-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
				love.graphics.draw(charSprite2, playerx-charSprite2:getWidth()*player.character.scale/2, playery-charSprite2:getHeight()*player.character.scale-player.character.shiftPos.z*scale, 0, player.character.scale, player.character.scale)
			elseif player.character.catLoc~=nil and player.character.catLoc.y == j then
				local nonActiveSprite
				local playerx
				local playery
				if player.character.humanMode then
					nonActiveSprite = util.getImage(player.character.catSprite)
					playerx = (player.character.catLoc.x-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
					playery = (player.character.catLoc.y-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
				else
					nonActiveSprite = util.getImage(player.character.humanSprite)
					playerx = (player.character.humanLoc.x-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
					playery = (player.character.humanLoc.y-1)*scale*tileHeight+wallSprite.height+tileHeight/2*scale+10
				end

				love.graphics.draw(nonActiveSprite, playerx-nonActiveSprite:getWidth()*player.character.scale/2, playery-nonActiveSprite:getHeight()*player.character.scale-player.elevation*scale, 0, player.character.scale, player.character.scale)
			end
		end


		--love.graphics.draw(walls, 0, 0, 0, width/walls:getWidth(), height/walls:getHeight())
	end


	for k = 1, #spotlights do
		local sl = spotlights[k]
		if sl.active then
			love.graphics.draw(sl.sprite, sl.x, sl.y-6*scale, 0, scale, yScale)
		end
	end

	for i = 1, #processes do
		processes[i]:draw()
	end

	if floorTransition or gameTransition then return end
	love.graphics.setShader()

	P.drawUI()
	
	if player.dead then
		love.graphics.draw(deathscreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
	end
	if won then
		love.graphics.draw(winscreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
	end
	if gamePaused then
		if toolManuel.opened then
			toolManuel.draw()
		else
			--love.graphics.draw(pausescreen, width/2-width/2000*320, 10, 0, width/1000, width/1000)
			love.graphics.draw(pausescreen, 0, 0, 0, width/pausescreen:getWidth(), height/pausescreen:getHeight())
		end
	end

	if editorMode then
		editor.draw()
	end
	if debugText ~= nil then
		text.print(debugText, 0, 100, {255,140,0,255}, nil, 22)
	end
end


function P.drawUI()
	if tools.toolDisplayTimer.timeLeft > 0 or player.luckTimer>0 then
		if player.luckTimer<tools.toolDisplayTimer.timeLeft then
			local toolWidth = util.getImage(tools[1].image):getWidth()
			local charSprite = util.getImage(player.character.sprite)
			local toolScale = charSprite:getWidth() * player.character.scale/toolWidth
			for i = 1, #tools.toolsShown do
				local supertool = tools[tools.toolsShown[i]]
				love.graphics.draw(util.getImage(supertool:getDisplayImage()), (i-math.ceil(#tools.toolsShown)/2-1)*toolScale*toolWidth+player.x, player.y - charSprite:getHeight()*player.character.scale - util.getImage(tools[1].image):getHeight()*toolScale, 0, toolScale, toolScale)
				if tools.toolsShown[i] > tools.numNormalTools then --if tool is a supertool
					--love.graphics.setFont(fontFile)
					--love.graphics.print(supertool.name, width/2-180, 110)
					--love.graphics.print(supertool.description, width/2-180, 120)
				end
			end
		else
			luckWidth = luckImage:getWidth()
			luckScale = charSprite:getWidth() * player.character.scale/luckWidth
			love.graphics.draw(luckImage, -0.5*luckScale*luckWidth+player.x, player.y - charSprite:getHeight()*player.character.scale - luckImage:getHeight()*luckScale, 0, luckScale, luckScale)
		end
	end

	--everything after this will be drawn regardless of bigRoomTranslation (i.e., translation is undone in following line)
	local bigRoomTranslation = getTranslation()
	love.graphics.translate(-1*bigRoomTranslation.x*tileWidth*scale, -1*bigRoomTranslation.y*tileHeight*scale)


	local textToDisplay = text.generateTextDisplay()
	for i = 1, #textToDisplay do
		--text object = to
		local to = textToDisplay[i]
		local text = to.text
		love.graphics.setNewFont(fontFile, to.size)
		local orientation = to.orientation
		if orientation==nil then oriention = 'center' end

		--draw background thing
		--minus 5 to have space of 10 pixels around
		local bLen = text:len()*to.size+10
		local bHeight = to.size+10
		local bX = width/2-bLen/2-5
		local bY = to.y-5

		love.graphics.draw(textBackground, bX, bY, 0, bLen/textBackground:getWidth(), bHeight/textBackground:getHeight())
		
		--print actual text
		love.graphics.printf(text, to.x, to.y, to.width, orientation)
	end
	love.graphics.setNewFont(fontSize)

	if not loadTutorial then
		if math.floor(gameTime.timeLeft)==315 then
			love.graphics.setColor(0,150,0)
		end
		love.graphics.print(math.floor(gameTime.timeLeft), width/2-10, 20);
		love.graphics.setColor(0,0,0)
	end

	P.drawMap()

	if not editorMode --[[and floorIndex>=1]] then
		P.drawToolUI()
	end
	love.graphics.setColor(255,255,255)

	if messageInfo.text~=nil then
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle("fill", width/2-200, 100, 400, 100)
		love.graphics.setColor(0,0,0,255)
		love.graphics.print(messageInfo.text, width/2-180, 110)
		love.graphics.setColor(255,255,255,255)
	end
end

function P.drawToolUI()
	love.graphics.setNewFont(fontSize)
	if not (player.character.canHoldBasics~=nil and not player.character.canHoldBasics) then
		for i = 0, 6 do
			love.graphics.setColor(255,255,255)
			love.graphics.draw(toolWrapper, i*width/18, 0, 0, (width/18)/16, (width/18)/16)
			if tool == i+1 then
				love.graphics.setColor(50, 200, 50)
				love.graphics.rectangle("fill", i*width/18, 0, width/18, width/18)
			end
			--love.graphics.rectangle("fill", i*width/18, 0, width/18, width/18)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", i*width/18, 0, width/18, width/18)
			love.graphics.setColor(255,255,255)
			local image = util.getImage(tools[i+1].image)
			love.graphics.draw(image, i*width/18, 0, 0, (width/18)/image:getWidth(), (width/18)/image:getHeight())
			if tools[i+1].numHeld==0 then
				love.graphics.draw(gray, i*width/18, 0, 0, (width/18)/32, (width/18)/32)
			end
			love.graphics.setColor(0,0,0)
			love.graphics.print(tools[i+1].numHeld, i*width/18+3, 0)
			love.graphics.print(i+1, i*width/18+7, (width/18)-20)
			love.graphics.circle("line", i*width/18+10, (width/18)-15, 9, 50)
		end
	end
	for i = 0, 2 do
		love.graphics.setColor(255,255,255)
		love.graphics.draw(toolWrapper, (i+13)*width/18, 0, 0, (width/18)/16, (width/18)/16)
		if tool == specialTools[i+1] and tool~=0 then
			love.graphics.setColor(50, 200, 50)
			love.graphics.rectangle("fill", (i+13)*width/18, 0, width/18, width/18)
		end
		--love.graphics.rectangle("fill", (i+13)*width/18, 0, width/18, width/18)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line", (i+13)*width/18, 0, width/18, width/18)
		love.graphics.setColor(255,255,255)
		if specialTools~=nil and specialTools[i+1]~=0 then
			local toolImage = util.getImage(tools[specialTools[i+1]].image)
			local tiWidth = toolImage:getWidth()
			local tiHeight = toolImage:getHeight()
			love.graphics.draw(toolImage, (i+13)*width/18, 0, 0, (width/18)/tiWidth, (width/18)/tiHeight)
		end
		if specialTools[i+1]==0 then
			love.graphics.draw(gray, (i+13)*width/18, 0, 0, (width/18)/32, (width/18)/32)
		end
		love.graphics.setColor(0,0,0)
		if specialTools[i+1]~=0 then
			if not tools[specialTools[i+1]].infiniteUses then
				love.graphics.print(tools[specialTools[i+1]].numHeld, (i+13)*width/18+3, 0)
			end
			love.graphics.print((i+8)%10, (i+13)*width/18+7, (width/18)-20)
			love.graphics.circle("line", (i+13)*width/18+10, (width/18)-15, 9, 50)
		end
	end
end

function P.drawMap()
	--draw minimap
	for i = 0, mapHeight do
		for j = 0, mapHeight do
			if visibleMap[i][j]>0 then
				if mainMap[i][j]==nil then
					love.graphics.setColor(0, 0, 0)
				else
					currentid = tostring(mainMap[i][j].roomid)
					if (i == mapy and j == mapx) then
						love.graphics.setColor(0,255,0)
					elseif completedRooms[i][j]>0 then
						love.graphics.setColor(255,255,255)
						if map.getFieldForRoom(currentid, 'minimapColor') ~= nil then
							love.graphics.setColor(map.getFieldForRoom(currentid, 'minimapColor'))
						end
					else
						love.graphics.setColor(100,100,100)
					end
				end
				local minimapScale = 8/mapHeight
				love.graphics.rectangle("fill", width - minimapScale*18*(mapHeight-j+1), minimapScale*9*i, minimapScale*18, minimapScale*9 )
				if player.character.name == "Francisco" and
				i==player.character.nextRoom.yLoc and j==player.character.nextRoom.xLoc then
					love.graphics.setColor(255, 0, 0)
					love.graphics.rectangle("fill", width - minimapScale*18*(mapHeight-j+1), minimapScale*9*i, minimapScale*9, minimapScale*4 )
				end
			else
				--love.graphics.setColor(255,255,255)
				--love.graphics.rectangle("line", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			end
		end
	end
end

function P.drawPlayer()
	local charSprite = util.getImage(player.character.sprite)
	love.graphics.draw(charSprite, math.floor(player.x-charSprite:getWidth()*player.character.scale/2), math.floor(player.y-charSprite:getHeight()*player.character.scale-player.elevation*scale), 0, player.character.scale, player.character.scale)
	love.graphics.setShader()
	love.graphics.print(player.character:getInfoText(), math.floor(player.x-charSprite:getWidth()*player.character.scale/2), math.floor(player.y-charSprite:getHeight()*player.character.scale));
	love.graphics.setShader(myShader)
end

function P.drawAnimal(animal)
	local animalSprite = util.getImage(animal.sprite)
	local drawCoords = animal:getDrawCoords()
	local drawx = drawCoords.x
	local drawy = drawCoords.y
	
	love.graphics.draw(animalSprite, drawx, drawy, 0, animal.scale, animal.scale)

	--overhead marks for animals, frozen or waitCounter or trained 
	if (not animal.dead) and (animal.frozen or animal.waitCounter>0 or animal.trained) then
		local markSprites = {}
		if animal.frozen then
			markSprites[#markSprites+1] = util.getImage('Graphics/frozenMark.png')
		end
		if animal.waitCounter>0 then
			for i = 1, animal.waitCounter do
				markSprites[#markSprites+1] = util.getImage('Graphics/waitCounterMark.png')
			end
		end
		if animal.trained then
			markSprites[#markSprites+1] = util.getImage('Graphics/trainedMark.png')
		end

		local markScale = scale
		
		for j = 1, #markSprites do
			local markSprite = markSprites[j]
			local markx = animal.x
			markx = markx-#markSprites/2*markScale*markSprite:getWidth()+markScale*(j-1)*markSprite:getWidth()
			local marky = drawy
			marky = marky-markSprite:getHeight()*markScale

			love.graphics.draw(markSprite, markx, marky, 0, markScale, markScale)
		end
	end
end

function P.drawPushable(pushable)
	if pushable.conductive and pushable.powered then toDraw = util.getImage(pushable.poweredSprite)
	else toDraw = util.getImage(pushable.sprite) end
	love.graphics.draw(toDraw, pushable.x, pushable.y, 0, scale, scale)
end

function P.drawWallsAndFloor()
	local toDrawFloor = nil

	if floorIndex<=1 then
		toDrawFloor = dungeonFloor
	else
		toDrawFloor = floortiles[floorIndex-1][1]
	end
	fto = map.getFieldForRoom(mainMap[mapy][mapx].roomid, "floorTileOverride")
	if (fto~=nil) then
		if fto=="dungeon" then
			toDrawFloor = dungeonFloor
		elseif fto=="heaven" then
			toDrawFloor = white
		end
	end

	if validSpace() then
		local testRooms = {{-1,0}, {1,0}, {0,-1}, {0,1}}
		for k = 1, #testRooms do
			local drawFloorPath = true
			local xdiff = testRooms[k][1]
			local ydiff = testRooms[k][2]
			if not (mapx+xdiff<=#completedRooms[mapy] and mapx+xdiff>0 and mapy+ydiff<=#completedRooms and mapy+ydiff>0) then
				drawFloorPath = false
			elseif mainMap[mapy+ydiff][mapx+xdiff]==nil then
				drawFloorPath = false
			elseif completedRooms[mapy][mapx]<1 and completedRooms[mapy+ydiff][mapx+xdiff]<1 then
				drawFloorPath = false
			elseif visibleMap[mapy+ydiff][mapx+xdiff]<1 then
				drawFloorPath = false
			end

			toDrawFloor = dungeonFloor

			if drawFloorPath then
				if xdiff==1 and ydiff==0 then
					love.graphics.draw(toDrawFloor, (roomLength+1)*tileWidth*scale+wallSprite.width, (math.floor(roomHeight/2))*tileHeight*scale+wallSprite.height, math.pi/2, scale, scale)
					love.graphics.draw(toDrawFloor, (roomLength+1)*tileWidth*scale+wallSprite.width, (math.floor(roomHeight/2)-1)*tileHeight*scale+wallSprite.height, math.pi/2, scale, scale)
				elseif xdiff==-1 and ydiff==0 then
					love.graphics.draw(toDrawFloor, (0)*tileWidth*scale+wallSprite.width, (math.floor(roomHeight/2))*tileHeight*scale+wallSprite.height, math.pi/2, scale, scale)
					love.graphics.draw(toDrawFloor, (0)*tileWidth*scale+wallSprite.width, (math.floor(roomHeight/2)-1)*tileHeight*scale+wallSprite.height, math.pi/2, scale, scale)
				elseif xdiff==0 and ydiff==1 then
					love.graphics.draw(toDrawFloor, (math.floor(roomLength/2)-1)*tileWidth*scale+wallSprite.width, (roomHeight)*tileHeight*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
					love.graphics.draw(toDrawFloor, (math.floor(roomLength/2))*tileWidth*scale+wallSprite.width, (roomHeight)*tileHeight*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
				elseif xdiff==0 and ydiff==-1 then
					love.graphics.draw(toDrawFloor, (math.floor(roomLength/2)-1)*tileWidth*scale+wallSprite.width, (-1)*tileHeight*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
					love.graphics.draw(toDrawFloor, (math.floor(roomLength/2))*tileWidth*scale+wallSprite.width, (-1)*tileHeight*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
				end
			end
		end
	end
	--[[love.graphics.setShader()
	for i = 1, roomLength do
		if not (i==math.floor(roomLength/2) or i==math.floor(roomLength/2)+1) then
			love.graphics.draw(topwall, (i-1)*tileWidth*scale+wallSprite.width, (yOffset+(-1)*tileHeight)*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
		else
			if mapy<=0 or mainMap[mapy-1][mapx]==nil or (completedRooms[mapy][mapx]==0 and completedRooms[mapy-1][mapx]==0) then
				love.graphics.draw(topwall, (i-1)*tileWidth*scale+wallSprite.width, (yOffset+(-1)*tileHeight)*scale+wallSprite.height, 0, scale*16/topwall:getWidth(), scale*16/topwall:getWidth())
			end	
		end
	end]]

	if floors[floorIndex-1]~=nil and fto==nil then
		--17 pixels from left/right/bottom, 33 from top
		local floorSprite = floors[floorIndex-1]

		local xScale = scale*16*roomLength/(floorSprite:getWidth()-34)
		local yScale = scale*16*roomHeight/(floorSprite:getHeight()-50)

		love.graphics.draw(floorSprite, wallSprite.width-17*scale, wallSprite.height-33*scale,
		0, xScale, yScale)
	end
	if (floors[floorIndex-1]==nil or editorMode or fto~=nil) then
		for i = 1, roomLength do
			for j = 1, roomHeight do
				if floorIndex<=1 then
					toDrawFloor = dungeonFloor
				else
					if (i*i*i+j*j)%3==0 then
						toDrawFloor = floortiles[floorIndex-1][1]
					elseif (i*i*i+j*j)%3==1 then
						toDrawFloor = floortiles[floorIndex-1][2]
					else
						toDrawFloor = floortiles[floorIndex-1][3]
					end
					if (i*i+j*j*j-1)%27==0 then
						--toDrawFloor = secondaryTiles[floorIndex-1][1]
					elseif (i*i+j*j*j-1)%29==1 then
						--toDrawFloor = secondaryTiles[floorIndex-1][2]
					elseif (i*i+j*j*j-1)%31==2 then
						--toDrawFloor = secondaryTiles[floorIndex-1][3]
					end
				end
				fto = map.getFieldForRoom(mainMap[mapy][mapx].roomid, "floorTileOverride")
				if (fto~=nil) then
					if fto=="dungeon" then
						toDrawFloor = dungeonFloor
					elseif fto=="heaven" then
						toDrawFloor = white
					end
				end


				love.graphics.draw(toDrawFloor, (i-1)*tileWidth*scale+wallSprite.width, (j-1)*tileHeight*scale+wallSprite.height,
				0, scale*16/toDrawFloor:getWidth(), scale*16/toDrawFloor:getWidth())
			end
		end
	end
end

return graphics