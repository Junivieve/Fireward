draw_sprite_ext(sprite_index, image_index, x, (y+16)+z, image_xscale, image_yscale*-1, image_angle, c_black, 0.2);
draw_sprite_ext(sprite_index, image_index, x, y-z, image_xscale, image_yscale, image_angle, image_blend, image_alpha);


draw_set_font(fText);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
//draw_text(48, 8, "Flameward");