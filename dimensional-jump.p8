pico-8 cartridge // http://www.pico-8.com
version 38
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
	music(20,1000,0)
	-- overlay_state 0 title screen
	-- overlay_state 1 main play
	-- overlay_state 2 pause
	-- overlay_state 3 end of level
	-- overlay_state 4 transition
	-- overlay_state 5 credits
	level = 0 -- default 0
	reset_stage = false
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
	if (reset_stage == false) music(21,1000,0)
	reset_stage = false
	-- TODO: debugging
	overlay_state = 4
	-- TODO: debugging
	zero_level = {
		lscore = 0,
		button_released = false,
		button_release_count = 0,
		color = 5,
		even = false,
		update=function(self)
			-- handle button press
			self.button_released = handle_button_release(4) or handle_button_release(5)
			if (self.button_released) self.button_release_count += 1
			if (self.button_release_count == 1) self.button_released = false
			if (timer == 300) score+=1
			if self.lscore == 10 then
				overlay_state = 4
			end
			if (stat(51) > 14 and self.even == true) self.even = false
			if (stat(51) > 23 and self.even == false) self.even = true
		end,
		draw=function(self)
			-- draw items in here
			self.color = 5
			if (stat(51) != nil) then
				print('beats: '..self.lscore, 0, 6, 7)
				-- print('even:'..(self.even and 'true' or 'false'), 0, 18, 7)
				print('press ❎/🅾️ when', 34, 20, 7)
				print('the object lights up', 27, 26, 7)
				-- print('button:'..(self.button_released and 'true' or 'false'), 0, 24, 7)
				if ((stat(51) > 19 and stat(51) < 24 and self.even == false) or (stat(51) > 10 and stat(51) < 15 and self.even == true)) then
					if (self.button_released) self.lscore += 1
					self.color = 7
				else
					if (self.button_released) self.lscore -= 1
				end
			end
			rectfill(44, 44, 84, 84, self.color)
		end
	}
end
function one_level_start()
	-- TODO: debugging
	overlay_state = 4
	-- TODO: debugging
	if (reset_stage == false) music(20,1000,0)
	reset_stage = false
	one_level = {
		-- todo: max dash value
		-- todo: recharge max dash
		left_released = false,
		right_released = false,
		start_pos = 0,
		end_pos = 300,
		end_tile = 88,
		end_timer = 0,
		player_pos = 5,
		player_screen_pos = 0,
		allow_timer = 0,
		tick_timer = 0,
		dash_jump = false,
		dropping = false,
		fall_anim = 0,
		falling = false,
		fall_override = false,
		enemy_visible = false,
		enemy_start_timer = 0,
		enemy_current_time = 0,
		enemy_pos = 0,
		enemy_fall_anim = 0,
		t=0,
		update=function(self)
			self.enemy_start_timer += 1
			if (self.enemy_start_timer > 300 and self.enemy_visible == false) then
				self.enemy_visible = true
				self.enemy_pos = self.player_pos - 6
			end
			-- handle right button press
			function control()
				self.right_released = handle_button_release(1)
				if (btn(4) and self.right_released and self.player_screen_pos < 130 and self.falling == false) then
					-- handle dash jump mechanic
					self.start_pos-=2
					self.end_pos-=2
					self.player_pos+=4
					self.allow_timer = true
					self.dash_jump = true
					sfx(63)
					if (self.enemy_visible) self.enemy_pos += 2
				elseif (self.right_released and self.player_screen_pos < 130 and self.falling == false) then
					self.start_pos-=1
					self.end_pos-=1
					self.player_pos+=2
					self.allow_timer = true
					self.dash_jump = false
					sfx(62)
					if (self.enemy_visible) self.enemy_pos += 1
				end
			end
			if (self.end_timer == 0) control()
			if self.allow_timer then
				self.t += 1
				if self.t % 14 == 0 then
					self.allow_timer = false
				self.dash_jump = false
				end
			end
			self.tick_timer += 1
			if self.tick_timer > 120 then
				self.allow_timer = true
				--self.start_pos-=1
				self.end_pos-=1
				self.tick_timer = 0
				self.dash_jump = false
			end
			if (self.enemy_pos < self.player_pos and self.tick_timer % 32 == 0) then
				if (self.enemy_visible and flr(rnd(10) > 6) and self.enemy_fall_anim == 0 and self.end_timer == 0) self.enemy_pos += 1
			end

			-- if (self.player_pos > 31 and self.enemy_visible == false and flr(rnd(3)) > 2) then
			-- 	self.enemy_visible = true
			-- 	self.enemy_pos = self.player_pos - 6
			-- end
		end,
		draw=function(self)
			-- draw items in here
			-- initial 1d grid
			local space=0
			local count=0
			local dashx = 0
			local drops = {15, 21, 28, 35, 42}
			--             25  37  51  65  79
			local x1, x2 = 0
			local player_local = self.player_pos - ( (self.player_pos - 5) / 2 )
			if (self.falling and self.tick_timer % 4 == 0) self.fall_anim += 1
			if (self.fall_anim == 1 and self.tick_timer % 4 == 0) sfx(61)
			if (self.fall_anim > 6) then
				self.fall_anim = 6
				if (self.tick_timer > 115) then
					self.fall_override = true
					reset_stage = true
					overlay_state = 4
				end
			end


				
			for i=self.start_pos,self.end_pos,1 do
				c = 5

				local x1 = space+(i*10)+i-self.t
				local x2 = space+10+(i*10)+i-self.t

				if (count == self.enemy_pos and self.player_pos > 31) c = 8

				if(count == self.player_pos) then
					c = 7
					dashx = x1
					self.player_screen_pos = x2
				end

				-- if (count == self.player_pos - 2 and self.player_pos > 31) c = 8
				if (i == self.end_tile) c = 11


				for drop in all(drops) do
					if (i == drop) c = 0
					-- 79 - ((79-5)/2)
					-- if (self.player_pos > 31 and x2 > 64 and i == (player_local - 2)) c = 8
				end
				print('pp:'..self.player_pos, 0, 6, 7)
				print('ep:'..self.enemy_pos, 0, 12, 7)
				if (count < self.player_pos and count < 5) c = 0
				if (count < self.player_pos-1 and count < 7) c = 0
				if (count < self.player_pos-3 and count < 9) c = 0
				if (count < self.player_pos-5 and count < 11) c = 0

				if (self.enemy_pos == count and self.player_pos == count) then
					self.falling = true
					if (self.end_timer == 0) rectfill(x1, 64, x2, 74, 8)
					if (self.fall_anim <= 5) rectfill(x1+self.fall_anim, 64+self.fall_anim, x2-self.fall_anim, 74-self.fall_anim, 7)
				else
					if (self.end_timer == 0) rectfill(x1, 64, x2, 74, c)
				end
				if (c == 7 and x2 < 0) self.falling = true
				if (c == 0) then
					if (self.player_pos == count) then
						if (self.fall_anim <= 5) rectfill(x1+self.fall_anim, 64+self.fall_anim, x2-self.fall_anim, 74-self.fall_anim, 7)
						self.falling = true
					end

					if (self.enemy_pos == count and self.enemy_start_timer > 300) then
						if (self.enemy_current_time == 0) self.enemy_current_time = self.enemy_start_timer
						if (self.enemy_fall_anim <= 5) rectfill(x1+self.enemy_fall_anim, 64+self.enemy_fall_anim, x2-self.enemy_fall_anim, 74-self.enemy_fall_anim, 8)
						print('counted', 0, 18, 7)
						if (self.enemy_start_timer > self.enemy_current_time + 60) then
							self.enemy_fall_anim = 0
							self.enemy_visible = false
							self.enemy_start_timer = 0
						else
							self.enemy_fall_anim += 1
						end
					end
				end
				--print(i, space+(i*10)+i-self.t, 84, 7)
				space = space + 2
				count+=1
				if (count == self.player_pos and i >= (self.end_tile - 1)) then
					-- win level
					self.end_timer += 1
					if (self.end_timer > 0) rectfill(64 - self.end_timer*2,64 - self.end_timer*2,64 + self.end_timer*2, 64 + self.end_timer*2,11)
					if (self.end_timer > 40) overlay_state = 4
				end
			end


			if (self.dash_jump) spr(252,dashx-12, 65, 2, 1)

		end
	}
