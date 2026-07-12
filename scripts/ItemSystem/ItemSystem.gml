/// Supports multiple item types with event-driven architecture

function ItemTypeToString(_enum_value) {
    // Array order must exactly match the enum order
    var _names = [
        "Consumable",
        "Equipment",
        "Material",
        "Key Item"
    ];
    
    // Bounds check to avoid "index out of bounds" errors
    if (_enum_value >= 0 && _enum_value < array_length(_names)) {
        return _names[_enum_value];
    }
    
    return "Unknown Item";
}

// ============================================
// ITEM STRUCTURE TEMPLATE
// ============================================
/*
Item Structure:
{
    id: "unique_item_id",
    name: "Item Name",
    description: "Item description",
    type: ITEM_TYPE_KEY, // Item type constant
    icon: sprite_index, // Sprite for inventory display
    quantity: 1, // Stackable amount (1 for key items)
    maxQuantity: 1, // Max stack size
    events: {
        onGet: function(_item, _quantity) 
		{ 
			/// triggered when obtained
		},
        onLose: function(_item, _quantity) 
		{ 
			/// triggered when lost
		},
        onUse: function(_item, _user, _target) 
		{ 
			/// triggered when used
		}
    },
    metadata: {} // Custom data for specific items
}
*/

// ============================================
// ITEM CREATION HELPERS
// ============================================
/*
/// @desc Create a new Key Item
function CreateKeyItem(_id, _name, _description, _icon, _onGet = -1, _onLose = -1)
{
    return {
        id: _id,
        name: _name,
        description: _description,
        type: ITEM_TYPE.key_item,
        icon: _icon,
        quantity: 1,
        maxQuantity: 1,
        events: {
            onGet: _onGet,
            onLose: _onLose,
            onUse: -1 // Key items typically not usable
        },
        metadata: {}
    }
}

/// @desc Create a generic item (for future item types)
function CreateItem(_id, _name, _description, _type, _icon, _quantity = 1, _maxQuantity = 99, _events = {})
{
    return {
        id: _id,
        name: _name,
        description: _description,
        type: _type,
        icon: _icon,
        quantity: _quantity,
        maxQuantity: _maxQuantity,
        events: _events,
        metadata: {}
    }
}
*/

function CreateItemInventory(_item_id_string, _quantity = 1)
{
    return {
        id: _item_id_string,
        stack: _quantity
    }
}

// Item Database

function LoadItemDatabase() {
    global.item_database = {}; 

    if (!file_exists("items_db.csv")) {
        show_debug_message("ERROR: items_db.csv tidak ditemukan!");
        return;
    }

    var _grid = load_csv("items_db.csv");
    var _grid_height = ds_grid_height(_grid);

    for (var i = 2; i < _grid_height; i++) {
        
        var _id          = ds_grid_get(_grid, 0, i); // String
        var _name        = ds_grid_get(_grid, 1, i); // String
        var _type        = real(ds_grid_get(_grid, 2, i));
        var _sell_price  = real(ds_grid_get(_grid, 3, i)); // Real
        var _sprite_s    = ds_grid_get(_grid, 4, i); // Asset (String)
        var _img_index   = real(ds_grid_get(_grid, 5, i)); // Real
        var _max_stack   = real(ds_grid_get(_grid, 6, i)); // Real
        var _level       = real(ds_grid_get(_grid, 7, i)); // Real
        var _rarity      = real(ds_grid_get(_grid, 8, i)); // Real
        var _desc        = ds_grid_get(_grid, 9, i); // String

        var _sprite_asset = asset_get_index(_sprite_s);
        if (_sprite_asset == -1) {
            _sprite_asset = sPlaceholder;
        }

        var _new_event = {
            onGet: -1,
            onLose: -1,
            onUse: -1
        };
        if (_type == ITEM_TYPE.key_item) {
            _new_event.onGet = function(_item_id, _quantity) {
                 show_debug_message("Got " + _item_id);
            };
            _new_event.onLose = function(_item_id, _quantity) {
                show_debug_message("Lost " + _item_id);
            };
            _new_event.onUse = function(_item_id, _quantity) {
                show_debug_message("Use " + _item_id);
            };
        }

        var _item_struct = {
            id: _id,
            name: _name,
            type: _type, 
            sell_price: _sell_price,
            icon: _sprite_asset,
            image_index: _img_index,
            max_stack: _max_stack,
            level: _level,
            rarity: _rarity,
            description: _desc,
            events: _new_event,
            metadata: {}
        };
        //show_debug_message("Add item to database: " + _id + " sprite: " + string(_sprite_asset));
        global.item_database[$ _id] = _item_struct;
    }

    ds_grid_destroy(_grid);
    show_debug_message("Database Item Berhasil Dimuat!");
}

function GetItemFromDatabase(_id) {
    return global.item_database[$ _id];
}

function GetRandomItemID() {
    var _item_keys = variable_struct_get_names(global.item_database);
    var _total_items = array_length(_item_keys);
    
    if (_total_items == 0) return "";

    var _random_index = irandom(_total_items - 1);
   
    return _item_keys[_random_index];
}

function SpawnItemPickup(_x, _y, _item_id) {
    instance_create_layer(_x, _y, "Instances", obj_item_pickup, {
        item_id_pickup: _item_id
    });
}

function SpawnItemPickupRandomAroundPosition(_x, _y, _item_id) {
    var _random_x = _x + random_range(-5, 5);
    var _random_y = _y + random_range(-5, 5);
    SpawnItemPickup(_random_x, _random_y, _item_id);
}
