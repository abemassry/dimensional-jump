pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	x=64
	y=64
	s=4
	u=0
	current= 0
	prevcurrent = 0
	level = 0
	xnudge = 0
	ynudge = 0
	xcpos = 0
	jumpanim = 0
	startanim = 0
	blocksize = 8
	leftpress = false
	rightpress = false
	uppress = false
	downpress = false
	jumppress = false

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
		if (jumppress == false) prevcurrent = current
		jumppress = true
	end
	if(btn(5)) then
		if (jumppress == false) prevcurrent = current
		jumppress = true
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

	if (jumppress == true) then
		current = -10
		if (startanim > 5) then
			jumpanim -= 3.75
		end
	end

	if (jumpanim < -50) then
		jumpanim = 0
		jumppress = false
		current = prevcurrent
		startanim = 0
		blocksize = 8
	end


end

function _draw()
	cls()
	for i=0,0 do
		ydiff = -17 + (i * 20) - (level*4)
		zdiff = 7
		depth = 2
		blocksize = 8
		if (level > 0) ydiff = ydiff + 5
		if (level >= 3) ydiff = ydiff + 6
		setup_block(xcpos+64+57,64+ydiff,zdiff,depth,12+xnudge,u,5,blocksize)
		setup_block(xcpos+64+37,64+ydiff,zdiff,depth,10+xnudge,u,5,blocksize)
		setup_block(xcpos+64+20,64+ydiff,zdiff,depth,8+xnudge,u,5,blocksize)
		setup_block(xcpos+64+3,64+ydiff,zdiff,depth,7+xnudge,u,5,blocksize)
		setup_block(xcpos+64-15,64+ydiff,zdiff,depth,4+xnudge,u,5,blocksize)
		setup_block(xcpos+64-32,64+ydiff,zdiff,depth,2+xnudge,u,5,blocksize)
		setup_block(xcpos+64-52,64+ydiff,zdiff,depth,0+xnudge,u,5,blocksize)
	end
	for i=0,0 do
		if (jumpanim == 0) then
			ydiff = -10 + (i * 20) - (level*4)
			blocksize = 8
			zdiff = 3
			ja5 = 0
			ja5n = 0
			ja2 = 0
			ja2n = 0
		else
			ydiff = - 10 + (i * 20) - (level*4) - (jumpanim * .2)
			blocksize = 8 - (jumpanim *.02)
			zdiff = 3  + (jumpanim * .02)
			ja5 = 5 + (jumpanim *.06)
			ja5n = -5 - (jumpanim *.06)
			ja2 = 2 + (jumpanim *.06)
			ja2n = -2 - (jumpanim *.06)
		end
		depth = 5
		if (level > 0) ydiff = ydiff + 5 + (jumpanim * .2)
		if (level >= 3) ydiff = ydiff + 6 + (jumpanim * .2)
		c = 5
		if (prevcurrent == 3 and jumppress == true and level == 0) c = 7
		setup_block(ja5+xcpos+64+55,64+ydiff,zdiff,depth,12+xnudge,u,c,blocksize)
		c = 5
		if (prevcurrent == 2 and jumppress == true and level == 0) c = 7
		setup_block(ja5+xcpos+64+35,64+ydiff,zdiff,depth,10+xnudge,u,c,blocksize)
		c = 5
		if (prevcurrent == 1 and jumppress == true and level == 0) c = 7
		setup_block(ja2+xcpos+64+18,64+ydiff,zdiff,depth,8+xnudge,u,c,blocksize)
		c = 5
		if (prevcurrent == 0 and jumppress == true and level == 0) c = 7
		setup_block(xcpos+64,64+ydiff,zdiff,depth,7+xnudge,u,c,blocksize)
		c = 5
		if (prevcurrent == -1 and jumppress == true and level == 0) c = 7
		setup_block(ja2n+xcpos+64-18,64+ydiff,zdiff,depth,4+xnudge,u,c,blocksize)
		c = 5
		if (prevcurrent == -2 and jumppress == true and level == 0) c = 7
		setup_block(ja5n+xcpos+64-35,64+ydiff,zdiff,depth,2+xnudge,u,c,blocksize)
		c = 5
		if (prevcurrent == -3 and jumppress == true and level == 0) c = 7
		setup_block(ja5n+xcpos+64-55,64+ydiff,zdiff,depth,0+xnudge,u,c,blocksize)
	end
	for j=0,3 do
		if (jumpanim < -40) then
			break
		end
		i= (jumpanim * .5)
		if (jumpanim == 0) then
			blocksize = 8
			ydiff = j*22 - (level*4)
		else
			ydiff = j*22 - (level*4) - (jumpanim * .2)
			blocksize = 8 - (jumpanim * .02)
		end
		i = 0
		depth = 5
		c = 5
		if (j == level) u = -(j-0.5)
		if (current == 3 and j == level) c = 7
		setup_block(xcpos+64+60,64+ydiff,i,depth,13+xnudge,u,c,blocksize)
		c = 5
		if (current == 2 and j == level) c = 7
		setup_block(xcpos+64+40,64+ydiff,i,depth,11+xnudge,u,c,blocksize)
		c = 5
		if (current == 1 and j == level) c = 7
		setup_block(xcpos+64+20,64+ydiff,i,depth,9+xnudge,u,c,blocksize)
		c = 5
		if (current == 0 and j == level) c = 7
		setup_block(xcpos+64,64+ydiff,i,depth,7+xnudge,u,c,blocksize)
		c = 5
		if (current == -1 and j == level) c = 7
		setup_block(xcpos+64-20,64+ydiff,i,depth,4+xnudge,u,c,blocksize)
		c = 5
		if (current == -2 and j == level) c = 7
		setup_block(xcpos+64-40,64+ydiff,i,depth,2+xnudge,u,c,blocksize)
		c = 5
		if (current == -3 and j == level) c = 7
		setup_block(xcpos+64-60,64+ydiff,i,depth,0+xnudge,u,c,blocksize)
	end
	if (jumppress == true) startanim += 1


end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
