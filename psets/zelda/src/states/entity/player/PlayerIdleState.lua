--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(entity, dungeon)
    self.entity = entity
    self.dungeon = dungeon

    EntityIdleState.init(self, entity)
end

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    local direction = self.entity.direction

    for k, object in pairs(self.dungeon.currentRoom.objects) do
        if love.keyboard.wasPressed('return') then
            if object.type == 'pot' then
                if direction == 'left' then
                    local condition = math.floor(self.entity.x) - self.entity.width
                    if object.x == condition or object.x == condition - 1 then
                        if self.entity.y < object.y + object.height or self.entity.y > object.y - object.height then
                            self.entity:changeState('pot-walk')
                        end
                    end
                elseif direction == 'right' then
                    local condition = math.floor(self.entity.x) + object.width
                    if object.x == condition or object.x == condition + 1 then
                        if self.entity.y < object.y + object.height or self.entity.y > object.y - object.height then
                            self.entity:changeState('pot-walk')
                        end
                    end
                end
            end
        end
    end
end
