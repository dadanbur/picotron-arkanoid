--[[pod_format="raw",created="2026-08-01 08:09:35",modified="2026-08-04 09:28:17",revision=48]]
----------------------------------------------------------------------
-- BALL
----------------------------------------------------------------------
-- Ball entity: creation, movement, and collision detection.
--   create_ball()        -> returns a new ball table at paddle position
--   update_ball(b)       -> moves ball; handles wall/paddle/brick hits
--   check_ball_paddle()  -> AABB test with impact-angle steering
--   check_ball_bricks()  -> AABB test; stops at first hit per frame
--   multiball()          -> splits one ball into three directions
--   duplicate_ball()     -> clones a ball preserving speed and state
----------------------------------------------------------------------

balls={}
local d = 1 / sqrt(2)

function draw_balls()
	for b in all(balls) do
		draw_ball(b) 
	end
end

function draw_ball(ball)
	local ball_x = ball.x - ball.r
	local ball_y = ball.y - ball.r
	
	--SHADOW
	palt(1,true)
	palt(0,false)
	spr(3,ball_x + 2,ball_y + 2)	
	palt()

	--BALL
	spr(ball.sprite,ball_x,ball_y)	
end


function update_stuck_ball(ball)
	-- Keep the ball attached to the paddle
	--ball.x = pad.x + flr(pad.width / 2) - ball.r
	ball.x = pad.x + pad.stuck_catch
	ball.y = pad.y - ball.r - 2
	
	-- Launch on X
	if ball.stuck and btnp(5) then
		-- Calculate launch direction from current ball position
		ball.dx, ball.dy = get_paddle_direction(ball.x)
		--ball.dy = -abs(ball.dy)
	   ball.stuck = false
	   pad.stuck_catch = 0
	end
	
end

function update_balls()
	for b in all(balls) do	
		update_ball(b)
	end
end

function update_ball(ball)

	if ball.stuck then
		update_stuck_ball(ball)
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
		
		if #balls <= 1 then
		
			lives -= 1
			
			if lives > 0 then
				balls[1] = create_ball()
				reset_ball(balls[1])
			else
				change_state(gameover_state)
			end
			
		else 
			del(balls,ball)
		end
		
		return
	end	
		
	check_ball_paddle(ball)
	check_ball_bricks(ball)
end

function reset_ball(ball)
	ball.stuck = true
	pad.stuck_catch = flr(pad.width / 2) + 4

	ball.x = pad.x + pad.stuck_catch
	ball.y = pad.y - ball.r

end


function get_paddle_direction(ball_x)
	-- Calculate impact position (0 = left, 1 = right)
	local hit = (ball_x - pad.x) / pad.width
	
	-- Convert to range [-1, 1]
	hit = hit * 2 - 1
	
	-- Set direction
	local dx = hit
	local dy = -1
	
	-- Normalize direction
	local len = sqrt(dx * dx + dy * dy)
	
	return dx / len, dy / len
end


function check_ball_paddle(ball)

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
		
		if has_powerup(POWERUP_CATCH) then
		   ball.stuck = true
			pad.stuck_catch = ball.x - pad.x
			return
		end	
		
		-- Calculate bounce direction
		ball.dx, ball.dy = get_paddle_direction(ball.x)
		
		sfx(1)
	end

end

function check_ball_bricks(ball)

	for brick in all(bricks) do
	
		if brick.alive
			and ball.x + ball.r >= brick.x
			and ball.x - ball.r <= brick.x + brick.width
			and ball.y + ball.r >= brick.y
			and ball.y - ball.r <= brick.y + brick.height then
			
			hit_brick(brick,ball)
			sfx(3)
			return
		
		end
	end

end


function create_ball()
	local ball = {
		x = GAME_X + (GAME_WIDTH - PADDLE_WIDTH) / 2,
		y = SCREEN_HEIGHT - (PADDLE_HEIGHT + PADDLE_BOTTOM_MARGIN),
		old_x = 0,
		old_y = 0,
		r = 2,
		dx = BALL_DIAG,
		dy = -BALL_DIAG,
		sprite = BALL_SPRITE,
		speed = BALL_SPEED_NORMAL,
		stuck = true,
		mega = false
	}
	
	return ball
end

function duplicate_ball(ball)
	local b = create_ball()
	b.x = ball.x
	b.y = ball.y
	b.dx = ball.dx
	b.dy = ball.dy 
	b.ang = ball.ang
	b.speed = ball.speed
	b.mega = ball.mega
	b.sprite = ball.sprite
	b.stuck = false

	return b 
end


function sign(n)
	 if n < 0 then return -1
	 elseif n > 0 then return 1
	 else return 0
	 end
end

function set_angle(ball,ang)
	ball.ang=ang
	if ang == 2 then
		ball.dx = 0.50 * sign(ball.dx)
		ball.dy = 1.30 * sign(ball.dy)
	elseif ang == 0 then
		ball.dx = 1.30 * sign(ball.dx)
		ball.dy = 0.50 * sign(ball.dy)
	else
		ball.dx=sign(ball.dx)
		ball.dy=sign(ball.dy)
	end
end

function multiball(ball)
	local b2 = duplicate_ball(ball)
	local b3 = duplicate_ball(ball)

	set_angle(ball,0)
	set_angle(b2,1)
	set_angle(b3,2)

	add(balls,b2)
	add(balls,b3)
end