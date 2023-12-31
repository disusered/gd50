--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level

    -- Extra balls are stored in a table in the lifetime of the PlayState
    self.balls = {}
    self.balls[1] = params.ball

    -- Always reset the powerups when entering the PlayState
    self.powerups = {}

    -- Pre-calculate the number of hits to beat the level
    self.hit_count = 0

    -- Determine if there is a locked brick in the level
    -- TODO: Don't spawn at start of level only for debugging
    for k, brick in pairs(self.bricks) do
      -- Save a reference to the locked brick
      if brick.locked then
          self.lockedBrick = brick
      end

      -- Calculate the number of hits to beat the level
      self.hit_count = self.hit_count + brick.color
    end

    self.recoverPoints = 5000

    -- give initial ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    -- Keep track of how many times we hit a brick
    self.brickHits = 0
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update paddle position based on velocity
    self.paddle:update(dt)

    -- iterate over all balls
    for k, ball in pairs(self.balls) do
      -- update ball position based on velocity
      ball:update(dt)
    end

    -- iterate over all powerups
    for k, powerup in pairs(self.powerups) do
      -- update position of powerup
      powerup:update(dt)

      -- if a given powerup collides with the paddle, trigger its effect
      if powerup:collides(self.paddle) then
        -- play a sound indicating a powerup was collected
        gSounds['powerup-triggered']:play()


        if powerup.type == 9 then
            -- Spawn another two balls at the position the powerup was collected
            for i = 2, 3 do
              local ball = Ball()
              ball.skin = math.random(7)
              ball.x = powerup.x
              ball.y = self.paddle.y - 8
              ball.dx = math.random(-200, 200)
              ball.dy = math.random(-50, -60)
              self.balls[#self.balls+1] = ball
            end
        elseif powerup.type == 10 then
            -- Unlock the locked brick
            self.lockedBrick.locked = false
            gSounds['locked-brick-unlock']:play()
        end

        -- remove powerup
        table.remove(self.powerups, k)
      end
    end

    -- iterate over all balls
    for k, ball in pairs(self.balls) do

      -- paddle collision logic
      if ball:collides(self.paddle) then
          -- raise ball above paddle in case it goes below it, then reverse dy
          ball.y = self.paddle.y - 8
          ball.dy = -ball.dy

          --
          -- tweak angle of bounce based on where it hits the paddle
          --

          -- if we hit the paddle on its left side while moving left...
          if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
              ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
          
          -- else if we hit the paddle on its right side while moving right...
          elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
              ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
          end

          gSounds['paddle-hit']:play()
      end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for k, ball in pairs(self.balls) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                local previous_score = self.score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- resize paddle every 1000 points
                if math.floor(previous_score/1000) < math.floor(self.score/1000) then
                  self.paddle:increase_size()
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- increment the number of times we hit a brick
                self.brickHits = self.brickHits + 1

                -- Set the probability of a locked powerup to spawn
                local locked_probability = math.random(1, self.hit_count)

                -- Create an unlock powerup to unlock the brick
                if self.brickHits % locked_probability == 0 then
                  -- Only spawn the unlock powerup if the brick is locked
                  if self.lockedBrick.locked then
                      local powerup = Powerup(brick.x + 16 / 2, brick.y)
                      powerup.type = 10
                      self.powerups[#self.powerups + 1] = powerup

                      -- play sound indicating unlock powerup was spawned
                      gSounds['powerup-locked']:play()
                  end
                end

                -- spawn powerup if we hit a brick given the spawn threshold
                if self.brickHits % POWERUP_SPAWN_THRESHOLD == 0 then
                    -- spawn powerup at center of brick
                    local powerup = Powerup(brick.x + 16 / 2, brick.y)

                    -- add powerup to powerupts table
                    self.powerups[#self.powerups + 1] = powerup

                    -- play sound indicating powerup was spawned
                    gSounds['powerup']:play()
                end

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- iterate over all balls
    for k, ball in pairs(self.balls) do
      -- if ball goes below bounds, remove it from play
      if ball.y >= VIRTUAL_HEIGHT then
          -- remove ball from table by index
          table.remove(self.balls, k)

          -- if we're out of balls, i.e. self.balls table is empty, end game
          if table.getn(self.balls) == 0 then
            self.health = self.health - 1
            self.paddle:decrease_size()
            gSounds['hurt']:play()

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints
                })
            end
        end
      end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    -- render all balls
    for k, ball in pairs(self.balls) do
      ball:render()
    end

    -- render powerups
    for k, powerup in pairs(self.powerups) do
      powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end
