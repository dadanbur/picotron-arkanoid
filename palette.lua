--[[pod_format="raw",created="2026-07-27 00:04:05",modified="2026-08-11 18:28:41",revision=97]]
----------------------------------------------------------------------
-- PALETTE
----------------------------------------------------------------------
-- Custom 64-color palette setup and Picotron IPC sync.
--   init_palette()   -> loads hex colors into Picotron memory (poke4)
--                       and broadcasts the palette to gfx/map editors
--   set_color()      -> writes one RGBA entry at address 0x5000 + 4*c
--   send_palette()   -> sends palette userdata to gfx and map PIDs
--   hex_to_decimal() -> parses a 6-digit hex string to an integer
----------------------------------------------------------------------

PALETTE = {
	-- Original Arkanoid colors
	{pos=6,  color="B0B0B0"}, -- SILVER
	{pos=7,  color="F8F8F8"}, -- WHITE
	{pos=8,  color="F80000"}, -- RED
	{pos=9,  color="F87800"}, -- ORANGE
	{pos=10, color="F8F800"}, -- YELLOW
	{pos=11, color="00B800"}, -- GREEN
	{pos=16, color="0058F8"}, -- BLUE
	{pos=25, color="F8B800"}, -- GOLDEN
	{pos=28, color="00B8F8"}, -- CYAN
	{pos=30, color="F800F8"}, -- VIOLET
	
	-- Ship
	{pos=33, color="BC1F00"},
	{pos=34, color="FF5100"},
	{pos=35, color="626262"},
	{pos=36, color="8F8F8F"},
	{pos=37, color="00009D"},
	{pos=38, color="008FFF"},
	{pos=39, color="00FFFF"},

	-- Blue shades
	{pos=40, color="000062"},
	{pos=41, color="000063"},
	{pos=42, color="000070"},
	{pos=43, color="000071"},
	{pos=44, color="00008f"},
	{pos=45, color="000090"},
	{pos=46, color="00009D"},
	{pos=47, color="00009E"},
	{pos=48, color="0000AF"},
	{pos=49, color="0000BC"},
	{pos=50, color="0000BD"},

	{pos=31, color="00002D"},
	{pos=26, color="000062"}, 
	{pos=27, color="000070"}, 

	
	-- Green shades
	{pos=51, color="006200"},
	{pos=52, color="006300"}, -- "002d00"
	
	{pos=53, color="008F00"},
	{pos=54, color="009000"}, -- "005100"
	
	{pos=55, color="00AE00"},
	{pos=56, color="00AF00"}, -- "007000"

	-- Green shadows
	{pos=57, color="002d00"}, 
	{pos=58, color="002d00"}, 
	{pos=59, color="005100"},
	{pos=60, color="005100"},
	{pos=61, color="007000"},
	{pos=62, color="007000"},
	
	{pos=63, color="2D2D2D"},
}

-- Darkened lookups for the shadow colour table: colour index -> shadow index
DARK_PALETTE = {
	[5]=63  ,[6]=35,  [7]=35,  [8]=24,  [9]=58,  [10]=59, [11]=54,
	[16]=37, [25]=59, [28]=47, [30]=49, [32]=40,
	[33]=58, [34]=59, [35]=40, [36]=35, [37]=40, [38]=46, [39]=46,
	[40]=31, [41]=31, [42]=26, [43]=26, [44]=27, [45]=27,
	[46]=44, [47]=44, [48]=46, [49]=46, [50]=48,
	[51]=57, [52]=58, [53]=59, [54]=60, [55]=61, [56]=62,
	[57]=58, [58]=59, [59]=60, [60]=60
}

function init_palette()
	set_palette_colors()
	init_shadow_table()
end

function set_palette_colors()
	for _, palette_entry in ipairs(PALETTE) do
		local palette_color = palette_entry.pos
		local decimal_color = hex_to_decimal(palette_entry.color)

		set_color(palette_color, decimal_color)
	end

	find_gfx_map_pids()
	send_palette()
end

function init_shadow_table()
	-- Table 1 (0x9000)
	for s = 0, 63 do
		for t = 0, 63 do
			poke(0x9000 + s * 64 + t, t)
		end
	end
	update_shadow_table()
end

function update_shadow_table()
	-- Table 0 (0x8000) shadow row: each target pixel colour is remapped
	-- to its darkened counterpart, plus the 0x40 stencil bit. Rebuilt
	-- every frame because pal()/palt() reset colour table 0 (see font.lua).
	local row = 0x8000 + SHADOW_COL * 64
	for target = 0, 63 do
		local shadow = DARK_PALETTE[target] or SHADOW_COLOR
		poke(row + target, shadow | 0x40)
	end
end

function set_pallete_colors_old()
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