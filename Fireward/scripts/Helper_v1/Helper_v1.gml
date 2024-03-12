#region Visual Functions
	function draw_setup(_font, _color, _halign, _valign) {
		draw_set_font(_font);
		draw_set_color(_color);
		draw_set_halign(_halign);
		draw_set_valign(_valign);
	}
	function draw_reset() {
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	function draw_angle_line(_x, _y, _angle, _length) {
		draw_line(_x, _y, _x + _length * dcos(_angle), _y - _length * dsin(_angle)); 
		var _points = get_line_points(_x, _y, _x + _length * dcos(_angle), _y - _length * dsin(_angle), 5);
		for(var _i = 0; _i < array_length(_points); ++_i) {
			draw_sprite(SPR_GUN, 0, _points[_i].x, _points[_i].y);	
		}
	}
	function draw_spiral(_x, _y, _radius, _vertex_count, _spiral_count, _spiral_grow, _line_width) {
		for (var i = 0; i < _vertex_count * _spiral_count; i++) {
		    var angle1 = (i / _vertex_count)       * 360 + image_angle;
		    var angle2 = ((i + 1) / _vertex_count) * 360 + image_angle;

		    // i * spiral_grow is how much longer an angle should be
		    draw_line_width(
		        _x + lengthdir_x(_radius + i * _spiral_grow, angle1),
		        _y + lengthdir_y(_radius + i * _spiral_grow, angle1),
		        _x + lengthdir_x(_radius + (i + 1) * _spiral_grow, angle2),
		        _y + lengthdir_y(_radius + (i + 1) * _spiral_grow, angle2),
		        _line_width
		    );
		}
	}
#endregion
#region Math Functions
	#region Trig
		function apply_sin(_value, _amplitude, _speed, _abs) {
			if(_abs) {
				return (_value+(_amplitude * (abs(sin(current_time * _speed)))));
			} else {
				return (_value+(_amplitude * (sin(current_time * _speed))));
			}
		}
	
		function approach(_start, _target, _change) {
			return _start < _target ? min(_start + _change, _target)												 : max(argument0 - argument2, argument1);
		}
		
		function angle_line_collision(_x, _y, _angle, _length, _collider) {
		    // invert 1 or -1.
			return {px: _x + _length * dcos(_angle), py: _y - _length * dsin(_angle), col: collision_line(_x, _y, _x + _length * dcos(_angle), _y - _length * dsin(_angle), _collider, false, false)};
		}
	#endregion
	#region Statistics
		function weighted_chance(_chances) {
			// example: weighted_chance({a: {return_value: true, 10}, b: {return: false, 5}});
			var _n = 0;
			var keys = variable_struct_get_names(_chances);
			for (var i = array_length(keys)-1; i >= 0; --i) {
			    var _option = keys[i];
				var _return_value = _chances[$ _option].return_value;
			    var _value = _chances[$ _option].weight;
				/* Use option and return and value here */
		
				_n += _value;
			}
	
			_n = random(_n);	
	
			var keys = variable_struct_get_names(_chances);
			for (var i = array_length(keys)-1; i >= 0; --i) {
			    var _option = keys[i];
				var _return_value = _chances[$ _option].return_value;
			    var _value = _chances[$ _option].weight;
		
		        if (_value <= 0) continue;
		        _n -= _value;
		        if (_n < 0) return _return_value;
		    }
    
		    return _chances[$ keys[0]].return_value
		}		
	#endregion
#endregion
#region Array Functions
	function get_line_points(_start_x, _start_y, _end_x, _end_y, _points) {
		// empty array to store points.
		var _points_array = [];
	
		// calculate the distance of x and y.
		var _x_distance = _end_x - _start_x;
		var _y_distance = _end_y - _start_y;
	
		// loop through the points.
		for(var _p = 0; _p < _points; ++_p) {
			// insert the x and y into the given index based on the formula.
			array_push(_points_array, {x: _x_distance * (_p / _points), y: _y_distance * (_p / _points)});
		}
	
		// return the array.
		return _points_array;
	}	
	#region Array 2D
		/// @func array_2d_height
		/// @param 2DArray
		function array_2d_height(_array) {
		    return array_length(_array);
		}

		/// @func array_2d_length
		/// @param 2DArray
		/// @param Entry
		function array_2d_length(_array, _n = 0) {
		    // Used to determine _n as an optional argument
		    return array_length(_array[_n]);    
		}


		/// @func array_2d_create
		/// @param Height
		/// @param Length
		/// @param [Value]
		function array_2d_create(_height, _length, _value = 0) {
		   var _array;
		   array[_height] = 0;
		  for(var _i = 0; _i < _height; ++_i) {
		    _array[_i] = array_create(_length, _value);
		  }
		  return _array;
		}

		/// @func array_2d_resize
		/// @param 2DArray
		/// @param Height
		/// @param [Length]
		function array_2d_resize(_array, _height, _length) {
			// Resize height
			array_resize(_array, _height);
	
		        // Resize Lengths 
			if (_length != undefined) {
				for(var _i = 0; _i < _height; ++_i) {
					array_resize(_array[@ _i], _length);
				}
			}
		}

		/// @func array_2d_get
		/// @param array2D
		/// @param height
		/// @param length
		function array_2d_get(_array2D, _height, _length) {
			return _array2D[_height][_length];	
		}

		/// @func array_2d_set
		/// @param array2D
		/// @param height
		/// @param length
		/// @param value
		function array_2d_set(_array2D, _height, _length, _value) {
			_array2D[@ _height][@ _length] = _value;	
		}
	#endregion
#endregion
#region Data Structure Functions
	#region DS TO STRUCT ARRAY
		/*
		Created by: TabularElf. https://tabularelf.com/
		Clarification: This is a set of scripts that allow you to convert ds_maps, ds_lists and ds_grids into astructs/arrays and vice versa.
		Addtionally, ds_maps and ds_lists will automatically convert ds_map/ds_list children into structs/arrays, and vice versa.
		You can disable this by assigning the optional argument [convert_children] to false when calling the function.
		Note: This does not convert any data structures that are stored within or as ds_grids and vice versa.
		Also to access a cell from an array2D of a ds_grid, you will do the following.
		grid[cell_x][cell_y]
		*/

		function __ds_struct_array_conversion_throw(_string) {
			var _callStack = debug_get_callstack();
			array_delete(_callStack, 0, 1);
			throw {
				message: _string,
				longMessage: _string,
				stacktrace: _callStack
			}
		}

		/// @func ds_map_from_struct(struct)
		/// @param struct
		/// @param [convert_children]
		function ds_map_from_struct(_struct, _nested = true) {
	
			// Error Checking
			if !is_struct(_struct) {
				__ds_struct_array_conversion_throw("Not a struct");   
			}
	
			var _structKeys = variable_struct_get_names(_struct);
	
			var _map = ds_map_create();
			var _len = array_length(_structKeys);
			var _i = 0;
			repeat(_len) {
				var _key = _structKeys[_i];
				if (_nested) {
					if is_struct(_struct[$ _key]) {
						// Struct
						ds_map_add_map(_map, _key, ds_map_from_struct(_struct[$ _key]));
						++_i;
						continue;
					} else if is_array(_struct[$ _key]) {
						// Array
						ds_map_add_list(_map, _key, ds_list_from_array(_struct[$ _key]));
						++_i;
						continue;
					}
				}
		
				_map[? _structKeys[_i]] = _struct[$ _structKeys[_i]];
				++_i;
			}
	
			return _map;
		}

		/// @func ds_map_to_struct(ds_map)
		/// @param ds_map
		/// @param [convert_children]
		function ds_map_to_struct(_map, _nested = true) {
		
			// Error Checking
			if !ds_exists(_map, ds_type_map) {
				__ds_struct_array_conversion_throw("Not a ds_map");      
			}
	
			var _mapKeys = ds_map_keys_to_array(_map);
	
			var _struct = {};
			var _len = array_length(_mapKeys);
			var _i = 0;
			repeat(_len) {
				var _key = _mapKeys[_i];
				if (_nested) {
					if ds_map_is_map(_map, _key) {
					// For DS_MAPs
						_struct[$ _key] = ds_map_to_struct(_map[? _key]);
						++_i;
						continue;
				} else if ds_map_is_list(_map, _key) {
						// The DS_LIST
						_struct[$ _key] = ds_list_to_array(_map[? _key]);	
						++_i;
						continue;
					} 
				}
		
				// For everything else
				_struct[$ _key] = _map[? _key];	
				++_i;
			}
	
			return _struct;
		}

		/// @func ds_list_from_array(array)
		/// @param array
		/// @param [convert_children]
		function ds_list_from_array(_array, _nested = true) {
	
			// Error Checking
			if !is_array(_array) {
				__ds_struct_array_conversion_throw("Not an array");   
			}
	
			var _len = array_length(_array);
	
			var _list = ds_list_create();
			ds_list_set(_list,_len-1,0);
			var _i = 0;
			repeat(_len) {
				var _index = _array[_i];
		
				if (_nested) {
					if is_struct(_index) {
						// Struct
						_list[| _i] = _index;
						ds_list_mark_as_map(_list, _i);
						++_i;
						continue;
					} else if is_array(_index) {
						// Array
						_list[| _i] = _index;
						ds_list_mark_as_list(_list, _i);
						++_i;
						continue;
					}
				}
		
				_list[| _i] = _index;
				++_i;
			}
	
			return _list;
		}

		/// @func ds_list_to_array(ds_list)
		/// @param ds_list
		/// @param [convert_children]
		function ds_list_to_array(_list, _nested = true) {

			// Error Checking
			if !ds_exists(_list, ds_type_list) {
				__ds_struct_array_conversion_throw("Not a ds_list");   
			}
	
			var _listSize = ds_list_size(_list);
	
			var _array = array_create(_listSize-1,0);
			var _len = _listSize;
			var _i = 0;
			repeat(_len) {
				var _index = _list[| _i];
		
				if (_nested) {
					if ds_list_is_map(_list, _i) {
						_array[_i] = ds_map_to_struct(_index);
						++_i;
						continue;
				} else if ds_list_is_list(_list, _i) {
						_array[_i] = ds_list_to_array(_index);
						++_i;
						continue;
					}
				}
		
				_array[_i] = _index;
				++_i;
		    }
   
			return _array;
		}

		/// @func ds_grid_from_array2D(array2D)
		/// @param array2D
		function ds_grid_from_array2D(_array) {
		    // Error Checking
		   if !is_array(_array) {
				__ds_struct_array_conversion_throw("Not an array");     
			}
	
			var _width = array_length(_array);
	
			var _grid = ds_grid_create(_width,1);
			var _gridHeight = 1;
			var _i = 0;
			repeat(_width)  {
				if (is_array(_array[_i])) {
			
					var _height = array_length(_array[_i]);
					if _height > _gridHeight {
						ds_grid_resize(_grid,ds_grid_width(_grid)-1,_height);
						_gridHeight = _height;
					}
			
					var _j = 0;
					repeat(_height) {
						_grid[# _i, _j] = _array[_i][_j];
						++_j;
					}
				}
				++_i;
			}
	
			return _grid;
		}

		/// @func ds_grid_to_array2D(ds_grid)
		/// @param ds_grid
		function ds_grid_to_array2D(_grid) {
			// Error Checking
			if !ds_exists(_grid, ds_type_grid) {
				__ds_struct_array_conversion_throw("Not a ds_grid");   
			}

			var _gridWidth = ds_grid_width(_grid);
			var _gridHeight = ds_grid_height(_grid);
	
			var _array = array_create(_gridWidth,0);
			var _i = 0;
			repeat(_gridWidth) {
				_array[_i] = array_create(_gridHeight, 0);
		
				var _j = 0;
				repeat(_gridHeight) {
					_array[_i][_j] = _grid[# _i, _j];
					++_j;
				}
				++_i;
			}
	
			return _array;
		}
	#endregion
#endregion
#region Twerp
	///@func twerp(TwerpType, start, end, pos, [looped], [option1], [option2]);
	function twerp(_type, _start, _end, _pos, _looped = false) {
	  _type = clamp(_type,0,TwerpType.count);
	  _pos = clamp(_looped ? _pos % 1 : _pos,0,1);
	  var _chng = _end-_start;
	  var _mid = (_start+_end) / 2;

	  #region Tween Types
	  enum TwerpType
	  {
	  	linear,
	  	inout_back,	in_back, out_back,
	  	inout_bounce,	out_bounce, in_bounce,
	  	inout_circle,	out_circle, in_circle,
	  	inout_cubic,	out_cubic, 	in_cubic,
	  	inout_elastic, out_elastic,	in_elastic,
	  	inout_expo,	out_expo,	in_expo,
	  	inout_quad,	out_quad,	in_quad,
	  	inout_quart, out_quart, in_quart,
	  	inout_quint, out_quint, in_quint,
	  	inout_sine, out_sine, in_sine,
	  	count
	  }
	  #endregion

	  switch(_type)
	  {
	  	case TwerpType.linear: return lerp(_start,_end,_pos); //Why are you using this?
	  	#region Back
	  	// Optional Argument: Bounciness - Default: 1.5
	  	#macro Twerp_Back_DefaultBounciness 1.5
	  	case TwerpType.inout_back:
	  				var _b = (argument_count > 5) ? argument[5] : Twerp_Back_DefaultBounciness;	
	  				return (_pos < .5) ? twerp(TwerpType.in_back,_start,_mid,_pos*2,_b) 
	  												   : twerp(TwerpType.out_back,_mid,_end,(_pos-.5)*2,_b);

	  	case TwerpType.in_back:
	  				var _b = (argument_count > 5) ? argument[5] : Twerp_Back_DefaultBounciness;
	  				return _chng * _pos * _pos * ((_b + 1) * _pos - _b) + _start

	  	case TwerpType.out_back:			
	  				var _b = (argument_count > 5) ? argument[5] : Twerp_Back_DefaultBounciness;
	  				_pos -= 1;
	  				return _chng * (_pos * _pos * ((_b + 1) * _pos + _b) + 1) + _start;
				
	  	#endregion
	  	#region Bounce
	  	//No Optional Arguments
	  	#macro Twerp_Bounce_DefaultBounciness 7.5625
	
	  	case TwerpType.inout_bounce:
	  			return (_pos < 0.5) ? twerp(TwerpType.in_bounce,_start, (_start + _end) / 2, _pos*2)
	  												  : twerp(TwerpType.out_bounce,(_start + _end) / 2, _end, (_pos-.5)*2);
												
	  	case TwerpType.out_bounce:
	  				if (_pos < 1/2.75) 
	  					return _chng * (Twerp_Bounce_DefaultBounciness * _pos * _pos) + _start;
	  				else if (_pos < 2/2.75) 
	  				{
	  				  _pos -= 1.5/2.75; 
	  				  return _chng * (Twerp_Bounce_DefaultBounciness * _pos * _pos + 3/4) + _start;
	  				}
	  				else if (_pos < 2.5/2.75)
	  				{
	  				  _pos -= 2.25/2.75; 
	  				  return _chng * (Twerp_Bounce_DefaultBounciness * _pos * _pos + 15/16) + _start; 
	  				}

	  				_pos -= 2.625/2.75;
	  				return _chng * (Twerp_Bounce_DefaultBounciness * _pos * _pos + 63/64) + _start;
				
	  	case TwerpType.in_bounce:
	  				_chng = _end-_pos;
	  				_pos = 1-_pos;
	  				return _chng - twerp(TwerpType.out_bounce,_start,_end,_pos,Twerp_Bounce_DefaultBounciness)+_start;
				
	  	#endregion
	  	#region Circle
	  	//No Optional Arguments
	  	case TwerpType.inout_circle:
	  				return (_pos < .5) ? twerp(TwerpType.in_circle,_start,_mid,_pos*2)
	  												   : twerp(TwerpType.out_circle,_mid,_end,(_pos-.5)*2);
												 
	  	case TwerpType.out_circle:
	  				_pos--;
	  				return _chng * sqrt(1 - _pos * _pos) + _start;
				
	  	case TwerpType.in_circle:
	  				return -_chng * (sqrt(1 - _pos*_pos)-1) + _start;
				
	  	#endregion
	  	#region Cubic
	  	//No Optional Arguments
	  	case TwerpType.inout_cubic:
	  				return (_pos < .5) ? twerp(TwerpType.in_cubic,_start,_mid,_pos*2) 
	  												   : twerp(TwerpType.out_cubic,_mid,_end,(_pos-.5)*2);
	  	case TwerpType.out_cubic:
	  				return _chng * (power(_pos - 1, 3) + 1) + _start;
	  	case TwerpType.in_cubic:
	  				return _chng * power(_pos, 3) + _start;
	  	#endregion
	  	#region Elastic
	  	// Optional Argument 1: Elasticity <0-1> - Default: .3
	  	// Optional Argument 2: Duration - Default: 5
	  	case TwerpType.inout_elastic:
	  				var _e = (argument_count > 5) ? argument[5] : 0.3;
	  				var _d = (argument_count > 6) ? argument[6] : 5.0;
				
	  				return (_pos < .5) ? twerp(TwerpType.in_elastic,_start,_mid,_pos*2,_e,_d)
	  												   : twerp(TwerpType.out_elastic,_mid,_end,(_pos-.5)*2,_e,_d);
												 
	  	case TwerpType.out_elastic:
	  				var _s,_p;
	  				var _e = (argument_count > 5) ? argument[5] : 0.3;
	  				var _d = (argument_count > 6) ? argument[6] : 5.0;

	  				if (_pos == 0 || _chng == 0) return _start;
	  				if (_pos == 1) return _end;

	  				_p = _d * _e;
	  				_s = (sign(_chng) == -1) ? _p * 0.25 : _p / (2 * pi) * arcsin (1);

	  				return _chng * power(2, -10 * _pos) * sin((_pos * _d - _s) * (2 * pi) / _p ) + _chng + _start;
	  	case TwerpType.in_elastic:
	  				var _s,_p;
				
	  				var _e = (argument_count > 5) ? argument[5] : 0.3;
	  				var _d = (argument_count > 6) ? argument[6] : 5.0;

	  				if (_pos == 0 || _chng == 0) return _start; 
	  				if (_pos == 1) return _end;

	  				_p = _d * _e;
	  				_s = sign(_chng) == -1 ? _p * 0.25 : _p / (2 * pi) * arcsin(1);

	  				return -(_chng * power(2,10 * (--_pos)) * sin((_pos * _d - _s) * (pi * 2) / _p)) + _start;

	  	#endregion
	  	#region Expo
	  	//No Optional arguments
	  	case TwerpType.inout_expo:
	  			  return (_pos < .5) ? twerp(TwerpType.in_expo,_start,_mid,_pos*2) 
	  												   : twerp(TwerpType.out_expo,_mid,_end,(_pos-.5)*2);
												 
	  	case TwerpType.out_expo:
	  				return _chng * (-power(2, -10 * _pos) + 1) + _start;
				
	  	case TwerpType.in_expo:
	  				return _chng * power(2, 10 * (_pos - 1)) + _start;
				
	  	#endregion
	  	#region Quad
	  	//No Optional Arguments
	  	case TwerpType.inout_quad:
	  				return (_pos < .5) ? twerp(TwerpType.in_quad,_start,_mid,_pos*2) 
	  												   : twerp(TwerpType.out_quad,_mid,_end,(_pos-.5)*2);
	  	case TwerpType.out_quad:
	  				return -_chng * _pos * (_pos - 2) + _start;
				
	  	case TwerpType.in_quad:
	  				return _chng * _pos * _pos + _start;

	  	#endregion
	  	#region Quart
	  	//No Optional Arguments
	  	case TwerpType.inout_quart:
	  				return (_pos < .5) ? twerp(TwerpType.in_quart,_start,_mid,_pos*2) 
	  												   : twerp(TwerpType.out_quart,_mid,_end,(_pos-.5)*2);

	  	case TwerpType.out_quart:
	  				return -_chng * (((_pos - 1) * (_pos - 1) * (_pos - 1) * (_pos - 1)) - 1) + _start;
				
	  	case TwerpType.in_quart:
	  				return _chng * (_pos * _pos * _pos * _pos) + _start;
				
	  	#endregion
	  	#region Quint
	  	//No Optional Arguments
	  	case TwerpType.inout_quint:
	  				return _pos < .5 ? twerp(TwerpType.in_quint,_start,_mid,_pos*2) 
	  												 : twerp(TwerpType.out_quint,_mid,_end,(_pos-.5)*2);
												 
	  	case TwerpType.out_quint:
	
	  				return _chng * ((_pos - 1) * (_pos -1) * (_pos -1) * (_pos -1) * (_pos -1) + 1) + _start;
				
	  	case TwerpType.in_quint:
	  				return _chng * _pos * _pos * _pos * _pos * _pos + _start;
				
	  	#endregion
	  	#region Sine
	  	//No Optional Arguments
	  	#macro Twerp_Sine_Half_Pi 1.57079632679
	  	case TwerpType.inout_sine:
	  				return _chng * 0.5 * (1 - cos(pi * _pos)) + _start;
				
	  	case TwerpType.out_sine:
	  				return _chng * sin(_pos * Twerp_Sine_Half_Pi) + _start;
				
	  	case TwerpType.in_sine:
	  				return _chng * (1 - cos(_pos * Twerp_Sine_Half_Pi)) + _start;
				
	  	#endregion
	  }
	}
#endregion
#region True State
#region --SYSTEM--
/// @func truestate_system_init
function truestate_system_init() {

	/// Initilize the variables required for the state engine.
	/// Call this on any object you want to use the state machine in the create event.

	//These are important for the state machine.
	#macro TRUESTATE_STEP 0
	#macro TRUESTATE_DRAW 1
	#macro TRUESTATE_DRAW_GUI 4
	#macro TRUESTATE_NEW 2
	#macro TRUESTATE_FINAL 3
	#macro TRUESTATE_QUEUE 9999 

	truestate_current_state  = noone;
	truestate_default_state  = noone;
	truestate_previous_state = noone;
	truestate_next_state     = noone;
	truestate_state_script   = noone;

	truestate_switch_locked  = false;
	truestate_stack_locked   = false;
	truestate_reset_state    = false;
	truestate_in_queue       = false;

	truestate_map   = ds_map_create();
	truestate_names = ds_map_create(); 
	truestate_vars  = ds_map_create(); //Useful for storing variables specific to a specific state
	truestate_stack = ds_stack_create();
	truestate_queue = ds_queue_create();

	truestate_timer = 0;
}

/// @func truestate_create_state(state_id,script, *name)
/// @param state_id The unique ID for this state within this object.  An enum, macro, or string.
/// @param script The script that will handle step and draw for this object.
/// @param *name Optional name for the state.  Good for drawing out when debugging.
function truestate_create_state(_id, _script, _name) {
	if(0) return argument[0]; //Removes the IDE warning when allowing optional arguments
	
	ds_map_replace(truestate_map, _id, _script);
	ds_map_replace(truestate_names,_id,_name != undefined ? _name : script_get_name(argument[1]));
	if(ds_map_size(truestate_map) == 1)
		truestate_set_default(_id);
}

/// @func truestate_set_default(state_id)
function truestate_set_default(_id) {
	/// Sets the default/first state for the object.  Called only in the create event, typically after you've defined
	/// all the states for this object.
  if(truestate_current_state == _id) exit;
	truestate_current_state = _id;
	truestate_state_script = ds_map_find_value(truestate_map,_id);    

	truestate_default_state = truestate_current_state;

	truestate_next_state=truestate_current_state;
	ds_stack_push(truestate_stack,truestate_current_state);
	script_execute(truestate_state_script,TRUESTATE_NEW);
}

/// @func truestate_enqueue(state_id, *state_id...)
/// Adds any number of states to the queue.
/// @param state_id The next state to execute
/// @param *state_id... as many other states as you want.
function truestate_enqueue() {
	
	var _i=0;
	repeat(argument_count) {
		var _state = argument[_i];
		if(truestate_state_exists(_state))
			ds_queue_enqueue(truestate_queue,_state);	
		else
			show_debug_message("Tried to queue a non-existent state");
		_i++;
	}
}

/// @func truestate_queue_start 
function truestate_queue_start() {
	/// Begins the state queue.
	truestate_in_queue = ds_queue_size(truestate_queue) > 0;
	truestate_switch();
}

/// @func truestate_switch(*state_id, *lock)
/// @param *state_id
/// @param *lock_switch
function truestate_switch(_id, _lock) {
	if(0) return argument[0]; //Removes the IDE warning when allowing optional arguments
	/// Switches to a new state at the end of this step.
	/// If you lock the state switch, any other state switches will be ignored until this change happens 
	/// the following step.
	/// Finally, if you are in the middle of executing a state queue, any state switch will be
	/// interpreted as a "go to next".  You can call this script with no arguments in that case, or to return to the default state.

	//Queue handling
	if(truestate_switch_locked) {
		if(truestate_in_queue) {	
			//The locked state will interrupt the queue
			ds_queue_clear(truestate_queue);
			truestate_in_queue=false;
		}
		exit;
	}
	
	if(truestate_in_queue && ds_queue_size(truestate_queue)>0) {
		truestate_next_state = TRUESTATE_QUEUE;
		exit;
	}
	truestate_in_queue = false;

	//Switch to default
	if(_id == undefined) {
		truestate_next_state = truestate_default_state;
		exit;
	}


	if(ds_map_exists(truestate_map,_id)) {
	  truestate_next_state = _id;
	}	else {
	  show_debug_message("Tried to switch to a non-existent state("+string(_id)+").  Moving to default state.")
	  truestate_next_state = truestate_default_state;
	}

	//Push to stack if not locked.
	if(!truestate_stack_locked && ds_stack_top(truestate_stack) != truestate_next_state) 
	  ds_stack_push(truestate_stack,truestate_next_state);
	else
		truestate_stack_locked=false; //Reset the lock on the stack.

	if(_lock != undefined)
	  truestate_switch_locked = _lock;
}

/// @func truestate_switch_previous Returns to the previous state.
function truestate_switch_previous() {
	if(truestate_in_queue) {	
		truestate_switch();
		exit;
	}
	if(ds_stack_empty(truestate_stack)) {
		truestate_switch(truestate_default_state);
		exit;
	}

	ds_stack_pop(truestate_stack);
	truestate_stack_locked = true;
	truestate_switch(ds_stack_top(truestate_stack));
}
#endregion
#region --Event Functions--
/// @func truestate_begin_step
/// Script that executes before all other logic has been performed for the object.
/// Will perform the ACTUAL state switching, and also resets timers.
function truestate_begin_step() {

	var _is_new = false;
	truestate_switch_locked=false; //Release the lock

	if(truestate_next_state != truestate_current_state || truestate_reset_state) { 
		//Switch to the new state
	  script_execute(truestate_state_script,TRUESTATE_FINAL);
	
		truestate_previous_state=truestate_current_state;
		truestate_reset_state=false;
		if(truestate_next_state == TRUESTATE_QUEUE) {
			 truestate_next_state=ds_queue_dequeue(truestate_queue);	
			 ds_stack_push(truestate_stack,truestate_next_state);
		}
	
	  truestate_current_state=truestate_next_state;
	  truestate_state_script=truestate_map[? truestate_current_state];
	  truestate_timer=0;
	  script_execute(truestate_state_script,TRUESTATE_NEW);
	  _is_new = true;
	}	else { 
		//Increment current state timer
	  truestate_timer++;
	  _is_new = false;
	}

	return _is_new;
}

/// @func truestate_cleanup
function truestate_cleanup() {
	/// Put in the cleanup event of the object.
	/// Cleans up all related data structures.
	script_execute(truestate_state_script,TRUESTATE_FINAL);
	ds_map_destroy(truestate_map);
	ds_map_destroy(truestate_names);
	ds_map_destroy(truestate_vars);
	ds_stack_destroy(truestate_stack);
	ds_queue_destroy(truestate_queue);
}

/// @func truestate_draw
function truestate_draw() {
	/// Call this in the draw event of your object.
	if(script_exists(truestate_state_script))
	  script_execute(truestate_state_script,TRUESTATE_DRAW)
	else
	  truestate_switch(truestate_default_state);
}

/// @func truestate_step
function truestate_step() {
	/// Call this in the step event of your object.
	if(script_exists(truestate_state_script))
	  script_execute(truestate_state_script,TRUESTATE_STEP)
	else
	  truestate_switch(truestate_default_state);
}
#endregion
#region --Helpers--

///@function truestate_draw_history(title, x, y, count, bg_color, bg_alpha);
function truestate_draw_history(_title, _x, _y, _count, _bg_color, _bg_alpha) {
	var _str = _title;
	var _stack = ds_stack_create();
	ds_stack_copy(_stack,truestate_stack);
	var _lineHeight = string_height(_str);
	_str+="\n\n"
	var _i = 0;
	while(_i < _count && !ds_stack_empty(_stack)) {
		_str += truestate_names[? ds_stack_pop(_stack)] +"\n";
		_i++;
	}
	ds_stack_destroy(_stack);
	var _margin = 20;
	draw_set_color(_bg_color);
	draw_set_alpha(_bg_alpha);
	draw_rectangle(_x,_y,	
									_x+string_width(_str)+_margin*2,
									_y+_lineHeight*(_count+1)+_margin*3,
									false);
	draw_set_alpha(1);
	draw_set_halign(fa_left); 
	draw_set_valign(fa_top); 
	draw_set_color(c_white);
	draw_text(_x+_margin,_y+_margin,_str);
}


/// @func truestate_clear_history
function truestate_clear_history() {

	/// Empties the previous state stack to prevent getting to big.
	/// Recommended you call it when you are at a "default" state.

	ds_stack_clear(truestate_stack);
	ds_stack_push(truestate_stack,truestate_current_state);
}

/// @func truestate_draw_current(x,y)
function truestate_draw_current(_x, _y) {

	/// Useful debug script that draws the current state name to the screen 
	/// as well as the current state timer value.

	var _str = truestate_names[? truestate_current_state] + " ("+string(truestate_timer)+")";
	draw_text(_x,_y,_str);
}

/// @func truestate_get_name(stateId)
function truestate_get_name(_id) {

	/// Returns the string name of the passed state.

	var _name = truestate_names[? _id];
	return _name == undefined ? "Undefined" : _name;
}

/// @func truestate_reset_current_state
/// Will repeat the current state as if it had just been switched to for the first time.
function truestate_reset_current_state() {
	truestate_reset_state=true;
}

#endregion
/// @description easy_tween
/// @param type
/// @param start
/// @param end
/// @param position
/// @param  <Option1>
/// @param  <Option2>
function easy_tween() {
	var _type = clamp(argument[0],0,TweenType.count);
	var _start = argument[1];
	var _end = argument[2];
	var _pos = argument[3];
	var _chng = _end-_start;
	var _mid = (_start+_end) / 2;

#region Tween Types
	enum TweenType
	{
		linear,
		inout_back,	out_back, in_back, 
		inout_bounce,	out_bounce, in_bounce,
		inout_circle,	out_circle, in_circle,
		inout_cubic,	out_cubic, 	in_cubic,
		inout_elastic, out_elastic,	in_elastic,
		inout_expo,	out_expo,	in_expo,
		inout_quad,	out_quad,	in_quad,
		inout_quart, out_quart, in_quart,
		inout_quint, out_quint, in_quint,
		inout_sine, out_sine, in_sine,
		count
	}
	switch(_type)
	{
		case TweenType.linear: return lerp(_start,_end,_pos); //Why are you using this?
	#region Back
		// Optional Argument: Bounciness - Default: 1.5
	#macro EasyTween_Back_DefaultBounciness 1.5
		case TweenType.inout_back:
					var _b = (argument_count > 4) ? argument[4] : EasyTween_Back_DefaultBounciness;	
					return (_pos < .5) ? easy_tween(TweenType.in_back,_start,_mid,_pos*2,_b) 
													   : easy_tween(TweenType.out_back,_mid,_end,(_pos-.5)*2,_b);

		case TweenType.in_back:
					var _b = (argument_count > 4) ? argument[4] : EasyTween_Back_DefaultBounciness;
					return _chng * (_pos) * _pos * ((_b + 1) * _pos - _b) + _start

		case TweenType.out_back:			
					var _b = (argument_count > 4) ? argument[4] : EasyTween_Back_DefaultBounciness;
					_pos -= 1;
					return _chng * (_pos * _pos * ((_b + 1) * _pos + _b) + 1) + _start;
				
	#endregion
	#region Bounce
		//No Optional Arguments
	#macro EasyTween_Bounce_DefaultBounciness 7.5625

	#macro EasyTween_Bounce_Bounce1_Pos 1/2.75
	#macro EasyTween_Bounce_Bounce2_Pos 2/2.75
	#macro EasyTween_Bounce_Bounce3_Pos 2.25/2.75
	#macro EasyTween_Bounce_Bounce1_Change 1.5/2.75
	#macro EasyTween_Bounce_Bounce2_Change 2.25/2.75
	#macro EasyTween_Bounce_Bounce3_Change 2.625/2.75
	
		case TweenType.inout_bounce:
				return (_pos < 0.5) ? easy_tween(TweenType.in_bounce,_start, (_start + _end) / 2, _pos*2)
													  : easy_tween(TweenType.out_bounce,(_start + _end) / 2, _end, (_pos-.5)*2);
												
		case TweenType.out_bounce:
					if (_pos < 1/2.75) 
						return _chng * (EasyTween_Bounce_DefaultBounciness * _pos * _pos) + _start;
					else if (_pos < 2/2.75) 
					{
					  _pos -= 1.5/2.75; 
					  return _chng * (EasyTween_Bounce_DefaultBounciness * _pos * _pos + 3/4) + _start;
					}
					else if (_pos < 2.5/2.75)
					{
					  _pos -= 2.25/2.75; 
					  return _chng * (EasyTween_Bounce_DefaultBounciness * _pos * _pos + 15/16) + _start; 
					}

					_pos -= 2.625/2.75;
					return _chng * (EasyTween_Bounce_DefaultBounciness * _pos * _pos + 63/64) + _start;
				
		case TweenType.in_bounce:
					var _chng = _end-_pos;
					var _pos = 1-_pos;
					return _chng - easy_tween(TweenType.out_bounce,_start,_end,_pos,EasyTween_Bounce_DefaultBounciness)+_start;
				
	#endregion
	#region Circle
		//No Optional Arguments
		case TweenType.inout_circle:
					return (_pos < .5) ? easy_tween(TweenType.in_circle,_start,_mid,_pos*2)
													   : easy_tween(TweenType.out_circle,_mid,_end,(_pos-.5)*2);
												 
		case TweenType.out_circle:
					_pos--;
					return _chng * sqrt(1 - _pos * _pos) + _start;
				
		case TweenType.in_circle:
					return -_chng * (sqrt(1 - _pos*_pos)-1) + _start;
				
	#endregion
	#region Cubic
		//No Optional Arguments
		case TweenType.inout_cubic:
					return (_pos < .5) ? easy_tween(TweenType.in_cubic,_start,_mid,_pos*2) 
													   : easy_tween(TweenType.out_cubic,_mid,_end,(_pos-.5)*2);
		case TweenType.out_cubic:
					return _chng * (power(_pos - 1, 3) + 1) + _start;
		case TweenType.in_cubic:
					return _chng * power(_pos, 3) + _start;
	#endregion
	#region Elastic
		// Optional Argument 1: Elasticity <0-1> - Default: .3
		// Optional Argument 2: Duration - Default: 5
		case TweenType.inout_elastic:
					var _e = (argument_count > 4) ? argument[4] : 0.3;
					var _d = (argument_count > 5) ? argument[5] : 5.0;
				
					return (_pos < .5) ? easy_tween(TweenType.in_elastic,_start,_mid,_pos*2,_e,_d)
													   : easy_tween(TweenType.out_elastic,_mid,_end,(_pos-.5)*2,_e,_d);
												 
		case TweenType.out_elastic:
					var _s,_p;
					var _e = (argument_count > 4) ? argument[4] : 0.3;
					var _d = (argument_count > 5) ? argument[5] : 5.0;

					if (_pos == 0 || _chng == 0) return _start;
					if (_pos == 1) return _end;

					_p = _d * _e;
					_s = (sign(_chng) == -1) ? _p * 0.25 : _p / (2 * pi) * arcsin (1);

					return _chng * power(2, -10 * _pos) * sin((_pos * _d - _s) * (2 * pi) / _p ) + _chng + _start;
		case TweenType.in_elastic:
					var _s,_p;
				
					var _e = (argument_count > 4) ? argument[4] : 0.3;
					var _d = (argument_count > 5) ? argument[5] : 5.0;

					if (_pos == 0 || _chng == 0) return _start; 
					if (_pos == 1) return _end;

					_p = _d * _e;
					_s = sign(_chng) == -1 ? _p * 0.25 : _p / (2 * pi) * arcsin(1);

					return -(_chng * power(2,10 * (--_pos)) * sin((_pos * _d - _s) * (pi * 2) / _p)) + _start;

	#endregion
	#region Expo
		//No Optional arguments
		case TweenType.inout_expo:
				  return (_pos < .5) ? easy_tween(TweenType.in_expo,_start,_mid,_pos*2) 
													   : easy_tween(TweenType.out_expo,_mid,_end,(_pos-.5)*2);
												 
		case TweenType.out_expo:
					return _chng * (-power(2, -10 * _pos) + 1) + _start;
				
		case TweenType.in_expo:
					return _chng * power(2, 10 * (_pos - 1)) + _start;
				
	#endregion
	#region Quad
		//No Optional Arguments
		case TweenType.inout_quad:
					return (_pos < .5) ? easy_tween(TweenType.in_quad,_start,_mid,_pos*2) 
													   : easy_tween(TweenType.out_quad,_mid,_end,(_pos-.5)*2);
		case TweenType.out_quad:
					return -_chng * _pos * (_pos - 2) + _start;
				
		case TweenType.in_quad:
					return _chng * _pos * _pos + _start;

	#endregion
	#region Quart
		//No Optional Arguments
		case TweenType.inout_quart:
					return (_pos < .5) ? easy_tween(TweenType.in_quart,_start,_mid,_pos*2) 
													   : easy_tween(TweenType.out_quart,_mid,_end,(_pos-.5)*2);

		case TweenType.out_quart:
					return -_chng * (((_pos - 1) * (_pos - 1) * (_pos - 1) * (_pos - 1)) - 1) + _start;
				
		case TweenType.in_quart:
					return _chng * (_pos * _pos * _pos * _pos) + _start;
				
	#endregion
	#region Quint
		//No Optional Arguments
		case TweenType.inout_quint:
					return _pos < .5 ? easy_tween(TweenType.in_quint,_start,_mid,_pos*2) 
													 : easy_tween(TweenType.out_quint,_mid,_end,(_pos-.5)*2);
												 
		case TweenType.out_quint:
	
					return _chng * ((_pos - 1) * (_pos -1) * (_pos -1) * (_pos -1) * (_pos -1) + 1) + _start;
				
		case TweenType.in_quint:
					return _chng * _pos * _pos * _pos * _pos * _pos + _start;
				
	#endregion
	#region Sine
		//No Optional Arguments
	#macro EasyTween_Sine_Half_Pi 1.57079632679
		case TweenType.inout_sine:
					return _chng * 0.5 * (1 - cos(pi * _pos)) + _start;
				
		case TweenType.out_sine:
					return _chng * sin(_pos * EasyTween_Sine_Half_Pi) + _start;
				
		case TweenType.in_sine:
					return _chng * (1 - cos(_pos * EasyTween_Sine_Half_Pi)) + _start;
				
	#endregion
	}
}
#endregion
#endregion
#region Collision Functions
	function wall_escape(_collider) {
	//Moves the calling object in a spiral until it
	//is no longer in collision.
	var _dir=0;
	var _start_x=round(x);
	var _start_y=round(y);
	var _iterations=1;
	while(place_meeting(x,y,_collider))
	{   //This loop will find the closest free space by spiraling 
	    //outward looking for anywhere free of collision.
	    //The deeper lodged in a wall the player is, the longer this will take.
	    x=_start_x;
	    y=_start_y;
	    x+=lengthdir_x(1*_iterations,_dir);
	    y+=lengthdir_y(1*_iterations,_dir);
    
	    _dir+=45;
	    if(_dir>=360)
	    {
	        _dir=0;
	        _iterations++;
	    }
    
	    //show_debug_message("stuck in wall, breaking out");
	}
	return(_iterations);
}
	function collision(_hsp, _vsp, _collider){
		if(place_meeting(x+_hsp, y+_vsp, _collider)) {
			while(!place_meeting(x+sign(_hsp), y+sign(_vsp), _collider)) {
				x += sign(_hsp);
				y += sign(_vsp);
			}
			if(_hsp != 0) hsp = 0;
			if(_vsp != 0) vsp = 0;
		}
	}
#endregion
#region Particle System
function CreateParticle(_x,_y,_layer,_particle_object, _sprite,_dir,_spd,_length,_scale,_color,_end_on_anim){
	var _p = instance_create_layer(_x,_y,_layer,_particle_object);
	with(_p)
	{
		Spd = _spd
		Dir = _dir
		EndOnAnim = _end_on_anim
		Length = _length
		sprite_index = _sprite
		image_xscale = _scale
		image_yscale = _scale
		image_blend = _color
		
	}
	return _p;
}
#endregion
#region Better String
/// @func betterString(string, [index], [count])
/// @param string
/// @param [index]
/// @param [count]
function betterString(_string = "", _index, _count) constructor {
	var _str = !is_string(_string) ? string(_string) : _string;
	
	if !(is_undefined(_index) || is_undefined(_count)) {
		str = string_copy(_str, is_undefined(_index) ? 1 : _index+1, is_undefined(_count) ? string_length(_str) : _count);	
	} else {
		str = _str;	
	}
	
	static byteAt = function(_index) {
		return string_byte_at(str, _index+1);
	}
	
	static byteLength = function() {
		return string_byte_length(str);
	}
	
	static setByteAt = function(_index, _val) {
		if (_index+1 > string_length(str)) {
			static _buffer = buffer_create(1, buffer_fixed, 1);
			buffer_resize(_buffer, _index+1-length());
			buffer_seek(_buffer, buffer_seek_start, 0);
			buffer_fill(_buffer, 0, buffer_u8, 0x20, buffer_get_size(_buffer));
			str += buffer_read(_buffer, buffer_text);
			buffer_resize(_buffer, 1);
		}
		str = string_set_byte_at(str, _index+1, _val)
		return self;
	}
	
	static charAt = function(_index) {
		return string_char_at(str, _index+1);
	}
	
	static ordAt = function(_index) {
		return string_ord_at(str, _index+1);
	}
	
	static count = function(_substr) {
		return string_count(_substr, str);
	}
	
	static copy = function(_str, _index, _count) {
		str = string_copy(_str, _index+1, _count);
		return self;
	}
	
	static digits = function() {
		str = string_digits(str);
		return self;
	}
	
	static format = function(_total = 0, _dec = 2) {
		str = string_format(real(string_digits(str)), _total, _dec);
		return self;
	}
	
	static insert = function(_substr, _index) {
		var _substr2 = is_struct(_substr) ? _substr.toString() : _substr;
		str = string_insert(_substr2, str, _index+1);
		return self;	
	}
	
	static lastPos = function(_substr) {
		return string_last_pos(_substr, str)-1;	
	}
	
	static lastPosExt = function(_substr, _startPos) {
		return string_last_pos_ext(_substr, str, _startPos+1)-1;
	}
	
	static length = function() {
		return string_length(str);
	}
	
	static letters = function() {
		str = string_letters(str);
		return self;
	}
	
	static lettersdigits = function() {
		str = string_lettersdigits(str);
		return self;	
	}
	
	static lower = function() {
		str = string_lower(str);
		return self;
	}
	
	static pos = function(_substr) {
		return string_pos(_substr, str)-1;
	}
	
	static posExt = function(_substr, _startPos) {
		return string_pos_ext(_substr, str, _startPos+1)-1;
	}
	
	static replace = function(_substr, _newstr) {
		var _substr2 = is_struct(_substr) ? _substr.toString() : _substr;
		var _newstr2 = is_struct(_newstr) ? _newstr.toString() : _newstr;
		str = string_replace(str, _substr2, _newstr2);
		return self;
	}
	
	static replaceAll = function(_substr, _newstr) {
		str = string_replace_all(str, _substr, _newstr);
		return self;
	}
	
	static repeatStr = function(_count) {
		str = string_repeat(str, _count);
		return self;
	}
	
	static repeatString = method(undefined, repeatStr);
	
	static upper = function() {
		str = string_upper(str);
		return self;
	}
	
	static height = function() {
		return string_height(str);
	}
	
	static heightExt = function(_sep, _w) {
		return string_height_ext(str, _sep, _w);	
	}
	
	static width = function() {
		return string_width(str);
	}
	
	static widthExt = function(_sep, _w) {
		return string_width_ext(str, _sep, _w);	
	}
	
	static hashToNewLine = function() {
		str = string_hash_to_newline(str);
		return self;
	}
	
	static upperExt = function(_index, _count  = 1) {
		var _string = str;
		var _stringCopy = string_copy(_string, _index+1, _count);
		_stringCopy = string_upper(_stringCopy);
		var _newString = string_delete(_string,_index+1,_count);
		str = string_insert(_stringCopy, _newString, _index+1);	
		return self;
	}
	
	static lowerExt = function(_index, _count  = 1) {
		var _string = str;
		var _stringCopy = string_copy(_string, _index+1, _count);
		_stringCopy = string_lower(_stringCopy);
		var _newString = string_delete(_string,_index+1,_count);
		str = string_insert(_stringCopy, _newString, _index+1);	
		return self;
	}
	
	static add = function() {
		var _i = 0;
		var _str;
		repeat(argument_count) {
			_str = is_struct(argument[_i]) ? argument[_i].toString() : argument[_i];
			str += !is_string(_str) ? string(_str) : _str;
			++_i;
		}
		return self;
	}
	
	static concat = add;
	
	static clone = function() {
		return new betterString(str);	
	}
	
	static remove = function(_index, _count) {
		str = string_delete(str, _index+1, _count);
		return self;
	}
	
	static del = remove;
	
	static clear = function() {
		str = "";
		return self;
	}
	
	static set = function(_str) {
		var _str2 = is_struct(_str) ? _str.toString() : _str;
		str = !is_string(_str2) ? string(_str2) : _str2;
		return self;
	}
	
	static trim = function() {
			trimStart();
			trimEnd();
			return self;
	}
	
	static trimStart = function() {
		var _str = str;
		var _i = 1;
		var _breakOut = false;
		var _whitespaceFound = false;
		
		while((_i < string_length(_str))) {
			
			switch(string_byte_at(_str, _i)) {
				case 0x20: case 0x9: case 0xA: case 0xD: // Space, tab, newline, carriage return
					_whitespaceFound = true;
				break;
				
				default: // The rest
					_breakOut = true;
				break;
			}
			
			if (_breakOut) break;
			
			++_i;	
		}
		
		if (_whitespaceFound) {
			_str = string_delete(_str, 1, _i-1);
			str = _str;
		}
		return self;
	}
	
	static trimEnd = function() {
		var _str = str;
		var _i = string_length(_str);
		var _breakOut = false;
		var _whitespaceFound = false;
		
		while(_i > 0) {
			
			switch(string_byte_at(_str, _i)) {
				case 0x20: case 0x9: case 0xA: case 0xD: // Space, tab, newline, carriage return
					_whitespaceFound = true;
				break;
				
				default: // The rest
					_breakOut = true;
				break;
			}
			
			if (_breakOut) break;
			
			--_i;	
		}
		
		if (_whitespaceFound) {
			_str = string_delete(_str, _i+1, string_length(_str)-_i);
			str = _str;
		}
		return self;	
	}
	
	static strip = function(_lettersToRemove, _index, _count) {
		var _bytes = array_create(string_length(_lettersToRemove));
		var _i = 0;
		repeat(string_length(_lettersToRemove)) {
			_bytes[_i] = string_byte_at(_lettersToRemove, _i);
			++_i;
		}
		
		var _bytesLength = array_length(_bytes);
		
		var _string = str;
		var _i = is_undefined(_index) ? 1 : _index+1;
		var _length = is_undefined(_count) ? string_length(_string) : _count+1-_index+1;
		repeat(_length) {
			var _ii = 0;
			repeat(_bytesLength) {
				var _a = string_byte_at(_string, _i);
				if _a == _bytes[_ii] {
					_string = string_delete(_string, _i, 1);
					--_i;
					break;
				}
				++_ii;	
			}
			++_i;
		}
		
		str = _string;
		return self;
	}
	
	static slice = function(_index, _count = string_length(str)-_index+1) {
		return new betterString(str, _index+1, _count);
	}
	
	static split = function(_str, _maxLimit = all) {
		if (is_undefined(_str)) {
			return new betterString([str]);	
		}
		
		var __str = str;
		var _stringLength = string_length(_str);
		var _limit = (_maxLimit == all) ? string_count(_str, str) : _maxLimit;
		var _i = 0;
		var _pos = 1;
		var _lastPos = string_pos_ext(_str, __str, 1);
		var _array = array_create(_limit+1);
		repeat(_limit) {
			_array[_i] = new betterString(__str, _pos-1, _lastPos-_pos);
			_pos = _lastPos+1;
			_lastPos = string_pos_ext(_str, __str, _lastPos);
			++_i;
		}
		_array[_i] =  new betterString(__str, _pos-1, string_length(__str));
		
		return _array;
	}
	
	static substring = function(_str) {
		var _substr;
		if !(is_string(_str)) {
			_substr = string(_str);	
		} else {
			_substr = _str;	
		}
		
		if (exists(_substr)) {
			return new betterString(str, pos(_substr), string_length(_substr));
		} 
		
		return new betterString();
	}
	
	static before = function(_str) {
		var _substr;
		if !(is_string(_str)) {
			_substr = string(_str);	
		} else {
			_substr = _str;	
		}
		
		return new betterString(str, 0, string_pos(_substr, str)-1);
	}
	
	static after = function(_str) {
		var _substr;
		if !(is_string(_str)) {
			_substr = string(_str);	
		} else {
			_substr = _str;	
		}
		
		return new betterString(str, string_pos(_substr, str)+string_length(_substr)-1, string_length(str));
	}
	
	static rawCodes = function() {
		replaceAll("\n", "\\n");
		replaceAll("\r", "\\r");
		replaceAll("\b", "\\b");
		replaceAll("\v", "\\v");
		replaceAll("\f", "\\f");
		replaceAll("\a", "\\a");
		replaceAll("\t", "\\t");
		
		return self;
	}
	
	static unrawCodes = function() {
		replaceAll("\\n", "\n");
		replaceAll("\\r", "\r");
		replaceAll("\\b", "\b");
		replaceAll("\\v", "\v");
		replaceAll("\\f", "\f");
		replaceAll("\\a", "\a");
		replaceAll("\\t", "\t");
		return self;
	}
	
	static tabsToSpaces = function(_spaces = 4) {
		var _i = 0;
		var _spaceStr = new betterString(" ").repeatStr(_spaces);
		replaceAll("	", _spaceStr);
		
		return self;
	}
	
	static exists = function(_substring, _caseSensitive = true) {
		if !(_caseSensitive) {
			var _str = string_upper(toString());
			return string_pos(string_upper(_substring), _str) > -1;
		}
		
		return pos(_substring) > -1;
	}
	
	static export = function() {
		return "@@betterString@@" + str;	
	}
	
	static toString = function() {
		return str;	
	}
	
	static get = toString;
}
#endregion
#region Screen Functions
	function init() {
		//set game resolution
		enum RES
		{
			WIDTH = 480,
			HEIGHT = 270,
			SCALE = 2,
		}

		var _camera = camera_create_view(0, 0, RES.WIDTH, RES.HEIGHT, 0, noone, -1, -1, RES.WIDTH/2, RES.HEIGHT/2);

		//set up view
		view_enabled = true;
		view_visible[0] = true;

		view_set_camera(0, _camera);
		
		//Resize game surface
		surface_resize(application_surface, RES.WIDTH, RES.HEIGHT);

		//resize window
		var _window_width = RES.WIDTH * RES.SCALE;
		var _window_height = RES.HEIGHT * RES.SCALE;

		window_set_size(_window_width, _window_height);

		//start game
		//room_goto_next();
}
#endregion

function AnimationEnd() {
    //returns true if the animation will loop this step.
    //returns true if the animation will loop this step.

    var _sprite=sprite_index;
    var _image=image_index;
    if(argument_count > 0)     _sprite=argument[0];
    if(argument_count > 1)    _image=argument[1];

    var _type=sprite_get_speed_type(_sprite);
    var _spd=sprite_get_speed(_sprite)*image_speed;
    if(_type == spritespeed_framespersecond)
        _spd = _spd/room_speed;
    if(argument_count > 2) _spd=argument[2];
    return _image+_spd >= sprite_get_number(_sprite);
}

function screenshake(_time, _magnitude, _fade) {
   with (OBJ_CAMERA) {
      shake = true;
      shake_time = _time;
      shake_magnitude = _magnitude;
      shake_fade = _fade;
   }
}