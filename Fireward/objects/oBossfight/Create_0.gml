state = "shoot";
bTimer = 0;
sTimer = 0;
if(audio_is_playing(mBgm)) {
	audio_stop_sound(mBgm);	
}

audio_play_sound(mBossFight, 1, true);