/*
if(oPlayer.hp <= 1) {
	move_towards_point(oPlayer.x, oPlayer.y, 0.6);	
}
*/
z = 4+apply_sin(2, 0.5, 0.01, false);

x = lerp(x, targetX, 0.025);
y = lerp(y, targetY, 0.025);

if(point_distance(x, y, targetX, targetY) < 6) {
	oPlayer.spawned = true;	
	oPlayer.hasD = true;
	oPlayer.dTime = 0.2;
	oPlayer.enableDialogue();
}