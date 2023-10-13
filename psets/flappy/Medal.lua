-- Class for rendering a medal

Medal = Class{}

-- Table of medal images with name as key
-- Attribution: First Vectors by Vecteezy
local medals = {
  ['bronze'] = love.graphics.newImage('Bronze.png'),
  ['silver'] = love.graphics.newImage('Silver.png'),
  ['gold'] = love.graphics.newImage('Gold.png'),
}

function Medal:init()
    self.image = nil
end

-- Set the medal image
function Medal:set(name)
    self.image = medals[name]
end

-- Render the medal
function Medal:render()
    local x = VIRTUAL_WIDTH / 2 - 35
    local y = VIRTUAL_HEIGHT / 2 + 45
    if self.image ~= nil then
      love.graphics.draw(self.image, x, y, 0, 0.04)
    end
end
