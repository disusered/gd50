--[[
    GD50
    Legend of Zelda

    Author: Carlos Antonio
]]

PlayerPotWalkState = Class{__includes = BaseState}

function PlayerPotWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.thrown = false
    self.pot = GameObject(GAME_OBJECT_DEFS['pot'], self.entity.x, self.entity.y)

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
    if self.thrown == false then
        self.pot.x = self.entity.x
        self.pot.y = self.entity.y - 12
    end

    -- TODO: Chuck pot when pressing return
    if love.keyboard.wasPressed('return') then
        self.thrown = true
        self.pot:fire(self.entity.direction, dt)
        -- self.entity:changeState('walk')
    end
end

function PlayerPotWalkState:render()
    -- render player entity in pot walk state
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    -- render pot
    love.graphics.draw(gTextures[self.pot.texture], gFrames[self.pot.texture][self.pot.frame],
        self.pot.x, self.pot.y)

    --
    -- debug for entity and hurtbox collision rects VV
    --

    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    -- love.graphics.rectangle('line', self.swordHurtbox.x, self.swordHurtbox.y,
    --     self.swordHurtbox.width, self.swordHurtbox.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end

