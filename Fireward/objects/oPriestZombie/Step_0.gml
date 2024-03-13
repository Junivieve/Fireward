/*
if(oPlayer.hp <= 1) {
	move_towards_point(oPlayer.x, oPlayer.y, 0.6);	
}
*/
z = 2+apply_sin(2, 0.5, 0.01, false);

move_towards_point(oGoblet.x, oGoblet.y, 0.5);

if(hp <= 0) {
	instance_destroy();	
}