x += lengthdir_x(2, dir) * 0.5;
y += lengthdir_y(2, dir) * 0.5;

if(point_distance(xstart, ystart, x, y) > 500) {
	var _b = 0;
	
	_b = choose(1, 2);
	
	switch(_b) {
		case 1:
			x = irandom_range(16, room_width-16);
			y = room_height-16;
			dir = irandom_range(5, 105);
		break
		
		case 2:
			x = irandom_range(16, room_width-16);
			y = 0;
			dir = irandom_range(-105, 5);
		break;
	}
}