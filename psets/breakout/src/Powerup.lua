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

  - [ ] Generate quads for the powerups
  - [ ] Render the extra balls powerup in fixed position
  - [ ] Define a condition for the extra balls powerup to spawn
  - [ ] Render the extra balls powerup when condition is met
  - [ ] Render the extra balls powerup from brick that met the condition
]]

Powerup = Class{}

function Powerup:init()
end
