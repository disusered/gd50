-- Pipe class

Pipe = Class({})

-- since we only want the image loaded once, not per instantiation, we define
-- it externally
local PIPE_IMAGE = love.graphics.newImage("pipe.png")

-- speed at which the pipe should scroll right to left
PIPE_SPEED = 60

-- dimensions of pipe image
PIPE_HEIGHT = 288
PIPE_WIDTH = 70

function Pipe:init(orientation, y)
	self.x = VIRTUAL_WIDTH
	self.y = y

	self.width = PIPE_IMAGE:getWidth()
	self.height = PIPE_HEIGHT

	self.orientation = orientation
end

function Pipe:render()
	love.graphics.draw(
		PIPE_IMAGE, -- image
		self.x, -- X axis
		(self.orientation == "top" and self.y + PIPE_HEIGHT or self.y), -- Y axis
		0, -- rotation
		1, -- X scale
		self.orientation == "top" and -1 or 1 -- Y scale
	)
end
