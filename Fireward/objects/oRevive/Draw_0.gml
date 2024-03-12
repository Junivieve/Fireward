priestArrive += 0.01 * global.gameTime;


if(priestArrive >= 1.5) {
	if(!fadeout) {
		PriestFade = lerp(PriestFade, 1, 0.025);
	}
	draw_set_alpha(PriestFade);	
	draw_sprite(sPriest, 0, 64, 64);
}

if(priestArrive >= 3) {
	if(!fadeout) {
		TextFade = lerp(TextFade, 1, 0.025);
	}
	draw_set_alpha(TextFade);	
	draw_set_color(c_black);
	draw_set_halign(fa_left);
	draw_text_ext(96, 64, "Ah, hero. There are many traps and hazzards in this land, please do be careful", 10, 128);
}

if(priestArrive >= 6) {
	fadeout = true;
	TextFade = lerp(TextFade, 0, 0.025);
}

if(priestArrive >= 7.5) {
	PriestFade = lerp(PriestFade, 0, 0.025);		
}