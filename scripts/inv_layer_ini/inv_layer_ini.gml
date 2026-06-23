///@description Initialize all layers
function inv_layer_ini() {

	global.Layer_Floor = layer_create(0);
	global.Layer_Wall = layer_get_id("Layer_Wall"); //Already created in the IDE
	global.Layer_Container = layer_create(-200);
	global.Layer_Item = layer_create(-300);
	global.Layer_Player = layer_create(-400);
	global.Layer_Debug = layer_create(-999);

	global.Tilemap_Floor = layer_tilemap_create(global.Layer_Floor, 0, 0, ts_floor, room_width, room_height);
	global.Tilemap_Wall = layer_tilemap_create(global.Layer_Wall, 0, 0, ts_wall, room_width, room_height);


}
