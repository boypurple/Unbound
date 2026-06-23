///@description This scripts trigger the update on the draw begin event
///@param Selected_Item_Id
function inv_update_descrpition_box(argument0) {

	var tmp_selected_item = argument0;

	with(instance_create_layer(0, 0, global.Layer_Container, obj_surface_updater))
	{
	Update_Description_Box = tmp_selected_item;
	}


}