end
function two_level_blanks()
	return {
		{127,10},
		{126,11},
		{125,12},
		{124,13},
		{123,14},
		{122,15},
		{124, 0},
		{124, 1},
		{124, 2},
		{124, 3},
		{124, 4},
		{124, 5},
		{124, 6},
		{124, 7},
		{124, 8},
		{124, 9},
		{124, 10},
		{124, 11},
		{124, 12},
		{112, 12},
		{113, 12},
		{114, 12},
		{115, 12},
		{116, 12},
		{117, 12},
		{118, 12},
		{119, 12},
		{120, 12},
		{121, 12},
		{122, 12},
		{123, 12},
		{124, 12},
		{120, 2},
		{120, 3},
		{120, 4},
		{120, 5},
		{120, 6},
		{120, 7},
		{120, 8},
		{113, 10},
		{114, 10},
		{115, 10},
		{116, 10},
		{117, 10},
		{115, 4},
		{115, 5},
		{115, 6},
		{115, 7},
		{115, 8}
	}
end
function two_level_start()
	-- TODO: debugging
	overlay_state = 4
	-- TODO: debugging
	if (reset_stage == false) music(20,1000,0)
	reset_stage = false
	two_level = {
		player_posx = 112,
		player_posy = 0,
		player_posx_prev = player_posx,
		player_posy_prev = player_posy,
		dashed = false,
		dashed_prev = false,
		dash_dir = '+h',
		disappear_timer = 0,
		disappear_x = 111,
		disappear_y = -1,
		obstacles = two_level_blanks(),
		tick_timer = 0,
		end_timer = 0,
		lose_timer = 0,
		falling = false,
		enemy_visible = false,
		enemy_posx = 0,
		enemy_posy = 0,
		enemy_win = false,
		enemy_fall_timer = 0,
		update=function(self)
			self.tick_timer += 1
			self.disappear_timer += 1
			if (self.tick_timer > 60) self.tick_timer = 0
			if (self.disappear_timer > 120) then
				self.disappear_timer = 0
				self.disappear_x += 1
				self.disappear_y += 1
			end
			-- handle button presses
			-- handle dash jump mechanic
			self.dashed = false
			function control()
				if (handle_button_release(0)) then
					self.player_posx_prev = self.player_posx
					self.player_posy_prev = self.player_posy
					if (btn(4)) then
						-- these bounds are for dash jumping
						-- it's two less than the bounds below
						if (self.player_posx < 114) then
							self.player_posx-=1
							return
						else
							self.player_posx-=2
							self.dashed = true
							self.dash_dir = '-h'
							return
						end
					else
						self.player_posx-=1
						sfx(62)
						return
					end
				elseif (handle_button_release(1)) then
					self.player_posx_prev = self.player_posx
					self.player_posy_prev = self.player_posy
					if (btn(4)) then
						if (self.player_posx > 125) then
							self.player_posx+=1
							return
						else
							self.player_posx+=2
							self.dashed = true
							self.dash_dir = '+h'
							return
						end
					else
						self.player_posx+=1
						sfx(62)
						return
					end
				elseif (handle_button_release(2)) then
					self.player_posx_prev = self.player_posx
					self.player_posy_prev = self.player_posy
					if (btn(4)) then
						if (self.player_posy < 2) then
							self.player_posy-=1
							return
						else
							self.player_posy -= 2
							self.dashed = true
							self.dash_dir = '-v'
							return
						end
					else
						self.player_posy-=1
						sfx(62)
						return
					end
				elseif (handle_button_release(3)) then
					self.player_posx_prev = self.player_posx
					self.player_posy_prev = self.player_posy
					if (btn(4)) then
						if (self.player_posy > 13) then
							self.player_posy+=1
							return
						else
							self.player_posy+=2
							self.dashed = true
							self.dash_dir = '+v'
							return
						end
					else
						self.player_posy+=1
						sfx(62)
						return
					end
				end

					
					

			end
			if (self.player_posx == self.enemy_posx and self.player_posy == self.enemy_posy) then
				self.falling = true
				self.enemy_win = true
			end
			if (self.player_posx == 127 and self.player_posy == 15) then
				self.end_timer += 1
			elseif (self.falling == true) then
				if (self.lose_timer == 0) sfx(61)
				self.lose_timer += 1
			else
				control()
			end

			if self.lose_timer > 60 then
				map(112, 0, 0, 0, 128, 128)
				reset_stage = true
				overlay_state = 4
			end

			if (self.player_posx > 127) then
				self.player_posx_prev = self.player_posx
				self.player_posy_prev = self.player_posy
				self.player_posx = 127
			end
			if (self.player_posy > 15) then
				self.player_posy_prev = self.player_posy
				self.player_posx_prev = self.player_posx
				self.player_posy = 15
			end
			if (self.player_posx < 112) then
				self.player_posx_prev = self.player_posx
				self.player_posy_prev = self.player_posy
				self.player_posx = 112
			end
			if (self.player_posy < 0) then
				self.player_posx_prev = self.player_posx
				self.player_posy_prev = self.player_posy
				self.player_posy = 0
			end

			-- spawn enemy
			if (self.tick_timer > 40 and self.enemy_visible == false) then
				self.enemy_fall_timer = 0
				self.enemy_falling = false
				self.enemy_visible = true
				self.enemy_posx = flr(rnd(15)) + 112
				self.enemy_posy = flr(rnd(15))
				--self.enemy_posx = 115
				--self.enemy_posy = 6
			end
			-- enemy fall animation counter
			if (self.enemy_visible and self.enemy_falling) self.enemy_fall_timer += 1

			-- enemy reset after falling
			if (self.enemy_fall_timer > 60 and self.tick_timer == 0) then
				self.enemy_visible = false
				self.enemy_fall_anim = 0
			end

			-- temp end
			-- 127,15

			function enemy_ai()
				if (self.enemy_falling) return
				if self.enemy_visible and self.tick_timer % 45 == 0 then
					local condition_x = abs(self.player_posx - self.enemy_posx)
					local condition_y = abs(self.player_posy - self.enemy_posy)

					if (condition_x >= condition_y) then
						if (self.player_posx > self.enemy_posx) then
							self.enemy_posx+=1
						elseif (self.player_posx < self.enemy_posx) then 
							self.enemy_posx-=1
						end
					else
						if (self.player_posy > self.enemy_posy) then
							self.enemy_posy+=1
						elseif (self.player_posy < self.enemy_posy) then
							self.enemy_posy-=1
						end
					end
				end
			end
			enemy_ai()

		end,
		draw=function(self)
			-- draw items in here
			local i = 0
			local j = 0
			map(112, 0, 0, 0, 128, 128)
			for i=111,127,1 do
				for j=-1,15,1 do
					mset(i, j, 255)
				end
			end
			mset(self.player_posx, self.player_posy, 254)
			print('ppx:'..self.player_posx, 0, 6, 7)
			print('ppy:'..self.player_posy, 0, 12, 7)
			print('epx:'..self.enemy_posx, 0, 18, 7)
			print('epy:'..self.enemy_posy, 0, 24, 7)
			function dash_unset()
				mset(self.player_posx_prev+1, self.player_posy_prev, 255)
				mset(self.player_posx_prev-1, self.player_posy_prev, 255)
				mset(self.player_posx_prev, self.player_posy_prev+1, 255)
				mset(self.player_posx_prev, self.player_posy_prev-1, 255)
				mset(self.player_posx_prev-2, self.player_posy_prev-2, 255)
				mset(self.player_posx_prev+2, self.player_posy_prev+2, 255)
				mset(self.player_posx_prev+2, self.player_posy_prev-2, 255)
				mset(self.player_posx_prev-2, self.player_posy_prev+2, 255)
			end


			if (self.player_posx and self.player_posy) then
				mset(self.player_posx+1, self.player_posy, 255)
				mset(self.player_posx-1, self.player_posy, 255)
				mset(self.player_posx, self.player_posy+1, 255)
				mset(self.player_posx, self.player_posy-1, 255)
				mset(self.player_posx-2, self.player_posy-2, 255)
				mset(self.player_posx+2, self.player_posy+2, 255)
				mset(self.player_posx+2, self.player_posy-2, 255)
				mset(self.player_posx-2, self.player_posy+2, 255)
				mset(self.player_posx, self.player_posy-2, 255)
				mset(self.player_posx, self.player_posy+2, 255)
				mset(self.player_posx+2, self.player_posy, 255)
				mset(self.player_posx-2, self.player_posy, 255)
			end

			if (self.player_posx >= 112 and self.player_posx <= 127 and self.player_posy >= 0 and self.player_posy <= 15) then
				mset(self.player_posx, self.player_posy, 254)

				if (self.dashed) then
					if (self.dashed_prev) then
						dash_unset()
					end
					if (self.dash_dir == '+h') mset(self.player_posx_prev+1, self.player_posy_prev, 251)
					if (self.dash_dir == '-h') mset(self.player_posx_prev-1, self.player_posy_prev, 251)
					if (self.dash_dir == '+v') mset(self.player_posx_prev, self.player_posy_prev+1, 250)
					if (self.dash_dir == '-v') mset(self.player_posx_prev, self.player_posy_prev-1, 250)
					sfx(63)
					self.dashed_prev = true
				else
					mset(self.player_posx_prev, self.player_posy_prev, 255)
					if (self.dashed_prev) then
						dash_unset()
						self.dashed_prev = false
					end
				end
			end
			if (self.enemy_visible and self.enemy_falling == false) mset(self.enemy_posx, self.enemy_posy, 239)

			mset(127,15,249)
			if (self.player_posx == 127 and self.player_posy == 15) then
				mset(127,15,254)
				if (self.end_timer > 40) overlay_state = 4
			end
			for i=111,self.disappear_x,1 do
				for j=-1,self.disappear_y,1 do
					mset(i, j, 248)
					if (self.player_posx == i and self.player_posy == j) then
						mset(i, j, 247)
						self.falling = true
						if (self.lose_timer > 30) mset(i, j, 246)
						if (self.lose_timer > 45) mset(i, j, 248)
					end
				end
			end

			if (self.enemy_win) then
				if (self.lose_timer > 20) mset(self.player_posx, self.player_posy, 238)
				if (self.lose_timer > 35) mset(self.player_posx, self.player_posy, 237)
				if (self.lose_timer > 45) mset(self.player_posx, self.player_posy, 239)
			end
				
			for key,value in pairs(self.obstacles) do
				mset(value[1], value[2], 248) -- black square representing drop

				-- player falls down
				if (self.player_posx == value[1] and self.player_posy == value[2]) then
					mset(value[1], value[2], 247)
					self.falling = true
					if (self.lose_timer > 30) mset(value[1], value[2], 246)
					if (self.lose_timer > 45) mset(value[1], value[2], 248)
				end

				-- enemy falls down
				if (self.enemy_posx == value[1] and self.enemy_posy == value[2]) then
					mset(value[1], value[2], 239)
					self.enemy_falling = true
					if (self.enemy_fall_timer > 30) mset(value[1], value[2], 236)
					if (self.enemy_fall_timer > 45) mset(value[1], value[2], 235)
					if (self.enemy_fall_timer > 55) mset(value[1], value[2], 248)
				end

				-- show dashed line of player dashing past drop
				if (self.player_posx_prev and self.dashed) then
					if (self.dash_dir == '+h') mset(self.player_posx_prev+1, self.player_posy_prev, 251)
					if (self.dash_dir == '-h') mset(self.player_posx_prev-1, self.player_posy_prev, 251)
					if (self.dash_dir == '+v') mset(self.player_posx_prev, self.player_posy_prev+1, 250)
					if (self.dash_dir == '-v') mset(self.player_posx_prev, self.player_posy_prev-1, 250)
				end
			end

			-- win condition hit
			if (self.end_timer > 0) rectfill(64 - self.end_timer*2,64 - self.end_timer*2,64 + self.end_timer*2, 64 + self.end_timer*2,11)

		end
	}
