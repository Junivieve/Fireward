var _dGrid = global.depthGrid;
var _instNum = instance_number(pDepth);
ds_grid_resize(_dGrid, 2, _instNum);

var _yy = 0;
with(pDepth) {
	_dGrid[# 0, _yy] = id;
	_dGrid[# 1, _yy] = y+z;
	_yy++;
}
	
ds_grid_sort(_dGrid, 1, true);

_yy = 0;
var _inst;
repeat(_instNum) {
	_inst = _dGrid[# 0, _yy];
	with(_inst) {
		event_perform(ev_draw, 0);	
	}
	_yy++;
}