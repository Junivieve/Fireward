if(oPlayer.state == "attack") {
	y -= 24;
	screenshake(2, 2, 1);
	hp --;
	audio_play_sound(mSpikeHit, 1, false);	
}