end

function setup_block(x, y, z, depth, s, u, c, blocksize)
	x0=(x-blocksize)+(z)
	y0=(y-blocksize)+(z)
	x1=(x+blocksize)-z
	y1=(y+blocksize)-(z)

	iz=depth

	xx0=x0+iz+2
	yy0=y0-iz+2
	xx1=x1+iz-2
	yy1=y1-iz-2
	if iz < 3 then
		rectfill(xx0,yy0,xx1,yy1,c)
	else
		draw_block(x0+s,x1+s,y0+u,y1+u,xx0,xx1,yy0,yy1,c)
	end
end

function draw_block(x0,x1,y0,y1,xx0,xx1,yy0,yy1,c)
	palt(0, false)
	rectfill(xx0,yy0,xx1,yy1,0)
	rect(xx0,yy0,xx1,yy1,c)
	palt(0, true)
	rect(x0-2,y0,x1-2,y1,c)
	line(xx0,yy0,x0-2,y0,c)
	line(xx1,yy0,x1-2,y0,c)
	line(xx0,yy1,x0-2,y1,c)
	line(xx1,yy1,x1-2,y1,c)
end

function determine_color(self, i, column)

	if (self.prevcurrent == ((column-3) * -1) and self.jumppress == true and i == self.lvl) return 7
	if (self.endgoallevel == (self.jumplevel) and self.jumppress == true and i == 0 and self.endblocky == i and self.endblockx == column) return 11
	if (self.endgoallevel == (self.jumplevel+1) and self.jumppress == false and i == 0 and self.endblocky == i and self.endblockx == column) return 11
	if (self.enemy_slice == self.jumplevel and self.jumppress == true and i == self.enemyy and column == self.enemyx) return 8
	if (self.enemy_slice == (self.jumplevel+1) and self.jumppress == false and i == self.enemyy and column == self.enemyx) return 8
	return 5
