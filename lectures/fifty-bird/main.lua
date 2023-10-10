-- GD50 Flappy Bird Remake

-- virtual resolution handling library
local push = require("push")

-- class library for oop
Class = require("class")

-- require classes we've written
require("Bird")
require("Pipe")
require("PipePair")

-- physical dimensions of the window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--virtual dimensions of the window
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- load images into memory
local background = love.graphics.newImage("background.png")
local ground = love.graphics.newImage("ground.png")

-- scroll position of sprites
local backgroundScroll = 0
local groundScroll = 0

-- scrolling variable to pause the game when we collide with a pipe
local scrolling = true

-- scroll speed
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- point at which we should loop our background back to X 0
local BACKGROUND_LOOPING_POINT = 413

-- point at which we should loop our ground back to X 0
local GROUND_LOOPING_POINT = 514

-- bird sprite
local bird = Bird()

-- our table of spawning PipePairs
local pipePairs = {}

-- our time for spawning pipes
local spawnTimer = 0

-- initialize our last recorded Y value for a gap placement to base other gaps off of
local lastY = -PIPE_HEIGHT + math.random(80) + 20

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

	-- initialize input table
	love.keyboard.keysPressed = {}
end

function love.keypressed(key)
	-- add to our table of keys pressed this grame
	love.keyboard.keysPressed[key] = true

	-- allows us to quit the game
	if key == "escape" then
		love.event.quit()
	end
end

-- check our global input table for keys we activated during this frame
function love.keyboard.wasPressed(key)
	if love.keyboard.keysPressed[key] then
		return true
	else
		return false
	end
end

function love.update(dt)
	if scrolling then
		--scroll background by preset speed * dt, looping back to 0 after the looping point
		backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

		-- scroll ground by preset speed * dt, looping back to 0 after the screen width passes
		groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT

		-- count up our timer for pipe spawning
		spawnTimer = spawnTimer + dt

		-- spawn a new Pipe if the timer is past 2 seconds
		if spawnTimer > 2 then
			-- modify the last Y coordinate we placed so pipe faps aren't too far apart
			-- no higher than 10 pixels below the top edge of the screen, and no lower
			-- than a gap length (90 pixels) from the bottom
			local y = math.max(
				-PIPE_HEIGHT + 10,
				math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - GAP_HEIGHT - PIPE_HEIGHT)
			)
			lastY = y

			table.insert(pipePairs, PipePair(y))
			spawnTimer = 0
		end

		-- update bird based on gravity
		bird:update(dt)

		-- for every pipe in the scene, update the pipe pairs
		for k, pair in pairs(pipePairs) do
			pair:update(dt)

			-- check to see if bird collided with pipe
			for l, pipe in pairs(pair.pipes) do
				if bird:collides(pipe) then
					-- pause the game to show collision
					scrolling = false
				end
			end
		end

		-- remove any flagged pipes
		-- we need this second loop, rather than deleting the previous loop, because
		-- modifying the table in-place without explicit keys will result in skipping
		-- the next pipe, since all implicit keys (numerical indices) are automatically
		-- shifted down after a table removal
		for k, pair in pairs(pipePairs) do
			if pair.remove then
				table.remove(pipePairs, k)
			end
		end
	end

	-- reset input table
	love.keyboard.keysPressed = {}
end

function love.draw()
	push:start()

	-- draw the background starting at top left (0, 0)
	love.graphics.draw(background, -backgroundScroll, 0)

	-- render all the pipes in our scene
	for k, pair in pairs(pipePairs) do
		pair:render()
	end

	-- draw the ground on top of the background, towards the bottom of the screen
	love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

	-- render our bird to the screen using its own render logic
	bird:render()

	push:finish()
end

function love.resize(w, h)
	push:resize(w, h)
end
