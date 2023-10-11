-- The starting screen of the game, shown on startup. It should display "Press
-- Enter" and also our highest score.

TitleScreenState = Class({ __includes = BaseState })

function TitleScreenState:update(dt)
	if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
		G_STATE_MACHINE:change("play")
	end
end

function TitleScreenState:render()
	love.graphics.setFont(FLAPPY_FONT)
	love.graphics.printf("Fifty Bird", 0, 64, VIRTUAL_WIDTH, "center")
	love.graphics.setFont(MEDIUM_FONT)
	love.graphics.printf("Press Enter", 0, 100, VIRTUAL_WIDTH, "center")
end
