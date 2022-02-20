pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	x=64
	y=64
	s=4

end

function setup_block(x, y, z, depth, s, c)
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
		draw_block(x0+s,x1+s,y0,y1,xx0,xx1,yy0,yy1,c)
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
	if(btn(0)) then
		s-=1
	end
	if(btn(1)) then
		s+=1
	end

	if(btn(2)) then
	end
	if(btn(3)) then
	end
	if(btn(4)) then
	end
	if(btn(5)) then
	end



end

function _draw()
	cls()
	for i=0,0 do
		ydiff = -17 + (i * 20)
		zdiff = 7
		depth = 2
		setup_block(64+57,64+ydiff,zdiff,depth,12,6)
		setup_block(64+37,64+ydiff,zdiff,depth,10,6)
		setup_block(64+20,64+ydiff,zdiff,depth,8,6)
		setup_block(64+3,64+ydiff,zdiff,depth,7,6)
		setup_block(64-15,64+ydiff,zdiff,depth,4,6)
		setup_block(64-32,64+ydiff,zdiff,depth,2,6)
		setup_block(64-52,64+ydiff,zdiff,depth,0,6)
	end
	for i=0,0 do
		ydiff = -10 + (i * 20)
		zdiff = 3
		setup_block(64+55,64+ydiff,zdiff,5,12,6)
		setup_block(64+35,64+ydiff,zdiff,5,10,6)
		setup_block(64+18,64+ydiff,zdiff,5,8,6)
		setup_block(64,64+ydiff,zdiff,5,7,6)
		setup_block(64-18,64+ydiff,zdiff,5,4,6)
		setup_block(64-35,64+ydiff,zdiff,5,2,6)
		setup_block(64-55,64+ydiff,zdiff,5,0,6)
	end
	for j=0,3 do
		i=0
		ydiff = j*22
		setup_block(64+60,64+ydiff,i,5,12,6)
		setup_block(64+40,64+ydiff,i,5,10,6)
		setup_block(64+20,64+ydiff,i,5,8,6)
		setup_block(64,64+ydiff,i,5,7,6)
		setup_block(64-20,64+ydiff,i,5,4,6)
		setup_block(64-40,64+ydiff,i,5,2,6)
		setup_block(64-60,64+ydiff,i,5,0,6)
	end

end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