end

function determine_color_first_layer(self, j, column)
	if (self.current == ((column * -1) + 3) and j == self.lvl) return 7
	if (self.jumppress == false and self.endgoallevel == self.jumplevel and self.endblocky == j and self.endblockx == column) return 11
	if (self.jumppress == false and self.enemy_slice == self.jumplevel and j == self.enemyy and column == self.enemyx) return 8
	return 5
end

function three_level_start()
	if (reset_stage == false) music(20,1000,0)
	reset_stage = false
	three_level = {
		u=0,
		current= 0,
		prevcurrent = 0,
		lvl = 0,
		xnudge = 0,
		xcpos = 0,
		jumpanim = 0,
		startanim = 0,
		blocksize = 8,
		leftpress = false,
		rightpress = false,
		uppress = false,
		downpress = false,
		jumppress = false,
		jumplevel = 0,
		jumptimer = 0,
		jumptimerset = false,
		end_timer = 0,
		endgoallevel = 3, -- change to 24?
		endblockx = 0, --flr(rnd(6)),
		endblocky = 0, --flr(rnd(3)),
		enemy_slice = 3,
		enemyx = 6, --flr(rnd(6)),
		enemyy = 0, --flr(rnd(3)),
		enemy_visible = true,
		tick_timer = 0,

		update=function(self)
			self.tick_timer += 1
			-- if (self.tick_timer > 60) self.tick_timer = 0
			function control3d()
				-- current = 0
				if(btn(0)) then
					self.leftpress = true
				end
				if(btn(1)) then
					self.rightpress = true
				end
				if self.xnudge > 3 then
					self.xnudge = 3
				end
				if self.xnudge < -3 then
					self.xnudge = -3
				end

				if(btn(2)) then
					self.uppress = true
				end
				if(btn(3)) then
					self.downpress = true
				end
				if(btn(4) and self.jumptimer == 0) then
					if (self.jumppress == false) self.prevcurrent = self.current
					sfx(63)
					self.jumppress = true
					self.jumptimerset = true
					self.jumplevel += 1
				end
				if(btn(5) and self.jumptimer == 0) then
					if (self.jumppress == false) self.prevcurrent = self.current
					sfx(63)
					self.jumppress = true
					self.jumptimerset = true
					self.jumplevel += 1
				end

				if ((not btn(0)) and (not btn(1)) and (not btn(2)) and (not btn(3)) and (not btn(4)) and (not btn(5)))then
					if (self.leftpress == true) then
						sfx(62)
						self.xnudge+=1
						self.current-=1
						self.xcpos+=20
						self.leftpress = false
					end
					if (self.rightpress == true) then
						sfx(62)
						self.xnudge-=1
						self.current+=1
						self.xcpos-=20
						self.rightpress = false
					end
					if (self.uppress == true) then
						sfx(62)
						self.lvl -= 1
						self.uppress = false
					end
					if (self.downpress == true) then
						sfx(62)
						self.lvl += 1
						self.downpress = false
					end
					if (self.jumptimerset == true) then
						self.jumptimerset = false
						self.jumptimer = 0
					end
				end

				if self.xcpos > 60 then
					self.xcpos = 60
				end
				if self.xcpos < -60 then
					self.xcpos = -60
				end
				if self.current > 3 then
					self.current = 3
				end
				if self.current < -3 then
					self.current = -3
				end

				if self.lvl < 0 then
					self.lvl = 0
				end

				if self.lvl > 3 then
					self.lvl = 3
				end

				if (self.jumppress == true) then
					self.current = -10
					if (self.startanim > 5) then
						self.jumpanim -= 5.95
					end
				end

				if (self.jumpanim < -75) then
					self.jumpanim = 0
					self.jumppress = false
					self.current = self.prevcurrent
					self.startanim = 0
					self.blocksize = 8
				end
				if (self.jumptimerset == true) self.jumptimer += 1
				if (self.jumptimer > 120) then
					self.jumptimer = 0
					self.jumptimerset = false
				end

			end
			if self.jumplevel == self.endgoallevel and self.endblockx == ((self.current-3)*-1) and self.endblocky == self.lvl then
				self.end_timer += 1
			else
				control3d()
			end

			-- self.lvl is y the top is 0 and it goes down to 3
			-- self.current is x, the middle is 0 left is -3 right is 3
			function enemy_ai3d()
				if self.enemy_visible and self.tick_timer % 45 == 0 then
					-- local condition_x = abs(self.player_posx - self.enemy_posx)
					-- local condition_y = abs(self.player_posy - self.enemy_posy)
					self.enemyx -= 1
					self.enemyy += 1

					-- if (condition_x >= condition_y) then
					-- 	if (self.player_posx > self.enemy_posx) then
					-- 		self.enemy_posx+=1
					-- 	elseif (self.player_posx < self.enemy_posx) then 
					-- 		self.enemy_posx-=1
					-- 	end
					-- else
					-- 	if (self.player_posy > self.enemy_posy) then
					-- 		self.enemy_posy+=1
					-- 	elseif (self.player_posy < self.enemy_posy) then
					-- 		self.enemy_posy-=1
					-- 	end
					-- end
				end
			end
			if (self.tick_timer > 200) enemy_ai3d()
			if (self.end_timer > 60) overlay_state = 4

		end,

		draw=function(self)
			cls()
			print('pvc:'..self.prevcurrent, 0, 0, 7)
			print('lvl:'..self.lvl, 0, 6, 7)
			print('cur:'..self.current, 0, 12, 7)
			for i=0,0 do
				if (self.jumpanim == 0) then
					ydiff = -17 + (i * 20) - (self.lvl*4)
				else
					ydiff = -17 + (i * 20) - (self.lvl*4) - (self.jumpanim * .2)
				end

				zdiff = 7
				depth = 2
				self.blocksize = 8
				if (self.lvl > 0) ydiff = ydiff + 5
				if (self.lvl >= 3) ydiff = ydiff + 6
				if (self.lvl < 3) then
					setup_block(self.xcpos+64+57,64+ydiff,zdiff,depth,12+self.xnudge,self.u,5,self.blocksize)
					setup_block(self.xcpos+64+37,64+ydiff,zdiff,depth,10+self.xnudge,self.u,5,self.blocksize)
					setup_block(self.xcpos+64+20,64+ydiff,zdiff,depth,8+self.xnudge,self.u,5,self.blocksize)
					setup_block(self.xcpos+64+3,64+ydiff,zdiff,depth,7+self.xnudge,self.u,5,self.blocksize)
					setup_block(self.xcpos+64-15,64+ydiff,zdiff,depth,4+self.xnudge,self.u,5,self.blocksize)
					setup_block(self.xcpos+64-32,64+ydiff,zdiff,depth,2+self.xnudge,self.u,5,self.blocksize)
					setup_block(self.xcpos+64-52,64+ydiff,zdiff,depth,0+self.xnudge,self.u,5,self.blocksize)
				end
			end
			if (self.lvl <= 3) then
				for i=0,3 do
					if (self.jumpanim == 0) then
						if (i > 0) then
							break
						end
						ydiff = -10 + (i * 20) - (self.lvl*4)
						self.blocksize = 8
						zdiff = 3
						ja5 = 0
						ja5n = 0
						ja2 = 0
						ja2n = 0
					else
						ydiff = - 10 + (i * 20) - (self.lvl*4) - (self.jumpanim * .2)
						self.blocksize = 8 - (self.jumpanim *.02)
						zdiff = 3  + (self.jumpanim * .02)
						ja5 = 5 + (self.jumpanim *.06)
						ja5n = -5 - (self.jumpanim *.06)
						ja2 = 2 + (self.jumpanim *.06)
						ja2n = -2 - (self.jumpanim *.06)
						if (self.lvl >= 3) ydiff = ydiff + 10
					end
					depth = 5
					if (self.lvl > 0) ydiff = ydiff + 5 + (self.jumpanim * .2)
					if (self.lvl >= 3) ydiff = ydiff + 6 + (self.jumpanim * .2)
					-- render second layer
					c = determine_color(self, i, 0)
					setup_block(ja5+self.xcpos+64+55,64+ydiff,zdiff,depth,12+self.xnudge,self.u,c,self.blocksize)
					c = determine_color(self, i, 1)
					setup_block(ja5+self.xcpos+64+35,64+ydiff,zdiff,depth,10+self.xnudge,self.u,c,self.blocksize)
					c = determine_color(self, i, 2)
					setup_block(ja2+self.xcpos+64+18,64+ydiff,zdiff,depth,8+self.xnudge,self.u,c,self.blocksize)
					c = determine_color(self, i, 3)
					setup_block(self.xcpos+64,64+ydiff,zdiff,depth,7+self.xnudge,self.u,c,self.blocksize)
					c = determine_color(self, i, 4)
					setup_block(ja2n+self.xcpos+64-18,64+ydiff,zdiff,depth,4+self.xnudge,self.u,c,self.blocksize)
					c = determine_color(self, i, 5)
					setup_block(ja5n+self.xcpos+64-35,64+ydiff,zdiff,depth,2+self.xnudge,self.u,c,self.blocksize)
					c = determine_color(self, i, 6)
					setup_block(ja5n+self.xcpos+64-55,64+ydiff,zdiff,depth,0+self.xnudge,self.u,c,self.blocksize)
				end
			end
			for j=0,3 do
				if (self.jumpanim < -2) then
					break
				end
				i= (self.jumpanim * .5)
				if (self.jumpanim == 0) then
					self.blocksize = 8
					ydiff = j*22 - (self.lvl*4)
				else
					ydiff = j*22 - (self.lvl*4) - (self.jumpanim * .2)
					self.blocksize = 8 - (self.jumpanim * .02)
				end
				i = 0
				depth = 5
				-- render first layer
				if (j == self.lvl) u = -(j-0.5)
				c = determine_color_first_layer(self, j, 0)
				setup_block(self.xcpos+64+60,64+ydiff,i,depth,12+self.xnudge,self.u,c,self.blocksize)
				c = determine_color_first_layer(self, j, 1)
				setup_block(self.xcpos+64+40,64+ydiff,i,depth,11+self.xnudge,self.u,c,self.blocksize)
				c = determine_color_first_layer(self, j, 2)
				setup_block(self.xcpos+64+20,64+ydiff,i,depth,9+self.xnudge,self.u,c,self.blocksize)
				c = determine_color_first_layer(self, j, 3)
				setup_block(self.xcpos+64,64+ydiff,i,depth,7+self.xnudge,self.u,c,self.blocksize)
				c = determine_color_first_layer(self, j, 4)
				setup_block(self.xcpos+64-20,64+ydiff,i,depth,4+self.xnudge,self.u,c,self.blocksize)
				c = determine_color_first_layer(self, j, 5)
				setup_block(self.xcpos+64-40,64+ydiff,i,depth,2+self.xnudge,self.u,c,self.blocksize)
				c = determine_color_first_layer(self, j, 6)
				setup_block(self.xcpos+64-60,64+ydiff,i,depth,0+self.xnudge,self.u,c,self.blocksize)
			end
			if (self.jumppress == true) self.startanim += 1
			if (self.end_timer > 0) rectfill(64 - self.end_timer*2,64 - self.end_timer*2,64 + self.end_timer*2, 64 + self.end_timer*2,11)
		end
	}
