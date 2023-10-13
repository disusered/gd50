-- Class for rendering a medal

Medal = Class{}

  -- Attribution: First Vectors by Vecteezy
  local medals = {
    ['bronze'] = love.graphics.newImage('Bronze.png'),
    ['silver'] = love.graphics.newImage('Silver.png'),
    ['gold'] = love.graphics.newImage('Gold.png'),
  }

function Medal:init()
    self.image = medals['bronze']
end

function Medal:render()
    local x = VIRTUAL_WIDTH / 2 - self.image:getWidth() / 2
    local y = VIRTUAL_HEIGHT / 2 - self.image:getHeight() / 2
    love.graphics.draw(self.image, x, y)
end
