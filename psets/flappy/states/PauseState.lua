--[[
    Pause State
    Author: Carlos Murrieta
    crosquillas@gmail.com

    Pauses game play and allows the player to resume
]]

PauseState = Class{__includes = BaseState}

function PauseState:init()
end

-- Listen for user input to resume the game
function PauseState:update(dt)
    if love.keyboard.wasPressed('p') then
      gStateMachine:change('play')
    end
end

function PauseState:render()
    -- render count big in the middle of the screen
    love.graphics.setFont(hugeFont)
    love.graphics.printf("PAUSED", 0, 120, VIRTUAL_WIDTH, 'center')
end

