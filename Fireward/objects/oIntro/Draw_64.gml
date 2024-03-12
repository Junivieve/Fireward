if(slide >= sprite_get_number(sIntro)-1) {
	with(oTransition) {
		oTransition.mode = TRANS_MODE.NEXT;
		audio_stop_sound(mMenu);
		if(!audio_is_playing(mGobletSpeak)) {
			audio_play_sound(mGobletSpeak, 1, false);
		}
		if(!audio_is_playing(mBgm)) {
			audio_play_sound(mBgm, 1, true);
		}
	}
}

draw_set_alpha(alpha);
draw_sprite(sIntro, slide, 0, 0);

if(keyboard_check_pressed(ord("Z"))) {
	fade = true;
}

if(alpha == 1) {
	slideTime -= 0.01 * global.gameTime;
}

if(slideTime <= 0) {
	switch(slide) {
		case 0:
			slideTime = 5;
		break;
		
		case 1:
			slideTime = 5;
		break;
		
		case 2:
			slideTime = 5;
		break
		
		case 3:
			slideTime = 7.5;
		break;
	}
	
	fade = true;
}

if(fade) {
	alpha = lerp(alpha, 0, 0.25);	
} else {
	alpha = lerp(alpha, 1, 0.25);	
}

if(alpha == 0) {
	fade = false;	
	slide ++;
}

