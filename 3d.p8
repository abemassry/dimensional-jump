pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
  x0=8
  y0=8
  x1=8
  y1=8
  xx0=8
  yy0=8
  xx1=8
  yy1=8
  z=5
  
end

function draw_block(x0,x1,y0,y1,xx0,xx1,yy0,yy1,c,level)
	block_size_front=15
	block_size_back=2
	if level == 1 then
		block_size_front=10
		block_size_back=2
	end
	x1=x0+block_size_front
	y1=y0+block_size_front
	yy0=y0+block_size_back
	yy1=y1
	xx0=x0+block_size_back
	xx1=x1
	pos=0
	ypos=0
		
	rect(x0+z,y0+z,x1+z,y1+z,c)
	line(xx0,yy0,x0+z,y0+z,c)
	line(xx1,yy0,x1+z,y0+z,c)
	line(xx0,yy1,x0+z,y1+z,c)
	line(xx1,yy1,x1+z,y1+z,c)
	rect(xx0,yy0,xx1,yy1,c)
end

function _update60()
	if(btn(0)) then
		x0-=0.75
		x1-=0.75
		--xx0-=0.5
		--xx1-=0.5
	end
	if(btn(1)) then
		x0+=0.75
		x1+=0.75
		--xx0+=0.5
		--xx1+=0.5
	end
	
	if(btn(2)) then
		y0-=0.75
		y1-=0.75
		--yy0-=0.5
		--yy1-=0.5
	end
	if(btn(3)) then
		y0+=0.75
		y1+=0.75
		--yy0+=0.5
		--yy1+=0.5
	end
	if(btn(4)) then
		z+=1
	end
	if(btn(5)) then
	 z-=1
	end

	
	
end

function _draw()
	cls()
	for i=0,100,25 do
		for j=0,100,25 do
			draw_block(x0,x1,y0,y1,xx0,xx1,yy0,yy1,6,2)
			pos=i
			ypos=j
			draw_block(x0+pos,x1+pos,y0+ypos,y1+ypos,xx0+pos,xx1+pos,yy0+ypos,yy1+ypos,6,2)
			draw_block(x0,x1,y0,y1,xx0,xx1,yy0,yy1,6,1)
			pos=i
			ypos=j
			draw_block(x0+pos,x1+pos,y0+ypos,y1+ypos,xx0+pos,xx1+pos,yy0+ypos,yy1+ypos,6,1)
		end
	end


end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
