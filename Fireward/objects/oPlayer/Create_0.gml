event_inherited();
spd = 2;
dir = 1;
state = "idle";
preAttack = false;
hp = 1;
grav = 0.2;
jSpd = 2;
moveZ = 0;
hasPlayedAttackSound = false;
hasPlayedHitSound = false;
canDust = true;
dustTime = 0.5;
fall = false;
hasDied = false;
revived = false;
canMove = false;	
canAttack = false;
artifact = false;

switch(room) {
	case LevelTut1:
		// do nothing.
	break;
	
	case LevelTut2:
		hasDied = true;
		revived = true;
		canMove = true;	
	break;
	
	case Level1:
		hasDied = true;
		revived = true;
		canMove = true;	
		canAttack = true;
		artifact = true;
	break;
}