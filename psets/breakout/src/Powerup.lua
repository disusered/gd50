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
  - [ ] Define a condition for the extra balls powerup to spawn
  - [ ] Render the extra balls powerup when condition is met
  - [ ] Render the extra balls powerup from brick that met the condition
]]

Powerup = Class{}

function Powerup:init(x, y)
  -- Spawn position
  self.x = x
  self.y = y

  -- Used to determine whether this powerup should be rendered. We start with
  -- false so the powerup doesn't spawn until we want it to
  self.inPlay = false
end

function Powerup:render()
  if self.inPlay then
    love.graphics.draw(gTextures['main'], gFrames['powerups'][9], self.x, self.y)
  end
end