end

function draw_score()
	-- TODO: possibly remove
	-- print(flr(score), 2, 2, 5)
end

function draw_transition()
	if (reset_stage) then
		print('you disappeared', 36, 50, 7)
		print('from existence', 38, 60, 7)
		transition_timer += 1
		if (transition_timer > 120) reset_to_next_stage()
	else
		-- TODO: fade out music, do transition
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
				music(53, 1000)
			else
				reset_to_next_stage()
			end
		end
	end
end

function reset_to_next_stage()
	overlay_state = 1
	transition_timer = 0

	-- TODO: debug
	-- level = 1
	-- TODO: debug
	if level == 0 then
		if (reset_stage) then
			zero_level_start()
			return
		end
		level = 1
		one_level_start()
	elseif level == 1 then
		if (reset_stage) then
			one_level_start()
			return
		end
		level = 2
		two_level_start()
		-- music(28, 1000, 3)
	elseif level == 2 then
		if (reset_stage) then
			two_level_start()
			return
		end
		level = 3
		three_level_start()
		-- music(19, 1000, 3)
	elseif level == 3 then
		if (reset_stage) then
			three_level_start()
			return
		end
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
		spr(242, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(242, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
	end
	if (credit == 5) then
		print('programming', 35 + pad_left, 50, 7)
		spr(242, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
	end
	if (credit == 6) then
		print('art', 52 + pad_left, 50, 7)
		spr(242, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(242, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
		spr(243, 27 + pad_left, 70)
		print('@berrynikki', 36 + pad_left, 71, 7)
	end
	if (credit == 7) then
		print('music', 46 + pad_left, 50, 7)
		spr(242, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(242, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
	end
	if (credit == 8) then
		print('creative directors', 20 + pad_left, 50, 7)
		spr(242, 28 + pad_left, 55)
		print('@abemassry', 37 + pad_left, 57, 7)
		spr(242, 21 + pad_left, 62)
		print('@kenjihasegawa', 30 + pad_left, 64, 7)
		spr(243, 27 + pad_left, 70)
		print('@berrynikki', 36 + pad_left, 71, 7)
	end

	if (credit == 10) then
		print('with love and support from', 6 + pad_left, 50, 7)
		spr(245, 30 + pad_left, 55)
		print('@mindym121', 38 + pad_left, 57, 7)
		spr(244, 32 + pad_left, 63)
		print('@un1c0rn', 39 + pad_left, 64, 7)
		print('@spidermonkey', 29 + pad_left, 71, 7)
		spr(245, 19 + pad_left, 77)
		print('@siberianfurball', 27 + pad_left, 78, 7)
	end

	if (credit == 11) then
		print('dimensional jump', 27 + pad_left, 50, 7)
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
		spr(243, 22 + pad_left, y + hspr)
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
	sintimer+=0.004
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888800888888008888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888800088888800877778008888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008800000888800088778800877778008888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008800000888800088778800877778008888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888800088888800877778008888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888800888888008888880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cc000cc002222222000800000cd444500000000000000000000000000bbbbbb0057557500555555077777777777777000777777005555550
00000000000000000cc0cccc020000020097f0000e4554400000000000777700000000000bbbbbb0057557500777777000000000000000000777777005555550
0000000000000000ccccccc0020202020a777e00045115400007700000777700000000000bbbbbb0057557500555555000000000000000000777777005555550
000000000000000000ccccc00200002000b7d0000f5015f00007700000777700000000000bbbbbb0057557500555555077777777777777000777777005555550
000000000000000000cccc0002202200000c00000ff55ff00000000000777700000000000bbbbbb0057557500777777000000000000000000777777005555550
0000000000000000ccccc00000020000000000000ffffff00000000000000000000000000bbbbbb0057557500555555000000000000000000777777005555550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777777000000000000000000
__map__
000102030405060708090a0b0c0d0e0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
101112131415161718191a1b1c1d1e1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
202122232425262728292a2b2c2d2e2f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
303132333435363738393a3b3c3d3e3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
404142434445464748494a4b4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
505152535455565758595a5b5c5d5e5f000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
606162636465666768696a6b6c6d6e6f000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
707172737475767778797a7b7c7d7e7f000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
808182838485868788898a8b8c8d8e8f000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
909192939495969798999a9b9c9d9e9f000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
a0a1a2a3a4a5a6a7a8a9aaabacadaeaf000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
b0b1b2b3b4b5b6b7b8b9babbbcbdbebf000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
c0c1c2c3c4c5c6c7c8c9cacbcccdcecf000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
d0d1d2d3d4d5d6d7d8d9dadbdcdddedf000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
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
011000000d7700d7700d7000d7000d7740d7700d7000d7700d7750d770000000f7000f7700f7700f700000000f7740f7700f7000f7700f7750f7700f700107001077010770000000000010774107700000010770
011000001056300000000000000000000000000000000000105630000010563000000000000000000000000000000105001056310563000001e5531e6001b7001e30020300204001e5001e500000000000000000
013000001e7341e7201e7201e7101e7101e7101e7101e715000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000117341b7301b7301b7301b7201b7201b7201b7201b7201b7201b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b710
01100000107751077000000000000f7700f7700f700000000f7740f7700f7000f7700f7750f7700f700107000d7700d7700d7000d7000d7740d7700d7000d7700d7750d770000000f7000f7700f7700f70000000
011000201270012743127001274312700127430000000000127001274300000000001270012743000000000012700127431270012743127001274300000000001270012743000000000012700127430000000000
011000000f7740f7700f7000f7700f7750f7700f700107001077010770000000000010774107700000010770107751077000000000000f7700f7700f700000000f7740f7700f7000f7700f7750f7700f70010700
0120000019054190541905419000190001b0541b0541b0001c0541c0541c0541c0001c0001b0541b0541c00019054190541905419000190001b0541b0541b0001c0541c0541c0541c0001c0001b0541b0541c000
012000002503425034250342500025000270342703427000280342803428034280002800027034270341c0002503425034250342500025000270342703427000280342803428034280002800027034270341c000
012000000d0340d0340d0340d0000d0000f0340f0340f00010034100341003410000100000f0340f034100000d0340d0340d0340d0000d0000f0340f0340f00010034100341003410000100000f0340f0341c000
01090000117341b7301b7301b7301b7201b7201b7201b7201b7201b7201b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b710
010900001b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b7101b71000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900001e7341e7201e7201e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e710
010900001e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e7101e71000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc220024167241673016740167401673016720167101672512724127301274012740127301272012710127150f7240f7300f7400f7400f7300f7200f7100f7251573415740157401574015730157201571015715
170900000f1540f0000f154000001b154000000d154000000d1540000019154000001b154000001b1540000027154000000f100121000f0001e1000f000000000f1540f1000f154000001b154000000d15400000
170900000d15419100191541b100271540000027154000000f15400000000002a1000f0003610000000000000f154000000f154000001b154000000d154000000d15400000191540000027154000003315400000
170908002a10036100121001210000000000000f100000000f100000001b100000000d100000000d100000000f100000000000000000000000000000000000000000000000000000000000000000000000000000
010900000d00000000000000d00000000000001e000000001e0000d000000000f0530d00000000000001e0000d0000000000000000001b0530f00000000000001e00000000000000000000000000000000000000
b10900001a7501a7501a7501a7501a7501a7501a7501a7501f7501f7501f7501f7501f7501f7501f7501f7501c7501c7501c7501c7501c7501c7501c7501c7501d7501d7501d7501d7501d7501d7501d7501d750
170910000d15419100191541b100271540000027154000000f15400000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003906138061370613706136061350613406132061300512e0512c0412b04129041270312502123021200111c011160110f0110b0110601104011010110001100011000110001100011000110001100040
000100000d7100f7101171015710197101d7102072022720287202b7202b7201c7201972014720117000a70000700007000070000000000000000000000000000000000000000000000000000000000000000000
000100001b61022610286102e6103061032610336103361032610316102e6102c6102a6102761024610206101a610106100f6100c610096100661003610026100061000610006100061000610006100001000000
__music__
00 01024344
00 01034344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
03 14424344
01 15185944
00 1a185944
00 15185444
00 1a184344
00 15180a44
00 1a180b44
00 15180c44
02 1a180d44
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
01 006f7044
00 04054344
00 06054344
00 07054344
00 07054344
00 08050944
02 08050944

