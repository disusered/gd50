-- Counts down visually on the screen (3,2, 1) before the game begins.

CountdownState = Class({ __includes = BaseState })

-- takes 1 second to count down each time
COUNTDOWN_TIME = 0.75

function CountdownState:init()
	self.count = 3
	self.timer = 0
end

-- Keeps track of how much time has passed and decreases count if the timer has
-- exceeded our countdown time. If we have gone down to 0, we transition to the
-- play state
function CountdownState:update(dt)
	self.timer = self.timer + dt

	if self.timer > COUNTDOWN_TIME then
		self.timer = self.timer % COUNTDOWN_TIME
		self.count = self.count - 1

		if self.count == 0 then
			G_STATE_MACHINE:change("play")
		end
	end
end

function CountdownState:render()
	love.graphics.setFont(HUGE_FONT)
	love.graphics.printf(tostring(self.count), 0, 120, VIRTUAL_WIDTH, "center")
end
