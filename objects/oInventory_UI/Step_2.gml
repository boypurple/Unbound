if(global.gamePaused)
{
	keyUp = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))
	keyDown = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))
	keyLeft = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
	keyRight = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))
	keyActivate = keyboard_check_pressed(vk_space)
	keyDeactivate = keyboard_check_pressed(vk_escape)
	isInput = keyUp || keyDown || keyLeft || keyRight || keyActivate || keyDeactivate
	// Get items based on current tab
	var _currentItems = []
	if(inventoryTab == 0)
	{
		// Normal items (non-key items)
		for(var i = 0; i < array_length(global.inventory); i++)
		{
			if(global.inventory[i].type != ITEM_TYPE_KEY)
			{
				array_push(_currentItems, global.inventory[i])
			}
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

	if (isInput)
	{
		show_debug_message("Input detected: Up: " + string(keyUp) + ", Down: " + string(keyDown) + ", Left: " + string(keyLeft) + ", Right: " + string(keyRight) + ", Frame: " + string(frame) )
	}

	if (isInput)
	{
		if (inventoryCursor == 0)
		{
			// Tab switching with left/right keys
			inventoryTab += (keyRight - keyLeft)
			inventoryTab = clamp(inventoryTab, 0, 1)
			if (keyDown == 1)
			{
				inventoryCursor = 1
				inventoryOptionSelected = 0
			}
			show_debug_message("inventoryTab " + string(inventoryTab))
		}
		else if (inventoryCursor == 1)
		{
			// Item selection
			inventoryOptionSelected += ((keyRight - keyLeft) + ((keyDown - keyUp) * global.inventoryMaxColumn)) // Allow horizontal keys to also navigate items
			if(inventoryOptionSelected < 0) 
			{
				inventoryCursor = 0
			}
			inventoryOptionSelected = clamp(inventoryOptionSelected, -1,  global.inventoryMaxSlots - 1)
			show_debug_message("inventoryOptionSelected " + string(inventoryOptionSelected))

			/*
			var _item = {id: -1, name: "", description: "", type: "", icon: -1}
			if(inventoryOptionSelected >= 0 && inventoryOptionSelected < array_length(_currentItems) && _currentItems[inventoryOptionSelected].id != -1)
			{
				_item = _currentItems[inventoryOptionSelected]
			}
			ItemDescriptionPanel(_item)
			*/
		}

		inventoryCursor = clamp(inventoryCursor, 0, 1)
		show_debug_message("inventoryCursor " + string(inventoryCursor))
	}

	if(keyActivate)
	{
		// Use selected item
		if(array_length(_currentItems) > 0)
		{
			var _item = _currentItems[inventoryOptionSelected]
			// Add item usage logic here
		}
	}
	if(keyDeactivate && instance_exists(instance_inventory) )
	{
		instance_deactivate_object(instance_inventory)
		global.gameMenu = true
		instance_inventory = noone
	}

	frame += 1
}