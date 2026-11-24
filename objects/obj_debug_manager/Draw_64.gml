/// @description Debug HUD (Draw GUI) — performance stats + real-time stat editor

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Always-on so render/AI overhead is visible even with the overlay off.
// Yellow with a black outline so it stays legible over the green overworld map.
draw_set_color(c_black);
draw_text(17, 17, $"FPS (capped): {fps}");
draw_text(17, 33, $"FPS (real): {fps_real}");
draw_set_color(c_yellow);
draw_text(16, 16, $"FPS (capped): {fps}");
draw_text(16, 32, $"FPS (real): {fps_real}");
draw_set_color(c_white);

if (!debug_active) exit;

var _in_battle = instance_exists(oBattle);

// --- Resolve target (mirrors Step_0.gml's resolution so the view stays in sync while read-only) ---
var _target      = undefined;
var _target_name = "";
var _party_index = -1;

if (_in_battle) {
    if (array_length(oBattle.units) > 0) {
        battle_unit_index = clamp(battle_unit_index, 0, array_length(oBattle.units) - 1);
        _target = oBattle.units[battle_unit_index];
        _target_name = _target.name + (_target.object_index == oBattleUnitPC ? " (Party)" : " (Enemy)");
    }
} else {
    if (variable_global_exists("party") && stat_char_index < array_length(global.party)) {
        _target = global.party[stat_char_index];
        _target_name = _target.name;
    }
}

// --- Panel size (InventoryTray, nine-slice stretched to fit content — same panel used by oEquipment_UI) ---
var _pad         = 32;
var _line        = (debug_menu_tab == 3) ? 28 : 32; // resist tab is denser
var _battle_rows = _in_battle ? 4 : 0; // mode/turn/phase/acting lines
var _stat_rows   = array_length(stat_keys);
var _content_rows = 3; // title + tab header

var _current_enemy_key = "";
var _loot_table = [];
var _loot_rows = 0;
if (array_length(loot_enemy_keys) > 0) {
	_current_enemy_key = loot_enemy_keys[loot_enemy_index];
	_loot_table = global.loot_database[$ _current_enemy_key];
	_loot_rows = array_length(_loot_table);
}

if (debug_menu_tab == 0) {
	_content_rows += 1 + _battle_rows + _stat_rows + 2; // subtitle + battle info + stats + footer
} else if (debug_menu_tab == 1) {
	_content_rows += 1 + _loot_rows + 3; // subtitle + loot rows + gap + global rate + footer
} else if (debug_menu_tab == 2) {
	_content_rows += 1 + array_length(global.character_roster) + 2; // subtitle + roster + gap + footer
} else if (debug_menu_tab == 3) {
	if (_in_battle && _target != undefined) {
		var _buff_rows = clamp(array_length(_target.buffs), 1, 3);
		_content_rows += 2 + array_length(resist_tag_list) + 1 + _buff_rows + 1 + 3; // mode + editing + tags + buff header + buffs + picker + 3 footer lines
	} else {
		_content_rows += 1; // just the "battle only" message
	}
}

var _panel_w = 480;
var _panel_h = _pad * 2 + _content_rows * _line;
var _panel_x = RESOLUTION_W - _panel_w - 24;
var _panel_y = RESOLUTION_H - _panel_h - 24;

draw_sprite_stretched_ext(InventoryTray, 0, _panel_x, _panel_y, _panel_w, _panel_h, c_white, 1);

draw_set_font(fnMother3);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _x    = _panel_x + _pad;
var _y    = _panel_y + 18;
var _row_w = _panel_w - _pad * 2;

// Title
draw_set_color(c_yellow);
draw_text(_x, _y, "DEBUG MENU");
draw_set_halign(fa_right);
draw_text(_x + _row_w, _y, debug_edit_focus ? "[EDIT — Tab to release]" : "[VIEW — Tab to edit]");
draw_set_halign(fa_left);
_y += _line * 1.4;

// Tab Header
// Laid out with string_width so labels never overlap, whatever the font width is
var _tab_labels = ["[1] STATS", "[2] CONFIG", "[3] PARTY", "[4] RESIST"];
var _tab_x = _x;
for (var i = 0; i < array_length(_tab_labels); i++) {
	draw_set_color(debug_menu_tab == i ? c_yellow : c_dkgray);
	draw_text(_tab_x, _y, _tab_labels[i]);
	_tab_x += string_width(_tab_labels[i]) + 14;
}
_y += _line * 1.2;

