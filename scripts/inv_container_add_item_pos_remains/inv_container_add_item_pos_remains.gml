///@description Add an item on a container at a fixed position and keep remains selected.
///@param Container_Id
///@param Container_Cell
///@param Item_Id
///@param Quantity
function inv_container_add_item_pos_remains(argument0, argument1, argument2, argument3) {


	//That happens when adding a dragged item on a cell with the same type. It's similiar to inv_container_add_item_pos.


	var item_id, item_qty, max_stack, cell_val, cell_qty, amount;

	var container = argument0;
	var con_cell = argument1;
	var item_id = argument2;
	var item_qty = argument3;

	var max_stack = global.items[# I_MAXSTACK, item_id];

	if (item_qty < 1)
	{
	exit;
	}

	var cell_val = container.Array_Inv[con_cell, 0];
	var cell_qty = container.Array_Inv[con_cell, 1];
	var amount = 0;

           
	if (cell_val == -1 && inv_inventory_item_restriction(container, con_cell, item_id)) //On empty cell if restriction is met.
	{
	container.Array_Inv[con_cell, 0] = item_id;
	amount = min(item_qty, max_stack);
	container.Array_Inv[con_cell, 1] += amount;
	item_qty -= amount;
	}
	else if (cell_val == item_id) //Cell with the same item.
	{
	amount = min(item_qty, max_stack-cell_qty);
	container.Array_Inv[con_cell, 1] += amount;
	item_qty -= amount;
	}
           
	if (item_qty) //We don't drop the remains, we keep it selected.
	{
	obj_inventory.Selected_Item_Qty = item_qty;
	}
	else
	{
	inv_inventory_reset_selection("wait");
	}

	inv_update_surface_pos(container, con_cell);//update that single cell



}
