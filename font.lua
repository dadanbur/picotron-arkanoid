--[[pod_format="raw",created="2026-08-01 08:02:45",modified="2026-08-01 08:16:41",revision=2]]
FONT = {
    sprite = 56,
    width = 8,
    height = 8,
    spacing = 8,

    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    lookup = {},

    widths = {
        ["I"] = 4,
        ["1"] = 5,
        [" "] = 4
    }
}

function init_font()
	FONT.lookup = {}
	
	for i = 1, #FONT.chars do
		local c = sub(FONT.chars, i, i)
		FONT.lookup[c] = i
	end
end

function font_print(text, x, y, col)

	for i = 1, #text do	
		local c = sub(text, i, i)
		
		if c == " " then	
			x += FONT.widths[" "] or FONT.spacing
		else
			local idx = FONT.lookup[c]
			
			if idx then
			pal(7,col)
			sspr(FONT.sprite,(idx - 1) * FONT.width + 1,1,FONT.width,FONT.height,x,y)
			pal()
			end
			
			x += FONT.widths[c] or FONT.spacing
		
		end	
	end
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
