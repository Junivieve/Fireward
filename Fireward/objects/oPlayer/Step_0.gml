if(hasDied && !revived) {
	exit;	
}

hsp = keyboard_check(vk_right)-keyboard_check(vk_left);
vsp = keyboard_check(vk_down)-keyboard_check(vk_up);
input_jump = keyboard_check_pressed(vk_space);
input_jump_hold = keyboard_check(vk_space);
switch(state) {
	case "idle":
		if(hsp != 0 or vsp != 0) {
			state = "walk";	
		}
		
		switch(dir) {
			case 0:
				sprite_index = sPlayerIdleUp_strip12;
			break;
			
			case 1:
				sprite_index = sPlayerIdleDown_strip12;
			break;
			
			case 2:
				sprite_index = sPlayerIdleLeft_strip12;
			break;
			
			case 3:
				sprite_index = sPlayerIdleRight_strip12;
			break;
		}
		
		if(keyboard_check_pressed(ord("Z"))) {
			image_index = 0;
			state = "attack";
		}
	break;
	
	case "walk":
		if(!canMove) {
			state = "idle";
			return;
		}
		if(keyboard_check(vk_up)) {
			dir = 0;	
		} else if(keyboard_check(vk_down)) {
			dir = 1;	
		} else if(keyboard_check(vk_left)) {
			dir = 2;	
		} else if(keyboard_check(vk_right)) {
			dir = 3;	
		}
		
		var _d = 0;
		
		switch(dir) {
			case 0:
				sprite_index = sPlayerWalkUp_strip6;
			break;
			
			case 1:
				sprite_index = sPlayerWalkDown_strip6;
			break;
			
			case 2:
				sprite_index = sPlayerWalkLeft_strip6;
				_d = -1;
			break;
			
			case 3:
				sprite_index = sPlayerWalkRight_strip6;
				_d = 1;
			break;
		}	
		dustTime -= 0.01 * global.gameTime;
		if(dustTime <= 0) {
			canDust = true;	
			dustTime = 0.5;
		}
		if(canDust) {
			repeat(16) {
				var _p = CreateParticle(x, y+10, "Part", OBJ_PARTICLE, sWalkDust, irandom(360),0.1, 0.75, 1, c_white, true);
				_p.depth = depth+50;
				_p.image_alpha = 0.5;
				_p.image_blend = $1e253d
			}
			canDust = false;
		}
		
		if(hsp == 0 && vsp == 0) {
			state = "idle";	
		}
		
		x += hsp * spd;
		y += (vsp * spd)-moveZ;
		
		if(keyboard_check_pressed(ord("Z"))) {
			image_index = 0;
			state = "attack";
		}
	break;
	
	case "attack":
		if(!canAttack) {
			state = "idle";
			return;
		}
		if(!audio_is_playing(mSwipe) && !hasPlayedAttackSound) {
			audio_play_sound(mSwipe, 1, false);
			hasPlayedAttackSound = true;
		}
		switch(dir) {
			case 0:
				sprite_index = sPlayerAttackUp_strip7;
			break;
			
			case 1:
				sprite_index = sPlayerAttackDown_strip7;
			break;
			
			case 2:
				sprite_index = sPlayerAttackLeft_strip7;
			break;
			
			case 3:
				sprite_index = sPlayerAttackRight_strip7;
			break;
		}	
		
		if(keyboard_check_pressed(ord("Z"))) {
			preAttack = true;	
		}
		if(place_meeting(x, y, oBatBox)) {
			var _bb = instance_place(x, y, oBatBox)	;
			_bb.owner.hp --;
		}
		if(place_meeting(x, y, oChest)) {
			if(artifact) {	
				var _c = instance_place(x, y, oChest);
				_c.hit = true;
			}
		}
		if(image_index >= image_number-1) {
			if(preAttack) {
				image_index = 0;	
			} else {
				if(hsp != 0 or vsp!= 0) {
					state = "walk";	
				} else {
					state = "idle";	
				}
			}
			preAttack = false;
			hasPlayedAttackSound = false;
		}
	break;
	
	case "hit":
		switch(dir) {
		case 0:
			sprite_index = sPlayerHitUp_strip4;
		break;
		
		case 1:
			sprite_index = sPlayerHitDown_strip4;
		break;
		
		case 2:
			sprite_index = sPlayerHitLeft_strip4;
		break;
		
		case 3:
			sprite_index = sPlayerHitRight_strip4;
		break;
	}
	
	if(image_index >= image_number-1) {
		if(hsp != 0 or vsp!= 0) {
			state = "walk";	
		} else {
			state = "idle";	
		}
		hasPlayedHitSound = false;
	}
	break;
	
	case "heal":
		switch(dir) {
		case 0:
			sprite_index = sPlayerHealUp;
		break;
		
		case 1:
			sprite_index = sPlayerHealDown;
		break;
		
		case 2:
			sprite_index = sPlayerHealLeft;
		break;
		
		case 3:
			sprite_index = sPlayerHealRight;
		break;
	}
	
	if(image_index >= image_number-1) {
		if(hsp != 0 or vsp!= 0) {
			state = "walk";	
		} else {
			state = "idle";	
		}
		hasPlayedHitSound = false;
	}
	break;
	
	case "healStone":
	sprite_index = sPlayerHealUp;
	
	if(image_index >= image_number-1) {
		state = "stone";
		hasPlayedHitSound = false;
	}
	break;
	
	case "stone":
		sprite_index = sPlayerStone;
		image_index = stone;
	break;
	
	case "death":
		if(!hasDied) {
			instance_create_layer(0, 0, "DeathWipe", oDeathWipe);
			hasDied = true;
			var _r = instance_create_layer(0, 0, "DeathWipe", oRevive);
			_r.depth = -100;
		}
	break;
}
if(!fall) {
	moveZ = -200;
	z = moveZ;
	fall = true;
}
if(z > 0) { // in air...
	moveZ -= grav;
	z += moveZ;
	if(moveZ > 0 && !input_jump_hold) {
		moveZ = 0;	
	}
} else {
	z = 0;
	if(input_jump) {
		moveZ = jSpd;
		z = moveZ;
	} else {
		moveZ = 0;	
	}
}

if(hp <= 0 && !hasDied) {
	state = "death";
	//instance_create_layer(0, 0, "DeathWipe", oDeathWipe);	
}

if(hp <= 0 && room != LevelTut1) {
	if(room == Bossfight) {
		room_goto(Fireward);	
	} else {
		if(room != Fireward) {
			room_restart();	
		}
	}
}

if(!hasD && spawned) {
	dTime -= 0.01 * global.gameTime;
}

if(dTime <= 0) {
	hasD = true;
	enableDialogue();
	dTime = 0.2;
}

createPriest -= 0.01 * global.gameTime;

if(createPriest <= 0 && !instance_exists(oPriest) && room == LevelTut1) {
	instance_create_layer(192, -32, "Instances", oPriest);	
}

if(room == Level1 or room == Fireward) {
	if(point_distance(x, y, oGoblet.x, oGoblet.y) < 64) {
		if(!fireshrine) {
			fireshrine = true;
			hasD = false;
			dTime = 0.2;
			enableDialogue();
		}
	}
}

if(stone > 6) {
	instance_create_layer(0, 0, "DeathWipe", oStoneWipe);	
	audio_stop_sound(mBgm);
	if(!audio_is_playing(mMenu)) {
		audio_play_sound(mMenu, 1, true);
	}
}