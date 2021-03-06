local P = {}
editor = P
tools = require('scripts.tools')

P.stealInput = false

function P.draw()
	barLength = 660
	love.graphics.setColor(255,255,255)
	for i = 1, 90 do
		if tiles[i]~=nil then
			toDraw = tiles[i].sprite
			addx = 0
			addy = 0
			if i>45 then
				addx = -width
				addy = width/45
			end
			--love.graphics.rectangle("fill", (i-1)*width/25, height-width/25, width/25, width/25)
			--sprite width: floor.sprite:getWidth()
			love.graphics.draw(toDraw, (i-1)*width/45+addx, height-2*width/45+addy, 0, (width/45)/(floor.sprite:getWidth()), (width/45)/(floor.sprite:getWidth()))
			if editorAdd == i then
				love.graphics.draw(green, (i-1)*width/45+addx, height-2*width/45+addy, 0, (width/45)/(floor.sprite:getWidth()), (width/45)/(floor.sprite:getWidth()))
			end
		end
	end
end

function P.keypressed(key, unicode)
	if key=="p" then
		print("[")
		for i = 1, roomHeight do
			prt = "["
			for j =1, roomLength do
				if room[i][j]~=nil then
					for k = 1, #tiles do
						if tiles[k]~=nil and room[i][j]~=nil and tiles[k].name == room[i][j].name then
							addk = k
							if k == 1 then
								addk=0
							end
							prt = prt..addk
							if(room[i][j].rotation ~= 0) then
								prt = prt..'.'..room[i][j].rotation
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
		print("]")
	end
	if key=='tab' then
		roomHack = mainMap[mapy][mapx].roomid .. ''
		P.stealInput = true
		log('Room Hack: '..roomHack)
	end
	if key == 'r' then
		for i = 1, roomHeight do
    		for j = 1, roomLength do
    			room[i][j] = nil
    		end
    	end
    	animals = {}
    	animalCounter = 1
    end
	if key == "z" and prevRoom~=nil then
    	room = prevRoom
    	animals = prevAnimals
    	animalCounter = 1
    	for i = 1, 100 do
    		if animals[i]~=nil then
    			animalCounter = animalCounter+1
    		end
    	end
    	--print(room[1][1].name)
	elseif key == "f" then
		for i = 1, 7 do
			tools[i].numHeld = tools[i].numHeld+1
		end
		--[[for i = 1, 3 do
			tools[i+7].numHeld = tools[i+7].numHeld+1
		end]]
	end
end

function P.inputSteal(key, unicode)
	if key=='backspace' then
		roomHack = roomHack:sub(1, -2)
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
	for i = 1, animalCounter - 1 do
		prevAnimals[i] = animals[i]
	end



	if button == 'l' or button == 1 then
		tempAdd = editorAdd
	elseif button == 'r' or button == 2 then
		tempAdd = 1
	end
	if mouseY>height-2*width/45 then
		editorAdd = math.floor(mouseX/(width/45))+1
		if mouseY>height-width/45 then
			editorAdd = editorAdd+45
		end
	elseif tempAdd>0 and tileLocX>=1 and tileLocX<=24 and tileLocY>=1 and tileLocY<=12 then
		if(room[tileLocY][tileLocX] ~= nil and room[tileLocY][tileLocX].name == tiles[tempAdd].name) then
			room[tileLocY][tileLocX]:rotate(1)
		else
			room[tileLocY][tileLocX] = tiles[tempAdd]:new()
		end
		for i = 1, animalCounter-1 do
			if animals[i]~=nil and animals[i].tileX == tileLocX and animals[i].tileY == tileLocY then
				animals[i] = nil
				for j = i+1, animalCounter do
					animals[j-1] = animals[j]
				end
				animalCounter = animalCounter-1
			end
		end
		if tiles[tempAdd].animal~=nil then
			animalToSpawn = room[tileLocY][tileLocX].animal
			if not animalToSpawn.dead then
				animals[animalCounter] = animalList[tiles[tempAdd].listIndex]:new()
				animals[animalCounter].y = (tileLocY-1)*floor.sprite:getWidth()*scale+wallSprite.height
				animals[animalCounter].x = (tileLocX-1)*floor.sprite:getHeight()*scale+wallSprite.width
				animals[animalCounter].tileX = tileLocX
				animals[animalCounter].tileY = tileLocY
				animalCounter = animalCounter+1
			end
		end
		
		updateGameState()
	end
end

function P.mousemoved(x, y, dx, dy)
	if mouseDown > 0 and tempAdd>0 and tileLocX>=1 and tileLocX<=24 and tileLocY>=1 and tileLocY<=12 then
		room[tileLocY][tileLocX] = tiles[tempAdd]:new()
		
		updateGameState()
	end
end

return editor