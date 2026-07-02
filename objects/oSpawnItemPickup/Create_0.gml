amount_to_spawn = 10;          
minX = 0
maxX = 700
minY = 0
maxY = 600

repeat(amount_to_spawn)
{
    var _random_x = random_range(minX, maxX);
    var _random_y = random_range(minY, maxY);

    var _random_item_id = GetRandomItemID();

    if (_random_item_id != "")
    {
        instance_create_layer(_random_x, _random_y, "Instances", obj_item_pickup, {
            item_id_pickup: _random_item_id
        });
    }
}

instance_destroy();