var _newKeyItem = CreateKeyItem(
    "test_key_item",           // Unique ID
    "Key Item",         // Display name
    "This is a Key Item",  // Description
    sGoods,           // Sprite icon
    function(_item, _qty) { 
        // onGet event - triggered when obtained
        show_debug_message("Got " + _item.name);
    },
    function(_item, _qty) { 
        // onLose event - triggered when lost
        show_debug_message("Lost " + _item.name);
    }
);

InventoryAddItem(_newKeyItem);

instance_destroy(self);