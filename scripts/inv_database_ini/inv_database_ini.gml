function inv_database_ini() {
	/*
	Initializes/creates a ds_grid named: global.items.
	It will hold all items informations that you wrote on your 'database'.
	Item informations will be store like this:

	On the ds_grid Y axis you'll have each item. Their id/value will be their index on the Y axis.

	On the X axis you'll have their properties. (If you open the .csv file, you'll quickly get the idea.)

	On that project:

	index 0, on the X axis is a STRING that represent the name. On this project it's also call Item Id.
	index 1 is a REAL that represent the price of that item.
	index 2 is an ASSET on the resource tree that is the sprite of the item.
	index 3 REAL is the image_index of that sprite.
	index 4 REAL - Maximum stack size of that item.
	index 5 REAL - Level of the item (suppose that game requires an item level to set some restrictions)
	index 6 REAL - rarity
	index 7 REAL - Magic (Will be used as a boolean)
	index 8 STRING - description  (I set description in last because it requires more space on the .csv file.

	Look at the inv_macro_ini script. Macros will be used to represent those properties.

	So, when that ds_grid will be filled, if we do:

	name = global.items[# I_NAME, 0];

	name will be equal to: "Red Dust".
	A string.

	If you want the description of the the item with the name/Id 4:
	description = globals.items[# I_DESCRIPTION, 4];

	*/

	var tmp_grid = load_csv("inv_items_db.csv");//This is a new function of GMS2.

	var gw = ds_grid_width(tmp_grid);
	var gh = ds_grid_height(tmp_grid);

	global.items = ds_grid_create(gw, gh-2);

	var xx, yy;

	for(yy=2; yy<gh; yy++)
	{
		for(xx=0; xx<gw; xx++)
		{
		global.items[# xx, yy-2] = inv_item_asign_type(string(tmp_grid[# xx, yy]), string(tmp_grid[# xx, 1]));
		}
	}

	ds_grid_destroy(tmp_grid);


	/*
	Our global.items grid is ready to use. If you want to add more items, go ahead.
	You don't have to change anything in this code.















/* end inv_database_ini */
}
