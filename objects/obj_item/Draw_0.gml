//Draws the last item listed on the list.
if(Item_Value != -1)
{
draw_sprite(Item_Sprite, Item_Image_Index, x, y);

	if(position_meeting(mouse_x, mouse_y, id))
	{
	var name = global.items[# I_NAME, Item_Value];
	var text = name+" ("+string(Item_Quantity)+")\n"+Info;
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_font(font1);
	draw_text(mouse_x, mouse_y-16, text);
	}
}