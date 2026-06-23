///@description Resizes the inventory and sorts items by type(name), stacking the maximum possible.
///@param Container_Id
///@param New_Width
///@param New_Height
function inv_container_resize(argument0, argument1, argument2) {

	//You can make it 500x500...but that's huge! :) Also, you may fix a minimum and a maximum size.

	var container = argument0;
	var tmp_width = argument1;
	var tmp_height = argument2;

	//Set the maximum and minimum size.
	var min_width_size = 1;
	var min_height_size = 1;
	var max_width_size = 16;
	var max_height_size = 16;

	//Security control! We need a valid size. 
	if ((!is_real(tmp_width) || !is_real(tmp_height)) || (tmp_width < min_width_size || tmp_height < min_height_size) || (tmp_width > max_width_size || tmp_height > max_height_size))
	{
	show_message("Invalid size!");
	exit;
	}



	if (obj_inventory.State == "drag") //First, place dragged item on the inventory. (if one selected!)
	{
	inv_container_add_item(container, obj_inventory.Selected_Item_Id, obj_inventory.Selected_Item_Qty, obj_player.x, obj_player.y);
	}

	//Reset selection
	inv_inventory_reset_selection("wait");

	var new_inv_width = tmp_width;
	var new_inv_height = tmp_height;
	var list;

	//Backup inventory into 2 lists. 1 list for id and 1 list for quantity. (Index of second list matches with the first list)
	list[0] = ds_list_create();
	list[1] = ds_list_create();

	var tmp_nmb_of_cells = array_height_2d(container.Array_Inv);

	var cell_val, cell_qty, index_val, index_qty;
  
	//Scan the inventory and fill both list.
	for(i=0; i<tmp_nmb_of_cells; i++)
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
    
	}


	with(container)
	{
	//Resize inventory.
	Inv_Width = new_inv_width;
	Inv_Height = new_inv_height;

		if(!surface_exists(Surface_Container))
		{
		surface_create(Inv_Width*Inv_Cell_Size, Inv_Height*Inv_Cell_Size);
		}
		else
		{
		surface_resize(Surface_Container, Inv_Width*Inv_Cell_Size, Inv_Height*Inv_Cell_Size);
		}



	//Clear the Array_Inv array
	Array_Inv = 0; 
	}



	var xx = 0;
	var yy = 0;

	var count = 0;

	//Rebuild Array_Inv with the new size.
	repeat(new_inv_height)
	{
	xx = 0;

	    repeat(new_inv_width)
	    {
	    container.Array_Inv[count,0] = -1;
	    container.Array_Inv[count,1] = 0;
	    container.Array_Inv[count,2] = "none";
	    container.Array_Inv[count,3] = xx*container.Inv_Cell_Size;
	    container.Array_Inv[count,4] = yy*container.Inv_Cell_Size;
	    xx++;
	    count ++;
	    }
    
	yy++;
	}


	with(container)
	{
	Xbox2 = Xbox1+Inv_Width*Inv_Cell_Size;
	Ybox2 = Ybox1+Inv_Height*Inv_Cell_Size;
	}

	//Clean the surface
	inv_update_surface(container);

	var tmp_item, tmp_qty;

	//Re-fill it up
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
