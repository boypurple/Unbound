/// @desc Shop — opened directly from the field via action() (obj_npc), owns its own pause state.

if (!variable_instance_exists(id, "shop_items")) {
    // No curated list passed in — sell everything in the shop price database.
    shop_items = variable_struct_get_names(global.shop_price_database);
}

cursor_index        = 0;
shop_state          = 0; // 0 = browsing, 1 = confirm quantity
buy_quantity         = 1;
input_cooldown       = 0;
input_cooldown_max   = 8;
just_opened          = true; // Swallows the Space press that opened this UI so it isn't also read as a confirm

global.gamePaused = true;
