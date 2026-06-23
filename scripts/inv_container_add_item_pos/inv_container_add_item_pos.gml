///@description Adds items on a container at a fixed position. If no place available, it will be place elsewhere on that containter, otherwise it will be dropped at Drop_X/Drop_Y.
///@param Container_Id
///@param Container_Cell
///@param Item_Id
///@param Quantity
///@param Drop_X
///@param Drop_Y
function inv_container_add_item_pos(argument0, argument1, argument2, argument3, argument4, argument5) {

	var item_id, item_qty, max_stack, cell_val, cell_qty, amount;

	var container = argument0;
	var con_cell = argument1;
	var item_id = argument2;
	var item_qty = argument3;
	var dropx = argument4; //If can't be placed, where the item will be dropped.
	var dropy = argument5;

	var max_stack = global.items[# I_MAXSTACK, item_id];

	if (item_qty < 1)
	{
	exit;
	}

	var cell_val = container.Array_Inv[con_cell, 0];
	var cell_qty = container.Array_Inv[con_cell, 1];
	var amount = 0;

	//On empty cell if restriction is met.         
	if (cell_val == -1 && inv_inventory_item_restriction(container, con_cell, item_id))
	{
	container.Array_Inv[con_cell, 0] = item_id;
	amount = min(item_qty, max_stack);
	container.Array_Inv[con_cell, 1] += amount;
	item_qty -= amount;
	inv_update_surface_pos(container, con_cell);//update that single cell
	}
	else if (cell_val == item_id) //Cell with the same type.
	{
	amount = min(item_qty, max_stack-cell_qty);
	container.Array_Inv[con_cell, 1] += amount;
	item_qty -= amount;
	inv_update_surface_pos(container, con_cell);//update that single cell
	}
           
	if (item_qty) //We can't place that item on that cell, we'll try to place it elsewhere on the container:
	{
	inv_container_add_item(container, item_id, item_qty, dropx, dropy);
	}


}
