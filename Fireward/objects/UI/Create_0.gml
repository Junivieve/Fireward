/// GMLDocMaker trick
/// @struct						UI
/// @description				UI Manager object

surface_depth_disable(UI_ENABLE_DEPTH);

#region Private variables

	self.__scale = 1;
	self.__mouse_device = 0;
	self.__widgets = [];
	self.__panels = [];
	self.__currentlyHoveredPanel = noone;
	self.__currentlyHoveredWidget = noone;
	self.__currentlyDraggedWidget = noone;
	self.__drag_data = {
		__drag_action: -1,
		__drag_start_x: -1,
		__drag_start_y: -1,
		__drag_mouse_delta_x: -1,
		__drag_mouse_delta_y: -1,
		__drag_specific_start_x: -1,
		__drag_specific_start_y: -1,
		__drag_specific_start_width: -1,
		__drag_specific_start_height: -1
	}
	self.__UI_interaction = false;
	self.__logMessageLevel = UI_LOG_MESSAGE_LEVEL;
	self.__textbox_editing_ref = noone;
	
	
#endregion

#region Setters/Getters and Methods

	#region Private
	
		
	
		self.__setUICursor = function(_cursor) {
			if (_cursor > 0) {	// All cr_ constants are negative except cr_default, which is 0 - and this can coincide with a sprite index.
				window_set_cursor(cr_none);
				cursor_sprite = _cursor;
			}
			else {
				window_set_cursor(_cursor);
				cursor_sprite = -1;
			}
		}
	
		self.__logMessage = function(_msg, _lvl)	{ 
			var _lvls = ["INFO", "WARNING", "ERROR", "NOTICE"];
			if (_lvl >= self.__logMessageLevel) {
				show_debug_message("["+UI_LIBRARY_NAME+"] <"+ _lvls[_lvl]+"> "+_msg);
			}
		}
		
		self.__getPanelByIndex = function(_idx)		{ return _idx >= 0 && _idx < array_length(self.__panels) ? self.__panels[_idx] : noone; }
		
		self.__getPanelIndex = function(_ID) {
			var _i = 0;
			var _n = array_length(self.__panels);
			var _found = false;
			while (_i<_n && !_found) {
				if (self.__panels[_i].getID() == _ID) {
					_found = true;
				}
				else {
					_i++;
				}
			}
			return _found ? _i : noone;
		}
		
		self.__register = function(_ID) {
			var _suffix = 0;
			var _check_id = _ID.__ID;
			while (self.exists(_check_id)) {
				_suffix++;
				_check_id = _ID.__ID+string(_suffix);			
			}
			if (_suffix != 0)	{			
				self.__logMessage("Created widget ID renamed to '"+_check_id+"', because provided ID '"+_ID.__ID+"' already existed", UI_MESSAGE_LEVEL.WARNING);
				_ID.__ID = _check_id;
			}
			array_push(self.__widgets, _ID);
			if (_ID.getType() == UI_TYPE.PANEL) array_push(self.__panels, _ID);
			if (_suffix == 0) self.__logMessage("Created widget '"+_ID.__ID+"'", UI_MESSAGE_LEVEL.INFO);				
		}
		
		self.__destroy_widget = function(_ID) {			
			var _i=0; 
			var _n = array_length(self.__widgets);
			var _found = false;
			while (_i<_n && !_found) {
				if (self.__widgets[_i] == _ID) {
					array_delete(self.__widgets, _i, 1);
					_found = true;						
				}
				else {
					_i++
				}					
			}
			if (_ID.getType() == UI_TYPE.PANEL) {
				var _i=0; 
				var _n = array_length(self.__panels);
				var _found = false;
				while (_i<_n && !_found) {
					if (self.__panels[_i] == _ID) {
						array_delete(self.__panels, _i, 1);
						_found = true;						
					}
					else {
						_i++
					}					
				}
			}
		}
	
		self.__keep_allowed_chars = function(_string, _allow_lowercase = true, _allow_uppercase = true, _allow_spaces = true, _allow_digits = true, _allow_symbols = true, _symbols_allowed = ",.") {
			var _n = string_length(_string);
			var _str = "";
			for (var _i=1; _i<=_n; _i++) {
				if (	_allow_spaces && string_ord_at(_string, _i) == 32 ||
						_allow_uppercase && (string_ord_at(_string, _i) >= 65 && string_ord_at(_string, _i) <= 90) ||
						_allow_lowercase && (string_ord_at(_string, _i) >= 97 && string_ord_at(_string, _i) <= 122) ||
						_allow_digits && (string_ord_at(_string, _i) >= 48 && string_ord_at(_string, _i) <= 57)
						) {
					_str += string_char_at(_string, _i);
				}
				else if (_allow_symbols) {
					var _m = string_length(_symbols_allowed);
					var _allow = false;
					for (var _j=1; _j<=_m; _j++) {
						_allow = _allow || string_ord_at(_string, _i) == string_ord_at(_symbols_allowed, _j);
					}
					if (_allow)	_str += string_char_at(_string, _i);
				}
			}
			return _str;
		}
	
	#endregion
	
	/// @method					getLogMessageLevel()
	/// @description			gets the message level for the library
	/// @return					{Enum}	The message level, according to UI_MESSAGE_LEVEL	
	self.getLogMessageLevel = function()		{ return self.__logMessageLevel; }
	
	/// @method					setLogMessageLevel
	/// @description			sets sthe message level for the library
	/// @param					{Enum}	_lvl	The message level, according to UI_MESSAGE_LEVEL
	/// @return					{UI}	self
	self.setLogMessageLevel = function(_lvl)	{ self.__logMessageLevel = _lvl; return self; }
	
	/// @method					getScale()
	/// @description			gets the global rendering scale multiplier of the UI (1 is the default)
	/// @return					{Real}	The global scale multiplier of the UI
	self.getScale = function()					{ return self.__scale; }
	
	/// @method					setScale(_scale)
	/// @description			sets the global rendering scale multiplier of the UI (1 is the default)
	/// @param					{Real}	_scale	The global scale multiplier of the UI
	/// @return					{UI}	self
	self.setScale = function(_scale)			{ self.__scale = _scale; return self; }
	
	/// @method					resetScale()
	/// @description			resets the global rendering scale multiplier of the UI to 1x (1)
	/// @return					{Real}	The global scale multiplier of the UI
	self.resetScale = function()				{ self.__scale = 1; return self; }
	
	/// @method					getMouseDevice()
	/// @description			gets the currently used mouse device for handling mouse events. By default it's 0.
	/// @return					{Real}	The currently used mouse device
	self.getMouseDevice = function()			{ return self.__mouse_device; }
	
	/// @method					setMouseDevice(_device)
	/// @description			sets the mouse device for handling mouse events.
	/// @param					{Real}	_device	The number of the mouse device to use.
	/// @return					{UI}	self
	self.setMouseDevice = function(_device)		{ self.__mouse_device = _device; return self; }
	
	/// @method					getWidgets()
	/// @description			gets an array with all widgets currently registered
	/// @return					{Array<UIWidget>}	The array with the widgets
	self.getWidgets = function()				{ return self.__widgets; }
	
	/// @method					exists(_ID)
	/// @description			returns whether the specified Widget exists, identified by its *string ID* (not by its reference).
	/// @param					{String}	_ID		The Widget string ID
	/// @return					{Bool}	Whether the specified Widget exists
	self.exists = function(_ID)					{ return self.get(_ID) != noone; }
	
	/// @method					get(_ID)
	/// @description			gets a specific Widget by its *string ID* (not by its reference).
	/// @param					{String}	_ID		The Widget string ID
	/// @return					{Any}	The Widget's reference, or noone if not found
	self.get = function(_ID) {
		var _i = 0;
		var _n = array_length(self.__widgets);
		var _found = false;
		while (_i<_n && !_found) {
			if (self.__widgets[_i].getID() == _ID) {
				_found = true;
			}
			else {
				_i++;
			}
		}
		return _found ? self.__widgets[_i] : noone;
	}
	
	/// @method					getPanels()
	/// @description			gets an array with all Panel widgets currently registered
	/// @return					{Array<UIPanel>}	The array with the Panel widgets
	self.getPanels = function()					{ return self.__panels; }
	
	/// @method					getFocusedPanel()
	/// @description			gets the reference to the currently focused Panel widget, or -1 if no panels exist.
	/// @return					{UIPanel}	The reference to the currently focus Panel
	self.getFocusedPanel = function()			{ return array_length(self.__panels) > 0 ? self.__panels[array_length(self.__panels)-1] : -1; }
	
	/// @method					setFocusedPanel(_ID)
	/// @description			sets the specified Panel as focused
	/// @param					{String}	_ID		The Widget string ID	
	/// @return					{UI}	self
	self.setFocusedPanel = function(_ID) {				
		var _pos = self.__getPanelIndex(_ID);
		var _ref = self.get(_ID);
		array_delete(self.__panels, _pos, 1);
		array_push(self.__panels, _ref);
		return self;
	}
	
	/// @method					isInteracting()
	/// @description			returns whether the user is interacting with the UI, to prevent clicks/actions "drilling-through" to the game
	/// @return					{Bool}	whether the user is interacting with the UI
	self.isInteracting = function() {				
		return self.__UI_interaction;
	}
			
	/// @method					processEvents()
	/// @description			calls the UI library to process events. Run this in the Begin or End Step event of the manager object	
	self.processEvents = function() {
		self.__UI_interaction = false;
		
		// Drag
		if (UI.__currentlyDraggedWidget != noone && UI.__currentlyDraggedWidget.__draggable) {
			self.__UI_interaction = true;
			UI.__currentlyDraggedWidget.__drag();
			// Handle panel drag			
			if (UI.__currentlyDraggedWidget.__type == UI_TYPE.PANEL) {
				// Process common widget events (and descendants)
				var _common = UI.__currentlyDraggedWidget.__common_widgets;
				for (var  _n=array_length(_common), _i=_n-1; _i>=0; _i--) { 
					_common[_i].__processEvents();					
					var _descendants = _common[_i].getDescendants();
					for (var _m=array_length(_descendants), _j=_m-1; _j>=0; _j--) {
						_descendants[_j].__processEvents();
					}
				}
				
				// Determine common widget to execute built-in behaviors and callbacks depending on the processed events
				_i=_n-1;
				var _mouse_over = false;
				while (_i>=0 && !_mouse_over) {
					if (_common[_i].__events_fired[UI_EVENT.MOUSE_OVER]) {
						_mouse_over = true;
					}
					else {
						_i--;
					}
				}
				if (_mouse_over) {
					self.__currentlyHoveredWidget = _common[_i];
					// Override drag action of panel
					if (_common[_i].__events_fired[UI_EVENT.LEFT_HOLD] && _common[_i].__dragCondition())	{
						_common[_i].__dragStart();						
					}
					_common[_i].__builtInBehavior();
				}
				else {
					self.__currentlyHoveredWidget = noone;
				}
				
			}			
		}
		else {
			UI.__setUICursor(UI_CURSOR_DEFAULT);
			// Check for mouseover on all enabled and visible panels
			var _n = array_length(self.__panels);
			for (var _i = _n-1; _i>=0; _i--) {
				//if (self.__panels[_i].__visible && self.__panels[_i].__enabled)		self.__panels[_i].__processMouseover();
				self.__panels[_i].__processMouseover();
			}
		
			// Determine topmost mouseovered panel
			var _n = array_length(self.__panels);
			_i=_n-1;
			var _mouse_over = false;
			while (_i>=0 && !_mouse_over) {
				if (self.__panels[_i].__events_fired[UI_EVENT.MOUSE_OVER]) {
					_mouse_over = true;
				}
				else {
					_i--;
				}
			}
			self.__currentlyHoveredPanel = _i >= 0 ? _i : -1;
			if (self.__currentlyHoveredPanel != -1) {
				self.__UI_interaction = true;
				var _panel = self.__getPanelByIndex(self.__currentlyHoveredPanel);			
							
				// Get topmost panel, get all its descendants				
				var _descendants = _panel.getDescendants();
				
				// Process panel events - check if drag is active. If it is, give preference to Panel drag action; if not, clear panel events and proceed
				_panel.__processEvents();
				if (self.__currentlyDraggedWidget == _panel && self.__drag_data.__drag_action != UI_RESIZE_DRAG.NONE) {		
					//show_debug_message("  Panel "+self.__currentlyDraggedWidget.__ID+" with drag behavior "+string(self.__drag_data.__drag_action));
					_panel.__builtInBehavior();					
				}
				else {					
					//_panel.__clearEvents(false);
					// Process events on all enabled and visible children widgets
					var _n = array_length(_descendants);
					for (var _i = _n-1; _i>=0; _i--)	_descendants[_i].__processEvents();
					
					// Determine children widget to execute built-in behaviors and callbacks depending on the processed events
					_i=_n-1;
					var _mouse_over = false;
					while (_i>=0 && !_mouse_over) {
						if (_descendants[_i].__events_fired[UI_EVENT.MOUSE_OVER]) {
							_mouse_over = true;
							if (_descendants[_i].__type != UI_TYPE.TEXT && 
								_descendants[_i].__type != UI_TYPE.SPRITE &&
								_descendants[_i].__type != UI_TYPE.GROUP &&
								_descendants[_i].__type != UI_TYPE.GRID
								)
								UI.__setUICursor(UI_CURSOR_INTERACT);
						}
						else {
							_i--;
						}
					}
					if (_mouse_over) {						
						self.__currentlyHoveredWidget = _descendants[_i];
						// Override drag action of panel
						if (_descendants[_i].__events_fired[UI_EVENT.LEFT_HOLD] && _descendants[_i].__dragCondition())	{
							_descendants[_i].__dragStart();						
						}
						_descendants[_i].__builtInBehavior();
					}
					else {
						self.__currentlyHoveredWidget = noone;
						_panel.__builtInBehavior();	
					}
					
					// Process mouse exit
					for (var _i=0, _n=array_length(self.__widgets); _i<_n; _i++) {
						if (self.__widgets[_i].__events_fired[UI_EVENT.MOUSE_EXIT])	self.__widgets[_i].__callbacks[UI_EVENT.MOUSE_EXIT]();
					}
				}
			}
		
		
		
			// Handle text string for textboxes
			if (self.__textbox_editing_ref != noone) {
			
				var _actually_edit = false;
			
				// Cursor
				var _c = self.__textbox_editing_ref.getCursorPos();
				var _current_text = self.__textbox_editing_ref.getText();
				var _len = string_length(_current_text);
			
			
						
				// Check if click was done outside all textboxes
				if (device_mouse_check_button_pressed(self.getMouseDevice(), mb_left)) {
					var _click_outside_all = true;
					var _i=0, _n=array_length(self.__widgets);
					while (_i<_n && _click_outside_all) {					
						var _widget = self.__widgets[_i];
						if (_widget.__type == UI_TYPE.TEXTBOX) {
							_click_outside_all = _click_outside_all && !_widget.__events_fired[UI_EVENT.LEFT_CLICK];
						}
						_i++;
					}
					if (_click_outside_all) {
						self.__textbox_editing_ref.setCursorPos(-1);
						self.__textbox_editing_ref = noone;
						keyboard_string = "";
					}
					else {					
						_actually_edit = true;
					}
				}
				else {			
					_actually_edit = true;
				}
			
				if (_actually_edit) { // Capture text from keyboard at cursor position
					var _c_pos = (keyboard_lastkey == vk_delete) ? _c+2 : _c+1;
					keyboard_string = self.__keep_allowed_chars(keyboard_string, self.__textbox_editing_ref.getAllowLowercaseLetters(), self.__textbox_editing_ref.getAllowUppercaseLetters(), self.__textbox_editing_ref.getAllowSpaces(), self.__textbox_editing_ref.getAllowDigits(), self.__textbox_editing_ref.getAllowSymbols(), self.__textbox_editing_ref.getSymbolsAllowed() );				
					self.__textbox_editing_ref.setText(_c == -1 ? keyboard_string : keyboard_string + string_copy(_current_text, _c_pos, _len));
					var _c = self.__textbox_editing_ref.getCursorPos();
					var _current_text = self.__textbox_editing_ref.getText();
					keyboard_string = _c == -1 ? _current_text : string_copy(_current_text, 1, _c);
				}
			}
		}
		
		// Check drag end - Currently dragged widget might be noone now because of panel close
		if (UI.__currentlyDraggedWidget != noone)	UI.__currentlyDraggedWidget.__isDragEnd();
	}
	
	/// @method					render()
	/// @description			calls the UI library to render the Widgets. Run this in the Draw GUI Begin event of the manager object	
	self.render = function() {
		for (var _i=0, _n = array_length(self.__panels); _i<_n; _i++) {
			if (_i == _n-1 && self.__panels[_i].__modal && self.__panels[_i].__modal_color != -1) {
				draw_set_alpha(self.__panels[_i].__modal_alpha);
				draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), self.__panels[_i].__modal_color, self.__panels[_i].__modal_color,self.__panels[_i].__modal_color,self.__panels[_i].__modal_color, false);
				draw_set_alpha(1);
			}			
			self.__panels[_i].__render();
		}
	}
	
	/// @method					cleanup()
	/// @description			calls the UI library to cleanup the UI. Run this in the Clean Up of the manager object
	self.cleanup = function() {
		if (argument_count >= 1) throw("ERROR: trying to use UI method cleanup() to destroy an individual widget. Use widget.destroy() instead");
		for (var _i=array_length(self.__panels)-1; _i>=0; _i--) {
			self.__panels[_i].destroy();			
		}
	}
	
#endregion

self.__logMessage("Welcome to "+UI_LIBRARY_NAME+" "+UI_LIBRARY_VERSION+", an user interface library by manta ray", UI_MESSAGE_LEVEL.NOTICE);