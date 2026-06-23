///@description Draws an outline on a container surface.
function inv_container_surface_outline() {
	//I choose this method to avoid draw_rectangle.

	draw_set_color(c_black)
	var x1 = 0;
	var y1 = 0;
	var x2 = Inv_Width*Inv_Cell_Size-1;
	var y2 = Inv_Height*Inv_Cell_Size-1;
	var xf = Inv_Width*Inv_Cell_Size;
	var yf = Inv_Height*Inv_Cell_Size;
	draw_sprite_ext(spr_outline, 0, x1, y1, xf, 1, 0, c_white, 1);
	draw_sprite_ext(spr_outline, 0, x1, y1, 1, yf, 0, c_white, 1);
	draw_sprite_ext(spr_outline, 0, x1, y2, xf, 1, 0, c_white, 1);
	draw_sprite_ext(spr_outline, 0, x2, y1, 1, yf, 0, c_white, 1);


}
