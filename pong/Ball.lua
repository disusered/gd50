-- ball abstraction as class

Ball = Class({})

-- The `init` function on our class is called just once, when the object
-- is first created.
function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.dx = math.random(2) == 1 and 100 or -100
	self.dy = math.random(-50, 50)
end

-- Place the ball in the middle of the screen with an initial random velocity
-- on both axes.
function Ball:reset()
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2
	self.dx = math.random(2) == 1 and -100 or 100
	self.dy = math.random(-50, 50) * 1.5
end

-- Apply velocity to position, scaled by deltaTime
function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

-- Render the ball
function Ball:render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
