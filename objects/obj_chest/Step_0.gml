if (Is_Activated)
{
Is_Open = !Is_Open;

    if(Is_Open)//Opens the chest
    {
    image_index = 1;
    inv_container_list_add(id);
	
		with(obj_player_backpack)//That opens the backpack if it's not already open.
		{
		    if(!Is_Open)
		    {
			Is_Open = !Is_Open;
		    inv_container_list_add(id);
		    }
		}
    }
    else //closes the chest
    {
    image_index = 0;
    inv_container_list_delete(id);
		
		with(obj_player_backpack)//That closes the backpack if it's open.
		{
			if(Is_Open)
		    {
			Is_Open = !Is_Open;
		    inv_container_list_delete(id);
		    }
		}
    }

Is_Activated = 0;
}

if(Is_Open)
{
var col_player = place_meeting(x, y, obj_player);

    if(!col_player)
    {
    Is_Activated = 1;
    }
}