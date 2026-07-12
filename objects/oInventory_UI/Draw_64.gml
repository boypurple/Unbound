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

		// Draw player tabs (above item tabs)
		draw_set_halign(fa_left)
		draw_set_valign(fa_bottom)

		var _player_tab_yoffset = -30
		var _player_tab_spacing = 500 / array_length(global.party)

		for (var i = 0; i < array_length(global.party); i++)
		{
			if (playerTab == i)
			{
				draw_set_colour(c_yellow)
				draw_text(_panelX + (_player_tab_spacing * i), _panelY + _player_tab_yoffset, global.party[i].name)
			}
			else
			{
				draw_set_colour(c_white)
				draw_set_alpha(0.7)
				draw_text(_panelX + (_player_tab_spacing * i), _panelY + _player_tab_yoffset, global.party[i].name)
				draw_set_alpha(1)
			}
		}

		// Draw item type tabs
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

		// Get items based on current tab and selected player
		currentItems = []
		
		// Get character inventory data with safety check
		var _selected_character = global.party[playerTab]
		var _inv_data = GetCharacterInventory(_selected_character.name)
		
		if (_inv_data != undefined)
		{
			if (array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.key_item))
			{
				for(var i = 0; i < array_length(_inv_data[$ "key_items"]); i++)
				{
					var _item_data = GetItemFromDatabase(_inv_data[$ "key_items"][i].id)
					array_push(currentItems, _item_data)
				}
			}
			if (array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.consumable) || 
			array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.equipment) || 
			array_contains(global.inventory_tab_type[inventoryTab], ITEM_TYPE.material)	)
			{
				for(var i = 0; i < array_length(_inv_data[$ "items"]); i++)
				{
					var _item_data = GetItemFromDatabase(_inv_data[$ "items"][i].id)
					if (array_contains(global.inventory_tab_type[inventoryTab], _item_data.type))
					{
						array_push(currentItems, _item_data)
					}
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
		var _cellSpacingX = 15
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
				var _icon = _item[$ "icon"];
				var _img_index = _item[$ "image_index"] ?? 0; // Jika tidak ada image_index, default ke 0

				if (_icon != undefined && sprite_exists(_icon))
				{
					base_w = sprite_get_width(_icon);
					base_h = sprite_get_height(_icon);

					draw_set_halign(fa_center);
					draw_set_valign(fa_middle);
					
					// Gunakan variabel _icon dan _img_index yang sudah aman di sini
					draw_sprite_ext(_icon, _img_index, _cellX + (_cellWidth / 8), _cellY + (_cellHeight / 8), _iconWidth / base_w, _iconHeight / base_h, 0, c_white, 1);
				}

				// Draw item name below cell
				draw_set_halign(fa_center)
				draw_set_valign(fa_top)
				draw_set_colour(c_white)
				//show_debug_message("Display Item: " + _item.name);
				draw_text(_cellX + (_cellWidth / 2), _cellY + (_cellHeight - 5), _item.name)

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

						base_w = sprite_get_width(_icon)
						base_h = sprite_get_height(_icon)
						
						draw_sprite_ext(_icon, _img_index, inventory_panelX - (base_w), inventory_panelY + 100 - (base_h), _iconWidth / base_w  ,  _iconHeight / base_h, 0, c_white, 1);

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

		// Draw item options menu when in item options mode
		if(inventoryCursor == 3 && selectedItemIndex >= 0 && selectedItemIndex < array_length(currentItems))
		{
			var _options = ["Pass to other character", "Drop/Remove item"]
			var _menuX = _panelX + scaled_w + 50
			var _menuY = _panelY + 100
			var _optionHeight = 40
			var _optionSpacing = 10
			
			draw_set_halign(fa_center)
			draw_set_valign(fa_middle)
			// Draw InventoryTray panel behind options
			var _optionPanelScaleX = 0.6
			var _optionPanelScaleY = 0.6
			var _optionPanelW = sprite_get_width(InventoryTray) * _optionPanelScaleX
			var _optionPanelH = sprite_get_height(InventoryTray) * _optionPanelScaleY
			draw_sprite_ext(InventoryTray, 0, _menuX - _optionPanelW/4, _menuY - _optionPanelH/4, _optionPanelScaleX, _optionPanelScaleY, 0, c_white, 1)
			
			draw_set_halign(fa_left)
			draw_set_valign(fa_middle)
			
			for(var i = 0; i < array_length(_options); i++)
			{
				var _optionY = _menuY + (i * (_optionHeight + _optionSpacing))
				
				// Draw option background
				if(itemOptionSelected == i)
				{
					draw_set_colour(c_yellow)
					draw_rectangle(_menuX - 10, _optionY - _optionHeight/2, _menuX + 250, _optionY + _optionHeight/2, false)
					draw_set_colour(c_black)
				}
				else
				{
					draw_set_colour(c_white)
				}
				
				draw_text(_menuX, _optionY, _options[i])
			}
			
			draw_set_colour(c_white)
		}
		
		// Draw character selection menu when in character selection mode
		if(inventoryCursor == 4)
		{
			var _charMenuX = _panelX + scaled_w + 50
			var _charMenuY = _panelY + 100
			var _charOptionHeight = 40
			var _charOptionSpacing = 10
			
			draw_set_halign(fa_center)
			draw_set_valign(fa_middle)
			// Draw InventoryTray panel behind options
			var _optionPanelScaleX = 0.6
			var _optionPanelScaleY = 0.6
			var _optionPanelW = sprite_get_width(InventoryTray) * _optionPanelScaleX
			var _optionPanelH = sprite_get_height(InventoryTray) * _optionPanelScaleY
			draw_sprite_ext(InventoryTray, 0, _charMenuX - _optionPanelW/4, _charMenuY - _optionPanelH/4, _optionPanelScaleX, _optionPanelScaleY, 0, c_white, 1)
			
			draw_set_halign(fa_left)
			draw_set_valign(fa_middle)
			
			// Draw title
			draw_set_colour(c_white)
			draw_text(_charMenuX, _charMenuY - 30, "Select character:")
			
			// Draw character options (excluding current character)
			var _charIndex = 0
			for(var i = 0; i < array_length(global.party); i++)
			{
				if(i != playerTab)
				{
					var _charOptionY = _charMenuY + (_charIndex * (_charOptionHeight + _charOptionSpacing))
					
					// Draw character option background
					if(characterOptionSelected == i)
					{
						draw_set_colour(c_yellow)
						draw_rectangle(_charMenuX - 10, _charOptionY - _charOptionHeight/2, _charMenuX + 250, _charOptionY + _charOptionHeight/2, false)
						draw_set_colour(c_black)
					}
					else
					{
						draw_set_colour(c_white)
					}
					
					draw_text(_charMenuX, _charOptionY, global.party[i].name)
					_charIndex++
				}
			}
			
			draw_set_colour(c_white)
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
		draw_text(1248, 688, "Press Esc to go back | <- and -> to switch tabs")
}