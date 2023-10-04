-- GD50 2023 - Pong

local push = require("push")

-- Actual window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Virtual resolution dimensions
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

-- Initialize LÖVE2D
function love.load()
	-- use nearest-neighbor filtering on upscaling and downscaling to prevent
	-- blurring of text and graphics
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- load small "retro" font
	local smallFont = love.graphics.newFont("font.ttf", 8)

	-- larger font for drawing the score on the screen
	local scoreFont = love.graphics.newFont("font.ttf", 32)

	-- set LÖVE2D's active font to the smallFont object
	love.graphics.setFont(smallFont)

	-- Set up screen with virtual resolution using push
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true,
	})

	-- initialize score variables
	P1_SCORE = 0
	P2_SCORE = 0

	-- paddle positions on the Y axis (they can only move up or down)
	P1_Y = 30
	P2_Y = VIRTUAL_HEIGHT - 50
end

-- Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
function love.draw()
	-- begin rendering at virtual resolution
	push:apply("start")

	-- clear the screen with a color similar to some versions of the original Pong
	love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

	-- print "Hello Pong!" at the middle of the screen
	love.graphics.printf("Hello Pong", 0, 20, VIRTUAL_WIDTH, "center")

	-- render first paddle
	love.graphics.rectangle("fill", 10, P1_Y, 5, 20)

	-- render second paddle
	love.graphics.rectangle("fill", VIRTUAL_WIDTH - 10, P2_Y, 5, 20)

	-- end rendering at virtual resolution
	push:apply("end")
end

-- runs every frame with `dt`, our delta in seconds since the last frame
function love.update(dt)
	-- Player 1 movement
	if love.keyboard.isDown("w") then
		P1_Y = P1_Y + -PADDLE_SPEED * dt
	elseif love.keyboard.isDown("s") then
		P1_Y = P1_Y + PADDLE_SPEED * dt
	end

	-- Player 2 movement
	if love.keyboard.isDown("up") then
		P2_Y = P2_Y + -PADDLE_SPEED * dt
	elseif love.keyboard.isDown("down") then
		P2_Y = P2_Y + PADDLE_SPEED * dt
	end
end

-- Add keyboard handling
function love.keypressed(key)
	-- keys can be accessed by string name
	if key == "escape" then
		-- function LÖVE gives us to terminate application
		love.event.quit()
	end
end
