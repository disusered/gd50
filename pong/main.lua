-- GD50 2023 - Pong

local push = require("push")

-- Actual window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Virtual resolution dimensions
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Initialize LÖVE2D
function love.load()
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true,
	})
end

-- Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
function love.draw()
	-- begin rendering at virtual resolution
	push:apply("start")

	-- print "Hello Pong!" at the middle of the screen
	love.graphics.printf(
		"Hello Pong", -- text to render
		0, -- starting X (0 since we're going to center it based on width)
		VIRTUAL_HEIGHT / 2 - 6, -- starting Y (halfway down the virtual screen)
		VIRTUAL_WIDTH, -- number of pixels to center within (the entire virtual screen here)
		"center" -- alignment mode, can be 'center', 'left', or 'right'
	)

	-- end rendering at virtual resolution
	push:apply("end")
end
