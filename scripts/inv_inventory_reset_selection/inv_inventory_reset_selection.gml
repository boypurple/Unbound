///@description Resets a selection on obj_inventory
///@param State
function inv_inventory_reset_selection(argument0) {

	var tmp_state = argument0;

	with(obj_inventory)
	{
	Selected_Con_Id = -1;
	Selected_Con_Cell = -1;
	Selected_Item_Id = -1;
	Selected_Item_Sprite = -1;
	Selected_Item_Image_Index = -1;
	Selected_Item_Qty =  0;
	State = tmp_state;
	}


}
