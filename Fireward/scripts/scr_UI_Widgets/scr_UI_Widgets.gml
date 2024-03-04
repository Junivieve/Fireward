#region Helper Enums and Macros
	#macro UI_TEXT_RENDERER		scribble
	#macro GOOEY_NUM_CALLBACKS	15
	#macro UI_LIBRARY_NAME		"gooey"
	#macro UI_LIBRARY_VERSION	"2023.10"
	#macro UI_SCROLL_SPEED		20
	
	enum UI_MESSAGE_LEVEL {
		INFO,
		WARNING,
		ERROR,
		NOTICE
	}
	enum UI_EVENT {
		MOUSE_OVER,
		LEFT_CLICK,
		MIDDLE_CLICK,
		RIGHT_CLICK,
		LEFT_HOLD,
		MIDDLE_HOLD,
		RIGHT_HOLD,
		LEFT_RELEASE,
		MIDDLE_RELEASE,
		RIGHT_RELEASE,
		MOUSE_ENTER,		
		MOUSE_EXIT,
		MOUSE_WHEEL_UP,
		MOUSE_WHEEL_DOWN,
		
		VALUE_CHANGED
	}	
	enum UI_TYPE {
		PANEL,
		BUTTON,
		GROUP,
		TEXT,
		CHECKBOX,
		SLIDER,
		TEXTBOX,
		OPTION_GROUP,
		DROPDOWN,
		SPINNER,
		PROGRESSBAR,
		CANVAS,
		SPRITE,
		GRID
	}
	enum UI_RESIZE_DRAG {
		NONE,
		DRAG,
		RESIZE_NW,
		RESIZE_N,
		RESIZE_NE,
		RESIZE_W,
		RESIZE_E,
		RESIZE_SW,
		RESIZE_S,
		RESIZE_SE
	}	
	enum UI_RELATIVE_TO {
		TOP_LEFT,
		TOP_CENTER,
		TOP_RIGHT,
		MIDDLE_LEFT,
		MIDDLE_CENTER,
		MIDDLE_RIGHT,
		BOTTOM_LEFT,
		BOTTOM_CENTER,
		BOTTOM_RIGHT
	}
	enum UI_ORIENTATION {
		HORIZONTAL,
		VERTICAL
	}
	enum UI_PROGRESSBAR_RENDER_BEHAVIOR {
		REVEAL,
		STRETCH,
		REPEAT
	}
	enum UI_TAB_SIZE_BEHAVIOR {
		SPRITE,
		SPECIFIC,
		MAX
	}
#endregion

