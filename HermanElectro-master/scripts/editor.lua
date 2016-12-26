local P = {}
editor = P
tools = require('scripts.tools')

P.stealInput = false

roomsDesigned = 0

function P.draw()
	barLength = 660
	love.graphics.setColor(255,255,255)
	for i = 1, 200 do
		if tiles[i]~=nil then
			toDraw = tiles[i].sprite
			addx = 0
			addy = -width/25
			if i>50 and i<=100 then
				addx = -width
				addy = -width/50
			elseif i>100 and i<=150 then
				addx = -2*width
				addy = 0
			elseif i>150 and i<200 then
				addx = -3*width
				addy = width/50
			end
			--love.graphics.rectangle("fill", (i-1)*width/25, height-width/25, width/25, width/25)
			--sprite width: floor.sprite:getWidth()
			love.graphics.draw(toDraw, (i-1)*width/50+addx, height-2*width/50+addy, 0, (width/50)/(floor.sprite:getWidth())*16/toDraw:getWidth(), (width/50)/(floor.sprite:getWidth())*16/toDraw:getWidth())
			if editorAdd == i then
				love.graphics.draw(green, (i-1)*width/50+addx, height-2*width/50+addy, 0, (width/50)/(floor.sprite:getWidth()), (width/50)/(floor.sprite:getWidth()))
			end
		end
	end
end

function P.keypressed(key, unicode)
	if key=="p" then
		savedRoom = {}
		for i = 1, roomHeight do
			savedRoom[i] = {}
			for j = 1, roomLength do
				savedRoom[i][j] = room[i][j]
			end
		end
		savedAnimals = {}
		for i = 1, #animals do
			savedAnimals[i] = animals[i]
		end
		print("\"name\":")
		print("{")
		print("\"layout\":")
		print("[")
		for i = 1, roomHeight do
			prt = "["
			for j =1, roomLength do
				if room[i][j]~=nil then
					for k = 1, #tiles do
						if tiles[k]~=nil and room[i][j]~=nil and tiles[k].name == room[i][j].name then
							if room[i][j].overlay ~= nil then
								prt=prt..'['
							end
							addk = k
							if k == 1 then
								addk=0
							end
							prt = prt..addk
							if(room[i][j].rotation ~= 0) then
								prt = prt..'.'..room[i][j].rotation
							end
							if room[i][j].overlay ~= nil then
								prt=prt..','
								for k = 1, #tiles do
									if room[i][j].overlay.name == tiles[k].name then
										prt=prt..k
									end
								end
								if(room[i][j].overlay.rotation ~= 0) then
									prt = prt..'.'..room[i][j].overlay.rotation
								end
								prt=prt..']'
							end
							break
						end
					end
				else
					prt = prt..0
				end
				if j ~= roomLength then
					prt = prt..","
				end
			end
			prt = prt.."]"
			print(prt)
		end
		print("],")
		print("\"itemsNeeded\":")
		print("[")
		print("[0,0,0,0,0,0,0]")
		print("]")
		print("},\n")
	end
	if key=='tab' then
		roomHack = mainMap[mapy][mapx].roomid .. ''
		P.stealInput = true
		log('Room Hack: '..roomHack)
	end
	if key == 'c' then
		for i = 1, roomHeight do
    		for j = 1, roomLength do
    			room[i][j] = nil
    		end
    	end
    	animals = {}
    	pushables = {}
    end
	if key == "z" and prevRoom~=nil then
    	room = prevRoom
    	if prevAnimals~=nil then
    		animals = prevAnimals
    	end
    	--print(room[1][1].name)
	elseif key == "f" then
		tools.giveTools({1,2,3,4,5,6,7})
	elseif key == "b" then
		roomsDesigned = roomsDesigned+1
		print("\n\n---End of Room "..roomsDesigned.."---\n\n")
	elseif key == "r" and savedRoom~=nil then
		room = savedRoom
    	animals = savedAnimals
    end
end

function P.inputSteal(key, unicode)
	if key=='backspace' then
		roomHack = roomHack:sub(1, -2)
		log('Room Hack: '..roomHack)
	end
	if key=='right' then
		roomHack = map.getNextRoom(roomHack)
		log('Room Hack: '..roomHack)
	end
	if key == 'left' then
		roomHack = map.getPrevRoom(roomHack)
		log('Room Hack: '..roomHack)
	end
	if key=='return' then
		P.stealInput = false
		if hackEnterRoom(roomHack) then
			log('Teleported to room: '..roomHack)
		else
			log('Could not find room: '..roomHack)
		end
		roomHack = nil
	end
end

function P.textinput(text)
	if roomHack~=nil then
		roomHack = roomHack .. text
		log('Room Hack: '..roomHack)
	end
end

