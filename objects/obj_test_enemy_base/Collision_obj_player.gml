var _adv_color = c_black; // Normal
if (instance_exists(obj_player)) {
    var _p_dir = obj_player.facing_dir;
    var _e_dir = facing_dir;

    var _dir_from_player = point_direction(obj_player.x, obj_player.y, x, y);
    var _player_facing_enemy = (abs(angle_difference(_p_dir, _dir_from_player)) < 90);
    var _enemy_facing_away = (abs(angle_difference(_e_dir, _dir_from_player)) < 90);

    if (_player_facing_enemy && _enemy_facing_away) {
        _adv_color = c_blue;
    } else if (!_player_facing_enemy && !_enemy_facing_away) {
        _adv_color = c_red;
    }
}

// Strict guard: Do not start an encounter if a battle is already running or transition is active
if (can_trigger && !instance_exists(oBattle) && !instance_exists(obj_encounter_transition) && array_length(encounter_enemies) > 0) {
    can_trigger = false;
    var _trans = instance_create_depth(0, 0, -9999, obj_encounter_transition);
    _trans.swirl_color = _adv_color;
    _trans.enemies_data = encounter_enemies;
    _trans.bg = sBattle1;
    _trans.timer = 1500;
}
