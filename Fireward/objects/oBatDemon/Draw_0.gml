draw_sprite_ext(sprite_index, image_index, x, (y+8)+z, image_xscale, image_yscale*-1, image_angle, c_black, 0.2);
draw_sprite_ext(sprite_index, image_index, x, y-z, image_xscale, image_yscale, image_angle, image_blend, image_alpha);

image_xscale = x > oPlayer.x ? -1 : 1;

event_inherited();