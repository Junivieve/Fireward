if(surface_exists(surface)) {
	
	var _cam = OBJ_CAMERA;
	var _cw = _cam.view_w;
	var _ch = _cam.view_h;
	var _cx = _cam.cx;
	var _cy = _cam.cy;
	
	surface_set_target(surface);
	draw_set_color(c_black);
	draw_set_alpha(0.5);
	draw_rectangle(0, 0, _cw, _ch, 0);
	
	gpu_set_blendmode(bm_subtract);
	
	with(oGoblet) {
		draw_sprite_ext(sLightMask, 0, x-_cx, y-_cy, 0.5 + random(0.05), 0.5 + random(0.05), 0, c_white, 1);	
	}
	
	with(oHealOrb) {
		draw_sprite_ext(sLightMask, 0, x-_cx, y-_cy, 0.25 + random(0.05), 0.25 + random(0.05), 0, c_white, 1);	
	}
	
	with(oFire) {
		draw_sprite_ext(sLightMask, 0, x-_cx, y-_cy, 0.25 + random(0.05), 0.25 + random(0.05), 0, c_white, 1);	
	}
	
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	surface_reset_target();
	draw_surface(surface, _cx, _cy);
} else {
	var _cam = OBJ_CAMERA;
	var _cw = _cam.view_w;
	var _ch = _cam.view_h;
	
	surface = surface_create(_cw, _ch);
	surface_set_target(surface);
		draw_set_color(c_black);
		draw_set_alpha(0.6);
		draw_rectangle(0, 0, _cw, _ch, 0);
	surface_reset_target();
}
	