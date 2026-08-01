--[[pod_format="raw",created="2026-07-26 19:51:34",modified="2026-08-01 08:29:48",revision=820]]
------------------------------------------------------------
-- INCLUDES
------------------------------------------------------------
include "./palette.lua"
include "./config.lua"
include "./levels.lua"
include "./state_manager.lua"
include "./game.lua"
include "./ball.lua"
include "./paddle.lua"
include "./bricks.lua"
include "./powerups.lua"
include "./font.lua"

------------------------------------------------------------
-- INIT
------------------------------------------------------------
function _init()
	init_palette()
	init_font()

	ball = create_ball()
	add(balls, ball)

	start_game()
end


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------
function _update()
	update_state()
end


------------------------------------------------------------
-- DRAW
------------------------------------------------------------
function _draw()
	draw_state()
end

