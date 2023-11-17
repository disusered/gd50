--[[
    GD50
    Legend of Zelda

    Author: Carlos Antonio
]]

PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:init(entity, dungeon)
    self.entity = entity
    self.dungeon = dungeon

    EntityIdleState.init(self, entity)
end

function PlayerPotIdleState:enter(params)
    self.entity:changeAnimation('pot-idle-' .. self.entity.direction)

    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk')
    end

    self.dungeon.currentRoom.projectile.x = self.entity.x
    self.dungeon.currentRoom.projectile.y = self.entity.y - 12

    -- fire projectile when pressing return
    if love.keyboard.wasPressed('return') then
        self.dungeon.currentRoom.projectile:fire(self.entity.direction)
        self.entity:changeState('walk')
    end
end
