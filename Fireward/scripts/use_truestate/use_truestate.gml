enum TrueStateEvent {
  onStep,
  onDraw,
  
  onEnter,
  onExit,
  
  onSwitchState,
}

///@func use_truestate([start state script])
function use_truestate(_startState = undefined) {
  var _layer = new __iTRUE_STATE_LAYER();  
  _layer.__iOwner = self.id;
  if(_startState != undefined)
    _layer.addState(_startState);
  return _layer;
}

function __iTRUE_STATE_LAYER() constructor {	
  __iStates = {};
  
  //Start
	__iOriginal = undefined;
	__iPrevious = undefined;
	__iNext = undefined;
  
	__iStack = [];
                   
	__iSwitchIsLocked = false;
	__iStateShouldReset = false;

	current = undefined;
  history = [];
	timer = 0;

  ///@func addState(stateId, function, [name = function name])
  addState = function(_id, _func = _id, _name = script_get_name(_func)) {
    var _newState = {id: _id, func: _func, name: _name};
    __iStates[$ string(_id)] = _newState;
    
    if(__iOriginal == undefined){
      __iOriginal = _newState;
    	__iPrevious = _newState;
    	__iNext = _newState;
    }
    
    return _newState;      
  }
		
	///@func stateSwitch([stateId = default], [lock = false])
	stateSwitch = function (_stateId = __iOriginal.id, _lock = false) {
    if(__iSwitchIsLocked) return;
    
    var _state = __iStates[$ string(_stateId)];
    if(_state == undefined) {
      //Trying to switch to a state we don't have. Add it if it's a function
      if(!script_exists(_stateId)) {
        throw("This state does not exist on the current object")
        game_end();
      }
      
      _state = addState(_stateId, _stateId)
    }
    
		if(current != _state){
			array_push(__iStack, _state);
      __iNext = _state
    }
    
		if(_lock != undefined)
			__iSwitchIsLocked = _lock;
	}
  
  ///@func stateReset()
  stateReset = function() {
    if(__iSwitchIsLocked) return;
    __iStateShouldReset = true;
  }

	///@func stateSwitchPrevious() Returns to the __iPrevious state.
	stateSwitchPrevious = function () {
    if(__iSwitchIsLocked) return;
		if(array_length(__iStack) == 0) {
			stateSwitch(__iOriginal.id);
			return;
		}

		array_pop(__iStack);
		__iSwitchIsLocked = true;
		stateSwitch(array_pop(__iStack));
	}
    
  ///@func clearHistory()
  clearHistory = function() {
    history = [];
    __iPushToHistory(current);
  }
  
  __iPushToHistory = function(_state) {
    array_push(history, _state.name);
  }
  

  ///@func event(TrueStateEvent.<event>)
	event = function(_event){
    
    var _state = current;
    if(_state == undefined) {
      current = __iOriginal
      event(TrueStateEvent.onEnter);
      return;
    }

    switch(_event){
      case TrueStateEvent.onSwitchState: 
        __iSwitchIsLocked = false; //Release the lock
        timer++;

        if(__iNext == current && !__iStateShouldReset) return; 
        
        __iStateShouldReset = false;
        
        var _func = current.func;
        with(__iOwner) {
          if(_func != undefined) _func(TrueStateEvent.onExit, other);
        }
	
        __iPrevious = current;
        current = __iNext;
        
        __iPushToHistory(current);
        timer = 0;
        _func = current.func;
        with(__iOwner) {
          _func(TrueStateEvent.onEnter, other);
        }
      break;
      
      default: 
        var _func = _state.func;
        with(__iOwner) {
          _func(_event, other); 
        }
      break;
    }
  }
  
  ///@func drawHistory(x, y, [count = 10], [scale = 1], [bg color = c_black], [bg alpha = .5], [text color = c_white])
  drawHistory = function(_x, _y, _count = 10, _scale = 1, _bgCol = c_black, _bgAlpha = .5, _txtCol = c_white) {
    var _margin = 5;
    var _str = "";
    var _h = string_height("W") * _scale;
    var _total = array_length(history)
    for(var _i = 0; _i < min(_count, _total); _i++) {
      _str += history[_total - 1 - _i] + "\n";
    }
    var _w = string_width(_str) * _scale;
    draw_set_alpha(_bgAlpha);
    draw_set_color(_bgCol);
    draw_rectangle(_x, _y, _x + _w + _margin * 2, _y + _h * _count + _margin * 2, false);
    draw_set_alpha(1);
    draw_set_color(_txtCol);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_transformed(_x + _margin, _y + _margin, _str, _scale, _scale, 0);
    return {width: _w + _margin * 2, height: _h + _margin * 2}
  }
}