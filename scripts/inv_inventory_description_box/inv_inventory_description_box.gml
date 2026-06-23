///@description This event draws/updates the description box of an item.
///@param Selected_Item_Id
function inv_inventory_description_box(argument0) {

	var item_id = argument0;

	if (item_id == -1)
	{
	exit;
	}


	with(obj_inventory)
	{
		if(!surface_exists(Surface_Description_Box))
		{
		var ww = sprite_get_width(spr_description_box);
		var hh = sprite_get_height(spr_description_box);
		Surface_Description_Box = surface_create(ww, hh);
		}
	
	surface_set_target(Surface_Description_Box);
	draw_clear_alpha(c_black, 0);
	gpu_set_blendmode(bm_normal);

	draw_sprite(spr_description_box, 0, 0, 0);

	draw_set_color(c_black);
	draw_set_font(font0);

	var name, picture, i_index, price, level, rarity, magic, description;
	name = global.items[# I_NAME, item_id];
	price = global.items[# I_PRICE, item_id];
	picture = global.items[# I_SPRITE, item_id];
	i_index = global.items[# I_IMAGE_INDEX, item_id];
	level = global.items[# I_LEVEL, item_id];
	rarity = global.items[# I_RARITY, item_id];
	magic = global.items[# I_MAGIC, item_id];
	description = global.items[# I_DESCRIPTION, item_id];
    
	    if (magic)
	    {
	    magic = "Magical item";
	    }
	    else
	    {
	    magic = "Common item";
	    }
    

	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);
	draw_text(128, 16, name);
	draw_sprite_ext(picture, i_index, 112, 24, 2, 2, 0, c_white, 1);

	draw_set_halign(fa_left);
	draw_text(4, 80, "Price: "+string(price)+" gold.");
	draw_text(4, 96, "Level: "+string(level));
	draw_text(4, 112, "Rarity: "+string(rarity));
	draw_text(4, 128, "Type: "+string(magic));

	draw_set_halign(fa_center);
	draw_text_ext(128, 196, description, 16, 248);


	surface_reset_target();
	}








}
