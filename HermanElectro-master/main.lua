

debug = true

rooms = {}
rooms[0] = {}

wallSprite = {width = 78, height = 72, heightForHitbox = 62}

require('scripts.tiles')

function generateMap(height, numRooms, seed)
	mapx = 4
	mapy = 4
	map = {}
	for i = 0, height+1 do
		map[i] = {}
	end
	map[height/2][height/2] = {roomid = 0, isFinal = false, isInitial = false}
	for i = 0, numRooms-1 do
		available = {}
		a = 0
		for j = 1, height do
			for k = 1, height do
				if map[j][k]==nil then
					--numNil = map[j+1][k] ~= nil and 1 or 0 + map[j-1][k] ~= nil and 1 or 0 + map[j][k+1] ~= nil and 1 or 0 + map[j][k-1] ~= nil and 1 or 0
					e = map[j+1][k]
					b = map[j-1][k]
					c = map[j][k+1]
					d = map[j][k-1]
					numNil = 0;
					if (e==nil) then
						numNil=numNil+1
					end
					if (b==nil) then
						numNil=numNil+1
					end
					if (c==nil) then
						numNil=numNil+1
					end
					if (d==nil) then
						numNil=numNil+1
					end
					if (numNil == 3) then
						available[a] = {x=j,y=k}
						a=a+1
					end
				end
			end
		end
		
		--math.randomseed(seed)
		math.randomseed(seed)
		numRooms=0
		choice = available[math.floor(math.random()*a)]
		--roomNum = math.floor(math.random()*table.getn(rooms)) -- what we will actually do, with some editing
		roomNum = i+1 -- for testing purposes
		map[choice.x][choice.y] = {roomid = roomNum, isFinal = false, isInitial = false}
	end
	for i = 0, height do
		p = ''
		for j = 0, height do
			if map[i][j] == nil then
				p = p .. '- '
			else
				p = p .. map[i][j].roomid .. ' '
			end
		end
		print(p)
	end
	--make a fucking crawler ben most
end

function love.load()
	mapHeight = 8
	generateMap(mapHeight, 20, os.time())
	width, height = love.graphics.getDimensions()
	player = { x = 400, y = 400, width = 20, height = 20, speed = 250, sprite = love.graphics.newImage('herman_sketch.png'), roomid = 0, scale = 0.3 }
	--image = love.graphics.newImage("cake.jpg")
	love.graphics.setNewFont(12)
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(255,255,255)
	f1 = love.graphics.newImage('concretewalls.png')
	walls = love.graphics.newImage('walls2.png')
	--print(love.graphics.getWidth(f1))
	scale = (width - 2*wallSprite.width)/(20 * 16)
	floor = Tile
	rooms[0][0] = {}
	rooms[0][1] = {}
	rooms[0][2] = {}
	for i = 0, 20 do
		rooms[i] = {}
		rooms[i].roomid = i
		for j = 0, 10 do
			rooms[i][j] = {}
		end
	end
	for roomNum = 0, 20 do
		for i = 0, 10 do
			for j = 0, 20 do
				rooms[roomNum][i][j] = Tile
			end
		end
		rooms[roomNum][0][roomNum] = ConductiveTile
	end
	room = rooms[0]
	function player:getTileLoc()
		return {x = self.x/(floor.sprite:getWidth()*scale), y = self.y/(floor.sprite:getWidth()*scale)}
	end
end

function love.draw()
	for i = 0, (width-wallSprite.width*2)/(floor.sprite:getWidth()*scale) do
		for j = 0, (height-wallSprite.height*2)/(floor.sprite:getHeight()*scale) do
			if j > table.getn(room) or i > table.getn(room[0]) then
				toDraw = f1
			else
				toDraw = room[j][i].sprite
			end
			love.graphics.draw(toDraw, i*floor.sprite:getWidth()*scale+wallSprite.width, j*floor.sprite:getHeight()*scale+wallSprite.height, 0, scale, scale)
		end
	end
	love.graphics.draw(walls, 0, 0, 0, width/walls:getWidth(), height/walls:getHeight())
	love.graphics.draw(player.sprite, player.x-player.sprite:getWidth()*player.scale/2, player.y-player.sprite:getHeight()*player.scale, 0, player.scale, player.scale)
	love.graphics.print(player:getTileLoc().x .. ":" .. player:getTileLoc().y, 0, 0);
	for i = 0, mapHeight do
		for j = 0, mapHeight do
			if map[i][j] == nil then
				love.graphics.setColor(255,255,255)
				love.graphics.rectangle("line", width - 18*(mapHeight-j), 9*i, 18, 9 )
			else
				if (map[i][j].roomid == room.roomid) then
					love.graphics.setColor(0,255,0)
				else
					love.graphics.setColor(255,255,255)
				end
				love.graphics.rectangle("fill", width - 18*(mapHeight-j), 9*i, 18, 9 )
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

function enterRoom(dir)
	if dir== 0 then
		if mapy>0 then
			if isNotNil(map[mapy-1][mapx]) then
				mapy = mapy-1
				newRoomNum = map[mapy][mapx].roomid
				room = rooms[newRoomNum]
				player.y = height-wallSprite.heightForHitbox-5
			end
		end
	elseif dir == 1 then
		if mapx<mapHeight-1 then
			if isNotNil(map[mapy][mapx+1]) then
				mapx = mapx+1
				newRoomNum = map[mapy][mapx].roomid
				room = rooms[newRoomNum]
				player.x = wallSprite.width+5
			end
		end
	elseif dir == 2 then
		if mapy<mapHeight then
			if isNotNil(map[mapy+1][mapx]) then
				mapy = mapy+1
				newRoomNum = map[mapy][mapx].roomid
				room = rooms[newRoomNum]
				player.y = wallSprite.heightForHitbox+player.height+5
			end
		end
	elseif dir == 3 then
		if mapx>0 then
			if isNotNil(map[mapy][mapx-1]) then
				mapx = mapx-1
				newRoomNum = map[mapy][mapx].roomid
				room = rooms[newRoomNum]
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