local function postTileAddCleanup(tempAdd, tileLocY, tileLocX)
	for i = 1, #animals do
		if animals[i]~=nil and animals[i].tileX == tileLocX and animals[i].tileY == tileLocY then
			animals[i] = nil
			for j = i+1, #animals+1 do
				animals[j-1] = animals[j]
			end
		end
	end

	local pushableLen = #pushables
	for i = 1, pushableLen do
		if pushables[i]~=nil and pushables[i].tileX == tileLocX and pushables[i].tileY == tileLocY then
			pushables[i] = nil
			for j = i+1, pushableLen+1 do
				pushables[j-1] = pushables[j]
			end
		end
	end

	if tiles[tempAdd]~=nil and tiles[tempAdd].animal~=nil then
		local animalToSpawn = animalList[room[tileLocY][tileLocX].listIndex]:new()
		if not animalToSpawn.dead then
			animals[#animals+1] = animalToSpawn
			animalToSpawn.y = (tileLocY-1)*floor.sprite:getWidth()*scale+wallSprite.height
			animalToSpawn.x = (tileLocX-1)*floor.sprite:getHeight()*scale+wallSprite.width
			animalToSpawn.tileX = tileLocX
			animalToSpawn.tileY = tileLocY
			animalToSpawn.prevTileX = animals[#animals].tileX
			animalToSpawn.prevTileY = animals[#animals].tileY
			animalToSpawn.loaded = true
		end
	end

	if tiles[tempAdd]~=nil and tiles[tempAdd].pushable~=nil then
		pushables[#pushables+1] = pushableList[tiles[tempAdd].listIndex]:new()
		pushables[#pushables].tileX = tileLocX
		pushables[#pushables].tileY = tileLocY
		pushables[#pushables].prevTileX = pushables[#pushables].tileX
		pushables[#pushables].prevTileY = pushables[#pushables].tileY
	end
	
	updateGameState()
end

function P.mousepressed(x, y, button, istouch)
	--store information for undoing
	prevRoom = {}
	for i = 1, roomHeight do
		prevRoom[i] = {}
		for j = 1, roomLength do
			prevRoom[i][j] = room[i][j]
		end
	end
	prevAnimals = {}
	for i = 1, #animals do
		prevAnimals[i] = animals[i]
	end



	if button == 'l' or button == 1 then
		tempAdd = editorAdd
	elseif button == 'r' or button == 2 then
		tempAdd = 1
	end
	--tileLocX = math.ceil((x-wallSprite.width)/(scale*floor.sprite:getWidth()))-getTranslation().x
	--tileLocY = math.ceil((y-wallSprite.height)/(scale*floor.sprite:getHeight()))-getTranslation().y
	if mouseY>height-4*width/50 then
		editorAdd = math.floor(mouseX/(width/50))+1
		if mouseY>height-3*width/50 then
			editorAdd = editorAdd+50
		end
		if mouseY>height-2*width/50 then
			editorAdd = editorAdd+50
		end
		if mouseY>height-width/50 then
			editorAdd = editorAdd+50
		end
	elseif tempAdd>0 and tempAdd<=#tiles and tileLocX>=1 and tileLocX<=roomLength and tileLocY>=1 and tileLocY<=roomHeight then
		if(room[tileLocY]~=nil and room[tileLocY][tileLocX] ~= nil and room[tileLocY][tileLocX].name == tiles[tempAdd].name) then
			room[tileLocY][tileLocX]:rotate(1)
		else
			if tiles[tempAdd]~=nil then
				if room[tileLocY] ~= nil and room[tileLocY][tileLocX] ~= nil and room[tileLocY][tileLocX].overlayable and tiles[tempAdd].overlaying then
					if room[tileLocY][tileLocX].overlay ~= nil and room[tileLocY][tileLocX].overlay.name == tiles[tempAdd].name then
						room[tileLocY][tileLocX].overlay:rotate(1)
					else
						room[tileLocY][tileLocX]:setOverlay(tiles[tempAdd]:new())
					end
				else
					room[tileLocY][tileLocX] = tiles[tempAdd]:new()
				end
			end
			if tempAdd==1 then room[tileLocY][tileLocX]=nil end
			postTileAddCleanup(tempAdd, tileLocY, tileLocX)
		end
	end
end

function P.mousemoved(x, y, dx, dy)
	if mouseY>height-2*width/50 then return end
	if mouseDown and tempAdd>0 and tiles[tempAdd]~=nil and tileLocX>=1 and tileLocX<=roomLength and tileLocY>=1 and tileLocY<=roomHeight then
		if room[tileLocY] ~= nil and room[tileLocY][tileLocX] ~= nil and room[tileLocY][tileLocX].overlayable and tiles[tempAdd].overlaying then
			if not (room[tileLocY][tileLocX].overlay ~= nil and room[tileLocY][tileLocX].overlay.name == tiles[tempAdd].name) then
				room[tileLocY][tileLocX]:setOverlay(tiles[tempAdd]:new())
			end
		else
			room[tileLocY][tileLocX] = tiles[tempAdd]:new()
		end
		postTileAddCleanup(tempAdd, tileLocY, tileLocX)
	end
end

return editor