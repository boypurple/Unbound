///@description Imporant: every container that you add to your game MUST add its ID to that list.
///@param Container_Id
function inv_container_list_add(argument0) {

	var container = argument0;

	if(container == -1)
	{
	exit;
	}

	with(obj_inventory)
	{
	ds_list_add(List_Draw_Container, container);
	}


}
