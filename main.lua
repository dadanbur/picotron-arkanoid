--[[pod_format="raw",created="2026-07-26 19:51:34",modified="2026-07-27 15:16:39",revision=289]]
include "./palette.lua"

SCREEN_WIDTH  = 480
SCREEN_HEIGHT = 270

TOP_MARGIN  = 8
LEFT_MARGIN = 25
FRAME_SIZE  = 8

GAME_WIDTH  = 222
GAME_HEIGHT = 254

GAME_BOTTOM = SCREEN_HEIGHT - 1

FRAME_WIDTH  = GAME_WIDTH + FRAME_SIZE * 2
FRAME_HEIGHT = GAME_HEIGHT + FRAME_SIZE
FRAME_TILE_SIZE = 16

FRAME_X = LEFT_MARGIN

GAME_X = FRAME_X + FRAME_SIZE
--GAME_Y = FRAME_Y + FRAME_SIZE
GAME_Y = SCREEN_HEIGHT - GAME_HEIGHT

GAME_RIGHT = GAME_X + GAME_WIDTH - 1

--FRAME_Y = TOP_MARGIN
FRAME_Y = GAME_Y - FRAME_SIZE

HUD_X = FRAME_X + FRAME_WIDTH
HUD_Y = 0
HUD_WIDTH = SCREEN_WIDTH - HUD_X
HUD_HEIGHT = SCREEN_HEIGHT

SPR_FRAME_CORNER   = 24
SPR_FRAME_DECOR_A  = 32
SPR_FRAME_DECOR_B  = 40
SPR_FRAME_CLAMP_L  = 25
SPR_FRAME_CLAMP_R  = 26

PADDLE_WIDTH  = 32
PADDLE_HEIGHT = 8
PADDLE_BOTTOM_MARGIN = 18

BRICK_WIDTH  = 16
BRICK_HEIGHT = 8
BRICK_SPACING_X = 1
BRICK_SPACING_Y = 1
BRICK_FLASH = 18

BRICKS_X = FRAME_X + FRAME_SIZE
BRICKS_Y = FRAME_Y + FRAME_SIZE + (BRICK_HEIGHT*3) 

pad = {
	x = GAME_X + (GAME_WIDTH - PADDLE_WIDTH) / 2,
	y = SCREEN_HEIGHT - (PADDLE_HEIGHT + PADDLE_BOTTOM_MARGIN),
	width = PADDLE_WIDTH,
	height = PADDLE_HEIGHT,
	speed = 5,
	friction=1.5,
	sprite = 8,
	dx = 0
}

local d = 1 / sqrt(2)

ball = {
	x = GAME_X + (GAME_WIDTH - PADDLE_WIDTH) / 2,
	y = SCREEN_HEIGHT - (PADDLE_HEIGHT + PADDLE_BOTTOM_MARGIN),
	old_x = 0,
	old_y = 0,
	r = 3,
	dx = d,
	dy = -d,
	sprite = 1,
	speed = 2.5,
	stuck = true
}

BRICK_EMPTY		= "0"
BRICK_WHITE		= "1"
BRICK_ORANGE		= "2"
BRICK_CYAN		= "3"
BRICK_GREEN		= "4"
BRICK_RED			= "5"
BRICK_BLUE		= "6"
BRICK_VIOLET		= "7"
BRICK_YELLOW	= "8"
BRICK_SILVER		= "S"
BRICK_GOLD		= "G"

brick_types = {
    [BRICK_WHITE]		= { col = 7,  type = 1,  score = 50,  hits = 1 }, -- White
    [BRICK_ORANGE]		= { col = 9,  type = 2,  score = 60,  hits = 1 }, -- Orange
    [BRICK_CYAN] 		= { col = 28, type = 3,  score = 70,  hits = 1 }, -- Cyan
    [BRICK_GREEN] 		= { col = 11, type = 4,  score = 90,  hits = 1 }, -- Green
    [BRICK_RED] 		= { col = 8,  type = 5,  score = 100, hits = 1 }, -- Red
    [BRICK_BLUE] 		= { col = 16, type = 6,  score = 100, hits = 1 }, -- Blue
    [BRICK_VIOLET] 	= { col = 30, type = 7,  score = 100, hits = 1 }, -- Violet
    [BRICK_YELLOW] 	= { col = 10, type = 8,  score = 50,  hits = 1 }, -- Yellow
    [BRICK_SILVER] 	= { col = 6,  type = 9,  score = 50,  hits = 2 }, -- Silver
    [BRICK_GOLD] 		= { col = 25,  type = 10, score = 0,   hits = -1 } -- Gold
}

