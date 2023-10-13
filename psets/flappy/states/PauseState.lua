--[[
    Pause State
    Author: Carlos Murrieta
    crosquillas@gmail.com

    Pauses game play and allows the player to resume
]]

PauseState = Class{__includes = BaseState}

function PauseState:init()
  -- play pause sound
  sounds['pause']:play()

  -- stop music
  sounds['music']:pause()

  -- State needed to resume game when leaving pause state
  self.bird = nil
  self.pipePairs = nil
  self.timer = nil
  self.score = nil
  self.interval = nil
  self.lastY = nil
end

function PauseState:enter(params)
  -- Get state from play state transition
  self.bird = params.bird
  self.pipePairs = params.pipePairs
  self.timer = params.timer
  self.score = params.score
  self.interval = params.interval
  self.lastY = params.lastY

  -- Set global pause variable
  gPaused = true
end

-- Listen for user input to resume the game
function PauseState:update(dt)
    if love.keyboard.wasPressed('p') then
      -- play pause sound
      sounds['pause']:play()

      -- resume game
      gStateMachine:change('play', {
        bird = self.bird,
        pipePairs = self.pipePairs,
        timer = self.timer,
        score = self.score,
        interval = self.interval,
        lastY = self.lastY
      })

      -- resume music
      sounds['music']:play()

      -- Set global pause variable
      gPaused = false
    end
end

function PauseState:render()
    -- render pause message
    love.graphics.setFont(hugeFont)
    love.graphics.printf("PAUSED", 0, 120, VIRTUAL_WIDTH, 'center')

    -- show score in pause screen
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')
end

