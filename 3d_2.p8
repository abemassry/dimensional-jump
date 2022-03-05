pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	x=64
	y=64
	s=4
  current= 0
	level = 0
	xnudge = 0
	ynudge = 0
	xcpos = 0
	leftpress = false
	rightpress = false
	uppress = false
	downpress = false

end

function setup_block(x, y, z, depth, s, u, c)
	x0=(x-8)+(z)
	y0=(y-8)+(z)
	x1=(x+8)-z
	y1=(y+8)-(z)

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

function _update60()
	-- current = 0
	if(btn(0)) then
		leftpress = true
	end
	if(btn(1)) then
		rightpress = true
	end
	if xnudge > 3 then
		xnudge = 3
	end
	if xnudge < -3 then
		xnudge = -3
	end

	if(btn(2)) then
		uppress = true
	end
	if(btn(3)) then
		downpress = true
	end
	if(btn(4)) then
	end
	if(btn(5)) then
	end

	if ((not btn(0)) and (not btn(1)) and (not btn(2)) and (not btn(3))) then
		if (leftpress == true) then
			xnudge+=1
			current-=1
			xcpos+=20
			leftpress = false
		end
		if (rightpress == true) then
			xnudge-=1
			current+=1
			xcpos-=20
			rightpress = false
		end
		if (uppress == true) then
			level -= 1
			uppress = false
		end
		if (downpress == true) then
			level += 1
			downpress = false
		end

	end

	if xcpos > 60 then
		xcpos = 60
	end
	if xcpos < -60 then
		xcpos = -60
	end
	if current > 3 then
		current = 3
	end
	if current < -3 then
		current = -3
	end

	if level < 0 then
		level = 0
	end

	if level > 3 then
		level = 3
	end

end

function _draw()
	cls()
	for i=0,0 do
		ydiff = -17 + (i * 20) - (level*4)
		zdiff = 7
		depth = 2
		setup_block(xcpos+64+57,64+ydiff,zdiff,depth,12+xnudge,5)
		setup_block(xcpos+64+37,64+ydiff,zdiff,depth,10+xnudge,5)
		setup_block(xcpos+64+20,64+ydiff,zdiff,depth,8+xnudge,5)
		setup_block(xcpos+64+3,64+ydiff,zdiff,depth,7+xnudge,5)
		setup_block(xcpos+64-15,64+ydiff,zdiff,depth,4+xnudge,5)
		setup_block(xcpos+64-32,64+ydiff,zdiff,depth,2+xnudge,5)
		setup_block(xcpos+64-52,64+ydiff,zdiff,depth,0+xnudge,5)
	end
	for i=0,0 do
		ydiff = -10 + (i * 20) - (level*4)
		zdiff = 3
		depth = 5
		setup_block(xcpos+64+55,64+ydiff,zdiff,depth,12+xnudge,5)
		setup_block(xcpos+64+35,64+ydiff,zdiff,depth,10+xnudge,5)
		setup_block(xcpos+64+18,64+ydiff,zdiff,depth,8+xnudge,5)
		setup_block(xcpos+64,64+ydiff,zdiff,depth,7+xnudge,5)
		setup_block(xcpos+64-18,64+ydiff,zdiff,depth,4+xnudge,5)
		setup_block(xcpos+64-35,64+ydiff,zdiff,depth,2+xnudge,5)
		setup_block(xcpos+64-55,64+ydiff,zdiff,depth,0+xnudge,5)
	end
	for j=0,3 do
		i=0
		ydiff = j*22 - (level*4)
		depth = 5
		c = 5

		if (current == 3 and j == level) c = 7
		setup_block(xcpos+64+60,64+ydiff,i,depth,13+xnudge,c)
		c = 5
		if (current == 2 and j == level) c = 7
		setup_block(xcpos+64+40,64+ydiff,i,depth,11+xnudge,c)
		c = 5
		if (current == 1 and j == level) c = 7
		setup_block(xcpos+64+20,64+ydiff,i,depth,9+xnudge,c)
		c = 5
		if (current == 0 and j == level) c = 7
		setup_block(xcpos+64,64+ydiff,i,depth,7+xnudge,c)
		c = 5
		if (current == -1 and j == level) c = 7
		setup_block(xcpos+64-20,64+ydiff,i,depth,4+xnudge,c)
		c = 5
		if (current == -2 and j == level) c = 7
		setup_block(xcpos+64-40,64+ydiff,i,depth,2+xnudge,c)
		c = 5
		if (current == -3 and j == level) c = 7
		setup_block(xcpos+64-60,64+ydiff,i,depth,0+xnudge,c)
	end

end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
