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
		var panel_xscale = 1.4
		var panel_yscale = 1.4

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
		var _tab_spacing = 500 / array_length(global.inventory_tab_name) //ITEM_TYPE.COUNT

		for (var i = 0; i < array_length(global.inventory_tab_name); i++) 
		{
			// i matches the numeric value of each enum element sequentially
			//show_debug_message("Processing item index: " + string(i));

			if (inventoryTab == i)
			{
				draw_set_colour(c_yellow)
				draw_text(_panelX + (_tab_spacing * i), _panelY + _tab_yoffset, global.inventory_tab_name[i])
			}
			else
			{
				draw_set_colour(c_white)
				draw_set_alpha(0.7)
				draw_text(_panelX + (_tab_spacing * i), _panelY + _tab_yoffset, global.inventory_tab_name[i])
				draw_set_alpha(1)
			}
		}

		// Get items based on current tab
		currentItems = []
		if (array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.key_item))
		{
			for(var i = 0; i < array_length(global.inventoryKeyItems); i++)
			{
				array_push(currentItems, global.inventoryKeyItems[i])
			}
		}
		if (array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.consumable) || 
		array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.equipment) || 
		array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.material)	)
		{
			for(var i = 0; i < array_length(global.inventory); i++)
			{
				if (array_contains(global.inventory_tab_type[inventoryTab], global.inventory[i].type))
				{
					array_push(currentItems, global.inventory[i])
				}
			}
		}

		// Draw item grid (5 columns x 2 rows)
		var base_cell_w = sprite_get_width(ItemTray)
		var base_cell_h = sprite_get_height(ItemTray)
		var _cellWidth = 100
		var _cellHeight = 100
		var _iconWidth = 60
		var _iconHeight = 60
		var _cellSpacingX = 10
		var _cellSpacingY = 20
		var _gridStartX = _panelX + (scaled_w / 16)
		var _gridStartY = _panelY + (scaled_h / 12)
		var _cellTray_ScaleX = _cellWidth / base_cell_w
		var _cellTray_ScaleY = _cellHeight / base_cell_h

		for(var i = 0; i < global.inventoryMaxSlots; i++)
		{
			var _col = i mod 5
			var _row = i div 5
			var _cellX = _gridStartX + (_col * (_cellWidth + _cellSpacingX))
			var _cellY = _gridStartY + (_row * (_cellHeight + _cellSpacingY))

			draw_set_halign(fa_left)
			draw_set_valign(fa_top)
			// Draw item cell
			draw_sprite_ext(ItemTray, 0, _cellX, _cellY, _cellTray_ScaleX, _cellTray_ScaleY, 0, c_white, 1)
			//draw_set_colour(c_red);
			//draw_rectangle(_cellX, _cellY, _cellX + _cellWidth, _cellY + _cellHeight, true);
			//draw_set_colour(c_white);
			//draw_text(/*_cellX, _cellY,*/ _cellX + _cellWidth, _cellY + _cellHeight, "X: " + string(_cellX) + " Y: " + string(_cellY));
			

			if (i < array_length(currentItems))
			{
				var _item = currentItems[i]
				// Draw item icon if available
				if(_item.icon != -1)
				{
					base_w = sprite_get_width(_item.icon)
					base_h = sprite_get_height(_item.icon)

					draw_set_halign(fa_center)
					draw_set_valign(fa_middle)
					draw_sprite_ext(_item.icon, 0, _cellX + (_cellWidth / 8), _cellY + (_cellHeight / 8), _iconWidth / base_w  ,  _iconHeight / base_h, 0, c_white, 1)
				}

				// Draw item name below cell
				draw_set_halign(fa_center)
				draw_set_valign(fa_top)
				draw_set_colour(c_white)
				draw_text(_cellX + (_cellWidth / 2), _cellY + (_cellHeight - 5), currentItems[i].name)

				if(i == inventoryOptionSelected)
				{
					if (_item.id != -1)
					{
						panel_xscale = 0.4
						panel_yscale = 1
						// Fetch original asset sizes
						base_w = sprite_get_width(InventoryTray)
						base_h = sprite_get_height(InventoryTray)
						// Multiply by scale
						scaled_w = base_w * panel_xscale
						scaled_h = base_h * panel_yscale
						inventory_panelX = (RESOLUTION_W - scaled_w) / 2 + 300
						inventory_panelY = (RESOLUTION_H - scaled_h) / 2
						draw_set_halign(fa_left)
						draw_set_valign(fa_middle)

						draw_sprite_ext(InventoryTray, 0, inventory_panelX, inventory_panelY, panel_xscale, panel_yscale, 0, c_white, 1)

						inventory_panelX = inventory_panelX + (scaled_w / 2)

						draw_set_color(c_white);
						//draw_set_font(font0);

						draw_set_valign(fa_middle);
						draw_set_halign(fa_center);
						draw_text(inventory_panelX, inventory_panelY + 200, _item.name);

						base_w = sprite_get_width(_item.icon)
						base_h = sprite_get_height(_item.icon)
						
						draw_sprite_ext(_item.icon, 0, inventory_panelX, inventory_panelY + 100, _iconWidth / base_w  ,  _iconHeight / base_h, 0, c_white, 1);

						//draw_set_halign(fa_left);
						//draw_text(4, 80, "Price: "+string(price)+" gold.");
						//draw_text(4, 96, "Level: "+string(level));
						//draw_text(4, 112, "Rarity: "+string(rarity));
						draw_text(inventory_panelX, inventory_panelY, "Type: "+ ItemTypeToString(_item.type));

						//draw_set_halign(fa_center);
						draw_text_ext(inventory_panelX, inventory_panelY + 250, _item.description, 16, 248);
					}
				}
			}

			// Draw selection cursor
			if(i == inventoryOptionSelected)
			{
				draw_sprite(sCursor, 0, _cellX - 8, _cellY - 8)
			}
		}

		// Show empty message if no items
		if(array_length(currentItems) == 0)
		{
			draw_set_halign(fa_center);
  			draw_set_valign(fa_middle);
  			draw_set_colour(c_white);

			var _gridCenterX = _panelX + ((_cellWidth + _cellSpacingX) * (inventoryTab ? 2 : 1)) / 2;
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