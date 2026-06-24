/// @desc Pause Screen
if(global.gamePaused)
{
		draw_set_colour(c_black)
		draw_set_alpha(0.75)
		draw_rectangle(0, 0, RESOLUTION_W, RESOLUTION_H, false)
		draw_set_alpha(1)
		draw_set_colour(c_white)
		draw_set_font(fnMother3)
		draw_set_valign(fa_top)
		draw_set_halign(fa_center)

		// Draw inventory panel - centered and scaled to fill most of screen
		var panel_xscale = 1.2
		var panel_yscale = 1.2

		// Fetch original asset sizes
		var base_w = sprite_get_width(InventoryTray)
		var base_h = sprite_get_height(InventoryTray)

		// Multiply by scale
		var scaled_w = base_w * panel_xscale
		var scaled_h = base_h * panel_yscale

		var _panelX = (RESOLUTION_W - scaled_w) / 2
		var _panelY = (RESOLUTION_H - scaled_h) / 2

		draw_sprite_ext(InventoryTray, 0, _panelX, _panelY, panel_xscale, panel_yscale, 0, c_white, 1)

		// Draw tabs
		draw_set_halign(fa_left)
		draw_set_valign(fa_bottom)

		var _tab_yoffset = 10

		// Normal Items tab
		if(inventoryTab == 0)
		{
			draw_set_colour(c_yellow)
			draw_text(_panelX, _panelY + _tab_yoffset, "Normal Items")
		}
		else
		{
			draw_set_colour(c_white)
			draw_set_alpha(0.7)
			draw_text(_panelX, _panelY + _tab_yoffset, "Normal Items")
			draw_set_alpha(1)
		}

		// Key Items tab
		if(inventoryTab == 1)
		{
			draw_set_colour(c_yellow)
			draw_text(_panelX + 300, _panelY + _tab_yoffset, "Key Items")
		}
		else
		{
			draw_set_colour(c_white)
			draw_set_alpha(0.7)
			draw_text(_panelX + 400, _panelY + _tab_yoffset, "Key Items")
			draw_set_alpha(1)
		}

		// Get items based on current tab
		var _currentItems = []
		if(inventoryTab == 0)
		{
			// Normal items (non-key items)
			for(var i = 0; i < array_length(global.inventory); i++)
			{
				array_push(_currentItems, global.inventory[i])
			}
		}
		else
		{
			// Key items only
			for(var i = 0; i < array_length(global.inventoryKeyItems); i++)
			{
				if(global.inventoryKeyItems[i].type == ITEM_TYPE_KEY)
				{
					array_push(_currentItems, global.inventoryKeyItems[i])
				}
			}
		}

		// Draw item grid (5 columns x 2 rows)
		var _cellWidth = 80
		var _cellHeight = 80
		var _cellSpacing = 20
		var _gridStartX = _panelX + (scaled_w / 12)
		var _gridStartY = _panelY + (scaled_h / 12)
		var _cellSpriteScale = 0.5
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)

		for(var i = 0; i < global.inventoryMaxSlots; i++)
		{
			var _col = i mod 5
			var _row = i div 5
			var _cellX = _gridStartX + (_col * (_cellWidth + _cellSpacing))
			var _cellY = _gridStartY + (_row * (_cellHeight + _cellSpacing))

			// Draw item cell
			draw_sprite_ext(ItemTray, 0, _cellX, _cellY, _cellSpriteScale, _cellSpriteScale, 0, c_white, 1)
			//draw_set_colour(c_red);
			//draw_rectangle(_cellX, _cellY, _cellX + _cellWidth, _cellY + _cellHeight, true);
			//draw_set_colour(c_white);
			//draw_text(/*_cellX, _cellY,*/ _cellX + _cellWidth, _cellY + _cellHeight, "X: " + string(_cellX) + " Y: " + string(_cellY));

			if (i < array_length(_currentItems))
			{
				var _item = _currentItems[i]
				if (_item.id != -1)
				{
					// Draw item icon if available
					if(_item.icon != -1)
					{
						draw_sprite(_item.icon, 0, _cellX + _cellWidth / 2, _cellY + _cellHeight / 2)
					}

					panel_xscale = 0.2
					panel_yscale = 0.9
					// Fetch original asset sizes
					base_w = sprite_get_width(InventoryTray) / 6
					base_h = sprite_get_height(InventoryTray) * 3 / 4
					// Multiply by scale
					scaled_w = base_w * panel_xscale
					scaled_h = base_h * panel_yscale
					_panelX = (RESOLUTION_W - scaled_w) / 2
					_panelY = (RESOLUTION_H - scaled_h) / 2
					draw_set_halign(fa_right)
					draw_set_valign(fa_middle)

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

				// Draw item name below cell
				draw_set_halign(fa_center)
				draw_set_valign(fa_top)
				draw_set_colour(c_white)
				draw_text(_cellX + _cellWidth / 2, _cellY + _cellHeight + 4, _currentItems[i].name)
			}

			// Draw selection cursor
			if(i == inventoryOptionSelected)
			{
				draw_sprite(sCursor, 0, _cellX - 8, _cellY - 8)
			}
		}

		// Show empty message if no items
		if(array_length(_currentItems) == 0)
		{
			draw_set_halign(fa_center);
  			draw_set_valign(fa_middle);
  			draw_set_colour(c_white);

			var _gridCenterX = _panelX + ((_cellWidth + _cellSpacing) * (inventoryTab ? 2 : 1)) / 2;
			var _gridCenterY = _gridStartY - _cellHeight / 2;
			var _panelCenterX = _panelX + (scaled_w / 2);
			var _panelCenterY = _panelY + (scaled_h / 2);

  			var _tabName = inventoryTab == 0 ? "Normal Items" : "Key Items";
  			draw_text(_panelCenterX, _panelCenterY, "No " + _tabName);
		}

		draw_set_halign(fa_right)
		draw_set_valign(fa_bottom)
		draw_text(1248, 688, "Press [Esc] to go back | [←/→] to switch tabs")
}