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

	-- seed the rng
	math.randomseed(os.time())

	-- load small "retro" font
	SmallFont = love.graphics.newFont("font.ttf", 8)

	-- larger font for drawing the score on the screen
	ScoreFont = love.graphics.newFont("font.ttf", 32)

	-- set LÖVE2D's active font to the smallFont object
	love.graphics.setFont(SmallFont)

	-- Set up screen with virtual resolution using push
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true,
	})

	-- initialize score variables
	P1Score = 0
	P2Score = 0

	-- paddle positions on the Y axis (they can only move up or down)
	P1y = 30
	P2y = VIRTUAL_HEIGHT - 50

	-- velocity and position variables for our ball when play starts
	BallX = VIRTUAL_WIDTH / 2 - 2
	BallY = VIRTUAL_HEIGHT / 2 - 2

	BallDx = math.random(2) == 1 and 100 or -100
	BallDy = math.random(-50, 50)

	-- game state variable used to transition between different parts of the game
	GameState = "start"
end

-- runs every frame with `dt`, our delta in seconds since the last frame
function love.update(dt)
	-- Player 1 movement
	if love.keyboard.isDown("w") and P1y > 0 then
		P1y = P1y + -PADDLE_SPEED * dt
	elseif love.keyboard.isDown("s") and P1y < VIRTUAL_HEIGHT - 20 then
		P1y = P1y + PADDLE_SPEED * dt
	end

	-- Player 2 movement
	if love.keyboard.isDown("up") and P2y > 0 then
		P2y = P2y + -PADDLE_SPEED * dt
	elseif love.keyboard.isDown("down") and P2y < VIRTUAL_HEIGHT - 20 then
		P2y = P2y + PADDLE_SPEED * dt
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

-- Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
function love.draw()
	-- begin rendering at virtual resolution
	push:apply("start")

	-- clear the screen with a color similar to some versions of the original Pong
	love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

	-- print "Hello Pong!" at the middle of the screen
	love.graphics.setFont(SmallFont)
	love.graphics.printf("Hello Pong", 0, 20, VIRTUAL_WIDTH, "center")

	-- draw score on the left and right center of the screen
	love.graphics.setFont(ScoreFont)
	love.graphics.print(tostring(P1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(P2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

	-- render first paddle
	love.graphics.rectangle("fill", 10, P1y, 5, 20)

	-- render second paddle
	love.graphics.rectangle("fill", VIRTUAL_WIDTH - 10, P2y, 5, 20)

	-- render ball
	love.graphics.rectangle("fill", BallX, BallY, 4, 4)

	-- end rendering at virtual resolution
	push:apply("end")
end
