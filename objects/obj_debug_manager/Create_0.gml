/// @description Debug & Stress Testing Manager — persistent, room-independent

debug_active     = false;
debug_edit_focus = false; // Tab, while debug_active: arms stat editing and steals arrow/enter keys from oMenu/obj_player

// --- Stat editor ---
// Overworld target: global.party[stat_char_index]. Battle target: oBattle.units[battle_unit_index].
// Keys must match fields shared by both global.party structs and battle unit instances
// (scripts/GameData/GameData.gml party/enemy templates).
stat_char_index      = 0;
stat_keys            = ["strength", "def", "spd", "hp", "hpMax", "pp", "ppMax", "wrath", "iq"];
stat_labels          = ["Strength", "Defense", "Speed", "HP", "Max HP", "PP", "Max PP", "Wrath", "IQ"];
stat_selected_index  = 0;
stat_step            = 1;

// Which oBattle.units[] index is targeted while in battle (cycled with Q/E)
battle_unit_index = 0;

// Held-key repeat timing for Left/Right stat editing
input_cooldown     = 0;
input_cooldown_max = 8;

// --- Enemy visualizer ---
// obj_enemy has no vision_range/current_state vars yet — these are the
// fallbacks used until an AI system defines them on the instance.
enemy_vision_default    = 96;
enemy_vision_color      = c_lime;
enemy_vision_alpha      = 0.25;
