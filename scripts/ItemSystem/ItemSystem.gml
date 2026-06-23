/// Supports multiple item types with event-driven architecture

// ============================================
// ITEM TYPE DEFINITIONS
// ============================================

#macro ITEM_TYPE_KEY "key_item"
#macro ITEM_TYPE_CONSUMABLE "consumable"
#macro ITEM_TYPE_EQUIPMENT "equipment"
#macro ITEM_TYPE_MATERIAL "material"

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

/// @desc Create a new Key Item
function CreateKeyItem(_id, _name, _description, _icon, _onGet = -1, _onLose = -1)
{
    return {
        id: _id,
        name: _name,
        description: _description,
        type: ITEM_TYPE_KEY,
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

function ItemSystem(){

}