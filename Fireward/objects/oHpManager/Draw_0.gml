if(!instance_exists(oDialogue)) {
	for (var i = 0; i < oPlayer.hp; ++i) {
	    draw_sprite(sHeart, 0, OBJ_CAMERA.cx + 8 + (12 * i), OBJ_CAMERA.cy + 10);
	}
}