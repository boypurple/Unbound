/// @desc Modular Inventory System

// ============================================
// GLOBAL INVENTORY DATA
// ============================================

function InventorySystem()
{
    show_debug_message("InventorySystem");
    InventorySystemInit()
    return global.inventories
}

function InventorySystemInit()
{
    var _stack = debug_get_callstack(10); // Retrieves the last 10 execution layers
    for (var i = 0; i < array_length(_stack); i++) {
        show_debug_message(_stack[i]);
    }
    show_debug_message("InventorySystemInit");
    // Initialize inventory if not exists
    if(!global.inventoryInit)
    {
        global.inventoryMaxSlots = 10   
        global.inventories = {} // Dictionary for multi-character inventories
        global.inventoryInit = true
    }
}

// ============================================
// MULTI-CHARACTER INVENTORY MANAGEMENT
// ============================================

/// @desc Get inventory container for a specific character
/// @param _character_id ID of the character
/// @return struct with items and key_items arrays, or undefined if not found
function GetCharacterInventory(_character_id)
{
    var _char_key = string(_character_id);
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        global.inventories[$ _char_key] = {
            items: [],     // List item biasa milik karakter
            key_items: []  // List key item milik karakter
        };
    }
    return global.inventories[$ _char_key];
}

/// @desc Initialize inventory for a specific character
/// @param _character_id ID of the character to initialize inventory for
function InitializeCharacterInventory(_character_id)
{
    var _char_key = string(_character_id);
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        global.inventories[$ _char_key] = {
            items: [],
            key_items: []
        }
    }
}

/// @desc Add item to specific character's inventory
/// @param _character_id ID of the character
/// @param _item_id_string ID of the item to add
/// @param _quantity Quantity to add (optional, uses item.quantity if not specified)
/// @return true if added successfully, false otherwise
function AddItemToCharacterInventory(_character_id, _item_id_string, _quantity = 1)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        InitializeCharacterInventory(_character_id);
    }
    
    var _inv_data = global.inventories[$ _char_key];
    var _item_data = GetItemFromDatabase(_item_id_string);
    
    // Check if item already exists in inventory (for stackable items)
    if (_item_data.type == ITEM_TYPE.key_item)
    {
        for(var i = 0; i < array_length(_inv_data[$ "key_items"]); i++)
        {
            if(_inv_data[$ "key_items"][i].id == _item_id_string)
            {
                // Stack with existing item
                var _newQty = _inv_data[$ "key_items"][i].stack + _quantity
                if(_newQty <= _item_data.max_stack)
                {
                    _inv_data[$ "key_items"][i].stack = _newQty
                    // Trigger onGet event
                    if(_item_data.events.onGet != -1)
                    {
                        _item_data.events.onGet(_item_id_string, _quantity)
                    }
                    return true
                }
            }
        }
        
        // Add as new item
        var _newItem = CreateItemInventory(_item_id_string, _quantity)
        array_push(_inv_data[$ "key_items"], _newItem)
        
        // Trigger onGet event
        if(_item_data.events.onGet != -1)
        {
            _item_data.events.onGet(_item_id_string, _quantity)
        }
    }
    else
    {
        for(var i = 0; i < array_length(_inv_data[$ "items"]); i++)
        {
            if(_inv_data[$ "items"][i].id == _item_id_string)
            {
                // Stack with existing item
                var _newQty = _inv_data[$ "items"][i].stack + _quantity
                if(_newQty <= _item_data.max_stack)
                {
                    _inv_data[$ "items"][i].stack = _newQty
                    // Trigger onGet event
                    show_debug_message("AddItemToCharacterInventory: Stack with existing item {" + _item_id_string + "}" + " new quantity: " + string(_newQty));
                    if(_item_data.events.onGet != -1)
                    {
                        _item_data.events.onGet(_item_id_string, _quantity)
                    }
                    return true
                }
            }
        }
        // Check inventory space
        if(array_length(_inv_data[$ "items"]) >= global.inventoryMaxSlots)
        {
            return false // Inventory full
        }
        
        // Add as new item
        var _newItem = CreateItemInventory(_item_id_string, _quantity)
        array_push(_inv_data[$ "items"], _newItem)
    }
    
    return true
}

