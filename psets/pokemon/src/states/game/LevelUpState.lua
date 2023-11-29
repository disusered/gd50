--[[
    GD50
    Pokemon

    Author: Carlos Antonio
    crosquillas@gmail.com
]]

LevelUpState = Class{__includes = BaseState}

function LevelUpState:init(baseStats, increasedStats)
    self.baseStats = baseStats
    self.increasedStats = increasedStats

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

    local width = 176
    local height = 96

    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - width,
        y = VIRTUAL_HEIGHT - height,
        width = width,
        height = height,
        interactive = false,
        items = {
            { text = 'HP: ' .. self.baseStats.HP .. " + " .. self.increasedStats.HP .. " = " .. self.baseStats.HP + self.increasedStats.HP, onSelect = fadeOutWhite },
            { text = 'Attack: ' .. self.baseStats.attack .. " + " .. self.increasedStats.attack .. " = " .. self.baseStats.attack + self.increasedStats.attack, onSelect = fadeOutWhite },
            { text = 'Defense: ' .. self.baseStats.defense .. " + " .. self.increasedStats.defense .. " = " .. self.baseStats.defense + self.increasedStats.defense, onSelect = fadeOutWhite },
            { text = 'Speed: ' .. self.baseStats.speed .. " + " .. self.increasedStats.speed .. " = " .. self.baseStats.speed + self.increasedStats.speed, onSelect = fadeOutWhite },
        }
    }
end

function LevelUpState:update(dt)
    self.levelUpMenu:update(dt)
end

function LevelUpState:render()
    self.levelUpMenu:render()
end
