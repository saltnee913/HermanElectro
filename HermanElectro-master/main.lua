

debug = true

wallSprite = {width = 78, height = 72, heightForHitbox = 62}

require('scripts.tiles')
require('scripts.map')


function love.load()
	mapHeight = 8
	mainMap = map.generateMap(mapHeight, 20, os.time())
	map.loadRooms()
	room = map.rooms[0]
	width, height = love.graphics.getDimensions()
	player = { x = 400, y = 400, width = 20, height = 20, speed = 250, sprite = love.graphics.newImage('herman_sketch.png'), roomid = 0, scale = 0.3 }
	--image = love.graphics.newImage("cake.jpg")
	love.graphics.setNewFont(12)
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(255,255,255)
	f1 = love.graphics.newImage('concretewalls.png')
	walls = love.graphics.newImage('walls2.png')
	rocks = love.graphics.newImage('pen15.png')
	number1 = love.math.random()*-200
	number2 = love.math.random()*-200
	--print(love.graphics.getWidth(f1))
	scale = (width - 2*wallSprite.width)/(20 * 16)
	floor = tiles.tile
	function player:getTileLoc()
		return {x = self.x/(floor.sprite:getWidth()*scale), y = self.y/(floor.sprite:getWidth()*scale)}
	end
end

function love.draw()
	love.graphics.draw(rocks, -mapx * width, -mapy * height, 0, 1, 1)
	for i = 0, (width-wallSprite.width*2)/(floor.sprite:getWidth()*scale) do
		for j = 0, (height-wallSprite.height*2)/(floor.sprite:getHeight()*scale) do
			if j > table.getn(room) or i > table.getn(room[0]) then
				toDraw = f1
			else
				toDraw = room[j][i].sprite
			end
			--love.graphics.draw(toDraw, i*floor.sprite:getWidth()*scale+wallSprite.width, j*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
		end
	end
	love.graphics.draw(walls, 0, 0, 0, width/walls:getWidth(), height/walls:getHeight())
	love.graphics.draw(player.sprite, player.x-player.sprite:getWidth()*player.scale/2, player.y-player.sprite:getHeight()*player.scale, 0, player.scale, player.scale)
	love.graphics.print(player:getTileLoc().x .. ":" .. player:getTileLoc().y, 0, 0);
	for i = 0, mapHeight do
		for j = 0, mapHeight do
			if mainMap[i][j] == nil then
				love.graphics.setColor(255,255,255)
				love.graphics.rectangle("line", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			else
				if (i == mapy and j == mapx) then
					love.graphics.setColor(0,255,0)
				else
					love.graphics.setColor(255,255,255)
				end
				love.graphics.rectangle("fill", width - 18*(mapHeight-j+1), 9*i, 18, 9 )
			end
		end
	end
	love.graphics.setColor(255,255,255)
end

function isNotNil(a)
	if a==nil then
		return false;
	end
		return true;
end
mapx=4
mapy=4
function enterRoom(dir)
	if dir== 0 then
		if mapy>0 then
			if isNotNil(mainMap[mapy-1][mapx]) then
				mapy = mapy-1
				newRoomNum = mainMap[mapy][mapx].roomid
				room = map.rooms[newRoomNum]
				player.y = height-wallSprite.heightForHitbox-5
			end
		end
	elseif dir == 1 then
		if mapx<mapHeight then
			if isNotNil(mainMap[mapy][mapx+1]) then
				mapx = mapx+1
				newRoomNum = mainMap[mapy][mapx].roomid
				room = map.rooms[newRoomNum]
				player.x = wallSprite.width+5
			end
		end
	elseif dir == 2 then
		if mapy<mapHeight then
			if isNotNil(mainMap[mapy+1][mapx]) then
				mapy = mapy+1
				newRoomNum = mainMap[mapy][mapx].roomid
				room = map.rooms[newRoomNum]
				player.y = wallSprite.heightForHitbox+player.height+5
			end
		end
	elseif dir == 3 then
		if mapx>0 then
			if isNotNil(mainMap[mapy][mapx-1]) then
				mapx = mapx-1
				newRoomNum = mainMap[mapy][mapx].roomid
				room = map.rooms[newRoomNum]
				player.x = width-wallSprite.width-player.width-5
			end
		end
	end
end

function love.update(dt)
	if love.keyboard.isDown("up") then 
		if player.y == wallSprite.heightForHitbox+player.height and player.x < width/2+20 and player.x > width/2-40 then
			enterRoom(0)
		end
		player.y = player.y - player.speed * dt
	end
	if love.keyboard.isDown("down") then 
		if player.y == height - wallSprite.heightForHitbox and player.x < width/2+20 and player.x > width/2-40 then
			enterRoom(2)
		end
		player.y = player.y + player.speed * dt
	end
	if love.keyboard.isDown("left") then 
		if player.x == wallSprite.width and player.y < height/2+50 and player.y > height/2-20 then
			enterRoom(3)
		end
		player.x = player.x - player.speed * dt
		
	end
	if love.keyboard.isDown("right") then 
		if player.x == width-wallSprite.width-player.width and player.y < height/2+50 and player.y > height/2-20 then
			enterRoom(1)
		end
		player.x = player.x + player.speed * dt
	end
	if player.x < 0 then
		player.x = 0
	end
	if player.x < wallSprite.width then
		player.x = wallSprite.width
	end
	if player.y < wallSprite.heightForHitbox+player.height then
		player.y = wallSprite.heightForHitbox+player.height
	end
	if player.x > width-wallSprite.width-player.width then
		player.x = width-wallSprite.width-player.width
	end
	if player.y > height-wallSprite.heightForHitbox then
		player.y = height-wallSprite.heightForHitbox
	end
end