--[[
    GD50
    Legend of Zelda

    Author: Carlos Antonio
]]

PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:enter(params)
    self.entity:changeAnimation('pot-idle-' .. self.entity.direction)

    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0

    -- TODO: Render pot above player
end

function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk')
    end

    -- TODO: Update pot position based on player position

    -- TODO: Chuck pot when pressing return
    if love.keyboard.wasPressed('return') then
        self.entity:changeState('walk')
    end
end
