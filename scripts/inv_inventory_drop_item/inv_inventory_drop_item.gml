///@description Creates/drops an item at X/Y.
///@param Item_Id
///@param Quantity
///@param x
///@param y
function inv_inventory_drop_item(argument0, argument1, argument2, argument3) {
	//This is a script you'll use when a monster/enemy drop something, when a crate has been destroyed, etc...


	var item_id = argument0;
	var quantity = argument1;
	var x1 = argument2;
	var y1 = argument3;

	with(instance_create_layer(x1, y1, global.Layer_Item, obj_item))
	{
	ds_list_add(List[0], item_id);
	ds_list_add(List[1], quantity);
	event_user(0);
	}


}