#region Widgets

	#region UIPanel
	
		/// @constructor	UIPanel(_id, _x, _y, _width, _height, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Panel widget, the main container of the UI system
		/// @param			{String}			_id				The Panel's name, a unique string ID. If the specified name is taken, the panel will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Panel, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Panel, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the Panel
		/// @param			{Real}				_height			The height of the Panel
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Panel
		/// @param			{Enum}				[_relative_to]	The position relative to which the Panel will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIPanel}							self
		function UIPanel(_id, _x, _y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.PANEL;			
				self.__draggable = true;
				self.__drag_bar_height = 32;
				self.__resizable = true;				
				self.__movable = true;
				self.__resize_border_width = 4;
				self.__title = "";
				self.__title_format = "";
				self.__title_anchor = UI_RELATIVE_TO.TOP_CENTER;
				self.__title_offset = {x: 0, y: 0};
				self.__close_button = noone;
				self.__close_button_sprite = noone;
				self.__close_button_anchor = UI_RELATIVE_TO.TOP_RIGHT;
				self.__close_button_offset = {x: 0, y: 0};
				
				// Tabs Preparation
				self.__tabs = [[]];
				self.__current_tab = 0;
				
				self.__tab_group = {
					__vertical: false,
					__text_format: "[c_black]"
				}
				
				self.__tab_offset = 0;
				self.__tab_spacing = 0;
				self.__tab_size_behavior = UI_TAB_SIZE_BEHAVIOR.MAX;
				self.__tab_size_specific = 0;
				self.__tab_group_control = noone; // This is the UIGroup control for the tab buttons
								
				function __UITab(_sprite = noone, _sprite_mouseover = noone, _sprite_selected = noone) constructor {					
					self.text = "";
					self.text_mouseover = "";
					self.text_selected = "";					
					self.tab_index = 0;
					self.sprite_tab = _sprite;
					self.sprite_tab_mouseover = _sprite_mouseover;
					self.sprite_tab_selected = _sprite_selected;			
					self.image_tab = 0;
					self.image_tab_mouseover = 0;
					self.image_tab_selected = 0;
					self.text_format = "";
					self.text_format_mouseover = "";
					self.text_format_selected = "";
					return self;
				}
				
				// First tab data
				var _id_tab = new __UITab();
				self.__tab_data = [_id_tab];
				
				// Common widgets
				self.__common_widgets = [];
				self.__children = self.__tabs[self.__current_tab];	// self.__children is a pointer to the tabs array, which will be the one to be populated with widgets with add()
				
				// Modal
				self.__modal = false;
				self.__modal_color = c_black;
				self.__modal_alpha = 0.75;
				
			#endregion
			#region Setters/Getters		
			
				/// @method					getTitle()
				/// @desc					Returns the title of the Panel
				/// @return					{string} The title of the Panel
				self.getTitle = function()							{ return self.__title; }
			
				/// @method					setTitle(_title)
				/// @description			Sets the title of the Panel
				/// @param					{String} _title	The desired title
				/// @return					{UIPanel}	self
				self.setTitle = function(_title)					{ self.__title = _title; return self; }
			
				/// @method					getTitleOffset()
				/// @description			Gets the title offset, starting from the title anchor point.
				/// @return	{Struct}			the title offset as as struct {x, y}
				self.getTitleOffset = function() {
					return self.__title_offset;
				}

				/// @method					setTitleOffset(_offset)
				/// @description			Sets the title offset, starting from the title anchor point.
				/// @param					{Struct}			_offset	a struct with {x, y}
				/// @return					{Struct}		self
				self.setTitleOffset = function(_offset) {
					self.__title_offset = _offset;
					return self;
				}

				/// @method					getTitleAnchor()
				/// @description			Gets the anchor for the Panel title, relative to the drag bar
				/// @return					{Enum}	The anchor for the Panel's title, according to UI_RELATIVE.
				self.getTitlelAnchor = function()					{ return self.__title_anchor; }

				/// @method					setTitleAnchor(_anchor)
				/// @description			Sets the anchor for the Panel title, relative to the drag bar
				/// @param					{Enum}	_anchor	An anchor point for the Panel title, according to UI_RELATIVE.			
				/// @return					{UIPanel}	self
				self.setTitleAnchor = function(_anchor)				{ self.__title_anchor = _anchor; return self; }
			
				/// @method					getTitleFormat()
				/// @desc					Returns the title format of the Panel
				/// @return					{string} The title format of the Panel
				self.getTitleFormat = function()							{ return self.__title_format; }
			
				/// @method					setTitleFormat(_format)
				/// @description			Sets the title format of the Panel
				/// @param					{String} _format	The desired title
				/// @return					{UIPanel}	self
				self.setTitleFormat = function(_format)					{ self.__title_format = _format; return self; }
			
			
				/// @method					getDragBarHeight()
				/// @description			Gets the height of the Panel's drag zone, from the top of the panel downward.			
				/// @return					{Real}	The height in pixels of the drag zone.
				self.getDragBarHeight = function()					{ return self.__drag_bar_height; }
			
				/// @method					setDragBarHeight(_height)
				/// @description			Sets the height of the Panel's drag zon, from the top of the panel downward.
				/// @param					{Real}	_height	The desired height in pixels
				/// @return					{UIPanel}	self
				self.setDragBarHeight = function(_height)			{ self.__drag_bar_height = _height; return self; }
			
				/// @method					getCloseButton()
				/// @description			Gets the close Button reference that is assigned to the Panel
				/// @return					{UIButton}	the Button reference
				self.getCloseButton = function() { return self.__close_button; }
			
				/// @method					setCloseButtonSprite(_button_sprite)
				/// @description			Sets a sprite for rendering the close button for the Panel. If `noone`, there will be no close button.
				/// @param					{Asset.GMSprite}	_button_sprite	The sprite to assign to the Panel close button, or `noone` to remove it
				/// @return					{UIPanel}	self
				self.setCloseButtonSprite = function(_button_sprite) { 
					if (self.__close_button_sprite == noone && _button_sprite != noone) { // Create button					
						self.__close_button_sprite = _button_sprite;
						var _w = sprite_exists(_button_sprite) ? sprite_get_width(_button_sprite) : 0;
						var _h = sprite_exists(_button_sprite) ? sprite_get_height(_button_sprite) : 0;
						self.__close_button = new UIButton(self.__ID+"_CloseButton", self.__close_button_offset.x, self.__close_button_offset.y, _w, _h, "", _button_sprite, self.__close_button_anchor);
						self.__close_button.setCallback(UI_EVENT.LEFT_RELEASE, function() {						
							self.destroy(); // self is UIPanel here
						});
						self.add(self.__close_button, -1); // add to common
					}
					else if (self.__close_button_sprite != noone && _button_sprite != noone) { // Change sprite
						self.__close_button_sprite = _button_sprite;
						self.__close_button.setSprite(_button_sprite);
						var _w = sprite_exists(_button_sprite) ? sprite_get_width(_button_sprite) : 0;
						var _h = sprite_exists(_button_sprite) ? sprite_get_height(_button_sprite) : 0;
						self.__close_button.setDimensions(self.__close_button_offset.x, self.__close_button_offset.y, _w, _h, self.__close_button_anchor);
					}
					else if (self.__close_button_sprite != noone && _button_sprite == noone) { // Destroy button					
						self.remove(self.__close_button.__ID, -1);
						self.__close_button.destroy();
						self.__close_button = noone;
						self.__close_button_sprite = noone;					
					}				
					return self;
				}
				
				/// @method					getCloseButtonOffset()
				/// @description			Gets the close button offset, starting from the close button anchor point.
				/// @return	{Struct}		the close button offset, as a struct {x, y}
				self.getCloseButtonOffset = function() {
					return self.__close_button_offset;
				}

				/// @method					setCloseButtonOffset(_offset)
				/// @description			Sets the close button offset, starting from the close button anchor point.
				/// @param					{Struct}		_offset	the value to set, a struct {x, y}
				/// @return					{Struct}		self
				self.setCloseButtonOffset = function(_offset) {
					self.__close_button_offset = _offset;
					var _w = sprite_exists(self.__close_button_sprite) ? sprite_get_width(self.__close_button_sprite) : 0;
					var _h = sprite_exists(self.__close_button_sprite) ? sprite_get_height(self.__close_button_sprite) : 0;
					if (self.__close_button != noone)	self.__close_button.setDimensions(self.__close_button_offset.x, self.__close_button_offset.y, _w, _h, self.__close_button_anchor);
					return self;
				}

				/// @method					getCloseButtonAnchor()
				/// @description			Gets the anchor for the Panel close button
				/// @return					{Enum}	The anchor for the Panel's close button, according to UI_RELATIVE.
				self.getCloseButtonlAnchor = function()					{ return self.__close_button_anchor; }

				/// @method					setCloseButtonAnchor(_anchor)
				/// @description			Sets the anchor for the Panel close button
				/// @param					{Enum}	_anchor	An anchor point for the Panel close button, according to UI_RELATIVE.			
				/// @return					{UIPanel}	self
				self.setCloseButtonAnchor = function(_anchor) {
					self.__close_button_anchor = _anchor;
					var _w = sprite_exists(self.__close_button_sprite) ? sprite_get_width(self.__close_button_sprite) : 0;
					var _h = sprite_exists(self.__close_button_sprite) ? sprite_get_height(self.__close_button_sprite) : 0;
					if (self.__close_button != noone)	self.__close_button.setDimensions(self.__close_button_offset.x, self.__close_button_offset.y, _w, _h, self.__close_button_anchor);
					return self;
				}
				
				/// @method					getModal()
				/// @description			Gets whether this Panel is modal. <br>
				///							A modal Panel will get focus and disable all other widgets until it's destroyed. Only one Panel can be modal at any one time.
				/// @return					{Bool}	Whether this Panel is modal or not
				self.getModal = function()					{ return self.__modal; }
			
				/// @method					setModal(_modal)
				/// @description			Sets this Panel as modal.<br>
				///							A modal Panel will get focus and disable all other widgets until it's destroyed. Only one Panel can be modal at any one time.
				/// @param					{Bool}	_modal	whether to set this panel as modal
				/// @return					{UIPanel}	self
				self.setModal = function(_modal) {
					var _change = _modal != self.__modal;
					self.__modal = _modal;					
					if (_change) {
						if (self.__modal) {
							UI.setFocusedPanel(self.__ID);
							var _n = array_length(UI.__panels);
							for (var _i=0; _i<_n; _i++) {
								if (UI.__panels[_i].__ID != self.__ID) {
									UI.__panels[_i].setEnabled(false);
									if (UI.__panels[_i].__modal)	UI.__panels[_i].setModal(false);
								}
							}
						}
						else {
							var _n = array_length(UI.__panels);
							for (var _i=0; _i<_n; _i++) {
								if (UI.__panels[_i].__ID != self.__ID) {
									UI.__panels[_i].setEnabled(true);									
								}
							}
						}
					}
					return self;
				}
				
				/// @method					getModalOverlayColor()
				/// @description			Gets the color of the overlay drawn over non-modal Panels when this Panel is modal. If -1, it does not draw an overlay.
				/// @return					{Asset.GMColour}	the color to draw, or -1
				self.getModalOverlayColor = function()					{ return self.__modal_color; }
			
				/// @method					setModalOverlayColor(_color)
				/// @description			Sets the color of the overlay drawn over non-modal Panels when this Panel is modal. If -1, it does not draw an overlay.
				/// @param					{Asset.GMColour}	_color	the color to draw, or -1
				/// @return					{UIPanel}	self
				self.setModalOverlayColor = function(_color)			{ self.__modal_color = _color; return self;	}
					
				/// @method					getModalOverlayAlpha()
				/// @description			Gets the alpha of the overlay drawn over non-modal Panels when this Panel is modal.
				/// @return					{Real}	the alpha to draw the overlay with
				self.getModalOverlayAlpha = function()					{ return self.__modal_alpha; }
			
				/// @method					setModalOverlayAlpha(_alpha)
				/// @description			Sets the alpha of the overlay drawn over non-modal Panels when this Panel is modal.
				/// @param					{Real}	_alpha	the alpha to draw the overlay with
				/// @return					{UIPanel}	self
				self.setModalOverlayAlpha = function(_alpha)			{ self.__modal_alpha = _alpha; return self;	}
				
				/// @method				getMovable()
				/// @description		Gets whether the widget is movable (currently only set for Panels)
				/// @return				{Bool}		the movable value
				self.getMovable = function() {
					return self.__movable;
				}

				/// @method				setMovable(_movable)
				/// @description		Sets whether the widget is movable (currently only set for Panels)
				/// @param				{Bool}		_movable	the value to set
				/// @return				{UIPanel}	self
				self.setMovable = function(_movable) {
					self.__movable = _movable;
					return self;
				}
				
			#endregion	
			#region Setters/Getters - Tab Management
				
				/// @method					getTabSizeBehavior()
				/// @description			Gets the behavior of the tab size (width/length according to tab group orientation), specified by the `UI_TAB_SIZE_BEHAVIOR` enum
				/// @return					{Enum}			the behavior of the tab size
				self.getTabSizeBehavior = function() {
					return self.__tab_size_behavior;
				}

				/// @method					setTabSizeBehavior(_behavior)
				/// @description			Sets the behavior of the tab size (width/length according to tab group orientation), specified by the `UI_TAB_SIZE_BEHAVIOR` enum
				/// @param					{Enum}			_behavior	the behavior of the tab size
				/// @return					{UIPanel}		self
				self.setTabSizeBehavior = function(_behavior) {
					self.__tab_size_behavior = _behavior;
					//self.__changeTabSizeBehavior();
					self.__redimensionTabs();
					return self;
				}
				
				/// @method					getTabSpecificSize()
				/// @description			Gets the specific size set for all tabs, this is used when setting `UI_TAB_SIZE_BEHAVIOR` to `SPECIFIC`.
				/// @return					{Real}			the behavior of the tab size
				self.getTabSpecificSize = function() {
					return self.__tab_size_specific;
				}

				/// @method					setTabSpecificSize(_size)
				/// @description			Sets the specific size set for all tabs, this is used when setting `UI_TAB_SIZE_BEHAVIOR` to `SPECIFIC`.
				/// @param					{Real}			_size	the size to set
				/// @return					{UIPanel}		self
				self.setTabSpecificSize = function(_size) {
					self.__tab_size_specific = _size;
					self.__redimensionTabs();
					return self;
				}
				
				/// @method					getTabOffset()
				/// @description			Gets the value of the tab offset, starting from the tab anchor point.
				/// @return	{Real}			the value of the tab offset
				self.getTabOffset = function() {
					return self.__tab_offset;
				}

				/// @method					setTabOffset(_offset)
				/// @description			Sets the value of the tab offset, starting from the tab anchor point.
				/// @param					{Real}			_offset	the value to set
				/// @return					{UIPanel}		self
				self.setTabOffset = function(_offset) {
					self.__tab_offset = _offset;
					self.__redimensionTabs();
					return self;
				}
				
				/// @method					getTabSpacing()
				/// @description			Gets the value of the tab spacing
				/// @return	{Real}			the value of the tab spacing
				self.getTabSpacing = function() {
					return self.__tab_spacing;
				}

				/// @method					setTabSpacing(_spacing)
				/// @description			Sets the value of the tab spacing
				/// @param					{Real}			_spacing	the value to set
				/// @return					{UIPanel}		self
				self.setTabSpacing = function(_spacing) {
					self.__tab_spacing = _spacing;
					self.__redimensionTabs();
					return self;
				}
			
				/// @method				getRawTabText(_tab)
				/// @description		Gets the title text of the specified tab, without Scribble formatting tags.
				/// @param				{Real}	_tab	The tab to get title text from
				///	@return				{String}	The title text, without Scribble formatting tags
				self.getRawTabText = function(_tab)					{ return UI_TEXT_RENDERER(self.__tab_data[_tab].text).get_text(); }
			
				/// @method				getTabText(_tab)
				/// @description		Gets the title text of the specified tab
				/// @param				{Real}	_tab	The tab to get title text from
				///	@return				{String}	The title text
				self.getTabText = function(_tab)					{ return self.__tab_data[_tab].text; }
				
				/// @method				setTabText(_tab, _text, _set_all_states=true)
				/// @description		Sets the title text of the specified tab
				/// @param				{Real}		_tab	The tab to set title text
				/// @param				{String}	_text	The title text to set
				/// @param				{Bool}		[_set_all_states]	If true, set text for all states (normal/mouseovered/selected). By default, true.
				///	@return				{UIPanel}	self
				self.setTabText = function(_tab, _text, _set_all_states = true)	{
					self.__tab_data[_tab].text = _text; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setText(_text);
					if (_set_all_states) {
						self.setTabTextMouseover(_tab, _text);
						self.setTabTextSelected(_tab, _text);
					}
					return self;
				}
				
				/// @method				getTabTextFormat(_tab)
				/// @description		Gets the text format of the specified tab
				/// @param				{Real}	_tab	The tab to get the text format text from
				///	@return				{String}	The format
				self.getTabTextFormat = function(_tab)					{ return self.__tab_data[_tab].text_format; }
				
				/// @method				setTabTextFormat(_tab, _format)
				/// @description		Sets the text format of the specified tab
				/// @param				{Real}		_tab	The tab to set text format to
				/// @param				{String}	_format	The text format to set
				///	@return				{UIPanel}	self
				self.setTabTextFormat = function(_tab, _format)	{
					self.__tab_data[_tab].text_format = _format; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setTextFormat(_format);
					return self;
				}
				
				/// @method				setTabsTextFormat(_format)
				/// @description		Sets the text format for all tabs
				/// @param				{String}	_format	The text format to set
				///	@return				{UIPanel}	self
				self.setTabsTextFormat = function(_format)	{
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) self.setTabTextFormat(_i, _format);
					return self;
				}
				
				/// @method				getTabTextFormatMouseover(_tab)
				/// @description		Gets the text format of the specified tab when mouseovered
				/// @param				{Real}	_tab	The tab to get the text mouseover format text from
				///	@return				{String}	The format
				self.getTabTextFormatMouseover = function(_tab)					{ return self.__tab_data[_tab].text_format_mouseover; }
				
				/// @method				setTabTextFormatMouseover(_tab, _format)
				/// @description		Sets the text format of the specified tab when mouseovered
				/// @param				{Real}		_tab	The tab to set text format to
				/// @param				{String}	_format	The text format to set
				///	@return				{UIPanel}	self
				self.setTabTextFormatMouseover = function(_tab, _format)	{
					self.__tab_data[_tab].text_format_mouseover = _format; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setTextFormatMouseover(_format);
					return self;
				}
				
				/// @method				setTabsTextFormatMouseover(_format)
				/// @description		Sets the text format for all tabs when mouseovered
				/// @param				{String}	_format	The text format to set
				///	@return				{UIPanel}	self
				self.setTabsTextFormatMouseover = function(_format)	{
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) self.setTabTextFormatMouseover(_i, _format);
					return self;
				}
				
				/// @method				getTabTextFormatSelected(_tab)
				/// @description		Gets the text format of the specified tab when selected 
				/// @param				{Real}	_tab	The tab to get the text format from
				///	@return				{String}	The format
				self.getTabTextFormatSelected = function(_tab)					{ return self.__tab_data[_tab].text_format_selected; }
				
				/// @method				setTabTextFormatSelected(_tab, _format)
				/// @description		Sets the text format of the specified tab when selected
				/// @param				{Real}		_tab	The tab to set text format to
				/// @param				{String}	_format	The text format to set
				///	@return				{UIPanel}	self
				self.setTabTextFormatSelected = function(_tab, _format)	{
					self.__tab_data[_tab].text_format_selected = _format; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setTextFormatClick(_format);
					return self;
				}
				
				/// @method				setTabsTextFormatSelected(_format)
				/// @description		Sets the text format for all tabs when selected
				/// @param				{String}	_format	The text format to set
				///	@return				{UIPanel}	self
				self.setTabsTextFormatSelected = function(_format)	{
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) self.setTabTextFormatSelected(_i, _format);
					return self;
				}
				
				/// @method				getRawTabTextMouseover(_tab)
				/// @description		Gets the title text of the specified tab when mouseovered, without Scribble formatting tags.
				/// @param				{Real}	_tab	The tab to get the mouseover title text from
				///	@return				{String}	The title text when mouseovered, without Scribble formatting tags
				self.getRawTabTextMouseover = function(_tab)		{ return UI_TEXT_RENDERER(self.__tab_data[_tab].text_mouseover).get_text(); }
			
				/// @method				getTabTextMouseover(_tab)
				/// @description		Gets the title text of the specified tab when mouseovered
				/// @param				{Real}	_tab	The tab to get the mouseover title text from
				///	@return				{String}	The title text when mouseovered
				self.getTabTextMouseover = function(_tab)			{ return self.__tab_data[_tab].text_mouseover; }
				
				/// @method				setTabTextMouseover(_tab, _text)
				/// @description		Sets the title text of the specified tab when mouseovered
				/// @param				{Real}		_tab	The tab to set mouseover title text from
				/// @param				{String}	_text	The title text to set when mouseovered
				///	@return				{UIPanel}	self
				self.setTabTextMouseover = function(_tab, _text) {
					self.__tab_data[_tab].text_mouseover = _text;
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setTextMouseover(_text);
					return self;
				}
				
				/// @method				getRawTabTextSelected(_tab)
				/// @description		Gets the title text of the specified tab when selected, without Scribble formatting tags.
				/// @param				{Real}	_tab	The tab to get the selected title text from
				///	@return				{String}	The title text when selected, without Scribble formatting tags
				self.getRawTabTextSelected = function(_tab)		{ return UI_TEXT_RENDERER(self.__tab_data[_tab].text_selected).get_text(); }
			
				/// @method				getTabTextSelected(_tab)
				/// @description		Gets the title text of the specified tab when selected
				/// @param				{Real}	_tab	The tab to get the selected title text from
				///	@return				{String}	The title text when selected
				self.getTabTextSelected = function(_tab)			{ return self.__tab_data[_tab].text_selected; }
				
				/// @method				setTabTextSelected(_tab, _text)
				/// @description		Sets the title text of the specified tab when selected
				/// @param				{Real}		_tab	The tab to set selected title text from
				/// @param				{String}	_text	The title text to set when selected
				///	@return				{UIPanel}	self
				self.setTabTextSelected = function(_tab, _text)	{
					self.__tab_data[_tab].text_selected = _text; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setTextClick(_text);
					return self; 
				}
				
				/// @method				getTabSprite(_tab)
				/// @description		Gets the sprite ID of the specified tab
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab
				self.getTabSprite = function(_tab)				{ return self.__tab_data[_tab].sprite_tab; }
			
				/// @method				setTabSprite(_tab, _sprite)
				/// @description		Sets the sprite to be rendered for this tab
				/// @param				{Real}				_tab		The tab to set the sprite to
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIPanel}	self
				self.setTabSprite = function(_tab, _sprite)	{
					self.__tab_data[_tab].sprite_tab = _sprite; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setSprite(_sprite);
					self.__redimensionTabs();
					return self;
				}
				
				/// @method				setTabSprites(_sprite)
				/// @description		Sets the sprite to be rendered for all tabs
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIPanel}	self
				self.setTabSprites = function(_sprite)	{
					var _b = self.__tab_group_control.getChildren();
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) {
						self.__tab_data[_i].sprite_tab = _sprite;						
						_b[_i].setSprite(_sprite);
					}
					self.__redimensionTabs();
					return self;
				}
			
				/// @method				getTabImage(_tab)
				/// @description		Gets the image index of the specified tab
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Real}		The image index of the specified tab
				self.getTabImage = function(_tab)				{ return self.__tab_data[_tab].image_tab; }
			
				/// @method				setTabImage(_tab, _index)
				/// @description		Sets the image index of the sprite to be rendered for this tab
				/// @param				{Real}				_tab		The tab to set the image index to
				/// @param				{Real}				_index		The image index
				/// @return				{UIPanel}	self
				self.setTabImage = function(_tab, _index)		{ 
					self.__tab_data[_tab].image_tab = _index; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setImage(_index);
					return self;
				}
				
				/// @method				setTabImages(_tab, _index)
				/// @description		Sets the image index of the sprite to be rendered for all tabs
				/// @param				{Real}				_index		The image index
				/// @return				{UIPanel}	self
				self.setTabImages = function(_index)		{ 
					var _b = self.__tab_group_control.getChildren();
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) {
						self.__tab_data[_i].image_tab = _index; 
						_b[_i].setImage(_index);
					}
					return self;
				}
				
				/// @method				getTabSpriteMouseover(_tab)
				/// @description		Gets the sprite ID of the specified tab when mouseovered
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab when mouseovered
				self.getTabSpriteMouseover = function(_tab)	{ return self.__tab_data[_tab].sprite_tab_mouseover; }
			
				/// @method				setTabSpriteMouseover(_tab, _sprite)
				/// @description		Sets the sprite to be rendered for this tab when mouseovered
				/// @param				{Real}				_tab		The tab to set the sprite to
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIPanel}	self
				self.setTabSpriteMouseover = function(_tab, _sprite) {
					self.__tab_data[_tab].sprite_tab_mouseover = _sprite;
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setSpriteMouseover(_sprite);
					self.__redimensionTabs();
					return self;
				}
				
				/// @method				setTabSpritesMouseover(_sprite)
				/// @description		Sets the sprite to be rendered for all tabs when mouseovered
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIPanel}	self
				self.setTabSpritesMouseover = function(_sprite) {
					var _b = self.__tab_group_control.getChildren();
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) {
						self.__tab_data[_i].sprite_tab_mouseover = _sprite;
						_b[_i].setSpriteMouseover(_sprite);
					}					
					self.__redimensionTabs();
					return self;
				}
			
				/// @method				getTabImageMouseover(_tab)
				/// @description		Gets the image index of the specified tab when mouseovered
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Real}		The image index of the specified tab when mouseovered
				self.getTabImageMouseover = function(_tab)			{ return self.__tab_data[_tab].image_tab_mouseover; }
			
				/// @method				setTabImageMouseover(_tab, _index)
				/// @description		Sets the image index of the sprite to be rendered for this tab when mouseovered
				/// @param				{Real}				_tab		The tab to set the image index to
				/// @param				{Real}				_index		The image index
				/// @return				{UIPanel}	self
				self.setTabImageMouseover = function(_tab, _index)	{
					self.__tab_data[_tab].image_tab_mouseover = _index; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setImageMouseover(_index);
					return self;
				}
				
				/// @method				setTabImagesMouseover(_index)
				/// @description		Sets the image index of the sprite to be rendered for all tabs when mouseovered
				/// @param				{Real}				_index		The image index
				/// @return				{UIPanel}	self
				self.setTabImagesMouseover = function(_index)	{
					var _b = self.__tab_group_control.getChildren();
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) {
						self.__tab_data[_i].image_tab_mouseover = _index; 
						_b[_i].setImageMouseover(_index);					
					}	
					return self;
				}
				
				/// @method				getTabSpriteSelected(_tab)
				/// @description		Gets the sprite ID of the specified tab when selected
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab when selected
				self.getTabSpriteSelected = function(_tab)			{ return self.__tab_data[_tab].sprite_tab_selected; }
			
				/// @method				setTabSpriteSelected(_tab, _sprite)
				/// @description		Sets the sprite to be rendered for this tab when selected
				/// @param				{Real}				_tab		The tab to set the sprite to
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIPanel}	self
				self.setTabSpriteSelected = function(_tab, _sprite)	{
					self.__tab_data[_tab].sprite_tab_selected = _sprite; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setSpriteClick(_sprite);
					self.__redimensionTabs();
					return self;
				}
				
				/// @method				setTabSpritesSelected(_tab, _sprite)
				/// @description		Sets the sprite to be rendered for all tabs when selected
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIPanel}	self
				self.setTabSpritesSelected = function(_sprite)	{
					var _b = self.__tab_group_control.getChildren();
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) {
						self.__tab_data[_i].sprite_tab_selected = _sprite; 
						_b[_i].setSpriteClick(_sprite);
					}	
					self.__redimensionTabs();
					return self;
				}
			
				/// @method				getTabImageSelected(_tab)
				/// @description		Gets the image index of the specified tab when selected
				/// @param				{Real}		_tab	The tab to get the sprite from
				/// @return				{Real}		The image index of the specified tab when selected
				self.getTabImageSelected = function(_tab)			{ return self.__tab_data[_tab].image_tab_selected; }
			
				/// @method				setTabImageSelected(_tab, _index)
				/// @description		Sets the image index of the sprite to be rendered for this tab when selected
				/// @param				{Real}				_tab		The tab to set the image index to
				/// @param				{Real}				_index		The image index
				/// @return				{UIPanel}	self
				self.setTabImageSelected = function(_tab, _index) {
					self.__tab_data[_tab].image_tab_selected = _index; 
					var _b = self.__tab_group_control.getChildren();
					_b[_tab].setImageClick(_index);
					return self;
				}
				
				/// @method				setTabImagesSelected(_index)
				/// @description		Sets the image index of the sprite to be rendered for all tabs when selected
				/// @param				{Real}				_index		The image index
				/// @return				{UIPanel}	self
				self.setTabImagesSelected = function(_index) {
					var _b = self.__tab_group_control.getChildren();
					var _n = self.getTabCount();
					for (var _i=0; _i<_n; _i++) {
						self.__tab_data[_i].image_tab_selected = _index; 
						_b[_i].setImageClick(_index);
					}	
					return self;
				}
				
				/// @method				getSpriteTabBackground()
				/// @description		Gets the sprite ID of the tab header background
				/// @return				{Asset.GMSprite}	The sprite ID of the specified tab header background
				self.getSpriteTabBackground = function()			{ return self.__tab_group_control.getSprite(); }
			
				/// @method				setSpriteTabBackground(_sprite)
				/// @description		Sets the sprite to be rendered for the tab header background
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIPanel}	self
				self.setSpriteTabBackground = function(_sprite)	{ 
					self.__tab_group_control.setSprite(_sprite);
					self.__redimensionTabs();
					return self; 
				}
			
				/// @method				getImageTabBackground()
				/// @description		Gets the image index of the tab header background
				/// @return				{Real}		The image index of the tab header background
				self.getImageTabBackground = function()			{ return self.__tab_group_control.getImage(); }
			
				/// @method				setImageTabBackground(_index)
				/// @description		Sets the image index of the sprite to be rendered for the tab header background
				/// @param				{Real}				_index		The image index
				/// @return				{UIPanel}	self
				self.setImageTabBackground = function(_index) { 
					self.__tab_group_control.setImage(_index);
					return self; 
				}	
								
				/// @method				getVerticalTabs()
				/// @description		Gets whether the tabs are being rendered vertically
				/// @return				{Bool}		whether the tabs are being rendered vertically
				self.getVerticalTabs = function()			{ return self.__tab_group.__vertical; }
			
				/// @method				setVerticalTabs(_vertical)
				/// @description		Sets whether the tabs are being rendered vertically
				/// @param				{Bool}				_vertical	whether to render tabs vertically
				/// @return				{UIPanel}	self
				self.setVerticalTabs = function(_vertical)	{ 
					var _change = _vertical != self.__tab_group.__vertical;
					self.__tab_group.__vertical = _vertical;
					if (_change) self.__redimensionTabs();
					return self;
				}
				
				/// @method				getTabControl()
				/// @description		Returns the tab control for further processing
				/// @return				{UIGroup}	the tab control, a UIGroup
				self.getTabControl = function()				{ return self.__tab_group_control; }
				
				/// @method				getTabControlVisible()
				/// @description		Returns whether the tab control is visible
				/// @return				{Bool}	whether the tab control is visible
				self.getTabControlVisible = function()		{ return self.__tab_group_control.getVisible(); }
				
				/// @method				setTabControlVisible(_visible)
				/// @description		Sets whether the tab control is visible
				/// @param				{Bool}	_visible	whether the tab control is visible
				/// @return				{UIPanel}	self
				self.setTabControlVisible = function(_visible)		{ self.__tab_group_control.setVisible(_visible); return self; }
								
				/// @method				getTabControlAlignment()
				/// @description		Gets the tab group control alignment (position relative to the Panel)
				/// @return				{Enum}	The tab group control alignment, according to `UI_RELATIVE_TO`.
				self.getTabControlAlignment = function() { return self.__tab_group_control.__relative_to; }
				
				/// @method				setTabControlAlignment(_relative_to)
				/// @description		Sets the tab group control alignment (position relative to the Panel)
				/// @param				{Enum}	_relative_to	The tab group control alignment, according to `UI_RELATIVE_TO`.
				/// @return				{UIPanel}	self
				self.setTabControlAlignment = function(_relative_to) {
					var _y = (_relative_to == UI_RELATIVE_TO.TOP_LEFT) || (_relative_to == UI_RELATIVE_TO.TOP_CENTER) || (_relative_to == UI_RELATIVE_TO.TOP_RIGHT) ? self.__drag_bar_height : 0;
					self.__tab_group_control.setDimensions(, _y,,,_relative_to); 
					self.__tab_group_control.__dimensions.calculateCoordinates();
					self.__tab_group_control.__updateChildrenPositions();
					return self;
				}
				
			#endregion	
			#region Methods
				
				self.__draw = function() {
					
					// Adjust tabs on "max" behavior - specific for resize
					if (array_length(self.__tabs) > 0 && self.__tab_size_behavior == UI_TAB_SIZE_BEHAVIOR.MAX) self.__redimensionTabs();
					
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					if (sprite_exists(self.__sprite)) draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
					// Title
					if (self.__title != "")	{					
						var _s = UI_TEXT_RENDERER(self.__title_format+self.__title);
					
						var _h = _s.get_height();
						var _title_x =	self.__title_anchor == UI_RELATIVE_TO.TOP_LEFT || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_LEFT || self.__title_anchor == UI_RELATIVE_TO.BOTTOM_LEFT ? _x : 
										((self.__title_anchor == UI_RELATIVE_TO.TOP_CENTER || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_CENTER || self.__title_anchor == UI_RELATIVE_TO.BOTTOM_CENTER ? _x+_width/2 : _x+_width));
						_title_x += self.__title_offset.x;
						var _title_y =	self.__title_anchor == UI_RELATIVE_TO.TOP_LEFT || self.__title_anchor == UI_RELATIVE_TO.TOP_CENTER || self.__title_anchor == UI_RELATIVE_TO.TOP_RIGHT ? _y : 
										((self.__title_anchor == UI_RELATIVE_TO.MIDDLE_LEFT || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_CENTER || self.__title_anchor == UI_RELATIVE_TO.MIDDLE_RIGHT ? _y+self.__drag_bar_height/2 : _y+self.__drag_bar_height));
						_title_y += self.__title_offset.y;
						_s.draw(_title_x, _title_y);
					}
				}
			
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK])	UI.setFocusedPanel(self.__ID);
					__generalBuiltInBehaviors();
				}
			
				self.__drag = function() {										
					if (self.__movable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.DRAG) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_SE) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x);
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y);
						self.__updateChildrenPositions();					
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_NE) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x);
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + UI.__drag_data.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_SW) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + UI.__drag_data.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y);
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_NW) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + UI.__drag_data.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + UI.__drag_data.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_N) {
						self.__dimensions.y = UI.__drag_data.__drag_start_y + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y;
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + UI.__drag_data.__drag_mouse_delta_y - device_mouse_y_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_S) {
						self.__dimensions.height = max(self.__min_height, UI.__drag_data.__drag_start_height + device_mouse_y_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_y);
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_W) {
						self.__dimensions.x = UI.__drag_data.__drag_start_x + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x;
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + UI.__drag_data.__drag_mouse_delta_x - device_mouse_x_to_gui(UI.getMouseDevice()));
						self.__updateChildrenPositions();
					}
					else if (self.__resizable && UI.__drag_data.__drag_action == UI_RESIZE_DRAG.RESIZE_E) {
						self.__dimensions.width = max(self.__min_width, UI.__drag_data.__drag_start_width + device_mouse_x_to_gui(UI.getMouseDevice()) - UI.__drag_data.__drag_mouse_delta_x);
						self.__updateChildrenPositions();
					}
				}
			
			#endregion
			#region Methods - Tab Management
				
				self.__changeTabSizeBehavior = function() {
					var _buttons = self.__tab_group_control.getChildren(0);
					var _n = array_length(_buttons);
					var _max_size = round(self.__tab_group.__vertical ? (self.getDimensions().height - self.__drag_bar_height - 2*self.__tab_offset - (_n-1)*self.__tab_spacing) / _n : (self.getDimensions().width - 2*self.__tab_offset - (_n-1)*self.__tab_spacing) / _n);
					for (var _i=0; _i<_n; _i++) {						
						switch (self.__tab_size_behavior) {
							case UI_TAB_SIZE_BEHAVIOR.SPECIFIC:
								if (self.__tab_group.__vertical) {
									var _w = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_width(self.__tab_data[_i].sprite_tab) : 0;
									_buttons[_i].setDimensions(,,_w,self.__tab_size_specific);
								}
								else {
									var _h = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : 0;
									_buttons[_i].setDimensions(,,self.__tab_size_specific, _h);
								}
								break;
							case UI_TAB_SIZE_BEHAVIOR.MAX:
								if (self.__tab_group.__vertical) {
									var _w = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_width(self.__tab_data[_i].sprite_tab) : 0;
									_buttons[_i].setDimensions(,,_w,_max_size);
								}
								else {
									var _h = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : 0;
									_buttons[_i].setDimensions(,,_max_size, _h);
								}
								break;
							case UI_TAB_SIZE_BEHAVIOR.SPRITE:
								var _w = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_width(self.__tab_data[_i].sprite_tab) : 0;
								var _h = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : 0;
								_buttons[_i].setDimensions(,,_w,_h);
							default:
								break;
						}
					}
				}
				
				self.__redimensionTabs = function() {
					var _buttons = self.__tab_group_control.getChildren(0);
					var _x = self.__tab_group.__vertical ? 0 : self.__tab_offset;
					var _y = self.__tab_group.__vertical ? self.__tab_offset : 0;
					var _max_w = 0;
					var _max_h = 0;
										
					self.__changeTabSizeBehavior();
					
					for (var _i=0, _n=array_length(_buttons); _i<_n; _i++) {
						var _sprite_w = _buttons[_i].getDimensions().width;
						var _sprite_h = _buttons[_i].getDimensions().height;
						_max_w = max(_max_w, _sprite_w);
						_max_h = max(_max_h, _sprite_h);
						_buttons[_i].setDimensions(_x, _y);
						
						if (self.__tab_group.__vertical) {							
							_y += _sprite_h + self.__tab_spacing;
						}
						else {
							_x += _sprite_w + self.__tab_spacing;
						}
					}
					
					if (self.__tab_group.__vertical) {						
						self.__tab_group_control.setInheritWidth(false);
						self.__tab_group_control.setInheritHeight(true);
						self.__tab_group_control.setDimensions(,,_max_w, 1);												
					}
					else {
						self.__tab_group_control.setInheritWidth(true);
						self.__tab_group_control.setInheritHeight(false);
						self.__tab_group_control.setDimensions(,,1,_max_h);						
					}
					
					// Force update of format for starting tab
					self.gotoTab(self.__current_tab);
				}			
				
				/// @method					addTab([_num_tabs])
				/// @description			Adds new tabs at the end
				/// @param					{Real}	[_num_tabs]	The number of tabs to add. Note that all panels have one tab by default. If not specified, adds one tab.
				/// @return					{UIPanel}	self
				self.addTab = function(_num_tabs=1)	{ 
					repeat(_num_tabs) {
						array_push(self.__tabs, []);
						var _id_tab = new __UITab();
						array_push(self.__tab_data, _id_tab);
					
						array_push(self.__cumulative_horizontal_scroll_offset, 0);
						array_push(self.__cumulative_vertical_scroll_offset, 0);
					
						var _n = self.getTabCount() - 1;
						_id_tab.text = "Tab "+string(_n+1); 
						_id_tab.text_mouseover = "Tab "+string(_n+1); 
						_id_tab.text_selected = "Tab "+string(_n+1); 
					
						// Calculate total width/height
						var _cum_w = 0;
						var _cum_h = 0;
						for (var _i=0; _i<_n; _i++) {
							_cum_w += sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_width(self.__tab_data[_i].sprite_tab) : 0;
							_cum_h += sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : 0;
						}
					
						// Add corresponding button
					
						var _panel_id = self.__ID;
						var _sprite_tab0 = self.getTabSprite(_n);
						var _w = sprite_exists(_sprite_tab0) ? sprite_get_width(_sprite_tab0) : 0;
						var _h = sprite_exists(_sprite_tab0) ? sprite_get_height(_sprite_tab0) : 0;
						//self.setTabText(0, "Tab "+string(_n+1));
						if (self.__tab_group.__vertical) {
							var _x_button = 0;
							var _y_button = _cum_h;
						}
						else {
							var _x_button = _cum_w;
							var _y_button = 0;
						}
						var _button = self.__tab_group_control.add(new UIButton(_panel_id+"_TabControl_Group_TabButton"+string(_n), _x_button, _y_button, _w, _h, self.__tab_group.__text_format+self.getTabText(0), _sprite_tab0), -1);
						_button.setUserData("panel_id", _panel_id);
						_button.setUserData("tab_index", _n);
						_button.setSprite(self.__tab_data[_n].sprite_tab);
						_button.setImage(self.__tab_data[_n].image_tab);
						_button.setSpriteMouseover(self.__tab_data[_n].sprite_tab_mouseover);
						_button.setImageMouseover(self.__tab_data[_n].image_tab_mouseover);
						_button.setSpriteClick(self.__tab_data[_n].sprite_tab_mouseover);
						_button.setImageClick(self.__tab_data[_n].image_tab_mouseover);					
						_button.setText("Tab "+string(_n+1));
						_button.setTextMouseover("Tab "+string(_n+1));
						_button.setTextClick("Tab "+string(_n+1));
						_button.setVisible(self.__tab_group_control.getVisible());
						with (_button) {
							setCallback(UI_EVENT.LEFT_RELEASE, function() {
								var _panel = UI.get(self.getUserData("panel_id"));
								var _tab = self.getUserData("tab_index");
								_panel.gotoTab(_tab);	
								_panel.__redimensionTabs();
							});
						}
					}
					self.setTabControlVisible(self.getTabCount() > 1);
					return self;
				}
				
				/// @method					removeTab([_tab = <current_tab>)
				/// @description			Removes the specified tab. Note, if there is only one tab left, you cannot remove it.
				/// @param					{Real}	[_tab]	The tab number to remove. If not specified, removes the current tab.
				/// @return					{UIPanel}	self
				self.removeTab = function(_tab = self.__current_tab)	{
					var _n = array_length(self.__tabs);
					if (_n > 1) {
						// Remove button and reconfigure the other buttons
						
						var _total = 0;					
						var _w = -1;
						for (var _i=0; _i<_n; _i++) {
							var _widget = self.__tab_group_control.__children[_i];
							var _tab_index = _widget.getUserData("tab_index");
							if (_tab_index == _tab) {
								_w = _widget;
							}
							else if (_tab_index > _tab) {
								var _x_button = (self.__tab_group.__vertical) ? 0 : _total;
								var _y_button = (self.__tab_group.__vertical) ? _total : 0;
								_widget.setDimensions(_x_button, _y_button);
								_widget.setUserData("tab_index", _i-1);
								var _w_tab = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_width(self.__tab_data[_i].sprite_tab) : 0;
								var _h_tab = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : 0;
								_total += ((self.__tab_group.__vertical) ? _h_tab : _w_tab);
							}
							else {
								var _w_tab = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_width(self.__tab_data[_i].sprite_tab) : 0;
								var _h_tab = sprite_exists(self.__tab_data[_i].sprite_tab) ? sprite_get_height(self.__tab_data[_i].sprite_tab) : 0;
								_total += ((self.__tab_group.__vertical) ? _h_tab : _w_tab);
							}
						}
						_w.destroy();
						
						// Remove from arrays
						var _curr_tab = self.__current_tab;
						array_delete(self.__tabs, _tab, 1);
						array_delete(self.__tab_data, _tab, 1);
						
						array_delete(self.__cumulative_horizontal_scroll_offset, _tab, 1);
						array_delete(self.__cumulative_vertical_scroll_offset, _tab, 1);
												
						var _m = array_length(self.__tabs);
						//if (_curr_tab == _m)	self.__current_tab = _m-1;
						if (_curr_tab == _m) {
							self.gotoTab(_m-1);
						}
						else {
							self.gotoTab(self.__current_tab);
						}
						//self.__children = self.__tabs[self.__current_tab];
						
					}
					self.setTabControlVisible(self.getTabCount() > 1);
					return self;
				}
				
				/// @method					nextTab([_wrap = false])
				/// @description			Moves to the next tab
				/// @param					{Bool}	_wrap	If true, tab will return to the first one if called from the last tab. If false (default) and called from the last tab, it will remain in that tab.
				/// @return					{UIPanel}	self
				self.nextTab = function(_wrap = false)	{
					var _target;
					if (_wrap)	_target = (self.__current_tab + 1) % array_length(self.__tabs);
					else		_target = min(self.__current_tab + 1, array_length(self.__tabs)-1);					
					self.gotoTab(_target);
					return self;
				}
				
				/// @method					previousTab([_wrap = false])
				/// @description			Moves to the previous tab
				/// @param					{Bool}	_wrap	If true, tab will jump to the last one if called from the first tab. If false (default) and called from the first tab, it will remain in that tab.
				/// @return					{UIPanel}	self
				self.previousTab = function(_wrap = false)	{
					var _target;
					if (_wrap)	{
						_target = (self.__current_tab - 1);
						if (_target == -1)	 _target = array_length(self.__tabs)-1;
					}
					else		_target = max(_target - 1, 0);					
					self.gotoTab(_target);
					return self;
				}
				
								
				/// @method					gotoTab(_tab)
				/// @description			Moves to the specified tab
				/// @param					{Real}	_tab	The tab number.
				/// @return					{UIPanel}	self
				self.gotoTab = function(_tab)	{
					var _old = self.__current_tab;
					var _new = _tab;
					var _changed = (_old != _new);
					if (_changed) {
						self.__current_tab = _new;
						self.__tab_group_control.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);
					
						self.__children = self.__tabs[self.__current_tab];
						for (var _i=0, _n=array_length(self.__tabs); _i<_n; _i++) {
							var _button = self.__tab_group_control.__children[_i];
							if (_button.getUserData("tab_index") == _tab) {
								_button.setSprite(self.__tab_data[_i].sprite_tab_selected);
								_button.setImage(self.__tab_data[_i].image_tab_selected);
								_button.setText(self.__tab_data[_i].text_selected);
								_button.setTextFormat(self.__tab_data[_i].text_format_selected);
							}
							else {
								_button.setSprite(self.__tab_data[_i].sprite_tab);
								_button.setImage(self.__tab_data[_i].image_tab);
								_button.setText(self.__tab_data[_i].text);
								_button.setTextFormat(self.__tab_data[_i].text_format);
							}
						}
					}
					return self;
				}
				
				/// @method					getTabCount()
				/// @description			Gets the tab count for the widget. If this is a non-tabbed widget, it will return 0.
				/// @return					{Real}	The tab count for this Widget.
				self.getTabCount = function()	{
					if (self.__type == UI_TYPE.PANEL)	return array_length(self.__tabs);
					else								return 0;
				}
				
				/// @method					getTabTitle(_tab)
				/// @description			Gets the tab title of the specified tab
				/// @param					{Real}		_tab	The tab number
				/// @return					{String}	The tab title for _tab
				self.getTabTitle = function(_tab) {
					return self.getRawTabText(_tab);
				}
				
				/// @method				getCurrentTab()
				/// @description		Gets the index of the selected tab
				/// @return				{Real}	the index of the currently selected tab
				self.getCurrentTab = function()					{ return self.__current_tab; }
				
				
			#endregion
			
			// Register before tab controls so it has the final ID
			self.__register();
			
			#region Tab Control Initial Setup
			
				// Initial setup for tab 0
				var _panel_id = self.__ID;
				var _sprite_tab0 = self.getTabSprite(0);
				var _w = sprite_exists(_sprite_tab0) ? sprite_get_width(_sprite_tab0) : 0; // Start with something
				var _h = sprite_exists(_sprite_tab0) ? sprite_get_height(_sprite_tab0) : 0;
				if (self.__tab_group.__vertical) {
					self.__tab_group_control = self.add(new UIGroup(_panel_id+"_TabControl_Group", 0, self.__drag_bar_height, _w, 1, noone, UI_RELATIVE_TO.TOP_LEFT), -1);
					self.__tab_group_control.setInheritHeight(true);
				}
				else {
					self.__tab_group_control = self.add(new UIGroup(_panel_id+"_TabControl_Group", 0, self.__drag_bar_height, 1, _h, noone, UI_RELATIVE_TO.TOP_LEFT), -1);
					self.__tab_group_control.setInheritWidth(true);
				}
				self.__tab_group_control.setVisible(false);
				self.__tab_group_control.setClipsContent(true);
				var _button = self.__tab_group_control.add(new UIButton(_panel_id+"_TabControl_Group_TabButton0", 0, 0, _w, _h, self.__tab_group.__text_format+self.getTabText(0), _sprite_tab0), -1);
				_button.setUserData("panel_id", _panel_id);
				_button.setUserData("tab_index", 0);
				_button.setSprite(self.__tab_data[0].sprite_tab_selected);
				_button.setImage(self.__tab_data[0].image_tab_selected);
				_button.setSpriteMouseover(self.__tab_data[0].sprite_tab_mouseover);
				_button.setImageMouseover(self.__tab_data[0].image_tab_mouseover);
				_button.setSpriteClick(self.__tab_data[0].sprite_tab_mouseover);
				_button.setImageClick(self.__tab_data[0].image_tab_mouseover);
				_button.setText("Tab 1");
				_button.setTextMouseover("Tab 1");
				_button.setTextClick("Tab 1");
				_button.setVisible(self.__tab_group_control.getVisible());
				with (_button) {
					setCallback(UI_EVENT.LEFT_RELEASE, function() {	
						var _panel = UI.get(self.getUserData("panel_id"));
						var _tab = self.getUserData("tab_index");
						_panel.gotoTab(_tab);
						_panel.__redimensionTabs();
					});
				}
				var _id_tab = self.__tab_data[0];
				_id_tab.text = "Tab 1"; 
				_id_tab.text_mouseover = "Tab 1"; 
				_id_tab.text_selected = "Tab 1"; 			
				
				
			#endregion
			
			self.setClipsContent(true);
			
			return self;
		}
	
	#endregion
	
	#region UIButton
	
		/// @constructor	UIButton(_id, _x, _y, _width, _height, _text, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Button widget, clickable UI widget that performs an action
		/// @param			{String}			_id				The Button's name, a unique string ID. If the specified name is taken, the Button will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Button, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Button, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the Button
		/// @param			{Real}				_height			The height of the Button
		/// @param			{String}			_text			The text to display for the Button
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Button
		/// @param			{Enum}				[_relative_to]	The position relative to which the Button will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIButton}							self
		function UIButton(_id, _x, _y, _width, _height, _text, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.BUTTON;
				self.__text = _text;
				self.__text_mouseover = _text;
				self.__text_click = _text;
				self.__text_disabled = _text;
				self.__sprite_mouseover = _sprite;
				self.__sprite_click = _sprite;
				self.__sprite_disabled = _sprite;
				self.__image_mouseover = 0;
				self.__image_click = 0;			
				self.__image_disabled = 0;
				self.__text_format = "";
				self.__text_format_mouseover = "";
				self.__text_format_click = "";
				self.__text_format_disabled = "";
				self.__text_relative_to = UI_RELATIVE_TO.MIDDLE_CENTER;
				self.__text_offset = {x: 0, y:0};
			#endregion
			#region Setters/Getters
			
				// Note: set/get sprite, set/get image inherited from UIWidget.
			
				/// @method				getRawText()
				/// @description		Gets the text of the button, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawText = function()						{ return UI_TEXT_RENDERER(self.__text).get_text(); }
			
				/// @method				getText()
				/// @description		Gets the Scribble text string of the button, either via the defined binding or, if undefined, the defined text.
				///	@return				{String}	The Scribble text string of the button.
				self.getText = function()	{
					var _text = self.__updateBinding();
					if (is_undefined(_text))	return self.__text;
					else if (is_method(_text))	return _text();
					else return _text;
				}
			
				/// @method				setText(_text)
				/// @description		Sets the Scribble text string of the button.
				/// @param				{String}	_text	The Scribble string to assign to the button.			
				/// @return				{UIButton}	self
				self.setText = function(_text)						{ self.__text = _text; return self; }
						
				/// @method				getRawTextMouseover()
				/// @description		Gets the text of the button when mouseovered, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextMouseover = function()				{ return UI_TEXT_RENDERER(self.__text_mouseover).get_text(); }	
			
				/// @method				getTextMouseover()
				/// @description		Gets the Scribble text string of the button when mouseovered.
				///	@return				{String}	The Scribble text string of the button when mouseovered.
				self.getTextMouseover = function()					{ return self.__text_mouseover; }
			
				/// @method				setTextMouseover(_text)
				/// @description		Sets the Scribble text string of the button when mouseovered.
				/// @param				{String}	_text	The Scribble string to assign to the button when mouseovered.
				/// @return				{UIButton}	self
				self.setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; return self; }
			
				/// @method				getRawTextClick()
				/// @description		Gets the text of the button when clicked, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextClick = function()					{ return UI_TEXT_RENDERER(self.__text_click).get_text(); }
			
				/// @method				getTextClick()
				/// @description		Gets the Scribble text string of the button when clicked.
				///	@return				{String}	The Scribble text string of the button when clicked.
				self.getTextClick = function()						{ return self.__text_click; }
			
				/// @method				setTextClick(_text)
				/// @description		Sets the Scribble text string of the button when clicked.
				/// @param				{String}	_text	The Scribble string to assign to the button when clicked.
				/// @return				{UIButton}	self
				self.setTextClick = function(_text_click)			{ self.__text_click = _text_click; return self; }
				
				/// @method				getRawTextDisabled()
				/// @description		Gets the text of the button when disabled, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextDisabled = function()					{ return UI_TEXT_RENDERER(self.__text_disabled).get_text(); }
			
				/// @method				getTextDisabled()
				/// @description		Gets the Scribble text string of the button when disabled.
				///	@return				{String}	The Scribble text string of the button when disabled.
				self.getTextDisabled = function()						{ return self.__text_disabled; }
			
				/// @method				setTextDisabled(_text)
				/// @description		Sets the Scribble text string of the button when disabled.
				/// @param				{String}	_text	The Scribble string to assign to the button when disabled.
				/// @return				{UIButton}	self
				self.setTextDisabled = function(_text_disabled)			{ self.__text_disabled = _text_disabled; return self; }
				
				
				/// @method				getTextFormat()
				/// @description		Gets the general Scribble string format (tags) of the button on its normal state
				///	@return				{String}	The Scribble text string format
				self.getTextFormat = function()					{ return self.__text_format; }
			
				/// @method				setTextFormat(_text_format)
				/// @description		Sets the general Scribble string format (tags) of the button on its normal state
				/// @param				{String}	_text_format	The Scribble tag format to render the button 
				/// @return				{UIButton}	self
				self.setTextFormat = function(_text_format)	{ self.__text_format = _text_format; return self; }
				
				/// @method				getTextFormatMouseover()
				/// @description		Gets the general Scribble string format (tags) of the button on its mouseovered state
				///	@return				{String}	The Scribble text string format
				self.getTextFormatMouseover = function()					{ return self.__text_format_mouseover; }
			
				/// @method				setTextFormatMouseover(_text_format)
				/// @description		Sets the general Scribble string format (tags) of the button on its mouseovered state
				/// @param				{String}	_text_format	The Scribble tag format to render the button when mouseovered
				/// @return				{UIButton}	self
				self.setTextFormatMouseover = function(_text_format)	{ self.__text_format_mouseover = _text_format; return self; }
				
				/// @method				getTextFormatClick()
				/// @description		Gets the general Scribble string format (tags) of the button on its clicked state
				///	@return				{String}	The Scribble text string format
				self.getTextFormatClick = function()					{ return self.__text_format_click; }
			
				/// @method				setTextFormatClick(_text_format)
				/// @description		Sets the general Scribble string format (tags) of the button on its clicked state
				/// @param				{String}	_text_format	The Scribble tag format to render the button when clicked
				/// @return				{UIButton}	self
				self.setTextFormatClick = function(_text_format)	{ self.__text_format_click = _text_format; return self; }
				
				/// @method				getTextFormatDisabled()
				/// @description		Gets the general Scribble string format (tags) of the button on its disabled state
				///	@return				{String}	The Scribble text string format
				self.getTextFormatDisabled = function()					{ return self.__text_format_disabled; }
			
				/// @method				setTextFormatDisabled(_text_format)
				/// @description		Sets the general Scribble string format (tags) of the button on its disabled state
				/// @param				{String}	_text_format	The Scribble tag format to render the button when disabled
				/// @return				{UIButton}	self
				self.setTextFormatDisabled = function(_text_format)	{ self.__text_format_disabled = _text_format; return self; }
				
				/// @method				getSpriteMouseover()
				/// @description		Gets the sprite ID of the button when mouseovered			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when mouseovered
				self.getSpriteMouseover = function()				{ return self.__sprite_mouseover; }
			
				/// @method				setSpriteMouseover(_sprite)
				/// @description		Sets the sprite to be rendered when mouseovered.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIButton}	self
				self.setSpriteMouseover = function(_sprite)			{ self.__sprite_mouseover = _sprite; return self; }
			
				/// @method				getSpriteClick()
				/// @description		Gets the sprite ID of the button when clicked.			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when clicked
				self.getSpriteClick = function()					{ return self.__sprite_click; }
						
				/// @method				setSpriteClick(_sprite)
				/// @description		Sets the sprite to be rendered when clicked.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIButton}	self
				self.setSpriteClick = function(_sprite)				{ self.__sprite_click = _sprite; return self; }
								
				/// @method				getSpriteDisabled()
				/// @description		Gets the sprite ID of the button when disabled.			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when disabled
				self.getSpriteDisabled = function()					{ return self.__sprite_disabled; }
						
				/// @method				setSpriteDisabled(_sprite)
				/// @description		Sets the sprite to be rendered when disabled.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIButton}	self
				self.setSpriteDisabled = function(_sprite)				{ self.__sprite_disabled = _sprite; return self; }

				/// @method				getImageMouseover()
				/// @description		Gets the image index of the button when mouseovered.		
				/// @return				{Real}	The image index of the button when mouseovered
				self.getImageMouseover = function()					{ return self.__image_mouseover; }
			
				/// @method				setImageMouseover(_image)
				/// @description		Sets the image index of the button when mouseovered
				/// @param				{Real}	_image	The image index
				/// @return				{UIButton}	self
				self.setImageMouseover = function(_image)			{ self.__image_mouseover = _image; return self; }
			
				/// @method				getImageClick()
				/// @description		Gets the image index of the button when clicked.
				/// @return				{Real}	The image index of the button when clicked
				self.getImageClick = function()						{ return self.__image_click; }
			
				/// @method				setImageClick(_image)
				/// @description		Sets the image index of the button when clicked.
				/// @param				{Real}	_image	The image index
				/// @return				{UIButton}	self
				self.setImageClick = function(_image)				{ self.__image_click = _image; return self; }
				
				/// @method				getImageDisabled()
				/// @description		Gets the image index of the button when disabled.
				/// @return				{Real}	The image index of the button when disabled
				self.getImageDisabled = function()						{ return self.__image_disabled; }
			
				/// @method				setImageDisabled(_image)
				/// @description		Sets the image index of the button when disabled.
				/// @param				{Real}	_image	The image index
				/// @return				{UIButton}	self
				self.setImageDisabled = function(_image)				{ self.__image_disabled = _image; return self; }
				
				/// @method				getTextRelativeTo()
				/// @description		Gets the positioning of the button text relative to the button, according to UI_RELATIVE_TO
				/// @return				{Enum}	The relative positioning of the text within the button
				self.getTextRelativeTo = function()						{ return self.__text_relative_to; }
			
				/// @method				setTextRelativeTo(_relative_to)
				/// @description		Sets the positioning of the button text relative to the button, according to UI_RELATIVE_TO
				/// @param				{Enum}	_relative_to	The relative positioning of the text within the button
				/// @return				{UIButton}	self
				self.setTextRelativeTo = function(_relative_to)			{ self.__text_relative_to = _relative_to; return self; }
				
				/// @method				getTextOffset()
				/// @description		Gets the text x-y offset for the button, starting from the anchor point
				/// @return				{Struct}	A struct with x and y position
				self.getTextOffset = function()						{ return self.__text_offset; }
			
				/// @method				setTextOffset(_offset)
				/// @description		Sets the text x-y offset for the button, starting from the anchor point
				/// @param				{Struct}	_offset		A struct with x and y position
				/// @return				{UIButton}	self
				self.setTextOffset = function(_offset)			{ self.__text_offset = _offset; return self; }
				
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					
					var _bound = !is_undefined(self.__binding);
										
					if (self.__enabled) {
						var _sprite = self.__sprite;
						var _image = self.__image;
						var _text = self.getText();
						var _fmt = self.getTextFormat();
						if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
							_sprite =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__sprite_click : self.__sprite_mouseover;
							_image =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__image_click : self.__image_mouseover;
							_text =		self.__events_fired[UI_EVENT.LEFT_HOLD] ? (_bound ? self.getText() : self.__text_click) : (_bound ? self.getText() : self.__text_mouseover);
							_fmt =		self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.getTextFormatClick() : self.getTextFormatMouseover();											
						}
					}
					else {
						var _sprite = self.__sprite_disabled;
						var _image = self.__image_disabled;
						var _text = (_bound ? self.getText() : self.__text_disabled);
						var _fmt = self.getTextFormatDisabled();
					}
					if (sprite_exists(_sprite)) draw_sprite_stretched_ext(_sprite, _image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
					
					if (self.__text_relative_to == UI_RELATIVE_TO.TOP_CENTER || self.__text_relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.__text_relative_to == UI_RELATIVE_TO.BOTTOM_CENTER)	_x += self.__dimensions.width / 2;
					if (self.__text_relative_to == UI_RELATIVE_TO.TOP_RIGHT || self.__text_relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT || self.__text_relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT)		_x += self.__dimensions.width;
					if (self.__text_relative_to == UI_RELATIVE_TO.MIDDLE_LEFT || self.__text_relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.__text_relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT)	_y += self.__dimensions.height / 2;
					if (self.__text_relative_to == UI_RELATIVE_TO.BOTTOM_LEFT || self.__text_relative_to == UI_RELATIVE_TO.BOTTOM_CENTER || self.__text_relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT)	_y += self.__dimensions.height;
					
					_x += self.__text_offset.x;
					_y += self.__text_offset.y;
					
					var _scale = "[scale,"+string(UI.getScale())+"]";
					UI_TEXT_RENDERER(_scale+_fmt+string(_text)).draw(_x, _y);
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					_arr[UI_EVENT.LEFT_CLICK] = false;
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	
	#endregion
	
	#region UIGroup
	
		/// @constructor	UIGroup(_id, _x, _y, _width, _height, _sprite, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Group widget, packs several widgets on a single, related group
		/// @param			{String}			_id				The Group's name, a unique string ID. If the specified name is taken, the Group will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Group, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Group, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the Group
		/// @param			{Real}				_height			The height of the Group
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Group
		/// @param			{Enum}				[_relative_to]	The position relative to which the Group will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIGroup}							self
		function UIGroup(_id, _x, _y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.GROUP;
				self.__debug_draw = false;
			#endregion
			#region Setters/Getters
			
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					if (sprite_exists(self.__sprite)) draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);				
					if (self.__debug_draw) draw_rectangle_color(_x, _y, _x+_width, _y+_height, c_gray, c_gray, c_gray, c_gray, true);
				}
				/*self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();				
				}*/
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion
	
	#region UIText
	
		/// @constructor	UIText(_id, _x, _y, _text, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Text widget, which renders a Scribble text to the screen
		/// @param			{String}			_id				The Text's name, a unique string ID. If the specified name is taken, the Text will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Text, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Text, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{String}			_text			The text to display for the Button
		/// @param			{Enum}				[_relative_to]	The position relative to which the Text will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIText}							self
		function UIText(_id, _x, _y, _text, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, -1, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.TEXT;
				self.__text = _text;
				self.__text_mouseover = _text;
				self.__text_click = _text;
				self.__border_color = -1;
				self.__background_color = -1;
				self.__max_width = 0;
				self.__typist = undefined;
				self.__background_alpha = 1;
			#endregion
			#region Setters/Getters
				/// @method				getRawText()
				/// @description		Gets the text of the UIText, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawText = function()						{ return UI_TEXT_RENDERER(self.__text).get_text(); }
			
				/// @method				getText()
				/// @description		Gets the Scribble text string of the UIText, either via the defined binding or, if undefined, the defined text.
				///	@return				{String}	The Scribble text string of the button.
				self.getText = function() {
					var _text = self.__updateBinding();
					if (is_undefined(_text))	return self.__text;
					else if (is_method(_text))	return _text();
					else return _text;
				}
			
				/// @method				setText(_text)
				/// @description		Sets the Scribble text string of the UIText.
				/// @param				{String}	_text	The Scribble string to assign to the UIText.			
				/// @return				{UIText}	self
				self.setText = function(_text)						{ self.__text = _text; return self; }
						
				/// @method				getRawTextMouseover()
				/// @description		Gets the text of the UIText when mouseovered, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextMouseover = function()				{ return UI_TEXT_RENDERER(self.__text_mouseover).get_text(); }	
			
				/// @method				getTextMouseover()
				/// @description		Gets the Scribble text string of the UIText when mouseovered.
				///	@return				{String}	The Scribble text string of the UIText when mouseovered.
				self.getTextMouseover = function()					{ return self.__text_mouseover; }
			
				/// @method				setTextMouseover(_text)
				/// @description		Sets the Scribble text string of the UIText when mouseovered.
				/// @param				{String}	_text	The Scribble string to assign to the UIText when mouseovered.
				/// @return				{UIText}	self
				self.setTextMouseover = function(_text_mouseover)	{ self.__text_mouseover = _text_mouseover; return self; }
			
				/// @method				getRawTextClick()
				/// @description		Gets the text of the UIText when clicked, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextClick = function()					{ return UI_TEXT_RENDERER(self.__text_click).get_text(); }
			
				/// @method				getTextClick()
				/// @description		Gets the Scribble text string of the UIText when clicked.
				///	@return				{String}	The Scribble text string of the UIText when clicked.
				self.getTextClick = function()						{ return self.__text_click; }
			
				/// @method				setTextClick(_text)
				/// @description		Sets the Scribble text string of the UIText when clicked.
				/// @param				{String}	_text	The Scribble string to assign to the UIText when clicked.
				/// @return				{UIText}	self
				self.setTextClick = function(_text_click)			{ self.__text_click = _text_click; return self; }
			
				/// @method				getBorderColor()
				/// @description		Gets the border color of the text, or -1 if invisible
				///	@return				{Constant.Colour}	The border color or -1
				self.getBorderColor = function()					{ return self.__border_color; }
			
				/// @method				setBorderColor(_color)
				/// @description		Sets the border color of the text to a color, or unsets it if it's -1
				/// @param				{Constant.Color}	_color	The color constant, or -1
				/// @return				{UIText}	self
				self.setBorderColor = function(_color)			{ self.__border_color = _color; return self; }
			
				/// @method				getBackgroundColor()
				/// @description		Gets the background color of the text, or -1 if invisible
				///	@return				{Constant.Colour}	The background color or -1
				self.getBackgroundColor = function()				{ return self.__background_color; }
			
				/// @method				setBackgroundColor(_color)
				/// @description		Sets the background color of the text to a color, or unsets it if it's -1
				/// @param				{Constant.Color}	_color	The color constant, or -1
				/// @return				{UIText}	self
				self.setBackgroundColor = function(_color)			{ self.__background_color = _color; return self; }
				
				/// @method				getBackgroundAlpha()
				/// @description		Gets the background alpha of the text background
				///	@return				{Real}	The background alpha
				self.getBackgroundAlpha = function()				{ return self.__background_alpha; }
			
				/// @method				setBackgroundAlpha(_alpha)
				/// @description		Sets the background alpha of the text background
				/// @param				{Real}	_alpha	The alpha value
				/// @return				{UIText}	self
				self.setBackgroundAlpha = function(_alpha)			{ self.__background_alpha = _alpha; return self; }
			
				/// @method				getTypist()
				/// @description		Gets the text renderer typist
				///	@return				{Any}	The typist
				self.getTypist = function()				{ return self.__background_color; }
			
				/// @method				setTypist(_typist)
				/// @description		Sets the text renderer typist
				/// @param				{Any}	_typist	The typist to set
				/// @return				{UIText}	self
				self.setTypist = function(_typist)			{ self.__typist = _typist; return self; }
			
				
				/// @method				getMaxWidth()
				/// @description		Gets the max width of the text element. If greater than zero, text will wrap to the next line when it reaches the maximum width.
				///	@return				{Real}	The max width, or 0 if unlimited
				self.getMaxWidth = function()				{ return self.__max_width; }
			
				/// @method				setMaxWidth(_max_width)
				/// @description		Sets the max width of the text element. If greater than zero, text will wrap to the next line when it reaches the maximum width.
				/// @param				{Real}	_max_width	The max width, or 0 if unlimited
				/// @return				{UIText}	self
				self.setMaxWidth = function(_max_width)			{ self.__max_width = _max_width; return self; }
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;					
										
					var _text = self.getText();
					var _scale = "[scale,"+string(UI.getScale())+"]";
										
					if (self.__events_fired[UI_EVENT.MOUSE_OVER])	{					
						_text =	self.__events_fired[UI_EVENT.LEFT_HOLD] ? self.__text_click : self.__text_mouseover;
					}
				
					var _s = UI_TEXT_RENDERER(_scale+string(_text));					
					if (self.__max_width > 0)	_s.wrap(self.__max_width);
					
					//self.setDimensions(self.getDimensions().offset_x+_s.get_width(),self.getDimensions().offset_y+_s.get_height(),_s.get_width(), _s.get_height());
					
					var _x1 = _s.get_left(_x);
					var _x2 = _s.get_right(_x);
					var _y1 = _s.get_top(_y);
					var _y2 = _s.get_bottom(_y);
					var _alpha = draw_get_alpha();
					draw_set_alpha(self.__background_alpha);
					if (self.__background_color != -1)	draw_rectangle_color(_x1, _y1, _x2, _y2, self.__background_color, self.__background_color, self.__background_color, self.__background_color, false);
					draw_set_alpha(_alpha);
					if (self.__border_color != -1)		draw_rectangle_color(_x1, _y1, _x2, _y2, self.__border_color, self.__border_color, self.__border_color, self.__border_color, true);
					_s.draw(_x, _y, self.__typist);
					//draw_circle_color(_x, _y, 2, c_red, c_red, false);					
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					_arr[UI_EVENT.LEFT_CLICK] = false;
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion
	
	#region UICheckbox
	
		/// @constructor	UICheckbox(_id, _x, _y, _text, _sprite, [_value=false], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Checkbox widget, clickable UI widget that stores a true/false state
		/// @param			{String}			_id				The Checkbox's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Checkbox, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Checkbox, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{String}			_text			The text to display for the Checkbox
		/// @param			{Asset.GMSprite}	_sprite_true	The sprite ID to use for rendering the Checkbox when true
		/// @param			{Asset.GMSprite}	_sprite_false	The sprite ID to use for rendering the Checkbox when false
		/// @param			{Bool}				[_value]		The initial value of the Checkbox (default=false)
		/// @param			{Enum}				[_relative_to]	The position relative to which the Checkbox will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UICheckbox}						self
		function UICheckbox(_id, _x, _y, _text, _sprite_true, _sprite_false, _value=false, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite_true, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.CHECKBOX;
				self.__text_false = _text;
				self.__text_true = _text;
				self.__text_offset = {x: 0, y: 0};
				self.__text_format_true = "[fa_left]";
				self.__text_format_false = "[fa_left]";
				self.__text_format_mouseover_false = "[fa_left]";
				self.__text_format_mouseover_true = "[fa_left]";
				self.__sprite_base = -1;
				self.__sprite_false = _sprite_false;
				self.__sprite_true = _sprite_true;
				self.__sprite_mouseover_false = _sprite_false;			
				self.__sprite_mouseover_true = _sprite_true;
				self.__image_base = 0;
				self.__image_false = 0;
				self.__image_true = 0;
				self.__image_mouseover_false = 0;
				self.__image_mouseover_true = 0;
				self.__inner_sprite_offset = {x: 0, y: 0};
				self.__value = _value;
			#endregion
			#region Setters/Getters			
				/// @method				getRawTextTrue()
				/// @description		Gets the text of the checkbox on the true state, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextTrue = function()					{ return UI_TEXT_RENDERER(self.__text_true).get_text(); }
			
				/// @method				getTextTrue()
				/// @description		Gets the Scribble text string of the checkbox on the true state.
				///	@return				{String}	The Scribble text string.
				self.getTextTrue = function()						{ return self.__text_true; }
			
				/// @method				setTextTrue(_text)
				/// @description		Sets the Scribble text string of the checkbox on the true state.
				/// @param				{String}	_text	The Scribble string to assign to the checbox for the true state.			
				/// @return				{UICheckbox}	self
				self.setTextTrue = function(_text)					{ self.__text_true = _text; return self; }
				
				/// @method				getRawTextFalse()
				/// @description		Gets the text of the checkbox on the false state, without Scribble formatting tags.
				///	@return				{String}	The text, without Scribble formatting tags.			
				self.getRawTextFalse = function()					{ return UI_TEXT_RENDERER(self.__text_false).get_text(); }
			
				/// @method				getTextFalse()
				/// @description		Gets the Scribble text string of the checkbox on the false state.
				///	@return				{String}	The Scribble text string.
				self.getTextFalse = function()						{ return self.__text_false; }
			
				/// @method				setTextFalse(_text)
				/// @description		Sets the Scribble text string of the checkbox on the false state.
				/// @param				{String}	_text	The Scribble string to assign to the checbox for the false state.			
				/// @return				{UICheckbox}	self
				self.setTextFalse = function(_text)					{ self.__text_false = _text; return self; }
		
				/// @method				getSpriteTrue()
				/// @description		Gets the sprite ID of the checkbox used for the true state.
				/// @return				{Asset.GMSprite}	The sprite ID of the checkbox used for the true state.
				self.getSpriteTrue = function()				{ return self.__sprite_true; }
			
				/// @method				setSpriteTrue(_sprite)
				/// @description		Sets the sprite to be used for the true state.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteTrue = function(_sprite)			{ self.__sprite_true = _sprite; return self; }
			
				/// @method				getImageTrue()
				/// @description		Gets the image index of the checkbox used for the true state.
				/// @return				{Real}	The image index of the checkbox used for the true state.
				self.getImageTrue = function()					{ return self.__image_true; }
			
				/// @method				setImageTrue(_image)
				/// @description		Sets the image index of the checkbox used for the true state.
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageTrue = function(_image)			{ self.__image_true = _image; return self; }				
				
				/// @method				getSpriteFalse()
				/// @description		Gets the sprite ID of the checkbox used for the false state.	
				/// @return				{Asset.GMSprite}	The sprite ID of the checkbox used for the false state.	
				self.getSpriteFalse = function()				{ return self.__sprite_false; }
			
				/// @method				setSpriteFalse(_sprite)
				/// @description		Sets the sprite to be used for the false state.	
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteFalse = function(_sprite)			{ self.__sprite_false = _sprite; return self; }
				
				/// @method				getSpriteBase()
				/// @description		Gets the sprite ID of the checkbox base.	
				/// @return				{Asset.GMSprite}	The sprite ID of the checkbox base.	
				self.getSpriteBase = function()				{ return self.__sprite_base; }
			
				/// @method				setSpriteBase(_sprite)
				/// @description		Sets the sprite ID of the checkbox base.	
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UICheckbox}	self
				self.setSpriteBase = function(_sprite)			{ self.__sprite_base = _sprite; return self; }
				
				/// @method				getImageFalse()
				/// @description		Gets the image index of the checkbox used for the false state.		
				/// @return				{Real}	The image index of the checkbox  used for the false state.	
				self.getImageFalse = function()					{ return self.__image_false; }
			
				/// @method				setImageFalse(_image)
				/// @description		Sets the image index of the checkbox used for the false state.	
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageFalse = function(_image)			{ self.__image_false = _image; return self; }
				
				/// @method				getImageBase()
				/// @description		Gets the image index of the base sprite for the checkbox.
				/// @return				{Real}	The image index
				self.getImageBase = function()					{ return self.__image_true; }
			
				/// @method				setImageBase(_image)
				/// @description		Sets the image index of the base sprite for the checkbox.
				/// @param				{Real}	_image	The image index
				/// @return				{UICheckbox}	self
				self.setImageBase = function(_image)			{ self.__image_base = _image; return self; }	
				
				/// @method			getSpriteMouseoverFalse()
				/// @description	Gets the sprite for the false state when mouseovered
				/// @return	{Any}	the sprite
				self.getSpriteMouseoverFalse = function() {
					return self.__sprite_mouseover_false;
				}

				/// @method			setSpriteMouseoverFalse(_sprite)
				/// @description	Sets the sprite for the false state when mouseovered
				/// @param	{Any}	_sprite	the sprite to set
				/// @return	{Struct}	self
				self.setSpriteMouseoverFalse = function(_sprite) {
					self.__sprite_mouseover_false = _sprite;
					return self;
				}

				/// @method			getSpriteMouseoverTrue()
				/// @description	Gets the sprite for the true state when mouseovered
				/// @return	{Any}	the sprite
				self.getSpriteMouseoverTrue = function() {
					return self.__sprite_mouseover_true;
				}

				/// @method			setSpriteMouseoverTrue(_sprite)
				/// @description	Sets the sprite for the true state when mouseovered
				/// @param	{Any}	_sprite	the sprite to set
				/// @return	{Struct}	self
				self.setSpriteMouseoverTrue = function(_sprite) {
					self.__sprite_mouseover_true = _sprite;
					return self;
				}

				/// @method			getImageMouseoverFalse()
				/// @description	Gets the image for the false state when mouseovered
				/// @return	{Any}	the image index
				self.getImageMouseoverFalse = function() {
					return self.__image_mouseover_false;
				}

				/// @method			setImageMouseoverFalse(_image)
				/// @description	Sets the image for the false state when mouseovered
				/// @param	{Any}	_image	the image index to set
				/// @return	{Struct}	self
				self.setImageMouseoverFalse = function(_image) {
					self.__image_mouseover_false = _image;
					return self;
				}

				/// @method			getImageMouseoverTrue()
				/// @description	Gets the image for the true state when mouseovered
				/// @return	{Any}	the image index
				self.getImageMouseoverTrue = function() {
					return self.__image_mouseover_true;
				}

				/// @method			setImageMouseoverTrue(_image)
				/// @description	Sets the image for the true state when mouseovered
				/// @param	{Any}	_image	the image index to set
				/// @return	{Struct}	self
				self.setImageMouseoverTrue = function(_image) {
					self.__image_mouseover_true = _image;
					return self;
				}

				/// @method			getTextFormatMouseoverFalse()
				/// @description	Gets the format of the text for the false state when mouseovered
				/// @return	{Any}	the format
				self.getTextFormatMouseoverFalse = function() {
					return self.__text_format_mouseover_false;
				}

				/// @method			setTextFormatMouseoverFalse(_format)
				/// @description	Sets the format of the text for the false state when mouseovered
				/// @param	{Any}	_format	the format to set
				/// @return	{Struct}	self
				self.setTextFormatMouseoverFalse = function(_format) {
					self.__text_format_mouseover_false = _format;
					return self;
				}

				/// @method			getTextFormatMouseoverTrue()
				/// @description	Gets the format of the text for the true state when mouseovered
				/// @return	{Any}	the format
				self.getTextFormatMouseoverTrue = function() {
					return self.__text_format_mouseover_true;
				}

				/// @method			setTextFormatMouseoverTrue(_format)
				/// @description	Sets the format of the text for the true state when mouseovered
				/// @param	{Any}	_format	the format to set
				/// @return	{Struct}	self
				self.setTextFormatMouseoverTrue = function(_format) {
					self.__text_format_mouseover_true = _format;
					return self;
				}

				/// @method			getTextFormatTrue()
				/// @description	Gets the format of the text for the true state
				/// @return	{Any}	the format
				self.getTextFormatTrue = function() {
					return self.__text_format_true;
				}

				/// @method			setTextFormatTrue(_format)
				/// @description	Sets the format of the text for the true state
				/// @param	{Any}	_format	the format to set
				/// @return	{Struct}	self
				self.setTextFormatTrue = function(_format) {
					self.__text_format_true = _format;
					return self;
				}

				/// @method			getTextFormatFalse()
				/// @description	Gets the format of the text for the false state
				/// @return	{Any}	the format
				self.getTextFormatFalse = function() {
					return self.__text_format_false;
				}

				/// @method			setTextFormatFalse(_format)
				/// @description	Sets the format of the text for the false state
				/// @param	{Any}	_format	the format to set
				/// @return	{Struct}	self
				self.setTextFormatFalse = function(_format) {
					self.__text_format_false = _format;
					return self;
				}

				/// @method				getValue()
				/// @description		Gets the value of the checkbox
				/// @return				{Bool}	the value of the checkbox
				self.getValue = function()						{ return self.__value; }
				
				/// @method				setValue(_value)
				/// @description		Sets the value of the checkbox
				/// @param				{Bool}	_value	the value to set
				/// @return				{UICheckbox}	self
				self.setValue = function(_value) {
					var _old = self.__value;
					var _new = _value;
					var _changed = (_old != _new);
					if (_changed) {
						self.__value = _new;					
						self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);
					}
					return self;
				}
				
				/// @method				toggle()
				/// @description		Toggles the value of the checkbox
				/// @return				{UICheckbox}	self
				self.toggle = function() { 					
					self.__value = !self.__value;
					self.__callbacks[UI_EVENT.VALUE_CHANGED](!self.__value, self.__value);
					return self;
				}
				
				/// @method				getTextOffset()
				/// @description		Gets the text x-y offset for the checkbox, starting from the anchor point
				/// @return				{Struct}	A struct with x and y position
				self.getTextOffset = function()						{ return self.__text_offset; }
			
				/// @method				setTextOffset(_offset)
				/// @description		Sets the text x-y offset for the checkbox, starting from the anchor point
				/// @param				{Struct}	_offset		A struct with x and y position
				/// @return				{UIButton}	self
				self.setTextOffset = function(_offset)			{ self.__text_offset = _offset; return self; }
				
				/// @method				getInnerSpritesOffset()
				/// @description		Gets the x-y offset for the checkbox inner true/false sprites relative to the top-left of the base sprite
				/// @return				{Struct}	A struct with x and y position
				self.getInnerSpritesOffset = function()						{ return self.__inner_sprite_offset; }
			
				/// @method				setInnerSpritesOffset(_offset)
				/// @description		Sets the x-y offset for the checkbox inner true/false sprites relative to the top-left of the base sprite
				/// @param				{Struct}	_offset		A struct with x and y position
				/// @return				{UIButton}	self
				self.setInnerSpritesOffset = function(_offset)			{ self.__inner_sprite_offset = _offset; return self; }
								
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _w_true = sprite_exists(self.__sprite_true) ? sprite_get_width(self.__sprite_true) : 0;
					var _h_true = sprite_exists(self.__sprite_true) ? sprite_get_height(self.__sprite_true) : 0;
					var _w_false = sprite_exists(self.__sprite_false) ? sprite_get_width(self.__sprite_false) : 0;
					var _h_false = sprite_exists(self.__sprite_false) ? sprite_get_height(self.__sprite_false) : 0;
					
					var _width = (self.__value ? _w_true : _w_false) * UI.getScale();
					var _height = (self.__value ? _h_true : _h_false) * UI.getScale();
					var _width_base = sprite_exists(self.__sprite_base) ? sprite_get_width(self.__sprite_base) * UI.getScale() : 0;
					var _height_base = sprite_exists(self.__sprite_base) ? sprite_get_height(self.__sprite_base) * UI.getScale() : 0;
					
					var _sprite = self.__events_fired[UI_EVENT.MOUSE_OVER] ? (self.__value ? self.__sprite_mouseover_true : self.__sprite_mouseover_false) : (self.__value ? self.__sprite_true : self.__sprite_false);
					var _image = self.__events_fired[UI_EVENT.MOUSE_OVER] ? (self.__value ? self.__image_mouseover_true : self.__image_mouseover_false) : (self.__value ? self.__image_true : self.__image_false);
					var _text = self.__value ? self.__text_true : self.__text_false;
					var _fmt = self.__events_fired[UI_EVENT.MOUSE_OVER] ? (self.__value ? self.__text_format_mouseover_true : self.__text_format_mouseover_false) : (self.__value ? self.__text_format_true : self.__text_format_false);
					
					if (sprite_exists(self.__sprite_base)) draw_sprite_stretched_ext(self.__sprite_base, self.__image_base, _x, _y, _width_base, _height_base, self.__image_blend, self.__image_alpha); 
					if (sprite_exists(_sprite)) draw_sprite_stretched_ext(_sprite, _image, _x + self.__inner_sprite_offset.x, _y + self.__inner_sprite_offset.y, _width, _height, self.__image_blend, self.__image_alpha);
					
					var _x = _x + max(_width, _width_base);
					var _y = _y + max(_height/2, _height_base/2);
					
					var _scale = "[scale,"+string(UI.getScale())+"]";				
					var _s = UI_TEXT_RENDERER(_scale+_fmt+_text);
					
					self.setDimensions(,,max(_width, _width_base) + _s.get_width() + self.__text_offset.x, max(_height, _height_base) + _s.get_height() + self.__text_offset.y);
					_s.draw(_x + self.__text_offset.x, _y + self.__text_offset.y);
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
						self.toggle();
					}
					
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UISlider
	
		/// @constructor	UISlider(_id, _x, _y, _length, _sprite, _sprite_handle, _value, _min_value, _max_value, [_orientation=UI_ORIENTATION.HORIZONTAL], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Slider widget, that allows the user to select a value from a range by dragging, clicking or scrolling
		/// @param			{String}			_id				The Slider's name, a unique string ID. If the specified name is taken, the Slider will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Slider, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Slider, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_length			The length of the Slider in pixels (this will be applied either horizontally or vertically depending on the `_orientation` parameter)
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the Slider base
		/// @param			{Asset.GMSprite}	_sprite_handle	The sprite ID to use for rendering the Slider handle
		/// @param			{Real}				_value			The initial value of the Slider
		/// @param			{Real}				_min_value		The minimum value of the Slider
		/// @param			{Real}				_max_value		The maximum value of the Slider
		/// @param			{Enum}				[_orientation]	The orientation of the Slider, according to UI_ORIENTATION. By default: HORIZONTAL
		/// @param			{Enum}				[_relative_to]	The position relative to which the Slider will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UISlider}							self
		function UISlider(_id, _x, _y, _length, _sprite, _sprite_handle, _value, _min_value, _max_value, _orientation=UI_ORIENTATION.HORIZONTAL, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.SLIDER;
				self.__draggable = true;
				self.__length = _length;
				self.__sprite_base = _sprite;
				self.__sprite_handle = _sprite_handle;
				self.__sprite_handle_mouseover = _sprite_handle;
				self.__sprite_progress = noone;
				self.__sprite_progress_offset = {x: 0, y: 0};
				self.__image_base = 0;
				self.__image_handle = 0;
				self.__image_handle_mouseover = 0;
				self.__image_progress = 0;
				self.__value = _value;
				self.__min_value = _min_value;
				self.__max_value = _max_value;
				self.__drag_change = 1;
				self.__scroll_change = 1;
				self.__click_change = 2;
				self.__show_min_max_text = true;
				self.__show_handle_text = true;
				self.__text_format = "[fa_left][fa_middle]";
				self.__orientation = _orientation;
				self.__handle_hold = false;
				self.__handle_anchor = UI_RELATIVE_TO.TOP_LEFT;
				self.__handle_offset = {x: 0, y: 0};
				self.__handle_text_offset = {x: 0, y: 0};
				self.__click_to_set = false;
			#endregion
			#region Setters/Getters			
				
				/// @method				getLength()
				/// @description		Gets the length of the slider in pixels (this will be applied either horizontally or vertically depending on the orientation parameter)
				/// @return				{Real}	The length of the slider in pixels
				self.getLength = function()								{ return self.__length; }
			
				/// @method				setLength(_length)
				/// @description		Sets the length of the slider in pixels (this will be applied either horizontally or vertically depending on the orientation parameter)
				/// @param				{Real}	_length		The length of the slider in pixels
				/// @return				{UISlider}	self
				self.setLength = function(_length)						{ self.__length = _length; return self; }
				
				/// @method				getSpriteBase()
				/// @description		Gets the sprite ID used for the base of the slider.
				/// @return				{Asset.GMSprite}	The sprite ID used for the base of the slider.
				self.getSpriteBase = function()							{ return self.__sprite_base; }
			
				/// @method				setSpriteBase(_sprite)
				/// @description		Sets the sprite to be used for the base of the slider
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UISlider}	self
				self.setSpriteBase = function(_sprite)					{ self.__sprite_base = _sprite; return self; }
				
				/// @method				getSpriteProgress()
				/// @description		Gets the sprite ID used for the progress of the slider.
				/// @return				{Asset.GMSprite}	The sprite ID used for the progress of the slider.
				self.getSpriteProgress = function()							{ return self.__sprite_progress; }
			
				/// @method				setSpriteProgress(_sprite)
				/// @description		Sets the sprite to be used for the progress of the slider
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UISlider}	self
				self.setSpriteProgress = function(_sprite)					{ self.__sprite_progress = _sprite; return self; }
			
				/// @method				getImageBase()
				/// @description		Gets the image index of the sprite used for the base of the slider.
				/// @return				{Real}	The image index of the sprite used for the base of the slider
				self.getImageBase = function()							{ return self.__image_base; }
			
				/// @method				setImageBase(_image)
				/// @description		Sets the image index of the sprite used for the base of the slider
				/// @param				{Real}	_image	The image index
				/// @return				{UISlider}	self
				self.setImageBase = function(_image)					{ self.__image_base = _image; return self; }				
				
				/// @method				getImageProgress()
				/// @description		Gets the image index of the sprite used for the progress of the slider.
				/// @return				{Real}	The image index of the sprite used for the progress of the slider
				self.getImageProgress = function()							{ return self.__image_progress; }
			
				/// @method				setImageProgress(_image)
				/// @description		Sets the image index of the sprite used for the progress of the slider
				/// @param				{Real}	_image	The image index
				/// @return				{UISlider}	self
				self.setImageProgress = function(_image)					{ self.__image_progress = _image; return self; }	
				
				/// @method				getSpriteProgressOffset()
				/// @description		Gets the x,y offset of the sprite used for the progress of the slider, relative to the x,y of the base sprite
				/// @return				{Struct}	The x,y struct defining the offset
				self.getSpriteProgressOffset = function()							{ return self.__sprite_progress_offset; }
			
				/// @method				setSpriteProgressOffset(_offset)
				/// @description		Sets the x,y offset of the sprite used for the progress of the slider, relative to the x,y of the base sprite
				/// @param				{Struct}	_offset		The x,y struct defining the offset
				/// @return				{UISlider}	self
				self.setSpriteProgressOffset = function(_offset)					{ self.__sprite_progress_offset = _offset; return self; }	
				
				
				/// @method				getSpriteHandle()
				/// @description		Gets the sprite ID used for the handle of the slider.
				/// @return				{Asset.GMSprite}	The sprite ID used for the handle of the slider.
				self.getSpriteHandle = function()						{ return self.__sprite_handle; }
			
				/// @method				setSpriteHandle(_sprite)
				/// @description		Sets the sprite to be used for the handle of the slider
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UISlider}	self
				self.setSpriteHandle = function(_sprite)				{ self.__sprite_handle = _sprite; return self; }
				
				/// @method				getSpriteHandleMouseover()
				/// @description		Gets the sprite ID used for the handle of the slider when mouseovered
				/// @return				{Asset.GMSprite}	The sprite ID used for the handle of the slider when mouseovered
				self.getSpriteHandleMouseover = function()						{ return self.__sprite_handle_mouseover; }
			
				/// @method				setSpriteHandleMouseover(_sprite)
				/// @description		Sets the sprite to be used for the handle of the slider when mouseovered
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UISlider}	self
				self.setSpriteHandleMouseover = function(_sprite)				{ self.__sprite_handle_mouseover = _sprite; return self; }
				
				/// @method				getImageHandle()
				/// @description		Gets the image index of the sprite used for the handle of the slider.
				/// @return				{Real}	The image index of the sprite used for the handle of the slider
				self.getImageHandle = function()						{ return self.__image_handle; }
			
				/// @method				setImageHandle(_image)
				/// @description		Sets the image index of the sprite used for the handle of the slider
				/// @param				{Real}	_image	The image index
				/// @return				{UISlider}	self
				self.setImageHandle = function(_image)					{ self.__image_handle = _image; return self; }		
				
				
				/// @method				getImageHandleMouseover()
				/// @description		Gets the image index of the sprite used for the handle of the slider when mouseovered
				/// @return				{Real}	The image index of the sprite used for the handle of the slider when mouseovered
				self.getImageHandleMouseover = function()						{ return self.__image_handle_mouseover; }
			
				/// @method				setImageHandleMouseover(_image)
				/// @description		Sets the image index of the sprite used for the handle of the slider when mouseovered
				/// @param				{Real}	_image	The image index of the sprite when mouseovered
				/// @return				{UISlider}	self
				self.setImageHandleMouseover = function(_image)					{ self.__image_handle_mouseover = _image; return self; }		
				
				/// @method				getClickToSet()
				/// @description		Gets how the slider click action is managed
				/// @return				{Bool}	Return whether clicking sets the value immediately to the spot (true) or modifies its value by a set amount (false)
				self.getClickToSet = function()						{ return self.__click_to_set; }
			
				/// @method				setClickToSet(_set)
				/// @description		Sets how the slider click action is managed
				/// @param				{Bool}	_set	Whether clicking sets the value immediately to the spot (true) or modifies its value by a set amount (false)
				/// @return				{UISlider}	self
				self.setClickToSet = function(_set)					{ self.__click_to_set = _set; return self; }
				
				/// @method				getValue()
				/// @description		Gets the value of the slider
				/// @return				{Real}	the value of the slider
				self.getValue = function()								{ return self.__value; }
				
				/// @method				setValue(_value)
				/// @description		Sets the value of the slider
				/// @param				{Real}	_value	the value to set
				/// @return				{UISlider}	self
				self.setValue = function(_value) { 
					var _old = self.__value;
					var _new = clamp(_value, self.__min_value, self.__max_value);
					var _changed = (_new != _old);					
					if (_changed) {
						self.__value = _new;
						self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);					
					}
					return self;
				}
				
				/// @method				getMinValue()
				/// @description		Gets the minimum value of the slider
				/// @return				{Real}	the minimum value of the slider
				self.getMinValue = function()							{ return self.__min_value; }
				
				/// @method				setMinValue(_min_value)
				/// @description		Sets the minimum value of the slider
				/// @param				{Real}	_min_value	the value to set
				/// @return				{UISlider}	self
				self.setMinValue = function(_min_value)					{ self.__min_value = _min_value; return self; }
				
				/// @method				getMaxValue()
				/// @description		Gets the maximum value of the slider
				/// @return				{Real}	the maximum value of the slider
				self.getMaxValue = function()							{ return self.__max_value; }
				
				/// @method				setMaxValue(_max_value)
				/// @description		Sets the maximum value of the slider
				/// @param				{Real}	_max_value	the value to set
				/// @return				{UISlider}	self
				self.setMaxValue = function(_max_value)					{ self.__max_value = _max_value; return self; }
				
				/// @method				getDragChange()
				/// @description		Gets the amount changed when dragging the handle
				/// @return				{Real}	the drag change amount
				self.getDragChange = function()						{ return self.__drag_change; }
				
				/// @method				setDragChange(_max_value)
				/// @description		Sets the amount changed when dragging the handle
				/// @param				{Real}	_amount	the drag change amount
				/// @return				{UISlider}	self
				self.setDragChange = function(_amount)					{ self.__drag_change = _amount; return self; }
				
				/// @method				getScrollChange()
				/// @description		Gets the amount changed when scrolling with the mouse
				/// @return				{Real}	the mouse scroll change amount
				self.getScrollChange = function()						{ return self.__scroll_change; }
				
				/// @method				setScrollChange(_max_value)
				/// @description		Sets the amount changed when scrolling with the mouse
				/// @param				{Real}	_amount	the mouse scroll change amount
				/// @return				{UISlider}	self
				self.setScrollChange = function(_amount)					{ self.__scroll_change = _amount; return self; }
				
				/// @method				getClickChange()
				/// @description		Gets the amount changed when clicking on an empty area of the slider
				/// @return				{Real}	the change amount when clicking
				self.getClickChange = function()							{ return self.__click_change; }
				
				/// @method				setClickChange(_max_value)
				/// @description		Sets the amount changed when clicking on an empty area of the slider
				/// @param				{Real}	_amount	the change amount when clicking
				/// @return				{UISlider}	self
				self.setClickChange = function(_amount)					{ self.__click_change = _amount; return self; }
				
				/// @method				getOrientation()
				/// @description		Gets the orientation of the slider according to UI_ORIENTATION
				/// @return				{Enum}	the orientation of the slider
				self.getOrientation = function()						{ return self.__orientation; }
				
				/// @method				setOrientation(_orientation)
				/// @description		Sets the orientation of the slide
				/// @param				{Enum}	_orientation	the orientation according to UI_ORIENTATION
				/// @return				{UISlider}	self
				self.setOrientation = function(_orientation)			{ self.__orientation = _orientation; return self; }
				
				/// @method				getShowMinMaxText()
				/// @description		Gets whether the slider renders text for the min and max values
				/// @return				{Bool}	whether the slider renders min/max text
				self.getShowMinMaxText = function()						{ return self.__show_min_max_text; }
				
				/// @method				setShowMinMaxText(_value)
				/// @description		Sets whether the slider renders text for the min and max values
				/// @param				{Bool}	_value	whether the slider renders min/max text
				/// @return				{UISlider}	self
				self.setShowMinMaxText = function(_value)				{ self.__show_min_max_text = _value; return self; }
				
				/// @method				getShowHandleText()
				/// @description		Gets whether the slider renders text for the handle value
				/// @return				{Bool}	whether the slider renders renders text for the handle value
				self.getShowHandleText = function()						{ return self.__show_handle_text; }
				
				/// @method				setShowHandleText(_value)
				/// @description		Sets whether the slider renders text for the handle value
				/// @param				{Bool}	_value	whether the slider renders text for the handle value
				/// @return				{UISlider}	self
				self.setShowHandleText = function(_value)				{ self.__show_handle_text = _value; return self; }
				
				/// @method				getTextFormat()
				/// @description		Gets the text format for the slider text
				/// @return				{String}	the Scribble text format used for the slider text
				self.getTextFormat = function()							{ return self.__text_format; }
				
				/// @method				setTextFormat(_format)
				/// @description		Sets the text format for the slider text
				/// @param				{String}	_format	the Scribble text format used for the slider text
				/// @return				{UISlider}	self
				self.setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
				/// @method				getInheritLength()
				/// @description		Gets whether the widget inherits its length (width or height, according to UI_ORIENTATION) from its parent.
				/// @returns			{Bool}	Whether the widget inherits its length from its parent
				self.getInheritLength = function()					{ return self.__orientation == UI_ORIENTATION.HORIZONTAL ?  self.__dimensions.inherit_width : self.__dimensions.inherit_length; }
				
				/// @method				setInheritLength(_inherit_length)
				/// @description		Sets whether the widget inherits its length (width or height, according to UI_ORIENTATION) from its parent.
				/// @param				{Bool}	_inherit_length Whether the widget inherits its length from its parent
				/// @return				{UIWidget}	self
				self.setInheritLength = function(_inherit_length)	{ 
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						self.__dimensions.inherit_width = _inherit_length;
					}
					else {
						self.__dimensions.inherit_height = _inherit_length;
					}
					self.__dimensions.calculateCoordinates();
					self.__updateChildrenPositions();
					return self;
				}
				
				/// @method				getHandleOffset()
				/// @description		Gets the x,y offset of the handle sprite, relative to the default (by default, it displays at the baseline of the rail, depending on orientation)
				/// @return				{Struct}	The x,y struct defining the offset
				self.getHandleOffset = function()							{ return self.__handle_offset; }
			
				/// @method				setHandleOffset(_offset)
				/// @description		Sets the x,y offset of the handle sprite, relative to the default (by default, it displays at the baseline of the rail, depending on orientation)
				/// @param				{Struct}	_offset		The x,y struct defining the offset
				/// @return				{UISlider}	self
				self.setHandleOffset = function(_offset)					{ self.__handle_offset = _offset; return self; }	
				
				/// @method				getHandleTextOffset()
				/// @description		Gets the x,y offset of the handle value text, relative to the default (by default, it displays the value at the top or the left of the handle, depending on orientation)
				/// @return				{Struct}	The x,y struct defining the offset
				self.getHandleTextOffset = function()							{ return self.__handle_text_offset; }
			
				/// @method				setHandleTextOffset(_offset)
				/// @description		Sets the x,y offset of the handle value text, relative to the default (by default, it displays the value at the top or the left of the handle, depending on orientation)
				/// @param				{Struct}	_offset		The x,y struct defining the offset
				/// @return				{UISlider}	self
				self.setHandleTextOffset = function(_offset)					{ self.__handle_text_offset = _offset; return self; }
				
			#endregion
			#region Methods
				self.__getHandle = function() {
					var _proportion = (self.__value - self.__min_value)/(self.__max_value - self.__min_value);
					var _handle_x, _handle_y;
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						var _width = self.__length * UI.getScale();
						var _height = sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) * UI.getScale() : 0;
						var _handle_x = self.__dimensions.x + _width * _proportion + self.__handle_offset.x;
						var _handle_y = self.__dimensions.y;
					}
					else {
						var _width = sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) * UI.getScale() : 0;
						var _height = self.__length * UI.getScale();
						var _handle_x = self.__dimensions.x;
						var _handle_y = self.__dimensions.y + _height * _proportion + self.__handle_offset.y;						
					}
					return {x: _handle_x, y: _handle_y};
				}
				
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					
					var _proportion = (self.__value - self.__min_value)/(self.__max_value - self.__min_value);
					
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						var _width = self.__length * UI.getScale();
						var _height = sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) * UI.getScale() : 0;
						var _width_base = _width;
						var _height_base = sprite_exists(self.__sprite_base) ? sprite_get_height(self.__sprite_base) * UI.getScale() : 0;
						var _width_progress = _width * _proportion;
						var _height_progress = sprite_exists(self.__sprite_progress) ? sprite_get_height(self.__sprite_progress) * UI.getScale() : 0;
						
						var _x_sprites = _x + (sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle)/2 : 0);
						var _y_sprites = _y - self.__handle_offset.y;
						var _width_widget = _width + (sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) : 0);
						var _height_widget = _height;
					}
					else {
						var _width = sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) * UI.getScale() : 0;
						var _height = self.__length * UI.getScale();
						var _width_base = sprite_exists(self.__sprite_base) ? sprite_get_width(self.__sprite_base) * UI.getScale() : 0;
						var _height_base = _height;
						var _width_progress = sprite_exists(self.__sprite_progress) ? sprite_get_width(self.__sprite_progress) * UI.getScale() : 0;
						var _height_progress = _height * _proportion;
						
						var _x_sprites = _x - self.__handle_offset.x;
						var _y_sprites = _y + (sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle)/2 : 0);
						var _width_widget = _width;
						var _height_widget = _height + (sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) : 0);
					}
					var _handle = self.__getHandle();
					
					var _m_x = device_mouse_x_to_gui(UI.getMouseDevice());
					var _m_y = device_mouse_y_to_gui(UI.getMouseDevice());
					var _w_handle = sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) : 0;
					var _h_handle = sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) : 0;
					var _within_handle = point_in_rectangle(_m_x, _m_y, _handle.x, _handle.y, _handle.x + _w_handle * UI.getScale(), _handle.y + _h_handle);
					
					// Draw
					if (sprite_exists(self.__sprite_base))			draw_sprite_stretched_ext(self.__sprite_base, self.__image_base, _x_sprites, _y_sprites, _width_base, _height_base, self.__image_blend, self.__image_alpha);
					if (sprite_exists(self.__sprite_progress))		draw_sprite_stretched_ext(self.__sprite_progress, self.__image_progress, _x_sprites + self.__sprite_progress_offset.x, _y_sprites + self.__sprite_progress_offset.y, _width_progress, _height_progress, self.__image_blend, self.__image_alpha);
					
					if (_within_handle || UI.__currentlyDraggedWidget == self) {
						if (sprite_exists(self.__sprite_handle_mouseover))			draw_sprite_ext(self.__sprite_handle_mouseover, self.__image_handle_mouseover, _handle.x, _handle.y, 1, 1, 0, self.__image_blend, self.__image_alpha);
					}
					else {
						if (sprite_exists(self.__sprite_handle))			draw_sprite_ext(self.__sprite_handle, self.__image_handle, _handle.x, _handle.y, 1, 1, 0, self.__image_blend, self.__image_alpha);
					}
					
					self.setDimensions(,, _width_widget, _height_widget);
					
					if (self.__show_min_max_text) {
						var _smin = UI_TEXT_RENDERER(self.__text_format + string(self.__min_value));
						var _smax = UI_TEXT_RENDERER(self.__text_format + string(self.__max_value));												
						if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
							_smin.draw(_x - _smin.get_width(), _y_sprites);
							//_smax.draw(_x + _width, _y);
							_smax.draw(_x + _width_widget, _y_sprites);
						}
						else {
							_smin.draw(_x_sprites, _y - _smin.get_height());
							//_smax.draw(_x, _y + _height);
							_smax.draw(_x_sprites, _y + _height_widget);
						}
					}
					
					if (self.__show_handle_text) {
						var _stxt = UI_TEXT_RENDERER(self.__text_format + string(self.__value));
						if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
							var _w_handle = sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) : 0;					
							_stxt.draw(_handle.x + _w_handle/2 + self.__handle_text_offset.x, _handle.y - _stxt.get_height() + self.__handle_text_offset.y);
						}
						else {
							var _h_handle = sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) : 0;
							_stxt.draw(_handle.x - _stxt.get_width() + self.__handle_text_offset.x, _handle.y + _h_handle/2 + self.__handle_text_offset.y);
						}
					}
										
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					
					// Check if click is outside handle
					var _m_x = device_mouse_x_to_gui(UI.getMouseDevice());
					var _m_y = device_mouse_y_to_gui(UI.getMouseDevice());
					var _handle = self.__getHandle();
					var _w_handle = sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) : 0;
					var _h_handle = sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) : 0;
					var _within_handle = point_in_rectangle(_m_x, _m_y, _handle.x, _handle.y, _handle.x + _w_handle * UI.getScale(), _handle.y + _h_handle);
					// Check if before or after handle
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						var _before = _m_x < _handle.x;
						var _after = _m_x > _handle.x + _w_handle;
					}
					else {
						var _before = _m_y < _handle.y;
						var _after = _m_y > _handle.y + _h_handle;
					}
					
					if (!_within_handle && self.__events_fired[UI_EVENT.LEFT_CLICK]) {
						if (self.__click_to_set) {
							self.__drag();
						}
						else {
							self.setValue(self.__value + (_before ? -1 : (_after ? 1 : 0)) * self.__click_change);
						}
					}					
					else if (self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN]) {
						self.setValue(self.__value + self.__scroll_change);
					}
					else if (self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP]) {
						self.setValue(self.__value - self.__scroll_change);
					}					
					
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
				
				self.__dragCondition = function() {
					var _m_x = device_mouse_x_to_gui(UI.getMouseDevice());
					var _m_y = device_mouse_y_to_gui(UI.getMouseDevice());
					var _handle = self.__getHandle();
					var _w_handle = sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) : 0;
					var _h_handle = sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) : 0;
					
					var _within_handle = point_in_rectangle(_m_x, _m_y, _handle.x, _handle.y, _handle.x + _w_handle * UI.getScale(), _handle.y + _h_handle);
					if (_within_handle) {
						UI.__drag_data.__drag_specific_start_x = _m_x;
						UI.__drag_data.__drag_specific_start_y = _m_y;
						UI.__drag_data.__drag_specific_start_width = _w_handle * UI.getScale();
						UI.__drag_data.__drag_specific_start_height = _h_handle * UI.getScale();
						UI.__drag_data.__drag_specific_start_value = self.__value;
					}
					return _within_handle;
				}
				
				self.__drag = function() {
					var _w_handle = sprite_exists(self.__sprite_handle) ? sprite_get_width(self.__sprite_handle) : 0;
					var _h_handle = sprite_exists(self.__sprite_handle) ? sprite_get_height(self.__sprite_handle) : 0;
					
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						var _width = self.__length * UI.getScale();
						var _current_value_proportion = (self.__value - self.__min_value)/(self.__max_value - self.__min_value);
						//var _current_handle_x_center = self.__getHandle().x + _w_handle/2;
						var _m_x = device_mouse_x_to_gui(UI.getMouseDevice());
						var _new_handle_x_center = _m_x  - _w_handle/2;
						var _new_value_proportion = clamp((_new_handle_x_center - self.__dimensions.x - self.__handle_offset.x) / _width, 0, 1);			
					}
					else {
						var _height = self.__length * UI.getScale();
						var _current_value_proportion = (self.__value - self.__min_value)/(self.__max_value - self.__min_value);
						//var _current_handle_y_center = self.__getHandle().y + _h_handle/2;
						var _m_y = device_mouse_y_to_gui(UI.getMouseDevice());
						var _new_handle_y_center = _m_y  - _h_handle/2;
						var _new_value_proportion = clamp((_new_handle_y_center - self.__dimensions.y - self.__handle_offset.y) / _height , 0, 1);	
					}
					
					if (abs(_new_value_proportion - _current_value_proportion) > 0.00001) {
						var _raw_value = _new_value_proportion * (self.__max_value - self.__min_value) + self.__min_value;
						if (_raw_value >= self.__max_value)			self.setValue(self.__max_value);
						else if (_raw_value <= self.__min_value)	self.setValue(self.__min_value);
						else {
							if (_raw_value < self.__value) {
								var _max_unit = self.__value;
								var _min_unit = max(self.__min_value, _max_unit - self.__drag_change);
								
								while (!(_raw_value <= _max_unit && _raw_value >= _min_unit)) {
									_max_unit = _min_unit;
									_min_unit = max(self.__min_value, _min_unit - self.__drag_change);
								}
								self.setValue( abs(_min_unit - _raw_value) < abs(_max_unit - _raw_value) ? _min_unit : _max_unit );								
							}
							else if (_raw_value > self.__value) {
								var _min_unit = self.__value;
								var _max_unit = min(self.__max_value, _min_unit + self.__drag_change);
								
								while (!(_raw_value <= _max_unit && _raw_value >= _min_unit)) {
									_min_unit = _max_unit;
									_max_unit = min(self.__max_value, _max_unit + self.__drag_change);
								}
								self.setValue( abs(_min_unit - _raw_value) < abs(_max_unit - _raw_value) ? _min_unit : _max_unit );								
							}		
						}						
					}
				}
				
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UITextBox
	
		/// @constructor	UITextBox(_id, _x, _y, _width, _height, _sprite, _max_chars, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A TextBox widget, that allows the user to select a value from a range by dragging, clicking or scrolling
		/// @param			{String}			_id				The TextBox's name, a unique string ID. If the specified name is taken, the TextBox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the TextBox, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the TextBox, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Real}				_width			The width of the TextBox
		/// @param			{Real}				_height			The height of the TextBox
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the TextBox
		/// @param			{Real}				[_max_chars]	The maximum number of characters for the TextBox, By default, no maximum.
		/// @param			{Enum}				[_relative_to]	The position relative to which the TextBox will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UITextBox}							self
		function UITextBox(_id, _x, _y, _width, _height, _sprite, _max_chars=999999999, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.TEXTBOX;
				self.__text = "";
				self.__placeholder_text = "";
				self.__max_chars = _max_chars <= 0 ? 999999999 : _max_chars;
				self.__mask_text = false;
				self.__mask_char = "*";
				self.__multiline = false;
				self.__cursor_pos = -1;
				self.__currently_editing = false;
				self.__read_only = false;
				self.__allow_uppercase_letters = true;
				self.__allow_lowercase_letters = true;
				self.__allow_spaces = true;
				self.__allow_digits = true;
				self.__allow_symbols = true;
				self.__symbols_allowed = "";
				self.__allow_cursor_mouse = true;
				self.__allow_cursor_keyboard = false;
				self.__text_anchor = UI_RELATIVE_TO.TOP_LEFT;
				self.__text_format = "";
				self.__text_margin = 2;
				
				self.__display_starting_char = 0;
				self.__surface_id = -1;
				
				// Adjust width/height to consider margin
				self.__dimensions.set(,, self.__dimensions.width + 2*self.__text_margin, self.__dimensions.height + 2*self.__text_margin);
			#endregion
			#region Setters/Getters			
				
				/// @method				getText()
				/// @description		Gets the text of the textbox
				/// @return				{String}	The text of the textbox
				self.getText = function()								{ return self.__text; }
			
				/// @method				setText(_text)
				/// @description		Sets the text of the textbox. If set to read only, this will have no effect.
				/// @param				{String}	__text	The text to set
				/// @return				{UITextBox}	self
				self.setText = function(_text) {
					if (!self.__read_only) {
						var _old = self.__text;
						var _new = self.__max_chars == 99999999 ? _text : string_copy(_text, 1, self.__max_chars);
						var _changed = _old != _new;
						if (_changed) {
							self.__text = _new;
							self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);
						}
						self.__processCursor(_changed);
					}
					return self;
				}
				
				/// @method				getPlaceholderText()
				/// @description		Gets the placeholder text of the textbox (text that is shown when the textbox is empty)
				/// @return				{String}	The placeholder text of the textbox
				self.getPlaceholderText = function()					{ return self.__placeholder_text; }
			
				/// @method				setPlaceholderText(_text)
				/// @description		Sets the placeholder text of the textbox (text that is shown when the textbox is empty)
				/// @param				{String}	__text	The placeholder text to set
				/// @return				{UITextBox}	self
				self.setPlaceholderText = function(_text)				{ self.__placeholder_text = _text; return self; }
				
				/// @method				getMaxChars()
				/// @description		Gets the maximum character limit for the textbox. If 0, the textbox has no limit.
				/// @return				{Real}	The character limit for the textbox
				self.getMaxChars = function()							{ return self.__max_chars; }
			
				/// @method				setMaxChars(_max_chars)
				/// @description		Sets the maximum character limit for the textbox. If 0, the textbox has no limit.
				/// @param				{Real}	_max_chars	The character limit to set
				/// @return				{UITextBox}	self
				self.setMaxChars = function(_max_chars)	{
					self.__max_chars =  _max_chars <= 0 ? 999999999 : _max_chars;
					if (_max_chars >  0 && string_length(self.__text) > _max_chars)	self.__text = string_copy(self.__text, 1, _max_chars);
					return self;
				}
				
				/// @method				getMaskText()
				/// @description		Gets whether text is masked using a masking character
				/// @return				{Bool}	Whether the text is masked or not
				self.getMaskText = function()							{ return self.__mask_text; }
				
				/// @method				setMaskText(_mask_text)
				/// @description		Sets whether text is masked using a masking character
				/// @param				{Bool}	_mask_text	Whether the text is masked or not
				/// @return				{UITextBox}	self
				self.setMaskText = function(_mask_text)					{ self.__mask_text = _mask_text; return self; }
				
				/// @method				getMaskChar()
				/// @description		Gets the character used to mask text
				/// @return				{String}	The character used to mask
				self.getMaskChar = function()							{ return self.__mask_char; }
				
				/// @method				setMaskChar(_mask_char)
				/// @description		Sets the character used to mask text
				/// @param				{String}	_mask_char	The character to use to mask
				/// @return				{UITextBox}	self
				self.setMaskChar = function(_mask_char)					{ self.__mask_char = _mask_char; return self; }
				
				/// @method				getMultiline()
				/// @description		Returns whether the textbox is multi-line or not.
				/// @return				{Bool}	Whether the textbox is multiline or not
				self.getMultiline = function()							{ return self.__multiline; }
				
				/// @method				setMultiline(_multiline)
				/// @description		Sets whether the textbox is multi-line or not.
				/// @param				{Bool}	_multiline	Whether to set the textbox to multiline or not
				/// @return				{UITextBox}	self
				self.setMultiline = function(_multiline)					{ self.__multiline = _multiline; return self; }
				
				/// @method				getCursorPos()
				/// @description		Returns the cursor position (in characters)
				/// @return				{Real}	the cursor position
				self.getCursorPos = function()							{ return self.__cursor_pos; }
				
				/// @method				setCursorPos(_pos)
				/// @description		Sets the cursor position (in characters)
				/// @param				{Real}	_pos	The cursor position
				/// @return				{UITextBox}	self
				self.setCursorPos = function(_pos)						{ self.__cursor_pos = _pos; return self; }
				
				/// @method				getCurrentlyEditing()
				/// @description		Returns whether the textbox is being edited or not
				/// @return				{Bool}	Whether the textbox is being edited or not
				self.getCurrentlyEditing = function()					{ return UI.__textbox_editing_ref == self; }
				
				/// @method				setCurrentlyEditing(_edit)
				/// @description		Sets whether the textbox is being edited or not. Will only set if the textbox is not set to read only.
				/// @param				{Bool}	_edit	Whether the textbox is being edited
				/// @return				{UITextBox}	self
				self.setCurrentlyEditing = function(_edit) {
					if (!self.__read_only && _edit) {
						UI.__textbox_editing_ref = self;
					}
					return self;
				}
				
				/// @method				getReadOnly()
				/// @description		Returns whether the textbox is read-only or not
				/// @return				{Bool}	Whether the textbox is read-only or not
				self.getReadOnly = function()							{ return self.__read_only; }
				
				/// @method				setReadOnly(_read_only)
				/// @description		Sets whether the textbox is read-only or not
				/// @param				{Bool}	_read_only	Whether the textbox is the textbox is read-only
				/// @return				{UITextBox}	self
				self.setReadOnly = function(_read_only)					{ self.__read_only = _read_only; return self; }
				
				/// @method				getAllowUppercaseLetters()
				/// @description		Returns whether uppercase letters are allowed in the textbox
				/// @return				{Bool}	Whether uppercase letters are allowed
				self.getAllowUppercaseLetters = function()				{ return self.__allow_uppercase_letters; }
				
				/// @method				setAllowUppercaseLetters(_allow_uppercase_letters)
				/// @description		Sets whether uppercase letters are allowed in the textbox
				/// @param				{Bool}	_allow_uppercase_letters	Whether uppercase letters are allowed
				/// @return				{UITextBox}	self
				self.setAllowUppercaseLetters = function(_allow_uppercase_letters)			{ self.__allow_uppercase_letters = _allow_uppercase_letters; return self; }
				
				/// @method				getAllowLowercaseLetters()
				/// @description		Returns whether lowercase letters are allowed in the textbox
				/// @return				{Bool}	Whether lowercase letters are allowed
				self.getAllowLowercaseLetters = function()				{ return self.__allow_lowercase_letters; }
				
				/// @method				setAllowLowercaseLetters(_allow_lowercase_letters)
				/// @description		Sets whether lowercase letters are allowed in the textbox
				/// @param				{Bool}	_allow_lowercase_letters	Whether lowercase letters are allowed
				/// @return				{UITextBox}	self
				self.setAllowLowercaseLetters = function(_allow_lowercase_letters)			{ self.__allow_lowercase_letters = _allow_lowercase_letters; return self; }
				
				/// @method				getAllowSpaces()
				/// @description		Returns whether spaces are allowed in the textbox
				/// @return				{Bool}	Whether spaces are allowed
				self.getAllowSpaces = function()						{ return self.__allow_spaces; }
				
				/// @method				setAllowSpaces(_allow_spaces)
				/// @description		Sets whether spaces are allowed in the textbox
				/// @param				{Bool}	_allow_spaces	Whether spaces are allowed
				/// @return				{UITextBox}	self
				self.setAllowSpaces = function(_allow_spaces)			{ self.__allow_spaces = _allow_spaces; return self; }
				
				/// @method				getAllowDigits()
				/// @description		Returns whether digits are allowed in the textbox
				/// @return				{Bool}	Whether digits are allowed
				self.getAllowDigits = function()						{ return self.__allow_digits; }
				
				/// @method				setAllowDigits(_allow_digits)
				/// @description		Sets whether digits are allowed in the textbox
				/// @param				{Bool}	_allow_digits	Whether digits are allowed
				/// @return				{UITextBox}	self
				self.setAllowDigits = function(_allow_digits)			{ self.__allow_digits = _allow_digits; return self; }
				
				/// @method				getAllowSymbols()
				/// @description		Returns whether symbols are allowed in the textbox
				/// @return				{Bool}	Whether symbols are allowed
				self.getAllowSymbols = function()						{ return self.__allow_symbols; }
				
				/// @method				setAllowSymbols(_allow_symbols)
				/// @description		Sets whether symbols are allowed in the textbox. The specific symbols allowed can be set with the setSymbolsAllowed method.
				/// @param				{Bool}	_allow_symbols	Whether symbols are allowed
				/// @return				{UITextBox}	self
				self.setAllowSymbols = function(_allow_symbols)			{ self.__allow_symbols = _allow_symbols; return self; }
				
				/// @method				getAllowCursorMouse()
				/// @description		Returns whether mouse cursor navigation is allowed
				/// @return				{Bool}	Whether mouse cursor navigation is allowed
				self.getAllowCursorMouse = function()					{ return self.__allow_cursor_mouse; }
				
				/// @method				setAllowCursorMouse(_allow_cursor_mouse)
				/// @description		Sets whether mouse cursor navigation is allowed
				/// @param				{Bool}	_allow_cursor_mouse	Whether mouse cursor navigation is allowed
				/// @return				{UITextBox}	self
				self.setAllowCursorMouse = function(_allow_cursor_mouse)	{ self.__allow_cursor_mouse = _allow_cursor_mouse; return self; }
				
				/// @method				getAllowCursorKeyboard()
				/// @description		Returns whether keyboard cursor navigation is allowed
				/// @return				{Bool}	Whether keyboard cursor navigation is allowed
				self.getAllowCursorKeyboard = function()					{ return self.__allow_cursor_keyboard; }
				
				/// @method				setAllowCursorKeyboard(_allow_cursor_keyboard)
				/// @description		Sets whether keyboard cursor navigation is allowed
				/// @param				{Bool}	_allow_cursor_keyboard	Whether keyboard cursor navigation is allowed
				/// @return				{UITextBox}	self
				self.setAllowCursorKeyboard = function(_allow_cursor_keyboard)	{ self.__allow_cursor_keyboard = _allow_cursor_keyboard; return self; }
				
				/// @method				getSymbolsAllowed()
				/// @description		Returns the list of allowed symbols. This does not have any effect if getAllowSymbols is false.
				/// @return				{String}	The list of allowed symbols
				self.getSymbolsAllowed = function()					{ return self.__symbols_allowed; }
				
				/// @method				setSymbolsAllowed(_symbols)
				/// @description		Sets the list of allowed symbols. This does not have any effect if getAllowSymbols is false.
				/// @param				{String}	_symbols	The list of allowed symbols
				/// @return				{UITextBox}	self
				self.setSymbolsAllowed = function(_symbols)	{ self.__symbols_allowed = _symbols; return self; }
				
				/// @method				getTextAnchor()
				/// @description		Returns the position to which text is anchored within the textbox, according to UI_RELATIVE_TO
				/// @return				{Enum}	The text anchor
				self.getTextAnchor = function()					{ return self.__text_anchor; }
				
				/// @method				setTextAnchor(_anchor)
				/// @description		Sets the position to which text is anchored within the textbox, according to UI_RELATIVE_TO
				/// @param				{Enum}	_anchor		The desired text anchor
				/// @return				{UITextBox}	self
				self.setTextAnchor = function(_anchor)	{ self.__text_anchor = _anchor; return self; }
				
				/// @method				getTextFormat()
				/// @description		Gets the text format for the textbox
				/// @return				{String}	the Scribble text format used for the textbox
				self.getTextFormat = function()							{ return self.__text_format; }
				
				/// @method				setTextFormat(_format)
				/// @description		Sets the text format for the textbox
				/// @param				{String}	_format	the Scribble text format used for the textbox
				/// @return				{UITextBox}	self
				self.setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
				/// @method				getTextMargin()
				/// @description		Gets the text margin for the text inside the textbox
				/// @return				{Real}	the margin for the text inside the textbox
				self.getTextMargin = function()							{ return self.__text_margin; }
				
				/// @method				setTextMargin(_margin)
				/// @description		Sets the text margin for the text inside the textbox
				/// @param				{Real}	_margin		the margin for the text inside the textbox
				/// @return				{UITextBox}	self
				self.setTextMargin = function(_margin)					{ self.__text_margin = _margin; return self; }
				
			#endregion
			#region Methods
				
				/// @method				clearText()
				/// @description		clears the TextBox text
				/// @return				{UITextBox}	self
				self.clearText= function() {
					self.setText("");
					self.__cursor_pos = -1;
				}
				
				self.__processCursor = function(_text_change) {
					if (_text_change) {
						if (keyboard_lastkey == vk_backspace)	self.__cursor_pos = self.__cursor_pos == -1 ? -1 : max(0, self.__cursor_pos-1);
						else if (keyboard_lastkey == vk_delete)	keyboard_lastkey = vk_nokey;
						else if (keyboard_lastkey != vk_delete)	self.__cursor_pos = self.__cursor_pos == -1 ? -1 : self.__cursor_pos+1;
					}
					else {									
						if (keyboard_lastkey == vk_home)		self.__cursor_pos = 0;
						else if (keyboard_lastkey == vk_end)	self.__cursor_pos = -1;
						else if (keyboard_lastkey == vk_left) {
							var _n = string_length(self.__text);
							if (keyboard_check(vk_control) && self.__cursor_pos != 0)	{
								do {
									self.__cursor_pos = self.__cursor_pos == -1 ? _n-1 : self.__cursor_pos - 1;
								}
								until (self.__cursor_pos == 0 || string_char_at(self.__text, self.__cursor_pos) == " ");
								
							}
							else {
								self.__cursor_pos = (self.__cursor_pos == -1 ? _n-1 : max(self.__cursor_pos-1, 0));
							}
							keyboard_lastkey = vk_nokey;
						}
						else if (keyboard_lastkey == vk_right) {
							var _n = string_length(self.__text);
							if (keyboard_check(vk_control) && self.__cursor_pos != -1)	{
								do {
									self.__cursor_pos = self.__cursor_pos == -1 ? -1 : self.__cursor_pos + 1;
									if (self.__cursor_pos == _n) self.__cursor_pos = -1;
								}
								until (self.__cursor_pos == -1 || string_char_at(self.__text, self.__cursor_pos) == " ");								
							}
							else {
								if (self.__cursor_pos >= 0) self.__cursor_pos = ( self.__cursor_pos == _n-1 ? -1 : self.__cursor_pos+1 );						
							}
							keyboard_lastkey = vk_nokey;
						}
					}
				}
				
				self.__draw = function() {
					// Clean the click command
					if ((keyboard_check_pressed(vk_enter) && !self.__multiline) && UI.__textbox_editing_ref == self && !self.__read_only) {
						UI.__textbox_editing_ref = noone;
						self.__cursor_pos = -1;
						keyboard_string = "";
					}
					
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();					
					var _height = self.__dimensions.height * UI.getScale();
															
					var _text_to_display = (self.__text == "" && UI.__textbox_editing_ref != self) ? self.__placeholder_text : (self.__mask_text ? string_repeat(self.__mask_char, string_length(self.__text)) : self.__text);
					var _cursor = (UI.__textbox_editing_ref == self ? "[blink][c_gray]|[/blink]"+self.getTextFormat() : "");
					var _text_with_cursor = self.__cursor_pos == -1 ? _text_to_display + _cursor : string_copy(_text_to_display, 1, self.__cursor_pos)+_cursor+string_copy(_text_to_display, self.__cursor_pos+1, string_length(_text_to_display));
					
					var _n = max(1, string_length(_text_to_display));
					var _avg_width = UI_TEXT_RENDERER(self.__text_format + "e").get_width();
					var _letter_height = UI_TEXT_RENDERER(self.__text_format + "|").get_height();
					var _s = UI_TEXT_RENDERER(self.__text_format + _text_with_cursor);
										
					// Fix width
					var _offset = max(0, _s.get_width() - _width);
					
					if (self.__multiline) {
						_s.wrap(_width - 2*self.__text_margin);						
					}
					else {						
						_height = _letter_height + 2*self.__text_margin;
						self.__dimensions.height = _height * UI.getScale();
					}
					
					if (_offset > 0 && self.__cursor_pos != -1) {
						var _test = UI_TEXT_RENDERER(string_copy(_text_to_display, 1, self.__cursor_pos)).get_width();
						var _cursor_left_of_textbox = (_test < _offset);
						while (_cursor_left_of_textbox) {
							_offset -= 2*_avg_width;
							_cursor_left_of_textbox = (_test < _offset);
						}
					}
					
					
					if (sprite_exists(self.__sprite)) draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
					
					if (!surface_exists(self.__surface_id))	self.__surface_id = surface_create(_width, _height);
					surface_set_target(self.__surface_id);
					draw_clear_alpha(c_black, 0);
					_s.draw(self.__text_margin - _offset, self.__text_margin);
					surface_reset_target();
					draw_surface(self.__surface_id, _x, _y);					
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK] && UI.__textbox_editing_ref != self)  {
						if (UI.__textbox_editing_ref != noone)	UI.__textbox_editing_ref.__cursor_pos = -1;
						keyboard_string = self.__cursor_pos == -1 ? self.__text : string_copy(self.__text, 1, self.__cursor_pos);
						UI.__textbox_editing_ref = self;
						self.__callbacks[UI_EVENT.LEFT_CLICK]();
					}
					
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					_arr[UI_EVENT.LEFT_CLICK] = false;
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UIOptionGroup
	
		/// @constructor	UIOptionGroup(_id, _x, _y, _option_array, _sprite, [_initial_idx=0], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	An option group widget, clickable UI widget that lets the user select from a list of values.
		/// @param			{String}			_id				The Checkbox's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Checkbox, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Checkbox, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Array<String>}		_option_array	An array with at least one string that contains the text for each of the options
		/// @param			{Asset.GMSprite}	_sprite			The sprite ID to use for rendering the option group
		/// @param			{Real}				[_initial_idx]	The initial selected index of the Option group (default=0, the first option)
		/// @param			{Enum}				[_relative_to]	The position relative to which the Checkbox will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIOptionGroup}						self
		function UIOptionGroup(_id, _x, _y, _option_array, _sprite, _initial_idx=-1, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.OPTION_GROUP;
				self.__option_array_unselected = _option_array;
				self.__option_array_selected = _option_array;
				self.__option_array_mouseover = _option_array;
				self.__text_format_unselected = "";
				self.__text_format_selected = "";
				self.__text_format_mouseover = "";
				self.__sprite_unselected = _sprite;
				self.__sprite_selected = _sprite;
				self.__sprite_mouseover = _sprite;			
				self.__image_unselected = 0;
				self.__image_selected = 1;
				self.__image_mouseover = -1;
				self.__index = _initial_idx;
				self.__vertical = true;
				self.__spacing = 20;
				
				self.__option_array_dimensions = [];
			#endregion
			#region Setters/Getters			
				/// @method				getRawOptionArrayUnselected()
				/// @description		Gets the options text array of the group, for the unselected state, without Scribble formatting tags.
				///	@return				{Array<String>}	The options text array on the unselected state, without Scribble formatting tags
				self.getRawOptionArrayUnselected = function()	{ 
					var _arr = [];
					for (var _i=0, _n=array_length(self.__option_array_unselected); _i<_n; _i++)		array_push(_arr, UI_TEXT_RENDERER(self.__option_array_unselected[_i]).get_text());
					return _arr;
				}
				
				/// @method				getOptionArrayUnselected()
				/// @description		Gets the options text array of the group
				///	@return				{Array<String>}	The options text array on the unselected state
				self.getOptionArrayUnselected = function()						{ return self.__option_array_unselected; }
			
				/// @method				setOptionArrayUnselected(_option_array)
				/// @description		Sets the options text array of the group
				/// @param				{Array<String>}	_option_array	The array containing the text for each of the options
				///	@return				{UIOptionGroup}	self
				self.setOptionArrayUnselected = function(_option_array)			{ self.__option_array_unselected = _option_array; return self; }
				
				/// @method				getRawOptionArraySelected()
				/// @description		Gets the options text array of the group, for the selected state, without Scribble formatting tags.
				///	@return				{Array<String>}	The options text array on the selected state, without Scribble formatting tags
				self.getRawOptionArraySelected = function()	{ 
					var _arr = [];
					for (var _i=0, _n=array_length(self.__option_array_selected); _i<_n; _i++)		array_push(_arr, UI_TEXT_RENDERER(self.__option_array_selected[_i]).get_text());
					return _arr;
				}
				
				/// @method				getOptionArraySelected()
				/// @description		Gets the options text array of the group
				///	@return				{Array<String>}	The options text array on the selected state
				self.getOptionArraySelected = function()						{ return self.__option_array_selected; }
			
				/// @method				setOptionArraySelected(_option_array)
				/// @description		Sets the options text array of the group
				/// @param				{Array<String>}	_option_array	The array containing the text for each of the options
				///	@return				{UIOptionGroup}	self
				self.setOptionArraySelected = function(_option_array)			{ self.__option_array_selected = _option_array; return self; }
				
				/// @method				getRawOptionArrayMouseover()
				/// @description		Gets the options text array of the group, for the mouseover state, without Scribble formatting tags.
				///	@return				{Array<String>}	The options text array on the mouseover state, without Scribble formatting tags
				self.getRawOptionArrayMouseover = function()	{ 
					var _arr = [];
					for (var _i=0, _n=array_length(self.__option_array_mouseover); _i<_n; _i++)		array_push(_arr, UI_TEXT_RENDERER(self.__option_array_mouseover[_i]).get_text());
					return _arr;
				}
				
				/// @method				getOptionArrayMouseover()
				/// @description		Gets the options text array of the group
				///	@return				{Array<String>}	The options text array on the mouseover state
				self.getOptionArrayMouseover = function()						{ return self.__option_array_mouseover; }
			
				/// @method				setOptionArrayMouseover(_option_array)
				/// @description		Sets the options text array of the group
				/// @param				{Array<String>}	_option_array	The array containing the text for each of the options
				///	@return				{UIOptionGroup}	self
				self.setOptionArrayMouseover = function(_option_array)			{ self.__option_array_mouseover = _option_array; return self; }				
				
			
				/// @method				getSpriteMouseover()
				/// @description		Gets the sprite ID of the options group button when mouseovered			
				/// @return				{Asset.GMSprite}	The sprite ID of the button when mouseovered
				self.getSpriteMouseover = function()				{ return self.__sprite_mouseover; }
			
				/// @method				setSpriteMouseover(_sprite)
				/// @description		Sets the sprite to be rendered when mouseovered.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIOptionGroup}	self
				self.setSpriteMouseover = function(_sprite)			{ self.__sprite_mouseover = _sprite; return self; }
			
				/// @method				getImageMouseover()
				/// @description		Gets the image index of the options group button when mouseovered.		
				/// @return				{Real}	The image index of the button when mouseovered
				self.getImageMouseover = function()					{ return self.__image_mouseover; }
			
				/// @method				setImageMouseover(_image)
				/// @description		Sets the image index of the options group button when mouseovered
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageMouseover = function(_image)			{ self.__image_mouseover = _image; return self; }
			
				/// @method				getSpriteSelected()
				/// @description		Gets the sprite ID of the options group button used for the selected state.
				/// @return				{Asset.GMSprite}	The sprite ID of the options group button used for the selected state.
				self.getSpriteSelected = function()					{ return self.__sprite_selected; }
			
				/// @method				setSpriteSelected(_sprite)
				/// @description		Sets the sprite to be used for the selected state.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIOptionGroup}	self
				self.setSpriteSelected = function(_sprite)			{ self.__sprite_selected = _sprite; return self; }
			
				/// @method				getImageSelected()
				/// @description		Gets the image index of the options group button used for the selected state.
				/// @return				{Real}	The image index of the options group button used for the selected state.
				self.getImageSelected = function()					{ return self.__image_selected; }
			
				/// @method				setImageSelected(_image)
				/// @description		Sets the image index of the options group button used for the selected state.
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageSelected = function(_image)			{ self.__image_selected = _image; return self; }				
				
				/// @method				getSpriteUnselected()
				/// @description		Gets the sprite ID of the options group button used for the unselected state.	
				/// @return				{Asset.GMSprite}	The sprite ID of the options group button used for the unselected state.	
				self.getSpriteUnselected = function()				{ return self.__sprite_unselected; }
			
				/// @method				setSpriteUnselected(_sprite)
				/// @description		Sets the sprite to be used for the unselected state.	
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIOptionGroup}	self
				self.setSpriteUnselected = function(_sprite)			{ self.__sprite_unselected = _sprite; return self; }
			
				/// @method				getImageUnselected()
				/// @description		Gets the image index of the options group button used for the unselected state.		
				/// @return				{Real}	The image index of the options group button  used for the unselected state.	
				self.getImageUnselected = function()					{ return self.__image_unselected; }
			
				/// @method				setImageUnselected(_image)
				/// @description		Sets the image index of the options group button used for the unselected state.	
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageUnselected = function(_image)			{ self.__image_unselected = _image; return self; }
				
				/// @method				getIndex()
				/// @description		Gets the index of the selected option, or -1 if no option is currently selected.
				/// @return				{Real}	The selected option index
				self.getIndex = function()							{ return self.__index; }
				
				/// @method				setIndex(_index)
				/// @description		Sets the index of the selected option. If set to -1, it will select no options.<br>
				///						If the number provided exceeds the range of the options array, no change will be performed.
				/// @param				{Real}	_index	The index to set
				/// @return				{UIOptionGroup}	self
				self.setIndex = function(_index) {
					var _old = self.__index;
					var _new = (_index == -1 ? -1 : clamp(_index, 0, array_length(self.__option_array_unselected)));
					var _changed = (_old != _new);					
					if (_changed) {
						self.__index = _new;
						self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);
					}
					return self;
				}
				
				/// @method				getOptionRawText()
				/// @description		Gets the raw text of the selected option, or "" if no option is currently selected, without Scribble formatting tags
				/// @return				{String}	The selected option text
				self.getOptionRawText = function()					{ return self.__index == -1 ? "" : UI_TEXT_RENDERER(self.__option_array_selected[self.__index]).get_text(); }
				
				/// @method				getOptionText()
				/// @description		Gets the text of the selected option, or "" if no option is currently selected.
				/// @return				{String}	The selected option text
				self.getOptionText = function()						{ return self.__index == -1 ? "" : self.__option_array_selected[self.__index]; }
				
				/// @method				getVertical()
				/// @description		Gets whether the options group is rendered vertically (true) or horizontally (false)
				/// @return				{Bool}	Whether the group is rendered vertically
				self.getVertical = function()						{ return self.__vertical; }
				
				/// @method				setVertical(_is_vertical)
				/// @description		Sets whether the options group is rendered vertically (true) or horizontally (false)
				/// @param				{Bool}	_is_vertical	Whether to render the group vertically
				/// @return				{UIOptionGroup}	self
				self.setVertical = function(_is_vertical)			{ self.__vertical = _is_vertical; return self; }
				
				/// @method				getSpacing()
				/// @description		Gets the spacing between options when rendering
				/// @return				{Real}	The spacing in px
				self.getSpacing = function()						{ return self.__spacing; }
				
				/// @method				setSpacing(_spacing)
				/// @description		Sets the spacing between options when rendering
				/// @param				{Real}	_spacing	The spacing in px
				/// @return				{UIOptionGroup}	self
				self.setSpacing = function(_spacing)				{ self.__spacing = _spacing; return self; }
				
				/// @method			getTextFormatUnselected()
				/// @description	Gets the text format for unselected items
				/// @return			{Any}	the format
				self.getTextFormatUnselected = function() {
					return self.__text_format_unselected;
				}

				/// @method			setTextFormatUnselected(_format)
				/// @description	Sets the text format for unselected items
				/// @param			{Any}	_format	the format to set
				/// @return			{Struct}	self
				self.setTextFormatUnselected = function(_format) {
					self.__text_format_unselected = _format;
					return self;
				}

				/// @method			getTextFormatSelected()
				/// @description	Gets text format for selected items
				/// @return			{Any}	the format
				self.getTextFormatSelected = function() {
					return self.__text_format_selected;
				}

				/// @method			setTextFormatSelected(_format)
				/// @description	Sets text format for selected items
				/// @param			{Any}	_format	the format to set
				/// @return			{Struct}	self
				self.setTextFormatSelected = function(_format) {
					self.__text_format_selected = _format;
					return self;
				}

				/// @method			getTextFormatMouseover()
				/// @description	Gets text format for mouseovered items
				/// @return			{Any}	the format
				self.getTextFormatMouseover = function() {
					return self.__text_format_mouseover;
				}

				/// @method			setTextFormatMouseover(_format)
				/// @description	Sets text format for mouseovered items
				/// @param			{Any}	_format	the value to set
				/// @return			{Struct}	self
				self.setTextFormatMouseover = function(_format) {
					self.__text_format_mouseover = _format;
					return self;
				}


				
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					
					var _curr_x = _x;
					var _curr_y = _y;
					var _sum_width = 0;
					var _sum_height = 0;
					var _max_width = 0;
					var _max_height = 0;
					var _n=array_length(self.__option_array_unselected);
					
					self.__option_array_dimensions = array_create(_n);
					for (var _i=0; _i<_n; _i++)	self.__option_array_dimensions[_i] = {x:0, y:0, width:0, height:0};
					for (var _i=0; _i<_n; _i++) {
						var _sprite = self.__index == _i ? self.__sprite_selected : self.__sprite_unselected;
						var _image = self.__index == _i ? self.__image_selected : self.__image_unselected;
						var _text = self.__index == _i ? self.__option_array_selected[_i] : self.__option_array_unselected[_i];
						var _w_selected =   sprite_exists(self.__sprite_selected) ? sprite_get_width(self.__sprite_selected) : 0;
						var _h_selected =   sprite_exists(self.__sprite_selected) ? sprite_get_height(self.__sprite_selected) : 0;
						var _w_unselected = sprite_exists(self.__sprite_unselected) ? sprite_get_width(self.__sprite_unselected) : 0;
						var _h_unselected = sprite_exists(self.__sprite_unselected) ? sprite_get_height(self.__sprite_unselected) : 0;
						var _width = (self.__index == _i ? _w_selected : _w_unselected) * UI.getScale();
						var _height = (self.__index == _i ? _h_selected : _h_unselected) * UI.getScale();
						if (sprite_exists(_sprite)) draw_sprite_stretched_ext(_sprite, _image, _curr_x, _curr_y, _width, _height, self.__image_blend, self.__image_alpha);
						var _scale = "[scale,"+string(UI.getScale())+"]";				
						var _s = UI_TEXT_RENDERER(_scale+_text);
						var _text_x = _curr_x + _width;
						var _text_y = _curr_y + _height/2;
						_s.draw(_text_x, _text_y);
						
						self.__option_array_dimensions[_i].x = _curr_x;
						self.__option_array_dimensions[_i].y = _curr_y;
						self.__option_array_dimensions[_i].width = _width + _s.get_width();
						self.__option_array_dimensions[_i].height = _height;
						
						if (self.__vertical) {
							_curr_y += _height + (_i<_n-1 ? self.__spacing : 0);
						}						
						else {
							_curr_x += _width + _s.get_width() + (_i<_n-1 ? self.__spacing : 0);
						}
						
						_sum_width += _width + _s.get_width() + (_i<_n-1 ? self.__spacing : 0);
						_sum_height += _height + (_i<_n-1 ? self.__spacing : 0);
						_max_width = max(_max_width, _width + _s.get_width());
						_max_height = max(_max_height, _height);
					}
					
					if (self.__vertical) {
						self.setDimensions(,, _max_width, _sum_height);
					}
					else {
						self.setDimensions(,, _sum_width, _max_height);
					}
					
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
						var _clicked = -1;
						var _n=array_length(self.__option_array_unselected);
						var _i=0;
						while (_i<_n && _clicked == -1) {
							if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), self.__option_array_dimensions[_i].x, self.__option_array_dimensions[_i].y, self.__option_array_dimensions[_i].x + self.__option_array_dimensions[_i].width, self.__option_array_dimensions[_i].y + self.__option_array_dimensions[_i].height)) {
								_clicked = _i;
							}
							else {
								_i++;
							}
						}
						
						if (_clicked != -1 && _clicked != self.__index)	{
							self.setIndex(_clicked);
						}
					}
					
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UIDropDown
	
		/// @constructor	UIDropdown(_id, _x, _y, _option_array, _sprite_dropdown, _sprite, [_initial_idx=0], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIOptionGroup
		/// @description	A Dropdown widget, clickable UI widget that lets the user select from a list of values. Extends UIOptionGroup as it provides the same functionality with different interface.
		/// @param			{String}			_id					The Dropdown's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x					The x position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y					The y position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Array<String>}		_option_array		An array with at least one string that contains the text for each of the options
		/// @param			{Asset.GMSprite}	_sprite_dropdown	The sprite ID to use for rendering the background of the list of values
		/// @param			{Asset.GMSprite}	_sprite				The sprite ID to use for rendering each value within the list of values
		/// @param			{Real}				[_initial_idx]		The initial selected index of the Dropdown list (default=0, the first option)
		/// @param			{Enum}				[_relative_to]		The position relative to which the Dropdown will be drawn. By default, the top left (TOP_LEFT) <br>
		///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIDropdown}							self
		function UIDropdown(_id, _x, _y, _option_array, _sprite_dropdown, _sprite, _initial_idx=0, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : UIOptionGroup(_id, _x, _y, _option_array, _sprite, _initial_idx, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.DROPDOWN;
				self.__sprite_arrow = noone;
				self.__image_arrow = 0;
				self.__sprite_dropdown = _sprite_dropdown;
				self.__image_dropdown = 0;
				self.__dropdown_active = false;
			#endregion
			#region Setters/Getters			
				/// @method				getSpriteDropdown()
				/// @description		Gets the sprite ID of the dropdown background
				/// @return				{Asset.GMSprite}	The sprite ID of the dropdown
				self.getSpriteDropdown = function()				{ return self.__sprite_dropdown; }
			
				/// @method				setSpriteDropdown(_sprite)
				/// @description		Sets the sprite ID of the dropdown background
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIDropdown}	self
				self.setSpriteDropdown = function(_sprite)			{ self.__sprite_dropdown = _sprite; return self; }
			
				/// @method				getImageDropdown()
				/// @description		Gets the image index of the dropdown background
				/// @return				{Real}	The image index of the dropdown background
				self.getImageDropdown = function()					{ return self.__image_dropdown; }
			
				/// @method				setImageDropdown(_image)
				/// @description		Sets the image index of the dropdown background
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageDropdown = function(_image)			{ self.__image_dropdown = _image; return self; }
				
				/// @method				getSpriteArrow()
				/// @description		Gets the sprite ID of the arrow icon for the dropdown
				/// @return				{Asset.GMSprite}	The sprite ID of the dropdown
				self.getSpriteArrow = function()				{ return self.__sprite_arrow; }
			
				/// @method				setSpriteArrow(_sprite)
				/// @description		Sets the sprite ID of the arrow icon for the dropdown
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIArrow}	self
				self.setSpriteArrow = function(_sprite)			{ self.__sprite_arrow = _sprite; return self; }
			
				/// @method				getImageArrow()
				/// @description		Gets the image index of the arrow icon for the dropdown
				/// @return				{Real}	The image index of the arrow icon for the dropdown
				self.getImageArrow = function()					{ return self.__image_arrow; }
			
				/// @method				setImageArrow(_image)
				/// @description		Sets the image index of the arrow icon for the dropdown
				/// @param				{Real}	_image	The image index
				/// @return				{UIOptionGroup}	self
				self.setImageArrow = function(_image)			{ self.__image_arrow = _image; return self; }
			
			#endregion
			#region Methods
				self.__draw = function() {
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _pad_left = 10;
					var _pad_right = 10 + (sprite_exists(self.__sprite_arrow) ? sprite_get_width(self.__sprite_arrow) : 0);
					var _pad_top = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
					var _pad_bottom = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
					
					var _sprite = self.__sprite_selected;
					var _image = self.__image_selected;
					var _fmt = self.__text_format_selected;
					var _text = self.__option_array_selected[self.__index];
					var _scale = "[scale,"+string(UI.getScale())+"]";
					var _t = UI_TEXT_RENDERER(_scale+_fmt+_text);						
					var _width = self.__dimensions.width == 0 ? _t.get_width() + _pad_left+_pad_right : self.__dimensions.width;
					var _height = _t.get_height() + _pad_top+_pad_bottom;
					
					if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x, _y, _x + _width, _y + _height)) {
						_sprite =	self.__sprite_mouseover;
						_image =	self.__image_mouseover;
						_fmt =		self.__text_format_mouseover;
						_text =		self.__option_array_mouseover[self.__index];
						_t = UI_TEXT_RENDERER(_scale+_fmt+_text);
					}
					
					if (sprite_exists(_sprite)) draw_sprite_stretched_ext(_sprite, _image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);
						
					var _x = _x + _pad_left;
					var _y = _y + _height * UI.getScale()/2;
					_t.draw(_x, _y);
						
					// Arrow
					var _x = self.__dimensions.x + _width - _pad_right;
					if (sprite_exists(self.__sprite_arrow)) draw_sprite_ext(self.__sprite_arrow, self.__image_arrow, _x, _y - sprite_get_height(self.__sprite_arrow)/2, 1, 1, 0, self.__image_blend, self.__image_alpha);
					
					if (self.__dropdown_active) {  // Draw actual dropdown list
						var _x = self.__dimensions.x;
						var _y = self.__dimensions.y + _height;
						var _n = array_length(self.__option_array_unselected);
						if (sprite_exists(self.__sprite_dropdown)) draw_sprite_stretched_ext(self.__sprite_dropdown, self.__image_dropdown, _x, _y, _width, _height * _n + _pad_bottom, self.__image_blend, self.__image_alpha);
						
						var _cum_h = 0;
						_x += _pad_left;
						for (var _i=0; _i<_n; _i++) {	
							var _fmt = self.__text_format_unselected;
							_t = UI_TEXT_RENDERER(_scale+_fmt+self.__option_array_unselected[_i]);
							if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x, _y + _cum_h, _x + _width, _y + _t.get_height() + _cum_h + self.__spacing)) {
								_fmt =	self.__text_format_mouseover;
								_t = UI_TEXT_RENDERER(_scale+_fmt+self.__option_array_mouseover[_i]);
							}
							_t.draw(_x, _y + _t.get_height() + _cum_h);
							_cum_h += _t.get_height();
							if (_i<_n-1)  _cum_h += self.__spacing;
						}
					}
					
					self.setDimensions(,,_width, self.__dropdown_active ? _height * (_n+1) + _pad_bottom : _height);
					
				}
				//self.__generalBuiltInBehaviors = method(self, __UIWidget.__builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) {
						if (self.__dropdown_active) {
							
							var _pad_left = 10;
							var _pad_right = 10 + (sprite_exists(self.__sprite_arrow) ? sprite_get_width(self.__sprite_arrow) : 0);
							var _pad_top = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
							var _pad_bottom = 5 + (sprite_exists(self.__sprite_arrow) ? sprite_get_height(self.__sprite_arrow)/2 : 0);
							var _scale = "[scale,"+string(UI.getScale())+"]";
							var _x = self.__dimensions.x;
							var _y = self.__dimensions.y + UI_TEXT_RENDERER(self.__option_array_selected[self.__index]).get_height() + _pad_top+_pad_bottom;
							
							var _width = self.__dimensions.width;							
							
							var _clicked = -1;
							var _n=array_length(self.__option_array_unselected);
							var _i=0;
							var _cum_h = 0;
							while (_i<_n && _clicked == -1) {
								_t = UI_TEXT_RENDERER(_scale+self.__option_array_mouseover[_i]);
								if (point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x, _y + _cum_h, _x + _width, _y + _t.get_height() + _cum_h + self.__spacing)) {
									_clicked = _i;
								}
								else {
									_cum_h += _t.get_height();
									if (_i<_n-1)  _cum_h += self.__spacing;
									_i++;
								}
							}
						
							if (_clicked != -1 && _clicked != self.__index)	{
								self.setIndex(_clicked);
							}
							
							self.__dropdown_active = false;
						}
						else {
							self.__dropdown_active = true;
						}						
					}
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			// Do not register since it extends UIOptionGroup and that one already registers
			//self.__register();
			return self;
		}
	
	#endregion
	
	#region UISpinner
	
		/// @constructor	UISpinner(_id, _x, _y, _option_array, _sprite_base, _sprite_arrow_left, _sprite_arrow_right, _width, _height, [_initial_idx=0], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIOptionGroup
		/// @description	A Spinner widget, clickable UI widget that lets the user toggle through a list of values. Extends UIOptionGroup as it provides the same functionality with different interface.
		/// @param			{String}			_id					The Dropdown's name, a unique string ID. If the specified name is taken, the checkbox will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x					The x position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y					The y position of the Dropdown, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Array<String>}		_option_array		An array with at least one string that contains the text for each of the options
		/// @param			{Asset.GMSprite}	_sprite_base		The sprite ID to use for rendering the background of the currently selected value
		/// @param			{Asset.GMSprite}	_sprite_arrow_left	The sprite ID to use for rendering each value within the list of values
		/// @param			{Asset.GMSprite}	_sprite_arrow_right	The sprite ID to use for rendering each value within the list of values
		/// @param			{Asset.GMSprite}	_width				The total width of the control
		/// @param			{Asset.GMSprite}	_height				The total height of the control
		/// @param			{Real}				[_initial_idx]		The initial selected index of the Dropdown list (default=0, the first option)
		/// @param			{Enum}				[_relative_to]		The position relative to which the Dropdown will be drawn. By default, the top left (TOP_LEFT) <br>
		///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIDropdown}							self
		function UISpinner(_id, _x, _y, _option_array, _sprite_base, _sprite_arrow_left, _sprite_arrow_right, _width, _height, _initial_idx=0, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : UIOptionGroup(_id, _x, _y, _option_array, _sprite_base, _initial_idx, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.SPINNER;
				self.setDimensions(_x, _y, _width, _height);				
				self.__control = self.add(new UIGroup(_id+"_SpinnerGroup", _x, _y, _width, _height, -1, _relative_to));
				self.__control.setInheritWidth(true).setInheritHeight(true);				
				self.__grid = self.__control.add(new UIGrid(_id+"_SpinnerGroup_Grid", 1, 3));				
				var _lw = sprite_exists(_sprite_arrow_left) ? sprite_get_width(_sprite_arrow_left)/_width : 0;
				var _rw = sprite_exists(_sprite_arrow_right) ? sprite_get_width(_sprite_arrow_right)/_width : 0;
				var _cw = 1 - _lw - _rw;
				self.__grid.setColumnProportions([_lw, _cw, _rw]);
				self.__button_left = self.__grid.addToCell(new UIButton(_id+"_SpinnerGroup_ButtonLeft", 0, 0, 0, 0, "", _sprite_arrow_left, UI_RELATIVE_TO.TOP_LEFT), 0, 0);
				self.__button_left.setInheritWidth(true);
				self.__button_left.setInheritHeight(true);
				self.__button_right = self.__grid.addToCell(new UIButton(_id+"_SpinnerGroup_ButtonRight", 0, 0, 0, 0, "", _sprite_arrow_right, UI_RELATIVE_TO.TOP_LEFT), 0, 2);
				self.__button_right.setInheritWidth(true);
				self.__button_right.setInheritHeight(true);
				self.__button_text = self.__grid.addToCell(new UIButton(_id+"_SpinnerGroup_Text", 0, 0, 0, 0, "", _sprite_base, UI_RELATIVE_TO.MIDDLE_CENTER), 0, 1);
				self.__button_text.setText(self.getOptionRawText());
				self.__button_text.setTextMouseover(self.getOptionRawText());
				self.__button_text.setTextClick(self.getOptionRawText());
				self.__button_text.setInheritWidth(true);
				self.__button_text.setInheritHeight(true);
				self.__button_left.setCallback(UI_EVENT.LEFT_CLICK, method({spinner: _id, text: self.__button_text.__ID}, function() {
					var _new_index = UI.get(spinner).getIndex()-1;
					if (_new_index == -1) _new_index = array_length(UI.get(spinner).__option_array_unselected)-1;
					UI.get(spinner).setIndex(_new_index);
						
					UI.get(text).setText(UI.get(spinner).getOptionRawText());						
					UI.get(text).setTextMouseover(UI.get(spinner).getOptionRawText());						
					UI.get(text).setTextClick(UI.get(spinner).getOptionRawText());						
				}));
				self.__button_right.setCallback(UI_EVENT.LEFT_CLICK, method({spinner: _id, text: self.__button_text.__ID}, function() {
					var _new_index = (UI.get(spinner).__index + 1) % array_length(UI.get(spinner).__option_array_unselected);
					UI.get(spinner).setIndex(_new_index);
					UI.get(text).setText(UI.get(spinner).getOptionRawText());
					UI.get(text).setTextMouseover(UI.get(spinner).getOptionRawText());
					UI.get(text).setTextClick(UI.get(spinner).getOptionRawText());
				}));				
				
			#endregion
			#region Setters/Getters			
				/// @method				getButtonLeft()
				/// @description		Gets the left button of the Spinner control
				/// @return				{UIButton}	The left button
				self.getButtonLeft = function()				{ return self.__button_left; }
			
				/// @method				getButtonRight()
				/// @description		Gets the right button of the Spinner control
				/// @return				{UIButton}	The right button
				self.getButtonRight = function()				{ return self.__button_right; }
				
				/// @method				getButtonText()
				/// @description		Gets the text button of the Spinner control
				/// @return				{UIButton}	The text button
				self.getButtonText = function()				{ return self.__button_text; }
				
				/// @method				getGrid()
				/// @description		Gets the UIGrid of the Spinner control
				/// @return				{UIGrid}	The grid
				self.getGrid = function()				{ return self.__grid; }
				
			#endregion
			#region Methods
				self.__draw = function() {
					self.setDimensions();				
				}
				//self.__generalBuiltInBehaviors = method(self, __UIWidget.__builtInBehavior);
				self.__builtInBehavior = function() {					
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			// Do not register since it extends UIOptionGroup and that one already registers
			//self.__register();
			return self;
		}
	
	#endregion
	
	#region UIProgressBar
		
		/// @constructor	UIProgressBar(_id, _x, _y, _sprite_base, _sprite_progress, _value, _min_value, _max_value, [_orientation=UI_ORIENTATION.HORIZONTAL], [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A UIProgressBar widget, that allows the user to select a value from a range by dragging, clicking or scrolling
		/// @param			{String}			_id					The UIProgressBar's name, a unique string ID. If the specified name is taken, the UIProgressBar will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x					The x position of the UIProgressBar, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y					The y position of the UIProgressBar, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Asset.GMSprite}	_sprite_base		The sprite ID to use for rendering the UIProgressBar base
		/// @param			{Asset.GMSprite}	_sprite_progress	The sprite ID to use for rendering the UIProgressBar handle
		/// @param			{Real}				_value				The initial value of the UIProgressBar
		/// @param			{Real}				_min_value			The minimum value of the UIProgressBar
		/// @param			{Real}				_max_value			The maximum value of the UIProgressBar
		/// @param			{Enum}				[_orientation]		The orientation of the UIProgressBar, according to UI_ORIENTATION. By default: HORIZONTAL
		/// @param			{Enum}				[_relative_to]		The position relative to which the UIProgressBar will be drawn. By default, the top left (TOP_LEFT) <br>
		///															See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIProgressBar}							self
		function UIProgressBar(_id, _x, _y, _sprite_base, _sprite_progress, _value, _min_value, _max_value, _orientation=UI_ORIENTATION.HORIZONTAL, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, 0, 0, _sprite_base, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.PROGRESSBAR;
				self.__sprite_base = _sprite_base;
				self.__sprite_progress = _sprite_progress;
				self.__sprite_repeat_remaining_progress = noone;
				self.__image_repeat_remaining_progress = 0;
				self.__image_base = 0;
				self.__image_progress = 0;
				self.__sprite_progress_anchor = {x: 0, y: 0};
				self.__text_value_anchor = {x: 0, y: 0};
				self.__value = _value;
				self.__min_value = _min_value;
				self.__max_value = _max_value;
				self.__show_value = false;
				self.__prefix = "";
				self.__suffix = "";
				self.__text_format = "";
				self.__render_progress_behavior = UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL;
				self.__progress_repeat_unit = 1;
				self.__orientation = _orientation;
			#endregion
			#region Setters/Getters				
				/// @method				getSpriteBase()
				/// @description		Gets the sprite ID used for the base of the progressbar, that will be drawn behind
				/// @return				{Asset.GMSprite}	The sprite ID used for the base of the progressbar.
				self.getSpriteBase = function()							{ return self.__sprite_base; }
			
				/// @method				setSpriteBase(_sprite)
				/// @description		Sets the sprite to be used for the base of the progessbar, that will be drawn behind 
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIProgressBar}	self
				self.setSpriteBase = function(_sprite)					{ self.__sprite_base = _sprite; return self; }
			
				/// @method				getImageBase()
				/// @description		Gets the image index of the sprite used for the base of the progressbar, that will be drawn behind
				/// @return				{Real}	The image index of the sprite used for the base of the progressbar
				self.getImageBase = function()							{ return self.__image_base; }
			
				/// @method				setImageBase(_image)
				/// @description		Sets the image index of the sprite used for the base of the progressbar, that will be drawn behind
				/// @param				{Real}	_image	The image index
				/// @return				{UIProgressbar}	self
				self.setImageBase = function(_image)					{ self.__image_base = _image; return self; }				
				
				/// @method				getSpriteProgress()
				/// @description		Gets the sprite ID used for rendering progress.
				/// @return				{Asset.GMSprite}	The sprite ID used for rendering progress.
				self.getSpriteProgress = function()						{ return self.__sprite_progress; }
			
				/// @method				setSpriteProgress(_sprite)
				/// @description		Sets the sprite to be used for rendering progress.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIProgressbar}	self
				self.setSpriteProgress = function(_sprite)				{ self.__sprite_progress = _sprite; return self; }
				
				/// @method				getSpriteRemainingProgress()
				/// @description		Gets the sprite ID used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
				/// @return				{Asset.GMSprite}	The sprite ID used for rendering the remaining progress.
				self.getSpriteRemainingProgress = function()						{ return self.__sprite_repeat_remaining_progress; }
			
				/// @method				setSpriteRemainingProgress(_sprite)
				/// @description		Sets the sprite to be used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIProgressbar}	self
				self.setSpriteRemainingProgress = function(_sprite)				{ self.__sprite_repeat_remaining_progress = _sprite; return self; }
			
				/// @method				getImageProgress()
				/// @description		Gets the image index of the sprite used for rendering progress.
				/// @return				{Real}	The image index of the sprite used for rendering progress
				self.getImageProgress = function()						{ return self.__image_progress; }
			
				/// @method				setImageProgress(_image)
				/// @description		Sets the image index of the sprite used for rendering progress.
				/// @param				{Real}	_image	The image index
				/// @return				{UIProgressbar}	self
				self.setImageProgress = function(_image)					{ self.__image_progress = _image; return self; }		

				/// @method				getImageRemainingProgress()
				/// @description		Gets the image index of the sprite used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
				/// @return				{Real}	The image index of the sprite used for rendering remaining progress
				self.getImageRemainingProgress = function()						{ return self.__image_repeat_remaining_progress; }
			
				/// @method				setImageRemainingProgress(_image)
				/// @description		Sets the image index of the sprite used for rendering remaining progress, when using the REPEAT rendering behavior for the progressbar.
				/// @param				{Real}	_image	The image index
				/// @return				{UIProgressbar}	self
				self.setImageRemainingProgress = function(_image)					{ self.__image_repeat_remaining_progress = _image; return self; }		
												
				/// @method				getValue()
				/// @description		Gets the value of the progressbar, either via the defined binding or, if undefined, the defined value.<br>
				///						If the value of the defined binding is not boolean, it will return the fixed value set by `setValue` instead.
				/// @return				{Real}	the value of the progressbar
				self.getValue = function()	{
					var _val = self.__updateBinding();
					if (is_undefined(_val))	return self.__value;
					else if (is_method(_val))	{
						var _actual_value = _val();
						if (is_real(_actual_value)) return _actual_value;
						else {
							UI.__logMessage("Bound value is not numeric for progressbar '"+self.__ID+"', returning fixed value set by setValue() instead", UI_MESSAGE_LEVEL.WARNING);
							return self.__value;
						}
					}
					else {
						if (is_real(_val)) return _val;
						else {
							UI.__logMessage("Bound value is not numeric for progressbar '"+self.__ID+"', returning fixed value set by setValue() instead", UI_MESSAGE_LEVEL.WARNING);
							return self.__value;
						}
					}					
				}
				
				/// @method				setValue(_value)
				/// @description		Sets the value of the progressbar
				/// @param				{Real}	_value	the value to set for the progressbar
				/// @return				{UIProgressbar}	self
				self.setValue = function(_value) { 
					var _old = self.__value;
					var _new = clamp(_value, self.__min_value, self.__max_value);
					var _changed = (_old != _new);
					if (_changed) {
						self.__value = _new;
						self.__callbacks[UI_EVENT.VALUE_CHANGED](_old, _new);
					}					
					return self;
				}
				
				/// @method				getMinValue()
				/// @description		Gets the minimum value of the progressbar
				/// @return				{Real}	the minimum value of the progressbar
				self.getMinValue = function()							{ return self.__min_value; }
				
				/// @method				setMinValue(_min_value)
				/// @description		Sets the minimum value of the progressbar
				/// @param				{Real}	_min_value	the value to set
				/// @return				{UIProgressbar}	self
				self.setMinValue = function(_min_value)					{ self.__min_value = _min_value; return self; }
				
				/// @method				getMaxValue()
				/// @description		Gets the maximum value of the progressbar
				/// @return				{Real}	the maximum value of the progressbar
				self.getMaxValue = function()							{ return self.__max_value; }
				
				/// @method				setMaxValue(_max_value)
				/// @description		Sets the maximum value of the progressbar
				/// @param				{Real}	_max_value	the value to set
				/// @return				{UIProgressbar}	self
				self.setMaxValue = function(_max_value)					{ self.__max_value = _max_value; return self; }
				
				/// @method				getOrientation()
				/// @description		Gets the orientation of the progressbar according to UI_ORIENTATION. Note that VERTICAL orientation will be rendered bottom-up and not top-down.
				/// @return				{Enum}	the orientation of the progressbar
				self.getOrientation = function()						{ return self.__orientation; }
				
				/// @method				setOrientation(_orientation)
				/// @description		Sets the orientation of the progressbar. Note that VERTICAL orientation will be rendered bottom-up and not top-down.
				/// @param				{Enum}	_orientation	the orientation according to UI_ORIENTATION
				/// @return				{UIProgressbar}	self
				self.setOrientation = function(_orientation)			{ self.__orientation = _orientation; return self; }
				
				/// @method				getShowValue()
				/// @description		Gets whether the progressbar renders text for the value
				/// @return				{Bool}	whether the progressbar renders renders text for the value
				self.getShowValue = function()						{ return self.__show_value; }
				
				/// @method				setShowValue(_show_value)
				/// @description		Sets whether the progressbar renders text for the value
				/// @param				{Bool}	_value	whether the progressbar renders text for the value
				/// @return				{UIProgressbar}	self
				self.setShowValue = function(_show_value)				{ self.__show_value = _show_value; return self; }
				
				/// @method				getTextFormat()
				/// @description		Gets the text format for the progressbar text
				/// @return				{String}	the Scribble text format used for the progressbar text
				self.getTextFormat = function()							{ return self.__text_format; }
				
				/// @method				setTextFormat(_format)
				/// @description		Sets the text format for the progressbar text
				/// @param				{String}	_format	the Scribble text format used for the progressbar text
				/// @return				{UIProgressbar}	self
				self.setTextFormat = function(_format)					{ self.__text_format = _format; return self; }
				
				/// @method				getPrefix()
				/// @description		Gets the prefix for the progressbar text
				/// @return				{String}	the Scribble prefix used for the progressbar text
				self.getPrefix = function()							{ return self.__prefix; }
				
				/// @method				setPrefix(_prefix)
				/// @description		Sets the prefix for the progressbar text
				/// @param				{String}	_prefix	the Scribble prefix used for the progressbar text
				/// @return				{UIProgressbar}	self
				self.setPrefix = function(_prefix)					{ self.__prefix = _prefix; return self; }
				
				/// @method				getSuffix()
				/// @description		Gets the suffix for the progressbar text
				/// @return				{String}	the Scribble suffix used for the progressbar text
				self.getSuffix = function()							{ return self.__suffix; }
				
				/// @method				setSuffix(_suffix)
				/// @description		Sets the suffix for the progressbar text
				/// @param				{String}	_suffix	the Scribble suffix used for the progressbar text
				/// @return				{UIProgressbar}	self
				self.setSuffix = function(_suffix)					{ self.__suffix = _suffix; return self; }
				
				/// @method				getRenderProgressBehavior()
				/// @description		Gets the render behavior of the progress bar, according to UI_PROGRESSBAR_RENDER_BEHAVIOR.<br>
				///						If set to REVEAL, the progressbar will be rendered by drawing X% of the progress sprite, where X is the percentage that
				///						the progressbar current value represents from the range (max-min) of the progressbar.<br>
				///						If set to STRETCH, the progress sprite will be streched to the amount of pixels representing X% of the width of the sprite.<br>
				///						If set to REPEAT, the progressbar will be rendered by repeating the progress sprite as many times as needed
				///						to reach the progressbar value, where each repetition represents X units, according to the `progress_repeat_unit` parameter.<br>
				/// @return				{Bool}	The image index of the sprite used for the base of the progressbar
				self.getRenderProgressBehavior = function()							{ return self.__render_progress_behavior; }
			
				/// @method				setRenderProgressBehavior(_progress_behavior)
				/// @description		Sets the render behavior of the progress bar, according to UI_PROGRESSBAR_RENDER_BEHAVIOR.<br>
				///						If set to REVEAL, the progressbar will be rendered by drawing X% of the progress sprite, where X is the percentage that
				///						the progressbar current value represents from the range (max-min) of the progressbar.<br>
				///						If set to STRETCH, the progress sprite will be streched to the amount of pixels representing X% of the width of the sprite.<br>
				///						If set to REPEAT, the progressbar will be rendered by repeating the progress sprite as many times as needed
				///						to reach the progressbar value, where each repetition represents X units, according to the `progress_repeat_unit` parameter.<br>
				/// @param				{Enum}	_progress_behavior	The desired rendering behavior of the progressbar
				/// @return				{UIProgressbar}	self
				self.setRenderProgressBehavior = function(_progress_behavior)					{ self.__render_progress_behavior = _progress_behavior; return self; }
				
				/// @method				getProgressRepeatUnit()
				/// @description		Gets the value that each repeated progress sprite occurrence represents.<br>
				///						For example, if the value of the progressbar is 17 and the progress repeat units are 5, this widget will repeat the progress sprite three `(= floor(17/5))` times
				///						(provided the render mode is set to REPEAT using `setRenderProgressBehavior`).
				/// @return				{Real}	The value that each marking represents within the progress bar
				self.getProgressRepeatUnit = function()							{ return self.__progress_repeat_unit; }
			
				/// @method				setProgressRepeatUnit(_progress_repeat_unit)
				/// @description		Sets the value that each repeated progress sprite occurrence represents.<br>
				///						For example, if the value of the progressbar is 17 and the progress repeat units are 5, this widget will repeat the progress sprite three (floor(17/5)) times
				///						(provided the render mode is set to progress repeat using `setRenderProgressRepeat`).				
				/// @param				{Real}	_progress_repeat_unit	The value that each marking represents within the progress bar
				/// @return				{UIProgressbar}	self
				self.setProgressRepeatUnit = function(_progress_repeat_unit)					{ self.__progress_repeat_unit = _progress_repeat_unit; return self; }
				
				/// @method				getSpriteProgressAnchor()
				/// @description		Gets the {x,y} anchor point where the progress sprite will be drawn over the back sprite. Note these coordinates are relative to their parent's origin and not screen coordinates
				///						(i.e. the same way an (x,y) coordinate for a Widget would be specified when adding it to a Panel)
				///						NOTE: The anchor point will be where the **top left** point of the progress sprite will be drawn, irrespective of its xoffset and yoffset.
				/// @return				{Struct}	a struct with `x` and `y` values representing the anchor points
				self.getSpriteProgressAnchor = function()						{ return self.__sprite_progress_anchor; }
				
				/// @method				setSpriteProgressAnchor(_anchor_struct)
				/// @description		Sets the {x,y} anchor point where the progress sprite will be drawn over the back sprite. Note these coordinates are relative to their parent's origin and not screen coordinates
				///						(i.e. the same way an (x,y) coordinate for a Widget would be specified when adding it to a Panel).
				///						NOTE: The anchor point will be where the **top left** point of the progress sprite will be drawn, irrespective of its xoffset and yoffset.
				/// @param				{Struct}	_anchor_struct	a struct with `x` and `y` values representing the anchor points
				/// @return				{UIProgressbar}	self
				self.setSpriteProgressAnchor = function(_anchor_struct)			{ self.__sprite_progress_anchor = _anchor_struct; return self; }
				
				/// @method				getTextValueAnchor()
				/// @description		Gets the {x,y} anchor point where the text value of the progressbar will be rendered, relative to the (x,y) of the progress bar itself
				/// @return				{Struct}	a struct with `x` and `y` values representing the anchor points
				self.getTextValueAnchor = function()						{ return self.__text_value_anchor; }
				
				/// @method				setTextValueAnchor(_anchor_struct)
				/// @description		Sets the {x,y} anchor point where the text value of the progressbar will be rendered, relative to the (x,y) of the progress bar itself
				/// @param				{Struct}	_anchor_struct	a struct with `x` and `y` values representing the anchor points
				/// @return				{UIProgressbar}	self
				self.setTextValueAnchor = function(_anchor_struct)			{ self.__text_value_anchor = _anchor_struct; return self; }
			#endregion
			#region Methods
				
				self.__draw = function() {
										
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					
					var _proportion = clamp((self.getValue() - self.__min_value)/(self.__max_value - self.__min_value), 0, 1);
					
					var _width_base =  sprite_exists(self.__sprite_base) ? sprite_get_width(self.__sprite_base) : 0;
					var _height_base = sprite_exists(self.__sprite_base) ? sprite_get_height(self.__sprite_base) : 0;
					if (sprite_exists(self.__sprite_base)) draw_sprite_ext(self.__sprite_base, self.__image_base, _x, _y, UI.getScale(), UI.getScale(), 0, self.__image_blend, self.__image_alpha);
					
					if (self.__orientation == UI_ORIENTATION.HORIZONTAL) {
						switch (self.__render_progress_behavior) {
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL:
								var _width_progress =  sprite_exists(self.__sprite_progress) ? sprite_get_width(self.__sprite_progress) : 0;
								var _height_progress = sprite_exists(self.__sprite_progress) ? sprite_get_height(self.__sprite_progress) : 0;
								if (sprite_exists(self.__sprite_progress)) draw_sprite_part_ext(self.__sprite_progress, self.__sprite_progress, 0, 0, _width_progress * _proportion, _height_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, self.__dimensions.y + self.__sprite_progress_anchor.y, UI.getScale(), UI.getScale(), self.__image_blend, self.__image_alpha);
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REPEAT:
								var _times = floor(self.getValue() / self.__progress_repeat_unit);
								var _max_times = floor(self.__max_value / self.__progress_repeat_unit);
								var _w1 = sprite_exists(self.__sprite_progress) ? sprite_get_width(self.__sprite_progress) : 0;
								for (var _i=0; _i<_times; _i++) {
									if (sprite_exists(self.__sprite_progress)) draw_sprite_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x + _i*_w1, self.__dimensions.y + self.__sprite_progress_anchor.y, UI.getScale(), UI.getScale(), 0, self.__image_blend, self.__image_alpha);
								}
								var _w2 = sprite_exists(self.__sprite_repeat_remaining_progress) ? sprite_get_width(self.__sprite_repeat_remaining_progress) : 0;
								for (var _i=_times; _i<_max_times; _i++) {
									if (sprite_exists(self.__sprite_repeat_remaining_progress)) draw_sprite_ext(self.__sprite_repeat_remaining_progress, self.__image_repeat_remaining_progress, self.__dimensions.x + self.__sprite_progress_anchor.x + _i*_w2, self.__dimensions.y + self.__sprite_progress_anchor.y, UI.getScale(), UI.getScale(), 0, self.__image_blend, self.__image_alpha);
								}
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH:
								var _width_progress =  sprite_exists(self.__sprite_progress) ? sprite_get_width(self.__sprite_progress) : 0;
								var _height_progress = sprite_exists(self.__sprite_progress) ? sprite_get_height(self.__sprite_progress) : 0;
								if (sprite_exists(self.__sprite_progress)) draw_sprite_stretched_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, self.__dimensions.y + self.__sprite_progress_anchor.y, _proportion * _width_progress, _height_progress, self.__image_blend, self.__image_alpha);
								break;
						}
					}
					else {
						switch (self.__render_progress_behavior) {
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REVEAL:
								var _width_progress =  sprite_exists(self.__sprite_progress) ? sprite_get_width(self.__sprite_progress) : 0;
								var _height_progress = sprite_exists(self.__sprite_progress) ? sprite_get_height(self.__sprite_progress) : 0;
								_y = self.__dimensions.y + self.__sprite_progress_anchor.y - _height_progress * _proportion;
								if (sprite_exists(self.__sprite_progress)) draw_sprite_part_ext(self.__sprite_progress, self.__image_progress, 0, _height_progress * (1-_proportion), _width_progress, _height_progress * _proportion, self.__dimensions.x + self.__sprite_progress_anchor.x, _y, UI.getScale(), UI.getScale(), self.__image_blend, self.__image_alpha);
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.REPEAT:
								var _times = floor(self.getValue() / self.__progress_repeat_unit);
								var _h = sprite_exists(self.__sprite_progress) ? sprite_get_height(self.__sprite_progress) : 0;
								for (var _i=0; _i<_times; _i++) {
									if (sprite_exists(self.__sprite_progress)) draw_sprite_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, self.__dimensions.y + self.__sprite_progress_anchor.y - _i * _h, UI.getScale(), UI.getScale(), 0, self.__image_blend, self.__image_alpha);
								}
								break;
							case UI_PROGRESSBAR_RENDER_BEHAVIOR.STRETCH:
								var _width_progress =  sprite_exists(self.__sprite_progress) ? sprite_get_width(self.__sprite_progress) : 0;
								var _height_progress = sprite_exists(self.__sprite_progress) ? sprite_get_height(self.__sprite_progress) : 0;
								_y = self.__dimensions.y + self.__sprite_progress_anchor.y - _height_progress * _proportion;
								if (sprite_exists(self.__sprite_progress)) draw_sprite_stretched_ext(self.__sprite_progress, self.__image_progress, self.__dimensions.x + self.__sprite_progress_anchor.x, _y, _width_progress, _height_progress * _proportion, self.__image_blend, self.__image_alpha);
								break;
						}
					}
					
					self.setDimensions(,, _width_base, _height_base);
					
					if (self.__show_value) {
						UI_TEXT_RENDERER(self.__text_format+self.__prefix+string(self.getValue())+self.__suffix).draw(self.__dimensions.x + self.__text_value_anchor.x, self.__dimensions.y + self.__text_value_anchor.y);
					}
										
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);					
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UICanvas
	
		/// @constructor	UICanvas(_id, _x, _y, _width, _height, _surface, [_relative_to=UI_RELATIVE_TO.TOP_LEFT])
		/// @extends		UIWidget
		/// @description	A Canvas widget, which lets you draw a custom drawn surface on a Panel. The surface will be streched to the values of `width` and `height`.<br>
		///					*WARNING: destroying the Canvas widget will NOT free the surface, you need to do that yourself to avoid a memory leak*<br>
		///					*WARNING: the widget itself does not handle recreating the surface if it's automatically destroyed by the target platform. You need to do that yourself.
		/// @param			{String}			_id				The Canvas's name, a unique string ID. If the specified name is taken, the Canvas will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x				The x position of the Canvas, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y				The y position of the Canvas, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{Real}				_width			The width of the Canvas, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{Real}				_height			The height of the Canvas, **relative to its parent**, according to the _relative_to parameter		
		/// @param			{String}			_surface		The surface ID to draw
		/// @param			{Enum}				[_relative_to]	The position relative to which the Canvas will be drawn. By default, the top left (TOP_LEFT) <br>
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UICanvas}							self
		function UICanvas(_id, _x, _y, _width, _height, _surface, _relative_to=UI_RELATIVE_TO.TOP_LEFT) : __UIWidget(_id, _x, _y, _width, _height, -1, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.CANVAS;
				self.__surface_id = _surface;				
			#endregion
			#region Setters/Getters
				
				/// @method				getSurface()
				/// @description		Gets the id of the surface bound to the Canvas
				///	@return				{Asset.GMSurface}	the surface id
				self.getSurface = function()				{ return self.__surface_id; }
			
				/// @method				setSurface(_surface)
				/// @description		Sets the surface bound to the Canvas
				/// @param				{Asset.GMSurface}	_surface	The surface id
				/// @return				{UICanvas}	self
				self.setSurface = function(_color)			{ self.__background_color = _color; return self; }
			
			#endregion
			#region Methods
				self.__draw = function() {
					if (surface_exists(self.__surface_id)) {						
						draw_surface_stretched_ext(self.__surface_id, self.__dimensions.x, self.__dimensions.y, self.__dimensions.width * UI.getScale(), self.__dimensions.height * UI.getScale(), self.__image_blend, self.__image_alpha);
					}
					else {
						UI.__logMessage("Surface bound to Canvas widget '"+self.__ID+"' does not exist.", UI_MESSAGE_LEVEL.WARNING);
					}
				}
				self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					var _arr = array_create(GOOEY_NUM_CALLBACKS, true);
					self.__generalBuiltInBehaviors(_arr);
				}
			#endregion
		
			self.__register();
			return self;
		}
	
	#endregion

	#region UISprite
	
		/// @constructor	UISprite(_id, _x, _y, _width, _height, _sprite, [_starting_frame=0], [_relative_to=UI_RELATIVE_TO.TOP_LEFT], [_time_source_parent=time_source_global])
		/// @extends		UIWidget
		/// @description	A Sprite widget to draw a sprite onto
		/// @param			{String}			_id						The Sprite's name, a unique string ID. If the specified name is taken, the Sprite will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_x						The x position of the Sprite, **relative to its parent**, according to the _relative_to parameter
		/// @param			{Real}				_y						The y position of the Sprite, **relative to its parent**, according to the _relative_to parameter	
		/// @param			{Asset.GMSprite}	_sprite					The sprite ID to use for rendering the Sprite
		/// @param			{Real}				[_width]				The width of the Sprite (by default, the original width) 
		/// @param			{Real}				[_height]				The height of the Sprite (by default, the original height)
		/// @param			{Real}				[_starting_frame]		The starting frame index (by default 0)
		/// @param			{Enum}				[_relative_to]			The position relative to which the Sprite will be drawn. By default, the top left (TOP_LEFT) <br>
		///																See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @param			{Real}				[_time_source_parent]	The parent of the time source used to animate the sprite (by default, time_source_global)
		/// @return			{UISprite}									self
		function UISprite(_id, _x, _y, _sprite, _width=0, _height=0, _starting_frame=0, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _time_source_parent=time_source_global) : __UIWidget(_id, _x, _y, _width, _height, _sprite, _relative_to) constructor {
			#region Private variables
				self.__type = UI_TYPE.SPRITE;	
				self.__starting_frame = _starting_frame;
				self.__image = _starting_frame;
				self.__animation_step = 1;
				self.__animation_speed = sprite_get_speed(_sprite);
				self.__animation_length = sprite_get_number(_sprite);
				self.__time_source = noone;
				self.__time_source_parent = _time_source_parent;
				self.__num_frames = 0;
			#endregion
			#region Setters/Getters
			
				/// @method				getAnimationStep()
				/// @description		Gets the number of frames advanced each animation time
				///	@return				{Real}	the number of frames advanced each time
				self.getAnimationStep = function()				{ return self.__animation_step; }
			
				/// @method				setAnimationStep(_step)
				/// @description		Sets the number of frames advanced each animation time
				/// @param				{Real}	_step	the number of frames advanced each time
				/// @return				{UISprite}	self
				self.setAnimationStep = function(_step)			{ self.__animation_step = _step; return self; }
				
				/// @method				getAnimationSpeed()
				/// @description		Gets the animation speed of the sprite (as handled by the UI library).
				///	@return				{Real}	the animation speed
				self.getAnimationSpeed = function()				{ return self.__animation_speed; }
			
				/// @method				setAnimationSpeed(_speed, [_units = time_source_units_frames], [_start=true])
				/// @description		Sets the animation speed of the sprite (as handled by the UI library). This will NOT modify the actual sprite speed (e.g. by using `sprite_set_speed`).
				/// @param				{Real}	_speed	the animation speed
				/// @param				{Real}	[_units] the animation units (by default, frames), according to the time_source_units_* constants
				/// @param				{Bool}	[_start] whether to automatically start the animation (by default, true)
				/// @return				{UISprite}	self
				self.setAnimationSpeed = function(_speed, _units = time_source_units_frames, _start=true) {
					self.__animation_speed = _speed;
					if (_speed > 0)	{
						if (time_source_exists(self.__time_source))	time_source_destroy(self.__time_source);
						self.__time_source = time_source_create(self.__time_source_parent, self.__animation_speed, _units, function() {							
							self.__image += self.__animation_step;
							if (self.__image < 0)	self.__image = sprite_get_number(self.__sprite) + self.__image;
							else if (self.__image > sprite_get_number(self.__sprite))	self.__image = self.__image % sprite_get_number(self.__sprite);							
							self.__num_frames++;
							if (self.__num_frames == self.__animation_length) {
								self.__image = self.__starting_frame;
								self.__num_frames = 0;
							}
						}, [], -1);						
						if (_start)	time_source_start(self.__time_source);
					}
					return self;
				}
				
				/// @method				getAnimationLength()
				/// @description		Gets the number of frames to consider in the animation
				///	@return				{Real}	the number of frames to consider
				self.getAnimationLength = function()				{ return self.__animation_length; }
			
				/// @method				setAnimationLength(_length)
				/// @description		Sets the number of frames to consider in the animation
				/// @param				{Real}	_length	the number of frames to consider
				/// @return				{UISprite}	self
				self.setAnimationLength = function(_length)			{ self.__animation_length = _length; return self; }
				
			#endregion
			#region Methods
				
				/// @method				animationStart()
				/// @description		Starts the animation of the sprite				
				/// @return				{UISprite}	self
				self.animationStart = function() {
					if (time_source_get_state(self.__time_source) != time_source_state_active) time_source_start(self.__time_source);					
					return self;
				}
				
				/// @method				animationPause()
				/// @description		Pauses the animation of the sprite				
				/// @return				{UISprite}	self
				self.animationPause = function() {
					if (time_source_get_state(self.__time_source) == time_source_state_active) time_source_pause(self.__time_source);					
					return self;
				}
				
				/// @method				animationRestart()
				/// @description		Restarts the animation of the sprite				
				/// @return				{UISprite}	self
				self.animationRestart = function() {
					self.__image = self.__starting_frame;
					self.setAnimationSpeed(self.__animation_speed);
					return self;
				}
				
				self.__draw = function() {
					if (self.__dimensions.width == 0) {
						self.setDimensions(,, sprite_exists(self.__sprite) ? sprite_get_width(self.__sprite) : 0);
					}
					if (self.__dimensions.height == 0) {
						self.setDimensions(,,, sprite_exists(self.__sprite) ? sprite_get_height(self.__sprite) : 0);
					}
					var _x = self.__dimensions.x;
					var _y = self.__dimensions.y;
					var _width = self.__dimensions.width * UI.getScale();
					var _height = self.__dimensions.height * UI.getScale();
					if (sprite_exists(self.__sprite)) draw_sprite_stretched_ext(self.__sprite, self.__image, _x, _y, _width, _height, self.__image_blend, self.__image_alpha);				
				}
				/*self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();				
				}*/
				
				self.__parent_destroy = method(self, destroy);
				self.destroy = function() {
					if (time_source_exists(self.__time_source))	time_source_destroy(self.__time_source);
					self.__parent_destroy();
				}
			#endregion
			
			// Start animation
			self.setAnimationSpeed(self.__animation_speed);
			
			self.__register();
			return self;
		}
	
	#endregion
	
	#region UIGrid
	
		/// @constructor	UIGrid(_id, _width, _height, _rows, _cols)
		/// @extends		UIWidget
		/// @description	A Grid widget, that enables adding other widgets to a Panel on a specific row/col
		/// @param			{String}			_id				The Grid's name, a unique string ID. If the specified name is taken, the Group will be renamed and a message will be displayed on the output log.
		/// @param			{Real}				_rows			The number of rows of the Grid
		/// @param			{Real}				_columns		Ths number of columns of the Grid
		///														See the [UIWidget](#UIWidget) documentation for more info and valid values.
		/// @return			{UIGroup}							self
		function UIGrid(_id, _rows, _columns) : __UIWidget(_id, 0, 0, 0, 0, noone, UI_RELATIVE_TO.TOP_LEFT) constructor {
			#region Private variables
				self.__type = UI_TYPE.GRID;	
				self.__rows = _rows;
				self.__columns = _columns;
				self.__margin_top = 0;
				self.__margin_bottom = 0;
				self.__margin_left = 0;
				self.__margin_right = 0;
				self.__spacing_horizontal = 0;				
				self.__spacing_vertical = 0;				
				self.__row_proportions = [];
				self.__column_proportions = [];
				self.__show_grid_overlay = false;							
			#endregion
			#region Setters/Getters
				/// @method				getRows()
				/// @description		Gets the number of rows of the grid
				///	@return				{Real}	the number of rows of the grid
				self.getRows = function()				{ return self.__rows; }
			
				/// @method				getColumns()
				/// @description		Gets the number of columns of the grid
				///	@return				{Real}	the number of columns of the grid
				self.getColumns = function()				{ return self.__columns; }
			
				/// @method				getMarginTop()
				/// @description		Gets the top margin amount in pixels of the grid with respect to the container's borders
				///	@return				{Real}	the margin in px
				self.getMarginTop = function()				{ return self.__margin_top; }
			
				/// @method				setMarginTop(_margin)
				/// @description		Sets the top margin amount in pixels of the grid with respect to the container's borders
				/// @param				{Real}	_margin		the desired margin
				/// @return				{UIGrid}	self
				self.setMarginTop = function(_margin)	{ 
					self.__margin_top = _margin; 
					self.__updateGridDimensions();
					return self; 
				}
				
				/// @method				getMarginBottom()
				/// @description		Gets the bottom margin amount in pixels of the grid with respect to the container's borders
				///	@return				{Real}	the margin in px
				self.getMarginBottom = function()				{ return self.__margin_bottom; }
			
				/// @method				setMarginBottom(_margin)
				/// @description		Sets the bottom margin amount in pixels of the grid with respect to the container's borders
				/// @param				{Real}	_margin		the desired margin
				/// @return				{UIGrid}	self
				self.setMarginBottom = function(_margin)	{ 
					self.__margin_bottom = _margin; 
					self.__updateGridDimensions();
					return self; 
				}
				
				/// @method				getMarginLeft()
				/// @description		Gets the left margin amount in pixels of the grid with respect to the container's borders
				///	@return				{Real}	the margin in px
				self.getMarginLeft = function()				{ return self.__margin_left; }
			
				/// @method				setMarginLeft(_margin)
				/// @description		Sets the left margin amount in pixels of the grid with respect to the container's borders
				/// @param				{Real}	_margin		the desired margin
				/// @return				{UIGrid}	self
				self.setMarginLeft = function(_margin)	{ 
					self.__margin_left = _margin; 
					self.__updateGridDimensions();
					return self; 
				}
				
				/// @method				getMarginRight()
				/// @description		Gets the right margin amount in pixels of the grid with respect to the container's borders
				///	@return				{Real}	the margin in px
				self.getMarginRight = function()				{ return self.__margin_right; }
			
				/// @method				setMarginRight(_margin)
				/// @description		Sets the right margin amount in pixels of the grid with respect to the container's borders
				/// @param				{Real}	_margin		the desired margin
				/// @return				{UIGrid}	self
				self.setMarginRight = function(_margin)	{ 
					self.__margin_right = _margin; 
					self.__updateGridDimensions();
					return self; 
				}
				
				/// @method				setMargins(_margin)
				/// @description		Sets all margins to the same amount in pixels of the grid with respect to the container's borders
				/// @param				{Real}	_margin		the desired margin
				/// @return				{UIGrid}	self
				self.setMargins = function(_margin)	{ 
					self.__margin_top = _margin; 
					self.__margin_bottom = _margin; 
					self.__margin_left = _margin; 
					self.__margin_right = _margin; 
					self.__updateGridDimensions();
					return self; 
				}
				
				
				/// @method				getSpacingHorizontal()
				/// @description		Gets the horizontal spacing in pixels between cells of the grid
				///	@return				{Real}	the spacing in px
				self.getSpacingHorizontal = function()				{ return self.__spacing_horizontal; }
			
				/// @method				setSpacingHorizontal(_spacing)
				/// @description		Sets the horizontal spacing in pixels between cells of the grid
				/// @param				{Real}	_spacing		the desired spacing
				/// @return				{UIGrid}	self
				self.setSpacingHorizontal = function(_spacing) {
					self.__spacing_horizontal = _spacing; 
					self.__updateGridDimensions();
					return self;
				}
				
				
				/// @method				getSpacingVertical()
				/// @description		Gets the vertical spacing in pixels between cells of the grid
				///	@return				{Real}	the spacing in px
				self.getSpacingVertical = function()				{ return self.__spacing_vertical; }
			
				/// @method				setSpacingVertical(_spacing)
				/// @description		Sets the vertical spacing in pixels between cells of the grid
				/// @param				{Real}	_spacing		the desired spacing
				/// @return				{UIGrid}	self
				self.setSpacingVertical = function(_spacing) {
					self.__spacing_vertical = _spacing; 
					self.__updateGridDimensions();
					return self;
				}
				
				/// @method				setSpacings(_spacing)
				/// @description		Sets both horizontal and vertical spacings to the same amount in pixels between cells of the grid
				/// @param				{Real}	_spacing		the desired spacing
				/// @return				{UIGrid}	self
				self.setSpacings = function(_spacing) {
					self.__spacing_horizontal = _spacing; 
					self.__spacing_vertical = _spacing; 
					self.__updateGridDimensions();
					return self;
				}
				
				
				/// @method				getRowProportions()
				/// @description		Gets an array with the percent proportions of each row's height with respect to the usable area of the grid.<br>
				///						The usable area of the grid is the container's size minus the margin and spacing.
				///	@return				{Real}	the row proportions
				self.getRowProportions = function()				{ return self.__row_proportions; }
			
				/// @method				setRowProportions(_row_proportions)
				/// @description		Sets an array with the percent proportions of each row's height with respect to the usable area of the grid.<br>
				///						The usable area of the grid is the container's size minus the margin and spacing.
				/// @param				{Array<Real>}	_row_proportions		the desired row proportions
				/// @return				{UIGrid}	self
				self.setRowProportions = function(_row_proportions) { 
					self.__row_proportions = _row_proportions; 
					self.__updateGridDimensions();
					return self;
				}
				
				/// @method				getColumnProportions()
				/// @description		Gets an array with the percent proportions of each column's width with respect to the usable area of the grid.<br>
				///						The usable area of the grid is the container's size minus the margin and spacing.
				///	@return				{Real}	the column proportions
				self.getColumnProportions = function()				{ return self.__column_proportions; }
			
				/// @method				setColumnProportions(_column_proportions)
				/// @description		Sets an array with the percent proportions of each column's width with respect to the usable area of the grid.<br>
				///						The usable area of the grid is the container's size minus the margin and spacing.
				/// @param				{Array<Real>}	_column_proportions		the desired column proportions
				/// @return				{UIGrid}	self
				self.setColumnProportions = function(_column_proportions) {
					self.__column_proportions = _column_proportions; 
					self.__updateGridDimensions();
					return self;
				}
				
				/// @method				resetRowProportions()
				/// @description		Resets the row proportions to the default (equal, uniform proportions for each row's height)
				/// @return				{UIGrid}	self
				self.resetRowProportions = function(_update = true)	{
					self.__row_proportions = [];
					for (var _row=0; _row<self.__rows; _row++)	array_push(self.__row_proportions, 1/self.__rows);
					if (_update) self.__updateGridDimensions();
					return self;
				}
				
				/// @method				resetColumnProportions()
				/// @description		Resets the column proportions to the default (equal, uniform proportions for each column's width)
				/// @return				{UIGrid}	self
				self.resetColumnProportions = function(_update = true)	{
					self.__column_proportions = [];
					for (var _col=0; _col<self.__columns; _col++)	array_push(self.__column_proportions, 1/self.__columns);
					if (_update) self.__updateGridDimensions();
					return self;
				}
				
				/// @method				getCell(_row, _col) 
				/// @description		Gets the UIGroup widget corresponding to the specified row, column coordinate of the UIGrid
				///	@return				{UIGroup}	a UIGroup widget
				self.getCell = function(_row, _col) { 
					var _grp = UI.get(self.__ID+"_CellGroup_"+string(_row)+"_"+string(_col));
					return _grp;
				}
			
				/// @method				setShowGridOverlay(_show)
				/// @description		Sets whether the grid outline is shown (useful for placing items at development)
				/// @param				{Bool}	_show		whether the overlay is shown
				/// @return				{UIGrid}	self
				self.setShowGridOverlay = function(_show) {
					self.__show_grid_overlay = _show; 
					self.__updateDebugGridCells();
					return self;
				}
				
				/// @method				getShowGridOverlay()
				/// @description		Gets whether the grid outline is shown (useful for placing items at development)
				///	@return				{Bool}	whether the overlay is shown
				self.getShowGridOverlay = function()				{ return self.__show_grid_overlay; }
			
				
			#endregion
			#region Methods
				self.__updateDebugGridCells = function() {
					for (var _row = 0; _row < self.__rows; _row++) {
						for (var _col = 0; _col < self.__columns; _col++) {
							var _grp = UI.get(self.__ID+"_CellGroup_"+string(_row)+"_"+string(_col));
							_grp.__debug_draw = self.__show_grid_overlay;
						}
					}
				}
			
				self.__col_width = function(_col) {
					if (_col < 0 || _col >= self.__columns)	return -1;
					else {
						var _width = self.__dimensions.width * UI.getScale();
						var _usable_width = _width - self.__margin_left - self.__margin_right - (self.__columns-1)*self.__spacing_horizontal;
						var _col_width = self.__column_proportions[_col] * _usable_width;
						return _col_width;
					}
				}
				self.__row_height = function(_row) {
					if (_row < 0 || _row >= self.__rows)	return -1;
					else {
						var _height = self.__dimensions.height * UI.getScale();
						var _usable_height = _height - self.__margin_top - self.__margin_bottom - (self.__rows-1)*self.__spacing_vertical;
						var _row_height = self.__row_proportions[_row] * _usable_height;
						return _row_height;
					}
				}
				self.__col_to_x = function(_col) {
					if (_col < 0 || _col >= self.__columns)	return -1;
					else {
						var _x = self.__dimensions.x;
						var _width = self.__dimensions.width * UI.getScale();
						var _usable_width = _width - self.__margin_left - self.__margin_right - (self.__columns-1)*self.__spacing_horizontal;
						_x += self.__margin_left;
						for (var _c=0; _c<_col; _c++) {
							var _col_width = self.__column_proportions[_c] * _usable_width;
							_x += _col_width;
							if (_c < self.__columns-1)	_x += self.__spacing_horizontal;
						}
					}
					var _col_width = self.__column_proportions[_col] * _usable_width;
					
					return _x;
				}
				self.__row_to_y = function(_row) {
					if (_row < 0 || _row >= self.__rows)	return -1;
					else {
						var _y = self.__dimensions.y;
						var _height = self.__dimensions.height * UI.getScale();
						var _usable_height = _height - self.__margin_top - self.__margin_bottom - (self.__rows-1)*self.__spacing_vertical;
						_y += self.__margin_top;
						for (var _r=0; _r<_row; _r++) {
							var _row_height = self.__row_proportions[_r] * _usable_height;
							_y += _row_height;
							if (_r < self.__rows-1)	_y += self.__spacing_vertical;
						}
					}
					var _row_height = self.__row_proportions[_row] * _usable_height;
					
					return _y;
				}
				
				self.addToCell = function(_widget, _row, _col) {
					var _grp = UI.get(self.__ID+"_CellGroup_"+string(_row)+"_"+string(_col));
					_grp.add(_widget);
					return _widget;
				}
				
				
				self.__updateGridDimensions = function() {
					if (self.getParent() != noone) {
						var _parent = self.getParent();
						var _parent_dim = _parent.getDimensions();
					}
					else {
						var _parent_dim = {x: 0, y: 0};
					}
					
					for (var _row = 0; _row < self.__rows; _row++) {
						for (var _col = 0; _col < self.__columns; _col++) {
							var _widget = UI.get(self.__ID+"_CellGroup_"+string(_row)+"_"+string(_col));
							var _x = self.__col_to_x(_col) - _parent_dim.x;
							var _y = self.__row_to_y(_row) - _parent_dim.y;
							var _w = self.__col_width(_col);
							var _h = self.__row_height(_row);
							_widget.setDimensions(_x, _y, _w, _h);
						}
					}
				}
				
				self.__createGrid = function() {
					for (var _row = 0; _row < self.__rows; _row++) {
						for (var _col = 0; _col < self.__columns; _col++) {
							var _x = self.__col_to_x(_col);
							var _y = self.__row_to_y(_row);
							var _w = self.__col_width(_col);
							var _h = self.__row_height(_row);
							self.add(new UIGroup(self.__ID+"_CellGroup_"+string(_row)+"_"+string(_col), _x, _y, _w, _h, noone));							
						}
					}
				}
				
				self.__draw = function() {
					
				}
				
				/*self.__generalBuiltInBehaviors = method(self, __builtInBehavior);
				self.__builtInBehavior = function() {
					if (self.__events_fired[UI_EVENT.LEFT_CLICK]) 	self.__callbacks[UI_EVENT.LEFT_CLICK]();				
				}*/
			#endregion
			
			// Initialize - Set w/h and default proportions
			self.resetRowProportions(false);
			self.resetColumnProportions(false);			
			self.__createGrid();
			self.setInheritWidth(true);
			self.setInheritHeight(true);			
			self.__register();
			return self;
		}
	
	#endregion
	
