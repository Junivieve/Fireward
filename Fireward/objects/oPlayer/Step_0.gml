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

if(keyboard_check_pressed(ord("X"))) {
	if(!instance_exists(oDialogue)) {
		switch(room) {
			case LevelTut1:
				var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
				audio_play_sound(mPriestVoice, 1, false);
				with(OBJ_CAMERA) {
					if(target_w == base_w) {
						target_w = base_w/2;
						target_h = base_h/2;
						following = oPriest; 
					}
				}
				if(!revived) {
					with(_d) {
						dialogue =
						[ 
							"",
							"Tutorus The Accolyte: AHHHH!!",
							"Tutorus The Accolyte: THE H-H-HE-HERO HAS BEEN SUMMONED!",
							"Tutorus The Accolyte: This is a grand day, praise be!",
							"Tutorus The Accolyte: Thy Hero, can you stand!?",
							"...",
							"Move around with 'arrow keys'"
						]	
					}	
				} else {
					with(_d) {
						text = 0;
						dialogue =
						[ 
							"",
							"Tutorus The Accolyte: Oh great Hero! I revived you...",
							"Spikes deal 1 damage",
							"Tutorus The Accolyte: Great hero!",
							"Tutorus The Accolyte: Your strength is unparalleled",
							"Tutorus The Accolyte: ... Yes, it was due to your strength",
							"Tutorus The Accolyte: you are able to survive",
							"you hear a dissonance and a whisper in the distance...",
							"???: HAHAHAA yes... PRAISE THE HERO!",
							"it seems Tutorus did not hear this sound",
							"Tutorus The Accolyte: Please do be careful oh chosen one!'",
							"Tutorus The Accolyte: Anyway, moving on..."
						]	
					}						
				}
			break;
			
			case LevelTut2:
				if(canAttack && instance_number(oBatDemon) != 0) {
					// do nothing					
				} else {
					var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
					audio_play_sound(mPriestVoice, 1, false);
					with(OBJ_CAMERA) {
						if(target_w == base_w) {
							target_w = base_w/2;
							target_h = base_h/2;
							following = oPriest; 
						}
					}
					if(hp < 4) {
						with(_d) {
							dialogue =
							[ 
								"",
								"Tutorus The Accolyte: HUZZAH!",
								"Tutorus The Accolyte: You have slain the demon!",
								"Tutorus The Accolyte: the people of Myneria are safe now.",
								"Tutorus The Accolyte: Oh Hero, our savior... ",
								"...",
								"Ancient artifact chests can be found in forest pathways.",
								"Tutorus The Accolyte: Hero! An crate... Claim thy prize.",
								"Hit the chest to open it.",
							]	
						}
					} else {
						with(_d) {
							dialogue =
							[ 
								"",
								"Tutorus The Accolyte: Grand Hero!",
								"Tutorus The Accolyte: You have found an artifact!",
								"Tutorus The Accolyte: It has great healing properties.",
								"Tutorus The Accolyte: Our kingdom's chefs call it...",
								"...",
								"Tutorus The Accolyte: The Wheat Steak potion!.",
								"Tutorus The Accolyte: Amazing! You are indeed a grand savior!"
							]	
						}						
					}
				}
				
				if(!canAttack) {
					with(OBJ_CAMERA) {
						if(target_w == base_w) {
							target_w = base_w/2;
							target_h = base_h/2;
							following = oPriest; 
						}
					}
					with(_d) {
						dialogue =
						[ 
							"",
							"Tutorus The Accolyte: Grand Hero!",
							"Tutorus The Accolyte: There is a demon!!",
							"Tutorus The Accolyte: We've summoned you here to defeat them.",
							"Tutorus The Accolyte: Please take this sword, save me oh hero!",
							"...",
							"Press Z to attack!"
						]	
					}	
				}
			break;
			
			case Level1:
				var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
				audio_play_sound(mGobletSpeak, 1, false);
				with(OBJ_CAMERA) {
					if(target_w == base_w) {
						target_w = base_w/2;
						target_h = base_h/2;
						following = oGoblet; 
					}
				}
				with(_d) {
					dialogue =
					[ 
						"???: Hello summoned...",
						"???: The Apoth priests have trapped you here",
						"???: The promise of title 'hero' is not benevolent",
						"???: I can take you home...",
						"???: Who am I?..",
						"Myria: I am the demon queen Myria",
						"You hear the voice shout proud and firm",
						"Myria: These lowly rutts managed to trap me in this shrine",
						"Myria: however the issues of this world, matter not to you",
						"Myria: your return, your freedom. I can grant",
						"Myria: These apoth will keep reviving you if you die",
						"Myria: If you sacrifice your lifeforce to me...",
						"Myria: I can send you home",
						"Myria needs exactly 2 soul hearts to free themselves",
						"Use traps, demons and anything else to lower your soul",
					]	
				}
			break;
		}
	}
}

