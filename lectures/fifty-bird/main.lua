-- GD50 Flappy Bird Remake

-- virtual resolution handling library
local push = require("push")

-- class library for oop
Class = require("class")

-- bird class we've written
require("Bird")

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

-- scroll speed
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- point at which we should loop our background back to X 0
local BACKGROUND_LOOPING_POINT = 413

-- bird sprite
local bird = Bird()

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
	--scroll background by preset speed * dt, looping back to 0 after the looping point
	backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

	-- scroll ground by preset speed * dt, looping back to 0 after the screen width passes
	groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

	-- update bird based on gravity
	bird:update(dt)

	-- reset input table
	love.keyboard.keysPressed = {}
end

function love.draw()
	push:start()

	-- draw the background starting at top left (0, 0)
	love.graphics.draw(background, -backgroundScroll, 0)

	-- draw the ground on top of the background, towards the bottom of the screen
	love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

	-- render our bird to the screen using its own render logic
	bird:render()

	push:finish()
end

function love.resize(w, h)
	push:resize(w, h)
end
