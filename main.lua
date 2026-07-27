--[[pod_format="raw",created="2026-07-26 19:51:34",modified="2026-07-27 10:00:18",revision=219]]
include "./palette.lua"

SCREEN_WIDTH  = 480
SCREEN_HEIGHT = 270

TOP_MARGIN  = 8
LEFT_MARGIN = 25
FRAME_SIZE  = 8

GAME_WIDTH  = 222
GAME_HEIGHT = 254

GAME_BOTTOM = SCREEN_HEIGHT

FRAME_WIDTH  = GAME_WIDTH + FRAME_SIZE * 2
FRAME_HEIGHT = GAME_HEIGHT + FRAME_SIZE

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
	x = GAME_X + (GAME_WIDTH - 32) / 2,
	y = SCREEN_HEIGHT - (PADDLE_HEIGHT + PADDLE_BOTTOM_MARGIN),
	width = PADDLE_WIDTH,
	height = PADDLE_HEIGHT,
	sprite = 8,
	dx = 0
}

local d = 1 / sqrt(2)

ball = {
	x = GAME_X + (GAME_WIDTH - 32) / 2,
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


brick_types = {
    ["1"] = { col = 7,  type = 1,  score = 50,  hits = 1 }, -- White
    ["2"] = { col = 9,  type = 2,  score = 60,  hits = 1 }, -- Orange
    ["3"] = { col = 28, type = 3,  score = 70,  hits = 1 }, -- Cyan
    ["4"] = { col = 11, type = 4,  score = 90,  hits = 1 }, -- Green
    ["5"] = { col = 8,  type = 5,  score = 100, hits = 1 }, -- Red
    ["6"] = { col = 16, type = 6,  score = 100, hits = 1 }, -- Blue
    ["7"] = { col = 30, type = 7,  score = 100, hits = 1 }, -- Violet
    ["8"] = { col = 10, type = 8,  score = 50,  hits = 1 }, -- Yellow
    ["S"] = { col = 6,  type = 9,  score = 50,  hits = 2 }, -- Silver
    ["G"] = { col = 25,  type = 10, score = 0,   hits = -1 } -- Gold
}

remaining_bricks = 0
bricks={}  	

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
    ball.stuck = true
    lives = 3
    score = 0
    round = 1
    bricks = {}
    create_level(round)
end

function gameplay_draw()
    draw_background()
    draw_left_margin()
    draw_game_area()
    draw_bricks()
    draw_game_frame()
    draw_ball()
    draw_pad()
    draw_hud()
    draw_hud_score()
end

function gameplay_update()
	local button_pressed=false
	--left
	if btn(0) then
		button_pressed = true
		pad.dx =- 5
	end
	--right
	if btn(1) then
		button_pressed = true
		pad.dx = 5
	end
	
	if not button_pressed then
		pad.dx = pad.dx/1.5
	end	
	
	pad.x += pad.dx
	pad.x = mid(GAME_X,pad.x,GAME_X + GAME_WIDTH - pad.width - 1)
	
	update_ball()
	update_bricks()
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

gameover_state = {
    enter = gameover_enter,
    update = gameover_update,
    draw = gameover_draw
}

------------------------------------------------------------
-- INIT
------------------------------------------------------------

function _init()
	init_palette()
	change_state(gameplay_state)
	--create_level(round)	
end

------------------------------------------------------------
-- DRAW
------------------------------------------------------------

function draw_pad()
	local EDGE_WIDTH = 7
	local PAD_HEIGHT = 15
	--rectfill(pad.x,pad.y,pad.x + pad.width,pad.y + pad.height,7)
	local pad_sprite = pad.sprite
	
	palt(1,true)
	palt(0,false)
	-- Left cap
	sspr(pad_sprite,0,0,EDGE_WIDTH,PAD_HEIGHT,pad.x,pad.y)
	-- Center
	for x = EDGE_WIDTH,pad.width-EDGE_WIDTH-1 do
		sspr(pad_sprite,EDGE_WIDTH,0,1,PAD_HEIGHT,pad.x+x,pad.y)
	end
	-- Right cap	
	sspr(pad_sprite,9,0,EDGE_WIDTH,PAD_HEIGHT,pad.x+pad.width-EDGE_WIDTH,pad.y)
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

	local TILE_SIZE = 16
	
	local left_x  = FRAME_X
	local right_x = FRAME_X + FRAME_WIDTH - TILE_SIZE
	local top_y   = FRAME_Y
	local bottom_y = GAME_BOTTOM - TILE_SIZE + 1
	
	palt(1, true)
	palt(0, false)
	
	-- Top left corner
	spr(24, left_x, top_y)
	
	-- Top right corner (mirrored)
	spr(24, right_x - 1, top_y, true)
	
	-- Top border
	for x = left_x + 8, right_x - 1 do
		sspr(24, 8, 0, 1, 15, x, top_y)
	end
	
	-- Vertical border
	for y = top_y + 9, bottom_y do
		sspr(40, 0, 15, 15, 1, left_x, y)
		sspr(40, 0, 15, 15, 1, right_x, y, 15, 1, true)
	end
	
	-- Side decorations
	local section_height = 45
	local sections = 6
	
	for i = 0, sections - 1 do
	
	local y = top_y + 7 + i * section_height
	
	-- Left
	sspr(24, 0, 7, 8, 16, left_x, y)
	sspr(32, 0, 0, 15, 16, left_x, y + 8)
	sspr(40, 0, 0, 15, 15, left_x, y + 24)
	
	-- Right
	sspr(24, 0, 7, 8, 16, right_x + 7, y, 8, 16, true)
	sspr(32, 0, 0, 15, 16, right_x, y + 8, 15, 16, true)
	sspr(40, 0, 0, 15, 15, right_x, y + 24, 15, 15, true)
	
	end
	
	-- Top clamps
	local dx = 50
	local tam = 16
	spr(25, left_x + dx, top_y)
	spr(26, left_x + dx + tam, top_y)
	
	dx = 165
	spr(25, left_x + dx, top_y)
	spr(26, left_x + dx + tam, top_y)
	
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
				GAME_X + x * tile_w - 5,
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
	
			-- Empty space
			if elem ~= " " then
	
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