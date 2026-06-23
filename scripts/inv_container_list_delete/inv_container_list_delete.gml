///@description Imporant: every container that you remove from your game MUST delete its ID to that list.
///@param Container_Id
function inv_container_list_delete(argument0) {

	var container = argument0;

	if(container == -1)
	{
	exit;
	}

	with(obj_inventory)
	{

	    //If we are dragging an item from the container that we are closing, we drop it at obj_player x/y...
	    if(Selected_Con_Id == container)
	    {
	        if(State == "drag" && Selected_Item_Id != -1)
	        {
	        inv_inventory_drop_item(Selected_Item_Id, Selected_Item_Qty, obj_player.x, obj_player.y);
	        }
        
	    inv_inventory_reset_selection("wait");//...and reset selection
	    }
    
	ds_list_delete(List_Draw_Container, ds_list_find_index(List_Draw_Container, container));
	}


}
