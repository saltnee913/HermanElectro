local P = {}
editor = P
tools = require('scripts.tools')
editorTiles = require('scripts.editorTiles')

P.stealInput = false
P.tab = 1
--1 for basic tiles, 2 for animasl, 3 for boxes, 4 for advanced tiles

P.leftStartDist = 110
P.downStartDist = height-3.2*width/50
P.tabLength = 105
P.tabHeight = 20

roomsDesigned = 0

P.visionHack = false

P.setNames = {"Basic", "Animal", "Box", "Shop", "Advanced"}
local function getTileSet()
	if editor.tab==1 then
		return editorTiles.basicTiles
	elseif editor.tab==2 then
		return editorTiles.animalTiles
	elseif editor.tab==3 then
		return editorTiles.boxTiles
	elseif editor.tab==4 then
		return editorTiles.shopTiles
	elseif editor.tab==5 then
		return editorTiles.advancedTiles
	end
end

function P.draw()
	local tileSet = nil
	local setName = nil
	tileSet = getTileSet(editor.tab)

	--tile sets
	for i = 1, #P.setNames do
		if editor.tab==i then
			love.graphics.setColor(160,0,160)
		else
			love.graphics.setColor(50,0,50)
		end
		love.graphics.rectangle("fill", editor.leftStartDist+(i-1)*editor.tabLength, editor.downStartDist, editor.tabLength-5, editor.tabHeight)
		love.graphics.setColor(255,140,0)
		love.graphics.print(editor.setNames[i], editor.leftStartDist+(i-1)*editor.tabLength+5, editor.downStartDist+2);
	end

	--save and load
	love.graphics.setColor(50,0,50)
	love.graphics.rectangle("fill", width/2+editor.leftStartDist+2*tileUnit*scale, editor.downStartDist, editor.tabLength-5, editor.tabHeight)	
	love.graphics.rectangle("fill", width/2+editor.leftStartDist+2*tileUnit*scale+editor.tabLength, editor.downStartDist, editor.tabLength-5, editor.tabHeight)
	
	love.graphics.setColor(255,140,0)
	love.graphics.print("Save", width/2+editor.leftStartDist+2*tileUnit*scale+5, editor.downStartDist+2);
	love.graphics.print("Load", width/2+editor.leftStartDist+2*tileUnit*scale+5+editor.tabLength, editor.downStartDist+2);

	if nameEnter~=nil then
		local textAdd = ''
		if editor.stealInput and roomHack==nil then
			textAdd = "Enter name: "
		end
		--love.graphics.print(textAdd..nameEnter, width/2+editor.leftStartDist+2*tileUnit*scale+5+editor.tabLength+(editor.tabLength+5), editor.downStartDist+2);
	end

	love.graphics.setColor(255,255,255)
	
	for i = 1, #tileSet do
		toDraw = util.getImage(tileSet[i]:getEditorSprite())
		love.graphics.draw(toDraw, (i-1)*width/50+editor.leftStartDist, height-3.2*width/50+32, 0, (width/50)/(tileWidth)*16/toDraw:getWidth(), (width/50)/(tileWidth)*16/toDraw:getWidth())
		if tiles[editorAdd]~=nil and tiles[editorAdd].name==tileSet[i].name then
			love.graphics.draw(util.getImage(green), (i-1)*width/50+editor.leftStartDist, height-3.2*width/50+32, 0, (width/50)/(tileWidth)*16/toDraw:getWidth(), (width/50)/(tileWidth)*16/toDraw:getWidth())
		end
	end

	--[[for i = 1, 200 do
		if tiles[i]~=nil then
			toDraw = util.getImage(tiles[i].sprite)
			addx = 0
			addy = -width/25
			if i>50 and i<=100 then
				addx = -width
				addy = -width/50
			elseif i>100 and i<=150 then
				addx = -2*width
				addy = 0
			elseif i>150 and i<=200 then
				addx = -3*width
				addy = width/50
			end
			--love.graphics.rectangle("fill", (i-1)*width/25, height-width/25, width/25, width/25)
			--sprite width: floor.sprite:getWidth()
			--love.graphics.draw(toDraw, (i-1)*width/50+addx, height-2*width/50+addy, 0, (width/50)/(tileWidth)*16/toDraw:getWidth(), (width/50)/(tileWidth)*16/toDraw:getWidth())
			if editorAdd == i then
				love.graphics.draw(green, (i-1)*width/50+addx, height-2*width/50+addy, 0, (width/50)/(tileWidth), (width/50)/(tileWidth))
			end
		end
	end]]
end

function openRoomHack()
	if nameEnter~=nil then return end
	roomHack = mainMap[mapy][mapx].roomid .. ''
	P.stealInput = true
	log('Room Hack: '..roomHack)
end

