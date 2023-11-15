--[[
    GD50
    Legend of Zelda

    Author: Carlos Antonio
]]

PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:init(entity, dungeon)
    self.entity = entity
    self.dungeon = dungeon
    self.pot = GameObject(GAME_OBJECT_DEFS['pot'], self.entity.x, self.entity.y)

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

    -- TODO: Update pot position based on player position
    self.pot.x = self.entity.x
    self.pot.y = self.entity.y - 12

    -- TODO: Chuck pot when pressing return
    if love.keyboard.wasPressed('return') then
        self.entity:changeState('walk')
    end
end

function PlayerPotIdleState:render()
    -- render player entity in pot idle state
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    -- render pot
    love.graphics.draw(gTextures[self.pot.texture], gFrames[self.pot.texture][self.pot.frame],
        self.pot.x, self.pot.y)
end
