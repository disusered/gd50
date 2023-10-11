-- The PlayState class is the bulk of the game, where the player controls the
-- bird and avoids pipes. When the player collides with a pipe, we should go to
-- the GameOver state, where we go back to the main menu

PlayState = Class({ __includes = BaseState })

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24
