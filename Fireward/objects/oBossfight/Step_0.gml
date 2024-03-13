switch(state) {
	case "bishops":
		with(oBishop) {
			alive = true;	
		}
		bTimer += 0.01 * global.gameTime;
		
		if(bTimer > 5) {
			state = choose("td", "nah");	
			with(oBishop) {
				alive = false;	
			}
		}
	break;
	
	case "td":
		for (var i = 0; i < 16; ++i) {
		    instance_create_layer(16 * i, -32, "Instances", oPriestZombie);
		}
		state = "tdCheck";
	break;
	
	case "tdCheck":
		if(instance_number(oPriestZombie) <= 0) {
			state = "bishops";	
		}
	break;
}