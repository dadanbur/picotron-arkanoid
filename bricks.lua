--[[pod_format="raw",created="2026-08-01 08:05:32",modified="2026-08-06 16:41:20",revision=86]]
----------------------------------------------------------------------
-- BRICKS
----------------------------------------------------------------------
-- Brick type definitions, level layout, rendering, and hit logic.
--   brick_types    -> map from level character to brick properties
--   create_level() -> populates bricks[] from the levels[n] string grid
--   hit_brick()    -> resolves bounce direction on ball-brick collision
--   damage_brick() -> reduces hit points; awards score; triggers pill
--   draw_bricks()  -> renders all bricks with type-specific highlights
----------------------------------------------------------------------

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
    [BRICK_GOLD] 		= { col = 25, type = 10, score = 0,   hits = -1 } -- Gold
}

remaining_bricks = 0
bricks={}  

function create_level(level_index)
	bricks = {}
	remaining_bricks = 0
	local level = levels[level_index].pattern
	local bricks_y = GAME_Y + levels[level_index].bricks * 8
	
	for row = 1, #level do
		local level_line = level[row]
		
		for col = 1, #level_line do
		
			local elem = sub(level_line, col, col)
			
			-- Empty brick
			if elem ~= BRICK_EMPTY then			
				local data = brick_types[elem]
				if data then
					create_brick(data,col,row,bricks_y)
					-- Count only breakable bricks
					if data.hits > 0 then
						remaining_bricks += 1
					end			
				end
			end
		end
	end
	
end

function draw_bricks_shadow()
	local shadow_size = 3
	local shadow_color = levels[round].shadow_color or SHADOW_COLOR
	
	for brick in all(bricks) do
		if brick.alive then	
			-- Brick body
			rectfill(
				brick.x + shadow_size,
				brick.y + shadow_size,
				brick.x + brick.width + shadow_size*2,
				brick.y + brick.height + shadow_size*2,
				shadow_color
			)		
		end
	end

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

function update_bricks()
	for brick in all(bricks) do
		if brick.flash > 0 then
			brick.flash -= 1
		end
	end
end

function damage_brick(brick)
	if brick.hits > 0 then
		brick.hits -= 1
		
		if brick.hits == 0 then
			brick.alive = false
			score += brick.score
			remaining_bricks -= 1
			if remaining_bricks == 0 then
        		next_level()
        	end
        	spawn_random_pill(brick.x,brick.y)
		end
	end
end

function deflect_ball(ball, angle)
	local angle1 = atan2(ball.dy, ball.dx)
	local cos_a = cos(angle)
	local sin_a = sin(angle)
	
	local dx = ball.dx * cos_a - ball.dy * sin_a
	local dy = ball.dx * sin_a + ball.dy * cos_a
	
	local length = sqrt(dx * dx + dy * dy)
	
	ball.dx = dx / length
	ball.dy = dy / length
	
	if demo_mode then
		local angle2 = atan2(ball.dy, ball.dx)
		printh(
		    "DEFLECT BALL " ..
		    " angle1=" .. angle1 ..
		    " angle2=" .. angle2
		)
	end	
end

function nudge_ball(ball)
	local BALL_NUDGE_STRENGTH  = 0.35
	local angle1 = atan2(ball.dy, ball.dx)
	ball.dx += (rnd(1) - 0.5) * BALL_NUDGE_STRENGTH
	ball.dy += (rnd(1) - 0.5) * BALL_NUDGE_STRENGTH
	
	local magnitude = sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
	if magnitude > 0 then
		ball.dx /= magnitude
		ball.dy /= magnitude
	end	
	magnitude = sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
	
	--clamp_ball_angle(ball)
	if demo_mode then
		printh(
		    "NUDGE BALL " ..
		    " dx=" .. ball.dx ..
		    " dy=" .. ball.dy ..
		    " magnitude=" .. magnitude
		)
	end	
end

