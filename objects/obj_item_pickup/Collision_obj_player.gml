var _newItem = NaN

if (item_type_pickup != ITEM_TYPE_KEY)
{
	_newItem = CreateItem(
		item_id_pickup,           // Unique ID
	    display_name_pickup,         // Display name
	    description_pickup,  // Description
		item_type_pickup,
	    sprite_pickup,           // Sprite icon
	)
}
else if (item_type_pickup == ITEM_TYPE_KEY)
{
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




InventoryAddItem(_newItem);

instance_destroy(self);