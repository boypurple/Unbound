///@description This script draws all the cells of a container on its surface
///@param container_id
function inv_container_surface(argument0) {

	var container = argument0;

	with(container)
	{
		if(!surface_exists(Surface_Container))
		{
		Surface_Container = surface_create(Inv_Width*Inv_Cell_Size, Inv_Height*Inv_Cell_Size);
		}
	
	surface_set_target(Surface_Container);

	draw_clear_alpha(c_black, 0);

	gpu_set_blendmode(bm_normal);

	var cell_index, nmb_cells;

	cell_index = 0;
	nmb_cells = array_height_2d(Array_Inv);

	var x1, y1, c_val, tmp_sprite, tmp_index;

	    repeat(nmb_cells)
	    {
	    draw_sprite(spr_inventory_box, 0, Array_Inv[cell_index,3], Array_Inv[cell_index,4]); //Draw a single box. (That will be repeated many times.)
        
    
	    var c_val = Array_Inv[cell_index,0];
            
	            if (c_val != -1) //If there is an item on that cells draw its sprite and its quantity.
	            {
				tmp_sprite = global.items[# I_SPRITE, c_val];
				tmp_index = global.items[# I_IMAGE_INDEX, c_val];
				x1 = Array_Inv[cell_index,3]+8;
				y1 = Array_Inv[cell_index,4]+8;
	            draw_sprite(tmp_sprite, tmp_index, x1, y1);
			
	            draw_set_color(c_black);
	            draw_set_font(font1);
	            draw_set_valign(fa_bottom);
	            draw_set_halign(fa_right);
				//You may adjust those variables under to fits with your fonts.
				x1 = Array_Inv[cell_index,3]+Inv_Cell_Size-1;
				y1 = Array_Inv[cell_index,4]+Inv_Cell_Size+5;
	            draw_text(x1, y1, Array_Inv[cell_index,1]);
	            }
    
	    cell_index += 1;
	    }
	
	//That part draws an outline around each container surface.    
	inv_container_surface_outline();


	surface_reset_target();
	}


}