function hit_brick_new(brick, ball)

	-- Mega Ball passes through destructible bricks
	-- but still bounces on indestructible gold bricks.
	if ball.mega and brick.hits >= 0 then
		damage_brick(brick)
		return
	end

	-- Calculate the overlap between the ball and the brick.
	local left = ball.x + ball.r - brick.x
	local right = brick.x + brick.width - (ball.x - ball.r)
	local top = ball.y + ball.r - brick.y
	local bottom = brick.y + brick.height - (ball.y - ball.r)

	local penetration_x = min(left, right)
	local penetration_y = min(top, bottom)

	-- Resolve the collision along the axis with the smallest penetration.
	if penetration_x < penetration_y then

		if ball.x < brick.x + brick.width / 2 then
			ball.x = brick.x - ball.r
			ball.dx = -abs(ball.dx)
		else
			ball.x = brick.x + brick.width + ball.r
			ball.dx = abs(ball.dx)
		end

	else

		if ball.y < brick.y + brick.height / 2 then
			ball.y = brick.y - ball.r
			ball.dy = -abs(ball.dy)
		else
			ball.y = brick.y + brick.height + ball.r
			ball.dy = abs(ball.dy)
		end

	end

	-- Damage the brick after resolving the collision.
	if not ball.mega or brick.hits < 0 then
		damage_brick(brick)
	end

	-- Flash silver/gold bricks.
	if brick.type == 9 or brick.type == 10 then
		brick.flash = BRICK_FLASH
	end

	-- Break periodic trajectories caused by indestructible bricks.
	if brick.type == 10 then
		ball.gold_hits += 1

		if ball.gold_hits >= GOLD_HITS_MAX then
			ball.gold_hits = 0
			-- Add a controlled deflection here if needed.
		end
	else
		ball.gold_hits = 0
		ball.stuck_timer = 0
	end
end


function hit_brick(brick, ball)

	-- Mega Ball passes through destructible bricks
	-- but still bounces on indestructible gold bricks.
	if ball.mega and brick.hits >= 0 then
		damage_brick(brick)
		return
	end

	-- Determine collision direction from previous position
	local from_left = ball.old_x + ball.r <= brick.x
	local from_right = ball.old_x - ball.r >= brick.x + brick.width
	local from_top = ball.old_y + ball.r <= brick.y
	local from_bottom = ball.old_y - ball.r >= brick.y + brick.height

	-- Resolve collision
	if from_left then
		ball.x = brick.x - ball.r
		ball.dx = -abs(ball.dx)
	elseif from_right then
		ball.x = brick.x + brick.width + ball.r
		ball.dx = abs(ball.dx)
	elseif from_top then
		ball.y = brick.y - ball.r
		ball.dy = -abs(ball.dy)
	elseif from_bottom then
		ball.y = brick.y + brick.height + ball.r
		ball.dy = abs(ball.dy)
	else

		-- Ball is already inside the brick.
		-- Push it out using the smallest penetration.

		local left = ball.x + ball.r - brick.x
		local right = brick.x + brick.width - (ball.x - ball.r)
		local top = ball.y + ball.r - brick.y
		local bottom = brick.y + brick.height - (ball.y - ball.r)

		local penetration_x = min(left, right)
		local penetration_y = min(top, bottom)

		if penetration_x < penetration_y then

			if ball.x < brick.x + brick.width / 2 then
				ball.x = brick.x - ball.r
				ball.dx = -abs(ball.dx)
			else
				ball.x = brick.x + brick.width + ball.r
				ball.dx = abs(ball.dx)
			end

		else

			if ball.y < brick.y + brick.height / 2 then
				ball.y = brick.y - ball.r
				ball.dy = -abs(ball.dy)
			else
				ball.y = brick.y + brick.height + ball.r
				ball.dy = abs(ball.dy)
			end

		end
	end

	-- Damage the brick after resolving the collision
	if not ball.mega or brick.hits < 0 then
		damage_brick(brick)
	end

	-- Flash silver/gold bricks
	if brick.type == 9 or brick.type == 10 then
		brick.flash = BRICK_FLASH
	end

	-- Break periodic trajectories caused by indestructible bricks
	if brick.type == 10 then
		ball.gold_hits += 1

		if ball.gold_hits >= GOLD_HITS_MAX then
			local angle = GOLD_DEFLECT * (rnd(1) < 0.5 and -1 or 1)
			--deflect_ball(ball, angle)
			--nudge_ball(ball)
			ball.gold_hits = 0
		end
	else
		ball.gold_hits = 0
		ball.stuck_timer = 0
	end	
	
end


function create_brick(data,col,row,bricks_y)
	add(bricks, {
		x = BRICKS_X + (col - 1) * (BRICK_WIDTH + BRICK_SPACING_X),
		y = bricks_y + (row - 1) * (BRICK_HEIGHT + BRICK_SPACING_Y),
		width  = BRICK_WIDTH,
		height = BRICK_HEIGHT,
		col   = data.col,
		type  = data.type,
		score = data.score,
		hits  = data.hits,
		flash = 0,
		alive = true
	})					
end

function check_bullet_bricks(bullet)

	for brick in all(bricks) do
	
		if brick.alive and
         bullet.x >= brick.x and
         bullet.x <= brick.x + brick.width and
         bullet.y >= brick.y and
         bullet.y <= brick.y + brick.height then
			
			damage_brick(brick)
			del(bullets,bullet)
			sfx(3)
			return true
		
		end
	end

	return false

end