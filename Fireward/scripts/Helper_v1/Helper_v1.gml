
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