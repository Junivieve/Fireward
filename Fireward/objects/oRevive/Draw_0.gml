priestArrive += 0.01 * global.gameTime;


if(priestArrive >= 1) {
	if(!fadeout) {
		PriestFade = lerp(PriestFade, 1, 0.025);
	}
	draw_set_alpha(PriestFade);	
	draw_sprite(sPriest, 0, 64, 64);
}

if(priestArrive >= 2) {
	if(!fadeout) {
		TextFade = lerp(TextFade, 1, 0.025);
	}
	draw_set_alpha(TextFade);	
	draw_set_color(c_black);
	draw_set_halign(fa_left);
	draw_text_ext(96, 64, "Ah, hero. There are many traps and hazzards in this land, please do be careful", 10, 128);
}

if(priestArrive >= 4) {
	fadeout = true;
	TextFade = lerp(TextFade, 0, 0.025);
}

if(priestArrive >= 5) {
	PriestFade = lerp(PriestFade, 0, 0.25);
	
	if(PriestFade == 0) {
		oDeathWipe.playerFade = lerp(oDeathWipe.playerFade, 0, 0.25);	
	}
	
	if(oDeathWipe.playerFade == 0) {
		oDeathWipe.playerFade = 0;
		oDeathWipe.image_alpha = lerp(oDeathWipe.image_alpha, 0, 0.25);
	}
	
	if(oDeathWipe.image_alpha == 0) {
		instance_destroy(oDeathWipe);
		oPlayer.revived = true;
		oPlayer.sprite_index = sPlayerIdleRight_strip12;
		draw_set_alpha(1);
		oPlayer.state = "heal";
		oPlayer.enableDialogue();
		instance_destroy();
	}
}