-- paddle abstraction as class

Paddle = Class({})

-- The `init` function on our class is called just once, when the object
-- is first created.
function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.dy = 0
end

function Paddle:update(dt)
	-- math.max here ensures that we're the greater of 0 or the player's
	-- current calculated Y position when pressing up so that we don't
	-- go into the negatives; the movement calculation is simply our
	-- previously-defined paddle speed scaled by dt
	if self.dy < 0 then
		self.y = math.max(0, self.y + self.dy * dt)
	else
		-- similar to before, this time we use math.min to ensure we don't
		-- go any farther than the bottom of the screen minus the paddle's
		-- height (or else it will go partially below, since position is
		-- based on its top left corner)
		self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
	end
end

-- called by love.draw; we just want to see a rectangle on the screen
function Paddle:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
