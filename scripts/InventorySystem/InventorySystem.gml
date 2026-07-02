/// @desc Modular Inventory System

// ============================================
// GLOBAL INVENTORY DATA
// ============================================

function InventorySystem()
{
    show_debug_message("InventorySystem");
    InventorySystemInit()
    return global.inventory
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
        global.inventory = []
        global.inventoryMaxSlots = 10
        global.inventoryKeyItems = [] // Separate array for key items
        global.inventoryInit = true
    }
}

// ============================================
// INVENTORY MANAGEMENT
// ============================================

/// @desc Add item to inventory
/// @param _item_id_string ID of the item to add
/// @param _quantity Quantity to add (optional, uses item.quantity if not specified)
/// @return true if added successfully, false otherwise
function InventoryAddItem(_item_id_string, _quantity = 1)
{
    //show_debug_message("InventoryAddItem: " + _item_id_string);
    var _item_data = GetItemFromDatabase(_item_id_string)

    // Check if item already exists in inventory (for stackable items)
    if (_item_data.type == ITEM_TYPE.key_item)
    {
        for(var i = 0; i < array_length(global.inventoryKeyItems); i++)
        {
            if(global.inventoryKeyItems[i].id == _item_id_string)
            {
                // Stack with existing item
                var _newQty = global.inventoryKeyItems[i].stack + _quantity
                if(_newQty <= _item_data.max_stack)
                {
                    global.inventoryKeyItems[i].stack = _newQty
                    // Trigger onGet event
                    if(global.inventoryKeyItems[i].events.onGet != -1)
                    {
                        global.inventoryKeyItems[i].events.onGet(_item_id_string, _quantity)
                    }
                    return true
                }
            }
        }

        // Add as new item
        var _newItem = CreateItemInventory(_item_id_string, _quantity)
        array_push(global.inventoryKeyItems, _newItem)

        // Trigger onGet event
        if(_item_data.events.onGet != -1)
        {
            _item_data.events.onGet(_item_id_string, _quantity)
        }
    }
    else
    {
        for(var i = 0; i < array_length(global.inventory); i++)
        {
            if(global.inventory[i].id == _item_id_string)
            {
                // Stack with existing item
                var _newQty = global.inventory[i].stack + _quantity
                if(_newQty <= _item_data.max_stack)
                {
                    global.inventory[i].stack = _newQty
                    // Trigger onGet event
                    if(global.inventory[i].events.onGet != -1)
                    {
                        global.inventory[i].events.onGet(_item_id_string, _quantity)
                    }
                    return true
                }
            }
        }
        // Check inventory space
        if(array_length(global.inventory) >= global.inventoryMaxSlots)
        {
            return false // Inventory full
        }

        // Add as new item
        var _newItem = CreateItemInventory(_item_id_string, _quantity)
        array_push(global.inventory, _newItem)
    }
    
    return true
}

/// @desc Remove item from inventory
/// @param _itemId ID of item to remove
/// @param _quantity Quantity to remove (optional, removes all if not specified)
/// @return true if removed successfully, false otherwise
function InventoryRemoveItem(_itemId, _quantity = 1)
{
    var _item_data = GetItemFromDatabase(_itemId)

    if (_item_data.type == ITEM_TYPE.key_item)
    {
        for(var i = 0; i < array_length(global.inventoryKeyItems); i++)
        {
            if(global.inventoryKeyItems[i].id == _itemId)
            {
                // Trigger onLose event before removal
                if(_item_data.events.onLose != -1)
                {
                    _item_data.events.onLose(_itemId, _quantity)
                }
                
                if(_quantity >= global.inventoryKeyItems[i].stack)
                {
                    // Remove entire item
                    array_delete(global.inventoryKeyItems, i, 1)
                    return true
                }
                else
                {
                    // Reduce quantity
                    global.inventoryKeyItems[i].stack -= _quantity
                    return true
                }
            }
        }
    }
    else
    {
        for(var i = 0; i < array_length(global.inventory); i++)
        {
            if(global.inventory[i].id == _itemId)
            {
                // Trigger onLose event before removal
                if(_item_data.events.onLose != -1)
                {
                    _item_data.events.onLose(_itemId, _quantity)
                }
                
                if(_quantity >= global.inventory[i].stack)
                {
                    // Remove entire item
                    array_delete(global.inventory, i, 1)
                    return true
                }
                else
                {
                    // Reduce quantity
                    global.inventory[i].stack -= _quantity
                    return true
                }
            }
        }
    }
    return false // Item not found
}

/// @desc Check if player has item
/// @param _itemId ID of item to check
/// @return quantity if has item, 0 otherwise
function InventoryHasItem(_itemId)
{
    for(var i = 0; i < array_length(global.inventory); i++)
    {
        if(global.inventory[i].id == _itemId)
        {
            return global.inventory[i].stack
        }
    }
    return 0
}

/// @desc Get item by ID
/// @param _itemId ID of item to get
/// @return item struct if found, undefined otherwise
function InventoryGetItem(_itemId)
{
    for(var i = 0; i < array_length(global.inventory); i++)
    {
        if(global.inventory[i].id == _itemId)
        {
            return global.inventory[i]
        }
    }
    return undefined
}

/// @desc Get all items of specific type
/// @param _type Item type constant
/// @return array of items of specified type
function InventoryGetItemsByType(_type)
{
    var _result = []
    for(var i = 0; i < array_length(global.inventory); i++)
    {
        if(global.inventory[i].type == _type)
        {
            array_push(_result, global.inventory[i])
        }
    }
    return _result
}

/// @desc Use item from inventory
/// @param _itemId ID of item to use
/// @param _user User using the item
/// @param _target Target of item usage
/// @return true if used successfully, false otherwise
function InventoryUseItem(_itemId, _user, _target)
{
    for(var i = 0; i < array_length(global.inventory); i++)
    {
        if(global.inventory[i].id == _itemId)
        {
            var _item = global.inventory[i]
            
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
                    array_delete(global.inventory, i, 1)
                }
                
                return true
            }
            
            return false // Item not usable
        }
    }
    
    return false // Item not found
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

/// @desc Get total inventory count
/// @return total number of items in inventory
function InventoryGetCount()
{
    return array_length(global.inventory)
}

/// @desc Get inventory space remaining
/// @return number of empty slots
function InventoryGetSpaceRemaining()
{
    return global.inventoryMaxSlots - array_length(global.inventory)
}

/// @desc Clear entire inventory
function InventoryClear()
{
    // Trigger onLose events for all items
    for(var i = array_length(global.inventory) - 1; i >= 0; i--)
    {
        var _item = global.inventory[i]
        if(_item.events.onLose != -1)
        {
            _item.events.onLose(_item.id, _item.stack)
        }
    }
    
    global.inventory = []
}

/// @desc Sort inventory by item type, then by name
function InventorySort()
{
    array_sort(global.inventory, function(_a, _b)
    {
        if(_a.type != _b.type)
        {
            return _a.type < _b.type ? -1 : 1
        }
        return _a.name < _b.name ? -1 : 1
    })
}
