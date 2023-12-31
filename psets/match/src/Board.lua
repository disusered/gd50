--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = 1

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            -- set variety based on level
            local variety = math.random(6)
            if self.level == 1 then
                variety = 1
            end


            -- set chance of shiny tile lower on initial layout, 2.5% chance
            local shiny = math.random(40) == 1

            -- limit to 8 unique colors
            local allowedColors = {1, 2, 6, 7, 11, 12, 14, 17}
            local color = allowedColors[math.random(#allowedColors)]

            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, color, variety, shiny))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

-- Swaps a base tile with a new tile and checks if there are any matches. If
-- there are matches, then the swap is valid and the function returns true.
function Board:swapMatchTest(baseTile, newTile)
  -- whether there are matches after the swap
  local hasMatch = false

  -- Swap grid positions of tiles
  local tempX = baseTile.gridX
  local tempY = baseTile.gridY

  baseTile.gridX = newTile.gridX
  baseTile.gridY = newTile.gridY
  newTile.gridX = tempX
  newTile.gridY = tempY

  -- swap tiles in the tiles table
  self.tiles[baseTile.gridY][baseTile.gridX] = baseTile
  self.tiles[newTile.gridY][newTile.gridX] = newTile

  -- if we have any matches, the swap was valid
  local matches = self:calculateMatches()
  if matches then
    hasMatch = true
  end

  -- always revert swap grid positions of tiles after counting
  newTile.gridX = baseTile.gridX
  newTile.gridY = baseTile.gridY
  baseTile.gridX = tempX
  baseTile.gridY = tempY

  --revert swap tiles in the tiles table
  self.tiles[baseTile.gridY][baseTile.gridX] = baseTile
  self.tiles[newTile.gridY][newTile.gridX] = newTile

  -- return whether there are matches
  return hasMatch
end

-- Count the number of potential matches on the board. To do this, we need to
-- swap everything left, right, up, and down, and see if that forms any matches.
function Board:hasMatches()
  local hasMatches = false

  -- Iterate over every tile in the board
  for y = 1, 8, 1 do
      for x = 1, 8, 1 do
          -- Current tile that is being tested
          local currentTile = self.tiles[y][x]

          -- Test swapping with tile to the left. This should only be tested if the x
          -- position is greater than 1 because there is no tile to the left of the
          -- first column.
          if x > 1 and self:swapMatchTest(currentTile, self.tiles[y][x - 1]) then
            hasMatches = true
          end

          -- Test swapping with tile to the right. This should only be tested if the x
          -- position is less than 8 because there is no tile to the right of the last
          -- column.
          if x < 8 and self:swapMatchTest(currentTile, self.tiles[y][x + 1]) then
            hasMatches = true
          end

          -- Test swapping with tile above. This should only be tested if the y position
          -- is greater than 1 because there is no tile above the first row
          if y > 1 and self:swapMatchTest(currentTile, self.tiles[y - 1][x]) then
            hasMatches = true
          end

          -- Test swapping with tile below. This should only be tested if the y position
          -- is less than 8 because there is no tile below the last row
          if y < 8 and self:swapMatchTest(currentTile, self.tiles[y + 1][x]) then
            hasMatches = true
          end
      end
  end

  return hasMatches
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- if any matched tile is shiny, then the whole row is deleted
                    local hasShiny = false

                    -- go backwards from here by matchNum to see if there are any shiny tiles
                    for x2 = x - 1, x - matchNum, -1 do
                        -- set shiny flag if any matched tile is shiny
                        if self.tiles[y][x2].shiny then
                            hasShiny = true
                        end
                    end

                    if hasShiny then
                        -- delete the entire row if shiny
                        for x3 = 8, 1, -1 do
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x3])
                        end
                    else
                        -- go backwards from here by matchNum if not shiny
                        for x3 = x - 1, x - matchNum, -1 do
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x3])
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)

                    -- remove the shiny flag for the next iteration
                    hasShiny = false
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            -- if any matched tile is shiny, then the whole row is deleted
            local hasShiny = false

            -- go backwards from here to end of last row to check for shiny tiles
            for x2 = 8, 8 - matchNum + 1, -1 do
                -- set shiny flag if any matched tile is shiny
                if self.tiles[y][x2].shiny then
                    hasShiny = true
                end
            end

          if hasShiny then
              -- delete the entire row if shiny
              for x3 = 8, 1, -1 do
                  -- add each tile to the match that's in that match
                  table.insert(match, self.tiles[y][x3])
              end
          else
              -- go backwards from end of last row by matchNum
              for x = 8, 8 - matchNum + 1, -1 do
                  table.insert(match, self.tiles[y][x])
              end
          end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                -- set variety based on level
                local variety = math.random(6)
                if self.level == 1 then
                    variety = 1
                end

                -- set chance of shiny tile higher on replacement tiles, 10% chance
                local shiny = math.random(10) == 1

                -- limit to 8 unique colors
                local allowedColors = {1, 2, 6, 7, 11, 12, 14, 17}
                local color = allowedColors[math.random(#allowedColors)]

                -- new tile with random color and variety
                local tile = Tile(x, y, color, variety, shiny)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end
