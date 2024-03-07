cx = camera_get_view_x(cam);
cy = camera_get_view_y(cam);
var _panSpeed = 0.0175;
var _peakSpeed = 0.075;
var _targetSpeed = 0.05;

global.game_time = ((60/1000000) * delta_time);

switch(mode) {
	case CAMERA_MODE.FOLLOW_OBJECT:
		if(!instance_exists(following)) break;
		cx = lerp(cx,following.x - (view_w / 2), _peakSpeed * global.game_time);
		cy = lerp(cy,following.y - (view_h / 2) , _peakSpeed * global.game_time);
	break;
	
	case CAMERA_MODE.FOLLOW_MOUSE_BORDER:
		if(!point_in_rectangle(mouse_x, mouse_y, cx+(view_w*0.1), cy+(view_h*0.1), cx+(view_w*0.9), cy+(view_h*0.9))) {
			cx = lerp(cx, mouse_x - (view_w / 2), _panSpeed);
			cy = lerp(cy, mouse_y - (view_h / 2), _panSpeed);
		}
	break;
	
	case CAMERA_MODE.FOLLOW_MOUSE_PEAK:
	if(!instance_exists(following)) break;
		cx = lerp(following.x, mouse_x, _peakSpeed) - (view_w / 2);
		cy = lerp(following.y, mouse_y, _peakSpeed) - (view_h / 2);	
	break;

	case CAMERA_MODE.MOVE_TO_TARGET:
		cx = lerp(cx, targetX - (view_w / 2), _targetSpeed);
		cy = lerp(cy, targetY - (view_h / 2), _targetSpeed);	
		if(cx == targetX - (view_w / 2) && cy = targetY - (view_h / 2)) {
			mode = CAMERA_MODE.MOVE_TO_FOLLOW_TARGET;
		}
	break;
	
	case CAMERA_MODE.MOVE_TO_FOLLOW_TARGET:
		if(!instance_exists(following)) break;
		cx = lerp(cx, following.x - (view_w / 2), _targetSpeed);
		cy = lerp(cy, following.y - (view_h / 2), _targetSpeed);

		if(point_distance(cx, cy, following.x - (view_w/2), following.y - (view_h/2)) < 1) {
			mode = CAMERA_MODE.FOLLOW_OBJECT;
		}
	break;
}

// Locked to the room / window
if(!free) {
	cx = clamp(cx, 0, room_width-view_w);
	cy = clamp(cy, 0, room_height-view_h);
}

view_w = lerp(view_w, target_w, 0.125);
view_h = lerp(view_h, target_h, 0.125);
camera_set_view_size(cam, view_w, view_h);
camera_set_view_pos(cam, cx, cy);

if (shake) { 
   shake_time --; 
   var _xval = choose(-shake_magnitude, shake_magnitude); 
   var _yval = choose(-shake_magnitude, shake_magnitude); 
   camera_set_view_pos(cam, cx+_xval, cy+_yval);

   if (shake_time <= 0) { 
      shake_magnitude -= shake_fade; 

      if (shake_magnitude <= 0) { 
         camera_set_view_pos(cam, cx, cy); 
         shake = false; 
      } 
   } 
}