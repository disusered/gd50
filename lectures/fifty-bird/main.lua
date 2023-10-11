-- GD50 Flappy Bird Remake

-- virtual resolution handling library
local push = require("push")

-- class library for oop
Class = require("class")

-- require classes we've written
require("Bird")
require("Pipe")
require("PipePair")

-- state machine library
require("StateMachine")

-- states in our game
require("states.BaseState")
require("states.PlayState")
require("states.TitleScreenState")

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

function love.load()
	-- initialize nearest-neighbor filter
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- app window title
	love.window.setTitle("Fifty Bird")

	-- initialize our nice-looking retro text fonts
	SMALL_FONT = love.graphics.newFont("font.ttf", 8)
	MEDIUM_FONT = love.graphics.newFont("flappy.ttf", 14)
	FLAPPY_FONT = love.graphics.newFont("flappy.ttf", 28)
	HUGE_FONT = love.graphics.newFont("flappy.ttf", 56)
	love.graphics.setFont(FLAPPY_FONT)

	-- initialize virtual resolution
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true,
	})

	-- initialize state machine with all state-returning functions
	G_STATE_MACHINE = StateMachine({
		["title"] = function()
			return TitleScreenState()
		end,
		["play"] = function()
			return PlayState()
		end,
	})
	G_STATE_MACHINE:change("title")

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

		-- now, we just update the state machine, which defers to the right state
		G_STATE_MACHINE:update(dt)
	end

	-- reset input table
	love.keyboard.keysPressed = {}
end

function love.draw()
	push:start()

	-- draw the background starting at top left (0, 0)
	love.graphics.draw(background, -backgroundScroll, 0)

	-- draw state machine between the background and ground, which defers render
	-- logic to the currently active state
	G_STATE_MACHINE:render()

	-- draw the ground on top of the background, towards the bottom of the screen
	love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

	push:finish()
end

function love.resize(w, h)
	push:resize(w, h)
end
