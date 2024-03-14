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
arrive = false;
stone = 0;
bossfightStart = false;

switch(room) {
	case LevelTut1:
		spawned = false;
	break;
	
	case LevelTut2:
		spawned = true;
		hasDied = true;
		revived = true;
		canMove = true;	
	break;
	
	case Level1:
		fireshrine = false;
		spawned = true;
		hasDied = true;
		revived = true;
		canMove = true;	
		canAttack = true;
		artifact = true;
		hp = 5;
	break;
	
	case Bossfight:
		spawned = true;
		hasDied = true;
		revived = true;
		canMove = true;	
		canAttack = true;
		artifact = true;
		hp = 5;
	break;
	
	case Stone:
		state = "stone";
		canMove = false;
		canAttack = false;
		artifact = true;
		hp = 5;
		spawned = true;
		hasDied = true;
		revived = true;
	break;
	
	case Fireward:
		canMove = true;
		canAttack = false;
		artifact = true;
		hp = 0;
		spawned = true;
		hasDied = true;
		revived = true;	
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
							"Tutorus The Accolyte: Great hero!",
							"Tutorus The Accolyte: Your strength is unparalleled",
							"Tutorus The Accolyte: ... Yes, it was due to your strength",
							"Tutorus The Accolyte: you are able to survive",
							"you hear a voice in the distance...",
							"???: HAHAHAA yes... PRAISE THE HERO!",
							"it seems Tutorus did not hear this voice",
							"Tutorus The Accolyte: Please do be careful oh chosen one!'",
							"Tutorus The Accolyte: Anyway, moving on..."
						]	
					}						
				}
			break;
			
			case LevelTut2:
					if(hp > 4) {
					var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
					audio_play_sound(mPriestVoice, 1, false);
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
					var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
					audio_play_sound(mPriestVoice, 1, false);
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
			if(fireshrine) {
				var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
				audio_play_sound(mGobletSpeak, 1, false);
				if(!arrive) {
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
							"...",
							"???: Who am I?..",
							"Myria: I am the demon queen Myria",
							"You hear the voice shout proud and firm",
							"Myria: These lowly rutts managed to trap me in this shrine",
							"Myria: however the issues of this world, matter not to you",
							"Myria: your return, your freedom. I can grant",
							"Myria: These apoth will keep reviving you if you die",
							"Myria: They offer you treasures...", 
							"Myria: They offer you false glory",
							"Myria: Just so they can keep you for themselves",
							"Myria: These lunatics have slaughtered my kind for centuries",
							"Myria: You're a hostage, not a hero!",
							"Myria: ...",
							"Myria: If you sacrifice your lifeforce to me...",
							"Myria: I can send you home",
							"Myria: I just need your soul to help free me from this cage!",
							"...",
							"Myria: uh oh...",
						]	
					}
				} else {
					with(OBJ_CAMERA) {
						if(target_w == base_w) {
							target_w = base_w/2;
							target_h = base_h/2;
							following = oArchbishopCutscene; 
						}
					}
					with(_d) {
						dialogue =
						[ 
							"",
							"Archbishop: Hero what are you doing?",
							"Archbishop: p-p-PLEASE hero, step away!",
							"...",
							"Archbishop: that thing.. there is a demon in there!",
							"Archbishop: trying to curse your soul!",
							"Archbishop: you are the chosen one!!!",
							"Archbishop: Please hero, come let me cleans your soul!",
							"...",
							"Myria: They are delusional... I will save you.",
						]	
					}					
				}
			}
			break;
			
			case Bossfight:
				var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
				
				with(_d) {
					dialogue =
					[
						"",
						"Myria: These lunatics are going to try and put out the flame",
						"Myria: They wont harm you though, be careful not to get healed",
						"Myria: I will summon demons to harm you",
						"Myria: You can use their healing to our advance",
						"Myria: Revive the demons to bring your sould to 0",
						"Myria: Dont let those priests get near me!",
						"Myria: Quickly sacrifice yourself...",
					];
				}
			break;
			
			case Stone:
					with(OBJ_CAMERA) {
						if(target_w == base_w) {
							//target_w = base_w/2;
							//target_h = base_h/2;
							following = oArchBishopStone; 
						}
					}
					var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
					with(_d) {
						text = 0;
						switch(oPlayer.stone) {
							case 0:
								dialogue =
								[ 
									"",
									"Archbishop: Ah hero, yes this is the way!",
									"Archbishop: Hero, I've been researching...",
									"Archbishop: ancient magic, called petrification",
									"Archbishop: it's told that a hero's soul...",
									"Archbishop: can ward off demons",
									"Archbishop: so Hero, we shall perserve your very soul!",
									"Archbishop: this wont take long..."
								]	
							break;
							
							case 1:
								dialogue =
								[ 
									"",
									"Archbishop: your sacrifice will be told in legend",
									"Archbishop: for years to come!",
								]								
							break;
							
							case 2:
								dialogue =
								[ 
									"",
									"Archbishop: ... Tutorus and the others will sing my praises!",
									"Archbishop: They all said we should trust the hero...",
								]								
							break;
							
							case 3:
								dialogue =
								[ 
									"",
									"Archbishop: But i sought your memories...",
									"Archbishop: I saw the corruption... the delusions",
								]								
							break;
							
							case 4:
								dialogue =
								[ 
									"",
									"Archbishop: DEAR HERO, OUR SAVIOR",
									"Archbishop: we must ensure our safety...",
									"Archbishop: heavens, you would treat our world",
									"Archbishop: as a, simple game!?!"
								]								
							break;
							
							case 5:
								dialogue =
								[ 
									"",
									"Archbishop: you do understand?",
									"Archbishop: This was not going to happen!",
								]								
							break;
							
							case 6:
								dialogue =
								[ 
									"",
									"Archbishop: Thank you hero, for playing...",
									"Archbishop: playing my game...",
									"Archbishop: however, the survival of the Apoth",
									"Archbishop: is the only thing that matters",
									"Archbishop: Goodbye, ...Hero"
								]								
							break;
						}
					}										
			break;
			
			case Fireward:
				if(fireshrine) {
					var _d = instance_create_layer(0, 0, "Dialogue", oDialogue);
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
							"",
							"Myria: Thank you hostaged hero,",
							"Myria: I will now return you to your world as promised",
							"Myria: Farewell...",
						];
					}			
				}
			break;
		}
	}	
}
	
hasD = false;
dTime = 0.2;
createPriest = 1;
fireshrine = false;