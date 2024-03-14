if(alive) {
	move_towards_point(oPlayer.x, oPlayer.y, speed);
	sprite_index = sKamakazi;
	speed = 0.5;
	if(place_meeting(x, y, oPlayerBox)) {
		oPlayer.x += 15 * image_xscale;
		oPlayer.hp -= hp;
		oPlayer.state = "hit";
		screenshake(2, 2, 1);
		audio_play_sound(mSpikeHit, 1, false);
		hasHit = true;
		alive = false;
	}
} else {
	sprite_index = sKamakaziDead;	
	speed = 0;
	if(place_meeting(x, y, oTargetOrb)) {
		instance_destroy(instance_place(x, y, oTargetOrb));
		alive = true;	
	}
}





