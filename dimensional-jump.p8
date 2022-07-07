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

	btn_press = {}
	btn_press[0] = false
	btn_press[1] = false
	btn_press[2] = false
	btn_press[3] = false
	btn_press[4] = false
	btn_press[5] = false
	btn_release = {}
	btn_release[0] = false
	btn_release[1] = false
	btn_release[2] = false
	btn_release[3] = false
	btn_release[4] = false
	btn_release[5] = false

	overlay_state = 0
	-- overlay_state 0 title screen
	-- overlay_state 1 main play
	-- overlay_state 2 pause
	-- overlay_state 3 end of level
	-- overlay_state 4 transition
	-- overlay_state 5 credits
	level = 0 -- default 0
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
	timer=0
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

function handle_button_release(btn_num)
	if btn_press[btn_num] == true and btn_release[btn_num] == true then
		btn_press[btn_num] = false
		btn_release[btn_num] = false
	end
	if (btn(btn_num)) then
		print('btn_num'..btn_num, 0, 6, 7)
		btn_press[btn_num] = true
	elseif btn_press[btn_num] == true then
		btn_release[btn_num] = true
	end
	return btn_release[btn_num]
end

function zero_level_start()
	music(0,1000,0)
	zero_level = {
		button_released = false,
		color = 5,
		update=function(self)
			-- handle button press
			self.button_released = handle_button_release(4)
			if (timer == 50) score+=1
			if score > 3 then
				overlay_state = 4
			end
		end,
		draw=function(self)
			-- draw items in here
			self.color = 5
			if (stat(50) != nil) then
				print('stat:'..stat(50), 0, 6, 7)
				if (stat(50) > 19 and stat(50) < 22) self.color = 7
			end
			rectfill(44, 44, 84, 84, self.color)
		end
	}
end
function one_level_start()
	one_level = {
		left_released = false,
		right_released = false,
		start_pos = 0,
		end_pos = 300,
		end_tile = 88,
		player_pos = 1,
		c_override = 0,
		allow_timer = 0,
		t=0,
		update=function(self)
			-- handle button press
			self.right_released = handle_button_release(1)
			if (self.right_released) then
				self.c_override -= 1
				self.start_pos-=1
				self.end_pos-=1
				self.player_pos+=2
				self.allow_timer = true
			end
			if self.allow_timer then
				self.t += 1
				if self.t % 14 == 0 then
					self.allow_timer = false
				end
			end
		end,
		draw=function(self)
			-- draw items in here
			-- initial 1d grid
			local space=0
			local count=0
			for i=self.start_pos,self.end_pos,1 do
				c = 5
				--if (i % 2 == 0 ) c = 6
				if(count == self.player_pos) c = 7
				if (i == self.end_tile) c = 11
				rectfill(space+(i*10)+i-self.t, 64, space+10+(i*10)+i-self.t, 74, c)
				--print(i, space+(i*10)+i-self.t, 84, 7)
				space = space + 2
				count+=1
			end
		end
	}
end
function two_level_start()
	two_level = {
		draw=function(self)
			-- draw items in here
			rectfill(54, 54, 84, 84, 7)
		end,
		update=function(self)
			-- handle button press
			if (btn(4) or btn(5)) then
				overlay_state = 4
			end
		end
	}
end
function three_level_start()
	three_level = {
		draw=function(self)
			-- draw items in here
			rectfill(54, 54, 84, 84, 7)
		end,
		update=function(self)
			-- handle button press
			if (btn(4) or btn(5)) then
				overlay_state = 4
			end
		end
	}
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
	if transition_timer > 120 then
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

	if level == 0 then
		level = 1
		one_level_start()
	elseif level == 1 then
		level = 2
		two_level_start()
		-- music(28, 1000, 3)
	elseif level == 2 then
		level = 3
		three_level_start()
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
		print('dimensional jump', 40 + pad_left, 50, 7)
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
		transition_timer += 0.5
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
	timer+=1
	if (timer > 60) timer=0
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
			zero_level_start()
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

		if level == 0 then
			zero_level:update()
		elseif level == 1 then
			one_level:update()
		elseif level == 2 then
			two_level:update()
		elseif level == 3 then
			three_level:update()
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
		if level == 0 then
			zero_level:draw()
		elseif level == 1 then
			one_level:draw()
		elseif level == 2 then
			two_level:draw()
		elseif level == 3 then
			three_level:draw()
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
	-- print('score1: '..flr(score1), 0, 0, 5)

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
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001056300000000000000000000000000000000000105630000010563000000000000000000000000000000105001056310563000001e5531e6001b7001e30020300204001e5001e500000000000000000
003000001e7341e7201e7201e7101e7101e7101e7101e715000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b7341b7301b7301b7301b7201b7201b7201b7201b7201b7201b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7150000000000000000000000000000000000000000
__music__
00 01024344
00 01034344

