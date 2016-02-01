require('scripts.object')

local P = {}
boundaries = P
P.Boundary = Object:new{x=0, y=0, width=0, height=0, isPlayer=false}

function P.Boundary:onCollide(bound)

end

function P.Boundary:isColliding(bound)
	if(bound.x < self.x + self.width and
		self.x < bound.x + bound.width and
		bound.y < self.y + self.height and
		self.y < bound.y + bound.height) then
		self:onCollide(bound)
		return true
	end
	return false
end

P.Door = Boundary:new{dir = 0}
function P.Door:onCollide(bound)
	if(bound.isPlayer) then
		bound.switchRooms(self.dir)
	end
end

return boundaries