remaining_bricks = 0
bricks={}  	

SPR_PILL_SHADOW = 48
POWERUP_DROP_CHANCE = 1

POWERUP_NONE			= 0
POWERUP_SLOW			= 1
POWERUP_PLAYER			= 2
POWERUP_CATCH			= 3
POWERUP_ENLARGE		= 4
POWERUP_MEGA			= 5
POWERUP_DISRUPTION	= 6
POWERUP_LASER			= 7
POWERUP_BREAK			= 8
--POWERUP_REDUCE			= 5

powerup_types = {
    [POWERUP_SLOW] = { 
        type = POWERUP_SLOW,
        name = "SLOW",
        text = "SPEED DOWN",
        label = "S",
        color = 9,
        sprites = {64,65,66,67,68,69,70,71}
    },

    [POWERUP_PLAYER] = {
        type = POWERUP_PLAYER,
        name = "PLAYER",
        text = "PLAYER",
        label = "P",
        color = 13,
        sprites = {112,113,114,115,116,117,118,119}
    },

    [POWERUP_CATCH] = {
        type = POWERUP_CATCH,
        name = "CATCH",
        text = "CATCH",
        label = "C",
        color = 11,
        sprites = {72,73,74,75,76,77,78,79}
    },

    [POWERUP_ENLARGE] = {
        type = POWERUP_ENLARGE,
        name = "ENLARGE",
        text = "ENLARGE",
        label = "E",
        color = 12,
        sprites = {88,89,90,91,92,93,94,95}
    },
    
    [POWERUP_MEGA] = {
        type = POWERUP_MEGA,
        name = "MEGA",
        text = "MEGA BALL",
        label = "M",
        color = 2,
        sprites = {120,121,122,123,124,125,126,127}
    },

    [POWERUP_DISRUPTION] = {
        type = POWERUP_DISRUPTION,
        name = "DISRUPTION",
        text = "DISRUPTION",
        label = "D",
        color = 28,
        sprites = {96,97,98,99,100,101,102,103}
    },

    [POWERUP_LASER] = {
        type = POWERUP_LASER,
        name = "LASER",
        text = "LASER",
        label = "L",
        color = 8,
        sprites = {80,81,82,83,84,85,86,87}
    },

    [POWERUP_BREAK] = {
        type = POWERUP_BREAK,
        name = "BREAK",
        text = "BREAK",
        label = "B",
        color = 30,
        sprites = {104,105,106,107,108,109,110,111}
    }
    
    --[[
    [POWERUP_REDUCE] = {
        type = POWERUP_REDUCE,
        name = "REDUCE",
        text = "REDUCE",
        label = "R",
        color = 5,
        sprites = nil
    },  
    ]]  
    
}

pills={}
active_powerups = {}

round = 1
levels={
	[1]={
		"SSSSSSSSSSSSS",
  		"5555555555555",
  		"8888888888888",
  		"6666666666666",
  		"7777777777777",
  		"4444444444444"},
  	[2]={
		"1000000000000",
		"1200000000000",
		"1230000000000",
		"1234000000000",
		"1234500000000",
		"1234560000000",
		"1234567000000",
		"1234567800000",
		"1234567810000",
		"1234567812000",
		"1234567812300",
		"1234567812340",
		"SSSSSSSSSSSS5"},
	[3]={
		"4444444444444",
		"0000000000000",
		"111GGGGGGGGGG",
		"0000000000000",
		"5555555555555",
		"0000000000000",
		"GGGGGGGGGG111",
		"0000000000000",
		"7777777777777",
		"0000000000000",
		"666GGGGGGGGGG",
		"0000000000000",
		"3333333333333",
		"0000000000000",
		"GGGGGGGGGG111",}		
	}

lives = 3
score = 0

--------------------------
-- STATE MACHINE
--------------------------

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


--------------------------
-- GAMEPLAY STATE
--------------------------

function gameplay_enter()

end

