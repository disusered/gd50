-- GD50 Flappy Bird Remake

-- virtual resolution handling library
local push = require("push")

-- physical dimensions of the window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--virtual dimensions of the window
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- load images into memory
local background = love.graphics.newImage("background.png")
local ground = love.graphics.newImage("ground.png")

function love.load()
	-- initialize nearest-neighbor filter
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- app window title
	love.window.setTitle("Fifty Bird")

	-- initialize virtual resolution
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true,
	})
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.draw()
	push:start()

	-- draw the background starting at top left (0, 0)
	love.graphics.draw(background, 0, 0)

	-- draw the ground on top of the background, towards the bottom of the screen
	love.graphics.draw(ground, 0, VIRTUAL_HEIGHT - 16)

	push:finish()
end
