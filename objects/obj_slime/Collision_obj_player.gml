var _adv_color = c_black; // Normal
var _p_dir = obj_player.facing_dir;
var _e_dir = facing_dir;

var _dir_from_player = point_direction(obj_player.x, obj_player.y, x, y);
var _player_facing_slime = (abs(angle_difference(_p_dir, _dir_from_player)) < 90);
var _slime_facing_away = (abs(angle_difference(_e_dir, _dir_from_player)) < 90);

if (_player_facing_slime && _slime_facing_away) {
	_adv_color = c_blue;
} else if (!_player_facing_slime && !_slime_facing_away) {
	_adv_color = c_red;
}

var _enemies = [
	{data: global.enemies.boar, col: 0, row: 0},
	{data: global.enemies.boar, col: 1, row: 0},
	{data: global.enemies.boar, col: 1, row: 1}
];

show_debug_message("COLLISION: instance_exists check = " + string(instance_exists(obj_encounter_transition)));

if (!instance_exists(obj_encounter_transition)) {
	show_debug_message("COLLISION: Creating obj_encounter_transition...");
	var _trans = instance_create_depth(0, 0, -9999, obj_encounter_transition);
	show_debug_message("COLLISION: Created, id = " + string(_trans));
	_trans.swirl_color = _adv_color;
	_trans.enemies_data = _enemies;
	_trans.bg = sBattle1;
	_trans.timer = 1500;
}
