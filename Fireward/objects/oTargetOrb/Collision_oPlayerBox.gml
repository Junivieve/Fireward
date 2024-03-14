oPlayer.state = "heal";
oPlayer.hp += heal;
screenshake(2, 2, 1);
audio_play_sound(mHealHit, 1, false);

instance_destroy();