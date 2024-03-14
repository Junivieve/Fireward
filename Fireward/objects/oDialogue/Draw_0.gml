if(array_length(dialogue) > 0) {
	draw_set_color(c_black);
	draw_rectangle(OBJ_CAMERA.cx, OBJ_CAMERA.cy, OBJ_CAMERA.cx + OBJ_CAMERA.view_w, OBJ_CAMERA.cy + 16, false);
	draw_rectangle(OBJ_CAMERA.cx, OBJ_CAMERA.cy+OBJ_CAMERA.view_h-16, OBJ_CAMERA.cx + OBJ_CAMERA.view_w, OBJ_CAMERA.cy+OBJ_CAMERA.view_h, false);

	draw_set_color(c_white);
	draw_text_ext_transformed(OBJ_CAMERA.cx + OBJ_CAMERA.view_w/2, OBJ_CAMERA.cy + OBJ_CAMERA.view_h-12, dialogue[text], 0, 400, 0.5, 0.5, 0);
	if(!hasdoneX) {
		draw_text_ext_transformed(OBJ_CAMERA.cx + OBJ_CAMERA.view_w/2, OBJ_CAMERA.cy + OBJ_CAMERA.view_h-15, "Press (X) to continue", 0, 400, 0.25, 0.25, 0);
	}
	if(keyboard_check_pressed(ord("X"))) {
		hasdoneX = true;
		text ++;
		if(text >= array_length(dialogue)) {
			with(OBJ_CAMERA) {
				target_w = base_w;
				target_h = base_h;	
				following = oPlayer; 	
			}
			if(room == LevelTut1) {
				if(!oPlayer.revived) {
					oPlayer.canMove = true;
				} else {
					with(oTransition) {
						oTransition.mode = TRANS_MODE.NEXT;	
					}				
				}
			}
			if(room == LevelTut2) {
				if(!oPlayer.canAttack) {
					oPlayer.canAttack = true;	
					oBatDemon.agro = true;
				} else if(!oPlayer.artifact) {
					oPlayer.artifact = true;	
				} else if(oPlayer.hp > 4) {
					with(oTransition) {
						oTransition.mode = TRANS_MODE.NEXT;	
					}	
				}
			}
			if(room == Level1) {
				if(!oPlayer.arrive) {
					instance_create_layer(room_width/2, -32, "Instances", oArchbishopCutscene);
				} else {
					with(OBJ_CAMERA) {
						target_w = base_w;
						target_h = base_h;	
						following = oPlayer; 	
					}
					instance_create_layer(0, 0, "DeathWipe", oChoiceWipe);		
				}
			}
			if(room == Stone) {
				if(oPlayer.stone < 7) {
					oArchBishopStone.petrify();
				}
			}
			instance_destroy();	
		}
	}
}