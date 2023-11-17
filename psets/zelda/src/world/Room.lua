--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.tiles = {}
    self:generateWallsAndFloors()

    -- entities in the room
    self.entities = {}
    self:generateEntities()

    -- game objects in the room
    self.objects = {}
    self:generateObjects()

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    table.insert(self.doorways, Doorway('top', false, self))
    table.insert(self.doorways, Doorway('bottom', false, self))
    table.insert(self.doorways, Doorway('left', false, self))
    table.insert(self.doorways, Doorway('right', false, self))

    -- reference to player for collisions, etc.
    self.player = player

    -- reference to projectile i.e. the pot
    self.projectile = nil

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    for i = 1, 10 do
        local type = types[math.random(#types)]

        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,
            hasHeart = math.random(10) == 1,

            -- ensure X and Y are within bounds of the map
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            
            width = 16,
            height = 16,

            health = 1
        })

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')
    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    local switch = GameObject(
        GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    )

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end

    -- add to list of objects in scene (only one switch for now)
    table.insert(self.objects, switch)

    for i = 1, math.random(6) do
        -- insert a pot object in the room using same placement code as the switch
        local pot = GameObject(GAME_OBJECT_DEFS['pot'],
            math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                  VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                  VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16))
        pot.projectile = true
        table.insert(self.objects, pot)
    end
end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function Room:update(dt)
    
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- remove entity from the table if health is <= 0
        if entity.health <= 0 then
            entity.dead = true
        elseif not entity.dead then
            entity:processAI({room = self}, dt)
            entity:update(dt)
        end

        -- collision between the player and entities in the room
        if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end

        -- add a heart to the room when an entity dies if it has a heart
        if entity.dead and entity.hasHeart then
            local heart = GameObject(GAME_OBJECT_DEFS['heart'], entity.x, entity.y)

            heart.onCollide = function()
                if not heart.used then
                    -- the default health max is 6, so we don't want to go above that
                    self.player.health = math.min(self.player.health + 2, 6)

                    -- play heart sound
                    gSounds['heart']:play()

                    -- indicate that the heart has been taken
                    heart.used = true
                end
            end

            table.insert(self.objects, heart)
            entity.hasHeart = false
        end
    end

    -- update projectile, if set
    if self.projectile then
        self.projectile:update(dt)
    end

    -- check if projectile goes further than 4 tiles, if so, destroy it
    if self.projectile then
        if self.projectile.startX > 0 or self.projectile.startY > 0 then
            if math.abs(self.projectile.x - self.projectile.startX) > 4 * TILE_SIZE or
                math.abs(self.projectile.y - self.projectile.startY) > 4 * TILE_SIZE then
                self.projectile = nil
            end
        end
    end


    -- check if projectile hits the wall, if so, destroy it. adapted from the
    -- wall collision code in entity walk state
    if self.projectile then
        if self.player.direction == 'left' then
            if self.projectile.x <= MAP_RENDER_OFFSET_X + TILE_SIZE - self.projectile.width / 2 then
                self.projectile = nil
            end
        elseif self.player.direction == 'right' then
            if self.projectile.x + self.player.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 + self.projectile.width / 2 then
                self.projectile = nil
            end
        elseif self.player.direction == 'up' then
            if self.projectile.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.player.height / 2 - self.projectile.height / 2 then
                self.projectile = nil
            end
        elseif self.player.direction == 'down' then
            local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + self.projectile.height / 2
                + MAP_RENDER_OFFSET_Y - TILE_SIZE

            if self.projectile.y + self.player.height >= bottomEdge then
                self.projectile = nil
            end
        end

        -- after checking for wall collision, if the projectile was destroyed,
        -- play a sound
        if not self.projectile then
            gSounds['destroy-pot']:play()
        end
    end

        -- TODO: check if projectile collides with any entities in the scene
        -- TODO: if projectile collides with enemy, destroy enemy and projectile
        -- TODO: try to animate when projectile is destroyed

    for k, object in pairs(self.objects) do
        object:update(dt)

        -- remove any objects that are used up, removing them from the table
        if object.used then
            table.remove(self.objects, k)
        end

        -- do not allow player to walk through objects. the extra space on the
        -- positions is to prevent additional collisions when changing direction
        if object.solid and self.player:collides(object) then
            if self.player.direction =='right' then
                self.player.x = object.x - self.player.width - 1
            elseif self.player.direction == 'left' then
                self.player.x = object.x + 1 + object.width
            elseif self.player.direction == 'up' then
                self.player.y = object.y + 6
            elseif self.player.direction == 'down' then
                self.player.y = object.y - self.player.height - 1
            end
        end

        -- trigger collision callback on object
        if self.player:collides(object) then
            object:onCollide()
        end
    end
end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
        
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)
    
    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()

    -- render pot
    if self.projectile then
        love.graphics.draw(gTextures[self.projectile.texture], gFrames[self.projectile.texture][self.projectile.frame],
            self.projectile.x, self.projectile.y)
    end

    --
    -- DEBUG DRAWING OF STENCIL RECTANGLES
    --

    -- love.graphics.setColor(255, 0, 0, 100)
    
    -- -- left
    -- love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
    -- TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- right
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
    --     MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- top
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

    -- --bottom
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    
    -- love.graphics.setColor(255, 255, 255, 255)
end
