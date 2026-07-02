if (instance_exists(obj_player)) 
{
    var _player_in_range = place_meeting(x, y, obj_player);
    
    if (_player_in_range) 
    {
        var _key_interact = keyboard_check_pressed(vk_space);
        if (_key_interact) 
        {
            InventoryAddItem(item_id_pickup,item_stack );
            instance_destroy();
        }
    }
}