function gameplay_draw()
    draw_background()
    draw_left_margin()
    draw_game_area()
    draw_bricks()
    draw_ball()
    draw_pad()
    draw_pills()
    draw_game_frame()
    draw_hud()
    draw_hud_score()
end

function gameplay_update()
	local button_pressed=false
	--left
	if btn(0) then
		button_pressed = true
		pad.dx =- pad.speed
	end
	--right
	if btn(1) then
		button_pressed = true
		pad.dx = pad.speed
	end
	
	if not button_pressed then
		pad.dx = pad.dx/pad.friction
	end	
	
	pad.x += pad.dx
	pad.x = mid(GAME_X,pad.x,GAME_X + GAME_WIDTH - pad.width - 1)
	
	update_ball()
	update_bricks()
	update_pills()
	update_powerups()
end

gameplay_state = {
    enter = gameplay_enter,
    update = gameplay_update,
    draw = gameplay_draw
}

--------------------------
-- GAMEOVER STATE
--------------------------

function gameover_enter()
end

function gameover_draw()
	cls(24)
	local text = "GAME OVER"
	local x = (SCREEN_WIDTH - #text * 8) / 2
	local y = GAME_Y + GAME_HEIGHT / 2 + 20

	print(text, x+1, y+1, 1)
	print(text, x, y, next_text_color())
end

function gameover_update()
	if btnp(5) then
		change_state(gameplay_state)
	end
end

function gameover_leave()
	start_game()
end

gameover_state = {
    enter = gameover_enter,
    update = gameover_update,
    draw = gameover_draw,
    leave = gameover_leave
}

--------------------------
-- ROUND STATE
--------------------------
local round_timer = 0

function round_enter()
    ball.stuck = true

    bricks = {}
    create_level(round)
	round_timer = 120
end

function round_draw()
	gameplay_draw()
	local text = "ROUND "..round
	local x = GAME_X + (GAME_WIDTH - #text * 8) / 2
	local y = GAME_Y + GAME_HEIGHT / 2 + 20

	print(text, x+1, y+1, 1)
	print(text, x, y, 7)
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


------------------------------------------------------------
-- INIT
------------------------------------------------------------

function start_game()
    lives = 3
    score = 0
    round = 1
    ball.stuck = true
end

function _init()
	init_palette()
	start_game()
	change_state(round_state)
	--create_level(round)	
end

------------------------------------------------------------
-- DRAW
------------------------------------------------------------

function draw_pad()
	draw_pad_shadow()

	local EDGE_WIDTH = 7
	local PAD_HEIGHT = 15
	rectfill(pad.x+EDGE_WIDTH-1,pad.y,pad.x+pad.width-4,pad.y+pad.height-1,0)
	local pad_sprite = pad.sprite
	
	palt(1,true)
	palt(0,false)
	-- Left cap
	sspr(pad_sprite,0,0,EDGE_WIDTH,PAD_HEIGHT,pad.x,pad.y)
	-- Center
	for x = EDGE_WIDTH+1,pad.width-EDGE_WIDTH-2 do
		sspr(pad_sprite,EDGE_WIDTH,0,1,PAD_HEIGHT,pad.x+x,pad.y)
	end
	-- Right cap	
	sspr(pad_sprite,9,0,EDGE_WIDTH,PAD_HEIGHT,pad.x+pad.width-EDGE_WIDTH,pad.y)
	palt()	
end

function draw_pad_shadow_old()
	local _x=pad.x+4
	local _y=pad.y+4
	rectfill(_x+6,_y+2,_x+pad.width-2,_y+pad.height-2,0)
	palt(1,true)
	palt(0,false)
	sspr(11,0,0,7,15,_x,_y)
	for i=8,pad.width-6 do
		sspr(11,7,0,1,15,_x+i,_y)
	end
	sspr(11,9,0,7,15,_x+pad.width-4,_y)
	palt()	
end

function draw_pad_shadow()

	local SHADOW_OFFSET_X = 4
	local SHADOW_OFFSET_Y = 4
	
	local EDGE_WIDTH = 7
	local SPRITE_HEIGHT = 15
	
	local shadow_x = pad.x + SHADOW_OFFSET_X
	local shadow_y = pad.y + SHADOW_OFFSET_Y
	
	-- Shadow body
	rectfill(shadow_x + 6, shadow_y + 2, shadow_x + pad.width - 2, shadow_y + pad.height - 2, 0)
	
	palt(1, true)
	palt(0, false)
	
	-- Left cap
	sspr(11, 0, 0, EDGE_WIDTH, SPRITE_HEIGHT, shadow_x, shadow_y)
	
	-- Center
	for x = EDGE_WIDTH + 1, pad.width - EDGE_WIDTH + 1 do
	    sspr(11, EDGE_WIDTH, 0, 1, SPRITE_HEIGHT, shadow_x + x, shadow_y)
	end
	
	-- Right cap
	sspr(11, 9, 0, EDGE_WIDTH, SPRITE_HEIGHT, shadow_x + pad.width - 4, shadow_y)
	
	palt()

end

function draw_ball()
	--SHADOW
	palt(1,true)
	palt(0,false)
	spr(3,ball.x+2,ball.y+2)	
	palt()

	--circfill(ball.x,ball.y,ball.r,7)
	--BALL
	spr(ball.sprite,ball.x,ball.y)	
end

function draw_background()
    cls(0)
end

function draw_left_margin()
    rectfill(
        0,
        0,
        LEFT_MARGIN - 1,
        SCREEN_HEIGHT - 1,
        0
    )
end

function draw_game_frame_v2()

    -- TOP
    rectfill(
        FRAME_X,
        FRAME_Y,
        FRAME_X + FRAME_WIDTH - 1,
        FRAME_Y + FRAME_SIZE - 1,
        5
    )

    -- LEFT
    rectfill(
        FRAME_X,
        FRAME_Y,
        FRAME_X + FRAME_SIZE - 1,
        SCREEN_HEIGHT - 1,
        5
    )

    -- RIGHT
    rectfill(
        FRAME_X + FRAME_WIDTH - FRAME_SIZE,
        FRAME_Y,
        FRAME_X + FRAME_WIDTH - 1,
        SCREEN_HEIGHT - 1,
        5
    )

end

function draw_game_frame_v3()

    -- TOP
    rectfill(
        FRAME_X,
        FRAME_Y,
        FRAME_X + FRAME_WIDTH - 1,
        GAME_Y - 1,
        5
    )

    -- LEFT
    rectfill(
        FRAME_X,
        FRAME_Y,
        FRAME_X + FRAME_SIZE - 1,
        GAME_BOTTOM,
        5
    )

    -- RIGHT
    rectfill(
        FRAME_X + FRAME_WIDTH - FRAME_SIZE,
        FRAME_Y,
        FRAME_X + FRAME_WIDTH - 1,
        GAME_BOTTOM,
        5
    )

end

function draw_game_frame()
	local left_x  = FRAME_X
	local right_x = FRAME_X + FRAME_WIDTH - FRAME_TILE_SIZE
	local top_y   = FRAME_Y
	local bottom_y = GAME_BOTTOM - FRAME_TILE_SIZE + 1
	
	palt(1, true)
	palt(0, false)
	
	-- Top left corner
	spr(SPR_FRAME_CORNER, left_x, top_y)
	
	-- Top right corner (mirrored)
	spr(SPR_FRAME_CORNER, right_x - 1, top_y, true)
	
	-- Top border
	for x = left_x + 8, right_x - 1 do
		sspr(SPR_FRAME_CORNER, 8, 0, 1, 15, x, top_y)
	end
	
	-- Vertical border
	for y = top_y + 9, bottom_y do
		sspr(SPR_FRAME_DECOR_B, 0, 15, 15, 1, left_x, y)
		sspr(SPR_FRAME_DECOR_B, 0, 15, 15, 1, right_x, y, 15, 1, true)
	end
	
	-- Side decorations
	local section_height = 45
	local sections = 6
	
	for i = 0, sections - 1 do
	
		local y = top_y + 7 + i * section_height
		
		-- Left
		sspr(SPR_FRAME_CORNER, 0, 7, 8, 16, left_x, y)
		sspr(SPR_FRAME_DECOR_A, 0, 0, 15, 16, left_x, y + 8)
		sspr(SPR_FRAME_DECOR_B, 0, 0, 15, 15, left_x, y + 24)
		
		-- Right
		sspr(SPR_FRAME_CORNER, 0, 7, 8, 16, right_x + 7, y, 8, 16, true)
		sspr(SPR_FRAME_DECOR_A, 0, 0, 15, 16, right_x, y + 8, 15, 16, true)
		sspr(SPR_FRAME_DECOR_B, 0, 0, 15, 15, right_x, y + 24, 15, 15, true)
	
	end
	
	-- Top clamps
	local dx = 50
	spr(SPR_FRAME_CLAMP_L, left_x + dx, top_y)
	spr(SPR_FRAME_CLAMP_R, left_x + dx + FRAME_TILE_SIZE, top_y)
	
	dx = 165
	spr(SPR_FRAME_CLAMP_L, left_x + dx, top_y)
	spr(SPR_FRAME_CLAMP_R, left_x + dx + FRAME_TILE_SIZE, top_y)
	
	palt()	
end

function draw_game_area()
   rectfill(
       GAME_X,
       GAME_Y,
       GAME_RIGHT,
       GAME_BOTTOM,
       1
   )
	local tile_w = 23
	local tile_h = 16
	
	local cols = flr((GAME_WIDTH + tile_w - 1) / tile_w)
	local rows = flr((GAME_HEIGHT + tile_h - 1) / tile_h)
	
	for y = 0, rows - 1 do
		for x = 0, cols - 1 do
			spr(
				192,
				GAME_X + x * tile_w - 8,
				GAME_Y + y * tile_h
			)
		end
	end    
    
end

function draw_hud()
    rectfill(
        HUD_X,
        HUD_Y,
        SCREEN_WIDTH - 1,
        SCREEN_HEIGHT - 1,
        0
    )
end

function draw_bricks()

	for brick in all(bricks) do
		if brick.alive then
	
		
			-- Brick body
			rectfill(
				brick.x,
				brick.y,
				brick.x + brick.width,
				brick.y + brick.height,
				brick.col
			)

			if brick.flash > 0 then
    			draw_brick_flash(brick)
			end	
			
			--[[
			-- Black outline
				rect(
				brick.x-1,
				brick.y-1,
				brick.x + brick.width,
				brick.y + brick.height,
				0
			]]
			
			-- Bottom outline
			line(
				brick.x,
				brick.y + brick.height,
				brick.x + brick.width,
				brick.y + brick.height,
				0
			)
			
			-- Right outline
			line(
				brick.x + brick.width,
				brick.y,
				brick.x + brick.width,
				brick.y + brick.height,
				0
			)			
							
			-- Silver highlights
			if brick.type == 9 then
				draw_silver_brick(brick)
			end
			-- Golden highlights
			if brick.type == 10 then
				draw_gold_brick(brick)
			end
			
		
			
		end
	end

end


function draw_brick_flash(brick)

    local phase = 3 - flr(brick.flash / (BRICK_FLASH / 3))
    local t = (BRICK_FLASH - brick.flash) % (BRICK_FLASH / 3)
    t /= (BRICK_FLASH / 3)

    if phase == 0 then

        local x = brick.x + brick.width * t
        local y = brick.y + brick.height * t

        line(x,
             brick.y + brick.height,
             brick.x + brick.width,
             brick.y + brick.height,
             7)

        line(brick.x + brick.width,
             y,
             brick.x + brick.width,
             brick.y + brick.height,
             7)

    elseif phase == 1 then

        rectfill(
            brick.x,
            brick.y,
            brick.x + brick.width,
            brick.y + brick.height,
            7
        )

    else

        local x = brick.x + brick.width * (1 - t)
        local y = brick.y + brick.height * (1 - t)

        line(
            brick.x,
            brick.y,
            x,
            brick.y,
            7
        )

        line(
            brick.x,
            brick.y,
            brick.x,
            y,
            7
        )

    end

end


function draw_silver_brick(brick)
	-- Top highlight
	line(
		brick.x,
		brick.y,
		brick.x + brick.width - 1,
		brick.y,
		7
	)

	-- Left highlight
	line(
		brick.x,
		brick.y,
		brick.x,
		brick.y + brick.height - 1,
		7
	)
	
	-- Bottom shadow
	line(
		brick.x,
		brick.y + brick.height - 1,
		brick.x + brick.width - 1,
		brick.y + brick.height - 1,
		22
	)
	
	-- Right shadow
	line(
		brick.x + brick.width - 1,
		brick.y,
		brick.x + brick.width - 1,
		brick.y + brick.height - 1,
		22
	)
end

function draw_gold_brick(brick)
	-- Top highlight
	line(
		brick.x,
		brick.y,
		brick.x + brick.width - 1,
		brick.y,
		10
	)

	-- Left highlight
	line(
		brick.x,
		brick.y,
		brick.x,
		brick.y + brick.height - 1,
		10
	)
	
	-- Bottom shadow
	line(
		brick.x,
		brick.y + brick.height - 1,
		brick.x + brick.width - 1,
		brick.y + brick.height - 1,
		4
	)
	
	-- Right shadow
	line(
		brick.x + brick.width - 1,
		brick.y,
		brick.x + brick.width - 1,
		brick.y + brick.height - 1,
		4
	)
end

function draw_hud_score()
    local x = HUD_X + 12

    print("A  R  K  A  N  O  I  D", x, 20, 7)

    print("LIVES", x, 50, 8)
    print(lives,  x, 60, 7)

    print("SCORE", x, 90, 8)
    print(score,  x, 100, 7)

    print("ROUND", x, 130, 8)
    print(round,  x, 140, 7)

    print("(C) 2026 DADANBUR", x, SCREEN_HEIGHT - 26, 28)
    print("ALL RIGHTS RESERVED", x, SCREEN_HEIGHT - 16, 28)
    
    draw_active_powerups()
end




------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

function update_bricks()
	for brick in all(bricks) do
		if brick.flash > 0 then
			brick.flash -= 1
		end
	end
end

function update_stuck_ball()
	-- Keep the ball attached to the paddle
	ball.x = pad.x + flr(pad.width / 2) - ball.r
	ball.y = pad.y - ball.r - 2
	
	-- Launch on X
	if btnp(5) then
	    ball.stuck = false
	end
end

function update_ball()

	if ball.stuck then
		update_stuck_ball()
		return
	end

	ball.old_x = ball.x
	ball.old_y = ball.y

	ball.x += ball.dx * ball.speed
	ball.y += ball.dy * ball.speed	
	
	-- LEFT
	if ball.x - ball.r <= GAME_X then
		ball.x = GAME_X + ball.r
		ball.dx = -ball.dx
		sfx(0)
	end
	
	-- RIGHT
	if ball.x + ball.r >= GAME_X + GAME_WIDTH - 1 then
		ball.x = GAME_X + GAME_WIDTH - 1 - ball.r
		ball.dx = -ball.dx
		sfx(0)
	end
	
	-- TOP
	if ball.y - ball.r <= GAME_Y then
		ball.y = GAME_Y + ball.r
		ball.dy = -ball.dy
		sfx(0)
	end	
	
	-- BOTTOM. Ball falls below the bottom of the playfield
	if ball.y - ball.r > SCREEN_HEIGHT then
		sfx(2)
		
		lives -= 1
		
		if lives > 0 then
			reset_ball()
		else
			change_state(gameover_state)
		end
		
		return
	end	
	
	check_ball_paddle()
	check_ball_bricks()
end

function reset_ball()
	ball.stuck = true

	ball.x = pad.x + flr(pad.width / 2)
	ball.y = pad.y - ball.r

end

function check_ball_paddle()

	-- Ignore collision if the ball is moving upwards
	if ball.dy <= 0 then
	    return
	end
	
	-- Check collision with the paddle
	if ball.x + ball.r >= pad.x
	and ball.x - ball.r <= pad.x + pad.width
	and ball.y + ball.r >= pad.y
	and ball.y - ball.r <= pad.y + pad.height then
	
		-- Place the ball above the paddle
		ball.y = pad.y - ball.r
		
		-- Calculate the impact position (0 = left, 1 = right)
		local hit = (ball.x - pad.x) / pad.width
		
		-- Convert to the range [-1, 1]
		hit = hit * 2 - 1
		
		-- Set the new direction
		ball.dx = hit
		ball.dy = -1
		
		-- Normalize the direction vector
		local len = sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
		
		ball.dx /= len
		ball.dy /= len
		
		sfx(1)
	end

end

function check_ball_bricks()

	for brick in all(bricks) do
	
		if brick.alive
			and ball.x + ball.r >= brick.x
			and ball.x - ball.r <= brick.x + brick.width
			and ball.y + ball.r >= brick.y
			and ball.y - ball.r <= brick.y + brick.height then
			
			hit_brick_v3(brick)
			sfx(3)
			return
		
		end
	end

end

function hit_brick(brick)

	if brick.hits > 0 then
		brick.hits -= 1
		
		if brick.hits == 0 then
			brick.alive = false
			score += brick.score
			remaining_bricks -= 1
			if remaining_bricks == 0 then
        		next_round()
        	end
        	spawn_pill(brick.x,brick.y,POWERUP_SLOW)
		end
	end
	
	local from_left   = ball.old_x + ball.r <= brick.x
	local from_right  = ball.old_x - ball.r >= brick.x + brick.width
	local from_top    = ball.old_y + ball.r <= brick.y
	local from_bottom = ball.old_y - ball.r >= brick.y + brick.height

	if from_left or from_right then
		ball.dx = -ball.dx
	else
		ball.dy = -ball.dy
	end
	
	if brick.type == 9 or brick.type == 10 then
		brick.flash = BRICK_FLASH
	end 

end


function hit_brick_v2(brick)
	
	-- Damage the brick
	if brick.hits > 0 then
		brick.hits -= 1
		
		if brick.hits == 0 then
			brick.alive = false
			score += brick.score
			remaining_bricks -= 1
			if remaining_bricks == 0 then
        		next_round()
        	end
        	spawn_pill(brick.x,brick.y,POWERUP_SLOW)
		end
	end
	
	-- Calculate overlap on each axis
	local overlap_left   = (ball.x + ball.r) - brick.x
	local overlap_right  = (brick.x + brick.width) - (ball.x - ball.r)
	local overlap_top    = (ball.y + ball.r) - brick.y
	local overlap_bottom = (brick.y + brick.height) - (ball.y - ball.r)
	
	local overlap_x = min(overlap_left, overlap_right)
	local overlap_y = min(overlap_top, overlap_bottom)
	
	-- Bounce on the axis with the smallest overlap
	if overlap_x < overlap_y then
	
		ball.dx = -ball.dx
		
		-- Move the ball outside the brick
		if ball.dx > 0 then
			ball.x = brick.x - ball.r
		else
			ball.x = brick.x + brick.width + ball.r
		end
	
	else
	
		ball.dy = -ball.dy
		
		-- Move the ball outside the brick
		if ball.dy > 0 then
			ball.y = brick.y - ball.r
		else
			ball.y = brick.y + brick.height + ball.r
		end
	
	end

end


function spawn_random_pill(x,y)
	if rnd() < POWERUP_DROP_CHANCE then
		local powerup = flr(rnd(#powerup_types)) + 1
		spawn_pill(x,y,powerup)
	end
end

function hit_brick_v3(brick)
    if brick.hits > 0 then
        brick.hits -= 1
        if brick.hits == 0 then
            brick.alive = false
            score += brick.score
            remaining_bricks -= 1
            if remaining_bricks == 0 then
                next_round()
            end
            spawn_random_pill(brick.x,brick.y)
        end
    end

    local from_left   = ball.old_x + ball.r <= brick.x
    local from_right  = ball.old_x - ball.r >= brick.x + brick.width
    local from_top    = ball.old_y + ball.r <= brick.y
    local from_bottom = ball.old_y - ball.r >= brick.y + brick.height

    if from_left then
        ball.dx = -ball.dx
        ball.x = brick.x - ball.r
    elseif from_right then
        ball.dx = -ball.dx
        ball.x = brick.x + brick.width + ball.r
    elseif from_top then
        ball.dy = -ball.dy
        ball.y = brick.y - ball.r
    elseif from_bottom then
        ball.dy = -ball.dy
        ball.y = brick.y + brick.height + ball.r
    else
        -- Fallback: bola ya dentro del ladrillo (esquina, alta velocidad)
        -- Usar el eje con menor solapamiento
        local ox = min((ball.x + ball.r) - brick.x, (brick.x + brick.width) - (ball.x - ball.r))
        local oy = min((ball.y + ball.r) - brick.y, (brick.y + brick.height) - (ball.y - ball.r))
        if ox < oy then
            ball.dx = -ball.dx
        else
            ball.dy = -ball.dy
        end
    end

    if brick.type == 9 or brick.type == 10 then
        brick.flash = BRICK_FLASH
    end
end

function create_level(level_index)
	bricks = {}
	remaining_bricks = 0
	local level = levels[level_index]

	for row = 1, #level do

		local level_line = level[row]

		for col = 1, #level_line do

			local elem = sub(level_line, col, col)
	
			-- Empty brick
			if elem ~= BRICK_EMPTY then
	
				local data = brick_types[elem]
	
				if data then
	
					add(bricks, {
						x = BRICKS_X + (col - 1) * (BRICK_WIDTH + BRICK_SPACING_X),
						y = BRICKS_Y + (row - 1) * (BRICK_HEIGHT + BRICK_SPACING_Y),
						width  = BRICK_WIDTH,
						height = BRICK_HEIGHT,
						col   = data.col,
						type  = data.type,
						score = data.score,
						hits  = data.hits,
						flash = 0,
						alive = true
					})
					
					-- Count only breakable bricks
					if data.hits > 0 then
    					remaining_bricks += 1
					end
	
				end
			end
		end
	end
	
end

function next_round()
    round += 1

    if round > #levels then
        -- Game completed
        --change_state(game_completed_state)
        return
    end

    create_level(round)
    reset_ball()

end

local text_anim = {5,5,5,5,5,5,5,5,5,5,5,6,6,7,7,6,6,5}

text_frame = 1

function next_text_color()
    local c = text_anim[text_frame]

    text_frame += 1
    if text_frame > #text_anim then
        text_frame = 1
    end

    return c
end



function spawn_pill(x, y, powerup_type)

    local data = powerup_types[powerup_type]
    if not data then
        return
    end

    local pill = {
        x = x,
        y = y,
        width = 4,
        height = 4,
        type = powerup_type,

        frame = 1,
        timer = 0,

        sprites = data.sprites,
        name = data.name,
        text = data.text,
        label = data.label,
        col = data.color
    }

    add(pills, pill)

end


function update_pills()
	--MOVE PILLS
	for pill in all(pills) do
		update_pill(pill)
	end
end

function update_pill(pill)
   pill.timer += 1
   if pill.timer > 10 then
   		pill.timer = 0
   		pill.frame += 1
   		if pill.frame > 8 then pill.frame=1 end
   end
	pill.y+=0.75
	if pill.y > GAME_BOTTOM  then 
		del(pills,pill)
		return 
	end
	--check collision pill and pad
	if check_collision(pill,pad) then
		del(pills,pill)
		sfx(5)
		--spawn_puft_pill(pill.x,pill.y,pill)
		activate_powerup(pill.type,10*60)
		return  
	end
end

function check_collision(a, b)
	if a.x > b.x + b.width  then return false end
	if a.x + a.width < b.x  then return false end
	if a.y > b.y + b.height then return false end
	if a.y + a.height < b.y then return false end
	
	return true
end


function draw_pill(pill)
	if pill.type == POWERUP_NONE then return end

	spr(SPR_PILL_SHADOW,pill.x+2,pill.y+2)
	spr(pill.sprites[pill.frame],pill.x,pill.y)

end

function draw_pills()
	palt(1,true)
	palt(0,false)
	for pill in all(pills) do
		draw_pill(pill)
	end
	palt()
end

function activate_powerup(kind, duration)
    active_powerups[kind] = duration
end

function deactivate_powerup(kind, duration)
    active_powerups[kind] = nil
end

function draw_active_powerups()

	local x = HUD_X + 8
	local y = HUD_Y + 160
	
	for powerup,time in pairs(active_powerups) do
	
		local p = powerup_types[powerup]
		local blink = time <= 5 * 60 and flr(time / 10) % 2 == 0
		
		if not blink then
			palt(1,true)
			palt(0,false)		
			spr(p.sprites[1], x, y)
			palt()
			print(p.name.." ("..flr(time/60)..")", x + 20, y + 2, p.color)
		end
		
		y += 12
	
	end

end


function update_powerups()
	for powerup,time in pairs(active_powerups) do		
		time -= 1
		
		if time <= 0 then
			deactivate_powerup(powerup)
		else
			active_powerups[powerup] = time
		end
	
	end
end