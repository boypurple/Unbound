/// @description Toggle overlay (F1), edit focus (Tab) + stat editor input

if (keyboard_check_pressed(vk_f1)) {
    debug_active = !debug_active;
    if (!debug_active) debug_edit_focus = false;
}

if (debug_active && keyboard_check_pressed(vk_tab)) {
    debug_edit_focus = !debug_edit_focus;
}

// Other objects (obj_player, oMenu) read these to suppress their own input
// while the debug overlay owns arrow/tab keys, so controls don't overlap.
global.debug_ui_active  = debug_active;
global.debug_edit_focus = debug_edit_focus;

// Read-only mode (overlay on, not focused): show info, capture nothing else.
if (!debug_active || !debug_edit_focus) {
    input_cooldown = 0;
    exit;
}

var _in_battle = instance_exists(oBattle);

// --- Cycle target unit (Q/E) ---
// Battle: cycles battle_unit_index over oBattle.units. Overworld: cycles
// stat_char_index over global.party, so every party member is reachable.
if (_in_battle && array_length(oBattle.units) > 0) {
    var _unit_count = array_length(oBattle.units);
    battle_unit_index = clamp(battle_unit_index, 0, _unit_count - 1);

    if (keyboard_check_pressed(ord("E"))) {
        battle_unit_index = (battle_unit_index + 1) mod _unit_count;
    }
    if (keyboard_check_pressed(ord("Q"))) {
        battle_unit_index = (battle_unit_index - 1 + _unit_count) mod _unit_count;
    }
} else if (!_in_battle && variable_global_exists("party") && array_length(global.party) > 0) {
    var _party_count = array_length(global.party);
    stat_char_index = clamp(stat_char_index, 0, _party_count - 1);

    if (keyboard_check_pressed(ord("E"))) {
        stat_char_index = (stat_char_index + 1) mod _party_count;
    }
    if (keyboard_check_pressed(ord("Q"))) {
        stat_char_index = (stat_char_index - 1 + _party_count) mod _party_count;
    }
}

// --- Navigate stats ---
var _stat_count = array_length(stat_keys);

if (keyboard_check_pressed(vk_up)) {
    stat_selected_index = (stat_selected_index - 1 + _stat_count) mod _stat_count;
}
if (keyboard_check_pressed(vk_down)) {
    stat_selected_index = (stat_selected_index + 1) mod _stat_count;
}

// --- Resolve edit target ---
var _target      = undefined;
var _party_index = -1;

if (_in_battle) {
    if (array_length(oBattle.units) > 0) {
        _target = oBattle.units[battle_unit_index];
        if (_target.object_index == oBattleUnitPC) {
            _party_index = array_get_index(oBattle.partyUnits, _target);
        }
    }
} else {
    _target = (variable_global_exists("party") && stat_char_index < array_length(global.party))
        ? global.party[stat_char_index]
        : undefined;
}

if (_target == undefined) {
    input_cooldown = 0;
    exit;
}

// --- Edit selected stat ---
var _left  = keyboard_check(vk_left);
var _right = keyboard_check(vk_right);

if (_left || _right) {
    if (input_cooldown <= 0) {
        var _key       = stat_keys[stat_selected_index];
        var _delta     = _right ? stat_step : -stat_step;
        var _new_value = (_target[$ _key] ?? 0) + _delta;

        _target[$ _key] = _new_value;

        // Party units in battle write through to global.party so a mid-fight
        // balance tweak persists for that character after the battle ends.
        if (_party_index != -1) {
            global.party[_party_index][$ _key] = _new_value;
        }

        input_cooldown = input_cooldown_max;
    } else {
        input_cooldown--;
    }
} else {
    input_cooldown = 0;
}
