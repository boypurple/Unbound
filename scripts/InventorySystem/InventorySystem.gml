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
    show_debug_message("InventorySystemInit");
    // Initialize inventory if not exists
    if(!variable_global_exists("inventory"))
    {
        global.inventory = []
        global.inventoryMaxSlots = 10
        global.inventoryKeyItems = [] // Separate array for key items
    }
}

// ============================================
// INVENTORY MANAGEMENT
// ============================================

/// @desc Add item to inventory
/// @param _item Item struct to add
/// @param _quantity Quantity to add (optional, uses item.quantity if not specified)
/// @return true if added successfully, false otherwise
function InventoryAddItem(_item, _quantity = undefined)
{
    var _qtyToAdd = _quantity == undefined ? _item.quantity : _quantity
    
    // Check if item already exists in inventory (for stackable items)
    if(_item.type != ITEM_TYPE_KEY)
    {
        for(var i = 0; i < array_length(global.inventory); i++)
        {
            if(global.inventory[i].id == _item.id)
            {
                // Stack with existing item
                var _newQty = global.inventory[i].quantity + _qtyToAdd
                if(_newQty <= global.inventory[i].maxQuantity)
                {
                    global.inventory[i].quantity = _newQty
                    // Trigger onGet event
                    if(global.inventory[i].events.onGet != -1)
                    {
                        global.inventory[i].events.onGet(global.inventory[i], _qtyToAdd)
                    }
                    return true
                }
            }
        }

        // Add as new item
        var _newItem = _item
        _newItem.quantity = _qtyToAdd
        
        // Check inventory space
        if(array_length(global.inventory) >= global.inventoryMaxSlots)
        {
            return false // Inventory full
        }
        
        array_push(global.inventory, _newItem)
    }
    else if (_item.type == ITEM_TYPE_KEY)
    {
        // Add as new item
        var _newItem = _item
        _newItem.quantity = _qtyToAdd
        array_push(global.inventoryKeyItems, _newItem)

        // Trigger onGet event
        if(_newItem.events.onGet != -1)
        {
            _newItem.events.onGet(_newItem, _qtyToAdd)
        }
    }
    
    return true
}

/// @desc Remove item from inventory
/// @param _itemId ID of item to remove
/// @param _quantity Quantity to remove (optional, removes all if not specified)
/// @return true if removed successfully, false otherwise
function InventoryRemoveItem(_itemId, _quantity = undefined)
{
    for(var i = 0; i < array_length(global.inventory); i++)
    {
        if(global.inventory[i].id == _itemId)
        {
            var _item = global.inventory[i]
            var _qtyToRemove = _quantity == undefined ? _item.quantity : _quantity
            
            // Trigger onLose event before removal
            if(_item.events.onLose != -1)
            {
                _item.events.onLose(_item, _qtyToRemove)
            }
            
            if(_qtyToRemove >= _item.quantity)
            {
                // Remove entire item
                array_delete(global.inventory, i, 1)
                return true
            }
            else
            {
                // Reduce quantity
                _item.quantity -= _qtyToRemove
                return true
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
            return global.inventory[i].quantity
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
                if(_item.quantity > 1)
                {
                    _item.quantity--
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
            _item.events.onLose(_item, _item.quantity)
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
