/*
if(oPlayer.hp <= 1) {
	move_towards_point(oPlayer.x, oPlayer.y, 0.6);	
}
*/
z = 4+apply_sin(2, 0.5, 0.01, false);
if(alive) {
	sprite_index = sPriestStatueAlive;
	shootTime -= 0.01 * global.gameTime;

	if(shootTime <= 0) {
		var _b = instance_create_layer(x, y, "Instances", oHealOrb);
		_b.direction = irandom_range(minRange, maxRange);
		shootTime = 0.5;
	}
} else {
	sprite_index = sPriestStatue;
}
	