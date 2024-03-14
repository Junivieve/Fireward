z = 15+apply_sin(2, 0.5, 0.01, false);
if(shoot) {
	if(!hasMegad) {
		var _b = instance_create_layer(x, y, "Instances", oTargetMegaHeal);
		_b.direction = point_direction(x, y, oPlayer.x, oPlayer.y);	
		hasMegad = true;
	}
	shootTime -= 0.01 * global.gameTime;

	if(shootTime <= 0) {
		var _b = instance_create_layer(x, y, "Instances", oTargetOrb);
		_b.direction = point_direction(x, y, oPlayer.x, oPlayer.y);
		shootTime = 0.5;
	}
}