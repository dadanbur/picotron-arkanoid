--[[pod_format="raw",created="2026-08-01 08:00:00",modified="2026-08-01 08:36:13",revision=2]]
----------------------------------------------------------------------
-- STATE MACHINE
----------------------------------------------------------------------
-- States:
-- intro_state          -> Title / Start screen
-- round_state          -> Round intro
-- gameplay_state       -> Main gameplay
-- gameover_state       -> Game Over screen
-- gamecompleted_state  -> Game completed screen
----------------------------------------------------------------------

state_manager = {
	current = nil
}

function change_state(new_state)

	if state_manager.current and state_manager.current.leave then
		state_manager.current.leave()
	end
	
	state_manager.current = new_state
	
	if state_manager.current.enter then
		state_manager.current.enter()
	end
end

function update_state()
	state_manager.current.update()
end

function draw_state()
	state_manager.current.draw()
end

function _update()
   update_state()
end

function _draw()
	draw_state()
end


----------------------------------------------------------------------
-- GAMEPLAY STATE
----------------------------------------------------------------------

function gameplay_enter()

end

function gameplay_draw()
    draw_background()
    draw_left_margin()
    draw_game_area()
    draw_bricks_shadow()
    draw_bricks()
    draw_balls()
    draw_pad()
    draw_bullets()
    draw_pills()
    draw_game_frame()
    draw_hud()
    draw_hud_score()
end

function gameplay_update()
	local button_pressed=false
	local ball = balls[1]
	--left
	if btn(0) then
		button_pressed = true
		pad.dx =- pad.speed
		if ball.stuck then ball.dx=-d end	
	end
	--right
	if btn(1) then
		button_pressed = true
		pad.dx = pad.speed
		if ball.stuck then ball.dx=d end
	end
	--- Fire laser
	if pad.laser and btnp(5) then
		fire_lasers()
	end

	--- TMP Next level
	if demo_mode and btnp(4) then
		next_level()
	end

		
	if not button_pressed then
		pad.dx = pad.dx/pad.friction
	end	
	
	pad.x += pad.dx
	pad.x = mid(GAME_X,pad.x,GAME_X + GAME_WIDTH - pad.width - 1)
	
	update_balls()
	update_bricks()
	update_pills()
	update_powerups()
	update_bullets()
end

gameplay_state = {
    enter = gameplay_enter,
    update = gameplay_update,
    draw = gameplay_draw
}

----------------------------------------------------------------------
-- INTRO STATE
----------------------------------------------------------------------
local intro_timer = 0
function intro_enter()
	intro_timer = 0
end

function intro_draw()
	cls(0)
	draw_starfield()
	
	spr(136,1,60)
	
	if (intro_timer // 10) % 2 == 0 then
		font_print("PRESS X KEY TO START",165,180,6)
	end
end

function intro_update()
	intro_timer += 1
	--- Start Game
	if btnp(5) then
		change_state(round_state)
	end
	update_starfield()
end

intro_state = {
    enter = intro_enter,
    update = intro_update,
    draw = intro_draw
}

----------------------------------------------------------------------
-- GAMEOVER STATE
----------------------------------------------------------------------

function gameover_enter()
end

function gameover_draw()
	gameplay_draw()
	local text = "GAME OVER"
	local x = GAME_X + (GAME_WIDTH - #text * 8) / 2
	local y = GAME_Y + GAME_HEIGHT / 2 + 40

	font_print(text, x, y, 7)
	
end

function gameover_update()
	if btnp(5) then
		start_game()
	end
end

function gameover_leave()
end

gameover_state = {
    enter = gameover_enter,
    update = gameover_update,
    draw = gameover_draw,
    leave = gameover_leave
}

----------------------------------------------------------------------
-- GAMECOMPLETED STATE
----------------------------------------------------------------------

function gamecompleted_enter()
end

function gamecompleted_draw()
	cls(1)
	local text = "C O N G R A T U L A T I O N S"
	local x = (SCREEN_WIDTH - #text * 8) / 2
	local y = SCREEN_HEIGHT / 2

	font_print(text, x, y, next_text_color())
end

function gamecompleted_update()
	if btnp(5) then
		start_game()
	end
end

gamecompleted_state = {
    enter = gamecompleted_enter,
    update = gamecompleted_update,
    draw = gamecompleted_draw
}

----------------------------------------------------------------------
-- ROUND STATE
----------------------------------------------------------------------
local round_timer = 0

function round_enter()
	init_level()
	round_timer = 120
end

function round_draw()
	gameplay_draw()
	local text = "ROUND "..round
	local x = GAME_X + (GAME_WIDTH - #text * 8) / 2
	local y = GAME_Y + GAME_HEIGHT / 2 + 40

	font_print(text, x, y, 7)
	
	text = "READY"
	x = GAME_X + (GAME_WIDTH - #text * 8) / 2	
	y += 18
	
	font_print(text, x, y, 7)
	
end

function round_update()
	gameplay_update()
	
	round_timer -= 1
	if round_timer <= 0 then
		change_state(gameplay_state)
	end
end

round_state = {
    enter = round_enter,
    update = round_update,
    draw = round_draw
}