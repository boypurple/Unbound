///@description Removes a quantity of an item on target container(if available) If not enough, it will not remove it.
///@param Container_Id
///@param Name
///@param Quantity to remove
function inv_inventory_remove_item(argument0, argument1, argument2) {

	var container = argument0;
	var item_name = argument1;
	var quantity = argument2;

	with(obj_inventory)
	{
		if(Selected_Item_Id != -1 && State == "drag") //First, place Selected dragged item on the container if one selected.
		{
		inv_container_add_item(container, Selected_Item_Id, Selected_Item_Qty, obj_player.x, obj_player.y);
		}
	}

	var nmb_of_cells = array_height_2d(container.Array_Inv);
	var amount = 0;
	var i, cell_name, cell_value;

	//Scans all cells and compares the name
	for(i=0; i<nmb_of_cells; i++)
	{
	cell_value = container.Array_Inv[i,0];

		if(cell_value != -1)
		{
		cell_name = global.items[# I_NAME,container.Array_Inv[i,0]];
    
			if(cell_name == item_name)
		    {
		    amount = container.Array_Inv[i,1];
		
				if(amount >= quantity)
				{
				container.Array_Inv[i,1] -= quantity;
			
					if(container.Array_Inv[i,1] <= 0)
					{
					inv_container_clear_cell(container, i);
					inv_inventory_reset_selection("wait");
					}
				}
		    }
		}

	}

	inv_container_surface(container);



}
