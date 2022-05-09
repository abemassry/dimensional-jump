pico-8 cartridge // http://www.pico-8.com
version 29
__lua__


overlay_state = 0

function _init()
	btn_0_state = false
	btn_1_state = false
	btn_2_state = false
	btn_3_state = false
	btn_4_state = false
	btn_5_state = false

	btn_4_press = false
	btn_5_press = false

	overlay_state = 0
	-- overlay_state 0 title screen
	-- overlay_state 1 main play
	-- overlay_state 2 pause
	-- overlay_state 3 end of level
	-- overlay_state 4 transition
	-- overlay_state 5 credits
	level = 1 -- default 1
	pause_length = 5
	score = 0
	score_counter = 0
	score_tabulate = 0
	score1 = 0
	end_stage_control = 0
	transition_timer = 0
	monamie_code={}
	monamie = false
	credit_number = 1
	rolling_credits = false
	rolling_credits_height = 130
	reset_game = false
	i=0
	sintimer=0
	-- music(12, 0, 3)
end

function zero_overlay()
	print('press ❎ or 🅾️ to start', 18, 98, 7)
	print('presented by:', 39, 107, 6)
	print('mass industries', 35, 113, 5)
end

function draw_zero_overlay()
	cls()
	-- map( celx, cely, sx, sy, celw, celh, [layer] )
	pal(7, 12)
	bluepos = sin(sintimer)*5
	res = 5 + bluepos
	map(1, 0, 13+bluepos, 0, 128, 128)
	pal(7, 8)
	redpos = -1*(sin(sintimer)*5)
	map(1, 0, 4+(redpos), 0, 128, 128)
	pal(7, 7)
	map(1, 0, 8, 0, 128, 128)
	zero_overlay()
end

function update_first_level()
	prev_4 = btn_4_press
	if btn(4) then
		btn_4_press = true
	else
		btn_4_press = false
	end
	if prev_4 == false and btn_4_press == true then
		score1 += 1
	end

	if score1 >= 3 then
		overlay_state = 4
	end
end

function draw_first_level()
	rectfill(10,10,120,120,7)
end

function screen_shake(acs)
	local fade = 0.95
	local offset_x=1-rnd(2)
	local offset_y=1-rnd(2)
	if acs == 0 then
		offset_x*=offset
		offset_y*=offset
	end

	camera(offset_x,offset_y)
	offset*=fade
	if offset<0.5 then
		offset=0
	end
end


function draw_end_first_stage_bg(bg_height)
	bg_height+=156
	if (bg_height < 104) then
		if (bg_height == 103) then
			end_stage_control = 1
			music(-1)
			sfx(14)
		end
		bg_height = 104
	end

	spr(192, 0, bg_height, 1, 3)
	spr(192, 8, bg_height, 1, 3)
	spr(192, 16, bg_height, 1, 3)
	spr(193, 24, bg_height, 1, 3)
	spr(198, 32, bg_height, 1, 3)
	if (cloud_token % 2 == 0) then
		for i=1,4 do
			sp=flr(rnd(3))+194
			water_sparkle[i] = sp
		end
	end
	for i=40,72,8 do
		j = flr(i/16)
		spr(water_sparkle[j], i, bg_height, 1, 1)
		spr(210, i, bg_height+8, 1, 2)
	end
	spr(198, 80, bg_height, 1, 3, true, false)
	spr(193, 88, bg_height, 1,3, true, false)
	for i=92,128,8 do
		spr(192, i, bg_height, 1, 3)
	end

end

function draw_score()
	print(flr(score), 2, 2, 5)
end

function draw_transition()
	if score_tabulate == 0 then
		-- TODO: tabulate score at end of level
		score_tabulate = 1
	end
	local multiplier = flr(score/100) * 2
	if multiplier < 1 then
		multiplier = 1
	end
	if score_counter < score then
		score_counter+=multiplier
		sfx(17)
	else
		score_counter = score
		transition_timer += 1
	end
	print('score: '..flr(score_counter), 40, 50, 7)
	if transition_timer > 60 then
		if level == 3 then
			-- call roll credits
			transition_timer = 0
			overlay_state = 5
			music(43, 1000)
		else
			reset_to_next_stage()
		end
	end
end

function reset_to_next_stage()
	overlay_state = 1

	if level == 2 then
		level = 3
		-- music(28, 1000, 3)
	else
		level = 2
		-- music(19, 1000, 3)
	end
	-- overlay_state 0 title screen
	-- overlay_state 1 main play
	-- overlay_state 2 pause
	-- overlay_state 3 end of level
	pause_length = 5
	score_counter = score
	score_tabulate = 0
	
	offset = 0
	end_stage_control = 0
	transition_timer = 0
	i=0

