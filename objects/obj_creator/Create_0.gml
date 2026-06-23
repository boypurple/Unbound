//Nothing special to say here! That object loads up all instances.

game_set_speed(60, gamespeed_fps);
randomize();
inv_macro_ini();

//Enable the use of views
view_enabled = true;

//Make view 0 visible
view_set_visible(0, true);

//Set wport and hport
view_set_wport(0, 1024);
view_set_hport(0, 768);

inv_layer_ini();

global.Camera = camera_create_view(0, 0, 1024, 768, 0, -1, -1, -1, 32, 32);
view_set_camera(0, global.Camera);


//Resize and center
window_set_rectangle((display_get_width() - view_wport[0]) * 0.5, (display_get_height() - view_hport[0]) * 0.5, view_wport[0], view_hport[0]);
surface_resize(application_surface,view_wport[0],view_hport[0]);
alarm[1] = 1; //Will centers the windows


alarm[0] = 30; //Start spawning items on the floor.


var xx, yy; //That part places floor tiles.

for (yy=0; yy<room_height/TILE_SIZE; yy++)
{
    for (xx=0; xx<room_width/TILE_SIZE; xx++)
    {
    tilemap_set_at_pixel(global.Tilemap_Floor, 1, xx*TILE_SIZE, yy*TILE_SIZE);
    }
}


//Create player and center camera on him
instance_create_layer(256, 256, global.Layer_Player, obj_player1);
instance_create_layer(320, 256, global.Layer_Player, obj_king);
camera_set_view_target(global.Camera, obj_player);
camera_set_view_border(global.Camera, 320, 320);

inv_database_ini();

/*
For each container type you need to implement in your game, dupplicate the obj_container_template object
and fill it with the desired attributes and, of course, change its name. In this current project, we have:
obj_player_backpack who represent the main inventory of the player.
obj_player_belt: A fixed inventory with some restrictions on certain cells.
obj_chest: To find treasures and store items.
*/

instance_create_layer(0, 0, global.Layer_Debug, obj_inventory);
instance_create_layer(0, 0, global.Layer_Debug, obj_player_backpack);
instance_create_layer(0, 0, global.Layer_Debug, obj_player_belt);

