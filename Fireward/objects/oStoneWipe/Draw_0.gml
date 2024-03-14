draw_sprite_ext(sWhiteScreen, 0, 0, 0, 1, 1, 0, c_white, image_alpha);
draw_sprite_ext(sPlayerIdleDown_strip12, oPlayer.image_index, room_width/2, room_height/2, 1, 1, 0, c_black, playerFade);

draw_set_color(c_black);
draw_text(room_width/2, 64, "Your consciousness fades");

draw_text_transformed(room_width/2, room_height/2 + 72, "Fireward was writen/produced by Juniper Taylor for the Acerola Game Jam 0", 0.5, 0.5, 0);
draw_text_transformed(room_width/2, room_height - 72, "Press (Z) to revive", 0.5, 0.5, 0);
if(keyboard_check_pressed(vk_left) && option == 2) {
	option --;	
} else if(keyboard_check_pressed(vk_right) && option == 1) {
	option ++;	
}

if(keyboard_check_pressed(ord("Z"))) {
	audio_stop_sound(mMenu);
	audio_play_sound(mBgm, 1, true);
	room_goto(Level1);
}