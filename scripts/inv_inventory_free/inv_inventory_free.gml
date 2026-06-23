///@description Called when you quit a room or restart the game.
///@param global.items destroy global.items grid boolean
function inv_inventory_free(argument0) {

	if(argument0)
	{
	ds_grid_destroy(global.items);
	}

	with(obj_inventory)
	{
	ds_list_destroy(List_Draw_Container);
	}


	inv_surfaces_free();

	with(obj_item)
	{
	ds_list_destroy(List[0]);
	ds_list_destroy(List[1]);
	}

	camera_destroy(global.Camera);

	layer_destroy(global.Layer_Floor);
	layer_destroy(global.Layer_Container);
	layer_destroy(global.Layer_Item);
	layer_destroy(global.Layer_Player);
	layer_destroy(global.Layer_Debug);
	layer_tile_destroy(global.Tilemap_Floor);
	layer_tile_destroy(global.Tilemap_Wall);


}
