require('scripts.object')
--require('scripts.tiles')
--floor = tiles.tile

local P = {}
text = P

P.toolText = {}
P.textTimers = {toolTimer = 0}
P.baseTimes = {toolTimer = 2.1}

--returns list of text, 
function P.generateTextDisplay()
	return P.toolText
end

function P.setToolDisplay(tool)
	if tool==nil then
		P.toolText = {}
		return
	end
	P.textTimers.toolTimer = 0
	P.toolText[1] = {text = tool.name, size = 40, orientation = 'center', x = 0, width = width, y = 100}
	P.toolText[2] = {text = tool.description, size = 27, orientation = 'center', x = 0, width = width, y = 200}
end

function P.updateTextTimers(dt)
	P.textTimers.toolTimer = P.textTimers.toolTimer+dt
	if P.textTimers.toolTimer>P.baseTimes.toolTimer then
		P.textTimers.toolTimer = 0
		P.setToolDisplay(nil)
	end
end

local function setFont(font,fontSize)
	if font ~= nil then
		love.graphics.setNewFont(font, fontSize)
	elseif fontSize ~= nil then
		love.graphics.setNewFont(fontSize)
	end
end

function P.print(message,x,y,color,font,fontSize)
	if color == nil then color = {0,0,0} end
	setFont(font,fontSize)
	love.graphics.setColor(color[1],color[2],color[3],color[4])
	love.graphics.print(message,x,y)
	love.graphics.setColor(255,255,255,255)
	setFont(nil,fontSize)
end

return text