function closeInputSteal()
	P.stealInput = false
	if nameEnter ~= nil then
		log('Saving Cancelled')
	else
		log('Room Hack Cancelled')
	end
	roomHack = nil
	nameEnter = nil
	args = nil
end

function printRoom()
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

function P.keypressed(key, unicode)
	if key=="p" then
		local tempRooms = {}
		if love.filesystem.exists(saveDir..'/tempRooms.json') then
			tempRooms = util.readJSON(saveDir .. '/tempRooms.json')
			if tempRooms == nil then
				tempRooms = {}
			end
		end
		local newRoom = {}
		newRoom.layout = {}
		savedRoom = {}
		for i = 1, roomHeight do
			newRoom.layout[i] = {}
			savedRoom[i] = {}
			for j = 1, roomLength do
				savedRoom[i][j] = room[i][j]
				if room[i][j] == nil then
					newRoom.layout[i][j] = 0
				else
					local tileWithRot = 0
					--find the tile id
					for k = 2, #tiles do
						if tiles[k].name == room[i][j].name then
							tileWithRot = k
						end
					end
					--add in the rotation of the tile
					if room[i][j].rotation ~= 0 then
						tileWithRot = tileWithRot + room[i][j].rotation/10
					end
	
					if room[i][j].overlay == nil then
						newRoom.layout[i][j] = tileWithRot
					else
						local overlayWithRot = 0
						for k = 2, #tiles do
							if tiles[k].name == room[i][j].overlay.name then
								overlayWithRot = k
							end
						end
						if room[i][j].overlay.rotation ~= 0 then
							overlayWithRot = overlayWithRot + room[i][j].overlay.rotation/10
						end
						newRoom.layout[i][j] = {tileWithRot,overlayWithRot}
					end

				end
			end
		end
		savedAnimals = {}
		for i = 1, #animals do
			savedAnimals[i] = animals[i]
		end
		newRoom.itemsNeeded = {}
		newRoom.itemsNeeded[1] = {0,0,0,0,0,0,0}
		tempRooms[#tempRooms+1] = {name = newRoom}
		local state = {indent = true}
		util.writeJSON('/tempRooms.json', tempRooms, state)
		local json = require('scripts.dkjson')
		local toPrint = json.encode({name = newRoom}, state)
		toPrint = toPrint:sub(3)
		toPrint = toPrint:sub(1,-3)
		toPrint = toPrint..","
		toPrint = "  \""..mainMap[mapy][mapx].roomid.."\""..toPrint:sub(10)
		print(toPrint)
	end
	if key=='tab' then
		openRoomHack()
	end
	if key == 'c' then
		for i = 1, roomHeight do
    		for j = 1, roomLength do
    			room[i][j] = nil
    		end
    	end
    	animals = {}
    	pushables = {}
    	spotlights = {}
    	bossList = {}
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
    elseif key == "l" then
		P.visionHack = not P.visionHack
	elseif key == "h" then win()
    elseif key == "=" then
    	--unlock everything
    	for i = 1, #unlocks do
    		if not unlocks[i].hidden then
    			unlocks.unlockUnlockable(i,true)
    		end
    	end
    elseif key == "-" then
   		--lock everything
     	for i = 1, #unlocks do
    		--if not unlocks[i].hidden then
    			unlocks.lockUnlockable(i)
    		--end
    	end
    	stats.statsData = {}
    	stats.writeStats()  		
    elseif key == "o" then
    	createElements()
    end
end

function P.inputSteal(key, unicode)
	if key=='escape' then
		closeInputSteal()
	end
	if roomHack~=nil then
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
	elseif nameEnter~=nil then
		if key=='backspace' then
			nameEnter = nameEnter:sub(1, -2)
			log('Enter name: '..nameEnter)
		end
		if key=='return' then
			editor.saveRoom()
		end
	end
end

function P.textinput(text)
	if roomHack~=nil then
		roomHack = roomHack .. text
		log('Room Hack: '..roomHack)
	elseif nameEnter~=nil then
		nameEnter = nameEnter .. text
		log('Enter name: '..nameEnter)
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
			animalToSpawn.y = (tileLocY-1)*tileWidth*scale+wallSprite.height
			animalToSpawn.x = (tileLocX-1)*tileHeight*scale+wallSprite.width
			animalToSpawn.tileX = tileLocX
			animalToSpawn.tileY = tileLocY
			animalToSpawn.prevTileX = animals[#animals].tileX
			animalToSpawn.prevTileY = animals[#animals].tileY
			animalToSpawn:setLoc()
			animalToSpawn.loaded = true
		end
	end

	if tiles[tempAdd]~=nil and tiles[tempAdd].pushable~=nil then
		pushables[#pushables+1] = pushableList[tiles[tempAdd].listIndex]:new()
		pushables[#pushables].tileX = tileLocX
		pushables[#pushables].tileY = tileLocY
		pushables[#pushables].y = (tileLocY-1)*tileWidth*scale+wallSprite.height
		pushables[#pushables].x = (tileLocX-1)*tileHeight*scale+wallSprite.width
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
	if mouseY>editor.downStartDist then
		if mouseY<=editor.downStartDist+editor.tabHeight then
			if mouseX<editor.leftStartDist or mouseX>width/2+editor.leftStartDist+2*tileUnit*scale+5+editor.tabLength*2 then
				return
			elseif mouseX>editor.leftStartDist+#P.setNames*editor.tabLength then
				--load
				if mouseX>width/2+editor.leftStartDist+editor.tabLength+2*tileUnit*scale+5 then
					if roomHack == nil then
						openRoomHack()
					else
						closeInputSteal()
					end
				elseif mouseX>width/2+editor.leftStartDist+2*tileUnit*scale+5 then
					if args==nil then
						if roomHack~=nil then return end
						local customRooms = {}
						if love.filesystem.exists(saveDir..'/customRooms.json') then
							customRooms = util.readJSON(saveDir .. '/customRooms.json')
							if customRooms == nil then
								customRooms = {}
							end
						end
						local newRoom = {}
						newRoom.layout = {}
						savedRoom = {}
						for i = 1, roomHeight do
							newRoom.layout[i] = {}
							savedRoom[i] = {}
							for j = 1, roomLength do
								savedRoom[i][j] = room[i][j]
								if room[i][j] == nil then
									newRoom.layout[i][j] = 0
								else
									local tileWithRot = 0
									--find the tile id
									for k = 2, #tiles do
										if tiles[k].name == room[i][j].name then
											tileWithRot = k
										end
									end
									--add in the rotation of the tile
									if room[i][j].rotation ~= 0 then
										tileWithRot = tileWithRot + room[i][j].rotation/10
									end
					
									if room[i][j].overlay == nil then
										newRoom.layout[i][j] = tileWithRot
									else
										local overlayWithRot = 0
										for k = 2, #tiles do
											if tiles[k].name == room[i][j].overlay.name then
												overlayWithRot = k
											end
										end
										if room[i][j].overlay.rotation ~= 0 then
											overlayWithRot = overlayWithRot + room[i][j].overlay.rotation/10
										end
										newRoom.layout[i][j] = {tileWithRot,overlayWithRot}
									end

								end
							end
						end
						savedAnimals = {}
						for i = 1, #animals do
							savedAnimals[i] = animals[i]
						end
						newRoom.itemsNeeded = {}
						newRoom.itemsNeeded[1] = {0,0,0,0,0,0,0}
						customRooms[#customRooms+1] = {name = newRoom}
						local state = {indent = true}
						local json = require('scripts.dkjson')
						local toPrint = json.encode({name = newRoom}, state)
						toPrint = toPrint:sub(3)
						toPrint = toPrint:sub(1,-3)
						toPrint = toPrint..","
						args = {'/customRooms.json', toPrint}
						nameEnter = ''
						log('Enter name: ')
						editor.stealInput = true
					else
						editor.saveRoom()
					end
				end
			else
				for i = 1, #P.setNames do
					if mouseX>editor.leftStartDist+(i-1)*editor.tabLength then
						editor.tab = i
					end
				end
			end
		elseif mouseY<=editor.downStartDist+editor.tabHeight+10+width/50 then
			local numTile = math.floor((mouseX-editor.leftStartDist)/(width/50))+1
			local tileSet = getTileSet()
			local tileToAdd = tileSet[numTile]
			if tileToAdd==nil then return end
			
			editorAdd = 0
			for i = 1, #tiles do
				if tiles[i].name==tileToAdd.name then
					editorAdd = i
					break
				end
			end
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

function P.saveRoom()
	unlocks.unlockUnlockableRef(unlocks.laptopUnlock)

	if map.createRoom(nameEnter)~=nil then
		log("Save failed -- name already taken (continue typing to insert a new name)")
		return
	end

	P.stealInput = false

	args[2] = '  "'..nameEnter..'":'..args[2]:sub(11)
	util.writeJSONCustom(args[1],args[2])
	log("Saved!")
	unlocks.unlockUnlockableRef(unlocks.laptopUnlock)
	local justNamed = nameEnter

	nameEnter = nil
	args = nil
	local roomsData, roomsArray = util.readJSON(saveDir..'/customRooms.json', true)
	map.floorInfo.rooms.customRooms = roomsData.rooms
	--add room to current list
	map.floorInfo.roomsArray[#(map.floorInfo.roomsArray)+1] = roomsArray[#roomsArray]

	hackEnterRoom(justNamed)
end

return editor