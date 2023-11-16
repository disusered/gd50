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

    -- iterate over objects in room
    for k, object in pairs(self.dungeon.currentRoom.objects) do
        -- listen to return/enter key
        if love.keyboard.wasPressed('return') then
            -- detect if object is a pot, and if so, depending on the direction
            -- of the player determine whether the player can lift the pot. We
            -- don't use the :collides() method here because we want to check
            -- specifically whether the player is colliding with the pot's hitbox,
            -- but since the pot is an object, it doesn't have a hitbox property.
            if object.type == 'pot' then
                local canLift = false

                if direction == 'left' then
                    local condition = math.floor(self.entity.x) - self.entity.width
                    if object.x == condition or object.x == condition - 1 then
                        if self.entity.y < object.y + object.height or self.entity.y > object.y - object.height then
                            canLift = true
                        end
                    end
                elseif direction == 'right' then
                    local condition = math.floor(self.entity.x) + object.width
                    if object.x == condition or object.x == condition + 1 then
                        if self.entity.y < object.y + object.height or self.entity.y > object.y - object.height then
                            canLift = true
                        end
                    end
                elseif direction == 'up' then
                    local condition = math.floor(self.entity.y) - 6
                    if object.y == condition or object.y == condition + 1 then
                        if self.entity.x < object.x + object.width or self.entity.x > object.x - object.width then
                            canLift = true
                        end
                    end
                elseif direction == 'down' then
                    local condition = math.floor(self.entity.y) + self.entity.height
                    if object.y == condition or object.y == condition + 1 then
                        if self.entity.x < object.x + object.width or self.entity.x > object.x - object.width then
                            canLift = true
                        end
                    end
                end

              if canLift then
                  -- remove pot from room
                  table.remove(self.dungeon.currentRoom.objects, k)

                  -- change to lift state
                  self.entity:changeState('pot-lift')

                  -- pass pot object to current room
                  self.dungeon.currentRoom.projectile = object
              end
            end
        end
    end
end
