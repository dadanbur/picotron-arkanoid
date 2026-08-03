--[[pod_format="raw",created="2026-08-01 08:01:39",modified="2026-08-02 18:06:00",revision=17]]
----------------------------------------------------------------------
-- PADDLE
----------------------------------------------------------------------
-- Paddle entity: state, rendering, and laser weapon.
--   pad              -> global paddle table (position, size, speed)
--   draw_pad()       -> renders paddle body and drop shadow
--   fire_lasers()    -> spawns a paired laser shot at paddle edges
--   update_bullets() -> moves bullets upward; checks brick collision
--   draw_bullets()   -> renders all active bullet sprites
----------------------------------------------------------------------

pad = {
	x = GAME_X + (GAME_WIDTH - PADDLE_WIDTH) / 2,
	y = SCREEN_HEIGHT - (PADDLE_HEIGHT + PADDLE_BOTTOM_MARGIN),
	width = PADDLE_WIDTH,
	height = PADDLE_HEIGHT,
	speed = 5,
	friction=1.5,
	sprite = PADDLE_SPRITE,
	animation = PADDLE_ANIMATION,
	frame = 1,
	dx = 0,
	laser = false,
	stuck_catch=0
}

laser_shots={}

function draw_pad()
	draw_pad_shadow()

	local EDGE_WIDTH = 7
	local PAD_HEIGHT = 15
	rectfill(pad.x+EDGE_WIDTH-1,pad.y,pad.x+pad.width-4,pad.y+pad.height-1,0)
	
	local pad_animation_index = flr(time() * PADDLE_ANIMATION_SPEED) % #pad.animation + 1
	--local pad_sprite = pad.sprite
	local pad_sprite = pad.animation[pad_animation_index]
	
	palt(1,true)
	palt(0,false)
	-- Left cap
	sspr(pad_sprite,0,0,EDGE_WIDTH,PAD_HEIGHT,pad.x,pad.y)
	-- Center
	for x = EDGE_WIDTH+1,pad.width-EDGE_WIDTH-2 do
		sspr(pad.sprite,EDGE_WIDTH,0,1,PAD_HEIGHT,pad.x+x,pad.y)
	end
	-- Right cap	
	sspr(pad_sprite,9,0,EDGE_WIDTH,PAD_HEIGHT,pad.x+pad.width-EDGE_WIDTH,pad.y)
	palt()	
end


function draw_pad_shadow()

	local SHADOW_OFFSET_X = 1
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


function fire_lasers()
	if #laser_shots >= 2 then
		return
	end
	
	local shot = {
		bullets = {
			{
				x = pad.x + 10,
				y = pad.y - 6,
				width = 1,
				height = 2,
				speed = 6
			},
			{
				x = pad.x + pad.width - 10,
				y = pad.y - 6,
				width = 1,
				height = 2,
				speed = 6
			}
		}
	}
		
	add(laser_shots,shot)
end


function update_bullets()
	for shot in all(laser_shots) do
		local delete = false
		for b in all(shot.bullets) do
	
			b.y-=b.speed
			
			--delete = b.y < GAME_Y
			if b.y < GAME_Y then
				delete = true
				break
			end
			if check_bullet_bricks(b) then
				delete = true
				break
         end
		end
		if delete then
			del(laser_shots, shot)
		end	
	end
end

function draw_bullets()
	for shot in all(laser_shots) do
		for bullet in all(shot.bullets) do
			spr(4, bullet.x, bullet.y)
		end
	end
end