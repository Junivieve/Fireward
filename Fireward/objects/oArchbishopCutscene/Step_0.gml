z = 15+apply_sin(2, 0.5, 0.01, false);

y = lerp(y, targetY, 0.01);

if(point_distance(x, y, x, targetY) < 4) {
	waitTime -= 0.01 * global.gameTime;	
}

if(waitTime <= 0) {
	oPlayer.arrive = true;
	oPlayer.enableDialogue();	
}