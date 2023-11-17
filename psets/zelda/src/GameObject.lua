--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- movement parameters
    self.projectile = false
    self.dx = 0
    self.dy = 0

    -- default empty collision callback
    self.onCollide = function() end

    -- whether the object should be removed from the game or not
    self.used = false
end

function GameObject:update(dt)
    if self.projectile then
      self.x = self.x + self.dx * dt
      self.y = self.y + self.dy * dt
    end
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end

function GameObject:fire(direction)
    if direction == 'left' then
        self.dx = -100
    elseif direction == 'right' then
        self.dx = 100
    elseif direction == 'up' then
        self.dy = -100
    elseif direction == 'down' then
        self.dy = 100
    end
end
