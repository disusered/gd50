--[[
  GD50
  Breakout Remake

  -- Powerup Class --

  Author: Carlos Murrieta
  crosquillas@gmail.com

  Represents a powerup that can spawn in the world space that should spawn
  randomly when a `Ball` hits a `Block` enough times, and gradually descend toward
  the player.

  Once collided with the `Paddle`, two more `Ball`s should spawn and behave
  identically to the original, including all collision and scoring points. Once
  the player wins and proceeds to the `VictoryState`, all `Ball`s and `Powerups`
  should reset.

  - [x] Generate quads for the powerups
  - [x] Render the extra balls powerup in fixed position
  - [x] Render the extra balls powerup from brick that met the condition
  - [x] Render the powerup in the center of the brick
  - [x] Allow ability to render multiple powerups
  - [x] Define a condition for the extra balls powerup to spawn
  - [x] Move the powerup down the screen
  - [ ] Detect collision with the paddle
  - [ ] Spawn two more balls when collided with the paddle
]]

Powerup = Class{}

function Powerup:init(x, y)
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16

    -- Spawn position
    self.x = x
    self.y = y

    -- Random fall velocity
    self.dy = math.random(25, 50)

    -- Used to determine whether this powerup should be rendered. We start with
    -- true because we spawn powerups within the PlayState update function, so
    -- when they are created they should be visibile immediately
    self.inPlay = true
end

--[[
    Expects an argument with a bounding box, i.e. the paddle, and returns true
    if the bounding boxes of this and the argument overlap.
]]
function Powerup:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true
end

-- Update powerup position i.e. animate the fall at random velocity
function Powerup:update(dt)
  self.y = self.y + self.dy * dt
end

function Powerup:render()
  -- Render powerup if in play
  if self.inPlay then
    love.graphics.draw(gTextures['main'], gFrames['powerups'][9], self.x, self.y)
  end
end

