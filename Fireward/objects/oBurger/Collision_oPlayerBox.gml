if(canTake) {
	oPlayer.hp = 5;
	audio_play_sound(mBurger, 1, false);
	oPlayer.hasD = false;
	instance_destroy();
}