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

-- Score needed to win
MAX_SCORE = 10

-- Initialize LÖVE2D
function love.load()
	-- use nearest-neighbor filtering on upscaling and downscaling to prevent
	-- blurring of text and graphics
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- set the title of our application window
	love.window.setTitle("Pong")

	-- seed the rng
	math.randomseed(os.time())

	-- load "retro" fonts
	SmallFont = love.graphics.newFont("font.ttf", 8)
	LargeFont = love.graphics.newFont("font.ttf", 16)
	ScoreFont = love.graphics.newFont("font.ttf", 32)

	-- set up our sound effects; later, we can just index this table and
	-- call each entry's `play` method
	Sounds = {
		["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
		["score"] = love.audio.newSource("sounds/score.wav", "static"),
		["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static"),
	}

	-- set LÖVE2D's active font to the smallFont object
	love.graphics.setFont(SmallFont)

	-- Set up screen with virtual resolution using push
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true,
		canvas = false,
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

	-- player who won the game; not set to a proper value until we reach
	-- that state in the game
	WinningPlayer = 0

	-- the state of our game; can be any of the following:
	-- 1. 'start' (the beginning of the game, before first serve)
	-- 2. 'serve' (waiting on a key press to serve the ball)
	-- 3. 'play' (the ball is in play, bouncing between paddles)
	-- 4. 'done' (the game is over, with a victor, ready for restart)
	GameState = "start"
end

-- Called by LÖVE2D whenever we resize the screen
function love.resize(w, h)
	push:resize(w, h)
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

			Sounds["paddle_hit"]:play()
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

			Sounds["paddle_hit"]:play()
		end

		-- detect upper and lower screen boundry collision and reverse if collided
		if GameBall.y <= 0 then
			GameBall.y = 0
			GameBall.dy = -GameBall.dy
			Sounds["wall_hit"]:play()
		end

		-- -4 to account for the ball's size
		if GameBall.y >= VIRTUAL_HEIGHT - 4 then
			GameBall.y = VIRTUAL_HEIGHT - 4
			GameBall.dy = -GameBall.dy
			Sounds["wall_hit"]:play()
		end

		-- detect left and right edge of the screen and reset if collided
		if GameBall.x < 0 then
			ServingPlayer = 1
			P2Score = P2Score + 1
			Sounds["score"]:play()

			-- if we've reached a score of 10, the game is over
			if P2Score == MAX_SCORE then
				WinningPlayer = 2
				GameState = "done"
			else
				GameState = "serve"
				GameBall:reset()
			end
		end

		if GameBall.x > VIRTUAL_WIDTH then
			ServingPlayer = 2
			P1Score = P1Score + 1
			Sounds["score"]:play()

			-- if we've reached a score of 10, the game is over
			if P1Score == MAX_SCORE then
				WinningPlayer = 1
				GameState = "done"
			else
				GameState = "serve"
				GameBall:reset()
			end
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
		elseif GameState == "done" then
			-- game is simply in a restart phase here, but will set the serving player
			-- to the oppoonent of whomever won
			GameState = "serve"
			GameBall:reset()

			-- reset scores to 0
			P1Score = 0
			P2Score = 0

			-- decide serving player as the opposite of who won
			if WinningPlayer == 1 then
				ServingPlayer = 2
			else
				ServingPlayer = 1
			end
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
	if GameState == "start" then
		love.graphics.setFont(SmallFont)
		love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press Enter to begin!", 0, 20, VIRTUAL_WIDTH, "center")
	elseif GameState == "serve" then
		love.graphics.setFont(SmallFont)
		love.graphics.printf("Player " .. tostring(ServingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press Enter to serve!", 0, 20, VIRTUAL_WIDTH, "center")
	elseif GameState == "play" then
	-- no UI messages to display in play
	elseif GameState == "done" then
		love.graphics.setFont(LargeFont)
		love.graphics.printf("Player " .. tostring(WinningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.setFont(SmallFont)
		love.graphics.printf("Press Enter to restart!", 0, 30, VIRTUAL_WIDTH, "center")
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
