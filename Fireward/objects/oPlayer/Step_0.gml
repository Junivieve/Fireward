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
		if(keyboard_check(vk_up)) {
			dir = 0;	
		} else if(keyboard_check(vk_down)) {
			dir = 1;	
		} else if(keyboard_check(vk_left)) {
			dir = 2;	
		} else if(keyboard_check(vk_right)) {
			dir = 3;	
		}
		
		switch(dir) {
			case 0:
				sprite_index = sPlayerWalkUp_strip6;
			break;
			
			case 1:
				sprite_index = sPlayerWalkDown_strip6;
			break;
			
			case 2:
				sprite_index = sPlayerWalkLeft_strip6;
			break;
			
			case 3:
				sprite_index = sPlayerWalkRight_strip6;
			break;
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

if(hp <= 0) {
	instance_create_layer(0, 0, "DeathWipe", oDeathWipe);	
}

if(keyboard_check_pressed(ord("X"))) {
	if(!instance_exists(oDialogue)) {
		instance_create_layer(0, 0, "Dialogue", oDialogue);
		with(OBJ_CAMERA) {
			if(target_w == base_w) {
				target_w = base_w/2;
				target_h = base_h/2;
				following = oGoblet; 
			}
		}
	}
}

