local P = {}
tools = P

P.tool = Object:new{numHeld = 0, image=love.graphics.newImage("pen15.png")}

P.wireCutters = P.tool:new{image = love.graphics.newImage}

return tools