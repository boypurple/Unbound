/// @description Enemy AI visualizer (world space) — vision radius + state text

if (!debug_active) exit;
if (instance_exists(oBattle)) exit; // battle status is shown in the Draw GUI panel instead

with (obj_enemy) {
    var _vision = variable_instance_exists(id, "vision_range") ? vision_range : other.enemy_vision_default;

    var _state = "N/A";
    if (variable_instance_exists(id, "current_state")) {
        _state = string(current_state);
    } else if (variable_instance_exists(id, "state_text")) {
        _state = string(state_text);
    }

    draw_set_alpha(other.enemy_vision_alpha);
    draw_circle_color(x, y, _vision, other.enemy_vision_color, other.enemy_vision_color, false);
    draw_set_alpha(1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    draw_text(x, y - sprite_height / 2 - 4, _state);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
