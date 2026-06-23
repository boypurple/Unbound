///@description Put a container on the top of the List_Draw_Container list of obj_inventory.
///@param Container_Id
function inv_container_list_top(argument0) {


	//That means it will be drawn on top of the others.

	var container = argument0;

	if(container == -1)
	{
	exit;
	}

	with(obj_inventory)
	{
	ds_list_delete(List_Draw_Container, ds_list_find_index(List_Draw_Container, container));
	ds_list_insert(List_Draw_Container, 0, container);//Insert on position 0
	}


}
