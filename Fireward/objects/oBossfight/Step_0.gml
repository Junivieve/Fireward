switch(state) {
	case "bishops":
		with(oBishop) {
			alive = true;	
		}
		bTimer += 0.01 * global.gameTime;
		
		if(bTimer > 5) {
			state = choose("td", "shoot", "shoot", "shoot",);
			//oArchBishop.shoot = false;
			bTimer = 0;
			with(oBishop) {
				alive = false;	
			}
		}
	break;
	
	case "td":
		oArchBishop.shoot = false;
		for (var i = 0; i < 16; ++i) {
		    instance_create_layer(16 * i, -32, "Instances", oPriestZombie);
		}
		state = "tdCheck";
	break;
	
	case "tdCheck":
		if(instance_number(oPriestZombie) <= 0) {
			state = choose("shoot", "shoot", "shoot", "bishops", "bishops", "bishops");		
		}
	break;
	
	case "shoot":
		oArchBishop.shoot = true;
		sTimer += 0.01 * global.gameTime;
		
		if(sTimer > 5) {
			state = choose("bishops", "bishops", "bishops");
			//oArchBishop.shoot = false;
			sTimer = 0;
			with(oBishop) {
				alive = false;	
			}
		}
	break;
}