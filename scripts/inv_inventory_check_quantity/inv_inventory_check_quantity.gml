///@description Returns the quantity of an item on a container
///@param Container_Id
///@param Name
function inv_inventory_check_quantity(argument0, argument1) {

	var container = argument0;
	var item_name = argument1;

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
		    amount += container.Array_Inv[i,1];
		    }
		}

	}

	return amount;



}
