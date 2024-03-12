if(hit && !hasBeenHit) {
	image_speed = 1;
	sprite_index = sChestHit;
	
	if(image_index >= image_number-1) {
		sprite_index = sChest;
		image_index = 0;
		hasBeenHit = true;
	}
}

if(image_speed > 0 && sprite_index == sChest) {
	if(image_index >= image_number-1) {
		image_speed = 0;
		image_index = image_number-1;
		instance_create_layer(x, y - 16, "Instances", oBurger);
	}
}