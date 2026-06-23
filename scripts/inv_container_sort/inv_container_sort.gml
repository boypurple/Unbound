///@description Regroups items by type(name), stacking the maximum possible.
///@param Container_Id
function inv_container_sort(argument0) {

	var container = argument0;

	if (container == -1)
	{
	exit;
	}

	if(obj_inventory.Selected_Item_Id != -1 && obj_inventory.State == "drag") //First, place Selected dragged item on the container if one selected.
	{
	inv_container_add_item(container, obj_inventory.Selected_Item_Id, obj_inventory.Selected_Item_Qty, obj_player.x, obj_player.y);
	}

	//Reset
	inv_inventory_reset_selection("wait");


	var list;

	//One list for item id/value and one list for the quantity
	list[0] = ds_list_create();
	list[1] = ds_list_create();


	//Scan the inventory grid and fill both list
	var tmp_cells_qty = array_height_2d(container.Array_Inv);
	var cell_val;
	var cell_qty;
	var index_val;
	var index_qty;
	var i;

	    for(i=0; i<tmp_cells_qty; i++)
	    {
	    cell_val = container.Array_Inv[i,0];
        
	        if (cell_val != -1)
	        {
	        cell_qty = container.Array_Inv[i,1];
	        index_val = ds_list_find_index(list[0], cell_val);
            
	            if (index_val !=-1) //Stack together items of the same type
	            {
	            index_qty = ds_list_find_value(list[1], index_val);
	            ds_list_replace(list[1], index_val, index_qty+cell_qty);
	            }
	            else
	            {
	            ds_list_add(list[0], cell_val);
	            ds_list_add(list[1], cell_qty);
	            }
	        }
	    container.Array_Inv[i,0] = -1;
	    container.Array_Inv[i,1] = 0;
	    }

	//Clean the surface
	inv_update_surface(container);


	var tmp_item, tmp_qty;

	//Refill inventory and emptied both list at the same time.
	while (!ds_list_empty(list[0]))
	{
	tmp_item = ds_list_find_value(list[0], 0);
	tmp_qty = ds_list_find_value(list[1], 0);
	inv_container_add_item(container, tmp_item, tmp_qty, obj_player.x, obj_player.y);
	ds_list_delete(list[0], 0);
	ds_list_delete(list[1], 0);
	}


	//Clean up memory.
	ds_list_destroy(list[0]);
	ds_list_destroy(list[1]);




}