if (debug_menu_tab == 0) {
	// Subtitle: mode + current target
	draw_set_color(c_white);
	draw_text(_x, _y, _in_battle ? "Mode: BATTLE" : "Mode: OVERWORLD");
	_y += _line;

	// --- Battle status ("behind the scenes" visualizer) ---
	if (_in_battle) {
	    var _phase_label = "Unknown";
	    if (oBattle.battleState == oBattle.BattleStateSelectAction)      _phase_label = "Selecting Action";
	    else if (oBattle.battleState == oBattle.BattleStatePerformAction)   _phase_label = "Performing Action";
	    else if (oBattle.battleState == oBattle.BattleStateVictoryCheck)    _phase_label = "Checking Victory";
	    else if (oBattle.battleState == oBattle.BattleStateTurnProgression) _phase_label = "Turn Progression";

	    var _turn_name = "N/A";
	    if (array_length(oBattle.unitTurnOrder) > 0 && instance_exists(oBattle.unitTurnOrder[oBattle.turn])) {
	        _turn_name = oBattle.unitTurnOrder[oBattle.turn].name;
	    }

	    draw_set_color(c_ltgray);
	    draw_text(_x, _y, $"Turn: {_turn_name}   Round: {oBattle.roundCount}");
	    _y += _line;
	    draw_text(_x, _y, $"Phase: {_phase_label}");
	    _y += _line;

	    if (instance_exists(oBattle.currentUser) && is_struct(oBattle.currentAction)) {
	        draw_text(_x, _y, $"Acting: {oBattle.currentUser.name} → {oBattle.currentAction.name}");
	    } else {
	        draw_text(_x, _y, "Acting: —");
	    }
	    _y += _line * 1.2;
	}

	// --- Stat editor ---
	draw_set_color(c_white);
	draw_text(_x, _y, _target != undefined ? $"Editing: {_target_name}" : "Editing: —");
	_y += _line;

	if (_target == undefined) {
	    draw_set_color(c_gray);
	    draw_text(_x, _y, _in_battle ? "No battle units found." : "No character data found.");
	    _y += _stat_rows * _line;
	} else {
	    for (var i = 0; i < _stat_rows; i++) {
	        var _key      = stat_keys[i];
	        var _value    = _target[$ _key] ?? "N/A";
	        var _selected = (i == stat_selected_index);

	        if (_selected && debug_edit_focus) {
	            draw_set_alpha(0.25);
	            draw_set_color(c_yellow);
	            draw_rectangle(_x - 6, _y - 2, _x + _row_w, _y + _line - 4, false);
	            draw_set_alpha(1);
	        }

	        draw_set_color(_selected && debug_edit_focus ? c_yellow : c_white);
	        draw_text(_x, _y, $"{_selected ? ">" : " "} {stat_labels[i]}");
	        draw_set_halign(fa_right);
	        draw_text(_x + _row_w, _y, string(_value));
	        draw_set_halign(fa_left);

	        _y += _line;
	    }
	}

	draw_set_color(c_ltgray);
	_y += 6;
	if (!debug_edit_focus) {
	    draw_text(_x, _y, "Tab: edit stats");
	} else {
	    draw_text(_x, _y, $"Up/Down: stat   Left/Right: -/+   Q/E: {_in_battle ? "unit" : "party member"}");
	}
} else if (debug_menu_tab == 1) {
	draw_set_color(c_white);
	draw_text(_x, _y, $"Loot Target: {_current_enemy_key}");
	_y += _line * 1.5;

	if (_loot_rows == 0) {
	    draw_set_color(c_gray);
	    draw_text(_x, _y, "No loot defined.");
	    _y += _line;
	} else {
	    for (var i = 0; i < _loot_rows; i++) {
	        var _drop     = _loot_table[i];
	        var _selected = (i == loot_item_index);

	        if (_selected && debug_edit_focus) {
	            draw_set_alpha(0.25);
	            draw_set_color(c_yellow);
	            draw_rectangle(_x - 6, _y - 2, _x + _row_w, _y + _line - 4, false);
	            draw_set_alpha(1);
	        }

	        draw_set_color(_selected && debug_edit_focus ? c_yellow : c_white);
	        draw_text(_x, _y, $"{_selected ? ">" : " "} {_drop.item}");
	        draw_set_halign(fa_right);
	        draw_text(_x + _row_w, _y, $"{_drop.chance}%");
	        draw_set_halign(fa_left);

	        _y += _line;
	    }
	}
	
	_y += _line * 0.5;
	draw_set_color(c_white);
	draw_text(_x, _y, $"Global Drop Rate Multiplier: x{global.dropRateMultiplier}");
	
	draw_set_color(c_ltgray);
	_y += _line * 1.5;
	if (!debug_edit_focus) {
	    draw_text(_x, _y, "Tab: edit config");
	} else {
	    draw_text(_x, _y, "Q/E: enemy   L/R: chance   [/]: global");
	}
} else if (debug_menu_tab == 2) {
	draw_set_color(c_white);
	draw_text(_x, _y, "PARTY ROSTER");
	_y += _line * 1.2;

	var _roster = global.character_roster;
	for (var i = 0; i < array_length(_roster); i++) {
		var _name     = _roster[i].name;
		var _selected = (i == party_roster_index);

		var _in_party = false;
		for (var j = 0; j < array_length(global.party); j++) {
			if (global.party[j].name == _name) { _in_party = true; break; }
		}

		if (_selected && debug_edit_focus) {
			draw_set_alpha(0.25);
			draw_set_color(c_yellow);
			draw_rectangle(_x - 6, _y - 2, _x + _row_w, _y + _line - 4, false);
			draw_set_alpha(1);
		}

		draw_set_color(_selected && debug_edit_focus ? c_yellow : c_white);
		draw_text(_x, _y, $"{_selected ? ">" : " "} {_name}");
		draw_set_halign(fa_right);
		draw_set_color(_in_party ? c_lime : c_gray);
		draw_text(_x + _row_w, _y, _in_party ? "IN PARTY" : "NOT IN PARTY");
		draw_set_halign(fa_left);
		_y += _line;
	}

	draw_set_color(c_ltgray);
	_y += 6;
	if (!debug_edit_focus) {
		draw_text(_x, _y, "Tab: edit party");
	} else {
		draw_text(_x, _y, "Up/Down: select   Enter: toggle in/out");
	}
} else if (debug_menu_tab == 3) {
	draw_set_color(c_white);
	if (!_in_battle || _target == undefined) {
		draw_set_color(c_gray);
		draw_text(_x, _y, "Resist/buff: battle only.");
	} else {
		draw_text(_x, _y, "Mode: BATTLE");
		_y += _line;
		draw_text(_x, _y, $"Editing: {_target_name}");
		_y += _line;

		// One row per tag: unit's base multiplier -> total after buffs. Immune nullifies the damage.
		for (var i = 0; i < array_length(resist_tag_list); i++) {
			var _tag      = resist_tag_list[i];
			var _selected = (i == resist_row_index);
			var _base     = _target.resist[$ _tag] ?? 1;
			var _total    = BuffGetResistMult(_target, _tag);
			var _immune   = BuffIsTagImmune(_target, _tag);

			if (_selected && debug_edit_focus) {
				draw_set_alpha(0.25);
				draw_set_color(c_yellow);
				draw_rectangle(_x - 6, _y - 2, _x + _row_w, _y + _line - 4, false);
				draw_set_alpha(1);
			}

			draw_set_color(_selected && debug_edit_focus ? c_yellow : c_white);
			draw_text(_x, _y, $"{_selected ? ">" : " "} {_tag}");

			draw_set_halign(fa_right);
			if (_immune) {
				draw_set_color(c_aqua);
				draw_text(_x + _row_w, _y, "IMMUNE");
			} else {
				draw_set_color(_total > 1 ? DMG_COLOR_WEAK : (_total < 1 ? DMG_COLOR_RESIST : c_white));
				draw_text(_x + _row_w, _y, $"base x{_base}  total x{_total}");
			}
			draw_set_halign(fa_left);
			_y += _line;
		}

		// Active buffs (newest 3)
		draw_set_color(c_ltgray);
		draw_text(_x, _y, "Buffs:");
		_y += _line;
		var _buff_count = array_length(_target.buffs);
		if (_buff_count == 0) {
			draw_set_color(c_gray);
			draw_text(_x, _y, "  none");
			_y += _line;
		} else {
			for (var i = max(0, _buff_count - 3); i < _buff_count; i++) {
				var _b     = _target.buffs[i];
				var _turns = (_b.turnsLeft < 0) ? "perm" : $"{_b.turnsLeft}t";
				var _src   = (_b.source != noone && instance_exists(_b.source)) ? _b.source.name : "-";
				draw_set_color(c_white);
				draw_text(_x, _y, $"  {_b.def.name} ({_turns})");
				draw_set_halign(fa_right);
				draw_text(_x + _row_w, _y, $"from {_src}");
				draw_set_halign(fa_left);
				_y += _line;
			}
		}

		// Library buff picker
		draw_set_color(c_white);
		if (array_length(buff_pick_keys) > 0) {
			draw_text(_x, _y, $"Apply: {buff_pick_keys[buff_pick_index]}");
		}
		_y += _line;

		// Footer: short lines so they stay inside the panel
		draw_set_color(c_ltgray);
		_y += 6;
		if (!debug_edit_focus) {
			draw_text(_x, _y, "Tab: edit resist/buffs");
		} else {
			draw_text(_x, _y, "Up/Dn: tag   L/R: mult (Shift: fine)");
			_y += _line;
			draw_text(_x, _y, "R: reset   I: immune   Q/E: unit");
			_y += _line;
			draw_text(_x, _y, "Z/X: buff   Enter: apply   Bksp: remove");
		}
	}
}

draw_set_color(c_white);
draw_set_font(-1);