/// @desc Remove item from specific character's inventory
/// @param _character_id ID of the character
/// @param _itemId ID of item to remove
/// @param _quantity Quantity to remove (optional, removes all if not specified)
/// @return true if removed successfully, false otherwise
function RemoveItemFromCharacterInventory(_character_id, _itemId, _quantity = 1)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return false // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    var _item_data = GetItemFromDatabase(_itemId);

    if (_item_data.type == ITEM_TYPE.key_item)
    {
        for(var i = 0; i < array_length(_inv_data[$ "key_items"]); i++)
        {
            if(_inv_data[$ "key_items"][i].id == _itemId)
            {
                // Trigger onLose event before removal
                if(_item_data.events.onLose != -1)
                {
                    _item_data.events.onLose(_itemId, _quantity)
                }
                
                if(_quantity >= _inv_data[$ "key_items"][i].stack)
                {
                    // Remove entire item
                    array_delete(_inv_data[$ "key_items"], i, 1)
                    return true
                }
                else
                {
                    // Reduce quantity
                    _inv_data[$ "key_items"][i].stack -= _quantity
                    return true
                }
            }
        }
    }
    else
    {
        for(var i = 0; i < array_length(_inv_data[$ "items"]); i++)
        {
            if(_inv_data[$ "items"][i].id == _itemId)
            {
                // Trigger onLose event before removal
                if(_item_data.events.onLose != -1)
                {
                    _item_data.events.onLose(_itemId, _quantity)
                }
                
                if(_quantity >= _inv_data[$ "items"][i].stack)
                {
                    // Remove entire item
                    array_delete(_inv_data[$ "items"], i, 1)
                    return true
                }
                else
                {
                    // Reduce quantity
                    _inv_data[$ "items"][i].stack -= _quantity
                    return true
                }
            }
        }
    }
    return false // Item not found
}

/// @desc Check if character has item
/// @param _character_id ID of the character
/// @param _itemId ID of item to check
/// @return quantity if has item, 0 otherwise
function CharacterHasItem(_character_id, _itemId)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return 0 // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    
    for(var i = 0; i < array_length(_inv_data[$ "items"]); i++)
    {
        if(_inv_data[$ "items"][i].id == _itemId)
        {
            return _inv_data[$ "items"][i].stack
        }
    }
    return 0
}

/// @desc Get item from character's inventory by ID
/// @param _character_id ID of the character
/// @param _itemId ID of item to get
/// @return item struct if found, undefined otherwise
function GetCharacterItem(_character_id, _itemId)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return undefined // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    
    for(var i = 0; i < array_length(_inv_data[$ "items"]); i++)
    {
        if(_inv_data[$ "items"][i].id == _itemId)
        {
            return _inv_data[$ "items"][i]
        }
    }
    return undefined
}

/// @desc Get all items of specific type from character's inventory
/// @param _character_id ID of the character
/// @param _type Item type constant
/// @return array of items of specified type
function GetCharacterItemsByType(_character_id, _type)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return [] // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    var _result = []
    
    for(var i = 0; i < array_length(_inv_data[$ "items"]); i++)
    {
        if(_inv_data[$ "items"][i].type == _type)
        {
            array_push(_result, _inv_data[$ "items"][i])
        }
    }
    return _result
}

/// @desc Use item from character's inventory
/// @param _character_id ID of the character
/// @param _itemId ID of item to use
/// @param _user User using the item
/// @param _target Target of item usage
/// @return true if used successfully, false otherwise
function UseCharacterItem(_character_id, _itemId, _user, _target)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return false // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    
    for(var i = 0; i < array_length(_inv_data[$ "items"]); i++)
    {
        if(_inv_data[$ "items"][i].id == _itemId)
        {
            var _item = _inv_data[$ "items"][i]
            
            // Check if item has use event
            if(_item.events.onUse != -1)
            {
                // Execute use event
                _item.events.onUse(_item, _user, _target)
                
                // Reduce quantity or remove item
                if(_item.stack > 1)
                {
                    _item.stack--
                }
                else
                {
                    array_delete(_inv_data[$ "items"], i, 1)
                }
                
                return true
            }
            
            return false // Item not usable
        }
    }
    
    return false // Item not found
}

/// @desc Get total inventory count for character
/// @param _character_id ID of the character
/// @return total number of items in character's inventory
function GetCharacterInventoryCount(_character_id)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return 0 // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    return array_length(_inv_data[$ "items"])
}

/// @desc Get inventory space remaining for character
/// @param _character_id ID of the character
/// @return number of empty slots
function GetCharacterInventorySpaceRemaining(_character_id)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return global.inventoryMaxSlots // Character inventory doesn't exist, all slots available
    }
    
    var _inv_data = global.inventories[$ _char_key];
    return global.inventoryMaxSlots - array_length(_inv_data[$ "items"])
}

/// @desc Clear entire character's inventory
/// @param _character_id ID of the character
function ClearCharacterInventory(_character_id)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    
    // Trigger onLose events for all items
    for(var i = array_length(_inv_data[$ "items"]) - 1; i >= 0; i--)
    {
        var _item = _inv_data[$ "items"][i]
        if(_item.events.onLose != -1)
        {
            _item.events.onLose(_item.id, _item.stack)
        }
    }
    
    _inv_data[$ "items"] = []
    _inv_data[$ "key_items"] = []
}

/// @desc Sort character's inventory by item type, then by name
/// @param _character_id ID of the character
function SortCharacterInventory(_character_id)
{
    var _char_key = string(_character_id);
    
    // Initialize character inventory if not exists
    if (!variable_struct_exists(global.inventories, _char_key))
    {
        return // Character inventory doesn't exist
    }
    
    var _inv_data = global.inventories[$ _char_key];
    
    array_sort(_inv_data[$ "items"], function(_a, _b)
    {
        if(_a.type != _b.type)
        {
            return _a.type < _b.type ? -1 : 1
        }
        return _a.name < _b.name ? -1 : 1
    })
}