#endregion

#region Parent Structs
	function None() {}
	
	#region	__UIDimensions
		/// @struct					__UIDimensions(_offset_x, _offset_y, _width, _height,  _id, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _inherit_width=false, _inherit_height=false)
		/// @description			Private struct that represents the position and size of a particular Widget<br>
		///							Apart from the specified offset_x and offset_y, the resulting struct will also have:<br>
		///							`x`			x coordinate of the `TOP_LEFT` corner of the widget, relative to `SCREEN` (**absolute** coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
		///							`y`			y coordinate of the `TOP_LEFT` corner of the widget, relative to `SCREEN` (**absolute** coordinates). These will be used to draw the widget on screen and perform the event handling checks.<br>
		///							`x_parent`	x coordinate of the `TOP_LEFT` corner of the widget, relative to `PARENT` (**relative** coordinates). These will be used to draw the widget inside other widgets which have the `clipContents` property enabled (e.g. scrollable panels or other scrollable areas).<br>
		///							`y_parent`	y coordinate of the `TOP_LEFT` corner of the widget, relative to `PARENT` (**relative** coordinates). These will be used to draw the widget inside other widgets which have the `clipContents` property enabled (e.g. scrollable panels or other scrollable areas).
		///	@param					{Real}		_offset_x			Amount of horizontal pixels to move, starting from the `_relative_to` corner, to set the x position. Can be negative as well.
		///															This is NOT the x position of the top left corner (except if `_relative_to` is `TOP_LEFT`), but rather the x position of the corresponding corner.
		///	@param					{Real}		_offset_y			Amount of vertical pixels to move, starting from the `_relative_to` corner, to set the y position. Can be negative as well.
		///															This is NOT the y position of the top corner (except if `_relative_to` is `TOP_LEFT`), but rather the y position of the corresponding corner.
		///	@param					{Real}		_width				Width of widget
		///	@param					{Real}		_height				Height of widget
		///	@param					{UIWidget}	_id					ID of the corresponing widget
		///	@param					{Enum}		[_relative_to]		Relative to, according to `UI_RELATIVE_TO` enum
		///	@param					{UIWidget}	[_parent]			Reference to the parent, or noone		
		///	@param					{UIWidget}	[_inherit_width]	Whether the widget inherits its width from its parent
		///	@param					{UIWidget}	[_inherit_height]	Whether the widget inherits its height from its parent
		function __UIDimensions(_offset_x, _offset_y, _width, _height, _id, _relative_to=UI_RELATIVE_TO.TOP_LEFT, _parent=noone, _inherit_width=false, _inherit_height=false) constructor {
			self.widget_id = _id;
			self.relative_to = _relative_to;
			self.offset_x = _offset_x;
			self.offset_y = _offset_y;
			self.width = _width;
			self.height = _height;
			self.inherit_width = _inherit_width;
			self.inherit_height = _inherit_height;
			self.parent = noone;
		
			// These values are ALWAYS the coordinates of the top-left corner, irrespective of the relative_to value
			self.x = 0;
			self.y = 0;
			self.relative_x = 0;
			self.relative_y = 0;
		
			/// @method			calculateCoordinates()
			/// @description	computes the relative and absolute coordinates, according to the set parent		
			self.calculateCoordinates = function() {
				// Get parent x,y SCREEN TOP-LEFT coordinates and width,height (if no parent, use GUI size)
				var _parent_x = 0;
				var _parent_y = 0;
				var _parent_w = display_get_gui_width();
				var _parent_h = display_get_gui_height();
				if (self.parent != noone) {
					_parent_x = self.parent.__dimensions.x;
					_parent_y = self.parent.__dimensions.y;
					_parent_w = self.parent.__dimensions.width;
					_parent_h = self.parent.__dimensions.height;
				}
				// Inherit width/height
				if (self.inherit_width)		self.width = _parent_w;
				if (self.inherit_height)	self.height = _parent_h;
				// Calculate the starting point
				var _starting_point_x = _parent_x;
				var _starting_point_y = _parent_y;
				if (self.relative_to == UI_RELATIVE_TO.TOP_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER) {
					_starting_point_x += _parent_w/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.TOP_RIGHT || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					_starting_point_x += _parent_w;
				}
				if (self.relative_to == UI_RELATIVE_TO.MIDDLE_LEFT || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT) {
					_starting_point_y += _parent_h/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.BOTTOM_LEFT || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					_starting_point_y += _parent_h;
				}
				// Calculate anchor point
				var _anchor_point_x = _starting_point_x + self.offset_x;
				var _anchor_point_y = _starting_point_y + self.offset_y;
				// Calculate widget TOP_LEFT SCREEN x,y coordinates (absolute)
				self.x = _anchor_point_x;
				self.y = _anchor_point_y;
				if (self.relative_to == UI_RELATIVE_TO.TOP_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER) {
					self.x -= self.width/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.TOP_RIGHT || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					self.x -= self.width;
				}
				if (self.relative_to == UI_RELATIVE_TO.MIDDLE_LEFT || self.relative_to == UI_RELATIVE_TO.MIDDLE_CENTER || self.relative_to == UI_RELATIVE_TO.MIDDLE_RIGHT) {
					self.y -= self.height/2;
				}
				else if (self.relative_to == UI_RELATIVE_TO.BOTTOM_LEFT || self.relative_to == UI_RELATIVE_TO.BOTTOM_CENTER || self.relative_to == UI_RELATIVE_TO.BOTTOM_RIGHT) {
					self.y -= self.height;
				}
				// Calculate widget RELATIVE x,y coordinates (relative to parent)
				self.relative_x = self.x - _parent_x;
				self.relative_y = self.y - _parent_y;			
			}
		
		
			/// @method					setParent(_parent)
			/// @description			sets the parent of the UIDimensions struct, so coordinates can be calculated taking that parent into account.<br>
			///							Coordinates are automatically updated when set - i.e. [`calculateCoordinates()`](#__UIDimensions.calculateCoordinates) is automatically called.
			/// @param					{UIWidget}	_parent		the reference to the UIWidget		
			self.setParent = function(_parent) {
				self.parent = _parent;
				// Update screen and relative coordinates with new parent
				self.calculateCoordinates();
			}
		
			/// @method					set(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to=undefined)
			/// @description			sets the values for the struct, with optional parameters
			///	@param					{Real}		[_offset_x]		Amount of horizontal pixels to move, starting from the `_relative_to` corner, to set the x position. Can be negative as well.
			///														This is NOT the x position of the top left corner (except if `_relative_to` is `TOP_LEFT`), but rather the x position of the corresponding corner.
			///	@param					{Real}		[_offset_y]		Amount of vertical pixels to move, starting from the `_relative_to` corner, to set the y position. Can be negative as well.
			///														This is NOT the y position of the top corner (except if `_relative_to` is `TOP_LEFT`), but rather the y position of the corresponding corner.
			///	@param					{Real}		[_width]		Width of widget
			///	@param					{Real}		[_height]		Height of widget				
			///	@param					{Enum}		[_parent]		Sets the anchor relative to which coordinates are calculated.
			self.set = function(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to = undefined) {
				self.offset_x = _offset_x ?? self.offset_x;
				self.offset_y = _offset_y ?? self.offset_y;
				self.relative_to = _relative_to ?? self.relative_to;
				self.width = _width ?? self.width;
				self.height = _height ?? self.height;
				// Update screen and relative coordinates with new parent
				self.calculateCoordinates();
			}
			
			self.setScrollOffsetH = function(_signed_amount) {
				self.offset_x = self.offset_x + _signed_amount;
				// Update screen and relative coordinates with scroll
				self.calculateCoordinates();
			}
			self.setScrollOffsetV = function(_signed_amount) {
				self.offset_y = self.offset_y + _signed_amount;
				// Update screen and relative coordinates with scroll
				self.calculateCoordinates();
			}
			
			self.toString = function() {
				var _rel;
				switch (self.relative_to) {
					case UI_RELATIVE_TO.TOP_LEFT:		_rel = "top left";			break;
					case UI_RELATIVE_TO.TOP_CENTER:		_rel = "top center";		break;
					case UI_RELATIVE_TO.TOP_RIGHT:		_rel = "top right";			break;
					case UI_RELATIVE_TO.MIDDLE_LEFT:	_rel = "middle left";		break;
					case UI_RELATIVE_TO.MIDDLE_CENTER:	_rel = "middle center";		break;
					case UI_RELATIVE_TO.MIDDLE_RIGHT:	_rel = "middle right";		break;
					case UI_RELATIVE_TO.BOTTOM_LEFT:	_rel = "bottom left";		break;
					case UI_RELATIVE_TO.BOTTOM_CENTER:	_rel = "bottom center";		break;
					case UI_RELATIVE_TO.BOTTOM_RIGHT:	_rel = "bottom right";		break;
					default:							_rel = "UNKNOWN";			break;
				}
				return self.widget_id.__ID + ": ("+string(self.x)+", "+string(self.y)+") relative to "+_rel+"  width="+string(self.width)+" height="+string(self.height)+
				" offset provided: "+string(self.offset_x)+","+string(self.offset_y)+
				"\n	parent: "+(self.parent != noone ? self.parent.__ID + " ("+(string(self.parent.__dimensions.x)+", "+string(self.parent.__dimensions.y)+")   width="+string(self.parent.__dimensions.width)+" height="+string(self.parent.__dimensions.height)) : "no parent");
			}
			
			// Set parent (and calculate screen/relative coordinates) on creation
			self.setParent(_parent);
		}	
	
	#endregion
	
	#region __UIWidget
	
		/// @constructor	UIWidget(_id, _offset_x, _offset_y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT)
		/// @description	The base class for all ofhter widgets. Should be treated as an
		///					uninstantiable class / template.
		/// @param	{String}				_id					The widget's string ID by which it will be referred as.
		/// @param	{Real}					_offset_x			The x offset position relative to its parent, according to the _relative_to parameter
		/// @param	{Real}					_offset_y			The y offset position relative to its parent, according to the _relative_to parameter
		/// @param	{Real}					_width				The width of the widget
		/// @param	{Real}					_height				The height of the widget
		/// @param	{Asset.GMSprite}		_sprite				The sprite asset to use for rendering
		/// @param	{Enum}					[_relative_to]		Anchor position from which to calculate offset, from the UI_RELATIVE enum (default: TOP_LEFT)
		/// @return	{UIWidget}				self
		function __UIWidget(_id, _offset_x, _offset_y, _width, _height, _sprite, _relative_to=UI_RELATIVE_TO.TOP_LEFT) constructor {
			#region Private variables
				self.__ID = _id;
				self.__type = -1;
				self.__dimensions = new __UIDimensions(_offset_x, _offset_y, _width, _height, self, _relative_to, noone, false, false);
				self.__sprite = _sprite;
				self.__image = 0;
				self.__image_alpha = 1;
				self.__image_blend = c_white;				
				self.__events_fired_last = array_create(GOOEY_NUM_CALLBACKS, false);
				self.__events_fired = array_create(GOOEY_NUM_CALLBACKS, false);
				self.__callbacks = array_create(GOOEY_NUM_CALLBACKS, None);
				self.__parent = noone;
				self.__children = [];
				//self.__builtInBehavior = None;			
				self.__visible = true;
				self.__enabled = true;
				self.__draggable = false;
				self.__resizable = false;
				self.__resize_border_width = 0;
				self.__drag_bar_height = self.__dimensions.height;
				self.__clips_content = false;
				self.__surface_id = noone;
				self.__min_width = 1;
				self.__min_height = 1;
				self.__user_data = {};
				self.__binding = undefined;
				self.__cumulative_horizontal_scroll_offset = [0];
				self.__cumulative_vertical_scroll_offset = [0];
				self.__pre_render_callback = None;
				self.__post_render_callback = None;
			#endregion
			#region Setters/Getters
				/// @method				getID()
				/// @description		Getter for the widget's string ID
				/// @returns			{string} The widget's string ID
				self.getID = function()					{ return self.__ID; }
			
				/// @method				getType()
				/// @description		Getter for the widget's type
				/// @returns			{Enum}	The widget's type, according to the UI_TYPE enum			
				self.getType = function()					{ return self.__type; }
			
				/// @method				getDimensions()
				/// @description		Gets the UIDimensions object for this widget
				/// @returns			{UIDimensions}	The dimensions object. See [`UIDimensions`](#__UIDimensions).
				self.getDimensions = function()			{ return self.__dimensions; }
			
				/// @method						setDimensions()
				/// @description				Sets the UIDimensions object for this widget, with optional parameters.
				/// @param	{Real}				[_offset_x]			The x offset position relative to its parent, according to the _relative_to parameter
				/// @param	{Real}				[_offset_y]			The y offset position relative to its parent, according to the _relative_to parameter
				/// @param	{Real}				[_width]			The width of the widget
				/// @param	{Real}				[_height]			The height of the widget			
				/// @param	{Enum}				[_relative_to]		Anchor position from which to calculate offset, from the UI_RELATIVE enum (default: TOP_LEFT)
				/// @param	{UIWidget}			[_parent]			Parent Widget reference
				/// @return						{UIWidget}	self
				self.setDimensions = function(_offset_x = undefined, _offset_y = undefined, _width = undefined, _height = undefined, _relative_to = undefined, _parent = undefined)	{
					self.__dimensions.set(_offset_x, _offset_y, _width, _height, _relative_to, _parent);					
					self.__updateChildrenPositions();
					return self;
				}
				
				/// @method				getInheritWidth()
				/// @description		Gets whether the widget inherits its width from its parent.
				/// @returns			{Bool}	Whether the widget inherits its width from its parent
				self.getInheritWidth = function()						{ return self.__dimensions.inherit_width; }
				
				/// @method				setInheritWidth(_inherit_width)
				/// @description		Sets whether the widget inherits its width from its parent.
				/// @param				{Bool}	_inherit_width	Whether the widget inherits its width from its parent
				/// @return				{UIWidget}	self
				self.setInheritWidth = function(_inherit_width) { 
					self.__dimensions.inherit_width = _inherit_width; 
					self.__dimensions.calculateCoordinates();
					self.__updateChildrenPositions();
					return self;
				}
				
				/// @method				getInheritHeight()
				/// @description		Gets whether the widget inherits its height from its parent.
				/// @returns			{Bool}	Whether the widget inherits its height from its parent
				self.getInheritHeight = function()					{ return self.__dimensions.inherit_height; }
				
				/// @method				setInheritHeight(_inherit_height)
				/// @description		Sets whether the widget inherits its height from its parent.
				/// @param				{Bool}	_inherit_height Whether the widget inherits its height from its parent
				/// @return				{UIWidget}	self
				self.setInheritHeight = function(_inherit_height)	{ 
					self.__dimensions.inherit_height = _inherit_height;
					self.__dimensions.calculateCoordinates();
					self.__updateChildrenPositions();
					return self;
				}
				
				/// @method				getSprite(_sprite)
				/// @description		Get the sprite ID to be rendered
				/// @return				{Asset.GMSprite}	The sprite ID
				self.getSprite = function()				{ return self.__sprite; }
			
				/// @method				setSprite(_sprite)
				/// @description		Sets the sprite to be rendered
				/// @param				{Asset.GMSprite}	_sprite		The sprite ID
				/// @return				{UIWidget}	self
				self.setSprite = function(_sprite)		{ self.__sprite = _sprite; return self; }
			
				/// @method				getImage()
				/// @description		Gets the image index of the Widget
				/// @return				{Real}	The image index of the Widget
				self.getImage = function()				{ return self.__image_; }
			
				/// @method				setImage(_image)
				/// @description		Sets the image index of the Widget
				/// @param				{Real}	_image	The image index
				/// @return				{UIWidget}	self
				self.setImage = function(_image)			{ self.__image = _image; return self; }
				
				/// @method				getImageBlend()
				/// @description		Gets the image blend of the Widget's sprite
				/// @return				{Constant.Color}	The image blend
				self.getImageBlend = function()			{ return self.__image_blend; }
			
				/// @method				setImageBlend(_color)
				/// @description		Sets the image blend of the Widget
				/// @param				{Constant.Color}	_color	The image blend
				/// @return				{UIWidget}	self
				self.setImageBlend = function(_color)		{ self.__image_blend = _color; return self; }
				
				/// @method				getImageAlpha()
				/// @description		Gets the image alpha of the Widget's sprite
				/// @return				{Real}	The image alpha
				self.getImageAlpha = function()			{ return self.__image_alpha; }
			
				/// @method				setImageAlpha(_color)
				/// @description		Sets the image alpha of the Widget
				/// @param				{Real}	_alpha	The image alpha
				/// @return				{UIWidget}	self
				self.setImageAlpha = function(_alpha)		{ self.__image_alpha = _alpha; return self; }
				
				/// @method				getCallback(_callback_type)
				/// @description		Gets the callback function for a specific callback type, according to the `UI_EVENT` enum
				/// @param				{Enum}	_callback_type	The callback type
				/// @return				{Function}	the callback function
				self.getCallback = function(_callback_type)				{ return self.__callbacks[_callback_type]; }
			
				/// @method				setCallback(_callback_type, _function)
				/// @description		Sets a callback function for a specific event
				/// @param				{Enum}	_callback_type	The callback type, according to `UI_EVENT` enum
				/// @param				{Function}	_function	The callback function to assign
				/// @return				{UIWidget}	self
				self.setCallback = function(_callback_type, _function)	{ self.__callbacks[_callback_type] = _function; return self; }
			
				/// @method				getParent()
				/// @description		Gets the parent reference of the Widget (also a Widget)			
				/// @return				{UIWidget}	the parent reference
				self.getParent = function()				{ return self.__parent; }
			
				/// @method				getContainingPanel()
				/// @description		Gets the reference of the Panel containing this Widget. If this Widget is a Panel, it will return itself.
				/// @return				{UIPanel}	the parent reference
				self.getContainingPanel = function() {
					if (self.__type == UI_TYPE.PANEL)	return self;
					else if (self.__parent.__type == UI_TYPE.PANEL)	return self.__parent;
					else return self.__parent.getContainingPanel();
				}
				
				/// @method				getContainingTab()
				/// @description		Gets the index number of the tab of the Panel containing this Widget. <br>
				///						If this Widget is a common widget, it will return -1.<br>
				///						If this Widget is a Panel, it will return -4;
				/// @return				{Real}	the tab number
				self.getContainingTab = function() {					
					if (self.__type == UI_TYPE.PANEL)	return -4;
					else {
						var _parent_widget = self.__parent;
						var _target_widget = self;
						while (_parent_widget.__type != UI_TYPE.PANEL) {
							_parent_widget = _parent_widget.__parent;
							_target_widget = _target_widget.__parent;
						}
						var _i=0, _n=array_length(_parent_widget.__tabs); 
						var _found = false;
						while (_i<_n && !_found) {
							var _j=0, _m=array_length(_parent_widget.__tabs[_i]);
							while (_j<_m && !_found) {
								_found = (_parent_widget.__tabs[_i][_j] == _target_widget);
								if (!_found) _j++;
							}
							if (!_found) _i++; 
						}
						if (!_found) { // Must be common controls, return -1 - but calculate it anyway
							var _k=0; 
							var _o=array_length(_parent_widget.__common_widgets);
							var _found_common = false;
							while (_k<_o && !_found_common) {
								_found_common = (_parent_widget.__common_widgets[_k] == _target_widget);
								if (!_found_common) _k++;
							}
							if (_found_common)	return -1;
							else throw("Something REALLY weird happened, the specified control isn't anywhere. Run far, far away");
						}
						else {
							return _i;
						}
					}
				}
			
				/// @method				setParent(_parent_id)
				/// @description		Sets the parent of the Widget. Also calls the `setParent()` method of the corresponding `UIDimensions` struct to recalculate coordinates.
				/// @param				{UIWidget}	_parent_id	The reference to the parent Widget
				/// @return				{UIWidget}	self
				self.setParent = function(_parent_id)		{ 
					self.__parent = _parent_id;
					self.__dimensions.setParent(_parent_id);
					return self;
				}
			
				/// @method				getChildren([_tab=<current tab>])
				/// @description		Gets the array containing all children of this Widget
				/// @param				{Real}	[_tab]				Tab to get the controls from. <br>
				///													If _tab is a nonnegative number, it will get the children from the specified tab.<br>
				///													If _tab is -1, it will return the common widgets instead.<br>
				///													If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).
				/// @return				{Array<UIWidget>}	the array of children Widget references
				self.getChildren = function(_tab=self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			return self.__tabs[_tab];
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	return self.__common_widgets;
					else													return self.__children;
				}
			
				/// @method				setChildren(_children, [_tab=<current tab>])
				/// @description		Sets the children Widgets to a new array of Widget references
				/// @param				{Array<UIWidget>}	_children	The array containing the references of the children Widgets
				/// @param				{Real}				[_tab]		Tab to set the controls for. <br>
				///														If _tab is a nonnegative number, it will set the children of the specified tab.<br>
				///														If _tab is -1, it will set the common widgets instead.<br>
				///														If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).				
				/// @return				{UIWidget}	self
				self.setChildren = function(_children, _tab = self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			self.__tabs[_tab] = _children;
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	self.__common_widgets = _children;
					else													self.__children = _children; 
					return self;
				}
			
				/// @method				getVisible()
				/// @description		Gets the visible state of a Widget
				/// @return				{Bool}	whether the Widget is visible or not
				self.getVisible = function()				{ return self.__visible; }
			
				/// @method				setVisible(_visible)
				/// @description		Sets the visible state of a Widget
				/// @param				{Bool}	_visible	Whether to set visibility to true or false			
				/// @return				{UIWidget}	self
				self.setVisible = function(_visible)		{
					self.__visible = _visible; 
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
						self.__children[_i].setVisible(_visible);
					}
					return self;
				}
			
				/// @method				getEnabled()
				/// @description		Gets the enabled state of a Widget
				/// @return				{Bool}	whether the Widget is enabled or not
				self.getEnabled = function()				{ return self.__enabled; }
			
				/// @method				setEnabled(_enabled)
				/// @description		Sets the enabled state of a Widget
				/// @param				{Bool}	_enabled	Whether to set enabled to true or false			
				/// @return				{UIWidget}	self			
				self.setEnabled = function(_enabled)		{
					self.__enabled = _enabled;
					for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
						self.__children[_i].setEnabled(_enabled);
					}
					return self;
				}
			
				/// @method				getDraggable()
				/// @description		Gets the draggable state of a Widget
				/// @return				{Bool}	whether the Widget is draggable or not
				self.getDraggable = function()			{ return self.__draggable; }
			
				/// @method				setDraggable(_draggable)
				/// @description		Sets the draggable state of a Widget
				/// @param				{Bool}	_draggable	Whether to set draggable to true or false			
				/// @return				{UIWidget}	self
				self.setDraggable = function(_draggable)	{ self.__draggable = _draggable; return self; }
			
				/// @method				getResizable()
				/// @description		Gets the resizable state of a Widget
				/// @return				{Bool}	whether the Widget is resizable or not
				self.getResizable = function()			{ return self.__resizable; }
			
				/// @method				setResizable(_resizable)
				/// @description		Sets the resizable state of a Widget
				/// @param				{Bool}	_resizable	Whether to set resizable to true or false			
				/// @return				{UIWidget}	self
				self.setResizable = function(_resizable)	{ self.__resizable = _resizable; return self; }
								
				/// @method				getResizeBorderWidth()
				/// @description		Gets the width of the border of a Widget that enables resizing
				/// @return				{Real}	the width of the border in px
				self.getResizeBorderWidth = function()		{ return self.__resize_border_width; }
			
				/// @method				setResizeBorderWidth(_resizable)
				/// @description		Sets the resizable state of a Widget
				/// @param				{Real}	_border_width	The width of the border in px
				/// @return				{UIWidget}	self
				self.setResizeBorderWidth = function(_border_width)		{ self.__resize_border_width = _border_width; return self; }
			
				/// @method				getClipsContent()
				/// @description		Gets the Widget's masking/clipping state
				/// @return				{Bool}	Whether the widget clips its content or not.
				self.getClipsContent = function()			{ return self.__clips_content; }
			
				/// @method				setClipsContent(_clips)
				/// @description		Sets the Widget's masking/clipping state.<br>
				///						Note this method automatically creates/frees the corresponding surfaces.
				/// @param				{Bool}	_clips	Whether the widget clips its content or not.
				/// @return				{UIWidget}	self
				self.setClipsContent = function(_clips) {
					self.__clips_content = _clips;
					if (_clips) {
						if (!surface_exists(self.__surface_id))	self.__surface_id = surface_create(display_get_gui_width(), display_get_gui_height());
					}
					else {
						if (surface_exists(self.__surface_id))	surface_free(self.__surface_id);
						self.__surface_id = noone;
					}
					return self;
				}	
				
				/// @method				getUserData(_name)
				/// @description		Gets the user data element named `_name`.
				/// @param				{String}	_name	the name of the data element
				/// @return				{String}	The user data value for the specified name, or an empty string if it doesn't exist
				self.getUserData = function(_name) {
					if (variable_struct_exists(self.__user_data, _name)) {
						return variable_struct_get(self.__user_data, _name);
					}
					else {
						UI.__logMessage("Cannot find data element with name '"+_name+"' in widget '"+self.__ID+"', returning blank string", UI_MESSAGE_LEVEL.WARNING);
						return "";
					}
				}
				
				/// @method				setUserData(_name, _value)
				/// @description		Sets the user data element named `_name`.
				/// @param				{String}	_name	the name of the data element
				/// @param				{Any}		_value	the value to set
				/// @return				{UIWidget}	self
				self.setUserData = function(_name, _value) {
					variable_struct_set(self.__user_data, _name, _value);
					return self;
				}
				
				/// @method				getBinding()
				/// @description		Returns the previously defined object instance or struct variable/method binding.
				/// @return				{Struct}	A struct containing the object or struct ID and the variable or function name that is bound.
				self.getBinding = function() {
					return self.__binding;
				}
				
				/// @method				setBinding(_name, _object_or_struct_ref, _variable_name)
				/// @description		Defines the binding for the defined object or struct reference and the corresponding variable or method name.<br>
				///						The handle of the binding itself is dependent on the specific Widget.
				/// @param				{Struct||Instance.ID}	_object_or_struct_ref		the object or struct reference
				/// @param				{String}				_variable_or_function_name	the name of the variable or method to bind
				/// @return				{UIWidget}	self
				self.setBinding = function(_object_or_struct_ref, _variable_or_method_name) {
					self.__binding = { struct_or_object: _object_or_struct_ref, variable_or_method_name: _variable_or_method_name};
					return self;
				}
				
				/// @method				clearBinding()
				/// @description		Unsets/clears the data binding.
				/// @return				{UIWidget}	self
				self.clearBinding = function() {
					self.__binding = undefined;
					return self;
				}
				
				/// @method				getPreRenderCallback()
				/// @description		Gets the pre-render callback function set.<br>
				///						NOTE: The pre-render event will run regardless of whether the control is visible/enabled.
				/// @return				{Function}	the callback function
				self.getPreRenderCallback = function()				{ return self.__pre_render_callback; }
			
				/// @method				setPreRenderCallback(_function)
				/// @description		Sets a callback function for pre-render.<br>
				///						NOTE: The pre-render event will run regardless of whether the control is visible/enabled.
				/// @param				{Function}	_function	The callback function to assign
				/// @return				{UIWidget}	self
				self.setPreRenderCallback = function(_function)	{ self.__pre_render_callback = _function; return self; }
				
				/// @method				getPostRenderCallback()
				/// @description		Gets the post-render callback function set.<br>
				///						NOTE: The pre-render event will run regardless of whether the control is visible/enabled.
				/// @return				{Function}	the callback function
				self.getPostRenderCallback = function()				{ return self.__post_render_callback; }
			
				/// @method				setPostRenderCallback(_function)
				/// @description		Sets a callback function for post-render.<br>
				///						NOTE: The pre-render event will run regardless of whether the control is visible/enabled.
				/// @param				{Function}	_function	The callback function to assign
				/// @return				{UIWidget}	self
				self.setPostRenderCallback = function(_function)	{ self.__post_render_callback = _function; return self; }
								
			#endregion
			#region Methods
			
				#region Private
					
					// Get the value of the bound variable or function					
					self.__updateBinding = function() {
						if (!is_undefined(self.__binding)) {
							var _struct_or_object_name = self.__binding.struct_or_object;
							var _variable = self.__binding.variable_or_method_name;
							if (is_struct(_struct_or_object_name))			return variable_struct_get(_struct_or_object_name, _variable);
							else if (instance_exists(_struct_or_object_name)) && variable_instance_exists(_struct_or_object_name, _variable) {
								return variable_instance_get(_struct_or_object_name, _variable);
							}
							else {
								UI.__logMessage("Cannot find object instance or struct ("+string(_struct_or_object_name)+") and/or corresponding variable or method ("+_variable+"), previously bound in widget '"+self.__ID+"', returning undefined", UI_MESSAGE_LEVEL.INFO);
								return undefined;
							}
						}
						else {
							//UI.__logMessage("Binding is undefined in widget '"+self.__ID+"', returning undefined", UI_MESSAGE_LEVEL.WARNING);
							return undefined;
						}
						
					}
					
					self.__register = function() {
						if (instance_exists(UI)) UI.__register(self);
						else throw("ERROR: UI manager object is not imported. Drag the UI manager object to your first room and make sure it's created before any other objects using UI, with Instance Creation Order.");
					}
			
					self.__updateChildrenPositions = function() {
						
						if (self.__type == UI_TYPE.PANEL) {
							for (var _j=0, _m=array_length(self.__tabs); _j<_m; _j++) {
								for (var _i=0, _n=array_length(self.__tabs[_j]); _i<_n; _i++) {
									self.__tabs[_j][_i].__dimensions.calculateCoordinates();
									self.__tabs[_j][_i].__updateChildrenPositions();
								}
							}
							// Update common widgets as well
							for (var _i=0, _n=array_length(self.__common_widgets); _i<_n; _i++) {
								self.__common_widgets[_i].__dimensions.calculateCoordinates();
								self.__common_widgets[_i].__updateChildrenPositions();
							}	
						}
						else {
							for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
								self.__children[_i].__dimensions.calculateCoordinates();								
								self.__children[_i].__updateChildrenPositions();							
							}
							if (self.__type == UI_TYPE.GRID) self.__updateGridDimensions();
						}
					}
			
					self.__render = function() {
						// Pre-render
						self.__pre_render_callback();
						
						if (self.__visible) {							
							// Draw this widget
							self.__draw();
							
							if (self.__clips_content) {
								if (!surface_exists(self.__surface_id)) self.__surface_id = surface_create(display_get_gui_width(), display_get_gui_height());
								surface_set_target(self.__surface_id);
								draw_clear_alpha(c_black, 0);
							}
										
							// Render children
							for (var _i=0, _n=array_length(self.__children); _i<_n; _i++)	self.__children[_i].__render();
							// Render common items
							if (self.__type == UI_TYPE.PANEL) {
								for (var _i=0, _n=array_length(self.__common_widgets); _i<_n; _i++)	self.__common_widgets[_i].__render();
							}
					
							if (self.__clips_content) {						
								surface_reset_target();
								// The surface needs to be drawn with screen coords
								draw_surface_part(self.__surface_id, self.__dimensions.x, self.__dimensions.y, self.__dimensions.width * UI.getScale(), self.__dimensions.height * UI.getScale(), self.__dimensions.x, self.__dimensions.y);
							}
						}
						
						// Post-render
						self.__post_render_callback();
					}
			
					self.__processMouseover = function() {
						if (self.__visible && self.__enabled)	self.__events_fired[UI_EVENT.MOUSE_OVER] = point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), self.__dimensions.x, self.__dimensions.y, self.__dimensions.x + self.__dimensions.width * UI.getScale(), self.__dimensions.y + self.__dimensions.height * UI.getScale());
					}
					
					self.__clearEvents = function(_clear_enter_exit=true) {
						for (var _i=0; _i<GOOEY_NUM_CALLBACKS; _i++)	{
							if (_clear_enter_exit || !_clear_enter_exit && _i != UI_EVENT.MOUSE_ENTER && _i != UI_EVENT.MOUSE_EXIT) self.__events_fired[_i] = false;
						}
					}
				
					self.__processEvents = function() {
						array_copy(self.__events_fired_last, 0, self.__events_fired, 0, GOOEY_NUM_CALLBACKS);
						
						self.__clearEvents();
						
						if (self.__visible && self.__enabled) {
							self.__processMouseover();
							self.__events_fired[UI_EVENT.LEFT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(UI.getMouseDevice(), mb_left);
							self.__events_fired[UI_EVENT.MIDDLE_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(UI.getMouseDevice(), mb_middle);
							self.__events_fired[UI_EVENT.RIGHT_CLICK] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_pressed(UI.getMouseDevice(), mb_right);
							self.__events_fired[UI_EVENT.LEFT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(UI.getMouseDevice(), mb_left);
							self.__events_fired[UI_EVENT.MIDDLE_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(UI.getMouseDevice(), mb_middle);
							self.__events_fired[UI_EVENT.RIGHT_HOLD] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button(UI.getMouseDevice(), mb_right);
							self.__events_fired[UI_EVENT.LEFT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(UI.getMouseDevice(), mb_left);
							self.__events_fired[UI_EVENT.MIDDLE_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(UI.getMouseDevice(), mb_middle);
							self.__events_fired[UI_EVENT.RIGHT_RELEASE] = self.__events_fired[UI_EVENT.MOUSE_OVER] && device_mouse_check_button_released(UI.getMouseDevice(), mb_right);
							self.__events_fired[UI_EVENT.MOUSE_ENTER] = !self.__events_fired_last[UI_EVENT.MOUSE_OVER] && self.__events_fired[UI_EVENT.MOUSE_OVER];
							self.__events_fired[UI_EVENT.MOUSE_EXIT] = self.__events_fired_last[UI_EVENT.MOUSE_OVER] && !self.__events_fired[UI_EVENT.MOUSE_OVER];
							self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_up();
							self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN] = self.__events_fired[UI_EVENT.MOUSE_OVER] && mouse_wheel_down();
							
							
							// Calculate 3x3 "grid" on the panel, based off on screen coords, that will determine what drag action is fired (move or resize)
							var _w = self.__resize_border_width * UI.getScale();					
							var _x0 = self.__dimensions.x;
							var _x1 = _x0 + _w;
							var _x3 = self.__dimensions.x + self.__dimensions.width * UI.getScale();
							var _x2 = _x3 - _w;
							var _y0 = self.__dimensions.y;
							var _y1 = _y0 + _w;
							var _y3 = self.__dimensions.y + self.__dimensions.height * UI.getScale();
							var _y2 = _y3 - _w;
					
							// Determine mouse cursors for mouseover
							if (self.__events_fired[UI_EVENT.MOUSE_OVER]) {
								var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
								if		(self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x1, _y1))		UI.__setUICursor(UI_CURSOR_SIZE_NWSE);
								else if (self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y0, _x3, _y1))		UI.__setUICursor(UI_CURSOR_SIZE_NESW);
								else if (self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y2, _x1, _y3))		UI.__setUICursor(UI_CURSOR_SIZE_NESW);
								else if (self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y2, _x3, _y3))		UI.__setUICursor(UI_CURSOR_SIZE_NWSE);
								else if (self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x3, _y1))		UI.__setUICursor(UI_CURSOR_SIZE_NS);
								else if (self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x2, _y0, _x3, _y3))		UI.__setUICursor(UI_CURSOR_SIZE_WE);
								else if (self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y2, _x3, _y3))		UI.__setUICursor(UI_CURSOR_SIZE_NS);
								else if (self.__resizable && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x0, _y0, _x1, _y3))		UI.__setUICursor(UI_CURSOR_SIZE_WE);
								else if (((self.__type == UI_TYPE.PANEL && self.__movable) || (self.__type != UI_TYPE.PANEL && self.__draggable)) && point_in_rectangle(device_mouse_x_to_gui(UI.getMouseDevice()), device_mouse_y_to_gui(UI.getMouseDevice()), _x1, _y1, _x2, _y1drag))	UI.__setUICursor(UI_CURSOR_DRAG);
							}
					
							if (self.__isDragStart())	{
								// Determine drag actions for left hold
								var _y1drag = self.__drag_bar_height == self.__dimensions.height ? _y2 : _y1 + self.__drag_bar_height;								
								if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y0, _x1, _y1))			UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_NW; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x2, _y0, _x3, _y1))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_NE; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y2, _x1, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_SW; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x2, _y2, _x3, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_SE; 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y0, _x3, _y1))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_N;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x2, _y0, _x3, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_E;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y2, _x3, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_S;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x0, _y0, _x1, _y3))		UI.__drag_data.__drag_action = UI_RESIZE_DRAG.RESIZE_W;	 
								else if (point_in_rectangle(UI.__drag_data.__drag_mouse_delta_x, UI.__drag_data.__drag_mouse_delta_y, _x1, _y1, _x2, _y1drag))	UI.__drag_data.__drag_action = UI_RESIZE_DRAG.DRAG;
								else 	UI.__drag_data.__drag_action = UI_RESIZE_DRAG.NONE;								
							}
														
						}
					}
					
					self.__dragCondition = function() { return true; }
					
					self.__dragStart = function() {
						if (self.__type == UI_TYPE.PANEL)	UI.setFocusedPanel(self.__ID);
						UI.__currentlyDraggedWidget = self;								
						UI.__drag_data.__drag_start_x = self.__dimensions.x;
						UI.__drag_data.__drag_start_y = self.__dimensions.y;
						UI.__drag_data.__drag_start_width = self.__dimensions.width;
						UI.__drag_data.__drag_start_height = self.__dimensions.height;
						UI.__drag_data.__drag_mouse_delta_x = device_mouse_x_to_gui(UI.getMouseDevice());
						UI.__drag_data.__drag_mouse_delta_y = device_mouse_y_to_gui(UI.getMouseDevice());						
					}
					
					self.__isDragStart = function() {
						if (UI.__currentlyDraggedWidget == noone && self.__draggable && self.__events_fired[UI_EVENT.LEFT_HOLD] && self.__dragCondition())	{							
							self.__dragStart();
							return true;
						}
						else return false;
					}
					
					self.__isDragEnd = function() {
						if (UI.__currentlyDraggedWidget == self && device_mouse_check_button_released(UI.getMouseDevice(), mb_left)) {								
							UI.__currentlyDraggedWidget = noone;
							UI.__drag_data.__drag_start_x = -1;
							UI.__drag_data.__drag_start_y = -1;
							UI.__drag_data.__drag_start_width = -1;
							UI.__drag_data.__drag_start_height = -1;
							UI.__drag_data.__drag_mouse_delta_x = -1;
							UI.__drag_data.__drag_mouse_delta_y = -1;
							UI.__drag_data.__drag_action = -1;
							UI.__drag_data.__drag_specific_start_x = -1;
							UI.__drag_data.__drag_specific_start_y = -1;
							UI.__drag_data.__drag_specific_start_width = -1;
							UI.__drag_data.__drag_specific_start_height = -1;
							UI.__setUICursor(UI_CURSOR_DEFAULT);
							return true;
						}
						else return false;
					}
					
					self.__builtInBehavior = function(_process_array = array_create(GOOEY_NUM_CALLBACKS, true)) {
						if (_process_array[UI_EVENT.MOUSE_OVER] && self.__events_fired[UI_EVENT.MOUSE_OVER]) 				self.__callbacks[UI_EVENT.MOUSE_OVER]();
						if (_process_array[UI_EVENT.LEFT_CLICK] && self.__events_fired[UI_EVENT.LEFT_CLICK]) 				self.__callbacks[UI_EVENT.LEFT_CLICK]();
						if (_process_array[UI_EVENT.MIDDLE_CLICK] && self.__events_fired[UI_EVENT.MIDDLE_CLICK]) 			self.__callbacks[UI_EVENT.MIDDLE_CLICK]();
						if (_process_array[UI_EVENT.RIGHT_CLICK] && self.__events_fired[UI_EVENT.RIGHT_CLICK]) 				self.__callbacks[UI_EVENT.RIGHT_CLICK]();
						if (_process_array[UI_EVENT.LEFT_HOLD] && self.__events_fired[UI_EVENT.LEFT_HOLD]) 					self.__callbacks[UI_EVENT.LEFT_HOLD]();
						if (_process_array[UI_EVENT.MIDDLE_HOLD] && self.__events_fired[UI_EVENT.MIDDLE_HOLD]) 				self.__callbacks[UI_EVENT.MIDDLE_HOLD]();
						if (_process_array[UI_EVENT.RIGHT_HOLD] && self.__events_fired[UI_EVENT.RIGHT_HOLD]) 				self.__callbacks[UI_EVENT.RIGHT_HOLD]();
						if (_process_array[UI_EVENT.LEFT_RELEASE] && self.__events_fired[UI_EVENT.LEFT_RELEASE]) 			self.__callbacks[UI_EVENT.LEFT_RELEASE]();
						if (_process_array[UI_EVENT.MIDDLE_RELEASE] && self.__events_fired[UI_EVENT.MIDDLE_RELEASE])		self.__callbacks[UI_EVENT.MIDDLE_RELEASE]();
						if (_process_array[UI_EVENT.RIGHT_RELEASE] && self.__events_fired[UI_EVENT.RIGHT_RELEASE]) 			self.__callbacks[UI_EVENT.RIGHT_RELEASE]();
						if (_process_array[UI_EVENT.MOUSE_ENTER] && self.__events_fired[UI_EVENT.MOUSE_ENTER]) 				self.__callbacks[UI_EVENT.MOUSE_ENTER]();
						if (_process_array[UI_EVENT.MOUSE_EXIT] && self.__events_fired[UI_EVENT.MOUSE_EXIT]) 				self.__callbacks[UI_EVENT.MOUSE_EXIT]();
						if (_process_array[UI_EVENT.MOUSE_WHEEL_UP] && self.__events_fired[UI_EVENT.MOUSE_WHEEL_UP]) 		self.__callbacks[UI_EVENT.MOUSE_WHEEL_UP]();
						if (_process_array[UI_EVENT.MOUSE_WHEEL_DOWN] && self.__events_fired[UI_EVENT.MOUSE_WHEEL_DOWN])	self.__callbacks[UI_EVENT.MOUSE_WHEEL_DOWN]();					
						// Handle Value Changed event on the UI object
					}	
					
					self.__drag = function() {}
					
				#endregion
			
				/// @method				scroll(_orientation, _sign, [_amount = UI_SCROLL_SPEED])
				/// @description		Scrolls the content of this widget in a particular direction (horizontal/vertical) and sign (negative/positive)
				/// @param				{Enum}	_orientation	the direction to scroll, as in `UI_ORIENTATION`.
				/// @param				{Real}	_sign			the sign (-1 or 1)
				/// @param				{Real}	_amount			the amount to scroll, by default `UI_SCROLL_SPEED`
				/// @return				{UIWidget}	self
				self.scroll = function(_orientation, _sign, _amount = UI_SCROLL_SPEED) {
					var _s = _sign >= 0 ? 1 : -1;
					var _tab = self.__type == UI_TYPE.PANEL ? self.getCurrentTab() : 0;
					if (_orientation == UI_ORIENTATION.HORIZONTAL) {
						self.__cumulative_horizontal_scroll_offset[_tab] += _s * _amount;
						for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
							self.__children[_i].__dimensions.setScrollOffsetH(_s * _amount);
						}
					}
					else {
						self.__cumulative_vertical_scroll_offset[_tab] += _s * _amount;
						for (var _i=0, _n=array_length(self.__children); _i<_n; _i++) {
							self.__children[_i].__dimensions.setScrollOffsetV(_s * _amount);
						}
					}
				}
				
				/// @method				getScrollOffset(_orientation, _value)
				/// @description		Gets the cumulative scroll offset to a particular number
				/// @param				{Enum}	_orientation	whether to set the horizontal or vertical offset
				/// @return				{Real}	the cumulative scroll offset
				self.getScrollOffset = function(_orientation) {
					var _tab = self.__type == UI_TYPE.PANEL ? self.getCurrentTab() : 0;
					return _orientation == UI_ORIENTATION.HORIZONTAL ? self.__cumulative_horizontal_scroll_offset[_tab] : self.__cumulative_vertical_scroll_offset[_tab];
				}
				
				/// @method				setScrollOffset(_orientation, _value)
				/// @description		Sets the scroll offset to a particular number
				/// @param				{Enum}	_orientation	whether to set the horizontal or vertical offset
				/// @param				{Real}	_value			the value to set				
				/// @return				{UIWidget}	self
				self.setScrollOffset = function(_orientation, _value) {
					var _tab = self.__type == UI_TYPE.PANEL ? self.getCurrentTab() : 0;
					var _current_offset = _orientation == UI_ORIENTATION.HORIZONTAL ? self.__cumulative_horizontal_scroll_offset[_tab] : self.__cumulative_vertical_scroll_offset[_tab];
					var _amount = abs(_value - _current_offset);
					var _sign = sign(_value - _current_offset);
					self.scroll(_orientation, _sign, _amount);			
				}
				
				/// @method				resetScroll(_direction)
				/// @description		Resets the scrolling offset to 0 in the indicated direction
				/// @param				{Enum}	_direction	the direction to scroll, as in `UI_ORIENTATION`.				
				/// @return				{UIWidget}	self
				self.resetScroll = function(_direction) {
					var _tab = self.__type == UI_TYPE.PANEL ? self.getCurrentTab() : 0;
					var _cum = _direction == UI_ORIENTATION.HORIZONTAL ? self.__cumulative_horizontal_scroll_offset[_tab] : self.__cumulative_vertical_scroll_offset[_tab];
					self.scroll(_direction, -sign(_cum), abs(_cum));
				}
					
				/// @method				add(_id, [_tab = <current_tab>])
				/// @description		Adds a children Widget to this Widget
				/// @param				{UIWidget}	_id 	The reference to the children Widget to add
				/// @param				{Real}	[_tab]				Tab to get the controls from. <br>
				///													If _tab is a nonnegative number, it will add the children to the specified tab.<br>
				///													If _tab is -1, it will add the children to the common widgets instead.<br>
				///													If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).				
				/// @return				{UIWidget}	The added children Widget. *Note that this does NOT return the current Widget's reference, but rather the children's reference*. This is by design to be able to use `with` in conjunction with this method.
				self.add = function(_id, _tab = self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					_id.__parent = self;
					_id.__dimensions.setParent(self);
					//array_push(self.__children, _id);
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			array_push(self.__tabs[_tab], _id);					
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	array_push(self.__common_widgets, _id);
					else array_push(self.__children, _id);
					
					if (_id.__type == UI_TYPE.GRID) {
						_id.__updateGridDimensions();
					}
					
					return _id;
				}
			
				/// @method				remove(_ID)
				/// @description		Removes a Widget from the list of children Widget. *Note that this does NOT destroy the Widget*.
				/// @param				{String}	_ID 	The string ID of the children Widget to delete
				/// @param				{Real}	[_tab]				Tab to remove the control from. <br>
				///													If _tab is a nonnegative number, it will add the children to the specified tab.<br>
				///													If _tab is -1, it will add the children to the common widgets instead.<br>
				///													If _tab is omitted, it will default to the current tab (or ignored, in case of non-tabbed widgets).				
				/// @return				{Bool}				Whether the Widget was found (and removed from the list of children) or not.<br>
				///											NOTE: If tab was specified, it will return `false` if the control was not found on the specified tab, regardless of whether it exists on other tabs, or on the common widget-
				self.remove = function(_ID, _tab = self.__type == UI_TYPE.PANEL ? self.__current_tab : 0) {
					var _array;
					if (self.__type == UI_TYPE.PANEL && _tab != -1)			_array = self.__tabs[_tab];
					else if (self.__type == UI_TYPE.PANEL && _tab == -1)	_array = self.__common_widgets;
					else													_array = self.__children;
					
					var _i=0; 
					var _n = array_length(_array);
					var _found = false;
					while (_i<_n && !_found) {
						if (_array[_i].__ID == _ID) {
							array_delete(_array, _i, 1);
							_found = true;						
						}
						else {
							_i++
						}					
					}
					return _found;
				}
			
			
				/// @method				getDescendants()
				/// @description		Gets an array containing all descendants (children, grandchildren etc.) of this Widget.<br>
				///						If widget is a Panel, gets all descendants of the current tab, including common widgets for a Panel
				/// @return				{Array<UIWidget>}	the array of descendant Widget references
				self.getDescendants = function() {
					var _n_children = array_length(self.getChildren());					
					//var _a = array_create(_n_children + _n_common);					
					var _a = [];
					array_copy(_a, 0, self.getChildren(), 0, _n_children); 

					var _n = array_length(_a);
					if (_n > 0) {						
						for (var _i=0; _i<_n; _i++) {
							var _b = _a[_i].getDescendants();				
							var _m = array_length(_b);
							for (var _j=0; _j<_m; _j++)			array_push(_a, _b[_j]);
						}
					}
					
					// Copy common widgets at the end in order to give them preference						
					if (self.__type == UI_TYPE.PANEL) {
						var _n_common = array_length(self.getChildren(-1));
						var _common = self.getChildren(-1);
						for (var _i=0; _i<_n_common; _i++)	array_push(_a, _common[_i]);
							
						// Descendants of common widgets 
						for (var _i=0; _i<_n_common; _i++) {
							var _b = _common[_i].getDescendants();				
							var _m = array_length(_b);
							for (var _j=0; _j<_m; _j++)		array_push(_a, _b[_j]);
						}
					}
						
					return _a;
				
				}
			
				/// @method				destroy()
				/// @description		Destroys the current widget	and all its children (recursively)
				self.destroy = function() {
					UI.__logMessage("Destroying widget with ID '"+self.__ID+"' from containing Panel '"+self.getContainingPanel().__ID+"' on tab "+string(self.getContainingTab()), UI_MESSAGE_LEVEL.INFO);
					
					// Delete surface
					if (surface_exists(self.__surface_id))	surface_free(self.__surface_id);
					
					if (self.__type == UI_TYPE.PANEL) {						
						for (var _i=0, _n=array_length(self.__tabs); _i<_n; _i++) {
							for (var _m=array_length(self.__tabs[_i]), _j=_m-1; _j>=0; _j--) {
								//self.__children[_i].destroy();
								self.__tabs[_i][_j].destroy();
							}
						}
						// Destroy common widgets too
						for (var _n=array_length(self.__common_widgets), _i=_n-1; _i>=0; _i--) {
							self.__common_widgets[_i].destroy();
						}
						self.__close_button = undefined;
						self.__tab_button_control = undefined;
						UI.__destroy_widget(self);
						UI.__currentlyHoveredPanel = noone;
						
						if (self.__modal) {
							var _n = array_length(UI.__panels);
							for (var _i=0; _i<_n; _i++) {
								if (UI.__panels[_i].__ID != self.__ID) {
									UI.__panels[_i].setEnabled(true);
								}
							}
						}
					}
					else {						
						// Delete children
						for (var _n=array_length(self.__children), _i=_n-1; _i>=0; _i--) {
							self.__children[_i].destroy();						
						}
						// Remove from parent panel						
						if (self.__parent.__type == UI_TYPE.PANEL) {
							var _t = self.getContainingTab();
							self.__parent.remove(self.__ID, _t);
						}
						else {
							self.__parent.remove(self.__ID);
						}
						UI.__destroy_widget(self);
					}					
					self.__children = [];					
					UI.__currentlyDraggedWidget = noone;
				}		
				
				/// @method				getChildrenBoundingBoxAbsolute()
				/// @description		Gets the dimensions of the minimum bounding rectangle that contains all chidren in the current tab, *relative to the screen*. <br>
				///						Does not consider common elements.
				/// @return				{Struct}	the screen dimensions (x, y, width and height) for the minimum bounding box
				self.getChildrenBoundingBoxAbsolute = function() {
					var _min_y=99999999;
					var _max_y=-99999999;
					var _min_x=99999999;
					var _max_x=-99999999;
					for (var _i=0; _i<array_length(self.__children); _i++) {
						var _child = self.__children[_i];
						var _dim = _child.getDimensions();
						// Temporary (:D) fix for text width/height being 0
						var _this_w = _child.__type == UI_TYPE.TEXT ? UI_TEXT_RENDERER(_child.getText()).get_width() : _dim.width;
						var _this_h = _child.__type == UI_TYPE.TEXT ? UI_TEXT_RENDERER(_child.getText()).get_height() : _dim.height;
						_min_y = min(_min_y, _dim.y);
						_max_y = max(_max_y, _dim.y+_this_h);
						_min_x = min(_min_x, _dim.x);
						_max_x = max(_max_x, _dim.x+_this_w);
					}
					var _w = _max_x - _min_x;
					var _h = _max_y - _min_y;
					return {x: _min_x, y: _min_y, width: _w, height: _h};						
				}
				
				/// @method				getChildrenBoundingBoxRelative()
				/// @description		Gets the dimensions of the minimum bounding rectangle that contains all chidren in the current tab, *relative to its container coordinates*. <br>
				///						Does not consider common elements.
				/// @return				{Struct}	the parent-based dimensions (x, y, width and height) for the minimum bounding box
				self.getChildrenBoundingBoxRelative = function() {
					var _min_y=99999999;
					var _max_y=-99999999;
					var _min_x=99999999;
					var _max_x=-99999999;
					for (var _i=0; _i<array_length(self.__children); _i++) {
						var _child = self.__children[_i];
						var _dim = _child.getDimensions();
						// Temporary (:D) fix for text width/height being 0
						var _this_w = _child.__type == UI_TYPE.TEXT ? UI_TEXT_RENDERER(_child.getText()).get_width() : _dim.width;
						var _this_h = _child.__type == UI_TYPE.TEXT ? UI_TEXT_RENDERER(_child.getText()).get_height() : _dim.height;
						_min_y = min(_min_y, _dim.relative_y);
						_max_y = max(_max_y, _dim.relative_y+_this_h);
						_min_x = min(_min_x, _dim.relative_x);
						_max_x = max(_max_x, _dim.relative_x+_this_w);
					}
					var _w = _max_x - _min_x;
					var _h = _max_y - _min_y;
					return {x: _min_x, y: _min_y, width: _w, height: _h};						
				}
			
			#endregion		
		}
	
	#endregion
	
