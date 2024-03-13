z = 4+apply_sin(2, 0.5, 0.005, false);

if(agro) {

	if(hasHit) {
		x -= lengthdir_x(point_distance(x, y, oPlayer.x, oPlayer.y)+2, point_direction(x, y, oPlayer.x, oPlayer.y)) * spd;
		y -= lengthdir_y(point_distance(x, y, oPlayer.x, oPlayer.y)+2, point_direction(x, y, oPlayer.x, oPlayer.y)) * spd;
		
		if(point_distance(x, y, oPlayer.x, oPlayer.y) > 24) {
			hasHit = false;
		}
	} else {
		x += lengthdir_x(point_distance(x, y, oPlayer.x, oPlayer.y)+2, point_direction(x, y, oPlayer.x, oPlayer.y)) * spd;
		y += lengthdir_y(point_distance(x, y, oPlayer.x, oPlayer.y)+2, point_direction(x, y, oPlayer.x, oPlayer.y)) * spd;
	}
}

if(place_meeting(x, y, oPlayerBox)) {
	oPlayer.x += 15 * dir;
	oPlayer.hp -= hp;
	oPlayer.state = "hit";
	screenshake(2, 2, 1);
	audio_play_sound(mSpikeHit, 1, false);
	hasHit = true;
}

dir = x > oPlayer.x ? -1 : 1;


if(hp <= 0) {
	instance_destroy(oBatBox);	
	if(room == LevelTut2) {
		oPlayer.artifact = true;	
	}
	instance_destroy();
}

