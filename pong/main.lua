-- GD50 2023 - Pong

-- Add a class library
Class = require("class")

-- Add a library for "retro" style visuals
local push = require("push")

-- Load the classes
require("Paddle")
require("Ball")

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

	-- set the title of our application window
	love.window.setTitle("Pong")

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

	-- initialize our player paddles
	Player1 = Paddle(10, 30, 5, 20)
	Player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	-- initialize the ball
	GameBall = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	-- initialize score variables
	P1Score = 0
	P2Score = 0

	-- player who last scored serves the ball
	ServingPlayer = 1

	-- game state variable used to transition between different parts of the game
	GameState = "start"
end

-- runs every frame with `dt`, our delta in seconds since the last frame
function love.update(dt)
	-- player 1 movement
	if love.keyboard.isDown("w") then
		Player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown("s") then
		Player1.dy = PADDLE_SPEED
	else
		Player1.dy = 0
	end

	-- player 2 movement
	if love.keyboard.isDown("up") then
		Player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown("down") then
		Player2.dy = PADDLE_SPEED
	else
		Player2.dy = 0
	end

	if GameState == "serve" then
		-- before switching to play, initialize ball's velocity based on player who
		-- last scored
		GameBall.dy = math.random(-50, 50)
		if ServingPlayer == 1 then
			GameBall.dx = math.random(140, 200)
		else
			GameBall.dx = -math.random(140, 200)
		end
	elseif GameState == "play" then
		-- detect ball collision with paddles, reversing dx if true and slightly
		-- increasing it, then altering the dy based on the position of collision
		if GameBall:collides(Player1) then
			GameBall.dx = -GameBall.dx * 1.03
			GameBall.x = Player1.x + 5

			-- keep velocity going in the same direction but randomize it
			if GameBall.dy < 0 then
				GameBall.dy = -math.random(10, 150)
			else
				GameBall.dy = math.random(10, 150)
			end
		end

		if GameBall:collides(Player2) then
			GameBall.dx = -GameBall.dx * 1.03
			GameBall.x = Player2.x - 4
			-- keep velocity going in the same direction but randomize it
			if GameBall.dy < 0 then
				GameBall.dy = -math.random(10, 150)
			else
				GameBall.dy = math.random(10, 150)
			end
		end

		-- detect upper and lower screen boundry collision and reverse if collided
		if GameBall.y <= 0 then
			GameBall.y = 0
			GameBall.dy = -GameBall.dy
		end

		-- -4 to account for the ball's size
		if GameBall.y >= VIRTUAL_HEIGHT - 4 then
			GameBall.y = VIRTUAL_HEIGHT - 4
			GameBall.dy = -GameBall.dy
		end

		-- detect left and right edge of the screen and reset if collided
		if GameBall.x < 0 then
			ServingPlayer = 1
			P2Score = P2Score + 1
			GameBall:reset()
			GameState = "start"
		end

		if GameBall.x > VIRTUAL_WIDTH then
			ServingPlayer = 2
			P1Score = P1Score + 1
			GameBall:reset()
			GameState = "start"
		end

		GameBall:update(dt)
	end

	-- update values in class with delta
	Player1:update(dt)
	Player2:update(dt)
end

-- Add keyboard handling
function love.keypressed(key)
	-- keys can be accessed by string name
	if key == "escape" then
		-- function LÖVE gives us to terminate application
		love.event.quit()
	-- if we press enter during the start state of the game, we'll go into play mode
	elseif key == "enter" or key == "return" then
		if GameState == "start" then
			GameState = "serve"
		elseif GameState == "serve" then
			GameState = "play"
		end
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
	if GameState == "start" then
		love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press Enter to begin!", 0, 20, VIRTUAL_WIDTH, "center")
	else
		love.graphics.printf("Player " .. tostring(ServingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press Enter to serve!", 0, 20, VIRTUAL_WIDTH, "center")
	end

	-- draw score on the left and right center of the screen
	love.graphics.setFont(ScoreFont)
	love.graphics.print(tostring(P1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(P2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

	-- render paddles
	Player1:render()
	Player2:render()

	-- render ball
	GameBall:render()

	-- render FPS
	displayFPS()

	-- end rendering at virtual resolution
	push:apply("end")
end

-- simple FPS display across all states
function displayFPS()
	love.graphics.setFont(SmallFont)
	love.graphics.setColor(0, 255 / 255, 0, 255 / 255)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end
