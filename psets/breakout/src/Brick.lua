--[[
    GD50
    Breakout Remake

    -- Brick Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a brick in the world space that the ball can collide with;
    differently colored bricks have different point values. On collision,
    the ball will bounce away depending on the angle of collision. When all
    bricks are cleared in the current map, the player should be taken to a new
    layout of bricks.

    - [x] Update bricks table to include locked brick
    - [x] Add flag to Brick class to determine if brick is locked
    - [x] Render locked brick if flag is set
    - [x] Add particle effect to locked brick
    - [x] Don't play sound on locked brick hit or destruction
    - [x] Add custom sound for locked brick hit
    - [x] Set locked brick to lowest tier
    - [x] Don't allow locked brick to be destroyed unless condition is met
    - [x] Spawn locked brick with LevelMaker
    - [x] Render powerup to unlock locked brick
    - [x] Add sound for unlock powerup
    - [ ] Calculate number of hits to beat level
    - [ ] Spawn unlock powerup once per level
    - [ ] Respawn powerup if not collected
    - [x] Add custom sound for when unlocked powerup is collected
    - [ ] Adjust points for locked brick
]]

Brick = Class{}

-- some of the colors in our palette (to be used with particle systems)
paletteColors = {
    -- blue
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- green
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- red
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- gold
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
}

function Brick:init(x, y)
    -- used for coloring and score calculation
    self.tier = 0
    self.color = 1
    
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    
    -- used to determine whether this brick should be rendered
    self.inPlay = true

    -- used to short circuit brick color and render a locked brick
    self.locked = false

    -- particle system belonging to the brick, emitted on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    -- various behavior-determining functions for the particle system
    -- https://love2d.org/wiki/ParticleSystem

    -- lasts between 0.5-1 seconds seconds
    self.psystem:setParticleLifetime(0.5, 1)

    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
    -- gives generally downward 
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    -- spread of particles; normal looks more natural than uniform
    self.psystem:setEmissionArea('normal', 10, 10)
end

--[[
    Triggers a hit on the brick, taking it out of play if at 0 health or
    changing its color otherwise.
]]
function Brick:hit()
    -- Add short circuit to configure locked brick particle system
    local particle_color = self.color

    if self.locked then
      particle_color = 5
    end

    -- set the particle system to interpolate between two colors; in this case, we give
    -- it our self.color but with varying alpha; brighter for higher tiers, fading to 0
    -- over the particle's lifetime (the second color)
    self.psystem:setColors(
        paletteColors[particle_color].r / 255,
        paletteColors[particle_color].g / 255,
        paletteColors[particle_color].b / 255,
        55 * (self.tier + 1) / 255,
        paletteColors[particle_color].r / 255,
        paletteColors[particle_color].g / 255,
        paletteColors[particle_color].b / 255,
        0
    )
    self.psystem:emit(64)

    -- sound on hit based on whether a brick is locked
    if self.locked then
        gSounds['locked-brick-hit']:play()
    else
        gSounds['brick-hit-2']:stop()
        gSounds['brick-hit-2']:play()
    end

    if self.locked == false then
        if self.tier > 0 then
            -- if we're at a higher tier than the base, we need to go down a tier
            -- if we're already at the lowest color, else just go down a color
            if self.color == 1 then
                self.tier = self.tier - 1
                self.color = 5
            else
                self.color = self.color - 1
            end
        else
            -- if we're in the first tier and the base color, remove brick from play
            if self.color == 1 then
                self.inPlay = false
            else
                self.color = self.color - 1
            end
        end
    end

    -- play a second layer sound if the brick is destroyed
    if not self.inPlay and self.locked== false then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
end

function Brick:render()
    -- Calculate desired color
    local color = 1 + ((self.color - 1) * 4) + self.tier

    -- If brick has the locked flag, set table index to locked brick
    if self.locked then
      color = 24
    end

    if self.inPlay then
        love.graphics.draw(gTextures['main'], 
            -- multiply color by 4 (-1) to get our color offset, then add tier to that
            -- to draw the correct tier and color brick onto the screen
            gFrames['bricks'][color],
            self.x, self.y)
    end
end

--[[
    Need a separate render function for our particles so it can be called after all bricks are drawn;
    otherwise, some bricks would render over other bricks' particle systems.
]]
function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end
