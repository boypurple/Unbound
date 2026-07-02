// ============================================
// ITEM TYPE DEFINITIONS
// ============================================

#macro ITEM_TYPE_KEY "key_item"
#macro ITEM_TYPE_CONSUMABLE "consumable"
#macro ITEM_TYPE_EQUIPMENT "equipment"
#macro ITEM_TYPE_MATERIAL "material"

enum ITEM_TYPE 
{
    consumable,     // Evaluates to 0
    equipment,  // Evaluates to 1
    material,    // Evaluates to 2
    key_item,    // Evaluates to 3
    COUNT
}

function ItemData(){

}