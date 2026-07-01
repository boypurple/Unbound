/// @desc Variable Setup
surfMinimapBg = -1
surfMinimapEntities = -1
w = 640
h = 360
x = 608
y = 32

//Refdresh the map background
function RefreshMapBG()
{
	surfMinimapBg = surface_create(w, h)
	var _surfTemp = surface_create(room_width, room_height)
	surface_set_target(_surfTemp)
		draw_clear(c_black)
		draw_tilemap(layer_tilemap_get_id("Tiles"), 0, 0)
	surface_reset_target()
	surface_set_target(surfMinimapBg)
		draw_surface_stretched(_surfTemp, 0, 0, w, h)
	surface_reset_target()
	surface_free(_surfTemp)
}

//Initialize background
RefreshMapBG()

// Enable minimap
function MinimapEnable()
{
	visible = true
}

// Disable minimap
function MinimapDisable()
{
	visible = false
}