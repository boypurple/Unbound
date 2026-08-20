/// @desc Shop panel — InventoryTray list of items, price, and cash on hand.

draw_set_colour(c_black);
draw_set_alpha(0.75);
draw_rectangle(0, 0, RESOLUTION_W, RESOLUTION_H, false);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_font(fnMother3);

var _item_count = array_length(shop_items);

var _pad   = 26;
var _line  = 36;
var _panel_w = 460;
var _panel_h = _pad * 2 + _line * 1.4 /*title*/ + max(_item_count, 1) * _line + _line /*footer gap*/;
var _panel_x = (RESOLUTION_W - _panel_w) / 2;
var _panel_y = (RESOLUTION_H - _panel_h) / 2;

draw_sprite_stretched_ext(InventoryTray, 0, _panel_x, _panel_y, _panel_w, _panel_h, c_white, 1);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _x = _panel_x + _pad;
var _y = _panel_y + 18;
var _row_w = _panel_w - _pad * 2;

draw_set_colour(c_yellow);
draw_text(_x, _y, "SHOP");
draw_set_halign(fa_right);
draw_text(_x + _row_w, _y, "Cash: $" + string(global.cash));
draw_set_halign(fa_left);
_y += _line * 1.4;

if (_item_count == 0) {
    draw_set_colour(c_gray);
    draw_text(_x, _y, "Nothing for sale.");
} else {
    for (var i = 0; i < _item_count; i++) {
        var _item_data = GetItemFromDatabase(shop_items[i]);
        var _selected  = (i == cursor_index);

        if (_item_data == undefined) continue;

        if (_selected) {
            draw_set_alpha(0.25);
            draw_set_colour(c_yellow);
            draw_rectangle(_x - 6, _y - 2, _x + _row_w, _y + _line - 10, false);
            draw_set_alpha(1);
        }

        draw_set_colour(_selected ? c_yellow : c_white);
        draw_text(_x, _y, $"{_selected ? ">" : " "} {_item_data.name}");
        draw_set_halign(fa_right);
        draw_text(_x + _row_w, _y, "$" + string(GetShopPrice(shop_items[i])));
        draw_set_halign(fa_left);

        _y += _line;
    }
}

draw_set_colour(c_ltgray);
_y += 6;
draw_text(_x, _y, "Up/Down: browse   Enter: buy   Esc: leave");

// --- Quantity confirm overlay ---
if (shop_state == 1 && _item_count > 0) {
    var _item_data = GetItemFromDatabase(shop_items[cursor_index]);
    var _cost      = GetShopPrice(shop_items[cursor_index]) * buy_quantity;

    var _box_w = 300;
    var _box_h = 140;
    var _box_x = (RESOLUTION_W - _box_w) / 2;
    var _box_y = (RESOLUTION_H - _box_h) / 2;

    draw_sprite_stretched_ext(InventoryTray, 0, _box_x, _box_y, _box_w, _box_h, c_white, 1);

    var _bx = _box_x + 24;
    var _by = _box_y + 20;

    draw_set_colour(c_yellow);
    draw_text(_bx, _by, _item_data.name);
    _by += 28;

    draw_set_colour(c_white);
    draw_text(_bx, _by, "Quantity: " + string(buy_quantity));
    _by += 24;
    draw_text(_bx, _by, "Total: $" + string(_cost));
    _by += 32;

    draw_set_colour(CanAffordCash(_cost) ? c_ltgray : c_red);
    draw_text(_bx, _by, CanAffordCash(_cost) ? "Left/Right: qty   Enter: confirm" : "Not enough cash!");
}

draw_set_colour(c_white);
draw_set_font(-1);
