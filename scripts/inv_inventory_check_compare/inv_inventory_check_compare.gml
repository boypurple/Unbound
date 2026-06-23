///@description Returns true if at least x quantity of two objects.
///@param Container_Id
///@param Name1
///@param Quantity1
///@param Name2
///@param Quantity2
function inv_inventory_check_compare(argument0, argument1, argument2, argument3, argument4) {

	/*
	I.E: inv_inventory_check_compare(obj_player_backpack.id, "Icy Axe", 1, "Icy Plate", 1);
	Checks if player had at least 1 Icy Axe and 1 Icy Plate in his backpack
	*/

	var container = argument0;
	var item1 = argument1;
	var qty1 = argument2
	var item2 = argument3;
	var qty2 = argument4;

	var nmb_of_cells = array_height_2d(container.Array_Inv);

	var item1_qty = 0;
	var item2_qty = 0;

	var i, cell_name, cell_value;

	//Scans all cells and compares the name
	for(i=0; i<nmb_of_cells; i++)
	{
	cell_value = container.Array_Inv[i,0];

		if(cell_value != -1)
		{
		cell_name = global.items[# I_NAME,container.Array_Inv[i,0]];

		    if(cell_name == item1)
		    {
		    item1_qty += container.Array_Inv[i,1];
		    }
			else if(cell_name == item2)
		    {
		    item2_qty += container.Array_Inv[i,1];
		    }
		}

	}

	if(item1_qty >= qty1 && item2_qty= qty2)
	{
	return 1;
	}
	else
	{
	return 0;
	}





}
