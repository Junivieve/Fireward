/************************************************************************************

	gooey
	Configuration Script
	
*************************************************************************************/

// Change the enum value (UI_MEESAGE_LEVEL) to set the number of messages you receive in the log
// Set it to WARNING or above if running a production build
#macro		UI_LOG_MESSAGE_LEVEL		UI_MESSAGE_LEVEL.INFO

// Change this to false if your game is 2D. This sets surface_depth_enable.
#macro		UI_ENABLE_DEPTH				false
	
// Change this to Gamemaker values or sprite references if you want to use graphical cursors
#macro		UI_CURSOR_DEFAULT			cr_default
#macro		UI_CURSOR_INTERACT			cr_handpoint
#macro		UI_CURSOR_SIZE_NWSE			cr_size_nwse
#macro		UI_CURSOR_SIZE_NESW			cr_size_nesw
#macro		UI_CURSOR_SIZE_NS			cr_size_ns
#macro		UI_CURSOR_SIZE_WE			cr_size_we
#macro		UI_CURSOR_DRAG				cr_drag
