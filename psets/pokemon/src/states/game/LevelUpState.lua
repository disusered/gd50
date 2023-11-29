--[[
    GD50
    Pokemon

    Author: Carlos Antonio
    crosquillas@gmail.com
]]

LevelUpState = Class{__includes = BaseState}

function LevelUpState:init()
    local fadeOutWhite = function()
        -- pop off level up menu
        gStateStack:pop()

        -- fade in
        gStateStack:push(FadeInState({
            r = 1, g = 1, b = 1
        }, 1,
        function()
            -- resume field music
            gSounds['victory-music']:stop()
            gSounds['field-music']:play()

            -- pop off the battle state
            gStateStack:pop()
            gStateStack:push(FadeOutState({
                r = 1, g = 1, b = 1
            }, 1, function() end))
        end))
    end

    local width = 196
    local height = 96

    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - width,
        y = VIRTUAL_HEIGHT - height,
        width = width,
        height = height,
        interactive = false,
        items = {
            { text = 'HP: ', onSelect = fadeOutWhite },
            { text = 'Attack: '},
            { text = 'Defense: '},
            { text = 'Speed: '},
        }
    }
end

function LevelUpState:update(dt)
    self.levelUpMenu:update(dt)
end

function LevelUpState:render()
    self.levelUpMenu:render()
end