#endregion

#region Utility

	/// @function					sprite_scale(_sprite, _image, _scale_x, _scale_y = _scale_x)
	/// @description				scales an existing sprite frame by the specified scale and returns a new scaled sprite
	/// @param	{Asset.GMSprite}	_sprite		the sprite to scale
	/// @param	{Real}				_image		the image of the sprite to scale
	/// @param	{Real}				_scale_x	the x scale
	/// @param	{Real}				[_scale_y]	the y scale, by default equal to the x scale
	/// @return	{Asset.GMSprite}	the new scaled sprite
	function sprite_scale(_sprite, _image, _scale_x, _scale_y = _scale_x) {
		var _w = sprite_exists(_sprite) ? sprite_get_width(_sprite) : 0;
		var _h = sprite_exists(_sprite) ? sprite_get_height(_sprite) : 0;
		var _s = surface_create(_w * _scale_x, _h * _scale_y);
		surface_set_target(_s);
		draw_clear_alpha(c_black, 0);
		if (sprite_exists(_sprite)) draw_sprite_ext(_sprite, _image, 0, 0, _scale_x, _scale_y, 0, c_white, 1);
		surface_reset_target();
		var _spr = sprite_create_from_surface(_s, 0, 0, _w * _scale_x, _h * _scale_y, false, false, sprite_get_xoffset(_sprite) * _scale_x, sprite_get_yoffset(_sprite) * _scale_y);
		surface_free(_s);
		return _spr;
	}

	/// @function					room_x_to_gui(_x)
	/// @description				returns the GUI coordinate corresponding to the specified room x posiition
	/// @param	{Real}				_x		the room x
	/// @return	{Real}				the GUI x coordinate
	function room_x_to_gui(_x) {
		return (_x-camera_get_view_x(CAMERA)) * display_get_gui_width() / camera_get_view_width(CAMERA);
	}
	
	/// @function					room_y_to_gui(_y)
	/// @description				returns the GUI coordinate corresponding to the specified room y posiition
	/// @param	{Real}				_y		the room y
	/// @return	{Real}				the GUI y coordinate
	function room_y_to_gui(_y) {
		return (_y-camera_get_view_y(CAMERA)) * display_get_gui_height() / camera_get_view_height(CAMERA);
	}


#endregion

#region GM Text Renderer
	
	function text_renderer(_text) constructor {
		self.text = _text;
		self.draw = function(_x, _y) {
			draw_text(_x, _y, self.text);
			return self;
		}
		self.get_text = function() {
			return self.text;
		}
		self.get_width = function() {
			return string_width(self.text);
		}
		self.get_height = function() {
			return string_height(self.text);
		}
		self.get_left = function(_x) {
			return draw_get_halign() == fa_left ? _x : (draw_get_halign() == fa_right ? _x - self.get_width() : _x - self.get_width()/2);
		}
		self.get_right = function(_x) {
			return draw_get_halign() == fa_right ? _x : (draw_get_halign() == fa_left ? _x - self.get_width() : _x + self.get_width()/2);
		}
		self.get_top = function(_y) {
			return draw_get_valign() == fa_top ? _y : (draw_get_valign() == fa_bottom ? _y - self.get_height() : _y - self.get_height()/2);
		}
		self.get_bottom = function(_y) {
			return draw_get_valign() == fa_bottom ? _y : (draw_get_valign() == fa_top ? _y - self.get_height() : _y + self.get_height()/2);
		}
		return self;
	}

#endregion