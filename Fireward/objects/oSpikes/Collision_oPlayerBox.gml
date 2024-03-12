if(!hit) {
	hit = true;
	image_speed = 1;
	oPlayer.state = "hit";
	oPlayer.hp -= damage;
	screenshake(2, 2, 1);
	audio_play_sound(mSpikeHit, 1, false);
}