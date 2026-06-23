///@description Adds a quantity of an item on inventory. It prioritizes to fill stack of the same type.
///@param Container_Id
///@param Item_Id
///@param Quantity
///@param Drop_X
///@param Drop_Y
function inv_container_add_item(argument0, argument1, argument2, argument3, argument4) {

	//If no place available, the item is dropped on the floor at Drop_X, Drop_Y


	var container = argument0;
	var item_id = argument1;
	var item_qty = argument2;
	var dropx = argument3;
	var dropy = argument4;

	var max_stack = global.items[# I_MAXSTACK, item_id];

	if (item_qty < 1)
	{
	exit;
	}

	var nmb_of_cells = array_height_2d(container.Array_Inv);
	var cell_qty = 0;
	var amount = 0;
	var i;

	//The first scan will fill cells containing the same item
	for(i=0; i<nmb_of_cells; i++)
	{
	    if (container.Array_Inv[i,0] == item_id)
	    {
	    cell_qty = container.Array_Inv[i,1];
	    amount = min(item_qty, max_stack-cell_qty);
	    container.Array_Inv[i, 1] += amount;
	    item_qty -= amount;
	    inv_update_surface_pos(container, i);//update that single cell
        
	        if (item_qty == 0) //No more item, break!
	        {
	        break;
	        }
	    }

	}

	//Second scan will fill first empty cell met if restriction is met.
	if (item_qty > 0)
	{
	    for(i=0; i<nmb_of_cells; i++)
	    {
	        if (container.Array_Inv[i,0] == -1 && inv_inventory_item_restriction(container, i, item_id))
	        {
	        container.Array_Inv[i,0] = item_id;
	        amount = min(item_qty, max_stack);
	        container.Array_Inv[i, 1] += amount;
	        item_qty -= amount;
	        inv_update_surface_pos(container, i);//update that single cell
        
	            if (item_qty == 0) //No more item, break!
	            {
	            break;
	            }
	        }
    
	    }
	}

	if (item_qty) //If we can't place remaining items on the inventory, we drop them:
	{
	inv_inventory_drop_item(item_id, item_qty, dropx, dropy);
	}




}
