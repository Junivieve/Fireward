var _spd = choose(0.01, 0.02, 0.025);


waitTime --;

if(waitTime <= 0) {
	x = lerp(x, oGoblet.x, _spd);
	y = lerp(y, oGoblet.y, _spd);		
}