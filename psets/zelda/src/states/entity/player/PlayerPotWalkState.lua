--[[
    GD50
    Legend of Zelda

    Author: Carlos Antonio
]]

PlayerPotWalkState = Class{__includes = BaseState}

function PlayerPotWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerPotWalkState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('pot-walk-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('pot-walk-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('pot-walk-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('pot-walk-down')
    else
        self.entity:changeState('pot-idle')
    end

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)

    -- update pot location
    self.dungeon.currentRoom.projectile.x = self.entity.x
    self.dungeon.currentRoom.projectile.y = self.entity.y - 12

    -- fire projectile when pressing return
    if love.keyboard.wasPressed('return') then
        self.dungeon.currentRoom.projectile:fire(self.entity.direction)
        self.dungeon.currentRoom.projectile.startX = self.entity.x
        self.dungeon.currentRoom.projectile.startY = self.entity.y
        self.entity:changeState('walk')
    end
end

function PlayerPotWalkState:render()
    -- render player entity in pot walk state
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
end