end

function display_credit(credit)
	if (credit == 1) print("the end", 50, 50, 7)
	if (credit == 2) print("winners don't use drugs\n rip william sessions", 20, 50, 7)
	if (credit == 3) then
		print('presented by:', 39, 50, 6)
		print('massindustries', 36, 56, 5)
	end
	pad_left = 4
	if (credit == 4) then
		print('game design', 35 + pad_left, 50, 7)
		spr(79, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(79, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
	end
	if (credit == 5) then
		print('programming', 35 + pad_left, 50, 7)
		spr(79, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
	end
	if (credit == 6) then
		print('art', 52 + pad_left, 50, 7)
		spr(79, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(79, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
		spr(95, 27 + pad_left, 70)
		print('@berrynikki', 36 + pad_left, 71, 7)
	end
	if (credit == 7) then
		print('music', 46 + pad_left, 50, 7)
		spr(79, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(79, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
	end
	if (credit == 8) then
		print('creative directors', 20 + pad_left, 50, 7)
		spr(79, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(79, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
		spr(95, 27 + pad_left, 70)
		print('@berrynikki', 36 + pad_left, 71, 7)
	end

	if (credit == 10) then
		print('with love and support from', 6 + pad_left, 50, 7)
		spr(127, 30 + pad_left, 55)
		print('@mindym121', 38 + pad_left, 57, 7)
		spr(111, 32 + pad_left, 63)
		print('@un1c0rn', 39 + pad_left, 64, 7)
		print('@spidermonkey', 29 + pad_left, 71, 7)
		spr(127, 19 + pad_left, 77)
		print('@siberianfurball', 27 + pad_left, 78, 7)
	end

	if (credit == 11) then
		print('rain drop', 40 + pad_left, 50, 7)
		print('the end', 44 + pad_left, 57, 7)
	end

	if (credit == 12) then
		reset_game = true
	end

end


function rolling_credits_active(y)
	pad_left = 4
	hspr = 0
	htxt = 0
	creative_contributors = {
		'@tory2k',
		'@illblew',
		'@admiralyarrr',
		'@lyn81',
		'@victorycondition',
		'@itsphillc',
		'@lucky_chucky7',
		'@zerotoherodev',
		'@evinjenioso',
		'@displague',
		'@yodadog',
		'@diagnostuck',
		'@puffinplaytv',
		'@alladuss',
		'@rps_75',
		'@machado_tv',
		'@prozacgod',
		'@bigwaterkids12',
		'@arieshothead',
		'@slickshoess',
		'@kr_deepblack'
	}
	print('creative contributors', 22 + pad_left, y, 7)
	for c in all(creative_contributors) do
		hspr = htxt
		hspr+=6
		htxt=hspr+1
		spr(95, 22 + pad_left, y + hspr)
		print(c, 31 + pad_left, y + htxt, 7)
	end
	if (y + htxt < -10) then
		rolling_credits = false
	end
end


function roll_credits()
	print('score: '..flr(score), 0, 0, 5)
	if (rolling_credits == false) then
		transition_timer += 1
		if (transition_timer < 5) then
			pal(7, 5)
			pal(2, 5)
			pal(12, 5)
		end
		if (transition_timer >= 5 and transition_timer < 10) then
			pal(7, 6)
			pal(2, 6)
			pal(12, 6)
		end
		if (transition_timer >= 10 and transition_timer < 110) then
			pal(7, 7)
			pal(2, 2)
			pal(12, 12)
		end
		if (transition_timer >= 110 and transition_timer < 115) then
			pal(7, 6)
			pal(2, 6)
			pal(12, 6)
		end
		if (transition_timer >= 115) then
			pal(7, 5)
			pal(2, 5)
			pal(12, 5)
		end
		display_credit(credit_number)
		if transition_timer > 120 then
			transition_timer = 0
			credit_number += 1
			if credit_number == 9 then
				rolling_credits = true
			end

		end

	else
		pal(7, 7)
		pal(2, 2)
		pal(12, 12)
		rolling_credits_height -= 0.3
		rolling_credits_active(rolling_credits_height)
	end
	if reset_game == true then
		run()
	end

end


function _update60()
	sintimer+=0.005
	if overlay_state == 0 then
		
		if (btn(4) or btn(5)) then
			overlay_state = 1
			-- TODO: check with Kenji about monamie code 
			if (monamie_code[#monamie_code-0] == 1 and
			    monamie_code[#monamie_code-1] == 0 and
			    monamie_code[#monamie_code-2] == 1 and
			    monamie_code[#monamie_code-3] == 0 and
			    monamie_code[#monamie_code-4] == 3 and
			    monamie_code[#monamie_code-5] == 3 and
			    monamie_code[#monamie_code-6] == 2 and
			    monamie_code[#monamie_code-7] == 2) then
				monamie = true
			end

			cls()
			-- music(1, 1000, 3)
			-- start of play
			if not monamie then
			end
		end
		if (btn(0) or btn(1) or btn(2) or btn(3)) then
			btn_0_state = btn(0) -- left
			btn_1_state = btn(1) -- right
			btn_2_state = btn(2) -- up
			btn_3_state = btn(3) -- down
		else
			if (btn_0_state == true and
					btn_1_state == false and
					btn_2_state == false and
					btn_3_state == false) then
				add(monamie_code, 0)
			elseif (btn_0_state == false and
					btn_1_state == true and
					btn_2_state == false and
					btn_3_state == false) then
				add(monamie_code, 1)
			elseif (btn_0_state == false and
					btn_1_state == false and
					btn_2_state == true and
					btn_3_state == false) then
				add(monamie_code, 2)
			elseif (btn_0_state == false and
					btn_1_state == false and
					btn_2_state == false and
					btn_3_state == true) then
				add(monamie_code, 3)
			end

			btn_0_state = false
			btn_1_state = false
			btn_2_state = false
			btn_3_state = false

		end

	elseif overlay_state == 1 then
		i+=1

		if monamie then
		end
		camera(0,0)
		if level == 1 then
			update_first_level()
		end
	-- TODO: if condition for overlay state 4
	-- if negative_altitude > 400 then
	-- end

	-- TODO: if condition for overlay state 2
	-- elseif overlay_state == 2 then

	-- 	pause_length-=1
	-- 	if pause_length == 0 then
	-- 		overlay_state = 1
	-- 		pause_length = 5
	-- 	end

	end

end

function _draw()
	if overlay_state == 0 then
		draw_zero_overlay()
	elseif overlay_state == 1 then
		cls()
		-- above is background

		-- hud
		draw_score()
		-- end hud

		-- below is foreground
		if level == 1 then
			draw_first_level()
		end
	elseif overlay_state == 3 then
		cls()
	elseif overlay_state == 4 then
		cls()
		draw_transition()
	elseif overlay_state == 5 then
		cls()
		roll_credits()
	end

	-- debug area
	print('score1: '..flr(score1), 0, 0, 5)

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000700000007000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000770000000070000070000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000707700000007000700000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000070077000000707000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000700000070000770000070000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000070000007007007700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007000007070000077000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000700000700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007000000070000700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000700000007000070000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000070700000700070000000000000777777000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000007007000070007000000000007000000700000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077770000700070007007000000000070077770070000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000070007000070000700700000000000700700007007000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000070000700007000007070000000007007000000700700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000070000070000700000000000000070070000000070070000000000000000000000000
00000000000000000000000000000000000000000000000000000000700007000007000070000000000000700700000000007007000000000000000000000000
00000000000000000000000000000000000000000000000000000007000000700000700007000000000007007000000000000707000000000000000000000000
00000000000000000000000000000000000000000000000000000070000000070000070000700000000007070000000000000707000000000000000000000000
00000000000000000000000000000000000000000000000000000707000000007000007000000000000007007000000000000707000000000000000000000000
00000000000000000000000000000000000000000000000000007000700000000700007000000000000007000700000000007007000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000000070007000000000000000700070000000070070000000000000000000000000
00000000000000000000000000000000000000000000000000000000007000000007777000000000000000070007000000700700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000700000000000000000000000000007000700007007000000000000000000000000000
00000000000000000000000000000000000000000000000007777000000070000000000000000000000000000700070070070000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000007000000000000000777000000000070007700700000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000000700070000000007000700000000007000007000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000000070700000000070000070000000000700070000000000000000000000000000000
00000000000000000000000000000000000000000007000070000000000000007000000000700070007000000000070007000000000000000000000000000000
00000000000000000000000000000000000000000000700007777777770000070000000000700707000700000000007000700000000000000000000000000000
00000000000000000000000000000000000000000000070000000000007000700000000000700700700070000000000700070000000000000000000000000000
00000000000000000000000000000000000000000000007000000000007000000000000000070070070007000000000070007000000000000000000000000000
00000000000000000000000000000000000000070000000700000000007000000000000000007007007000700000000007000700000000000000000000000000
00000000000000000000000000000000000000007000000070000000007000000000000000000700700700070000000000700070000000000000000000000000
00000000000000000000000000000000000007000707000007000000007000000000777000000070070070007000000000070700000000000000000000000000
00000000000000000000000000000000000070000070070000700077770000000007000700000007007007000700000000007000000000000000000000000000
00000000000000000000000000000000000700000007000700070000000000000070000070000000700700700070000000000000000000000000000000000000
00000000000000000000000000000000007000000000700007007000000000000700077007000000700700070007000000000000000000000000000000000000
00000000000000000000000000000000070000000000070000070700000000000700700700700000070070007000700000000000000000000000000000000000
00000000000000000000000000000000007000000070007000000000000000000700070070070000070070000700070000000000000000000000000000000000
00000000000000000000000000000007000700000700000700000000000000000070007007007700070070000070007000000000000000000000000000000000
00000000000000000000000000000000700070007000000070000000000000000007000700700077770070000007070000000000000000000000000000000000
00000000000000000000000000000007070007070000000007000000000000000000700070070000000070000000700000000000000000000000000000000000
00000000000000000000000000000000707000700000000000000000007000000000070007007700000070000000000000000000000000000000000000000000
00000000000000000000000000070707000700070000000700000000070700000000007000700077777700000000000000000000000000000000000000000000
00000000000000000000000000007070700070007000007000000000700070000000000700070000000000000000000000000000000000000000000000000000
00000000000000000000000007000700070007000700070000000000070007000000000070007000000000000000000000000000000000000000000000000000
00000000000000000000000070000070007000700070700000000000007000700000000007000700000000000000000000000000000000000000000000000000
00000000000000000000000700000007000700070007000000000000000700070000000000700070000000000000000000000000000000000000000000000000
00000000000000000000007070000000700070007000000000000000000070007000000000070007000000000000000000000000000000000000000000000000
00000000000000000000070007000000070007000700000000000000000007000700000000007000700000000000000000000000000000000000000000000000
00000000000000000000000000700000007000700000000000700000000000700070000000000700070000000000000000000000000000000000000000000000
00000000000000000000000000070000000700070000000007070000000000070007000000000070007000000000000000000000000000000000000000000000
00000000000000000777770000007000000070000000000070007000000000007000700000000007070000000000000000000000000000000000000000000000
00000000000000007000007000000700000007000000000007000700000000000700070000000000700000000000000000000000000000000000000000000000
00000000000000070000000700000070000000000000000000700070000000000070007000000000000000000000000000000000000000000000000000000000
00000000000000007000000070000007000700000000000000070007000000000007000700000000000000000000000000000000000000000000000000000000
00000000000000000700000007000000707000000000000000007000700000000000700070000000000000000000000000000000000000000000000000000000
00000000000000000070000000700000070000000007000000000700070000000000070007000000000000000000000000000000000000000000000000000000
00000000000000000007000000070000700000000070700000000070007000000000007007000000000000000000000000000000000000000000000000000000
00000000000000000000700000070007000000000700070000000007000700000000007007000000000000000000000000000000000000000000000000000000
00000000000000000000070000070000000000007000700000000000700070000000070007000000000000000000000000000000000000000000000000000000
00000000000000000000007000070000000000070007000000000000070007000000700070000000000000000000000000000000000000000000000000000000
00000000000000000000000700070000000000700070000000000000007000700007000700000000000000000000000000000000000000000000000000000000
00000000000000000000000070700000000007000007000000000000000700070070007000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000000000070077000700000000000000070007700070000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000700700700070000000000000007000000700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007007000070007000000000000000700007000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070070000007000700000000000000077770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000700700000000700070000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000007007000000000070007000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000007070000000000007000700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000700000000000000700070000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070070000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007007000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007007000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077000070070000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000700777700700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000070000007000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000007777770000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000102030405060708090a0b0c0d0e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
101112131415161718191a1b1c1d1e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
202122232425262728292a2b2c2d2e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
303132333435363738393a3b3c3d3e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404142434445464748494a4b4c4d4e4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505152535455565758595a5b5c5d5e5f00000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606162636465666768696a6b6c6d6e6f00000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707172737475767778797a7b7c7d7e7f00000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
808182838485868788898a8b8c8d8e8f00000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
909192939495969798999a9b9c9d9e9f00000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a8a9aaabacadaeaf00000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9babbbcbdbebf00000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c4c5c6c7c8c9cacbcccdcecf00000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d4d5d6d7d8d9dadbdcdddedf00000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000607080900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000304051617181900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000011314152627282900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000010112324253637383900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000020213334350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000030310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
