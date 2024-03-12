draw_sprite(sMenu, 0, 0, 0);
draw_sprite(sMenuPlayer, 0, window_get_width()/2, ((window_get_height()/2) + apply_sin(60, 24, 0.00212, false))+30);
if(keyboard_check_pressed(ord("Z"))) {
	oTransition.mode = TRANS_MODE.NEXT;
	audio_play_sound(mGobletSpeak, 1, false);
}