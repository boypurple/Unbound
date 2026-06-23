///@description Frees surfaces used for inventory.
function inv_surfaces_free() {

	with(obj_inventory)
	{
	surface_free(Surface_Description_Box);
	}
	with(obj_parent_container)
	{
	surface_free(Surface_Container);
	}


}
