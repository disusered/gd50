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

