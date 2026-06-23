///@description Use this script on empty container. Ideally when it's created.
///@param Container_Id
///@param Container Cell
///@param Restriction(string)
function inv_container_cell_set_restriction(argument0, argument1, argument2) {

	var container = argument0;
	var con_cell = argument1;
	var restriction = argument2;

	with(container)
	{
	Array_Inv[con_cell,2] = restriction;
	}



}
