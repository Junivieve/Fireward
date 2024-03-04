draw_sprite_ext(sprite_index, image_index, x, (y+16)+z, image_xscale, image_yscale*-1, image_angle, c_black, 0.2);
draw_sprite_ext(sprite_index, image_index, x, y-z, image_xscale, image_yscale, image_angle, image_blend, image_alpha);

draw_sprite(sHeart, 0, x-8, (y-16)-z);
draw_set_font(fText);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x+4, (y-17)-z, hp);

//draw_text(48, 8, "Cindersoul");
//draw_text(48, 8, "Flameward");
//draw_text(48, 8, "Incendia");
draw_text(48, 8, "Flameward");