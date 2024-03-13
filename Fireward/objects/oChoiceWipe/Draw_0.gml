draw_sprite_ext(sWhiteScreen, 0, 0, 0, 1, 1, 0, c_white, image_alpha);
draw_sprite_ext(sPlayerIdleDown_strip12, oPlayer.image_index, room_width/2, room_height/2, 1, 1, 0, c_black, playerFade);

draw_set_color(c_black);
draw_text(room_width/2, 64, "What do you choose?");
if(option == 1) {
	draw_text(room_width/2 - 100, room_height-96, "x Become The Hero");
	draw_text(room_width/2 + 100, room_height-96, "  Make a deal with Myria");
} else {
	draw_text(room_width/2 - 100, room_height-96, "  Become The Hero");
	draw_text(room_width/2 + 100, room_height-96, "x Make a deal with Myria");	
}

draw_text_transformed(room_width/2, room_height-16, "Press (Z) to confirm", 0.5, 0.5, 0);

if(keyboard_check_pressed(vk_left) && option == 2) {
	option --;	
} else if(keyboard_check_pressed(vk_right) && option == 1) {
	option ++;	
}

if(keyboard_check_pressed(ord("Z"))) {
	if(option == 1) {
		room_goto(Stone)	
	} else {
		room_goto(Bossfight);
	}
}