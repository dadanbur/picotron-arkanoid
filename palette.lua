--[[pod_format="raw",created="2026-07-27 00:04:05",modified="2026-07-27 06:35:25",revision=20]]
function init_palette()

	PALETTE={
	   "F8F8F8", --WHITE
		"F87800", --ORANGE
		"00B8F8", --CYAN
		"00B800", --GREEN
		"F80000", --RED
		"0058F8", --BLUE
		"F800F8", --VIOLET
		"F8F800", --YELLOW
		"B0B0B0", --SILVER
		"F8B800", --GOLDEN
	}

	PALETTE_POS={
		7, 9, 28, 11, 8, 16, 30, 10, 6, 25
	}

	set_pallete_colors()
end

function set_pallete_colors()
	local base_color = 33
	for i=1,#PALETTE do 
		local palette_color=PALETTE_POS[i]
		dec_color=hex_to_decimal(PALETTE[i])
		set_color(palette_color,dec_color)
	end
	
	find_gfx_map_pids()
	send_palette()
end


function index_of(s,c)
	local index=0
	
	for i=0,#s do
		if sub(s,i,true) == c then
			return i
		end
	end

	return index
end

function hex_to_decimal(s) 
	local DIGITS = "0123456789ABCDEF"
	--s = s.toUpperCase();
	local val = 0
	for i = 1,#s do
		c = sub(s,i,true)
		d = index_of(DIGITS,c)
		val = 16*val + d-1
	end
	return val
end

function set_color(c, code)
	poke4(0x5000 + 4 * c, code)
end

function get_color(c)
	return peek4(0x5000 + 4 * c)
end

function change_color_code(c, code)
	pal_code[c] = code
	pal_okhsl[c] = oklab.color_to_okhsl(pal_code[c])
	set_color(c, code)
end


function change_color(c, hue, sat, lum)
	local hsl = {
		h = hue or pal_okhsl[c].h,
		s = sat or pal_okhsl[c].s,
		l = lum or pal_okhsl[c].l,
	}
	hsl.h = mid(-1.0, hsl.h, 1.0)
	hsl.s = mid(0.0, hsl.s, 1.0)
	hsl.l = mid(0.0, hsl.l, 1.0)
	local code = oklab.okhsl_to_color(hsl)
	pal_code[c] = code
	pal_okhsl[c] = hsl
	set_color(c, code)
	return
end

function find_gfx_map_pids()
	local processes = fetch "/ram/system/processes.pod"
	for i = 1, #processes do
		if processes[i].name == "gfx" then
			picotron_gfx_pid = processes[i].id
		elseif processes[i].name == "map" then
			picotron_map_pid = processes[i].id
		end
	end
end


function send_palette()
	local palette = userdata("i32", 64)
	for c = 0, 63 do
		palette:set(c, get_color(c))
	end
	if picotron_gfx_pid then
		send_message(picotron_gfx_pid, { event = "set_palette", palette = palette })
	end
	if picotron_map_pid then
		send_message(picotron_map_pid, { event = "set_palette", palette = palette })
	end
end