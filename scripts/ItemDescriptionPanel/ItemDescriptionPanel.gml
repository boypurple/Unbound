function ItemDescriptionPanel(_item){
	if (_item.id == -1)
	{
		exit;
	}

	with (oInventory_UI)
	{
		var panel_xscale = 0.2
		var panel_yscale = 0.9

		// Fetch original asset sizes
		var base_w = sprite_get_width(InventoryTray) / 6
		var base_h = sprite_get_height(InventoryTray) * 3 / 4

		// Multiply by scale
		var scaled_w = base_w * panel_xscale
		var scaled_h = base_h * panel_yscale

		var _panelX = (RESOLUTION_W - scaled_w) / 2
		var _panelY = (RESOLUTION_H - scaled_h) / 2

		draw_sprite_ext(InventoryTray, 0, _panelX, _panelY, panel_xscale, panel_yscale, 0, c_white, 1)

		draw_set_color(c_black);
		draw_set_font(font0);

		draw_set_valign(fa_middle);
		draw_set_halign(fa_center);
		draw_text(128, 16, _item.name);
		draw_sprite_ext(_item.icon, 0, 112, 24, 2, 2, 0, c_white, 1);

		draw_set_halign(fa_left);
		//draw_text(4, 80, "Price: "+string(price)+" gold.");
		//draw_text(4, 96, "Level: "+string(level));
		//draw_text(4, 112, "Rarity: "+string(rarity));
		draw_text(4, 128, "Type: "+string(_item.type));

		draw_set_halign(fa_center);
		draw_text_ext(128, 196, _item.description, 16, 248);
	}

	
}