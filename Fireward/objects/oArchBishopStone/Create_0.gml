event_inherited();
//image_xscale = 2;
//image_yscale = 2;
z = 15;
y = 100;
direction = -90;
function petrify() {
	var _b = instance_create_layer(x, y, "Instances", oStoneHeal);
	_b.direction = direction;
}