var totalHealthWidth = hp * 6; // Total width of all health boxes plus spacing
var startingX = x - (totalHealthWidth / 2)+3; // This offsets the starting point so that the health boxes are centered

for (var i = 0; i < hp; ++i) {
    // Adjusted startingX by removing the extra -4 (since we've already accounted for centering) and using the new starting point
    draw_sprite(sEnemyHealth, 0, startingX + (6 * i), y - (8+sprite_height/3) - z);
}