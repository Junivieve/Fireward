draw_set_color(c_black);
draw_rectangle(OBJ_CAMERA.cx, OBJ_CAMERA.cy, OBJ_CAMERA.cx + OBJ_CAMERA.view_w, OBJ_CAMERA.cy + 16, false);
draw_rectangle(OBJ_CAMERA.cx, OBJ_CAMERA.cy+OBJ_CAMERA.view_h-16, OBJ_CAMERA.cx + OBJ_CAMERA.view_w, OBJ_CAMERA.cy+OBJ_CAMERA.view_h, false);
draw_set_color(c_white);
draw_text_ext_transformed(OBJ_CAMERA.cx + OBJ_CAMERA.view_w/2, OBJ_CAMERA.cy + OBJ_CAMERA.view_h-12, dialogue[text], 0, 400, 0.5, 0.5, 0);

if(keyboard_check_pressed(ord("X"))) {
	text ++;
	if(text >= array_length(dialogue)) {
		with(OBJ_CAMERA) {
			target_w = base_w;
			target_h = base_h;	
			following = oPlayer; 	
		}
		instance_destroy();	
	}
}