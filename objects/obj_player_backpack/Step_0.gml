if(keyboard_check_pressed(ord("I")))
{
Is_Open = !Is_Open;

    if(Is_Open)
    {
    inv_container_list_add(id);
    }
    else
    {
    inv_container_list_delete(id);
    }

}