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
		}

		inventoryCursor = clamp(inventoryCursor, 0, 2)
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
	if(keyDeactivate && instance_exists(instance_inventory) )
	{
		instance_deactivate_object(instance_inventory)
		global.gameMenu = true
		instance_inventory = noone
	}

	frame += 1
}