--[[pod_format="raw",created="2026-08-01 08:06:58",modified="2026-08-01 08:17:28",revision=5]]
POWERUP_DROP_CHANCE = 0.25

POWERUP_NONE			= 0
POWERUP_SLOW			= 1
POWERUP_PLAYER			= 2
POWERUP_CATCH			= 3
POWERUP_ENLARGE		= 4
POWERUP_MEGA			= 5
POWERUP_DISRUPTION	= 6
POWERUP_LASER			= 7
POWERUP_BREAK			= 8
POWERUP_DEMO			= POWERUP_LASER

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
      
}

pills={}
active_powerups = {}


function spawn_random_pill(x,y)
	if rnd() < POWERUP_DROP_CHANCE then
		local powerup = flr(rnd(#powerup_types)) + 1
		if demo_mode then
			spawn_pill(x,y,POWERUP_DEMO)
		else
			spawn_pill(x,y,powerup)
		end
	end
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
	if kind == POWERUP_SLOW then
	    slowball(true)
	    return
	end 
	if kind == POWERUP_ENLARGE then
	    pad.width = PADDLE_WIDTH_LARGE
	    return
	end  
	if kind == POWERUP_CATCH then
	    --ball.stuck = true
	    return
	end 	      
	if kind == POWERUP_PLAYER then
	    lives += 1
	    active_powerups[kind] = 60
	    return
	end  
	if kind == POWERUP_DISRUPTION then
	    multiball(balls[1])
	    active_powerups[kind] = 60
	    return
	end  	 
	if kind == POWERUP_BREAK then
	    next_level()
	    active_powerups[kind] = 60
	    return
	end 
	if kind == POWERUP_MEGA  then
	    megaball(true)
	    return
	end
	if kind == POWERUP_LASER then
		pad.laser = true
		pad.sprite = PADDLE_SPRITE_LASER
		return
	end                 
end

function deactivate_powerup(kind, duration)
	active_powerups[kind] = nil
	if kind == POWERUP_SLOW then
		slowball(false)
		return
	end 
	if kind == POWERUP_ENLARGE then
		pad.width = PADDLE_WIDTH
		return
	end   
	if kind == POWERUP_CATCH then
	    --ball.stuck = false
	    return
	end 	      	  
	if kind == POWERUP_MEGA then
		megaball(false)
		return
	end  
	if kind == POWERUP_LASER then
		pad.laser = false
		pad.sprite = PADDLE_SPRITE
		return
	end 	   
end

function slowball(active)
	for ball in all(balls) do
		if active then
			ball.speed = BALL_SPEED_SLOW
	   else
			ball.speed = BALL_SPEED_NORMAL
	   end	
	end
end

function has_powerup(powerup)
    return active_powerups[powerup] ~= nil
end

function megaball(active)
	for ball in all(balls) do
		if active then
			ball.mega = true
		   ball.sprite = BALL_SPRITE_MEGA
	   else
			ball.mega = false
		   ball.sprite = BALL_SPRITE
	   end	
	end
end

function draw_active_powerups()
	local x = HUD_X + 12
	local y = HUD_Y + 160
	
	for powerup,time in pairs(active_powerups) do
	
		local p = powerup_types[powerup]
		local blink = time <= 5 * 60 and flr(time / 10) % 2 == 0
		
		if not blink then
			palt(1,true)
			palt(0,false)		
			spr(p.sprites[1], x, y)
			palt()
			font_print (p.name, x + 20, y + 1, p.color)
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