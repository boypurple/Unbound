///@description This scripts triggers the update on the draw begin event
///@param container_id
function inv_update_surface(argument0) {


	var tmp_container_id = argument0;

	with(instance_create_layer(0, 0, global.Layer_Container, obj_surface_updater))
	{
	Update_Container_Id = tmp_container_id;
	}


}
