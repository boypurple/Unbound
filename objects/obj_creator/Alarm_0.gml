var max_item_val = ds_grid_height(global.items)-1; //Thats the maximum of items.
var tmp_item;
var	quantity;
var tmp_maxstack;
var x1, y1;
var t_map;

repeat(120)//120 random items on the floor
{
tmp_item = irandom_range(0, max_item_val);
tmp_maxstack = global.items[# I_MAXSTACK,tmp_item];
quantity = irandom_range(1, tmp_maxstack);

	do
	{
	x1 = irandom_range(TILE_SIZE, room_width-2*TILE_SIZE) div TILE_SIZE*TILE_SIZE+8;
	y1 = irandom_range(TILE_SIZE, room_height-2*TILE_SIZE) div TILE_SIZE*TILE_SIZE+8;
	t_map = tilemap_get_at_pixel(global.Layer_Wall, x1, y1);
	}
	until(t_map == 0)

inv_inventory_drop_item(tmp_item, quantity, x1, y1);
}


repeat(30)//30 chest will be scattered on the level
{
	do
	{
	x1 = irandom_range(TILE_SIZE, room_width-2*TILE_SIZE) div TILE_SIZE*TILE_SIZE;
	y1 = irandom_range(TILE_SIZE, room_height-2*TILE_SIZE) div TILE_SIZE*TILE_SIZE;
	t_map = tilemap_get_at_pixel(global.Layer_Wall, x1, y1);
	}
	until(t_map == 0)
	
instance_create_layer(x1, y1, global.Layer_Container, obj_chest);
}

