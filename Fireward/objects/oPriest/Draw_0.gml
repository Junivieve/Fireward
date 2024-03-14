draw_sprite_ext(sprite_index, image_index, x, (y+16)+z, image_xscale, image_yscale*-1, image_angle, c_black, 0.2);
draw_sprite_ext(sprite_index, image_index, x, y-z, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
/*
var totalHealthWidth = hp * 6; // Total width of all health boxes plus spacing
var startingX = x - (totalHealthWidth / 2)+3; // This offsets the starting point so that the health boxes are centered

for (var i = 0; i < hp; ++i) {
    // Adjusted startingX by removing the extra -4 (since we've already accounted for centering) and using the new starting point
    draw_sprite(sPriestHeal, 0, startingX + (6 * i), y - (sprite_height/3) - z);
}

