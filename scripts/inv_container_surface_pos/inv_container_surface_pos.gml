///@description This script draws a single cell of a container on its surface
///@param Container_Id
///@param Cell_Index
function inv_container_surface_pos(argument0, argument1) {

	var container = argument0;
	var con_cell = argument1;
	var x1, y1, tmp_sprite, tmp_index, c_val;

	with(container)
	{
		if(!surface_exists(Surface_Container))
		{
		//Here we have lost the surface, so we draw it all, not just a single cell.
		inv_update_surface(container);
		exit;//No need to run the code under, we exit here.
		}
	
	surface_set_target(Surface_Container);

	gpu_set_blendmode(bm_normal);

	draw_sprite(spr_inventory_box, 0, Array_Inv[con_cell,3], Array_Inv[con_cell,4]); //Draw a single box.
        
	c_val = Array_Inv[con_cell,0];
            
	    if (c_val != -1) //If there is an item on that cells draw its sprite and its quantity.
	    {
		tmp_sprite = global.items[# I_SPRITE, c_val];
		tmp_index = global.items[# I_IMAGE_INDEX, c_val];
		x1 = Array_Inv[con_cell,3]+8;
		y1 = Array_Inv[con_cell,4]+8;
	    draw_sprite(tmp_sprite, tmp_index, x1,  y1);
	
	    draw_set_color(c_black);
	    draw_set_font(font1);
	    draw_set_valign(fa_bottom);
	    draw_set_halign(fa_right);
		//You may adjust those variables under to fits with your fonts.
		x1 = Array_Inv[con_cell,3]+Inv_Cell_Size-1;
		y1 = Array_Inv[con_cell,4]+Inv_Cell_Size+5;
	    draw_text(x1, y1, Array_Inv[con_cell,1]);
	    }
       
	//That part draws an outline around each container surface.
	inv_container_surface_outline();


	surface_reset_target();
	}


}
