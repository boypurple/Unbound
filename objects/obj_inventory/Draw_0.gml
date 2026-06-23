var vx = camera_get_view_x(global.Camera);
var vy = camera_get_view_y(global.Camera);

//That part draws all the opened containers:
var tmp_index = ds_list_size(List_Draw_Container)-1;

repeat(tmp_index+1)
{
    with(ds_list_find_value(List_Draw_Container, tmp_index))
    {
        if(Is_Open)
        {
		
            if(surface_exists(Surface_Container))
            {
            draw_surface(Surface_Container, vx+Xbox1, vy+Ybox1);
            }
            else
            {
            Surface_Container = surface_create(Inv_Width*Inv_Cell_Size, Inv_Height*Inv_Cell_Size);
			inv_update_surface(id);
            }
        }        
    }
tmp_index--;
}



//Draw the selector
if (State == "selected" && Selected_Con_Id != -1 && Selected_Con_Cell != -1) 
{
var x1 = vx+Selected_Con_Id.Xbox1+Selected_Con_Id.Array_Inv[Selected_Con_Cell,3];
var y1 = vy+Selected_Con_Id.Ybox1+Selected_Con_Id.Array_Inv[Selected_Con_Cell,4];
draw_sprite(spr_selector, 0,  x1, y1);
}


//Description box part
if ((State == "selected" || State == "drag"))
{
    if(surface_exists(Surface_Description_Box))
    {
    draw_surface(Surface_Description_Box, vx+Xbox_D, vy+Ybox_D);
    }
    else
    {
    var ww = sprite_get_width(spr_description_box);
    var hh = sprite_get_height(spr_description_box);
    Surface_Description_Box = surface_create(ww, hh);
	inv_update_descrpition_box(Selected_Item_Id);
    }  

}



//Draw the item being dragged
if (State == "drag")
{
draw_sprite(Selected_Item_Sprite, Selected_Item_Image_Index, mouse_x-8, mouse_y-8);
draw_set_font(font1);
draw_set_valign(fa_bottom);
draw_set_halign(fa_right);
draw_set_color(c_black);
draw_text(mouse_x+16, mouse_y+16, string(Selected_Item_Qty));
}

//Below it's for debug purpose
if(Debug)
{
draw_set_font(font1);
draw_set_valign(fa_bottom);
draw_set_halign(fa_left);
draw_set_color(c_orange);

draw_text(vx, vy+548, "Mouseover_Con_Id : " +string(Mouseover_Con_Id));
draw_text(vx, vy+564, "Mouseover_Con_Cell : " +string(Mouseover_Con_Cell));
draw_text(vx, vy+580, "Selected_Con_Id : " +string(Selected_Con_Id));
draw_text(vx, vy+596, "Selected_Con_Cell : " +string(Selected_Con_Cell));
draw_text(vx, vy+612, "Selected_Item_Id : " +string(Selected_Item_Id));
draw_text(vx, vy+628, "Selected_Item_Qty : " +string(Selected_Item_Qty));
draw_text(vx, vy+644, "State : " +string(State));


draw_set_font(font0);
draw_set_valign(fa_top);
draw_set_halign(fa_right);
draw_set_color(c_orange);
var text = "";
text+="TAB - DEBUG\n";
text+="I - Show/hide Backpack\n";
text+="Spacebar - Take an item or Open/Close a chest\n";
text+="Arrow - Move player\n";
text+="R - Restart Room\n";
text+="\n";
text+="--On any container--\n";
text+="Left-click - Select an item\n";
text+="Left-click again to drag\n";
text+="Alt+Left-click on selected item - Take half\n";
text+="Ctrl+Left-click to drop all items on a cell\n";
text+="Right-click on a selected item to 'use' it\n";
text+="S - Sort inventory where mouse is on\n";
text+="Z - Resize inventory where mouse is on\n";
text+="\n";
text+="--While dragging--\n";
text+="Left-click to place/swap on a cell\n";
text+="Left-click outside the box to drop on the floor\n";
text+="Right-click to place 1 on a cell\n";
text+="Right-click outside the box to drop 1 on the floor\n";
text+="Alt+Right-Click to move inventory\n";
text+="Belt stays open and has restriction\n";
draw_text(vx+camera_get_view_width(global.Camera)-16, vy+16, text);
}
