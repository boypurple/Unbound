/// @desc ATM panel — deposit/withdraw between cash and bank.

draw_set_colour(c_black);
draw_set_alpha(0.75);
draw_rectangle(0, 0, RESOLUTION_W, RESOLUTION_H, false);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_font(fnMother3);

var _panel_w = 380;
var _panel_h = 240;
var _panel_x = (RESOLUTION_W - _panel_w) / 2;
var _panel_y = (RESOLUTION_H - _panel_h) / 2;

draw_sprite_stretched_ext(InventoryTray, 0, _panel_x, _panel_y, _panel_w, _panel_h, c_white, 1);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _x = _panel_x + 26;
var _y = _panel_y + 18;
var _line = 30;

draw_set_colour(c_yellow);
draw_text(_x, _y, "ATM");
_y += _line * 1.3;

draw_set_colour(c_white);
draw_text(_x, _y, "Bank: $" + string(global.coins));
_y += _line * 0.8;
draw_text(_x, _y, "Cash: $" + string(global.cash));
_y += _line * 1.3;

var _actions = ["Deposit", "Withdraw"];
for (var i = 0; i < 2; i++) {
    var _selected = (atm_mode == 0) && (i == atm_action_index);
    draw_set_colour(_selected ? c_yellow : (atm_mode == 1 && i == atm_action_index ? c_ltgray : c_white));
    draw_text(_x, _y, $"{_selected ? ">" : " "} {_actions[i]}");
    _y += _line * 0.8;
}

_y += _line * 0.4;

if (atm_mode == 1) {
    draw_set_colour(c_white);
    draw_text(_x, _y, $"{_actions[atm_action_index]} amount: $" + string(atm_amount));
    _y += _line * 0.8;
    draw_set_colour(c_ltgray);
    draw_text(_x, _y, "Left/Right: -/+$" + string(atm_step) + "   Enter: confirm   Esc: back");
} else {
    draw_set_colour(c_ltgray);
    draw_text(_x, _y, "Up/Down: select   Enter: choose   Esc: leave");
}

draw_set_colour(c_white);
draw_set_font(-1);
