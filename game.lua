--[[pod_format="raw",created="2026-08-01 08:20:22",modified="2026-08-01 08:36:20",revision=6]]
function start_game()
    lives = 3
    score = 0
    round = 1
    ball.stuck = true
    
    if demo_mode then
    	lives = 300
    end
    change_state(intro_state)
end

function init_level()
	ball.stuck = true
	
	active_powerups = {}
	pills = {}
	bricks = {}
	create_level(round)	
end


function next_level()
	next_round()
	if state_manager.current ~= gamecompleted_state then
		change_state(round_state)
	end
end

function next_round()
    round += 1

    if round > #levels then
        -- Game completed
        change_state(gamecompleted_state)
        return
    end

    create_level(round)
    balls = {}
    local b = create_ball()
    add(balls, b)
    reset_ball(ball)

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

function draw_borders_shadow()
	local shadow_size = 6
	
	-- left inner shadow
	rectfill(
		GAME_X,
		GAME_Y,
		GAME_X + shadow_size - 1,
		GAME_BOTTOM,
		shadow_color
	)
	
	-- top inner shadow
	rectfill(
		GAME_X,
		GAME_Y,
		GAME_RIGHT,
		GAME_Y + shadow_size - 1,
		shadow_color
	)

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
   draw_borders_shadow() 
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



function draw_hud_score()
	local x = HUD_X + 12
	
	--print("A  R  K  A  N  O  I  D", x, 20, 7)
	spr(128,x - 8,10)
		
	local y = 80
	font_print("LIVES", x, y, 8)
	font_print(lives.."",  x, y + 10, 7)
	
	y += 25
	font_print("SCORE", x, y, 8)
	font_print(score.."",  x, y + 10, 7)
	
	y += 25
	font_print("ROUND", x, y, 8)
	font_print(round.."",  x, y + 10, 7)
	
	--print("BALLS: "..#balls,x,y+30,7)
	
	font_print("PICOTRON VERSION BY DADANBUR", x - 6, SCREEN_HEIGHT - 16, 16)
	
	draw_active_powerups()
end

function check_collision(a, b)
	if a.x > b.x + b.width  then return false end
	if a.x + a.width < b.x  then return false end
	if a.y > b.y + b.height then return false end
	if a.y + a.height < b.y then return false end
	
	return true
end

starfield = {}
STARFIELD_X = 70
STARFIELD_Y = SCREEN_HEIGHT
STARFIELD_WIDTH=340
STARFIELD_HEIGHT=270
for i=1,500 do
	local x=STARFIELD_X + flr(rnd(STARFIELD_WIDTH))
	local y=STARFIELD_Y + flr(rnd(STARFIELD_HEIGHT))
	local s=rnd(1.5) + 0.5
	--local size = flr(rnd(4))
	add(starfield,{x=x,y=y,speed=s,size=size})
end

function draw_starfield()
	local star_colors = {57, 58, 59, 60}

	for star in all(starfield) do
		local x = star.x
		local y = star.y

		-- Calculate color based on screen height
		local percentage = 1 - y / SCREEN_HEIGHT
		local color_index = 1 + flr(percentage * #star_colors)

		color_index = mid(1, color_index, #star_colors)

		local size = star.size or flr(rnd(4))

		rectfill(
			x,
			y,
			x + size,
			y + size,
			star_colors[color_index]
		)
	end
end

function update_starfield()
	for star in all(starfield) do
		star.y -= star.speed
		if (star.y < 0) then
			star.y = STARFIELD_Y
			star.x = STARFIELD_X + flr(rnd(STARFIELD_WIDTH))
		end	
	end
end
