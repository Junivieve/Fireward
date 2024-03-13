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
		hp = 5;
	break;
	
	case Level2:
		hasDied = true;
		revived = true;
		canMove = true;	
		canAttack = true;
		artifact = true;
		hp = 5;
	break;
	
	case BossRoom:
		hasDied = true;
		revived = true;
		canMove = true;	
		canAttack = true;
		artifact = true;
		hp = 5;
	break;
}
	
	
function enableDialogue() {
	if(!instance_exists(oDialogue)) {
		switch(room) {
			case LevelTut1:
				if(!revived) {
					if(!canMove) {
						with(OBJ_CAMERA) {
							if(target_w == base_w) {
								target_w = base_w/2;
								target_h = base_h/2;
								following = oPriest; 
							}
						}
						var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
						audio_play_sound(mPriestVoice, 1, false);
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
					}
				} else {
					with(OBJ_CAMERA) {
						if(target_w == base_w) {
							target_w = base_w/2;
							target_h = base_h/2;
							following = oPriest; 
						}
					}
					var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
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
	
dTime = 0.5;
hasD = false;