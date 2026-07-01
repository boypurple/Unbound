var _newItem = NaN
show_debug_message("item_type_pickup " + string(item_type_pickup))
if (item_type_pickup == ITEM_TYPE.key_item)
{
	show_debug_message("Get Key ")
	_newItem = CreateKeyItem(
	    item_id_pickup,           // Unique ID
	    display_name_pickup,         // Display name
	    description_pickup,  // Description
	    sprite_pickup,           // Sprite icon
	    function(_item, _qty) { 
	        // onGet event - triggered when obtained
	        show_debug_message("Got " + _item.name);
	    },
	    function(_item, _qty) { 
	        // onLose event - triggered when lost
	        show_debug_message("Lost " + _item.name);
	    }
	);
}
else
{
	_newItem = CreateItem(
		item_id_pickup,           // Unique ID
	    display_name_pickup,         // Display name
	    description_pickup,  // Description
		item_type_pickup,
	    sprite_pickup,           // Sprite icon
	)
}




InventoryAddItem(_newItem);

instance_destroy(self);