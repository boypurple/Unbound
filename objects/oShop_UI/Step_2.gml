/// @desc Shop input — browse items, confirm quantity, buy

if (just_opened) {
    just_opened = false;
    exit; // The Space press that opened this UI is still "pressed" this frame — don't also read it as a confirm.
}

var _key_up     = keyboard_check_pressed(vk_up);
var _key_down   = keyboard_check_pressed(vk_down);
var _key_left   = keyboard_check(vk_left);
var _key_right  = keyboard_check(vk_right);
var _key_accept = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var _key_cancel = keyboard_check_pressed(vk_escape);

var _item_count = array_length(shop_items);

if (shop_state == 0) {
    // --- Browsing ---
    input_cooldown = 0;

    if (_item_count > 0) {
        if (_key_up)   cursor_index = (cursor_index - 1 + _item_count) mod _item_count;
        if (_key_down) cursor_index = (cursor_index + 1) mod _item_count;

        if (_key_accept) {
            shop_state   = 1;
            buy_quantity = 1;
        }
    }

    if (_key_cancel) {
        global.gamePaused = false;
        instance_destroy();
    }
} else {
    // --- Confirm quantity ---
    if (_key_left || _key_right) {
        if (input_cooldown <= 0) {
            buy_quantity = clamp(buy_quantity + (_key_right ? 1 : -1), 1, 99);
            input_cooldown = input_cooldown_max;
        } else {
            input_cooldown--;
        }
    } else {
        input_cooldown = 0;
    }

    if (_key_accept) {
        var _item_id   = shop_items[cursor_index];
        var _item_data = GetItemFromDatabase(_item_id);

        if (_item_data != undefined) {
            var _cost = GetShopPrice(_item_id) * buy_quantity;
            if (SpendCash(_cost)) {
                AddItemToCharacterInventory(global.party[0].name, _item_id, buy_quantity);
            }
        }

        shop_state = 0;
    }

    if (_key_cancel) {
        shop_state = 0;
    }
}
