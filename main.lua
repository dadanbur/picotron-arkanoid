--[[pod_format="raw",created="2026-07-26 19:51:34",modified="2026-07-26 22:24:52",revision=90]]
SCREEN_WIDTH  = 480
SCREEN_HEIGHT = 270

TOP_MARGIN  = 16
LEFT_MARGIN = 25
FRAME_SIZE  = 6

GAME_WIDTH  = 220
GAME_HEIGHT = 208

FRAME_WIDTH  = GAME_WIDTH + FRAME_SIZE * 2
FRAME_HEIGHT = GAME_HEIGHT + FRAME_SIZE

FRAME_X = LEFT_MARGIN
FRAME_Y = TOP_MARGIN

GAME_X = FRAME_X + FRAME_SIZE
GAME_Y = FRAME_Y + FRAME_SIZE

HUD_X = FRAME_X + FRAME_WIDTH
HUD_Y = 0
HUD_WIDTH = SCREEN_WIDTH - HUD_X
HUD_HEIGHT = SCREEN_HEIGHT

PADDLE_WIDTH  = 32
PADDLE_HEIGHT = 8
PADDLE_BOTTOM_MARGIN = 16

BRICK_WIDTH  = 16
BRICK_HEIGHT = 8
BRICK_SPACING_X = 1
BRICK_SPACING_Y = 1

BRICKS_X = FRAME_X + FRAME_SIZE
BRICKS_Y = FRAME_Y + FRAME_SIZE + (BRICK_HEIGHT*3) 

pad = {
	x = GAME_X + (GAME_WIDTH - 32) / 2,
	y = SCREEN_HEIGHT - (PADDLE_HEIGHT + PADDLE_BOTTOM_MARGIN),
	width = PADDLE_WIDTH,
	height = PADDLE_HEIGHT,
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
    ["G"] = { col = 9,  type = 10, score = 0,   hits = -1 } -- Gold
}

bricks={}  	
 
levels={
	[1]={
		"SSSSSSSSSSSSS",
  		"5555555555555",
  		"8888888888888",
  		"6666666666666",
  		"7777777777777",
  		"4444444444444"}	  		
  		}

function _init()
	create_level(1)
	
end

lives = 3
score = 0
round = 1

------------------------------------------------------------
-- DRAW
------------------------------------------------------------

function draw_pad()
	rectfill(pad.x,pad.y,pad.x + pad.width,pad.y + pad.height,7)
end

function draw_ball()
	circfill(ball.x,ball.y,ball.r,7)
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

function draw_game_frame()

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

function draw_game_area()
    rectfill(
        GAME_X,
        GAME_Y,
        GAME_X + GAME_WIDTH - 1,
        SCREEN_HEIGHT - 1,
        1
    )
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
			rectfill(
				brick.x,
				brick.y,
				brick.x + brick.width - 1,
				brick.y + brick.height - 1,
				brick.col
			)
		end
	end

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
-- MAIN DRAW
------------------------------------------------------------

function _draw()
    draw_background()
    draw_left_margin()
    draw_game_frame()
    draw_game_area()
    draw_bricks()
    draw_pad()
    draw_ball()
    draw_hud()
    draw_hud_score()
end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

function _update()
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
end

function update_stuck_ball()
	-- Keep the ball attached to the paddle
	ball.x = pad.x + flr(pad.width / 2)
	ball.y = pad.y - ball.r
	
	-- Launch on X
	if btnp(5) then
	    ball.stuck = false
	end
end

function update_ball()

	if ball.stuck then
		update_stuck_ball()
	end

	ball.old_x = ball.x
	ball.old_y = ball.y

	ball.x += ball.dx * ball.speed
	ball.y += ball.dy * ball.speed	
	
	-- LEFT
	if ball.x - ball.r <= GAME_X then
		ball.x = GAME_X + ball.r
		ball.dx = -ball.dx
	end
	
	-- RIGHT
	if ball.x + ball.r >= GAME_X + GAME_WIDTH - 1 then
		ball.x = GAME_X + GAME_WIDTH - 1 - ball.r
		ball.dx = -ball.dx
	end
	
	-- TOP
	if ball.y - ball.r <= GAME_Y then
		ball.y = GAME_Y + ball.r
		ball.dy = -ball.dy
	end	
	
	check_ball_paddle()
	check_ball_bricks()
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
	end

end

function check_ball_bricks()

	for brick in all(bricks) do
	
		if brick.alive
			and ball.x + ball.r >= brick.x
			and ball.x - ball.r <= brick.x + brick.width
			and ball.y + ball.r >= brick.y
			and ball.y - ball.r <= brick.y + brick.height then
			
			hit_brick(brick)
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

end


function hit_brick_v2(brick)
	
	-- Damage the brick
	if brick.hits > 0 then
		brick.hits -= 1
		
		if brick.hits == 0 then
			brick.alive = false
			score += brick.score
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

function create_level(level)

	local level = levels[level]

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
	
						alive = true
					})
	
				end
			end
		end
	end
	
end