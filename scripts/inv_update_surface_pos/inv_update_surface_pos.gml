///@description This scripts triggers the update on the draw begin event
///@param container_id
///@param Cell_Index
function inv_update_surface_pos(argument0, argument1) {

	var tmp_container_id = argument0;
	var tmp_cell_index = argument1;

	with(instance_create_layer(0, 0, global.Layer_Container, obj_surface_updater))
	{
	Update_Container_Id = tmp_container_id;
	Update_Cell_Index = tmp_cell_index;
	}



}
