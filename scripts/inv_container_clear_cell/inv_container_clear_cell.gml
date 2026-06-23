///@description free a single container cell
///@param Container_Id
///@param Container_Cell
function inv_container_clear_cell(argument0, argument1) {

	var container = argument0;
	var con_cell = argument1;

	with(container)
	{
	Array_Inv[con_cell, 0] = -1;
	Array_Inv[con_cell, 1] = 0;
	inv_update_surface_pos(container, con_cell);
	}


}
