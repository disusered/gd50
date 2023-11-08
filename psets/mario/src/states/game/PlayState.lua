--[[
    GD50
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  if params then
    self.player.score = params.score
    self.levelNumber = params.levelNumber
  end
end

function PlayState:init()
    self.camX = 0
    self.camY = 0
    self.levelNumber = 1
    self.level = LevelMaker.generate(50 + (self.levelNumber * 10), 10)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0
    self.keyColor = math.random(4)
    self.keyCollected = false
    self.unlocked = false
    self.gravityOn = true
    self.gravityAmount = 6

    -- Initial player x position
    local playerX = 0

    -- flag for whether there's ground on this column of the level
    local groundFound = false

    -- Find the first column with ground
    while not groundFound do
        -- Loop through the column until we find ground
        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][playerX + 1].id == TILE_ID_GROUND then
                  groundFound = true
                end
            end
        end

        -- If we didn't find ground, move to the next column
        if not groundFound then
          playerX = playerX + 1
        end
    end

    self.player = Player({
        x = playerX * 16, y = 0,
        width = 16, height = 20,
        texture = 'green-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level
    })

    self:spawnEnemies()

    self:spawnLockAndKey()

    self.player:changeState('falling')
end

function PlayState:update(dt)
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.player:update(dt)
    self.level:update(dt)
    self:updateCamera()

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

    if self.keyCollected and not self.unlocked then
      love.graphics.draw(gTextures['keys-and-locks'], gFrames['keys-and-locks'][self.keyColor], VIRTUAL_WIDTH - 30, 0)
    end
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
    
    -- render score
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.player.score), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(self.player.score), 4, 4)
end

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then
                        
                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end

--[[
    Adds lock and key to the level.
]]
function PlayState:spawnLockAndKey()
    local keySpawned = false

    -- spawn a lock in the level
    for x = 1, self.tileMap.width do
        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND and self.tileMap.tiles[y][x].topper then
                    groundFound = true

                    -- random chance, can be any x tile
                    if not keySpawned and math.random(self.tileMap.width / 6) == 1 then
                        -- spawn key
                        table.insert(self.level.objects,
                            GameObject {
                                texture = 'keys-and-locks',
                                x = (x - 1) * TILE_SIZE,
                                y = (y - 2) * TILE_SIZE + 2,
                                width = 16,
                                height = 16,
                                frame = self.keyColor,
                                consumable = true,
                                onConsume = function()
                                    self.keyCollected = true
                                    gSounds['key']:play()
                                end
                            }
                        )
                        keySpawned = true

                        -- spawn a lock ahead of the key
                        table.insert(self.level.objects,
                            GameObject {
                                texture = 'keys-and-locks',
                                x = (x + math.random(4, 16)) * TILE_SIZE,
                                y = (y - 4) * TILE_SIZE,
                                frame = self.keyColor + 4,
                                width = 16,
                                height = 16,
                                collidable = true,
                                solid = true,
                                locked = true,
                                onCollide = function(obj)
                                    if self.keyCollected then
                                        obj.locked = false
                                        self.unlocked = true
                                        self:spawnFlag()
                                        gSounds['unlocked']:play()
                                    else
                                        gSounds['locked']:play()
                                    end
                                end
                            }
                        )
                    end
                end
            end
        end
    end
end

--[[
    Adds lock and key to the level.
]]
function PlayState:spawnFlag()
    -- flag for whether there's ground on this column of the level
    local groundFound = false

    -- Initial flag x position
    local flagY = 0
    local flagX = self.tileMap.width - 3

    -- Find the first column with ground
    while not groundFound do
        -- Loop through the column until we find ground
        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][flagX + 1].id == TILE_ID_GROUND then
                  groundFound = true
                  flagY = y
                end
            end
        end

        -- If we didn't find ground, move to the previous column
        if not groundFound then
          flagX = flagX - 1
        end
    end

    -- Flag to mount on the flagpole
    local flag = GameObject {
        texture = 'flags',
        x = (flagX) * TILE_SIZE + 8,
        y = (flagY - 4) * TILE_SIZE + 4,
        frame = 16,
        width = 16,
        height = 48,
        collidable = false,
        solid = false,
    }

    -- spawn a flagpole at the end of the level
    table.insert(self.level.objects,
        GameObject {
            texture = 'flagpoles',
            x = (flagX) * TILE_SIZE,
            y = (flagY - 4) * TILE_SIZE,
            frame = 4,
            width = 16,
            height = 48,
            consumable= true,
            onConsume= function()
              gSounds['flag']:play()
              gStateMachine:change('play', {
                score = self.player.score + 500,
                levelNumber = self.levelNumber + 1
              })
            end
        }
    )

    table.insert(self.level.objects, flag)
end
