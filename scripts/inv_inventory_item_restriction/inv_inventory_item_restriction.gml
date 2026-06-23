///@description Returns true if item meets the restriction on a Container Cell.
///@param Container_Id
///@param Container_Cell
///@param Item_ Id
function inv_inventory_item_restriction(argument0, argument1, argument2) {


	var container = argument0;
	var con_cell = argument1;
	var item_id = argument2;


	//On that current project, restriction is the NAME(I_NAME) of the item. (Index 0 on the X axis of global.items)


	var item_restriction = global.items[# I_NAME, item_id];

	var cell_restriction = container.Array_Inv[con_cell, 2];


	if(cell_restriction == "none" || item_restriction == cell_restriction)
	{
	return 1;
	}
	else
	{
	return 0;
	}

	/*
	A good idea could be to add a TYPE on the item properties on the database(on the X axis). Like : armor_head, ring, potion, scroll, gold, etc...
	You could create more script like this one. To check if the item is magic, cost at least 100 golds, etc...

/* end inv_inventory_item_restriction */
}
