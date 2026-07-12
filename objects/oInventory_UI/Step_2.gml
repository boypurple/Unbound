if(global.gamePaused)
{
	keyUp = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))
	keyDown = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))
	keyLeft = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
	keyRight = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))
	keyActivate = keyboard_check_pressed(vk_space)
	keyDeactivate = keyboard_check_pressed(vk_escape)
	isInput = keyUp || keyDown || keyLeft || keyRight || keyActivate || keyDeactivate

	if (isInput)
	{
		if (inventoryCursor == 0)
		{
			// Player tab switching with left/right keys
			playerTab += (keyRight - keyLeft)
			playerTab = clamp(playerTab, 0, array_length(global.party) - 1)
			if (keyDown == 1)
			{
				inventoryCursor = 1
				inventoryTab = 0
			}
		}
		else if (inventoryCursor == 1)
		{
			// Item type tab switching with left/right keys
			inventoryTab += (keyRight - keyLeft)
			inventoryTab = clamp(inventoryTab, 0, array_length(global.inventory_tab_name) - 1)
			if (keyDown == 1)
			{
				inventoryCursor = 2
				inventoryOptionSelected = 0
			}
			if (keyUp == 1)
			{
				inventoryCursor = 0
			}
		}
		else if (inventoryCursor == 2)
		{
			// Item selection
			inventoryOptionSelected += ((keyRight - keyLeft) + ((keyDown - keyUp) * global.inventoryMaxColumn))
			if(inventoryOptionSelected < 0) 
			{
				inventoryCursor = 1
			}
			inventoryOptionSelected = clamp(inventoryOptionSelected, -1, global.inventoryMaxSlots - 1)
			
			// Enter to open item options if slot has item
			if(keyActivate && inventoryOptionSelected >= 0 && inventoryOptionSelected < array_length(currentItems))
			{
				inventoryCursor = 3
				itemOptionSelected = 0
				selectedItemIndex = inventoryOptionSelected
			}
		}
		else if (inventoryCursor == 3)
		{
			// Item options navigation
			itemOptionSelected += (keyDown - keyUp)
			itemOptionSelected = clamp(itemOptionSelected, 0, 1)
			
			// ESC to return to item selection
			if(keyDeactivate)
			{
				inventoryCursor = 2
				selectedItemIndex = -1
			}
			
			// Enter to execute selected option
			if(keyActivate)
			{
				if(itemOptionSelected == 0)
				{
					// Pass to other character - go to character selection
					inventoryCursor = 4
					characterOptionSelected = 0
					// Skip current character in selection
					if(characterOptionSelected == playerTab)
					{
						characterOptionSelected = (characterOptionSelected + 1) mod array_length(global.party)
					}
				}
				else if(itemOptionSelected == 1)
				{
					// Drop/Remove item
					var _selected_character = global.party[playerTab]
					var _inv_data = GetCharacterInventory(_selected_character.name)
					
					if(_inv_data != undefined && selectedItemIndex >= 0)
					{
						var _item = undefined
						if(inventoryTab == 1) // Key Items tab
						{
							if(selectedItemIndex < array_length(_inv_data[$ "key_items"]))
							{
								_item = _inv_data[$ "key_items"][selectedItemIndex]
							}
						}
						else // Normal Items tab
						{
							if(selectedItemIndex < array_length(_inv_data[$ "items"]))
							{
								_item = _inv_data[$ "items"][selectedItemIndex]
							}
						}
						
						if(_item != undefined)
						{
							var playerPosX = obj_player.posX[0]
							var playerPosY = obj_player.posY[0]
							SpawnItemPickupRandomAroundPosition(playerPosX, playerPosY, _item.id)
							RemoveItemFromCharacterInventory(_selected_character.name, _item.id, _item.stack)
						}
					}
					
					// Return to item selection after action
					inventoryCursor = 2
					selectedItemIndex = -1
				}
			}
		}
		else if (inventoryCursor == 4)
		{
			// Character selection navigation
			characterOptionSelected += (keyDown - keyUp)
			characterOptionSelected = clamp(characterOptionSelected, 0, array_length(global.party) - 1)
			
			// Skip current character
			if(characterOptionSelected == playerTab)
			{
				characterOptionSelected = (characterOptionSelected + 1) mod array_length(global.party)
			}
			
			// ESC to return to item options
			if(keyDeactivate)
			{
				inventoryCursor = 3
			}
			
			// Enter to execute item passing
			if(keyActivate)
			{
				var _from_character = global.party[playerTab]
				var _to_character = global.party[characterOptionSelected]
				var _inv_data = GetCharacterInventory(_from_character.name)
				
				if(_inv_data != undefined && selectedItemIndex >= 0)
				{
					var _item = undefined
					if(inventoryTab == 1) // Key Items tab
					{
						if(selectedItemIndex < array_length(_inv_data[$ "key_items"]))
						{
							_item = _inv_data[$ "key_items"][selectedItemIndex]
						}
					}
					else // Normal Items tab
					{
						if(selectedItemIndex < array_length(_inv_data[$ "items"]))
						{
							_item = _inv_data[$ "items"][selectedItemIndex]
						}
					}
					
					if(_item != undefined)
					{
						// Remove from current character
						RemoveItemFromCharacterInventory(_from_character.name, _item.id, _item.stack)
						// Add to target character
						AddItemToCharacterInventory(_to_character.name, _item.id, _item.stack)
						show_debug_message("Passed " + _item.id + " from " + _from_character.name + " to " + _to_character.name)
					}
				}
				
				// Return to item selection after action
				inventoryCursor = 2
				selectedItemIndex = -1
			}
		}

		inventoryCursor = clamp(inventoryCursor, 0, 4)
	}

	if(keyActivate)
	{
		// Use selected item
		if(inventoryCursor == 2 && array_length(currentItems) > 0)
		{
			var _item = currentItems[inventoryOptionSelected]
			// Add item usage logic here
		}
	}
	if(keyDeactivate && instance_exists(instance_inventory) && inventoryCursor != 3 && inventoryCursor != 4)
	{
		instance_deactivate_object(instance_inventory)
		global.gameMenu = true
		instance_inventory = noone
	}

	frame += 1
}